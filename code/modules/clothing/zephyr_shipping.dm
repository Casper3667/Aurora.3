#define ZEPHYR_CHARCOAL "#414446"
#define ZEPHYR_BROWN "#7a6347"
#define ZEPHYR_SILVER "#c3c49e"
#define ZEPHYR_SEA_GREEN "#2f7775"
#define ZEPHYR_SAND "#bda77c"

/*
 * Zephyr Shipping Company
 *
 * These uniforms use existing colorable clothing sprites so the different
 * silhouettes and palettes can be tested before any bespoke sprites are made.
 */

// Commercial deckhand variant
/obj/item/clothing/under/color/colorable/zephyr/deckhand
	name = "Zephyr Shipping deckhand jumpsuit"
	desc = "A charcoal work jumpsuit issued to deckhands employed by the Zephyr Shipping Company."
	color = ZEPHYR_CHARCOAL

/obj/item/clothing/suit/storage/toggle/highvis/colorable/zephyr/deckhand
	name = "Zephyr Shipping deck jacket"
	desc = "A brown work jacket with sea-green reflective trim, issued to Zephyr Shipping Company deckhands."
	color = ZEPHYR_BROWN
	accent_color = ZEPHYR_SEA_GREEN

/obj/item/clothing/head/softcap/colorable/accent/zephyr/deckhand
	name = "Zephyr Shipping deck cap"
	desc = "A charcoal work cap with a sea-green band, issued to Zephyr Shipping Company deckhands."
	color = ZEPHYR_CHARCOAL
	accent_color = ZEPHYR_SEA_GREEN

// Shipboard variant
/obj/item/clothing/under/color/colorable/zephyr/shipboard
	name = "Zephyr Shipping shipboard jumpsuit"
	desc = "A charcoal work jumpsuit intended for the shipboard employees of the Zephyr Shipping Company."
	color = ZEPHYR_CHARCOAL

/obj/item/clothing/suit/storage/toggle/highvis/colorable/zephyr/shipboard
	name = "Zephyr Shipping shipboard jacket"
	desc = "A brown shipboard jacket with silver reflective trim, issued by the Zephyr Shipping Company."
	color = ZEPHYR_BROWN
	accent_color = ZEPHYR_SILVER

/obj/item/clothing/head/beanie/submariner/zephyr/shipboard
	name = "Zephyr Shipping submariner's beanie"
	desc = "A close-fitting sea-green beanie favored by Zephyr Shipping Company crews."
	color = ZEPHYR_SEA_GREEN

// Sparring Sea courier variant
/obj/item/clothing/under/color/colorable/zephyr/courier
	name = "Zephyr Shipping courier jumpsuit"
	desc = "A sand-colored work jumpsuit issued to Zephyr Shipping Company couriers operating throughout the Sparring Sea."
	color = ZEPHYR_SAND

/obj/item/clothing/suit/storage/toggle/highvis/colorable/zephyr/courier
	name = "Zephyr Shipping courier jacket"
	desc = "A sea-green courier jacket with silver reflective trim, made for employees constantly on the move."
	color = ZEPHYR_SEA_GREEN
	accent_color = ZEPHYR_SILVER

/obj/item/clothing/head/softcap/colorable/accent/zephyr/courier
	name = "Zephyr Shipping courier cap"
	desc = "A sea-green work cap with a silver band, issued to Zephyr Shipping Company couriers."
	color = ZEPHYR_SEA_GREEN
	accent_color = ZEPHYR_SILVER

// Travelling factor variant
/obj/item/clothing/under/color/colorable/zephyr/factor
	name = "Zephyr Shipping factor uniform"
	desc = "A charcoal uniform issued to the travelling commercial agents of the Zephyr Shipping Company."
	color = ZEPHYR_CHARCOAL

/obj/item/clothing/suit/storage/toggle/suitjacket/blazer/long/zephyr/factor
	name = "Zephyr Shipping factor's blazer"
	desc = "A long brown blazer with sea-green accents, worn by Zephyr Shipping Company factors meeting clients abroad."
	color = ZEPHYR_BROWN
	accent_color = ZEPHYR_SEA_GREEN

