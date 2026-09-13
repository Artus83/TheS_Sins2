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
    special_operation_kind = "thes_incursion",

    -- Strategic controller only. Native unit AI owns all tactical combat.
    strategic_update_interval_seconds = 5.0,
    strategic_recovery_timeout_seconds = 60.0,
    target_search_retry_seconds = 30.0,
    recovery_sample_size = 3,

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



local debug_print

-- ============================================================
-- PER-WAVE STRATEGIC CONTROLLER
--
-- Lua chooses only strategic destinations. Native auto-order AI owns tactical
-- combat inside gravity wells. A wave receives one direct move order to the
-- nearest enemy-owned gravity well. The move may be overridden by native AI at
-- any time so the ships can engage enemies encountered or attacking them.
-- ============================================================

local WAVE_GROUPS_BY_INSTANCE = {}

local function wave_group_state_key(slot, field)
    return "wave_group_" .. tostring(slot) .. "_" .. tostring(field)
end

local function persist_wave_group_state(context, group)
    if group.state_slot == nil then
        context.instance.wave_group_count = (context.instance.wave_group_count or 0) + 1
        group.state_slot = context.instance.wave_group_count
    end

    local slot = group.state_slot
    context.instance[wave_group_state_key(slot, "active")] = true
    context.instance[wave_group_state_key(slot, "attacker_player_index")] = group.attacker_player_index
    context.instance[wave_group_state_key(slot, "spawn_well_id")] = group.spawn_well_id
    context.instance[wave_group_state_key(slot, "strategic_target_well_id")] = group.strategic_target_well_id
    context.instance[wave_group_state_key(slot, "tracker_name")] = group.tracker_name
end

local function deactivate_wave_group_state(context, group)
    if group.state_slot ~= nil then
        context.instance[wave_group_state_key(group.state_slot, "active")] = false
    end
end

local function rebuild_wave_groups_from_instance(context)
    local groups = {}
    local group_count = context.instance.wave_group_count or 0

    for slot = 1, group_count do
        if context.instance[wave_group_state_key(slot, "active")] == true then
            local tracker_name = context.instance[wave_group_state_key(slot, "tracker_name")]
            local attacker_player_index = context.instance[wave_group_state_key(slot, "attacker_player_index")]
            local spawn_well_id = context.instance[wave_group_state_key(slot, "spawn_well_id")]

            if tracker_name ~= nil and attacker_player_index ~= nil and spawn_well_id ~= nil then
                groups[#groups + 1] = {
                    state_slot = slot,
                    attacker_player_index = attacker_player_index,
                    spawn_well_id = spawn_well_id,
                    strategic_target_well_id = context.instance[wave_group_state_key(slot, "strategic_target_well_id")],
                    tracker_name = tracker_name
                }
            end
        end
    end

    return groups
end

local function get_wave_groups(context)
    local instance_id = context.instance_id
    local groups = WAVE_GROUPS_BY_INSTANCE[instance_id]
    if groups == nil then
        groups = rebuild_wave_groups_from_instance(context)
        WAVE_GROUPS_BY_INSTANCE[instance_id] = groups
    end
    return groups
end

local function get_or_create_wave_tracker(context, group)
    return context:get_or_create_unit_tracker(group.tracker_name)
end

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

