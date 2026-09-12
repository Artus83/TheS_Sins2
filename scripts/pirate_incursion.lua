-- Incursion Wave System
-- Supply-budgeted mandatory and weighted ship composition.
-- The last configured wave repeats indefinitely.

local EventMetadata = require("event_metadata")

function Get_event_metadata()
    local metadata = EventMetadata.create()

    metadata.event_name = "pirate_incursion"
    metadata.event_id = "pirate_incursion_v1"

    metadata.register_event_function = "Pirate_incursion_register"
    metadata.on_event_registered_function = "Pirate_incursion_on_event_registered"
    metadata.on_initialize_function = "Pirate_incursion_initialize"
    metadata.should_trigger_function = "Pirate_incursion_should_trigger"
    metadata.on_start_function = "Pirate_incursion_on_start"
    metadata.on_update_function = "Pirate_incursion_on_update"
    metadata.on_complete_function = "Pirate_incursion_on_complete"
    metadata.on_cancel_function = "Pirate_incursion_on_cancel"
    metadata.on_teardown_function = "Pirate_incursion_on_teardown"

    metadata.trigger_check_interval_seconds = 1.0
    metadata.update_interval_seconds = 1.0
    metadata.on_update_function_initial_delay = 0.0

    metadata.event_version = 1.0
    metadata.description = "Supply-budgeted incursion wave system"
    metadata.author = "TheS"
    metadata.priority = 50.0
    metadata.incompatible_event_ids = {"test_event_v1"}
    metadata.max_concurrent_instances = 1

    return metadata
end

local CONFIG = {
    wave_interval_seconds = 20.0,
    hyperspace_arrival_delay_seconds = 10.0,
    wave_timer = "incursion_wave_spawn_timer",
    recent_unit_slots_per_player = 96,

    -- Spawned wave units are uncontrollable and do not consume normal fleet supply.
    special_operation_kind = "trade_escort",

    -- Runtime player.race -> faction ship-role mapping.
    factions = {
        trader_incursion = {
            name = "tec",
            ships = {
                colony_capital_ship = "trader_colony_capital_ship",
                carrier_cruiser = "trader_carrier_cruiser",
                heavy_cruiser = "trader_heavy_cruiser"
            }
        },
        advent_incursion = {
            name = "advent",
            ships = {
                colony_capital_ship = "advent_colony_capital_ship",
                carrier_cruiser = "advent_carrier_cruiser",
                heavy_cruiser = "advent_heavy_cruiser"
            }
        },
        vasari_incursion = {
            name = "vasari",
            ships = {
                colony_capital_ship = "vasari_colony_capital_ship",
                carrier_cruiser = "vasari_carrier_cruiser",
                heavy_cruiser = "vasari_heavy_cruiser"
            }
        },
        dlc3_herald_incursion = {
            name = "eidolon",
            ships = {
                colony_capital_ship = "dlc3_herald_colony_capital_ship",
                carrier_cruiser = "dlc3_herald_carrier_cruiser"
                -- No dlc3_herald_heavy_cruiser exists in current game data.
            }
        }
    },

    -- Hard supply budget per wave. The last configured wave repeats indefinitely.
    waves = {
        {
            supply = 75,
            mandatory = {
                { role = "colony_capital_ship", count = 1 }
            }
        },
        {
            supply = 150,
            mandatory = {
                { role = "colony_capital_ship", count = 1 }
            }
        },
        {
            supply = 300,
            mandatory = {
                { role = "colony_capital_ship", count = 1 }
            }
        }
    },

    -- Candidate weights are relative. Equal weights produce roughly equal ship counts.
    possible_ships = {
        { role = "carrier_cruiser", unlock_wave = 1, weight = 1 },
        { role = "heavy_cruiser", unlock_wave = 3, weight = 1 }
    }
}

local function debug_print(message)
    print("[faction_wave_test] " .. tostring(message))
end

local function set_status(context, text)
    context.instance.status_text = tostring(text or "")
    debug_print(context.instance.status_text)
end

local function player_state_key(prefix, player_index)
    return prefix .. tostring(player_index)
end

local function recent_unit_key(player_index, slot)
    return "recent_unit_" .. tostring(player_index) .. "_" .. tostring(slot)
end

local function get_faction_definition(race)
    if race == nil then
        return nil
    end

    return CONFIG.factions[tostring(race)]
end

local function is_wave_enabled_for_race(race)
    local faction = get_faction_definition(race)
    return faction ~= nil, faction
end

