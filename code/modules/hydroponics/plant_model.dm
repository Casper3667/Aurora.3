/**
 * Immutable identity and presentation data for a plant species.
 *
 * Existing /datum/seed subtypes remain the content authoring format during the
 * migration. Each seed builds one of these records after its subtype has set up
 * its defaults. Cultivars share this datum instead of repeatedly copying static
 * species data.
 */
/datum/plant_species
	var/id
	var/seed_name
	var/seed_noun
	var/display_name
	var/kitchen_tag
	var/trash_type
	var/splat_type
	var/product_desc
	var/product_desc_extended
	var/force_layer
	var/hydrotray_only = FALSE
	var/harvest_time
	var/can_self_harvest = FALSE
	var/base_growth_speed
	var/temperature_growth_boost
	var/light_growth_boost
	var/list/mutants

/datum/plant_species/New(datum/seed/source)
	if(!source)
		return
	id = source.name
	seed_name = source.seed_name
	seed_noun = source.seed_noun
	display_name = source.display_name
	kitchen_tag = source.kitchen_tag
	trash_type = source.trash_type
	splat_type = source.splat_type
	product_desc = source.product_desc
	product_desc_extended = source.product_desc_extended
	force_layer = source.force_layer
	hydrotray_only = source.hydrotray_only
	harvest_time = source.harvest_time
	can_self_harvest = source.can_self_harvest
	base_growth_speed = source.base_growth_speed
	temperature_growth_boost = source.temperature_growth_boost
	light_growth_boost = source.light_growth_boost
	mutants = source.mutants?.Copy()

/**
 * Mutable, inheritable properties of a cultivar.
 *
 * These are deliberately real vars rather than values hidden in an associative
 * list. get_trait()/set_trait() are the temporary bridge for existing plant
 * definitions and callers which use the TRAIT_* constants.
 */
/datum/plant_genome
	var/chemistry
	var/exude_gasses
	var/alter_temperature = 0
	var/potency = 1
	var/repeat_harvest = FALSE
	var/produces_power = FALSE
	var/juicy = 0
	var/product_icon
	var/plant_icon
	var/consume_gasses
	var/requires_nutrients = TRUE
	var/nutrient_consumption = 0.25
	var/requires_water = TRUE
	var/water_consumption = 3
	var/carnivorous = 0
	var/parasitic = FALSE
	var/stinging = FALSE
	var/ideal_heat = IDEAL_HEAT_TEMPERATE
	var/heat_tolerance = 12
	var/ideal_light = IDEAL_LIGHT_TEMPERATE
	var/light_tolerance = 2.5
	var/low_pressure_tolerance = 25
	var/high_pressure_tolerance = 200
	var/explosive = FALSE
	var/toxin_tolerance = 5
	var/pest_tolerance = 5
	var/weed_tolerance = 5
	var/endurance = 100
	var/yield = 0
	var/spread = 0
	var/maturation = 0
	var/production = 0
	var/teleporting = FALSE
	var/plant_colour = "#46B543"
	var/product_colour
	var/bioluminescent = FALSE
	var/bioluminescent_colour
	var/immutable = 0
	var/flesh_colour
	var/sporous = FALSE
	var/bioluminescent_power = 1
	var/large = FALSE
	var/leaves_colour
	var/heat_preference = 5
	var/light_preference = 1.5
	var/product_type = /obj/item/reagent_containers/food/snacks/grown

