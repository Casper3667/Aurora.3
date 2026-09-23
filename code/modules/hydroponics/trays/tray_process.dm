/obj/structure/machinery/portable_atmospherics/hydroponics/process()
	// Stasis needs power and freezes both the plant and its growing medium.
	if((stat & (NOPOWER|BROKEN)) && stasis)
		stasis = FALSE
		update_use_power(POWER_USE_IDLE)
	if(stasis)
		return
	sync_model_from_legacy()

	for(var/obj/effect/smoke/chem/smoke in view(1, src))
		if(smoke.reagents.total_volume)
			smoke.reagents.trans_to_obj(src, 5, copy = 1)

	process_reagents()
	if(force_update)
		force_update = FALSE
	else if(world.time < lastcycle + cycledelay)
		return
	lastcycle = world.time

	sync_model_from_legacy()
	var/datum/plant_growing_medium/medium = growing_medium

	// Weed pressure also accrues continuously at the old average rate.
	if(!mechanical && medium.water > 10 && medium.nutrients > 2)
		medium.weeds += (plant ? 0.01 : 0.05) * HYDRO_SPEED_MULTIPLIER
	if(medium.weeds >= 10)
		if(!plant || medium.weeds >= GET_SEED_TRAIT(plant.line, TRAIT_WEED_TOLERANCE))
			sync_legacy_from_model()
			weed_invasion()
			sync_model_from_legacy()

	if(!plant || plant.dead)
		medium.sanitize()
		sync_legacy_from_model()
		if(mechanical)
			update_icon()
		return

	var/datum/seed/line = plant.line
	var/immutability = GET_SEED_TRAIT(line, TRAIT_IMMUTABLE)
	// Highly mutable plants gain a steady five exposure per cycle: the expected
	// rate of the old 5% roll, without arbitrarily succeeding or failing.
	if(immutability == -1)
		plant.mutation_pressure += 5
	if(immutability <= 0 && plant.mutation_pressure >= 100)
		var/mutation_severity = plant.mutation_pressure >= 115 ? 2 : 1
		plant.mutation_count++
		if(immutability == -1 && !(plant.mutation_count % 5))
			mutation_severity = 2
		sync_legacy_from_model()
		mutate(mutation_severity)
		sync_model_from_legacy()
		plant.mutation_pressure = 0
		line = plant.line
	else if(immutability != -1)
		plant.mutation_pressure = max(0, plant.mutation_pressure - 3)

	var/turf/current_turf = get_turf(src)
	var/datum/gas_mixture/atmosphere
	if(closed_system && (connected_port || holding))
		atmosphere = air_contents
	if(!atmosphere && current_turf)
		atmosphere = current_turf.return_air()
	if(!atmosphere)
		medium.sanitize()
		plant.sanitize()
		sync_legacy_from_model()
		return

	var/light_supplied = closed_system ? tray_light : current_turf.get_lumcount(0, 3) * 5
	var/datum/plant_environment/environment = new(current_turf, atmosphere, light_supplied)
	var/datum/plant_tick_result/tick_result = plant.process_cycle(environment, medium, HYDRO_SPEED_MULTIPLIER)
	var/plant_died = tick_result.died
	if(closed_system && connected_port)
		update_connected_network()

	if(tick_result.died)
		sync_legacy_from_model()
		die()
		sync_model_from_legacy()
	else if(tick_result.became_harvestable)
		if(GET_SEED_TRAIT(line, TRAIT_SPOROUS) && !closed_system)
			line.create_spores(get_turf(src))
			visible_message(SPAN_DANGER("\The [src] releases its spores!"))
	qdel(tick_result)
	qdel(environment)
	if(plant_died)
		return

	if(!closed_system && GET_SEED_TRAIT(line, TRAIT_SPREAD) == 2 && 2 * plant.age >= GET_SEED_TRAIT(line, TRAIT_MATURATION) && !(locate(/obj/effect/plant) in get_turf(src)))
		plant.wild_spread_progress += min(1, 2 * GET_SEED_TRAIT(line, TRAIT_POTENCY) / 100) * plant.growth_variance
		if(plant.wild_spread_progress >= 1)
			plant.wild_spread_progress -= 1
			new /obj/effect/plant(get_turf(src), line)

	// Pest pressure accrues continuously at the old average arrival rate.
	medium.pests += 0.003 * HYDRO_SPEED_MULTIPLIER

	sync_legacy_from_model()
	if(plant.line.species.can_self_harvest && plant.harvest_ready && !closed_system)
		plant.self_harvest_progress += 0.05 * HYDRO_SPEED_MULTIPLIER
		if(plant.self_harvest_progress >= 1)
			harvest()
			return
	update_icon()