local function get_wave_definition(wave_number)
    if #CONFIG.waves == 0 then
        return nil, nil
    end

    local wave_index = math.min(wave_number, #CONFIG.waves)
    return CONFIG.waves[wave_index], wave_index
end

local function get_ship_type(faction, role)
    if faction == nil or faction.ships == nil or role == nil then
        return nil
    end

    return faction.ships[role]
end

local function get_ship_supply_cost(context, unit_type)
    if unit_type == nil then
        return nil
    end

    local cost = context.simulation:get_unit_supply_cost(unit_type)
    if cost == nil or cost <= 0 then
        return nil
    end

    return cost
end

local function make_spawn_options(ship_spec)
    local options = spawn_unit_options.new()

    if ship_spec.level ~= nil then
        options.level = math.max(0, ship_spec.level - 1)
    end

    if ship_spec.items ~= nil then
        for _, item_name in ipairs(ship_spec.items) do
            options:add_item(item_name)
        end
    end

    return options
end

local function get_living_playable_player_indices(context)
    return context.simulation:filter_playable_players(function(player)
        return not player.is_npc and not player.has_lost
    end)
end

local function get_home_gravity_well(context, player_index)
    local player = context.simulation:get_player_by_player_index(player_index)
    if player == nil then
        return nil
    end

    local owned_wells = context.simulation:get_gravity_wells_owned_by_player_index(player_index)
    if owned_wells == nil or #owned_wells == 0 then
        return nil
    end

    if player.home_planet ~= nil then
        for _, well in ipairs(owned_wells) do
            local primary_fixture = context.simulation:get_gravity_well_primary_fixture(well)
            if primary_fixture ~= nil and primary_fixture.id == player.home_planet.id then
                return well
            end
        end
    end

    return owned_wells[1]
end

-- Same principle as the working Pirate Incursion test:
-- choose another living playable player with the highest economic score.
-- Actual combat friend/foe remains normal ownership/diplomacy behavior.
local function find_target_player_index(context, attacker_player_index)
    local eligible_indices = context.simulation:filter_playable_players(function(player)
        if player.is_npc or player.has_lost then
            return false
        end

        return player.player_index ~= attacker_player_index
    end)

    local best_player_index = nil
    local best_score = -1

    for _, player_index in ipairs(eligible_indices) do
        local player = context.simulation:get_player_by_player_index(player_index)
        if player ~= nil then
            local score = player.economic_score or 0
            if score > best_score then
                best_score = score
                best_player_index = player_index
            end
        end
    end

    return best_player_index
end

local function select_target_well(context, target_player_index, source_well)
    if target_player_index == nil then
        return nil
    end

    local target_wells = context.simulation:get_gravity_wells_owned_by_player_index(target_player_index)
    if target_wells == nil or #target_wells == 0 then
        return nil
    end

    if source_well ~= nil then
        local closest_wells = context.simulation:get_closest_gravity_wells(source_well, target_wells)
        if closest_wells ~= nil and #closest_wells > 0 then
            return closest_wells[1]
        end
    end

    return target_wells[1]
end

local function clear_target_for_player(context, attacker_player_index)
    context.instance[player_state_key("target_player_", attacker_player_index)] = nil
    context.instance[player_state_key("target_well_", attacker_player_index)] = nil
end

local function ensure_target_for_player(context, attacker_player_index, source_well)
    local target_player_key = player_state_key("target_player_", attacker_player_index)
    local target_well_key = player_state_key("target_well_", attacker_player_index)

    local target_player_index = context.instance[target_player_key]
    local target_player = nil

    if target_player_index ~= nil then
        target_player = context.simulation:get_player_by_player_index(target_player_index)
    end

    if target_player == nil or target_player.has_lost then
        target_player_index = find_target_player_index(context, attacker_player_index)
        context.instance[target_player_key] = target_player_index
        context.instance[target_well_key] = nil
    end

    if target_player_index == nil then
        return nil, nil
    end

    local target_well_id = context.instance[target_well_key]
    if target_well_id == nil then
        local target_well = select_target_well(context, target_player_index, source_well)
        if target_well ~= nil then
            target_well_id = target_well.id
            context.instance[target_well_key] = target_well_id
        end
    end

    return target_player_index, target_well_id
end

local function order_unit_to_target(context, unit_id, target_well_id)
    if target_well_id == nil then
        return false
    end

    context.simulation:set_unit_auto_order_mode_by_id(unit_id, "engage_any_targets")

    return context.simulation:issue_move_order_by_id(
        unit_id,
        target_well_id,
        {
            ai_override = "never",
            clear_orders = true
        }
    )
end

local function store_recent_unit(context, player_index, unit_id)
    local slot_key = player_state_key("recent_slot_", player_index)
    local slot = (context.instance[slot_key] or 0) + 1

    if slot > CONFIG.recent_unit_slots_per_player then
        slot = 1
    end

    context.instance[slot_key] = slot
    context.instance[recent_unit_key(player_index, slot)] = unit_id
end

local function retarget_recent_units(context, player_index, target_well_id)
    if target_well_id == nil then
        return
    end

    for slot = 1, CONFIG.recent_unit_slots_per_player do
        local key = recent_unit_key(player_index, slot)
        local unit_id = context.instance[key]

        if unit_id ~= nil then
            if context.simulation:does_unit_exist_by_id(unit_id) then
                order_unit_to_target(context, unit_id, target_well_id)
            else
                context.instance[key] = nil
            end
        end
    end
end

local function spawn_one_ship(context, player_index, spawn_well_id, target_well_id, unit_type, ship_spec)
    local spawn_def = spawn_units_definition.new()
    spawn_def:add_required_units(unit_type, 1, make_spawn_options(ship_spec))

    local spawned_units = context.simulation:create_units_by_id(
        spawn_def,
        nil,
        spawn_well_id,
        player_index,
        float3.new(0.0, 0.0, 0.0),
        true,
        CONFIG.hyperspace_arrival_delay_seconds,
        nil,
        CONFIG.special_operation_kind
    )

    if spawned_units == nil or #spawned_units == 0 then
        return nil
    end

    local unit = spawned_units[1]

    -- One composition entry is exactly one ship.
    for extra_index = 2, #spawned_units do
        context.simulation:despawn_unit_by_id(spawned_units[extra_index].id)
    end

    store_recent_unit(context, player_index, unit.id)
    order_unit_to_target(context, unit.id, target_well_id)

    return unit
end

local function build_eligible_weight_pool(context, faction, wave_number, remaining_supply)
    local pool = {}

    for _, candidate in ipairs(CONFIG.possible_ships) do
        if wave_number >= (candidate.unlock_wave or 1) then
            local unit_type = get_ship_type(faction, candidate.role)
            local supply_cost = get_ship_supply_cost(context, unit_type)

            if unit_type ~= nil and supply_cost ~= nil and supply_cost <= remaining_supply then
                local weight = math.max(1, math.floor(candidate.weight or 1))

                for _ = 1, weight do
                    pool[#pool + 1] = {
                        spec = candidate,
                        unit_type = unit_type,
                        supply_cost = supply_cost
                    }
                end
            end
        end
    end

    -- Deterministic shuffle. A weight-cycle keeps equal weights relatively even per wave.
    for i = #pool, 2, -1 do
        local j = context.random_integer(1, i)
        pool[i], pool[j] = pool[j], pool[i]
    end

    return pool
end

local function update_hud(context)
    local now = context.simulation.current_time
    local remaining = math.max(0, (context.instance.next_wave_time or now) - now)
    local seconds = math.ceil(remaining)
    local next_wave_number = (context.instance.wave_number or 0) + 1
    local next_wave = get_wave_definition(next_wave_number)
    local next_supply = next_wave ~= nil and next_wave.supply or 0

    context.simulation:display_text("timer_label", "Next Incursion Wave")
    context.simulation:display_text("timer_value", string.format("0:%02d", seconds))
    context.simulation:display_text("progress_label", "Next Wave")

    local value =
        "Wave " .. tostring(next_wave_number)
        .. " | " .. tostring(next_supply) .. " supply"

    if context.instance.status_text ~= nil and context.instance.status_text ~= "" then
        value = value .. " | " .. context.instance.status_text
    end

    context.simulation:display_text("progress_value", value)
end

function Pirate_incursion_wave_spawn_callback(context)
    context.instance.wave_number = (context.instance.wave_number or 0) + 1

    local wave_number = context.instance.wave_number
    local wave, wave_index = get_wave_definition(wave_number)
    context.instance.next_wave_time = context.simulation.current_time + CONFIG.wave_interval_seconds

    if wave == nil then
        set_status(context, "no wave configuration")
        return
    end

    local success, error_message = pcall(function()
        local playable_indices = get_living_playable_player_indices(context)
        local spawned_wave = false

        for _, player_index in ipairs(playable_indices) do
            local player = context.simulation:get_player_by_player_index(player_index)

            if player ~= nil then
                local enabled, faction = is_wave_enabled_for_race(player.race)

                if enabled and faction ~= nil then
                    local spawn_well = get_home_gravity_well(context, player_index)

                    if spawn_well ~= nil then
                        local _, target_well_id = ensure_target_for_player(context, player_index, spawn_well)

                        if target_well_id ~= nil then
                            local supply_budget = wave.supply or 0
                            local supply_used = 0
                            local spawned_count = 0
                            local composition = {}

                            -- Mandatory ships consume budget first.
                            for _, mandatory in ipairs(wave.mandatory or {}) do
                                local unit_type = get_ship_type(faction, mandatory.role)
                                local supply_cost = get_ship_supply_cost(context, unit_type)
                                local count = mandatory.count or 1

                                if unit_type == nil then
                                    error(
                                        "mandatory role '" .. tostring(mandatory.role)
                                        .. "' has no unit mapping for " .. tostring(faction.name)
                                    )
                                end

                                if supply_cost == nil then
                                    error("could not read supply cost for " .. tostring(unit_type))
                                end

                                for _ = 1, count do
                                    if supply_used + supply_cost > supply_budget then
                                        error(
                                            "mandatory ships exceed wave budget: "
                                            .. tostring(supply_used + supply_cost)
                                            .. " > " .. tostring(supply_budget)
                                        )
                                    end

                                    local unit = spawn_one_ship(
                                        context,
                                        player_index,
                                        spawn_well.id,
                                        target_well_id,
                                        unit_type,
                                        mandatory
                                    )

                                    if unit == nil then
                                        error("failed to spawn mandatory ship " .. tostring(unit_type))
                                    end

                                    supply_used = supply_used + supply_cost
                                    spawned_count = spawned_count + 1
                                    composition[unit_type] = (composition[unit_type] or 0) + 1
                                end
                            end

                            -- Fill remaining budget from the weighted candidate list.
                            local weighted_pool = {}
                            local pool_index = 1

                            while supply_used < supply_budget do
                                local remaining_supply = supply_budget - supply_used

                                if pool_index > #weighted_pool then
                                    weighted_pool = build_eligible_weight_pool(
                                        context,
                                        faction,
                                        wave_number,
                                        remaining_supply
                                    )
                                    pool_index = 1
                                end

                                if #weighted_pool == 0 then
                                    break
                                end

                                local choice = weighted_pool[pool_index]
                                pool_index = pool_index + 1

                                if choice.supply_cost <= (supply_budget - supply_used) then
                                    local unit = spawn_one_ship(
                                        context,
                                        player_index,
                                        spawn_well.id,
                                        target_well_id,
                                        choice.unit_type,
                                        choice.spec
                                    )

                                    if unit == nil then
                                        error("failed to spawn weighted ship " .. tostring(choice.unit_type))
                                    end

                                    supply_used = supply_used + choice.supply_cost
                                    spawned_count = spawned_count + 1
                                    composition[choice.unit_type] = (composition[choice.unit_type] or 0) + 1
                                else
                                    weighted_pool = {}
                                    pool_index = 1
                                end
                            end

                            local composition_parts = {}

                            for unit_type, count in pairs(composition) do
                                composition_parts[#composition_parts + 1] =
                                    tostring(unit_type) .. " x" .. tostring(count)
                            end

                            table.sort(composition_parts)

                            local repeated_suffix = ""
                            if wave_number > #CONFIG.waves then
                                repeated_suffix = " (repeating wave " .. tostring(wave_index) .. ")"
                            end

                            set_status(
                                context,
                                "wave " .. tostring(wave_number) .. repeated_suffix
                                .. " | " .. tostring(supply_used) .. "/" .. tostring(supply_budget) .. " supply"
                                .. " | " .. tostring(spawned_count) .. " ships"
                                .. " | " .. table.concat(composition_parts, ", ")
                            )

                            spawned_wave = true

                            -- Exactly one incursion wave per timer tick.
                            break
                        end
                    end
                end
            end
        end

        if not spawned_wave then
            set_status(context, "no valid incursion player/target")
        end
    end)

    if not success then
        set_status(context, "SPAWN ERROR: " .. tostring(error_message))
    end

    local hud_success, hud_error = pcall(function()
        update_hud(context)
    end)

    if not hud_success then
        debug_print("HUD ERROR: " .. tostring(hud_error))
    end
end

local function update_player_target_progress(context, attacker_player_index)
    local attacker = context.simulation:get_player_by_player_index(attacker_player_index)

    if attacker == nil or attacker.has_lost then
        clear_target_for_player(context, attacker_player_index)
        return
    end

    local enabled = is_wave_enabled_for_race(attacker.race)
    if not enabled then
        clear_target_for_player(context, attacker_player_index)
        return
    end

    local target_player_key = player_state_key("target_player_", attacker_player_index)
    local target_well_key = player_state_key("target_well_", attacker_player_index)

    local target_player_index = context.instance[target_player_key]
    local target_well_id = context.instance[target_well_key]

    if target_player_index == nil or target_well_id == nil then
        local source_well = get_home_gravity_well(context, attacker_player_index)
        local _, new_target_well_id = ensure_target_for_player(context, attacker_player_index, source_well)

        if new_target_well_id ~= nil then
            retarget_recent_units(context, attacker_player_index, new_target_well_id)
        end

        return
    end

    local target_player = context.simulation:get_player_by_player_index(target_player_index)

    if target_player == nil or target_player.has_lost then
        clear_target_for_player(context, attacker_player_index)

        local source_well = get_home_gravity_well(context, attacker_player_index)
        local _, new_target_well_id = ensure_target_for_player(context, attacker_player_index, source_well)

        if new_target_well_id ~= nil then
            retarget_recent_units(context, attacker_player_index, new_target_well_id)
        end

        return
    end

    local target_well = context.simulation:get_unit_by_id(target_well_id)

    if target_well == nil then
        context.instance[target_well_key] = nil

        local source_well = get_home_gravity_well(context, attacker_player_index)
        local _, new_target_well_id = ensure_target_for_player(context, attacker_player_index, source_well)

        if new_target_well_id ~= nil then
            retarget_recent_units(context, attacker_player_index, new_target_well_id)
        end

        return
    end

    local primary_fixture = context.simulation:get_gravity_well_primary_fixture(target_well)
    local still_owned = false

    if primary_fixture ~= nil then
        local owner = context.simulation:get_unit_owner(primary_fixture)
        still_owned = owner ~= nil and owner.player_index == target_player_index
    end

    local cleared = not context.simulation:does_gravity_well_contain_player_units_by_player_index(
        target_well,
        target_player_index
    )

    if (not still_owned) and cleared then
        local new_target_well = select_target_well(context, target_player_index, target_well)

        if new_target_well ~= nil then
            context.instance[target_well_key] = new_target_well.id
            retarget_recent_units(context, attacker_player_index, new_target_well.id)
        else
            clear_target_for_player(context, attacker_player_index)

            local _, next_target_well_id = ensure_target_for_player(
                context,
                attacker_player_index,
                target_well
            )

            if next_target_well_id ~= nil then
                retarget_recent_units(context, attacker_player_index, next_target_well_id)
            end
        end
    end
end

local function update_all_target_progress(context)
    local playable_indices = get_living_playable_player_indices(context)

    for _, player_index in ipairs(playable_indices) do
        update_player_target_progress(context, player_index)
    end
end

function Pirate_incursion_register(context)
    context.simulation:display_text("timer_label", "FACTION WAVE TEST LOADED")
    context.simulation:display_text("timer_value", "register() called")

    debug_print("register() called")
    return true
end

function Pirate_incursion_on_event_registered(context)
    debug_print("on_event_registered() called")
end

function Pirate_incursion_initialize(context)
    debug_print("initialize() called for instance " .. tostring(context.instance_id))
    context.instance.ready_to_trigger = (context.active_instance_count == 0)
end

function Pirate_incursion_should_trigger(context)
    return context.instance.ready_to_trigger == true
end

function Pirate_incursion_on_start(context)
    debug_print("on_start() called")

    context.instance.ready_to_trigger = false
    context.instance.wave_number = 0
    context.instance.status_text = "waiting for wave 1 (75 supply)"
    context.instance.next_wave_time = context.simulation.current_time + CONFIG.wave_interval_seconds

    context.timers.register({
        name = CONFIG.wave_timer,
        interval_seconds = CONFIG.wave_interval_seconds,
        on_complete = "Pirate_incursion_wave_spawn_callback",
        is_repeating = true
    })

    update_hud(context)
end

function Pirate_incursion_on_update(context)
    local success, error_message = pcall(function()
        update_hud(context)
        update_all_target_progress(context)
    end)

    if not success then
        debug_print("UPDATE ERROR: " .. tostring(error_message))

        pcall(function()
            set_status(context, "UPDATE ERROR: " .. tostring(error_message))
        end)
    end
end

function Pirate_incursion_on_complete(context)
    debug_print("on_complete() called")
end

function Pirate_incursion_on_cancel(context)
    debug_print("on_cancel() called")
end

function Pirate_incursion_on_teardown(context)
    debug_print("on_teardown() called")

    context.simulation:display_text("timer_label", "")
    context.simulation:display_text("timer_value", "")
    context.simulation:display_text("progress_label", "")
    context.simulation:display_text("progress_value", "")
end
