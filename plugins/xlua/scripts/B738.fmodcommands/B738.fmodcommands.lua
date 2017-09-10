--- (C) Zibo, audiobirdxp 2017
B738DR_vol_airport = 5
---------- CREATE REFS -------------------------------------------------------------------------------

B738DR_enable_pax_boarding	= create_dataref("laminar/b738/fmodpack/fmod_pax_boarding_on", "number")
B738DR_enable_gyro	= create_dataref("laminar/b738/fmodpack/fmod_woodpecker_on", "number")
B738DR_enable_crew	= create_dataref("laminar/b738/fmodpack/fmod_crew_on", "number")
B738DR_enable_chatter	= create_dataref("laminar/b738/fmodpack/fmod_chatter_on", "number")
B738DR_airport_set = create_dataref("laminar/b738/fmodpack/fmod_airport_set", "number")
B738DR_vol_int_ducker = create_dataref("laminar/b738/fmodpack/fmod_vol_int_ducker", "number")
B738DR_vol_int_eng = create_dataref("laminar/b738/fmodpack/fmod_vol_int_eng", "number")
B738DR_vol_int_start = create_dataref("laminar/b738/fmodpack/fmod_vol_int_start", "number")
B738DR_vol_int_ac = create_dataref("laminar/b738/fmodpack/fmod_vol_int_ac", "number")
B738DR_vol_int_gyro = create_dataref("laminar/b738/fmodpack/fmod_vol_int_gyro", "number")
B738DR_vol_int_roll = create_dataref("laminar/b738/fmodpack/fmod_vol_int_roll", "number")
B738DR_vol_int_bump = create_dataref("laminar/b738/fmodpack/fmod_vol_int_bump", "number")


B738DR_vol_int_pax = create_dataref("laminar/b738/fmodpack/fmod_vol_int_pax", "number")
B738DR_vol_int_pax_applause = create_dataref("laminar/b738/fmodpack/fmod_pax_applause_on", "number")
B738DR_vol_int_wind_vol = create_dataref("laminar/b738/fmodpack/fmod_vol_int_wind", "number")

-- ********************* NEW audiobirdxp 7-8-2017
-- to mute the trim wheel when the AP is trimming
B738DR_enable_mutetrim	= create_dataref("laminar/b738/fmodpack/fmod_mutetrim_on", "number")
-- to set the airport volume (5 = standard)
B738DR_vol_airport	= create_dataref("laminar/b738/fmodpack/fmod_vol_airport", "number")
-- to trigger the long GWPS test
B738DR_enable_gpwstest_long	= create_dataref("laminar/b738/fmodpack/fmod_gpwstest_long_on", "number")
B738DR_enable_gpwstest_short	= create_dataref("laminar/b738/fmodpack/fmod_gpwstest_short_on", "number")

---------- FIND REFS -------------------------------------------------------------------------------

-- to control overall interior volume (XP11 setting) directly from FMC
B738DR_vol_int_XP = find_dataref("sim/operation/sound/interior_volume_ratio")

---------- COMMANDS HANDLER FUNCTIONS -------------------------------------------------------------------------------


function B738_enable_pax_boarding_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_enable_pax_boarding == 0 then
			B738DR_enable_pax_boarding = 1
		elseif B738DR_enable_pax_boarding == 1 then
			B738DR_enable_pax_boarding = 0
		end
	end
end

function B738_enable_gyro_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_enable_gyro == 0 then
			B738DR_enable_gyro = 1
		elseif B738DR_enable_gyro == 1 then
			B738DR_enable_gyro = 0
		end
	end
end

function B738_enable_crew_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_enable_crew == 0 then
			B738DR_enable_crew = 1
		elseif B738DR_enable_crew == 1 then
			B738DR_enable_crew = 0
		end
	end
end

function B738_enable_chatter_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_enable_chatter == 0 then
			B738DR_enable_chatter = 1
		elseif B738DR_enable_chatter == 1 then
			B738DR_enable_chatter = 0
		end
	end
end

function B738_airport_set_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_airport_set == 0 then
			B738DR_airport_set = 1
		elseif B738DR_airport_set == 1 then
			B738DR_airport_set = 2
		elseif B738DR_airport_set == 2 then
			B738DR_airport_set = 0
		end
	end 
end
-- function to drop internal volume by 10 db
function B738_vol_int_ducker_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_ducker == 0 then
			B738DR_vol_int_ducker = 1
		elseif B738DR_vol_int_ducker == 1 then
			B738DR_vol_int_ducker = 0
		end
	end
