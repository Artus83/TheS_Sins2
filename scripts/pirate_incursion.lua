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
    debug_hud = true,
    wave_interval_seconds = 20.0,
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
    supply_end_time = 7200,

    level_start = 3,
    level_end = 10,
    level_end_time = 10800,

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
-- Lua chooses only strategic route destinations. Native auto-order AI owns
-- tactical combat and uses the live diplomacy state. Route waypoints are never
-- treated as proof that their owner is hostile, so alliance changes cannot turn
-- an allied gravity well into a permanent objective.
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
    context.instance[wave_group_state_key(slot, "route_cursor_well_id")] = group.route_cursor_well_id
    context.instance[wave_group_state_key(slot, "preferred_target_player_index")] = group.preferred_target_player_index
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
                    route_cursor_well_id = context.instance[wave_group_state_key(slot, "route_cursor_well_id")],
                    preferred_target_player_index = context.instance[wave_group_state_key(slot, "preferred_target_player_index")],
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

-- Lua has no direct player-alliance query. Use a stable strategic heuristic for
-- the first foreign empire each wave prefers: rank foreign home worlds by the
-- shortest phase-lane jump distance from the wave owner's home world, keep the
-- farthest half (rounded up), then choose the highest-economic-score player from
-- that half. This strongly biases team games away from the nearby ally without
-- pretending Lua knows the real diplomacy state. Native engage_any_targets still
-- decides actual hostility. After the preferred empire is placed first, the
-- existing foreign route order is preserved for all remaining empires and
-- secondary worlds.
local function get_foreign_route_well_ids(context, group)
    local attacker_player_index = group.attacker_player_index
    local player_indices = context.simulation:filter_playable_players(function(player)
        return not player.is_npc
            and not player.has_lost
            and player.player_index ~= attacker_player_index
    end)
    table.sort(player_indices)

    -- Build shortest-path jump distances once from this wave's spawn/home well.
    -- Every phase lane counts as one jump. Unreachable wells are left absent and
    -- therefore cannot enter the farthest-half target candidate set.
    local jump_distance_by_well_id = {}
    if group.spawn_well_id ~= nil
        and group.spawn_well_id ~= 0
        and context.simulation:does_unit_exist_by_id(group.spawn_well_id)
    then
        local queue = { group.spawn_well_id }
        local queue_head = 1
        jump_distance_by_well_id[group.spawn_well_id] = 0

        while queue_head <= #queue do
            local current_well_id = queue[queue_head]
            queue_head = queue_head + 1
            local current_distance = jump_distance_by_well_id[current_well_id]
            local adjacent_wells = context.simulation:get_adjacent_gravity_wells_by_id(current_well_id)

            if adjacent_wells ~= nil then
                for _, adjacent_well in ipairs(adjacent_wells) do
                    if adjacent_well ~= nil
                        and adjacent_well.id ~= nil
                        and jump_distance_by_well_id[adjacent_well.id] == nil
                    then
                        jump_distance_by_well_id[adjacent_well.id] = current_distance + 1
                        queue[#queue + 1] = adjacent_well.id
                    end
                end
            end
        end
    end

    local player_entries = {}

    for _, player_index in ipairs(player_indices) do
        local player = context.simulation:get_player_by_player_index(player_index)
        local owned_wells = context.simulation:get_gravity_wells_owned_by_player_index(player_index)

        if player ~= nil and owned_wells ~= nil and #owned_wells > 0 then
            local sorted_wells = {}
            for _, well in ipairs(owned_wells) do
                if well ~= nil and well.id ~= nil then
                    sorted_wells[#sorted_wells + 1] = well
                end
            end
            table.sort(sorted_wells, function(a, b) return a.id < b.id end)

            if #sorted_wells > 0 then
                local home_well = nil
                if player.home_planet ~= nil then
                    for _, well in ipairs(sorted_wells) do
                        local primary_fixture = context.simulation:get_gravity_well_primary_fixture(well)
                        if primary_fixture ~= nil and primary_fixture.id == player.home_planet.id then
                            home_well = well
                            break
                        end
                    end
                end

                -- A living player with territory should normally have a resolvable
                -- home world. Fall back to their first owned well if the original
                -- home planet was lost or cannot be resolved.
                if home_well == nil then
                    home_well = sorted_wells[1]
                end

                player_entries[#player_entries + 1] = {
                    player_index = player_index,
                    economic_score = tonumber(player.economic_score) or 0,
                    jump_distance = jump_distance_by_well_id[home_well.id],
                    home_well_id = home_well.id,
                    sorted_wells = sorted_wells
                }
            end
        end
    end

    if #player_entries == 0 then
        group.preferred_target_player_index = nil
        return {}
    end

    local preferred_entry = nil
    if group.preferred_target_player_index ~= nil then
        for _, entry in ipairs(player_entries) do
            if entry.player_index == group.preferred_target_player_index then
                preferred_entry = entry
                break
            end
        end
    end

    -- Select once per wave and keep the choice stable while that player remains
    -- alive and owns territory. If that player disappears, this block selects a
    -- replacement using the same farthest-half + highest-economy rule.
    if preferred_entry == nil then
        local by_distance = {}
        for _, entry in ipairs(player_entries) do
            if entry.jump_distance ~= nil then
                by_distance[#by_distance + 1] = entry
            end
        end

        if #by_distance == 0 then
            group.preferred_target_player_index = nil
            debug_print("no phase-lane-reachable foreign home world for " .. tostring(group.tracker_name))
            return {}
        end

        table.sort(by_distance, function(a, b)
            if a.jump_distance ~= b.jump_distance then
                return a.jump_distance > b.jump_distance
            end
            return a.player_index < b.player_index
        end)

        local candidate_count = math.max(1, math.floor((#by_distance + 1) / 2))
        for index = 1, candidate_count do
            local entry = by_distance[index]
            if preferred_entry == nil
                or entry.economic_score > preferred_entry.economic_score
                or (entry.economic_score == preferred_entry.economic_score
                    and entry.jump_distance > preferred_entry.jump_distance)
                or (entry.economic_score == preferred_entry.economic_score
                    and entry.jump_distance == preferred_entry.jump_distance
                    and entry.player_index < preferred_entry.player_index)
            then
                preferred_entry = entry
            end
        end

        group.preferred_target_player_index = preferred_entry.player_index
        debug_print("preferred strategic player " .. tostring(group.tracker_name)
            .. " | player " .. tostring(preferred_entry.player_index)
            .. " | farthest-half candidates " .. tostring(candidate_count)
            .. "/" .. tostring(#by_distance)
            .. " | jumps " .. tostring(preferred_entry.jump_distance)
            .. " | economy " .. tostring(preferred_entry.economic_score))
    end

    -- Keep the old deterministic player-index order for every player after the
    -- preferred target. Only the first strategic empire is changed by this filter.
    local ordered_entries = { preferred_entry }
    for _, entry in ipairs(player_entries) do
        if entry.player_index ~= preferred_entry.player_index then
            ordered_entries[#ordered_entries + 1] = entry
        end
    end

    local home_ids = {}
    local other_ids = {}
    local seen = {}

    for _, entry in ipairs(ordered_entries) do
        if entry.home_well_id ~= nil and not seen[entry.home_well_id] then
            seen[entry.home_well_id] = true
            home_ids[#home_ids + 1] = entry.home_well_id
        end

        for _, well in ipairs(entry.sorted_wells) do
            if not seen[well.id] then
                seen[well.id] = true
                other_ids[#other_ids + 1] = well.id
            end
        end
    end

    local ordered_ids = {}
    for _, well_id in ipairs(home_ids) do ordered_ids[#ordered_ids + 1] = well_id end
    for _, well_id in ipairs(other_ids) do ordered_ids[#ordered_ids + 1] = well_id end
    return ordered_ids
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

local function issue_wave_strategic_move(context, group, target_well_id, reason, clear_orders)
    if target_well_id == nil then return false end

    local tracker = get_or_create_wave_tracker(context, group)
    local issued_any = false
    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            context.simulation:set_unit_auto_order_mode_by_id(unit_id, "engage_any_targets")
            local success = context.simulation:issue_move_order_by_id(unit_id, target_well_id, {
                clear_orders = clear_orders == true,
                ai_override = "anytime"
            })
            if success then issued_any = true end
        end
    end

    if issued_any then
        group.last_order_time = context.simulation.current_time
        debug_print("strategic move " .. tostring(group.tracker_name)
            .. " -> well " .. tostring(target_well_id)
            .. " | " .. tostring(reason or "order"))
    end
    return issued_any
end

-- Briefly clear the long-range pilgrimage for ships that have reached a new
-- gravity well. Native engage_any_targets remains enabled and decides whether
-- anything in that well is actually hostile.
local function release_wave_to_native_ai(context, group, current_well_id)
    if current_well_id == nil or current_well_id == 0 then return {} end

    local tracker = get_or_create_wave_tracker(context, group)
    local released_unit_ids = {}

    for _, unit_id in ipairs(tracker:get_units()) do
        if context.simulation:does_unit_exist_by_id(unit_id)
            and context.simulation:get_unit_current_gravity_well_id(unit_id) == current_well_id
        then
            context.simulation:set_unit_auto_order_mode_by_id(unit_id, "engage_any_targets")
            local success = context.simulation:issue_move_order_by_id(unit_id, current_well_id, {
                clear_orders = true,
                ai_override = "anytime",
                stop_at_destination = true,
                allow_hyperspace = false,
                relative_destination = "closest",
                max_duration = 1.0
            })
            if success then
                released_unit_ids[#released_unit_ids + 1] = unit_id
            end
        end
    end

    if #released_unit_ids > 0 then
        debug_print("native combat release " .. tostring(group.tracker_name)
            .. " | well " .. tostring(current_well_id)
            .. " | ships " .. tostring(#released_unit_ids))
    end

    return released_unit_ids
end

local function resume_released_wave_units(context, group, unit_ids, target_well_id)
    if target_well_id == nil then return false end

    local issued_any = false
    for _, unit_id in ipairs(unit_ids or {}) do
        if context.simulation:does_unit_exist_by_id(unit_id) then
            context.simulation:set_unit_auto_order_mode_by_id(unit_id, "engage_any_targets")
            local success = context.simulation:issue_move_order_by_id(unit_id, target_well_id, {
                clear_orders = false,
                ai_override = "anytime"
            })
            if success then issued_any = true end
        end
    end

    if issued_any then
        group.last_order_time = context.simulation.current_time
        debug_print("resume pilgrimage " .. tostring(group.tracker_name)
            .. " -> well " .. tostring(target_well_id))
    end

    return issued_any
end

-- Select the next stable route waypoint without making any diplomatic assumption.
-- The cursor prevents the old "nearest other player" logic from selecting the well
-- the wave is already sitting in, and also prevents two nearby allied wells from
-- becoming a permanent bounce pair. When there is only one foreign-owned well,
-- the route goes back to the wave's spawn well before visiting it again.
local function select_next_route_waypoint(context, group, current_well_id)
    local route_well_ids = get_foreign_route_well_ids(context, group)
    local cursor = group.route_cursor_well_id

    if #route_well_ids > 0 then
        local start_index = 1

        if cursor ~= nil then
            local found_cursor = false
            for index, well_id in ipairs(route_well_ids) do
                if well_id == cursor then
                    start_index = (index % #route_well_ids) + 1
                    found_cursor = true
                    break
                end
            end

            if not found_cursor then
                -- The preferred player can change only if the previous preferred
                -- player is gone. Restart from the new route head in that case.
                start_index = 1
            end
        end

        for offset = 0, #route_well_ids - 1 do
            local index = ((start_index + offset - 1) % #route_well_ids) + 1
            local well_id = route_well_ids[index]
            if well_id ~= current_well_id then
                return well_id, true
            end
        end
    end

    if group.spawn_well_id ~= nil
        and group.spawn_well_id ~= 0
        and group.spawn_well_id ~= current_well_id
        and context.simulation:does_unit_exist_by_id(group.spawn_well_id)
    then
        return group.spawn_well_id, false
    end

    return nil, false
end

local function assign_next_route_target(context, group, current_well_id, reason, clear_orders)
    if current_well_id == nil or current_well_id == 0 then
        current_well_id = group.spawn_well_id
    end

    local target_well_id, is_foreign_waypoint = select_next_route_waypoint(
        context,
        group,
        current_well_id
    )

    group.strategic_target_well_id = target_well_id
    group.next_target_search_time = nil
    persist_wave_group_state(context, group)

    if target_well_id == nil then
        group.next_target_search_time = context.simulation.current_time + CONFIG.target_search_retry_seconds
        debug_print("no foreign route waypoint for " .. tostring(group.tracker_name))
        return false
    end

    debug_print("strategic route target " .. tostring(group.tracker_name)
        .. " | well " .. tostring(target_well_id)
        .. (is_foreign_waypoint and " | foreign waypoint" or " | return waypoint"))

    if current_well_id == target_well_id then return true end

    return issue_wave_strategic_move(
        context,
        group,
        target_well_id,
        reason or "route target",
        clear_orders
    )
end

-- A route waypoint is complete as soon as the wave reaches it. Lua does not wait
-- for ownership changes or attempt to decide whether the owner is an ally/enemy.
-- If attackable enemies are present, native engage_any_targets overrides the
-- queued move and fights them; after combat the queued strategic route continues.
local function advance_route_if_waypoint_reached(context, group, current_well_id)
    local target_well_id = group.strategic_target_well_id
    if target_well_id == nil or current_well_id == nil then return false end
    if current_well_id ~= target_well_id then return false end

    if target_well_id ~= group.spawn_well_id then
        group.route_cursor_well_id = target_well_id
    end

    return assign_next_route_target(
        context,
        group,
        current_well_id,
        "next route waypoint",
        false
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
    local start_level = CONFIG.level_start or 1
    local end_level = CONFIG.level_end or start_level
    local end_time = CONFIG.level_end_time or 0
    if end_time <= 0 then return end_level end
    if game_time <= 0 then return start_level end
    if game_time >= end_time then return end_level end
    local progress = game_time / end_time
    return math.floor(start_level + ((end_level - start_level) * progress) + 0.5)
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

    local group = {
        attacker_player_index = player_index,
        spawn_well_id = spawn_well.id,
        strategic_target_well_id = nil,
        route_cursor_well_id = nil,
        preferred_target_player_index = nil,
        last_observed_well_id = spawn_well.id,
        tracker_name = "incursion_wave_" .. tostring(context.instance_id)
            .. "_" .. tostring(player_index) .. "_" .. tostring(wave_number)
    }

    local strategic_target_well_id = select_next_route_waypoint(
        context,
        group,
        spawn_well.id
    )
    if strategic_target_well_id == nil then return false end
    group.strategic_target_well_id = strategic_target_well_id

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

    debug_print("initial strategic route target " .. tostring(group.tracker_name)
        .. " | well " .. tostring(strategic_target_well_id))

    if spawn_well.id ~= strategic_target_well_id then
        if not issue_wave_strategic_move(
            context,
            group,
            strategic_target_well_id,
            "initial route target",
            true
        ) then
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
    local current_well_id = get_first_living_wave_well_id(context, group)

    -- A one-second native-AI release is processed on the event's 1.0 second update
    -- cadence, independently of the existing 5-second strategic controller cadence.
    if group.native_ai_release_until ~= nil then
        if now < group.native_ai_release_until then return true end

        local resume_target_well_id = group.native_ai_resume_target_well_id
        local released_unit_ids = group.native_ai_release_unit_ids
        group.native_ai_release_until = nil
        group.native_ai_resume_target_well_id = nil
        group.native_ai_release_unit_ids = nil

        if resume_target_well_id ~= nil
            and context.simulation:does_unit_exist_by_id(resume_target_well_id)
        then
            resume_released_wave_units(
                context,
                group,
                released_unit_ids,
                resume_target_well_id
            )
        end
        return true
    end

    -- Intermediate wells are otherwise invisible to the strategic controller.
    -- When the representative living ship is first observed in a different well,
    -- briefly clear the pilgrimage only for wave ships already in that same well.
    -- Native engage_any_targets then gets one complete event update interval to
    -- acquire any attackable ships, structures, or planets before the pilgrimage
    -- is appended again without clearing native combat orders.
    if current_well_id ~= nil then
        if group.last_observed_well_id == nil then
            group.last_observed_well_id = current_well_id
        elseif current_well_id ~= group.last_observed_well_id then
            group.last_observed_well_id = current_well_id

            if group.strategic_target_well_id ~= nil
                and context.simulation:does_unit_exist_by_id(group.strategic_target_well_id)
            then
                local released_unit_ids = release_wave_to_native_ai(
                    context,
                    group,
                    current_well_id
                )

                if #released_unit_ids > 0 then
                    group.native_ai_release_unit_ids = released_unit_ids
                    group.native_ai_resume_target_well_id = group.strategic_target_well_id
                    group.native_ai_release_until = now + 1.0
                    return true
                end
            end
        end
    end

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

    if group.strategic_target_well_id == nil
        or not context.simulation:does_unit_exist_by_id(group.strategic_target_well_id)
    then
        if group.next_target_search_time == nil or now >= group.next_target_search_time then
            assign_next_route_target(
                context,
                group,
                current_well_id,
                "replacement route target",
                false
            )
        end
        return true
    end

    -- Reaching a waypoint always advances the route. Diplomacy is intentionally
    -- left to native engage_any_targets, so allied wells can never become a
    -- permanent Lua objective and alliance changes require no cached refresh.
    advance_route_if_waypoint_reached(context, group, current_well_id)
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
