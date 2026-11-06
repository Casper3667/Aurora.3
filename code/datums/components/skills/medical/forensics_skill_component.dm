GLOBAL_LIST_EMPTY(active_noir_forensics_components)

/proc/notify_noir_blood_changed(atom/changed_blood)
	for(var/datum/component/skill/forensics/forensics_component as anything in GLOB.active_noir_forensics_components)
		var/mob/investigator = forensics_component.parent
		if(investigator?.client && (changed_blood in view(investigator)))
			forensics_component.queue_noir_blood_refresh()

/datum/action/forensics_noir
	name = "Enable Noir Vision"
	button_icon = 'icons/hud/action_buttons/actions.dmi'
	button_icon_state = "genetic_view"
	var/datum/component/skill/forensics/forensics_component

/datum/action/forensics_noir/Trigger()
	if(!Checks())
		return

	if(active)
		Deactivate()
	else
		Activate()

/datum/action/forensics_noir/Checks()
	if(!..() || owner.stat)
		return FALSE
	return TRUE

/datum/action/forensics_noir/Activate()
	if(!owner)
		return

	owner.add_client_color(/datum/client_color/noir)
	active = TRUE
	forensics_component?.enable_noir_blood_color()
	name = "Disable Noir Vision"
	owner.update_action_buttons()

/datum/action/forensics_noir/Deactivate()
	if(!owner)
		return

	active = FALSE
	forensics_component?.disable_noir_blood_color()
	owner.remove_client_color(/datum/client_color/noir)
	name = "Enable Noir Vision"
	owner.update_action_buttons()

/datum/component/skill/forensics
	var/datum/action/forensics_noir/noir_action
	var/list/image/noir_blood_images = list()

/datum/component/skill/forensics/Initialize(level)
	. = ..()
	if(!parent || skill_level < SKILL_LEVEL_PROFESSIONAL)
		return

	noir_action = new()
	noir_action.forensics_component = src
	noir_action.SetTarget(noir_action)
	noir_action.Grant(parent)
	RegisterSignal(parent, COMSIG_MOB_AFTER_LOGIN, PROC_REF(setup_action_button), override = TRUE)

/datum/component/skill/forensics/Destroy(force)
	GLOB.active_noir_forensics_components -= src
	if(!parent)
		return ..()

	UnregisterSignal(parent, COMSIG_MOB_AFTER_LOGIN)
	if(noir_action?.active)
		noir_action.Deactivate()
	disable_noir_blood_color()
	noir_action?.Remove(parent)
	if(noir_action)
		noir_action.forensics_component = null
	QDEL_NULL(noir_action)
	return ..()

/datum/component/skill/forensics/proc/setup_action_button()
	astype(parent, /mob)?.update_action_buttons()
	if(noir_action?.active)
		refresh_noir_blood_images()

/datum/component/skill/forensics/proc/enable_noir_blood_color()
	GLOB.active_noir_forensics_components |= src
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_investigator_moved), override = TRUE)
	refresh_noir_blood_images()

/datum/component/skill/forensics/proc/disable_noir_blood_color()
	GLOB.active_noir_forensics_components -= src
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	var/mob/investigator = parent
	if(investigator?.client)
		investigator.client.images -= noir_blood_images
	noir_blood_images.Cut()
/datum/component/skill/forensics/proc/on_investigator_moved()
	SIGNAL_HANDLER
	queue_noir_blood_refresh()

/datum/component/skill/forensics/proc/queue_noir_blood_refresh()
	addtimer(CALLBACK(src, PROC_REF(refresh_noir_blood_images)), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/component/skill/forensics/proc/add_noir_blood_image(image/source, atom/movable/target)
	var/image/colored_blood = image(source, target)
	colored_blood.plane = ABOVE_GAME_PLANE
	if(colored_blood.layer == FLOAT_LAYER)
		colored_blood.layer = target.layer + 0.01
	colored_blood.appearance_flags |= NO_CLIENT_COLOR
	noir_blood_images += colored_blood

/datum/component/skill/forensics/proc/refresh_noir_blood_images()
	var/mob/investigator = parent
	if(!investigator?.client)
		return

	investigator.client.images -= noir_blood_images
	noir_blood_images.Cut()

	for(var/obj/effect/decal/cleanable/blood/blood_decal in view(investigator))
		var/image/colored_blood = image(blood_decal, blood_decal)
		colored_blood.plane = ABOVE_GAME_PLANE
		colored_blood.layer = blood_decal.layer + 0.01
		colored_blood.appearance_flags |= NO_CLIENT_COLOR
		noir_blood_images += colored_blood

	for(var/obj/item/item in view(investigator))
		if(item.blood_overlay && isturf(item.loc))
			add_noir_blood_image(item.blood_overlay, item)

	for(var/mob/living/simple_animal/animal in view(investigator))
		if(animal.blood_overlay)
			add_noir_blood_image(animal.blood_overlay, animal)

	for(var/mob/living/carbon/human/human in view(investigator))
		for(var/slot in human.noir_blood_overlays)
			var/list/slot_overlays = human.noir_blood_overlays[slot]
			for(var/image/blood_overlay in slot_overlays)
				add_noir_blood_image(blood_overlay, human)

	investigator.client.images += noir_blood_images