end

-- function to control eng volume inside
function B738_vol_int_eng_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_eng <= 9 then
			B738DR_vol_int_eng = (B738DR_vol_int_eng +1)
		elseif B738DR_vol_int_eng == 10 then
			B738DR_vol_int_eng = 0
		end
	end
end

-- function to control eng volume inside
function B738_vol_int_start_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_start <= 9 then
			B738DR_vol_int_start = (B738DR_vol_int_start +1)
		elseif B738DR_vol_int_start == 10 then
			B738DR_vol_int_start = 0
		end
	end
end

--  function to control AC volume inside 
function B738_vol_int_ac_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_ac <= 9 then
			B738DR_vol_int_ac = (B738DR_vol_int_ac +1)
		elseif B738DR_vol_int_ac == 10 then
			B738DR_vol_int_ac = 0
		end
	end
end

-- function to control AC volume inside 
function B738_vol_int_gyro_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_gyro <= 9 then
			B738DR_vol_int_gyro = (B738DR_vol_int_gyro +1)
		elseif B738DR_vol_int_gyro == 10 then
			B738DR_vol_int_gyro = 0
		end
	end
end

-- function to control roll volume inside 
function B738_vol_int_roll_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_roll <= 9 then
			B738DR_vol_int_roll = (B738DR_vol_int_roll +1)
		elseif B738DR_vol_int_roll == 10 then
			B738DR_vol_int_roll = 0
		end
	end
end


-- function to control intensity of extra bumps volume inside NEW **** audiobirdxp
function B738_vol_int_bump_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_bump <= 9 then
			B738DR_vol_int_bump = (B738DR_vol_int_bump +1)
		elseif B738DR_vol_int_bump == 10 then
			B738DR_vol_int_bump = 0
		end
	end
end


-- function to control PAX volume

function B738_vol_int_pax_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_pax <= 9 then
			B738DR_vol_int_pax = (B738DR_vol_int_pax +1)
		elseif B738DR_vol_int_pax == 10 then
			B738DR_vol_int_pax = 0
		end
	end
end

-- function to toggle PAX applause on landing ON or OFF

function B738_vol_int_pax_applause_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_pax_applause == 0 then
			B738DR_vol_int_pax_applause = 1
		elseif B738DR_vol_int_pax_applause == 1 then
			B738DR_vol_int_pax_applause = 0
		end
	end
end

-- function to control wind volume

function B738_vol_int_wind_vol_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_wind_vol <= 9 then
			B738DR_vol_int_wind_vol = (B738DR_vol_int_wind_vol +1)
		elseif B738DR_vol_int_wind_vol == 10 then
			B738DR_vol_int_wind_vol = 0
		end
	end
end


-- function to mute the trimwheel when AP is trimmming NEW AUDIOBIRDXP 7-8-2017

function B738_enable_mutetrim_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_enable_mutetrim == 0 then
			B738DR_enable_mutetrim = 1
		elseif B738DR_enable_mutetrim == 1 then
			B738DR_enable_mutetrim = 0
		end
	end
end

-- function to enable the long GPWS self test NEW AUDIOBIRDXP 7-8-2017


function B738_enable_gpwstest_long_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_enable_gpwstest_long == 0 then
			B738DR_enable_gpwstest_long = 1
		elseif B738DR_enable_gpwstest_long == 1 then
			B738DR_enable_gpwstest_long = 0
		end
	end
end


-- function to control overall interior volume from FMC (XP11 volume setting) NEW AUDIOBIRDXP 7-8-2017
-- from 0.0 to 1.0 !!!
-- maybe show this in FMC as 10, 20, 30, ... % so it's clear that this is not the FMOD volume but XP volume

function B738_vol_int_XP_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_int_XP <= 0.9 then
			B738DR_vol_int_XP = (B738DR_vol_int_XP + 0.1)
		elseif B738DR_vol_int_XP > 0.9 then
			B738DR_vol_int_XP = 0
		end
	end
end

-- function to control airport ambience volume inside AND outside NEW AUDIOBIRDXP 7-8-2017
function B738_vol_airport_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_vol_airport <= 9 then
			B738DR_vol_airport = (B738DR_vol_airport + 1)
		elseif B738DR_vol_airport == 10 then
			B738DR_vol_airport = 0
		end
	end
end




---------- CREATE COMMANDS -------------------------------------------------------------------------------

