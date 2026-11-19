/// Runtime inhand generation adapted from Azure Peak's on-mob generator.
/// Items opt in with runtime_inhand and may override get_runtime_onmob_properties().

#define RUNTIME_INHAND_ICON_SIZE 64
#define RUNTIME_INHAND_BEHIND_LAYER -100
#define RUNTIME_ONMOB_CACHE_LIMIT 512

/obj/item/proc/get_runtime_onmob_tag()
	// Aurora implements wielding on several unrelated item families. Using vars keeps this
	// opt-in without adding overrides to every family that happens to define "wielded".
	if(vars["wielded"] && length(get_runtime_onmob_properties("wielded")))
		return "wielded"
	return "gen"

/// Defers the refresh until the complete update_icon() override chain has set its state and attachments.
/obj/item/proc/queue_runtime_onmob_refresh()
	if(runtime_onmob_refresh_queued)
		return
	runtime_onmob_refresh_queued = TRUE
	addtimer(CALLBACK(src, PROC_REF(finish_runtime_onmob_refresh)), 0, TIMER_UNIQUE)

/obj/item/proc/finish_runtime_onmob_refresh()
	runtime_onmob_refresh_queued = FALSE
	if(QDELETED(src))
		return
	invalidate_runtime_onmob()

/// Invalidates generated appearances and immediately refreshes a slot containing this item.
/obj/item/proc/invalidate_runtime_onmob(update_holder = TRUE)
	runtime_onmob_dirty = TRUE
	if(!update_holder || !ishuman(loc))
		return

	var/mob/living/carbon/human/H = loc
	if(H.l_hand == src)
		H.update_inv_l_hand()
	else if(H.r_hand == src)
		H.update_inv_r_hand()
	else if(H.belt == src)
		H.update_inv_belt()
	else if(H.back == src)
		H.update_inv_back()

/// Compatibility wrapper for callers interested specifically in held appearances.
/obj/item/proc/invalidate_runtime_inhand(update_holder = TRUE)
	return invalidate_runtime_onmob(update_holder)

/obj/item/proc/get_runtime_onmob_properties(tag)
	var/list/custom_properties = runtime_onmob_properties?[tag]
	if(length(custom_properties))
		return custom_properties

	if(tag == "gen")
		return list(
			"shrink" = 0.4,
			"sx" = -7, "sy" = -4,
			"nx" = 7, "ny" = -4,
			"wx" = -4, "wy" = -4,
			"ex" = 2, "ey" = -4,
			"nturn" = 0, "sturn" = 0, "wturn" = 0, "eturn" = 0,
			"nflip" = 0, "sflip" = 0, "wflip" = 0, "eflip" = 0,
			"northabove" = 0, "southabove" = 1,
			"eastabove" = 1, "westabove" = 0
		)
	if(tag == "onbelt")
		return list(
			"shrink" = 0.3,
			"sx" = -2, "sy" = -5,
			"nx" = 4, "ny" = -5,
			"wx" = 0, "wy" = -5,
			"ex" = 2, "ey" = -5,
			"nturn" = 0, "sturn" = 0, "wturn" = 0, "eturn" = 0,
			"nflip" = 0, "sflip" = 0, "wflip" = 0, "eflip" = 0,
			"northabove" = 0, "southabove" = 1,
			"eastabove" = 1, "westabove" = 0
		)
	if(tag == "onback")
		return list(
			"shrink" = 0.5,
			"sx" = 1, "sy" = -1,
			"nx" = 1, "ny" = -1,
			"wx" = 4, "wy" = -1,
			"ex" = -1, "ey" = -1,
			"nturn" = 0, "sturn" = 0, "wturn" = 0, "eturn" = 0,
			"nflip" = WEST, "sflip" = 0, "wflip" = 0, "eflip" = 0,
			"northabove" = 1, "southabove" = 0,
			"eastabove" = 0, "westabove" = 0
		)

/obj/item/proc/get_runtime_inhand_appearances(mob/living/carbon/human/H, mirrored, slot)
	var/tag = get_runtime_onmob_tag()
	return get_runtime_onmob_appearances(H, tag, mirrored, slot)

