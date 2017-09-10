
-------------------------------------------- DEFINING VARIABLES  ---------------------------------------------------------------------------------------

-- plane on ground - all wheels
on_the_ground = 0

-- plane on air more than 30 sec and any wheel touch the ground (protect against bump toachdown)
touch_down = 0

-- plane on air more than 30 seconds
was_air_delay = 0

-- plane on ground more than 7 seconds
was_ground_delay = 0

play_landed_ann_armed = 0




-- NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW
ground_time = 0		-- time on the ground 0-30sec
air_time = 0		-- time in the air 0-100 sec
plane_on_the_ground = 0
-- NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW


-------------------------------------------- FINDING DATAREFS ---------------------------------------------------------------------------------------

apu_gen        = find_dataref("sim/cockpit/electrical/generator_apu_on")
gpu_on        = find_dataref("sim/cockpit/electrical/gpu_on")
apu_temp      = find_dataref("laminar/B738/electrical/apu_temp")
standbypwr    = find_dataref("sim/cockpit2/electrical/battery_on[1]")
minimums    = find_dataref("sim/cockpit/misc/radio_altimeter_minimum")
ft_agl   = find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
fpm  = find_dataref("sim/flightmodel/position/vh_ind_fpm")
eng_gen  = find_dataref("sim/cockpit/electrical/generator_on")
left_pack  = find_dataref("laminar/B738/air/l_pack_pos")
right_pack  = find_dataref("laminar/B738/air/r_pack_pos")
pressure_L = find_dataref("laminar/B738/indicators/duct_press_L")
pressure_R = find_dataref("laminar/B738/indicators/duct_press_R")
bleed_valve_L = find_dataref("laminar/B738/toggle_switch/bleed_air_1_pos")
bleed_valve_R = find_dataref("laminar/B738/toggle_switch/bleed_air_2_pos")
bleed_valve_APU = find_dataref("laminar/B738/toggle_switch/bleed_air_apu_pos")
eng_genL  = find_dataref("sim/cockpit/electrical/generator_on[0]")
eng_genR  = find_dataref("sim/cockpit/electrical/generator_on[1]")

vvi_dial_show		= find_dataref("laminar/B738/autopilot/vvi_dial_show")
vvi_dial			= find_dataref("sim/cockpit2/autopilot/vvi_dial_fpm")

spd_dial_show		= find_dataref("laminar/B738/autopilot/show_ias")
spd_dial			= find_dataref("sim/cockpit2/autopilot/airspeed_dial_kts_mach")

-- datarefs for after landing announcements
is_autospeedbrake_up = find_dataref("sim/flightmodel/controls/sbrkrat")
is_plane_onground =  find_dataref("sim/flightmodel/failures/onground_any")
current_gs = find_dataref("sim/flightmodel/position/groundspeed")
-- datarefs for V1 alert
calculated_V1 =  find_dataref("laminar/B738/FMS/v1_calc")
autobrake_status = find_dataref("laminar/B738/autobrake/autobrake_pos")
-- TO config and Cabin altitude warnings
alt_horn_cut_disable	= find_dataref("laminar/B738/alert/alt_horn_cut_disable")
cabin_alt				= find_dataref("sim/cockpit2/pressurization/indicators/cabin_altitude_ft")
to_config				= find_dataref("laminar/B738/system/takeoff_config_warn")
-- Below G/S warning
below_gs_disable		= find_dataref("laminar/B738/alert/below_gs_disable")
below_gs_warn			= find_dataref("laminar/B738/system/below_gs_warn")
chosen_airport_set = find_dataref ("laminar/b738/fmodpack/fmod_airport_set")

--- datarefs for fuel pump detection and battery on?

fuel1 = find_dataref("laminar/B738/fuel/fuel_tank_pos_lft1")
fuel2 = find_dataref("laminar/B738/fuel/fuel_tank_pos_lft2")
fuel3 = find_dataref("laminar/B738/fuel/fuel_tank_pos_ctr1")
fuel4 = find_dataref("laminar/B738/fuel/fuel_tank_pos_ctr2")
fuel5 = find_dataref("laminar/B738/fuel/fuel_tank_pos_rgt1")
fuel6 = find_dataref("laminar/B738/fuel/fuel_tank_pos_rgt2")
bat_on = find_dataref("sim/cockpit/electrical/battery_on")



-- for fuel pumps
simDR_bus_volts1		= find_dataref("sim/cockpit2/electrical/bus_volts[0]")
simDR_bus_volts2		= find_dataref("sim/cockpit2/electrical/bus_volts[1]")
-- for V1 callout
fms_v1_set			= find_dataref("laminar/B738/FMS/v1_set")
simDR_airspeed_pilot	= find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
v1r_bugs		= find_dataref("laminar/B738/FMS/v1r_bugs")