/obj/item/clothing/head/flatcap/colourable/zephyr/factor
	name = "Zephyr Shipping factor's cap"
	desc = "A brown flat cap commonly worn by travelling factors of the Zephyr Shipping Company."
	color = ZEPHYR_BROWN

// Cold-weather mariner variant
/obj/item/clothing/under/color/colorable/zephyr/cold_weather
	name = "Zephyr Shipping cold-weather jumpsuit"
	desc = "A charcoal work jumpsuit issued to Zephyr Shipping Company employees on colder routes."
	color = ZEPHYR_CHARCOAL

/obj/item/clothing/suit/storage/toggle/peacoat/zephyr/cold_weather
	name = "Zephyr Shipping mariner's peacoat"
	desc = "A sturdy brown peacoat issued to Zephyr Shipping Company mariners working cold routes."
	color = ZEPHYR_BROWN

/obj/item/clothing/head/beanie/submariner/zephyr/cold_weather
	name = "Zephyr Shipping mariner's beanie"
	desc = "A warm sea-green beanie issued to Zephyr Shipping Company mariners."
	color = ZEPHYR_SEA_GREEN

// Long-coat factor variant
/obj/item/clothing/under/color/colorable/zephyr/longcoat_factor
	name = "Zephyr Shipping senior factor uniform"
	desc = "A charcoal uniform issued to senior commercial agents of the Zephyr Shipping Company."
	color = ZEPHYR_CHARCOAL

/obj/item/clothing/suit/storage/toggle/trench/colorable/alt/zephyr/longcoat_factor
	name = "Zephyr Shipping factor's long coat"
	desc = "A long brown canvas coat with sea-green accents, intended for Zephyr Shipping Company factors travelling between ports."
	color = ZEPHYR_BROWN
	accent_color = ZEPHYR_SEA_GREEN

/obj/item/clothing/head/flatcap/colourable/zephyr/longcoat_factor
	name = "Zephyr Shipping senior factor's cap"
	desc = "A sea-green flat cap worn by senior factors of the Zephyr Shipping Company."
	color = ZEPHYR_SEA_GREEN

// Shared accessories
/obj/item/clothing/accessory/sleevepatch/zephyr
	name = "Zephyr Shipping sleeve patch"
	desc = "A sea-green embroidered patch identifying the wearer as an employee of the Zephyr Shipping Company."
	color = ZEPHYR_SEA_GREEN

/obj/item/clothing/gloves/fingerless/colour/zephyr
	name = "Zephyr Shipping work gloves"
	desc = "A pair of charcoal fingerless gloves issued to Zephyr Shipping Company cargo handlers and couriers."
	color = ZEPHYR_CHARCOAL

/obj/item/clothing/shoes/workboots/color/zephyr
	name = "Zephyr Shipping workboots"
	desc = "A pair of brown steel-toed workboots issued to Zephyr Shipping Company employees."
	color = ZEPHYR_BROWN

// Loadout entries
/datum/gear/faction/zephyr_uniforms
	display_name = "zephyr shipping uniform selection"
	description = "A selection of experimental Zephyr Shipping Company uniforms."
	path = /obj/item/clothing/under/color/colorable/zephyr/deckhand
	slot = slot_w_uniform
	faction = "Orion Express"

/datum/gear/faction/zephyr_uniforms/New()
	..()
	var/list/zephyr_uniforms = list()
	zephyr_uniforms["commercial deckhand - jumpsuit"] = /obj/item/clothing/under/color/colorable/zephyr/deckhand
	zephyr_uniforms["shipboard - jumpsuit"] = /obj/item/clothing/under/color/colorable/zephyr/shipboard
	zephyr_uniforms["Sparring Sea courier - jumpsuit"] = /obj/item/clothing/under/color/colorable/zephyr/courier
	zephyr_uniforms["travelling factor - uniform"] = /obj/item/clothing/under/color/colorable/zephyr/factor
	zephyr_uniforms["cold-weather mariner - jumpsuit"] = /obj/item/clothing/under/color/colorable/zephyr/cold_weather
	zephyr_uniforms["long-coat factor - uniform"] = /obj/item/clothing/under/color/colorable/zephyr/longcoat_factor
	gear_tweaks += new /datum/gear_tweak/path(zephyr_uniforms)

