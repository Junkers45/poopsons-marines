
/mob/living/carbon/human/var/opened_gift = 0

/obj/item/m_gift //Marine Gift
	name = "Present"
	desc = "One, standard issue USCM Present"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"

/obj/item/m_gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	if(w_class > 0 && w_class < 4)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"
	return

/obj/item/m_gift/attack_self(mob/M as mob)
	var/mob/living/carbon/human/H = M
	if(istype(H))
		if(H.opened_gift == 1)
			to_chat(H, "<span class='notice'> This is not your gift, opening it feels wrong.</span>")
		if(H.opened_gift == 2)
			to_chat(H, "<span class='notice'> Santa knows of your treachery, yet you open another present.</span>")
		if(H.opened_gift == 3)
			to_chat(H, "<span class='notice'> Even the Grinch glares with disguist...</span>")
		if(H.opened_gift == 4)
			to_chat(H, "<span class='notice'> You're ruining the Christmas magic, I hope you're happy.</span>")
		if(H.opened_gift == 5)
			to_chat(H, "<span class='danger'>Ok, Congratulations, you've ruined Christmas for 5 marines now.</span>")
		if(H.opened_gift > 5)
			to_chat(H, "<span class='danger'>You've ruined Christmas for [H.opened_gift] marines now...</span>")
		
		H.opened_gift++
	var fancy = rand(1,100) //Check if it has the possibility of being a FANCY present
	var exFancy = rand(1,20) // Checks if it might be one of the ULTRA fancy presents.
	var gift_type = /obj/item/storage/fancy/crayons   //Default, just in case

	if(fancy > 90)
		if(exFancy == 1)
			to_chat(M, "<span class='notice'> Just what the fuck is it???</span>")
			gift_type = /obj/item/clothing/mask/facehugger/lamarr
			var/obj/item/I = new gift_type(M)
			M.temp_drop_inv_item(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			qdel(src)
			return
		if(exFancy > 15)
			to_chat(M, "<span class='notice'> Oh, just what I needed... Fucking HEFA's.</span>")
			gift_type = /obj/item/storage/box/nade_box/frag
			var/obj/item/I = new gift_type(M)
			M.temp_drop_inv_item(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			qdel(src)
			return
		else
			gift_type = pick(
			/obj/item/weapon/gun/revolver/mateba,
			/obj/item/weapon/gun/pistol/heavy,
			/obj/item/weapon/claymore,
			/obj/item/weapon/energy/sword/green,
			/obj/item/weapon/energy/sword/red,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/burstfire_assembly,
			)
			to_chat(M, "<span class='notice'> It's a REAL gift!!!</span>")
			var/obj/item/I = new gift_type(M)
			M.temp_drop_inv_item(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			qdel(src)
			return
	else if (fancy <=5)
		to_chat(M, "<span class='notice'> It's fucking EMPTY.  Man, Fuck CM.</span>")
		M.temp_drop_inv_item(src)
		qdel(src)
		return


	gift_type = pick(
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/belt/champion,
		/obj/item/tool/soap/deluxe,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/contraband/poster,
		/obj/item/toy/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/weapon/banhammer,
		/obj/item/toy/crossbow,
		/obj/item/toy/gun,
		/obj/item/toy/katana,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/toy/spinningtoy,
		/obj/item/clothing/tie/horrible,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/rifle,
		/obj/item/attachable/scope)

	if(!ispath(gift_type,/obj/item))	return
	to_chat(M, "<span class='notice'> At least it's something...</span>")
	var/obj/item/I = new gift_type(M)
	M.temp_drop_inv_item(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return