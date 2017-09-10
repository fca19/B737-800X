

--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--

-- AUTOPILOT
n1_butt_old = 0
speed_butt_old = 0
lvl_chg_butt_old = 0
vnav_butt_old = 0
lnav_butt_old = 0
vor_loc_butt_old = 0
app_butt_old = 0
hdg_sel_butt_old = 0
alt_hld_butt_old = 0
vs_butt_old = 0
cmd_a_butt_old = 0
cmd_b_butt_old = 0
cws_a_butt_old = 0
cws_b_butt_old = 0
co_butt_old = 0
disconnect_old = 0
fd_ca_old = 0
fd_fo_old = 0
at_arm_old = 0
at_arm_old_pos = 0
ap_disc_old = 0
ap_disc_old_pos = 0
bank_angle_old = 0
apu_start_old = 0
B738_apu_start_old = 0
spd_intv_butt_old = 0
alt_intv_butt_old = 0
--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_startup_running	= find_dataref("sim/operation/prefs/startup_running")

simDR_throttle_override			= find_dataref("sim/operation/override/override_throttles")
simDR_joy_pitch_override		= find_dataref("sim/operation/override/override_joystick_pitch")
simDR_fdir_pitch_ovr			= find_dataref("sim/operation/override/override_flightdir_ptch")
simDR_fdir_roll_ovr				= find_dataref("sim/operation/override/override_flightdir_roll")
simDR_fms_override 				= find_dataref("sim/operation/override/override_fms_advance")
simDR_toe_brakes_ovr			= find_dataref("sim/operation/override/override_toe_brakes")
simDR_steer_ovr					= find_dataref("sim/operation/override/override_wheel_steer")
simDR_override_heading			= find_dataref("sim/operation/override/override_joystick_heading")
simDR_override_pitch			= find_dataref("sim/operation/override/override_joystick_pitch")
simDR_override_roll				= find_dataref("sim/operation/override/override_joystick_roll")
simDR_kill_map_fms			= find_dataref("sim/graphics/misc/kill_map_fms_line")

simDR_gpu_on				= find_dataref("sim/cockpit/electrical/gpu_on")
--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_gpu_on					= find_command("sim/electrical/GPU_on")
simCMD_generator_1_off			= find_command("sim/electrical/generator_1_off")
simCMD_generator_2_off			= find_command("sim/electrical/generator_2_off")






--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

B738DR_autopilot_fd_pos				= find_dataref("laminar/B738/autopilot/flight_director_pos")
B738DR_autopilot_fd_fo_pos			= find_dataref("laminar/B738/autopilot/flight_director_fo_pos")
B738DR_autopilot_bank_angle_pos		= find_dataref("laminar/B738/autopilot/bank_angle_pos")
B738DR_autopilot_autothr_arm_pos	= find_dataref("laminar/B738/autopilot/autothrottle_arm_pos")
B738DR_autopilot_disconnect_pos		= find_dataref("laminar/B738/autopilot/disconnect_pos")
B738DR_gear_handle_pos				= find_dataref("laminar/B738/controls/gear_handle_down")

B738DR_apu_power_bus1				= find_dataref("laminar/B738/electrical/apu_power_bus1")
B738DR_apu_power_bus2				= find_dataref("laminar/B738/electrical/apu_power_bus2")

B738DR_engine_no_running_state 		= find_dataref("laminar/B738/fms/engine_no_running_state")

--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--

-- AUTOPILOT
B738CMD_autopilot_n1_press				= find_command("laminar/B738/autopilot/n1_press")
B738CMD_autopilot_speed_press			= find_command("laminar/B738/autopilot/speed_press")
B738CMD_autopilot_lvl_chg_press			= find_command("laminar/B738/autopilot/lvl_chg_press")
B738CMD_autopilot_vnav_press			= find_command("laminar/B738/autopilot/vnav_press")
B738CMD_autopilot_co_press				= find_command("laminar/B738/autopilot/change_over_press")

B738CMD_autopilot_lnav_press			= find_command("laminar/B738/autopilot/lnav_press")
B738CMD_autopilot_vorloc_press			= find_command("laminar/B738/autopilot/vorloc_press")
B738CMD_autopilot_app_press				= find_command("laminar/B738/autopilot/app_press")
B738CMD_autopilot_hdg_sel_press			= find_command("laminar/B738/autopilot/hdg_sel_press")