/obj/item/proc/get_runtime_onmob_appearances(mob/living/carbon/human/H, tag, mirrored, slot)
	var/list/properties = get_runtime_onmob_properties(tag)
	if(!length(properties))
		return

	var/regenerate = runtime_onmob_dirty
	var/icon/front_icon = get_runtime_onmob_icon(tag, properties, FALSE, mirrored, regenerate)
	var/icon/behind_icon = get_runtime_onmob_icon(tag, properties, TRUE, mirrored, regenerate)
	runtime_onmob_dirty = FALSE
	if(!front_icon || !behind_icon)
		return

	front_icon = shift_runtime_onmob_icon(H, front_icon, slot)
	behind_icon = shift_runtime_onmob_icon(H, behind_icon, slot)

	var/image/front = overlay_image(front_icon, "blank", flags = RESET_COLOR|RESET_ALPHA)
	var/image/behind = overlay_image(behind_icon, "blank", flags = RESET_COLOR|RESET_ALPHA)
	behind.layer = RUNTIME_INHAND_BEHIND_LAYER
	center_image(front, RUNTIME_INHAND_ICON_SIZE, RUNTIME_INHAND_ICON_SIZE)
	center_image(behind, RUNTIME_INHAND_ICON_SIZE, RUNTIME_INHAND_ICON_SIZE)
	return list(behind, front)

/obj/item/proc/get_runtime_onmob_icon(tag, list/properties, behind, mirrored, regenerate = FALSE)
	var/static/list/generated_icons = list()
	var/cache_key = "[type]|[icon]|[icon_state]|[color]|[alpha]|[tag]|[behind]|[mirrored]|[runtime_onmob_property_signature(properties)]|[runtime_onmob_overlay_signature()]"
	var/icon/generated = generated_icons[cache_key]
	if(!generated || regenerate)
		if(!generated && length(generated_icons) >= RUNTIME_ONMOB_CACHE_LIMIT)
			generated_icons.Cut()
		generated = generate_runtime_onmob_icon(properties, behind, mirrored)
		if(generated)
			generated = fcopy_rsc(generated)
			generated_icons[cache_key] = generated
	return generated

/obj/item/proc/runtime_onmob_property_signature(list/properties)
	var/static/list/property_keys = list(
		"shrink",
		"sx", "sy", "nx", "ny", "wx", "wy", "ex", "ey",
		"nturn", "sturn", "wturn", "eturn",
		"nflip", "sflip", "wflip", "eflip",
		"northabove", "southabove", "eastabove", "westabove"
	)
	var/list/signature = list()
	for(var/key in property_keys)
		signature += "[key]=[properties[key]]"
	return signature.Join(";")

/obj/item/proc/runtime_onmob_appearance_signature(list/appearances)
	var/list/signature = list()
	for(var/image/appearance as anything in appearances)
		if(appearance.plane != FLOAT_PLANE && appearance.plane != plane)
			continue
		signature += "[appearance.icon]|[appearance.icon_state]|[appearance.dir]|[appearance.color]|[appearance.alpha]|[appearance.pixel_x]|[appearance.pixel_y]|[appearance.blend_mode]"
	return signature.Join(";")

/obj/item/proc/runtime_onmob_overlay_signature()
	return "u:[runtime_onmob_appearance_signature(underlays)]|o:[runtime_onmob_appearance_signature(overlays)]"

/obj/item/proc/runtime_onmob_direction_name(direction)
	switch(direction)
		if(NORTH)
			return "north"
		if(SOUTH)
			return "south"
		if(EAST)
			return "east"
		if(WEST)
			return "west"
	return "south"

/obj/item/proc/runtime_onmob_mirror_fix(shrink, large_source)
	if(!shrink)
		return 0
	switch(shrink)
		if(0.5)
			return 1
		if(0.6)
			return large_source ? 1 : 2
		if(0.7)
			return 1
	return 0

/obj/item/proc/get_runtime_onmob_source(behind)
	if(!icon)
		return

	var/static/list/icon_states_cache = list()
	var/icon_key = "[icon]"
	var/list/known_states = icon_states_cache[icon_key]
	if(!known_states)
		known_states = icon_states(icon)
		icon_states_cache[icon_key] = known_states

	var/source_state = icon_state
	if(behind && "[icon_state]_behind" in known_states)
		source_state = "[icon_state]_behind"

	var/icon/source = icon(icon, source_state)
	if(islist(color))
		source.MapColors(arglist(color))
	else if(color)
		source.Blend(color, ICON_MULTIPLY)
	if(alpha < 255)
		source.Blend(rgb(255, 255, 255, alpha), ICON_MULTIPLY)

	// A dedicated behind state is already a complete appearance.
	if(behind && source_state != icon_state)
		return source

	// Aurora uses underlays for gun attachments such as bayonets and suppressors.
	for(var/image/underlay as anything in underlays)
		if(underlay.plane != FLOAT_PLANE && underlay.plane != plane)
			continue
		var/icon/underlay_icon = icon(underlay.icon, underlay.icon_state)
		if(islist(underlay.color))
			underlay_icon.MapColors(arglist(underlay.color))
		else if(underlay.color)
			underlay_icon.Blend(underlay.color, ICON_MULTIPLY)
		if(underlay.alpha < 255)
			underlay_icon.Blend(rgb(255, 255, 255, underlay.alpha), ICON_MULTIPLY)
		source.Blend(underlay_icon, ICON_UNDERLAY, underlay.pixel_x + 1, underlay.pixel_y + 1)

	for(var/image/overlay as anything in overlays)
		if(overlay.plane != FLOAT_PLANE && overlay.plane != plane)
			continue
		var/icon/overlay_icon = icon(overlay.icon, overlay.icon_state)
		if(islist(overlay.color))
			overlay_icon.MapColors(arglist(overlay.color))
		else if(overlay.color)
			overlay_icon.Blend(overlay.color, ICON_MULTIPLY)
		if(overlay.alpha < 255)
			overlay_icon.Blend(rgb(255, 255, 255, overlay.alpha), ICON_MULTIPLY)
		source.Blend(overlay_icon, blendMode2iconMode(overlay.blend_mode), overlay.pixel_x + 1, overlay.pixel_y + 1)
	return source