/datum/gear/faction/zephyr_outerwear
	display_name = "zephyr shipping outerwear selection"
	description = "A selection of experimental Zephyr Shipping Company jackets and coats."
	path = /obj/item/clothing/suit/storage/toggle/highvis/colorable/zephyr/deckhand
	slot = slot_wear_suit
	faction = "Orion Express"

/datum/gear/faction/zephyr_outerwear/New()
	..()
	var/list/zephyr_outerwear = list()
	zephyr_outerwear["commercial deckhand - deck jacket"] = /obj/item/clothing/suit/storage/toggle/highvis/colorable/zephyr/deckhand
	zephyr_outerwear["shipboard - reflective jacket"] = /obj/item/clothing/suit/storage/toggle/highvis/colorable/zephyr/shipboard
	zephyr_outerwear["Sparring Sea courier - courier jacket"] = /obj/item/clothing/suit/storage/toggle/highvis/colorable/zephyr/courier
	zephyr_outerwear["travelling factor - long blazer"] = /obj/item/clothing/suit/storage/toggle/suitjacket/blazer/long/zephyr/factor
	zephyr_outerwear["cold-weather mariner - peacoat"] = /obj/item/clothing/suit/storage/toggle/peacoat/zephyr/cold_weather
	zephyr_outerwear["long-coat factor - trenchcoat"] = /obj/item/clothing/suit/storage/toggle/trench/colorable/alt/zephyr/longcoat_factor
	gear_tweaks += new /datum/gear_tweak/path(zephyr_outerwear)

/datum/gear/faction/zephyr_headwear
	display_name = "zephyr shipping headwear selection"
	description = "A selection of experimental Zephyr Shipping Company headwear."
	path = /obj/item/clothing/head/softcap/colorable/accent/zephyr/deckhand
	slot = slot_head
	faction = "Orion Express"

/datum/gear/faction/zephyr_headwear/New()
	..()
	var/list/zephyr_headwear = list()
	zephyr_headwear["commercial deckhand - deck cap"] = /obj/item/clothing/head/softcap/colorable/accent/zephyr/deckhand
	zephyr_headwear["shipboard - submariner's beanie"] = /obj/item/clothing/head/beanie/submariner/zephyr/shipboard
	zephyr_headwear["Sparring Sea courier - courier cap"] = /obj/item/clothing/head/softcap/colorable/accent/zephyr/courier
	zephyr_headwear["travelling factor - flat cap"] = /obj/item/clothing/head/flatcap/colourable/zephyr/factor
	zephyr_headwear["cold-weather mariner - submariner's beanie"] = /obj/item/clothing/head/beanie/submariner/zephyr/cold_weather
	zephyr_headwear["long-coat factor - flat cap"] = /obj/item/clothing/head/flatcap/colourable/zephyr/longcoat_factor
	gear_tweaks += new /datum/gear_tweak/path(zephyr_headwear)

/datum/gear/faction/zephyr_patch
	display_name = "zephyr shipping sleeve patch"
	description = "A Zephyr Shipping Company employee patch."
	path = /obj/item/clothing/accessory/sleevepatch/zephyr
	slot = slot_tie
	faction = "Orion Express"

/datum/gear/faction/zephyr_gloves
	display_name = "zephyr shipping work gloves"
	path = /obj/item/clothing/gloves/fingerless/colour/zephyr
	slot = slot_gloves
	faction = "Orion Express"

/datum/gear/faction/zephyr_workboots
	display_name = "zephyr shipping workboots"
	path = /obj/item/clothing/shoes/workboots/color/zephyr
	slot = slot_shoes
	faction = "Orion Express"

#undef ZEPHYR_CHARCOAL
#undef ZEPHYR_BROWN
#undef ZEPHYR_SILVER
#undef ZEPHYR_SEA_GREEN
#undef ZEPHYR_SAND
