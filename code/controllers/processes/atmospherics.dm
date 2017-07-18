datum/controller/process/atmospherics

datum/controller/process/atmospherics/setup()
	name = "Atmospherics"
	schedule_interval = 25 // 2.5 seconds


	if(!air_master)
		air_master = new /datum/controller/air_system()
		air_master.Setup()

	world << "\red \b Initializing pipe networks"
	sleep(-1)
	for (var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()

	world << "\red \b Initializing atmos machinery."
	sleep(-1)
	for (var/obj/machinery/atmospherics/unary/U in machines)
		if (istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()

		else if (istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()

datum/controller/process/atmospherics/doWork()
	air_master.Tick()

	var/i = 1
	while(i<=pipe_networks.len)
		var/datum/pipe_network/Network = pipe_networks[i]
		if(Network)
			Network.process()
			i++
			continue
		pipe_networks.Cut(i,i+1)