B738CMD_autopilot_alt_hld_press			= find_command("laminar/B738/autopilot/alt_hld_press")
B738CMD_autopilot_vs_press				= find_command("laminar/B738/autopilot/vs_press")

B738CMD_autopilot_disconnect_toggle		= find_command("laminar/B738/autopilot/disconnect_toggle")
B738CMD_autopilot_autothr_arm_toggle	= find_command("laminar/B738/autopilot/autothrottle_arm_toggle")
B738CMD_autopilot_flight_dir_toggle		= find_command("laminar/B738/autopilot/flight_director_toggle")
B738CMD_autopilot_flight_dir_fo_toggle	= find_command("laminar/B738/autopilot/flight_director_fo_toggle")
B738CMD_autopilot_bank_angle_up			= find_command("laminar/B738/autopilot/bank_angle_up")
B738CMD_autopilot_bank_angle_dn			= find_command("laminar/B738/autopilot/bank_angle_dn")

B738CMD_autopilot_cmd_a_press			= find_command("laminar/B738/autopilot/cmd_a_press")
B738CMD_autopilot_cmd_b_press			= find_command("laminar/B738/autopilot/cmd_b_press")

B738CMD_autopilot_cws_a_press			= find_command("laminar/B738/autopilot/cws_a_press")
B738CMD_autopilot_cws_b_press			= find_command("laminar/B738/autopilot/cws_b_press")

B738CMD_vhf_nav_source_switch_lft		= find_command("laminar/B738/toggle_switch/vhf_nav_source_lft")
B738CMD_vhf_nav_source_switch_rgt		= find_command("laminar/B738/toggle_switch/vhf_nav_source_rgt")

B738CMD_gear_down						= find_command("laminar/B738/push_button/gear_down")
B738CMD_gear_up							= find_command("laminar/B738/push_button/gear_up")
B738CMD_gear_off						= find_command("laminar/B738/push_button/gear_off")

B738CMD_apu_starter_switch_up	= find_command("laminar/B738/spring_toggle_switch/APU_start_pos_up")
B738CMD_apu_starter_switch_dn	= find_command("laminar/B738/spring_toggle_switch/APU_start_pos_dn")


B738CMD_autopilot_spd_interv			= find_command("laminar/B738/autopilot/spd_interv")
B738CMD_autopilot_alt_interv			= find_command("laminar/B738/autopilot/alt_interv")

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--

function B738_n1_butt_DRhandler()end
function B738_speed_butt_DRhandler()end
function lvl_chg_butt_DRhandler()end
function B738_vnav_butt_DRhandler()end
function B738_lnav_butt_DRhandler()end
function B738_vor_loc_butt_DRhandler()end
function B738_app_butt_DRhandler()end
function B738_hdg_sel_butt_DRhandler()end
function B738_alt_hld_butt_DRhandler()end
function B738_vs_butt_DRhandler()end
function B738_cmd_a_butt_DRhandler()end
function B738_cmd_b_butt_DRhandler()end
function B738_cws_a_butt_DRhandler()end
function B738_cws_b_butt_DRhandler()end
function B738_co_butt_DRhandler()end

function B738_fd_ca_switch_DRhandler()end
function B738_fd_fo_switch_DRhandler()end
function B738_at_arm_switch_DRhandler()end
function B738_ap_disconnect_switch_DRhandler()end

function B738_bank_angle_rot_DRhandler()end

function B738_landing_gear_DRhandler()end
function B738_apu_start_DRhandler()end

function B738_spd_intv_butt_DRhandler()end
function B738_alt_intv_butt_DRhandler()end

--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--