-- ********************** refs to calculate gear warning (1 = down, 0 = up) audiobirdxp

gear_nose	= find_dataref("sim/flightmodel/movingparts/gear1def")
gear_main1	= find_dataref("sim/flightmodel/movingparts/gear2def")
gear_main2	= find_dataref("sim/flightmodel/movingparts/gear2def")
ias			= find_dataref("sim/flightmodel/position/indicated_airspeed")


-- ********* refs to calculate pre landing announcement trigger 7-8-2017 *******
ed_dist				= find_dataref("laminar/B738/fms/ed_dist")
ed_found			= find_dataref("laminar/B738/fms/ed_idx")
offset				= find_dataref("laminar/B738/fms/vnav_idx")
simDR_fmc_dist2		= find_dataref("laminar/B738/fms/lnav_dist2_next")
B738_legs_num		= find_dataref("laminar/B738/vnav/legs_num")



-- ********************** NEW refs 7-8-2017 to suppress touch_down going to 1 while taxiing

is_taxi = find_dataref("sim/cockpit2/switches/generic_lights_switch[4]")



-------------------------------------------- CREATING DATAREFS ---------------------------------------------------------------------------------------

-- dataref to show if AC power is established (gyro, fans,...)
ac_is_established   = create_dataref("laminar/b738/fmodpack/ac_established", "number")
-- APP minimums callout
appromins    = create_dataref("laminar/b738/fmodpack/appro_mins", "number")
-- datarefs for pack operation
packsLon   = create_dataref("laminar/b738/fmodpack/packs_L", "number")
packsRon   = create_dataref("laminar/b738/fmodpack/packs_R", "number")
-- dataref to mute VS dial when autopilot is dialing
play_vvi_dial = create_dataref("laminar/b738/fmodpack/play_vvi_dial_sound", "number")

-- dataref to mute SPD dial when autopilot is dialing
play_spd_dial = create_dataref("laminar/b738/fmodpack/play_spd_dial_sound", "number")

-- dataref after landing announcements
play_landed_announcement = create_dataref("laminar/b738/fmodpack/play_landed", "number")
-- dataref for V1 alert
play_V1 = create_dataref("laminar/b738/fmodpack/play_V1", "number")
-- dataref for converted ground speed
real_gs = create_dataref("laminar/b738/fmodpack/real_groundspeed", "number")

