/*!
 * Base state and helpers for states. Just does some sanity checks,
 * implement a proper state for in-depth checks.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * public
 *
 * Checks the UI state for a mob.
 *
 * required user mob The mob who opened/is using the UI.
 * required state datum/ui_state The state to check.
 *
 * return UI_state The state of the UI.
 */
/datum/proc/tgui_status(mob/user, datum/tgui_state/state)
	var/src_object = tgui_host(user)
	. = STATUS_CLOSE
	if(!state)
		return

	if(isobserver(user))
		// Admins can always interact.
		if(check_rights_for(user.client, R_ADMIN|R_EVENT|R_DEBUG))
			. = max(., STATUS_INTERACTIVE)

		// Regular ghosts can always at least view if in range.
		if(user.client)
			var/clientviewlist = getviewsize(user.client.view)
			if(get_dist(src_object, user) < max(clientviewlist[1], clientviewlist[2]))
				. = max(., STATUS_UPDATE)

	// Check if the state allows interaction
	var/result = state.can_use_topic(src_object, user)
	. = max(., result)

/**
 * private
 *
 * Checks if a user can use src_object's UI, and returns the state.
 * Can call a mob proc, which allows overrides for each mob.
 *
 * required src_object datum The object/datum which owns the UI.
 * required user mob The mob who opened/is using the UI.
 *
 * return UI_state The state of the UI.
 */
/datum/tgui_state/proc/can_use_topic(src_object, mob/user)
	// Don't allow interaction by default.
	return STATUS_CLOSE

/**
 * public
 *
 * Standard interaction/sanity checks. Different mob types may have overrides.
 *
 * return UI_state The state of the UI.
 */
/mob/proc/shared_tgui_interaction(src_object)
	// Close UIs if mindless.
	if(!client)
		return STATUS_CLOSE
	// Disable UIs if unconcious.
	else if(stat)
		return STATUS_DISABLED
	// Update UIs if incapicitated but concious.
	else if(incapacitated())
		return STATUS_UPDATE
	return STATUS_INTERACTIVE

/mob/living/silicon/ai/shared_tgui_interaction(src_object)
	// Disable UIs if the AI is unpowered.
	if(lacks_power())
		return STATUS_DISABLED
	return ..()

/mob/living/silicon/robot/shared_tgui_interaction(src_object)
	// Disable UIs if the Borg is unpowered or locked.
	if(!cell || cell.charge <= 0 || lockcharge)
		return STATUS_DISABLED
	return ..()

/**
 * public
 *
 * Check the distance for a living mob.
 * Really only used for checks outside the context of a mob.
 * Otherwise, use shared_living_tgui_distance().
 *
 * required src_object The object which owns the UI.
 * required user mob The mob who opened/is using the UI.
 *
 * return UI_state The state of the UI.
 */
/atom/proc/contents_tgui_distance(src_object, mob/living/user)
	// Just call this mob's check.
	return user.shared_living_tgui_distance(src_object)

/**
 * public
 *
 * Distance versus interaction check.
 *
 * required src_object atom/movable The object which owns the UI.
 *
 * return UI_state The state of the UI.
 */
/mob/living/proc/shared_living_tgui_distance(atom/movable/src_object, viewcheck = TRUE)
	// If the object is obscured, close it.
	if(viewcheck && !(src_object in view(src)))
		return STATUS_CLOSE

	var/dist = get_dist(src_object, src)
	if(dist <= 1) // Open and interact if 1-0 tiles away.
		return STATUS_INTERACTIVE
	else if(dist <= 2) // View only if 2-3 tiles away.
		return STATUS_UPDATE
	else if(dist <= 5) // Disable if 5 tiles away.
		return STATUS_DISABLED
	return STATUS_CLOSE // Otherwise, we got nothing.

/**
 * public
 *
 * Distance versus interaction check, with max'd update range.
 *
 * required src_object atom/movable The object which owns the UI.
 *
 * return UI_state The state of the UI.
 */
/mob/living/proc/shared_living_tgui_distance_bigscreen(atom/movable/src_object, viewcheck = TRUE)
	// If the object is obscured, close it.
	if(viewcheck && !(src_object in view(src)))
		return STATUS_CLOSE

	var/dist = get_dist(src_object, src)
	if(dist <= 1) // Open and interact if 1-0 tiles away.
		return STATUS_INTERACTIVE
	else if(dist <= world.view)
		return STATUS_UPDATE
	return STATUS_CLOSE // Otherwise, we got nothing.

// Topic Extensions for old UIs
/datum/proc/CanUseTopic(var/mob/user, var/datum/tgui_state/state)
	return tgui_status(user, state)
