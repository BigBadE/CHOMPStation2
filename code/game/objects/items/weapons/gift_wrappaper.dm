/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"
	drop_sound = 'sound/items/drop/cardboardbox.ogg'
	pickup_sound = 'sound/items/pickup/cardboardbox.ogg'

/obj/item/a_gift/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	if(w_class > 0 && w_class < ITEMSIZE_LARGE)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"

/obj/item/gift/attack_self(mob/user as mob)
	user.drop_item()
	playsound(src, 'sound/items/package_unwrap.ogg', 50,1)
	if(src.gift)
		user.put_in_active_hand(gift)
		src.gift.add_fingerprint(user)
	else
		to_chat(user, span_warning("The gift was empty!"))
	qdel(src)
	return

/obj/item/a_gift/ex_act()
	qdel(src)
	return

/obj/effect/spresent/relaymove(mob/user as mob)
	if (user.stat)
		return
	to_chat(user, span_warning("You can't move."))

/obj/effect/spresent/attackby(obj/item/W as obj, mob/user as mob)
	..()

	if (!W.has_tool_quality(TOOL_WIRECUTTER))
		to_chat(user, span_warning("I need wirecutters for that."))
		return

	to_chat(user, span_notice("You cut open the present."))

	for(var/mob/M in src) //Should only be one but whatever.
		M.forceMove(src.loc)

	qdel(src)

/obj/item/a_gift/attack_self(mob/M as mob)
	var/gift_type = pick(
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/backpack/holding,
		/obj/item/storage/belt/champion,
		/obj/item/soap/deluxe,
		/obj/item/pickaxe/silver,
		/obj/item/pen/invisible,
		/obj/item/lipstick/random,
		/obj/item/grenade/smokebomb,
		/obj/item/corncob,
		/obj/item/poster/custom,
		/obj/item/book/manual/barman_recipes,
		/obj/item/book/manual/chef_recipes,
		/obj/item/bikehorn,
		/obj/item/beach_ball,
		/obj/item/beach_ball/holoball,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/gun/projectile/revolver/toy/crossbow,
		/obj/item/storage/box/capguntoy,
		/obj/item/toy/katana,
		/obj/item/toy/mecha/deathripley,
		/obj/item/toy/mecha/durand,
		/obj/item/toy/mecha/fireripley,
		/obj/item/toy/mecha/gygax,
		/obj/item/toy/mecha/honk,
		/obj/item/toy/mecha/marauder,
		/obj/item/toy/mecha/mauler,
		/obj/item/toy/mecha/odysseus,
		/obj/item/toy/mecha/phazon,
		/obj/item/toy/mecha/ripley,
		/obj/item/toy/mecha/seraph,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/paicard,
		/obj/item/instrument/violin,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/accessory/tie/horrible)

	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.remove_from_mob(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return

/*
 * Wrapping Paper
 */
/obj/item/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/items.dmi'
	icon_state = "wrap_paper"
	var/amount = 20.0
	drop_sound = 'sound/items/drop/wrapper.ogg'
	pickup_sound = 'sound/items/pickup/wrapper.ogg'

/obj/item/wrapping_paper/attackby(obj/item/W as obj, mob/living/user as mob)
	..()
	if (!( locate(/obj/structure/table, src.loc) ))
		to_chat(user, span_warning("You MUST put the paper on a table!"))
	if (W.w_class < ITEMSIZE_LARGE)
		var/obj/item/I = user.get_inactive_hand()
		if(I && I.has_tool_quality(TOOL_WIRECUTTER))
			var/a_used = 2 ** (src.w_class - 1)
			if (src.amount < a_used)
				to_chat(user, span_warning("You need more paper!"))
				return
			else
				if(istype(W, /obj/item/smallDelivery) || istype(W, /obj/item/gift)) //No gift wrapping gifts!
					to_chat(user, span_warning("You can't wrap something that's already wrapped!"))
					return

				src.amount -= a_used
				user.drop_item()
				var/obj/item/gift/G = new /obj/item/gift( src.loc )
				G.size = W.w_class
				G.w_class = G.size + 1
				G.icon_state = text("gift[]", G.size)
				G.gift = W
				W.loc = G
				G.add_fingerprint(user)
				W.add_fingerprint(user)
				src.add_fingerprint(user)
			if (src.amount <= 0)
				new /obj/item/c_tube( src.loc )
				qdel(src)
				return
		else
			to_chat(user, span_warning("You need scissors!"))
	else
		to_chat(user, span_warning("The object is FAR too large!"))
	return


/obj/item/wrapping_paper/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += "There is about [src.amount] square units of paper left!"

/obj/item/wrapping_paper/attack(mob/target as mob, mob/user as mob)
	if (!ishuman(target)) return
	var/mob/living/carbon/human/H = target

	if (istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket) || H.stat)
		if (src.amount > 2)
			var/obj/effect/spresent/present = new /obj/effect/spresent (H.loc)
			src.amount -= 2

			H.forceMove(present)

			add_attack_logs(user,H,"Wrapped with [src]")
		else
			to_chat(user, span_warning("You need more paper."))
	else
		to_chat(user, "They are moving around too much. A straightjacket would help.")