B738CMD_enable_pax_boarding 		= create_command("laminar/b738/fmodpack/fmod_toggle_pax_boarding", "Play PAX boarding", B738_enable_pax_boarding_CMDhandler)
B738CMD_enable_gyro 		= create_command("laminar/b738/fmodpack/fmod_woodpecker_on", "Toggle classic gyro vibrator ON or OFF", B738_enable_gyro_CMDhandler)
B738CMD_enable_crew		= create_command("laminar/b738/fmodpack/fmod_crew_on", "Toggle crew ON or OFF", B738_enable_crew_CMDhandler)
B738CMD_enable_chatter 		= create_command("laminar/b738/fmodpack/fmod_chatter_on", "Toggle chatter ON or OFF", B738_enable_chatter_CMDhandler)
B738CMD_airport_set 		= create_command("laminar/b738/fmodpack/fmod_airport_set", "Toggle airport ambience sets regional, busy or OFF", B738_airport_set_CMDhandler)
B738CMD_vol_int_ducker 		= create_command("laminar/b738/fmodpack/fmod_vol_int_ducker", "Toggle 10 db reduction of internal volume", B738_vol_int_ducker_CMDhandler)
B738CMD_vol_int_eng 		= create_command("laminar/b738/fmodpack/fmod_vol_int_eng", "Change engine volume inside", B738_vol_int_eng_CMDhandler)
B738CMD_vol_int_start 		= create_command("laminar/b738/fmodpack/fmod_vol_int_start", "Change engine start and stop volume inside", B738_vol_int_start_CMDhandler)

--- new commands *************** audiobirdxp
B738CMD_vol_int_ac 		= create_command("laminar/b738/fmodpack/fmod_vol_int_ac", "Change AC fans volume", B738_vol_int_ac_CMDhandler)
B738CMD_vol_int_gyro 		= create_command("laminar/b738/fmodpack/fmod_vol_int_gyro", "Change gyro vibrator volume if enabled", B738_vol_int_gyro_CMDhandler)
B738CMD_vol_int_roll		= create_command("laminar/b738/fmodpack/fmod_vol_int_roll", "Change roll volume", B738_vol_int_roll_CMDhandler)
B738CMD_vol_int_bump		= create_command("laminar/b738/fmodpack/fmod_vol_int_bump", "Change intensity of extra bumps when rolling", B738_vol_int_bump_CMDhandler)


-- ********************* NEW audiobirdxp 28-06-2017

B738CMD_vol_int_pax		= create_command("laminar/b738/fmodpack/fmod_vol_int_pax", "Change volume of passengers if enabled", B738_vol_int_pax_CMDhandler)
B738CMD_vol_int_pax_applause		= create_command("laminar/b738/fmodpack/fmod_pax_applause_on", "Toggle passengers applause on landing On or OFF", B738_vol_int_pax_applause_CMDhandler)
B738CMD_vol_int_wind_vol		= create_command("laminar/b738/fmodpack/fmod_vol_int_wind", "Change wind volume", B738_vol_int_wind_vol_CMDhandler)


-- ********************* NEW audiobirdxp 7-8-2017
-- ********************* AP trim wheel mute

B738CMD_enable_mutetrim 		= create_command("laminar/b738/fmodpack/fmod_mutetrim_on", "Toggle trimwheel muting ON or OFF", B738_enable_mutetrim_CMDhandler)

-- ********************* XP11 interior volume NEW audiobirdxp 7-8-2017
B738CMD_vol_int_XP		= create_command("laminar/b738/fmodpack/fmod_vol_int_XP", "Modify overall interior volume, same as XP11 setting", B738_vol_int_XP_CMDhandler)	

-- ********************* airport volume inside and outside NEW audiobirdxp 7-8-2017

B738CMD_vol_airport		= create_command("laminar/b738/fmodpack/fmod_vol_airport", "Change airport ambience volume inside and outside", B738_vol_airport_CMDhandler)	

-- ********************* enable playback of long GWPS self test NEW audiobirdxp 7-8-2017

B738CMD_enable_gpwstest_long		= create_command("laminar/b738/fmodpack/fmod_gpwstest_long_on", "Play or stop the long GWPS self-test", B738_enable_gpwstest_long_CMDhandler)	


function after_physics() 
end

-- names for FMC options:
--- AC FANS
--- GYRO VOL
--- ROLL VOL
--- BUMP INTENS


-- ********************* NEW audiobirdxp 28-06-2017
-- PAX VOL
-- APPLAUSE


-- ********************* NEW audiobirdxp 7-8-2017
-- MUTE TRIMWH. ON / OFF
-- XP INT VOL 0.1 to 1.0 