/datum/plant_genome/proc/clone()
	var/datum/plant_genome/copy = new
	copy.chemistry = islist(chemistry) ? deep_copy_list(chemistry) : chemistry
	copy.exude_gasses = islist(exude_gasses) ? deep_copy_list(exude_gasses) : exude_gasses
	copy.consume_gasses = islist(consume_gasses) ? deep_copy_list(consume_gasses) : consume_gasses
	copy.alter_temperature = alter_temperature
	copy.potency = potency
	copy.repeat_harvest = repeat_harvest
	copy.produces_power = produces_power
	copy.juicy = juicy
	copy.product_icon = product_icon
	copy.plant_icon = plant_icon
	copy.requires_nutrients = requires_nutrients
	copy.nutrient_consumption = nutrient_consumption
	copy.requires_water = requires_water
	copy.water_consumption = water_consumption
	copy.carnivorous = carnivorous
	copy.parasitic = parasitic
	copy.stinging = stinging
	copy.ideal_heat = ideal_heat
	copy.heat_tolerance = heat_tolerance
	copy.ideal_light = ideal_light
	copy.light_tolerance = light_tolerance
	copy.low_pressure_tolerance = low_pressure_tolerance
	copy.high_pressure_tolerance = high_pressure_tolerance
	copy.explosive = explosive
	copy.toxin_tolerance = toxin_tolerance
	copy.pest_tolerance = pest_tolerance
	copy.weed_tolerance = weed_tolerance
	copy.endurance = endurance
	copy.yield = yield
	copy.spread = spread
	copy.maturation = maturation
	copy.production = production
	copy.teleporting = teleporting
	copy.plant_colour = plant_colour
	copy.product_colour = product_colour
	copy.bioluminescent = bioluminescent
	copy.bioluminescent_colour = bioluminescent_colour
	copy.immutable = immutable
	copy.flesh_colour = flesh_colour
	copy.sporous = sporous
	copy.bioluminescent_power = bioluminescent_power
	copy.large = large
	copy.leaves_colour = leaves_colour
	copy.heat_preference = heat_preference
	copy.light_preference = light_preference
	copy.product_type = product_type
	return copy

/datum/plant_genome/proc/get_trait(trait)
	switch(trait)
		if(TRAIT_CHEMS) return chemistry
		if(TRAIT_EXUDE_GASSES) return exude_gasses
		if(TRAIT_ALTER_TEMP) return alter_temperature
		if(TRAIT_POTENCY) return potency
		if(TRAIT_HARVEST_REPEAT) return repeat_harvest
		if(TRAIT_PRODUCES_POWER) return produces_power
		if(TRAIT_JUICY) return juicy
		if(TRAIT_PRODUCT_ICON) return product_icon
		if(TRAIT_PLANT_ICON) return plant_icon
		if(TRAIT_CONSUME_GASSES) return consume_gasses
		if(TRAIT_REQUIRES_NUTRIENTS) return requires_nutrients
		if(TRAIT_NUTRIENT_CONSUMPTION) return nutrient_consumption
		if(TRAIT_REQUIRES_WATER) return requires_water
		if(TRAIT_WATER_CONSUMPTION) return water_consumption
		if(TRAIT_CARNIVOROUS) return carnivorous
		if(TRAIT_PARASITE) return parasitic
		if(TRAIT_STINGS) return stinging
		if(TRAIT_IDEAL_HEAT) return ideal_heat
		if(TRAIT_HEAT_TOLERANCE) return heat_tolerance
		if(TRAIT_IDEAL_LIGHT) return ideal_light
		if(TRAIT_LIGHT_TOLERANCE) return light_tolerance
		if(TRAIT_LOWKPA_TOLERANCE) return low_pressure_tolerance
		if(TRAIT_HIGHKPA_TOLERANCE) return high_pressure_tolerance
		if(TRAIT_EXPLOSIVE) return explosive
		if(TRAIT_TOXINS_TOLERANCE) return toxin_tolerance
		if(TRAIT_PEST_TOLERANCE) return pest_tolerance
		if(TRAIT_WEED_TOLERANCE) return weed_tolerance
		if(TRAIT_ENDURANCE) return endurance
		if(TRAIT_YIELD) return yield
		if(TRAIT_SPREAD) return spread
		if(TRAIT_MATURATION) return maturation
		if(TRAIT_PRODUCTION) return production
		if(TRAIT_TELEPORTING) return teleporting
		if(TRAIT_PLANT_COLOUR) return plant_colour
		if(TRAIT_PRODUCT_COLOUR) return product_colour
		if(TRAIT_BIOLUM) return bioluminescent
		if(TRAIT_BIOLUM_COLOUR) return bioluminescent_colour
		if(TRAIT_IMMUTABLE) return immutable
		if(TRAIT_FLESH_COLOUR) return flesh_colour
		if(TRAIT_SPOROUS) return sporous
		if(TRAIT_BIOLUM_PWR) return bioluminescent_power
		if(TRAIT_LARGE) return large
		if(TRAIT_LEAVES_COLOUR) return leaves_colour
		if(TRAIT_HEAT_PREFERENCE) return heat_preference
		if(TRAIT_LIGHT_PREFERENCE) return light_preference

