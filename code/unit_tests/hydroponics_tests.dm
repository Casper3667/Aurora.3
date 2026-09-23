/*
For unit tests relating to hydroponics mechanics, with no direct relation to cooking.
*/

/**
Checks if the preference values of a seed are lesser than their tolerance values.
Preferences should always be within tolerances. We don't want any plant to be dying from intolerance
while simultaneously growing faster from being within its preferences.
*/
/datum/unit_test/seed_preferences_check
	name = "HYDROPONICS: Check preference and tolerance validity"
	groups = list("generic", "cooking")

/datum/unit_test/seed_preferences_check/start_test()
	for(var/seed_name in SSplants.cultivars)
		var/datum/seed/S = SSplants.get_cultivar(seed_name)

		if(GET_SEED_TRAIT(S, TRAIT_LIGHT_TOLERANCE) < GET_SEED_TRAIT(S, TRAIT_LIGHT_PREFERENCE))
			TEST_FAIL("Seed [S] has a light preference value set higher than its light tolerance.")

		if(GET_SEED_TRAIT(S, TRAIT_HEAT_TOLERANCE) < GET_SEED_TRAIT(S, TRAIT_HEAT_PREFERENCE))
			TEST_FAIL("Seed [S] has a heat preference value set higher than its heat tolerance.")

	if(!reported)
		TEST_PASS("All seeds have preference values that are lower than their tolerance values.")

	return 1

/** A cultivar clone must never retain mutable list references to its parent. */
/datum/unit_test/plant_genome_clone_isolation
	name = "HYDROPONICS: Cultivar genomes are deeply isolated"
	groups = list("generic", "cooking")

/datum/unit_test/plant_genome_clone_isolation/start_test()
	var/datum/seed/original = SSplants.get_cultivar("tomato")
	var/datum/seed/copy = original?.diverge(TRUE)
	if(!original || !copy)
		TEST_FAIL("Could not create a tomato cultivar clone.")
		return 1

	var/original_potency = GET_SEED_TRAIT(original, TRAIT_POTENCY)
	var/original_nutriment = original.chems[/singleton/reagent/nutriment][1]
	if(copy.species != original.species)
		TEST_FAIL("A cultivar clone duplicated immutable species metadata.")
	if(copy.genome == original.genome)
		TEST_FAIL("A cultivar clone retained its parent's mutable genome datum.")
	SET_SEED_TRAIT(copy, TRAIT_POTENCY, original_potency + 20)
	copy.chems[/singleton/reagent/nutriment][1] = original_nutriment + 20

	if(GET_SEED_TRAIT(original, TRAIT_POTENCY) != original_potency)
		TEST_FAIL("Changing a clone's scalar genome changed its parent.")
	if(original.chems[/singleton/reagent/nutriment][1] != original_nutriment)
		TEST_FAIL("Changing a clone's nested chemistry changed its parent.")
	if(!reported)
		TEST_PASS("Cultivar scalar and nested genome data are isolated.")
	qdel(copy)
	return 1

/** Growth accrues continuously and must not depend on a per-cycle probability roll. */
/datum/unit_test/plant_growth_is_deterministic
	name = "HYDROPONICS: Growth uses deterministic progress"
	groups = list("generic", "cooking")

/datum/unit_test/plant_growth_is_deterministic/start_test()
	var/datum/seed/line = SSplants.get_cultivar("tomato")
	if(!line)
		TEST_FAIL("Could not find the tomato seed definition.")
		return 1

	var/datum/plant_instance/plant = new(line, 0)
	plant.growth_variance = 1
	var/datum/gas_mixture/atmosphere = new(CELL_VOLUME, GET_SEED_TRAIT(line, TRAIT_IDEAL_HEAT))
	var/datum/plant_environment/environment = new(null, atmosphere, GET_SEED_TRAIT(line, TRAIT_IDEAL_LIGHT))
	var/expected_growth = FLOOR(((line.get_growth_rate(atmosphere, environment.light) / 100) * 20) + 0.000001, 1)
	for(var/i in 1 to 20)
		plant.advance_growth(environment)

	if(plant.age != expected_growth)
		TEST_FAIL("Expected [expected_growth] age after 20 ideal cycles, got [plant.age].")

	var/age_before_darkness = plant.age
	var/datum/plant_environment/dark_environment = new(null, atmosphere, 0)
	var/datum/plant_tick_result/dark_result = plant.advance_growth(dark_environment)
	if(!dark_result.blocked_by_environment || plant.age != age_before_darkness)
		TEST_FAIL("Zero supplied light did not block an intolerant plant's growth.")

	if(!reported)
		TEST_PASS("Growth accumulated deterministically across 20 cycles.")
	qdel(dark_result)
	qdel(dark_environment)
	qdel(environment)
	qdel(atmosphere)
	qdel(plant)
	return 1