-- AUTOPILOT buttons
B738_n1_butt			= create_dataref("laminar/B738/buttons/autopilot/n1", "number", B738_n1_butt_DRhandler)
B738_speed_butt			= create_dataref("laminar/B738/buttons/autopilot/speed", "number", B738_speed_butt_DRhandler)
B738_lvl_chg_butt		= create_dataref("laminar/B738/buttons/autopilot/lvl_chg", "number", lvl_chg_butt_DRhandler)
B738_vnav_butt			= create_dataref("laminar/B738/buttons/autopilot/vnav", "number", B738_vnav_butt_DRhandler)
B738_lnav_butt			= create_dataref("laminar/B738/buttons/autopilot/lnav", "number", B738_lnav_butt_DRhandler)
B738_vor_loc_butt		= create_dataref("laminar/B738/buttons/autopilot/vor_loc", "number", B738_vor_loc_butt_DRhandler)
B738_app_butt			= create_dataref("laminar/B738/buttons/autopilot/app", "number", B738_app_butt_DRhandler)
B738_hdg_sel_butt		= create_dataref("laminar/B738/buttons/autopilot/hdg_sel", "number", B738_hdg_sel_butt_DRhandler)
B738_alt_hld_butt		= create_dataref("laminar/B738/buttons/autopilot/alt_hld", "number", B738_alt_hld_butt_DRhandler)
B738_vs_butt			= create_dataref("laminar/B738/buttons/autopilot/vs", "number", B738_vs_butt_DRhandler)
B738_cmd_a_butt			= create_dataref("laminar/B738/buttons/autopilot/cmd_a", "number", B738_cmd_a_butt_DRhandler)
B738_cmd_b_butt			= create_dataref("laminar/B738/buttons/autopilot/cmd_b", "number", B738_cmd_b_butt_DRhandler)
B738_cws_a_butt			= create_dataref("laminar/B738/buttons/autopilot/cws_a", "number", B738_cws_a_butt_DRhandler)
B738_cws_b_butt			= create_dataref("laminar/B738/buttons/autopilot/cws_b", "number", B738_cws_b_butt_DRhandler)
B738_co_butt			= create_dataref("laminar/B738/buttons/autopilot/co", "number", B738_co_butt_DRhandler)
B738_spd_intv_butt		= create_dataref("laminar/B738/buttons/autopilot/spd_intv", "number", B738_spd_intv_butt_DRhandler)
B738_alt_intv_butt		= create_dataref("laminar/B738/buttons/autopilot/alt_intv", "number", B738_alt_intv_butt_DRhandler)

-- AUTOPILOT switches
B738_fd_ca_switch	= create_dataref("laminar/B738/switches/autopilot/fd_ca", "number", B738_fd_ca_switch_DRhandler)
B738_fd_fo_switch	= create_dataref("laminar/B738/switches/autopilot/fd_fo", "number", B738_fd_fo_switch_DRhandler)
-- AUTOPILOT switches with auto-off
B738_at_arm_switch			= create_dataref("laminar/B738/switches/autopilot/at_arm", "number", B738_at_arm_switch_DRhandler)
B738_ap_disconnect_switch	= create_dataref("laminar/B738/switches/autopilot/ap_disconnect", "number", B738_ap_disconnect_switch_DRhandler)
-- AUTOPILOT rotary
B738_bank_angle_rot		= create_dataref("laminar/B738/rotary/autopilot/bank_angle", "number", B738_bank_angle_rot_DRhandler)

-- OTHERS
B738_landing_gear		= create_dataref("laminar/B738/switches/landing_gear", "number", B738_landing_gear_DRhandler)
B738_apu_start			= create_dataref("laminar/B738/switches/apu_start", "number", B738_apu_start_DRhandler)

--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--


			
--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             REPLACE X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              WRAP X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					           OBJECT CONSTRUCTORS         		        		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                  CREATE OBJECTS              	     			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--


-- AUTOPILOT buttons