/datum/plant_genome/proc/set_trait(trait, value)
	switch(trait)
		if(TRAIT_CHEMS) chemistry = value
		if(TRAIT_EXUDE_GASSES) exude_gasses = value
		if(TRAIT_ALTER_TEMP) alter_temperature = value
		if(TRAIT_POTENCY) potency = value
		if(TRAIT_HARVEST_REPEAT) repeat_harvest = value
		if(TRAIT_PRODUCES_POWER) produces_power = value
		if(TRAIT_JUICY) juicy = value
		if(TRAIT_PRODUCT_ICON) product_icon = value
		if(TRAIT_PLANT_ICON) plant_icon = value
		if(TRAIT_CONSUME_GASSES) consume_gasses = value
		if(TRAIT_REQUIRES_NUTRIENTS) requires_nutrients = value
		if(TRAIT_NUTRIENT_CONSUMPTION) nutrient_consumption = value
		if(TRAIT_REQUIRES_WATER) requires_water = value
		if(TRAIT_WATER_CONSUMPTION) water_consumption = value
		if(TRAIT_CARNIVOROUS) carnivorous = value
		if(TRAIT_PARASITE) parasitic = value
		if(TRAIT_STINGS) stinging = value
		if(TRAIT_IDEAL_HEAT) ideal_heat = value
		if(TRAIT_HEAT_TOLERANCE) heat_tolerance = value
		if(TRAIT_IDEAL_LIGHT) ideal_light = value
		if(TRAIT_LIGHT_TOLERANCE) light_tolerance = value
		if(TRAIT_LOWKPA_TOLERANCE) low_pressure_tolerance = value
		if(TRAIT_HIGHKPA_TOLERANCE) high_pressure_tolerance = value
		if(TRAIT_EXPLOSIVE) explosive = value
		if(TRAIT_TOXINS_TOLERANCE) toxin_tolerance = value
		if(TRAIT_PEST_TOLERANCE) pest_tolerance = value
		if(TRAIT_WEED_TOLERANCE) weed_tolerance = value
		if(TRAIT_ENDURANCE) endurance = value
		if(TRAIT_YIELD) yield = value
		if(TRAIT_SPREAD) spread = value
		if(TRAIT_MATURATION) maturation = value
		if(TRAIT_PRODUCTION) production = value
		if(TRAIT_TELEPORTING) teleporting = value
		if(TRAIT_PLANT_COLOUR) plant_colour = value
		if(TRAIT_PRODUCT_COLOUR) product_colour = value
		if(TRAIT_BIOLUM) bioluminescent = value
		if(TRAIT_BIOLUM_COLOUR) bioluminescent_colour = value
		if(TRAIT_IMMUTABLE) immutable = value
		if(TRAIT_FLESH_COLOUR) flesh_colour = value
		if(TRAIT_SPOROUS) sporous = value
		if(TRAIT_BIOLUM_PWR) bioluminescent_power = value
		if(TRAIT_LARGE) large = value
		if(TRAIT_LEAVES_COLOUR) leaves_colour = value
		if(TRAIT_HEAT_PREFERENCE) heat_preference = value
		if(TRAIT_LIGHT_PREFERENCE) light_preference = value
	return value

/datum/plant_genome/proc/set_bounded_trait(trait, value, upper_bound, lower_bound, degradation)
	if(!isnum(value))
		return set_trait(trait, value)
	var/effective_degradation = isnull(degradation) ? 1 : degradation
	var/effective_lower = isnull(lower_bound) ? -INFINITY : lower_bound
	var/effective_upper = isnull(upper_bound) ? INFINITY : upper_bound
	return set_trait(trait, clamp(value * effective_degradation, effective_lower, effective_upper))

/datum/plant_genome/proc/validate()
	heat_tolerance = max(0, heat_tolerance)
	light_tolerance = max(0, light_tolerance)
	heat_preference = clamp(heat_preference, 0, heat_tolerance)
	light_preference = clamp(light_preference, 0, light_tolerance)
	low_pressure_tolerance = max(0, low_pressure_tolerance)
	high_pressure_tolerance = max(low_pressure_tolerance, high_pressure_tolerance)
	endurance = max(1, endurance)
	maturation = max(0, maturation)
	production = max(0, production)

/datum/plant_genome/proc/is_outside_light_tolerance(light_supplied)
	if(isnull(light_supplied))
		return TRUE
	return abs(light_supplied - ideal_light) > light_tolerance

/datum/plant_genome/proc/is_outside_heat_tolerance(datum/gas_mixture/atmosphere)
	if(!atmosphere)
		return TRUE
	return abs(atmosphere.temperature - ideal_heat) > heat_tolerance

/datum/plant_genome/proc/is_within_light_preference(light_supplied)
	if(isnull(light_supplied))
		return FALSE
	return abs(light_supplied - ideal_light) < light_preference

