/obj/item/forensics
	icon = 'icons/obj/forensics.dmi'
	w_class = WEIGHT_CLASS_TINY

/**
 * The maximum percentage of unknown points in a fingerprint string (represented as asterisks)
 * before the fingerprint is considered incomplete enough (and thus not recognisable)
 *
 * A fingerprint is 32 characters long and every unknown point of it is "*"
 */
#define MAX_UNKNOWN_POINTS_FOR_KNOWN_FINGERPRINT_PERCENTAGE 98

/**
 * Returns `TRUE` if the fingerprint is complete (above `FINGERPRINT_COMPLETE`), `FALSE` otherwise
 *
 * * print - The fingerprint (a string)
 */
/proc/is_complete_print(var/print)
	var/unknown_points_percentage = stringpercent(print)
	if(unknown_points_percentage <= MAX_UNKNOWN_POINTS_FOR_KNOWN_FINGERPRINT_PERCENTAGE)
		return TRUE
	else
		return FALSE

#undef MAX_UNKNOWN_POINTS_FOR_KNOWN_FINGERPRINT_PERCENTAGE

/atom/var/list/suit_fibers

/**
 * Shared trace profiles deliberately describe a material rather than identifying a garment.
 * Keep these color-free and give several compatible sources, including sources outside the
 * wearer's outfit. Garments can override forensic_fiber or set it to null to shed no trace.
 */
/singleton/forensic_fiber
	var/description = "Flattened staple fibers interspersed with smooth synthetic filaments, consistent with a woven textile blend."
	var/list/possible_matches = list("uniforms", "trousers", "cloth coats", "caps", "cloth gloves")

/singleton/forensic_fiber/proc/get_report()
	return "[description]<br><b>Possible clothing matches:</b> [english_list(possible_matches)]."

/singleton/forensic_fiber/knit
	description = "Soft, crimped staple fibers with remnants of looped yarn, consistent with a knitted textile."
	possible_matches = list("knitted caps", "cardigans", "sweaters", "knitted gloves")

/singleton/forensic_fiber/wool
	description = "Crimped animal-like fibers with overlapping surface scales, consistent with wool or a wool-like textile."
	possible_matches = list("felt berets", "winter hats", "wool coats", "woolen trousers")

/singleton/forensic_fiber/denim
	description = "Coarse, twisted plant-like staple fibers with fragments of a dense twill weave, consistent with denim."
	possible_matches = list("jeans", "denim shorts", "denim jackets", "heavy twill workwear")

/singleton/forensic_fiber/leather
	description = "Irregular bundles of fine, interlocking fibers with fragments of a treated surface, consistent with leather or imitation leather."
	possible_matches = list("leather jackets", "leather vests", "boots", "leather shoes", "leather gloves")

/singleton/forensic_fiber/polymer
	description = "Flexible polymer fragments with a smooth, non-woven surface, consistent with rubber or a similar synthetic coating."
	possible_matches = list("protective gloves", "insulated gloves", "respirator masks", "rubberized footwear", "waterproof clothing")

/singleton/forensic_fiber/nonwoven
	description = "Fine synthetic filaments bonded into a porous web, consistent with a non-woven filter textile."
	possible_matches = list("surgical masks", "disposable medical clothing", "filter-lined protective clothing")

/singleton/forensic_fiber/reinforced
	description = "Tough, smooth synthetic filaments in tightly packed bundles, consistent with a reinforced protective textile."
	possible_matches = list("body armor", "protective helmets", "spacesuit fabric", "reinforced work gloves", "protective workwear")

/obj/item/clothing
	/// Shared material profile for forensic traces. Never use the item's name or color here.
	var/forensic_fiber = /singleton/forensic_fiber

/obj/item/clothing/head/beanie
	forensic_fiber = /singleton/forensic_fiber/knit

/obj/item/clothing/head/beret
	forensic_fiber = /singleton/forensic_fiber/wool

/obj/item/clothing/head/ushanka
	forensic_fiber = /singleton/forensic_fiber/wool

/obj/item/clothing/head/helmet
	forensic_fiber = /singleton/forensic_fiber/reinforced

/obj/item/clothing/suit/armor
	forensic_fiber = /singleton/forensic_fiber/reinforced

/obj/item/clothing/suit/space
	forensic_fiber = /singleton/forensic_fiber/reinforced

/obj/item/clothing/suit/storage/toggle/cardigan
	forensic_fiber = /singleton/forensic_fiber/knit

/obj/item/clothing/suit/storage/leathercoat
	forensic_fiber = /singleton/forensic_fiber/leather

/obj/item/clothing/suit/storage/toggle/leather_jacket
	forensic_fiber = /singleton/forensic_fiber/leather

/obj/item/clothing/suit/storage/toggle/leather_vest
	forensic_fiber = /singleton/forensic_fiber/leather

/obj/item/clothing/pants/jeans
	forensic_fiber = /singleton/forensic_fiber/denim

/obj/item/clothing/pants/classic
	forensic_fiber = /singleton/forensic_fiber/denim