local function get_sorted_adjacent_well_ids(context, well_id)
    local adjacent_wells = context.simulation:get_adjacent_gravity_wells_by_id(well_id)
    if adjacent_wells == nil then return {} end

    local ids = {}
    for _, well in ipairs(adjacent_wells) do
        if well ~= nil and well.id ~= nil then ids[#ids + 1] = well.id end
    end
    table.sort(ids)
    return ids
end

-- Build the enemy-owned target set first, then BFS through the actual phase-lane
-- graph. This avoids the broken get_closest_gravity_wells Lua binding and avoids
-- geometric-distance guesses that ignore phase-lane topology.
local function find_nearest_enemy_owned_well(context, attacker_player_index, source_well_id)
    if source_well_id == nil or source_well_id == 0 then return nil, nil, nil end

    local target_owner_by_well_id = {}
    local target_count = 0
    for _, enemy_player_index in ipairs(get_enemy_playable_player_indices(context, attacker_player_index)) do
        local owned_wells = context.simulation:get_gravity_wells_owned_by_player_index(enemy_player_index)
        if owned_wells ~= nil then
            for _, well in ipairs(owned_wells) do
                if well ~= nil and well.id ~= nil and target_owner_by_well_id[well.id] == nil then
                    target_owner_by_well_id[well.id] = enemy_player_index
                    target_count = target_count + 1
                end
            end
        end
    end
    if target_count == 0 then return nil, nil, nil end

    local queue = { source_well_id }
    local queue_depth = { 0 }
    local head = 1
    local visited = { [source_well_id] = true }

    while head <= #queue do
        local well_id = queue[head]
        local depth = queue_depth[head]
        head = head + 1

        local owner_index = target_owner_by_well_id[well_id]
        if owner_index ~= nil then
            return owner_index, well_id, depth
        end

        for _, adjacent_id in ipairs(get_sorted_adjacent_well_ids(context, well_id)) do
            if not visited[adjacent_id] then
                visited[adjacent_id] = true
                queue[#queue + 1] = adjacent_id
                queue_depth[#queue_depth + 1] = depth + 1
            end
        end
    end

    return nil, nil, nil
end

local function gravity_well_contains_playable_enemy_units(context, attacker_player_index, well)
    if well == nil then return false end
    for _, enemy_player_index in ipairs(get_enemy_playable_player_indices(context, attacker_player_index)) do
        if context.simulation:does_gravity_well_contain_player_units_by_player_index(well, enemy_player_index) then
            return true
        end
    end
    return false
end

-- A strategic target remains active while either the planet is still owned by a
-- living playable enemy or any living playable enemy still has units in the well.
-- The well does NOT have to become owned by the incursion empire. Neutralization
-- is enough once the enemy combat presence has also been removed.
local function strategic_target_is_active(context, group)
    local target_well_id = group.strategic_target_well_id
    if target_well_id == nil then return false end

    local target_well = context.simulation:get_unit_by_id(target_well_id)
    if target_well == nil then return false end

    local owner_index = get_well_owner_player_index(context, target_well)
    if is_player_index_enemy_to_wave(context, group.attacker_player_index, owner_index) then
        return true
    end

    return gravity_well_contains_playable_enemy_units(
        context,
        group.attacker_player_index,
        target_well
    )
end

local function get_first_living_wave_well_id(context, group)
    local tracker = get_or_create_wave_tracker(context, group)
    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            local well_id = context.simulation:get_unit_current_gravity_well_id(unit_id)
            if well_id ~= nil and well_id ~= 0 then return well_id end
        end
    end
    return nil
end

local function wave_has_living_units(context, group)
    local tracker = get_or_create_wave_tracker(context, group)
    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id) then return true end
    end
    return false
end

local function issue_wave_strategic_move(context, group, target_well_id, reason)
    if target_well_id == nil then return false end

    local tracker = get_or_create_wave_tracker(context, group)
    local issued_any = false
    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            -- engage_any_targets is normally set only once at spawn. Reapplying it
            -- here is intentional only when a strategic order is (re)issued.
            context.simulation:set_unit_auto_order_mode_by_id(unit_id, "engage_any_targets")
            local success = context.simulation:issue_move_order_by_id(unit_id, target_well_id, {
                clear_orders = true,
                ai_override = "anytime"
            })
            if success then issued_any = true end
        end
    end

    if issued_any then
        group.last_order_time = context.simulation.current_time
        group.last_progress_time = context.simulation.current_time
        group.last_recovery_signature = nil
        debug_print("strategic move " .. tostring(group.tracker_name)
            .. " -> well " .. tostring(target_well_id)
            .. " | " .. tostring(reason or "order"))
    end
    return issued_any
end

local function assign_new_strategic_target(context, group, source_well_id)
    if source_well_id == nil or source_well_id == 0 then
        source_well_id = group.spawn_well_id
    end

    local target_player_index, target_well_id, distance = find_nearest_enemy_owned_well(
        context,
        group.attacker_player_index,
        source_well_id
    )

    group.strategic_target_well_id = target_well_id
    group.next_target_search_time = nil
    group.last_progress_time = context.simulation.current_time
    group.last_recovery_signature = nil
    persist_wave_group_state(context, group)

    if target_well_id == nil then
        group.next_target_search_time = context.simulation.current_time + CONFIG.target_search_retry_seconds
        debug_print("no enemy-owned gravity well for " .. tostring(group.tracker_name))
        return false
    end

    debug_print("strategic target " .. tostring(group.tracker_name)
        .. " | player " .. tostring(target_player_index)
        .. " | well " .. tostring(target_well_id)
        .. " | jumps " .. tostring(distance or 0))

    -- If the target is the well the wave is already in, native engage_any_targets
    -- owns the battle; no local movement order is required.
    if source_well_id == target_well_id then return true end
    return issue_wave_strategic_move(context, group, target_well_id, "new target")
end

local function build_recovery_signature(context, group)
    local tracker = get_or_create_wave_tracker(context, group)
    local sampled = {}
    local occupied_well_ids = {}
    local occupied_seen = {}

    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            local well_id = context.simulation:get_unit_current_gravity_well_id(unit_id)
            if well_id ~= nil and well_id ~= 0 then
                if not occupied_seen[well_id] then
                    occupied_seen[well_id] = true
                    occupied_well_ids[#occupied_well_ids + 1] = well_id
                end
                if #sampled < CONFIG.recovery_sample_size then
                    sampled[#sampled + 1] = tostring(unit_id) .. "@" .. tostring(well_id)
                end
            end
        end
    end

    table.sort(sampled)
    table.sort(occupied_well_ids)
    return table.concat(sampled, ","), occupied_well_ids
end

local function any_occupied_well_has_playable_enemies(context, group, occupied_well_ids)
    for _, well_id in ipairs(occupied_well_ids or {}) do
        local well = context.simulation:get_unit_by_id(well_id)
        if well ~= nil and gravity_well_contains_playable_enemy_units(
            context,
            group.attacker_player_index,
            well
        ) then
            return true
        end
    end
    return false
end

-- This is deliberately the only stuck recovery. It runs at most once per timeout,
-- samples only a few ships, and never runs while any sampled wave-occupied well has
-- playable enemies. Its sole action is to reissue the existing strategic target.
local function update_strategic_recovery(context, group)
    if group.strategic_target_well_id == nil then return end

    local now = context.simulation.current_time
    if group.next_recovery_check_time ~= nil and now < group.next_recovery_check_time then return end
    group.next_recovery_check_time = now + CONFIG.strategic_recovery_timeout_seconds

    local signature, occupied_well_ids = build_recovery_signature(context, group)
    if signature == "" then return end

    if group.last_recovery_signature ~= signature then
        group.last_recovery_signature = signature
        group.last_progress_time = now
        return
    end

    local last_progress = group.last_progress_time or now
    if now - last_progress < CONFIG.strategic_recovery_timeout_seconds then return end

    if any_occupied_well_has_playable_enemies(context, group, occupied_well_ids) then
        group.last_progress_time = now
        return
    end

    local reference_well_id = get_first_living_wave_well_id(context, group)
    if reference_well_id == group.strategic_target_well_id then
        -- At the objective native AI owns planet/fleet combat; never spam movement
        -- orders inside the target gravity well.
        group.last_progress_time = now
        return
    end

    issue_wave_strategic_move(
        context,
        group,
        group.strategic_target_well_id,
        "60s no inter-well progress"
    )
end

debug_print = function(message)
    print("[faction_wave_test] " .. tostring(message))
end

local function set_status(context, text)
    context.instance.status_text = tostring(text or "")
    debug_print(context.instance.status_text)
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

local function make_spawn_batch_key(wave, unit_type, ship_spec)
    local parts = { tostring(unit_type), "level=" .. tostring(get_effective_ship_level(wave, ship_spec)) }
    if ship_spec ~= nil and ship_spec.items ~= nil then
        for _, item_name in ipairs(ship_spec.items) do
            parts[#parts + 1] = "item=" .. tostring(item_name)
        end
    end
    return table.concat(parts, "|")
end

local function new_spawn_plan()
    return { batches = {}, by_key = {}, expected_count = 0 }
end

local function add_to_spawn_plan(plan, wave, unit_type, ship_spec, count)
    count = count or 1
    if count <= 0 then return end
    if unit_type == nil then error("spawn plan entry is missing unit") end

    local key = make_spawn_batch_key(wave, unit_type, ship_spec)
    local batch = plan.by_key[key]
    if batch == nil then
        batch = { unit_type = unit_type, ship_spec = ship_spec, count = 0 }
        plan.by_key[key] = batch
        plan.batches[#plan.batches + 1] = batch
    end

    batch.count = batch.count + count
    plan.expected_count = plan.expected_count + count
end

local function spawn_planned_wave(context, player_index, spawn_well_id, wave, plan)
    if plan.expected_count <= 0 then return {} end

    local spawn_def = spawn_units_definition.new()
    for _, batch in ipairs(plan.batches) do
        spawn_def:add_required_units(
            batch.unit_type,
            batch.count,
            make_spawn_options(wave, batch.ship_spec)
        )
    end

    local spawned_units = context.simulation:create_units_by_id(
        spawn_def, nil, spawn_well_id, player_index, float3.new(0.0, 0.0, 0.0),
        true, CONFIG.hyperspace_arrival_delay_seconds, nil, CONFIG.special_operation_kind
    )

    if spawned_units == nil then
        error("batched wave spawn returned nil")
    end

    if #spawned_units < plan.expected_count then
        for _, unit in ipairs(spawned_units) do
            context.simulation:despawn_unit_by_id(unit.id)
        end
        error("batched wave spawn count mismatch: expected " .. tostring(plan.expected_count)
            .. ", got " .. tostring(#spawned_units))
    end

    if #spawned_units > plan.expected_count then
        debug_print("batched wave spawn returned " .. tostring(#spawned_units - plan.expected_count)
            .. " extra units; despawning extras")
        for extra_index = plan.expected_count + 1, #spawned_units do
            context.simulation:despawn_unit_by_id(spawned_units[extra_index].id)
        end
    end

    local unit_ids = {}
    for unit_index = 1, plan.expected_count do
        local unit = spawned_units[unit_index]
        context.simulation:set_unit_auto_order_mode_by_id(unit.id, "engage_any_targets")
        unit_ids[#unit_ids + 1] = unit.id
    end
    return unit_ids
end

local function build_wave_spawn_plan(context, faction, game_time, balance)
    local plan = new_spawn_plan()
    local supply_budget = balance.supply or 0
    local supply_used = 0
    local normal_count = 0
    local composition = {}

    for _, mandatory in ipairs(faction.mandatory_ships or {}) do
        local unit_type = mandatory.unit
        local supply_cost = get_ship_supply_cost(context, unit_type)
        local count = mandatory.count or 1
        if unit_type == nil then error("mandatory ship entry is missing unit for " .. tostring(faction.name)) end
        if supply_cost == nil then error("could not read supply cost for " .. tostring(unit_type)) end

        local required_supply = supply_cost * count
        if supply_used + required_supply > supply_budget then
            error("mandatory ships exceed wave budget: " .. tostring(supply_used + required_supply)
                .. " > " .. tostring(supply_budget))
        end

        add_to_spawn_plan(plan, balance, unit_type, mandatory, count)
        supply_used = supply_used + required_supply
        normal_count = normal_count + count
        composition[unit_type] = (composition[unit_type] or 0) + count
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
            add_to_spawn_plan(plan, balance, choice.unit_type, choice.spec, 1)
            supply_used = supply_used + choice.supply_cost
            normal_count = normal_count + 1
            composition[choice.unit_type] = (composition[choice.unit_type] or 0) + 1
        else
            weighted_pool = {}
            pool_index = 1
        end
    end

    return {
        plan = plan,
        supply_budget = supply_budget,
        supply_used = supply_used,
        normal_count = normal_count,
        composition = composition
    }
end

local function spawn_one_exact_ship(context, player_index, spawn_well_id, unit_type, wave, ship_spec)
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
    return unit
end

local function spawn_elites_individually(context, race, pending_elites, balance, player_index, spawn_well_id, transaction_unit_ids, composition)
    local elite_count = 0
    local elite_labels = {}

    for _, pending_elite in ipairs(pending_elites) do
        local elite_definition = CONFIG.elite_waves[pending_elite.elite]
        if elite_definition == nil then
            error("missing elite definition " .. tostring(pending_elite.elite))
        end

        local elite_list = elite_definition[tostring(race)]
        if elite_list ~= nil then
            for _, elite_ship in ipairs(elite_list) do
                local unit_type = elite_ship.unit
                local count = elite_ship.count or 1
                if unit_type == nil then
                    error("elite ship entry is missing unit for race " .. tostring(race))
                end

                for _ = 1, count do
                    local resolved_spec = with_random_ship_artifact(context, elite_ship)
                    local unit = spawn_one_exact_ship(
                        context, player_index, spawn_well_id, unit_type, balance, resolved_spec
                    )
                    if unit == nil then error("failed to spawn elite ship " .. tostring(unit_type)) end
                    transaction_unit_ids[#transaction_unit_ids + 1] = unit.id
                    elite_count = elite_count + 1
                    composition[unit_type] = (composition[unit_type] or 0) + 1
                end
            end
        end

        elite_labels[#elite_labels + 1] = tostring(pending_elite.elite)
    end

    return elite_count, elite_labels
end

local function despawn_unit_ids(context, unit_ids)
    for _, unit_id in ipairs(unit_ids or {}) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            context.simulation:despawn_unit_by_id(unit_id)
        end
    end
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



local function spawn_wave_for_player(context, player_index, player, faction, wave_number, game_time, balance, wave_groups, transaction_unit_ids)
    local spawn_well = get_home_gravity_well(context, player_index)
    if spawn_well == nil then return false end

    local target_player_index, strategic_target_well_id, target_distance = find_nearest_enemy_owned_well(
        context,
        player_index,
        spawn_well.id
    )
    if strategic_target_well_id == nil then return false end

    local group = {
        attacker_player_index = player_index,
        spawn_well_id = spawn_well.id,
        strategic_target_well_id = strategic_target_well_id,
        tracker_name = "incursion_wave_" .. tostring(context.instance_id)
            .. "_" .. tostring(player_index) .. "_" .. tostring(wave_number)
    }

    local planned = build_wave_spawn_plan(context, faction, game_time, balance)
    local wave_unit_ids = spawn_planned_wave(
        context, player_index, spawn_well.id, balance, planned.plan
    )
    for _, unit_id in ipairs(wave_unit_ids) do
        transaction_unit_ids[#transaction_unit_ids + 1] = unit_id
    end

    local pending_elites = get_pending_elite_events(context, game_time, player_index)
    local elite_count, elite_labels = spawn_elites_individually(
        context, player.race, pending_elites, balance, player_index, spawn_well.id,
        transaction_unit_ids, planned.composition
    )

    local tracker = get_or_create_wave_tracker(context, group)
    for _, unit_id in ipairs(transaction_unit_ids) do
        tracker:add_unit(unit_id)
    end

    persist_wave_group_state(context, group)
    wave_groups[#wave_groups + 1] = group

    debug_print("initial strategic target " .. tostring(group.tracker_name)
        .. " | player " .. tostring(target_player_index)
        .. " | well " .. tostring(strategic_target_well_id)
        .. " | jumps " .. tostring(target_distance or 0))

    if spawn_well.id ~= strategic_target_well_id then
        if not issue_wave_strategic_move(context, group, strategic_target_well_id, "initial target") then
            debug_print("initial strategic move failed for " .. tostring(group.tracker_name))
        end
    end

    for _, pending_elite in ipairs(pending_elites) do
        context.instance[elite_event_state_key(pending_elite.index, player_index)] = true
    end

    local composition_parts = {}
    for unit_type, count in pairs(planned.composition) do
        composition_parts[#composition_parts + 1] = tostring(unit_type) .. " x" .. tostring(count)
    end
    table.sort(composition_parts)
    local elite_status = #elite_labels > 0
        and (" | ELITE " .. table.concat(elite_labels, ",")) or ""
    local spawned_count = planned.normal_count + elite_count

    set_status(context,
        tostring(faction.name) .. " wave " .. tostring(wave_number)
        .. " | time " .. tostring(math.floor(game_time)) .. "s"
        .. " | " .. tostring(planned.supply_used) .. "/" .. tostring(planned.supply_budget) .. " supply"
        .. " | level " .. tostring(balance.level or 1)
        .. " | " .. tostring(spawned_count) .. " ships"
        .. elite_status .. " | " .. table.concat(composition_parts, ", ")
    )

    return true
end

function Pirate_incursion_wave_spawn_callback(context)
    context.instance.wave_number = (context.instance.wave_number or 0) + 1
    local wave_number = context.instance.wave_number
    local game_time = context.simulation.current_time
    local balance = get_balance_for_time(game_time)
    context.instance.next_wave_time = game_time + CONFIG.wave_interval_seconds
    local wave_groups = get_wave_groups(context)
    local playable_indices = get_living_playable_player_indices(context)
    local spawned_any_wave = false
    local had_spawn_error = false

    for _, player_index in ipairs(playable_indices) do
        local player = context.simulation:get_player_by_player_index(player_index)
        if player ~= nil then
            local enabled, faction = is_wave_enabled_for_race(player.race)
            if enabled and faction ~= nil then
                local transaction_unit_ids = {}
                local success, result_or_error = pcall(function()
                    return spawn_wave_for_player(
                        context, player_index, player, faction, wave_number, game_time, balance,
                        wave_groups, transaction_unit_ids
                    )
                end)

                if success then
                    if result_or_error == true then spawned_any_wave = true end
                else
                    had_spawn_error = true
                    despawn_unit_ids(context, transaction_unit_ids)
                    local message = "SPAWN ERROR player " .. tostring(player_index)
                        .. " (" .. tostring(faction.name) .. "): " .. tostring(result_or_error)
                    debug_print(message)
                    set_status(context, message)
                end
            end
        end
    end

    if not spawned_any_wave and not had_spawn_error then
        set_status(context, "no valid incursion player/target")
    end

    local hud_success, hud_error = pcall(function() update_hud(context) end)
    if not hud_success then debug_print("HUD ERROR: " .. tostring(hud_error)) end
end

local function update_wave_group(context, group)
    local now = context.simulation.current_time
    local interval = math.max(1.0, CONFIG.strategic_update_interval_seconds or 5.0)

    if group.next_strategic_update_time == nil then
        local slot = tonumber(group.state_slot) or tonumber(group.attacker_player_index) or 0
        local phase_steps = 10
        local phase = (math.floor(slot) % phase_steps) * (interval / phase_steps)
        group.next_strategic_update_time = now + phase
    end
    if now < group.next_strategic_update_time then return true end
    group.next_strategic_update_time = now + interval

    if not wave_has_living_units(context, group) then
        deactivate_wave_group_state(context, group)
        return false
    end

    if not strategic_target_is_active(context, group) then
        if group.next_target_search_time == nil or now >= group.next_target_search_time then
            local source_well_id = get_first_living_wave_well_id(context, group)
            assign_new_strategic_target(context, group, source_well_id)
        end
        return true
    end

    update_strategic_recovery(context, group)
    return true
end

local function update_all_target_progress(context)
    local groups = get_wave_groups(context)
    for index = #groups, 1, -1 do
        if not update_wave_group(context, groups[index]) then
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
    context.instance.wave_group_count = 0
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