function B738_ap_buttons()

	-- N1
	if B738_n1_butt ~= n1_butt_old
	and B738_n1_butt == 1 then
		B738CMD_autopilot_n1_press:once()
	end
	n1_butt_old = B738_n1_butt
	
	-- SPEED
	if B738_speed_butt ~= speed_butt_old 
	and B738_speed_butt == 1 then
		B738CMD_autopilot_speed_press:once()
	end
	speed_butt_old = B738_speed_butt
	
	-- LVL CHG
	if B738_lvl_chg_butt ~= lvl_chg_butt_old 
	and B738_lvl_chg_butt == 1 then
		B738CMD_autopilot_lvl_chg_press:once()
	end
	lvl_chg_butt_old = B738_lvl_chg_butt
	
	-- VNAV
	if B738_vnav_butt ~= vnav_butt_old 
	and B738_vnav_butt == 1 then
		B738CMD_autopilot_vnav_press:once()
	end
	vnav_butt_old = B738_vnav_butt
	
	-- LNAV
	if B738_lnav_butt ~= lnav_butt_old 
	and B738_lnav_butt == 1 then
		B738CMD_autopilot_lnav_press:once()
	end
	lnav_butt_old = B738_lnav_butt
	
	-- VOR LOC
	if B738_vor_loc_butt ~= vor_loc_butt_old 
	and B738_vor_loc_butt == 1 then
		B738CMD_autopilot_vorloc_press:once()
	end
	vor_loc_butt_old = B738_vor_loc_butt
	
	-- APP
	if B738_app_butt ~= app_butt_old 
	and B738_app_butt == 1 then
		B738CMD_autopilot_app_press:once()
	end
	app_butt_old = B738_app_butt
	
	-- HDG SEL
	if B738_hdg_sel_butt ~= hdg_sel_butt_old 
	and B738_hdg_sel_butt == 1 then
		B738CMD_autopilot_hdg_sel_press:once()
	end
	hdg_sel_butt_old = B738_hdg_sel_butt
	
	-- ALT HLD
	if B738_alt_hld_butt ~= alt_hld_butt_old 
	and B738_alt_hld_butt == 1 then
		B738CMD_autopilot_alt_hld_press:once()
	end
	alt_hld_butt_old = B738_alt_hld_butt
	
	-- VS
	if B738_vs_butt ~= vs_butt_old 
	and B738_vs_butt == 1 then
		B738CMD_autopilot_vs_press:once()
	end
	vs_butt_old = B738_vs_butt
	
	-- CMD a
	if B738_cmd_a_butt ~= cmd_a_butt_old 
	and B738_cmd_a_butt == 1 then
		B738CMD_autopilot_cmd_a_press:once()
	end
	cmd_a_butt_old = B738_cmd_a_butt
	
	-- CND b
	if B738_cmd_b_butt ~= cmd_b_butt_old 
	and B738_cmd_b_butt == 1 then
		B738CMD_autopilot_cmd_b_press:once()
	end
	cmd_b_butt_old = B738_cmd_b_butt
	
	-- CWS a
	if B738_cws_a_butt ~= cws_a_butt_old 
	and B738_cws_a_butt == 1 then
		B738CMD_autopilot_cws_a_press:once()
	end
	cws_a_butt_old = B738_cws_a_butt
	
	-- CWS b
	if B738_cws_b_butt ~= cws_b_butt_old 
	and B738_cws_b_butt == 1 then
		B738CMD_autopilot_cws_b_press:once()
	end
	cws_b_butt_old = B738_cws_b_butt
	
	-- C/O crossover altitude
	if B738_co_butt ~= co_butt_old 
	and B738_co_butt == 1 then
		B738CMD_autopilot_co_press:once()
	end
	co_butt_old = B738_co_butt
	
	-- FLIGHT DIRECTOR CAPTAIN
	if fd_ca_old ~= B738_fd_ca_switch then
		if B738DR_autopilot_fd_pos ~= B738_fd_ca_switch then
			B738CMD_autopilot_flight_dir_toggle:once()
		end
	end
	fd_ca_old = B738_fd_ca_switch
	
	-- FLIGHT DIRECTOR OFFICER
	if fd_fo_old ~= B738_fd_fo_switch then
		if B738DR_autopilot_fd_fo_pos ~= B738_fd_fo_switch then
			B738CMD_autopilot_flight_dir_fo_toggle:once()
		end
	end
	fd_fo_old = B738_fd_fo_switch
	
	-- BANK ANGLE
	if bank_angle_old ~= B738_bank_angle_rot then
		if B738_bank_angle_rot ~= B738DR_autopilot_bank_angle_pos then
			B738DR_autopilot_bank_angle_pos = B738_bank_angle_rot
		end
	end
	bank_angle_old = B738_bank_angle_rot
	
	-- AUTOTHROTTLE ARM
	if at_arm_old ~= B738_at_arm_switch then
		if B738_at_arm_switch ~= B738DR_autopilot_autothr_arm_pos then
			if B738_at_arm_switch == 0 then
				B738CMD_autopilot_autothr_arm_toggle:once()
			else
				if at_arm_old_pos == 0  then	-- not auto disconnect
					B738CMD_autopilot_autothr_arm_toggle:once()
				end
			end
		else
			at_arm_old_pos = B738DR_autopilot_autothr_arm_pos
		end
	end
	at_arm_old = B738_at_arm_switch
	
	-- AUTOPILOT DISCONNECT
	if ap_disc_old ~= B738_ap_disconnect_switch then
		if B738_ap_disconnect_switch ~= B738DR_autopilot_disconnect_pos then
			if B738_ap_disconnect_switch == 1 then
				B738CMD_autopilot_disconnect_toggle:once()
			else
				if ap_disc_old_pos == 1  then	-- not auto disconnect
					B738CMD_autopilot_disconnect_toggle:once()
				end
			end
		else
			ap_disc_old_pos = B738DR_autopilot_disconnect_pos
		end
	end
	ap_disc_old = B738_ap_disconnect_switch
	
	-- SPEED INTERVENTION
	if B738_spd_intv_butt ~= spd_intv_butt_old
	and B738_spd_intv_butt == 1 then
		B738CMD_autopilot_spd_interv:once()
	end
	spd_intv_butt_old = B738_spd_intv_butt
	
	-- ALT INTERVENTION
	if B738_alt_intv_butt ~= alt_intv_butt_old
	and B738_alt_intv_butt == 1 then
		B738CMD_autopilot_alt_interv:once()
	end
	alt_intv_butt_old = B738_alt_intv_butt
	
