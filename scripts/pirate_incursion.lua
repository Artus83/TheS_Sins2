-- Incursion Wave System
-- Supply-budgeted mandatory and weighted ship composition.

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
    debug_hud = false,
    wave_interval_seconds = 900.0,
    hyperspace_arrival_delay_seconds = 10.0,
    wave_timer = "incursion_wave_spawn_timer",
    special_operation_kind = "trade_escort",

    -- Low-cost group stuck watchdog. Checks only two living ships per wave.
    stuck_check_interval_seconds = 15.0,
    stuck_timeout_seconds = 60.0,
    stuck_sample_size = 2,

    supply_start = 100,
    supply_end = 2400,
    supply_end_time = 8100,

    level_timeline = {
        { time = 0,    level = 3 },
        { time = 900,  level = 4 },
        { time = 2700, level = 5 },
        { time = 5400, level = 6 }
    },

    elite_events = {
        { time = 2700, elite = 1 },
        { time = 6300, elite = 2 }
    },

    ship_artifacts = {
        "exoforce_matrix_ship_artifact",
        "kinetic_intensifier_ship_artifact",
        "mass_negation_core_ship_artifact",
        "power_core_relic_ship_artifact",
        "resilient_metaloids_ship_artifact",
        "weapon_symbiote_ship_artifact"
    },

    elite_waves = {
        [1] = {
            trader_incursion = {
                { unit = "dlc2_trader_loyalist_super_capital_ship", count = 1, random_ship_artifact = true },
                { unit = "trader_battle_capital_ship", count = 2 }
            },
            advent_incursion = {
                { unit = "dlc2_advent_loyalist_super_capital_ship", count = 1, random_ship_artifact = true },
                { unit = "advent_battle_capital_ship", count = 2 }
            },
            vasari_incursion = {
                { unit = "dlc2_vasari_loyalist_super_capital_ship", count = 1, random_ship_artifact = true },
                { unit = "vasari_battle_capital_ship", count = 2 }
            },
            dlc3_herald_incursion = {
                { unit = "dlc3_herald_super_capital_ship", count = 1, random_ship_artifact = true },
                { unit = "dlc3_herald_battle_capital_ship", count = 2 }
            }
        },
        [2] = {
            trader_incursion = {
                { unit = "trader_loyalist_titan", count = 1, random_ship_artifact = true },
                { unit = "dlc2_trader_loyalist_super_capital_ship", count = 2 }
            },
            advent_incursion = {
                { unit = "advent_loyalist_titan", count = 1, random_ship_artifact = true },
                { unit = "dlc2_advent_loyalist_super_capital_ship", count = 2 }
            },
            vasari_incursion = {
                { unit = "vasari_loyalist_titan", count = 1, random_ship_artifact = true },
                { unit = "dlc2_vasari_loyalist_super_capital_ship", count = 2 }
            },
            dlc3_herald_incursion = {
                { unit = "dlc3_herald_titan", count = 1, random_ship_artifact = true },
                { unit = "dlc3_herald_battle_capital_ship", count = 6 }
            }
        }
    },

    factions = {
        trader_incursion = {
            name = "tec",
            mandatory_ships = {
                { unit = "trader_colony_capital_ship", count = 1 }
            },
            possible_ships = {
                { unit = "trader_carrier_cruiser", unlock_time = 900, weight = 32 },
                { unit = "trader_heavy_cruiser", unlock_time = 0, weight = 56 },
                { unit = "trader_command_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "trader_long_range_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "trader_medium_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "trader_robotics_cruiser", unlock_time = 1800, weight = 40 },
                { unit = "trader_torpedo_cruiser", unlock_time = 2700, weight = 32 },
                { unit = "trader_battle_capital_ship", unlock_time = 1800, weight = 12 },
                { unit = "trader_carrier_capital_ship", unlock_time = 1800, weight = 8 },
                { unit = "trader_colony_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "trader_siege_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "trader_support_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "dlc2_trader_loyalist_super_capital_ship", unlock_time = 5400, weight = 2 },
                { unit = "dlc2_trader_rebel_super_capital_ship", unlock_time = 5400, weight = 2 },
                { unit = "trader_loyalist_titan", unlock_time = 7200, weight = 1 },
                { unit = "trader_rebel_titan", unlock_time = 7200, weight = 1 }
            }
        },

        advent_incursion = {
            name = "advent",
            mandatory_ships = {
                { unit = "advent_colony_capital_ship", count = 1 }
            },
            possible_ships = {
                { unit = "advent_carrier_cruiser", unlock_time = 900, weight = 40 },
                { unit = "advent_heavy_cruiser", unlock_time = 0, weight = 56 },
                { unit = "advent_defense_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "advent_guardian_cruiser", unlock_time = 1800, weight = 32 },
                { unit = "advent_long_range_cruiser", unlock_time = 2700, weight = 32 },
                { unit = "advent_medium_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "advent_subjugator_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "advent_battle_capital_ship", unlock_time = 1800, weight = 12 },
                { unit = "advent_battle_psionic_capital_ship", unlock_time = 1800, weight = 8 },
                { unit = "advent_carrier_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "advent_colony_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "advent_planet_psionic_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "dlc2_advent_loyalist_super_capital_ship", unlock_time = 5400, weight = 2 },
                { unit = "dlc2_advent_rebel_super_capital_ship", unlock_time = 5400, weight = 2 },
                { unit = "advent_loyalist_titan", unlock_time = 7200, weight = 1 },
                { unit = "advent_rebel_titan", unlock_time = 7200, weight = 1 }
            }
        },

        vasari_incursion = {
            name = "vasari",
            mandatory_ships = {
                { unit = "vasari_colony_capital_ship", count = 1 }
            },
            possible_ships = {
                { unit = "vasari_carrier_cruiser", unlock_time = 900, weight = 64 },
                { unit = "vasari_heavy_cruiser", unlock_time = 0, weight = 96 },
                { unit = "vasari_antiarmor_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "vasari_colony_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "vasari_fabricator_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "vasari_overseer_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "vasari_siege_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "vasari_battle_capital_ship", unlock_time = 1800, weight = 12 },
                { unit = "vasari_carrier_capital_ship", unlock_time = 1800, weight = 8 },
                { unit = "vasari_colony_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "vasari_marauder_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "vasari_siege_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "dlc2_vasari_loyalist_super_capital_ship", unlock_time = 5400, weight = 2 },
                { unit = "dlc2_vasari_rebel_super_capital_ship", unlock_time = 5400, weight = 2 },
                { unit = "vasari_loyalist_titan", unlock_time = 7200, weight = 1 },
                { unit = "vasari_rebel_titan", unlock_time = 7200, weight = 1 }
            }
        },

        dlc3_herald_incursion = {
            name = "eidolon",
            mandatory_ships = {
                { unit = "dlc3_herald_colony_capital_ship", count = 1 }
            },
            possible_ships = {
                { unit = "dlc3_herald_carrier_cruiser", unlock_time = 0, weight = 96 },
                { unit = "dlc3_herald_corruptor_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "dlc3_herald_defiler_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "dlc3_herald_long_range_cruiser", unlock_time = 2700, weight = 64 },
                { unit = "dlc3_herald_siege_cruiser", unlock_time = 899100, weight = 1 },
                { unit = "dlc3_herald_battle_capital_ship", unlock_time = 1800, weight = 12 },
                { unit = "dlc3_herald_carrier_capital_ship", unlock_time = 1800, weight = 8 },
                { unit = "dlc3_herald_colony_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "dlc3_herald_siege_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "dlc3_herald_support_capital_ship", unlock_time = 1800, weight = 4 },
                { unit = "dlc3_herald_super_capital_ship", unlock_time = 899100, weight = 1 },
                { unit = "dlc3_herald_titan", unlock_time = 7200, weight = 1 }
            }
        }
    }
}


-- Lua-side per-instance wave state.
-- Do not store nested Lua tables in context.instance; the event-state proxy only
-- reliably persists scalar values.
local WAVE_GROUPS_BY_INSTANCE = {}

local function get_wave_groups(context)
    local instance_id = context.instance_id
    local groups = WAVE_GROUPS_BY_INSTANCE[instance_id]
    if groups == nil then
        groups = {}
        WAVE_GROUPS_BY_INSTANCE[instance_id] = groups
    end
    return groups
end

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
    if race == nil then return nil end
    return CONFIG.factions[tostring(race)]
end

local function is_wave_enabled_for_race(race)
    local faction = get_faction_definition(race)
    return faction ~= nil, faction
end

local function get_level_for_time(game_time)
    if #CONFIG.level_timeline == 0 then return 1 end
    local level = CONFIG.level_timeline[1].level or 1
    for _, entry in ipairs(CONFIG.level_timeline) do
        if game_time >= entry.time then
            level = entry.level or level
        else
            break
        end
    end
    return level
end

local function get_supply_for_time(game_time)
    local start_supply = CONFIG.supply_start or 0
    local end_supply = CONFIG.supply_end or start_supply
    local end_time = CONFIG.supply_end_time or 0
    if end_time <= 0 then return end_supply end
    if game_time <= 0 then return start_supply end
    if game_time >= end_time then return end_supply end
    local progress = game_time / end_time
    return math.floor(start_supply + ((end_supply - start_supply) * progress) + 0.5)
end

local function get_balance_for_time(game_time)
    return { supply = get_supply_for_time(game_time), level = get_level_for_time(game_time) }
end

-- Elite state is per incursion player. One empire firing an elite never consumes it for another empire.
local function elite_event_state_key(event_index, player_index)
    return "elite_event_fired_" .. tostring(player_index) .. "_" .. tostring(event_index)
end

local function get_pending_elite_events(context, game_time, player_index)
    local pending = {}
    for event_index, elite_event in ipairs(CONFIG.elite_events or {}) do
        if game_time >= elite_event.time
            and not context.instance[elite_event_state_key(event_index, player_index)]
        then
            pending[#pending + 1] = { index = event_index, elite = elite_event.elite }
        end
    end
    return pending
end

local function has_pending_elite_for_time(context, game_time)
    local playable_indices = context.simulation:filter_playable_players(function(player)
        return not player.is_npc and not player.has_lost
    end)
    for _, player_index in ipairs(playable_indices) do
        local player = context.simulation:get_player_by_player_index(player_index)
        if player ~= nil and is_wave_enabled_for_race(player.race) then
            for event_index, elite_event in ipairs(CONFIG.elite_events or {}) do
                if game_time >= elite_event.time
                    and not context.instance[elite_event_state_key(event_index, player_index)]
                then
                    return true
                end
            end
        end
    end
    return false
end

local function get_ship_supply_cost(context, unit_type)
    if unit_type == nil then return nil end
    local cost = context.simulation:get_unit_supply_cost(unit_type)
    if cost == nil or cost <= 0 then return nil end
    return cost
end

local function get_effective_ship_level(wave, ship_spec)
    if ship_spec ~= nil and ship_spec.level ~= nil then return ship_spec.level end
    if wave ~= nil and wave.level ~= nil then return wave.level end
    return 1
end

local function make_spawn_options(wave, ship_spec)
    local options = spawn_unit_options.new()
    options.level = math.max(0, get_effective_ship_level(wave, ship_spec) - 1)
    if ship_spec ~= nil and ship_spec.items ~= nil then
        for _, item_name in ipairs(ship_spec.items) do
            options:add_item(item_name)
        end
    end
    return options
end

local function with_random_ship_artifact(context, ship_spec)
    if ship_spec == nil or not ship_spec.random_ship_artifact then return ship_spec end
    if #CONFIG.ship_artifacts == 0 then error("random_ship_artifact requested but CONFIG.ship_artifacts is empty") end
    local resolved_spec = {}
    for key, value in pairs(ship_spec) do resolved_spec[key] = value end
    resolved_spec.items = { CONFIG.ship_artifacts[context.random_integer(1, #CONFIG.ship_artifacts)] }
    return resolved_spec
end

local function get_living_playable_player_indices(context)
    return context.simulation:filter_playable_players(function(player)
        return not player.is_npc and not player.has_lost
    end)
end

local function get_home_gravity_well(context, player_index)
    local player = context.simulation:get_player_by_player_index(player_index)
    if player == nil then return nil end
    local owned_wells = context.simulation:get_gravity_wells_owned_by_player_index(player_index)
    if owned_wells == nil or #owned_wells == 0 then return nil end
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

local function find_target_player_index(context, attacker_player_index, excluded_target_player_index)
    local eligible_indices = context.simulation:filter_playable_players(function(player)
        return not player.is_npc
            and not player.has_lost
            and player.player_index ~= attacker_player_index
            and player.player_index ~= excluded_target_player_index
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

local function squared_distance_between_units(context, a, b)
    if a == nil or b == nil then return nil end
    local a_pos = context.simulation:get_unit_position(a)
    local b_pos = context.simulation:get_unit_position(b)
    if a_pos == nil or b_pos == nil then return nil end
    local dx = a_pos.x - b_pos.x
    local dy = a_pos.y - b_pos.y
    local dz = a_pos.z - b_pos.z
    return (dx * dx) + (dy * dy) + (dz * dz)
end

local function select_target_well(context, target_player_index, source_well)
    local target_wells = context.simulation:get_gravity_wells_owned_by_player_index(target_player_index)
    if target_wells == nil or #target_wells == 0 then return nil end
    if source_well == nil then return target_wells[1] end

    local best_well = nil
    local best_distance = nil
    for _, well in ipairs(target_wells) do
        local distance = squared_distance_between_units(context, source_well, well)
        if distance ~= nil and (best_distance == nil or distance < best_distance) then
            best_distance = distance
            best_well = well
        end
    end
    return best_well or target_wells[1]
end

local function clear_target_for_player(context, attacker_player_index)
    context.instance[player_state_key("target_player_", attacker_player_index)] = nil
    context.instance[player_state_key("target_well_", attacker_player_index)] = nil
    context.instance[player_state_key("blocking_well_", attacker_player_index)] = nil
    context.instance[player_state_key("blocking_requires_conquest_", attacker_player_index)] = nil
end

-- The enemy home/capital is the persistent strategic destination.
-- ============================================================
-- PER-WAVE MOVEMENT / TARGETING
-- One spawned wave is one script-side group.
-- ============================================================

local function get_enemy_playable_player_indices(context, attacker_player_index)
    return context.simulation:filter_playable_players(function(player)
        return not player.is_npc
            and not player.has_lost
            and player.player_index ~= attacker_player_index
    end)
end

local function is_player_index_enemy_to_wave(context, attacker_player_index, other_player_index)
    if other_player_index == nil or other_player_index == attacker_player_index then return false end
    local other_player = context.simulation:get_player_by_player_index(other_player_index)
    return other_player ~= nil and not other_player.is_npc and not other_player.has_lost
end

local function get_well_owner_player_index(context, well)
    if well == nil then return nil end
    local primary_fixture = context.simulation:get_gravity_well_primary_fixture(well)
    if primary_fixture == nil then return nil end
    local owner = context.simulation:get_unit_owner(primary_fixture)
    return owner ~= nil and owner.player_index or nil
end

local function find_nearest_enemy_planet_well(context, attacker_player_index, source_well)
    local best_well = nil
    local best_distance = nil

    for _, enemy_player_index in ipairs(get_enemy_playable_player_indices(context, attacker_player_index)) do
        local owned_wells = context.simulation:get_gravity_wells_owned_by_player_index(enemy_player_index)
        if owned_wells ~= nil then
            for _, well in ipairs(owned_wells) do
                if source_well == nil then
                    return well
                end
                local distance = squared_distance_between_units(context, source_well, well)
                if distance ~= nil and (best_distance == nil or distance < best_distance) then
                    best_distance = distance
                    best_well = well
                end
            end
        end
    end

    return best_well
end

local function is_well_hostile_to_wave(context, attacker_player_index, well)
    if well == nil then return false, false end
    local owner_index = get_well_owner_player_index(context, well)
    local hostile_owner = is_player_index_enemy_to_wave(context, attacker_player_index, owner_index)
    local hostile_units = false
    for _, enemy_player_index in ipairs(get_enemy_playable_player_indices(context, attacker_player_index)) do
        if context.simulation:does_gravity_well_contain_player_units_by_player_index(well, enemy_player_index) then
            hostile_units = true
            break
        end
    end
    return hostile_owner or hostile_units, hostile_owner
end

local function is_blocking_well_finished(context, group, well)
    if well == nil then return true end
    for _, enemy_player_index in ipairs(get_enemy_playable_player_indices(context, group.attacker_player_index)) do
        if context.simulation:does_gravity_well_contain_player_units_by_player_index(well, enemy_player_index) then
            return false
        end
    end
    if group.blocking_requires_conquest then
        return get_well_owner_player_index(context, well) == group.attacker_player_index
    end
    return true
end

local function get_or_create_wave_tracker(context, group)
    return context:get_or_create_unit_tracker(group.tracker_name)
end

local function set_wave_units_auto_combat(context, group)
    local tracker = get_or_create_wave_tracker(context, group)
    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            context.simulation:set_unit_auto_order_mode_by_id(unit_id, "engage_any_targets")
        end
    end
end

local function issue_wave_group_move(context, group, target_well_id)
    if target_well_id == nil then return false end
    local tracker = get_or_create_wave_tracker(context, group)
    if tracker:count() <= 0 then return false end

    local issued_any = false
    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            context.simulation:set_unit_auto_order_mode_by_id(unit_id, "engage_any_targets")
            local success = context.simulation:issue_move_order_by_id(unit_id, target_well_id, {
                clear_orders = true,
                ai_override = "anytime"
            })
            if success then
                issued_any = true
            end
        end
    end

    if issued_any then
        group.last_order_well_id = target_well_id
    end
    return issued_any
end

local function reset_group_stuck_watchdog(group, now)
    group.stuck_watchdog_next_check = now + CONFIG.stuck_check_interval_seconds
    group.stuck_watchdog_stable_since = nil
    group.stuck_watchdog_sample_unit_1 = nil
    group.stuck_watchdog_sample_well_1 = nil
    group.stuck_watchdog_sample_unit_2 = nil
    group.stuck_watchdog_sample_well_2 = nil
end

local function update_group_stuck_watchdog(context, group)
    local now = context.simulation.current_time

    if group.stuck_watchdog_next_check ~= nil and now < group.stuck_watchdog_next_check then
        return false
    end
    group.stuck_watchdog_next_check = now + CONFIG.stuck_check_interval_seconds

    -- Blocking combat/conquest is an intentional stop, never a stuck condition.
    if group.blocking_well_id ~= nil or group.strategic_target_well_id == nil then
        reset_group_stuck_watchdog(group, now)
        return false
    end

    local tracker = get_or_create_wave_tracker(context, group)
    local sample_units = {}
    local sample_wells = {}

    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            local well_id = context.simulation:get_unit_current_gravity_well_id(unit_id)
            if well_id ~= nil and well_id ~= 0 then
                sample_units[#sample_units + 1] = unit_id
                sample_wells[#sample_wells + 1] = well_id
                if #sample_units >= CONFIG.stuck_sample_size then
                    break
                end
            end
        end
    end

    if #sample_units == 0 then
        reset_group_stuck_watchdog(group, now)
        return false
    end

    -- Reaching the strategic target is progress, not a stuck condition.
    for _, well_id in ipairs(sample_wells) do
        if well_id == group.strategic_target_well_id then
            reset_group_stuck_watchdog(group, now)
            return false
        end
    end

    local same_sample =
        group.stuck_watchdog_sample_unit_1 == sample_units[1]
        and group.stuck_watchdog_sample_well_1 == sample_wells[1]
        and group.stuck_watchdog_sample_unit_2 == sample_units[2]
        and group.stuck_watchdog_sample_well_2 == sample_wells[2]

    if not same_sample then
        group.stuck_watchdog_sample_unit_1 = sample_units[1]
        group.stuck_watchdog_sample_well_1 = sample_wells[1]
        group.stuck_watchdog_sample_unit_2 = sample_units[2]
        group.stuck_watchdog_sample_well_2 = sample_wells[2]
        group.stuck_watchdog_stable_since = now
        return false
    end

    if group.stuck_watchdog_stable_since == nil then
        group.stuck_watchdog_stable_since = now
        return false
    end

    if now - group.stuck_watchdog_stable_since >= CONFIG.stuck_timeout_seconds then
        local recovered = issue_wave_group_move(context, group, group.strategic_target_well_id)
        group.stuck_watchdog_stable_since = now
        return recovered
    end

    return false
end

local function find_wave_reference_well(context, group)
    local tracker = get_or_create_wave_tracker(context, group)
    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            local well_id = context.simulation:get_unit_current_gravity_well_id(unit_id)
            if well_id ~= nil and well_id ~= 0 then
                return context.simulation:get_unit_by_id(well_id)
            end
        end
    end
    return nil
end

local function find_hostile_well_encountered_by_wave(context, group)
    local tracker = get_or_create_wave_tracker(context, group)
    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            local current_well_id = context.simulation:get_unit_current_gravity_well_id(unit_id)
            if current_well_id ~= nil and current_well_id ~= 0 then
                local current_well = context.simulation:get_unit_by_id(current_well_id)
                if current_well ~= nil then
                    local hostile, hostile_owner = is_well_hostile_to_wave(context, group.attacker_player_index, current_well)
                    if hostile then return current_well_id, hostile_owner end
                end
            end
        end
    end
    return nil, false
end

local function wave_target_is_still_enemy_owned(context, group)
    if group.strategic_target_well_id == nil then return false end
    local target_well = context.simulation:get_unit_by_id(group.strategic_target_well_id)
    if target_well == nil then return false end
    return is_player_index_enemy_to_wave(
        context,
        group.attacker_player_index,
        get_well_owner_player_index(context, target_well)
    )
end

local function assign_new_nearest_enemy_target(context, group)
    local source_well = find_wave_reference_well(context, group)
    if source_well == nil then source_well = context.simulation:get_unit_by_id(group.spawn_well_id) end
    local target_well = find_nearest_enemy_planet_well(context, group.attacker_player_index, source_well)
    group.strategic_target_well_id = target_well ~= nil and target_well.id or nil
    group.blocking_well_id = nil
    group.blocking_requires_conquest = false
    if group.strategic_target_well_id ~= nil then
        issue_wave_group_move(context, group, group.strategic_target_well_id)
        return true
    end
    return false
end

local function spawn_one_ship(context, player_index, spawn_well_id, unit_type, wave, ship_spec, wave_unit_ids)
    local spawn_def = spawn_units_definition.new()
    spawn_def:add_required_units(unit_type, 1, make_spawn_options(wave, ship_spec))
    local spawned_units = context.simulation:create_units_by_id(
        spawn_def, nil, spawn_well_id, player_index, float3.new(0.0, 0.0, 0.0),
        true, CONFIG.hyperspace_arrival_delay_seconds, nil, CONFIG.special_operation_kind
    )
    if spawned_units == nil or #spawned_units == 0 then return nil end
    local unit = spawned_units[1]
    for extra_index = 2, #spawned_units do
        context.simulation:despawn_unit_by_id(spawned_units[extra_index].id)
    end
    context.simulation:set_unit_auto_order_mode_by_id(unit.id, "engage_any_targets")
    if wave_unit_ids ~= nil then wave_unit_ids[#wave_unit_ids + 1] = unit.id end
    return unit
end

local function build_eligible_weight_pool(context, faction, game_time, remaining_supply)
    local pool = {}
    for _, candidate in ipairs(faction.possible_ships or {}) do
        local unlock_time = candidate.unlock_time or 0
        local weight = math.max(0, math.floor(candidate.weight or 0))
        if game_time >= unlock_time and weight > 0 then
            local unit_type = candidate.unit
            local supply_cost = get_ship_supply_cost(context, unit_type)
            if unit_type ~= nil and supply_cost ~= nil and supply_cost <= remaining_supply then
                for _ = 1, weight do
                    pool[#pool + 1] = { spec = candidate, unit_type = unit_type, supply_cost = supply_cost }
                end
            end
        end
    end
    for i = #pool, 2, -1 do
        local j = context.random_integer(1, i)
        pool[i], pool[j] = pool[j], pool[i]
    end
    return pool
end

local function spawn_elite_ships(context, race, elite_id, balance, player_index, spawn_well_id, wave_unit_ids)
    local elite_definition = CONFIG.elite_waves[elite_id]
    if elite_definition == nil then error("missing elite definition " .. tostring(elite_id)) end
    local elite_list = elite_definition[tostring(race)]
    if elite_list == nil then return 0, {} end
    local spawned_count = 0
    local composition = {}
    for _, elite_ship in ipairs(elite_list) do
        local unit_type = elite_ship.unit
        local count = elite_ship.count or 1
        if unit_type == nil then error("elite ship entry is missing unit for race " .. tostring(race)) end
        for _ = 1, count do
            local unit = spawn_one_ship(
                context, player_index, spawn_well_id, unit_type,
                balance, with_random_ship_artifact(context, elite_ship), wave_unit_ids
            )
            if unit == nil then error("failed to spawn elite ship " .. tostring(unit_type)) end
            spawned_count = spawned_count + 1
            composition[unit_type] = (composition[unit_type] or 0) + 1
        end
    end
    return spawned_count, composition
end

local function update_hud(context)
    local now = context.simulation.current_time
    local next_wave_time = context.instance.next_wave_time or now
    local remaining = math.max(0, next_wave_time - now)
    local seconds = math.ceil(remaining)
    local next_balance = get_balance_for_time(next_wave_time)

    context.simulation:display_text("timer_label", CONFIG.debug_hud and "Next Incursion Wave" or "Incursion")
    if seconds >= 60 then
        context.simulation:display_text("timer_value", string.format("%d:%02d", math.floor(seconds / 60), seconds % 60))
    else
        context.simulation:display_text("timer_value", tostring(seconds))
    end

    if CONFIG.debug_hud then
        context.simulation:display_text("progress_label", "Next Wave")
        local value = "Wave " .. tostring((context.instance.wave_number or 0) + 1)
            .. " | " .. tostring(next_balance.supply or 0) .. " supply"
            .. " | level " .. tostring(next_balance.level or 1)
        if context.instance.status_text ~= nil and context.instance.status_text ~= "" then
            value = value .. " | " .. context.instance.status_text
        end
        context.simulation:display_text("progress_value", value)
    else
        context.simulation:display_text("progress_label", has_pending_elite_for_time(context, next_wave_time) and "Elite" or "")
        context.simulation:display_text("progress_value", "")
    end
end

function Pirate_incursion_wave_spawn_callback(context)
    context.instance.wave_number = (context.instance.wave_number or 0) + 1
    local wave_number = context.instance.wave_number
    local game_time = context.simulation.current_time
    local balance = get_balance_for_time(game_time)
    context.instance.next_wave_time = game_time + CONFIG.wave_interval_seconds
    local wave_groups = get_wave_groups(context)

    local success, error_message = pcall(function()
        local playable_indices = get_living_playable_player_indices(context)
        local spawned_any_wave = false

        -- Every living incursion empire spawns its own independent wave.
        for _, player_index in ipairs(playable_indices) do
            local player = context.simulation:get_player_by_player_index(player_index)
            if player ~= nil then
                local enabled, faction = is_wave_enabled_for_race(player.race)
                if enabled and faction ~= nil then
                    local spawn_well = get_home_gravity_well(context, player_index)
                    if spawn_well ~= nil then
                        -- Main goal for this wave: nearest enemy-owned planet at spawn time.
                        local strategic_target_well = find_nearest_enemy_planet_well(context, player_index, spawn_well)
                        if strategic_target_well ~= nil then
                            local group = {
                                attacker_player_index = player_index,
                                spawn_well_id = spawn_well.id,
                                strategic_target_well_id = strategic_target_well.id,
                                blocking_well_id = nil,
                                blocking_requires_conquest = false,
                                tracker_name = "incursion_wave_" .. tostring(context.instance_id)
                                    .. "_" .. tostring(player_index) .. "_" .. tostring(wave_number)
                            }

                            local supply_budget = balance.supply or 0
                            local supply_used = 0
                            local spawned_count = 0
                            local composition = {}
                            local wave_unit_ids = {}

                            for _, mandatory in ipairs(faction.mandatory_ships or {}) do
                                local unit_type = mandatory.unit
                                local supply_cost = get_ship_supply_cost(context, unit_type)
                                local count = mandatory.count or 1
                                if unit_type == nil then error("mandatory ship entry is missing unit for " .. tostring(faction.name)) end
                                if supply_cost == nil then error("could not read supply cost for " .. tostring(unit_type)) end
                                for _ = 1, count do
                                    if supply_used + supply_cost > supply_budget then
                                        error("mandatory ships exceed wave budget: " .. tostring(supply_used + supply_cost) .. " > " .. tostring(supply_budget))
                                    end
                                    local unit = spawn_one_ship(
                                        context, player_index, spawn_well.id, unit_type,
                                        balance, mandatory, wave_unit_ids
                                    )
                                    if unit == nil then error("failed to spawn mandatory ship " .. tostring(unit_type)) end
                                    supply_used = supply_used + supply_cost
                                    spawned_count = spawned_count + 1
                                    composition[unit_type] = (composition[unit_type] or 0) + 1
                                end
                            end

                            local weighted_pool = {}
                            local pool_index = 1
                            while supply_used < supply_budget do
                                local remaining_supply = supply_budget - supply_used
                                if pool_index > #weighted_pool then
                                    weighted_pool = build_eligible_weight_pool(context, faction, game_time, remaining_supply)
                                    pool_index = 1
                                end
                                if #weighted_pool == 0 then break end
                                local choice = weighted_pool[pool_index]
                                pool_index = pool_index + 1
                                if choice.supply_cost <= (supply_budget - supply_used) then
                                    local unit = spawn_one_ship(
                                        context, player_index, spawn_well.id, choice.unit_type,
                                        balance, choice.spec, wave_unit_ids
                                    )
                                    if unit == nil then error("failed to spawn weighted ship " .. tostring(choice.unit_type)) end
                                    supply_used = supply_used + choice.supply_cost
                                    spawned_count = spawned_count + 1
                                    composition[choice.unit_type] = (composition[choice.unit_type] or 0) + 1
                                else
                                    weighted_pool = {}
                                    pool_index = 1
                                end
                            end

                            local elite_labels = {}
                            local pending_elites = get_pending_elite_events(context, game_time, player_index)
                            for _, pending_elite in ipairs(pending_elites) do
                                local elite_spawned_count, elite_composition = spawn_elite_ships(
                                    context, player.race, pending_elite.elite, balance,
                                    player_index, spawn_well.id, wave_unit_ids
                                )
                                spawned_count = spawned_count + elite_spawned_count
                                for unit_type, count in pairs(elite_composition) do
                                    composition[unit_type] = (composition[unit_type] or 0) + count
                                end
                                context.instance[elite_event_state_key(pending_elite.index, player_index)] = true
                                elite_labels[#elite_labels + 1] = tostring(pending_elite.elite)
                            end

                            -- One wave = one script tracker. This is not a native fleet.
                            local tracker = get_or_create_wave_tracker(context, group)
                            for _, unit_id in ipairs(wave_unit_ids) do
                                tracker:add_unit(unit_id)
                            end

                            wave_groups[#wave_groups + 1] = group

                            -- One group order after the complete wave exists.
                            issue_wave_group_move(context, group, group.strategic_target_well_id)

                            local composition_parts = {}
                            for unit_type, count in pairs(composition) do
                                composition_parts[#composition_parts + 1] = tostring(unit_type) .. " x" .. tostring(count)
                            end
                            table.sort(composition_parts)
                            local elite_status = #elite_labels > 0 and (" | ELITE " .. table.concat(elite_labels, ",")) or ""
                            set_status(context,
                                tostring(faction.name) .. " wave " .. tostring(wave_number)
                                .. " | time " .. tostring(math.floor(game_time)) .. "s"
                                .. " | " .. tostring(supply_used) .. "/" .. tostring(supply_budget) .. " supply"
                                .. " | level " .. tostring(balance.level or 1)
                                .. " | " .. tostring(spawned_count) .. " ships"
                                .. elite_status .. " | " .. table.concat(composition_parts, ", ")
                            )
                            spawned_any_wave = true
                        end
                    end
                end
            end
        end

        if not spawned_any_wave then set_status(context, "no valid incursion player/target") end
    end)

    if not success then set_status(context, "SPAWN ERROR: " .. tostring(error_message)) end
    local hud_success, hud_error = pcall(function() update_hud(context) end)
    if not hud_success then debug_print("HUD ERROR: " .. tostring(hud_error)) end
end

local function update_wave_group(context, group)
    local tracker = get_or_create_wave_tracker(context, group)
    if tracker:count() <= 0 then
        return false
    end

    -- Temporary combat/conquest interruption. The persistent main target is kept.
    if group.blocking_well_id ~= nil then
        local blocking_well = context.simulation:get_unit_by_id(group.blocking_well_id)

        if not is_blocking_well_finished(context, group, blocking_well) then
            -- Native AI owns combat while this well is blocking the wave.
            -- Do not reapply auto-order mode or issue any movement order here;
            -- repeated writes would continuously disturb the unit command state.
            return true
        end

        group.blocking_well_id = nil
        group.blocking_requires_conquest = false

        -- Return to the original main goal after the interruption.
        if wave_target_is_still_enemy_owned(context, group) then
            issue_wave_group_move(context, group, group.strategic_target_well_id)
            return true
        end

        -- Original target is gone/conquered: choose the new nearest enemy planet.
        assign_new_nearest_enemy_target(context, group)
        return true
    end

    -- If any member reaches a gravity well owned by an enemy, or a gravity well
    -- containing enemy ships (including a fleet actively attacking the wave), the
    -- whole wave interrupts its route and groups on that gravity well.
    local encountered_well_id, requires_conquest = find_hostile_well_encountered_by_wave(context, group)
    if encountered_well_id ~= nil then
        group.blocking_well_id = encountered_well_id
        group.blocking_requires_conquest = requires_conquest == true
        set_wave_units_auto_combat(context, group)
        return true
    end

    -- If the main target was conquered by somebody else while travelling, retarget.
    if not wave_target_is_still_enemy_owned(context, group) then
        assign_new_nearest_enemy_target(context, group)
        return true
    end

    -- Cheap fail-safe for groups that stop making inter-well progress.
    -- It checks only two living ships every 15 seconds and reissues the real
    -- strategic destination after 60 seconds in the same gravity well.
    update_group_stuck_watchdog(context, group)

    return true
end

local function update_all_target_progress(context)
    local groups = get_wave_groups(context)

    for index = #groups, 1, -1 do
        local group = groups[index]
        local keep_group = update_wave_group(context, group)
        if not keep_group then
            table.remove(groups, index)
        end
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
    WAVE_GROUPS_BY_INSTANCE[context.instance_id] = {}
    context.instance.status_text = "waiting for wave 1"
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
        pcall(function() set_status(context, "UPDATE ERROR: " .. tostring(error_message)) end)
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
    WAVE_GROUPS_BY_INSTANCE[context.instance_id] = nil
    context.simulation:display_text("timer_label", "")
    context.simulation:display_text("timer_value", "")
    context.simulation:display_text("progress_label", "")
    context.simulation:display_text("progress_value", "")
end
