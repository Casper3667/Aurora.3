#define NEIGHBOR_REFRESH_TIME 100

/obj/effect/plant/proc/get_cardinal_neighbors()
	var/list/cardinal_neighbors = list()
	for(var/check_dir in GLOB.cardinals)
		var/turf/simulated/T = get_step(get_turf(src), check_dir)
		if(istype(T))
			cardinal_neighbors |= T
	return cardinal_neighbors

/obj/effect/plant/proc/update_neighbors()
	// Update our list of valid neighboring turfs.
	neighbors = list()
	for(var/turf/simulated/floor in get_cardinal_neighbors())
		if(get_dist(parent, floor) > spread_distance)
			continue
		if((locate(/obj/effect/plant) in floor.contents) || (locate(/obj/effect/dead_plant) in floor.contents) )
			continue
		if(floor.density)
			if(seed && seed.chems[/singleton/reagent/acid/polyacid])
				addtimer(CALLBACK(floor, TYPE_PROC_REF(/atom, ex_act), 3), rand(5, 25))
			continue
		if(!Adjacent(floor) || !floor.Enter(src))
			continue
		neighbors |= floor

	if (neighbors.len)
		SSplants.add_plant(src)

	// Update all of our friends.
	var/turf/T = get_turf(src)
	for(var/obj/effect/plant/neighbor in range(1,src))
		neighbor.neighbors -= T

/obj/effect/plant/process()
	// Something is very wrong, kill ourselves.
	if(!seed)
		die_off()
		return 0

	for(var/obj/effect/smoke/chem/smoke in view(1, src))
		if(smoke.reagents.has_reagent(/singleton/reagent/toxin/plantbgone))
			die_off()
			return

	// Handle life.
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		health -= seed.handle_environment(T,T.return_air(),null,1)
	if(health < maxhealth)
		health += 4
		refresh_icon()
		if(health > maxhealth)
			health = maxhealth
	else if(health == maxhealth && !plant)
		plant = new(T,seed)
		plant.dir = src.dir
		plant.transform = src.transform
		plant.age = GET_SEED_TRAIT(seed, TRAIT_MATURATION)-1
		plant.update_icon()
		if(growth_type==0) //Vines do not become invisible.
			set_invisibility(INVISIBILITY_MAXIMUM)
		else
			plant.layer = layer + 0.1

	if(buckled)
		seed.do_sting(buckled,src)
		if(GET_SEED_TRAIT(seed, TRAIT_CARNIVOROUS))
			seed.do_thorns(buckled,src)

	if(world.time >= last_tick+NEIGHBOR_REFRESH_TIME)
		last_tick = world.time
		update_neighbors()

	if(sampled)
		var/recovery_time = max(1, GET_SEED_TRAIT(seed, TRAIT_PRODUCTION))
		sample_regrowth_progress += 0.3 / recovery_time
		if(sample_regrowth_progress >= 1)
			sampled = 0
			sample_regrowth_progress = 0

	if(is_mature() && neighbors.len && spread_chance > 0)
		// Preserve the old long-run spread rate without rerolling whether the
		// plant grows on every controller tick.
		var/max_spread = between(1, round(GET_SEED_TRAIT(seed, TRAIT_YIELD)*3/14), 3)
		var/spread_rate = clamp(spread_chance / 100, 0, 1)
		spread_progress += spread_rate * spread_rate * max_spread
		var/spread_count = FLOOR(spread_progress, 1)
		if(spread_count > 0)
			spread_progress -= spread_count
			do_spread(spread_count)

	// We shouldn't have spawned if the controller doesn't exist.
	check_health()
	if(neighbors.len || health != maxhealth || buckled || !is_mature())
		SSplants.add_plant(src)

/obj/effect/plant/proc/do_spread(spread_count)
	set waitfor = FALSE
	for(var/i in 1 to spread_count)
		sleep(rand(3,5))
		if(!neighbors.len)
			return

		var/turf/target_turf = pick(neighbors)
		var/obj/effect/plant/child = new(get_turf(src),seed,parent)
		// This should do a little bit of animation.
		addtimer(CALLBACK(src, PROC_REF(do_move), target_turf, child), 1)
		// Update neighboring squares.
		for(var/obj/effect/plant/neighbor in range(1,target_turf))
			neighbor.neighbors -= target_turf

/obj/effect/plant/proc/do_move(turf/target, obj/effect/plant/child)
	child.forceMove(target)
	child.queue_icon_update()

/obj/effect/plant/proc/die_off()
	// Kill off our plant.
	if(plant) plant.die()
	// This turf is clear now, let our buddies know.
	for(var/turf/simulated/check_turf in get_cardinal_neighbors())
		if(!istype(check_turf))
			continue
		for(var/obj/effect/plant/neighbor in check_turf.contents)
			neighbor.neighbors |= check_turf
			SSplants.add_plant(neighbor)

	qdel(src)

#undef NEIGHBOR_REFRESH_TIME