/obj/item/proc/generate_runtime_onmob_icon(list/properties, behind, mirrored)
	var/icon/source = get_runtime_onmob_source(behind)
	if(!source)
		return

	var/source_width = source.Width()
	var/source_height = source.Height()
	// Azure Peak's masks cover 32px and 64px sources. Larger sprites retain Aurora's authored inhand fallback.
	if(source_width > 64 || source_height > 64)
		return
	var/large_source = source_width > 32 || source_height > 32
	var/mask_file = large_source ? 'icons/mob/items/runtime_inhand_64.dmi' : 'icons/mob/items/runtime_inhand.dmi'
	var/mask_size = large_source ? 64 : 32
	var/icon/result = icon(mask_file, "blank")

	for(var/direction in list(NORTH, SOUTH, EAST, WEST))
		var/direction_name = runtime_onmob_direction_name(direction)
		var/prefix = copytext(direction_name, 1, 2)
		var/above = !!properties["[direction_name]above"]
		if(above == behind)
			continue

		var/used_prefix = prefix
		if(mirrored && direction == EAST)
			used_prefix = "w"
		else if(mirrored && direction == WEST)
			used_prefix = "e"

		// Azure's inputs are normally exactly 32px or 64px. Aurora gun sheets can use
		// rectangular frames (the STS35 is 42x32), so center them before masking.
		var/source_x = round((mask_size - source_width) / 2) + 1
		var/source_y = round((mask_size - source_height) / 2) + 1
		var/icon/holder = icon(mask_file, "blank")
		holder.Blend(source, ICON_OVERLAY, source_x, source_y)
		var/icon/mask = icon(mask_file, direction_name)
		holder.Blend(mask, ICON_MULTIPLY)
		holder.Crop(source_x, source_y, source_x + source_width - 1, source_y + source_height - 1)

		var/flip = properties["[used_prefix]flip"]
		if(flip)
			holder.Flip(flip)
		var/rotation = properties["[used_prefix]turn"]
		if(rotation)
			holder.Turn(rotation)

		var/offset_x = properties["[used_prefix]x"] || 0
		var/offset_y = properties["[used_prefix]y"] || 0
		if(mirrored)
			offset_x *= -1
			if(direction == NORTH || direction == SOUTH)
				offset_x += runtime_onmob_mirror_fix(properties["shrink"], large_source)

		var/shrink = properties["shrink"]
		if(isnull(shrink))
			shrink = 1
		holder.Scale(max(1, round(source_width * shrink)), max(1, round(source_height * shrink)))
		offset_x += 32 - (holder.Width() / 2)
		offset_y += 32 - (holder.Height() / 2)

		if(mirrored)
			holder.Flip(direction == NORTH ? WEST : EAST)
		result.Blend(holder, ICON_OVERLAY, offset_x, offset_y)

	return result

/obj/item/proc/shift_runtime_onmob_icon(mob/living/carbon/human/H, icon/source, slot)
	if(!H?.species || !LAZYLEN(H.species.equip_adjust) || !length(H.species.equip_adjust[slot]))
		return source

	var/icon/shifted = icon('icons/mob/items/runtime_inhand_64.dmi', "blank")
	var/list/shifts = H.species.equip_adjust[slot]
	for(var/shift_facing in shifts)
		var/list/facing_shift = shifts[shift_facing]
		var/use_dir = text2num(shift_facing)
		var/icon/equip = icon(source, "blank", use_dir)
		var/icon/canvas = icon('icons/mob/items/runtime_inhand_64.dmi', "blank")
		canvas.Blend(equip, ICON_OVERLAY, facing_shift["x"] + 1, facing_shift["y"] + 1)
		shifted.Insert(canvas, dir = use_dir)
	return shifted

#undef RUNTIME_INHAND_ICON_SIZE
#undef RUNTIME_INHAND_BEHIND_LAYER
#undef RUNTIME_ONMOB_CACHE_LIMIT