/datum/plant_genome/proc/is_within_heat_preference(datum/gas_mixture/atmosphere)
	if(!atmosphere)
		return FALSE
	return abs(atmosphere.temperature - ideal_heat) < heat_preference

/// Calculates continuous growth using immutable species rates and this genome's preferences.
/datum/plant_genome/proc/get_growth_rate(datum/plant_species/species, datum/gas_mixture/atmosphere, light_supplied)
	if(!species || !atmosphere)
		return 0
	var/growth_rate = species.base_growth_speed
	if(is_within_heat_preference(atmosphere))
		growth_rate += species.temperature_growth_boost
	if(is_within_light_preference(light_supplied))
		growth_rate += species.light_growth_boost
	return max(0, growth_rate)

/**
 * Applies atmospheric exchange and returns deterministic environmental damage.
 * Preview callers can disable exchange while still evaluating the conditions.
 */
/datum/plant_genome/proc/apply_environment(datum/plant_environment/environment, speed_multiplier = 1, apply_exchange = TRUE)
	if(!environment?.atmosphere)
		return 0

	var/datum/gas_mixture/atmosphere = environment.atmosphere
	var/health_damage = 0
	if(LAZYLEN(consume_gasses))
		var/missing_gasses = 0
		for(var/gas in consume_gasses)
			if(atmosphere.gas && atmosphere.gas[gas] && atmosphere.gas[gas] >= consume_gasses[gas])
				if(apply_exchange)
					atmosphere.adjust_gas(gas, -consume_gasses[gas], TRUE)
			else
				missing_gasses++
		health_damage += missing_gasses * speed_multiplier

	var/pressure = XGM_PRESSURE(atmosphere)
	if(pressure < low_pressure_tolerance || pressure > high_pressure_tolerance)
		health_damage += 2 * speed_multiplier
	if(is_outside_heat_tolerance(atmosphere))
		health_damage += 2 * speed_multiplier
	if(is_outside_light_tolerance(environment.light))
		health_damage += 2 * speed_multiplier

	if(apply_exchange && LAZYLEN(exude_gasses))
		var/gas_count = LAZYLEN(exude_gasses)
		for(var/gas in exude_gasses)
			atmosphere.adjust_gas(gas, max(1, round((exude_gasses[gas] * (potency / 5)) / gas_count)))
	if(apply_exchange && alter_temperature)
		atmosphere.temperature = max(0, atmosphere.temperature + alter_temperature)

	return health_damage

/// A normalized view of the conditions supplied by any growing container.
/datum/plant_environment
	var/turf/location
	var/datum/gas_mixture/atmosphere
	var/light = 0

/datum/plant_environment/New(turf/new_location, datum/gas_mixture/new_atmosphere, supplied_light)
	location = new_location
	atmosphere = new_atmosphere
	light = supplied_light

/// Explicit output from a growth step; callers decide how to present events.
/datum/plant_tick_result
	var/growth_added = 0
	var/age_advanced = 0
	var/blocked_by_environment = FALSE
	var/health_delta = 0
	var/became_harvestable = FALSE
	var/died = FALSE

/// Resources and contaminants belonging to the growing medium, not the plant.
/datum/plant_growing_medium
	var/water = 100
	var/nutrients = 10
	var/pests = 0
	var/weeds = 0
	var/toxins = 0
	var/max_water = 100
	var/max_nutrients = 10
	var/max_pests = 10
	var/max_weeds = 0
	var/max_toxins = 10

/datum/plant_growing_medium/proc/sanitize()
	water = clamp(water, 0, max_water)
	nutrients = clamp(nutrients, 0, max_nutrients)
	pests = clamp(pests, 0, max_pests)
	weeds = clamp(weeds, 0, max_weeds)
	toxins = clamp(toxins, 0, max_toxins)

/** Runtime state for one living plant. */
/datum/plant_instance
	var/datum/seed/line
	var/age = 0
	var/growth_progress = 0
	var/health = 0
	var/dead = FALSE
	var/harvest_ready = FALSE
	var/stunted = FALSE
	var/sampled = FALSE
	var/last_produce_age = 0
	var/yield_bonus = 0
	var/mutation_pressure = 0
	var/mutation_bonus = 0
	var/mutation_count = 0
	var/self_harvest_progress = 0
	var/wild_spread_progress = 0
	/// Fixed per planting. This is the only ordinary growth timing variance.
	var/growth_variance = 1