/obj/item/clothing/pants/mustang
	forensic_fiber = /singleton/forensic_fiber/denim

/obj/item/clothing/pants/jeansblack
	forensic_fiber = /singleton/forensic_fiber/denim

/obj/item/clothing/pants/designer
	forensic_fiber = /singleton/forensic_fiber/denim

/obj/item/clothing/pants/tailoredjeans
	forensic_fiber = /singleton/forensic_fiber/denim

/obj/item/clothing/pants/ripped
	forensic_fiber = /singleton/forensic_fiber/denim

/obj/item/clothing/pants/blackripped
	forensic_fiber = /singleton/forensic_fiber/denim

/obj/item/clothing/pants/shorts/jeans
	forensic_fiber = /singleton/forensic_fiber/denim

/obj/item/clothing/gloves/latex
	forensic_fiber = /singleton/forensic_fiber/polymer

/obj/item/clothing/gloves/yellow
	forensic_fiber = /singleton/forensic_fiber/polymer

/obj/item/clothing/gloves/black
	forensic_fiber = /singleton/forensic_fiber/reinforced

/obj/item/clothing/gloves/swat
	forensic_fiber = /singleton/forensic_fiber/reinforced

/obj/item/clothing/gloves/swat/tactical
	forensic_fiber = /singleton/forensic_fiber/leather

/obj/item/clothing/gloves/combat
	forensic_fiber = /singleton/forensic_fiber/reinforced

/obj/item/clothing/mask/gas
	forensic_fiber = /singleton/forensic_fiber/polymer

/obj/item/clothing/mask/breath
	forensic_fiber = /singleton/forensic_fiber/polymer

/obj/item/clothing/mask/surgical
	forensic_fiber = /singleton/forensic_fiber/nonwoven

/obj/item/clothing/shoes
	forensic_fiber = /singleton/forensic_fiber/leather

/obj/item/clothing/shoes/sneakers
	forensic_fiber = /singleton/forensic_fiber

/obj/item/clothing/shoes/footwraps
	forensic_fiber = /singleton/forensic_fiber

/obj/item/clothing/shoes/galoshes
	forensic_fiber = /singleton/forensic_fiber/polymer

/obj/item/clothing/shoes/swimmingfins
	forensic_fiber = /singleton/forensic_fiber/polymer

/** Returns exposed garments and their base trace-transfer chances, from outside to inside. */
/mob/living/carbon/human/proc/get_forensic_clothing()
	var/list/layers = list()
	var/obj/item/clothing/pants/P = pants
	if(istype(P) && P.mob_wear_layer == ABOVE_SUIT_LAYER_PA)
		layers[P] = 15
	if(wear_suit)
		layers[wear_suit] = 10
	if(istype(P) && P.mob_wear_layer == ABOVE_UNIFORM_LAYER_PA)
		layers[P] = 15
	if(w_uniform)
		layers[w_uniform] = 15
	if(istype(P) && P.mob_wear_layer == UNDER_UNIFORM_LAYER_PA)
		layers[P] = 15
	if(head)
		layers[head] = 10
	if(wear_mask)
		layers[wear_mask] = 10
	if(gloves)
		layers[gloves] = 20
	if(shoes)
		layers[shoes] = 10

	var/list/exposed = list()
	var/covered = 0
	var/hidden_slots = 0
	for(var/obj/item/clothing/C in layers)
		var/hidden = FALSE
		if(C == w_uniform && (hidden_slots & HIDEJUMPSUIT))
			hidden = TRUE
		else if(C == gloves && (hidden_slots & HIDEGLOVES))
			hidden = TRUE
		else if(C == shoes && (hidden_slots & HIDESHOES))
			hidden = TRUE
		else if(C == wear_mask && (hidden_slots & HIDEMASK))
			hidden = TRUE
		else if(C == pants && (C.flags_inv & HIDEPANTS))
			hidden = TRUE
		if(!hidden && (C.body_parts_covered & ~covered))
			exposed[C] = layers[C]
			covered |= C.body_parts_covered
			if(C == wear_suit || C == head)
				hidden_slots |= C.flags_inv
	return exposed

/atom/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.transfer_blood && G.bloody_hands_mob?.resolve()) //bloodied gloves transfer blood to touched objects
			if(add_blood(G.bloody_hands_mob.resolve())) //only reduces the bloodiness of our gloves if the item wasn't already bloody
				G.transfer_blood--
	else if(M.bloody_hands && M.bloody_hands_mob?.resolve())
		if(add_blood(M.bloody_hands_mob.resolve()))
			M.bloody_hands--

	var/item_multiplier = istype(src,/obj/item)?1.2:1
	var/list/exposed = M.get_forensic_clothing()
	for(var/obj/item/clothing/C in exposed)
		if(!C.forensic_fiber || !prob(exposed[C] * item_multiplier))
			continue
		var/singleton/forensic_fiber/profile = GET_SINGLETON(C.forensic_fiber)
		LAZYDISTINCTADD(suit_fibers, profile.get_report())