-- is the plane on the ground? 
-- is it moving (to avoid V1 being played when GS = 0 and calculated V1 = 0) ? (GS > 10 because even standing still GS is always > 0 in XP11)
-- is the converted groundspeed (XP groundspeed value * 1.94) >= calculated V1 from the FMS? (the event is self-terminating, so it's okay to have play_V1 go to "1" as soon as calculated_V1 is reached)
-- is the autobrake set to RTO? (to avoid V1 being played during landing roll)

-- dataref for TO config and Cabin altitude warnings
horn_alert = create_dataref("laminar/b738/fmodpack/horn_alert", "number")
-- dataref for Below G/S warning
below_gs_alert = create_dataref("laminar/b738/fmodpack/below_gs_alert", "number")

-- for airport ambience
enable_airport_ambience = create_dataref("laminar/b738/fmodpack/fmod_enable_airport_ambience", "number")

--- dataref to play fuel pumps

play_fuelpumps = create_dataref("laminar/b738/fmodpack/fmod_playfuelpumps", "number")

-- ********************** ref to play  gear warning audiobirdxp

play_gearwarn = create_dataref("laminar/b738/fmodpack/fmod_playgearwarn", "number")

-- ********************** NEW refs 7-8-2017 to play pre landing announcement

play_preland = create_dataref("laminar/b738/fmodpack/fmod_play_preland", "number")



DR_begin_flight = create_dataref("laminar/b738/fmodpack/begin_flight", "number")



-- wheels on the ground
simDR_on_ground_0				= find_dataref("sim/flightmodel2/gear/on_ground[0]")
simDR_on_ground_1				= find_dataref("sim/flightmodel2/gear/on_ground[1]")
simDR_on_ground_2				= find_dataref("sim/flightmodel2/gear/on_ground[2]")
simDR_radio_height_pilot_ft		= find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")


-- TOO LOW , GEAR warning if attempting to land with landing gears up
-- maybe rather take annunciators going green instead of actual landing gear deployment?

function gear_warn()
	if ft_agl < 500 and ias < 178 and fpm < 0 and (gear_nose + gear_main1 + gear_main2) < 3 then
	play_gearwarn = 1
	else
	play_gearwarn = 0
	end
end
-- ***** NEW FUNCTION *****--

-- ***** NEW FUNCTION *****--
function detect_fuel_pumps()
	if simDR_bus_volts1 > 10 or simDR_bus_volts2 > 10 then
		if fuel1 == 1 or fuel2 == 1 or fuel3 == 1 or fuel4 == 1 or fuel5 == 1 or fuel6 == 1 then 
			play_fuelpumps = 1
		else
			play_fuelpumps = 0 
		end
	else
		play_fuelpumps = 0 
	end
end
-- ***** NEW FUNCTION *****--






function play_airport_ambience()
	if is_plane_onground == 0 then 
		enable_airport_ambience = 0
	elseif is_plane_onground == 1 then
		 enable_airport_ambience = (chosen_airport_set +1)
	end
end




-- function alert_V1()
-- real_gs = (current_gs * 1.94)
    -- if is_plane_onground > 0 and real_gs > 10  and real_gs >= calculated_V1 and autobrake_status == 0 then
        -- play_V1 = 1
    -- else
        -- play_V1 = 0
    -- end
    
-- end

-- ***** NEW FUNCTION *****--
function alert_V1()
	if v1r_bugs == 1 and fms_v1_set > 0 then
		if simDR_airspeed_pilot >= fms_v1_set then
			play_V1 = 1
		else
			play_V1 = 0
		end
    else
        play_V1 = 0
    end
    
end
-- ***** NEW FUNCTION *****--


-- spoilers deployed on ground (values > 1)?
-- plane moving?
-- plane on the ground?

-- function announcement_crew_landed()
-- real_gs = (current_gs * 1.94)
    -- if is_autospeedbrake_up > 1.1 and real_gs > 10 and is_plane_onground == 1  then
        -- play_landed_announcement = 1
    -- else
        -- play_landed_announcement = 0
    -- end
    
-- end

-- are any generators providing AC power and are switched on?

function acgyrologic()
    if gpu_on == 1 or eng_genL == 1 or eng_genR == 1 or apu_gen == 1  then
        ac_is_established = 1
    else
        ac_is_established = 0
    end
    
end

-- PACK LOGIC: AC blows in air if either the engine bleeds air and the pack for that side is turned on OR the APU bleeds air into the system and pack for that side is turned on

function pack_play_L()
    if left_pack > 0 and bleed_valve_L == 1 and pressure_L > 0 then
        packsLon = 1
    elseif left_pack > 0 and bleed_valve_APU == 1 and pressure_L > 0 then
        packsLon = 1
    else
        packsLon = 0
    end
    
end

function pack_play_R()
    if right_pack > 0 and bleed_valve_R == 1 and pressure_R > 0 then
        packsRon = 1
    elseif right_pack > 0 and bleed_valve_APU == 1 and pressure_R > 0 then
        packsRon = 1
    else
        packsRon = 0
    end
    
end


function appromins_func()
	if ft_agl < minimums + 105 and ft_agl > minimums + 100 and fpm < 0 and minimums > 0 then
		appromins = 1
	else
		appromins = 0
	end
   
end


-- MINIMUMS --------------------------------------------
-- function dh_mins_func()
	-- local dh_min = 0
	-- if dh_min_pilot > 0 then
		-- dh_min = 1
	-- end
	-- if dh_min_pilot_old ~= dh_min and dh_min == 1 then
		-- --play_mins = 1
	-- else
		-- -- play_mins = 0
	-- end
	-- dh_min_pilot_old = dh_min
-- end
---------------------------------------------------------

-- VVI DIAL ---------------------------------------------

function vvi_dial_func()
	if vvi_dial_show == 1 then
		play_vvi_dial = vvi_dial
	end
end

---------------------------------------------------------

-- TO CONFIG and ALT HORN CUTOUT
function alt_horn_cutout_func()
	local horn = 0
	if alt_horn_cut_disable == 0 and cabin_alt > 10000 then
		horn = 1
	end
	if to_config == 1 then
		horn = 1
	end
	horn_alert = horn
end

-- BELOW G/S
function below_gs_func()
	if below_gs_disable == 0 and below_gs_warn == 1 then
		below_gs_alert = 1
	else
		below_gs_alert = 0
	end
end





-- ***** NEW FUNCTION *****--

-- SPD DIAL ---------------------------------------------
function spd_dial_func()
	if spd_dial_show == 1 then
		play_spd_dial = spd_dial
	end
end

-- ***** NEW FUNCTION *****--




-- ***** NEW FUNCTION *****--

function was_air_delay_timer()
	was_air_delay = 1
end

function was_ground_delay_timer()
	was_ground_delay = 1
end

function ground_air_logic()
	-- on the ground
	if simDR_on_ground_0 == 1 and simDR_on_ground_1 == 1 and simDR_on_ground_2 == 1 then
		on_the_ground = 1
		touch_down = 0
	end
	if simDR_on_ground_0 == 0 and simDR_on_ground_1 == 0 and simDR_on_ground_2 == 0 then
		on_the_ground = 0
		was_ground_delay = 0
	end
	
	if on_the_ground == 0 and was_air_delay == 0 then
		if is_timer_scheduled(was_air_delay_timer) == false then
			run_after_time(was_air_delay_timer, 30)	-- 30 seconds
		end
	end
	
	if on_the_ground == 1 and was_ground_delay == 0 then
		if is_timer_scheduled(was_ground_delay_timer) == false then
			run_after_time(was_ground_delay_timer, 5)	-- 5 seconds
		end
	end
	
	if was_air_delay == 1 then
		if simDR_on_ground_0 == 1 or simDR_on_ground_1 ==1 or simDR_on_ground_2 == 1 then
			touch_down = 1
			was_air_delay = 0
		end
	end
	
end

-- ***** NEW FUNCTION *****--




-- ***** MODIFIED FUNCTION 7-8-2017 
-- modified GS condition from <20 to <30 (which is rough measure for maximum taxi speed)
-- added is_taxi to determin if plane is taxiing (by position of taxi light switch)

function announcement_crew_landed()
	
	real_gs = (current_gs * 1.94)	-- knots
	
	if touch_down == 1 and is_taxi == 0 then
		play_landed_ann_armed = 1
	end
	if play_landed_ann_armed == 1 and on_the_ground == 1 and real_gs < 100 and is_taxi == 0 then
		play_landed_announcement = 1
		play_landed_ann_armed = 0
	end
	if was_ground_delay == 1 and real_gs < 30 then
		play_landed_announcement = 0
	end
	if was_air_delay == 1 then
		play_landed_ann_armed = 0
	end
	
end
-- ***** NEW FUNCTION *****--



-- ***** NEW FUNCTION *****--
function detect_prelanding()

	if offset == ed_found then
		if ed_found > B738_legs_num then
			-- E/D is Destination airport
			if simDR_fmc_dist2 < 10 then 	-- 10 NM before airport
				play_preland = 1 	--- YOUR TRIGGER ---
			end
		else
			-- E/D is waypoint before Destination airport 
			if simDR_fmc_dist2 < 6 then 	-- 6 NM before airport
				play_preland = 1 	--- YOUR TRIGGER ---
			end
		end
	else
		play_preland  = 0 	--- YOUR TRIGGER ---
	end
end
-- ***** NEW FUNCTION *****--



-- NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW
-- ***** NEW FUNCTION 01-08-2017 *****--

-- plane on the ground
function plane_on_ground()
	
	if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 or simDR_on_ground_2 == 1 then
		plane_on_the_ground = 1
	else
		plane_on_the_ground = 0
	end

end

-- timer for plane on the ground 0 - 30 sec
function ground_timer()
	if plane_on_the_ground == 1 then
		if ground_time < 30 then
			ground_time = ground_time + 1
		end
	else
		air_time = 0
	end
end

-- timer for plane in the air 0 - 100 sec
function air_timer()
	if plane_on_the_ground == 0 then
		if air_time < 100 then
			air_time = ground_time + 1
		end
	else
		ground_time = 0
	end
end

function detect_takeoff()
	if air_time > 30 then	-- 30sec in the air
		-- detected takeoff
	end
end
-- NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW



-- This function startet when you load aircraft first time
--function aircraft_load()
--end


-- This function startet once when you load or reload aircraft
function flight_start()

	on_the_ground = 0
	touch_down = 0
	was_air_delay = 0
	was_ground_delay = 0
	play_landed_ann_armed = 0
	
	-- NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW --
	
	ground_time = 0
	air_time = 0
	plane_on_the_ground = 0
	
	if is_timer_scheduled(ground_timer) == false then
		run_after_time(ground_timer, 1)	-- Every 1 sec
	end
	if is_timer_scheduled(air_timer) == false then
		run_after_time(air_timer, 1)	-- Every 1 sec
	end
	
	DR_begin_flight = 0			-- aircraft loaded or reloaded
	if ft_agl > 50 then
		DR_begin_flight = 1		-- you started plane in air (for exapmple approach 10NM to runway)
	end
	
	-- NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW --

	end



function after_physics()

	 gear_warn()
	 detect_fuel_pumps()
	 play_airport_ambience()
	 alert_V1()
	 announcement_crew_landed()
	 acgyrologic()
	 appromins_func()
	 pack_play_L()
	 pack_play_R()
	 vvi_dial_func()
	 alt_horn_cutout_func()
	 below_gs_func()
	 spd_dial_func()
	 ground_air_logic()
	 -- new name for your trigger function 7-8-2017 audiobirdxp
	 detect_prelanding()
	 
	 -- NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW
	 plane_on_ground()
	 detect_takeoff()
	-- NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW NEW

	 end
