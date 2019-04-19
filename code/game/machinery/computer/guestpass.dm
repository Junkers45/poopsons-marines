/////////////////////////////////////////////
//Guest pass ////////////////////////////////
/////////////////////////////////////////////
/obj/item/card/id/guest
	name = "guest pass"
	desc = "Allows temporary access to station areas."
	icon_state = "guest"

	var/temp_access = list() //to prevent agent cards stealing access as permanent
	var/expiration_time = 0
	var/reason = "NOT SPECIFIED"

/obj/item/card/id/guest/GetAccess()
	if (world.time > expiration_time)
		return access
	else
		return temp_access

/obj/item/card/id/guest/examine(mob/user)
	..()
	if (world.time < expiration_time)
		to_chat(user, "<span class='notice'>This pass expires at [worldtime2text(expiration_time)].</span>")
	else
		to_chat(user, "<span class='warning'>It expired at [worldtime2text(expiration_time)].</span>")

/obj/item/card/id/guest/read()
	if (world.time > expiration_time)
		to_chat(usr, "<span class='notice'>This pass expired at [worldtime2text(expiration_time)].</span>")
	else
		to_chat(usr, "<span class='notice'>This pass expires at [worldtime2text(expiration_time)].</span>")

	to_chat(usr, "<span class='notice'>It grants access to following areas:</span>")
	for (var/A in temp_access)
		to_chat(usr, "<span class='notice'>[get_access_desc(A)].</span>")
	to_chat(usr, "<span class='notice'>Issuing reason: [reason].</span>")
	return

/////////////////////////////////////////////
//Guest pass terminal////////////////////////
/////////////////////////////////////////////

/obj/machinery/computer/guestpass
	name = "guest pass terminal"
	icon_state = "guest"
	density = 0


	var/obj/item/card/id/giver
	var/list/accesses = list()
	var/giv_name = "NOT SPECIFIED"
	var/reason = "NOT SPECIFIED"
	var/duration = 5

	var/list/internal_log = list()
	var/mode = 0  // 0 - making pass, 1 - viewing logs

/obj/machinery/computer/guestpass/New()
	..()
	uid = "[rand(100,999)]-G[rand(10,99)]"

/obj/machinery/computer/guestpass/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/card/id))
		if(!giver)
			if(user.drop_held_item())
				O.forceMove(src)
				giver = O
				updateUsrDialog()
		else
			to_chat(user, "<span class='warning'>There is already ID card inside.</span>")

/obj/machinery/computer/guestpass/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/guestpass/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/guestpass/attack_hand(var/mob/user as mob)
	if(..())
		return

	user.set_interaction(src)
	var/dat

	if (mode == 1) //Logs
		dat += "<h3>Activity log</h3><br>"
		for (var/entry in internal_log)
			dat += "[entry]<br><hr>"
		dat += "<a href='?src=\ref[src];action=print'>Print</a><br>"
		dat += "<a href='?src=\ref[src];mode=0'>Back</a><br>"
	else
		dat += "<h3>Guest pass terminal #[uid]</h3><br>"
		dat += "<a href='?src=\ref[src];mode=1'>View activity log</a><br><br>"
		dat += "Issuing ID: <a href='?src=\ref[src];action=id'>[giver]</a><br>"
		dat += "Issued to: <a href='?src=\ref[src];choice=giv_name'>[giv_name]</a><br>"
		dat += "Reason:  <a href='?src=\ref[src];choice=reason'>[reason]</a><br>"
		dat += "Duration (minutes):  <a href='?src=\ref[src];choice=duration'>[duration] m</a><br>"
		dat += "Access to areas:<br>"
		if (giver && giver.access)
			for (var/A in giver.access)
				var/area = get_access_desc(A)
				if (A in accesses)
					area = "<b>[area]</b>"
				dat += "<a href='?src=\ref[src];choice=access;access=[A]'>[area]</a><br>"
		dat += "<br><a href='?src=\ref[src];action=issue'>Issue pass</a><br>"

	user << browse(dat, "window=guestpass;size=400x520")
	onclose(user, "guestpass")


/obj/machinery/computer/guestpass/Topic(href, href_list)
	if(..())
		return
	usr.set_interaction(src)
	if (href_list["mode"])
		mode = text2num(href_list["mode"])

	if (href_list["choice"])
		switch(href_list["choice"])
			if ("giv_name")
				var/nam = stripped_input("Person pass is issued to", "Name", giv_name)
				if (nam)
					giv_name = nam
			if ("reason")
				var/reas = stripped_input(usr,"Reason why pass is issued", "Reason", reason)
				if(reas)
					reason = reas
			if ("duration")
				var/dur = input("Duration (in minutes) during which pass is valid (up to 30 minutes).", "Duration") as num|null
				if (dur)
					if (dur > 0 && dur <= 30)
						duration = dur
					else
						to_chat(usr, "<span class='warning'>Invalid duration.</span>")
			if ("access")
				var/A = text2num(href_list["access"])
				if (A in accesses)
					accesses.Remove(A)
				else
					accesses.Add(A)
	if (href_list["action"])
		switch(href_list["action"])
			if ("id")
				if (giver)
					if(ishuman(usr))
						giver.loc = usr.loc
						if(!usr.get_active_hand())
							usr.put_in_hands(giver)
						giver = null
					else
						giver.loc = src.loc
						giver = null
					accesses.Cut()
				else
					var/obj/item/I = usr.get_active_hand()
					if (istype(I, /obj/item/card/id))
						if(usr.drop_held_item())
							I.forceMove(src)
							giver = I
				updateUsrDialog()

			if ("print")
				var/dat = "<h3>Activity log of guest pass terminal #[uid]</h3><br>"
				for (var/entry in internal_log)
					dat += "[entry]<br><hr>"
				//to_chat(usr, "Printing the log, standby...")
				//sleep(50)
				var/obj/item/paper/P = new/obj/item/paper( loc )
				P.name = "activity log"
				P.info = dat

			if ("issue")
				if (giver)
					var/number = add_zero("[rand(0,9999)]", 4)
					var/entry = "\[[worldtime2text()]\] Pass #[number] issued by [giver.registered_name] ([giver.assignment]) to [giv_name]. Reason: [reason]. Grants access to following areas: "
					for (var/i=1 to accesses.len)
						var/A = accesses[i]
						if (A)
							var/area = get_access_desc(A)
							entry += "[i > 1 ? ", [area]" : "[area]"]"
					entry += ". Expires at [worldtime2text(world.time + duration*10*60)]."
					internal_log.Add(entry)

					var/obj/item/card/id/guest/pass = new(src.loc)
					pass.temp_access = accesses.Copy()
					pass.registered_name = giv_name
					pass.expiration_time = world.time + duration*10*60
					pass.reason = reason
					pass.name = "guest pass #[number]"
				else
					to_chat(usr, "<span class='danger'>Cannot issue pass without issuing ID.</span>")
	updateUsrDialog()
	return