/datum/plant_instance/New(datum/seed/new_line, starting_age = 1, health_multiplier = 1)
	line = new_line
	age = starting_age
	growth_variance = rand(95, 105) / 100
	if(line)
		health = line.genome.endurance * health_multiplier

/datum/plant_instance/proc/set_line(datum/seed/new_line, reset_age = TRUE)
	line = new_line
	if(reset_age)
		age = 0
		growth_progress = 0
		last_produce_age = 0
	harvest_ready = FALSE
	stunted = FALSE
	dead = FALSE
	self_harvest_progress = 0
	wild_spread_progress = 0
	health = line ? line.genome.endurance : 0

/datum/plant_instance/proc/advance_growth(datum/plant_environment/environment, speed_multiplier = 1)
	var/datum/plant_tick_result/result = new
	if(!line || dead || !environment)
		return result
	if(!environment.atmosphere)
		result.blocked_by_environment = TRUE
		return result
	if(line.genome.is_outside_light_tolerance(environment.light) || line.genome.is_outside_heat_tolerance(environment.atmosphere))
		result.blocked_by_environment = TRUE
		return result
	var/growth_rate = line.genome.get_growth_rate(line.species, environment.atmosphere, environment.light)
	result.growth_added = (growth_rate / 100) * growth_variance * speed_multiplier
	growth_progress += result.growth_added
	if(growth_progress < 1)
		return result
	// Avoid losing a whole age step to floating-point drift at exact boundaries.
	var/whole_growth = FLOOR(growth_progress + 0.000001, 1)
	age += whole_growth
	growth_progress = max(0, growth_progress - whole_growth)
	result.age_advanced = whole_growth
	return result

/**
 * Advances the biological state of one plant by a complete cycle. Containers
 * provide conditions and resources; presentation and world effects remain the
 * caller's responsibility through the returned event record.
 */
/datum/plant_instance/proc/process_cycle(datum/plant_environment/environment, datum/plant_growing_medium/medium, speed_multiplier = 1)
	var/datum/plant_tick_result/result = new
	if(!line || dead || !environment?.atmosphere || !medium)
		return result

	var/datum/plant_genome/genome = line.genome
	var/starting_health = health
	medium.nutrients -= max(0, genome.nutrient_consumption * 0.25 * speed_multiplier)
	medium.water -= max(0, genome.water_consumption * 0.25 * speed_multiplier)

	var/maintenance_health = 0.7 * speed_multiplier
	if(genome.requires_nutrients)
		health += medium.nutrients < 2 ? -maintenance_health : maintenance_health
	if(genome.requires_water)
		health += medium.water < 10 ? -maintenance_health : maintenance_health

	health -= genome.apply_environment(environment, speed_multiplier)
	var/datum/plant_tick_result/growth_result = advance_growth(environment, speed_multiplier)
	result.growth_added = growth_result.growth_added
	result.age_advanced = growth_result.age_advanced
	result.blocked_by_environment = growth_result.blocked_by_environment
	qdel(growth_result)

	if(medium.toxins > 0)
		var/toxin_uptake = max(1, round(medium.toxins / 10))
		if(medium.toxins > genome.toxin_tolerance)
			health -= toxin_uptake
		medium.toxins -= toxin_uptake

	if(medium.pests > 0)
		if(genome.carnivorous)
			health += speed_multiplier
			medium.pests -= speed_multiplier
		else if(medium.pests >= genome.pest_tolerance)
			health -= speed_multiplier

	if(medium.weeds > 0)
		if(genome.parasitic)
			health += speed_multiplier
			medium.weeds -= speed_multiplier
		else if(medium.weeds >= genome.weed_tolerance)
			health -= speed_multiplier

	medium.sanitize()
	sanitize()
	result.health_delta = health - starting_health
	result.died = dead

	if(!dead && age > genome.maturation && age - last_produce_age > genome.production && !harvest_ready)
		stunted = !line.genome.is_within_light_preference(environment.light) || !line.genome.is_within_heat_preference(environment.atmosphere)
		harvest_ready = TRUE
		last_produce_age = age
		result.became_harvestable = TRUE

	return result

/datum/plant_instance/proc/sanitize()
	if(!line)
		health = 0
		dead = FALSE
		return
	health = clamp(health, 0, line.genome.endurance)
	mutation_pressure = max(0, mutation_pressure)
	if(health <= 0)
		dead = TRUE
		harvest_ready = FALSE