end

function B738_land_gear()

	if B738_landing_gear == 0 then
		if B738DR_gear_handle_pos ~= 0 then
			B738CMD_gear_up:once()
		end
	elseif B738_landing_gear == 1 then
		if B738DR_gear_handle_pos ~= 0.5 then
			B738CMD_gear_off:once()
		end
	elseif B738_landing_gear == 2 then
		if B738DR_gear_handle_pos ~= 1 then
			B738CMD_gear_down:once()
		end
	end

end

function B738_apu_start_stop()

	if B738_apu_start_old ~= B738_apu_start then
		if B738_apu_start_old == 0 then
			if B738_apu_start == 1 then
				B738CMD_apu_starter_switch_up:once()
			elseif B738_apu_start == 2 then
				B738CMD_apu_starter_switch_up:once()
				B738CMD_apu_starter_switch_up:once()
			end
		elseif B738_apu_start_old == 1 then
			if B738_apu_start == 0 then
				B738CMD_apu_starter_switch_dn:once()
			elseif B738_apu_start == 2 then
				B738CMD_apu_starter_switch_up:once()
			end
		elseif B738_apu_start_old == 2 then
			if B738_apu_start == 1 then
				B738CMD_apu_starter_switch_dn:once()
			elseif B738_apu_start == 0 then
				B738CMD_apu_starter_switch_dn:once()
				B738CMD_apu_starter_switch_dn:once()
			end
		end
		B738_apu_start_old = B738_apu_start
	end

end

--function aircraft_load() end

function aircraft_unload() 
	
	simDR_throttle_override = 0
	simDR_joy_pitch_override = 0
	simDR_fdir_pitch_ovr = 0
	simDR_fdir_roll_ovr = 0
	simDR_fms_override = 0
	simDR_toe_brakes_ovr = 0
	simDR_steer_ovr = 0
	simDR_override_heading = 0
	simDR_override_pitch = 0
	simDR_override_roll = 0
	simDR_kill_map_fms = 0

end

function flight_start()

	if B738DR_gear_handle_pos == 0 then
		B738_landing_gear = 0
	elseif B738DR_gear_handle_pos == 0.5 then
		B738_landing_gear = 1
	elseif B738DR_gear_handle_pos == 1 then
		B738_landing_gear = 2
	end
	

end


--function flight_crash() end

--function before_physics() end

function after_physics()

	B738_ap_buttons()
	B738_land_gear()
	B738_apu_start_stop()


end

--function after_replay() end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



