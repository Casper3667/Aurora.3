/mob/living/carbon/human/proc/get_covered_body_parts(var/thick)
	var/skipbody = 0
	for(var/obj/item/clothing/C in list(wear_suit, head, wear_mask, w_uniform, gloves, shoes))
		if(!thick || (C.item_flags & ITEM_FLAG_THICK_MATERIAL))
			skipbody |= C.body_parts_covered
	return skipbody

/mob/living/carbon/human/proc/get_covered_clothes()
	var/skipitems = 0
	for(var/obj/item/clothing/C in list(wear_suit, head, wear_mask, w_uniform, gloves, shoes))
		skipitems |= C.flags_inv
	return skipitems

/mob/living/carbon/human/proc/examine_pulse(mob/user)
	if(user.stat || user.incapacitated() || !ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	if(H.has_stethoscope_active())
		var/obj/item/organ/organ = src.get_organ(user.zone_sel.selecting)
		if(organ && do_mob(user, src, 1.5 SECONDS))
			user.visible_message("<b>[user]</b> checks [src] with a stethoscope.", "You check [src] with the stethoscope on your person.")
			to_chat(user, EXAMINE_BLOCK("You place the stethoscope against [src]'s [organ.name]. You hear <b>[english_list(organ.listen())]</b>."))
		else
			to_chat(user, SPAN_WARNING("[src] is missing that limb!"))

	else if(src.stat && !(src.species.flags & NO_BLOOD))
		user.visible_message("<b>[user]</b> checks [src]'s pulse.", "You check [src]'s pulse.")
		if(do_mob(user, src, 2 SECONDS))
			if(pulse() == PULSE_NONE || (status_flags & FAKEDEATH))
				to_chat(user, "<span class='deadsay'>[get_pronoun("He")] [get_pronoun("has")] no pulse.</span>")
			else
				to_chat(user, "<span class='deadsay'>[get_pronoun("He")] [get_pronoun("has")] a pulse!</span>")

/mob/living/carbon/human/proc/get_examine_equipment_line(mob/user, label, obj/item/item, extra_text)
	var/item_link
	if(item.blood_color)
		item_link = "[item.gender == PLURAL ? "some" : "a"] [fluid_color_type_map(item.blood_color)]-stained <a href='byond://?src=[REF(src)];lookitem_desc_only=[REF(item)]'>[item.name]</a>"
	else
		item_link = "<a href='byond://?src=[REF(src)];lookitem_desc_only=[REF(item)]'>\a [item]</a>"
	var/line = "<b>[label]:</b> [icon2html(item, user)] [item_link]"
	if(extra_text)
		line += " [extra_text]"
	line += item.blood_color ? "!" : "."
	return item.blood_color ? SPAN_WARNING(line) : line

/mob/living/carbon/human/proc/get_examine_attachment_lines(mob/user, obj/item/clothing/clothing)
	var/list/grouped_items = list()
	for(var/obj/item/clothing/accessory/accessory in clothing.accessories)
		var/group = accessory.get_examine_group()
		if(!grouped_items[group])
			grouped_items[group] = list()
		var/list/group_items = grouped_items[group]
		group_items += accessory

	if(clothing.attached_radio)
		grouped_items["Radios"] = list(clothing.attached_radio)

	var/list/lines = list()
	for(var/group in grouped_items)
		var/list/item_texts = list()
		for(var/obj/item/item as anything in grouped_items[group])
			item_texts += "[icon2html(item, user)] <a href='byond://?src=[REF(src)];lookitem_desc_only=[REF(item)]'>\a [item]</a>"
		lines += "&nbsp;&nbsp;- <b>[group]:</b> [english_list(item_texts)].\n"
	return lines

/mob/living/carbon/human/get_examine_text(mob/user, distance, is_adjacent, infix, suffix)
	SHOULD_CALL_PARENT(FALSE) //Special snowflake case

	. = list()
	var/skipbody = get_covered_body_parts()
	var/skipbody_thick = get_covered_body_parts(TRUE)
	var/skipitems = get_covered_clothes()

	//exosuits and helmets obscure our view and stuff.
	var/skipgloves = skipitems & HIDEGLOVES
	var/skipsuitstorage = skipitems & HIDESUITSTORAGE
	var/skipjumpsuit = skipitems & HIDEJUMPSUIT
	var/skipshoes = skipitems & HIDESHOES
	var/skipmask = skipitems & HIDEMASK
	var/skipeyes = skipitems & HIDEEYES
	var/skipears = skipitems & HIDEEARS
	var/skipwrists = skipitems & HIDEWRISTS
	var/skippants = skipitems & HIDEPANTS

	var/list/msg = list("<span class='info'>This is ")

	if(icon)
		msg += icon2html(icon, user)

	msg += "<EM>[src.name]</EM>"

	var/ipcmodel
	if(isipc(src))
		var/obj/item/organ/internal/machine/posibrain/ipcbrain = internal_organs_by_name[BP_BRAIN]
		var/modelmsg = ipcbrain.custom_model
		ipcmodel = "[modelmsg]"
	if(!species.hide_name || ipcmodel)
		msg += ", a <b><font color='[species.examine_color || species.flesh_color]'>[ipcmodel ? "[ipcmodel] ":""][species.name]</font></b>"
	msg += "!\n"

	var/list/equipment_msg = list()
	var/list/holding_msg = list()

	if(head)
		equipment_msg += "[get_examine_equipment_line(user, "Head", head, head.get_head_examine_text(src))]\n"

	if(wear_mask && !skipmask)
		equipment_msg += "[get_examine_equipment_line(user, "Mask", wear_mask, wear_mask.get_mask_examine_text(src))]\n"

	if(glasses && !skipeyes)
		equipment_msg += "[get_examine_equipment_line(user, "Eyes", glasses)]\n"

	if(l_ear && !skipears)
		equipment_msg += "[get_examine_equipment_line(user, "Left ear", l_ear, l_ear.get_ear_examine_text(src, "left"))]\n"

	if(r_ear && !skipears)
		equipment_msg += "[get_examine_equipment_line(user, "Right ear", r_ear, r_ear.get_ear_examine_text(src, "right"))]\n"

	if(wear_suit)
		var/obj/item/clothing/suit/examined_outerwear = wear_suit
		equipment_msg += "[get_examine_equipment_line(user, "Outerwear", wear_suit)]\n"
		equipment_msg += get_examine_attachment_lines(user, examined_outerwear)

		if(s_store && !skipsuitstorage)
			equipment_msg += "[get_examine_equipment_line(user, "Suit storage", s_store)]\n"
	else if(s_store && !skipsuitstorage)
		equipment_msg += "[get_examine_equipment_line(user, "Suit storage", s_store)]\n"

	if(w_uniform && !skipjumpsuit)
		var/obj/item/clothing/under/examined_uniform = w_uniform
		equipment_msg += "[get_examine_equipment_line(user, "Uniform", w_uniform)]\n"
		equipment_msg += get_examine_attachment_lines(user, examined_uniform)

	if(back)
		equipment_msg += "[get_examine_equipment_line(user, "Back", back)]\n"

	if(gloves && !skipgloves)
		equipment_msg += "[get_examine_equipment_line(user, "Hands", gloves)]\n"
	else if(blood_color)
		equipment_msg += SPAN_WARNING("<b>Hands:</b> [fluid_color_type_map(hand_blood_color)]-stained!\n")

	if(belt)
		equipment_msg += "[get_examine_equipment_line(user, "Belt", belt)]\n"

	if(pants && !skippants)
		equipment_msg += "[get_examine_equipment_line(user, "Pants", pants)]\n"

	if(shoes && !skipshoes)
		equipment_msg += "[get_examine_equipment_line(user, "Feet", shoes)]\n"
	else if(footprint_color)
		equipment_msg += SPAN_WARNING("<b>Feet:</b> [fluid_color_type_map(footprint_color)]-stained!\n")

	if(wear_id)
		equipment_msg += "[get_examine_equipment_line(user, "ID", wear_id)]\n"

	if(wrists && !skipwrists)
		equipment_msg += "[get_examine_equipment_line(user, "Wrists", wrists, wrists.get_wrist_examine_text(src))]\n"

	if(l_hand)
		holding_msg += "[get_examine_equipment_line(user, "Left hand", l_hand)]\n"
	if(r_hand)
		holding_msg += "[get_examine_equipment_line(user, "Right hand", r_hand)]\n"

	if(length(equipment_msg))
		msg += "<b>Visible equipment</b>\n"
		msg += equipment_msg
	if(length(holding_msg))
		msg += "<b>Holding</b>\n"
		msg += holding_msg

	//closed eyes
	if(!skipeyes && eyes_are_closed())
		msg += "[get_pronoun("His")] eyes are closed.\n"

	//Jitters
	if(is_jittery)
		if(jitteriness >= 300)
			msg += SPAN_WARNING("<B>[get_pronoun("He")] [get_pronoun("is")] convulsing violently!</B>\n")
		else if(jitteriness >= 200)
			msg += SPAN_WARNING("[get_pronoun("He")] [get_pronoun("is")] extremely jittery.\n")
		else if(jitteriness >= 100)
			msg += SPAN_WARNING("[get_pronoun("He")] [get_pronoun("is")] twitching ever so slightly.\n")

	//splints
	for(var/organ in list(BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND,BP_R_FOOT,BP_L_FOOT))
		var/obj/item/organ/external/o = get_organ(organ)
		if(o)
			if(o.status & ORGAN_SPLINTED)
				msg += SPAN_WARNING("[get_pronoun("He")] [get_pronoun("has")] a splint on [get_pronoun("his")] [o.name]!\n")
			if(o.applied_pressure == src)
				msg += SPAN_WARNING("[get_pronoun("He")] [get_pronoun("is")] applying pressure to [get_pronoun("his")] [o.name]!\n")

	if((mutations & mSmallsize))
		msg += "[get_pronoun("He")] [get_pronoun("is")] small halfling!\n"
	//height
	if(height)
		msg += "[SPAN_NOTICE("[assemble_height_string(user)]")]\n"

	//buckled_to
	if(buckled_to)
		msg += "[get_pronoun("He")] [get_pronoun("is")] buckled to [icon2html(buckled_to, user)] [buckled_to].\n"

	//handcuffed?
	if(handcuffed)
		msg += SPAN_WARNING("[get_pronoun("He")] [get_pronoun("has")] [icon2html(handcuffed, user)] cuffs around [get_pronoun("his")] wrists!\n")

	//handcuffed?
	if(legcuffed)
		msg += SPAN_WARNING("[get_pronoun("He")] [get_pronoun("has")] [icon2html(legcuffed, user)] cuffs around [get_pronoun("his")] ankles!\n")

	//Red Nightshade
	if(is_berserk())
		msg += SPAN_WARNING("<B>[get_pronoun("He")] [get_pronoun("has")] engorged veins, which appear a vibrant red!</B>\n")

	if((src.stat || (status_flags & FAKEDEATH)) && !(src.species.flags & NO_BLOOD))	// No point checking pulse of a species that doesn't have one.
		msg += SPAN_WARNING("[get_pronoun("He")] [get_pronoun("is")]n't responding to anything around [get_pronoun("him")] and seems to be unconscious.\n")
		if(distance <= 3 && ((stat == DEAD || is_asystole() || src.losebreath) || (status_flags & FAKEDEATH)))
			msg += SPAN_WARNING("[get_pronoun("He")] [get_pronoun("does")] not appear to be breathing.\n")

	else if (src.stat)
		msg += SPAN_WARNING("[get_pronoun("He")] [get_pronoun("is")] not responding to anything around [get_pronoun("him")].\n")

	if(fire_stacks)
		msg += "[get_pronoun("He")] [get_pronoun("is")] covered in some liquid.\n"

	if(on_fire)
		msg += SPAN_DANGER("[get_pronoun("He")] [get_pronoun("is")] on fire!\n")

	//when the player is winded by an admin
	if(paralysis > 6000)
		msg += "<span><font size='3'><font color='#002eb8'><b>OOC Information:</b></font> <font color='red'>This player has been winded by a member of staff! Please freeze all roleplay involving their character until the matter is resolved! Adminhelp if you have further questions.</font></font></span>\n"

	var/have_client = client
	var/inactivity = client ? client.inactivity : null

	if(bg)
		disconnect_time = bg.disconnect_time
		have_client = bg.client
		inactivity =  have_client ? bg.client.inactivity : null

	if(sleeping)
		msg += species.sleep_examine_msg(src)

	if(species.show_ssd && (!species.has_organ[BP_BRAIN] || has_brain()) && stat != DEAD && !(status_flags & FAKEDEATH))
		if(!vr_mob && !key)
			msg += "<span class='deadsay'>[get_pronoun("He")] [get_pronoun("is")] [species.show_ssd]. It doesn't look like [get_pronoun("he")] [get_pronoun("is")] waking up anytime soon.</span>\n"
		else if(!vr_mob && !client && !bg)
			msg += "<span class='deadsay'>[get_pronoun("He")] [get_pronoun("is")] [species.show_ssd].</span>\n"
		if(have_client && ((inactivity / 600) > 10)) // inactivity/10/60 > 10 MINUTES
			msg += "<span class='deadsay'>\[Inactive for [round(inactivity / 600)] minutes.\]\n</span>"
		else if(!have_client && (world.realtime - disconnect_time) >= 5 MINUTES)
			msg += "<span class='deadsay'>\[Disconnected/ghosted [(world.realtime - disconnect_time)/600] minutes ago.\]\n</span>"

	var/list/wound_flavor_text = list()
	var/list/is_bleeding = list()

	for(var/organ_tag in species.has_limbs)

		var/list/organ_data = species.has_limbs[organ_tag]
		var/organ_descriptor = organ_data["descriptor"]

		var/obj/item/organ/external/E = organs_by_name[organ_tag]
		if(!E)
			var/has_prosthetic_socket = FALSE
			for(var/obj/item/organ/external/possible_receiver in organs)
				if(organ_tag in possible_receiver.prosthetic_sockets)
					has_prosthetic_socket = TRUE
					break

			if(has_prosthetic_socket)
				wound_flavor_text["[organ_descriptor]"] = SPAN_WARNING("<b>[get_pronoun("He")] [get_pronoun("has")] an exposed prosthetic socket where [get_pronoun("his")] [organ_descriptor] should be.</b>\n")
			else
				wound_flavor_text["[organ_descriptor]"] = SPAN_WARNING("<b>[get_pronoun("He")] [get_pronoun("is")] missing [get_pronoun("his")] [organ_descriptor].</b>\n")
		else if(E.is_stump())
			wound_flavor_text["[organ_descriptor]"] = SPAN_WARNING("<b>[get_pronoun("He")] [get_pronoun("has")] a stump where [get_pronoun("his")] [organ_descriptor] should be.</b>\n")
		else
			continue

	for(var/obj/item/organ/external/temp in organs)
		if(temp)
			if(temp.CheckNeedsAmputation())
				var/damage_descriptor = "mangled"
				if(!(temp.burn_ratio < 100))
					damage_descriptor = "charred"
				wound_flavor_text["[temp.name]"] = SPAN_DANGER("<b>[get_pronoun("He")] [get_pronoun("has")] \a [temp.name] that is [damage_descriptor] beyond recognition.</b>\n")
				continue//If it's this bad, we don't care about the rest of the wounds. The limb is gone.
			var/body_part = temp.body_part
			if(temp.body_part & HEAD)
				body_part &= ~HEAD
				body_part |= (temp.body_part & FACE) ? HEAD : 0
			if(skipbody_thick & body_part)
				continue
			var/thin_covering = (skipbody & body_part) ? TRUE : FALSE
			if((temp.status & ORGAN_ASSISTED) && !thin_covering)
				if(!(LIMB_GET_BRUTE_DAMAGE(temp) + LIMB_GET_BURN_DAMAGE(temp)) && !(temp.open))
					continue
				else
					wound_flavor_text["[temp.name]"] = SPAN_WARNING("[get_pronoun("He")] [get_pronoun("has")] [temp.get_wounds_desc()] on [get_pronoun("his")] [temp.name].<br>")
			else if(length(temp.wounds) || temp.open)
				if(!thin_covering)
					if(temp.is_stump() && temp.parent_organ && organs_by_name[temp.parent_organ])
						var/obj/item/organ/external/parent = organs_by_name[temp.parent_organ]
						wound_flavor_text["[temp.name]"] = SPAN_WARNING("[get_pronoun("He")] [get_pronoun("has")] [temp.get_wounds_desc()] on [get_pronoun("his")] [parent.name].<br>")
					else
						wound_flavor_text["[temp.name]"] = SPAN_WARNING("[get_pronoun("He")] [get_pronoun("has")] [temp.get_wounds_desc()] on [get_pronoun("his")] [temp.name].<br>")
				if(temp.status & ORGAN_BLEEDING)
					is_bleeding["[temp.name]"] = SPAN_DANGER("[get_pronoun("His")] [temp.name] is bleeding")+ "<br>"
			else
				wound_flavor_text["[temp.name]"] = ""
			if(LIMB_GET_DISLOCATED(temp) == 2)
				wound_flavor_text["[temp.name]"] += SPAN_WARNING("[get_pronoun("His")] [temp.joint] is dislocated!<br>")
			if(((temp.status & ORGAN_BROKEN) && LIMB_GET_BRUTE_DAMAGE(temp) > temp.min_broken_damage) || (temp.status & ORGAN_MUTATED))
				wound_flavor_text["[temp.name]"] += SPAN_WARNING("[get_pronoun("His")] [temp.name] is dented and swollen!<br>")

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.

	for(var/limb in wound_flavor_text)
		if(wound_flavor_text[limb])
			msg += wound_flavor_text[limb]
			is_bleeding[limb] = null
	for(var/limb in is_bleeding)
		msg += is_bleeding[limb]
	for(var/obj/item/organ/external/organ in src.organs)
		for(var/obj/item/O in organ.implants)
			if(!istype(O,/obj/item/implant) && !istype(O,/obj/item/material/shard/shrapnel))
				msg += SPAN_DANGER("[src] [get_pronoun("has")] \a [O] sticking out of [get_pronoun("his")] [organ.name]!\n")
	if(digitalcamo)
		msg += "[get_pronoun("He")] [get_pronoun("is")] a little difficult to identify.\n"

	if(hasHUD(user,SEC_HUDTYPE))
		var/perpname = "wot"
		var/criminal = "None"

		if(wear_id)
			var/obj/item/card/id/I = wear_id.GetID()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
		else
			perpname = name

		if(perpname)
			var/datum/record/general/R = SSrecords.find_record("name", perpname)
			if(istype(R) && istype(R.security))
				criminal = R.security.criminal

			msg += "<span class = 'deptradio'>Criminal status:</span> <a href='byond://?src=[REF(src)];criminal=1'>\[[criminal]\]</a>\n"
			msg += "<span class = 'deptradio'>Security records:</span> <a href='byond://?src=[REF(src)];secrecord=`'>\[View\]</a>  <a href='byond://?src=[REF(src)];secrecordadd=`'>\[Add comment\]</a>\n"

	if(hasHUD(user,MED_HUDTYPE))
		var/perpname = "wot"
		var/medical = "None"
		var/bloodtype = "Unknown"

		var/obj/item/card/id/ID = GetIdCard()
		if(ID)
			perpname = ID.registered_name
		else
			perpname = src.name

		var/datum/record/general/R = SSrecords.find_record("name", perpname)
		if(istype(R))
			medical = R.physical_status
			bloodtype = R.medical.blood_type

		msg += "<span class = 'deptradio'>Physical Status:</span> <a href='byond://?src=[REF(src)];medical=1'>\[[medical]\]</a>\n"
		msg += "<span class = 'deptradio'>Medical Records:</span> <a href='byond://?src=[REF(src)];medrecord=`'>\[View\]</a> <a href='byond://?src=[REF(src)];medrecordadd=`'>\[Add Comment\]</a>\n"
		msg += "<span class = 'deptradio'>Triage Tag:</span> <a href='byond://?src=[REF(src)];triagetag=1'>\[[triage_tag]\]</a>\n"
		msg += "<span class = 'deptradio'>Blood type:</span> [bloodtype]\n"


	if(print_flavor_text()) msg += "[print_flavor_text()]\n"

	if(GLOB.config.allow_Metadata && client?.prefs.metadata)
		msg += "<span class='deadsay'>OOC Notes:</span> <a href='byond://?src=[REF(src)];metadata=1'>\[View\]</a>\n"

	msg += "</span>"

	if(src in GLOB.intent_listener)
		msg += SPAN_NOTICE("\n[get_pronoun("He")] looks like [get_pronoun("he")] [get_pronoun("is")] listening intently to [get_pronoun("his")] surroundings.")

	var/datum/vampire/V = get_antag_datum(MODE_VAMPIRE)
	if(V && (V.status & VAMP_DRAINING))
		var/obj/item/grab/G = get_active_hand()
		msg += SPAN_ALERT(FONT_LARGE("\n[get_pronoun("He")] is biting [G.affecting]'[G.affecting.get_pronoun("end")] neck!"))

	// recognition message for ghostroles, so they can recongize one another
	if(isliving(user) && user != src && mind?.recognition_group && mind.recognition_group == user.mind?.recognition_group && mind.recognition_message)
		msg += SPAN_GOOD("[mind.recognition_message]\n")

	if(pose)
		if(findtext(pose, ".", length(pose)) == 0 && findtext(pose, "!", length(pose)) == 0 && findtext(pose, "?", length(pose)) == 0)
			pose = addtext(pose, ".") // Makes sure all emotes end with punctuation.
		msg += "\n[get_pronoun("He")] [pose]"

	. += msg.Join()

	if(Adjacent(user))
		INVOKE_ASYNC(src, PROC_REF(examine_pulse), user)

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M, hudtype)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/clothing/glasses/G = H.glasses
		var/eye_hud = 0
		var/hud = 0
		// Checks for eye sensor HUD
		var/obj/item/organ/internal/augment/eye_sensors/E = locate() in H.internal_organs
		if(E)
			eye_hud = E.check_hud(hudtype)
		if(G)
			switch(hudtype)
				if(SEC_HUDTYPE)
					hud = G.is_sec_hud()
				if(MED_HUDTYPE)
					hud = G.is_med_hud()
		return hud || eye_hud
	else if(istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		switch(hudtype)
			if(SEC_HUDTYPE)
				return R.sensor_mode_sec()
			if(MED_HUDTYPE)
				return R.sensor_mode_med()
			else
				return 0
	else
		return 0

/proc/fluid_color_type_map(var/supplied_color)
	var/static/list/color_map = list(
					COLOR_HUMAN_BLOOD = "blood",
					COLOR_DIONA_BLOOD = "blood",
					COLOR_SKRELL_BLOOD = "blood",
					COLOR_VAURCA_BLOOD = "blood",
					COLOR_IPC_BLOOD = "oil",
					COLOR_OIL = "oil",
					COLOR_SNOW = "snow",
					COLOR_ASH = "ash",
						)

	var/output_text = color_map[supplied_color] || "fluid"
	return output_text

/mob/living/carbon/human/proc/assemble_height_string(mob/examiner)
	var/height_string = ""
	var/height_descriptor
	if(height == HEIGHT_NOT_USED)
		return height_string

	// Compare to Species Average
	if(species.species_height != HEIGHT_NOT_USED)
		switch(height - species.species_height)
			if(-999 to -100)
				height_descriptor = "miniscule"
			if(-99 to -50)
				height_descriptor = "tiny"
			if(-49 to -11)
				height_descriptor = "small"
			if(-10 to 10)
				height_descriptor = "about average height"
			if(11 to 50)
				height_descriptor = "tall"
			if(51 to 100)
				height_descriptor = "huge"
			else
				height_descriptor = "gargantuan"
		height_string += "[get_pronoun("He")] look[get_pronoun("end")] [height_descriptor]"
		if(!species.hide_name)
			height_string += " for a [species.name]"
		height_string += "." // Punctuation.

	if(examiner.height == HEIGHT_NOT_USED)
		return height_string

	switch(height - examiner.height)
		if(-999 to -51)
			height_descriptor = "absolutely tiny compared to"
		if(-50 to -31)
			height_descriptor = "much smaller than"
		if(-30 to -21)
			height_descriptor = "significantly shorter than"
		if(-20 to -11)
			height_descriptor = "shorter than"
		if(-10 to -6)
			height_descriptor = "slightly shorter than"
		if(-5 to 5)
			height_descriptor = "around the same height as"
		if(6 to 10)
			height_descriptor = "slightly taller than"
		if(11 to 20)
			height_descriptor = "taller than"
		if(21 to 30)
			height_descriptor = "significantly taller than"
		if(31 to 50)
			height_descriptor = "much larger than"
		else
			height_descriptor = "to tower over"
	if(height_string)
		return height_string += " [get_pronoun("He")] seem[get_pronoun("end")] [height_descriptor] you."
	return "[get_pronoun("He")] seem[get_pronoun("end")] [height_descriptor] you."
