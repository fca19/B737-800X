--[[
*****************************************************************************************
* Program Script Name	:	B738.glaresheild
*
* Author Name			:	Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2016-08-26	0.01a				Start of Dev
*
*
*
*
*****************************************************************************************
*         COPYRIGHT � 2016 JIM GREGORY / LAMINAR RESEARCH - ALL RIGHTS RESERVED
*****************************************************************************************
--]]


--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD - this contains the duration of the current frame in seconds (so it is alway a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.

IN_REPLAY - evaluates to 0 if replay is off, 1 if replay mode is on

--]]


--*************************************************************************************--

-- PFD SPEED MODES
PFD_SPD_ARM = 1
PFD_SPD_N1 = 2
PFD_SPD_MCP_SPD = 3
PFD_SPD_FMC_SPD = 4
PFD_SPD_GA = 5
PFD_SPD_THR_HLD = 6
PFD_SPD_RETARD = 7

-- PFD ROLL MODES
PFD_HDG_HDG_SEL = 1
PFD_HDG_VOR_LOC = 2
PFD_HDG_LNAV = 3
PFD_HDG_ROLLOUT = 4
PFD_HDG_FAC = 5

-- PFD PITCH MODES
PFD_ALT_VS = 1
PFD_ALT_MCP_SPD = 2
PFD_ALT_ALT_ACQ = 3
PFD_ALT_ALT_HOLD = 4
PFD_ALT_GS = 5
PFD_ALT_FLARE = 6
PFD_ALT_GP = 7
PFD_ALT_VNAV_SPD = 8
PFD_ALT_VNAV_PTH = 9
PFD_ALT_VNAV_ALT = 10
PFD_ALT_TO_GA = 11

-- PFD ROLL MODES ARM
PFD_HDG_VOR_LOC_ARM = 1
PFD_HDG_ROLLOUT_ARM = 2
PFD_HDG_LNAV_ARM = 3
PFD_HDG_FAC_ARM = 4

-- PFD PITCH MODES ARM
PFD_ALT_GS_ARM = 1
PFD_ALT_VS_ARM = 2
PFD_ALT_FLARE_ARM = 3
PFD_ALT_GP_ARM = 4
PFD_ALT_VNAV_ARM = 5
 
n1_correct = 
	{
	[0]     = {  5,  7},
	[5000]  = { 19, 16},
	[10000] = { 23, 18},
	[15000] = { 27, 20.5},
	[20000] = { 32, 25},
	[25000] = { 38, 30},
	[30000] = { 44, 35},
	[35000] = { 45, 40},
	[40000] = { 50, 44}
	}

eng1_N1_thrust = 0.97				-- engine 1 N1 THRUST = 97%
eng2_N1_thrust = 0.97			-- engine 2 N1 THRUST = 97%
N1_takeoff_thrust = 1.00		-- N1 TAKEOFF THRUST = 100%
N1_goaround_thrust = 1.00		-- N1 GOAROUND THRUST = 100%

fmc_speed_cur = 145.0

blink_rec_thr_status = 0
blink_rec_thr2_status = 0
blink_rec_hdg_status = 0
blink_rec_alt_status = 0
blink_rec_cmd_status1 = 0
blink_rec_cmd_status2 = 0
blink_rec_sch_status = 0
blink_rec_alt_alert_status = 0
blink_to_ga = 0
blink_out = 0

pfd_spd_old = 0
pfd_hdg_old = 0
pfd_alt_old = 0


autothrottle_pfd_old = 0
autothrottle_status_old = 0
retard_status_old = 0
n1_status_old = 0
fmc_spd_status_old = 0
alt_mode_status_old = 0
vnav_alt_status_old = 0
vnav_pth_status_old = 0
vnav_spd_status_old = 0
flare_status_old = 0
hdg_mode_status_old = 0
ga_pfd_old = 0
thr_hld_pfd_old = 0
to_ga_pfd_old = 0
alt_acq_pfd_old = 0
cmd_old1 = 0
cmd_old2 = 0
single_ch_status_old = 0

vvi_rate = 0

null_vvi = 0

ap_speed_mode = 0
ap_pitch_mode = 0
ap_roll_mode = 0
ap_pitch_mode_eng = 0
ap_roll_mode_eng = 0
ap_on = 0
ap_on_first = 0
at_on_first = 0
cws_on = 0
cws_on_first = 0
ap_disco_first = 0
ap_dis_time = 0
at_dis_time = 0
mem_airspeed_dial = 100
mem_speed_mode = 0
at_mode = 0
at_mode_eng = 0
ap_pitch_mode_old = 0
ap_roll_mode_old = 0
takeoff_n1 = 0
ap_goaround = 0
fd_goaround = 0
cmd_first = 0
simDR_ap_vvi_dial_cur = 0
simDR_ap_altitude_dial_ft_old = 0
ap_app_block = 0
ap_app_block_800 = 0
ils_test_enable = 0
ils_test_on = 0
ils_test_ok = 0
fd_cur = 0
--fd_target = 0
fd_target_rate = 0
flare_vvi_old = 0
ap_vnav_status = 0
vnav_descent = 0
vnav_active = 0
--vnav_active2 = 0
vnav_cruise = 0
vnav_altitude_dial = 0
--vnav_speed_dial = 200
--vnav_speed_dial2 = 0
vnav_thrust = 0
--vnav_block_thrust = 0
course_pilot = 0
to_after_80kts = 0
lift_off_150 = 0
on_ground_30 = 1
ap_goaround_block = 0
to_thrust_set = 0
ias_disagree = 0
alt_disagree = 0
vnav_speed_cur = 0
vnav_alt = 0
--vnav_speed = 0
vnav_speed_delta = 0
vnav_speed_trg_old = 0

eng1_N1_man = 0.984
eng2_N1_man = 0.984

eng1_N1_thrust_trg = 0
eng2_N1_thrust_trg = 0
eng1_N1_thrust_cur = 0
eng2_N1_thrust_cur = 0

at_throttle_hold = 0
init_climb = 0

baro_sel_old = 0
baro_sel_co_old = 0

lnav_app = 0
lnav_vorloc = 0
dme_dist = 0
dme_dist_old = 100

fmc_vvi_cur = 0
vvi_trg = 0

thrust1 = 0
thrust2 = 0
--ed_alt = 0
airspeed_pilot_old = 0
v_speed_pilot_old = 0
vdot_ratio_old = 0
nav_id_old = "*"
vnav_vs = 0
vnav_alt_hld = 0
altitude_dial_ft_old = 0

reverse_max_enable = 0
reverse_max_on = 0

radio_dh_pilot = 0
baro_dh_pilot = 0
baro_dh_pilot_disable = 0
radio_dh_copilot = 0
baro_dh_copilot = 0
baro_dh_copilot_disable = 0
--vnav_descent_disable = 0
--mcp_intv_speed = 0
dh_minimum_pilot = 0
dh_minimum_copilot = 0
dh_min_enable_pilot = 0
dh_min_enable_copilot = 0
dh_min_block_pilot = 0
dh_min_block_copilot = 0

vnav_init = 0
vnav_init2 = 0

vs_first = 0
vnav_alt_hold = 0
vnav_alt_hold_act = 0
vnav_engaged = 0
lnav_engaged = 0
--vnav_alt_mode = 0

thr1_target = 0
thr2_target = 0

roll_mode_old = 0
pitch_mode_old = 0
at_on_old = 0
ap_disco_do = 0

vnav_desc_spd = 0

fac_engaged = 0
rest_wpt_alt_idx_old = 0

dh_timer = 0
DH_STEP = 0.1	-- step 0.1 sec
dh_timer2 = 0
DH_STEP2 = 2.0	-- step 2.0 sec

axis_throttle_old = 0
axis_throttle1_old = 0
axis_throttle2_old = 0
lock_throttle = 0
ap_disco2 = 0

mcp_hdg_timer = 0

--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--

local autopilot_cmd_a_status = 0
local autopilot_cmd_b_status = 0
local autopilot_cws_a_status = 0
local autopilot_cws_b_status = 0

local autopilot_fms_nav_status = 0
-- = 0 in vorloc mode and 1 in lnav mode, buttons swap. Use this to determine NAV 1,2, FMS Selection logic

--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--

local alt_timer = 0
local alt_up_active = 0
local alt_dn_active = 0
local crs1_timer = 0
local crs1_up_active = 0
local crs1_dn_active = 0
local crs2_timer = 0
local crs2_up_active = 0
local crs2_dn_active = 0
local baro_pilot_timer = 0
local baro_pilot_up_active = 0
local baro_pilot_dn_active = 0
local baro_copilot_timer = 0
local baro_copilot_up_active = 0
local baro_copilot_dn_active = 0
local aircraft_was_on_air = 0
local bellow_400ft = 0

--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local altitude_dial_ft = 0
local yoke_pitch = 0
local yoke_pitch2 = 0
local vorloc_only = 0
local throttle = 0

--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_barometer_setting_capt 	= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot")
simDR_barometer_setting_fo		= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot")

--simDR_decision_height_capt		= find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_pilot")
--simDR_decision_height_fo		= find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_copilot")

simDR_map_mode_is_HSI			= find_dataref("sim/cockpit2/EFIS/map_mode_is_HSI")

simDR_vor1_capt					= find_dataref("sim/cockpit2/EFIS/EFIS_1_selection_pilot")
simDR_vor2_capt					= find_dataref("sim/cockpit2/EFIS/EFIS_2_selection_pilot")
simDR_vor1_fo					= find_dataref("sim/cockpit2/EFIS/EFIS_1_selection_copilot")
simDR_vor2_fo					= find_dataref("sim/cockpit2/EFIS/EFIS_2_selection_copilot")

simDR_efis_ndb					= find_dataref("sim/cockpit2/EFIS/EFIS_ndb_on")


----- AUTOPILOT DATAREFS

simDR_autothrottle_status		= find_dataref("sim/cockpit2/autopilot/autothrottle_on")
simDR_autopilot_altitude_mode	= find_dataref("sim/cockpit2/autopilot/altitude_mode")
simDR_autopilot_heading_mode	= find_dataref("sim/cockpit2/autopilot/heading_mode")

simDR_autopilot_approach		= find_dataref("sim/cockpit2/autopilot/approach_status")

simDR_servos_on					= find_dataref("sim/cockpit2/autopilot/servos_on")
simDR_bank_angle				= find_dataref("sim/cockpit2/autopilot/bank_angle_mode")
simDR_flight_dir_mode			= find_dataref("sim/cockpit2/autopilot/flight_director_mode")

simDR_approach_status			= find_dataref("sim/cockpit2/autopilot/approach_status")
simDR_glideslope_status			= find_dataref("sim/cockpit2/autopilot/glideslope_status")
simDR_roll_status				= find_dataref("sim/cockpit2/autopilot/roll_status")
simDR_alt_hold_status			= find_dataref("sim/cockpit2/autopilot/altitude_hold_status")
simDR_vvi_status				= find_dataref("sim/cockpit2/autopilot/vvi_status")

simDR_autopilot_source			= find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_pilot")
simDR_autopilot_fo_source		= find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_copilot")

simDR_autopilot_side			= find_dataref("sim/cockpit2/autopilot/autopilot_source")

simDR_nav_status				= find_dataref("sim/cockpit2/autopilot/nav_status")

simDR_autopilot_on				= find_dataref("sim/cockpit2/autopilot/autopilot_on")

simDR_ap_capt_heading			= find_dataref("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot")
simDR_ap_fo_heading				= find_dataref("sim/cockpit2/autopilot/heading_dial_deg_mag_copilot")

simDR_airspeed_dial				= find_dataref("sim/cockpit2/autopilot/airspeed_dial_kts_mach")
simDR_airspeed_dial_kts			= find_dataref("sim/cockpit2/autopilot/airspeed_dial_kts")

-- 0 for NAV1, 1 for NAV2, 2 for FMS/GPS

simDR_EFIS_mode					= find_dataref("sim/cockpit2/EFIS/map_mode")
simDR_EFIS_WX					= find_dataref("sim/cockpit2/EFIS/EFIS_weather_on")
simDR_EFIS_TCAS					= find_dataref("sim/cockpit2/EFIS/EFIS_tcas_on")


simDR_ap_altitude_dial_ft		= find_dataref("sim/cockpit2/autopilot/altitude_dial_ft")
simDR_ap_vvi_dial				= find_dataref("sim/cockpit2/autopilot/vvi_dial_fpm")

---- CUSTOM
simDR_radio_height_pilot_ft		= find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
simDR_radio_height_copilot_ft	= find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_copilot")
simDR_throttle_all				= find_dataref("sim/cockpit2/engine/actuators/throttle_ratio_all")
simDR_yoke_pitch				= find_dataref("sim/cockpit2/controls/yoke_pitch_ratio")
simDR_aircraft_on_ground		= find_dataref("sim/flightmodel/failures/onground_all")
simDR_on_ground_0				= find_dataref("sim/flightmodel2/gear/on_ground[0]")
simDR_on_ground_1				= find_dataref("sim/flightmodel2/gear/on_ground[1]")
simDR_on_ground_2				= find_dataref("sim/flightmodel2/gear/on_ground[2]")
simDR_vvi_fpm_pilot				= find_dataref("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
simDR_vvi_fpm_copilot			= find_dataref("sim/cockpit2/gauges/indicators/vvi_fpm_copilot")
simDR_elevator_trim				= find_dataref("sim/cockpit2/controls/elevator_trim")

simDR_nav1 						= find_dataref("sim/cockpit2/radios/actuators/nav1_frequency_hz")
simDR_nav2 						= find_dataref("sim/cockpit2/radios/actuators/nav2_frequency_hz")
simDR_hsi_crs1					= find_dataref("sim/cockpit2/radios/actuators/hsi_obs_deg_mag_pilot")
simDR_hsi_crs2					= find_dataref("sim/cockpit2/radios/actuators/hsi_obs_deg_mag_copilot")
simDR_crs1						= find_dataref("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot")
simDR_crs2						= find_dataref("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_copilot")
simDR_crs1_nav2					= find_dataref("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot")
simDR_crs2_nav2					= find_dataref("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_copilot")
simDR_brake						= find_dataref("sim/cockpit2/controls/parking_brake_ratio")
simDR_autobrake_level			= find_dataref("sim/cockpit2/switches/auto_brake_level")
simDR_airspeed_pilot			= find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
simDR_altitude_pilot			= find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
simDR_airspeed_copilot			= find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_copilot")
simDR_altitude_copilot			= find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_copilot")


simDR_hnav_armed				= find_dataref("sim/cockpit2/autopilot/hnav_armed")

--simDR_autothrottle_enable		= find_dataref("sim/cockpit2/autopilot/autothrottle_enabled")

simDR_airspeed_is_mach			= find_dataref("sim/cockpit2/autopilot/airspeed_is_mach")
simDR_mach_no					= find_dataref("sim/flightmodel/misc/machno")

simDR_nav1_hdef_pilot			= find_dataref("sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot")
simDR_nav1_vdef_pilot			= find_dataref("sim/cockpit2/radios/indicators/nav1_vdef_dots_pilot")
simDR_nav2_hdef_pilot			= find_dataref("sim/cockpit2/radios/indicators/nav2_hdef_dots_pilot")
simDR_nav2_vdef_pilot			= find_dataref("sim/cockpit2/radios/indicators/nav2_vdef_dots_pilot")

simDR_nav1_hdef_copilot			= find_dataref("sim/cockpit2/radios/indicators/nav1_hdef_dots_copilot")
simDR_nav1_vdef_copilot			= find_dataref("sim/cockpit2/radios/indicators/nav1_vdef_dots_copilot")
simDR_nav2_hdef_copilot			= find_dataref("sim/cockpit2/radios/indicators/nav2_hdef_dots_copilot")
simDR_nav2_vdef_copilot			= find_dataref("sim/cockpit2/radios/indicators/nav2_vdef_dots_copilot")

simDR_engine_N1_pct1			= find_dataref("sim/cockpit2/engine/indicators/N1_percent[0]")
simDR_engine_N1_pct2			= find_dataref("sim/cockpit2/engine/indicators/N1_percent[1]")

simDR_throttle_1				= find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[0]")
simDR_throttle_2				= find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[1]")
simDR_throttle_override			= find_dataref("sim/operation/override/override_throttles")
simDR_throttle1_use				= find_dataref("sim/flightmodel/engine/ENGN_thro_use[0]")
simDR_throttle2_use				= find_dataref("sim/flightmodel/engine/ENGN_thro_use[1]")
simDR_joy_pitch_override		= find_dataref("sim/operation/override/override_joystick_pitch")

simDR_autothrottle_enable		= find_dataref("sim/cockpit2/autopilot/autothrottle_enabled")

simDR_heading_pilot				= find_dataref("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
simDR_flaps_ratio				= find_dataref("sim/cockpit2/controls/flap_handle_deploy_ratio")
--simDR_flaps_ratio				= find_dataref("sim/flightmodel2/controls/flap1_deploy_ratio")

simDR_fdir_pitch_ovr			= find_dataref("sim/operation/override/override_flightdir_ptch")
simDR_fdir_roll_ovr				= find_dataref("sim/operation/override/override_flightdir_roll")
simDR_fdir_pitch				= find_dataref("sim/cockpit/autopilot/flight_director_pitch")
simDR_fdir_roll					= find_dataref("sim/cockpit/autopilot/flight_director_roll")
simDR_ahars_pitch_deg_pilot		= find_dataref("sim/cockpit2/gauges/indicators/pitch_AHARS_deg_pilot")
simDR_ahars_pitch_deg_copilot	= find_dataref("sim/cockpit2/gauges/indicators/pitch_AHARS_deg_copilot")

simDR_total_weight				= find_dataref("sim/flightmodel/weight/m_total")

--simDR_eng1_reverser_on			= find_dataref("sim/cockpit2/annunciators/reverser_on[0]")
--simDR_eng2_reverser_on			= find_dataref("sim/cockpit2/annunciators/reverser_on[1]")

simDR_vnav_status				= find_dataref("sim/cockpit2/autopilot/fms_vnav")
simDR_vnav_tod_nm				= find_dataref("sim/cockpit2/radios/indicators/fms_distance_to_tod_pilot")
simDR_fms_fpta					= find_dataref("sim/cockpit2/radios/indicators/fms_fpta_pilot")
simDR_fms_vtk					= find_dataref("sim/cockpit2/radios/indicators/fms_vtk_pilot")
simDR_tod_before				= find_dataref("sim/cockpit2/radios/indicators/fms_tod_before_distance_pilot")
simDR_fms_override 				= find_dataref("sim/operation/override/override_fms_advance")

simDR_elevation_m				= find_dataref("sim/flightmodel/position/elevation")

simDR_efis_map_range			= find_dataref("sim/cockpit2/EFIS/map_range")
simDR_ground_spd				= find_dataref("sim/flightmodel/position/groundspeed")

simDR_reverse1_deploy			= find_dataref("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[0]")
simDR_reverse2_deploy			= find_dataref("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[1]")
simDR_engine_mixture1			= find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[0]")
simDR_engine_mixture2			= find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[1]")

simDR_vdot_nav1_pilot			= find_dataref("sim/cockpit2/radios/indicators/hsi_vdef_dots_pilot")
--simDR_vdot_nav1_pilot			= 999

--simDR_dme_dist				= find_dataref("sim/cockpit2/radios/indicators/gps_dme_distance_nm")
simDR_dme_dist					= find_dataref("laminar/B738/fms/lnav_dist_next")


simDR_nav1_bearing				= find_dataref("sim/cockpit2/radios/indicators/nav1_bearing_deg_mag")
simDR_nav1_hdispl				= find_dataref("sim/cockpit2/radios/indicators/nav1_display_horizontal")
simDR_nav2_bearing				= find_dataref("sim/cockpit2/radios/indicators/nav2_bearing_deg_mag")
simDR_nav2_hdispl				= find_dataref("sim/cockpit2/radios/indicators/nav2_display_horizontal")
simDR_nav1_course_pilot			= find_dataref("sim/cockpit2/radios/actuators/nav1_course_deg_mag_pilot")
simDR_nav2_course_pilot			= find_dataref("sim/cockpit2/radios/actuators/nav2_course_deg_mag_pilot")
simDR_nav1_course_copilot		= find_dataref("sim/cockpit2/radios/actuators/nav1_course_deg_mag_copilot")
simDR_nav2_course_copilot		= find_dataref("sim/cockpit2/radios/actuators/nav2_course_deg_mag_copilot")

simDR_glideslope_armed			= find_dataref("sim/cockpit2/autopilot/glideslope_armed")
simDR_gps_nav_id				= find_dataref("sim/cockpit2/radios/indicators/gps_nav_id")

simDR_reverse1_act				= find_dataref("sim/cockpit2/engine/actuators/prop_mode[0]")
simDR_reverse2_act				= find_dataref("sim/cockpit2/engine/actuators/prop_mode[1]")

simDR_mag_hdg					= find_dataref("sim/cockpit2/gauges/indicators/ground_track_mag_pilot")
simDR_vor1_id					= find_dataref("sim/cockpit2/radios/indicators/nav1_nav_id")
simDR_nav1_dme					= find_dataref("sim/cockpit2/radios/indicators/nav1_dme_distance_nm")
simDR_nav1_has_dme				= find_dataref("sim/cockpit2/radios/indicators/nav1_has_dme")
simDR_nav1_type					= find_dataref("sim/cockpit2/radios/indicators/nav1_type")

simDR_vor2_id					= find_dataref("sim/cockpit2/radios/indicators/nav2_nav_id")
simDR_nav2_dme					= find_dataref("sim/cockpit2/radios/indicators/nav2_dme_distance_nm")
simDR_nav2_has_dme				= find_dataref("sim/cockpit2/radios/indicators/nav2_has_dme")
simDR_nav2_type					= find_dataref("sim/cockpit2/radios/indicators/nav2_type")

simDR_dh_pilot					= find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_pilot")
simDR_dh_copilot				= find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_copilot")

simDR_ahars_mag_hdg		= find_dataref("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
simDR_mag_variation		= find_dataref("sim/flightmodel/position/magnetic_variation")


simDR_efis_map_mode		= find_dataref("sim/cockpit/switches/EFIS_map_mode")
simDR_efis_sub_mode		= find_dataref("sim/cockpit/switches/EFIS_map_submode")

simDR_efis_vor_on		= find_dataref("sim/cockpit2/EFIS/EFIS_vor_on")
simDR_efis_apt_on		= find_dataref("sim/cockpit2/EFIS/EFIS_airport_on")
simDR_efis_fix_on		= find_dataref("sim/cockpit2/EFIS/EFIS_fix_on")
simDR_efis_wxr_on		= find_dataref("sim/cockpit2/EFIS/EFIS_weather_on")

--- VNAV
--td_dist						= find_dataref("laminar/B738/fms/td_dist")
B738DR_vnav_td_dist 		= find_dataref("laminar/B738/fms/vnav_td_dist")
B738DR_vnav_pth_alt			= find_dataref("laminar/B738/fms/vnav_pth_alt")
B738DR_vnav_alt_err			= find_dataref("laminar/B738/fms/vnav_alt_err")
B738DR_vnav_vvi				= find_dataref("laminar/B738/fms/vnav_vvi")
B738DR_vnav_vvi_corr		= find_dataref("laminar/B738/fms/vnav_vvi_corr")
B738DR_vnav_err_pfd			= find_dataref("laminar/B738/fms/vnav_err_pfd")

B738DR_gp_vvi			= find_dataref("laminar/B738/fms/gp_vvi")
B738DR_gp_vvi_corr		= find_dataref("laminar/B738/fms/gp_vvi_corr")
B738DR_gp_err_pfd		= find_dataref("laminar/B738/fms/gp_err_pfd")

td_fix_dist 				= find_dataref("laminar/B738/fms/vnav_td_fix_dist")

B738DR_rnav_enable			= find_dataref("laminar/B738/fms/rnav_enable")
B738DR_gp_active			= find_dataref("laminar/B738/fms/vnav_gp_active")

B738DR_end_route			= find_dataref("laminar/B738/fms/end_route")
B738DR_no_perf				= find_dataref("laminar/B738/fms/no_perf")

B738DR_vnav_desc_spd_disable = find_dataref("laminar/B738/fms/vnav_desc_spd_disable")


simDR_wind_hdg				= find_dataref("sim/cockpit2/gauges/indicators/wind_heading_deg_mag")
simDR_wind_spd				= find_dataref("sim/cockpit2/gauges/indicators/wind_speed_kts")

simDR_fmc_crs				= find_dataref("laminar/B738/fms/gps_course_degtm")
simDR_fmc_trk				= find_dataref("laminar/B738/fms/gps_track_degtm")
simDR_TAS					= find_dataref("sim/flightmodel/position/true_airspeed")


--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_efis_wxr = find_command("sim/instruments/EFIS_wxr")
simCMD_efis_sta = find_command("sim/instruments/EFIS_vor")
simCMD_efis_wpt = find_command("sim/instruments/EFIS_fix")
simCMD_efis_arpt = find_command("sim/instruments/EFIS_apt")
simCMD_efis_tfc = find_command("sim/instruments/EFIS_tcas")

---- AUTOPILOT COMMANDS

simCMD_autothrottle			= find_command("sim/autopilot/autothrottle_toggle")
simCMD_autothrottle_on		= find_command("sim/autopilot/autothrottle_on")
simCMD_autothrottle_off		= find_command("sim/autopilot/autothrottle_off")

simCMD_autopilot_vnav		= find_command("sim/autopilot/FMS")
simCMD_autopilot_lvl_chg	= find_command("sim/autopilot/level_change")
simCMD_autopilot_hdg		= find_command("sim/autopilot/heading")
simCMD_autopilot_lnav		= find_command("sim/autopilot/NAV")
simCMD_autopilot_app		= find_command("sim/autopilot/approach")
simCMD_autopilot_alt_hold	= find_command("sim/autopilot/altitude_hold")
simCMD_autopilot_vs			= find_command("sim/autopilot/vertical_speed")
simCMD_autopilot_vs_sel		= find_command("sim/autopilot/vertical_speed_pre_sel")

simCMD_autopilot_fd			= find_command("sim/autopilot/fdir_toggle")
simCMD_autopilot_servos		= find_command("sim/autopilot/servos_toggle")
simCMD_autopilot_cws		= find_command("sim/autopilot/control_wheel_steer")

simCMD_disconnect			= find_command("sim/autopilot/servos_fdir_off")

simCMD_autopilot_co			= find_command("sim/autopilot/knots_mach_toggle")
simCMD_flight_director		= find_command("sim/autopilot/fdir_on")
simCMD_autothrottle_discon	= find_command("sim/autopilot/autothrottle_off")

simCMD_source_nav1			= find_command("sim/autopilot/hsi_select_nav_1")
simCMD_source_nav2			= find_command("sim/autopilot/hsi_select_nav_2")
simCDM_source_FMS			= find_command("sim/autopilot/hsi_select_gps")

simCMD_source_fo_nav1		= find_command("sim/autopilot/hsi_select_copilot_nav_1")
simCMD_source_fo_nav2		= find_command("sim/autopilot/hsi_select_copilot_nav_2")
simCDM_source_fo_FMS		= find_command("sim/autopilot/hsi_select_copilot_gps")

simCMD_servos_on			= find_command("sim/autopilot/servos_on")
--simCMD_take_off_go_around	= find_command("sim/autopilot/take_off_go_around")
--simCMD_autopilot_up			= find_command("sim/autopilot/override_up")
--simCMD_autopilot_dn			= find_command("sim/autopilot/override_down")

simCMD_fdir_up				= find_command("sim/autopilot/fdir_servos_up_one")
simCMD_fdir_dn				= find_command("sim/autopilot/fdir_servos_down_one")

simCMD_nosmoking_toggle		= find_command("sim/systems/no_smoking_toggle")

simCMD_FMS_key_1L		= find_command("sim/FMS/ls_1l")
simCMD_FMS_key_2L		= find_command("sim/FMS/ls_2l")
simCMD_FMS_key_dir_intc	= find_command("sim/FMS/dir_intc")
simCMD_FMS_key_legs		= find_command("sim/FMS/legs")
simCMD_FMS_key_fpln		= find_command("sim/FMS/fpln")
simCMD_FMS_key_clear	= find_command("sim/FMS/key_clear")
simCMD_FMS_key_delete	= find_command("sim/FMS/key_delete")
simCMD_FMS_key_exec		= find_command("sim/FMS/exec")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

B738DR_autobrake_RTO_arm	= find_dataref("laminar/B738/autobrake/autobrake_RTO_arm")
B738DR_autobrake_pos		= find_dataref("laminar/B738/autobrake/autobrake_pos")
B738DR_autobrake_RTO_test	= find_dataref("laminar/B738/autobrake/autobrake_RTO_test")

B738DR_fms_v2_15			= find_dataref("laminar/B738/FMS/v2_15")
--B738DR_pfd_flaps_bug		= find_dataref("laminar/B738/pfd/flaps_bug")

B738DR_fms_vref				= find_dataref("laminar/B738/FMS/vref")
B738DR_fms_vref_15			= find_dataref("laminar/B738/FMS/vref_15")
B738DR_fms_vref_25			= find_dataref("laminar/B738/FMS/vref_25")
B738DR_fms_vref_30			= find_dataref("laminar/B738/FMS/vref_30")
B738DR_fms_vref_40			= find_dataref("laminar/B738/FMS/vref_40")

B738DR_fms_N1_mode			= find_dataref("laminar/B738/FMS/N1_mode")
B738DR_fms_N1_thrust		= find_dataref("laminar/B738/FMS/N1_mode_thrust")

B738DR_flight_phase			= find_dataref("laminar/B738/FMS/flight_phase")

--B738DR_idle_thrust 			= find_dataref("laminar/B738/engine/idle_thrust")

B738DR_trans_alt			= find_dataref("laminar/B738/FMS/fmc_trans_alt")
B738DR_trans_lvl			= find_dataref("laminar/B738/FMS/fmc_trans_lvl")

B738DR_fms_descent_now		= find_dataref("laminar/B738/FMS/descent_now")
B738DR_thr_red_alt			= find_dataref("laminar/B738/FMS/throttle_red_alt")
B738DR_accel_alt			= find_dataref("laminar/B738/FMS/accel_height")

B738DR_fms_ils_disable		= find_dataref("laminar/B738/FMS/ils_disable")

B738DR_rest_wpt_spd_id 		= find_dataref("laminar/B738/fms/rest_wpt_spd_id")
B738DR_rest_wpt_spd 		= find_dataref("laminar/B738/fms/rest_wpt_spd")
B738DR_rest_wpt_alt_id 		= find_dataref("laminar/B738/fms/rest_wpt_alt_id")
B738DR_rest_wpt_alt 		= find_dataref("laminar/B738/fms/rest_wpt_alt")
B738DR_rest_wpt_alt_t 		= find_dataref("laminar/B738/fms/rest_wpt_alt_t")
B738DR_calc_wpt_spd 		= find_dataref("laminar/B738/fms/calc_wpt_spd")
B738DR_calc_wpt_alt 		= find_dataref("laminar/B738/fms/calc_wpt_alt")

--ed_alt_fms					= find_dataref("laminar/B738/fms/ed_alt")

vnav_idx					= find_dataref("laminar/B738/fms/vnav_idx")
td_idx 						= find_dataref("laminar/B738/fms/vnav_td_idx")
ed_alt						= find_dataref("laminar/B738/fms/ed_alt")

B738DR_irs_left_mode		= find_dataref("laminar/B738/irs/irs_mode")
B738DR_irs_right_mode		= find_dataref("laminar/B738/irs/irs2_mode")

-- B738DR_minim_fo = 			find_dataref("laminar/B738/EFIS_control/fo/minimums")
-- B738DR_minim_capt = 		find_dataref("laminar/B738/EFIS_control/cpt/minimums")

B738DR_lock_idle_thrust		= find_dataref("laminar/B738/fms/lock_idle_thrust")

B738DR_pfd_flaps_1			= find_dataref("laminar/B738/pfd/flaps_1")
B738DR_pfd_flaps_2			= find_dataref("laminar/B738/pfd/flaps_2")
B738DR_pfd_flaps_5			= find_dataref("laminar/B738/pfd/flaps_5")
B738DR_pfd_flaps_10			= find_dataref("laminar/B738/pfd/flaps_10")
B738DR_pfd_flaps_15			= find_dataref("laminar/B738/pfd/flaps_15")

B738DR_vnav_disconnect		= find_dataref("laminar/B738/fms/vnav_disconnect")
B738DR_lnav_disconnect		= find_dataref("laminar/B738/fms/lnav_disconnect")
decel_idx					= find_dataref("laminar/B738/fms/vnav_decel_idx")
decel_dist					= find_dataref("laminar/B738/fms/vnav_decel_dist")

B738DR_autopilot_pfd_mode		= find_dataref("laminar/B738/autopilot/pfd_mode")
B738DR_autopilot_pfd_mode_fo	= find_dataref("laminar/B738/autopilot/pfd_mode_fo")

B738DR_pfd_vert_path		= find_dataref("laminar/B738/pfd/pfd_vert_path")
B738DR_pfd_vert_path_fo		= find_dataref("laminar/B738/pfd/pfd_vert_path_fo")

B738DR_rest_wpt_alt_idx		= find_dataref("laminar/B738/fms/rest_wpt_alt_idx")

B738DR_hyd_A_status			= find_dataref("laminar/B738/hydraulic/A_status")
B738DR_hyd_B_status			= find_dataref("laminar/B738/hydraulic/B_status")

B738DR_throttle_noise		= find_dataref("laminar/B738/fms/throttle_noise")

B738DR_joy_axis_throttle	= find_dataref("laminar/B738/axis/throttle")
B738DR_joy_axis_throttle1	= find_dataref("laminar/B738/axis/throttle1")
B738DR_joy_axis_throttle2	= find_dataref("laminar/B738/axis/throttle2")

--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

-- CAPT EFIS DATAREFS

B738DR_efis_wxr_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/wxr", "number")
B738DR_efis_sta_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/sta", "number")
B738DR_efis_wpt_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/wpt", "number")
B738DR_efis_arpt_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/arpt", "number")
B738DR_efis_data_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/data", "number")
B738DR_efis_pos_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/pos", "number")
B738DR_efis_terr_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/terr", "number")

--B738DR_efis_map_range_capt 		= create_dataref("laminar/B738/EFIS/capt/map_range", "number")
--B738DR_map_mode_capt			= create_dataref("laminar/B738/EFIS_control/capt/map_mode_pos", "number")

B738DR_efis_data_capt_status	= create_dataref("laminar/B738/EFIS/capt/data_status", "number")


B738DR_efis_rst_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/rst", "number")
B738DR_efis_ctr_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/ctr", "number")
B738DR_efis_tfc_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/tfc", "number")
B738DR_efis_std_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/std", "number")

B738DR_efis_vor_on		= create_dataref("laminar/B738/EFIS/EFIS_vor_on", "number")
B738DR_efis_apt_on		= create_dataref("laminar/B738/EFIS/EFIS_airport_on", "number")
B738DR_efis_fix_on		= create_dataref("laminar/B738/EFIS/EFIS_fix_on", "number")


---
B738DR_baro_set_std_pilot		= create_dataref("laminar/B738/EFIS/baro_set_std_pilot", "number")
B738DR_baro_sel_in_hg_pilot		= create_dataref("laminar/B738/EFIS/baro_sel_in_hg_pilot", "number")
B738DR_baro_sel_pilot_show		= create_dataref("laminar/B738/EFIS/baro_sel_pilot_show", "number")
B738DR_baro_box_pilot_show		= create_dataref("laminar/B738/EFIS/baro_box_pilot_show", "number")
B738DR_baro_std_box_pilot_show	= create_dataref("laminar/B738/EFIS/baro_std_box_pilot_show", "number")
---

B738DR_efis_mtrs_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/mtrs", "number")
B738DR_efis_fpv_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/fpv", "number")

B738DR_efis_baro_mode_capt	= create_dataref("laminar/B738/EFIS_control/capt/baro_in_hpa", "number")
B738DR_efis_vor1_capt_pos	= create_dataref("laminar/B738/EFIS_control/capt/vor1_off_pos", "number")
B738DR_efis_vor2_capt_pos	= create_dataref("laminar/B738/EFIS_control/capt/vor2_off_pos", "number")

B738DR_capt_alt_mode_meters		= create_dataref("laminar/B738/PFD/capt/alt_mode_is_meters", "number")
B738DR_capt_fpv_on				= create_dataref("laminar/B738/PFD/capt/fpv_on", "number")


-- FO EFIS DATAREFS

B738DR_efis_wxr_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/wxr", "number")
B738DR_efis_sta_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/sta", "number")
B738DR_efis_wpt_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/wpt", "number")
B738DR_efis_arpt_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/arpt", "number")
B738DR_efis_data_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/data", "number")
B738DR_efis_pos_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/pos", "number")
B738DR_efis_terr_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/terr", "number")

B738DR_efis_data_fo_status	= create_dataref("laminar/B738/EFIS/fo/data_status", "number")

B738DR_efis_rst_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/rst", "number")
B738DR_efis_ctr_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/ctr", "number")
B738DR_efis_tfc_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/tfc", "number")
B738DR_efis_std_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/std", "number")

B738DR_efis_fo_vor_on		= create_dataref("laminar/B738/EFIS/fo/EFIS_vor_on", "number")
B738DR_efis_fo_apt_on		= create_dataref("laminar/B738/EFIS/fo/EFIS_airport_on", "number")
B738DR_efis_fo_fix_on		= create_dataref("laminar/B738/EFIS/fo/EFIS_fix_on", "number")

---
B738DR_baro_set_std_copilot			= create_dataref("laminar/B738/EFIS/baro_set_std_copilot", "number")
B738DR_baro_sel_in_hg_copilot		= create_dataref("laminar/B738/EFIS/baro_sel_in_hg_copilot", "number")
B738DR_baro_sel_copilot_show		= create_dataref("laminar/B738/EFIS/baro_sel_copilot_show", "number")
B738DR_baro_box_copilot_show		= create_dataref("laminar/B738/EFIS/baro_box_copilot_show", "number")
B738DR_baro_std_box_copilot_show	= create_dataref("laminar/B738/EFIS/baro_std_box_copilot_show", "number")
---

B738DR_efis_mtrs_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/mtrs", "number")
B738DR_efis_fpv_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/fpv", "number")

B738DR_efis_baro_mode_fo	= create_dataref("laminar/B738/EFIS_control/fo/baro_in_hpa", "number")
B738DR_efis_vor1_fo_pos		= create_dataref("laminar/B738/EFIS_control/fo/vor1_off_pos", "number")
B738DR_efis_vor2_fo_pos		= create_dataref("laminar/B738/EFIS_control/fo/vor2_off_pos", "number")

--B738DR_efis_map_range_fo 		= create_dataref("laminar/B738/EFIS/fo/map_range", "number")

B738DR_fo_alt_mode_meters		= create_dataref("laminar/B738/PFD/fo/alt_mode_is_meters", "number")
B738DR_fo_fpv_on				= create_dataref("laminar/B738/PFD/fo/fpv_on", "number")

--B738DR_map_mode_fo			= create_dataref("laminar/B738/EFIS_control/fo/map_mode_pos", "number")

-- AP BUTTON / SWITCH POSITION DRS

B738DR_autopilot_n1_pos				= create_dataref("laminar/B738/autopilot/n1_pos", "number")
B738DR_autopilot_speed_pos			= create_dataref("laminar/B738/autopilot/speed_pos", "number")
B738DR_autopilot_lvl_chg_pos		= create_dataref("laminar/B738/autopilot/lvl_chg_pos", "number")
B738DR_autopilot_vnav_pos			= create_dataref("laminar/B738/autopilot/vnav_pos", "number")
B738DR_autopilot_co_pos				= create_dataref("laminar/B738/autopilot/change_over_pos", "number")
	
B738DR_autopilot_lnav_pos			= create_dataref("laminar/B738/autopilot/lnav_pos", "number")
B738DR_autopilot_vorloc_pos			= create_dataref("laminar/B738/autopilot/vorloc_pos", "number")
B738DR_autopilot_app_pos			= create_dataref("laminar/B738/autopilot/app_pos", "number")
B738DR_autopilot_hdg_sel_pos		= create_dataref("laminar/B738/autopilot/hdg_sel_pos", "number")

B738DR_autopilot_alt_hld_pos		= create_dataref("laminar/B738/autopilot/alt_hld_pos", "number")
B738DR_autopilot_vs_pos				= create_dataref("laminar/B738/autopilot/vs_pos", "number")

B738DR_autopilot_cmd_a_pos			= create_dataref("laminar/B738/autopilot/cmd_a_pos", "number")
B738DR_autopilot_cmd_b_pos			= create_dataref("laminar/B738/autopilot/cmd_b_pos", "number")
B738DR_autopilot_cws_a_pos			= create_dataref("laminar/B738/autopilot/cws_a_pos", "number")
B738DR_autopilot_cws_b_pos			= create_dataref("laminar/B738/autopilot/cws_b_pos", "number")
B738DR_autopilot_disconnect_pos		= create_dataref("laminar/B738/autopilot/disconnect_pos", "number")
B738DR_autopilot_disco2				= create_dataref("laminar/B738/autopilot/disconnect_button", "number")

B738DR_autopilot_fd_pos				= create_dataref("laminar/B738/autopilot/flight_director_pos", "number")
B738DR_autopilot_fd_fo_pos			= create_dataref("laminar/B738/autopilot/flight_director_fo_pos", "number")
B738DR_autopilot_bank_angle_pos		= create_dataref("laminar/B738/autopilot/bank_angle_pos", "number")
B738DR_autopilot_autothr_arm_pos	= create_dataref("laminar/B738/autopilot/autothrottle_arm_pos", "number")


-- AP STATUS LIGHT DRS

B738DR_autopilot_n1_status				= create_dataref("laminar/B738/autopilot/n1_status", "number")
B738DR_autopilot_speed_status			= create_dataref("laminar/B738/autopilot/speed_status1", "number")
B738DR_autopilot_lvl_chg_status			= create_dataref("laminar/B738/autopilot/lvl_chg_status", "number")
B738DR_autopilot_vnav_status			= create_dataref("laminar/B738/autopilot/vnav_status1", "number")
	
B738DR_autopilot_lnav_status			= create_dataref("laminar/B738/autopilot/lnav_status", "number")
B738DR_autopilot_vorloc_status			= create_dataref("laminar/B738/autopilot/vorloc_status", "number")
B738DR_autopilot_app_status				= create_dataref("laminar/B738/autopilot/app_status", "number")
B738DR_autopilot_hdg_sel_status			= create_dataref("laminar/B738/autopilot/hdg_sel_status", "number")

B738DR_autopilot_alt_hld_status			= create_dataref("laminar/B738/autopilot/alt_hld_status", "number")
B738DR_autopilot_vs_status				= create_dataref("laminar/B738/autopilot/vs_status", "number")

B738DR_autopilot_cmd_a_status			= create_dataref("laminar/B738/autopilot/cmd_a_status", "number")
B738DR_autopilot_cmd_b_status			= create_dataref("laminar/B738/autopilot/cmd_b_status", "number")
B738DR_autopilot_cws_a_status			= create_dataref("laminar/B738/autopilot/cws_a_status", "number")
B738DR_autopilot_cws_b_status			= create_dataref("laminar/B738/autopilot/cws_b_status", "number")

B738DR_autopilot_autothrottle_status	= create_dataref("laminar/B738/autopilot/autothrottle_status", "number")
B738DR_autopilot_master_capt_status		= create_dataref("laminar/B738/autopilot/master_capt_status", "number")
B738DR_autopilot_master_fo_status		= create_dataref("laminar/B738/autopilot/master_fo_status", "number")

B738DR_autopilot_vhf_source_pos			= create_dataref("laminar/B738/toggle_switch/vhf_nav_source", "number")

B738DR_flare_status						= create_dataref("laminar/B738/autopilot/flare_status", "number")
B738DR_autoland_status					= create_dataref("laminar/B738/autopilot/autoland_status", "number")
B738DR_retard_status					= create_dataref("laminar/B738/autopilot/retard_status", "number")
B738DR_single_ch_status					= create_dataref("laminar/B738/autopilot/single_ch_status", "number")
B738DR_ils_pointer_disable				= create_dataref("laminar/B738/autopilot/ils_pointer_disable", "number")
--



B738DR_autopilot_autothrottle_on		= create_dataref("laminar/B738/autopilot/autothrottle_on_pfd", "number")
B738DR_autopilot_autothrottle_pfd		= create_dataref("laminar/B738/autopilot/autothrottle_pfd", "number")
B738DR_autopilot_n1_pfd					= create_dataref("laminar/B738/autopilot/n1_pfd", "number")
B738DR_autopilot_ga_pfd					= create_dataref("laminar/B738/autopilot/ga_pfd", "number")
B738DR_autopilot_thr_hld_pfd			= create_dataref("laminar/B738/autopilot/thr_hld_pfd", "number")
B738DR_autopilot_to_ga_pfd				= create_dataref("laminar/B738/autopilot/to_ga_pfd", "number")
B738DR_autopilot_alt_acq_pfd			= create_dataref("laminar/B738/autopilot/alt_acq_pfd", "number")

B738DR_autopilot_fmc_spd_pfd			= create_dataref("laminar/B738/autopilot/fmc_spd_pfd", "number")
B738DR_autopilot_vnav_alt_pfd			= create_dataref("laminar/B738/autopilot/vnav_alt_pfd", "number")
B738DR_autopilot_vnav_pth_pfd			= create_dataref("laminar/B738/autopilot/vnav_pth_pfd", "number")
B738DR_autopilot_vnav_spd_pfd			= create_dataref("laminar/B738/autopilot/vnav_spd_pfd", "number")
B738DR_autopilot_hnav_armed				= create_dataref("laminar/B738/autopilot/hnav_armed", "number")
B738DR_autopilot_alt_mode_pfd			= create_dataref("laminar/B738/autopilot/alt_mode_pfd", "number")
B738DR_autopilot_hdg_mode_pfd			= create_dataref("laminar/B738/autopilot/hdg_mode_pfd", "number")
B738DR_autopilot_vnav_arm_pfd			= create_dataref("laminar/B738/autopilot/vnav_arm_pfd", "number")

B738DR_autopilot_gs_armed				= create_dataref("laminar/B738/autopilot/gs_armed_pfd", "number")

-- AUTOPILOT PFD ANNUNCIATES --
B738DR_pfd_spd_mode						= create_dataref("laminar/B738/autopilot/pfd_spd_mode", "number")
B738DR_pfd_hdg_mode						= create_dataref("laminar/B738/autopilot/pfd_hdg_mode", "number")
B738DR_pfd_alt_mode						= create_dataref("laminar/B738/autopilot/pfd_alt_mode", "number")
B738DR_pfd_hdg_mode_arm					= create_dataref("laminar/B738/autopilot/pfd_hdg_mode_arm", "number")
B738DR_pfd_alt_mode_arm					= create_dataref("laminar/B738/autopilot/pfd_alt_mode_arm", "number")


B738DR_rec_thr_modes					= create_dataref("laminar/B738/autopilot/rec_thr_modes", "number")
B738DR_rec_thr2_modes					= create_dataref("laminar/B738/autopilot/rec_thr2_modes", "number")
B738DR_rec_hdg_modes					= create_dataref("laminar/B738/autopilot/rec_hdg_modes", "number")
B738DR_rec_alt_modes					= create_dataref("laminar/B738/autopilot/rec_alt_modes", "number")
B738DR_rec_cmd_modes1					= create_dataref("laminar/B738/autopilot/rec_cmd_modes", "number")
B738DR_rec_cmd_modes2					= create_dataref("laminar/B738/autopilot/rec_cmd_modes_fo", "number")
B738DR_rec_sch_modes					= create_dataref("laminar/B738/autopilot/rec_sch_modes", "number")
B738DR_rec_alt_alert					= create_dataref("laminar/B738/autopilot/rec_alt_alert", "number")
------------------------------

B738DR_lvl_chg_mode						= create_dataref("laminar/B738/autopilot/lvl_chg_mode", "number")
B738DR_show_ias							= create_dataref("laminar/B738/autopilot/show_ias", "number")


DRblink									= create_dataref("laminar/B738/autopilot/blink", "number")


B738DR_kts_disable						= create_dataref("laminar/B738/autopilot/kts_disable", "number")
B738DR_mach_disable						= create_dataref("laminar/B738/autopilot/mach_disable", "number")

B738DR_autopilot_vvi_status_pfd			= create_dataref("laminar/B738/autopilot/vvi_status_pfd", "number")


B738DR_pfd_h_dots_pilot					= create_dataref("laminar/B738/PFD/h_dots_pilot", "number")
B738DR_pfd_v_dots_pilot					= create_dataref("laminar/B738/PFD/v_dots_pilot", "number")
B738DR_pfd_h_dots_pilot_show			= create_dataref("laminar/B738/PFD/h_dots_pilot_show", "number")
B738DR_pfd_v_dots_pilot_show			= create_dataref("laminar/B738/PFD/v_dots_pilot_show", "number")
B738DR_pfd_ils_pilot_show				= create_dataref("laminar/B738/PFD/ils_pilot_show", "number")


B738DR_lowerDU_page						= create_dataref("laminar/B738/systems/lowerDU_page", "number")
B738DR_EICAS_page						= create_dataref("laminar/B738/systems/EICAS_page", "number")

B738DR_autopilot_side					= create_dataref("laminar/B738/autopilot/autopilot_source", "number")

--B738DR_impuls							= create_dataref("laminar/B738/autopilot/impuls", "number")
B738DR_fd_on							= create_dataref("laminar/B738/autopilot/flight_direct_on", "number")

B738DR_pfd_fd_cmd						= create_dataref("laminar/B738/autopilot/pfd_fd_cmd", "number")
B738DR_pfd_fd_cmd_fo					= create_dataref("laminar/B738/autopilot/pfd_fd_cmd_fo", "number")

B738DR_altitude_mode					= create_dataref("laminar/B738/autopilot/altitude_mode", "number")
B738DR_altitude_mode2					= create_dataref("laminar/B738/autopilot/altitude_mode2", "number")
B738DR_heading_mode						= create_dataref("laminar/B738/autopilot/heading_mode", "number")
B738DR_speed_mode						= create_dataref("laminar/B738/autopilot/speed_mode", "number")

B738DR_ap_disconnect					= create_dataref("laminar/B738/annunciator/ap_disconnect", "number")
B738DR_at_disconnect					= create_dataref("laminar/B738/annunciator/at_disconnect", "number")

B738DR_source_pilot						= create_dataref("laminar/B738/autopilot/source_pilot", "number")
B738DR_source_arm_pilot					= create_dataref("laminar/B738/autopilot/source_arm_pilot", "number")

B738DR_vvi_dial_show					= create_dataref("laminar/B738/autopilot/vvi_dial_show", "number")

fd_target								= create_dataref("laminar/B738/flare/fd_target", "number")
vvi_trend								= create_dataref("laminar/B738/flare/vvi_trend", "number")

B738DR_pfd_vorloc_lnav					= create_dataref("laminar/B738/autopilot/pfd_vorloc_lnav", "number")
B738DR_fd_pilot_show					= create_dataref("laminar/B738/autopilot/fd_pilot_show", "number")
B738DR_fd_copilot_show					= create_dataref("laminar/B738/autopilot/fd_copilot_show", "number")

B738DR_ias_disagree						= create_dataref("laminar/B738/autopilot/ias_disagree", "number")
B738DR_alt_disagree						= create_dataref("laminar/B738/autopilot/alt_disagree", "number")

B738_vnav_active						= create_dataref("laminar/B738/autopilot/vnav_active", "number")

B738DR_eng1_N1_bug		= create_dataref("laminar/B738/engine/eng1_N1_bug", "number")
B738DR_eng2_N1_bug		= create_dataref("laminar/B738/engine/eng2_N1_bug", "number")
B738DR_eng1_N1_bug_dig		= create_dataref("laminar/B738/engine/eng1_N1_bug_dig", "number")
B738DR_eng2_N1_bug_dig		= create_dataref("laminar/B738/engine/eng2_N1_bug_dig", "number")
B738DR_N1_mode_man			= create_dataref("laminar/B738/engine/N1_mode_man", "number")
B738DR_assum_temp_show		= create_dataref("laminar/B738/eicas/assum_temp_show", "number")

B738DR_thrust1_leveler		= create_dataref("laminar/B738/engine/thrust1_leveler", "number")
B738DR_thrust2_leveler		= create_dataref("laminar/B738/engine/thrust2_leveler", "number")

vnav_speed_trg				= create_dataref("laminar/B738/autopilot/vnav_speed_trg", "number")

--B738DR_mcp_alt_dial			= create_dataref("laminar/B738/autopilot/mcp_alt_dial", "number")
B738DR_course_pilot			= create_dataref("laminar/B738/autopilot/course_pilot", "number")
B738DR_course_copilot		= create_dataref("laminar/B738/autopilot/course_copilot", "number")

B738DR_autopilot_spd_interv_pos	= create_dataref("laminar/B738/autopilot/spd_interv_pos", "number")
B738DR_ap_spd_interv_status	= create_dataref("laminar/B738/autopilot/spd_interv_status", "number")

B738DR_EFIS_TCAS_on			= create_dataref("laminar/B738/EFIS/tcas_on", "number")

B738DR_speed_ratio			= create_dataref("laminar/B738/FMS/speed_ratio", "number")
B738DR_v_speed_ratio		= create_dataref("laminar/B738/FMS/v_speed_ratio", "number")
B738DR_vdot_ratio			= create_dataref("laminar/B738/FMS/vdot_ratio", "number")

flaps_speed					= create_dataref("laminar/B738/FMS/flaps_speed", "number")
vnav_speed					= create_dataref("laminar/B738/FMS/vnav_speed", "number")

B738DR_agl_pilot			= create_dataref("laminar/B738/PFD/agl_pilot", "number")
B738DR_agl_copilot			= create_dataref("laminar/B738/PFD/agl_copilot", "number")

B738DR_pfd_nav1_pilot		= create_dataref("laminar/B738/PFD/nav1_pilot", "number")
B738DR_pfd_nav2_pilot		= create_dataref("laminar/B738/PFD/nav2_pilot", "number")
B738DR_pfd_nav1_copilot		= create_dataref("laminar/B738/PFD/nav1_copilot", "number")
B738DR_pfd_nav2_copilot		= create_dataref("laminar/B738/PFD/nav2_copilot", "number")

B738DR_green_arc	 		= create_dataref("laminar/B738/EFIS/green_arc", "number")
B738DR_green_arc_show		= create_dataref("laminar/B738/EFIS/green_arc_show", "number")

B738DR_vor1_sel_rotate	 	= create_dataref("laminar/B738/pfd/vor1_sel_rotate", "number")
B738DR_vor1_sel_x	 		= create_dataref("laminar/B738/pfd/vor1_sel_x", "number")
B738DR_vor1_sel_y	 		= create_dataref("laminar/B738/pfd/vor1_sel_y", "number")
B738DR_vor1_sel_id	 		= create_dataref("laminar/B738/pfd/vor1_sel_id", "string")
B738DR_vor1_sel_crs	 		= create_dataref("laminar/B738/pfd/vor1_sel_crs", "string")
B738DR_vor1_sel_bcrs 		= create_dataref("laminar/B738/pfd/vor1_sel_bcrs", "string")
B738DR_vor1_show	 		= create_dataref("laminar/B738/pfd/vor1_show", "number")
B738DR_vor1_copilot_show	= create_dataref("laminar/B738/pfd/vor1_copilot_show", "number")
B738DR_vor1_line_show		= create_dataref("laminar/B738/pfd/vor1_line_show", "number")
B738DR_vor1_line_copilot_show	= create_dataref("laminar/B738/pfd/vor1_line_copilot_show", "number")

B738DR_vor2_sel_rotate	 	= create_dataref("laminar/B738/pfd/vor2_sel_rotate", "number")
B738DR_vor2_sel_x	 		= create_dataref("laminar/B738/pfd/vor2_sel_x", "number")
B738DR_vor2_sel_y	 		= create_dataref("laminar/B738/pfd/vor2_sel_y", "number")
B738DR_vor2_sel_id	 		= create_dataref("laminar/B738/pfd/vor2_sel_id", "string")
B738DR_vor2_sel_crs	 		= create_dataref("laminar/B738/pfd/vor2_sel_crs", "string")
B738DR_vor2_sel_bcrs 		= create_dataref("laminar/B738/pfd/vor2_sel_bcrs", "string")
B738DR_vor2_show	 		= create_dataref("laminar/B738/pfd/vor2_show", "number")
B738DR_vor2_copilot_show	= create_dataref("laminar/B738/pfd/vor2_copilot_show", "number")
B738DR_vor2_line_show		= create_dataref("laminar/B738/pfd/vor2_line_show", "number")
B738DR_vor2_line_copilot_show = create_dataref("laminar/B738/pfd/vor2_line_copilot_show", "number")

B738DR_dh_pilot				= create_dataref("laminar/B738/pfd/dh_pilot", "number")
B738DR_dh_copilot			= create_dataref("laminar/B738/pfd/dh_copilot", "number")

vnav_descent_disable		= create_dataref("laminar/B738/FMS/vnav_disable", "number")
B738DR_mcp_speed_dial_kts	= create_dataref("laminar/B738/autopilot/mcp_speed_dial_kts", "number")
B738DR_mcp_speed_dial		= create_dataref("laminar/B738/autopilot/mcp_speed_dial_kts_mach", "number")


-- FMOD SOUNDS DATAREFS
B738DR_dh_minimum_pilot			= create_dataref("laminar/B738/fmod/dh_minimum_pilot", "number")
B738DR_dh_minimum_copilot		= create_dataref("laminar/B738/fmod/dh_minimum_copilot", "number")

B738DR_ap_ils_active		= create_dataref("laminar/B738/ap/ils_active", "number")

B738DR_gp_status			= create_dataref("laminar/B738/pfd/gp_status", "number")


--- A/P, A/T light buttons
B738DR_ap_light_pilot		= create_dataref("laminar/B738/push_button/ap_light_pilot", "number")
B738DR_at_light_pilot		= create_dataref("laminar/B738/push_button/at_light_pilot", "number")
B738DR_ap_light_fo			= create_dataref("laminar/B738/push_button/ap_light_fo", "number")
B738DR_at_light_fo			= create_dataref("laminar/B738/push_button/at_light_fo", "number")


B738DR_fdir_pitch_pilot		= create_dataref("laminar/B738/pfd/flight_director_pitch_pilot", "number")
B738DR_fdir_pitch_copilot	= create_dataref("laminar/B738/pfd/flight_director_pitch_copilot", "number")

-- TO/GA BUTTONS
B738DR_autopilot_left_toga_pos	= create_dataref("laminar/B738/autopilot/left_toga_pos", "number")
B738DR_autopilot_right_toga_pos	= create_dataref("laminar/B738/autopilot/right_toga_pos", "number")

-- A/T DISENGAGE BUTTONS
B738DR_autopilot_left_at_diseng_pos	= create_dataref("laminar/B738/autopilot/left_at_diseng_pos", "number")
B738DR_autopilot_right_at_diseng_pos	= create_dataref("laminar/B738/autopilot/right_at_diseng_pos", "number")

-- OTHERS
B738DR_mic_pos				= create_dataref("laminar/B738/push_button/mic_pos", "number")


B738DR_mcp_hdg_dial_nd			= create_dataref("laminar/B738/nd/mcp_hdg_dial", "number")
B738DR_mcp_hdg_dial_nd_show		= create_dataref("laminar/B738/nd/mcp_hdg_dial_show", "number")

B738DR_hdg_mag_nd			= create_dataref("laminar/B738/nd/hdg_mag", "number")
B738DR_hdg_mag_nd_show		= create_dataref("laminar/B738/nd/hdg_mag_show", "number")



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--

function B738DR_fmc_speed_DRhandler()end
function B738DR_fmc_mode_DRhandler()end
function B738DR_fmc_descent_now_DRhandler()end
function B738DR_was_on_cruise_DRhandler()end

function B738DR_fmc_climb_speed_DRhandler()end
function B738DR_fmc_climb_speed_l_DRhandler()end
function B738DR_fmc_climb_speed_mach_DRhandler()end
function B738DR_fmc_climb_r_speed1_DRhandler()end
function B738DR_fmc_climb_r_alt1_DRhandler()end
function B738DR_fmc_climb_r_speed2_DRhandler()end
function B738DR_fmc_climb_r_alt2_DRhandler()end

function B738DR_fmc_cruise_speed_DRhandler()end
function B738DR_fmc_cruise_speed_mach_DRhandler()end
function B738DR_fmc_cruise_alt_DRhandler()end

function B738DR_fmc_descent_speed_DRhandler()end
function B738DR_fmc_descent_speed_mach_DRhandler()end
function B738DR_fmc_descent_alt_DRhandler()end
function B738DR_fmc_descent_r_speed1_DRhandler()end
function B738DR_fmc_descent_r_alt1_DRhandler()end
function B738DR_fmc_descent_r_speed2_DRhandler()end
function B738DR_fmc_descent_r_alt2_DRhandler()end
function B738DR_fmc_approach_alt_DRhandler()end

function B738DR_thrust_vvi_1_DRhandler()end
function B738DR_thrust_vvi_2_DRhandler()end
function B738DR_thrust_ratio_1_DRhandler()end
function B738DR_thrust_ratio_2_DRhandler()end
function B738DR_flare_ratio_DRhandler()end
function B738DR_pitch_last_DRhandler()end
function B738DR_pitch_ratio_DRhandler()end
function B738DR_pitch_offset_DRhandler()end
function B738DR_vvi_last_DRhandler()end
function B738DR_flare_offset_DRhandler()end

function B738DR_capt_map_mode_DRhandler()end
function B738DR_fo_map_mode_DRhandler()end

function B738DR_efis_map_range_capt_DRhandler()end
function B738DR_efis_map_range_fo_DRhandler()end

function B738DR_n1_set_source_DRhandler() end
function B738DR_n1_set_adjust_DRhandler() end

function B738DR_minim_fo_DRhandler() end
function B738DR_minim_capt_DRhandler() end
function B738DR_minim_dh_fo_DRhandler() end
function B738DR_minim_dh_capt_DRhandler() end

function B738DR_mcp_alt_dial_DRhandler() end
function B738DR_vnav_alt_mode_DRhandler() end
function B738DR_mcp_hdg_dial_DRhandler() end

function B738DR_test_glare_DRhandler() end

function B738DR_test_test_DRhandler() end
function B738DR_test_test2_DRhandler() end

--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--

B738DR_test_test			= create_dataref("laminar/B738/test_test", "number", B738DR_test_test_DRhandler)
B738DR_test_test2			= create_dataref("laminar/B738/test_test2", "number", B738DR_test_test2_DRhandler)

-----

B738DR_test_glare			= create_dataref("laminar/B738/test_glare", "number", B738DR_test_glare_DRhandler)

B738DR_mcp_hdg_dial			= create_dataref("laminar/B738/autopilot/mcp_hdg_dial", "number", B738DR_mcp_hdg_dial_DRhandler)
B738DR_mcp_alt_dial			= create_dataref("laminar/B738/autopilot/mcp_alt_dial", "number", B738DR_mcp_alt_dial_DRhandler)
vnav_alt_mode				= create_dataref("laminar/B738/autopilot/vnav_alt_mode", "number", B738DR_vnav_alt_mode_DRhandler)

B738DR_capt_map_mode		= create_dataref("laminar/B738/EFIS_control/capt/map_mode_pos", "number", B738DR_capt_map_mode_DRhandler)
B738DR_fo_map_mode			= create_dataref("laminar/B738/EFIS_control/fo/map_mode_pos", "number", B738DR_fo_map_mode_DRhandler)

B738DR_efis_map_range_capt 		= create_dataref("laminar/B738/EFIS/capt/map_range", "number", B738DR_efis_map_range_capt_DRhandler)
B738DR_efis_map_range_fo 		= create_dataref("laminar/B738/EFIS/fo/map_range", "number", B738DR_efis_map_range_fo_DRhandler)

B738DR_fmc_speed			= create_dataref("laminar/B738/autopilot/fmc_speed", "number", B738DR_fmc_speed_DRhandler)
B738DR_fmc_mode				= create_dataref("laminar/B738/autopilot/fmc_mode", "number", B738DR_fmc_mode_DRhandler)
B738DR_fmc_descent_now		= create_dataref("laminar/B738/autopilot/fmc_descent_now", "number", B738DR_fmc_descent_now_DRhandler)
B738DR_was_on_cruise		= create_dataref("laminar/B738/autopilot/fmc_was_on_cruise", "number", B738DR_was_on_cruise_DRhandler)

-- CLIMB
B738DR_fmc_climb_speed			= create_dataref("laminar/B738/autopilot/fmc_climb_speed", "number", B738DR_fmc_climb_speed_DRhandler)
B738DR_fmc_climb_speed_l		= create_dataref("laminar/B738/autopilot/fmc_climb_speed_l", "number", B738DR_fmc_climb_speed_l_DRhandler)
B738DR_fmc_climb_speed_mach		= create_dataref("laminar/B738/autopilot/fmc_climb_speed_mach", "number", B738DR_fmc_climb_speed_mach_DRhandler)
B738DR_fmc_climb_r_speed1		= create_dataref("laminar/B738/autopilot/fmc_climb_r_speed1", "number", B738DR_fmc_climb_r_speed1_DRhandler)
B738DR_fmc_climb_r_alt1			= create_dataref("laminar/B738/autopilot/fmc_climb_r_alt1", "number", B738DR_fmc_climb_r_alt1_DRhandler)
B738DR_fmc_climb_r_speed2		= create_dataref("laminar/B738/autopilot/fmc_climb_r_speed2", "number", B738DR_fmc_climb_r_speed2_DRhandler)
B738DR_fmc_climb_r_alt2			= create_dataref("laminar/B738/autopilot/fmc_climb_r_alt2", "number", B738DR_fmc_climb_r_alt2_DRhandler)

-- CRUISE
B738DR_fmc_cruise_speed			= create_dataref("laminar/B738/autopilot/fmc_cruise_speed", "number", B738DR_fmc_cruise_speed_DRhandler)
B738DR_fmc_cruise_speed_mach	= create_dataref("laminar/B738/autopilot/fmc_cruise_speed_mach", "number", B738DR_fmc_cruise_speed_mach_DRhandler)
B738DR_fmc_cruise_alt			= create_dataref("laminar/B738/autopilot/fmc_cruise_alt", "number", B738DR_fmc_cruise_alt_DRhandler)

-- DESCENT
B738DR_fmc_descent_speed		= create_dataref("laminar/B738/autopilot/fmc_descent_speed", "number", B738DR_fmc_descent_speed_DRhandler)
B738DR_fmc_descent_speed_mach	= create_dataref("laminar/B738/autopilot/fmc_descent_speed_mach", "number", B738DR_fmc_descent_speed_mach_DRhandler)
B738DR_fmc_descent_alt			= create_dataref("laminar/B738/autopilot/fmc_descent_alt", "number", B738DR_fmc_descent_alt_DRhandler)
B738DR_fmc_descent_r_speed1		= create_dataref("laminar/B738/autopilot/fmc_descent_r_speed1", "number", B738DR_fmc_descent_r_speed1_DRhandler)
B738DR_fmc_descent_r_alt1		= create_dataref("laminar/B738/autopilot/fmc_descent_r_alt1", "number", B738DR_fmc_descent_r_alt1_DRhandler)
B738DR_fmc_descent_r_speed2		= create_dataref("laminar/B738/autopilot/fmc_descent_r_speed2", "number", B738DR_fmc_descent_r_speed2_DRhandler)
B738DR_fmc_descent_r_alt2		= create_dataref("laminar/B738/autopilot/fmc_descent_r_alt2", "number", B738DR_fmc_descent_r_alt2_DRhandler)
-- APPROACH
B738DR_fmc_approach_alt			= create_dataref("laminar/B738/autopilot/fmc_approach_alt", "number", B738DR_fmc_approach_alt_DRhandler)


-- FLARE
B738DR_thrust_vvi_1				= create_dataref("laminar/B738/flare/thrust_vvi_1", "number", B738DR_thrust_vvi_1_DRhandler)
B738DR_thrust_vvi_2				= create_dataref("laminar/B738/flare/thrust_vvi_2", "number", B738DR_thrust_vvi_2_DRhandler)
B738DR_thrust_ratio_1			= create_dataref("laminar/B738/flare/thrust_ratio_1", "number", B738DR_thrust_ratio_1_DRhandler)
B738DR_thrust_ratio_2			= create_dataref("laminar/B738/flare/thrust_ratio_2", "number", B738DR_thrust_ratio_2_DRhandler)
B738DR_flare_ratio				= create_dataref("laminar/B738/flare/flare_ratio", "number", B738DR_flare_ratio_DRhandler)
B738DR_pitch_last				= create_dataref("laminar/B738/flare/pitch_last", "number", B738DR_pitch_last_DRhandler)
B738DR_pitch_ratio				= create_dataref("laminar/B738/flare/pitch_ratio", "number", B738DR_pitch_ratio_DRhandler)
B738DR_pitch_offset				= create_dataref("laminar/B738/flare/pitch_offset", "number", B738DR_pitch_offset_DRhandler)
B738DR_vvi_last					= create_dataref("laminar/B738/flare/vvi_last", "number", B738DR_vvi_last_DRhandler)
B738DR_flare_offset				= create_dataref("laminar/B738/flare/flare_offset", "number", B738DR_flare_offset_DRhandler)

B738DR_n1_set_source = 			create_dataref("laminar/B738/toggle_switch/n1_set_source", "number", B738DR_n1_set_source_DRhandler)
B738DR_n1_set_adjust = 			create_dataref("laminar/B738/toggle_switch/n1_set_adjust", "number", B738DR_n1_set_adjust_DRhandler)

B738DR_minim_fo = 				create_dataref("laminar/B738/EFIS_control/fo/minimums", "number", B738DR_minim_fo_DRhandler)
B738DR_minim_capt = 			create_dataref("laminar/B738/EFIS_control/cpt/minimums", "number", B738DR_minim_capt_DRhandler)

B738DR_minim_dh_fo = 				create_dataref("laminar/B738/EFIS_control/fo/minimums_dh", "number", B738DR_minim_dh_fo_DRhandler)
B738DR_minim_dh_capt = 				create_dataref("laminar/B738/EFIS_control/capt/minimums_dh", "number", B738DR_minim_dh_capt_DRhandler)
--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

-- First Officer MINIMUMS SET SWITCH
function B738_fo_minimums_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_minim_fo == 1 then
			B738DR_minim_fo = 0
			B738DR_dh_copilot = radio_dh_copilot
			simDR_dh_copilot = B738DR_dh_copilot
		end
	end
end

function B738_fo_minimums_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_minim_fo == 0 then
			B738DR_minim_fo = 1
			B738DR_dh_copilot = baro_dh_copilot
			simDR_dh_copilot = 0
			if simDR_altitude_copilot < baro_dh_copilot then
				baro_dh_copilot_disable = 1
			end
		end
	end
end

-- Captain MINIMUMS SET SWITCH
function B738_cpt_minimums_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_minim_capt == 1 then
			B738DR_minim_capt = 0
			B738DR_dh_pilot = radio_dh_pilot
			simDR_dh_pilot = B738DR_dh_pilot
		end
	end
end

function B738_cpt_minimums_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_minim_capt == 0 then
			B738DR_minim_capt = 1
			B738DR_dh_pilot = baro_dh_pilot
			simDR_dh_pilot = 0
			if simDR_altitude_pilot < baro_dh_pilot then
				baro_dh_pilot_disable = 1
			end
		end
	end
end


-- CAPTAIN EFIS CONTROLS

function B738_dh_pilot_up_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_minim_dh_capt = 1
		if B738DR_minim_capt == 0 then	--radio DH
			if B738DR_dh_pilot <= 2499 then
				B738DR_dh_pilot = B738DR_dh_pilot + 1
				radio_dh_pilot = B738DR_dh_pilot
			end
		else	-- baro DH
			if B738DR_dh_pilot <= 14999 then
				B738DR_dh_pilot = B738DR_dh_pilot + 1
				baro_dh_pilot = B738DR_dh_pilot
			end
		end
	elseif phase == 1 and duration > 1 then
		B738DR_minim_dh_capt = 2
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_minim_capt == 0 then	--radio DH
				if B738DR_dh_pilot <= 2490 then
					B738DR_dh_pilot = B738DR_dh_pilot + 10
					radio_dh_pilot = B738DR_dh_pilot
				else
					B738DR_dh_pilot = 2500
					radio_dh_pilot = B738DR_dh_pilot
				end
			else	-- baro DH
				if B738DR_dh_pilot <= 14990 then
					B738DR_dh_pilot = B738DR_dh_pilot + 10
					baro_dh_pilot = B738DR_dh_pilot
				else
					B738DR_dh_pilot = 15000
					baro_dh_pilot = B738DR_dh_pilot
				end
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_minim_capt == 0 then	--radio DH
					if B738DR_dh_pilot <= 2490 then
						B738DR_dh_pilot = B738DR_dh_pilot + 10
						radio_dh_pilot = B738DR_dh_pilot
					else
						B738DR_dh_pilot = 2500
						radio_dh_pilot = B738DR_dh_pilot
					end
				else	-- baro DH
					if B738DR_dh_pilot <= 14990 then
						B738DR_dh_pilot = B738DR_dh_pilot + 10
						baro_dh_pilot = B738DR_dh_pilot
					else
						B738DR_dh_pilot = 15000
						baro_dh_pilot = B738DR_dh_pilot
					end
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_capt = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_dh_pilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_minim_dh_capt = -1
		if B738DR_dh_pilot >= 1 then
			B738DR_dh_pilot = B738DR_dh_pilot - 1
		end
		if B738DR_minim_capt == 0 then	--radio DH
			radio_dh_pilot = B738DR_dh_pilot
		else	-- baro DH
			baro_dh_pilot = B738DR_dh_pilot
		end
	elseif phase == 1 and duration > 1 then
		B738DR_minim_dh_capt = -2
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_dh_pilot >= 10 then
				B738DR_dh_pilot = B738DR_dh_pilot - 10
			else
				B738DR_dh_pilot = 0
			end
			if B738DR_minim_capt == 0 then	--radio DH
				radio_dh_pilot = B738DR_dh_pilot
			else	-- baro DH
				baro_dh_pilot = B738DR_dh_pilot
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_dh_pilot >= 10 then
					B738DR_dh_pilot = B738DR_dh_pilot - 10
				else
					B738DR_dh_pilot = 0
				end
				if B738DR_minim_capt == 0 then	--radio DH
					radio_dh_pilot = B738DR_dh_pilot
				else	-- baro DH
					baro_dh_pilot = B738DR_dh_pilot
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_capt = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_dh_pilot_up1_CMDhandler(phase, duration)
	if phase < 2 then
		B738DR_minim_dh_capt = 1
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_minim_capt == 0 then	--radio DH
				if B738DR_dh_pilot <= 2499 then
					B738DR_dh_pilot = B738DR_dh_pilot + 1
					radio_dh_pilot = B738DR_dh_pilot
				end
			else	-- baro DH
				if B738DR_dh_pilot <= 14999 then
					B738DR_dh_pilot = B738DR_dh_pilot + 1
					baro_dh_pilot = B738DR_dh_pilot
				end
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_minim_capt == 0 then	--radio DH
					if B738DR_dh_pilot <= 2499 then
						B738DR_dh_pilot = B738DR_dh_pilot + 1
						radio_dh_pilot = B738DR_dh_pilot
					end
				else	-- baro DH
					if B738DR_dh_pilot <= 14999 then
						B738DR_dh_pilot = B738DR_dh_pilot + 1
						baro_dh_pilot = B738DR_dh_pilot
					end
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_capt = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_dh_pilot_up2_CMDhandler(phase, duration)
	if phase < 2 then
		B738DR_minim_dh_capt = 2
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_minim_capt == 0 then	--radio DH
				if B738DR_dh_pilot <= 2490 then
					B738DR_dh_pilot = B738DR_dh_pilot + 10
					radio_dh_pilot = B738DR_dh_pilot
				else
					B738DR_dh_pilot = 2500
					radio_dh_pilot = B738DR_dh_pilot
				end
			else	-- baro DH
				if B738DR_dh_pilot <= 14990 then
					B738DR_dh_pilot = B738DR_dh_pilot + 10
					baro_dh_pilot = B738DR_dh_pilot
				else
					B738DR_dh_pilot = 15000
					baro_dh_pilot = B738DR_dh_pilot
				end
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_minim_capt == 0 then	--radio DH
					if B738DR_dh_pilot <= 2490 then
						B738DR_dh_pilot = B738DR_dh_pilot + 10
						radio_dh_pilot = B738DR_dh_pilot
					else
						B738DR_dh_pilot = 2500
						radio_dh_pilot = B738DR_dh_pilot
					end
				else	-- baro DH
					if B738DR_dh_pilot <= 14990 then
						B738DR_dh_pilot = B738DR_dh_pilot + 10
						baro_dh_pilot = B738DR_dh_pilot
					else
						B738DR_dh_pilot = 15000
						baro_dh_pilot = B738DR_dh_pilot
					end
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_capt = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_dh_pilot_dn1_CMDhandler(phase, duration)
	if phase < 2 then
		B738DR_minim_dh_capt = -1
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_dh_pilot >= 1 then
				B738DR_dh_pilot = B738DR_dh_pilot - 1
			end
			if B738DR_minim_capt == 0 then	--radio DH
				radio_dh_pilot = B738DR_dh_pilot
			else	-- baro DH
				baro_dh_pilot = B738DR_dh_pilot
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_dh_pilot >= 1 then
					B738DR_dh_pilot = B738DR_dh_pilot - 1
				end
				if B738DR_minim_capt == 0 then	--radio DH
					radio_dh_pilot = B738DR_dh_pilot
				else	-- baro DH
					baro_dh_pilot = B738DR_dh_pilot
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_capt = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_dh_pilot_dn2_CMDhandler(phase, duration)
	if phase < 2 then
		B738DR_minim_dh_capt = -2
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_dh_pilot >= 10 then
				B738DR_dh_pilot = B738DR_dh_pilot - 10
			else
				B738DR_dh_pilot = 0
			end
			if B738DR_minim_capt == 0 then	--radio DH
				radio_dh_pilot = B738DR_dh_pilot
			else	-- baro DH
				baro_dh_pilot = B738DR_dh_pilot
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_dh_pilot >= 10 then
					B738DR_dh_pilot = B738DR_dh_pilot - 10
				else
					B738DR_dh_pilot = 0
				end
				if B738DR_minim_capt == 0 then	--radio DH
					radio_dh_pilot = B738DR_dh_pilot
				else	-- baro DH
					baro_dh_pilot = B738DR_dh_pilot
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_capt = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end



function B738_efis_wxr_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_wxr_capt = 1
		simCMD_efis_wxr:once()
	elseif phase == 2 then
		B738DR_efis_wxr_capt = 0
	end
end

function B738_efis_sta_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_sta_capt = 1
		--simCMD_efis_sta:once()
		if B738DR_efis_vor_on == 0 then
			B738DR_efis_vor_on = 1
		else
			B738DR_efis_vor_on = 0
		end
	elseif phase == 2 then
		B738DR_efis_sta_capt = 0
	end
end

function B738_efis_wpt_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_wpt_capt = 1
		if B738DR_efis_fix_on == 0 then
			B738DR_efis_fix_on = 1
		else
			B738DR_efis_fix_on = 0
		end
		--simCMD_efis_wpt:once()
	elseif phase == 2 then
		B738DR_efis_wpt_capt = 0
	end
end

function B738_efis_arpt_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_arpt_capt = 1
--		simCMD_efis_arpt:once()
		if B738DR_efis_apt_on == 0 then
			B738DR_efis_apt_on = 1
		else
			B738DR_efis_apt_on = 0
		end
	elseif phase == 2 then
		B738DR_efis_arpt_capt = 0
	end
end

function B738_efis_data_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_data_capt = 1
		B738DR_efis_data_capt_status = 1 - B738DR_efis_data_capt_status
	elseif phase == 2 then
		B738DR_efis_data_capt = 0
	end
end

function B738_efis_pos_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_pos_capt = 1
	elseif phase == 2 then
		B738DR_efis_pos_capt = 0
	end
end

function B738_efis_terr_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_terr_capt = 1
	elseif phase == 2 then
		B738DR_efis_terr_capt = 0
	end
end

function B738_efis_rst_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_rst_capt = 1
		B738DR_dh_pilot = 0
		dh_min_block_pilot = 1
		if B738DR_minim_capt == 0 then	--radio DH
			radio_dh_pilot = 0
			simDR_dh_pilot = 0
		else	-- baro DH
			baro_dh_pilot = 0
		end
	elseif phase == 2 then
		B738DR_efis_rst_capt = 0
	end
end

function B738_efis_ctr_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_ctr_capt = 1
		if simDR_map_mode_is_HSI == 0 then
			simDR_map_mode_is_HSI = 1
		elseif simDR_map_mode_is_HSI == 1 then
			simDR_map_mode_is_HSI = 0
		end
	elseif phase == 2 then
		B738DR_efis_ctr_capt = 0
	end
end

function B738_efis_tfc_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_tfc_capt = 1
		if B738DR_EFIS_TCAS_on == 0 then
			B738DR_EFIS_TCAS_on = 1
		else
			B738DR_EFIS_TCAS_on = 0
		end
--		simCMD_efis_tfc:once()
	elseif phase == 2 then
		B738DR_efis_tfc_capt = 0
	end
end

function B738_efis_std_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_std_capt = 1
		if B738DR_baro_set_std_pilot == 0 then
			B738DR_baro_set_std_pilot = 1
--			B738DR_baro_sel_pilot_show = 1
			baro_sel_old = B738DR_baro_sel_in_hg_pilot
			simDR_barometer_setting_capt = 29.92
		else
			B738DR_baro_set_std_pilot = 0
--			B738DR_baro_sel_pilot_show = 0
			simDR_barometer_setting_capt = B738DR_baro_sel_in_hg_pilot
		end
		B738DR_baro_sel_pilot_show = 0
	elseif phase == 2 then
		B738DR_efis_std_capt = 0
	end
end

function B738_efis_mtrs_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_mtrs_capt = 1
		if B738DR_capt_alt_mode_meters == 0 then
			B738DR_capt_alt_mode_meters = 1
		elseif B738DR_capt_alt_mode_meters == 1 then
			B738DR_capt_alt_mode_meters = 0
		end
	elseif phase == 2 then
		B738DR_efis_mtrs_capt = 0
	end
end

function B738_efis_fpv_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_fpv_capt = 1
		if B738DR_capt_fpv_on == 0 then
			B738DR_capt_fpv_on = 1
		elseif B738DR_capt_fpv_on == 1 then
			B738DR_capt_fpv_on = 0
		end
	elseif phase == 2 then
		B738DR_efis_fpv_capt = 0
	end
end

function B738_efis_baro_mode_capt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_baro_mode_capt == 0 then
			B738DR_efis_baro_mode_capt = 1
		end
	end
end

function B738_efis_baro_mode_capt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_baro_mode_capt == 1 then
			B738DR_efis_baro_mode_capt = 0
		end
	end
end

function B738_efis_vor1_capt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor1_capt_pos == -1 then
			B738DR_efis_vor1_capt_pos = 0
			simDR_vor1_capt = 1
		elseif B738DR_efis_vor1_capt_pos == 0 then
			B738DR_efis_vor1_capt_pos = 1
			simDR_vor1_capt = 2
		end
	end
end
			
function B738_efis_vor1_capt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor1_capt_pos == 1 then
			B738DR_efis_vor1_capt_pos = 0
			simDR_vor1_capt = 1
		elseif B738DR_efis_vor1_capt_pos == 0 then
			B738DR_efis_vor1_capt_pos = -1
			simDR_vor1_capt = 1
		end
	end
end

function B738_efis_vor2_capt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor2_capt_pos == -1 then
			B738DR_efis_vor2_capt_pos = 0
			simDR_vor2_capt = 1
		elseif B738DR_efis_vor2_capt_pos == 0 then
			B738DR_efis_vor2_capt_pos = 1
			simDR_vor2_capt = 2
		end
	end
end
			
function B738_efis_vor2_capt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor2_capt_pos == 1 then
			B738DR_efis_vor2_capt_pos = 0
			simDR_vor2_capt = 1
		elseif B738DR_efis_vor2_capt_pos == 0 then
			B738DR_efis_vor2_capt_pos = -1
			simDR_vor2_capt = 1
		end
	end
end


function B738_efis_map_range_capt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_map_range_capt == 0 then
			B738DR_efis_map_range_capt = 1
		elseif B738DR_efis_map_range_capt == 1 then
			B738DR_efis_map_range_capt = 2
		elseif B738DR_efis_map_range_capt == 2 then
			B738DR_efis_map_range_capt = 3
		elseif B738DR_efis_map_range_capt == 3 then
			B738DR_efis_map_range_capt = 4
		elseif B738DR_efis_map_range_capt == 4 then
			B738DR_efis_map_range_capt = 5
		elseif B738DR_efis_map_range_capt == 5 then
			B738DR_efis_map_range_capt = 6
		elseif B738DR_efis_map_range_capt == 6 then
			B738DR_efis_map_range_capt = 7
		end
	end
end

function B738_efis_map_range_capt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_map_range_capt == 1 then
			B738DR_efis_map_range_capt = 0
		elseif B738DR_efis_map_range_capt == 2 then
			B738DR_efis_map_range_capt = 1
		elseif B738DR_efis_map_range_capt == 3 then
			B738DR_efis_map_range_capt = 2
		elseif B738DR_efis_map_range_capt == 4 then
			B738DR_efis_map_range_capt = 3
		elseif B738DR_efis_map_range_capt == 5 then
			B738DR_efis_map_range_capt = 4
		elseif B738DR_efis_map_range_capt == 6 then
			B738DR_efis_map_range_capt = 5
		elseif B738DR_efis_map_range_capt == 7 then
			B738DR_efis_map_range_capt = 6
		end
	end
end

-- FIRST OFFICER EFIS CONTROLS

function B738_dh_copilot_up_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_minim_dh_fo = 1
		if B738DR_minim_fo == 0 then	--radio DH
			if B738DR_dh_copilot <= 2499 then
				B738DR_dh_copilot = B738DR_dh_copilot + 1
				radio_dh_copilot = B738DR_dh_copilot
			end
		else	-- baro DH
			if B738DR_dh_copilot <= 14999 then
				B738DR_dh_copilot = B738DR_dh_copilot + 1
				baro_dh_copilot = B738DR_dh_copilot
			end
		end
	elseif phase == 1 and duration > 1 then
		B738DR_minim_dh_fo = 2
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_minim_fo == 0 then	--radio DH
				if B738DR_dh_copilot <= 2490 then
					B738DR_dh_copilot = B738DR_dh_copilot + 10
					radio_dh_copilot = B738DR_dh_copilot
				else
					B738DR_dh_copilot = 2500
					radio_dh_copilot = B738DR_dh_copilot
				end
			else	-- baro DH
				if B738DR_dh_copilot <= 14990 then
					B738DR_dh_copilot = B738DR_dh_copilot + 10
					baro_dh_copilot = B738DR_dh_copilot
				else
					B738DR_dh_copilot = 15000
					baro_dh_copilot = B738DR_dh_copilot
				end
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_minim_fo == 0 then	--radio DH
					if B738DR_dh_copilot <= 2490 then
						B738DR_dh_copilot = B738DR_dh_copilot + 10
						radio_dh_copilot = B738DR_dh_copilot
					else
						B738DR_dh_copilot = 2500
						radio_dh_copilot = B738DR_dh_copilot
					end
				else	-- baro DH
					if B738DR_dh_copilot <= 14990 then
						B738DR_dh_copilot = B738DR_dh_copilot + 10
						baro_dh_copilot = B738DR_dh_copilot
					else
						B738DR_dh_copilot = 15000
						baro_dh_copilot = B738DR_dh_copilot
					end
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_fo = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_dh_copilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_minim_dh_fo = -1
		if B738DR_dh_copilot >= 1 then
			B738DR_dh_copilot = B738DR_dh_copilot - 1
		end
		if B738DR_minim_fo == 0 then	--radio DH
			radio_dh_copilot = B738DR_dh_copilot
		else	-- baro DH
			baro_dh_copilot = B738DR_dh_copilot
		end
	elseif phase == 1 and duration > 1 then
		B738DR_minim_dh_fo = -2
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_dh_copilot >= 10 then
				B738DR_dh_copilot = B738DR_dh_copilot - 10
			else
				B738DR_dh_copilot = 0
			end
			if B738DR_minim_fo == 0 then	--radio DH
				radio_dh_copilot = B738DR_dh_copilot
			else	-- baro DH
				baro_dh_copilot = B738DR_dh_copilot
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_dh_copilot >= 10 then
					B738DR_dh_copilot = B738DR_dh_copilot - 10
				else
					B738DR_dh_copilot = 0
				end
				if B738DR_minim_fo == 0 then	--radio DH
					radio_dh_copilot = B738DR_dh_copilot
				else	-- baro DH
					baro_dh_copilot = B738DR_dh_copilot
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_fo = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_dh_copilot_up1_CMDhandler(phase, duration)
	if phase < 2 then
		B738DR_minim_dh_fo = 1
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_minim_fo == 0 then	--radio DH
				if B738DR_dh_copilot <= 2499 then
					B738DR_dh_copilot = B738DR_dh_copilot + 1
					radio_dh_copilot = B738DR_dh_copilot
				end
			else	-- baro DH
				if B738DR_dh_copilot <= 14999 then
					B738DR_dh_copilot = B738DR_dh_copilot + 1
					baro_dh_copilot = B738DR_dh_copilot
				end
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_minim_fo == 0 then	--radio DH
					if B738DR_dh_copilot <= 2499 then
						B738DR_dh_copilot = B738DR_dh_copilot + 1
						radio_dh_copilot = B738DR_dh_copilot
					end
				else	-- baro DH
					if B738DR_dh_copilot <= 14999 then
						B738DR_dh_copilot = B738DR_dh_copilot + 1
						baro_dh_copilot = B738DR_dh_copilot
					end
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_fo = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_dh_copilot_up2_CMDhandler(phase, duration)
	if phase < 2 then
		B738DR_minim_dh_fo = 2
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_minim_fo == 0 then	--radio DH
				if B738DR_dh_copilot <= 2490 then
					B738DR_dh_copilot = B738DR_dh_copilot + 10
					radio_dh_copilot = B738DR_dh_copilot
				else
					B738DR_dh_copilot = 2500
					radio_dh_copilot = B738DR_dh_copilot
				end
			else	-- baro DH
				if B738DR_dh_copilot <= 14990 then
					B738DR_dh_copilot = B738DR_dh_copilot + 10
					baro_dh_copilot = B738DR_dh_copilot
				else
					B738DR_dh_copilot = 15000
					baro_dh_copilot = B738DR_dh_copilot
				end
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_minim_fo == 0 then	--radio DH
					if B738DR_dh_copilot <= 2490 then
						B738DR_dh_copilot = B738DR_dh_copilot + 10
						radio_dh_copilot = B738DR_dh_copilot
					else
						B738DR_dh_copilot = 2500
						radio_dh_copilot = B738DR_dh_copilot
					end
				else	-- baro DH
					if B738DR_dh_copilot <= 14990 then
						B738DR_dh_copilot = B738DR_dh_copilot + 10
						baro_dh_copilot = B738DR_dh_copilot
					else
						B738DR_dh_copilot = 15000
						baro_dh_copilot = B738DR_dh_copilot
					end
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_fo = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_dh_copilot_dn1_CMDhandler(phase, duration)
	if phase < 2 then
		B738DR_minim_dh_fo = -1
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_dh_copilot >= 1 then
				B738DR_dh_copilot = B738DR_dh_copilot - 1
			end
			if B738DR_minim_fo == 0 then	--radio DH
				radio_dh_copilot = B738DR_dh_copilot
			else	-- baro DH
				baro_dh_copilot = B738DR_dh_copilot
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_dh_copilot >= 1 then
					B738DR_dh_copilot = B738DR_dh_copilot - 1
				end
				if B738DR_minim_fo == 0 then	--radio DH
					radio_dh_copilot = B738DR_dh_copilot
				else	-- baro DH
					baro_dh_copilot = B738DR_dh_copilot
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_fo = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_dh_copilot_dn2_CMDhandler(phase, duration)
	if phase < 2 then
		B738DR_minim_dh_fo = -2
		dh_timer = dh_timer + SIM_PERIOD
		dh_timer2 = dh_timer2 + SIM_PERIOD
		if dh_timer2 > DH_STEP2 then
			if B738DR_dh_copilot >= 10 then
				B738DR_dh_copilot = B738DR_dh_copilot - 10
			else
				B738DR_dh_copilot = 0
			end
			if B738DR_minim_fo == 0 then	--radio DH
				radio_dh_copilot = B738DR_dh_copilot
			else	-- baro DH
				baro_dh_copilot = B738DR_dh_copilot
			end
			dh_timer = 0
			dh_timer2 = DH_STEP2
		else
			if dh_timer > DH_STEP then
				if B738DR_dh_copilot >= 10 then
					B738DR_dh_copilot = B738DR_dh_copilot - 10
				else
					B738DR_dh_copilot = 0
				end
				if B738DR_minim_fo == 0 then	--radio DH
					radio_dh_copilot = B738DR_dh_copilot
				else	-- baro DH
					baro_dh_copilot = B738DR_dh_copilot
				end
				dh_timer = 0
			end
		end
	elseif phase == 2 then
		B738DR_minim_dh_fo = 0
		dh_timer = 0
		dh_timer2 = 0
	end
end

function B738_efis_wxr_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_wxr_fo = 1
		simCMD_efis_wxr:once()
	elseif phase == 2 then
		B738DR_efis_wxr_fo = 0
	end
end

function B738_efis_sta_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_sta_fo = 1
		if B738DR_efis_fo_vor_on == 0 then
			B738DR_efis_fo_vor_on = 1
		else
			B738DR_efis_fo_vor_on = 0
		end
		--simCMD_efis_sta:once()
	elseif phase == 2 then
		B738DR_efis_sta_fo = 0
	end
end

function B738_efis_wpt_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_wpt_fo = 1
		if B738DR_efis_fo_fix_on == 0 then
			B738DR_efis_fo_fix_on = 1
		else
			B738DR_efis_fo_fix_on = 0
		end
		--simCMD_efis_wpt:once()
	elseif phase == 2 then
		B738DR_efis_wpt_fo = 0
	end
end

function B738_efis_arpt_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_arpt_fo = 1
		if B738DR_efis_fo_apt_on == 0 then
			B738DR_efis_fo_apt_on = 1
		else
			B738DR_efis_fo_apt_on = 0
		end
		--simCMD_efis_arpt:once()
	elseif phase == 2 then
		B738DR_efis_arpt_fo = 0
	end
end

function B738_efis_data_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_data_fo = 1
		B738DR_efis_data_fo_status = 1 - B738DR_efis_data_fo_status
	elseif phase == 2 then
		B738DR_efis_data_fo = 0
	end
end

function B738_efis_pos_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_pos_fo = 1
	elseif phase == 2 then
		B738DR_efis_pos_fo = 0
	end
end

function B738_efis_terr_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_terr_fo = 1
	elseif phase == 2 then
		B738DR_efis_terr_fo = 0
	end
end

function B738_efis_rst_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_rst_fo = 1
		B738DR_dh_copilot = 0
		dh_min_block_copilot = 1
		if B738DR_minim_fo == 0 then	--radio DH
			radio_dh_copilot = 0
			simDR_dh_copilot = 0
		else	-- baro DH
			baro_dh_copilot = 0
		end
	elseif phase == 2 then
		B738DR_efis_rst_fo = 0
	end
end

function B738_efis_ctr_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_ctr_fo = 1
		if simDR_map_mode_is_HSI == 0 then
			simDR_map_mode_is_HSI = 1
		elseif simDR_map_mode_is_HSI == 1 then
			simDR_map_mode_is_HSI = 0
		end
	elseif phase == 2 then
		B738DR_efis_ctr_fo = 0
	end
end

function B738_efis_tfc_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_tfc_fo = 1
		if B738DR_EFIS_TCAS_on == 0 then
			B738DR_EFIS_TCAS_on = 1
		else
			B738DR_EFIS_TCAS_on = 0
		end
--		simCMD_efis_tfc:once()
	elseif phase == 2 then
		B738DR_efis_tfc_fo = 0
	end
end

function B738_efis_std_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_std_fo = 1
		if B738DR_baro_set_std_copilot == 0 then
			B738DR_baro_set_std_copilot = 1
			baro_sel_co_old = B738DR_baro_sel_in_hg_copilot
			simDR_barometer_setting_fo = 29.92
--			B738DR_baro_sel_copilot_show = 1
		else
			B738DR_baro_set_std_copilot = 0
--			B738DR_baro_sel_copilot_show = 0
			simDR_barometer_setting_fo = B738DR_baro_sel_in_hg_copilot
		end
		B738DR_baro_sel_copilot_show = 0
	elseif phase == 2 then
		B738DR_efis_std_fo = 0
	end
end

function B738_efis_mtrs_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_mtrs_fo = 1
		if B738DR_fo_alt_mode_meters == 0 then
			B738DR_fo_alt_mode_meters = 1
		elseif B738DR_fo_alt_mode_meters == 1 then
			B738DR_fo_alt_mode_meters = 0
		end
	elseif phase == 2 then
		B738DR_efis_mtrs_fo = 0
	end
end

function B738_efis_fpv_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_fpv_fo = 1
		if B738DR_fo_fpv_on == 0 then
			B738DR_fo_fpv_on = 1
		elseif B738DR_fo_fpv_on == 1 then
			B738DR_fo_fpv_on = 0
		end
	elseif phase == 2 then
		B738DR_efis_fpv_fo = 0
	end
end

function B738_efis_baro_mode_fo_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_baro_mode_fo == 0 then
			B738DR_efis_baro_mode_fo = 1
		end
	end
end

function B738_efis_baro_mode_fo_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_baro_mode_fo == 1 then
			B738DR_efis_baro_mode_fo = 0
		end
	end
end

function B738_efis_vor1_fo_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor1_fo_pos == -1 then
			B738DR_efis_vor1_fo_pos = 0
			simDR_vor1_fo = 1
		elseif B738DR_efis_vor1_fo_pos == 0 then
			B738DR_efis_vor1_fo_pos = 1
			simDR_vor1_fo = 2
		end
	end
end
			
function B738_efis_vor1_fo_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor1_fo_pos == 1 then
			B738DR_efis_vor1_fo_pos = 0
			simDR_vor1_fo = 1
		elseif B738DR_efis_vor1_fo_pos == 0 then
			B738DR_efis_vor1_fo_pos = -1
			simDR_vor1_fo = 1
		end
	end
end

function B738_efis_vor2_fo_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor2_fo_pos == -1 then
			B738DR_efis_vor2_fo_pos = 0
			simDR_vor2_fo = 1
		elseif B738DR_efis_vor2_fo_pos == 0 then
			B738DR_efis_vor2_fo_pos = 1
			simDR_vor2_fo = 2
		end
	end
end
			
function B738_efis_vor2_fo_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor2_fo_pos == 1 then
			B738DR_efis_vor2_fo_pos = 0
			simDR_vor2_fo = 1
		elseif B738DR_efis_vor2_fo_pos == 0 then
			B738DR_efis_vor2_fo_pos = -1
			simDR_vor2_fo = 1
		end
	end
end



function B738_efis_map_mode_capt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_capt_map_mode == 0 then
			B738DR_capt_map_mode = 1
			--B738DR_fo_map_mode = 1
			simDR_EFIS_mode = 1
		elseif B738DR_capt_map_mode == 1 then
			B738DR_capt_map_mode = 2
			--B738DR_fo_map_mode = 2
			simDR_EFIS_mode = 2
		elseif B738DR_capt_map_mode == 2 then
			B738DR_capt_map_mode = 3
			--B738DR_fo_map_mode = 3
			simDR_EFIS_mode = 4
		end
	end
end

function B738_efis_map_mode_capt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_capt_map_mode == 1 then
			B738DR_capt_map_mode = 0
			--B738DR_fo_map_mode = 0
			simDR_EFIS_mode = 0
		elseif B738DR_capt_map_mode == 2 then
			B738DR_capt_map_mode = 1
			--B738DR_fo_map_mode = 1
			simDR_EFIS_mode = 1
		elseif B738DR_capt_map_mode == 3 then
			B738DR_capt_map_mode = 2
			--B738DR_fo_map_mode = 2
			simDR_EFIS_mode = 2
		end
	end
end

function B738_efis_map_mode_fo_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_fo_map_mode == 0 then
			--B738DR_capt_map_mode = 1
			B738DR_fo_map_mode = 1
			simDR_EFIS_mode = 1
		elseif B738DR_fo_map_mode == 1 then
			--B738DR_capt_map_mode = 2
			B738DR_fo_map_mode = 2
			simDR_EFIS_mode = 2
		elseif B738DR_fo_map_mode == 2 then
			--B738DR_capt_map_mode = 3
			B738DR_fo_map_mode = 3
			simDR_EFIS_mode = 4
		end
	end
end

function B738_efis_map_mode_fo_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_fo_map_mode == 1 then
			--B738DR_capt_map_mode = 0
			B738DR_fo_map_mode = 0
			simDR_EFIS_mode = 0
		elseif B738DR_fo_map_mode == 2 then
			--B738DR_capt_map_mode = 1
			B738DR_fo_map_mode = 1
			simDR_EFIS_mode = 1
		elseif B738DR_fo_map_mode == 3 then
			--B738DR_capt_map_mode = 2
			B738DR_fo_map_mode = 2
			simDR_EFIS_mode = 2
		end
	end
end

function B738_efis_map_range_fo_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_map_range_fo == 0 then
			B738DR_efis_map_range_fo = 1
		elseif B738DR_efis_map_range_fo == 1 then
			B738DR_efis_map_range_fo = 2
		elseif B738DR_efis_map_range_fo == 2 then
			B738DR_efis_map_range_fo = 3
		elseif B738DR_efis_map_range_fo == 3 then
			B738DR_efis_map_range_fo = 4
		elseif B738DR_efis_map_range_fo == 4 then
			B738DR_efis_map_range_fo = 5
		elseif B738DR_efis_map_range_fo == 5 then
			B738DR_efis_map_range_fo = 6
		elseif B738DR_efis_map_range_fo == 6 then
			B738DR_efis_map_range_fo = 7
		end
	end
end

function B738_efis_map_range_fo_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_map_range_fo == 1 then
			B738DR_efis_map_range_fo = 0
		elseif B738DR_efis_map_range_fo == 2 then
			B738DR_efis_map_range_fo = 1
		elseif B738DR_efis_map_range_fo == 3 then
			B738DR_efis_map_range_fo = 2
		elseif B738DR_efis_map_range_fo == 4 then
			B738DR_efis_map_range_fo = 3
		elseif B738DR_efis_map_range_fo == 5 then
			B738DR_efis_map_range_fo = 4
		elseif B738DR_efis_map_range_fo == 6 then
			B738DR_efis_map_range_fo = 5
		elseif B738DR_efis_map_range_fo == 7 then
			B738DR_efis_map_range_fo = 6
		end
	end
end


------------ AUTOPILOT ------------------------------------------------------------------

function B738_autopilot_n1_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_n1_pos = 1
		if B738DR_autopilot_autothr_arm_pos == 1 then	-- A/T on
			if B738DR_autopilot_n1_status == 0 then
				if at_mode_engaged == 3 and simDR_radio_height_pilot_ft > 800 then
					takeoff_n1 = 1
				else
					at_mode = 1
					takeoff_n1 = 0
				end
			else
				at_mode = 0
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_n1_pos = 0
	end
end

function B738_autopilot_speed_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_speed_pos = 1
		if B738DR_autopilot_autothr_arm_pos == 1 then
			if simDR_autothrottle_status == 0 then
				if ap_pitch_mode == 5 then -- vnav
					vnav_stop()
					ap_pitch_mode = 0
				end
				at_mode = 2
			else
				at_mode = 0
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_speed_pos = 0
	end
end

function B738_autopilot_lvl_chg_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_lvl_chg_pos = 1 
		if B738DR_autoland_status == 0 and bellow_400ft == 0 and B738DR_fd_on == 1
		and ap_app_block == 0 then		-- APP LOC and G/S captured  
--			if B738DR_autopilot_vnav_status == 1 and B738DR_fmc_mode == 2 then
--			and B738DR_efis_vor1_capt_pos >= 0 and B738DR_efis_vor2_capt_pos >= 0 then		-- TEMPORARY DESCENT NOW --
--			and ap_vnav_status == 1 then 		-- TEMPORARY DESCENT NOW --
--				B738DR_fmc_descent_now = 1
--			else
				if B738DR_autopilot_lvl_chg_status == 0 then
					ap_pitch_mode = 2
				else
					ap_pitch_mode = 0
					at_mode = 0
				end
--			end
		end
	elseif phase == 2 then
		B738DR_autopilot_lvl_chg_pos = 0
	end
end

function B738_autopilot_vnav_press_CMDhandler(phase, duration)
	
	local vnav_enable2 = 0
	if simDR_on_ground_0 == 1 and simDR_on_ground_1 ==1 and simDR_on_ground_2 == 1 then
		if B738DR_autoland_status == 0 --and bellow_400ft == 0 
		and B738DR_autopilot_fd_pos == 1 and B738DR_autopilot_fd_fo_pos == 1
		and B738DR_end_route == 0 and B738DR_no_perf == 0
		and ap_app_block == 0 then
			vnav_enable2 = 1
		end
	end
	if bellow_400ft == 0  and B738DR_fd_on == 1 then
		if B738DR_autoland_status == 0 --and bellow_400ft == 0 
		--and B738DR_autopilot_fd_pos == 1 and B738DR_autopilot_fd_fo_pos == 1
		and B738DR_end_route == 0 and B738DR_no_perf == 0
		and ap_app_block == 0 then 
			vnav_enable2 = 1
		end
	end
	if phase == 0 then
		B738DR_autopilot_vnav_pos = 1
		-- if B738DR_autoland_status == 0 --and bellow_400ft == 0 
		-- and B738DR_autopilot_fd_pos == 1 and B738DR_autopilot_fd_fo_pos == 1
		-- and simDR_on_ground_0 == 1 and simDR_on_ground_1 ==1 and simDR_on_ground_2 == 1
		-- and B738DR_end_route == 0 and B738DR_no_perf == 0
		-- and ap_app_block == 0 then --ap_roll_mode == 4 and bellow_400ft == 0 then			-- LNAV on 
		if vnav_enable2 == 1 then
			if B738DR_autopilot_vnav_status == 0 then
				-- VNAV ALT
				if ap_pitch_mode == 3 then		-- ALT HLD
					if B738DR_flight_phase ~= 2 then
						vnav_alt_mode = 1
						vnav_alt_hld = 1
					else
						vnav_alt_mode = 0
					end
				else
					vnav_alt_mode = 0
				end
				ap_pitch_mode = 5
			else
				ap_pitch_mode = 0
			end
		else
			if B738DR_autopilot_vnav_status == 1 then
				ap_pitch_mode = 0
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_vnav_pos = 0
	end

end

function B738_autopilot_co_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_co_pos = 1
		--if B738DR_autopilot_vnav_status == 0 then --and bellow_400ft == 0 then	-- VNAV off
		if B738DR_show_ias == 1 then
			simCMD_autopilot_co:once()
		end
	elseif phase == 2 then
		B738DR_autopilot_co_pos = 0
	end
end

--------

function B738_nav_source_swap()

	if autopilot_fms_nav_status == 0 then
		B738DR_pfd_vorloc_lnav = 0
		if B738DR_autopilot_vhf_source_pos == -1 then
			simDR_autopilot_source = 0		-- NAV 1
			simDR_autopilot_fo_source = 0	-- NAV 1
		elseif B738DR_autopilot_vhf_source_pos == 0 then
		 	simDR_autopilot_source = 0		-- NAV 1
			simDR_autopilot_fo_source = 1	-- NAV 2
		elseif B738DR_autopilot_vhf_source_pos == 1 then
		 	simDR_autopilot_source = 1		-- NAV 2
			simDR_autopilot_fo_source = 1	-- NAV 2
		end
	elseif autopilot_fms_nav_status == 1 then
		simDR_autopilot_source = 2			-- LNAV
		simDR_autopilot_fo_source = 2		-- LNAV
--		simDR_autopilot_fo_source = 0		-- LNAV
		B738DR_pfd_vorloc_lnav = 1
	end

end



function B738_autopilot_lnav_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_lnav_pos = 1
		if B738DR_autoland_status == 0 and B738DR_end_route == 0  and B738DR_fd_on == 1
		and ap_app_block == 0 then		-- APP LOC and G/S captured  
			if B738DR_autopilot_lnav_status == 0 then
				ap_roll_mode = 4
			else
				ap_roll_mode = 0
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_lnav_pos = 0
	end
end



function B738_autopilot_vorloc_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_vorloc_pos = 1
		if B738DR_autoland_status == 0 and bellow_400ft == 0  and B738DR_fd_on == 1
		and ap_app_block == 0 then		-- APP LOC and G/S captured  
			if B738DR_autopilot_vorloc_status == 0 then
				ap_roll_mode = 2
			else
				ap_roll_mode = 0
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_vorloc_pos = 0
	end
end

function B738_autopilot_app_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_app_pos = 1
		if B738DR_autoland_status == 0 and bellow_400ft == 0  and B738DR_fd_on == 1
		and ap_app_block == 0 then --and B738DR_autopilot_pfd_mode > 0 then		-- APP LOC and G/S captured  
			if B738DR_autopilot_app_status == 0 then
				ap_roll_mode = 3
			else
				ap_roll_mode = 0
			end
			
			
			
			-- if B738DR_autopilot_app_status == 0 then
				-- if B738DR_fms_ils_disable == 0 then
					-- if autopilot_fms_nav_status == 1 then
						-- ap_roll_mode = 6	-- APP ILS arm during LNAV
					-- else
						-- ap_roll_mode = 3	-- APP ILS
					-- end
				-- else
					-- if B738DR_rnav_enable == 1 then
						-- ap_roll_mode = 7	-- RNAV G/P
					-- elseif  B738DR_rnav_enable == 2 then
						-- ap_roll_mode = 8	-- LOC G/P
					-- end
				-- end
			-- else
				-- ap_roll_mode = 0
			-- end
			
			
		end
	elseif phase == 2 then
		B738DR_autopilot_app_pos = 0
	end
end

function B738_autopilot_hdg_sel_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_hdg_sel_pos = 1
		if B738DR_autoland_status == 0  and B738DR_fd_on == 1
		and ap_app_block == 0 then		-- APP LOC and G/S captured  
			if B738DR_autopilot_hdg_sel_status == 0 then
				ap_roll_mode = 1
			else
				ap_roll_mode = 0
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_hdg_sel_pos = 0
	end
end


function B738_autopilot_alt_hld_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_alt_hld_pos = 1
		if B738DR_autoland_status == 0 and bellow_400ft == 0  and B738DR_fd_on == 1
		and simDR_glideslope_status < 2 then
			if B738DR_autopilot_alt_hld_status == 0 then
				ap_pitch_mode = 3
			else
				ap_pitch_mode = 0
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_alt_hld_pos = 0
	end
end


function B738_autopilot_vs_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_vs_pos = 1
		if B738DR_autoland_status == 0 and bellow_400ft == 0  and B738DR_fd_on == 1
		and ap_app_block == 0 then	-- and simDR_autopilot_altitude_mode ~= 6 then		-- APP LOC and G/S captured  
			if B738DR_autopilot_vs_status == 0 then
				ap_pitch_mode = 1
			else
				ap_pitch_mode = 0
				simDR_ap_vvi_dial = 0
			end
		else
			simDR_ap_vvi_dial = 0
		end
	elseif phase == 2 then
		B738DR_autopilot_vs_pos = 0
	end
end

function B738_autopilot_disconnect_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_disconnect_pos == 0 then
			
			B738DR_autopilot_disconnect_pos = 1
		
			--B738DR_autopilot_fd_pos = 0
			--B738DR_autopilot_fd_fo_pos = 0
--			simCMD_disconnect:start()
			simDR_flight_dir_mode = 1

			simCMD_autopilot_cws:stop()
			autopilot_cws_a_status = 0
			autopilot_cws_b_status = 0
			autopilot_cmd_b_status = 0
			autopilot_cmd_a_status = 0
			B738DR_flare_status = 0
			B738DR_autoland_status = 0
			B738DR_retard_status = 0
			B738DR_single_ch_status = 0
--			B738DR_autopilot_vnav_status = 0
			B738DR_fmc_descent_now = 0
			B738DR_fmc_mode = 0
			B738DR_autopilot_n1_pfd = 0
			B738DR_autopilot_n1_status = 0
			B738DR_autopilot_vnav_alt_pfd = 0
			B738DR_autopilot_vnav_pth_pfd = 0
			B738DR_autopilot_vnav_spd_pfd = 0
			B738DR_autopilot_fmc_spd_pfd = 0
			B738DR_autopilot_to_ga_pfd = 0
			B738DR_autopilot_thr_hld_pfd = 0
			B738DR_autopilot_ga_pfd = 0
			B738DR_autopilot_alt_acq_pfd = 0
			----simDR_throttle_override = 0
			simDR_joy_pitch_override = 0
			if ap_roll_mode ~= 3 then -- APP off
				ap_roll_mode_eng = 0
				ap_pitch_mode_eng = 0
			end
			ap_roll_mode = 0
			ap_pitch_mode = 0
--			ap_roll_mode_eng = 0
--			ap_pitch_mode_eng = 0
			if at_mode_eng == 3 or at_mode_eng == 4 then	-- TAKEOFF and A/P GA mode off
				at_mode = 0
			end
			ils_test_enable = 0
			if ap_on == 1 then
				ap_disco_do = 1
			end
			
		elseif B738DR_autopilot_disconnect_pos == 1 then
			B738DR_autopilot_disconnect_pos = 0
			--ap_disco_do = 0
			--at_dis_time = 0
--			simCMD_disconnect:stop()
		end
	end
end

function B738_autopilot_autothr_arm_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_autothr_arm_pos == 0 then
			B738DR_autopilot_autothr_arm_pos = 1
			B738DR_autopilot_autothrottle_status = 1
			at_dis_time = 0
		elseif B738DR_autopilot_autothr_arm_pos == 1 then
			B738DR_autopilot_autothr_arm_pos = 0
			B738DR_autopilot_autothrottle_status = 0
--			B738DR_autopilot_n1_status = 0
--			----simDR_throttle_override = 0
--			at_mode_eng = 0
			at_mode = 0
			simCMD_autothrottle_discon:once()	-- disconnect autothrotle
		end
	end
end

---- FLIGHT DIRECTORS ------------------------------------------

function B738_autopilot_flight_dir_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_fd_pos == 0 then
			B738DR_autopilot_fd_pos = 1
			if B738DR_autopilot_fd_fo_pos == 0 then
				B738DR_autopilot_side = 0
			end
		elseif B738DR_autopilot_fd_pos == 1 then
			B738DR_autopilot_fd_pos = 0
			if B738DR_autopilot_fd_fo_pos == 1 then
				B738DR_autopilot_side = 1
			else
				B738DR_autopilot_side = 0
			end
		end
	end
end

function B738_autopilot_flight_dir_fo_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_fd_fo_pos == 0 then
			B738DR_autopilot_fd_fo_pos = 1
			if B738DR_autopilot_fd_pos == 0 then
				B738DR_autopilot_side = 1
			end
		elseif B738DR_autopilot_fd_fo_pos == 1 then
			B738DR_autopilot_fd_fo_pos = 0
			B738DR_autopilot_side = 0
		end
	end
end

---- BANK ANGLE ---------------------------------------------

function B738_autopilot_bank_angle_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_bank_angle_pos == 0 then
			B738DR_autopilot_bank_angle_pos = 1
--			simDR_bank_angle = 3
		elseif B738DR_autopilot_bank_angle_pos == 1 then
			B738DR_autopilot_bank_angle_pos = 2
--			simDR_bank_angle = 4
		elseif B738DR_autopilot_bank_angle_pos == 2 then
			B738DR_autopilot_bank_angle_pos = 3
--			simDR_bank_angle = 5
		elseif B738DR_autopilot_bank_angle_pos == 3 then
			B738DR_autopilot_bank_angle_pos = 4
--			simDR_bank_angle = 6
		end
	end
end
		
function B738_autopilot_bank_angle_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_bank_angle_pos == 4 then
			B738DR_autopilot_bank_angle_pos = 3
--			simDR_bank_angle = 5
		elseif B738DR_autopilot_bank_angle_pos == 3 then
			B738DR_autopilot_bank_angle_pos = 2
--			simDR_bank_angle = 4
		elseif B738DR_autopilot_bank_angle_pos == 2 then
			B738DR_autopilot_bank_angle_pos = 1
--			simDR_bank_angle = 3
		elseif B738DR_autopilot_bank_angle_pos == 1 then
			B738DR_autopilot_bank_angle_pos = 0
--			simDR_bank_angle = 2
		end
	end
end	

-- COMMAND A&B
		
function B738_autopilot_cmd_a_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_cmd_a_pos = 1
		if B738DR_fd_on == 1 then
			if autopilot_cmd_a_status == 0 and B738DR_autopilot_disconnect_pos == 0 
			and simDR_radio_height_pilot_ft > 400 and ap_app_block_800 == 0 then
				autopilot_cmd_a_status = 1
				ap_dis_time = 0
				if autopilot_cmd_b_status == 1
				and simDR_approach_status == 2
				and B738DR_autopilot_vhf_source_pos == 0 
				and simDR_radio_height_pilot_ft > 800 	--then		-- AUTOLAND on
				and B738DR_autopilot_fd_pos == 1
				and B738DR_autopilot_fd_fo_pos == 1 then		-- if both F/D on, AUTOLAND on
					B738DR_autoland_status = 1
					cmd_first = 1	-- CMD B first
					ils_test_enable = 1
				else									-- CMD A on
					autopilot_cmd_b_status = 0
					simCMD_autopilot_cws:stop()
					ap_on = 1
					if at_mode_eng == 3 then	-- TAKEOFF mode
						if ap_pitch_mode == 0 then
							ap_pitch_mode = 2	-- LVL CHG
							--at_mode = 6		-- N1
							B738DR_lvl_chg_mode = 1
						else
							--if ap_vnav_status == 2 then
							if B738DR_autopilot_vnav_status == 1 then
								at_mode = 7
							else
								at_mode = 2			-- SPEED mode
							end
						end
						if ap_roll_mode == 0 then
							ap_roll_mode = 1	-- HDG SEL
						end
						if B738DR_fms_v2_15 == 0 then
							simDR_airspeed_dial = 180
						else
							simDR_airspeed_dial = B738DR_fms_v2_15
						end
					elseif at_mode_eng == 5 then	-- F/D GA
						ap_roll_mode = 1	-- HDG SEL
						ap_pitch_mode = 2	-- LVL CHG
						fd_goaround = 3		-- F/D GA with CMD
						at_mode = 0
						at_mode_eng = 0
					elseif at_mode == 1 and ap_pitch_mode_eng == 0 and B738DR_flight_phase < 2 then	-- no pitch mode during climb
						if simDR_airspeed_pilot > B738DR_mcp_speed_dial then
							ap_pitch_mode = 1	-- VS mode
							ap_pitch_mode_eng = 1
							simCMD_autopilot_vs:once()
							simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100)
							at_mode = 2		-- SPEED mode
							simDR_airspeed_dial = simDR_airspeed_pilot
						else
							ap_pitch_mode = 1	-- VS mode
							ap_pitch_mode_eng = 1
							simCMD_autopilot_vs:once()
							simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100)
							simDR_airspeed_dial = B738DR_mcp_speed_dial
						end
					elseif ap_pitch_mode_eng == 2 and B738DR_flight_phase < 2 then	-- LVL CHG mode during climb
						-- ap_pitch_mode = 1	-- VS mode
						-- ap_pitch_mode_eng = 1
						-- simCMD_autopilot_vs:once()
						-- simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100)
						simDR_airspeed_dial = simDR_airspeed_pilot
						--at_mode = 6		-- N1 LVL CHG
					end
					if autopilot_cws_a_status == 1 or autopilot_cws_b_status == 1 then
						simCMD_autopilot_cws:stop()
						autopilot_cws_a_status = 0
						autopilot_cws_b_status = 0
						ap_roll_mode_eng = 6
						ap_pitch_mode_eng = 6
					else
						simCMD_servos_on:once()
					end
					simDR_autopilot_side = 0
					if B738DR_autopilot_lnav_status == 0 then
						autopilot_fms_nav_status = 0
--						simDR_autopilot_side = 0
--					else
--						simDR_autopilot_side = 1
					end
				end
			elseif autopilot_cmd_a_status == 1
			and B738DR_autoland_status == 0 then		-- CMD A off
--				simCMD_autopilot_servos:once()
				simDR_flight_dir_mode = 1

				autopilot_cmd_a_status = 0
--				ap_roll_mode_eng = 0
--				ap_pitch_mode_eng = 0
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_cmd_a_pos = 0
	end
end

function B738_autopilot_cmd_b_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_cmd_b_pos = 1
		if B738DR_fd_on == 1 then
			if autopilot_cmd_b_status == 0 and B738DR_autopilot_disconnect_pos == 0
			and simDR_radio_height_pilot_ft > 400 and ap_app_block_800 == 0 then
				autopilot_cmd_b_status = 1
				ap_dis_time = 0
				if autopilot_cmd_a_status == 1
				and simDR_approach_status == 2
				and B738DR_autopilot_vhf_source_pos == 0 
				and simDR_radio_height_pilot_ft > 800 --then		-- AUTOLAND on
				and B738DR_autopilot_fd_pos == 1
				and B738DR_autopilot_fd_fo_pos == 1 then		-- if both F/D on, AUTOLAND on
					B738DR_autoland_status = 1
					ils_test_enable = 1
					cmd_first = 0	-- CMD A first
				else									-- CMD B on
					autopilot_cmd_a_status = 0
					ap_on = 1
					if at_mode_eng == 3 then	-- TAKEOFF mode
						if ap_pitch_mode == 0 then
							ap_pitch_mode = 2	-- LVL CHG
							--at_mode = 6		-- N1
							B738DR_lvl_chg_mode = 1
						else
							--if ap_vnav_status == 2 then
							if B738DR_autopilot_vnav_status == 1 then
								at_mode = 7
							else
								at_mode = 2			-- SPEED mode
							end
						end
						if ap_roll_mode == 0 then
							ap_roll_mode = 1	-- HDG SEL
						end
						if B738DR_fms_v2_15 == 0 then
							simDR_airspeed_dial = 180
						else
							simDR_airspeed_dial = B738DR_fms_v2_15
						end
					elseif at_mode_eng == 5 then	-- F/D GA
						ap_roll_mode = 1	-- HDG SEL
						ap_pitch_mode = 2	-- LVL CHG
						fd_goaround = 3		-- F/D GA with CMD
						at_mode = 0
						at_mode_eng = 0
					elseif at_mode == 1 and ap_pitch_mode_eng == 0 and B738DR_flight_phase < 2 then	-- no pitch mode during climb
						if simDR_airspeed_pilot > B738DR_mcp_speed_dial then
							ap_pitch_mode = 1	-- VS mode
							ap_pitch_mode_eng = 1
							simCMD_autopilot_vs:once()
							simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100)
							at_mode = 2		-- SPEED mode
							simDR_airspeed_dial = simDR_airspeed_pilot
						else
							ap_pitch_mode = 1	-- VS mode
							ap_pitch_mode_eng = 1
							simCMD_autopilot_vs:once()
							simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100)
							simDR_airspeed_dial = B738DR_mcp_speed_dial
						end
					elseif ap_pitch_mode_eng == 2 and B738DR_flight_phase < 2 then	-- LVL CHG mode during climb
						-- ap_pitch_mode = 1	-- VS mode
						-- ap_pitch_mode_eng = 1
						-- simCMD_autopilot_vs:once()
						-- simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100)
						simDR_airspeed_dial = simDR_airspeed_pilot
						--at_mode = 6		-- N1 LVL CHG
					end
					if autopilot_cws_a_status == 1 or autopilot_cws_b_status == 1 then
						simCMD_autopilot_cws:stop()
						autopilot_cws_a_status = 0
						autopilot_cws_b_status = 0
						ap_roll_mode_eng = 0
						ap_pitch_mode_eng = 0
					else
						simCMD_servos_on:once()
					end
--					simDR_autopilot_side = 1
					if B738DR_autopilot_lnav_status == 0 then
						autopilot_fms_nav_status = 0
						simDR_autopilot_side = 1
					else
						simDR_autopilot_side = 0
					end
				end
			elseif autopilot_cmd_b_status == 1
			and B738DR_autoland_status == 0 then		-- CMD B off
--				simCMD_autopilot_servos:once()
				simDR_flight_dir_mode = 1

				autopilot_cmd_b_status = 0
--				ap_roll_mode_eng = 0
--				ap_pitch_mode_eng = 0
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_cmd_b_pos = 0
	end
end

-- CWS A&B

function B738_autopilot_cws_a_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_cws_a_pos = 1
		if autopilot_cws_a_status == 0 and B738DR_fd_on == 1
		and B738DR_autoland_status == 0
		and B738DR_autopilot_disconnect_pos == 0 
		and ap_app_block_800 == 0 then
			autopilot_cmd_b_status = 0
			autopilot_cmd_a_status = 0
			autopilot_cws_b_status = 0
			autopilot_cws_a_status = 1
			simCMD_autopilot_cws:start()
			simDR_autopilot_side = 0
			if B738DR_autopilot_lnav_status == 0 then
				autopilot_fms_nav_status = 0
			end
		elseif autopilot_cws_a_status == 1  and B738DR_fd_on == 1 then
			simCMD_autopilot_cws:stop()
			autopilot_cws_a_status = 0
--			simCMD_servos_on:once()
			simDR_flight_dir_mode = 1

			ap_roll_mode_eng = 0
			ap_pitch_mode_eng = 0
		end
	elseif phase == 2 then
		B738DR_autopilot_cws_a_pos = 0
	end
end

function B738_autopilot_cws_b_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_cws_b_pos = 1
		if autopilot_cws_b_status == 0 and B738DR_fd_on == 1
		and B738DR_autoland_status == 0 
		and B738DR_autopilot_disconnect_pos == 0 
		and ap_app_block_800 == 0 then
			autopilot_cmd_b_status = 0
			autopilot_cmd_a_status = 0
			autopilot_cws_a_status = 0
			autopilot_cws_b_status = 1
			simCMD_autopilot_cws:start()
--			simDR_autopilot_side = 1
			if B738DR_autopilot_lnav_status == 0 then
				autopilot_fms_nav_status = 0
				simDR_autopilot_side = 1
			else
				simDR_autopilot_side = 0
			end
		elseif autopilot_cws_b_status == 1  and B738DR_fd_on == 1 then
			simCMD_autopilot_cws:stop()
			autopilot_cws_b_status = 0
			simDR_flight_dir_mode = 1

--			simCMD_servos_on:once()
			ap_roll_mode_eng = 0
			ap_pitch_mode_eng = 0
		end
	elseif phase == 2 then
		B738DR_autopilot_cws_b_pos = 0
	end
end


function B738_autopilot_disconect_button_CMDhandler(phase, duration)
	
	if phase == 0 then
		B738DR_autopilot_disco2 = 1
		if autopilot_cmd_a_status == 1 then
			simDR_flight_dir_mode = 1
			autopilot_cmd_a_status = 0
			ap_disco2 = 1
		end
		if autopilot_cmd_b_status == 1 then
			simDR_flight_dir_mode = 1
			autopilot_cmd_b_status = 0
			ap_disco2 = 1
		end
		if autopilot_cws_a_status == 1 then
			simCMD_autopilot_cws:stop()
			autopilot_cws_a_status = 0
			simDR_flight_dir_mode = 1
			ap_roll_mode_eng = 0
			ap_pitch_mode_eng = 0
			ap_disco2 = 1
		end
		if autopilot_cws_b_status == 1 then
			simCMD_autopilot_cws:stop()
			autopilot_cws_b_status = 0
			simDR_flight_dir_mode = 1
			ap_roll_mode_eng = 0
			ap_pitch_mode_eng = 0
			ap_disco2 = 1
		end
	elseif phase == 2 then
		B738DR_autopilot_disco2 = 0
		ap_disco2 = 0
	end
end

function B738_vhf_nav_source_switch_rgt_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_vhf_source_pos == -1 then
			B738DR_autopilot_vhf_source_pos = 0
		elseif B738DR_autopilot_vhf_source_pos == 0 then
			B738DR_autopilot_vhf_source_pos = 1
		end
	end
end

function B738_vhf_nav_source_switch_lft_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_vhf_source_pos == 1 then
			B738DR_autopilot_vhf_source_pos = 0
		elseif B738DR_autopilot_vhf_source_pos == 0 then
			B738DR_autopilot_vhf_source_pos = -1
		end
	end
end

---- Custom altitude dial up / down

function alt_up(dial)
	altitude_dial_ft = B738DR_mcp_alt_dial - B738DR_mcp_alt_dial % 100
	altitude_dial_ft = altitude_dial_ft + dial
	if altitude_dial_ft > 41000 then
		altitude_dial_ft = 41000
	end
	B738DR_mcp_alt_dial = altitude_dial_ft
end

function alt_dn(dial)
	altitude_dial_ft = B738DR_mcp_alt_dial - B738DR_mcp_alt_dial % 100
	if altitude_dial_ft > 0 then
		altitude_dial_ft = altitude_dial_ft - dial
		if altitude_dial_ft < 0 then
			altitude_dial_ft = 0
		end
		B738DR_mcp_alt_dial = altitude_dial_ft
	end
end


-- alt_up_active / alt_dn_active => 0-no repeat, 1-repeat start, 2-repeat continue
function alt_updn_timer()
	if alt_up_active ~= 0 then
		alt_timer = alt_timer + SIM_PERIOD
		if (alt_up_active == 1) and (alt_timer > 0.8) then
			alt_up_active = 2
			alt_timer = 0
			alt_up(1000)
		end
		if (alt_up_active == 2) and (alt_timer > 0.1) then
			alt_timer = 0
			alt_up(1000)
		end
	end
	if alt_dn_active ~= 0 then
		alt_timer = alt_timer + SIM_PERIOD
		if (alt_dn_active == 1) and (alt_timer > 0.8) then
			alt_dn_active = 2
			alt_timer = 0
			alt_dn(1000)
		end
		if (alt_dn_active == 2) and (alt_timer > 0.1) then
			alt_timer = 0
			alt_dn(1000)
		end
	end
end

function B738_ap_altitude_up_CMDhandler(phase, duration)
	if phase == 0  then
		alt_up(100)
	end
	if phase == 1 then
		if alt_up_active == 0 then
			alt_up_active = 1
		end
	end
	if phase == 2  then
		alt_up_active = 0
		alt_timer = 0
	end
end

function B738_ap_altitude_dn_CMDhandler(phase, duration)
	if phase == 0  then
		alt_dn(100)
	end
	if phase == 1 then
		if alt_dn_active == 0 then
			alt_dn_active = 1
		end
	end
	if phase == 2  then
		alt_dn_active = 0
		alt_timer = 0
	end
end

---- MFD: ENG and SYS

function B738_mfd_sys_CMDhandler(phase, duration)
	if phase == 0 then
		-- if B738DR_lowerDU_page == 0 then
			-- B738DR_lowerDU_page = 1
		-- elseif B738DR_lowerDU_page == 1 then
			-- B738DR_lowerDU_page = 2
		-- elseif B738DR_lowerDU_page == 2 then
			-- B738DR_lowerDU_page = 0
		-- end
		if B738DR_lowerDU_page == 2 then
			B738DR_lowerDU_page = 0
		else
			B738DR_lowerDU_page = 2
		end
	end
end

function B738_mfd_eng_CMDhandler(phase, duration)

	if phase == 0 then
		-- if B738DR_EICAS_page == 0 then
			-- B738DR_EICAS_page = 1
		-- else
			-- B738DR_EICAS_page = 0
		-- end
		if B738DR_lowerDU_page == 1 then
			B738DR_lowerDU_page = 0
		else
			B738DR_lowerDU_page = 1
		end
	end

end

--- A/P, A/T light buttons

function B738_ap_light_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_ap_light_pilot = 1
	elseif phase == 2 then
		B738DR_ap_light_pilot = 0
	end
end

function B738_at_light_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_at_light_pilot = 1
	elseif phase == 2 then
		B738DR_at_light_pilot = 0
	end
end

function B738_ap_light_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_ap_light_fo = 1
	elseif phase == 2 then
		B738DR_ap_light_fo = 0
	end
end

function B738_at_light_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_at_light_fo = 1
	elseif phase == 2 then
		B738DR_at_light_fo = 0
	end
end

-- TO/GA button
function B738_to_ga_CMDhandler(phase, duration)
	local ap_ga = 0
	local fd_ga = 0
	if phase == 0 then
		
		ap_app_block = 0
		
		--Takeoff mode
--		to_after_80kts = 0
		if B738DR_autopilot_autothr_arm_pos == 1 
		and B738DR_autobrake_RTO_arm < 2 then
			-- Takeoff without F/D on
			if simDR_airspeed_pilot > 80
			and simDR_radio_height_pilot_ft < 2000 
			and lift_off_150 == 0 
			and on_ground_30 == 1 then
				at_mode = 3				-- TAKEOFF mode
				to_after_80kts = 1
				B738DR_fd_pilot_show = 1
				B738DR_fd_copilot_show = 1
			end
			-- Takeoff with both F/D on
			if B738DR_autopilot_fd_pos == 1
			and B738DR_autopilot_fd_fo_pos == 1
			and simDR_airspeed_pilot < 60 then
				at_mode = 3				-- TAKEOFF mode
			end
		end
		
		--AP GoAround mode
		if B738DR_autopilot_autothr_arm_pos == 1 then
			if ap_goaround == 1 then
				ap_goaround = 2			-- second push
			end
			if B738DR_flare_status > 0 then
				if ap_goaround == 0 then
					if simDR_on_ground_0 == 0 and simDR_on_ground_1 == 0 
					and simDR_on_ground_2 == 0 then		-- if aircraft on ground
						if simDR_radio_height_pilot_ft < 2000 then
							ap_ga = 1
						else	--if simDR_radio_height_pilot_ft > 2000 then
							if simDR_flaps_ratio > 0
							or simDR_glideslope_status == 2 then
								ap_ga = 1
							end
						end
					end
					if ap_ga == 1 then
						ap_goaround = 1		-- first push
						at_mode = 4			-- AP GA
						if simDR_approach_status > 0 then
							simCMD_autopilot_app:once()
						end
						if simDR_nav_status > 0 then
							simCMD_autopilot_lnav:once()
						end
					end
				end
			else
				-- AP GoAround after touchdown
				if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 
				or simDR_on_ground_2 == 1 then		-- if aircraft on ground
					if ap_goaround_block == 0 then
						-- A/T automatic off disengage
						if is_timer_scheduled(ap_at_off) == true then
							stop_timer(ap_at_off)
						end
						-- A/P off
						simDR_flight_dir_mode = 1
						autopilot_cmd_a_status = 0
						autopilot_cmd_b_status = 0
						ap_roll_mode = 0
						ap_pitch_mode = 0
						at_mode = 8
					end
				end
			end
			--F/D GoAround mode
			if ap_on == 0 and B738DR_fd_on == 1 and at_mode ~= 3 then
				if fd_goaround == 0 then
					if simDR_radio_height_pilot_ft < 2000 
					-- and simDR_on_ground_0 == 0 and simDR_on_ground_1 == 0 
					-- and simDR_on_ground_2 == 0 then
					and ap_goaround_block == 0 then
						fd_ga = 1
						if is_timer_scheduled(ap_at_off) == true then
							stop_timer(ap_at_off)
						end
					end
					if simDR_radio_height_pilot_ft > 2000 then
						if simDR_flaps_ratio > 0
						or simDR_glideslope_status == 2 then
							fd_ga = 1
						end
					end
					if fd_ga == 1 then
						fd_goaround = 1		-- first push
						at_mode = 5			-- FD GA
					end
				elseif fd_goaround == 1 then
					fd_goaround  = 2
				end
			end
		end
	end
end



-- N1 SET SWITCH
function B738_n1_set_source_left_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_n1_set_source == -1 then
			B738DR_n1_set_source = -2
			B738DR_n1_set_adjust = eng2_N1_man
			B738DR_eng1_N1_bug = eng1_N1_man
		elseif B738DR_n1_set_source == 0 then
			B738DR_n1_set_source = -1
			B738DR_n1_set_adjust = eng1_N1_man
			B738DR_eng2_N1_bug = eng2_N1_man
		elseif B738DR_n1_set_source == 1 then
			B738DR_n1_set_source = 0
			B738DR_eng1_N1_bug = eng1_N1_man
			B738DR_eng2_N1_bug = eng2_N1_man
		end
	end
end

function B738_n1_set_source_right_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_n1_set_source == -2 then
			B738DR_n1_set_source = -1
			B738DR_n1_set_adjust = eng1_N1_man
		elseif B738DR_n1_set_source == -1 then
			B738DR_n1_set_source = 0
		elseif B738DR_n1_set_source == 0 then
			B738DR_n1_set_source = 1
			B738DR_n1_set_adjust = eng1_N1_man
		end
	end
end

-- -- N1 SET ADJUST KNOB
-- function B738_n1_set_adj_left_CMDhandler(phase, duration)
	-- if phase == 0 then
		-- if B738DR_n1_set_adjust > 101 then
			-- B738DR_n1_set_adjust = B738DR_n1_set_adjust - 1
		-- end
	-- end
-- end

-- function B738_n1_set_adj_right_CMDhandler(phase, duration)
	-- if phase == 0 then
		-- if B738DR_n1_set_adjust < 251 then
			-- B738DR_n1_set_adjust = B738DR_n1_set_adjust + 1
		-- end
	-- end
-- end

---- Custom course pilot dial up / down


function crs1_up(dial)
	local crs1_dial = 0
	crs1_dial = simDR_crs1 + dial
	if crs1_dial > 359 then
		crs1_dial = crs1_dial - 360
	end
	simDR_crs1 = math.floor(crs1_dial + 0.5)
	simDR_crs1_nav2 = simDR_crs1
	B738DR_course_pilot = simDR_crs1
end

function crs1_dn(dial)
	local crs1_dial = 0
	crs1_dial = simDR_crs1 - dial
	if crs1_dial < 0 then
		crs1_dial = 360 + crs1_dial
	end
	simDR_crs1 = math.floor(crs1_dial + 0.5)
	simDR_crs1_nav2 = simDR_crs1
	B738DR_course_pilot = simDR_crs1
end

-- function crs1_up(dial)
	-- local crs1_dial = 0
	-- crs1_dial = simDR_hsi_crs1 + dial
	-- if crs1_dial > 359 then
		-- crs1_dial = crs1_dial - 360
	-- end
	-- simDR_hsi_crs1 = crs1_dial
	-- --simDR_crs1_nav2 = simDR_hsi_crs1
-- end

-- function crs1_dn(dial)
	-- local crs1_dial = 0
	-- crs1_dial = simDR_hsi_crs1 - dial
	-- if crs1_dial < 0 then
		-- crs1_dial = 360 + crs1_dial
	-- end
	-- simDR_hsi_crs1 = crs1_dial
	-- --simDR_crs1_nav2 = simDR_hsi_crs1
-- end

-- crs1_up_active / crs2_dn_active => 0-no repeat, 1-repeat start, 2-repeat continue
function crs1_updn_timer()
	if crs1_up_active ~= 0 then
		crs1_timer = crs1_timer + SIM_PERIOD
		if (crs1_up_active == 1) and (crs1_timer > 0.6) then
			crs1_up_active = 2
			crs1_timer = 0
			crs1_up(1)
		end
		if (crs1_up_active == 2) and (crs1_timer > 0.05) then
			crs1_timer = 0
			crs1_up(1)
		end
	end
	if crs1_dn_active ~= 0 then
		crs1_timer = crs1_timer + SIM_PERIOD
		if (crs1_dn_active == 1) and (crs1_timer > 0.6) then
			crs1_dn_active = 2
			crs1_timer = 0
			crs1_dn(1)
		end
		if (crs1_dn_active == 2) and (crs1_timer > 0.05) then
			crs1_timer = 0
			crs1_dn(1)
		end
	end
end

function B738_course_pilot_up_CMDhandler(phase, duration)
	if phase == 0  then
		crs1_up(1)
	end
	if phase == 1 then
		if crs1_up_active == 0 then
			crs1_up_active = 1
		end
	end
	if phase == 2  then
		crs1_up_active = 0
		crs1_timer = 0
	end
end

function B738_course_pilot_dn_CMDhandler(phase, duration)
	if phase == 0  then
		crs1_dn(1)
	end
	if phase == 1 then
		if crs1_dn_active == 0 then
			crs1_dn_active = 1
		end
	end
	if phase == 2  then
		crs1_dn_active = 0
		crs1_timer = 0
	end
end

-- Custom course copilot dial up / down

function crs2_up(dial)
	local crs2_dial = 0
	crs2_dial = simDR_crs2 + dial
	if crs2_dial > 359 then
		crs2_dial = crs2_dial - 360
	end
	simDR_crs2 = math.floor(crs2_dial + 0.5)
	simDR_crs2_nav2 = simDR_crs2
	B738DR_course_copilot = simDR_crs2
end

function crs2_dn(dial)
	local crs2_dial = 0
	crs2_dial = simDR_crs2 - dial
	if crs2_dial < 0 then
		crs2_dial = 360 + crs2_dial
	end
	simDR_crs2 = math.floor(crs2_dial + 0.5)
	simDR_crs2_nav2 = simDR_crs2
	B738DR_course_copilot = simDR_crs2
end

-- function crs2_up(dial)
	-- local crs2_dial = 0
	-- crs2_dial = simDR_hsi_crs2 + dial
	-- if crs2_dial > 359 then
		-- crs2_dial = crs2_dial - 360
	-- end
	-- simDR_hsi_crs2 = crs2_dial
	-- --simDR_crs2_nav2 = simDR_hsi_crs2
-- end

-- function crs2_dn(dial)
	-- local crs2_dial = 0
	-- crs2_dial = simDR_hsi_crs2 - dial
	-- if crs2_dial < 0 then
		-- crs2_dial = 360 + crs2_dial
	-- end
	-- simDR_hsi_crs2 = crs2_dial
	-- --simDR_crs2_nav2 = simDR_hsi_crs2
-- end

-- crs2_up_active / crs2_dn_active => 0-no repeat, 1-repeat start, 2-repeat continue
function crs2_updn_timer()
	if crs2_up_active ~= 0 then
		crs2_timer = crs2_timer + SIM_PERIOD
		if (crs2_up_active == 1) and (crs2_timer > 0.6) then
			crs2_up_active = 2
			crs2_timer = 0
			crs2_up(1)
		end
		if (crs2_up_active == 2) and (crs2_timer > 0.05) then
			crs2_timer = 0
			crs2_up(1)
		end
	end
	if crs2_dn_active ~= 0 then
		crs2_timer = crs2_timer + SIM_PERIOD
		if (crs2_dn_active == 1) and (crs2_timer > 0.6) then
			crs2_dn_active = 2
			crs2_timer = 0
			crs2_dn(1)
		end
		if (crs2_dn_active == 2) and (crs2_timer > 0.05) then
			crs2_timer = 0
			crs2_dn(1)
		end
	end
end

function B738_course_copilot_up_CMDhandler(phase, duration)
	if phase == 0  then
		crs2_up(1)
	end
	if phase == 1 then
		if crs2_up_active == 0 then
			crs2_up_active = 1
		end
	end
	if phase == 2  then
		crs2_up_active = 0
		crs2_timer = 0
	end
end

function B738_course_copilot_dn_CMDhandler(phase, duration)
	if phase == 0  then
		crs2_dn(1)
	end
	if phase == 1 then
		if crs2_dn_active == 0 then
			crs2_dn_active = 1
		end
	end
	if phase == 2  then
		crs2_dn_active = 0
		crs2_timer = 0
	end
end


-- baro_pilot_up_active / baro_pilot_dn_active => 0-no repeat, 1-repeat start, 2-repeat continue
function baro_pilot_updn_timer()
	if baro_pilot_up_active ~= 0 then
		baro_pilot_timer = baro_pilot_timer + SIM_PERIOD
		if (baro_pilot_up_active == 1) and (baro_pilot_timer > 0.3) then
			baro_pilot_timer = 0.5
			if B738DR_baro_sel_in_hg_pilot < 40 then
				B738DR_baro_sel_in_hg_pilot = B738DR_baro_sel_in_hg_pilot + 0.01
			end
		end
	end
	if baro_pilot_dn_active ~= 0 then
		baro_pilot_timer = baro_pilot_timer + SIM_PERIOD
		if (baro_pilot_dn_active == 1) and (baro_pilot_timer > 0.3) then
			baro_pilot_timer = 0.5
			if B738DR_baro_sel_in_hg_pilot > 0 then
				B738DR_baro_sel_in_hg_pilot = B738DR_baro_sel_in_hg_pilot - 0.01
			end
		end
	end
end

function B738CMD_baro_pilot_up_CMDhandler(phase, duration)
	if phase == 0  then
		if B738DR_baro_sel_in_hg_pilot < 40 then
			B738DR_baro_sel_in_hg_pilot = B738DR_baro_sel_in_hg_pilot + 0.01
		end
	end
	if phase == 1 then
		if baro_pilot_up_active == 0 then
			baro_pilot_up_active = 1
		end
	end
	if phase == 2  then
		baro_pilot_up_active = 0
		baro_pilot_timer = 0
	end
end

function B738CMD_baro_pilot_dn_CMDhandler(phase, duration)
	if phase == 0  then
		if B738DR_baro_sel_in_hg_pilot > 0 then
			B738DR_baro_sel_in_hg_pilot = B738DR_baro_sel_in_hg_pilot - 0.01
		end
	end
	if phase == 1 then
		if baro_pilot_dn_active == 0 then
			baro_pilot_dn_active = 1
		end
	end
	if phase == 2  then
		baro_pilot_dn_active = 0
		baro_pilot_timer = 0
	end
end

-- baro_copilot_up_active / baro_copilot_dn_active => 0-no repeat, 1-repeat start, 2-repeat continue
function baro_copilot_updn_timer()
	if baro_copilot_up_active ~= 0 then
		baro_copilot_timer = baro_copilot_timer + SIM_PERIOD
		if (baro_copilot_up_active == 1) and (baro_copilot_timer > 0.3) then
			baro_copilot_timer = 0.5
			if B738DR_baro_sel_in_hg_copilot < 40 then
				B738DR_baro_sel_in_hg_copilot = B738DR_baro_sel_in_hg_copilot + 0.01
			end
		end
	end
	if baro_copilot_dn_active ~= 0 then
		baro_copilot_timer = baro_copilot_timer + SIM_PERIOD
		if (baro_copilot_dn_active == 1) and (baro_copilot_timer > 0.3) then
			baro_copilot_timer = 0.5
			if B738DR_baro_sel_in_hg_copilot > 0 then
				B738DR_baro_sel_in_hg_copilot = B738DR_baro_sel_in_hg_copilot - 0.01
			end
		end
	end
end

function B738CMD_baro_copilot_up_CMDhandler(phase, duration)
	if phase == 0  then
		if B738DR_baro_sel_in_hg_copilot < 40 then
			B738DR_baro_sel_in_hg_copilot = B738DR_baro_sel_in_hg_copilot + 0.01
		end
	end
	if phase == 1 then
		if baro_copilot_up_active == 0 then
			baro_copilot_up_active = 1
		end
	end
	if phase == 2  then
		baro_copilot_up_active = 0
		baro_copilot_timer = 0
	end
end

function B738CMD_baro_copilot_dn_CMDhandler(phase, duration)
	if phase == 0  then
		if B738DR_baro_sel_in_hg_copilot > 0 then
			B738DR_baro_sel_in_hg_copilot = B738DR_baro_sel_in_hg_copilot - 0.01
		end
	end
	if phase == 1 then
		if baro_copilot_dn_active == 0 then
			baro_copilot_dn_active = 1
		end
	end
	if phase == 2  then
		baro_copilot_dn_active = 0
		baro_copilot_timer = 0
	end
end


function B738_ap_heading_up_CMDhandler(phase, duration)
	if phase == 0  then
		B738DR_mcp_hdg_dial = (B738DR_mcp_hdg_dial + 1) % 360
		mcp_hdg_timer = 0
	elseif phase == 1 then
		mcp_hdg_timer = mcp_hdg_timer + SIM_PERIOD
		if mcp_hdg_timer > 0.5 then
			B738DR_mcp_hdg_dial = (B738DR_mcp_hdg_dial + 1) % 360
			mcp_hdg_timer = 0.6
		end
	elseif phase == 2  then
		mcp_hdg_timer = 0
	end
end

function B738_ap_heading_dn_CMDhandler(phase, duration)
	if phase == 0  then
		B738DR_mcp_hdg_dial = B738DR_mcp_hdg_dial - 1
		if B738DR_mcp_hdg_dial < 0 then
			B738DR_mcp_hdg_dial = 360 + B738DR_mcp_hdg_dial
		end
		mcp_hdg_timer = 0
	elseif phase == 1 then
		mcp_hdg_timer = mcp_hdg_timer + SIM_PERIOD
		if mcp_hdg_timer > 0.5 then
			B738DR_mcp_hdg_dial = B738DR_mcp_hdg_dial - 1
			if B738DR_mcp_hdg_dial < 0 then
				B738DR_mcp_hdg_dial = 360 + B738DR_mcp_hdg_dial
			end
			mcp_hdg_timer = 0.6
		end
	elseif phase == 2  then
		mcp_hdg_timer = 0
	end
end


--- SPD INTV ---
function B738_autopilot_spd_interv_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_spd_interv_pos = 1
		if B738DR_autopilot_vnav_status == 1 and vnav_engaged == 1 then
			if B738DR_ap_spd_interv_status == 0 then
				B738DR_ap_spd_interv_status = 1
				if B738DR_flight_phase > 4 then
					if B738DR_vnav_desc_spd_disable == 0 and vnav_desc_spd == 0 and B738DR_pfd_spd_mode == PFD_SPD_ARM then
						vnav_desc_spd = 1
					else
						vnav_desc_spd = 0
					end
				end
				simDR_airspeed_dial_kts = simDR_airspeed_pilot
			else
				B738DR_ap_spd_interv_status = 0
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_spd_interv_pos = 0
	end
end

function B738_ap_alt_up_CMDhandler(phase, duration)
	if phase == 0 then
		B738CMD_ap_altitude_up:once()
	end
end

function B738_ap_alt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		B738CMD_ap_altitude_dn:once()
	end
end

function B738_ap_crs_pilot_up_CMDhandler(phase, duration)
	if phase == 0 then
		B738_course_pilot_up:once()
	end
end

function B738_ap_crs_pilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
		B738_course_pilot_dn:once()
	end
end

function B738_ap_crs_copilot_up_CMDhandler(phase, duration)
	if phase == 0 then
		B738_course_copilot_up:once()
	end
end

function B738_ap_crs_copilot_dn_CMDhandler(phase, duration)
	if phase == 0 then
		B738_course_copilot_dn:once()
	end
end

function B738_ap_left_toga_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_left_toga_pos = 1
		simCMD_take_off_go_around:once()
	elseif phase == 2 then
		B738DR_autopilot_left_toga_pos = 0
	end
end

function B738_ap_right_toga_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_right_toga_pos = 1
		simCMD_take_off_go_around:once()
	elseif phase == 2 then
		B738DR_autopilot_right_toga_pos = 0
	end
end

function B738_ap_left_atds_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_left_at_diseng_pos = 1
		B738DR_autopilot_autothr_arm_pos = 0
		B738DR_autopilot_autothrottle_status = 0
		at_mode = 0
		simCMD_autothrottle_discon:once()	-- disconnect autothrotle
	elseif phase == 2 then
		B738DR_autopilot_left_at_diseng_pos = 0
	end
end

function B738_ap_right_atds_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_right_at_diseng_pos = 1
		B738DR_autopilot_autothr_arm_pos = 0
		B738DR_autopilot_autothrottle_status = 0
		at_mode = 0
		simCMD_autothrottle_discon:once()	-- disconnect autothrotle
	elseif phase == 2 then
		B738DR_autopilot_right_at_diseng_pos = 0
	end
end


function B738_mic_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_mic_pos = 1
		simCMD_take_off_go_around:once()
	elseif phase == 2 then
		B738DR_mic_pos = 0
	end
end

--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

B738CMD_mic					= create_command("laminar/B738/push_button/mic", "MIC (TO/GA button)", B738_mic_CMDhandler)

B738CMD_autopilot_left_toga_press	= create_command("laminar/B738/autopilot/left_toga_press", "Left TO/GA", B738_ap_left_toga_press_CMDhandler)
B738CMD_autopilot_right_toga_press	= create_command("laminar/B738/autopilot/right_toga_press", "Right TO/GA", B738_ap_right_toga_press_CMDhandler)

B738CMD_autopilot_left_atds_press	= create_command("laminar/B738/autopilot/left_at_dis_press", "Left A/T disengage", B738_ap_left_atds_press_CMDhandler)
B738CMD_autopilot_right_atds_press	= create_command("laminar/B738/autopilot/right_at_dis_press", "Right A/T disengage", B738_ap_right_atds_press_CMDhandler)

-- CAPT and F/O minimums
B738CMD_fo_minimums_up = create_command("laminar/B738/EFIS_control/fo/minimums_up", "FO Minimums select up", B738_fo_minimums_up_CMDhandler)
B738CMD_fo_minimums_dn = create_command("laminar/B738/EFIS_control/fo/minimums_dn", "FO Minimums select down", B738_fo_minimums_dn_CMDhandler)
B738CMD_cpt_minimums_up = create_command("laminar/B738/EFIS_control/cpt/minimums_up", "CAPT Minimums select up", B738_cpt_minimums_up_CMDhandler)
B738CMD_cpt_minimums_dn = create_command("laminar/B738/EFIS_control/cpt/minimums_dn", "CAPT Minimums select down", B738_cpt_minimums_dn_CMDhandler)

-- CAPT EFIS COMMANDS
B738CMD_dh_pilot_up			= create_command("laminar/B738/pfd/dh_pilot_up", "Captain DH up", B738_dh_pilot_up_CMDhandler)
B738CMD_dh_pilot_dn			= create_command("laminar/B738/pfd/dh_pilot_dn", "Captain DH down", B738_dh_pilot_dn_CMDhandler)
B738CMD_dh_pilot_up1		= create_command("laminar/B738/pfd/dh_pilot_up1", "Captain DH up 1 detend", B738_dh_pilot_up1_CMDhandler)
B738CMD_dh_pilot_up2		= create_command("laminar/B738/pfd/dh_pilot_up2", "Captain DH up 2 detend", B738_dh_pilot_up2_CMDhandler)
B738CMD_dh_pilot_dn1		= create_command("laminar/B738/pfd/dh_pilot_dn1", "Captain DH down 1 detend", B738_dh_pilot_dn1_CMDhandler)
B738CMD_dh_pilot_dn2		= create_command("laminar/B738/pfd/dh_pilot_dn2", "Captain DH down 2 detend", B738_dh_pilot_dn2_CMDhandler)

B738CMD_efis_wxr_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/wxr_press", "CAPT EFIS Weather", B738_efis_wxr_capt_CMDhandler)
B738CMD_efis_sta_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/sta_press", "CAPT EFIS Station", B738_efis_sta_capt_CMDhandler)
B738CMD_efis_wpt_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/wpt_press", "CAPT EFIS Waypoint", B738_efis_wpt_capt_CMDhandler)
B738CMD_efis_arpt_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/arpt_press", "CAPT EFIS Airport", B738_efis_arpt_capt_CMDhandler)
B738CMD_efis_data_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/data_press", "CAPT EFIS DATA", B738_efis_data_capt_CMDhandler)
B738CMD_efis_pos_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/pos_press", "CAPT EFIS Position", B738_efis_pos_capt_CMDhandler)
B738CMD_efis_terr_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/terr_press", "CAPT EFIS Terrain", B738_efis_terr_capt_CMDhandler)

B738CMD_efis_rst_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/rst_press", "CAPT EFIS Reset", B738_efis_rst_capt_CMDhandler)
B738CMD_efis_ctr_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/ctr_press", "CAPT EFIS Center", B738_efis_ctr_capt_CMDhandler)
B738CMD_efis_tfc_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/tfc_press", "CAPT EFIS Traffic", B738_efis_tfc_capt_CMDhandler)
B738CMD_efis_std_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/std_press", "CAPT EFIS Standard", B738_efis_std_capt_CMDhandler)

B738CMD_efis_mtrs_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/mtrs_press", "CAPT ALT in Meters", B738_efis_mtrs_capt_CMDhandler)
B738CMD_efis_fpv_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/fpv_press", "CAPT Flight Path Vector", B738_efis_fpv_capt_CMDhandler)

B738CMD_efis_baro_mode_capt_up 	= create_command("laminar/B738/EFIS_control/capt/baro_in_hpa_up", "CAPT Baro Mode HPA", B738_efis_baro_mode_capt_up_CMDhandler)
B738CMD_efis_baro_mode_capt_dn 	= create_command("laminar/B738/EFIS_control/capt/baro_in_hpa_dn", "CAPT Baro Mode IN", B738_efis_baro_mode_capt_dn_CMDhandler)

B738CMD_efis_vor1_capt_up 		= create_command("laminar/B738/EFIS_control/capt/vor1_off_up", "CAPT VOR1 Up", B738_efis_vor1_capt_up_CMDhandler)
B738CMD_efis_vor1_capt_dn 		= create_command("laminar/B738/EFIS_control/capt/vor1_off_dn", "CAPT VOR1 Down", B738_efis_vor1_capt_dn_CMDhandler)
B738CMD_efis_vor2_capt_up 		= create_command("laminar/B738/EFIS_control/capt/vor2_off_up", "CAPT VOR1 Up", B738_efis_vor2_capt_up_CMDhandler)
B738CMD_efis_vor2_capt_dn 		= create_command("laminar/B738/EFIS_control/capt/vor2_off_dn", "CAPT VOR1 Down", B738_efis_vor2_capt_dn_CMDhandler)

B738CMD_efis_map_range_capt_up	= create_command("laminar/B738/EFIS_control/capt/map_range_up", "CAPT EFIS Map range Up", B738_efis_map_range_capt_up_CMDhandler)
B738CMD_efis_map_range_capt_dn	= create_command("laminar/B738/EFIS_control/capt/map_range_dn", "CAPT EFIS Map range Down", B738_efis_map_range_capt_dn_CMDhandler)

B738CMD_efis_map_mode_capt_up 	= create_command("laminar/B738/EFIS_control/capt/map_mode_up", "CAPT MAP mode Up", B738_efis_map_mode_capt_up_CMDhandler)
B738CMD_efis_map_mode_capt_dn 	= create_command("laminar/B738/EFIS_control/capt/map_mode_dn", "CAPT MAP mode Down", B738_efis_map_mode_capt_dn_CMDhandler)


-- FO EFIS COMMANDS
B738CMD_dh_copilot_up		= create_command("laminar/B738/pfd/dh_copilot_up", "First Officer DH up", B738_dh_copilot_up_CMDhandler)
B738CMD_dh_copilot_dn		= create_command("laminar/B738/pfd/dh_copilot_dn", "First Officer DH down", B738_dh_copilot_dn_CMDhandler)
B738CMD_dh_copilot_up1		= create_command("laminar/B738/pfd/dh_copilot_up1", "First Officer DH up 1 detend", B738_dh_copilot_up1_CMDhandler)
B738CMD_dh_copilot_up2		= create_command("laminar/B738/pfd/dh_copilot_up2", "First Officer DH up 2 detend", B738_dh_copilot_up2_CMDhandler)
B738CMD_dh_copilot_dn1		= create_command("laminar/B738/pfd/dh_copilot_dn1", "First Officer DH down 1 detend", B738_dh_copilot_dn1_CMDhandler)
B738CMD_dh_copilot_dn2		= create_command("laminar/B738/pfd/dh_copilot_dn2", "First Officer DH down 2 detend", B738_dh_copilot_dn2_CMDhandler)


B738CMD_efis_wxr_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/wxr_press", "fo EFIS Weather", B738_efis_wxr_fo_CMDhandler)
B738CMD_efis_sta_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/sta_press", "fo EFIS Station", B738_efis_sta_fo_CMDhandler)
B738CMD_efis_wpt_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/wpt_press", "fo EFIS Waypoint", B738_efis_wpt_fo_CMDhandler)
B738CMD_efis_arpt_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/arpt_press", "fo EFIS Airport", B738_efis_arpt_fo_CMDhandler)
B738CMD_efis_data_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/data_press", "fo EFIS DATA", B738_efis_data_fo_CMDhandler)
B738CMD_efis_pos_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/pos_press", "fo EFIS Position", B738_efis_pos_fo_CMDhandler)
B738CMD_efis_terr_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/terr_press", "fo EFIS Terrain", B738_efis_terr_fo_CMDhandler)

B738CMD_efis_rst_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/rst_press", "fo EFIS Reset", B738_efis_rst_fo_CMDhandler)
B738CMD_efis_ctr_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/ctr_press", "fo EFIS Center", B738_efis_ctr_fo_CMDhandler)
B738CMD_efis_tfc_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/tfc_press", "fo EFIS Traffic", B738_efis_tfc_fo_CMDhandler)
B738CMD_efis_std_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/std_press", "fo EFIS Standard", B738_efis_std_fo_CMDhandler)

B738CMD_efis_mtrs_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/mtrs_press", "fo ALT in Meters", B738_efis_mtrs_fo_CMDhandler)
B738CMD_efis_fpv_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/fpv_press", "fo Flight Path Vector", B738_efis_fpv_fo_CMDhandler)

B738CMD_efis_baro_mode_fo_up 	= create_command("laminar/B738/EFIS_control/fo/baro_in_hpa_up", "fo Baro Mode HPA", B738_efis_baro_mode_fo_up_CMDhandler)
B738CMD_efis_baro_mode_fo_dn 	= create_command("laminar/B738/EFIS_control/fo/baro_in_hpa_dn", "fo Baro Mode IN", B738_efis_baro_mode_fo_dn_CMDhandler)

B738CMD_efis_vor1_fo_up 		= create_command("laminar/B738/EFIS_control/fo/vor1_off_up", "fo VOR1 Up", B738_efis_vor1_fo_up_CMDhandler)
B738CMD_efis_vor1_fo_dn 		= create_command("laminar/B738/EFIS_control/fo/vor1_off_dn", "fo VOR1 Down", B738_efis_vor1_fo_dn_CMDhandler)

B738CMD_efis_vor2_fo_up 		= create_command("laminar/B738/EFIS_control/fo/vor2_off_up", "fo VOR1 Up", B738_efis_vor2_fo_up_CMDhandler)
B738CMD_efis_vor2_fo_dn 		= create_command("laminar/B738/EFIS_control/fo/vor2_off_dn", "fo VOR1 Down", B738_efis_vor2_fo_dn_CMDhandler)

B738CMD_efis_map_mode_fo_up 	= create_command("laminar/B738/EFIS_control/fo/map_mode_up", "FO MAP mode Up", B738_efis_map_mode_fo_up_CMDhandler)
B738CMD_efis_map_mode_fo_dn 	= create_command("laminar/B738/EFIS_control/fo/map_mode_dn", "FO MAP mode Down", B738_efis_map_mode_fo_dn_CMDhandler)

B738CMD_efis_map_range_fo_up	= create_command("laminar/B738/EFIS_control/fo/map_range_up", "FO EFIS Map range Up", B738_efis_map_range_fo_up_CMDhandler)
B738CMD_efis_map_range_fo_dn	= create_command("laminar/B738/EFIS_control/fo/map_range_dn", "FO EFIS Map range Down", B738_efis_map_range_fo_dn_CMDhandler)


----- AP COMMANDS

B738CMD_autopilot_n1_press				= create_command("laminar/B738/autopilot/n1_press", "N1 Mode", B738_autopilot_n1_press_CMDhandler)
B738CMD_autopilot_speed_press			= create_command("laminar/B738/autopilot/speed_press", "Speed Mode", B738_autopilot_speed_press_CMDhandler)
B738CMD_autopilot_lvl_chg_press			= create_command("laminar/B738/autopilot/lvl_chg_press", "Level Change Mode", B738_autopilot_lvl_chg_press_CMDhandler)
B738CMD_autopilot_vnav_press			= create_command("laminar/B738/autopilot/vnav_press", "Vertical NAV Mode", B738_autopilot_vnav_press_CMDhandler)
B738CMD_autopilot_co_press				= create_command("laminar/B738/autopilot/change_over_press", "IAS MACH Change Over", B738_autopilot_co_press_CMDhandler)

B738CMD_autopilot_lnav_press			= create_command("laminar/B738/autopilot/lnav_press", "FMS Lateral NAV Mode", B738_autopilot_lnav_press_CMDhandler)
B738CMD_autopilot_vorloc_press			= create_command("laminar/B738/autopilot/vorloc_press", "VOR Localizer Mode", B738_autopilot_vorloc_press_CMDhandler)
B738CMD_autopilot_app_press				= create_command("laminar/B738/autopilot/app_press", "Approach Mode", B738_autopilot_app_press_CMDhandler)
B738CMD_autopilot_hdg_sel_press			= create_command("laminar/B738/autopilot/hdg_sel_press", "Heading Select Mode", B738_autopilot_hdg_sel_press_CMDhandler)

B738CMD_autopilot_alt_hld_press			= create_command("laminar/B738/autopilot/alt_hld_press", "Altitude Hold Mode", B738_autopilot_alt_hld_press_CMDhandler)
B738CMD_autopilot_vs_press				= create_command("laminar/B738/autopilot/vs_press", "Vertical Speed Mode", B738_autopilot_vs_press_CMDhandler)

B738CMD_autopilot_disconnect_toggle		= create_command("laminar/B738/autopilot/disconnect_toggle", "AP Disconnect", B738_autopilot_disconnect_toggle_CMDhandler)
B738CMD_autopilot_autothr_arm_toggle	= create_command("laminar/B738/autopilot/autothrottle_arm_toggle", "Autothrottle ARM", B738_autopilot_autothr_arm_toggle_CMDhandler)
B738CMD_autopilot_flight_dir_toggle		= create_command("laminar/B738/autopilot/flight_director_toggle", "Flight Director", B738_autopilot_flight_dir_toggle_CMDhandler)
B738CMD_autopilot_flight_dir_fo_toggle	= create_command("laminar/B738/autopilot/flight_director_fo_toggle", "First Officer Flight Director", B738_autopilot_flight_dir_fo_toggle_CMDhandler)
B738CMD_autopilot_bank_angle_up			= create_command("laminar/B738/autopilot/bank_angle_up", "Bank Angle Increase", B738_autopilot_bank_angle_up_CMDhandler)
B738CMD_autopilot_bank_angle_dn			= create_command("laminar/B738/autopilot/bank_angle_dn", "Bank Angle Decrease", B738_autopilot_bank_angle_dn_CMDhandler)

B738CMD_autopilot_cmd_a_press			= create_command("laminar/B738/autopilot/cmd_a_press", "Command A", B738_autopilot_cmd_a_press_CMDhandler)
B738CMD_autopilot_cmd_b_press			= create_command("laminar/B738/autopilot/cmd_b_press", "Command B", B738_autopilot_cmd_b_press_CMDhandler)
B738CMD_autopilot_disconect_button		= create_command("laminar/B738/autopilot/disconnect_button", "AP Disconnect button", B738_autopilot_disconect_button_CMDhandler)

B738CMD_autopilot_cws_a_press			= create_command("laminar/B738/autopilot/cws_a_press", "Control Wheel Steering A", B738_autopilot_cws_a_press_CMDhandler)
B738CMD_autopilot_cws_b_press			= create_command("laminar/B738/autopilot/cws_b_press", "Control Wheel Steering B", B738_autopilot_cws_b_press_CMDhandler)

B738CMD_vhf_nav_source_switch_lft		= create_command("laminar/B738/toggle_switch/vhf_nav_source_lft", "VHF SOURCE LEFT", B738_vhf_nav_source_switch_lft_CMDhandler)
B738CMD_vhf_nav_source_switch_rgt		= create_command("laminar/B738/toggle_switch/vhf_nav_source_rgt", "VHF SOURCE RIGHT", B738_vhf_nav_source_switch_rgt_CMDhandler)


--- AP altitude dial ft
B738CMD_ap_altitude_up 		= create_command("laminar/B738/autopilot/altitude_up", "AP altitude Up", B738_ap_altitude_up_CMDhandler)
B738CMD_ap_altitude_dn 		= create_command("laminar/B738/autopilot/altitude_dn", "AP altitude Down", B738_ap_altitude_dn_CMDhandler)


B738CMD_ap_heading_up 		= create_command("laminar/B738/autopilot/heading_up", "AP heading Up", B738_ap_heading_up_CMDhandler)
B738CMD_ap_heading_dn 		= create_command("laminar/B738/autopilot/heading_dn", "AP heading Down", B738_ap_heading_dn_CMDhandler)



B738_course_pilot_up		= create_command("laminar/B738/autopilot/course_pilot_up", "CRS Pilot Up", B738_course_pilot_up_CMDhandler)
B738_course_pilot_dn		= create_command("laminar/B738/autopilot/course_pilot_dn", "CRS Pilot Down", B738_course_pilot_dn_CMDhandler)
B738_course_copilot_up		= create_command("laminar/B738/autopilot/course_copilot_up", "CRS Copilot Up", B738_course_copilot_up_CMDhandler)
B738_course_copilot_dn		= create_command("laminar/B738/autopilot/course_copilot_dn", "CRS Copilot Down", B738_course_copilot_dn_CMDhandler)

B738CMD_mfd_sys		 		= create_command("laminar/B738/LDU_control/push_button/MFD_SYS", "MFD SYS", B738_mfd_sys_CMDhandler)
B738CMD_mfd_eng		 		= create_command("laminar/B738/LDU_control/push_button/MFD_ENG", "MFD ENG", B738_mfd_eng_CMDhandler)

-- TEMORARY TO/GA BUTTON
--B738CMD_mfd_eng		 		= create_command("laminar/B738/LDU_control/push_button/MFD_ENG", "Temporary TO/GA button", B738_to_ga_CMDhandler)


-- A/P, A/T light buttons
B738CMD_ap_light_pilot		 	= create_command("laminar/B738/push_button/ap_light_pilot", "A/P light captain button", B738_ap_light_pilot_CMDhandler)
B738CMD_at_light_pilot		 	= create_command("laminar/B738/push_button/at_light_pilot", "A/T light captain button", B738_at_light_pilot_CMDhandler)
B738CMD_ap_light_fo		 		= create_command("laminar/B738/push_button/ap_light_fo", "A/P light FO button", B738_ap_light_fo_CMDhandler)
B738CMD_at_light_fo		 		= create_command("laminar/B738/push_button/at_light_fo", "A/T light FO button", B738_at_light_fo_CMDhandler)


B738CMD_n1_set_source_left = create_command("laminar/B738/toggle_switch/n1_set_source_left", "N1 set select left", B738_n1_set_source_left_CMDhandler)
B738CMD_n1_set_source_right = create_command("laminar/B738/toggle_switch/n1_set_source_right", "N1 set select right", B738_n1_set_source_right_CMDhandler)
--B738CMD_n1_set_adj_left = create_command("laminar/B738/toggle_switch/n1_set_adjust_left", "N1 set adjust left", B738_n1_set_adj_left_CMDhandler)
--B738CMD_n1_set_adj_right = create_command("laminar/B738/toggle_switch/n1_set_adjust_right", "N1 set adjust right", B738_n1_set_adj_right_CMDhandler)


B738CMD_baro_pilot_up 		= create_command("laminar/B738/pilot/barometer_up", "Captain Barometer Up", B738CMD_baro_pilot_up_CMDhandler)
B738CMD_baro_pilot_dn 		= create_command("laminar/B738/pilot/barometer_down", "Captain Barometer Down", B738CMD_baro_pilot_dn_CMDhandler)

B738CMD_baro_copilot_up 		= create_command("laminar/B738/copilot/barometer_up", "First Officer Barometer Up", B738CMD_baro_copilot_up_CMDhandler)
B738CMD_baro_copilot_dn 		= create_command("laminar/B738/copilot/barometer_down", "First Officer Barometer Down", B738CMD_baro_copilot_dn_CMDhandler)

B738CMD_autopilot_spd_interv		= create_command("laminar/B738/autopilot/spd_interv", "SPD intervention", B738_autopilot_spd_interv_CMDhandler)


--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--


function B738_reverse_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_thrust1_leveler < 0.05 then
			if simDR_reverse1_act == 1 and simDR_radio_height_pilot_ft < 10 then
				simDR_reverse1_act = 3
			else
				simDR_reverse1_act = 1
				reverse_max_enable = 0
			end
		end
 		if B738DR_thrust2_leveler < 0.05 then
			if simDR_reverse2_act == 1 and simDR_radio_height_pilot_ft < 10 then
				simDR_reverse2_act = 3
			else
				simDR_reverse2_act = 1
				reverse_max_enable = 0
			end
		end
	end
end

function B738_reverse_hold_CMDhandler(phase, duration)
	if phase == 0 then
--		if reverse_max_enable == 0 then
			if eng1_N1_thrust_cur < 0.05 or simDR_reverse1_act == 3 then	--simDR_throttle_1
				if simDR_radio_height_pilot_ft < 10 then
					if simDR_reverse1_act == 1 then
						simDR_reverse1_act = 3
					end
					reverse_max_enable = 1
					reverse_max_on = 1
				end
			end
			if eng2_N1_thrust_cur < 0.05 or simDR_reverse2_act == 3 then	--simDR_throttle_2
				if simDR_radio_height_pilot_ft < 10 then
					if simDR_reverse2_act == 1 then
						simDR_reverse2_act = 3
					end
					reverse_max_enable = 1
					reverse_max_on = 1
				end
			end
--		end
	elseif phase == 2 then
		reverse_max_on = 0
	end
end

--*************************************************************************************--
--** 				             REPLACE X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--

simCMD_take_off_go_around	= replace_command("sim/autopilot/take_off_go_around", B738_to_ga_CMDhandler)
simCMD_ap_alt_up			= replace_command("sim/autopilot/altitude_up", B738_ap_alt_up_CMDhandler)
simCMD_ap_alt_dn			= replace_command("sim/autopilot/altitude_down", B738_ap_alt_dn_CMDhandler)
simCMD_ap_crs_pilot_up		= replace_command("sim/radios/obs_HSI_up", B738_ap_crs_pilot_up_CMDhandler)
simCMD_ap_crs_pilot_dn		= replace_command("sim/radios/obs_HSI_down", B738_ap_crs_pilot_dn_CMDhandler)
simCMD_ap_crs_copilot_up	= replace_command("sim/radios/copilot_obs_HSI_up", B738_ap_crs_copilot_up_CMDhandler)
simCMD_ap_crs_copilot_dn	= replace_command("sim/radios/copilot_obs_HSI_down", B738_ap_crs_copilot_dn_CMDhandler)

simCMD_reverse_toggle		= replace_command("sim/engines/thrust_reverse_toggle", B738_reverse_toggle_CMDhandler)
simCMD_reverse_hold			= replace_command("sim/engines/thrust_reverse_hold", B738_reverse_hold_CMDhandler)


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

----- ANIMATION UTILITY -----------------------------------------------------------------

function B738_set_anim_value(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * SIM_PERIOD))
    end

end

----- RESCALE FLOAT AND CLAMP TO OUTER LIMITS -------------------------------------------
function B738_rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function roundUp(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

-- ROUNDING ---
function roundUpToIncrement(number, increment)

    local y = number / increment
    local q = math.ceil(y)
    local z = q * increment

    return z

end

function roundDownToIncrement(number, increment)

    local y = number / increment
    local q = math.floor(y)
    local z = q * increment

    return z

end



---- BLINK TIMER ----------------

function blink_timer()

	-- B738DR_rec_thr_modes = blink_rec_thr_status
	-- B738DR_rec_thr2_modes = blink_rec_thr2_status
	-- B738DR_rec_hdg_modes = blink_rec_hdg_status
	-- B738DR_rec_alt_modes = blink_rec_alt_status
	-- B738DR_rec_alt_alert = blink_rec_alt_alert_status
	-- B738DR_rec_cmd_modes1 = blink_rec_cmd_status1
	-- B738DR_rec_cmd_modes2 = blink_rec_cmd_status2
	-- B738DR_rec_sch_modes = blink_rec_sch_status
	
	if DRblink == 1 then
		if blink_out == 0 then
			blink_out = 1
		else
			blink_out = 0
		end
		-- if ap_dis_time > 0 then
			-- ap_dis_time = ap_dis_time - 1
		-- end
		-- if at_dis_time > 0 then
			-- at_dis_time = at_dis_time - 1
		-- end
		DRblink = 0
	else
		DRblink = 1
	end
	if ap_dis_time > 0 then
		B738DR_ap_disconnect = blink_out
	else
		B738DR_ap_disconnect = 0
	end
	if at_dis_time > 0 then
		B738DR_at_disconnect = blink_out
	else
		B738DR_at_disconnect = 0
	end
	
end

function rec_thr_timer()
	blink_rec_thr_status = 0
end

function rec_thr2_timer()
	blink_rec_thr2_status = 0
end


function rec_hdg_timer()
	blink_rec_hdg_status = 0
end

function rec_alt_timer()
	blink_rec_alt_status = 0
end

function rec_alt_alert_timer()
	blink_rec_alt_alert_status = 0
end

function rec_cmd_timer1()
	blink_rec_cmd_status1 = 0
end

function rec_cmd_timer2()
	blink_rec_cmd_status2 = 0
end

function rec_sch_timer()
	blink_rec_sch_status = 0
end


function B738_PFD_flash2()

	if is_timer_scheduled(blink_timer) == false then
		run_at_interval(blink_timer, 0.2)
	end

	-- SPEED modes
	if pfd_spd_old ~= B738DR_pfd_spd_mode
	and B738DR_pfd_spd_mode > 1 then
		if is_timer_scheduled(rec_thr2_timer) == true then
			stop_timer(rec_thr2_timer)
		end
		blink_rec_thr2_status = 0
		if is_timer_scheduled(rec_thr_timer) == true then
			stop_timer(rec_thr_timer)
		end
		run_after_time(rec_thr_timer, 10.0)
		blink_rec_thr_status = 1
	end
	if pfd_spd_old ~= B738DR_pfd_spd_mode
	and B738DR_pfd_spd_mode == 1 then
		if is_timer_scheduled(rec_thr_timer) == true then
			stop_timer(rec_thr_timer)
		end
		blink_rec_thr_status = 0
		if is_timer_scheduled(rec_thr2_timer) == true then
			stop_timer(rec_thr2_timer)
		end
		run_after_time(rec_thr2_timer, 10.0)
		blink_rec_thr2_status = 1
	end
	
	if B738DR_pfd_spd_mode == 0 then
		if is_timer_scheduled(rec_thr_timer) == true then
			stop_timer(rec_thr_timer)
		end
		blink_rec_thr_status = 0
		if is_timer_scheduled(rec_thr2_timer) == true then
			stop_timer(rec_thr2_timer)
		end
		blink_rec_thr2_status = 0
	end
	pfd_spd_old = B738DR_pfd_spd_mode

	if blink_rec_thr_status == 0 then
		B738DR_rec_thr_modes = 0
	end
	if blink_rec_thr2_status == 0 then
		B738DR_rec_thr2_modes = 0
	end
	
	-- ROLL modes
	if pfd_hdg_old ~= B738DR_pfd_hdg_mode
	and B738DR_pfd_hdg_mode > 0 then
		if is_timer_scheduled(rec_hdg_timer) == true then
			stop_timer(rec_hdg_timer)
		end
		run_after_time(rec_hdg_timer, 10.0)
		blink_rec_hdg_status = 1
	end
	
	if B738DR_pfd_hdg_mode == 0 then
		if is_timer_scheduled(rec_hdg_timer) == true then
			stop_timer(rec_hdg_timer)
		end
		blink_rec_hdg_status = 0
	end
	pfd_hdg_old = B738DR_pfd_hdg_mode

	if blink_rec_hdg_status == 0 then
		B738DR_rec_hdg_modes = 0
	end
	
	
	-- PITCH modes
	if pfd_alt_old ~= B738DR_pfd_alt_mode
	and B738DR_pfd_alt_mode > 0 then
		if is_timer_scheduled(rec_alt_timer) == true then
			stop_timer(rec_alt_timer)
		end
		run_after_time(rec_alt_timer, 10.0)
		blink_rec_alt_status = 1
	end
	
	if B738DR_pfd_alt_mode == 0 then
		if is_timer_scheduled(rec_alt_timer) == true then
			stop_timer(rec_alt_timer)
		end
		blink_rec_alt_status = 0
	end
	pfd_alt_old = B738DR_pfd_alt_mode

	if blink_rec_alt_status == 0 then
		B738DR_rec_alt_modes = 0
	end
	
	
	-- CMD MODES
	local cmd_status1 = 0	-- 0-Off,  1-FD, 2-CMD, 3-LAND 3
	if B738DR_single_ch_status == 0 then
		if B738DR_autopilot_fd_pos == 0 and simDR_flight_dir_mode < 2 then
			cmd_status1 = 0
		else
			cmd_status1 = simDR_flight_dir_mode
		end
		if B738DR_flare_status == 1 then
			cmd_status1 = 3
		end
	end
	if cmd_old1 ~= cmd_status1
	and cmd_status1 > 0 then
		if is_timer_scheduled(rec_cmd_timer1) == true then	-- 10 seconds
			stop_timer(rec_cmd_timer1)
		end
		run_after_time(rec_cmd_timer1, 10.0)
		blink_rec_cmd_status1 = 1
	end
	if cmd_status1 == 0 then
		if is_timer_scheduled(rec_cmd_timer1) == true then
			stop_timer(rec_cmd_timer1)
		end
		blink_rec_cmd_status1 = 0
	end
	cmd_old1 = cmd_status1
	if blink_rec_cmd_status1== 0 then
		B738DR_rec_cmd_modes1 = 0
	end
	
	local cmd_status2 = 0	-- 0-Off,  1-FD, 2-CMD, 3-LAND 3
	if B738DR_single_ch_status == 0 then
		if B738DR_autopilot_fd_fo_pos == 0 and simDR_flight_dir_mode < 2 then
			cmd_status2 = 0
		else
			cmd_status2 = simDR_flight_dir_mode
		end
		if B738DR_flare_status == 1 then
			cmd_status2 = 3
		end
	end
	if cmd_old2 ~= cmd_status2
	and cmd_status2 > 0 then
		if is_timer_scheduled(rec_cmd_timer2) == true then	-- 10 seconds
			stop_timer(rec_cmd_timer2)
		end
		run_after_time(rec_cmd_timer2, 10.0)
		blink_rec_cmd_status2 = 1
	end
	if cmd_status2 == 0 then
		if is_timer_scheduled(rec_cmd_timer2) == true then
			stop_timer(rec_cmd_timer2)
		end
		blink_rec_cmd_status2 = 0
	end
	cmd_old2 = cmd_status2
	if blink_rec_cmd_status2== 0 then
		B738DR_rec_cmd_modes2 = 0
	end
	
	
	-- SINGLE CHANNEL
	if single_ch_status_old ~= B738DR_single_ch_status
	and B738DR_single_ch_status == 1 then
		if is_timer_scheduled(rec_sch_timer) == true then	-- 10 seconds
			stop_timer(rec_sch_timer)
		end
		run_after_time(rec_sch_timer, 10.0)
		blink_rec_sch_status = 1
	end
	if B738DR_single_ch_status == 0 then
		if is_timer_scheduled(rec_sch_timer) == true then
			stop_timer(rec_sch_timer)
		end
		blink_rec_sch_status = 0
	end
	single_ch_status_old = B738DR_single_ch_status
	if blink_rec_sch_status == 0 then
		B738DR_rec_sch_modes = 0
	end
	
	-- ALT ALERT
	local altx = 0
	local capt_fo = 0	-- 0-captain, 1- first officer
	if simDR_autopilot_altitude_mode == 4 or simDR_autopilot_altitude_mode == 5 then
		
		if B738DR_autopilot_master_capt_status == 0 and B738DR_autopilot_master_fo_status == 0 then
			if autopilot_cmd_b_status == 1 then
				capt_fo = 1
			end
		elseif B738DR_autopilot_master_capt_status == 1 and B738DR_autopilot_master_fo_status == 1 then		-- autoland
			capt_fo = cmd_first
		elseif B738DR_autopilot_master_fo_status == 1 then
			capt_fo = 1
		end
		if capt_fo == 0 then
			altx = B738DR_mcp_alt_dial - simDR_altitude_pilot
		else
			altx = B738DR_mcp_alt_dial - simDR_altitude_copilot
		end
		
		if altx < 0 then
			altx = -altx
		end
		if altx > 980 and altx < 1000 then
			if is_timer_scheduled(rec_alt_alert_timer) == true then	-- 10 seconds
				stop_timer(rec_alt_alert_timer)
			end
			run_after_time(rec_alt_alert_timer, 12.0)
			blink_rec_alt_alert_status = 1
		end
		if altx > 1000 then
			if is_timer_scheduled(rec_alt_alert_timer) == true then
				stop_timer(rec_alt_alert_timer)
			end
			blink_rec_alt_alert_status = 0
		end
	end
	if blink_rec_alt_alert_status == 0 then
		B738DR_rec_alt_alert = 0
	end
	
	
	B738DR_rec_thr_modes = blink_rec_thr_status
	B738DR_rec_thr2_modes = blink_rec_thr2_status
	B738DR_rec_hdg_modes = blink_rec_hdg_status
	B738DR_rec_alt_modes = blink_rec_alt_status
	B738DR_rec_alt_alert = blink_rec_alt_alert_status
	B738DR_rec_cmd_modes1 = blink_rec_cmd_status1
	B738DR_rec_cmd_modes2 = blink_rec_cmd_status2
	B738DR_rec_sch_modes = blink_rec_sch_status

end








function B738_PFD_flash()

	if is_timer_scheduled(blink_timer) == false then
		run_at_interval(blink_timer, 0.2)
	end

	-- Thrust modes blink rectangle

--	blink_rec_thr_status = 0
	if autothrottle_pfd_old ~= B738DR_autopilot_autothrottle_pfd
	and B738DR_autopilot_autothrottle_pfd > 0 then
		if is_timer_scheduled(rec_thr_timer) == true then
			stop_timer(rec_thr_timer)
		end
		run_after_time(rec_thr_timer, 10.0)
		blink_rec_thr_status = 1
	end
	if autothrottle_status_old ~= B738DR_autopilot_autothrottle_on
	and B738DR_autopilot_autothrottle_on > 0 then
		if is_timer_scheduled(rec_thr_timer) == true then
			stop_timer(rec_thr_timer)
		end
		run_after_time(rec_thr_timer, 10.0)
		blink_rec_thr_status = 1
	end
	if n1_status_old ~= B738DR_autopilot_n1_pfd
	and B738DR_autopilot_n1_pfd == 1 then
		if is_timer_scheduled(rec_thr_timer) == true then
			stop_timer(rec_thr_timer)
		end
		run_after_time(rec_thr_timer, 10.0)
		blink_rec_thr_status = 1
	end
	if retard_status_old ~= B738DR_retard_status
	and B738DR_retard_status == 1 then
		if is_timer_scheduled(rec_thr_timer) == true then
			stop_timer(rec_thr_timer)
		end
		run_after_time(rec_thr_timer, 10.0)
		blink_rec_thr_status = 1
	end
	if ga_pfd_old ~= B738DR_autopilot_ga_pfd
	and B738DR_autopilot_ga_pfd == 1 then
		if is_timer_scheduled(rec_thr_timer) == true then
			stop_timer(rec_thr_timer)
		end
		run_after_time(rec_thr_timer, 10.0)
		blink_rec_thr_status = 1
	end
	if thr_hld_pfd_old ~= B738DR_autopilot_thr_hld_pfd
	and B738DR_autopilot_thr_hld_pfd == 1 then
		if is_timer_scheduled(rec_thr_timer) == true then
			stop_timer(rec_thr_timer)
		end
		run_after_time(rec_thr_timer, 10.0)
		blink_rec_thr_status = 1
	end
	if autopilot_cmd_a_status == 1 or autopilot_cmd_b_status == 1 then
		if fmc_spd_status_old ~= B738DR_autopilot_fmc_spd_pfd
		and B738DR_autopilot_fmc_spd_pfd == 1 then
			if is_timer_scheduled(rec_thr_timer) == true then
				stop_timer(rec_thr_timer)
			end
			run_after_time(rec_thr_timer, 10.0)
			blink_rec_thr_status = 1
		end
	end
	if B738DR_autopilot_autothrottle_pfd == 0
	and B738DR_autopilot_autothrottle_on == 0
	and B738DR_autopilot_n1_pfd == 0
	and B738DR_retard_status == 0
	and B738DR_autopilot_fmc_spd_pfd == 0
	and B738DR_autopilot_ga_pfd == 0
	and B738DR_autopilot_thr_hld_pfd == 0 then
		if is_timer_scheduled(rec_thr_timer) == true then
			stop_timer(rec_thr_timer)
		end
		blink_rec_thr_status = 0
	end
	autothrottle_pfd_old = B738DR_autopilot_autothrottle_pfd	-- ARM
	autothrottle_status_old = B738DR_autopilot_autothrottle_on	-- MCP SPD
	n1_status_old = B738DR_autopilot_n1_pfd 			-- N1
	retard_status_old = B738DR_retard_status			-- RETARD
	thr_hld_pfd_old = B738DR_autopilot_thr_hld_pfd
	ga_pfd_old = B738DR_autopilot_ga_pfd
	if autopilot_cmd_a_status == 1 or autopilot_cmd_b_status == 1 then
		fmc_spd_status_old = B738DR_autopilot_fmc_spd_pfd	-- FMC SPD
	else
		fmc_spd_status_old = 0
	end

	-- if blink_rec_thr_status == 1 then
		-- if is_timer_scheduled(rec_thr_timer) == false then	-- 10 seconds
			-- run_after_time(rec_thr_timer, 10.0)
		-- end
	-- else
	if blink_rec_thr_status == 0 then
		B738DR_rec_thr_modes = 0
	end

	-- Roll modes blink rectangle

--	blink_rec_hdg_status = 0
	if ap_on == 1 then
		if hdg_mode_status_old ~= B738DR_autopilot_hdg_mode_pfd
		and B738DR_autopilot_hdg_mode_pfd > 0 and B738DR_autoland_status == 0 then
			if is_timer_scheduled(rec_hdg_timer) == true then
				stop_timer(rec_hdg_timer)
			end
			run_after_time(rec_hdg_timer, 10.0)
			blink_rec_hdg_status = 1
		end
	else
		if is_timer_scheduled(rec_hdg_timer) == true then
			stop_timer(rec_hdg_timer)
		end
		blink_rec_hdg_status = 0
	end
	if B738DR_autopilot_hdg_mode_pfd == 0 then
		if is_timer_scheduled(rec_hdg_timer) == true then
			stop_timer(rec_hdg_timer)
		end
		blink_rec_hdg_status = 0
	end
	
	if ap_on == 1 then
		hdg_mode_status_old = B738DR_autopilot_hdg_mode_pfd 	-- HDG modes
	else
		hdg_mode_status_old = 0
	end
	
	-- if blink_rec_hdg_status == 1 then
		-- if is_timer_scheduled(rec_hdg_timer) == false then	-- 10 seconds
			-- run_after_time(rec_hdg_timer, 10.0)
		-- end
	-- else
	if blink_rec_hdg_status == 0 then
		B738DR_rec_hdg_modes = 0
	end

	-- Pitch modes blink rectangle
	if to_ga_pfd_old ~= B738DR_autopilot_to_ga_pfd
	and B738DR_autopilot_to_ga_pfd == 1 then
		if is_timer_scheduled(rec_alt_timer) == true then	-- 10 seconds
			stop_timer(rec_alt_timer)
		end
		run_after_time(rec_alt_timer, 10.0)
		blink_rec_alt_status = 1
		blink_to_ga = 1
	end
	if ap_on == 1 then
		if alt_mode_status_old ~= B738DR_autopilot_alt_mode_pfd
		and B738DR_autopilot_alt_mode_pfd >= 4 
		and B738DR_autopilot_alt_acq_pfd == 0 then
			if is_timer_scheduled(rec_alt_timer) == true then	-- 10 seconds
				stop_timer(rec_alt_timer)
			end
			run_after_time(rec_alt_timer, 10.0)
			blink_rec_alt_status = 1
		end
		if vnav_alt_status_old ~= B738DR_autopilot_vnav_alt_pfd
		and B738DR_autopilot_vnav_alt_pfd == 1 then
			if is_timer_scheduled(rec_alt_timer) == true then	-- 10 seconds
				stop_timer(rec_alt_timer)
			end
			run_after_time(rec_alt_timer, 10.0)
			blink_rec_alt_status = 1
		end
		if vnav_pth_status_old ~= B738DR_autopilot_vnav_pth_pfd
		and B738DR_autopilot_vnav_pth_pfd == 1 then
			if is_timer_scheduled(rec_alt_timer) == true then	-- 10 seconds
				stop_timer(rec_alt_timer)
			end
			run_after_time(rec_alt_timer, 10.0)
			blink_rec_alt_status = 1
		end
		if vnav_spd_status_old ~= B738DR_autopilot_vnav_spd_pfd
		and B738DR_autopilot_vnav_spd_pfd == 1 then
			if is_timer_scheduled(rec_alt_timer) == true then	-- 10 seconds
				stop_timer(rec_alt_timer)
			end
			run_after_time(rec_alt_timer, 10.0)
			blink_rec_alt_status = 1
		end
		if flare_status_old ~= B738DR_flare_status
		and B738DR_flare_status == 2 then
			if is_timer_scheduled(rec_alt_timer) == true then	-- 10 seconds
				stop_timer(rec_alt_timer)
			end
			run_after_time(rec_alt_timer, 10.0)
			blink_rec_alt_status = 1
		end
		if alt_acq_pfd_old ~= B738DR_autopilot_alt_acq_pfd
		and B738DR_autopilot_alt_acq_pfd == 1 then
			if is_timer_scheduled(rec_alt_timer) == true then	-- 10 seconds
				stop_timer(rec_alt_timer)
			end
			run_after_time(rec_alt_timer, 10.0)
			blink_rec_alt_status = 1
		end
	elseif blink_to_ga == 0 then
		if is_timer_scheduled(rec_alt_timer) == true 
		and blink_rec_alt_status == 0 then
			stop_timer(rec_alt_timer)
		end
		blink_rec_alt_status = 0
	end
	
	if B738DR_autopilot_alt_mode_pfd < 4
	and B738DR_autopilot_vnav_alt_pfd == 0
	and B738DR_autopilot_vnav_pth_pfd == 0
	and B738DR_autopilot_vnav_spd_pfd == 0
	and B738DR_flare_status == 0 
	and B738DR_autopilot_to_ga_pfd == 0
	and B738DR_autopilot_alt_acq_pfd == 0 then
		if is_timer_scheduled(rec_alt_timer) == true then
			stop_timer(rec_alt_timer)
		end
		blink_rec_alt_status = 0
		blink_to_ga = 0
	end

	to_ga_pfd_old = B738DR_autopilot_to_ga_pfd
	if ap_on == 1 then
		if ils_test_on == 0 then
			alt_mode_status_old = B738DR_autopilot_alt_mode_pfd	-- ALT modes
		end
		if B738DR_autopilot_alt_acq_pfd == 0 then
			vnav_alt_status_old = B738DR_autopilot_vnav_alt_pfd	-- VNAV ALT
		else
			vnav_alt_status_old = 10
		end
		vnav_pth_status_old = B738DR_autopilot_vnav_pth_pfd	-- VNAV PTH
		vnav_spd_status_old = B738DR_autopilot_vnav_spd_pfd	-- VNAV SPD
		flare_status_old = B738DR_flare_status				-- FLARE
		alt_acq_pfd_old = B738DR_autopilot_alt_acq_pfd
	else
		alt_mode_status_old = 0
		vnav_alt_status_old = 0
		vnav_pth_status_old = 0
		vnav_spd_status_old = 0
		flare_status_old = 0
--		to_ga_pfd_old = 0
		alt_acq_pfd_old = 0
	end
	
	-- if blink_rec_alt_status == 1 then
		-- if is_timer_scheduled(rec_alt_timer) == false then	-- 10 seconds
			-- run_after_time(rec_alt_timer, 10.0)
		-- end
	-- else
	if blink_rec_alt_status == 0 then
		B738DR_rec_alt_modes = 0
	end
	
	-- CMD MODES
	local cmd_status1 = 0	-- 0-Off,  1-FD, 2-CMD, 3-LAND 3
	if B738DR_single_ch_status == 0 then
		if B738DR_autopilot_fd_pos == 0 and simDR_flight_dir_mode < 2 then
			cmd_status1 = 0
		else
			cmd_status1 = simDR_flight_dir_mode
		end
		if B738DR_flare_status == 1 then
			cmd_status1 = 3
		end
	end
	if cmd_old1 ~= cmd_status1
	and cmd_status1 > 0 then
		if is_timer_scheduled(rec_cmd_timer1) == true then	-- 10 seconds
			stop_timer(rec_cmd_timer1)
		end
		run_after_time(rec_cmd_timer1, 10.0)
		blink_rec_cmd_status1 = 1
	end
	if cmd_status1 == 0 then
		if is_timer_scheduled(rec_cmd_timer1) == true then
			stop_timer(rec_cmd_timer1)
		end
		blink_rec_cmd_status1 = 0
	end
	cmd_old1 = cmd_status1
	if blink_rec_cmd_status1== 0 then
		B738DR_rec_cmd_modes1 = 0
	end
	
	local cmd_status2 = 0	-- 0-Off,  1-FD, 2-CMD, 3-LAND 3
	if B738DR_single_ch_status == 0 then
		if B738DR_autopilot_fd_fo_pos == 0 and simDR_flight_dir_mode < 2 then
			cmd_status2 = 0
		else
			cmd_status2 = simDR_flight_dir_mode
		end
		if B738DR_flare_status == 1 then
			cmd_status2 = 3
		end
	end
	if cmd_old2 ~= cmd_status2
	and cmd_status2 > 0 then
		if is_timer_scheduled(rec_cmd_timer2) == true then	-- 10 seconds
			stop_timer(rec_cmd_timer2)
		end
		run_after_time(rec_cmd_timer2, 10.0)
		blink_rec_cmd_status2 = 1
	end
	if cmd_status2 == 0 then
		if is_timer_scheduled(rec_cmd_timer2) == true then
			stop_timer(rec_cmd_timer2)
		end
		blink_rec_cmd_status2 = 0
	end
	cmd_old2 = cmd_status2
	if blink_rec_cmd_status2== 0 then
		B738DR_rec_cmd_modes2 = 0
	end
	
	
	-- SINGLE CHANNEL
	if single_ch_status_old ~= B738DR_single_ch_status
	and B738DR_single_ch_status == 1 then
		if is_timer_scheduled(rec_sch_timer) == true then	-- 10 seconds
			stop_timer(rec_sch_timer)
		end
		run_after_time(rec_sch_timer, 10.0)
		blink_rec_sch_status = 1
	end
	if B738DR_single_ch_status == 0 then
		if is_timer_scheduled(rec_sch_timer) == true then
			stop_timer(rec_sch_timer)
		end
		blink_rec_sch_status = 0
	end
	single_ch_status_old = B738DR_single_ch_status
	if blink_rec_sch_status == 0 then
		B738DR_rec_sch_modes = 0
	end
	
	-- ALT ALERT
	local altx = 0
	local capt_fo = 0	-- 0-captain, 1- first officer
	if simDR_autopilot_altitude_mode == 4 or simDR_autopilot_altitude_mode == 5 then
		
		if B738DR_autopilot_master_capt_status == 0 and B738DR_autopilot_master_fo_status == 0 then
			if autopilot_cmd_b_status == 1 then
				capt_fo = 1
			end
		elseif B738DR_autopilot_master_capt_status == 1 and B738DR_autopilot_master_fo_status == 1 then		-- autoland
			capt_fo = cmd_first
		elseif B738DR_autopilot_master_fo_status == 1 then
			capt_fo = 1
		end
		
		-- if capt_fo == 0 then
			-- altx = simDR_ap_altitude_dial_ft - simDR_altitude_pilot
		-- else
			-- altx = simDR_ap_altitude_dial_ft - simDR_altitude_copilot
		-- end
		if capt_fo == 0 then
			altx = B738DR_mcp_alt_dial - simDR_altitude_pilot
		else
			altx = B738DR_mcp_alt_dial - simDR_altitude_copilot
		end
		
		if altx < 0 then
			altx = -altx
		end
		if altx > 990 and altx < 1000 then
			if is_timer_scheduled(rec_alt_alert_timer) == true then	-- 10 seconds
				stop_timer(rec_alt_alert_timer)
			end
			run_after_time(rec_alt_alert_timer, 12.0)
			blink_rec_alt_alert_status = 1
		end
		if altx > 1000 then
			if is_timer_scheduled(rec_alt_alert_timer) == true then
				stop_timer(rec_alt_alert_timer)
			end
			blink_rec_alt_alert_status = 0
		end
	-- else
		-- if is_timer_scheduled(rec_alt_alert_timer) == true then
			-- stop_timer(rec_alt_alert_timer)
		-- end
		-- blink_rec_alt_alert_status = 0
	end
	if blink_rec_alt_alert_status == 0 then
		B738DR_rec_alt_alert = 0
	end
end





function autopilot_system_lights2()

	-- SPEED modes
	if B738DR_autopilot_autothr_arm_pos == 0 then
		-- none
		B738DR_pfd_spd_mode = 0
		B738DR_autopilot_speed_status = 0
	else
		if B738DR_autopilot_vnav_status == 1 and vnav_engaged == 1 then
			B738DR_autopilot_speed_status = 0
		else
			-- ARM
			if at_mode == 0 and at_mode_eng == 0 then
				B738DR_pfd_spd_mode = PFD_SPD_ARM
			end
			-- N1 mode
			if at_mode == 1 and at_mode_eng == 1 then
				B738DR_pfd_spd_mode = PFD_SPD_N1
			-- SPD mode
			end
			if at_mode == 2 and at_mode_eng == 2 then
				B738DR_autopilot_speed_status = 1
				B738DR_pfd_spd_mode = PFD_SPD_MCP_SPD
			else
				B738DR_autopilot_speed_status = 0
			end
		end
	end
	
	-- ROLL modes arm
	if simDR_nav_status == 0 then
		-- if autopilot_fms_nav_status == 0 then
			-- if B738DR_pfd_hdg_mode_arm == PFD_HDG_VOR_LOC_ARM then
				-- B738DR_pfd_hdg_mode_arm = 0
			-- end
		-- else
			-- if B738DR_pfd_hdg_mode_arm == PFD_HDG_LNAV_ARM then
				-- B738DR_pfd_hdg_mode_arm = 0
			-- end
		-- end
		if ap_roll_mode == 4 and ap_roll_mode_eng == 4 then -- LNAV
			if B738DR_pfd_hdg_mode_arm == PFD_HDG_LNAV_ARM then
				B738DR_pfd_hdg_mode_arm = 0
			end
		else
			if B738DR_pfd_hdg_mode_arm == PFD_HDG_VOR_LOC_ARM then
				B738DR_pfd_hdg_mode_arm = 0
			end
		end
	elseif simDR_nav_status == 1 then
		if autopilot_fms_nav_status == 0 then
			B738DR_pfd_hdg_mode_arm = PFD_HDG_VOR_LOC_ARM
		else
			B738DR_pfd_hdg_mode_arm = PFD_HDG_LNAV_ARM
		end
	end
	-- LNAV
	if ap_roll_mode == 4 and ap_roll_mode_eng == 4 and lnav_engaged == 0 then
		B738DR_pfd_hdg_mode_arm = PFD_HDG_LNAV_ARM
	else
		if B738DR_pfd_hdg_mode_arm == PFD_HDG_LNAV_ARM then
			B738DR_pfd_hdg_mode_arm = 0
		end
	end
	if simDR_approach_status == 1 then
		B738DR_pfd_hdg_mode_arm = PFD_HDG_VOR_LOC_ARM
	end
	-- FAC
	if ap_roll_mode == 8 then
		if fac_engaged == 0 then
			B738DR_pfd_hdg_mode_arm = PFD_HDG_FAC_ARM
		end
	else
		if B738DR_pfd_hdg_mode_arm == PFD_HDG_FAC_ARM then
			B738DR_pfd_hdg_mode_arm = 0
		end
	end
	if B738DR_flare_status == 0 then
		if B738DR_pfd_hdg_mode_arm == PFD_HDG_ROLLOUT_ARM then
			B738DR_pfd_hdg_mode_arm = 0
		end
	elseif B738DR_flare_status == 1 then
		B738DR_pfd_hdg_mode_arm = PFD_HDG_ROLLOUT_ARM
	elseif B738DR_flare_status == 2 then
		if B738DR_pfd_hdg_mode_arm == PFD_HDG_ROLLOUT_ARM then
			B738DR_pfd_hdg_mode_arm = 0
		end
	end
	
	-- ROLL modes
	if ap_roll_mode == 0 and ap_roll_mode_eng == 0 then
		B738DR_pfd_hdg_mode = 0
		B738DR_pfd_hdg_mode_arm = 0
	-- HDG SEL
	elseif ap_roll_mode == 1 and ap_roll_mode_eng == 1 then
		B738DR_pfd_hdg_mode = PFD_HDG_HDG_SEL
	-- VOR/LOC
	elseif ap_roll_mode == 2 and ap_roll_mode_eng == 2 then
		if simDR_nav_status == 2 then
			B738DR_pfd_hdg_mode = PFD_HDG_VOR_LOC
			if B738DR_pfd_hdg_mode_arm == PFD_HDG_VOR_LOC_ARM then
				B738DR_pfd_hdg_mode_arm = 0
			end
		end
	-- APP
	elseif ap_roll_mode == 3 and ap_roll_mode_eng == 3 then
		if simDR_approach_status == 2 then
			B738DR_pfd_hdg_mode = PFD_HDG_VOR_LOC
			if B738DR_pfd_hdg_mode_arm == PFD_HDG_VOR_LOC_ARM then
				B738DR_pfd_hdg_mode_arm = 0
			end
		end
	-- LNAV
	elseif ap_roll_mode == 4 and ap_roll_mode_eng == 4 and lnav_engaged > 0 then
		-- if simDR_radio_height_pilot_ft < 400 then
			-- B738DR_pfd_hdg_mode_arm = PFD_HDG_LNAV_ARM
		-- else
			B738DR_pfd_hdg_mode = PFD_HDG_LNAV
			if B738DR_pfd_hdg_mode_arm == PFD_HDG_LNAV_ARM then
				B738DR_pfd_hdg_mode_arm = 0
			end
		-- end
	-- LNAV -> VOR LOC
	elseif ap_roll_mode == 5 and ap_roll_mode_eng == 5 then
		B738DR_pfd_hdg_mode = PFD_HDG_LNAV
		B738DR_pfd_hdg_mode_arm = PFD_HDG_VOR_LOC_ARM
	-- LNAV -> APP
	elseif ap_roll_mode == 6 and ap_roll_mode_eng == 6 then
		B738DR_pfd_hdg_mode = PFD_HDG_LNAV
		B738DR_pfd_hdg_mode_arm = PFD_HDG_VOR_LOC_ARM
	-- LNAV / G/P
	elseif ap_roll_mode == 7 and ap_roll_mode_eng == 7 then
		B738DR_pfd_hdg_mode = PFD_HDG_LNAV
		--B738DR_pfd_hdg_mode_arm = PFD_HDG_VOR_LOC_ARM
	-- FAC LNAV / VNAV G/P
	elseif ap_roll_mode == 8 and ap_roll_mode_eng == 8 then
		--if simDR_nav_status == 2 and B738DR_gp_active == 2 then
			B738DR_pfd_hdg_mode = PFD_HDG_FAC
			if B738DR_pfd_hdg_mode_arm == PFD_HDG_FAC_ARM then
				B738DR_pfd_hdg_mode_arm = 0
			end
		--end
	elseif ap_roll_mode == 9 and ap_roll_mode_eng == 9 then
		if B738DR_flare_status == 2 then
			B738DR_pfd_hdg_mode = PFD_HDG_ROLLOUT
			if B738DR_pfd_hdg_mode_arm == PFD_HDG_ROLLOUT_ARM then
				B738DR_pfd_hdg_mode_arm = 0
			end
		end
	end
	
	-- PITCH modes arm
	if ap_pitch_mode ~= 3 then
		if B738DR_pfd_alt_mode_arm == PFD_ALT_VS_ARM then
			B738DR_pfd_alt_mode_arm = 0
		end
	end
	
	if simDR_glideslope_status == 0 then
		if B738DR_pfd_alt_mode_arm == PFD_ALT_GS_ARM then
			B738DR_pfd_alt_mode_arm = 0
		end
	elseif simDR_glideslope_status == 1 then
		B738DR_pfd_alt_mode_arm = PFD_ALT_GS_ARM
	elseif simDR_glideslope_status == 2 then
		if B738DR_pfd_alt_mode_arm == PFD_ALT_GS_ARM then
			B738DR_pfd_alt_mode_arm = 0
		end
	end
	-- -- LNAV / VOR LOC
	-- if ap_roll_mode == 5 and ap_roll_mode_eng == 5 then
		-- --B738DR_pfd_alt_mode_arm = PFD_HDG_VOR_LOC_ARM
	-- elseif ap_roll_mode == 6 and ap_roll_mode_eng == 6 then
		-- --B738DR_pfd_alt_mode_arm = PFD_HDG_VOR_LOC_ARM
	-- elseif ap_roll_mode == 7 and ap_roll_mode_eng == 7 then
		-- --B738DR_pfd_alt_mode_arm = PFD_HDG_VOR_LOC_ARM
	-- elseif ap_roll_mode == 8 and ap_roll_mode_eng == 8 then
		-- --B738DR_pfd_alt_mode_arm = PFD_HDG_VOR_LOC_ARM
	-- end
	
	if B738DR_gp_status == 0 then
		if B738DR_pfd_alt_mode_arm == PFD_ALT_GP_ARM then
			B738DR_pfd_alt_mode_arm = 0
		end
	elseif B738DR_gp_status == 1 then
		B738DR_pfd_alt_mode_arm = PFD_ALT_GP_ARM
	-- elseif B738DR_gp_status == 2 then
		-- if B738DR_pfd_alt_mode_arm == PFD_ALT_GP_ARM then
			-- B738DR_pfd_alt_mode_arm = 0
		-- end
	end
	if B738DR_flare_status == 0 then
		if B738DR_pfd_alt_mode_arm == PFD_ALT_FLARE_ARM then
			B738DR_pfd_alt_mode_arm = 0
		end
	elseif B738DR_flare_status == 1 then
		B738DR_pfd_alt_mode_arm = PFD_ALT_FLARE_ARM
	elseif B738DR_flare_status == 2 then
		if B738DR_pfd_alt_mode_arm == PFD_ALT_FLARE_ARM then
			B738DR_pfd_alt_mode_arm = 0
		end
	end
	
	--PITCH modes
	if at_mode_eng ~= 3 and at_mode_eng ~= 4 and at_mode_eng ~= 5 and at_mode_eng ~= 8 then		-- TOGA
		if ap_pitch_mode == 0 and ap_pitch_mode_eng == 0 then
			B738DR_pfd_alt_mode = 0
			B738DR_pfd_alt_mode_arm = 0
		-- V/S
		elseif ap_pitch_mode == 1 and ap_pitch_mode_eng == 1 then
			B738DR_pfd_alt_mode = PFD_ALT_VS
			if B738DR_pfd_alt_mode_arm == PFD_ALT_VS_ARM then
				B738DR_pfd_alt_mode_arm = 0
			end
		-- LVL CHG
		elseif ap_pitch_mode == 2 and ap_pitch_mode_eng == 2 then
			B738DR_pfd_alt_mode = PFD_ALT_MCP_SPD
		-- ALT HOLD
		elseif ap_pitch_mode == 3 and ap_pitch_mode_eng == 3 then
			B738DR_pfd_alt_mode = PFD_ALT_ALT_HOLD
		-- G/S
		elseif ap_pitch_mode == 4 and ap_pitch_mode_eng == 4 then
			B738DR_pfd_alt_mode = PFD_ALT_GS
		-- VNAV
		elseif ap_pitch_mode == 5 and ap_pitch_mode_eng == 5 then
			if simDR_radio_height_pilot_ft < 400 then
				B738DR_pfd_alt_mode_arm = PFD_ALT_VNAV_ARM
			else
				--B738DR_pfd_alt_mode = PFD_HDG_LNAV
				if B738DR_pfd_alt_mode_arm == PFD_ALT_VNAV_ARM then
					B738DR_pfd_alt_mode_arm = 0
				end
			end
		-- ALT ACQ
		elseif ap_pitch_mode == 6 and ap_pitch_mode_eng == 6 then
			B738DR_pfd_alt_mode = PFD_ALT_ALT_ACQ
		end
		if simDR_glideslope_status == 2 then
			B738DR_pfd_alt_mode = PFD_ALT_GS
			if B738DR_pfd_alt_mode_arm == PFD_ALT_GS_ARM then
				B738DR_pfd_alt_mode_arm = 0
			end
		end
		-- LNAV -> APP
		if ap_roll_mode == 6 and ap_roll_mode_eng == 6 then
			B738DR_pfd_alt_mode_arm = PFD_ALT_GS_ARM
		end
		-- if ap_pitch_mode == 7 and ap_pitch_mode_eng == 7
			-- B738DR_pfd_alt_mode = PFD_ALT_GP
			-- if B738DR_pfd_alt_mode_arm == PFD_ALT_GP_ARM then
				-- B738DR_pfd_alt_mode_arm = 0
			-- end
		-- end
		if B738DR_gp_status == 0 then
			if B738DR_pfd_alt_mode == PFD_ALT_GP then
				B738DR_pfd_alt_mode = 0
			end
		elseif B738DR_gp_status == 2 then
			B738DR_pfd_alt_mode = PFD_ALT_GP
			if B738DR_pfd_alt_mode_arm == PFD_ALT_GP_ARM then
				B738DR_pfd_alt_mode_arm = 0
			end
		end
		if B738DR_flare_status == 2 then
			B738DR_pfd_alt_mode = PFD_ALT_FLARE
			if B738DR_pfd_alt_mode_arm == PFD_ALT_FLARE_ARM then
				B738DR_pfd_alt_mode_arm = 0
			end
		end
	end
	
	-- MASTER CAPT / FO
	if B738DR_autoland_status == 1
	and simDR_radio_height_pilot_ft < 1500
	and B738DR_autopilot_fd_pos == 1 
	and B738DR_autopilot_fd_fo_pos == 1 then
			B738DR_autopilot_master_capt_status = 1
			B738DR_autopilot_master_fo_status = 1
	else
		if B738DR_autopilot_fd_pos == 0
		and B738DR_autopilot_fd_fo_pos == 0 then
			B738DR_autopilot_master_capt_status = 0
			B738DR_autopilot_master_fo_status = 0
		else
			if B738DR_autopilot_side == 0 then
				B738DR_autopilot_master_capt_status = 1
				B738DR_autopilot_master_fo_status = 0
			elseif B738DR_autopilot_side == 1 then
				B738DR_autopilot_master_capt_status = 0
				B738DR_autopilot_master_fo_status = 1
			end
		end
	end

	if B738DR_autopilot_master_capt_status == 1
	or B738DR_autopilot_master_fo_status == 1 then
		B738DR_fd_on = 1
	else
		B738DR_fd_on = 0
		-- turn off A/P
		simDR_flight_dir_mode = 1
		-- F/D on
		autopilot_cmd_a_status = 0
		autopilot_cmd_b_status = 0
		B738DR_autoland_status = 0
		B738DR_flare_status = 0
		B738DR_retard_status = 0
		simDR_ap_vvi_dial = 0
		vorloc_only = 0
		ap_pitch_mode = 0
		ap_roll_mode = 0
	end


	-- PFD >> off-FD-CMD
	local fd_cmd = 0
	local fd_cmd_fo = 0
	if ap_on == 1 then
		fd_cmd = 1
		fd_cmd_fo = 1
	else
		if B738DR_autopilot_fd_pos == 1 then
			fd_cmd = 1
		end
		if B738DR_autopilot_fd_fo_pos == 1 then
			fd_cmd_fo = 1
		end
	end
	B738DR_pfd_fd_cmd = fd_cmd			-- show/hide: FD/CMD on captain PFD
	B738DR_pfd_fd_cmd_fo = fd_cmd_fo	-- show/hide: FD/CMD on first officer PFD


	-- VHF NAV SOURCE SWITCHING
	if autopilot_fms_nav_status == 0 then
		B738DR_pfd_vorloc_lnav = 0
		if B738DR_autopilot_vhf_source_pos == -1 then
			simDR_autopilot_source = 0
			simDR_autopilot_fo_source = 0
		elseif B738DR_autopilot_vhf_source_pos == 0 then
		 	simDR_autopilot_source = 0
			simDR_autopilot_fo_source = 1
		elseif B738DR_autopilot_vhf_source_pos == 1 then
		 	simDR_autopilot_source = 1
			simDR_autopilot_fo_source = 1
		end
	elseif autopilot_fms_nav_status == 1 then
		simDR_autopilot_source = 2
		simDR_autopilot_fo_source = 2
--		simDR_autopilot_fo_source = 0
		B738DR_pfd_vorloc_lnav = 1
	end

	-- CMD / CWS
	B738DR_autopilot_cmd_a_status = autopilot_cmd_a_status --* simDR_servos_on
	B738DR_autopilot_cmd_b_status = autopilot_cmd_b_status --* simDR_servos_on
	B738DR_autopilot_cws_a_status = autopilot_cws_a_status * simDR_autopilot_on
	B738DR_autopilot_cws_b_status = autopilot_cws_b_status * simDR_autopilot_on

	simDR_ap_fo_heading = simDR_ap_capt_heading

	-- EFIS mode
	if simDR_EFIS_mode == 4 then
		simDR_EFIS_WX = 0
		--simDR_EFIS_TCAS = 0
		B738DR_EFIS_TCAS_on = 0
	end
	
	-- ILS test - pointer blink
	if ils_test_on == 0 then
		B738DR_ils_pointer_disable = 0
	else
		B738DR_ils_pointer_disable = blink_out
	end
	
	-- SHOW/HIDE IAS
	if ap_pitch_mode == 5 and ap_pitch_mode_eng == 5 and vnav_engaged == 1 then
		-- VNAV on
		if B738DR_ap_spd_interv_status == 0 then
			B738DR_show_ias = 0
		else
			B738DR_show_ias = 1
		end
	else
		B738DR_show_ias = 1
	end
	
	-- if B738DR_autopilot_vnav_status == 0 then
		-- B738DR_show_ias = 1
	-- else
		-- -- VNAV on
		-- if B738DR_ap_spd_interv_status == 0 then
			-- B738DR_show_ias = 0
		-- else
			-- B738DR_show_ias = 1
		-- end
	-- end

end









function B738_lnav()

	if ap_roll_mode_eng == 4 and ap_roll_mode == 4 then
		
		if simDR_radio_height_pilot_ft > 50 then
			lnav_engaged = 1
		end
		
		if lnav_engaged == 1 then
			if simDR_approach_status > 0 then
				simCMD_autopilot_app:once()
			end
			if autopilot_fms_nav_status == 0 then
				if simDR_nav_status > 0 then			-- if VOR LOC Arm or Captured
					simCMD_autopilot_lnav:once()			-- VOR LOC off
				end
			end
			autopilot_fms_nav_status = 1
			simDR_autopilot_source = 2
			simDR_autopilot_fo_source = 2
			lnav_vorloc = 0
			lnav_app = 0
			if simDR_nav_status == 0 then
				simCMD_autopilot_lnav:once()			-- LNAV on
			end
			lnav_engaged = 2
		end
	else
		lnav_engaged = 0
	end
end


function B738_lnav2()

	local wca = 0
--	local ws = 0
	local wh = 0
	local tas = 0
	local awa = 0
	local relative_brg = 0
	local bearing_corr = 0
	local idx_corr = 0
	local idx_dist = 0
	local mag_hdg = 0
	local mag_trk = 0	-- temporary without mag variantion
	local ap_hdg = 0
	local rnp_deg = 0
	
	if ap_roll_mode_eng == 4 and ap_roll_mode == 4 then
		
		if simDR_radio_height_pilot_ft > 50 then
			if lnav_engaged == 0 then
				lnav_engaged = 1
			end
		end
		
		if lnav_engaged == 1 then
			if simDR_approach_status > 0 then
				simCMD_autopilot_app:once()
			end
			--if autopilot_fms_nav_status == 0 then
				if simDR_nav_status > 0 then			-- if VOR LOC Arm or Captured
					simCMD_autopilot_lnav:once()			-- VOR LOC off
				end
			--end
			--autopilot_fms_nav_status = 1
			--simDR_autopilot_source = 2
			--simDR_autopilot_fo_source = 2
			lnav_vorloc = 0
			lnav_app = 0
			-- if simDR_nav_status == 0 then
				-- simCMD_autopilot_lnav:once()			-- LNAV on
			-- end
			lnav_engaged = 2
		end
	else
		lnav_engaged = 0
		if ap_roll_mode == 5 or ap_roll_mode_eng == 5 then
			if simDR_nav_status < 2 then			-- if VOR LOC Arm or Captured
				lnav_engaged = 2
			else
				ap_roll_mode = 2
				ap_roll_mode_eng = 2
			end
		end
		if ap_roll_mode == 6 or ap_roll_mode_eng == 6 then
			if simDR_approach_status < 2 then			-- if APP Arm or Captured
				lnav_engaged = 2
			else
				ap_roll_mode = 3
				ap_roll_mode_eng = 3
			end
		end
	end
	
	if lnav_engaged == 2 then
		if simDR_autopilot_heading_mode ~= 1 then
			simCMD_autopilot_hdg:once()
		end
		
		-- heading to track
		mag_trk = simDR_fmc_trk + simDR_mag_variation
		relative_brg = (mag_trk - simDR_fmc_crs + 360) % 360
		if relative_brg > 180 then
			relative_brg = relative_brg - 360
		end
		
		idx_dist = math.min(simDR_dme_dist, 0)
		idx_dist = math.max(simDR_dme_dist, 2.5)
		idx_corr = B738_rescale(0, 1, 2.5, 4, idx_dist)
		bearing_corr = relative_brg * idx_corr
		
		if bearing_corr < -50 then
			bearing_corr = -50
		end
		if bearing_corr > 50 then
			bearing_corr = 50
		end
		ap_hdg = (mag_trk - bearing_corr + 360) % 360	-- last working and testing
		
		-- wind correction
		mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
		tas = simDR_ground_spd * 1.94384449244	-- m/s to knots
		wh = (simDR_wind_hdg + 180) % 360
		relative_brg = (wh - mag_hdg + 360) % 360
		if relative_brg > 180 then
			relative_brg = relative_brg - 360
		end
		if relative_brg < -90 then
			awa = math.rad(180 + relative_brg)
			wca = math.asin(simDR_wind_spd * ((math.sin(awa) / tas)))
			wca = math.deg(-wca)
		elseif relative_brg < 0 then
			awa = math.rad(-relative_brg)
			wca = math.asin(simDR_wind_spd * ((math.sin(awa) / tas)))
			wca = math.deg(-wca)
		elseif relative_brg < 90 then
			awa = math.rad(relative_brg)
			wca = math.asin(simDR_wind_spd * ((math.sin(awa) / tas)))
			wca = math.deg(wca)
		else
			awa = math.rad(180 - relative_brg)
			wca = math.asin(simDR_wind_spd * ((math.sin(awa) / tas)))
			wca = math.deg(wca)
		end
		simDR_ap_capt_heading = (ap_hdg - wca) % 360
	else
		simDR_ap_capt_heading = B738DR_mcp_hdg_dial
	end
	
end


--- VNAV autopilot ---

function B738_vnav6()

	local delta_vvi = 0
	local delta_alt_dial = 0
	local vnav_speed_delta2 = 0
	local speed_step = 0
	
	local flaps = simDR_flaps_ratio
	local v2_20_speed = B738DR_fms_v2_15
	local v2 = 0
	local vvi_act = simDR_vvi_fpm_pilot
	local cca_alt = 0.0
	local nav_id = "*"
	local alt_x = 0
	local spd_250_10000 = 0
	
	if ap_pitch_mode_eng == 5 and ap_pitch_mode == 5 and B738DR_autopilot_vnav_status == 1 then --ap_vnav_status == 2 then
		
		if simDR_radio_height_pilot_ft > 400 then
			vnav_engaged = 1
		end
		
		if ap_on == 1 or vnav_engaged == 1 then
			
			if vnav_init == 0 then
				vnav_init2 = 0
				B738DR_vvi_dial_show = 0
				B738DR_autopilot_vvi_status_pfd = 0		-- no V/S arm
				
				if vnav_alt_mode == 0 then
					-- climb
					if B738DR_flight_phase < 2 then
						vnav_alt_hld = 0
						vnav_vs = 0
						delta_alt_dial = B738DR_mcp_alt_dial - simDR_altitude_pilot
						if delta_alt_dial > 500 then
							if B738DR_autopilot_autothr_arm_pos == 1 then
								at_mode = 7
							else
								alt_x = at_mode
							end
							if simDR_autopilot_altitude_mode ~= 5 then
								simCMD_autopilot_lvl_chg:once()
								if B738DR_autopilot_autothr_arm_pos == 0 then
									at_mode = alt_x
								end
							end
						else
							--ap_pitch_mode = 3
							vnav_alt_mode = 1
							vnav_alt_hld = 1
							--simCMD_autopilot_alt_hold:once()
						end
						
					-- cruise
					elseif B738DR_flight_phase == 2 then
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 9
						else
							alt_x = at_mode
						end
						if simDR_autopilot_altitude_mode ~= 6 then
							simCMD_autopilot_alt_hold:once()
							if B738DR_autopilot_autothr_arm_pos == 0 then
								at_mode = alt_x
							end
						end
					
					------------------------- NEW ---------------------
					-- cruise climb
					elseif B738DR_flight_phase == 3 then
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 9
						else
							alt_x = at_mode
						end
						if simDR_autopilot_altitude_mode ~= 6 then
							simCMD_autopilot_alt_hold:once()
							if B738DR_autopilot_autothr_arm_pos == 0 then
								at_mode = alt_x
							end
						end
						B738DR_flight_phase = 2
					
					-- cruise descent
					elseif B738DR_flight_phase == 4 then
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 9
						else
							alt_x = at_mode
						end
						if simDR_autopilot_altitude_mode ~= 6 then
							simCMD_autopilot_alt_hold:once()
							if B738DR_autopilot_autothr_arm_pos == 0 then
								at_mode = alt_x
							end
						end
						B738DR_flight_phase = 2
					------------------------- NEW ---------------------
					
					-- descent
					else
						delta_alt_dial = simDR_altitude_pilot - B738DR_mcp_alt_dial
						if delta_alt_dial > 500 then
							if B738DR_autopilot_autothr_arm_pos == 1 then
								at_mode = 2
							else
								alt_x = at_mode
							end
							if B738DR_vnav_err_pfd > 400 then
								vnav_alt_hold_act = 1
								if simDR_autopilot_altitude_mode ~= 6 then
									simCMD_autopilot_alt_hold:once()
								end
							else
								if simDR_autopilot_altitude_mode ~= 4 then
									simDR_ap_vvi_dial = B738DR_vnav_vvi
									simCMD_autopilot_vs_sel:once()
									if B738DR_autopilot_autothr_arm_pos == 0 then
										at_mode = alt_x
									end
								end
							end
						else
							--ap_pitch_mode = 3
							vnav_alt_mode = 1
							simCMD_autopilot_alt_hold:once()
						end
					end
					if at_mode == 3 then
						at_mode = 0
					end
				end
			end
			vnav_init = 1
			
			-- Restrict 250 kts / 10000 ft
			if B738DR_flight_phase < 3 then
				if simDR_altitude_pilot < 10000 then
					spd_250_10000 = 250
				else
					spd_250_10000 = 340
				end
			elseif B738DR_flight_phase > 4 then
				if simDR_altitude_pilot < 10900 then
					spd_250_10000 = 240
				else
					spd_250_10000 = 340
				end
			end
			
			-- PHASE CLIMB
			if B738DR_flight_phase < 2 then
				
				-- crossover altitude
				if simDR_mach_no >= B738DR_fmc_climb_speed_mach then
					if simDR_airspeed_is_mach == 0 then
						simCMD_autopilot_co:once()
					end
				end
				
				-- flaps limit speeds
				if flaps == 0 then
					flaps_speed = 340
				elseif flaps <= 0.25 then		-- flaps 1,2
					flaps_speed = 230
				elseif flaps <= 0.375 then		-- flaps 5
					--flaps_speed = B738DR_fms_vref_40 + 30
					flaps_speed = 230
				elseif flaps <= 0.5 then		-- flaps 10
					--flaps_speed = B738DR_fms_vref_40 + 30
					flaps_speed = 205
				elseif flaps <= 0.625 then		-- flaps 15
					--flaps_speed = B738DR_fms_vref_40 + 20
					flaps_speed = 195
				elseif flaps <= 0.75 then		-- flaps 25
					--flaps_speed = B738DR_fms_vref_40 + 10
					flaps_speed = 185
				else
					--flaps_speed = B738DR_fms_vref_40 + 10
					flaps_speed = 160
				end
				if flaps_speed == 0 then
					if flaps == 0 then
						flaps_speed = 340
					else
						flaps_speed = 230
					end
				end
				-- V2+20 limit speeds
				if v2_20_speed == 0 then
					v2_20_speed = 180
				end
				if simDR_radio_height_pilot_ft < B738DR_accel_alt then
					v2 = v2_20_speed - 20
					if simDR_airspeed_pilot < v2 or simDR_airspeed_pilot > v2_20_speed then
						v2_20_speed = v2_20_speed + 5
					else
						v2_20_speed = simDR_airspeed_pilot
					end
				else
					v2_20_speed = 340
				end
				if v2_20_speed < 340 then
					if flaps_speed < v2_20_speed then
						flaps_speed = v2_20_speed
					end
				end
				
				-- limited VNAV speed
				vnav_speed = B738DR_rest_wpt_spd
				if vnav_speed == 0 then
					vnav_speed = 340
				end
				
				-- B738DR_fmc_climb_speed_l = math.min (flaps_speed, v2_20_speed, vnav_speed, B738DR_fmc_speed)
				B738DR_fmc_climb_speed_l = math.min (flaps_speed, v2_20_speed, vnav_speed, spd_250_10000)
				
				if simDR_airspeed_is_mach == 0 then
					if B738DR_fmc_climb_speed_l < B738DR_fmc_climb_speed then
						vnav_speed_trg = B738DR_fmc_climb_speed_l
					else
						B738DR_fmc_climb_speed_l = 340
						vnav_speed_trg = B738DR_fmc_climb_speed
					end
				else
					B738DR_fmc_climb_speed_l = 340
					vnav_speed_trg = B738DR_fmc_climb_speed_mach
				end
				
				if B738DR_rest_wpt_alt == 0 or B738DR_rest_wpt_alt_t == 43 then
					vnav_alt = math.min(B738DR_fmc_cruise_alt, B738DR_mcp_alt_dial)
				else
					vnav_alt = math.min(B738DR_rest_wpt_alt, B738DR_fmc_cruise_alt, B738DR_mcp_alt_dial)
				end
				
				-- VNAV ALT
				if vnav_alt_mode == 0 then
				
					if vnav_alt_hld == 1 then
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 9		-- SPEED mode on with N1 limit
							B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
						end
						if simDR_autopilot_altitude_mode ~= 6 then
							simCMD_autopilot_alt_hold:once()
						end
					end
					if vnav_vs == 1 and simDR_autopilot_altitude_mode ~= 4 then
						simDR_ap_vvi_dial = 850
						vvi_trg = simDR_ap_vvi_dial
						fmc_vvi_cur = simDR_vvi_fpm_pilot
						simCMD_autopilot_vs_sel:once()
					end
					
					if simDR_autopilot_altitude_mode == 5 then		-- LVL CHG
						delta_alt_dial = vnav_alt - simDR_altitude_pilot
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 7
							B738DR_autopilot_n1_status = 1
							--B738DR_autopilot_fmc_spd_pfd = 0 		-- FMC SPD on
							B738DR_pfd_spd_mode = PFD_SPD_N1
						end
							--B738DR_autopilot_vnav_alt_pfd = 0	-- PFD: no VNAV ALT
							--B738DR_autopilot_vnav_pth_pfd = 0	-- PFD: VNAV PTH
							--B738DR_autopilot_vnav_spd_pfd = 1	-- PFD: VNAV SPD
							B738DR_pfd_alt_mode = PFD_ALT_VNAV_SPD
						if delta_alt_dial > 700 then
							if B738DR_autopilot_autothr_arm_pos == 1 then
								eng1_N1_thrust_trg = eng1_N1_thrust	-- N1 THRUST
								eng2_N1_thrust_trg = eng2_N1_thrust	-- N1 THRUST
							end
							simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
						else
							simDR_ap_altitude_dial_ft = vnav_alt
						end
						
					elseif simDR_autopilot_altitude_mode == 4 then
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 7
							B738DR_autopilot_n1_status = 1
							--B738DR_autopilot_fmc_spd_pfd = 0 		-- FMC SPD on
							B738DR_pfd_spd_mode = PFD_SPD_N1
						end
						--B738DR_autopilot_vnav_alt_pfd = 0	-- PFD: no VNAV ALT
						--B738DR_autopilot_vnav_pth_pfd = 0	-- PFD: VNAV PTH
						--B738DR_autopilot_vnav_spd_pfd = 1	-- PFD: VNAV SPD
						B738DR_pfd_alt_mode = PFD_ALT_VNAV_SPD
						delta_alt_dial = vnav_alt - simDR_altitude_pilot
						if delta_alt_dial > 700 then
							if B738DR_autopilot_autothr_arm_pos == 1 then
								eng1_N1_thrust_trg = eng1_N1_thrust	-- N1 THRUST
								eng2_N1_thrust_trg = eng2_N1_thrust	-- N1 THRUST
							end
							simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
						else
							simDR_ap_altitude_dial_ft = vnav_alt
						end
					elseif simDR_autopilot_altitude_mode == 6 then
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 9		-- SPEED mode on with N1 limit
							--B738DR_autopilot_fmc_spd_pfd = 1 		-- FMC SPD on
							--B738DR_autopilot_n1_status = 0
							B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
						end
						
						if simDR_ap_altitude_dial_ft == B738DR_fmc_cruise_alt and vnav_alt_hld == 0 then
							B738DR_flight_phase = 2
						else
							vnav_alt_hld = 1
							vnav_vs = 0
							simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
							delta_vvi = B738DR_fmc_cruise_alt - simDR_altitude_pilot
							if delta_vvi > 400 then
								--B738DR_autopilot_vnav_alt_pfd = 0	-- PFD: VNAV ALT
								--B738DR_autopilot_vnav_pth_pfd = 1	-- PFD: no VNAV PTH
								--B738DR_autopilot_vnav_spd_pfd = 0	-- PFD: no VNAV SPD
								B738DR_pfd_alt_mode = PFD_ALT_VNAV_PTH
							end
							delta_vvi = simDR_vvi_fpm_pilot
							if delta_vvi < 0 then
								delta_vvi = -delta_vvi
							end
							if delta_vvi < 500 then		-- ALT HLD stabilized
								delta_alt_dial = vnav_alt - simDR_altitude_pilot
								if delta_alt_dial > 500 then
									if B738DR_autopilot_autothr_arm_pos == 1 then
										at_mode_old = at_mode
										simCMD_autopilot_lvl_chg:once()
										at_mode = at_mode_old
										at_mode = 7
										B738DR_pfd_spd_mode = PFD_SPD_N1
									else
										at_mode_old = at_mode
										simCMD_autopilot_lvl_chg:once()
										at_mode = at_mode_old
									end
									vnav_alt_hld = 0
								end
							end
						end
					end
				else
					simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
					--B738DR_autopilot_vnav_alt_pfd = 1	-- PFD: VNAV ALT
					--B738DR_autopilot_vnav_pth_pfd = 0	-- PFD: no VNAV PTH
					---B738DR_autopilot_vnav_spd_pfd = 0	-- PFD: no VNAV SPD
					B738DR_pfd_alt_mode = PFD_ALT_VNAV_ALT
					
					--B738DR_autopilot_fmc_spd_pfd = 1 	-- FMC SPD on
					B738DR_autopilot_n1_status = 0
					B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
				end
			
			-- PHASE CRUISE
			elseif B738DR_flight_phase == 2 then
				
				--B738DR_autopilot_fmc_spd_pfd = 1 		-- FMC SPD on
				B738DR_autopilot_n1_status = 0
				B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
				if simDR_autopilot_altitude_mode == 6 then
					--B738DR_autopilot_vnav_alt_pfd = 0	-- PFD: no VNAV ALT
					--B738DR_autopilot_vnav_pth_pfd = 1	-- PFD: VNAV PTH
					--B738DR_autopilot_vnav_spd_pfd = 0
					B738DR_pfd_alt_mode = PFD_ALT_VNAV_PTH
					if at_mode == 9 then
						if B738DR_autopilot_autothr_arm_pos == 1 then
							if simDR_autothrottle_enable == 0 then
								simDR_autothrottle_enable = 1	-- speed on
							end
						end
					else
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 9		-- SPEED mode on with N1 limit
							at_mode_eng = 20
						end
					end
				end
				
				vnav_alt_mode = 0
				
				--if vnav_alt_hld == 1 and simDR_autopilot_altitude_mode ~= 6 then
				if simDR_autopilot_altitude_mode ~= 6 then
					simCMD_autopilot_alt_hold:once()
					if B738DR_autopilot_autothr_arm_pos == 1 then
						at_mode = 9		-- SPEED mode on with N1 limit
						at_mode_eng = 20
						B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
					end
					vnav_alt_hld = 0
					vnav_vs = 0
				end
				
				-- crossover altitude
				if simDR_mach_no >= B738DR_fmc_cruise_speed_mach then
					if simDR_airspeed_is_mach == 0 then
						simCMD_autopilot_co:once()
					end
				end
				-- cruise speed
				if simDR_airspeed_is_mach == 0 then
					if B738DR_rest_wpt_spd > 0 then
						if B738DR_mcp_speed_dial < 100 then
							vnav_speed_trg = B738DR_rest_wpt_spd
						else
							--if simDR_airspeed_dial ~= B738DR_rest_wpt_spd and simDR_dme_dist < decel_dist then
							if simDR_dme_dist < decel_dist then
								vnav_speed_trg = B738DR_rest_wpt_spd
							else
								vnav_speed_trg = B738DR_fmc_cruise_speed
							end
						end
						vnav_speed_trg = math.min(vnav_speed_trg, spd_250_10000, B738DR_fmc_cruise_speed)
					else
						-- 4NM before T/D
						if B738DR_vnav_td_dist > 0 and B738DR_vnav_td_dist < 4.5 then
							vnav_speed_trg = B738DR_fmc_descent_speed
						else
							vnav_speed_trg = B738DR_fmc_cruise_speed
						end
					end
				else
					-- 4NM before T/D
					if B738DR_vnav_td_dist > 0 and B738DR_vnav_td_dist < 4.5 then
						vnav_speed_trg = B738DR_fmc_descent_speed_mach
					else
						vnav_speed_trg = B738DR_fmc_cruise_speed_mach
					end
				end
				
				if simDR_autopilot_altitude_mode ~= 6 then
					delta_alt_dial = B738DR_fmc_cruise_alt - simDR_altitude_pilot
					if delta_alt_dial < 500 then
						simDR_ap_altitude_dial_ft = B738DR_fmc_cruise_alt
					end
				else
					simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
				end
				
				
				--------
				-- automatic descent
				--if B738DR_vnav_td_dist > 0 and B738DR_vnav_td_dist < 1 then
				if B738DR_vnav_td_dist < 1.5 then
					if simDR_ap_altitude_dial_ft < B738DR_fmc_cruise_alt then
						-- vnav descent
						if simDR_autopilot_altitude_mode ~= 4 then
							simDR_ap_vvi_dial = B738DR_vnav_vvi
							simCMD_autopilot_vs_sel:once()
						end
					else
						vnav_alt_mode = 1
					end
					B738DR_fms_descent_now = 3
					B738DR_flight_phase = 5
				end
				
				-- if vnav_alt_mode == 1 then
					-- B738DR_pfd_alt_mode = PFD_ALT_VNAV_ALT
				-- end
				
				
			-- PHASE CRUISE CLIMB
			elseif B738DR_flight_phase == 3 then
				
				vnav_alt_mode = 0
				--B738DR_autopilot_fmc_spd_pfd = 1 		-- FMC SPD on
				B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
				-- crossover altitude
				if simDR_mach_no >= B738DR_fmc_cruise_speed_mach then
					if simDR_airspeed_is_mach == 0 then
						simCMD_autopilot_co:once()
					end
				end
				-- cruise speed
				if simDR_airspeed_is_mach == 0 then
					vnav_speed_trg = B738DR_fmc_cruise_speed
				else
					vnav_speed_trg = B738DR_fmc_cruise_speed_mach
				end
				
				vnav_alt = math.min(B738DR_fmc_cruise_alt, B738DR_mcp_alt_dial)
				if vnav_alt > (simDR_altitude_pilot + 450) then
					if simDR_autopilot_altitude_mode ~= 5 then		-- LVL CHG
						at_mode_old = at_mode
						simCMD_autopilot_lvl_chg:once()
						at_mode = at_mode_old
						vnav_cruise = 0
					end
					if B738DR_autopilot_autothr_arm_pos == 1 then
						at_mode = 7
						eng1_N1_thrust_trg = eng1_N1_thrust	-- N1 THRUST
						eng2_N1_thrust_trg = eng2_N1_thrust	-- N1 THRUST
						B738DR_pfd_spd_mode = PFD_SPD_N1
					end
					--B738DR_autopilot_vnav_alt_pfd = 0	-- PFD: no VNAV ALT
					--B738DR_autopilot_vnav_pth_pfd = 1	-- PFD: VNAV PTH
					--B738DR_autopilot_vnav_spd_pfd = 0
					B738DR_pfd_alt_mode = PFD_ALT_VNAV_PTH
					simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
				else
					if B738DR_autopilot_autothr_arm_pos == 1 then
						at_mode = 9		-- SPEED mode on with N1 limit
						B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
					end
					--B738DR_autopilot_vnav_alt_pfd = 1	-- PFD: VNAV ALT
					--B738DR_autopilot_vnav_pth_pfd = 0	-- PFD: no VNAV PTH
					--B738DR_autopilot_vnav_spd_pfd = 0
					B738DR_pfd_alt_mode = PFD_ALT_VNAV_PTH
					if simDR_autopilot_altitude_mode ~= 5 then		-- LVL CHG
						if simDR_autopilot_altitude_mode == 6 then
							B738DR_flight_phase = 2
						end
						simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
					else
						simDR_ap_altitude_dial_ft = vnav_alt
					end
				end
				
			-- PHASE CRUISE DESCENT
			elseif B738DR_flight_phase == 4 then
				
				vnav_alt_mode = 0
				--B738DR_autopilot_fmc_spd_pfd = 1 		-- FMC SPD on
				B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
				-- crossover altitude
				cca_alt = B738DR_fmc_cruise_speed_mach
				if simDR_airspeed_pilot >= B738DR_fmc_cruise_speed
				and simDR_mach_no < cca_alt then
					if simDR_airspeed_is_mach == 1 then
						simCMD_autopilot_co:once()
					end
				end
				-- cruise speed
				if simDR_airspeed_is_mach == 0 then
					vnav_speed_trg = B738DR_fmc_cruise_speed
				else
					vnav_speed_trg = B738DR_fmc_cruise_speed_mach
				end
				
				if B738DR_autopilot_autothr_arm_pos == 1 then
					at_mode = 9		-- SPEED mode on with N1 limit
				end
				
				vnav_alt = math.max(B738DR_fmc_cruise_alt, B738DR_mcp_alt_dial)
				if (vnav_alt + 450) < simDR_altitude_pilot then
					simDR_ap_vvi_dial = -1000
					if simDR_autopilot_altitude_mode ~= 4 then		-- VS mode
						simCMD_autopilot_vs_sel:once()
						vnav_cruise = 0
					end
					simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
				else
					if simDR_autopilot_altitude_mode ~= 4 then		-- VS mode
						if simDR_autopilot_altitude_mode == 6 then
							B738DR_flight_phase = 2
						end
						simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
					else
						simDR_ap_altitude_dial_ft = vnav_alt
					end
				end
				
			-- PHASE DESCENT
			elseif B738DR_flight_phase > 4 then
				
				vnav_alt_hld = 0
				if B738DR_fms_descent_now == 2  then
				
					if vnav_desc_spd == 1 then
						vnav_desc_spd = 0
					end
					if B738DR_rest_wpt_alt == 0 or B738DR_rest_wpt_alt_t == 45 then
						vnav_alt = B738DR_mcp_alt_dial
					else
						vnav_alt = math.max(B738DR_rest_wpt_alt, B738DR_mcp_alt_dial)
					end
					
					-- VNAV ALT
					if vnav_alt_mode == 0 then
						
						
						-- restrict altitude
						delta_alt_dial = simDR_altitude_pilot - vnav_alt
						if delta_alt_dial < 700 and delta_alt_dial > -500 then
							if simDR_autopilot_altitude_mode ~= 6 then
								simDR_ap_altitude_dial_ft = vnav_alt
							else
								simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
								delta_vvi = simDR_vvi_fpm_pilot
								if delta_vvi < 0 then
									delta_vvi = -delta_vvi
								end
								if delta_vvi < 500 then		-- ALT HLD stabilized
									delta_alt_dial = simDR_altitude_pilot - vnav_alt
									if delta_alt_dial > 300 and B738DR_vnav_alt_err < 200 then
									--------UPDATE
										B738DR_fms_descent_now = 3		--------UPDATE
										simDR_ap_vvi_dial = B738DR_vnav_vvi		--------UPDATE
										simCMD_autopilot_vs_sel:once()
									end
								end
							end
						else
							simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
							if simDR_autopilot_altitude_mode ~= 4 then
								simDR_ap_vvi_dial = -1000
								simCMD_autopilot_vs_sel:once()
							end
						end
						
						-- crossover altitude
						delta_vvi = B738DR_fmc_descent_speed_mach
						if simDR_airspeed_pilot >= B738DR_fmc_descent_speed
						and simDR_mach_no < delta_vvi then
							if simDR_airspeed_is_mach == 1 then
								simCMD_autopilot_co:once()
							end
						end
						
						if B738DR_vnav_alt_err < 200 then	-- > -100
							B738DR_fms_descent_now = 3
						end
					else
						simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
						
					end
					
					-- descent speed
					
					-- flaps limit speeds
					flaps_speed = 340
					if flaps == 0 then
						flaps_speed = 340
					elseif flaps <= 0.25 then		-- flaps 1,2
						flaps_speed = B738DR_pfd_flaps_1
					elseif flaps <= 0.375 then		-- flaps 5
						flaps_speed = B738DR_pfd_flaps_5
					elseif flaps <= 0.5 then		-- flaps 10
						flaps_speed = B738DR_pfd_flaps_10
					elseif flaps <= 0.625 then		-- flaps 15
						if B738DR_fms_vref_15 == 0 then
							flaps_speed = B738DR_pfd_flaps_15
						else
							flaps_speed = B738DR_fms_vref_15
						end
					elseif flaps <= 0.75 then		-- flaps 25
						if B738DR_fms_vref_25 == 0 then
							flaps_speed = 175
						else
							flaps_speed = B738DR_fms_vref_25
						end
					elseif flaps <= 0.875 then		-- flaps 30
						if B738DR_fms_vref_30 == 0 then
							flaps_speed = 165
						else
							flaps_speed = B738DR_fms_vref_30
						end
					else		-- flaps 40
						if B738DR_fms_vref_40 == 0 then
							flaps_speed = 155
						else
							flaps_speed = B738DR_fms_vref_40
						end
					end
					
					if simDR_airspeed_is_mach == 0 then
						if B738DR_rest_wpt_spd > 0 then
							if B738DR_mcp_speed_dial < 100 then
								vnav_speed_trg = B738DR_rest_wpt_spd
							else
								if simDR_airspeed_dial ~= B738DR_rest_wpt_spd and simDR_dme_dist < decel_dist then
									vnav_speed_trg = B738DR_rest_wpt_spd
								end
							end
							vnav_speed_trg = math.min(vnav_speed_trg, spd_250_10000, flaps_speed)
						else
							if B738DR_calc_wpt_spd == 0 then
								vnav_speed_trg = math.min(spd_250_10000, flaps_speed)
							else
								vnav_speed_trg = math.min(B738DR_fmc_descent_speed, spd_250_10000, flaps_speed)
							end
						end
					else
						vnav_speed_trg = B738DR_fmc_descent_speed_mach
					end
				
				-- DESCENT NOW > 2
				else
					B738DR_fms_descent_now = 3
					
					delta_alt_dial = B738DR_fmc_cruise_alt - simDR_altitude_pilot
					if delta_alt_dial < 300 and simDR_autopilot_altitude_mode == 6 and B738DR_mcp_alt_dial >= B738DR_fmc_cruise_alt then
						-- crossover altitude
						if simDR_mach_no >= B738DR_fmc_cruise_speed_mach then
							if simDR_airspeed_is_mach == 0 then
								simCMD_autopilot_co:once()
							end
						end
						-- cruise speed
						if simDR_airspeed_is_mach == 0 then
							vnav_speed_trg = B738DR_fmc_cruise_speed
						else
							vnav_speed_trg = B738DR_fmc_cruise_speed_mach
						end
						
						simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
					
					else
					
						-- VNAV ALT
						if vnav_alt_mode == 0 then
						
							if vnav_desc_spd == 1 then
								-- if B738DR_vnav_alt_err > 80 and B738DR_vnav_alt_err < 300 then
								if B738DR_vnav_alt_err < -70 and B738DR_vnav_alt_err > -150 then
									simDR_ap_vvi_dial = B738DR_vnav_vvi
									simCMD_autopilot_vs_sel:once()
									vnav_desc_spd = 0 -- change to VNAV PTH
								end
								if B738DR_vnav_desc_spd_disable == 1 then
									simDR_ap_vvi_dial = B738DR_vnav_vvi
									simCMD_autopilot_vs_sel:once()
									vnav_desc_spd = 0 -- change to VNAV PTH
								end
							end
							
							if vnav_desc_spd == 0 then
							
								if B738DR_rest_wpt_alt == 0 or B738DR_rest_wpt_alt_t == 45 then		-- ignored Below alt restrict
									vnav_alt = B738DR_mcp_alt_dial
								else
									vnav_alt = math.max(B738DR_rest_wpt_alt, B738DR_mcp_alt_dial)
								end
								
								-- restrict altitude
								if vnav_alt_hold_act == 1 then
									if simDR_autopilot_altitude_mode == 6 then
										vnav_alt_hold_act = 0
										at_mode = 2
										rest_wpt_alt_idx_old = B738DR_rest_wpt_alt_idx
									else
										simDR_ap_altitude_dial_ft = vnav_alt_hold
										if B738DR_rest_wpt_alt_idx ~= rest_wpt_alt_idx_old then
											vnav_alt_hold_act = 0
											at_mode = 2
											rest_wpt_alt_idx_old = B738DR_rest_wpt_alt_idx
										end
									end
								else
									delta_alt_dial = simDR_altitude_pilot - vnav_alt
									if delta_alt_dial < 700 and B738DR_rest_wpt_alt_idx ~= rest_wpt_alt_idx_old then
										vnav_alt_hold = vnav_alt
										vnav_alt_hold_act = 1
									else
										simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
										simDR_ap_vvi_dial = B738DR_vnav_vvi
										if simDR_autopilot_altitude_mode == 6 then
											-- if vnav_desc_spd == 0 then
												delta_alt_dial = simDR_altitude_pilot - vnav_alt
												if delta_alt_dial > 100 and B738DR_vnav_alt_err < 100 then
													if simDR_autopilot_altitude_mode ~= 4 then
														simCMD_autopilot_vs_sel:once()
														vnav_alt_hold = 0
													end
												end
											-- else	-- VNAV SPD descent
												-- if B738DR_mcp_alt_dial < B738DR_rest_wpt_alt then
													-- if simDR_autopilot_altitude_mode ~= 5 then
														-- simCMD_autopilot_lvl_chg:once()
														-- vnav_alt_hold = 0
													-- end
													-- --at_mode = 7
												-- end
											-- end
										else
											-- if vnav_desc_spd == 0 then
												if simDR_autopilot_altitude_mode ~= 4 then
													simCMD_autopilot_vs_sel:once()
													vnav_alt_hold = 0
												end
											-- else
												-- if simDR_autopilot_altitude_mode ~= 5 then
													-- simCMD_autopilot_lvl_chg:once()
													-- vnav_alt_hold = 0
												-- end
											-- end
										end
									end
								end
							
							else	-- VNAV SPD descent
								if simDR_autopilot_altitude_mode ~= 5 then
									simCMD_autopilot_lvl_chg:once()
									vnav_alt_hold = 0
								end
								simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
							end
						
						else
							simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
						end
						
						-- crossover altitude
						delta_vvi = B738DR_fmc_descent_speed_mach
						if simDR_airspeed_pilot >= B738DR_fmc_descent_speed
						and simDR_mach_no < delta_vvi then
							if simDR_airspeed_is_mach == 1 then
								simCMD_autopilot_co:once()
							end
						end
						
						-- descent speed
						
						-- flaps limit speeds
						flaps_speed = 340
						if flaps == 0 then
							flaps_speed = 340
						elseif flaps <= 0.25 then		-- flaps 1,2
							flaps_speed = B738DR_pfd_flaps_1
						elseif flaps <= 0.375 then		-- flaps 5
							flaps_speed = B738DR_pfd_flaps_5
						elseif flaps <= 0.5 then		-- flaps 10
							flaps_speed = B738DR_pfd_flaps_10
						elseif flaps <= 0.625 then		-- flaps 15
							if B738DR_fms_vref_15 == 0 then
								flaps_speed = B738DR_pfd_flaps_15
							else
								flaps_speed = B738DR_fms_vref_15
							end
						elseif flaps <= 0.75 then		-- flaps 25
							if B738DR_fms_vref_25 == 0 then
								flaps_speed = 175
							else
								flaps_speed = B738DR_fms_vref_25
							end
						elseif flaps <= 0.875 then		-- flaps 30
							if B738DR_fms_vref_30 == 0 then
								flaps_speed = 165
							else
								flaps_speed = B738DR_fms_vref_30
							end
						else		-- flaps 40
							if B738DR_fms_vref_40 == 0 then
								flaps_speed = 155
							else
								flaps_speed = B738DR_fms_vref_40
							end
						end
						
						if vnav_desc_spd == 0 then
						
							if simDR_airspeed_is_mach == 0 then
								if B738DR_rest_wpt_spd > 0 then
									if B738DR_mcp_speed_dial < 100 then
										vnav_speed_trg = B738DR_rest_wpt_spd
									else
										if simDR_airspeed_dial ~= B738DR_rest_wpt_spd and simDR_dme_dist < decel_dist then
											vnav_speed_trg = B738DR_rest_wpt_spd
										end
									end
									vnav_speed_trg = math.min(vnav_speed_trg, spd_250_10000, flaps_speed)
								else
									if B738DR_calc_wpt_spd == 0 then
										vnav_speed_trg = math.min(spd_250_10000, flaps_speed)
									else
										vnav_speed_trg = math.min(B738DR_fmc_descent_speed, spd_250_10000, flaps_speed)
									end
								end
							else
								vnav_speed_trg = B738DR_fmc_descent_speed_mach
							end
						
						else
							if simDR_airspeed_is_mach == 0 then
								vnav_speed_trg = B738DR_fmc_descent_speed
							else
								vnav_speed_trg = B738DR_fmc_descent_speed_mach
							end
						end

					end
				end
				
				-- VNAV ALT
				if vnav_alt_mode == 0 then
					if B738DR_lock_idle_thrust == 0 then
						if vnav_desc_spd == 0 then
							if simDR_airspeed_is_mach == 0 then
								if simDR_airspeed_pilot < (vnav_speed_trg + 10) then
									if B738DR_autopilot_autothr_arm_pos == 1 then
										at_mode = 2
									end
								else
									if at_mode ~= 0 then
										if B738DR_thrust1_leveler == 0 or B738DR_thrust2_leveler == 0 then 
											at_mode = 0
										end
									end
								end
							else
								if simDR_mach_no < (vnav_speed_trg + 0.02) then
									if B738DR_autopilot_autothr_arm_pos == 1 then
										at_mode = 2
									end
								else
									if at_mode ~= 0 then
										if B738DR_thrust1_leveler == 0 or B738DR_thrust2_leveler == 0 then 
											at_mode = 0
										end
									end
								end
							end
						else
							if B738DR_autopilot_autothr_arm_pos == 1 then
								if simDR_autopilot_altitude_mode == 5 then
									eng1_N1_thrust_trg = 0.0
									eng2_N1_thrust_trg = 0.0
									B738DR_autopilot_n1_status = 0
									--B738DR_autopilot_n1_pfd = 0				-- PFD: no N1
									if B738DR_thrust1_leveler < 0.05 or B738DR_thrust2_leveler < 0.05 then
										at_mode = 0
										eng1_N1_thrust_cur = 0
										eng2_N1_thrust_cur = 0
									else
										--B738DR_retard_status = 1				-- PFD: RETARD
										B738DR_pfd_spd_mode = PFD_SPD_RETARD
									end
								end
							end
						end
					else
						if B738DR_autopilot_autothr_arm_pos == 1 then
							if vnav_desc_spd == 0 then
								at_mode = 2
							else
								eng1_N1_thrust_trg = 0.0
								eng2_N1_thrust_trg = 0.0
								B738DR_autopilot_n1_status = 0
								--B738DR_autopilot_n1_pfd = 0				-- PFD: no N1
								at_mode = 7
								if B738DR_thrust1_leveler < 0.05 or B738DR_thrust2_leveler < 0.05 then
									--B738DR_retard_status = 0				-- PFD: RETARD
									B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
								else
									--B738DR_retard_status = 1				-- PFD: RETARD
									B738DR_pfd_spd_mode = PFD_SPD_RETARD
								end
							end
						end
					end
					
					B738DR_autopilot_vnav_alt_pfd = 0	-- PFD: no VNAV ALT
					if vnav_desc_spd == 0 then
						--B738DR_autopilot_vnav_pth_pfd = 1	-- PFD: VNAV PTH
						--B738DR_autopilot_vnav_spd_pfd = 0	-- PFD: no VNAV SPD
						B738DR_pfd_alt_mode = PFD_ALT_VNAV_PTH
					else
						--B738DR_autopilot_vnav_pth_pfd = 0	-- PFD: VNAV PTH
						--B738DR_autopilot_vnav_spd_pfd = 1	-- PFD: no VNAV SPD
						B738DR_pfd_alt_mode = PFD_ALT_VNAV_SPD
					end
				else
					if B738DR_autopilot_autothr_arm_pos == 1 then
						at_mode = 2
						B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
					end
					--B738DR_autopilot_vnav_alt_pfd = 1	-- PFD: VNAV ALT
					--B738DR_autopilot_vnav_pth_pfd = 0	-- PFD: no VNAV PTH
					--B738DR_autopilot_vnav_spd_pfd = 0	-- PFD: no VNAV SPD
					B738DR_pfd_alt_mode = PFD_ALT_VNAV_ALT
				end
				
				if at_mode == 0 then
					--B738DR_retard_status = 0				-- PFD: no RETARD
					--B738DR_autopilot_autothrottle_pfd = 1	-- PFD: A/T ARM
					--B738DR_autopilot_fmc_spd_pfd = 0
					B738DR_pfd_spd_mode = PFD_SPD_ARM
				else
					if vnav_desc_spd == 0 then
						--B738DR_retard_status = 0				-- PFD: no RETARD
						--B738DR_autopilot_autothrottle_pfd = 0	-- PFD: no A/T ARM
						--B738DR_autopilot_fmc_spd_pfd = 1
						B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
					else
						--B738DR_autopilot_autothrottle_pfd = 0	-- PFD: no A/T ARM
						--B738DR_autopilot_fmc_spd_pfd = 0
						B738DR_pfd_spd_mode = PFD_SPD_FMC_SPD
					end
				end
			end
			
			if B738DR_ap_spd_interv_status == 0 then
				
				if vnav_speed_trg ~= 340 then
					simDR_airspeed_dial = vnav_speed_trg
					vnav_speed_trg_old = vnav_speed_trg
				else
					if vnav_speed_trg_old ~= 0 then
						simDR_airspeed_dial = vnav_speed_trg_old
					end
				end
				
				if simDR_autopilot_altitude_mode ~= 6 and B738DR_flight_phase < 2 then
					if init_climb == 0 and B738DR_flight_phase < 2 then
						speed_step = simDR_airspeed_pilot + (B738DR_speed_ratio * 9.5)	--8 10
						if speed_step > vnav_speed_trg and B738DR_flight_phase < 2 then
							if simDR_autopilot_altitude_mode ~= 5 then
								at_mode_old = at_mode
								simCMD_autopilot_lvl_chg:once()
								at_mode = at_mode_old
								--at_mode_eng = 20
								--fmc_speed_cur = simDR_airspeed_pilot
							end
							vnav_vs = 0
							if B738DR_autopilot_autothr_arm_pos == 1 then
								at_mode = 7		-- N1 thrust
								--at_mode_eng = 20
							end
							simDR_ap_vvi_dial = 0
						else
							speed_step = simDR_airspeed_pilot + 10
							if vnav_speed_trg > speed_step and B738DR_speed_ratio < 2 then
								-- turn climb vvi 900 ft
								if simDR_autopilot_altitude_mode ~= 4 then
									simDR_ap_vvi_dial = 850
									vvi_trg = simDR_ap_vvi_dial
									fmc_vvi_cur = simDR_vvi_fpm_pilot
									simCMD_autopilot_vs_sel:once()
								end
								vnav_vs = 1
							end
							-- if vnav_vs == 0 and simDR_vvi_fpm_pilot < 850 then
								-- -- turn climb vvi 900 ft
								-- if simDR_autopilot_altitude_mode ~= 4 then
									-- simDR_ap_vvi_dial = 850
									-- vvi_trg = simDR_ap_vvi_dial
									-- fmc_vvi_cur = simDR_vvi_fpm_pilot
									-- simCMD_autopilot_vs_sel:once()
								-- end
								-- vnav_vs = 1
							-- end
							if simDR_autopilot_altitude_mode == 4 then
								fmc_vvi_cur = B738_set_anim_value(fmc_vvi_cur, vvi_trg, 850, 8000, 0.15)
								simDR_ap_vvi_dial = fmc_vvi_cur
								if B738DR_autopilot_autothr_arm_pos == 1 then
									at_mode = 7		-- N1 thrust
									--at_mode_eng = 20
								end
							end
						end
						if simDR_airspeed_is_mach == 0 then
							if simDR_airspeed_pilot >= B738DR_fmc_climb_speed then
								init_climb = 1
							end
						else
							init_climb = 1
						end
					else
						init_climb = 1
					end
				else
					vnav_vs = 0
					init_climb = 0
				end
			else
				B738DR_pfd_spd_mode = PFD_SPD_MCP_SPD
				if B738DR_flight_phase < 2 then
					if vnav_vs == 1 then
						if simDR_autopilot_altitude_mode ~= 5 then
							at_mode_old = at_mode
							simCMD_autopilot_lvl_chg:once()
							at_mode = at_mode_old
						end
						vnav_vs = 0
					end
				end
			end
		
		end
	else
		vnav_engaged = 0
	end

end


-- LVL CHG and VNAV - LVL CHG, ALT HLD
function B738_lvl_chg()

	local delta_alt = 0

	--if ap_on == 1 and B738DR_autopilot_vnav_status == 0 then
	if B738DR_autopilot_vnav_status == 0 then
		if ap_pitch_mode_eng == 2 and ap_pitch_mode == 2 then --or ap_pitch_mode_eng == 5 then 		-- LVL CHG and VNAV custom
			
			--at_mode = 6
			if simDR_autopilot_altitude_mode ~= 5 then	-- not LVL CHG
				if simDR_ap_altitude_dial_ft < simDR_altitude_pilot then
					delta_alt = simDR_altitude_pilot - simDR_ap_altitude_dial_ft
					if delta_alt > 200 then
						B738DR_lvl_chg_mode = 0		-- descent
						simCMD_autopilot_lvl_chg:once()
					end
				end
				if simDR_ap_altitude_dial_ft > simDR_altitude_pilot then
					delta_alt = simDR_ap_altitude_dial_ft - simDR_altitude_pilot
					if delta_alt > 200 then
						B738DR_lvl_chg_mode = 1		-- climb
						simCMD_autopilot_lvl_chg:once()
					end
				end
			end
			if simDR_autopilot_altitude_mode == 5 then	-- LVL CHG
				
				if pitch_mode_old ~= ap_pitch_mode_eng or at_on_old ~= B738DR_autopilot_autothr_arm_pos then
					if B738DR_autopilot_autothr_arm_pos == 1 then
						at_mode = 6		-- SPEED LVL CHG
						--at_mode_eng = 20
					end
				end
				
				if B738DR_lvl_chg_mode == 0 then	-- descent mode
					if at_mode == 6 then
						eng1_N1_thrust_trg = 0.0
						eng2_N1_thrust_trg = 0.0
						B738DR_autopilot_n1_status = 0
						if B738DR_thrust1_leveler < 0.05 or B738DR_thrust2_leveler < 0.05 then
							--B738DR_retard_status = 0				-- PFD: RETARD
							--B738DR_autopilot_autothrottle_pfd = 1	-- PFD: A/T ARM
							--B738DR_autopilot_fmc_spd_pfd = 0
							B738DR_pfd_spd_mode = PFD_SPD_ARM
							if B738DR_lock_idle_thrust == 0 then
								at_mode = 0
								eng1_N1_thrust_cur = 0
								eng2_N1_thrust_cur = 0
							end
							--at_mode_eng = 0
						else
							--B738DR_retard_status = 1				-- PFD: RETARD
							--B738DR_autopilot_autothrottle_pfd = 0	-- PFD: A/T ARM
							--B738DR_autopilot_fmc_spd_pfd = 0
							B738DR_pfd_spd_mode = PFD_SPD_RETARD
						end
						B738DR_autopilot_n1_pfd = 0				-- PFD: no N1
					end
				else	-- climb mode
					if B738DR_autopilot_autothr_arm_pos == 1 then
						B738DR_autopilot_n1_status = 1
						eng1_N1_thrust_trg = eng1_N1_thrust	-- N1 THRUST
						eng2_N1_thrust_trg = eng2_N1_thrust	-- N1 THRUST
						
						--B738DR_retard_status = 0				-- PFD: no RETARD
						--B738DR_autopilot_autothrottle_pfd = 0	-- PFD: no A/T ARM
						--B738DR_autopilot_n1_pfd = 1				-- PFD: N1
						B738DR_pfd_spd_mode = PFD_SPD_N1
					end
				end
			end
		end
	end

end



-- function B738_alt_hld()

	-- local alt_x = 0
	-- if ap_on == 1 and ap_vnav_status ~= 2 then
		-- if ap_pitch_mode_eng == 3 or ap_pitch_mode_eng == 6 then
				-- if simDR_autopilot_altitude_mode == 6 then	-- ALT HLD and ALT ACQ mode
					-- if simDR_ap_altitude_dial_ft ~= B738DR_fmc_approach_alt then
						-- ap_pitch_mode = 3		-- ALT HLD
						-- ap_pitch_mode_eng = 3
					-- end
					-- if null_vvi == 1 then
						-- simDR_ap_vvi_dial = 0
						-- null_vvi = 0
					-- end
					-- if simDR_ap_altitude_dial_ft < simDR_altitude_pilot then
						-- alt_x = simDR_altitude_pilot - simDR_ap_altitude_dial_ft
					-- else
						-- alt_x = simDR_ap_altitude_dial_ft - simDR_altitude_pilot
					-- end
					-- if alt_x >= 200 and simDR_glideslope_status == 0 then
						-- B738DR_autopilot_vvi_status_pfd = 1		-- V/S arm
						-- if simDR_ap_vvi_dial ~= 0 then
							-- alt_x = simDR_ap_vvi_dial
							-- simCMD_autopilot_vs:once()
							-- simDR_ap_vvi_dial = alt_x
							-- ap_pitch_mode = 1
							-- ap_pitch_mode_eng = 1
							-- at_mode = 2		-- SPEED on
						-- end
					-- else
						-- B738DR_autopilot_vvi_status_pfd = 0		-- no V/S arm
					-- end
				-- end
		-- else
			-- B738DR_autopilot_vvi_status_pfd = 0		-- no V/S arm
			-- null_vvi = 1
		-- end
	-- end
	
-- end


function B738_alt_hld()

	local alt_x = 0
	--if ap_on == 1 and ap_vnav_status ~= 2 then
	--if ap_vnav_status ~= 2 then
	if B738DR_autopilot_vnav_status == 0 then
		if ap_pitch_mode_eng == 3 and ap_pitch_mode == 3 then
			if simDR_autopilot_altitude_mode == 6 then	-- ALT HLD
				if B738DR_gp_status == 0 then
					if null_vvi == 1 then
						simDR_ap_vvi_dial = 0
						null_vvi = 0
					end
					alt_x = simDR_altitude_pilot - simDR_ap_altitude_dial_ft
					if alt_x < 0 then
						alt_x = -alt_x
					end
					if alt_x >= 100 and simDR_glideslope_status == 0 
					and altitude_dial_ft_old ~= simDR_ap_altitude_dial_ft then
						--B738DR_autopilot_vvi_status_pfd = 1		-- V/S arm
						B738DR_pfd_alt_mode_arm = PFD_ALT_VS_ARM
						if simDR_ap_vvi_dial ~= 0 then
							simCMD_autopilot_vs_sel:once()
							ap_pitch_mode = 1
							ap_pitch_mode_eng = 1
							if pitch_mode_old ~= ap_pitch_mode_eng or at_on_old ~= B738DR_autopilot_autothr_arm_pos then
								if B738DR_autopilot_autothr_arm_pos == 1 then
									at_mode = 2		-- SPEED on
									--at_mode_eng = 20
								end
							end
						end
					else
						--B738DR_autopilot_vvi_status_pfd = 0		-- no V/S arm
						if B738DR_pfd_alt_mode_arm == PFD_ALT_VS_ARM then
							B738DR_pfd_alt_mode_arm = 0
						end
					end
				else
					--B738DR_autopilot_vvi_status_pfd = 0		-- no V/S arm
					if B738DR_pfd_alt_mode_arm == PFD_ALT_VS_ARM then
						B738DR_pfd_alt_mode_arm = 0
					end
				end
			end
		else
			--B738DR_autopilot_vvi_status_pfd = 0		-- no V/S arm
			--B738DR_pfd_alt_mode_arm = 0
			null_vvi = 1
		end
	end
	
end


function B738_alt_acq()	--ALT ACQ mode

	local alt_x = 0
	local alt_y = 0
	local alt_acq_disable = 0
	local climb_descent = 0
	--if ap_on == 1 then 
		--if ap_vnav_status == 2 and ap_pitch_mode == 5 and ap_pitch_mode_eng == 5 then
		if B738DR_autopilot_vnav_status == 1 and ap_pitch_mode == 5 and ap_pitch_mode_eng == 5 then
			if B738DR_flight_phase < 2 then
				if B738DR_mcp_alt_dial >= B738DR_fmc_cruise_alt then --or simDR_ap_altitude_dial_ft > simDR_altitude_pilot then
					alt_acq_disable = 1
				end
				if B738DR_mcp_alt_dial > B738DR_rest_wpt_alt and B738DR_rest_wpt_alt ~= 0 then
					alt_acq_disable = 1
				end
			elseif B738DR_flight_phase < 5 then
				alt_acq_disable = 1
			else
				if B738DR_mcp_alt_dial < B738DR_rest_wpt_alt and B738DR_rest_wpt_alt ~= 0 then --and B738DR_rest_wpt_alt ~= ed_alt then
					alt_acq_disable = 1
				end
				if B738DR_mcp_alt_dial < vnav_alt_hold and B738DR_rest_wpt_alt ~= 0 then --and B738DR_rest_wpt_alt ~= ed_alt then
					alt_acq_disable = 1
				end
				-- alt_x = simDR_altitude_pilot - ed_alt
				-- if B738DR_rest_wpt_alt == ed_alt and B738DR_mcp_alt_dial <= ed_alt and alt_x < 700 then	-- stop VNAV on E/D
					-- alt_acq_disable = 0
				-- end
			end
			if vnav_init2 == 0 then
				vnav_init2 = 1
				alt_acq_disable = 1
			end
		end
		if ap_pitch_mode_eng == 7 then		-- RNAV G/P or LOC G/P
			alt_acq_disable = 1
		end
		if B738DR_autoland_status == 1 or simDR_glideslope_status > 1 then
			alt_acq_disable = 1
		end
		if alt_acq_disable == 0 then
			if ap_pitch_mode ~= 6 then
				if simDR_autopilot_altitude_mode == 4 or simDR_autopilot_altitude_mode == 5 then	-- V/S or LVL CHG
					alt_x = simDR_altitude_pilot + (simDR_vvi_fpm_pilot / 3.5)	-- 17 seconds to MCP ALT
					alt_y = simDR_ap_altitude_dial_ft - simDR_altitude_pilot
					if alt_y < 0 then
						alt_y = -alt_y
						climb_descent = 1	-- descent
					end
					-- CLIMB
					if climb_descent == 0 then --simDR_vvi_fpm_pilot > 0 then
						if alt_x >= simDR_ap_altitude_dial_ft and alt_y < 1500 then
							ap_pitch_mode = 6
							ap_pitch_mode_eng = 6
							-- if simDR_autopilot_altitude_mode == 4 then
								-- if B738DR_autopilot_autothr_arm_pos == 1 then
									-- at_mode = 2		-- SPEED on
									-- at_mode_eng = 0
								-- end
							-- elseif simDR_autopilot_altitude_mode == 5 then
								-- if B738DR_autopilot_autothr_arm_pos == 1 then
									-- at_mode = 1		-- N1 with speed limit
									-- at_mode_eng = 0
								-- end
							-- end
							if simDR_glideslope_status < 2 then
								if simDR_autopilot_altitude_mode ~= 4 then
									simCMD_autopilot_vs:once()
									simDR_ap_vvi_dial = roundUpToIncrement(simDR_ap_vvi_dial, 100 )
								end
								-- ap_pitch_mode = 1
								-- ap_pitch_mode_eng = 1
							end
							if B738DR_autopilot_autothr_arm_pos == 1 then
								at_mode = 2		-- SPEED on
								at_mode_eng = 0
							end
							altitude_dial_ft_old = simDR_ap_altitude_dial_ft
							vnav_stop()
						end
					-- DESCENT
					else
						if alt_x <= simDR_ap_altitude_dial_ft and alt_y < 1500 then
							ap_pitch_mode = 6
							ap_pitch_mode_eng = 6
							-- if simDR_autopilot_altitude_mode == 4 then
								-- if B738DR_autopilot_autothr_arm_pos == 1 then
									-- at_mode = 2		-- SPEED on
									-- at_mode_eng = 0
								-- end
							-- elseif simDR_autopilot_altitude_mode == 5 then
								-- at_mode = 0		-- N1 with speed limit
								-- at_mode_eng = 0
							-- end
							if simDR_glideslope_status < 2 then
								if simDR_autopilot_altitude_mode ~= 4 then
									simCMD_autopilot_vs:once()
									simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100 )
								end
								-- ap_pitch_mode = 1
								-- ap_pitch_mode_eng = 1
							end
							if B738DR_autopilot_autothr_arm_pos == 1 then
								at_mode = 2		-- SPEED on
								at_mode_eng = 0
							end
							altitude_dial_ft_old = simDR_ap_altitude_dial_ft
							vnav_stop()
						end
					end
				end
			end
			if ap_pitch_mode_eng == 6 and ap_pitch_mode == 6 and altitude_dial_ft_old ~= simDR_ap_altitude_dial_ft then
				alt_x = simDR_altitude_pilot - simDR_ap_altitude_dial_ft
				if alt_x < 0 then
					alt_x = -alt_x
				end
				if alt_x > 200 and simDR_glideslope_status < 2 then
					if simDR_autopilot_altitude_mode ~= 4 then
						simCMD_autopilot_vs:once()
						simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100 )
					end
					ap_pitch_mode = 1
					ap_pitch_mode_eng = 1
					if pitch_mode_old ~= ap_pitch_mode_eng or at_on_old ~= B738DR_autopilot_autothr_arm_pos then
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 2		-- SPEED on
							--at_mode_eng = 20
						end
					end
				end
			end
			if ap_pitch_mode_eng == 6 and ap_pitch_mode == 6 then
				if simDR_autopilot_altitude_mode == 6 then
					simDR_ap_vvi_dial = 0
					vnav_stop()
					ap_pitch_mode = 3
					ap_pitch_mode_eng = 3
					if B738DR_autopilot_autothr_arm_pos == 1 then
						at_mode = 2		-- SPEED on
						--at_mode_eng = 20
					end
				end
			end
			if ap_pitch_mode_eng == 3 and ap_pitch_mode == 3 then
				if simDR_autopilot_altitude_mode == 6 then
					ap_pitch_mode = 3
					ap_pitch_mode_eng = 3
					--only once
					if ap_pitch_mode_eng ~= pitch_mode_old or at_on_old ~= B738DR_autopilot_autothr_arm_pos then
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 2		-- SPEED on
							--at_mode_eng = 20
						end
					end
				end
			end
			
			-- if simDR_autopilot_altitude_mode == 6 then
				-- if ap_pitch_mode == 6 then
					-- simDR_ap_vvi_dial = 0
					-- vnav_stop()
				-- end
				-- if ap_pitch_mode == 6 or ap_pitch_mode == 3 then
					-- ap_pitch_mode = 3
					-- ap_pitch_mode_eng = 3
					-- at_mode = 2		-- SPEED on
				-- else
					-- ap_pitch_mode = 0
				-- end
			-- end
		end
	--end
	
end


function B738_vs()

	--if ap_on == 1 and ap_vnav_status ~= 2 then
	--if ap_vnav_status ~= 2 then
	if B738DR_autopilot_vnav_status == 0 then
		if ap_pitch_mode_eng == 1 and ap_pitch_mode == 1 then
			-- if simDR_autopilot_altitude_mode == 6 then	-- ALT HLD
				-- at_mode = 2		-- SPEED on
				-- ap_pitch_mode = 3
				-- ap_pitch_mode_eng = 3
			if simDR_autopilot_altitude_mode ~= 4 then
				if simDR_ap_vvi_dial == 0 then
					simCMD_autopilot_vs:once()
				else
					simCMD_autopilot_vs_sel:once()
				end
			end
			if vs_first == 0 then
				vs_first = 1
				if at_mode ~= 2 then
					if B738DR_autopilot_autothr_arm_pos == 1 then
						at_mode = 2		-- SPEED on
						--at_mode_eng = 20
					end
				end
			end
		else
			vs_first = 0
		end
	else
		vs_first = 0
	end

end

function B738_app()
	--if ap_on == 1 then
		if simDR_approach_status > 1 
		and simDR_glideslope_status > 1 then
			ap_app_block = 1
			if simDR_radio_height_pilot_ft < 800 then
				ap_app_block_800 = 1
			else
				ap_app_block_800 = 0
			end
		else
			ap_app_block = 0
			ap_app_block_800 = 0
		end
	-- else
		-- ap_app_block = 0
		-- ap_app_block_800 = 0
	-- end
	
	if ap_roll_mode_eng == 3 then
		B738DR_ap_ils_active = 1
		if at_mode ~= 2 then
			if B738DR_autopilot_autothr_arm_pos == 1 then
				at_mode = 2		-- SPEED on
				--at_mode_eng = 20
			end
		end
	else
		B738DR_ap_ils_active = 0
	end
	--end
end


function B738_fac()
	
	local wca = 0
--	local ws = 0
	local wh = 0
	local tas = 0
	local awa = 0
	local relative_brg = 0
	local mag_hdg = 0
	local mag_trk = 0	-- temporary without mag variantion
	local ap_hdg = 0
	local rnp_deg = 0
	local bearing_corr = 0
	local idx_corr = 0
	local idx_dist = 0
	
	if ap_roll_mode == 8 then		-- FAC
		--if simDR_nav_status == 2 and B738DR_gp_active == 2 then
		if B738DR_gp_active == 2 then
			fac_engaged = 1
		-- else
			-- if B738DR_gp_status == 0 then
				-- B738DR_gp_status = 1	-- G/P armed
			-- end
		end
		if ap_pitch_mode_eng ~= 7 then
			B738DR_gp_status = 1	-- G/P armed
		end
	else
		-- disengage GP
		if ap_pitch_mode == 7 then
			ap_pitch_mode = 0
		end
		fac_engaged = 0
	end
	if fac_engaged == 1 then --and ap_roll_mode_eng ~= 8 then
		-- IAN -> LNAV/VNAV mode G/P
		if ap_roll_mode_eng ~= 8 then
			ap_roll_mode_eng = 8
			lnav_vorloc = 0
			lnav_app = 0
			
			if simDR_approach_status > 0 then
				simCMD_autopilot_app:once()
			end
		end
		
		if simDR_autopilot_heading_mode ~= 1 then
			simCMD_autopilot_hdg:once()
		end
		
		mag_trk = simDR_fmc_trk + simDR_mag_variation
		relative_brg = (mag_trk - simDR_fmc_crs + 360) % 360
		if relative_brg > 180 then
			relative_brg = relative_brg - 360
		end
		
		idx_dist = math.min(simDR_dme_dist, 0)
		idx_dist = math.max(simDR_dme_dist, 2.5)
		idx_corr = B738_rescale(0, 1, 2.5, 4, idx_dist)
		bearing_corr = relative_brg * idx_corr
		
		if bearing_corr < -50 then
			bearing_corr = -50
		end
		if bearing_corr > 50 then
			bearing_corr = 50
		end
		ap_hdg = (mag_trk - bearing_corr + 360) % 360	-- last working and testing
		
		-- wind correction
		mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
		tas = simDR_ground_spd * 1.94384449244	-- m/s to knots
		wh = (simDR_wind_hdg + 180) % 360
		relative_brg = (wh - mag_hdg + 360) % 360
		if relative_brg > 180 then
			relative_brg = relative_brg - 360
		end
		if relative_brg < -90 then
			awa = math.rad(180 + relative_brg)
			wca = math.asin(simDR_wind_spd * ((math.sin(awa) / tas)))
			wca = math.deg(-wca)
		elseif relative_brg < 0 then
			awa = math.rad(-relative_brg)
			wca = math.asin(simDR_wind_spd * ((math.sin(awa) / tas)))
			wca = math.deg(-wca)
		elseif relative_brg < 90 then
			awa = math.rad(relative_brg)
			wca = math.asin(simDR_wind_spd * ((math.sin(awa) / tas)))
			wca = math.deg(wca)
		else
			awa = math.rad(180 - relative_brg)
			wca = math.asin(simDR_wind_spd * ((math.sin(awa) / tas)))
			wca = math.deg(wca)
		end
		simDR_ap_capt_heading = (ap_hdg - wca) % 360
		
		if at_mode ~= 2 then
			if B738DR_autopilot_autothr_arm_pos == 1 then
				at_mode = 2		-- SPEED on
			end
		end
	end
	-- FAC disengage
	if ap_roll_mode == 8 and B738DR_gp_active == 0 and fac_engaged == 1 then
		ap_roll_mode = 0
	end
	if ap_pitch_mode == 7 and B738DR_gp_active == 0 and fac_engaged == 1 then
		ap_pitch_mode = 0
	end

end

function B738_gp()
--	if ap_on == 1 then
		local r_delta_alt = 0
		if ap_pitch_mode_eng == 7 and ap_pitch_mode == 7 then	-- G/P -> LOC/VNAV
			if pitch_mode_old ~= ap_pitch_mode_eng or at_on_old ~= B738DR_autopilot_autothr_arm_pos then
				if B738DR_autopilot_autothr_arm_pos == 1 then
					at_mode = 2
					--at_mode_eng = 20
				end
			end
			r_delta_alt = simDR_altitude_pilot + 700
			if B738DR_mcp_alt_dial > r_delta_alt then
				simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
			else
				simDR_ap_altitude_dial_ft = 0	-- ignored MCP alt dial
			end
			simDR_ap_vvi_dial = B738DR_gp_vvi
			if simDR_autopilot_altitude_mode ~= 4 then
				simCMD_autopilot_vs_sel:once()
			end
		end
--	else
--		if ap_pitch_mode_eng == 7 and ap_pitch_mode == 7 then	-- G/P -> RNAV/VNAV and LOC/VNAV
--			simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
--		end
--	end
end

function B738_lnav_vnav()
	
	local r_delta_alt = 0
	if ap_pitch_mode_eng == 5 and ap_pitch_mode == 5 	-- VNAV
	and ap_roll_mode_eng == 4 and ap_roll_mode == 4		-- LNAV
	and B738DR_gp_active == 2 and B738DR_pfd_vert_path == 1 then	-- (G/P) -> LNAV/VNAV
		if pitch_mode_old ~= ap_pitch_mode_eng or at_on_old ~= B738DR_autopilot_autothr_arm_pos then
			if B738DR_autopilot_autothr_arm_pos == 1 then
				at_mode = 2
				--at_mode_eng = 20
			end
		end
		r_delta_alt = simDR_altitude_pilot + 700
		if B738DR_mcp_alt_dial > r_delta_alt then
			simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
		else
			simDR_ap_altitude_dial_ft = 0	-- ignored MCP alt dial
		end
		simDR_ap_vvi_dial = B738DR_vnav_vvi
		if simDR_autopilot_altitude_mode ~= 4 then
			simCMD_autopilot_vs_sel:once()
		end
	end
	
end

function B738_loc_vnav()
	
	local r_delta_alt = 0
	if ap_pitch_mode_eng == 5 and ap_pitch_mode == 5 	-- VNAV
	and ap_roll_mode_eng == 2 and ap_roll_mode == 2		-- VOR LOC
	and B738DR_gp_active == 2 and B738DR_pfd_vert_path == 1 then	-- (G/P) -> LOC/VNAV
		if pitch_mode_old ~= ap_pitch_mode_eng or at_on_old ~= B738DR_autopilot_autothr_arm_pos then
			if B738DR_autopilot_autothr_arm_pos == 1 then
				at_mode = 2
				--at_mode_eng = 20
			end
		end
		r_delta_alt = simDR_altitude_pilot + 700
		if B738DR_mcp_alt_dial > r_delta_alt then
			simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
		else
			simDR_ap_altitude_dial_ft = 0	-- ignored MCP alt dial
		end
		simDR_ap_vvi_dial = B738DR_vnav_vvi
		if simDR_autopilot_altitude_mode ~= 4 then
			simCMD_autopilot_vs_sel:once()
		end
	end
	
end

-- AUTOMATIC AIRSPEED: KTS / MACH

-- function B738_kts_mach()

	-- if B738DR_autopilot_vnav_status == 0 then
		
		-- if simDR_altitude_pilot > 26000
		-- and B738DR_mach_disable == 0 then
			-- B738DR_mach_disable = 1
			-- B738DR_kts_disable = 0
			-- if simDR_airspeed_is_mach == 0 then
				-- simCMD_autopilot_co:once()
			-- end
		-- end

		-- if simDR_altitude_pilot < 25500
		-- and B738DR_kts_disable == 0 then
			-- B738DR_mach_disable = 0
			-- B738DR_kts_disable = 1
			-- if simDR_airspeed_is_mach == 1 then
				-- simCMD_autopilot_co:once()
			-- end
		-- end
	
	-- end

-- end

function B738_bellow_400ft()
	if simDR_radio_height_pilot_ft > 410 then
		bellow_400ft = 0
	end
	if simDR_radio_height_pilot_ft < 390 then
		bellow_400ft = 1
	end
end


--- CUSTOM AUTOLAND

-- function annun_single_ch()
	-- B738DR_single_ch_status = 0		-- SINGLE CH off
-- end

function annun_flare()
	B738DR_single_ch_status = 0		-- SINGLE CH off
	B738DR_flare_status = 1			-- FLARE armed
	ap_roll_mode = 9
end

function ils_test_off()
	ils_test_on = 0
	ils_test_ok = 1
end

function ap_at_off()

	simCMD_autothrottle_discon:once()	-- disconnect autothrotle
	B738DR_autopilot_autothrottle_status = 0
	B738DR_autopilot_autothr_arm_pos = 0
	at_mode = 0
	--at_mode_eng = 0
	--at_on_first = 0

end


function B738_adjust_flare()

	local flare_vvi = simDR_vvi_fpm_pilot
	local flare_delta_vvi = 0
--	local vvi_trend = 0
	
	flare_delta_vvi = flare_vvi - flare_vvi_old
	--flare_delta_vvi = -flare_delta_vvi
	vvi_trend = flare_vvi + (20 * flare_delta_vvi)	--10
	if vvi_trend > -30 then	--0 then
		fd_target = fd_cur - 0.075		--0.15	--- EDIT by vvi_trend !!!!!
	end
	if flare_vvi > -500 and flare_delta_vvi < 90 and fd_target > 2.0 then		-- 80
		fd_target = fd_cur - 0.35	-- 0.7
		B738DR_flare_ratio = 1.0	-- 1.5
	end
	flare_vvi_old = flare_vvi

end

function B738_ap_autoland()
	-- local vvi_target = 0
	-- local trim_rate = 0
	-- local rate_vvi = -1.0
	-- local rate_target = -1.0
	local delta_vvi = 0.0
	local delta_vref = 0
	local vref = 0
	local flare_alt = 0
	local vvi = 0
	local fd_corection = 0
	local weight_t = 0
	local weight_lbs = 0
	local vdot = 0
	local vdot_sim = 0
	local vdot_trend = 0
	local vvi_dial_act = 0
	local vvi_dial_trg = 0
	
	if B738DR_flare_status == 1 then		-- if FLARE armed
		
		if simDR_radio_height_pilot_ft < 250 then	-- at 500 /100 ft stabilized
			if vorloc_only == 0 then
				simCMD_autopilot_lnav:once()	-- A/P mode VOR/LOC
				simCMD_autopilot_lnav:once()	-- A/P mode VOR/LOC
				fd_cur = simDR_fdir_pitch
				simDR_fdir_pitch_ovr = 1
				B738DR_autopilot_alt_mode_pfd = 8	-- PFD ALT mode: G/S
				vorloc_only = 1
				simDR_fdir_pitch = fd_cur
			end
			-- if simDR_radio_height_pilot_ft > 240 then	-->110
				-- if simDR_vdot_nav1_pilot == nil or B738DR_vdot_ratio == 999 then
					-- simDR_fdir_pitch = fd_cur
				-- else
					-- vdot_sim = simDR_vdot_nav1_pilot
					-- vdot = -vdot_sim * 0.31	--0.12--0.1
					-- B738DR_flare_offset = vdot
					-- vdot = vdot - B738DR_vdot_ratio
					-- vdot = vdot * 5.3	--3.3
					-- if vdot < -0.005 then
						-- vdot = -0.005
					-- end
					-- if vdot > 0.005 then
						-- vdot = 0.005
					-- end
					-- fd_cur = simDR_fdir_pitch
					-- fd_target = fd_cur + vdot
					-- simDR_fdir_pitch = B738_set_anim_value(fd_cur, fd_target, -20, 20, 0.3)
				-- end
			if simDR_radio_height_pilot_ft > 90 then	--120 150
				simDR_fdir_pitch_ovr = 0
				if simDR_autopilot_altitude_mode ~= 4 then
					simDR_ap_vvi_dial = simDR_vvi_fpm_pilot
					simCMD_autopilot_vs_sel:once()
				end
				vvi_dial_trg = -850		--800 780
				vvi_dial_act = simDR_ap_vvi_dial
				simDR_ap_vvi_dial = B738_set_anim_value(vvi_dial_act, vvi_dial_trg, -1000, -550, 0.5)
				fd_cur = simDR_fdir_pitch
			elseif simDR_radio_height_pilot_ft > 60 then		--70
				simDR_fdir_pitch_ovr = 0
				if simDR_autopilot_altitude_mode ~= 4 then
					simDR_ap_vvi_dial = simDR_vvi_fpm_pilot
					simCMD_autopilot_vs_sel:once()
				end
				vvi_dial_trg = -550
				vvi_dial_act = simDR_ap_vvi_dial
				simDR_ap_vvi_dial = B738_set_anim_value(vvi_dial_act, vvi_dial_trg, -1000, -550, 0.5)
				fd_cur = simDR_fdir_pitch
			else
				if simDR_autopilot_altitude_mode == 4 then
					simCMD_autopilot_vs_sel:once()
					simDR_ap_vvi_dial = 0
				end
				simDR_fdir_pitch_ovr = 1
				simDR_fdir_pitch = fd_cur
			end
		end
		
		B738DR_pitch_last = simDR_fdir_pitch
		B738DR_vvi_last = simDR_vvi_fpm_pilot	-- touch down vvi
		
		-- rate of descent in fpm = tan(glideslope) * (speed in knots * 6076 / 60)
		if simDR_radio_height_pilot_ft < 43 then ---40  45 then	-- at 50 ft FLARE
			B738DR_flare_status = 2			-- FLARE engaged
			fd_cur = simDR_fdir_pitch
			vvi = simDR_vvi_fpm_pilot
			throttle = eng1_N1_thrust_cur
			simDR_autothrottle_enable = 0
			if B738DR_autopilot_autothr_arm_pos == 1 then
				at_mode = 6
				at_mode_eng = 6
				eng1_N1_thrust_trg = throttle
				eng2_N1_thrust_trg = throttle
			end
			delta_vvi = math.min(simDR_airspeed_pilot, 145)
			delta_vvi = math.max(simDR_airspeed_pilot, 130)
			fd_target = B738_rescale(130, 0, 145, 0.45, delta_vvi)
			fd_target = 0.45 - fd_target
			throttle_trg = throttle + fd_target		--0.28	-- 0.22 --0.28 --0.25

			delta_vvi = -B738DR_vvi_last
			delta_vvi = math.max(580, delta_vvi)
			delta_vvi = math.min(1000, delta_vvi)
			
			fd_target = fd_cur + B738_rescale(580, 2.8, 1000, 6.5, delta_vvi)	-- 3.0 / 6.5
			
			if fd_target < 2 then
				fd_target = 2			-- minimum FLARE pitch
			end
			if fd_target < fd_cur then		-- minimum nose up
				fd_target = fd_cur + 2
			end
			if fd_target > 7 then		-- maximum nose up
				fd_target = 7
			end
			flare_vvi_old = simDR_vvi_fpm_pilot
			if is_timer_scheduled(B738_adjust_flare) == false then
				run_at_interval(B738_adjust_flare, 0.5)	--0.3)
			end
			B738DR_flare_ratio = B738_rescale(580, 3.4, 1000, 5.9, delta_vvi)		-- 3.2 / 5.9
		end
-----------------------------------------------------------------------
		
		
	end
	
	if B738DR_flare_status == 2 then		-- if FLARE engaged
	
		B738DR_autopilot_alt_mode_pfd = 0	-- PFD ALT mode: blank
		if fd_target < 2 then
			fd_target = 2
		end
		if fd_target > 7 then
			fd_target = 7
		end
		
		if simDR_radio_height_pilot_ft < 10 then
			fd_target = 0
			fd_cur = B738_set_anim_value(fd_cur, fd_target, -20, 20, 0.5)		-- 4
		else
			fd_cur = B738_set_anim_value(fd_cur, fd_target, -20, 20, B738DR_flare_ratio)	--rate 0.5, 0.33 0.43
		end
		
		if simDR_radio_height_pilot_ft < 23 then	--23
			throttle = throttle - B738DR_thrust_ratio_1
		else
			if simDR_vvi_fpm_pilot > B738DR_thrust_vvi_1 then
				throttle = throttle - B738DR_thrust_ratio_1
			elseif simDR_vvi_fpm_pilot > B738DR_thrust_vvi_2 then
				throttle = throttle - B738DR_thrust_ratio_2
			else
				if throttle < throttle_trg then
					throttle = throttle + 0.05
				end
			end
		end
		if throttle <= 0 or simDR_radio_height_pilot_ft < 15 then		--15
			throttle = 0
		end
		simDR_fdir_pitch = fd_cur
		--B738DR_retard_status = 1			-- RETARD engaged
		B738DR_pfd_spd_mode = PFD_SPD_RETARD
		
		B738DR_vvi_last = simDR_vvi_fpm_pilot	-- touch down vvi

--		--simDR_throttle_all = throttle		-- set thrust
		if at_mode ~= 0 then
			if B738DR_autopilot_autothr_arm_pos == 1 then
				eng1_N1_thrust_trg = throttle
				eng2_N1_thrust_trg = throttle
			end
		end
		
	end
-----------------------------------------------------------------------
	
	if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 
	or simDR_on_ground_2 == 1 then		-- if aircraft on ground
		if B738DR_autoland_status == 1 then 	-- autoland active
			--simDR_fdir_pitch_ovr = 1
			--simDR_fdir_pitch = 0
			--simDR_fdir_pitch_ovr = 0
			if cmd_first == 0 then
				autopilot_cmd_b_status = 0
			else
				autopilot_cmd_a_status = 0
			end
			B738DR_autoland_status = 0
			simDR_ap_vvi_dial = 0
			ils_test_enable = 0
			ils_test_on = 0
			B738DR_flare_status = 0
			--B738DR_retard_status = 0
			B738DR_pfd_spd_mode = PFD_SPD_ARM
			--at_mode = 0
			--at_mode_eng = 0
			vorloc_only = 0
			--ap_roll_mode = 2
			ap_roll_mode = 0
			ap_pitch_mode = 0
			----simDR_throttle_override = 0
			--simDR_throttle_all = 0				-- thrust idle
			if is_timer_scheduled(B738_adjust_flare) == true then
				stop_timer(B738_adjust_flare)
			end
		end
		if aircraft_was_on_air == 1 then
			aircraft_was_on_air = 0
			if at_mode ~= 4 and at_mode ~= 5 then		-- if aircraft touch down
				if is_timer_scheduled(ap_at_off) == false then
					run_after_time(ap_at_off, 3.0)
				end
			end
		end
	end
--	end
end

function B738_ap_system()
	-- local crs1 = math.floor(simDR_hsi_crs1 + 0.5)
	-- local crs2 = math.floor(simDR_hsi_crs1 + 0.5)
	
	local crs1 = math.floor(simDR_crs1 + 0.5)
	local crs2 = math.floor(simDR_crs2 + 0.5)

	if B738DR_autoland_status == 0 then
		if is_timer_scheduled(B738_adjust_flare) == true then
			stop_timer(B738_adjust_flare)
		end
	elseif B738DR_autoland_status == 1 then
--		if B738DR_autopilot_fd_pos == 0
--		or B738DR_autopilot_fd_fo_pos == 0 then		-- AUTOLAND and A/P disconnect
		if at_mode ~= 0 then
			if B738DR_autopilot_autothr_arm_pos == 1 then
				eng1_N1_thrust_trg = throttle
				eng2_N1_thrust_trg = throttle
			end
		end
		if ap_on == 0 or B738DR_autopilot_fd_pos == 0 or B738DR_autopilot_fd_fo_pos == 0 then
--		and B738DR_fd_on == 0 then		-- AUTOLAND and A/P disconnect
			simDR_flight_dir_mode = 1
		-- F/D on
			ap_roll_mode_eng = 0
			ap_pitch_mode_eng = 0
			autopilot_cmd_a_status = 0
			autopilot_cmd_b_status = 0
			B738DR_autoland_status = 0
			B738DR_flare_status = 0
			B738DR_retard_status = 0
			simDR_ap_vvi_dial = 0
			at_mode = 0
			at_mode_eng = 0
			vorloc_only = 0
			----simDR_throttle_override = 0
			ils_test_enable = 0
			ils_test_on = 0
		end
	end

	if simDR_radio_height_pilot_ft < 350
	and simDR_radio_height_pilot_ft > 250
	and B738DR_flare_status == 0 
	and ap_on == 1 
	and at_mode ~= 4 
	and at_mode ~= 5 
	and B738DR_flight_phase > 0 then
	--and ap_pitch_mode_eng ~= 7 then
--	and simDR_autopilot_on == 1 then		-- at 350ft RA: if FLARE off -> A/P disengage
		simDR_flight_dir_mode = 1
			-- F/D on only
		autopilot_cws_a_status = 0
		autopilot_cws_b_status = 0
		autopilot_cmd_b_status = 0
		autopilot_cmd_a_status = 0
		B738DR_single_ch_status = 0
	end
	
	if B738DR_autoland_status == 1 
	and simDR_glideslope_status == 2
	and simDR_radio_height_pilot_ft < 1480 	-- 1300 ft
	and ils_test_ok == 1 then
		if B738DR_flare_status == 0 then
			if is_timer_scheduled(annun_flare) == false then
				run_after_time(annun_flare, 1.5)
			end
			--B738DR_flare_status = 1		-- FLARE armed
		end
	end
	
	if simDR_radio_height_pilot_ft > 100 
	and aircraft_was_on_air ==  0 then		-- aircraft above 100 ft RA
		aircraft_was_on_air = 1
	end
	
	if simDR_approach_status == 2
	and ap_on == 1 then
		if simDR_radio_height_pilot_ft < 1500
		and B738DR_autoland_status == 1 then
			if simDR_nav1 == simDR_nav2
			and crs1 == crs2 then
				--if ils_test_ok == 1 then
					--if B738DR_single_ch_status == 1 then
						--if is_timer_scheduled(annun_single_ch) == false then
						--	run_after_time(annun_single_ch, 1.0)
						--end
					--end
					--B738DR_single_ch_status = 0			-- SINGLE CH off
				--end
			else		-- AUTOLAND off
				B738DR_autoland_status = 0
				simDR_ap_vvi_dial = 0
				ils_test_enable = 0
				ils_test_on = 0
				if B738DR_autopilot_side == 0 then
					autopilot_cmd_b_status = 0			-- CMD B light off
				else
					autopilot_cmd_a_status = 0			-- CMD A light off
				end
				B738DR_autopilot_app_status = 1		-- APP light on
				B738DR_flare_status = 0				-- FLARE status off
				B738DR_single_ch_status = 1			-- SINGLE CH on
			end
		else
			if simDR_radio_height_pilot_ft < 1500 and simDR_glideslope_status == 2 then		--ils_test_ok == 0 and 
				B738DR_single_ch_status = 1			-- SINGLE CH on
			end
		end
	else
		if ap_roll_mode == 8 and ap_roll_mode_eng == 8 
		and ap_pitch_mode == 7 and ap_pitch_mode_eng == 7 and ap_on == 1 then
			B738DR_single_ch_status = 1			-- SINGLE CH on
		else
			B738DR_single_ch_status = 0			-- SINGLE CH off
		end
	end
	
	
	if ils_test_enable == 1 and simDR_glideslope_status == 2 
	and simDR_radio_height_pilot_ft < 1480 then
		ils_test_on = 1
		if is_timer_scheduled(ils_test_off) == false then
			run_after_time(ils_test_off, 7.0)
		end
		ils_test_enable = 0
	end
	
	-- flight director to O
	if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 
	or simDR_on_ground_2 == 1 then		-- if aircraft on ground
		if ap_pitch_mode == 0 or B738DR_autopilot_vnav_arm_pfd == 1 then
			if at_mode < 3 or at_mode > 5 then
				if simDR_fdir_pitch_ovr ~= 1 then 
					simDR_fdir_pitch_ovr = 1
				end
				fd_target = 0
				fd_cur = B738_set_anim_value(fd_cur, fd_target, -20, 20, 3)
				simDR_fdir_pitch = fd_cur
			end
		end
	else
		if simDR_radio_height_pilot_ft < 20 then
			if at_mode < 3 or at_mode > 5 then
				if simDR_fdir_pitch_ovr ~= 0 then
					simDR_fdir_pitch_ovr = 0
				end
			end
		end
	end
	
	
end

function vnav_stop()
	
	-- if simDR_vnav_status == 1 then
		-- simCMD_autopilot_vnav:once()		-- default VNAV off
	-- end
	-- simDR_fms_override = 0
	--vnav_active = 0
	--B738DR_vvi_dial_show = 1
	-- if ap_pitch_mode == 5 then
		-- ap_pitch_mode = 0
	-- end
	B738DR_autopilot_vnav_alt_pfd = 0	-- PFD: VNAV ALT
	B738DR_autopilot_vnav_pth_pfd = 0	-- PFD: VNAV PTH
	B738DR_autopilot_vnav_spd_pfd = 0	-- PFD: VNAV SPD
	
	-- simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
	B738DR_ap_spd_interv_status = 0
	vnav_engaged = 0
	vnav_desc_spd = 0
	
	if B738DR_autopilot_autothr_arm_pos == 1 then
		if B738DR_autopilot_n1_status == 0 then
			if at_mode ~= 0 then
				at_mode = 2
			end
		else
			at_mode = 1
		end
	end

	
end


function B738_ap_logic()

	local delta_alt = 0
	local altitude_dial = 0
	local airspeed_dial = 0
	local alt_x = 0
	local thrust = 0
	local crs_min = 0
	local crs_max = 0
	local vdot = 0
	local nav_course_pilot = 0
	local nav_bearing = 0
	local nav_hdispl = 0
	local nav_hdots = 0
	local nav1_hdots_pilot = 0
	local nav2_hdots_pilot = 0
	local nav1_hdots_copilot = 0
	local nav2_hdots_copilot = 0
	local vnav_enable = 0
	local allign_ok = 0

	if simDR_flight_dir_mode == 0 then
		autopilot_cmd_a_status = 0
		autopilot_cmd_b_status = 0
		B738DR_autopilot_cws_a_status = 0
		B738DR_autopilot_cws_b_status = 0
		ap_roll_mode_eng = 0
		ap_pitch_mode_eng = 0
		simDR_flight_dir_mode = 1
		simDR_airspeed_dial = mem_airspeed_dial
		if mem_speed_mode == 1 
		and B738DR_autopilot_autothr_arm_pos == 1 then
			simDR_autothrottle_enable = 1
		end
	end
	mem_airspeed_dial = simDR_airspeed_dial
	mem_speed_mode = simDR_autothrottle_status
	if B738DR_autoland_status == 1 			-- AUTOLAND
	or ap_pitch_mode == 5 					-- VNAV
	or ap_pitch_mode == 2					-- LVL CHG
	or ap_pitch_mode == 6 					-- ALT ACQ
	or ap_pitch_mode == 7 then				-- RNAV/VNAV, LOC/VNAV
		B738DR_vvi_dial_show = 0
	else
		B738DR_vvi_dial_show = 1
	end
	
	
	if autopilot_cmd_a_status == 1 or autopilot_cmd_b_status == 1 then
		ap_on = 1
	else
		ap_on = 0
--		----simDR_throttle_override = 0
		cmd_first = 0
		ap_app_block = 0
		ils_test_enable = 0
		ils_test_on = 0
		ils_test_ok = 0
		-- if B738DR_autoland_status == 0 and at_mode ~= 3 then
			-- if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 
			-- or simDR_on_ground_2 == 1 then		-- if aircraft on ground
				-- simDR_fdir_pitch_ovr = 1
				-- simDR_fdir_pitch = 0
			-- else
				-- simDR_fdir_pitch_ovr = 0
			-- end
		-- end
	end
	
	if ap_on == 0 then
		simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
	else
		if B738DR_autopilot_vnav_status ~= 1 and ap_pitch_mode_eng ~= 7 then 
			simDR_ap_altitude_dial_ft = B738DR_mcp_alt_dial
		end
	end
	
	-- local show_mcp_ias = 0
	-- if B738DR_show_ias == 0 then	-- IAS show on
		-- show_mcp_ias = 1
	-- else
		-- if simDR_vnav_status == 0 then
			-- show_mcp_ias = 1
		-- else
			-- if simDR_fms_fpta ~= nil then
				-- show_mcp_ias = 1
			-- end
		-- end
	-- end
	
	
	-- if show_mcp_ias == 1 then
		-- B738DR_mcp_speed_dial = simDR_airspeed_dial
		-- B738DR_mcp_speed_dial_kts = simDR_airspeed_dial_kts
	-- end
	-- if B738DR_autopilot_vnav_status == 1 and simDR_vnav_status == 0 and B738DR_ap_spd_interv_status == 0 then
		-- simDR_airspeed_dial = B738DR_mcp_speed_dial
		-- simDR_airspeed_dial_kts = B738DR_mcp_speed_dial_kts
	-- end
	
	B738DR_mcp_speed_dial = simDR_airspeed_dial
	B738DR_mcp_speed_dial_kts = simDR_airspeed_dial_kts
	
	
	-- IRS allign
	if B738DR_irs_left_mode > 1 or B738DR_irs_right_mode > 1 then
		allign_ok = 1
	end
	if allign_ok == 0 then
		ap_roll_mode = 0
	end
	
	if B738DR_vnav_disconnect == 1 then
		B738DR_vnav_disconnect = 0
		ap_pitch_mode = 0
	end
	if B738DR_lnav_disconnect == 1 then
		B738DR_lnav_disconnect = 0
		ap_roll_mode = 0
	end
	
	roll_mode_old = ap_roll_mode_eng
	pitch_mode_old = ap_pitch_mode_eng
	
	
	if ap_roll_mode ~= ap_roll_mode_eng then
		
		-- ROLL MODES: 0-off, 1-HDG SEL, 2-VOR/LOC, 3-APP, 4-LNAV
		if ap_roll_mode == 0 then
			ap_roll_mode_eng = 0
			if simDR_approach_status > 0 then
				simCMD_autopilot_app:once()
				if ap_pitch_mode == 4 then
					ap_pitch_mode = 0
				end
			end
			if simDR_nav_status > 0 then
				simCMD_autopilot_lnav:once()
				if autopilot_fms_nav_status == 1 and ap_pitch_mode == 7 then
					ap_pitch_mode = 0
				end
			end
			if simDR_autopilot_heading_mode == 1 then
				simCMD_autopilot_hdg:once()		-- HDG off
			end
			autopilot_fms_nav_status = 0
			B738DR_gp_status = 0
			-- simDR_crs1 = B738DR_course_pilot
			-- simDR_crs2 = B738DR_course_copilot
			--vnav_stop()
		
		-- HDG mode
		elseif ap_roll_mode == 1 then
			ap_roll_mode_eng = 1
			if simDR_approach_status > 0 then
				simCMD_autopilot_app:once()
			end
			if simDR_nav_status > 0 then			-- if VOR LOC or LNAV
				simCMD_autopilot_lnav:once()			-- VOR LOC, LNAV off
				simDR_autopilot_source = 0
				simDR_autopilot_fo_source = 0
			end
			--vnav_stop()
			if simDR_autopilot_heading_mode ~= 1 then
				simCMD_autopilot_hdg:once()
			end
			autopilot_fms_nav_status = 0
			-- simDR_crs1 = B738DR_course_pilot
			-- simDR_crs2 = B738DR_course_copilot
		
		-- VOR/LOC mode
		elseif ap_roll_mode == 2 then
			
			if simDR_nav_status == 0 then
				simCMD_autopilot_lnav:once()			-- VOR LOC on
			end
			
			if ap_roll_mode_eng == 4 then
				ap_roll_mode = 5
			else
				ap_roll_mode_eng = 2
				if at_mode ~= 2 then
					if B738DR_autopilot_autothr_arm_pos == 1 then
						at_mode = 2		-- SPEED on
						--at_mode_eng = 20
					end
				end
			end
			
		
		-- APP mode
		elseif ap_roll_mode == 3 then
			
			if B738DR_fms_ils_disable == 0 then
				if simDR_approach_status == 0 then
					simCMD_autopilot_app:once()
				end
				if ap_roll_mode_eng == 4 then
					ap_roll_mode = 6
				else
					ap_roll_mode_eng = 3
					if at_mode ~= 2 then
						if B738DR_autopilot_autothr_arm_pos == 1 then
							at_mode = 2		-- SPEED on
							--at_mode_eng = 20
						end
					end
				end
			else
				ap_roll_mode = 8	-- LOC/VNAV -> G/P
			end
			
		-- LNAV mode
		elseif ap_roll_mode == 4 then
			ap_roll_mode_eng = 4
			if simDR_approach_status > 0 then
				simCMD_autopilot_app:once()
			end
			--if autopilot_fms_nav_status == 0 then
				if simDR_nav_status > 0 then			-- if VOR LOC Arm or Captured
					simCMD_autopilot_lnav:once()			-- VOR LOC off
				end
			--end
		end
		-- LNAV / VOR LOC mode
		if ap_roll_mode == 5 then
			ap_roll_mode_eng = 5
			if simDR_nav_status == 0 then
				simCMD_autopilot_lnav:once()			-- VOR LOC on
			else
				if at_mode ~= 2 then
					if B738DR_autopilot_autothr_arm_pos == 1 then
						at_mode = 2		-- SPEED on
						--at_mode_eng = 20
					end
				end
			end
		-- LNAV / APP mode
		elseif ap_roll_mode == 6 then
			ap_roll_mode_eng = 6
			if simDR_approach_status == 0 then
				simCMD_autopilot_app:once()			-- APP on
			else
				if at_mode ~= 2 then
					if B738DR_autopilot_autothr_arm_pos == 1 then
						at_mode = 2		-- SPEED on
						--at_mode_eng = 20
					end
				end
			end
		end
		-- ROLLOUT
		if ap_roll_mode == 9 then
			ap_roll_mode_eng = 9
		end
	
	end

	--if ap_on == 1 then
		
		-- if ap_roll_mode_eng == 5 then		-- if LNAV / VOR LOC engaged
			
			-- if simDR_nav1_hdef_pilot == nil then
				-- nav1_hdots_pilot = 2.5
			-- else
				-- nav1_hdots_pilot = simDR_nav1_hdef_pilot
			-- end
			-- if simDR_nav1_hdef_copilot == nil then
				-- nav1_hdots_copilot = 2.5
			-- else
				-- nav1_hdots_copilot = simDR_nav1_hdef_copilot
			-- end
			-- if simDR_nav2_hdef_pilot == nil then
				-- nav2_hdots_pilot = 2.5
			-- else
				-- nav2_hdots_pilot = simDR_nav2_hdef_pilot
			-- end
			-- if simDR_nav2_hdef_copilot == nil then
				-- nav2_hdots_copilot = 2.5
			-- else
				-- nav2_hdots_copilot = simDR_nav2_hdef_copilot
			-- end
			
			-- if B738DR_autopilot_vhf_source_pos == -1 then
				-- if autopilot_cmd_a_status == 1 then
					-- nav_hdots = nav1_hdots_pilot
				-- else
					-- nav_hdots = nav1_hdots_copilot
				-- end
				-- if simDR_nav1_hdispl == nil then
					-- nav_hdispl = 0
				-- else
					-- nav_hdispl = simDR_nav1_hdispl
				-- end
			-- elseif B738DR_autopilot_vhf_source_pos == 0 then
				-- if autopilot_cmd_a_status == 1 then
					-- nav_hdots = nav1_hdots_pilot
					-- if simDR_nav1_hdispl == nil then
						-- nav_hdispl = 0
					-- else
						-- nav_hdispl = simDR_nav1_hdispl
					-- end
				-- else
					-- nav_hdots = nav2_hdots_copilot
					-- if simDR_nav2_hdispl == nil then
						-- nav_hdispl = 0
					-- else
						-- nav_hdispl = simDR_nav2_hdispl
					-- end
				-- end
			-- elseif B738DR_autopilot_vhf_source_pos == 1 then
				-- if autopilot_cmd_a_status == 1 then
					-- nav_hdots = nav2_hdots_pilot
				-- else
					-- nav_hdots = nav2_hdots_copilot
				-- end
				-- if simDR_nav2_hdispl == nil then
					-- nav_hdispl = 0
				-- else
					-- nav_hdispl = simDR_nav2_hdispl
				-- end
			-- end
			
			-- if nav_hdots > -2.49 and nav_hdots < 2.49 and nav_hdispl == 1 then	--1.9
			-- --if nav_hdots > -2.4 and nav_hdots < 2.4 and nav_hdispl == 1 then
				-- --if simDR_nav_status > 0 then			-- if LNAV Arm or Captured
					-- --simCMD_autopilot_lnav:once()			-- LNAV off
				-- --end
				-- autopilot_fms_nav_status = 0
				-- simDR_autopilot_source = 0
				-- simDR_autopilot_fo_source = 0
				-- -- simDR_crs1 = B738DR_course_pilot
				-- -- simDR_crs2 = B738DR_course_copilot
				-- lnav_vorloc = 1
				-- dme_dist = 0
				-- dme_dist_old = 100
				-- --simCMD_autopilot_lnav:once()
				-- autopilot_fms_nav_status = 0
				-- ap_roll_mode = 2
				-- ap_roll_mode_eng = 2
				-- if at_mode ~= 2 then
					-- if B738DR_autopilot_autothr_arm_pos == 1 then
						-- at_mode = 2		-- SPEED on
						-- --at_mode_eng = 20
					-- end
				-- end
			-- end
		-- end
		-- if ap_roll_mode_eng == 6 then		-- if LNAV / APP engaged
			
			-- if simDR_nav1_hdef_pilot == nil then
				-- nav1_hdots_pilot = 2.5
			-- else
				-- nav1_hdots_pilot = simDR_nav1_hdef_pilot
			-- end
			-- if simDR_nav1_hdef_copilot == nil then
				-- nav1_hdots_copilot = 2.5
			-- else
				-- nav1_hdots_copilot = simDR_nav1_hdef_copilot
			-- end
			-- if simDR_nav2_hdef_pilot == nil then
				-- nav2_hdots_pilot = 2.5
			-- else
				-- nav2_hdots_pilot = simDR_nav2_hdef_pilot
			-- end
			-- if simDR_nav2_hdef_copilot == nil then
				-- nav2_hdots_copilot = 2.5
			-- else
				-- nav2_hdots_copilot = simDR_nav2_hdef_copilot
			-- end
			
			-- if B738DR_autopilot_vhf_source_pos == -1 then
				-- if autopilot_cmd_a_status == 1 then
					-- nav_hdots = nav1_hdots_pilot
				-- else
					-- nav_hdots = nav1_hdots_copilot
				-- end
				-- if simDR_nav1_hdispl == nil then
					-- nav_hdispl = 0
				-- else
					-- nav_hdispl = simDR_nav1_hdispl
				-- end
			-- elseif B738DR_autopilot_vhf_source_pos == 0 then
				-- if autopilot_cmd_a_status == 1 then
					-- nav_hdots = nav1_hdots_pilot
					-- if simDR_nav1_hdispl == nil then
						-- nav_hdispl = 0
					-- else
						-- nav_hdispl = simDR_nav1_hdispl
					-- end
				-- else
					-- nav_hdots = nav2_hdots_copilot
					-- if simDR_nav2_hdispl == nil then
						-- nav_hdispl = 0
					-- else
						-- nav_hdispl = simDR_nav2_hdispl
					-- end
				-- end
			-- elseif B738DR_autopilot_vhf_source_pos == 1 then
				-- if autopilot_cmd_a_status == 1 then
					-- nav_hdots = nav2_hdots_pilot
				-- else
					-- nav_hdots = nav2_hdots_copilot
				-- end
				-- if simDR_nav2_hdispl == nil then
					-- nav_hdispl = 0
				-- else
					-- nav_hdispl = simDR_nav2_hdispl
				-- end
			-- end
			
			-- if nav_hdots > -2.49 and nav_hdots < 2.49 and nav_hdispl == 1 then	--1.9
			-- --if nav_hdots > -2.4 and nav_hdots < 2.4 and nav_hdispl == 1 then
				-- --if simDR_nav_status > 0 then			-- if LNAV Arm or Captured
					-- --simCMD_autopilot_lnav:once()			-- LNAV off
				-- --end
				-- autopilot_fms_nav_status = 0
				-- simDR_autopilot_source = 0
				-- simDR_autopilot_fo_source = 0
				-- -- simDR_crs1 = B738DR_course_pilot
				-- -- simDR_crs2 = B738DR_course_copilot
				-- lnav_app = 1
				-- dme_dist = 0
				-- dme_dist_old = 100
				-- simCMD_autopilot_app:once()
				-- ap_roll_mode = 3
				-- ap_roll_mode_eng = 3
				-- if at_mode ~= 2 then
					-- if B738DR_autopilot_autothr_arm_pos == 1 then
						-- at_mode = 2		-- SPEED on
						-- --at_mode_eng = 20
					-- end
				-- end
			-- end	
		-- end
		
		-- if ap_roll_mode_eng == 2 then		-- if VOR LOC engaged
			-- if B738DR_autopilot_vnav_status == 1 then
				-- if lnav_vorloc == 1 then
					-- if simDR_glideslope_status == 1 then
						-- -- track to gps
						-- dme_dist = simDR_dme_dist
						-- if dme_dist > dme_dist_old then
							-- -- next waypoint
							-- simCMD_FMS_key_delete:once()
							-- simCMD_FMS_key_clear:once()
							-- simCMD_FMS_key_clear:once()
-- --							simCMD_FMS_key_fpln:once()
							-- simCMD_FMS_key_legs:once()
							-- simCMD_FMS_key_2L:once()
							-- simCMD_FMS_key_dir_intc:once()
							-- simCMD_FMS_key_1L:once()
							-- simCMD_FMS_key_exec:once()
							-- simCMD_FMS_key_legs:once()
						-- end
						-- dme_dist_old = dme_dist
					-- else
						-- lnav_vorloc = 0
					-- end
				-- end
			-- end
		-- end
		
		-- if ap_roll_mode_eng == 3 then		-- if APP engaged
			-- if B738DR_autopilot_vnav_status == 1 then
				-- if lnav_app == 1 then
					-- -- if simDR_glideslope_status == 1 then
						-- -- -- track to gps
						-- -- dme_dist = simDR_dme_dist
						-- -- if dme_dist > dme_dist_old then
							-- -- -- next waypoint
							-- -- simCMD_FMS_key_delete:once()
							-- -- simCMD_FMS_key_clear:once()
							-- -- simCMD_FMS_key_clear:once()
-- -- --							simCMD_FMS_key_fpln:once()
							-- -- simCMD_FMS_key_legs:once()
							-- -- simCMD_FMS_key_2L:once()
							-- -- simCMD_FMS_key_dir_intc:once()
							-- -- simCMD_FMS_key_1L:once()
							-- -- simCMD_FMS_key_exec:once()
							-- -- simCMD_FMS_key_legs:once()
						-- -- end
						-- -- dme_dist_old = dme_dist
					-- else
						-- lnav_app = 0
					-- end
				-- end
				-- vdot = simDR_vdot_nav1_pilot
				-- if vdot == nil then
					-- -- waiting for glideslope
				-- else
					-- if vdot > -1.5 and vdot < 1.5 
					-- and simDR_glideslope_status == 1 then --and ap_pitch_mode_eng ~= 4 then
						-- -- if simDR_vnav_status == 1 then
							-- -- simCMD_autopilot_vnav:once()		-- default VNAV off
						-- -- end
						-- --vnav_active = 6
						-- --ap_pitch_mode = 4
						-- vnav_stop()
						-- if simDR_autopilot_altitude_mode == 4 then
							-- ap_pitch_mode = 1
							-- --ap_pitch_mode_eng = 1
						-- end
					-- end
				-- end
				-- if simDR_glideslope_status == 2 then
					-- ap_pitch_mode = 4
				-- end
			-- else
				-- if simDR_glideslope_status == 2 then --and ap_pitch_mode_eng ~= 4 then	-- if G/S engaged
					-- ap_pitch_mode = 4
					-- ap_pitch_mode_eng = 4
				-- end
			-- end
		-- end
		
		-- IAN -> LOC/VNAV (G/P)
		--if ap_roll_mode_eng == 7 or ap_roll_mode_eng == 8 then	-- if RNAV engaged
		if ap_roll_mode == 8 and ap_roll_mode_eng == 8 then	-- if RNAV engaged
			-- if B738DR_gp_status == 0 and B738DR_gp_active == 1 then
				-- B738DR_gp_status = 1
			-- end
			-- if B738DR_rnav_enable > 0 and B738DR_vnav_alt_err < 200 and  B738DR_vnav_alt_err > -300 
			-- and B738DR_gp_active == 2 and simDR_nav_status == 2 then
			
			--if B738DR_rnav_enable > 0 and B738DR_gp_err_pfd < 200 and B738DR_gp_err_pfd > -300 
			if B738DR_gp_err_pfd < 200 and B738DR_gp_err_pfd > -300 
			and B738DR_gp_active > 0 and simDR_nav_status == 2 then
			
			--if B738DR_rnav_enable > 0 and B738DR_vnav_alt_err > -200 and B738DR_gp_active == 1 and simDR_nav_status == 2 then
				ap_pitch_mode = 7	-- RNAV G/P or LOC G/P
				B738DR_gp_status = 2
			end
			-- if B738DR_gp_active == 0 then
				-- B738DR_gp_status = 0
			-- end
		else
			B738DR_gp_status = 0
		end
	--end
	
	if ap_roll_mode_eng == 3 then	-- APP
		if simDR_glideslope_status == 2 then --and ap_pitch_mode_eng ~= 4 then	-- if G/S engaged
			ap_pitch_mode = 4
			--ap_pitch_mode_eng = 4
		end
	end
	
	if ap_pitch_mode ~= ap_pitch_mode_eng then
		
		-- PITCH MODES: 0-off, 1-V/S, 2-LVL CHG, 3-ALT HLD, 4-G/S, 5-VNAV, 6-ALT ACQ, 7-RNAV G/P
		if ap_pitch_mode == 0 and ap_pitch_mode_eng ~= 0 then
			ap_pitch_mode_eng = 0
			-- if ap_on == 1 then
				-- ----simDR_throttle_override = 0
			-- end
			if simDR_autopilot_altitude_mode == 6 then
				simCMD_autopilot_alt_hold:once()	-- ALT HLD , ALT ACQ off
			elseif simDR_autopilot_altitude_mode == 5 then
				simCMD_autopilot_lvl_chg:once()		-- LVL CHG off
			elseif simDR_autopilot_altitude_mode == 4 then
				simCMD_autopilot_vs:once()			-- V/S off
			end
			vnav_stop()
			--B738DR_gp_status = 0
		
		elseif ap_pitch_mode == 1 and ap_pitch_mode_eng ~= 1 then		-- V/S
			ap_pitch_mode_eng = 1
			fd_goaround = 0
			vnav_stop()
			if B738DR_gp_status == 2 and ap_roll_mode == 8 then
				ap_roll_mode = 0
			end
			if simDR_autopilot_altitude_mode ~= 4 then
				if simDR_ap_vvi_dial ~= 0 then
					--alt_x = simDR_ap_vvi_dial
					simCMD_autopilot_vs_sel:once()
					simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100 )
					--simDR_ap_vvi_dial = alt_x
				else
					simCMD_autopilot_vs:once()
					simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100 )
				end
				--if ap_on == 1 then
			else
				simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100 )
			end
			if B738DR_autopilot_autothr_arm_pos == 1 then
				----simDR_throttle_override = 0
				at_mode = 2		-- SPEED on
				--at_mode_eng = 20
			end
		
		elseif ap_pitch_mode == 2 and ap_pitch_mode_eng~= 2 then	-- LVL CHG
			ap_pitch_mode_eng = 2
			vnav_stop()
			if B738DR_gp_status == 2 and ap_roll_mode == 8 then
				ap_roll_mode = 0
			end
			vnav_vs = 0
			init_climb = 0
--			if simDR_autopilot_altitude_mode ~= 5 then
				airspeed_dial = simDR_airspeed_dial
--				thrust = --simDR_throttle_all
				if simDR_ap_altitude_dial_ft < simDR_altitude_pilot then
					delta_alt = simDR_altitude_pilot - simDR_ap_altitude_dial_ft
					if delta_alt > 200 then
						delta_alt = at_mode
						B738DR_lvl_chg_mode = 0		-- descent
						if simDR_autopilot_altitude_mode ~= 5 then
							simCMD_autopilot_lvl_chg:once()
							--simDR_airspeed_dial = airspeed_dial
						end
						
						if B738DR_fd_on == 0 then
						
							if B738DR_autopilot_autothr_arm_pos == 1 then
								at_mode = delta_alt
								at_mode_eng = 20
							end
	--								----simDR_throttle_override = 0
							-- if ----simDR_throttle_override == 0 then
								-- --simDR_throttle_all = thrust
							-- else
								-- eng1_N1_thrust_trg = thrust
								-- eng2_N1_thrust_trg = thrust
							-- end
	--								eng1_N1_thrust_trg = 0.0
	--								eng2_N1_thrust_trg = 0.0
							
						else
							if B738DR_autopilot_autothr_arm_pos == 0 then
								at_mode = delta_alt
								at_mode_eng = 20
							else
								at_mode = 6
							end
						end
						
					else
						ap_pitch_mode = 3
					end
				end
				if simDR_ap_altitude_dial_ft > simDR_altitude_pilot then
					delta_alt = simDR_ap_altitude_dial_ft - simDR_altitude_pilot
					if delta_alt > 200 then
						delta_alt = at_mode
						B738DR_lvl_chg_mode = 1		-- climb
						if simDR_autopilot_altitude_mode ~= 5 then
							simCMD_autopilot_lvl_chg:once()
							--simDR_airspeed_dial = airspeed_dial
						end
						
						if B738DR_fd_on == 0 then
							if B738DR_autopilot_autothr_arm_pos == 1 then
								at_mode = delta_alt
								at_mode_eng = 20
							end
--							----simDR_throttle_override = 0
							-- if ----simDR_throttle_override == 0 then
								-- --simDR_throttle_all = thrust
							-- else
								-- eng1_N1_thrust_trg = thrust
								-- eng2_N1_thrust_trg = thrust
							-- end
	--								eng1_N1_thrust_trg = 0.0
	--								eng2_N1_thrust_trg = 0.0
						else
							if B738DR_autopilot_autothr_arm_pos == 0 then
								at_mode = delta_alt
								at_mode_eng = 20
							else
								at_mode = 6
							end
						end
						
					else
						ap_pitch_mode = 3
					end
				end
			--end
		
		elseif ap_pitch_mode == 3 and ap_pitch_mode_eng ~= 3 then	-- ALT HLD
			ap_pitch_mode_eng = 3
			fd_goaround = 0
			vnav_stop()
			if B738DR_gp_status == 2 and ap_roll_mode == 8 then
				ap_roll_mode = 0
			end
			if simDR_autopilot_altitude_mode ~= 6 then
				simCMD_autopilot_alt_hold:once()
				--simDR_ap_altitude_dial_ft = roundUpToIncrement(simDR_altitude_pilot, 100 )
				--B738DR_mcp_alt_dial = simDR_ap_altitude_dial_ft
			end
			simDR_ap_altitude_dial_ft = roundUpToIncrement(simDR_altitude_pilot, 100 )
			B738DR_mcp_alt_dial = simDR_ap_altitude_dial_ft
			altitude_dial_ft_old = simDR_ap_altitude_dial_ft
			simDR_ap_vvi_dial = 0
			if B738DR_autopilot_autothr_arm_pos == 1 then
				at_mode = 2		-- SPEED on
			end
		
		elseif ap_pitch_mode == 4 and ap_pitch_mode_eng ~= 4 then	-- G/S (APP)
			ap_pitch_mode_eng = 4
			fd_goaround = 0
			vnav_stop()
			B738DR_retard_status = 0				-- PFD: no RETARD
			B738DR_autopilot_n1_pfd = 0				-- PFD: no N1
			if B738DR_autopilot_autothr_arm_pos == 1 then
				at_mode = 2		-- SPEED on
				--at_mode_eng = 20
			end
		
		elseif ap_pitch_mode == 5 and ap_pitch_mode_eng ~= 5 then	-- VNAV
			ap_pitch_mode_eng = 5
			if B738DR_gp_status == 2 and ap_roll_mode == 8 then
				ap_roll_mode = 0
			end
			fd_goaround = 0
			vnav_descent = 0
			vnav_cruise = 0
			init_climb = 0
			vnav_descent_disable = 0
			vnav_init = 0
			vnav_init2 = 1
			vnav_alt_hold = 0
			vnav_alt_hold_act = 0
			vnav_engaged = 0
			rest_wpt_alt_idx_old = 0
				
		elseif ap_pitch_mode == 6 and ap_pitch_mode_eng ~= 6 then	-- ALT ACQ
			ap_pitch_mode_eng = 6
			fd_goaround = 0
			vnav_stop()
			if B738DR_gp_status == 2 and ap_roll_mode == 8 then
				ap_roll_mode = 0
			end
			if B738DR_fd_on == 1 then
				if simDR_autopilot_altitude_mode ~= 6 then
					altitude_dial = simDR_altitude_pilot 
					simCMD_autopilot_alt_hold:once()
					simDR_ap_altitude_dial_ft = altitude_dial
				end
				----simDR_throttle_override = 0
				B738DR_retard_status = 0				-- PFD: no RETARD
				B738DR_autopilot_n1_pfd = 0				-- PFD: no N1
			-- else
				-- if simDR_autopilot_altitude_mode ~= 6 then
					-- simCMD_autopilot_alt_hold:once()
				-- end
			else
				ap_pitch_mode = 0
			end
			if B738DR_autopilot_autothr_arm_pos == 1 then
				at_mode = 2		-- SPEED on
				--at_mode_eng = 20
			end
		elseif ap_pitch_mode == 7 and ap_pitch_mode_eng ~= 7 then		-- G/P
			ap_pitch_mode_eng = 7
			fd_goaround = 0
			vnav_stop()
			--B738DR_gp_status = 2	-- G/P armed
			--if ap_on == 1 then
			if B738DR_autopilot_autothr_arm_pos == 1 then
				----simDR_throttle_override = 0
				at_mode = 2		-- SPEED on
				--at_mode_eng = 20
			end
			-- if simDR_autopilot_altitude_mode ~= 4 then
				-- simCMD_autopilot_vs_sel:once()
				-- if ap_on == 1 then
					-- at_mode = 2		-- SPEED on
				-- end
			-- end
		end
		
		
	
	end
	


	-- AUTOPILOT BUTTONS LIGHTS
	if ap_roll_mode == 0 then
		B738DR_autopilot_hdg_sel_status = 0
		B738DR_autopilot_vorloc_status = 0
		B738DR_autopilot_app_status = 0
		B738DR_autopilot_lnav_status = 0
		autopilot_fms_nav_status = 0
	elseif ap_roll_mode == 1 then	-- HDG
		B738DR_autopilot_hdg_sel_status = 1
		B738DR_autopilot_vorloc_status = 0
		B738DR_autopilot_app_status = 0
		B738DR_autopilot_lnav_status = 0
		autopilot_fms_nav_status = 0
	elseif ap_roll_mode == 2 then	-- VOR/LOC
		if simDR_nav_status == 2 then
			B738DR_autopilot_hdg_sel_status = 0
		end
		B738DR_autopilot_vorloc_status = 1
		B738DR_autopilot_app_status = 0
		B738DR_autopilot_lnav_status = 0
		autopilot_fms_nav_status = 0
	elseif ap_roll_mode == 3 then	-- APP
		if B738DR_autoland_status == 1 then
			if simDR_glideslope_status == 2 
			or vorloc_only == 1 then
				B738DR_autopilot_app_status = 0		-- turn off APP light status
			end
		elseif at_mode_eng == 4 then
			B738DR_autopilot_app_status = 0		-- turn off APP light status
		else
			B738DR_autopilot_app_status = 1
		end
		if simDR_approach_status == 2 then
			B738DR_autopilot_hdg_sel_status = 0
		end
		B738DR_autopilot_vorloc_status = 0
		B738DR_autopilot_lnav_status = 0
		autopilot_fms_nav_status = 0
	elseif ap_roll_mode == 4 then	-- LNAV
		B738DR_autopilot_hdg_sel_status = 0
		B738DR_autopilot_vorloc_status = 0
		B738DR_autopilot_app_status = 0
		B738DR_autopilot_lnav_status = 1
		--autopilot_fms_nav_status = 1
	elseif ap_roll_mode == 5 then	-- LNAV / VOR LOC
		B738DR_autopilot_hdg_sel_status = 0
		B738DR_autopilot_vorloc_status = 1
		B738DR_autopilot_app_status = 0
		B738DR_autopilot_lnav_status = 1
		--autopilot_fms_nav_status = 1
	elseif ap_roll_mode == 6 then	-- LNAV / APP
		B738DR_autopilot_hdg_sel_status = 0
		B738DR_autopilot_vorloc_status = 0
		B738DR_autopilot_app_status = 1
		B738DR_autopilot_lnav_status = 1
		--autopilot_fms_nav_status = 1
	elseif ap_roll_mode == 7 then	-- RNAV
		B738DR_autopilot_hdg_sel_status = 0
		B738DR_autopilot_vorloc_status = 0
		B738DR_autopilot_app_status = 1
		B738DR_autopilot_lnav_status = 0
		--autopilot_fms_nav_status = 1
	elseif ap_roll_mode == 8 then	-- IAN APP
		B738DR_autopilot_hdg_sel_status = 0
		B738DR_autopilot_vorloc_status = 0
		B738DR_autopilot_app_status = 1
		B738DR_autopilot_lnav_status = 0
		--autopilot_fms_nav_status = 0
	end

	if ap_pitch_mode == 0 then
		B738DR_autopilot_vs_status = 0
		B738DR_autopilot_lvl_chg_status = 0
		B738DR_autopilot_alt_hld_status = 0
		B738DR_autopilot_vnav_status = 0
		ap_vnav_status = 0
--		vnav_active = 0
		elseif ap_pitch_mode == 1 then		-- V/S
		B738DR_autopilot_vs_status = 1
		B738DR_autopilot_lvl_chg_status = 0
		B738DR_autopilot_alt_hld_status = 0
		B738DR_autopilot_vnav_status = 0
		ap_vnav_status = 0
--		vnav_active = 0
	elseif ap_pitch_mode == 2 then	-- LVL CHG
		B738DR_autopilot_vs_status = 0
		B738DR_autopilot_lvl_chg_status = 1
		B738DR_autopilot_alt_hld_status = 0
		B738DR_autopilot_vnav_status = 0
		ap_vnav_status = 0
--		vnav_active = 0
	elseif ap_pitch_mode == 3 then	-- ALT HLD
		-- if ap_on == 1 then
			-- if simDR_vvi_fpm_pilot > -250 and simDR_vvi_fpm_pilot < 250 then
				-- B738DR_autopilot_alt_hld_status = 0
			-- else
				-- B738DR_autopilot_alt_hld_status = 1
			-- end
		-- else
			-- B738DR_autopilot_alt_hld_status = 1
		-- end
		B738DR_autopilot_alt_hld_status = 1
		B738DR_autopilot_vs_status = 0
		B738DR_autopilot_lvl_chg_status = 0
		B738DR_autopilot_vnav_status = 0
		ap_vnav_status = 0
--		vnav_active = 0
	elseif ap_pitch_mode == 4 then	-- G/S
		B738DR_autopilot_vs_status = 0
		B738DR_autopilot_lvl_chg_status = 0
		if simDR_glideslope_status == 2 then
			B738DR_autopilot_alt_hld_status = 0
		end
		B738DR_autopilot_vnav_status = 0
		ap_vnav_status = 0
--		vnav_active = 0
	elseif ap_pitch_mode == 5 then	-- VNAV
--		if B738DR_autopilot_vorloc_status == 1
--		or B738DR_autopilot_app_status > 0
--		or B738DR_autopilot_alt_hld_status == 1
--		or B738DR_autopilot_vs_status == 1 then
--			B738DR_autopilot_vnav_status = 0		-- turn off VNAV light status
--		else
			B738DR_autopilot_vnav_status = 1
--		end
		
--		B738DR_autopilot_vnav_status = 1
		
		if B738DR_autopilot_vnav_status == 1 then
--			if B738DR_efis_vor1_capt_pos >= 0
--			and B738DR_efis_vor2_capt_pos >= 0 then		-- custom VNAV
--				ap_vnav_status = 1
--			else
				ap_vnav_status = 2
--			end
		else
			ap_vnav_status = 0
		end
		B738DR_autopilot_vs_status = 0
		B738DR_autopilot_lvl_chg_status = 0
		B738DR_autopilot_alt_hld_status = 0
	elseif ap_pitch_mode == 6 then		-- ALT ACQ
		B738DR_autopilot_vs_status = 0
		B738DR_autopilot_lvl_chg_status = 0
		B738DR_autopilot_alt_hld_status = 0
		B738DR_autopilot_vnav_status = 0
		ap_vnav_status = 0
	elseif ap_pitch_mode == 7 then	-- RNAV G/P or LOC G/P
		B738DR_autopilot_vs_status = 0
		B738DR_autopilot_lvl_chg_status = 0
		B738DR_autopilot_alt_hld_status = 0
		B738DR_autopilot_vnav_status = 0
		ap_vnav_status = 0
	end
	-- fixed Laminar issue LNAV - only from captain FMS
	if B738DR_autopilot_lnav_status == 1 then
		simDR_autopilot_side = 0
	else
		if autopilot_cmd_a_status == 1 then
			simDR_autopilot_side = 0
		elseif autopilot_cmd_b_status == 1 then
			simDR_autopilot_side = 1
		else
			simDR_autopilot_side = 0
		end
	end
	
	B738DR_altitude_mode = ap_pitch_mode
	B738DR_altitude_mode2 = ap_pitch_mode_eng
	B738DR_heading_mode = ap_roll_mode
	
	
	
end


function B738_ap_at_disconnect()

	if autopilot_cws_a_status == 1 or autopilot_cws_b_status == 1 then
		cws_on = 1
	else
		cws_on = 0
	end

	local ap_dis_enable = 0
	if ap_on ~= ap_on_first or cws_on ~= cws_on_first then
		if ap_on == 0 and cws_on == 0 then
			-- AP disconect
			ap_dis_enable = 1
		end
	end
	ap_on_first = ap_on
	cws_on_first = cws_on
	
	if B738DR_autopilot_disconnect_pos ~= ap_disco_first then
		if B738DR_autopilot_disconnect_pos == 1 and ap_disco_do == 1 then
			-- AP disconect
			ap_dis_enable = 1
		end
		if B738DR_autopilot_disconnect_pos == 0 then
			ap_disco_do = 0
			ap_dis_enable = 0
			ap_dis_time = 0
		end
	end
	ap_disco_first = B738DR_autopilot_disconnect_pos
	
	local at_dis_enable = 0
	if B738DR_autopilot_autothr_arm_pos ~= at_on_first then
		if B738DR_autopilot_autothr_arm_pos == 0 then
			-- AT disconect
			at_dis_enable = 1
		end
	end
	at_on_first = B738DR_autopilot_autothr_arm_pos
	
	if B738DR_autopilot_disco2 == 1 and ap_disco2 == 0 then
		ap_dis_enable = 0
		ap_dis_time = 0
	end
	if B738DR_ap_light_pilot == 1 or B738DR_ap_light_fo == 1 then
		ap_dis_enable = 0
		ap_dis_time = 0
	end
	if B738DR_at_light_pilot == 1 or B738DR_at_light_fo == 1 then
		at_dis_enable = 0
		at_dis_time = 0
	end
	
	if ap_dis_enable == 1 then
		ap_dis_time = 40	-- 40 * 0.5sec = 20 seconds
	end
	if at_dis_enable == 1 then
		at_dis_time = 40	-- 40 * 0.5sec = 20 seconds
	end

end

function B738_at_logic()
	
	local airspeed_dial = 0
	local ap_thrust = 0.0
	
	-- AT MODES: 0-off, 1-N1, 2-MCP SPD, 3-Takeoff, 4-A/P GA, 5-F/D GA, 6-LVL CHG speed, 7-VNAV speed, 8-A/P GA after touchdown, 9 - MCP SPD with N1 limit
	
	-- if ap_on == 0 then
		-- if at_mode == 6 then	-- LVL CHG
			-- if B738DR_autopilot_n1_status == 0 then
				-- at_mode = 0
			-- else
				-- if B738DR_autopilot_autothr_arm_pos == 1 then
					-- at_mode = 1
				-- end
			-- end
		-- elseif at_mode == 7 then	-- VNAV SPD
			-- if B738DR_autopilot_n1_status == 0 then
				-- at_mode = 0
			-- else
				-- if B738DR_autopilot_autothr_arm_pos == 1 then
					-- at_mode = 1
				-- end
			-- end
		-- elseif at_mode == 9 then	-- MCP SPD with N1 limit
			-- --at_mode = 1
			-- if B738DR_autopilot_autothr_arm_pos == 1 then
				-- at_mode = 2
			-- end
		-- end
	-- end
	
	
	if B738DR_autopilot_autothr_arm_pos == 0 then
		at_mode = 0
		B738DR_autopilot_n1_status = 0
	end
	
	
	if at_mode == 0 and at_mode_eng ~= 0 then
		at_mode_eng = 0
--		if B738DR_autopilot_n1_status == 1 then
			--simDR_throttle_all = eng1_N1_thrust	-- N1 THRUST
--		end
		B738DR_autopilot_n1_status = 0
		----simDR_throttle_override = 0
		simDR_autothrottle_enable = 0	-- speed off
		B738DR_autopilot_to_ga_pfd = 0
		B738DR_autopilot_thr_hld_pfd = 0
		B738DR_autopilot_ga_pfd = 0
		--B738DR_autopilot_alt_acq_pfd = 0
		at_throttle_hold = 0	-- mode throttle HLD off
		ap_goaround = 0
		fd_goaround = 0
		to_after_80kts = 0
		simDR_fdir_pitch_ovr = 0
	
	-- N1 mode
	elseif at_mode == 1 and at_mode_eng ~= 1 then
		at_mode_eng = 1
		at_throttle_hold = 0	-- mode throttle HLD off
		to_after_80kts = 0
		B738DR_retard_status = 0				-- PFD: no RETARD
		if ap_pitch_mode == 2 
		and simDR_autopilot_altitude_mode == 5 
		and B738DR_fd_on == 1 then
			simCMD_autopilot_lvl_chg:once()		-- LVL CHG off
			ap_pitch_mode = 0
			ap_pitch_mode_eng = 0
		end
			
		ap_goaround = 0
		simDR_fdir_pitch_ovr = 0
		if fd_goaround < 3 then
			fd_goaround = 0
		end
		--B738DR_autopilot_thr_hld_pfd = 0
		--B738DR_autopilot_to_ga_pfd = 0
		--B738DR_autopilot_ga_pfd = 0
		--B738DR_autopilot_alt_acq_pfd = 0
		if B738DR_autopilot_speed_status == 1 then
			simDR_autothrottle_enable = 0	-- speed off
		end
		B738DR_autopilot_n1_status = 1
		----simDR_throttle_override = 1
		eng1_N1_thrust_trg = eng1_N1_thrust	-- N1 THRUST
		eng2_N1_thrust_trg = eng2_N1_thrust	-- N1 THRUST
--		--simDR_throttle_all = eng1_N1_thrust	-- N1 THRUST
		B738DR_retard_status = 0
	
	-- -- SPEED mode
	-- elseif at_mode == 2 and at_mode_eng ~= 2 then
		-- at_throttle_hold = 0	-- mode throttle HLD off
		-- ap_goaround = 0
		-- to_after_80kts = 0
		-- B738DR_retard_status = 0				-- PFD: no RETARD
		-- B738DR_autopilot_n1_pfd = 0				-- PFD: no N1
		-- if ap_pitch_mode == 2 
		-- and simDR_autopilot_altitude_mode == 5 then
			-- simCMD_autopilot_lvl_chg:once()		-- LVL CHG off
			-- ap_pitch_mode = 0
			-- ap_pitch_mode_eng = 0
		-- end
		-- simDR_fdir_pitch_ovr = 0
		-- if fd_goaround < 3 then
			-- fd_goaround = 0
		-- end
		-- B738DR_autopilot_thr_hld_pfd = 0
		-- B738DR_autopilot_to_ga_pfd = 0
		-- B738DR_autopilot_ga_pfd = 0
		-- if B738DR_autopilot_autothr_arm_pos == 1 then		-- A/T on
			-- at_mode_eng = 2
			-- airspeed_dial = simDR_airspeed_dial
			-- B738DR_retard_status = 0
			-- B738DR_autopilot_n1_pfd = 0
			-- B738DR_autopilot_n1_status = 0
			-- simDR_autothrottle_enable = 1	-- speed on
			-- simDR_airspeed_dial = airspeed_dial
		-- else
			-- at_mode = 0
		-- end
	
	-- SPD speed with N1 limit
	elseif at_mode == 2 and at_mode_eng ~= 2 then
		at_mode_eng = 2
		at_throttle_hold = 0	-- mode throttle HLD off
		ap_goaround = 0
		to_after_80kts = 0
		B738DR_retard_status = 0				-- PFD: no RETARD
		B738DR_autopilot_n1_pfd = 0				-- PFD: no N1
		B738DR_autopilot_n1_status = 0
		simDR_fdir_pitch_ovr = 0
		if ap_pitch_mode == 2 
		and simDR_autopilot_altitude_mode == 5 then
			simCMD_autopilot_lvl_chg:once()		-- LVL CHG off
			ap_pitch_mode = 0
			ap_pitch_mode_eng = 0
		end
		if fd_goaround < 3 then
			fd_goaround = 0
		end
		--B738DR_autopilot_thr_hld_pfd = 0
		--B738DR_autopilot_to_ga_pfd = 0
		--B738DR_autopilot_ga_pfd = 0
		simDR_autothrottle_enable = 1	-- speed on
	
	-- TAKEOFF mode
	elseif at_mode == 3 and at_mode_eng ~= 3 then
		at_mode_eng = 3
		at_throttle_hold = 0	-- mode throttle HLD off
		ap_goaround = 0
		fd_goaround = 0
		--ap_pitch_mode = 0
		--ap_pitch_mode_eng = 0
		ap_pitch_mode_old = ap_pitch_mode_eng
		-- if B738DR_autopilot_n1_status == 1 then
			--simDR_throttle_all = eng1_N1_thrust	-- N1 THRUST
		-- end
		B738DR_autopilot_n1_status = 0
		----simDR_throttle_override = 0
		simDR_autothrottle_enable = 0	-- speed off
		--B738DR_autopilot_to_ga_pfd = 0
		--B738DR_autopilot_thr_hld_pfd = 0
		--B738DR_autopilot_ga_pfd = 0
		--B738DR_autopilot_alt_acq_pfd = 0
		if ap_roll_mode == 0 then
			ap_roll_mode = 1	-- ROLL> HDG mode
		end
		to_thrust_set = 0
		fd_cur = simDR_fdir_pitch
		simDR_fdir_pitch_ovr = 1
	
	-- AP GoAround mode
	elseif at_mode == 4 and at_mode_eng ~= 4 then
		at_mode_eng = 4
		at_throttle_hold = 0	-- mode throttle HLD off
		fd_goaround = 0
		to_after_80kts = 0
		simDR_fdir_pitch_ovr = 0
		B738DR_autoland_status = 0
		B738DR_flare_status = 0
		B738DR_retard_status = 0
		vorloc_only = 0
		--if B738DR_autopilot_n1_status == 1 then
			--simDR_throttle_all = eng1_N1_thrust	-- N1 THRUST
		--end
		B738DR_autopilot_n1_status = 0
		----simDR_throttle_override = 0
		--B738DR_autopilot_thr_hld_pfd = 0
		--B738DR_autopilot_alt_acq_pfd = 0

		--ap_roll_mode = 0
		--ap_roll_mode_eng = 0
		ap_pitch_mode = 0
		--ap_pitch_mode_eng = 0
		--B738DR_autopilot_ga_pfd = 1			-- PFD speed> GA
		--B738DR_autopilot_to_ga_pfd = 1		-- PFD pitch> TO/GA
		B738DR_pfd_spd_mode = PFD_SPD_GA
		B738DR_pfd_alt_mode = PFD_ALT_TO_GA
		simDR_autothrottle_enable = 1
		if simDR_autopilot_altitude_mode ~= 4 then
			simCMD_autopilot_vs:once()			-- VS on
			simDR_ap_vvi_dial = roundDownToIncrement(simDR_ap_vvi_dial, 100 )
		end
		simDR_ap_vvi_dial = 1300
		simDR_ap_capt_heading = simDR_heading_pilot
		if simDR_autopilot_heading_mode == 0 then
			simCMD_autopilot_hdg:once()			-- HDG on
		end
		fd_cur = simDR_fdir_pitch
		simDR_fdir_pitch_ovr = 1
		if ap_roll_mode == 0 then
			ap_roll_mode = 1
		end
		ap_pitch_mode_old = ap_pitch_mode_eng
		ap_roll_mode_old = ap_roll_mode_eng
			-- FD GoAround mode
	elseif at_mode == 5 and at_mode_eng ~= 5 then
		at_mode_eng = 5
		at_throttle_hold = 0	-- mode throttle HLD off
		--ap_roll_mode = 0
		--ap_roll_mode_eng = 0
		ap_pitch_mode = 0
		ap_pitch_mode_eng = 0
		ap_goaround = 0
		to_after_80kts = 0
		airspeed_dial = simDR_airspeed_dial
		B738DR_retard_status = 0
		B738DR_autopilot_n1_pfd = 0
		B738DR_autopilot_n1_status = 0
		-- if ----simDR_throttle_override == 1 then
			-- ap_thrust = simDR_throttle1_use
			-- ----simDR_throttle_override = 0
			-- --simDR_throttle_all = ap_thrust
		-- end
		simDR_autothrottle_enable = 1
		simDR_airspeed_dial = airspeed_dial
		--B738DR_autopilot_to_ga_pfd = 1
		--B738DR_autopilot_thr_hld_pfd = 0
		--B738DR_autopilot_ga_pfd = 1
		--B738DR_autopilot_alt_acq_pfd = 0
		B738DR_pfd_spd_mode = PFD_SPD_GA
		B738DR_pfd_alt_mode = PFD_ALT_TO_GA
		fd_cur = simDR_fdir_pitch
		simDR_fdir_pitch_ovr = 1
		if ap_roll_mode == 0 then
			ap_roll_mode = 1
		end
		ap_pitch_mode_old = ap_pitch_mode_eng
		ap_roll_mode_old = ap_roll_mode_eng

	
	-- LVL CHG mode
	elseif at_mode == 6 and at_mode_eng ~= 6 then
		at_mode_eng = 6
		
		at_throttle_hold = 0	-- mode throttle HLD off
		ap_goaround = 0
		to_after_80kts = 0
		simDR_fdir_pitch_ovr = 0
		if fd_goaround < 3 then
			fd_goaround = 0
		end
		simDR_autothrottle_enable = 0	-- speed off
		--B738DR_autopilot_thr_hld_pfd = 0
		--B738DR_autopilot_to_ga_pfd = 0
		--B738DR_autopilot_ga_pfd = 0
		--B738DR_autopilot_alt_acq_pfd = 0
	
	-- VNAV speed
	elseif at_mode == 7 and at_mode_eng ~= 7 then
		at_mode_eng = 7
		at_throttle_hold = 0	-- mode throttle HLD off
		ap_goaround = 0
		to_after_80kts = 0
		simDR_fdir_pitch_ovr = 0
		if fd_goaround < 3 then
			fd_goaround = 0
		end
		simDR_autothrottle_enable = 0	-- speed off
		--B738DR_autopilot_thr_hld_pfd = 0
		--B738DR_autopilot_to_ga_pfd = 0
		--B738DR_autopilot_ga_pfd = 0
		--B738DR_autopilot_alt_acq_pfd = 0
	
	-- AP GoAround mode after touchdown
	elseif at_mode == 8 and at_mode_eng ~= 8 then
		at_mode_eng = 8
		at_throttle_hold = 0	-- mode throttle HLD off
		fd_goaround = 0
		to_after_80kts = 0
--		ap_roll_mode = 0
		ap_pitch_mode = 0
		ap_pitch_mode_eng = 0
		simDR_fdir_pitch_ovr = 0
		B738DR_autoland_status = 0
		B738DR_flare_status = 0
		B738DR_retard_status = 0
		vorloc_only = 0
		--if B738DR_autopilot_n1_status == 1 then
			--simDR_throttle_all = eng1_N1_thrust	-- N1 THRUST
		--end
		B738DR_autopilot_n1_status = 0
		----simDR_throttle_override = 0
		--B738DR_autopilot_thr_hld_pfd = 0
		--B738DR_autopilot_alt_acq_pfd = 0
		--B738DR_autopilot_ga_pfd = 1			-- PFD speed> GA
		--B738DR_autopilot_to_ga_pfd = 1		-- PFD pitch> TO/GA
		B738DR_pfd_spd_mode = PFD_SPD_GA
		B738DR_pfd_alt_mode = PFD_ALT_TO_GA
		simDR_autothrottle_enable = 0
		fd_cur = simDR_fdir_pitch
		simDR_fdir_pitch_ovr = 1
		ap_goaround = 2
		if ap_roll_mode == 0 then
			ap_roll_mode = 1
		end
	-- SPD speed with N1 limit
	elseif at_mode == 9 and at_mode_eng ~= 9 then
		at_mode_eng = 9
		at_throttle_hold = 0	-- mode throttle HLD off
		ap_goaround = 0
		to_after_80kts = 0
		simDR_fdir_pitch_ovr = 0
		if fd_goaround < 3 then
			fd_goaround = 0
		end
		--B738DR_autopilot_thr_hld_pfd = 0
		--B738DR_autopilot_to_ga_pfd = 0
		--B738DR_autopilot_ga_pfd = 0
		--B738DR_autopilot_alt_acq_pfd = 0
		simDR_autothrottle_enable = 1	-- speed on
	end
	B738DR_speed_mode = at_mode

end


function B738_n1()
	
	if at_mode == 1 and at_mode_eng == 1 then
		B738DR_autopilot_n1_status = 1
		----simDR_throttle_override = 1
		eng1_N1_thrust_trg = eng1_N1_thrust	-- N1 THRUST
		eng2_N1_thrust_trg = eng2_N1_thrust	-- N1 THRUST
--		--simDR_throttle_all = eng1_N1_thrust	-- N1 THRUST
		--B738DR_retard_status = 0
	end
	
end


function lift_off()

	lift_off_150 = 1	-- 150 seconds after lift off

end

function B738_lift_off()

	local lo_timer_enable = 1
	
	if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 
	or simDR_on_ground_2 == 1 then
		lo_timer_enable = 0
		lift_off_150 = 0
	end
	
	if lo_timer_enable == 1 and lift_off_150 == 0 then
		if is_timer_scheduled(lift_off) == false then
			run_after_time(lift_off, 150)
		end
	end

end

function on_ground()

	on_ground_30 = 1	-- 50 seconds on the ground

end

function B738_on_ground()

	local og_timer_enable = 0
	
	if simDR_on_ground_0 == 1 and simDR_on_ground_1 == 1 
	and simDR_on_ground_2 == 1 then
		og_timer_enable = 1
	end
	if simDR_airspeed_pilot < 20 then
		on_ground_30 = 1
	end
	
	if simDR_radio_height_pilot_ft > 500 then
		on_ground_30 = 0
	end
	
	if og_timer_enable == 1 and on_ground_30 == 0 then
		if is_timer_scheduled(on_ground) == false then
			run_after_time(on_ground, 50)
		end
	end

end

function B738_goaround_block()
 
	if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 
	or simDR_on_ground_2 == 1 then
		if B738DR_autopilot_autothr_arm_pos == 0 then
			ap_goaround_block = 1
		end
	end
	if simDR_radio_height_pilot_ft > 500 then
		ap_goaround_block = 0
	end

end



function B738_ap_takeoff()

	local delta_thr = 0
	
	if at_mode == 3 and at_mode_eng == 3 then
		if simDR_radio_height_pilot_ft > 400
		and ap_pitch_mode_eng ~= ap_pitch_mode_old then		-- terminate TAKEOFF mode
			at_mode = 0
		end
		if simDR_radio_height_pilot_ft < 400
		and B738DR_fd_on == 0 
		and to_after_80kts == 0 then					-- terminate TAKEOFF mode
			at_mode = 0
--			ap_pitch_mode_eng = 0
--			simDR_fdir_pitch_ovr = 0
		end
		if B738DR_autobrake_RTO_arm == 2 then			-- terminate TAKEOFF mode
			at_mode = 0
--			simDR_fdir_pitch_ovr = 0
		end
		
		if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 
		or simDR_on_ground_2 == 1 then		-- if aircraft on ground
			if simDR_airspeed_pilot < 60 then
				-- N1 TAKEOFF thrust
				--B738DR_autopilot_n1_pfd = 1			-- PFD speed> N1
				--B738DR_autopilot_to_ga_pfd = 1		-- PFD pitch> TO/GA
				B738DR_autopilot_n1_status = 1
				B738DR_pfd_spd_mode = PFD_SPD_N1
				B738DR_pfd_alt_mode = PFD_ALT_TO_GA
				if B738DR_autopilot_speed_status == 1 then
					simDR_autothrottle_enable = 0	-- speed off
				end
				----simDR_throttle_override = 1
				at_throttle_hold = 0	-- mode throttle HLD off
				--eng1_N1_thrust_trg = eng1_N1_thrust		-- N1 TAKEOFF THRUST
				--eng2_N1_thrust_trg = eng1_N1_thrust		-- N1 TAKEOFF THRUST
				eng1_N1_thrust_trg = B738DR_fms_N1_thrust
				eng2_N1_thrust_trg = B738DR_fms_N1_thrust
--				--simDR_throttle_all = eng1_N1_thrust		-- N1 TAKEOFF THRUST
				if simDR_fdir_pitch_ovr == 0 then
					fd_cur = simDR_fdir_pitch
					simDR_fdir_pitch_ovr = 1
				end
				fd_target = -10
				fd_cur = B738_set_anim_value(fd_cur, fd_target, -20, 20, 0.5)
				simDR_fdir_pitch = fd_cur
			elseif simDR_airspeed_pilot < 80 then	-- < 84 kts
				--B738DR_autopilot_n1_pfd = 1					-- PFD speed> N1
				--B738DR_autopilot_to_ga_pfd = 1				-- PFD pitch> TO/GA
				B738DR_autopilot_n1_status = 1
				B738DR_pfd_spd_mode = PFD_SPD_N1
				B738DR_pfd_alt_mode = PFD_ALT_TO_GA
				----simDR_throttle_override = 1
				at_throttle_hold = 0	-- mode throttle HLD off
				--eng1_N1_thrust_trg = eng1_N1_thrust		-- N1 TAKEOFF THRUST
				--eng2_N1_thrust_trg = eng1_N1_thrust		-- N1 TAKEOFF THRUST
				eng1_N1_thrust_trg = B738DR_fms_N1_thrust
				eng2_N1_thrust_trg = B738DR_fms_N1_thrust
--				--simDR_throttle_all = eng1_N1_thrust		-- N1 TAKEOFF THRUST
				if simDR_fdir_pitch_ovr == 0 then
					fd_cur = simDR_fdir_pitch
					simDR_fdir_pitch_ovr = 1
				end
				fd_target = 15
				fd_cur = B738_set_anim_value(fd_cur, fd_target, -20, 20, 0.5)
				simDR_fdir_pitch = fd_cur
			else	-- simDR_airspeed_pilot > 84 kts
				
				-- THR HLD thrust
				if simDR_fdir_pitch_ovr == 0 then
					fd_cur = simDR_fdir_pitch
					simDR_fdir_pitch_ovr = 1
				end
				fd_target = 15
				fd_cur = B738_set_anim_value(fd_cur, fd_target, -20, 20, 0.5)
				simDR_fdir_pitch = fd_cur
				--B738DR_autopilot_n1_pfd = 0
				B738DR_autopilot_n1_status = 0
				--B738DR_autopilot_thr_hld_pfd = 1			-- PFD speed> THR HLD
				--B738DR_autopilot_to_ga_pfd = 1				-- PFD pitch> TO/GA
				B738DR_pfd_spd_mode = PFD_SPD_THR_HLD
				B738DR_pfd_alt_mode = PFD_ALT_TO_GA
--				at_throttle_hold = 1	-- mode throttle HLD
				if to_thrust_set == 0 then
					--simDR_throttle_all = eng1_N1_thrust		-- N1 TAKEOFF THRUST
					----simDR_throttle_override = 0
					--simDR_throttle_all = eng1_N1_thrust		-- N1 TAKEOFF THRUST
					--eng1_N1_thrust_trg = eng1_N1_thrust		-- N1 TAKEOFF THRUST
					--eng2_N1_thrust_trg = eng1_N1_thrust		-- N1 TAKEOFF THRUST
					eng1_N1_thrust_trg = B738DR_fms_N1_thrust
					eng2_N1_thrust_trg = B738DR_fms_N1_thrust
					delta_thr = eng1_N1_thrust_trg - eng1_N1_thrust_cur
					if delta_thr < 0.02 then
						at_throttle_hold = 1	-- mode throttle HLD
						to_thrust_set = 1
					end
				else
					at_throttle_hold = 1	-- mode throttle HLD
				end
			end
		--elseif simDR_radio_height_pilot_ft < B738DR_thr_red_alt then 	--800 then
		elseif simDR_radio_height_pilot_ft < B738DR_accel_alt then 	--800 then
			
			if simDR_autopilot_altitude_mode ~= 5 then
				
				if simDR_fdir_pitch_ovr == 1 then
					simDR_fdir_pitch_ovr = 0
				end
				
				
			
				-- if simDR_fdir_pitch_ovr == 0 then
					-- fd_cur = simDR_fdir_pitch
					-- simDR_fdir_pitch_ovr = 1
				-- end
				-- fd_target = 15
				-- fd_cur = B738_set_anim_value(fd_cur, fd_target, -20, 20, 0.5)
				-- simDR_fdir_pitch = fd_cur
				--B738DR_autopilot_n1_pfd = 0
				--B738DR_autopilot_thr_hld_pfd = 1			-- PFD speed> THR HLD
				--B738DR_autopilot_to_ga_pfd = 1				-- PFD pitch> TO/GA
				B738DR_autopilot_n1_status = 0
				B738DR_pfd_spd_mode = PFD_SPD_THR_HLD
				B738DR_pfd_alt_mode = PFD_ALT_TO_GA
				if to_thrust_set == 0 then
					--simDR_throttle_all = eng1_N1_thrust		-- N1 TAKEOFF THRUST
					----simDR_throttle_override = 0
					--simDR_throttle_all = eng1_N1_thrust		-- N1 TAKEOFF THRUST
					--eng1_N1_thrust_trg = eng1_N1_thrust		-- N1 TAKEOFF THRUST
					--eng2_N1_thrust_trg = eng1_N1_thrust		-- N1 TAKEOFF THRUST
					eng1_N1_thrust_trg = B738DR_fms_N1_thrust
					eng2_N1_thrust_trg = B738DR_fms_N1_thrust
					delta_thr = eng1_N1_thrust_trg - eng1_N1_thrust_cur
					if delta_thr < 0.02 then
						at_throttle_hold = 1	-- mode throttle HLD
						to_thrust_set = 1
					end
				else
					at_throttle_hold = 1	-- mode throttle HLD
				end
				if at_throttle_hold == 1 and fd_cur > 14.5 and simDR_vvi_fpm_pilot > 500 then
					simDR_fdir_pitch_ovr = 0
					simCMD_autopilot_lvl_chg:once()
					if B738DR_fms_v2_15 == 0 then
						simDR_airspeed_dial = 165
					else
						simDR_airspeed_dial = B738DR_fms_v2_15
					end
				end
			end
		else --- simDR_radio_height_pilot_ft > accel height
			
			if simDR_fdir_pitch_ovr == 1 then
				simDR_fdir_pitch_ovr = 0
			end
			if simDR_autopilot_altitude_mode ~= 5 then
				simCMD_autopilot_lvl_chg:once()
			end
			
			--B738DR_autopilot_to_ga_pfd = 1				-- PFD pitch> TO/GA
			
			-- if simDR_radio_height_pilot_ft < B738DR_thr_red_alt then
			
				--B738DR_autopilot_n1_pfd = 0
				--B738DR_autopilot_thr_hld_pfd = 0			-- PFD speed> no THR HLD
				B738DR_autopilot_n1_status = 0
				B738DR_pfd_spd_mode = PFD_SPD_ARM
				B738DR_pfd_alt_mode = PFD_ALT_TO_GA
				if to_thrust_set == 0 then
						eng1_N1_thrust_trg = B738DR_fms_N1_thrust
						eng2_N1_thrust_trg = B738DR_fms_N1_thrust
						delta_thr = eng1_N1_thrust_trg - eng1_N1_thrust_cur
						if delta_thr < 0.02 then
							at_throttle_hold = 1	-- mode throttle HLD
							to_thrust_set = 1
						end
				else
					at_throttle_hold = 1	-- mode throttle HLD
				end
				
				-- B738DR_autopilot_n1_pfd = 0
				-- B738DR_autopilot_thr_hld_pfd = 0			-- PFD speed> no THR HLD
				-- B738DR_autopilot_to_ga_pfd = 1				-- PFD pitch> TO/GA
				-- B738DR_autopilot_n1_status = 0
				if to_thrust_set == 0 then
						eng1_N1_thrust_trg = B738DR_fms_N1_thrust
						eng2_N1_thrust_trg = B738DR_fms_N1_thrust
						delta_thr = eng1_N1_thrust_trg - eng1_N1_thrust_cur
						if delta_thr < 0.02 then
							at_throttle_hold = 1	-- mode throttle HLD
							to_thrust_set = 1
						end
				else
					at_throttle_hold = 1	-- mode throttle HLD
				end
			
			-- else
				-- if takeoff_n1 == 0 then
					-- takeoff_n1 = 1
				-- end
			-- end
			
			if takeoff_n1 == 1 then
				B738DR_autopilot_n1_status = 1
				--at_throttle_hold = 0	-- mode throttle HLD off
				eng1_N1_thrust_trg = B738DR_fms_N1_thrust
				eng2_N1_thrust_trg = B738DR_fms_N1_thrust
				B738DR_pfd_spd_mode = PFD_SPD_N1
			end
			
			-- if B738DR_autopilot_vnav_status == 0 then
				-- if B738DR_fmc_climb_speed > 250 then
					-- simDR_airspeed_dial = 250
				-- else
					-- simDR_airspeed_dial = B738DR_fmc_climb_speed
				-- end
			-- end
		
		end
	end
	ap_pitch_mode_old = ap_pitch_mode_eng
	
end

function B738_ap_goaround()

	local flaps_speed = 0
	local flaps = simDR_flaps_ratio
	-- A/P GoAround
	if at_mode == 4 and at_mode_eng == 4 then
		
		if simDR_radio_height_pilot_ft < 400 then
			if ap_on == 0
			and B738DR_fd_on == 0 then		-- terminate AP GoAround mode
				at_mode = 0
				ap_roll_mode_eng = 10
				ap_pitch_mode_eng = 10
				ap_goaround = 0
				simDR_fdir_pitch_ovr = 0
				B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
			end
		-- else
			-- if ap_roll_mode ~= 0 or ap_pitch_mode ~= 0 
			-- or B738DR_autopilot_alt_acq_pfd == 1 then
				-- at_mode = 2
				-- B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
				-- ap_roll_mode_eng = 10
				-- ap_pitch_mode_eng = 10
				-- ap_goaround = 0
				-- simDR_fdir_pitch_ovr = 0
				-- if cmd_first == 0 then
					-- autopilot_cmd_b_status = 0
				-- else
					-- autopilot_cmd_a_status = 0
				-- end
			-- end
		end
		--if ap_pitch_mode_old ~= ap_pitch_mode then
		if ap_pitch_mode ~= 0 then
			at_mode = 2
			--B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
			ap_pitch_mode_eng = 10
			ap_goaround = 0
			simDR_fdir_pitch_ovr = 0
			if cmd_first == 0 then
				autopilot_cmd_b_status = 0
			else
				autopilot_cmd_a_status = 0
			end
		end
		--if B738DR_autopilot_alt_acq_pfd == 1 then
		if ap_pitch_mode == 6 and ap_pitch_mode_eng == 6 then
			--B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
			ap_goaround = 0
			simDR_fdir_pitch_ovr = 0
			if cmd_first == 0 then
				autopilot_cmd_b_status = 0
			else
				autopilot_cmd_a_status = 0
			end
		end
		-- if simDR_radio_height_pilot_ft > 2000 then
			-- if simDR_glideslope_status < 2 or simDR_flaps_ratio < 0 then
				-- -- at_mode = 0
				-- -- ap_roll_mode_eng = 10
				-- -- ap_pitch_mode_eng = 10
				-- -- ap_goaround = 0
				-- -- simDR_fdir_pitch_ovr = 0
				-- -- B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
				-- simDR_flight_dir_mode = 1
				-- autopilot_cmd_a_status = 0
				-- autopilot_cmd_b_status = 0
			-- end
		-- end
		
		if ap_goaround == 1 then		-- first push
			-- speed: maximal current flaps speed, hdg: current track, vsi: 1000-2000fpm
			-- if B738DR_pfd_flaps_bug < 250 then
				-- flap_speed = B738DR_pfd_flaps_bug - 10
				-- if flap_speed == 0 then
					-- flap_speed = 180
				-- end
			-- else
				-- flap_speed = 250
			-- end
			if flaps == 0 then
				flaps_speed = 230
			elseif flaps <= 0.25 then		-- flaps 1,2
				flaps_speed = B738DR_pfd_flaps_1
			elseif flaps <= 0.375 then		-- flaps 5
				flaps_speed = B738DR_pfd_flaps_5
			elseif flaps <= 0.5 then		-- flaps 10
				flaps_speed = B738DR_pfd_flaps_10
			elseif flaps <= 0.625 then		-- flaps 15
				if B738DR_fms_vref_15 == 0 then
					flaps_speed = B738DR_pfd_flaps_15
				else
					flaps_speed = B738DR_fms_vref_15
				end
			elseif flaps <= 0.75 then		-- flaps 25
				if B738DR_fms_vref_25 == 0 then
					flaps_speed = 175
				else
					flaps_speed = B738DR_fms_vref_25
				end
			elseif flaps <= 0.875 then		-- flaps 30
				if B738DR_fms_vref_30 == 0 then
					flaps_speed = 165
				else
					flaps_speed = B738DR_fms_vref_30
				end
			else		-- flaps 40
				if B738DR_fms_vref_40 == 0 then
					flaps_speed = 155
				else
					flaps_speed = B738DR_fms_vref_40
				end
			end
			simDR_airspeed_dial = flaps_speed
			if simDR_vvi_fpm_pilot < 1200 then
				fd_target = 15
				fd_cur = B738_set_anim_value(fd_cur, fd_target, -20, 20, 0.5)
				simDR_fdir_pitch = fd_cur
			else
				simDR_fdir_pitch_ovr = 0
				if simDR_autopilot_altitude_mode ~= 5 then
					simCMD_autopilot_lvl_chg:once()		--LVL CHG on
				end
				
			end
			simDR_autothrottle_enable = 1
			-- eng1_N1_thrust_trg = N1_goaround_thrust * 0.9		-- N1 GOAROUND THRUST
			-- eng2_N1_thrust_trg = N1_goaround_thrust * 0.9		-- N1 GOAROUND THRUST

			
--			if simDR_vvi_fpm_pilot > 800 and simDR_yoke_pitch > 0.1 then
--				simDR_yoke_pitch = 0
--			end
			-- if simDR_autopilot_altitude_mode == 6 then
				-- B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
				-- if simDR_ap_altitude_dial_ft == B738DR_fmc_approach_alt then
					-- B738DR_autopilot_alt_acq_pfd = 1	-- PFD pitch> ALT ACQ
					-- ap_pitch_mode = 6
					-- ap_pitch_mode_eng = 6
				-- else
					-- ap_pitch_mode = 3
					-- ap_pitch_mode_eng = 3
				-- end
				-- ap_roll_mode_eng = 10
				-- at_mode = 2
				-- ap_goaround = 0
				-- if cmd_first == 0 then
					-- autopilot_cmd_b_status = 0
				-- else
					-- autopilot_cmd_a_status = 0
				-- end
			-- end
		
		elseif ap_goaround == 2 then	-- second push
			if flaps == 0 then
				flaps_speed = 230
			elseif flaps <= 0.25 then		-- flaps 1,2
				flaps_speed = B738DR_pfd_flaps_1
			elseif flaps <= 0.375 then		-- flaps 5
				flaps_speed = B738DR_pfd_flaps_5
			elseif flaps <= 0.5 then		-- flaps 10
				flaps_speed = B738DR_pfd_flaps_10
			elseif flaps <= 0.625 then		-- flaps 15
				if B738DR_fms_vref_15 == 0 then
					flaps_speed = B738DR_pfd_flaps_15
				else
					flaps_speed = B738DR_fms_vref_15
				end
			elseif flaps <= 0.75 then		-- flaps 25
				if B738DR_fms_vref_25 == 0 then
					flaps_speed = 175
				else
					flaps_speed = B738DR_fms_vref_25
				end
			elseif flaps <= 0.875 then		-- flaps 30
				if B738DR_fms_vref_30 == 0 then
					flaps_speed = 165
				else
					flaps_speed = B738DR_fms_vref_30
				end
			else		-- flaps 40
				if B738DR_fms_vref_40 == 0 then
					flaps_speed = 155
				else
					flaps_speed = B738DR_fms_vref_40
				end
			end
			simDR_airspeed_dial = flaps_speed
			simDR_fdir_pitch_ovr = 0
			simDR_autothrottle_enable = 0
			----simDR_throttle_override = 1
			eng1_N1_thrust_trg = N1_goaround_thrust		-- N1 FULL GOAROUND THRUST
			eng2_N1_thrust_trg = N1_goaround_thrust		-- N1 FULL GOAROUND THRUST
			--B738DR_autopilot_n1_status = 1
--			--simDR_throttle_all = N1_goaround_thrust		-- N1 FULL GOAROUND THRUST
			if simDR_autopilot_altitude_mode ~= 5 then
				simCMD_autopilot_lvl_chg:once()		--LVL CHG on
			-- elseif simDR_autopilot_altitude_mode == 6 then
				-- B738DR_autopilot_to_ga_pfd = 1		-- PFD pitch> TO/GA off
				-- if simDR_ap_altitude_dial_ft == B738DR_fmc_approach_alt then
				
					-- B738DR_autopilot_alt_acq_pfd = 1	-- PFD pitch> ALT ACQ
					-- ap_pitch_mode = 6
					-- ap_pitch_mode_eng = 6
				-- else
					-- ap_pitch_mode = 3
					-- ap_pitch_mode_eng = 3
				-- end
				-- ap_roll_mode = 0
				-- at_mode = 2
				-- ap_goaround = 0
				-- if cmd_first == 0 then
					-- autopilot_cmd_b_status = 0
				-- else
					-- autopilot_cmd_a_status = 0
				-- end
			end
		end
		
	-- A/P GoAround after touchdown
	elseif at_mode == 8 and at_mode_eng == 8 then
		if fd_on == 0 or ap_on == 0 then
			at_mode = 0
			ap_goaround = 0
			----simDR_throttle_override = 0
		else
			fd_target = 15
			fd_cur = B738_set_anim_value(fd_cur, fd_target, -20, 20, 0.5)
			simDR_fdir_pitch = fd_cur
			----simDR_throttle_override = 1
			eng1_N1_thrust_trg = N1_goaround_thrust		-- N1 FULL GOAROUND THRUST
			eng2_N1_thrust_trg = N1_goaround_thrust		-- N1 FULL GOAROUND THRUST
			--B738DR_autopilot_n1_status = 1
--			--simDR_throttle_all = N1_goaround_thrust		-- N1 FULL GOAROUND THRUST
			if simDR_autopilot_altitude_mode ~= 5 then
				simCMD_autopilot_lvl_chg:once()		--LVL CHG on
			end
		end
		--if B738DR_autopilot_alt_acq_pfd == 1 then
		if ap_pitch_mode_eng == 6 or ap_pitch_mode_eng == 3 then
			--B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
			ap_goaround = 0
			simDR_fdir_pitch_ovr = 0
			if cmd_first == 0 then
				autopilot_cmd_b_status = 0
			else
				autopilot_cmd_a_status = 0
			end
		end
	
	-- F/D GoAround
	elseif at_mode == 5 and at_mode_eng == 5 then
		
		if simDR_radio_height_pilot_ft < 400 then
			if B738DR_fd_on == 0 then		-- terminate FD GoAround mode
				at_mode = 0
				ap_roll_mode_eng = 10
				ap_pitch_mode_eng = 10
				fd_goaround = 0
				B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
			end
		else
			--if ap_pitch_mode_old ~= ap_pitch_mode then
			if ap_pitch_mode ~= 0 then
				ap_roll_mode = 1
				at_mode = 2
				B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
				fd_goaround = 0
				simDR_fdir_pitch_ovr = 0
			end
			--if B738DR_autopilot_alt_acq_pfd == 1 then
			if ap_pitch_mode_eng == 6 or ap_pitch_mode_eng == 3 then
				at_mode = 2
				B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
				fd_goaround = 0
				simDR_fdir_pitch_ovr = 0
			end
			-- if ap_roll_mode ~= 0 or ap_pitch_mode ~= 0 
			-- or B738DR_autopilot_alt_acq_pfd == 1 then
				-- at_mode = 2
				-- B738DR_autopilot_to_ga_pfd = 0		-- PFD pitch> TO/GA
				-- ap_roll_mode_eng = 10
				-- ap_pitch_mode_eng = 10
				-- fd_goaround = 0
				-- simDR_fdir_pitch_ovr = 0
			-- end
		end
		if ap_on == 1 then
			ap_roll_mode = 1
			ap_pitch_mode = 2
			ap_pitch_mode_eng = 10
			fd_goaround = 0
			simDR_fdir_pitch_ovr = 0
		end
		
		if fd_goaround == 1 then		-- first push
			-- speed: maximal current flaps speed
			-- if B738DR_pfd_flaps_bug < 250 then
				-- flap_speed = B738DR_pfd_flaps_bug - 10
				-- if flap_speed == 0 then
					-- flap_speed = 180
				-- end
			-- else
				-- flap_speed = 250
			-- end
			if flaps == 0 then
				flaps_speed = 230
			elseif flaps <= 0.25 then		-- flaps 1,2
				flaps_speed = B738DR_pfd_flaps_1
			elseif flaps <= 0.375 then		-- flaps 5
				flaps_speed = B738DR_pfd_flaps_5
			elseif flaps <= 0.5 then		-- flaps 10
				flaps_speed = B738DR_pfd_flaps_10
			elseif flaps <= 0.625 then		-- flaps 15
				if B738DR_fms_vref_15 == 0 then
					flaps_speed = B738DR_pfd_flaps_15
				else
					flaps_speed = B738DR_fms_vref_15
				end
			elseif flaps <= 0.75 then		-- flaps 25
				if B738DR_fms_vref_25 == 0 then
					flaps_speed = 175
				else
					flaps_speed = B738DR_fms_vref_25
				end
			elseif flaps <= 0.875 then		-- flaps 30
				if B738DR_fms_vref_30 == 0 then
					flaps_speed = 165
				else
					flaps_speed = B738DR_fms_vref_30
				end
			else		-- flaps 40
				if B738DR_fms_vref_40 == 0 then
					flaps_speed = 155
				else
					flaps_speed = B738DR_fms_vref_40
				end
			end
			simDR_airspeed_dial = flaps_speed
			simDR_autothrottle_enable = 1
			-- eng1_N1_thrust_trg = N1_goaround_thrust * 0.9		-- N1 GOAROUND THRUST
			-- eng2_N1_thrust_trg = N1_goaround_thrust * 0.9		-- N1 GOAROUND THRUST
			
			
			if simDR_vvi_fpm_pilot < 1200 then
				fd_target = 15
				fd_cur = B738_set_anim_value(fd_cur, fd_target, -20, 20, 0.5)
				simDR_fdir_pitch = fd_cur
			else
				simDR_fdir_pitch_ovr = 0
				if simDR_autopilot_altitude_mode ~= 5 then
					simCMD_autopilot_lvl_chg:once()		--LVL CHG on
				end
			end
		
		elseif fd_goaround == 2 then	-- second push
			if flaps == 0 then
				flaps_speed = 230
			elseif flaps <= 0.25 then		-- flaps 1,2
				flaps_speed = B738DR_pfd_flaps_1
			elseif flaps <= 0.375 then		-- flaps 5
				flaps_speed = B738DR_pfd_flaps_5
			elseif flaps <= 0.5 then		-- flaps 10
				flaps_speed = B738DR_pfd_flaps_10
			elseif flaps <= 0.625 then		-- flaps 15
				if B738DR_fms_vref_15 == 0 then
					flaps_speed = B738DR_pfd_flaps_15
				else
					flaps_speed = B738DR_fms_vref_15
				end
			elseif flaps <= 0.75 then		-- flaps 25
				if B738DR_fms_vref_25 == 0 then
					flaps_speed = 175
				else
					flaps_speed = B738DR_fms_vref_25
				end
			elseif flaps <= 0.875 then		-- flaps 30
				if B738DR_fms_vref_30 == 0 then
					flaps_speed = 165
				else
					flaps_speed = B738DR_fms_vref_30
				end
			else		-- flaps 40
				if B738DR_fms_vref_40 == 0 then
					flaps_speed = 155
				else
					flaps_speed = B738DR_fms_vref_40
				end
			end
			simDR_airspeed_dial = flaps_speed
			simDR_autothrottle_enable = 0
			----simDR_throttle_override = 1
			eng1_N1_thrust_trg = N1_goaround_thrust		-- N1 FULL GOAROUND THRUST
			eng2_N1_thrust_trg = N1_goaround_thrust		-- N1 FULL GOAROUND THRUST
			--B738DR_autopilot_n1_status = 1
--			--simDR_throttle_all = N1_goaround_thrust		-- N1 FULL GOAROUND THRUST
			if simDR_autopilot_altitude_mode ~= 5 then
				simCMD_autopilot_lvl_chg:once()		--LVL CHG on
			end
		end
	end
	ap_pitch_mode_old = ap_pitch_mode_eng
	ap_roll_mode_old = ap_roll_mode_eng

end

function B738_fd_show()

	if to_after_80kts == 0 then		-- if no Takeoff without F/D on
		if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 or simDR_on_ground_2 == 1 then
			if ap_pitch_mode == 0 and ap_roll_mode == 0 then
				B738DR_fd_pilot_show = 0
				B738DR_fd_copilot_show = 0
			else
				B738DR_fd_pilot_show = B738DR_autopilot_fd_pos
				B738DR_fd_copilot_show = B738DR_autopilot_fd_fo_pos
			end
		else
			B738DR_fd_pilot_show = B738DR_autopilot_fd_pos
			B738DR_fd_copilot_show = B738DR_autopilot_fd_fo_pos
		end
	end

end


-- function B738_bank_angle()

	-- if ap_roll_mode == 1 then
		-- if B738DR_autopilot_bank_angle_pos == 4 then
			-- simDR_bank_angle = 6
		-- elseif B738DR_autopilot_bank_angle_pos == 3 then
			-- simDR_bank_angle = 5
		-- elseif B738DR_autopilot_bank_angle_pos == 2 then
			-- simDR_bank_angle = 4
		-- elseif B738DR_autopilot_bank_angle_pos == 1 then
			-- simDR_bank_angle = 3
		-- elseif B738DR_autopilot_bank_angle_pos == 0 then
			-- simDR_bank_angle = 2
		-- end
	-- else
		-- if ap_pitch_mode == 5 then	--VNAV
			-- simDR_bank_angle = 6
		-- else
			-- simDR_bank_angle = 4
		-- end
	-- end

-- end


---- IAS and ALT DISAGREE ----

function ias_disagree_timer()
	ias_disagree = 1
end

function alt_disagree_timer()
	alt_disagree = 1
end

function B738_ias_alt_disagree()

	local delta_airspeed = 0
	local delta_alt = 0
	
	-- IAS disagree
	delta_airspeed = simDR_airspeed_pilot - simDR_airspeed_copilot
	if delta_airspeed < 0 then
		delta_airspeed = -delta_airspeed
	end
	if delta_airspeed > 5 then
		if is_timer_scheduled(ias_disagree_timer) == false then
			run_after_time(ias_disagree_timer, 5)	-- 5 seconds
		end
	else
		if is_timer_scheduled(ias_disagree_timer) == true then
			stop_timer(ias_disagree_timer)
		end
		ias_disagree = 0
	end
	
	-- ALT disagree
	delta_alt = simDR_altitude_pilot - simDR_altitude_copilot
	if delta_alt < 0 then
		delta_alt = -delta_alt
	end
	if delta_alt > 200 then
		if is_timer_scheduled(alt_disagree_timer) == false then
			run_after_time(alt_disagree_timer, 5)	-- 5 seconds
		end
	else
		if is_timer_scheduled(alt_disagree_timer) == true then
			stop_timer(alt_disagree_timer)
		end
		alt_disagree = 0
	end
	B738DR_ias_disagree = ias_disagree
	B738DR_alt_disagree = alt_disagree

end


function B738_eng_n1_set()
	
	local thrust_correct = 0
	local alt_correct = 0
	local req_idle = 0
	local req1_idle = 0
	local req2_idle = 0
	
	if B738DR_n1_set_source == -2 then		-- ENG 2 SET
--		if simDR_eng2_reverser_on == 1 then
		if simDR_reverse2_deploy > 0.01 then
			B738DR_eng2_N1_bug_dig = 0
			eng2_N1_thrust = 0
		else
			B738DR_eng2_N1_bug_dig = 1
			B738DR_eng2_N1_bug = B738DR_n1_set_adjust
			req_idle = math.max(0.5, simDR_engine_mixture2)
			req1_idle = B738_rescale(0.5, 0.5138, 1.0, 0.3741, req_idle)
			req2_idle = B738_rescale(0.5, 1.015, 1.0, 1.008, req_idle)
			eng2_N1_thrust = B738_rescale(0.6, req1_idle, req2_idle, 1.04, B738DR_eng2_N1_bug)
			-- eng2_N1_thrust = B738_rescale(0.6, 0.423, 1.011, 1.04, B738DR_eng2_N1_bug)
			eng2_N1_man = B738DR_eng2_N1_bug
		end
--		if simDR_eng1_reverser_on == 1 then
		if simDR_reverse1_deploy > 0.01 then
			B738DR_eng1_N1_bug_dig = 0
			eng1_N1_thrust = 0
		else
			B738DR_eng1_N1_bug_dig = 1
			req_idle = math.max(0.5, simDR_engine_mixture1)
			req1_idle = B738_rescale(0.5, 0.5138, 1.0, 0.3741, req_idle)
			req2_idle = B738_rescale(0.5, 1.015, 1.0, 1.008, req_idle)
			eng1_N1_thrust = B738_rescale(0.6, req1_idle, req2_idle, 1.04, B738DR_eng1_N1_bug)
			-- eng1_N1_thrust = B738_rescale(0.6, 0.423, 1.011, 1.04, B738DR_eng1_N1_bug)
		end
		B738DR_assum_temp_show = 0
		B738DR_N1_mode_man = 1
	
	elseif  B738DR_n1_set_source == -1 then	-- ENG 1 SET
--		if simDR_eng1_reverser_on == 1 then
		if simDR_reverse1_deploy > 0.01 then
			B738DR_eng1_N1_bug_dig = 0
			eng1_N1_thrust = 0
		else
			B738DR_eng1_N1_bug_dig = 1
			B738DR_eng1_N1_bug = B738DR_n1_set_adjust
			req_idle = math.max(0.5, simDR_engine_mixture1)
			req1_idle = B738_rescale(0.5, 0.5138, 1.0, 0.3741, req_idle)
			req2_idle = B738_rescale(0.5, 1.015, 1.0, 1.008, req_idle)
			eng1_N1_thrust = B738_rescale(0.6, req1_idle, req2_idle, 1.04, B738DR_eng1_N1_bug)
			-- eng1_N1_thrust = B738_rescale(0.6, 0.423, 1.011, 1.04, B738DR_eng1_N1_bug)
			eng1_N1_man = B738DR_eng1_N1_bug
		end
--		if simDR_eng2_reverser_on == 1 then
		if simDR_reverse2_deploy > 0.01 then
			B738DR_eng2_N1_bug_dig = 0
			eng2_N1_thrust = 0
		else
			B738DR_eng2_N1_bug_dig = 1
			req_idle = math.max(0.5, simDR_engine_mixture2)
			req1_idle = B738_rescale(0.5, 0.5138, 1.0, 0.3741, req_idle)
			req2_idle = B738_rescale(0.5, 1.015, 1.0, 1.008, req_idle)
			eng2_N1_thrust = B738_rescale(0.6, req1_idle, req2_idle, 1.04, B738DR_eng2_N1_bug)
			-- eng2_N1_thrust = B738_rescale(0.6, 0.423, 1.011, 1.04, B738DR_eng2_N1_bug)
		end
		B738DR_assum_temp_show = 0
		B738DR_N1_mode_man = 1
	
	elseif  B738DR_n1_set_source == 0 then	-- FMC AUTO
		B738DR_N1_mode_man = 0
--		if simDR_eng1_reverser_on == 1 
--		or simDR_eng2_reverser_on == 1 then
		if simDR_reverse1_deploy > 0.01 
		or simDR_reverse2_deploy > 0.01 then
			B738DR_eng1_N1_bug_dig = 0
			B738DR_eng2_N1_bug_dig = 0
			eng1_N1_thrust = 0
			eng2_N1_thrust = 0
			B738DR_assum_temp_show = 0
		else
			if B738DR_fms_N1_mode == 0 or B738DR_fms_N1_mode == 13 then		-- no mode
				B738DR_eng1_N1_bug_dig = 0
				B738DR_eng2_N1_bug_dig = 0
				B738DR_assum_temp_show = 0
--				eng1_N1_thrust = 0.984	-- default 98.4%
--				eng2_N1_thrust = 0.984	-- default 98.4%
			elseif B738DR_fms_N1_mode > 0 then
				B738DR_eng1_N1_bug_dig = 1
				B738DR_eng2_N1_bug_dig = 1
				req_idle = math.max(0.5, simDR_engine_mixture1)
				req1_idle = B738_rescale(0.5, 0.5138, 1.0, 0.3741, req_idle)
				req2_idle = B738_rescale(0.5, 1.015, 1.0, 1.008, req_idle)
				eng1_N1_thrust = B738_rescale(0.6, req1_idle, req2_idle, 1.04, B738DR_eng1_N1_bug)
				req_idle = math.max(0.5, simDR_engine_mixture2)
				req1_idle = B738_rescale(0.5, 0.5138, 1.0, 0.3741, req_idle)
				req2_idle = B738_rescale(0.5, 1.015, 1.0, 1.008, req_idle)
				eng2_N1_thrust = B738_rescale(0.6, req1_idle, req2_idle, 1.04, B738DR_eng2_N1_bug)
				-- eng1_N1_thrust = B738_rescale(0.6, 0.423, 1.011, 1.04, B738DR_eng1_N1_bug)
				-- eng2_N1_thrust = B738_rescale(0.6, 0.423, 1.011, 1.04, B738DR_eng2_N1_bug)
				B738DR_eng1_N1_bug = B738DR_fms_N1_thrust
				B738DR_eng2_N1_bug = B738DR_fms_N1_thrust
				if B738DR_fms_N1_mode > 3 and B738DR_fms_N1_mode < 7 then
					B738DR_assum_temp_show = 1
				else
					B738DR_assum_temp_show = 0
				end
			end
		end
	
	elseif  B738DR_n1_set_source == 1 then	-- both ENG SET
--		if simDR_eng1_reverser_on == 1 then
		if simDR_reverse1_deploy > 0.01 then
			B738DR_eng1_N1_bug_dig = 0
			eng1_N1_thrust = 0
		else
			B738DR_eng1_N1_bug_dig = 1
			B738DR_eng1_N1_bug = B738DR_n1_set_adjust
			req_idle = math.max(0.5, simDR_engine_mixture1)
			req1_idle = B738_rescale(0.5, 0.5138, 1.0, 0.3741, req_idle)
			req2_idle = B738_rescale(0.5, 1.015, 1.0, 1.008, req_idle)
			eng1_N1_thrust = B738_rescale(0.6, req1_idle, req2_idle, 1.04, B738DR_eng1_N1_bug)
--			eng1_N1_thrust = B738_rescale(0.6, 0.423, 1.011, 1.04, B738DR_eng1_N1_bug)
			eng1_N1_man = B738DR_eng1_N1_bug
		end
--		if simDR_eng2_reverser_on == 1 then
		if simDR_reverse2_deploy > 0.01 then
			B738DR_eng2_N1_bug_dig = 0
			eng2_N1_thrust = 0
		else
			B738DR_eng2_N1_bug_dig = 1
			B738DR_eng2_N1_bug = B738DR_n1_set_adjust
			req_idle = math.max(0.5, simDR_engine_mixture2)
			req1_idle = B738_rescale(0.5, 0.5138, 1.0, 0.3741, req_idle)
			req2_idle = B738_rescale(0.5, 1.015, 1.0, 1.008, req_idle)
			eng2_N1_thrust = B738_rescale(0.6, req1_idle, req2_idle, 1.04, B738DR_eng2_N1_bug)
--			eng2_N1_thrust = B738_rescale(0.6,  0.423, 1.011, 1.04, B738DR_eng2_N1_bug)
			eng2_N1_man = B738DR_eng2_N1_bug
		end
		B738DR_assum_temp_show = 0
		B738DR_N1_mode_man = 1
	end
	
	-- ALT THRUST CORRECT
--	alt_correct = math.min(40000, simDR_altitude_pilot)

	--alt_correct = math.min(40000, (simDR_elevation_m * 3.28))
	--thrust_correct = B738_rescale(0, 0, 40000, 0.0312, alt_correct)		-- alt thrust correction
	
	local alt_corr = 0
	local corr_min = 0
	local corr_max = 0
	alt_correct = math.min(40000, (simDR_elevation_m * 3.28))
	alt_correct = math.max(0, alt_correct)
	
	-- alt_corr = roundDownToIncrement(alt_correct, 5000 )
	-- corr_min = B738_rescale(0, n1_correct[alt_corr][1], 40000, n1_correct[alt_corr][2], B738DR_eng1_N1_bug)
	-- alt_corr = roundUpToIncrement(alt_correct, 5000 )
	-- corr_max = B738_rescale(0, n1_correct[alt_corr][1], 40000, n1_correct[alt_corr][2], B738DR_eng1_N1_bug)
	-- thrust_correct = B738_rescale(70, corr_min, 101.1, corr_max, B738DR_eng1_N1_bug)
	-- thrust_correct = thrust_correct / 1000
	
	corr_min = roundDownToIncrement(alt_correct, 5000 )
	corr_max = roundUpToIncrement(alt_correct, 5000 )
	alt_corr = alt_correct
	thrust_correct = B738_rescale(corr_min, n1_correct[corr_min][2], corr_max, n1_correct[corr_max][2], alt_correct)
	thrust_correct = thrust_correct / 1000
	
	if eng1_N1_thrust > 0 then
		eng1_N1_thrust = eng1_N1_thrust + thrust_correct
		eng1_N1_thrust = math.min ( 1.04, eng1_N1_thrust)
	end
	
	-- alt_corr = roundDownToIncrement(alt_correct, 5000 )
	-- corr_min = B738_rescale(0, n1_correct[alt_corr][1], 40000, n1_correct[alt_corr][2], B738DR_eng2_N1_bug)
	-- alt_corr = roundUpToIncrement(alt_correct, 5000 )
	-- corr_max = B738_rescale(0, n1_correct[alt_corr][1], 40000, n1_correct[alt_corr][2], B738DR_eng2_N1_bug)
	-- thrust_correct = B738_rescale(70, corr_min, 101.1, corr_max, B738DR_eng2_N1_bug)
	-- thrust_correct = thrust_correct / 1000
	
	if eng2_N1_thrust > 0 then
		eng2_N1_thrust = eng2_N1_thrust + thrust_correct
		eng1_N1_thrust = math.min ( 1.04, eng2_N1_thrust)
	end

	
end

function B738_N1_thrust_manage()

	--local thr1_target = 0
	--local thr2_target = 0
	local thr1_limit = 0
	local thr2_limit = 0
	local thr1_anim = 0
	local thr2_anim = 0
	local delta_throttle = 0
	local throttle_noise = B738DR_throttle_noise / 100

	if reverse_max_enable == 0 then
		thr1_target = eng1_N1_thrust_cur
		thr2_target = eng2_N1_thrust_cur
		if at_throttle_hold == 0 then		-- manual throttle
			
			if at_mode_eng == 0 then
				
				
				if B738DR_throttle_noise == 0 or lock_throttle == 0 then
					thr1_target = B738_rescale(0, 0, 1, 1.04, simDR_throttle_1)
					thr2_target = B738_rescale(0, 0, 1, 1.04, simDR_throttle_2)
				else
					if B738DR_joy_axis_throttle == -1 then
						
						if B738DR_joy_axis_throttle1 == - 1 and B738DR_joy_axis_throttle2 == -1 then
							lock_throttle = 0
						else
							delta_throttle = math.abs(axis_throttle1_old - B738DR_joy_axis_throttle1)
							if delta_throttle > throttle_noise then
								lock_throttle = 0
							end
							delta_throttle = math.abs(axis_throttle2_old - B738DR_joy_axis_throttle2)
							if delta_throttle > throttle_noise then
								lock_throttle = 0
							end
						end
					else
						delta_throttle = math.abs(axis_throttle_old - B738DR_joy_axis_throttle)
						if delta_throttle > throttle_noise then
							lock_throttle = 0
						end
					end
				end
				
				--thr1_target = B738_rescale(0, 0, 1, 1.04, simDR_throttle_1)
				--thr2_target = B738_rescale(0, 0, 1, 1.04, simDR_throttle_2)
				eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, thr1_target, 0.0, 1.04, 10)
				eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, thr2_target, 0.0, 1.04, 10)
				simDR_throttle1_use = eng1_N1_thrust_cur
				simDR_throttle2_use = eng2_N1_thrust_cur
				--thr1_anim = simDR_throttle_1
				--thr2_anim = simDR_throttle_2
				thr1_anim = eng1_N1_thrust_cur
				thr2_anim = eng2_N1_thrust_cur
			elseif at_mode_eng == 2 then	-- speed mode
				-- thr1_target = B738_rescale(0, 0, 1, 1.04, simDR_throttle_1)
				-- thr2_target = B738_rescale(0, 0, 1, 1.04, simDR_throttle_2)
				-- eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, thr1_target, 0.0, 1.04, 8)
				-- eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, thr2_target, 0.0, 1.04, 8)
				-- simDR_throttle1_use = eng1_N1_thrust_cur
				-- simDR_throttle2_use = eng2_N1_thrust_cur
				-- thr1_anim = math.min(1.0, eng1_N1_thrust_cur)
				-- thr2_anim = math.min(1.0, eng2_N1_thrust_cur)
				lock_throttle = 1
				if B738DR_n1_set_source == 0 then	-- FMC AUTO
					if B738DR_fms_N1_mode == 0 or B738DR_fms_N1_mode == 13 then		-- no mode
						thr1_limit = 1.04
						thr2_limit = 1.04
					else
						thr1_limit = eng1_N1_thrust
						thr2_limit = eng2_N1_thrust
					end
				else 
					thr1_limit = eng1_N1_thrust
					thr2_limit = eng2_N1_thrust
				end
				if simDR_throttle_1 > thr1_limit then
					thr1_target = thr1_limit
				else
					thr1_target = simDR_throttle_1
				end
				if simDR_throttle_2 > thr2_limit then
					thr2_target = thr2_limit
				else
					thr2_target = simDR_throttle_2
				end
				eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, thr1_target, 0.0, 1.04, 8)
				eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, thr2_target, 0.0, 1.04, 8)
				simDR_throttle1_use = eng1_N1_thrust_cur
				simDR_throttle2_use = eng2_N1_thrust_cur
				thr1_anim = math.min(1.0, eng1_N1_thrust_cur)
				thr2_anim = math.min(1.0, eng2_N1_thrust_cur)
				
				axis_throttle_old = B738DR_joy_axis_throttle
				axis_throttle1_old = B738DR_joy_axis_throttle1
				axis_throttle2_old = B738DR_joy_axis_throttle2
				
			elseif at_mode_eng == 9 then	-- speed mode with N1 limit
				lock_throttle = 1
				if B738DR_n1_set_source == 0 then	-- FMC AUTO
					if B738DR_fms_N1_mode == 0 or B738DR_fms_N1_mode == 13 then		-- no mode
						thr1_limit = 1.04
						thr2_limit = 1.04
					else
						thr1_limit = eng1_N1_thrust
						thr2_limit = eng2_N1_thrust
					end
				else 
					thr1_limit = eng1_N1_thrust
					thr2_limit = eng2_N1_thrust
				end
				if simDR_throttle_1 > thr1_limit then
					thr1_target = thr1_limit
				else
					thr1_target = simDR_throttle_1
				end
				if simDR_throttle_2 > thr2_limit then
					thr2_target = thr2_limit
				else
					thr2_target = simDR_throttle_2
				end
				eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, thr1_target, 0.0, 1.04, 8)
				eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, thr2_target, 0.0, 1.04, 8)
				simDR_throttle1_use = eng1_N1_thrust_cur
				simDR_throttle2_use = eng2_N1_thrust_cur
				thr1_anim = math.min(1.0, eng1_N1_thrust_cur)
				thr2_anim = math.min(1.0, eng2_N1_thrust_cur)
			
				
				axis_throttle_old = B738DR_joy_axis_throttle
				axis_throttle1_old = B738DR_joy_axis_throttle1
				axis_throttle2_old = B738DR_joy_axis_throttle2
				
			elseif at_mode_eng == 6 then	-- LVL CHG
				lock_throttle = 1
				if  B738DR_autoland_status == 0 then
					if eng1_N1_thrust_trg == 0 then		--retard
						eng1_N1_thrust_cur = eng1_N1_thrust_cur - 0.002
						if eng1_N1_thrust_cur < 0 then
							eng1_N1_thrust_cur = 0
						end
					else
						eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, eng1_N1_thrust_trg, 0.0, 1.04, 0.5)	--1.5
					end
					if eng2_N1_thrust_trg == 0 then		--retard
						eng2_N1_thrust_cur = eng2_N1_thrust_cur - 0.002
						if eng2_N1_thrust_cur < 0 then
							eng2_N1_thrust_cur = 0
						end
					else
						eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, eng2_N1_thrust_trg, 0.0, 1.04, 0.5)	--1.5
					end
				else
					eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, eng1_N1_thrust_trg, 0.0, 1.04, 1.0)
					eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, eng2_N1_thrust_trg, 0.0, 1.04, 1.0)
				end
				simDR_throttle1_use = eng1_N1_thrust_cur
				simDR_throttle2_use = eng2_N1_thrust_cur
				simDR_throttle_1 = eng1_N1_thrust_cur
				simDR_throttle_2 = eng2_N1_thrust_cur
				thr1_anim = math.min(1.0, eng1_N1_thrust_cur)
				thr2_anim = math.min(1.0, eng2_N1_thrust_cur)
				thr1_target = eng1_N1_thrust_trg
				thr2_target = eng2_N1_thrust_trg
			
				
				axis_throttle_old = B738DR_joy_axis_throttle
				axis_throttle1_old = B738DR_joy_axis_throttle1
				axis_throttle2_old = B738DR_joy_axis_throttle2
				
			elseif at_mode_eng == 4 or at_mode_eng == 5 or at_mode_eng == 8 then	-- AP and FD GoAround
				lock_throttle = 1
				if ap_goaround == 1 or fd_goaround == 1 then
					if B738DR_n1_set_source == 0 then	-- FMC AUTO
						if B738DR_fms_N1_mode == 0 or B738DR_fms_N1_mode == 13 then		-- no mode
							thr1_limit = 1.04
							thr2_limit = 1.04
						else
							thr1_limit = eng1_N1_thrust
							thr2_limit = eng2_N1_thrust
						end
					else 
						thr1_limit = eng1_N1_thrust
						thr2_limit = eng2_N1_thrust
					end
					if simDR_throttle_1 > thr1_limit then
						thr1_target = thr1_limit
					else
						thr1_target = simDR_throttle_1
					end
					if simDR_throttle_2 > thr2_limit then
						thr2_target = thr2_limit
					else
						thr2_target = simDR_throttle_2
					end
					eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, thr1_target, 0.0, 1.04, 8)
					eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, thr2_target, 0.0, 1.04, 8)
					simDR_throttle1_use = eng1_N1_thrust_cur
					simDR_throttle2_use = eng2_N1_thrust_cur
					thr1_anim = math.min(1.0, eng1_N1_thrust_cur)
					thr2_anim = math.min(1.0, eng2_N1_thrust_cur)
				else
					eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, eng1_N1_thrust_trg, 0.0, 1.04, 0.5)	--1.5
					eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, eng2_N1_thrust_trg, 0.0, 1.04, 0.5)	--1.5
					simDR_throttle1_use = eng1_N1_thrust_cur
					simDR_throttle2_use = eng2_N1_thrust_cur
					simDR_throttle_1 = eng1_N1_thrust_cur
					simDR_throttle_2 = eng2_N1_thrust_cur
					thr1_anim = math.min(1.0, eng1_N1_thrust_cur)
					thr2_anim = math.min(1.0, eng2_N1_thrust_cur)
				end
				thr1_target = eng1_N1_thrust_trg
				thr2_target = eng2_N1_thrust_trg
				
				axis_throttle_old = B738DR_joy_axis_throttle
				axis_throttle1_old = B738DR_joy_axis_throttle1
				axis_throttle2_old = B738DR_joy_axis_throttle2
				
			else
				lock_throttle = 1
				eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, eng1_N1_thrust_trg, 0.0, 1.04, 0.5)	--1.5
				eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, eng2_N1_thrust_trg, 0.0, 1.04, 0.5)	--1.5
				simDR_throttle1_use = eng1_N1_thrust_cur
				simDR_throttle2_use = eng2_N1_thrust_cur
				simDR_throttle_1 = eng1_N1_thrust_cur
				simDR_throttle_2 = eng2_N1_thrust_cur
				thr1_anim = math.min(1.0, eng1_N1_thrust_cur)
				thr2_anim = math.min(1.0, eng2_N1_thrust_cur)
				thr1_target = eng1_N1_thrust_trg
				thr2_target = eng2_N1_thrust_trg
				
				axis_throttle_old = B738DR_joy_axis_throttle
				axis_throttle1_old = B738DR_joy_axis_throttle1
				axis_throttle2_old = B738DR_joy_axis_throttle2
				
			end
		
		else
				
			if B738DR_throttle_noise == 0 or lock_throttle == 0 then
				thr1_target = B738_rescale(0, 0, 1, 1.04, simDR_throttle_1)
				thr2_target = B738_rescale(0, 0, 1, 1.04, simDR_throttle_2)
			else
				if B738DR_joy_axis_throttle == -1 then
					
					if B738DR_joy_axis_throttle1 == - 1 and B738DR_joy_axis_throttle2 == -1 then
						lock_throttle = 0
					else
						delta_throttle = math.abs(axis_throttle1_old - B738DR_joy_axis_throttle1)
						if delta_throttle > throttle_noise then
							lock_throttle = 0
						end
						delta_throttle = math.abs(axis_throttle2_old - B738DR_joy_axis_throttle2)
						if delta_throttle > throttle_noise then
							lock_throttle = 0
						end
					end
				else
					delta_throttle = math.abs(axis_throttle_old - B738DR_joy_axis_throttle)
					if delta_throttle > throttle_noise then
						lock_throttle = 0
					end
				end
			end
				
			-- thr1_target = B738_rescale(0, 0, 1, 1.04, simDR_throttle_1)
			-- thr2_target = B738_rescale(0, 0, 1, 1.04, simDR_throttle_2)
			eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, thr1_target, 0.0, 1.04, 2)
			eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, thr2_target, 0.0, 1.04, 2)
			simDR_throttle1_use = eng1_N1_thrust_cur
			simDR_throttle2_use = eng2_N1_thrust_cur
			thr1_anim = simDR_throttle_1
			thr2_anim = simDR_throttle_2
			thr1_target = eng1_N1_thrust_trg
			thr2_target = eng2_N1_thrust_trg
		end
	else
		if reverse_max_on == 1 then
			if simDR_reverse1_deploy > 0.9 or simDR_reverse2_deploy > 0.9 then
				eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, 0.95, 0.0, 1.04, 1.5)
				simDR_throttle1_use = eng1_N1_thrust_cur
				simDR_throttle_1 = eng1_N1_thrust_cur
				thr1_anim = math.min(1.0, eng1_N1_thrust_cur)
				eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, 0.95, 0.0, 1.04, 1.5)
				simDR_throttle2_use = eng2_N1_thrust_cur
				simDR_throttle_2 = eng2_N1_thrust_cur
				thr2_anim = math.min(1.0, eng2_N1_thrust_cur)
			end
		else
			eng1_N1_thrust_cur = B738_set_anim_value(eng1_N1_thrust_cur, 0.0, 0.0, 1.04, 1.5)
			simDR_throttle1_use = eng1_N1_thrust_cur
			simDR_throttle_1 = eng1_N1_thrust_cur
			thr1_anim = math.min(1.0, eng1_N1_thrust_cur)
			eng2_N1_thrust_cur = B738_set_anim_value(eng2_N1_thrust_cur, 0.0, 0.0, 1.04, 1.5)
			simDR_throttle2_use = eng2_N1_thrust_cur
			simDR_throttle_2 = eng2_N1_thrust_cur
			thr2_anim = math.min(1.0, eng2_N1_thrust_cur)
			if simDR_throttle1_use < 0.01 or simDR_throttle2_use < 0.01 then
				simDR_reverse1_act = 1
				simDR_reverse2_act = 1
				reverse_max_enable = 0
				eng1_N1_thrust_cur = 0
				eng2_N1_thrust_cur = 0
				simDR_throttle1_use = eng1_N1_thrust_cur
				simDR_throttle2_use = eng2_N1_thrust_cur
				simDR_throttle_1 = 0
				simDR_throttle_2 = 0
			end
		end
	end
	
	-- B738DR_thrust1_leveler = B738_set_anim_value(B738DR_thrust1_leveler, thr1_anim, 0.0, 1.0, 8)	--thr1_anim
	-- B738DR_thrust2_leveler = B738_set_anim_value(B738DR_thrust2_leveler, thr2_anim, 0.0, 1.0, 8)	--thr2_anim
	--B738DR_thrust1_leveler = B738_set_anim_value(B738DR_thrust1_leveler, thr1_anim, 0.0, 1.0, 8)	--thr1_anim
	--B738DR_thrust2_leveler = B738_set_anim_value(B738DR_thrust2_leveler, thr2_anim, 0.0, 1.0, 8)	--thr2_anim
	B738DR_thrust1_leveler = thr1_anim
	B738DR_thrust2_leveler = thr2_anim
	
end


-- Draw green cirlce
function B738_draw_arc()

	local delta_alt = 0
	local arc_dist = 0
	local arc_time = 0
	local arc_zoom = 0
	local arc_vvi = 0
	
	if simDR_EFIS_mode == 2 and B738DR_capt_map_mode <= 2 then
		if ap_pitch_mode == 1 then		-- V/S
			arc_vvi = simDR_ap_vvi_dial
			if arc_vvi > 100 and simDR_ap_altitude_dial_ft > simDR_altitude_pilot then
				delta_alt = simDR_ap_altitude_dial_ft - simDR_altitude_pilot
			elseif arc_vvi < -100 and simDR_ap_altitude_dial_ft < simDR_altitude_pilot then
				delta_alt = simDR_altitude_pilot - simDR_ap_altitude_dial_ft
				arc_vvi = -arc_vvi
			else
				arc_vvi = 0
			end
			if arc_vvi ~= 0 then 
				arc_time = delta_alt / (arc_vvi / 60) 	-- secs
				arc_dist = simDR_ground_spd * arc_time * 0.00054	-- m to NM
				if B738DR_efis_map_range_capt == 0 then	-- 5 NM
					arc_zoom = 0.226
				elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
					arc_zoom = 0.113
				elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
					arc_zoom = 0.0565
				elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
					arc_zoom = 0.02825
				elseif B738DR_efis_map_range_capt == 4 then	-- 80 NM
					arc_zoom = 0.014125
				end
				if arc_zoom == 0 then
					B738DR_green_arc_show = 0
				else
					arc_dist = arc_dist * arc_zoom
					if arc_dist < 0.005 or arc_dist > 1.0 then
						B738DR_green_arc_show = 0
					else
						B738DR_green_arc = arc_dist
						B738DR_green_arc_show = 1
					end
				end
			else
				B738DR_green_arc_show = 0
			end
		elseif ap_pitch_mode == 2 then		-- LVL CHG
			arc_vvi = simDR_vvi_fpm_pilot
			if arc_vvi > 100 and simDR_ap_altitude_dial_ft > simDR_altitude_pilot then
				delta_alt = simDR_ap_altitude_dial_ft - simDR_altitude_pilot
			elseif arc_vvi < -100 and simDR_ap_altitude_dial_ft < simDR_altitude_pilot then
				delta_alt = simDR_altitude_pilot - simDR_ap_altitude_dial_ft
				arc_vvi = -arc_vvi
			else
				arc_vvi = 0
			end
			if arc_vvi ~= 0 then
				arc_time = delta_alt / (arc_vvi / 60)	-- secs
				arc_dist = simDR_ground_spd * arc_time * 0.00054	-- m to NM
				if B738DR_efis_map_range_capt == 0 then	-- 5 NM
					arc_zoom = 0.226
				elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
					arc_zoom = 0.113
				elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
					arc_zoom = 0.0565
				elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
					arc_zoom = 0.02825
				elseif B738DR_efis_map_range_capt == 4 then	-- 80 NM
					arc_zoom = 0.014125
				end
				if arc_zoom == 0 then
					B738DR_green_arc_show = 0
				else
					arc_dist = arc_dist * arc_zoom
					if arc_dist < 0.005 or arc_dist > 1.0 then
						B738DR_green_arc_show = 0
					else
						B738DR_green_arc = arc_dist
						B738DR_green_arc_show = 1
					end
				end
			else
				B738DR_green_arc_show = 0
			end
		elseif ap_pitch_mode == 5 then		-- VNAV
			if simDR_autopilot_altitude_mode == 4 or simDR_autopilot_altitude_mode == 5 then	-- VS or LVL CHG
				arc_vvi = simDR_vvi_fpm_pilot
				if arc_vvi > 100 and simDR_ap_altitude_dial_ft > simDR_altitude_pilot then
					delta_alt = simDR_ap_altitude_dial_ft - simDR_altitude_pilot
				elseif arc_vvi < -100 and simDR_ap_altitude_dial_ft < simDR_altitude_pilot then
					delta_alt = simDR_altitude_pilot - simDR_ap_altitude_dial_ft
					arc_vvi = -arc_vvi
				else
					arc_vvi = 0
				end
				if arc_vvi ~= 0 then
					arc_time = delta_alt / (arc_vvi / 60)	-- secs
					arc_dist = simDR_ground_spd * arc_time * 0.00054	-- m to NM
					if B738DR_efis_map_range_capt == 0 then	-- 5 NM
						arc_zoom = 0.226
					elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
						arc_zoom = 0.113
					elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
						arc_zoom = 0.0565
					elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
						arc_zoom = 0.02825
					elseif B738DR_efis_map_range_capt == 4 then	-- 80 NM
						arc_zoom = 0.014125
					end
					if arc_zoom == 0 then
						B738DR_green_arc_show = 0
					else
						arc_dist = arc_dist * arc_zoom
						if arc_dist < 0.005 or arc_dist > 1.0 then
							B738DR_green_arc_show = 0
						else
							B738DR_green_arc = arc_dist
							B738DR_green_arc_show = 1
						end
					end
				else
					B738DR_green_arc_show = 0
				end
			else
				B738DR_green_arc_show = 0
			end
		else
			B738DR_green_arc_show = 0
		end
	end


end

function B738_vor_sel()

	local str_len = 0
	local vor_crs = 0
	local vor_bcrs = 0
	local vor_hdg = 0
	local vor_bearing = 0
	local vor_distance = 0
	local vor_bear_l = 0
	local vor_bear_r = 0
	local str_crs = ""
	local str_bcrs = ""
	local vor_angle = 0
	local efis_zoom = 0
	local out_of_range = 0
	local vor_x = 0
	local vor_y = 0
	local vor_quadr = 0
	local vor2_sel_disable = 0
	
	-- if simDR_autopilot_source ~= 2 then
		simDR_hsi_crs1 = simDR_crs1
	-- end
	-- if simDR_autopilot_fo_source ~= 2 then
		simDR_hsi_crs2 = simDR_crs2
	-- end
	
	if simDR_map_mode_is_HSI ~= 1 and B738DR_capt_map_mode ~= 3 then
		
		-- CAPTAIN VOR1
--		if simDR_vor1_capt == 2 and simDR_nav1_type == 4 then	-- VOR select
		if simDR_nav1_type == 4 then	-- VOR select
			if simDR_vor1_id == nil or simDR_nav1_dme == nil or simDR_nav1_has_dme == 0 then
				B738DR_vor1_show = 0
			else
				str_len = string.len(simDR_vor1_id)
				B738DR_vor1_sel_id = ""
				if str_len < 4 then
					B738DR_vor1_sel_id = " "
				end
				B738DR_vor1_sel_id = B738DR_vor1_sel_id .. simDR_vor1_id
				vor_crs = simDR_crs1
				vor_bcrs = (vor_crs + 180) % 360
				if vor_crs < 10 then
					if vor_crs < 0 then
						B738DR_vor1_sel_crs = "000"
					else
						B738DR_vor1_sel_crs = "00" .. string.format("%1d", vor_crs)
					end
				elseif vor_crs < 100 then
					B738DR_vor1_sel_crs = "0" .. string.format("%2d", vor_crs)
				else
					B738DR_vor1_sel_crs = string.format("%3d", vor_crs)
				end
				if vor_bcrs < 10 then
					if vor_bcrs < 0 then
						B738DR_vor1_sel_bcrs = "000"
					else
						B738DR_vor1_sel_bcrs = "00" .. string.format("%1d", vor_bcrs)
					end
				elseif vor_bcrs < 100 then
					B738DR_vor1_sel_bcrs = "0" .. string.format("%2d", vor_bcrs)
				else
					B738DR_vor1_sel_bcrs = string.format("%3d", vor_bcrs)
				end
				
				-- if simDR_efis_sub_mode < 2 then
					-- vor_hdg = simDR_ahars_mag_hdg	-- + 4.49		-- adjust
					-- if simDR_efis_map_mode == 0 then
						-- nav_disable = 1
					-- end
				-- elseif simDR_efis_sub_mode == 4 then
					-- vor_hdg = 0		--4.49
				-- else
					-- vor_hdg = simDR_mag_hdg 	-- + 4.49		-- adjust
				-- end
				vor_hdg = simDR_mag_hdg
				
				vor_bearing = simDR_nav1_bearing
				vor_distance = simDR_nav1_dme
				vor_bear_l = (vor_hdg + 270) % 360
				vor_bear_r = (vor_hdg + 90) % 360
				if vor_hdg < vor_bear_r then
					if vor_bearing >= vor_hdg and vor_bearing <= vor_bear_r then
						vor_quadr = 1
					end
				end
				if vor_hdg > vor_bear_l then
					if vor_bearing >= vor_bear_l and vor_bearing <= vor_hdg then
						vor_quadr = 2
					end
				end
				if vor_hdg < vor_bear_l then
					if vor_bearing >= vor_bear_l and vor_bearing <= 360 then
						vor_quadr = 3
					elseif vor_bearing >= 0 and vor_bearing <= vor_hdg then
						vor_quadr = 4
					end
				end
				if vor_hdg > vor_bear_r then
					if vor_bearing >= vor_hdg and vor_bearing <= 360 then
						vor_quadr = 5
					elseif vor_bearing >= 0 and vor_bearing <= vor_bear_r then
						vor_quadr = 6
					end
				end
				
				if vor_quadr == 1 then
					vor_angle = vor_bearing - vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 2 then
					vor_angle = vor_hdg - vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 3 then
					vor_angle = 360 - vor_bearing + vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 4 then
					vor_angle = vor_hdg - vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 5 then
					vor_angle = vor_bearing - vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 6 then
					vor_angle = 360 - vor_hdg + vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				else
					out_of_range = 1
				end
				if B738DR_efis_map_range_capt == 0 then	-- 5 NM
					efis_zoom = 2
				elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
					efis_zoom = 1
				elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
					efis_zoom = 0.5
				elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
					efis_zoom = 0.25
				elseif B738DR_efis_map_range_capt == 4 then	-- 80 NM
					efis_zoom = 0.125
				else
					out_of_range = 1
				end
				
				vor_x = vor_x * efis_zoom		-- zoom
				vor_y = vor_y * efis_zoom		-- zoom
				
				if vor_y > 7.5 or vor_y < 0 then
					out_of_range = 1
				end
				if vor_x < -6.0 or vor_x > 6.0 then
					out_of_range = 1
				end
				
				vor_hdg = (vor_crs - vor_hdg) % 360
				vor_hdg = (90 + vor_hdg) % 360
				vor_hdg = vor_hdg + simDR_mag_variation
				B738DR_vor1_sel_rotate = vor_hdg
				
				if out_of_range == 0 then
					B738DR_vor1_sel_x = vor_x
					B738DR_vor1_sel_y = vor_y
					B738DR_vor1_show = 1
					if simDR_vor1_capt == 2 then
						B738DR_vor1_line_show = 1
					else
						B738DR_vor1_line_show = 0
					end
				else
					B738DR_vor1_show = 0
				end
			end
		else
			B738DR_vor1_show = 0
		end
		
		-- CAPTAIN VOR2
		if simDR_vor2_id ~= nil then
			if B738DR_vor1_show == 1 and simDR_vor1_id == simDR_vor2_id then
				vor2_sel_disable = 1
			end
		end
--		if simDR_vor2_capt == 2 and simDR_nav2_type == 4 and vor2_sel_disable == 0 then	-- VOR select
		if simDR_nav2_type == 4 and vor2_sel_disable == 0 then	-- VOR select
			if simDR_vor2_id == nil or simDR_nav2_dme == nil or simDR_nav2_has_dme == 0 then
				B738DR_vor2_show = 0
			else
				str_len = string.len(simDR_vor2_id)
				B738DR_vor2_sel_id = ""
				if str_len < 4 then
					B738DR_vor2_sel_id = " "
				end
				B738DR_vor2_sel_id = B738DR_vor2_sel_id .. simDR_vor2_id
				vor_crs = simDR_crs2	--simDR_crs1
				vor_bcrs = (vor_crs + 180) % 360
				if vor_crs < 10 then
					if vor_crs < 0 then
						B738DR_vor2_sel_crs = "000"
					else
						B738DR_vor2_sel_crs = "00" .. string.format("%1d", vor_crs)
					end
				elseif vor_crs < 100 then
					B738DR_vor2_sel_crs = "0" .. string.format("%2d", vor_crs)
				else
					B738DR_vor2_sel_crs = string.format("%3d", vor_crs)
				end
				if vor_bcrs < 10 then
					if vor_bcrs < 0 then
						B738DR_vor2_sel_bcrs = "000"
					else
						B738DR_vor2_sel_bcrs = "00" .. string.format("%1d", vor_bcrs)
					end
				elseif vor_bcrs < 100 then
					B738DR_vor2_sel_bcrs = "0" .. string.format("%2d", vor_bcrs)
				else
					B738DR_vor2_sel_bcrs = string.format("%3d", vor_bcrs)
				end
				-- if simDR_efis_sub_mode < 2 then
					-- vor_hdg = simDR_ahars_mag_hdg	-- + 4.49		-- adjust
					-- if simDR_efis_map_mode == 0 then
						-- nav_disable = 1
					-- end
				-- elseif simDR_efis_sub_mode == 4 then
					-- vor_hdg = 0		--4.49
				-- else
					-- vor_hdg = simDR_mag_hdg 	-- + 4.49		-- adjust
				-- end
				vor_hdg = simDR_mag_hdg
				vor_bearing = simDR_nav2_bearing
				vor_distance = simDR_nav2_dme
				vor_bear_l = (vor_hdg + 270) % 360
				vor_bear_r = (vor_hdg + 90) % 360
				if vor_hdg < vor_bear_r then
					if vor_bearing >= vor_hdg and vor_bearing <= vor_bear_r then
						vor_quadr = 1
					end
				end
				if vor_hdg > vor_bear_l then
					if vor_bearing >= vor_bear_l and vor_bearing <= vor_hdg then
						vor_quadr = 2
					end
				end
				if vor_hdg < vor_bear_l then
					if vor_bearing >= vor_bear_l and vor_bearing <= 360 then
						vor_quadr = 3
					elseif vor_bearing >= 0 and vor_bearing <= vor_hdg then
						vor_quadr = 4
					end
				end
				if vor_hdg > vor_bear_r then
					if vor_bearing >= vor_hdg and vor_bearing <= 360 then
						vor_quadr = 5
					elseif vor_bearing >= 0 and vor_bearing <= vor_bear_r then
						vor_quadr = 6
					end
				end
				
				if vor_quadr == 1 then
					vor_angle = vor_bearing - vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 2 then
					vor_angle = vor_hdg - vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 3 then
					vor_angle = 360 - vor_bearing + vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 4 then
					vor_angle = vor_hdg - vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 5 then
					vor_angle = vor_bearing - vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 6 then
					vor_angle = 360 - vor_hdg + vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				else
					out_of_range = 1
				end
				if B738DR_efis_map_range_capt == 0 then	-- 5 NM
					efis_zoom = 2
				elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
					efis_zoom = 1
				elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
					efis_zoom = 0.5
				elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
					efis_zoom = 0.25
				elseif B738DR_efis_map_range_capt == 4 then	-- 80 NM
					efis_zoom = 0.125
				else
					out_of_range = 1
				end
				
				vor_x = vor_x * efis_zoom		-- zoom
				vor_y = vor_y * efis_zoom		-- zoom
				
				if vor_y > 7.5 or vor_y < 0 then
					out_of_range = 1
				end
				if vor_x < -6.0 or vor_x > 6.0 then
					out_of_range = 1
				end
				
				vor_hdg = (vor_crs - vor_hdg) % 360
				vor_hdg = (90 + vor_hdg) % 360
				vor_hdg = vor_hdg + simDR_mag_variation
				B738DR_vor2_sel_rotate = vor_hdg
				
				if out_of_range == 0 then
					B738DR_vor2_sel_x = vor_x
					B738DR_vor2_sel_y = vor_y
					B738DR_vor2_show = 1
					if simDR_vor2_capt == 2 then
						B738DR_vor2_line_show = 1
					else
						B738DR_vor2_line_show = 0
					end
				else
					B738DR_vor2_show = 0
				end
			end
		else
			B738DR_vor2_show = 0
		end
	end
	
	if simDR_map_mode_is_HSI ~= 1 and B738DR_fo_map_mode ~= 3 then
	
		-- FIRST OFFICER VOR1
		str_len = 0
		vor_crs = 0
		vor_bcrs = 0
		vor_hdg = 0
		vor_bearing = 0
		vor_distance = 0
		vor_bear_l = 0
		vor_bear_r = 0
		str_crs = ""
		str_bcrs = ""
		vor_angle = 0
		efis_zoom = 0
		out_of_range = 0
		vor_x = 0
		vor_y = 0
		vor_quadr = 0
		vor2_sel_disable = 0
--		if simDR_vor1_fo == 2 and simDR_nav1_type == 4 then	-- VOR select
		if simDR_nav1_type == 4 then	-- VOR select
			if simDR_vor1_id == nil or simDR_nav1_dme == nil or simDR_nav1_has_dme == 0 then
				B738DR_vor1_copilot_show = 0
			else
				str_len = string.len(simDR_vor1_id)
				B738DR_vor1_sel_id = ""
				if str_len < 4 then
					B738DR_vor1_sel_id = " "
				end
				B738DR_vor1_sel_id = B738DR_vor1_sel_id .. simDR_vor1_id
				vor_crs = simDR_crs1
				vor_bcrs = (vor_crs + 180) % 360
				if vor_crs < 10 then
					if vor_crs < 0 then
						B738DR_vor1_sel_crs = "000"
					else
						B738DR_vor1_sel_crs = "00" .. string.format("%1d", vor_crs)
					end
				elseif vor_crs < 100 then
					B738DR_vor1_sel_crs = "0" .. string.format("%2d", vor_crs)
				else
					B738DR_vor1_sel_crs = string.format("%3d", vor_crs)
				end
				if vor_bcrs < 10 then
					if vor_bcrs < 0 then
						B738DR_vor1_sel_bcrs = "000"
					else
						B738DR_vor1_sel_bcrs = "00" .. string.format("%1d", vor_bcrs)
					end
				elseif vor_bcrs < 100 then
					B738DR_vor1_sel_bcrs = "0" .. string.format("%2d", vor_bcrs)
				else
					B738DR_vor1_sel_bcrs = string.format("%3d", vor_bcrs)
				end
				vor_hdg = simDR_mag_hdg
				vor_bearing = simDR_nav1_bearing
				vor_distance = simDR_nav1_dme
				vor_bear_l = (vor_hdg + 270) % 360
				vor_bear_r = (vor_hdg + 90) % 360
				if vor_hdg < vor_bear_r then
					if vor_bearing >= vor_hdg and vor_bearing <= vor_bear_r then
						vor_quadr = 1
					end
				end
				if vor_hdg > vor_bear_l then
					if vor_bearing >= vor_bear_l and vor_bearing <= vor_hdg then
						vor_quadr = 2
					end
				end
				if vor_hdg < vor_bear_l then
					if vor_bearing >= vor_bear_l and vor_bearing <= 360 then
						vor_quadr = 3
					elseif vor_bearing >= 0 and vor_bearing <= vor_hdg then
						vor_quadr = 4
					end
				end
				if vor_hdg > vor_bear_r then
					if vor_bearing >= vor_hdg and vor_bearing <= 360 then
						vor_quadr = 5
					elseif vor_bearing >= 0 and vor_bearing <= vor_bear_r then
						vor_quadr = 6
					end
				end
				
				if vor_quadr == 1 then
					vor_angle = vor_bearing - vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 2 then
					vor_angle = vor_hdg - vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 3 then
					vor_angle = 360 - vor_bearing + vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 4 then
					vor_angle = vor_hdg - vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 5 then
					vor_angle = vor_bearing - vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 6 then
					vor_angle = 360 - vor_hdg + vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				else
					out_of_range = 1
				end
				if B738DR_efis_map_range_fo == 0 then	-- 5 NM
					efis_zoom = 2
				elseif B738DR_efis_map_range_fo == 1 then	-- 10 NM
					efis_zoom = 1
				elseif B738DR_efis_map_range_fo == 2 then	-- 20 NM
					efis_zoom = 0.5
				elseif B738DR_efis_map_range_fo == 3 then	-- 40 NM
					efis_zoom = 0.25
				elseif B738DR_efis_map_range_fo == 4 then	-- 80 NM
					efis_zoom = 0.125
				else
					out_of_range = 1
				end
				
				vor_x = vor_x * efis_zoom		-- zoom
				vor_y = vor_y * efis_zoom		-- zoom
				
				if vor_y > 7.5 or vor_y < 0 then
					out_of_range = 1
				end
				if vor_x < -6.0 or vor_x > 6.0 then
					out_of_range = 1
				end
				
				vor_hdg = (vor_crs - vor_hdg) % 360
				vor_hdg = (90 + vor_hdg) % 360
				vor_hdg = vor_hdg + simDR_mag_variation
				B738DR_vor1_sel_rotate = vor_hdg
				
				if out_of_range == 0 then
					B738DR_vor1_sel_x = vor_x
					B738DR_vor1_sel_y = vor_y
					B738DR_vor1_copilot_show = 1
					if simDR_vor1_fo == 2 then
						B738DR_vor1_line_copilot_show = 1
					else
						B738DR_vor1_line_copilot_show = 0
					end
				else
					B738DR_vor1_copilot_show = 0
				end
			end
		else
			B738DR_vor1_copilot_show = 0
		end
		
		-- FIRST OFFICER VOR2
		if simDR_vor2_id ~= nil then
			if B738DR_vor1_copilot_show == 1 and simDR_vor1_id == simDR_vor2_id then
				vor2_sel_disable = 1
			end
		end
--		if simDR_vor2_fo == 2 and simDR_nav2_type == 4 and vor2_sel_disable == 0 then	-- VOR select
		if simDR_nav2_type == 4 and vor2_sel_disable == 0 then	-- VOR select
			if simDR_vor2_id == nil or simDR_nav2_dme == nil or simDR_nav2_has_dme == 0 then
				B738DR_vor2_copilot_show = 0
			else
				str_len = string.len(simDR_vor2_id)
				B738DR_vor2_sel_id = ""
				if str_len < 4 then
					B738DR_vor2_sel_id = " "
				end
				B738DR_vor2_sel_id = B738DR_vor2_sel_id .. simDR_vor2_id
				vor_crs = simDR_crs2	--simDR_crs1
				vor_bcrs = (vor_crs + 180) % 360
				if vor_crs < 10 then
					if vor_crs < 0 then
						B738DR_vor2_sel_crs = "000"
					else
						B738DR_vor2_sel_crs = "00" .. string.format("%1d", vor_crs)
					end
				elseif vor_crs < 100 then
					B738DR_vor2_sel_crs = "0" .. string.format("%2d", vor_crs)
				else
					B738DR_vor2_sel_crs = string.format("%3d", vor_crs)
				end
				if vor_bcrs < 10 then
					if vor_bcrs < 0 then
						B738DR_vor2_sel_bcrs = "000"
					else
						B738DR_vor2_sel_bcrs = "00" .. string.format("%1d", vor_bcrs)
					end
				elseif vor_bcrs < 100 then
					B738DR_vor2_sel_bcrs = "0" .. string.format("%2d", vor_bcrs)
				else
					B738DR_vor2_sel_bcrs = string.format("%3d", vor_bcrs)
				end
				vor_hdg = simDR_mag_hdg
				vor_bearing = simDR_nav2_bearing
				vor_distance = simDR_nav2_dme
				vor_bear_l = (vor_hdg + 270) % 360
				vor_bear_r = (vor_hdg + 90) % 360
				if vor_hdg < vor_bear_r then
					if vor_bearing >= vor_hdg and vor_bearing <= vor_bear_r then
						vor_quadr = 1
					end
				end
				if vor_hdg > vor_bear_l then
					if vor_bearing >= vor_bear_l and vor_bearing <= vor_hdg then
						vor_quadr = 2
					end
				end
				if vor_hdg < vor_bear_l then
					if vor_bearing >= vor_bear_l and vor_bearing <= 360 then
						vor_quadr = 3
					elseif vor_bearing >= 0 and vor_bearing <= vor_hdg then
						vor_quadr = 4
					end
				end
				if vor_hdg > vor_bear_r then
					if vor_bearing >= vor_hdg and vor_bearing <= 360 then
						vor_quadr = 5
					elseif vor_bearing >= 0 and vor_bearing <= vor_bear_r then
						vor_quadr = 6
					end
				end
				
				if vor_quadr == 1 then
					vor_angle = vor_bearing - vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 2 then
					vor_angle = vor_hdg - vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 3 then
					vor_angle = 360 - vor_bearing + vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 4 then
					vor_angle = vor_hdg - vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = -vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 5 then
					vor_angle = vor_bearing - vor_hdg
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				elseif vor_quadr == 6 then
					vor_angle = 360 - vor_hdg + vor_bearing
					vor_angle = math.rad(vor_angle)
					vor_y = vor_distance * math.cos(vor_angle)
					vor_x = vor_distance * math.sin(vor_angle)
				else
					out_of_range = 1
				end
				if B738DR_efis_map_range_fo == 0 then	-- 5 NM
					efis_zoom = 2
				elseif B738DR_efis_map_range_fo == 1 then	-- 10 NM
					efis_zoom = 1
				elseif B738DR_efis_map_range_fo == 2 then	-- 20 NM
					efis_zoom = 0.5
				elseif B738DR_efis_map_range_fo == 3 then	-- 40 NM
					efis_zoom = 0.25
				elseif B738DR_efis_map_range_fo == 4 then	-- 80 NM
					efis_zoom = 0.125
				else
					out_of_range = 1
				end
				
				vor_x = vor_x * efis_zoom		-- zoom
				vor_y = vor_y * efis_zoom		-- zoom
				
				if vor_y > 7.5 or vor_y < 0 then
					out_of_range = 1
				end
				if vor_x < -6.0 or vor_x > 6.0 then
					out_of_range = 1
				end
				
				vor_hdg = (vor_crs - vor_hdg) % 360
				vor_hdg = (90 + vor_hdg) % 360
				vor_hdg = vor_hdg + simDR_mag_variation
				B738DR_vor2_sel_rotate = vor_hdg
				
				if out_of_range == 0 then
					B738DR_vor2_sel_x = vor_x
					B738DR_vor2_sel_y = vor_y
					B738DR_vor2_copilot_show = 1
					if simDR_vor2_fo == 2 then
						B738DR_vor2_line_copilot_show = 1
					else
						B738DR_vor2_line_copilot_show = 0
					end
				else
					B738DR_vor2_copilot_show = 0
				end
			end
		else
			B738DR_vor2_copilot_show = 0
		end
	end

end


-- Baro altimeter
function B738_efis_baro()

	-- Captain
	if B738DR_baro_set_std_pilot == 1 then	-- set STD
		if baro_sel_old ~= B738DR_baro_sel_in_hg_pilot then
			B738DR_baro_sel_pilot_show = 1
		end
		if B738DR_flight_phase > 3 then
			if simDR_altitude_pilot < B738DR_trans_lvl then
				B738DR_baro_std_box_pilot_show = 1
				B738DR_baro_box_pilot_show = 0
			else
				B738DR_baro_std_box_pilot_show = 0
				B738DR_baro_box_pilot_show = 0
			end
		else
			B738DR_baro_std_box_pilot_show = 0
			B738DR_baro_box_pilot_show = 0
		end
	else
		simDR_barometer_setting_capt = B738DR_baro_sel_in_hg_pilot
		if B738DR_flight_phase < 4 then
			if simDR_altitude_pilot > B738DR_trans_alt 
			and simDR_barometer_setting_capt ~= 29.92 then
				B738DR_baro_box_pilot_show = 1
				B738DR_baro_std_box_pilot_show = 0
			else
				B738DR_baro_box_pilot_show = 0
				B738DR_baro_std_box_pilot_show = 0
			end
		else
			B738DR_baro_box_pilot_show = 0
			B738DR_baro_std_box_pilot_show = 0
		end
	end

	-- First Officer
	if B738DR_baro_set_std_copilot == 1 then	-- set STD
		if baro_sel_co_old ~= B738DR_baro_sel_in_hg_copilot then
			B738DR_baro_sel_copilot_show = 1
		end
		if B738DR_flight_phase > 3 then
			if simDR_altitude_copilot < B738DR_trans_lvl then
				B738DR_baro_std_box_copilot_show = 1
				B738DR_baro_box_copilot_show = 0
			else
				B738DR_baro_std_box_copilot_show = 0
				B738DR_baro_box_copilot_show = 0
			end
		else
			B738DR_baro_std_box_copilot_show = 0
			B738DR_baro_box_copilot_show = 0
		end
	else
		simDR_barometer_setting_fo = B738DR_baro_sel_in_hg_copilot
		if B738DR_flight_phase < 4 then
			if simDR_altitude_copilot > B738DR_trans_alt 
			and simDR_barometer_setting_fo ~= 29.92 then
				B738DR_baro_box_copilot_show = 1
				B738DR_baro_std_box_copilot_show = 0
			else
				B738DR_baro_box_copilot_show = 0
				B738DR_baro_std_box_copilot_show = 0
			end
		else
			B738DR_baro_box_copilot_show = 0
			B738DR_baro_std_box_copilot_show = 0
		end
	end

end

-- Speed ratio, Vertical speed ratio
function speed_ratio_timer()

	local airspeed = simDR_airspeed_pilot
	B738DR_speed_ratio = airspeed - airspeed_pilot_old
	airspeed_pilot_old = airspeed
	
	local vert_speed = simDR_vvi_fpm_pilot
	B738DR_v_speed_ratio = vert_speed - v_speed_pilot_old
	v_speed_pilot_old = vert_speed
	
	local vdot = 0
	if simDR_vdot_nav1_pilot == nil then
		B738DR_vdot_ratio = 999
	else
		vdot = simDR_vdot_nav1_pilot
		B738DR_vdot_ratio = vdot_ratio_old - vdot
		vdot_ratio_old = vdot
	end
end

function B738_radio_height()
	
	local height = 0
	
	-- pilot
	height = simDR_radio_height_pilot_ft - 4
	if height < 100 then
		B738DR_agl_pilot = height + 4
	elseif height < 500 then
		B738DR_agl_pilot = roundDownToIncrement(height, 10) + 4
	else
		B738DR_agl_pilot = roundDownToIncrement(height, 20) + 4
	end
	
	-- copilot
	height = simDR_radio_height_copilot_ft - 4
	if height < 100 then
		B738DR_agl_copilot = height + 4
	elseif height < 500 then
		B738DR_agl_copilot = roundDownToIncrement(height, 10) + 4
	else
		B738DR_agl_copilot = roundDownToIncrement(height, 20) + 4
	end
end

function dh_min_off_pilot()
	dh_min_enable_pilot = 1
end

function dh_min_off_copilot()
	dh_min_enable_copilot = 1
end


function B738_baro_radio()
	
	local alt_dh = 0
	if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 or simDR_on_ground_2 == 1 then
		dh_min_block_pilot = 1
		dh_min_block_copilot = 1
	end
	-- captain
	if B738DR_minim_capt == 0 then	--radio DH
		simDR_dh_pilot = B738DR_dh_pilot
		if simDR_radio_height_pilot_ft < B738DR_dh_pilot and simDR_radio_height_pilot_ft > 0 then
			dh_minimum_pilot = 1
		end
		alt_dh = B738DR_dh_pilot + 75
		if simDR_radio_height_pilot_ft > alt_dh then
			dh_minimum_pilot = 0
			dh_min_block_pilot = 0
		end
		if B738DR_dh_pilot == 0 then
			dh_minimum_pilot = 0
		end
	else	-- baro DH
		if baro_dh_pilot > 0 then
			if simDR_altitude_pilot < baro_dh_pilot and baro_dh_pilot_disable == 0 then
				simDR_dh_pilot = simDR_radio_height_pilot_ft + 5
				baro_dh_pilot_disable = 1
				dh_minimum_pilot = 1
			end
			alt_dh = simDR_radio_height_pilot_ft - 5
			if simDR_dh_pilot < alt_dh then
				simDR_dh_pilot = 0
			end
			alt_dh = baro_dh_pilot + 75
			if simDR_altitude_pilot > alt_dh and baro_dh_pilot_disable == 1 then
				baro_dh_pilot_disable = 0
				simDR_dh_pilot = 0
				dh_minimum_pilot = 0
				dh_min_block_pilot = 0
			end
		else
			dh_minimum_pilot = 0
		end
	end
	if dh_minimum_pilot == 0 or dh_min_block_pilot == 1 then
		B738DR_dh_minimum_pilot = 0		-- green
		dh_min_enable_pilot = 0
		if is_timer_scheduled(dh_min_off_pilot) == true then
			stop_timer(dh_min_off_pilot)
		end
	else
		if dh_min_enable_pilot == 0 then
			if DRblink == 0 then
				B738DR_dh_minimum_pilot = 1		-- amber
			else
				B738DR_dh_minimum_pilot = 2		-- off
			end
			if is_timer_scheduled(dh_min_off_pilot) == false then
				run_after_time(dh_min_off_pilot, 3)	-- 3 seconds
			end
		else
			B738DR_dh_minimum_pilot = 1		-- amber
		end
	end
	
	-- first officer
	if B738DR_minim_fo == 0 then	--radio DH
		simDR_dh_copilot = B738DR_dh_copilot
		if simDR_radio_height_copilot_ft < B738DR_dh_copilot and simDR_radio_height_copilot_ft > 0 then
			dh_minimum_copilot = 1
		end
		alt_dh = B738DR_dh_copilot + 75
		if simDR_radio_height_copilot_ft > alt_dh then
			dh_minimum_copilot = 0
			dh_min_block_copilot = 0
		end
		if B738DR_dh_copilot == 0 then
			dh_minimum_copilot = 0
		end
	else	-- baro DH
		if baro_dh_copilot > 0 then
			if simDR_altitude_copilot < baro_dh_copilot and baro_dh_copilot_disable == 0 then
				simDR_dh_copilot = simDR_radio_height_copilot_ft + 5
				baro_dh_copilot_disable = 1
				dh_minimum_copilot = 1
			end
			alt_dh = simDR_radio_height_copilot_ft - 5
			if simDR_dh_copilot < alt_dh then
				simDR_dh_copilot = 0
			end
			alt_dh = baro_dh_copilot + 75
			if simDR_altitude_copilot > alt_dh and baro_dh_copilot_disable == 1 then
				baro_dh_copilot_disable = 0
				simDR_dh_copilot = 0
				dh_minimum_copilot = 0
				dh_min_block_copilot = 0
			end
		else
			dh_minimum_copilot = 0
		end
	end
	-- if dh_minimum_copilot == 0 then
		-- B738DR_dh_minimum_copilot = 0
	-- else
		-- B738DR_dh_minimum_copilot = 1
	-- end
	if dh_minimum_copilot == 0 or dh_min_block_copilot == 1 then
		B738DR_dh_minimum_copilot = 0		-- green
		dh_min_enable_copilot = 0
		if is_timer_scheduled(dh_min_off_copilot) == true then
			stop_timer(dh_min_off_copilot)
		end
	else
		if dh_min_enable_copilot == 0 then
			if DRblink == 0 then
				B738DR_dh_minimum_copilot = 1		-- amber
			else
				B738DR_dh_minimum_copilot = 2		-- off
			end
			if is_timer_scheduled(dh_min_off_copilot) == false then
				run_after_time(dh_min_off_copilot, 3)	-- 3 seconds
			end
		else
			B738DR_dh_minimum_copilot = 1		-- amber
		end
	end
	
end

-- ILS info on PFD
function ils_radio_pfd()

	if B738DR_autopilot_vhf_source_pos == -1 then
		B738DR_pfd_nav1_pilot = 1
		B738DR_pfd_nav2_pilot = 0
		B738DR_pfd_nav1_copilot = 1
		B738DR_pfd_nav2_copilot = 0
	elseif B738DR_autopilot_vhf_source_pos == 0 then
		B738DR_pfd_nav1_pilot = 1
		B738DR_pfd_nav2_pilot = 0
		B738DR_pfd_nav1_copilot = 0
		B738DR_pfd_nav2_copilot = 1
	elseif B738DR_autopilot_vhf_source_pos == 1 then
		B738DR_pfd_nav1_pilot = 0
		B738DR_pfd_nav2_pilot = 1
		B738DR_pfd_nav1_copilot = 0
		B738DR_pfd_nav2_copilot = 1
	end

end

function B738_flight_director()
	
	local fdir_temp = 0
	
	fdir_temp = simDR_fdir_pitch - simDR_ahars_pitch_deg_pilot
	fdir_temp = math.max(fdir_temp, -15)
	fdir_temp = math.min(fdir_temp, 15)
	B738DR_fdir_pitch_pilot = fdir_temp

	fdir_temp = simDR_fdir_pitch - simDR_ahars_pitch_deg_copilot
	fdir_temp = math.max(fdir_temp, -15)
	fdir_temp = math.min(fdir_temp, 15)
	B738DR_fdir_pitch_copilot = fdir_temp
	
end

function B738_hyd_sys()
	
	local lost_hyd = 0
	
	-- CMD A and CMD B (autoland)
	if B738DR_hyd_A_status == 0 or B738DR_hyd_B_status == 0 then
		if autopilot_cmd_a_status == 1 and autopilot_cmd_b_status == 1 then
			-- disengage A/P and autoland
				simDR_flight_dir_mode = 1
			-- F/D on
				ap_roll_mode = 0
				ap_pitch_mode = 0
				ap_roll_mode_eng = 0
				ap_pitch_mode_eng = 0
				autopilot_cmd_a_status = 0
				autopilot_cmd_b_status = 0
				B738DR_autoland_status = 0
				B738DR_flare_status = 0
				B738DR_retard_status = 0
				simDR_ap_vvi_dial = 0
				at_mode = 0
				at_mode_eng = 0
				vorloc_only = 0
				ils_test_enable = 0
				ils_test_on = 0
		end
	end
	-- CMD A
	if B738DR_hyd_A_status == 0 then
		if autopilot_cmd_a_status == 1 then
			-- disengaged A/P (A)
			simDR_flight_dir_mode = 1
				-- F/D on only
			autopilot_cws_a_status = 0
			autopilot_cmd_a_status = 0
			B738DR_single_ch_status = 0
			ap_roll_mode = 0
			ap_pitch_mode = 0
		end
	end
	-- CMD B
	if B738DR_hyd_B_status == 0 then
		if autopilot_cmd_b_status == 1 then
			-- disengaged A/P (B)
			simDR_flight_dir_mode = 1
				-- F/D on only
			autopilot_cws_b_status = 0
			autopilot_cmd_b_status = 0
			B738DR_single_ch_status = 0
			ap_roll_mode = 0
			ap_pitch_mode = 0
		end
	end

end


--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

simDR_vor1_capt = 1
simDR_vor2_capt	= 1
simDR_vor1_fo	= 1
simDR_vor2_fo	= 1

B738DR_efis_vor1_capt_pos = 0
B738DR_efis_vor2_capt_pos = 0
B738DR_efis_vor1_fo_pos = 0
B738DR_efis_vor2_fo_pos = 0
B738DR_capt_map_mode = 2
B738DR_fo_map_mode = 2

simDR_efis_ndb	= 0
simDR_bank_angle = 4
simDR_autopilot_source = 0
simDR_autopilot_fo_source = 1
simDR_autopilot_side = 0
B738DR_autopilot_bank_angle_pos = 2

autopilot_cmd_a_status = 0
autopilot_cmd_b_status = 0
autopilot_cws_a_status = 0
autopilot_cws_b_status = 0
B738DR_autopilot_hdg_sel_status = 0
B738DR_autopilot_vorloc_status = 0
B738DR_autopilot_app_status = 0
B738DR_autopilot_lnav_status = 0
B738DR_autopilot_vs_status = 0
B738DR_autopilot_lvl_chg_status = 0
B738DR_autopilot_alt_hld_status = 0
B738DR_autopilot_vnav_status = 0
B738DR_autopilot_fd_pos = 0
B738DR_autopilot_fd_fo_pos = 0
B738DR_autopilot_n1_pfd = 0
B738DR_autopilot_n1_status = 0
B738DR_autopilot_vnav_alt_pfd = 0
B738DR_autopilot_vnav_pth_pfd = 0
B738DR_autopilot_vnav_spd_pfd = 0
B738DR_autopilot_fmc_spd_pfd = 0
B738DR_autopilot_vvi_status_pfd = 0
ap_roll_mode = 0
ap_pitch_mode = 0
ap_roll_mode_eng = 0
ap_pitch_mode_eng = 0
simDR_joy_pitch_override = 0
B738DR_autopilot_autothr_arm_pos = 0
B738DR_autopilot_autothrottle_status = 0

simDR_throttle_override = 1
eng1_N1_thrust_cur = 0
eng2_N1_thrust_cur = 0
------simDR_throttle_override = 0

B738DR_autoland_status = 0
B738DR_flare_status = 0
B738DR_retard_status = 0
B738DR_single_ch_status = 0
vorloc_only = 0
B738DR_ils_pointer_disable = 0
aircraft_was_on_air = 0
B738DR_fmc_mode = 0
B738DR_fmc_descent_now = 0
B738DR_lowerDU_page = 0
DRblink = 0
B738DR_mach_disable = 0
B738DR_kts_disable = 0
B738DR_was_on_cruise = 0
mem_airspeed_dial = 100
mem_speed_mode = 0
at_mode = 0
at_mode_eng = 0
ap_pitch_mode_old = 0
ap_roll_mode_old = 0
B738DR_autopilot_to_ga_pfd = 0
B738DR_autopilot_thr_hld_pfd = 0
B738DR_autopilot_ga_pfd = 0
B738DR_autopilot_alt_acq_pfd = 0
takeoff_n1 = 0
ap_goaround = 0
fd_goaround = 0
cmd_first = 0
ils_test_enable = 0
ils_test_on = 0
ils_test_ok = 0
ap_app_block_800 = 0
B738DR_lowerDU_page = 1
vnav_descent = 0
vnav_active = 0
--vnav_active2 = 0
vnav_cruise = 0
--vnav_speed_dial = 200
--vnav_speed_dial2 = 0
--vnav_block_thrust = 0
lift_off_150 = 0
on_ground_30 = 1
ap_goaround_block = 0
B738DR_pfd_vorloc_lnav = 0
ias_disagree = 0
alt_disagree = 0

B738DR_eng1_N1_bug = 0.984
B738DR_eng2_N1_bug = 0.984
eng1_N1_man = 0.984
eng2_N1_man = 0.984

at_throttle_hold = 0
nav_id_old = "*"

B738DR_mcp_alt_dial = simDR_ap_altitude_dial_ft
if B738DR_mcp_alt_dial < 0 then
	B738DR_mcp_alt_dial = 0
end
simDR_ap_vvi_dial = 0

--- FLARE CONSTANTS ---
B738DR_thrust_vvi_1 = -200
B738DR_thrust_vvi_2 = -520
B738DR_thrust_ratio_1 = 0.06
B738DR_thrust_ratio_2 = 0.03	--0.003
B738DR_flare_ratio = 2.0	--0.6	--1.2
B738DR_pitch_ratio = 2.2	--1.6	--1.8	--2.1	--2.2	--2.22
B738DR_pitch_offset = 0.85

B738DR_baro_sel_in_hg_pilot = 29.92	--simDR_barometer_setting_capt
B738DR_baro_sel_in_hg_copilot = 29.92	--simDR_barometer_setting_fo

B738DR_EFIS_TCAS_on = 1
simDR_EFIS_TCAS = 0
B738DR_ap_spd_interv_status = 0
lnav_app = 0

simDR_fdir_pitch_ovr = 1
simDR_fdir_pitch = 0
simDR_fdir_pitch_ovr = 0

vnav_vs = 0
vnav_alt_hld = 0
altitude_dial_ft_old = 0
bellow_400ft = 0

if is_timer_scheduled(speed_ratio_timer) == false then
	run_at_interval(speed_ratio_timer, 1)
end


B738DR_pfd_nav1_pilot = 0
B738DR_pfd_nav2_pilot = 0
B738DR_pfd_nav1_copilot = 0
B738DR_pfd_nav2_copilot = 0

B738DR_fms_descent_now = 0

reverse_max_enable = 0
reverse_max_on = 0

radio_dh_pilot = 0
baro_dh_pilot = 0
baro_dh_pilot_disable = 0
radio_dh_copilot = 0
baro_dh_copilot = 0
baro_dh_copilot_disable = 0

blink_rec_cmd_status1 = 0
blink_rec_cmd_status2 = 0
blink_rec_sch_status = 0
blink_rec_alt_alert_status = 0
cmd_old1 = 0
cmd_old2 = 0
single_ch_status_old = 0
vnav_descent_disable = 0
dh_minimum_pilot = 0
dh_minimum_copilot = 0
dh_min_block_pilot = 0
dh_min_block_copilot = 0

B738DR_efis_vor_on = 0
B738DR_efis_apt_on = 0
B738DR_efis_fix_on = 0
B738DR_efis_wxr_capt = 0
simDR_efis_vor_on = 0
simDR_efis_apt_on = 0
simDR_efis_fix_on = 0
simDR_efis_wxr_on = 0
simDR_efis_sub_mode = 2

B738DR_efis_data_capt_status = 0
B738DR_efis_data_fo_status = 0

B738DR_efis_map_range_capt = 3
B738DR_efis_map_range_fo = 3

vnav_init = 0
vnav_init2 = 0
vs_first = 0
vnav_alt_hold = 0
vnav_alt_hold_act = 0
vnav_engaged = 0
lnav_engaged = 0
thr1_anim = 0
thr2_anim = 0

ap_on = 0
ap_on_first = 0
at_on_first = 0
cws_on = 0
cws_on_first = 0
ap_disco_first = 0
ap_dis_time = 0
at_dis_time = 0

roll_mode_old = 0
pitch_mode_old = 0
at_on_old = 0
vnav_desc_spd = 0
ap_disco_do = 0
vnav_speed_trg_old = 0

fac_engaged = 0
rest_wpt_alt_idx_old = 0

simDR_crs1 = math.floor(simDR_crs1 + 0.5)
simDR_crs1_nav2 = simDR_crs1
B738DR_course_copilot = simDR_crs1
simDR_crs2 = math.floor(simDR_crs2 + 0.5)
simDR_crs12_nav2 = simDR_crs2
B738DR_course_copilot = simDR_crs2
B738DR_mcp_hdg_dial = simDR_ap_capt_heading


dh_timer = 0
dh_timer2 = 0

axis_throttle_old = 0
axis_throttle1_old = 0
axis_throttle2_old = 0
lock_throttle = 0
ap_disco2 = 0

end

--function flight_crash() end

function before_physics()
	
	B738_nav_source_swap()
	--autopilot_system_lights()
	autopilot_system_lights2()
	B738_app_vnav()

end

function after_physics()
	alt_updn_timer()
	crs1_updn_timer()
	crs2_updn_timer()
	baro_pilot_updn_timer()
	baro_copilot_updn_timer()
	B738_efis_baro()
	B738_ap_logic()
	B738_at_logic()
	B738_ap_takeoff()
	B738_ap_goaround()
	B738_ap_autoland()
	B738_ap_system()
	--B738_lnav()
	B738_lnav2()
	B738_vnav6()
	--B738_rnav()
	B738_fac()
	B738_gp()
	B738_lnav_vnav()
	B738_loc_vnav()
	B738_lvl_chg()
	B738_vs()

	B738_alt_acq()
	B738_alt_hld()
	B738_app()
	--B738_PFD_flash()
	B738_PFD_flash2()
--	B738_kts_mach()
	B738_bellow_400ft()
	B738_ap_at_disconnect()
	B738_n1()
--	B738_bank_angle()
	B738_lift_off()
	B738_on_ground()
	B738_goaround_block()
	B738_fd_show()
	B738_ias_alt_disagree()
	B738_vnav_active = vnav_active
	B738_eng_n1_set()
	B738_N1_thrust_manage()
	B738_draw_arc()
	B738_radio_height()
	B738_baro_radio()
	ils_radio_pfd()
	B738_vor_sel()
	B738_flight_director()
	B738_hyd_sys()
	at_on_old = B738DR_autopilot_autothr_arm_pos
	if B738DR_capt_map_mode < 2 then
		B738DR_mcp_hdg_dial_nd = B738DR_mcp_hdg_dial - simDR_ahars_mag_hdg
		if simDR_efis_map_mode == 0 then
			B738DR_mcp_hdg_dial_nd_show = 0
		else
			B738DR_mcp_hdg_dial_nd_show = 1
		end
	elseif B738DR_capt_map_mode == 2 then
		B738DR_mcp_hdg_dial_nd = B738DR_mcp_hdg_dial - simDR_mag_hdg
		B738DR_mcp_hdg_dial_nd_show = 1
	else
		B738DR_mcp_hdg_dial_nd_show = 0
	end
	
	-- ND
	if simDR_efis_map_mode == 1 then
		if B738DR_capt_map_mode <= 2 then
			B738DR_hdg_mag_nd_show = 1
			if B738DR_capt_map_mode == 2 then
				-- MAP mode
				B738DR_hdg_mag_nd = -simDR_mag_hdg
			else
				-- APP, VOR mode
				B738DR_hdg_mag_nd = -simDR_ahars_mag_hdg
			end
		else
			-- PLN mode
			B738DR_hdg_mag_nd_show = 0
		end
	else
		B738DR_hdg_mag_nd_show = 0
	end
	
	--B738DR_mcp_hdg_dial_nd = B738DR_test_test

 end

--function after_replay() end

--simDR_mag_hdg


--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



