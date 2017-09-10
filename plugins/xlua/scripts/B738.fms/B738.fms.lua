--[[
*****************************************************************************************
* Program Script Name	:	B738.trim
* Author Name			:	Jim Gregory
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2016-04-26	0.01a				Start of Dev
*
*
*
*
*****************************************************************************************
*        COPYRIGHT � 2016 JIM GREGORY / LAMINAR RESEARCH - ALL RIGHTS RESERVED
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
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--

vnav_vvi = 
	{
	[3000] = 4000, [4000] = 3850, [5000] = 3750, [6000] = 3700, [7000] = 3650, [8000] = 3600, [9000] = 3500, [10000] = 3400,
	[11000] = 3300, [12000] = 3250, [13000] = 3100, [14000] = 3050, [15000] = 3150, [16000] = 3050, [17000] = 2950, [18000] = 2850, [19000] = 2750, [20000] = 2650,
	[21000] = 2550, [22000] = 2500, [23000] = 2400, [24000] = 2200, [25000] = 2150, [26000] = 2050, [27000] = 2750, [28000] = 2450, [29000] = 2200, [30000] = 2050,
	[31000] = 1850, [32000] = 1700, [33000] = 1600, [34000] = 1450, [35000] = 1350, [36000] = 1200, [37000] = 1000, [38000] =  850, [39000] =  650, [40000] =  500,
	[41000] = 350
	}

-- vnav_vvi = 
	-- {
	-- [3000] = 4000, [4000] = 3850, [5000] = 3650, [6000] = 3450, [7000] = 3550, [8000] = 3300, [9000] = 3250, [10000] = 3150,
	-- [11000] = 3200, [12000] = 3250, [13000] = 3100, [14000] = 3050, [15000] = 3150, [16000] = 3250, [17000] = 3300, [18000] = 3100, [19000] = 2900, [20000] = 2800,
	-- [21000] = 2700, [22000] = 2550, [23000] = 2400, [24000] = 2250, [25000] = 2100, [26000] = 2000, [27000] = 2500, [28000] = 2600, [29000] = 2200, [30000] = 2950,
	-- [31000] = 1850, [32000] = 1750, [33000] = 1550, [34000] = 1500, [35000] = 1300, [36000] = 1200, [37000] =  900, [38000] =  850, [39000] =  700, [40000] =  500,
	-- [41000] = 350
	-- }

MAX_NUM_SCRATCH = 24

-- MESSAGES --
INVALID_INPUT 				= ">INVALID ENTRY"
ENTER_IRS_POS 				= "ENTER IRS POSITION"
ENTER_IRS_HDG 				= "ENTER IRS HEADING"
USING_RSV_FUEL 				= "USING RSV FUEL"		--if the estimate is less than fuel reserve
INSUFICIENT_FUEL 			= "INSUFICIENT FUEL" --if predicted fuel at destin will be 2000 lb or less
RESET_MCP_ALT 				= "RESET MCP ALT"	-- during VNAV before 5 NM of TOD without selecting lower alt
VERIFY_TO_SPEEDS 			= "VERIFY TAKEOFF SPEEDS"
IRS_MOTION 					= "IRS MOTION"	-- if IRS restart align
GPS_L_INVALID 				= "GPS-L INVALID"	-- if GPS-L fail
GPS_R_INVALID 				= "GPS-R INVALID"	-- if GPS-R fail
GPS_LR_INVALID 				= "GPS-L-R INVALID"	-- if GPS-L-R fail
TO_SPEEDS_DELETED 			= "TAKEOFF SPEEDS DELETED"
DRAG_REQUIRED 				= "DRAG REQUIRED"	-- if airspeed > 10 kts above FMC target
NOT_IN_DATABASE 			= "NOT IN DATABASE"
NAV_DATA_OF_DATE 			= "NAV DATA OUT OF DATE"
UNABLE_CRUISE_ALT 			= "UNABLE CRZ ALT"
CONFIG_SAVED 				= "CONFIG SAVED"
CHECK_ALT_TGT 				= "CHECK ALT TGT"
TAI_ON_ABOVE_10C 			= "TAI ON ABOVE 10`C"	-- TAI operated above temp 10 C
DISCON 						= "DISCONTINUITY"
ABOVE_MAX_CERT_ALT 			= "ABOVE MAX CERT ALT"
APPRCH_VREF_NOT_SELECTED 	= "APPRCH VREF NOT SELECTED"
LNAV_DISCON 				= "LNAV DISCONNECT"
END_OF_ROUTE 				= "END OF ROUTE"
UNABLE_NEXT_ALTITUDE 		= "UNABLE NEXT ALTITUDE"
ALT_CONSTRAINT 				= "ALT CONSTRAINT "

TAXI_SPEED = 30

CL_THRSHLD = 0.18

--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--

xxx_str = ""
xxx = 0

--scratch = {}

-- for i = 0, MAX_NUM_SCRATCH - 1 do scratch[i] = 255 end

version = ""
fmod_version = "NOT FOUND"
file_navdata = 0

fmc_enable = 0
reset_fmc = 0

clr_repeat = 0
clr_repeat_time = 0

scratch_error = 0
--decode_value = 0
decode_value_mach = 0
decode_value2 = 0
--index_pos = 0
i = 0
delete_active = 0
FMS_page = 0

input_1L = 0
input_2L = 0
input_3L = 0
input_4L = 0
input_5L = 0
input_6L = 0

input_1R = 0
input_2R = 0
input_3R = 0
input_4R = 0
input_5R = 0
input_6R = 0

blank_data = 0

line0_l = ""
line1_l = ""
line2_l = ""
line3_l = ""
line4_l = ""
line5_l = ""
line6_l = ""
line0_s = ""
line1_s = ""
line2_s = ""
line3_s = ""
line4_s = ""
line5_s = ""
line6_s = ""
line1_x = ""
line2_x = ""
line3_x = ""
line4_x = ""
line5_x = ""
line6_x = ""
line0_inv = ""
line1_inv = ""
line2_inv = ""
line3_inv = ""
line4_inv = ""
line5_inv = ""
line6_inv = ""
line0_m = ""
line1_m = ""
line2_m = ""
line3_m = ""
line4_m = ""
line5_m = ""
line6_m = ""
line0_g = ""
line1_g = ""
line2_g = ""
line3_g = ""
line4_g = ""
line5_g = ""
line6_g = ""

max_page = 0
act_page = 0
act_page_old = 0
page_clear = 0

page_menu = 0
page_ident = 0
page_init = 0
page_takeoff = 0
display_update = 1
page_approach = 0
page_perf = 0
page_n1_limit = 0
page_pos_init = 0
page_route = 0
page_dep_arr = 0
page_dep = 0
page_arr = 0
page_descent = 0
page_descent_forecast = 0
page_legs = 0
page_rte_init = 0
page_climb = 0
page_cruise = 0
page_progress = 0
page_hold = 0
page_xtras = 0
page_xtras_fmod = 0
page_xtras_others = 0
page_sel_wpt = 0
page_sel_wpt2 = 0

page_legs_step = 0
legs_step = 0
map_mode = 2
map_mode_old = 2

entry = ""
entry_inv = ""
entry_wind_dir = ""
entry_wind_spd = ""

FMS_popup = 0

v1 = "---"
vr = "---"
v2 = "---"
flaps = "**"
vref_15 = "   "
vref_30 = "   "
vref_40 = "   "
flaps_app = "  "

gw_act = "    "
v1_set = "---"
vr_set = "---"
v2_set = "---"
irs_pos_set = "*****.*******.*"
gps_right = "-----.-------.-"
gps_left = "-----.-------.-"
last_pos = "-----.-------.-"
fmc_pos = "-----.-------.-"
last_pos_enable = 1

ref_icao = "----"
ref_gate = "-----"
des_icao = "****"
co_route = "------------"
flt_num = "--------"
ref_rwy = "-----"
des_rwy = "----"

gw = "***.*"
gw_calc = "***.*"
gw_lbs = "***.*"
gw_kgs = "***.*"

zfw_calc = "---.-"
zfw_calc_lbs = "---.-"
zfw_calc_kgs = "---.-"

fuel_weight = "--.-"
fuel_weight_lbs = "--.-"
fuel_weight_kgs = "--.-"

plan_weight = "---.-"
plan_weight_kgs = "---.-"
plan_weight_lbs = "---.-"

zfw = "***.*"
zfw_kgs = "***.*"
zfw_lbs = "***.*"

reserves = "**.*"
reserves_kgs = "**.*"
reserves_lbs = "**.*"

cost_index = "***"
econ_clb_spd = 0
econ_clb_spd_mach = 0
econ_crz_spd = 0
econ_crz_spd_mach = 0
econ_des_spd = 0
econ_des_spd_mach = 0
econ_des_vpa = 0.0

crz_alt = "*****"
crz_alt_num = 0
crz_alt_num2 = 0
crz_spd = "---"
crz_spd_mach = ".---"
crz_alt_old = "*****"
crz_spd_old = "---"
crz_spd_mach_old = ".---"
crz_exec = 0
clb_alt = "----"
clb_alt_num = 1500
crz_wind_dir = "---"
crz_wind_spd = "---"
rw_wind_dir = "---"
rw_wind_spd = "---"
rw_slope = "--.-"
rw_hdg = "---"
--trans_alt = "18000"
trans_alt = "-----"

trans_lvl = "-----"
isa_dev_f = "---"
isa_dev_c = "---"
tc_oat_f = "---"
tc_oat_c = "---"

forec_alt_1 = "-----"
forec_alt_1_num = 0
forec_dir_1 = "---"
forec_spd_1 = "---"
forec_alt_2 = "-----"
forec_alt_2_num = 0
forec_dir_2 = "---"
forec_spd_2 = "---"
forec_alt_3 = "-----"
forec_alt_3_num = 0
forec_dir_3 = "---"
forec_spd_3 = "---"
cabin_rate = "---"
forec_isa_dev = "---"
forec_qnh = "------"

to = "<ACT>"
to_1 = "     "
to_2 = "     "
clb = "<SEL>"
clb_1 = "     "
clb_2 = "     "
sel_clb_thr = 0
rw_cond = 0
cg = "--.-"
trim = "    "
time_err = "  "
units = 0
units_recalc = 0
weight_min = 90
weight_max = 180

clb_min_kts = "   "
clb_min_mach = "   "
clb_max_kts = "   "
clb_max_mach = "   "
crz_min_kts = "   "
crz_min_mach = "   "
crz_max_kts = "   "
crz_max_mach = "   "
des_min_kts = "   "
des_min_mach = "   "
des_max_kts = "   "
des_max_mach = "   "


latitude_deg = ""
latitude_min = ""
longitude_deg = ""
longitude_min = ""
irs_hdg = "---`"
irs_pos = "*****.*******.*"
msg_irs_pos = 0
msg_irs_hdg = 0
zulu_time = "             "
ground_air = 0
fmc_gs = ""
irs_gs = ""
irs2_gs = ""
oat_sim = "    "
oat = "    "
sel_temp = "----"
sel_temp_f = "----"
oat_f = "    "
oat_sim_f = "    "
oat_unit = "`C"

wind_corr = "--"
app_flap = "--"
app_spd = "---"

msg_to_vspeed = 0
qrh = "OFF"

fmc_message = {}
fmc_message_num = 0
msg_mcp_alt = 0
msg_gps_l_fail = 0
msg_gps_r_fail = 0
msg_gps_lr_fail = 0
msg_irs_motion = 0
msg_drag_req = 0
msg_nav_data = 0
msg_unavaible_crz_alt = 0
msg_chk_alt_tgt = 0
msg_tai_above_10 = 0
msg_above_max = 0
msg_vref_not_sel = 0
msg_chk_alt_constr = 0

auto_act = "<ACT>"
ga_act = "     "
con_act = "     "
clb_act = "     "
crz_act = "     "

tai_on_alt = "-----"
tai_off_alt = "-----"


eng_out_prompt = 0

was_on_air = 0
takeoff_enable = 0
climb_enable = 1
descent_enable = 0
goaround_enable = 0
fmc_climb_mode = 0
fmc_cruise_mode = 0
fmc_cont_mode = 0
fmc_takeoff_mode = 0
fmc_goaround_mode = 0
fms_N1_mode = 0
fms_N1_to_mode_sel = 0
fms_N1_clb_mode_sel = 0
in_flight_mode = 0


disable_POS_2L = 0
disable_POS_3L = 0
disable_POS_4R = 0
disable_POS_5R = 0
disable_PERF_3R = 0
disable_PERF_4R = 0
disable_N1_6L = 0
disable_N1_6R = 0


fmc_full_thrust = 0.984
fmc_dto_thrust = 0.984
fmc_sel_thrust = 0.984
fmc_clb_thrust = 0.984
fmc_crz_thrust = 0.984
fmc_con_thrust = 0.984
fmc_ga_thrust = 0.984
fmc_auto_thrust = 0.984

next_enable = 1
prev_enable = 1
exec1_light = 0

des_now_enable = 0
drag_timeout = 0

file_name = ""

ref_data = {}
rwy_num = 0
ref_data_sid = {}
sid_num = 0
ref_data_star = {}
star_num = 0
ref_data_star_tns = {}
ref_data_star_tns_n = 0
ref_data_app = {}
ref_data_app_n = 0
ref_data_app_tns = {}
ref_data_app_tns_n = 0
ref_ed_app = {}
ref_ed_app_n = 0

des_data = {}
des_rwy_num = 0

-- data destination star
data_des_star = {}
data_des_star_n = 0

-- data destination star transition
data_des_star_tns = {}
data_des_star_tns_n = 0

ref_data_sid_act = {}
sid_num_act = 0

ref_data_sid_tns = {}
ref_num_sid_tns = 0

ref_data_tns = {}
tns_num = 0

des_data_app_act = {}
des_num_app_act = 0

-- data destinstion approach
data_des_app = {}
data_des_app_n = 0

-- data destination approach transition
data_des_app_tns = {}
data_des_app_tns_n = 0

ed_app_num = 0
ed_app = {}

des_num_star_tns = 0
des_data_star_tns = {}

des_num_app_tns = 0
des_data_app_tns = {}

ref_rwy_map = {}
ref_rwy_map_num = 0

ref_trans_alt = 0

ref_sid = "------"
ref_sid_tns = "------"

des_star = "------"
des_star_trans = "------"

-- transition connect STAR <-> APP
des_star_trans_con = ""

des_app = "------"

des_app_tns = "------"

ref_rwy_exec = 0
ref_sid_exec = 0
ref_tns_exec = 0
ref_app_tns_exec = 0
des_star_exec = 0
des_star_tns_exec = 0
des_app_exec = 0
des_app_tns_exec = 0

fpln_num = 0
fpln_data = {}

fpln_data2 = {}
fpln_num2 = 0

legs_data = {}
legs_num = 0

ref_rwy_sel = {}
ref_rwy_sel[1] = ""
ref_rwy_sel[2] = ""
ref_rwy_sel[3] = ""
ref_rwy_sel[4] = ""
ref_rwy_sel[5] = ""

ref_sid_sel = {}
ref_sid_sel[1] = ""
ref_sid_sel[2] = ""
ref_sid_sel[3] = ""
ref_sid_sel[4] = ""
ref_sid_sel[5] = ""

ref_tns_sel = {}
ref_tns_sel[1] = ""
ref_tns_sel[2] = ""
ref_tns_sel[3] = ""
ref_tns_sel[4] = ""
ref_tns_sel[5] = ""

des_star_sel = {}
des_star_sel[1] = ""
des_star_sel[2] = ""
des_star_sel[3] = ""
des_star_sel[4] = ""
des_star_sel[5] = ""

des_star_tns_sel = {}
des_star_tns_sel[1] = ""
des_star_tns_sel[2] = ""
des_star_tns_sel[3] = ""
des_star_tns_sel[4] = ""
des_star_tns_sel[5] = ""

des_app_sel = {}
des_app_sel[1] = ""
des_app_sel[2] = ""
des_app_sel[3] = ""
des_app_sel[4] = ""
des_app_sel[5] = ""

des_tns_sel = {}
des_tns_sel[1] = ""
des_tns_sel[2] = ""
des_tns_sel[3] = ""
des_tns_sel[4] = ""
des_tns_sel[5] = ""

set_ils = 0
--offset = 1
legs_offset = 0
legs_select = 0
legs_delete = 0
legs_delete_item = 0
legs_delete_key = 0
legs_page = 0
legs_button = 0
direct_to = 0
direct_to_offset = 0
legs_intdir = 0
legs_dir = 0

legs_restr_spd = {}
legs_restr_spd_n = 0

legs_restr_alt = {}
legs_restr_alt_n = 0

--tc_dist = 0
--tc_idx = 0
tc_lat = 0
tc_lon = 0

--td_dist = 0
--td_idx = 0
td_lat = 0
td_lon = 0

--decel_dist = 0
--decel_idx = 0
decel_lat = 0
decel_lon = 0
was_decel = 0
--ed_found = 0
--ed_alt = 0
--td_idx_last = 0
--td_spd_rest = 0

vnav_update = 0

offset_old = 0

temp_ils3 = ""
temp_ils4 = ""

legs_add = 0
legs_ovwr = 0

--ed_fix_num = 0
ed_fix_found2 = {}
ed_fix_alt2 = {}

dist_dest = 0
dist_tc = 0
time_tc = 0
dist_td = 0
time_td = 0
dist_ed = 0
time_ed = 0

fms_msg_sound = 0

lock_bank = 0
file_path = ""

chock_pos_x = 0
chock_pos_y = 0
chock_pos_z = 0

pause_td_disable = 0

accel_alt = "----"
accel_alt_num = 1000

pre_flt_pos_init = 0
pre_flt_perf_init = 0
pre_flt_rte = 0
pre_flt_dep = 0

last_lat = 0 
last_lon = 0 
last_offset = 0

rw_dist = 0

head_wind = 0
cross_wind = 0

set_chock = 0
chock_timer = 0

--legs_add_select = 0

--td_fix_dist = 0
--td_fix_idx = 0

--rw_ils = ""

apt_data_num = 0
apt_data = {}
rnw_data_num = 0
rnw_data = {}
ref_runway_lenght = 0
ref_runway_lat = 0
ref_runway_lon = 0
ref_runway_crs = 0
des_runway_lenght = 0
des_runway_lat = 0
des_runway_lon = 0
des_runway_crs = 0

des_rnw = ""
log_line = ""

nd_teak = 0
nd_from = 0
nd_to = 0
nd_page1 = {}
nd_page2 = {}
nd_page = 0
nd_page1_num = 0
nd_page2_num = 0
first_time_apt = 0
near_apt1_dis = 0
near_apt1_icao = ""
near_apt2_dis = 0
near_apt2_icao = ""

cl_icao_found = 0
cl_num = 0
cl_lat1 = {}
cl_lon1 = {}
cl_lat2 = {}
cl_lon2 = {}

des_app_from_apt = 0
altitude_last = 0
ref_icao_pos = "               "
icao_latitude = 0
icao_longitude = 0
icao_tns_alt = 0
icao_tns_lvl = 0

awy_data_num = 0
awy_data = {}

awy_path = {}
awy_path_num = 0

awy_temp_num2 = 0
awy_temp2 = {}

via_via_entry = ""
via_via_ok = 0

--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--



	ref_rnw_list = {}
	ref_rnw_list_num = 0
	ref_rnw_list2 = {}
	ref_rnw_list_num2 = 0
	des_rnw_list = {}
	des_rnw_list_num = 0

	sid_list = {}
	sid_list_num = 0
	sid_tns_list = {}
	sid_tns_list_num = 0

	star_list = {}
	star_list_num = 0
	star_tns_list = {}
	star_tns_list_num = 0

	des_app_list = {}
	des_app_list_num = 0
	des_app_tns_list = {}
	des_app_tns_list_num = 0

	temp_list = {}
	temp_list_num = 0

	
	ref_rwy2 = "-----"
	ref_sid2 = "------"
	ref_sid_tns2 = "------"
	des_app2 = "------"
	des_app_tns2 = "------"
	des_star2 = "------"
	des_star_trans2 = "------"
	
	refdes_exec = 0
	des_icao_x = "****"
	arr_data = 0
	
	clip_offset = 0
	
	rte_sid = {}
	rte_sid_num = 0
	rte_star = {}
	rte_star_num = 0
	rte_app = {}
	rte_app_num = 0
	
	legs_data2_tmp_n = 0
	legs_data2_tmp = {}
	
	legs_num2 = 0
	legs_data2 = {}
	
	rte_data_num = 0
	rte_data = {}
	
	item_sel = 0

	earth_nav_num = 0  --number navid
	earth_nav = {}
	ils_nav_num = 0
	ils_nav = {}
	--B738_navdata = ""
	--B738_navdata_active = ""
	
	navaid_list = {}
	navaid_list_n = 0
	
	rte_lat = 0
	rte_lon = 0

	calc_rte_enable = 0
	calc_rte_act = 0
	rte_calc_lat = 0
	rte_calc_lon = 0
	
	calc_rte_enable2 = 0
	calc_rte_act2 = 0
	rte_calc_lat2 = 0
	rte_calc_lon2 = 0
	
	ref_icao_lat = 0
	ref_icao_lon = 0
	des_icao_lat = 0
	des_icao_lon = 0
	ref_tns_alt = 0
	ref_tns_lvl = 0
	des_tns_alt = 0
	des_tns_lvl = 0
	
	add_disco = 0
	temp_nav_sort = {}
	
	rte_exec = 0
	dir_change = 0
	dir_idx = 0
	dir_disco = 0
	fpln_data_tmp_n = 0
	fpln_data_tmp = {}
	
	find_lat = 0
	find_lon = 0
	
--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

--simDR_engine1_on		= find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")

simDR_startup_running               = find_dataref("sim/operation/prefs/startup_running")

simDR_total_weight			= find_dataref("sim/flightmodel/weight/m_total")
simDR_payload_weight		= find_dataref("sim/flightmodel/weight/m_fixed")
simDR_fuel_weight			= find_dataref("sim/flightmodel/weight/m_fuel_total")

simDR_latitude				= find_dataref("sim/flightmodel/position/latitude")
simDR_longitude				= find_dataref("sim/flightmodel/position/longitude")

simDR_zulu_hours			= find_dataref("sim/cockpit2/clock_timer/zulu_time_hours")
simDR_zulu_minutes			= find_dataref("sim/cockpit2/clock_timer/zulu_time_minutes")
simDR_zulu_seconds			= find_dataref("sim/cockpit2/clock_timer/zulu_time_seconds")
simDR_time_month			= find_dataref("sim/cockpit2/clock_timer/current_month")
simDR_time_day				= find_dataref("sim/cockpit2/clock_timer/current_day")

simDR_gps_fail					= find_dataref("sim/operation/failures/rel_gps")
simDR_gps2_fail					= find_dataref("sim/operation/failures/rel_gps2")

simDR_ground_speed		= find_dataref("sim/flightmodel/position/groundspeed")

simDR_OAT				= find_dataref("sim/cockpit2/temperature/outside_air_temp_degc")

simDR_on_ground_0				= find_dataref("sim/flightmodel2/gear/on_ground[0]")
simDR_on_ground_1				= find_dataref("sim/flightmodel2/gear/on_ground[1]")
simDR_on_ground_2				= find_dataref("sim/flightmodel2/gear/on_ground[2]")
simDR_radio_height_pilot_ft		= find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
simDR_altitude_pilot			= find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
--simDR_flaps_ratio				= find_dataref("sim/flightmodel2/controls/flap1_deploy_ratio")
simDR_flaps_ratio				= find_dataref("sim/cockpit2/controls/flap_handle_deploy_ratio")

simDR_gear_retract				= find_dataref("sim/aircraft/parts/acf_gear_deploy[0]")

simDR_vnav_tod_nm		= find_dataref("sim/cockpit2/radios/indicators/fms_distance_to_tod_pilot")
simDR_vnav_eod_alt		= find_dataref("sim/cockpit2/radios/indicators/fms_fpta_pilot")
simDR_vnav_path_angle	= find_dataref("sim/cockpit2/radios/indicators/fms_vpa_pilot")
simDR_vnav_path_err		= find_dataref("sim/cockpit2/radios/indicators/fms_vtk_pilot")
simDR_vnav_status				= find_dataref("sim/cockpit2/autopilot/fms_vnav")



simDR_bus_volts1		= find_dataref("sim/cockpit2/electrical/bus_volts[0]")
simDR_bus_volts2		= find_dataref("sim/cockpit2/electrical/bus_volts[1]")

simDR_ap_altitude_dial_ft		= find_dataref("sim/cockpit2/autopilot/altitude_dial_ft")
simDR_ap_vvi_dial				= find_dataref("sim/cockpit2/autopilot/vvi_dial_fpm")
simDR_airspeed_dial				= find_dataref("sim/cockpit2/autopilot/airspeed_dial_kts_mach")

simDR_airspeed_is_mach			= find_dataref("sim/cockpit2/autopilot/airspeed_is_mach")
simDR_vvi_fpm_pilot				= find_dataref("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")

simDR_autopilot_altitude_mode	= find_dataref("sim/cockpit2/autopilot/altitude_mode")

simDR_wind_hdg					= find_dataref("sim/cockpit2/gauges/indicators/wind_heading_deg_mag")
simDR_wind_spd					= find_dataref("sim/cockpit2/gauges/indicators/wind_speed_kts")
simDR_position_mag_psi 			= find_dataref("sim/flightmodel/position/mag_psi")


simDR_ground_spd					= find_dataref("sim/flightmodel/position/groundspeed")


simDR_fms_exec_light1			= find_dataref("sim/cockpit2/radios/indicators/fms_exec_light_pilot")
simDR_airspeed_pilot			= find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")

simDR_throttle1_use				= find_dataref("sim/flightmodel/engine/ENGN_thro_use[0]")
simDR_throttle2_use				= find_dataref("sim/flightmodel/engine/ENGN_thro_use[1]")


--simDR_gps_nav_id				= find_dataref("sim/cockpit2/radios/indicators/gps_nav_id")
simDR_elevator_trim				= find_dataref("sim/cockpit2/controls/elevator_trim")

--simDR_glideslope_status			= find_dataref("sim/cockpit2/autopilot/glideslope_status")

simDR_mag_variation		= find_dataref("sim/flightmodel/position/magnetic_variation")
--simDR_fmc_nav_id		= find_dataref("sim/cockpit2/radios/indicators/gps_nav_id")
--simDR_fmc_crs			= find_dataref("sim/cockpit/radios/gps_course_degtm")
--simDR_fmc_dist_xp			= find_dataref("sim/cockpit2/radios/indicators/gps_dme_distance_nm")


simDR_mag_hdg			= find_dataref("sim/cockpit2/gauges/indicators/ground_track_mag_pilot")
simDR_ahars_mag_hdg		= find_dataref("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
--simDR_mag_variation		= find_dataref("sim/flightmodel/position/magnetic_variation")
simDR_efis_sub_mode		= find_dataref("sim/cockpit/switches/EFIS_map_submode")
simDR_efis_map_range	= find_dataref("sim/cockpit2/EFIS/map_range")
simDR_efis_map_mode		= find_dataref("sim/cockpit/switches/EFIS_map_mode")


-- simDR_nav1_hdef_pilot		= find_dataref("sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot")
-- simDR_nav1_id				= find_dataref("sim/cockpit2/radios/indicators/nav1_nav_id")

--simDR_nav1_vert_dsp 		= find_dataref("sim/cockpit2/radios/indicators/nav1_display_vertical")
simDR_hsi_flag_gs			= find_dataref("sim/cockpit2/radios/indicators/hsi_flag_glideslope_pilot")
simDR_hsi_vert_dsp			= find_dataref("sim/cockpit2/radios/indicators/hsi_display_vertical_pilot")
-- simDR_nav1_dme				= find_dataref("sim/cockpit2/radios/indicators/nav1_dme_distance_nm")

simDR_nav1_flag_gs			= find_dataref("sim/cockpit2/radios/indicators/nav1_flag_glideslope")
simDR_nav1_vert_dsp			= find_dataref("sim/cockpit2/radios/indicators/nav1_display_vertical")
simDR_nav1_horz_dsp			= find_dataref("sim/cockpit2/radios/indicators/nav1_display_horizontal")
simDR_nav1_flag_ft			= find_dataref("sim/cockpit2/radios/indicators/nav1_flag_from_to_pilot")
simDR_nav1_nav_id			= find_dataref("sim/cockpit2/radios/indicators/nav1_nav_id")
simDR_nav1_dme				= find_dataref("sim/cockpit2/radios/indicators/nav1_dme_distance_nm")
simDR_nav1_has_dme			= find_dataref("sim/cockpit2/radios/indicators/nav1_has_dme")
simDR_nav1_obs_pilot		= find_dataref("sim/cockpit2/radios/actuators/nav1_obs_deg_mag_pilot")

simDR_nav2_flag_gs			= find_dataref("sim/cockpit2/radios/indicators/nav2_flag_glideslope")
simDR_nav2_vert_dsp			= find_dataref("sim/cockpit2/radios/indicators/nav2_display_vertical")
simDR_nav2_horz_dsp			= find_dataref("sim/cockpit2/radios/indicators/nav2_display_horizontal")
simDR_nav2_flag_ft			= find_dataref("sim/cockpit2/radios/indicators/nav2_flag_from_to_pilot")
simDR_nav2_nav_id			= find_dataref("sim/cockpit2/radios/indicators/nav2_nav_id")
simDR_nav2_dme				= find_dataref("sim/cockpit2/radios/indicators/nav2_dme_distance_nm")
simDR_nav2_has_dme			= find_dataref("sim/cockpit2/radios/indicators/nav2_has_dme")
simDR_nav2_obs_pilot		= find_dataref("sim/cockpit2/radios/actuators/nav2_obs_deg_mag_pilot")

simDR_approach_status		= find_dataref("sim/cockpit2/autopilot/approach_status")
simDR_glideslope_status		= find_dataref("sim/cockpit2/autopilot/glideslope_status")
simDR_nav_status			= find_dataref("sim/cockpit2/autopilot/nav_status")

simDR_elevation_m			= find_dataref("sim/flightmodel/position/elevation")

simDR_bank_angle			= find_dataref("sim/cockpit2/autopilot/bank_angle_mode")
simDR_cg					= find_dataref("sim/flightmodel/misc/cgz_ref_to_default")

simDR_cowl_ice_0_on			= find_dataref("sim/cockpit2/ice/ice_inlet_heat_on_per_engine[0]")
simDR_cowl_ice_1_on			= find_dataref("sim/cockpit2/ice/ice_inlet_heat_on_per_engine[1]")
simDR_TAT					= find_dataref("sim/cockpit2/temperature/outside_air_LE_temp_degc")

simDR_hide_yoke				= find_dataref("sim/graphics/view/hide_yoke")
simDR_nav1_hdef_pilot		= find_dataref("sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot")
simDR_roll					= find_dataref("sim/cockpit2/gauges/indicators/roll_AHARS_deg_pilot")
simDR_fms_time				= find_dataref("sim/cockpit/radios/gps_dme_time_secs")

simDR_pause					= find_dataref("sim/time/paused")

--simDR_toe_brakes_ovr		= find_dataref("sim/operation/override/override_toe_brakes")

simDR_nav1_relative_hdg		= find_dataref("sim/cockpit2/radios/indicators/nav1_relative_heading_AHARS_deg_pilot")

simDR_TAS					= find_dataref("sim/flightmodel/position/true_airspeed")

simDR_kill_map_fms			= find_dataref("sim/graphics/misc/kill_map_fms_line")


--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_FMS_key_0		= find_command("sim/FMS/key_0")
simCMD_FMS_key_1		= find_command("sim/FMS/key_1")
simCMD_FMS_key_2		= find_command("sim/FMS/key_2")
simCMD_FMS_key_3		= find_command("sim/FMS/key_3")
simCMD_FMS_key_4		= find_command("sim/FMS/key_4")
simCMD_FMS_key_5		= find_command("sim/FMS/key_5")
simCMD_FMS_key_6		= find_command("sim/FMS/key_6")
simCMD_FMS_key_7		= find_command("sim/FMS/key_7")
simCMD_FMS_key_8		= find_command("sim/FMS/key_8")
simCMD_FMS_key_9		= find_command("sim/FMS/key_9")
simCMD_FMS_key_period	= find_command("sim/FMS/key_period")
simCMD_FMS_key_minus	= find_command("sim/FMS/key_minus")

simCMD_FMS_key_A		= find_command("sim/FMS/key_A")
simCMD_FMS_key_B		= find_command("sim/FMS/key_B")
simCMD_FMS_key_C		= find_command("sim/FMS/key_C")
simCMD_FMS_key_D		= find_command("sim/FMS/key_D")
simCMD_FMS_key_E		= find_command("sim/FMS/key_E")
simCMD_FMS_key_F		= find_command("sim/FMS/key_F")
simCMD_FMS_key_G		= find_command("sim/FMS/key_G")
simCMD_FMS_key_H		= find_command("sim/FMS/key_H")
simCMD_FMS_key_I		= find_command("sim/FMS/key_I")
simCMD_FMS_key_J		= find_command("sim/FMS/key_J")
simCMD_FMS_key_K		= find_command("sim/FMS/key_K")
simCMD_FMS_key_L		= find_command("sim/FMS/key_L")
simCMD_FMS_key_M		= find_command("sim/FMS/key_M")
simCMD_FMS_key_N		= find_command("sim/FMS/key_N")
simCMD_FMS_key_O		= find_command("sim/FMS/key_O")
simCMD_FMS_key_P		= find_command("sim/FMS/key_P")
simCMD_FMS_key_Q		= find_command("sim/FMS/key_Q")
simCMD_FMS_key_R		= find_command("sim/FMS/key_R")
simCMD_FMS_key_S		= find_command("sim/FMS/key_S")
simCMD_FMS_key_T		= find_command("sim/FMS/key_T")
simCMD_FMS_key_U		= find_command("sim/FMS/key_U")
simCMD_FMS_key_V		= find_command("sim/FMS/key_V")
simCMD_FMS_key_W		= find_command("sim/FMS/key_W")
simCMD_FMS_key_X		= find_command("sim/FMS/key_X")
simCMD_FMS_key_Y		= find_command("sim/FMS/key_Y")
simCMD_FMS_key_Z		= find_command("sim/FMS/key_Z")
simCMD_FMS_key_SP		= find_command("sim/FMS/key_space")

simCMD_FMS_key_clb		= find_command("sim/FMS/clb")
simCMD_FMS_key_crz		= find_command("sim/FMS/crz")
simCMD_FMS_key_des		= find_command("sim/FMS/des")

simCMD_FMS_key_clear	= find_command("sim/FMS/key_clear")
simCMD_FMS_key_delete	= find_command("sim/FMS/key_delete")
simCMD_FMS_key_exec		= find_command("sim/FMS/exec")

simCMD_FMS_key_dep_arr	= find_command("sim/FMS/dep_arr")
simCMD_FMS_key_legs		= find_command("sim/FMS/legs")
simCMD_FMS_key_fpln		= find_command("sim/FMS/fpln")
simCMD_FMS_key_fix		= find_command("sim/FMS/fix")
simCMD_FMS_key_hold		= find_command("sim/FMS/hold")
simCMD_FMS_key_prog		= find_command("sim/FMS/prog")
simCMD_FMS_key_dir_intc	= find_command("sim/FMS/dir_intc")

simCMD_FMS_key_slash	= find_command("sim/FMS/key_slash")

simCMD_FMS_key_1L		= find_command("sim/FMS/ls_1l")
simCMD_FMS_key_2L		= find_command("sim/FMS/ls_2l")
simCMD_FMS_key_3L		= find_command("sim/FMS/ls_3l")
simCMD_FMS_key_4L		= find_command("sim/FMS/ls_4l")
simCMD_FMS_key_5L		= find_command("sim/FMS/ls_5l")
simCMD_FMS_key_6L		= find_command("sim/FMS/ls_6l")
simCMD_FMS_key_1R		= find_command("sim/FMS/ls_1r")
simCMD_FMS_key_2R		= find_command("sim/FMS/ls_2r")
simCMD_FMS_key_3R		= find_command("sim/FMS/ls_3r")
simCMD_FMS_key_4R		= find_command("sim/FMS/ls_4r")
simCMD_FMS_key_5R		= find_command("sim/FMS/ls_5r")
simCMD_FMS_key_6R		= find_command("sim/FMS/ls_6r")

simCMD_FMS_key_prev		= find_command("sim/FMS/prev")
simCMD_FMS_key_next		= find_command("sim/FMS/next")

simCMD_FMS_reset		= find_command("sim/FMS/init")

simCMD_FMS_popup		= find_command("sim/FMS/CDU_popup")

simCMD_nosmoking_toggle		= find_command("sim/systems/no_smoking_toggle")

simCMD_autopilot_lvl_chg	= find_command("sim/autopilot/level_change")
simCMD_autopilot_vs_sel		= find_command("sim/autopilot/vertical_speed_pre_sel")

simCMD_pause				= find_command("sim/operation/pause_toggle")

simCMD_autopilot_alt_hold	= find_command("sim/autopilot/altitude_hold")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

-- CLIMB
B738DR_fmc_climb_speed			= find_dataref("laminar/B738/autopilot/fmc_climb_speed")
B738DR_fmc_climb_speed_l		= find_dataref("laminar/B738/autopilot/fmc_climb_speed_l")
B738DR_fmc_climb_speed_mach		= find_dataref("laminar/B738/autopilot/fmc_climb_speed_mach")
B738DR_fmc_climb_r_speed1		= find_dataref("laminar/B738/autopilot/fmc_climb_r_speed1")
B738DR_fmc_climb_r_alt1			= find_dataref("laminar/B738/autopilot/fmc_climb_r_alt1")
B738DR_fmc_climb_r_speed2		= find_dataref("laminar/B738/autopilot/fmc_climb_r_speed2")
B738DR_fmc_climb_r_alt2			= find_dataref("laminar/B738/autopilot/fmc_climb_r_alt2")

-- CRUISE
B738DR_fmc_cruise_speed			= find_dataref("laminar/B738/autopilot/fmc_cruise_speed")
B738DR_fmc_cruise_speed_mach	= find_dataref("laminar/B738/autopilot/fmc_cruise_speed_mach")
B738DR_fmc_cruise_alt			= find_dataref("laminar/B738/autopilot/fmc_cruise_alt")

-- DESCENT
B738DR_fmc_descent_speed		= find_dataref("laminar/B738/autopilot/fmc_descent_speed")
B738DR_fmc_descent_speed_mach	= find_dataref("laminar/B738/autopilot/fmc_descent_speed_mach")
B738DR_fmc_descent_alt			= find_dataref("laminar/B738/autopilot/fmc_descent_alt")
B738DR_fmc_descent_r_speed1		= find_dataref("laminar/B738/autopilot/fmc_descent_r_speed1")
B738DR_fmc_descent_r_alt1		= find_dataref("laminar/B738/autopilot/fmc_descent_r_alt1")
B738DR_fmc_descent_r_speed2		= find_dataref("laminar/B738/autopilot/fmc_descent_r_speed2")
B738DR_fmc_descent_r_alt2		= find_dataref("laminar/B738/autopilot/fmc_descent_r_alt2")

-- APPROACH
B738DR_fmc_approach_alt			= find_dataref("laminar/B738/autopilot/fmc_approach_alt")

-- V speed
-- B738DR_fms_v1			= find_dataref("laminar/B738/FMS/v1")
-- B738DR_fms_vr			= find_dataref("laminar/B738/FMS/vr")
-- B738DR_fms_v2			= find_dataref("laminar/B738/FMS/v2")
-- B738DR_fms_v2_15		= find_dataref("laminar/B738/FMS/v2_15")
B738DR_fms_vref			= find_dataref("laminar/B738/FMS/vref")
B738DR_fms_vref_15		= find_dataref("laminar/B738/FMS/vref_15")
B738DR_fms_vref_25		= find_dataref("laminar/B738/FMS/vref_25")
B738DR_fms_vref_30		= find_dataref("laminar/B738/FMS/vref_30")
B738DR_fms_vref_40		= find_dataref("laminar/B738/FMS/vref_40")

B738DR_fms_v1_calc		= find_dataref("laminar/B738/FMS/v1_calc")
B738DR_fms_vr_calc		= find_dataref("laminar/B738/FMS/vr_calc")
B738DR_fms_v2_calc		= find_dataref("laminar/B738/FMS/v2_calc")
B738DR_trim_calc		= find_dataref("laminar/B738/FMS/trim_calc")

-- B738DR_fms_takeoff_flaps	= find_dataref("laminar/B738/FMS/takeoff_flaps")
-- B738DR_fms_approach_flaps	= find_dataref("laminar/B738/FMS/approach_flaps")

B738DR_latitude_deg			= find_dataref("laminar/B738/latitude_deg")
B738DR_latitude_min			= find_dataref("laminar/B738/latitude_min")
B738DR_latitude_NS			= find_dataref("laminar/B738/latitude_NS")
B738DR_longitude_deg		= find_dataref("laminar/B738/longitude_deg")
B738DR_longitude_min		= find_dataref("laminar/B738/longitude_min")
B738DR_longitude_EW			= find_dataref("laminar/B738/longitude_EW")

B738DR_gps_pos				= find_dataref("laminar/B738/irs/gps_pos")
B738DR_gps2_pos				= find_dataref("laminar/B738/irs/gps2_pos")
B738DR_irs_pos				= find_dataref("laminar/B738/irs/irs_pos")
B738DR_irs2_pos				= find_dataref("laminar/B738/irs/irs2_pos")
--B738DR_irs_pos_set			= find_dataref("laminar/B738/irs/irs_pos_set")
B738DR_irs2_pos_set			= find_dataref("laminar/B738/irs/irs2_pos_set")
B738DR_irs_status			= find_dataref("laminar/B738/irs/irs_status")
B738DR_irs2_status			= find_dataref("laminar/B738/irs/irs2_status")

B738DR_irs_left_mode		= find_dataref("laminar/B738/irs/irs_mode", "number")
B738DR_irs_right_mode		= find_dataref("laminar/B738/irs/irs2_mode", "number")

B738DR_irs_left 			= find_dataref("laminar/B738/toggle_switch/irs_left")
B738DR_irs_right 			= find_dataref("laminar/B738/toggle_switch/irs_right")

B738DR_n1_set_source 		= find_dataref("laminar/B738/toggle_switch/n1_set_source")

B738DR_altitude_mode		= find_dataref("laminar/B738/autopilot/altitude_mode")
B738DR_heading_mode			= find_dataref("laminar/B738/autopilot/heading_mode")

B738DR_irs1_restart			= find_dataref("laminar/B738/toggle_switch/irs_restart")
B738DR_irs2_restart			= find_dataref("laminar/B738/toggle_switch/irs2_restart")


B738DR_thr_takeoff_N1		= find_dataref("laminar/B738/engine/calc/thr_takeoff_N1")
B738DR_thr_climb_N1			= find_dataref("laminar/B738/engine/calc/thr_climb_N1")
B738DR_thr_cruise_N1		= find_dataref("laminar/B738/engine/calc/thr_cruise_N1")
B738DR_thr_cont_N1			= find_dataref("laminar/B738/engine/calc/thr_cont_N1")
B738DR_thr_goaround_N1		= find_dataref("laminar/B738/engine/calc/thr_goaround_N1")
B738DR_cruise_opt_alt		= find_dataref("laminar/B738/engine/calc/cruise_opt_alt")
B738DR_cruise_max_alt		= find_dataref("laminar/B738/engine/calc/cruise_max_alt")

B738DR_mcp_alt_dial			= find_dataref("laminar/B738/autopilot/mcp_alt_dial")

B738DR_baro_set_std_pilot		= find_dataref("laminar/B738/EFIS/baro_set_std_pilot")
B738DR_baro_sel_in_hg_pilot		= find_dataref("laminar/B738/EFIS/baro_sel_in_hg_pilot")
B738DR_baro_set_std_copilot		= find_dataref("laminar/B738/EFIS/baro_set_std_copilot")
B738DR_baro_sel_in_hg_copilot	= find_dataref("laminar/B738/EFIS/baro_sel_in_hg_copilot")

B738DR_efis_map_range_capt 		= find_dataref("laminar/B738/EFIS/capt/map_range")
B738DR_efis_map_range_fo 		= find_dataref("laminar/B738/EFIS/fo/map_range")
B738DR_capt_map_mode		= find_dataref("laminar/B738/EFIS_control/capt/map_mode_pos")
B738DR_fo_map_mode			= find_dataref("laminar/B738/EFIS_control/fo/map_mode_pos")



B738DR_ap_spd_interv_status	= find_dataref("laminar/B738/autopilot/spd_interv_status")
B738DR_speed_ratio			= find_dataref("laminar/B738/FMS/speed_ratio")

flaps_speed						= find_dataref("laminar/B738/FMS/flaps_speed")
vnav_speed						= find_dataref("laminar/B738/FMS/vnav_speed")
B738DR_autopilot_vnav_status	= find_dataref("laminar/B738/autopilot/vnav_status1")
B738DR_autopilot_cmd_a_status	= find_dataref("laminar/B738/autopilot/cmd_a_status")
B738DR_autopilot_cmd_b_status	= find_dataref("laminar/B738/autopilot/cmd_b_status")


B738DR_mcp_speed_dial		= find_dataref("laminar/B738/autopilot/mcp_speed_dial_kts_mach")

B738_navdata			= find_dataref("laminar/B738/navdata/navdata")
B738_navdata_active		= find_dataref("laminar/B738/navdata/navdata_active")
B738_navdata_test		= find_dataref("laminar/B738/navdata/navdata_test")

B738DR_efis_data_capt_status	= find_dataref("laminar/B738/EFIS/capt/data_status")

B738DR_autopilot_bank_angle_pos		= find_dataref("laminar/B738/autopilot/bank_angle_pos")

vnav_alt_mode				= find_dataref("laminar/B738/autopilot/vnav_alt_mode")

B738DR_spd_ref 				= find_dataref("laminar/B738/toggle_switch/spd_ref")

B738DR_efis_apt_on		= find_dataref("laminar/B738/EFIS/EFIS_airport_on")


-- FMOD by AudioBird XP
B738DR_enable_pax_boarding	= find_dataref("laminar/b738/fmodpack/fmod_pax_boarding_on")
B738DR_enable_gyro			= find_dataref("laminar/b738/fmodpack/fmod_woodpecker_on")
B738DR_enable_crew			= find_dataref("laminar/b738/fmodpack/fmod_crew_on")
B738DR_enable_chatter		= find_dataref("laminar/b738/fmodpack/fmod_chatter_on")
B738DR_airport_set 			= find_dataref("laminar/b738/fmodpack/fmod_airport_set")
B738DR_vol_int_ducker 		= find_dataref("laminar/b738/fmodpack/fmod_vol_int_ducker")
B738DR_vol_int_eng 			= find_dataref("laminar/b738/fmodpack/fmod_vol_int_eng")
B738DR_vol_int_start 		= find_dataref("laminar/b738/fmodpack/fmod_vol_int_start")
B738DR_vol_int_ac 			= find_dataref("laminar/b738/fmodpack/fmod_vol_int_ac")
B738DR_vol_int_gyro 		= find_dataref("laminar/b738/fmodpack/fmod_vol_int_gyro")
B738DR_vol_int_roll 		= find_dataref("laminar/b738/fmodpack/fmod_vol_int_roll")
B738DR_vol_int_bump 		= find_dataref("laminar/b738/fmodpack/fmod_vol_int_bump")
B738DR_vol_int_pax 			= find_dataref("laminar/b738/fmodpack/fmod_vol_int_pax")
B738DR_vol_int_pax_applause = find_dataref("laminar/b738/fmodpack/fmod_pax_applause_on")
B738DR_vol_int_wind			= find_dataref("laminar/b738/fmodpack/fmod_vol_int_wind")
B738DR_enable_mutetrim		= find_dataref("laminar/b738/fmodpack/fmod_mutetrim_on")
B738DR_vol_airport			= find_dataref("laminar/b738/fmodpack/fmod_vol_airport")
B738DR_xp_int_vol			= create_dataref("laminar/b738/fmodpack/fmod_xp_int_vol", "number")
B738DR_vol_int_XP 			= find_dataref("sim/operation/sound/interior_volume_ratio")

--*************************************************************************************--
--** 				               FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--

-- FMOD by AudioBird XP
B738CMD_enable_pax_boarding = find_command("laminar/b738/fmodpack/fmod_toggle_pax_boarding")
B738CMD_enable_gyro 		= find_command("laminar/b738/fmodpack/fmod_woodpecker_on")
B738CMD_enable_crew			= find_command("laminar/b738/fmodpack/fmod_crew_on")
B738CMD_enable_chatter 		= find_command("laminar/b738/fmodpack/fmod_chatter_on")
B738CMD_airport_set 		= find_command("laminar/b738/fmodpack/fmod_airport_set")
B738CMD_vol_int_ducker 		= find_command("laminar/b738/fmodpack/fmod_vol_int_ducker")
B738CMD_vol_int_eng 		= find_command("laminar/b738/fmodpack/fmod_vol_int_eng")
B738CMD_vol_int_start 		= find_command("laminar/b738/fmodpack/fmod_vol_int_start")
B738CMD_vol_int_ac 			= find_command("laminar/b738/fmodpack/fmod_vol_int_ac")
B738CMD_vol_int_gyro 		= find_command("laminar/b738/fmodpack/fmod_vol_int_gyro")
B738CMD_vol_int_roll		= find_command("laminar/b738/fmodpack/fmod_vol_int_roll")
B738CMD_vol_int_bump		= find_command("laminar/b738/fmodpack/fmod_vol_int_bump")
B738CMD_vol_int_pax				= find_command("laminar/b738/fmodpack/fmod_vol_int_pax")
B738CMD_vol_int_pax_applause	= find_command("laminar/b738/fmodpack/fmod_pax_applause_on")
B738CMD_vol_int_wind			= find_command("laminar/b738/fmodpack/fmod_vol_int_wind")
B738CMD_enable_mutetrim 		= find_command("laminar/b738/fmodpack/fmod_mutetrim_on")
B738CMD_vol_int_XP			= find_command("laminar/b738/fmodpack/fmod_vol_int_XP")
B738CMD_vol_airport			= find_command("laminar/b738/fmodpack/fmod_vol_airport")

--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

B738DR_fmc1_Line00_L                = create_dataref("laminar/B738/fmc1/Line00_L", "string")
B738DR_fmc1_Line01_L                = create_dataref("laminar/B738/fmc1/Line01_L", "string")
B738DR_fmc1_Line02_L                = create_dataref("laminar/B738/fmc1/Line02_L", "string")
B738DR_fmc1_Line03_L                = create_dataref("laminar/B738/fmc1/Line03_L", "string")
B738DR_fmc1_Line04_L                = create_dataref("laminar/B738/fmc1/Line04_L", "string")
B738DR_fmc1_Line05_L                = create_dataref("laminar/B738/fmc1/Line05_L", "string")
B738DR_fmc1_Line06_L                = create_dataref("laminar/B738/fmc1/Line06_L", "string")

B738DR_fmc1_Line00_S                = create_dataref("laminar/B738/fmc1/Line00_S", "string")
B738DR_fmc1_Line01_S                = create_dataref("laminar/B738/fmc1/Line01_S", "string")
B738DR_fmc1_Line02_S                = create_dataref("laminar/B738/fmc1/Line02_S", "string")
B738DR_fmc1_Line03_S                = create_dataref("laminar/B738/fmc1/Line03_S", "string")
B738DR_fmc1_Line04_S                = create_dataref("laminar/B738/fmc1/Line04_S", "string")
B738DR_fmc1_Line05_S                = create_dataref("laminar/B738/fmc1/Line05_S", "string")
B738DR_fmc1_Line06_S                = create_dataref("laminar/B738/fmc1/Line06_S", "string")

B738DR_fmc1_Line01_X                = create_dataref("laminar/B738/fmc1/Line01_X", "string")
B738DR_fmc1_Line02_X                = create_dataref("laminar/B738/fmc1/Line02_X", "string")
B738DR_fmc1_Line03_X                = create_dataref("laminar/B738/fmc1/Line03_X", "string")
B738DR_fmc1_Line04_X                = create_dataref("laminar/B738/fmc1/Line04_X", "string")
B738DR_fmc1_Line05_X                = create_dataref("laminar/B738/fmc1/Line05_X", "string")
B738DR_fmc1_Line06_X                = create_dataref("laminar/B738/fmc1/Line06_X", "string")

B738DR_fmc1_Line00_I                = create_dataref("laminar/B738/fmc1/Line00_I", "string")
B738DR_fmc1_Line01_I                = create_dataref("laminar/B738/fmc1/Line01_I", "string")
B738DR_fmc1_Line02_I                = create_dataref("laminar/B738/fmc1/Line02_I", "string")
B738DR_fmc1_Line03_I                = create_dataref("laminar/B738/fmc1/Line03_I", "string")
B738DR_fmc1_Line04_I                = create_dataref("laminar/B738/fmc1/Line04_I", "string")
B738DR_fmc1_Line05_I                = create_dataref("laminar/B738/fmc1/Line05_I", "string")
B738DR_fmc1_Line06_I                = create_dataref("laminar/B738/fmc1/Line06_I", "string")

B738DR_fmc1_Line00_M                = create_dataref("laminar/B738/fmc1/Line00_M", "string")
B738DR_fmc1_Line01_M                = create_dataref("laminar/B738/fmc1/Line01_M", "string")
B738DR_fmc1_Line02_M                = create_dataref("laminar/B738/fmc1/Line02_M", "string")
B738DR_fmc1_Line03_M                = create_dataref("laminar/B738/fmc1/Line03_M", "string")
B738DR_fmc1_Line04_M                = create_dataref("laminar/B738/fmc1/Line04_M", "string")
B738DR_fmc1_Line05_M                = create_dataref("laminar/B738/fmc1/Line05_M", "string")
B738DR_fmc1_Line06_M                = create_dataref("laminar/B738/fmc1/Line06_M", "string")

B738DR_fmc1_Line00_G                = create_dataref("laminar/B738/fmc1/Line00_G", "string")
B738DR_fmc1_Line01_G                = create_dataref("laminar/B738/fmc1/Line01_G", "string")
B738DR_fmc1_Line02_G                = create_dataref("laminar/B738/fmc1/Line02_G", "string")
B738DR_fmc1_Line03_G                = create_dataref("laminar/B738/fmc1/Line03_G", "string")
B738DR_fmc1_Line04_G                = create_dataref("laminar/B738/fmc1/Line04_G", "string")
B738DR_fmc1_Line05_G                = create_dataref("laminar/B738/fmc1/Line05_G", "string")
B738DR_fmc1_Line06_G                = create_dataref("laminar/B738/fmc1/Line06_G", "string")

B738DR_fmc1_Line_entry              = create_dataref("laminar/B738/fmc1/Line_entry", "string")
B738DR_fmc1_Line_entry_I            = create_dataref("laminar/B738/fmc1/Line_entry_I", "string")

--B7368DR_fmc1_show                   = create_dataref("laminar/B738/fmc1/fmc1_show", "number")

B738DR_fms_v1_set			= create_dataref("laminar/B738/FMS/v1_set", "number")
B738DR_fms_vr_set			= create_dataref("laminar/B738/FMS/vr_set", "number")
B738DR_fms_v2_set			= create_dataref("laminar/B738/FMS/v2_set", "number")

B738DR_calc_spd_enable		= create_dataref("laminar/B738/FMS/calc_spd_enable", "number")
B738DR_fmc_gw				= create_dataref("laminar/B738/FMS/fmc_gw", "number")
B738DR_irs_pos_fmc			= create_dataref("laminar/B738/FMS/irs_pos_fmc", "number")

B738DR_irs_hdg_fmc			= create_dataref("laminar/B738/FMS/irs_hdg_fmc", "number")
B738DR_irs_hdg_fmc_set		= create_dataref("laminar/B738/FMS/irs_hdg_fmc_set", "string")
B738DR_irs2_hdg_fmc_set		= create_dataref("laminar/B738/FMS/irs2_hdg_fmc_set", "string")
B738DR_irs_pos_fmc_set		= create_dataref("laminar/B738/FMS/irs_pos_fmc_set", "string")
B738DR_irs2_pos_fmc_set		= create_dataref("laminar/B738/FMS/irs2_pos_fmc_set", "string")


B738DR_fmc_units			= create_dataref("laminar/B738/FMS/fmc_units", "number")

B738DR_fmc_cg				= create_dataref("laminar/B738/FMS/fmc_cg", "number")
B738DR_fmc_sel_temp			= create_dataref("laminar/B738/FMS/fmc_sel_temp", "number")
B738DR_fmc_oat_temp			= create_dataref("laminar/B738/FMS/fmc_oat_temp", "number")

B738DR_fmc_rw_cond			= create_dataref("laminar/B738/FMS/fmc_rw_cond", "number")

B738DR_fms_N1_thrust		= create_dataref("laminar/B738/FMS/N1_mode_thrust", "number")
B738DR_fms_N1_mode			= create_dataref("laminar/B738/FMS/N1_mode", "number")
B738DR_fms_N1_to_sel		= create_dataref("laminar/B738/FMS/N1_mode_to_sel", "number")

B738DR_flight_phase			= create_dataref("laminar/B738/FMS/flight_phase", "number")
B738DR_climb_mode			= create_dataref("laminar/B738/FMS/climb_mode", "number")
B738DR_cruise_mode			= create_dataref("laminar/B738/FMS/cruise_mode", "number")
B738DR_descent_mode			= create_dataref("laminar/B738/FMS/descent_mode", "number")

B738DR_fms_exec_light_pilot		= create_dataref("laminar/B738/indicators/fms_exec_light_pilot", "number")


B738DR_autopilot_alt_interv_pos	= create_dataref("laminar/B738/autopilot/alt_interv_pos", "number")


B738DR_trans_alt			= create_dataref("laminar/B738/FMS/fmc_trans_alt", "number")
B738DR_trans_lvl			= create_dataref("laminar/B738/FMS/fmc_trans_lvl", "number")

B738DR_isa_dev_c			= create_dataref("laminar/B738/FMS/fmc_isa_dev_c", "number")

B738DR_takeoff_flaps_set	= create_dataref("laminar/B738/FMS/takeoff_flaps_set", "number")
B738DR_approach_flaps_set	= create_dataref("laminar/B738/FMS/approach_flaps_set", "number")
B738DR_trim_set				= create_dataref("laminar/B738/FMS/trim_set", "number")

B738DR_thr_red_alt			= create_dataref("laminar/B738/FMS/throttle_red_alt", "number")
B738DR_accel_alt			= create_dataref("laminar/B738/FMS/accel_height", "number")

B738DR_pfd_vert_path		= create_dataref("laminar/B738/pfd/pfd_vert_path", "number")
B738DR_pfd_vert_path_fo		= create_dataref("laminar/B738/pfd/pfd_vert_path_fo", "number")
B738DR_pfd_trk_path			= create_dataref("laminar/B738/pfd/pfd_trk_path", "number")
B738DR_pfd_trk_path_fo		= create_dataref("laminar/B738/pfd/pfd_trk_path_fo", "number")
B738DR_nd_vert_path			= create_dataref("laminar/B738/pfd/nd_vert_path", "number")

B738DR_autopilot_pfd_mode		= create_dataref("laminar/B738/autopilot/pfd_mode", "number")
B738DR_autopilot_pfd_mode_fo	= create_dataref("laminar/B738/autopilot/pfd_mode_fo", "number")

B738DR_fms_ils_disable		= create_dataref("laminar/B738/FMS/ils_disable", "number")
B738DR_align_time			= create_dataref("laminar/B738/FMS/align_time", "number")


-- FMOD SOUNDS DATAREFS
B738DR_fms_msg_sound		= create_dataref("laminar/B738/fmod/fms_message", "number")
B738DR_fms_key				= create_dataref("laminar/B738/fmod/fms_key", "number")

-- WAYPOINTs
B738DR_wpt_x	 		= create_dataref("laminar/B738/nd/wpt_x", "array[20]")
B738DR_wpt_y	 		= create_dataref("laminar/B738/nd/wpt_y", "array[20]")

--B738DR_wpt_idw 		= create_dataref("laminar/B738/nd/wpt_idw", "byte[10]")

B738DR_wpt_id00w 		= create_dataref("laminar/B738/nd/wpt_id00w", "string")
B738DR_wpt_alt00w 		= create_dataref("laminar/B738/nd/wpt_alt00w", "string")
B738DR_wpt_eta00w 		= create_dataref("laminar/B738/nd/wpt_eta00w", "string")
B738DR_wpt_id00m 		= create_dataref("laminar/B738/nd/wpt_id00m", "string")
B738DR_wpt_alt00m 		= create_dataref("laminar/B738/nd/wpt_alt00m", "string")
B738DR_wpt_eta00m 		= create_dataref("laminar/B738/nd/wpt_eta00m", "string")
B738DR_wpt_type00 		= create_dataref("laminar/B738/nd/wpt_type00", "number")

B738DR_wpt_id01w 		= create_dataref("laminar/B738/nd/wpt_id01w", "string")
B738DR_wpt_alt01w 		= create_dataref("laminar/B738/nd/wpt_alt01w", "string")
B738DR_wpt_eta01w 		= create_dataref("laminar/B738/nd/wpt_eta01w", "string")
B738DR_wpt_id01m 		= create_dataref("laminar/B738/nd/wpt_id01m", "string")
B738DR_wpt_alt01m 		= create_dataref("laminar/B738/nd/wpt_alt01m", "string")
B738DR_wpt_eta01m 		= create_dataref("laminar/B738/nd/wpt_eta01m", "string")
B738DR_wpt_type01 		= create_dataref("laminar/B738/nd/wpt_type01", "number")

B738DR_wpt_id02w 		= create_dataref("laminar/B738/nd/wpt_id02w", "string")
B738DR_wpt_alt02w 		= create_dataref("laminar/B738/nd/wpt_alt02w", "string")
B738DR_wpt_eta02w 		= create_dataref("laminar/B738/nd/wpt_eta02w", "string")
B738DR_wpt_id02m 		= create_dataref("laminar/B738/nd/wpt_id02m", "string")
B738DR_wpt_alt02m 		= create_dataref("laminar/B738/nd/wpt_alt02m", "string")
B738DR_wpt_eta02m 		= create_dataref("laminar/B738/nd/wpt_eta02m", "string")
B738DR_wpt_type02 		= create_dataref("laminar/B738/nd/wpt_type02", "number")

B738DR_wpt_id03w 		= create_dataref("laminar/B738/nd/wpt_id03w", "string")
B738DR_wpt_alt03w 		= create_dataref("laminar/B738/nd/wpt_alt03w", "string")
B738DR_wpt_eta03w 		= create_dataref("laminar/B738/nd/wpt_eta03w", "string")
B738DR_wpt_id03m 		= create_dataref("laminar/B738/nd/wpt_id03m", "string")
B738DR_wpt_alt03m 		= create_dataref("laminar/B738/nd/wpt_alt03m", "string")
B738DR_wpt_eta03m 		= create_dataref("laminar/B738/nd/wpt_eta03m", "string")
B738DR_wpt_type03 		= create_dataref("laminar/B738/nd/wpt_type03", "number")

B738DR_wpt_id04w 		= create_dataref("laminar/B738/nd/wpt_id04w", "string")
B738DR_wpt_alt04w 		= create_dataref("laminar/B738/nd/wpt_alt04w", "string")
B738DR_wpt_eta04w 		= create_dataref("laminar/B738/nd/wpt_eta04w", "string")
B738DR_wpt_id04m 		= create_dataref("laminar/B738/nd/wpt_id04m", "string")
B738DR_wpt_alt04m 		= create_dataref("laminar/B738/nd/wpt_alt04m", "string")
B738DR_wpt_eta04m 		= create_dataref("laminar/B738/nd/wpt_eta04m", "string")
B738DR_wpt_type04 		= create_dataref("laminar/B738/nd/wpt_type04", "number")

B738DR_wpt_id05w 		= create_dataref("laminar/B738/nd/wpt_id05w", "string")
B738DR_wpt_alt05w 		= create_dataref("laminar/B738/nd/wpt_alt05w", "string")
B738DR_wpt_eta05w 		= create_dataref("laminar/B738/nd/wpt_eta05w", "string")
B738DR_wpt_id05m 		= create_dataref("laminar/B738/nd/wpt_id05m", "string")
B738DR_wpt_alt05m 		= create_dataref("laminar/B738/nd/wpt_alt05m", "string")
B738DR_wpt_eta05m 		= create_dataref("laminar/B738/nd/wpt_eta05m", "string")
B738DR_wpt_type05 		= create_dataref("laminar/B738/nd/wpt_type05", "number")

B738DR_wpt_id06w 		= create_dataref("laminar/B738/nd/wpt_id06w", "string")
B738DR_wpt_alt06w 		= create_dataref("laminar/B738/nd/wpt_alt06w", "string")
B738DR_wpt_eta06w 		= create_dataref("laminar/B738/nd/wpt_eta06w", "string")
B738DR_wpt_id06m 		= create_dataref("laminar/B738/nd/wpt_id06m", "string")
B738DR_wpt_alt06m 		= create_dataref("laminar/B738/nd/wpt_alt06m", "string")
B738DR_wpt_eta06m 		= create_dataref("laminar/B738/nd/wpt_eta06m", "string")
B738DR_wpt_type06 		= create_dataref("laminar/B738/nd/wpt_type06", "number")

B738DR_wpt_id07w 		= create_dataref("laminar/B738/nd/wpt_id07w", "string")
B738DR_wpt_alt07w 		= create_dataref("laminar/B738/nd/wpt_alt07w", "string")
B738DR_wpt_eta07w 		= create_dataref("laminar/B738/nd/wpt_eta07w", "string")
B738DR_wpt_id07m 		= create_dataref("laminar/B738/nd/wpt_id07m", "string")
B738DR_wpt_alt07m 		= create_dataref("laminar/B738/nd/wpt_alt07m", "string")
B738DR_wpt_eta07m 		= create_dataref("laminar/B738/nd/wpt_eta07m", "string")
B738DR_wpt_type07 		= create_dataref("laminar/B738/nd/wpt_type07", "number")

B738DR_wpt_id08w 		= create_dataref("laminar/B738/nd/wpt_id08w", "string")
B738DR_wpt_alt08w 		= create_dataref("laminar/B738/nd/wpt_alt08w", "string")
B738DR_wpt_eta08w 		= create_dataref("laminar/B738/nd/wpt_eta08w", "string")
B738DR_wpt_id08m 		= create_dataref("laminar/B738/nd/wpt_id08m", "string")
B738DR_wpt_alt08m 		= create_dataref("laminar/B738/nd/wpt_alt08m", "string")
B738DR_wpt_eta08m 		= create_dataref("laminar/B738/nd/wpt_eta08m", "string")
B738DR_wpt_type08 		= create_dataref("laminar/B738/nd/wpt_type08", "number")

B738DR_wpt_id09w 		= create_dataref("laminar/B738/nd/wpt_id09w", "string")
B738DR_wpt_alt09w 		= create_dataref("laminar/B738/nd/wpt_alt09w", "string")
B738DR_wpt_eta09w 		= create_dataref("laminar/B738/nd/wpt_eta09w", "string")
B738DR_wpt_id09m 		= create_dataref("laminar/B738/nd/wpt_id09m", "string")
B738DR_wpt_alt09m 		= create_dataref("laminar/B738/nd/wpt_alt09m", "string")
B738DR_wpt_eta09m 		= create_dataref("laminar/B738/nd/wpt_eta09m", "string")
B738DR_wpt_type09 		= create_dataref("laminar/B738/nd/wpt_type09", "number")

B738DR_wpt_id10w 		= create_dataref("laminar/B738/nd/wpt_id10w", "string")
B738DR_wpt_alt10w 		= create_dataref("laminar/B738/nd/wpt_alt10w", "string")
B738DR_wpt_eta10w 		= create_dataref("laminar/B738/nd/wpt_eta10w", "string")
B738DR_wpt_id10m 		= create_dataref("laminar/B738/nd/wpt_id10m", "string")
B738DR_wpt_alt10m 		= create_dataref("laminar/B738/nd/wpt_alt10m", "string")
B738DR_wpt_eta10m 		= create_dataref("laminar/B738/nd/wpt_eta10m", "string")
B738DR_wpt_type10 		= create_dataref("laminar/B738/nd/wpt_type10", "number")

B738DR_wpt_id11w 		= create_dataref("laminar/B738/nd/wpt_id11w", "string")
B738DR_wpt_alt11w 		= create_dataref("laminar/B738/nd/wpt_alt11w", "string")
B738DR_wpt_eta11w 		= create_dataref("laminar/B738/nd/wpt_eta11w", "string")
B738DR_wpt_id11m 		= create_dataref("laminar/B738/nd/wpt_id11m", "string")
B738DR_wpt_alt11m 		= create_dataref("laminar/B738/nd/wpt_alt11m", "string")
B738DR_wpt_eta11m 		= create_dataref("laminar/B738/nd/wpt_eta11m", "string")
B738DR_wpt_type11 		= create_dataref("laminar/B738/nd/wpt_type11", "number")

B738DR_wpt_id12w 		= create_dataref("laminar/B738/nd/wpt_id12w", "string")
B738DR_wpt_alt12w 		= create_dataref("laminar/B738/nd/wpt_alt12w", "string")
B738DR_wpt_eta12w 		= create_dataref("laminar/B738/nd/wpt_eta12w", "string")
B738DR_wpt_id12m 		= create_dataref("laminar/B738/nd/wpt_id12m", "string")
B738DR_wpt_alt12m 		= create_dataref("laminar/B738/nd/wpt_alt12m", "string")
B738DR_wpt_eta12m 		= create_dataref("laminar/B738/nd/wpt_eta12m", "string")
B738DR_wpt_type12 		= create_dataref("laminar/B738/nd/wpt_type12", "number")

B738DR_wpt_id13w 		= create_dataref("laminar/B738/nd/wpt_id13w", "string")
B738DR_wpt_alt13w 		= create_dataref("laminar/B738/nd/wpt_alt13w", "string")
B738DR_wpt_eta13w 		= create_dataref("laminar/B738/nd/wpt_eta13w", "string")
B738DR_wpt_id13m 		= create_dataref("laminar/B738/nd/wpt_id13m", "string")
B738DR_wpt_alt13m 		= create_dataref("laminar/B738/nd/wpt_alt13m", "string")
B738DR_wpt_eta13m 		= create_dataref("laminar/B738/nd/wpt_eta13m", "string")
B738DR_wpt_type13 		= create_dataref("laminar/B738/nd/wpt_type13", "number")

B738DR_wpt_id14w 		= create_dataref("laminar/B738/nd/wpt_id14w", "string")
B738DR_wpt_alt14w 		= create_dataref("laminar/B738/nd/wpt_alt14w", "string")
B738DR_wpt_eta14w 		= create_dataref("laminar/B738/nd/wpt_eta14w", "string")
B738DR_wpt_id14m 		= create_dataref("laminar/B738/nd/wpt_id14m", "string")
B738DR_wpt_alt14m 		= create_dataref("laminar/B738/nd/wpt_alt14m", "string")
B738DR_wpt_eta14m 		= create_dataref("laminar/B738/nd/wpt_eta14m", "string")
B738DR_wpt_type14 		= create_dataref("laminar/B738/nd/wpt_type14", "number")

B738DR_wpt_id15w 		= create_dataref("laminar/B738/nd/wpt_id15w", "string")
B738DR_wpt_alt15w 		= create_dataref("laminar/B738/nd/wpt_alt15w", "string")
B738DR_wpt_eta15w 		= create_dataref("laminar/B738/nd/wpt_eta15w", "string")
B738DR_wpt_id15m 		= create_dataref("laminar/B738/nd/wpt_id15m", "string")
B738DR_wpt_alt15m 		= create_dataref("laminar/B738/nd/wpt_alt15m", "string")
B738DR_wpt_eta15m 		= create_dataref("laminar/B738/nd/wpt_eta15m", "string")
B738DR_wpt_type15 		= create_dataref("laminar/B738/nd/wpt_type15", "number")

B738DR_wpt_id16w 		= create_dataref("laminar/B738/nd/wpt_id16w", "string")
B738DR_wpt_alt16w 		= create_dataref("laminar/B738/nd/wpt_alt16w", "string")
B738DR_wpt_eta16w 		= create_dataref("laminar/B738/nd/wpt_eta16w", "string")
B738DR_wpt_id16m 		= create_dataref("laminar/B738/nd/wpt_id16m", "string")
B738DR_wpt_alt16m 		= create_dataref("laminar/B738/nd/wpt_alt16m", "string")
B738DR_wpt_eta16m 		= create_dataref("laminar/B738/nd/wpt_eta16m", "string")
B738DR_wpt_type16 		= create_dataref("laminar/B738/nd/wpt_type16", "number")

B738DR_wpt_id17w 		= create_dataref("laminar/B738/nd/wpt_id17w", "string")
B738DR_wpt_alt17w 		= create_dataref("laminar/B738/nd/wpt_alt17w", "string")
B738DR_wpt_eta17w 		= create_dataref("laminar/B738/nd/wpt_eta17w", "string")
B738DR_wpt_id17m 		= create_dataref("laminar/B738/nd/wpt_id17m", "string")
B738DR_wpt_alt17m 		= create_dataref("laminar/B738/nd/wpt_alt17m", "string")
B738DR_wpt_eta17m 		= create_dataref("laminar/B738/nd/wpt_eta17m", "string")
B738DR_wpt_type17 		= create_dataref("laminar/B738/nd/wpt_type17", "number")

B738DR_wpt_id18w 		= create_dataref("laminar/B738/nd/wpt_id18w", "string")
B738DR_wpt_alt18w 		= create_dataref("laminar/B738/nd/wpt_alt18w", "string")
B738DR_wpt_eta18w 		= create_dataref("laminar/B738/nd/wpt_eta18w", "string")
B738DR_wpt_id18m 		= create_dataref("laminar/B738/nd/wpt_id18m", "string")
B738DR_wpt_alt18m 		= create_dataref("laminar/B738/nd/wpt_alt18m", "string")
B738DR_wpt_eta18m 		= create_dataref("laminar/B738/nd/wpt_eta18m", "string")
B738DR_wpt_type18 		= create_dataref("laminar/B738/nd/wpt_type18", "number")

B738DR_wpt_id19w 		= create_dataref("laminar/B738/nd/wpt_id19w", "string")
B738DR_wpt_alt19w 		= create_dataref("laminar/B738/nd/wpt_alt19w", "string")
B738DR_wpt_eta19w 		= create_dataref("laminar/B738/nd/wpt_eta19w", "string")
B738DR_wpt_id19m 		= create_dataref("laminar/B738/nd/wpt_id19m", "string")
B738DR_wpt_alt19m 		= create_dataref("laminar/B738/nd/wpt_alt19m", "string")
B738DR_wpt_eta19m 		= create_dataref("laminar/B738/nd/wpt_eta19m", "string")
B738DR_wpt_type19 		= create_dataref("laminar/B738/nd/wpt_type19", "number")

-- ROUTEs
B738DR_rte_x	 		= create_dataref("laminar/B738/nd/rte_x", "array[20]")
B738DR_rte_y	 		= create_dataref("laminar/B738/nd/rte_y", "array[20]")
B738DR_rte_rot	 		= create_dataref("laminar/B738/nd/rte_rot", "array[20]")
B738DR_rte_dist	 		= create_dataref("laminar/B738/nd/rte_dist", "array[20]")
B738DR_rte_show			= create_dataref("laminar/B738/nd/rte_show", "array[20]")

B738DR_rte_x_act	 	= create_dataref("laminar/B738/nd/rte_x_act", "number")
B738DR_rte_y_act	 	= create_dataref("laminar/B738/nd/rte_y_act", "number")
B738DR_rte_rot_act	 	= create_dataref("laminar/B738/nd/rte_rot_act", "number")
B738DR_rte_dist_act	 	= create_dataref("laminar/B738/nd/rte_dist_act", "number")
B738DR_rte_show_act		= create_dataref("laminar/B738/nd/rte_show_act", "number")

-- T/C
B738DR_tc_x 			= create_dataref("laminar/B738/nd/tc_x", "number")
B738DR_tc_y 			= create_dataref("laminar/B738/nd/tc_y", "number")
B738DR_tc_id 			= create_dataref("laminar/B738/nd/tc_id", "string")
B738DR_tc_show 			= create_dataref("laminar/B738/nd/tc_show", "number")

-- T/D
B738DR_td_x 			= create_dataref("laminar/B738/nd/td_x", "number")
B738DR_td_y 			= create_dataref("laminar/B738/nd/td_y", "number")
B738DR_td_id 			= create_dataref("laminar/B738/nd/td_id", "string")
B738DR_td_show 			= create_dataref("laminar/B738/nd/td_show", "number")

-- DECEL
B738DR_decel_x 			= create_dataref("laminar/B738/nd/decel_x", "number")
B738DR_decel_y 			= create_dataref("laminar/B738/nd/decel_y", "number")
B738DR_decel_id 		= create_dataref("laminar/B738/nd/decel_id", "string")
B738DR_decel_show 		= create_dataref("laminar/B738/nd/decel_show", "number")


B738DR_rest_wpt_spd_id 		= create_dataref("laminar/B738/fms/rest_wpt_spd_id", "string")
B738DR_rest_wpt_spd 		= create_dataref("laminar/B738/fms/rest_wpt_spd", "number")
B738DR_rest_wpt_spd_idx		= create_dataref("laminar/B738/fms/rest_wpt_spd_idx", "number")

B738DR_rest_wpt_alt_id 		= create_dataref("laminar/B738/fms/rest_wpt_alt_id", "string")
B738DR_rest_wpt_alt 		= create_dataref("laminar/B738/fms/rest_wpt_alt", "number")
B738DR_rest_wpt_alt_t 		= create_dataref("laminar/B738/fms/rest_wpt_alt_t", "number")
B738DR_rest_wpt_alt_idx		= create_dataref("laminar/B738/fms/rest_wpt_alt_idx", "number")
B738DR_rest_wpt_alt_dist	= create_dataref("laminar/B738/fms/rest_wpt_alt_dist", "number")

B738DR_calc_wpt_spd 		= create_dataref("laminar/B738/fms/calc_wpt_spd", "number")
B738DR_calc_wpt_alt 		= create_dataref("laminar/B738/fms/calc_wpt_alt", "number")

id_ed						= create_dataref("laminar/B738/fms/id_ed", "string")
idx_ed						= create_dataref("laminar/B738/fms/idx_ed", "number")
alt_ed 						= create_dataref("laminar/B738/fms/alt_ed", "number")
alt_type_ed 				= create_dataref("laminar/B738/fms/alt_type_ed", "number")
ed_dist						= create_dataref("laminar/B738/fms/ed_dist", "number")
td_dist						= create_dataref("laminar/B738/fms/td_dist", "number")

ed_alt						= create_dataref("laminar/B738/fms/ed_alt", "number")
ed_found					= create_dataref("laminar/B738/fms/ed_idx", "number")
ed_to_dist					= create_dataref("laminar/B738/fms/ed_to_dist", "number")


-- AUTOPILOT
offset						= create_dataref("laminar/B738/fms/vnav_idx", "number")
--B738DR_lnav_dist_next		= create_dataref("laminar/B738/fms/lnav_dist_next", "number")
simDR_fmc_dist				= create_dataref("laminar/B738/fms/lnav_dist_next", "number")
simDR_fmc_dist2				= create_dataref("laminar/B738/fms/lnav_dist2_next", "number")
simDR_fmc_crs				= create_dataref("laminar/B738/fms/gps_course_degtm", "number")
simDR_fmc_trk				= create_dataref("laminar/B738/fms/gps_track_degtm", "number")
B738DR_fpln_active			= create_dataref("laminar/B738/fms/fpln_acive", "number")
B738DR_fpln_active_fo		= create_dataref("laminar/B738/fms/fpln_acive_fo", "number")
B738DR_fpln_nav_id			= create_dataref("laminar/B738/fms/fpln_nav_id", "string")






td_idx 						= create_dataref("laminar/B738/fms/vnav_td_idx", "number")
tc_idx						= create_dataref("laminar/B738/fms/vnav_tc_idx", "number")
decel_idx					= create_dataref("laminar/B738/fms/vnav_decel_idx", "number")
decel_before_idx			= create_dataref("laminar/B738/fms/vnav_decel_before_idx", "number")
decel_dist					= create_dataref("laminar/B738/fms/vnav_decel_dist", "number")
tc_dist						= create_dataref("laminar/B738/fms/vnav_tc_dist", "number")

td_fix_dist 				= create_dataref("laminar/B738/fms/vnav_td_fix_dist", "number")
td_fix_idx 					= create_dataref("laminar/B738/fms/vnav_td_fix_idx", "number")
ed_fix_found				= create_dataref("laminar/B738/fms/vnav_td_fix_ed", "number")
ed_fix_alt					= create_dataref("laminar/B738/fms/vnav_td_fix_alt", "number")
ed_fix_num					= create_dataref("laminar/B738/fms/vnav_ed_fix_num", "number")


B738DR_vnav_td_dist 		= create_dataref("laminar/B738/fms/vnav_td_dist", "number")
B738DR_vnav_pth_alt			= create_dataref("laminar/B738/fms/vnav_pth_alt", "number")
B738DR_vnav_alt_err			= create_dataref("laminar/B738/fms/vnav_alt_err", "number")
B738DR_vnav_vvi				= create_dataref("laminar/B738/fms/vnav_vvi", "number")
B738DR_vnav_vvi_corr		= create_dataref("laminar/B738/fms/vnav_vvi_corr", "number")
B738DR_vnav_err_pfd			= create_dataref("laminar/B738/fms/vnav_err_pfd", "number")
B738DR_vnav_pth_show		= create_dataref("laminar/B738/fms/vnav_pth_show", "number")


B738DR_gp_vvi				= create_dataref("laminar/B738/fms/gp_vvi", "number")
B738DR_gp_vvi_corr		= create_dataref("laminar/B738/fms/gp_vvi_corr", "number")
B738DR_gp_err_pfd			= create_dataref("laminar/B738/fms/gp_err_pfd", "number")


calc_to_time 				= create_dataref("laminar/B738/fms/calc_to_time", "number")

B738DR_rnav_enable			= create_dataref("laminar/B738/fms/rnav_enable", "number")
rnav_idx_first				= create_dataref("laminar/B738/fms/rnav_idx_first", "number")
rnav_idx_last				= create_dataref("laminar/B738/fms/rnav_idx_last", "number")
rnav_alt					= create_dataref("laminar/B738/fms/rnav_alt", "number")
rnav_vpa					= create_dataref("laminar/B738/fms/rnav_vpa", "number")

B738DR_gp_active			= create_dataref("laminar/B738/fms/vnav_gp_active", "number")

des_icao					= create_dataref("laminar/B738/fms/des_icao", "string")
ils_id						= create_dataref("laminar/B738/fms/ils_id", "string")
ils_freq					= find_dataref("laminar/B738/fms/ils_freq")
ils_course				= find_dataref("laminar/B738/fms/ils_course")

navaid					= create_dataref("laminar/B738/fms/navaid", "string")


B738DR_bank_angle		= create_dataref("laminar/B738/FMS/bank_angle", "number")

B738DR_fms_id_eta		= create_dataref("laminar/B738/fms/id_eta", "number")
B738DR_end_route		= create_dataref("laminar/B738/fms/end_route", "number")
B738DR_no_perf			= create_dataref("laminar/B738/fms/no_perf", "number")


B738DR_pause_td			= create_dataref("laminar/B738/fms/pause_td", "number")
B738DR_lock_idle_thrust	= create_dataref("laminar/B738/fms/lock_idle_thrust", "number")
B738DR_engine_no_running_state = create_dataref("laminar/B738/fms/engine_no_running_state", "number")
B738DR_parkbrake_remove_chock = create_dataref("laminar/B738/fms/parkbrake_remove_chock", "number")
B738DR_toe_brakes_ovr	= create_dataref("laminar/B738/fms/toe_brakes_ovr", "number")
B738DR_throttle_noise	= create_dataref("laminar/B738/fms/throttle_noise", "number")
B738DR_fuelgauge		= create_dataref("laminar/B738/effects/fuelgauge", "number")
B738DR_nosewheel		= create_dataref("laminar/B738/effects/nosewheel", "number")
B738DR_fpln_format		= create_dataref("laminar/B738/fms/fpln_format", "number")

B738_legs_num			= create_dataref("laminar/B738/vnav/legs_num", "number")
B738_legs_num_before	= create_dataref("laminar/B738/vnav/legs_num_before", "number")
B738_legs_num_first		= create_dataref("laminar/B738/vnav/legs_num_first", "number")

B738DR_fpln_dist		= create_dataref("laminar/B738/FMS/fpln_dist", "number")
--dist_dest				= create_dataref("laminar/B738/FMS/fpln_dist", "number")

B738DR_vnav_desc_spd_disable = create_dataref("laminar/B738/fms/vnav_desc_spd_disable", "number")

B738DR_fmc_message 		= create_dataref("laminar/B738/fmc/fmc_message", "number")
B738DR_fmc_message_warn = create_dataref("laminar/B738/fmc/fmc_message_warn", "number")

pfd_cpt_nav_txt1		= create_dataref("laminar/B738/pfd/cpt_nav_txt1", "string")
pfd_cpt_nav_txt2		= create_dataref("laminar/B738/pfd/cpt_nav_txt2", "string")
pfd_fo_nav_txt1			= create_dataref("laminar/B738/pfd/fo_nav_txt1", "string")
pfd_fo_nav_txt2			= create_dataref("laminar/B738/pfd/fo_nav_txt2", "string")

B738DR_rw_wind_dir		= create_dataref("laminar/B738/fms/rw_wind_dir", "number")
B738DR_rw_wind_spd		= create_dataref("laminar/B738/fms/rw_wind_spd", "number")
B738DR_rw_slope			= create_dataref("laminar/B738/fms/rw_slope", "number")
B738DR_rw_hdg			= create_dataref("laminar/B738/fms/rw_hdg", "number")


B738DR_ils_rotate	 	= create_dataref("laminar/B738/pfd/ils_rotate", "number")
B738DR_ils_x	 		= create_dataref("laminar/B738/pfd/ils_x", "number")
B738DR_ils_y	 		= create_dataref("laminar/B738/pfd/ils_y", "number")
B738DR_ils_runway 		= create_dataref("laminar/B738/pfd/ils_runway", "string")
B738DR_ils_show	 		= create_dataref("laminar/B738/pfd/ils_show", "number")
B738DR_ils_copilot_show	= create_dataref("laminar/B738/pfd/ils_copilot_show", "number")

B738DR_ils_rotate0	 		= create_dataref("laminar/B738/pfd/ils_rotate0", "number")
B738DR_ils_x0	 			= create_dataref("laminar/B738/pfd/ils_x0", "number")
B738DR_ils_y0	 			= create_dataref("laminar/B738/pfd/ils_y0", "number")
B738DR_ils_runway0 			= create_dataref("laminar/B738/pfd/ils_runway0", "string")
B738DR_ils_show0	 		= create_dataref("laminar/B738/pfd/ils_show0", "number")
B738DR_ils_copilot_show0	= create_dataref("laminar/B738/pfd/ils_copilot_show0", "number")

B738DR_apt_obj		 		= create_dataref("laminar/B738/nd/apt_enable", "array[30]")
B738DR_apt_x 				= create_dataref("laminar/B738/nd/apt_x", "array[30]")
B738DR_apt_y 				= create_dataref("laminar/B738/nd/apt_y", "array[30]")
B738DR_apt_id00				= create_dataref("laminar/B738/nd/apt_id00", "string")
B738DR_apt_id01				= create_dataref("laminar/B738/nd/apt_id01", "string")
B738DR_apt_id02				= create_dataref("laminar/B738/nd/apt_id02", "string")
B738DR_apt_id03				= create_dataref("laminar/B738/nd/apt_id03", "string")
B738DR_apt_id04				= create_dataref("laminar/B738/nd/apt_id04", "string")
B738DR_apt_id05				= create_dataref("laminar/B738/nd/apt_id05", "string")
B738DR_apt_id06				= create_dataref("laminar/B738/nd/apt_id06", "string")
B738DR_apt_id07				= create_dataref("laminar/B738/nd/apt_id07", "string")
B738DR_apt_id08				= create_dataref("laminar/B738/nd/apt_id08", "string")
B738DR_apt_id09				= create_dataref("laminar/B738/nd/apt_id09", "string")
B738DR_apt_id10				= create_dataref("laminar/B738/nd/apt_id10", "string")
B738DR_apt_id11				= create_dataref("laminar/B738/nd/apt_id11", "string")
B738DR_apt_id12				= create_dataref("laminar/B738/nd/apt_id12", "string")
B738DR_apt_id13				= create_dataref("laminar/B738/nd/apt_id13", "string")
B738DR_apt_id14				= create_dataref("laminar/B738/nd/apt_id14", "string")
B738DR_apt_id15				= create_dataref("laminar/B738/nd/apt_id15", "string")
B738DR_apt_id16				= create_dataref("laminar/B738/nd/apt_id16", "string")
B738DR_apt_id17				= create_dataref("laminar/B738/nd/apt_id17", "string")
B738DR_apt_id18				= create_dataref("laminar/B738/nd/apt_id18", "string")
B738DR_apt_id19				= create_dataref("laminar/B738/nd/apt_id19", "string")
B738DR_apt_id20				= create_dataref("laminar/B738/nd/apt_id20", "string")
B738DR_apt_id21				= create_dataref("laminar/B738/nd/apt_id21", "string")
B738DR_apt_id22				= create_dataref("laminar/B738/nd/apt_id22", "string")
B738DR_apt_id23				= create_dataref("laminar/B738/nd/apt_id23", "string")
B738DR_apt_id24				= create_dataref("laminar/B738/nd/apt_id24", "string")
B738DR_apt_id25				= create_dataref("laminar/B738/nd/apt_id25", "string")
B738DR_apt_id26				= create_dataref("laminar/B738/nd/apt_id26", "string")
B738DR_apt_id27				= create_dataref("laminar/B738/nd/apt_id27", "string")
B738DR_apt_id28				= create_dataref("laminar/B738/nd/apt_id28", "string")
B738DR_apt_id29				= create_dataref("laminar/B738/nd/apt_id29", "string")


B738DR_center_line			= create_dataref("laminar/B738/fms/center_line", "number")

B738DR_fms_light_pilot		= create_dataref("laminar/B738/push_button/fms_light_pilot", "number")
B738DR_fms_light_fo			= create_dataref("laminar/B738/push_button/fms_light_fo", "number")

--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--


function DRindex_DRhandler()end
function decode_value_DRhandler()end
function index_pos_DRhandler()end

function DR_test_DRhandler()end
function DR_test2_DRhandler()end

function B738DR_fms_takeoff_flaps_DRhandler()end
function B738DR_fms_approach_flaps_DRhandler()end
function B738DR_fms_approach_speed_DRhandler()end
function B738DR_fms_approach_wind_corr_DRhandler()end

function B738DR_fms_descent_now_DRhandler()end

function B7368DR_fmc1_show_DRhandler()end

function B738DR_vvi_const_DRhandler()end

function B738DR_found_ils_DRhandler()end
function B738DR_navaid_num_DRhandler()end
function B738DR_found_navaid_DRhandler()end

function B738DR_vnav_disconnect_DRhandler()end
function B738DR_lnav_disconnect_DRhandler()end

function B738DR_chock_status_DRhandler()end


function B738DR_test_DRhandler()end
function B738DR_test1_DRhandler()end

--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--

B738DR_fms_test			= create_dataref("laminar/B738/fms/test", "number", B738DR_test_DRhandler)
B738DR_fms_test1		= create_dataref("laminar/B738/fms/test1", "number", B738DR_test1_DRhandler)


B738DR_chock_status		= create_dataref("laminar/B738/fms/chock_status", "number", B738DR_chock_status_DRhandler)

-- found_ils => 0-no find, 1-find, 2-founded, 3-readed
found_ils			= create_dataref("laminar/B738/fms/found_ils", "number", B738DR_found_ils_DRhandler)
navaid_num			= create_dataref("laminar/B738/fms/navaid_num", "number", B738DR_navaid_num_DRhandler)
found_navaid		= create_dataref("laminar/B738/fms/found_navaid", "number", B738DR_found_navaid_DRhandler)

B738DR_vvi_const	= create_dataref("laminar/B738/fms/vnav_vvi_const", "number", B738DR_vvi_const_DRhandler)

DRindex	= create_dataref("laminar/B738/fmc/vnav/DRindex", "number", DRindex_DRhandler)

decode_value		= create_dataref("laminar/B738/fmc/decode_value", "number", decode_value_DRhandler)
index_pos			= create_dataref("laminar/B738/fmc/index_pos", "number", index_pos_DRhandler)

DR_test				= create_dataref("laminar/B738/fmc/DR_test", "number", DR_test_DRhandler)
DR_test2				= create_dataref("laminar/B738/fmc/DR_test2", "number", DR_test2_DRhandler)


B738DR_fms_takeoff_flaps	= create_dataref("laminar/B738/FMS/takeoff_flaps", "number", B738DR_fms_takeoff_flaps_DRhandler)
B738DR_fms_approach_flaps	= create_dataref("laminar/B738/FMS/approach_flaps", "number", B738DR_fms_approach_flaps_DRhandler)
B738DR_fms_approach_speed		= create_dataref("laminar/B738/FMS/approach_speed", "number", B738DR_fms_approach_speed_DRhandler)
B738DR_fms_approach_wind_corr	= create_dataref("laminar/B738/FMS/approach_wind_corr", "number", B738DR_fms_approach_wind_corr_DRhandler)

B738DR_fms_descent_now		= create_dataref("laminar/B738/FMS/descent_now", "number", B738DR_fms_descent_now_DRhandler)

B7368DR_fmc1_show                   = create_dataref("laminar/B738/fmc1/fmc1_show", "number", B7368DR_fmc1_show_DRhandler)

B738DR_vnav_disconnect		= create_dataref("laminar/B738/fms/vnav_disconnect", "number", B738DR_vnav_disconnect_DRhandler)
B738DR_lnav_disconnect		= create_dataref("laminar/B738/fms/lnav_disconnect", "number", B738DR_lnav_disconnect_DRhandler)

simDR_pos_x		= find_dataref("sim/flightmodel/position/local_x")
simDR_pos_y		= find_dataref("sim/flightmodel/position/local_y")
simDR_pos_z		= find_dataref("sim/flightmodel/position/local_z")
simDR_pos_vx		= find_dataref("sim/flightmodel/position/local_vx")
simDR_pos_vy		= find_dataref("sim/flightmodel/position/local_vy")
simDR_pos_vz		= find_dataref("sim/flightmodel/position/local_vz")
simDR_pos_ax		= find_dataref("sim/flightmodel/position/local_ax")
simDR_pos_ay		= find_dataref("sim/flightmodel/position/local_ay")
simDR_pos_az		= find_dataref("sim/flightmodel/position/local_az")

--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

function B738CMD_chock_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_chock_status == 0 then
			if simDR_on_ground_0 == 1 and simDR_on_ground_1 == 1 and simDR_on_ground_2 == 1 then
				B738DR_chock_status = 1
				chock_pos_x = simDR_pos_x
				chock_pos_y = simDR_pos_y
				chock_pos_z = simDR_pos_z
			end
		else
			B738DR_chock_status = 0
		end
	end
end

function B738CMD_pause_td_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_pause_td == 0 then
			B738DR_pause_td = 1
		else
			B738DR_pause_td = 0
		end
	end
end

function B738_fms_light_pilot_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_light_pilot = 1
		B738DR_fmc_message_warn = 0
	elseif phase == 2 then
		B738DR_fms_light_pilot = 0
	end
end

function B738_fms_light_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_light_fo = 1
		B738DR_fmc_message_warn = 0
	elseif phase == 2 then
		B738DR_fms_light_fo = 0
	end
end

-- --*************************************************************************************--
-- --** 				              CREATE CUSTOM COMMANDS              			     **--
-- --*************************************************************************************--


B738CMD_chock_toggle	= create_command("laminar/B738/toggle_switch/chock", "Chock toggle", B738CMD_chock_toggle_CMDhandler)
B738CMD_pause_td_toggle		= create_command("laminar/B738/toggle_switch/pause_td", "Pause at T/D toggle", B738CMD_pause_td_toggle_CMDhandler)

B738CMD_fms_light_pilot		 	= create_command("laminar/B738/push_button/fms_light_pilot", "FMS light captain button", B738_fms_light_pilot_CMDhandler)
B738CMD_fms_light_fo		 	= create_command("laminar/B738/push_button/fms_light_fo", "FMS light captain button", B738_fms_light_fo_CMDhandler)



-- B738WRP_FMS_key_0	= wrap_command("sim/FMS/key_0", blank, B738WRP_FMS_key_0_WRP)
-- B738WRP_FMS_key_1	= wrap_command("sim/FMS/key_1", blank, B738WRP_FMS_key_1_WRP)
-- B738WRP_FMS_key_2	= wrap_command("sim/FMS/key_2", blank, B738WRP_FMS_key_2_WRP)
-- B738WRP_FMS_key_3	= wrap_command("sim/FMS/key_3", blank, B738WRP_FMS_key_3_WRP)
-- B738WRP_FMS_key_4	= wrap_command("sim/FMS/key_4", blank, B738WRP_FMS_key_4_WRP)
-- B738WRP_FMS_key_5	= wrap_command("sim/FMS/key_5", blank, B738WRP_FMS_key_5_WRP)
-- B738WRP_FMS_key_6	= wrap_command("sim/FMS/key_6", blank, B738WRP_FMS_key_6_WRP)
-- B738WRP_FMS_key_7	= wrap_command("sim/FMS/key_7", blank, B738WRP_FMS_key_7_WRP)
-- B738WRP_FMS_key_8	= wrap_command("sim/FMS/key_8", blank, B738WRP_FMS_key_8_WRP)
-- B738WRP_FMS_key_9	= wrap_command("sim/FMS/key_9", blank, B738WRP_FMS_key_9_WRP)
-- B738WRP_FMS_key_period	= wrap_command("sim/FMS/key_period", blank, B738WRP_FMS_key_period_WRP)
-- B738WRP_FMS_key_slash	= wrap_command("sim/FMS/key_slash", blank, B738WRP_FMS_key_slash_WRP)

-- B738WRP_FMS_key_F	= wrap_command("sim/FMS/key_F", blank, B738WRP_FMS_key_F_WRP)
-- B738WRP_FMS_key_L	= wrap_command("sim/FMS/key_L", blank, B738WRP_FMS_key_L_WRP)

-- B738WRP_FMS_key_clear	= wrap_command("sim/FMS/key_clear", blank, B738WRP_FMS_key_clear_WRP)
-- B738WRP_FMS_key_delete	= wrap_command("sim/FMS/key_delete", blank, B738WRP_FMS_key_delete_WRP)
-- B738WRP_FMS_key_exec	= wrap_command("sim/FMS/exec", blank, B738WRP_FMS_key_exec_WRP)

-- B738WRP_FMS_key_crz		= wrap_command("sim/FMS/crz", blank, B738WRP_FMS_key_crz_WRP)
-- B738WRP_FMS_key_clb		= wrap_command("sim/FMS/clb", blank, B738WRP_FMS_key_clb_WRP)
-- B738WRP_FMS_key_des		= wrap_command("sim/FMS/des", blank, B738WRP_FMS_key_des_WRP)

-- B738WRP_FMS_key_1L		= wrap_command("sim/FMS/ls_1l", blank, B738WRP_FMS_key_1L_WRP)
-- B738WRP_FMS_key_2L		= wrap_command("sim/FMS/ls_2l", blank, B738WRP_FMS_key_2L_WRP)
-- B738WRP_FMS_key_3L		= wrap_command("sim/FMS/ls_3l", blank, B738WRP_FMS_key_3L_WRP)
-- B738WRP_FMS_key_4L		= wrap_command("sim/FMS/ls_4l", blank, B738WRP_FMS_key_4L_WRP)
-- B738WRP_FMS_key_5L		= wrap_command("sim/FMS/ls_5l", blank, B738WRP_FMS_key_5L_WRP)
-- B738WRP_FMS_key_6L		= wrap_command("sim/FMS/ls_6l", blank, B738WRP_FMS_key_6L_WRP)

-- B738WRP_FMS_key_1R		= wrap_command("sim/FMS/ls_1r", blank, B738WRP_FMS_key_1R_WRP)
-- B738WRP_FMS_key_2R		= wrap_command("sim/FMS/ls_2r", blank, B738WRP_FMS_key_2R_WRP)
-- B738WRP_FMS_key_3R		= wrap_command("sim/FMS/ls_3r", blank, B738WRP_FMS_key_3R_WRP)
-- B738WRP_FMS_key_4R		= wrap_command("sim/FMS/ls_4r", blank, B738WRP_FMS_key_4R_WRP)
-- B738WRP_FMS_key_5R		= wrap_command("sim/FMS/ls_5r", blank, B738WRP_FMS_key_5R_WRP)
-- B738WRP_FMS_key_6R		= wrap_command("sim/FMS/ls_6r", blank, B738WRP_FMS_key_6R_WRP)

-- B738WRP_FMS_key_prev		= wrap_command("sim/FMS/prev", blank, B738WRP_FMS_key_prev_WRP)
-- B738WRP_FMS_key_next		= wrap_command("sim/FMS/next", blank, B738WRP_FMS_key_next_WRP)
-- B738WRP_FMS_key_navrad		= wrap_command("sim/FMS/navrad", blank, B738WRP_FMS_key_navrad_WRP)
-- B738WRP_FMS_key_fix			= wrap_command("sim/FMS/fix", blank, B738WRP_FMS_key_fix_WRP)
-- B738WRP_FMS_key_dir_intc	= wrap_command("sim/FMS/dir_intc", blank, B738WRP_FMS_key_dir_intc_WRP)
-- B738WRP_FMS_key_legs		= wrap_command("sim/FMS/legs", blank, B738WRP_FMS_key_legs_WRP)
-- B738WRP_FMS_key_fpln		= wrap_command("sim/FMS/fpln", blank, B738WRP_FMS_key_fpln_WRP)
-- B738WRP_FMS_key_index		= wrap_command("sim/FMS/index", blank, B738WRP_FMS_key_index_WRP)
-- B738WRP_FMS_key_dep_arr		= wrap_command("sim/FMS/dep_arr", blank, B738WRP_FMS_key_dep_arr_WRP)
-- B738WRP_FMS_key_hold		= wrap_command("sim/FMS/hold", blank, B738WRP_FMS_key_hold_WRP)
-- B738WRP_FMS_key_prog		= wrap_command("sim/FMS/prog", blank, B738WRP_FMS_key_prog_WRP)

--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--



function type_to_fmc(input_txt)

	local scratch = ""
	local lenght = string.len(input_txt)
	local i = 0
	
	for i = 1, lenght do
		scratch = string.sub(input_txt,i,i)
		if scratch == "0" then
			simCMD_FMS_key_0:once()
		elseif scratch == "1" then
			simCMD_FMS_key_1:once()
		elseif scratch == "2" then
			simCMD_FMS_key_2:once()
		elseif scratch == "3" then
			simCMD_FMS_key_3:once()
		elseif scratch == "4" then
			simCMD_FMS_key_4:once()
		elseif scratch == "5" then
			simCMD_FMS_key_5:once()
		elseif scratch == "6" then
			simCMD_FMS_key_6:once()
		elseif scratch == "7" then
			simCMD_FMS_key_7:once()
		elseif scratch == "8" then
			simCMD_FMS_key_8:once()
		elseif scratch == "9" then
			simCMD_FMS_key_9:once()
		elseif scratch == "." then
			simCMD_FMS_key_period:once()
		elseif scratch == "A" then
			simCMD_FMS_key_A:once()
		elseif scratch == "B" then
			simCMD_FMS_key_B:once()
		elseif scratch == "C" then
			simCMD_FMS_key_C:once()
		elseif scratch == "D" then
			simCMD_FMS_key_D:once()
		elseif scratch == "E" then
			simCMD_FMS_key_E:once()
		elseif scratch == "F" then
			simCMD_FMS_key_F:once()
		elseif scratch == "G" then
			simCMD_FMS_key_G:once()
		elseif scratch == "H" then
			simCMD_FMS_key_H:once()
		elseif scratch == "I" then
			simCMD_FMS_key_I:once()
		elseif scratch == "J" then
			simCMD_FMS_key_J:once()
		elseif scratch == "K" then
			simCMD_FMS_key_K:once()
		elseif scratch == "L" then
			simCMD_FMS_key_L:once()
		elseif scratch == "M" then
			simCMD_FMS_key_M:once()
		elseif scratch == "N" then
			simCMD_FMS_key_N:once()
		elseif scratch == "O" then
			simCMD_FMS_key_O:once()
		elseif scratch == "P" then
			simCMD_FMS_key_P:once()
		elseif scratch == "Q" then
			simCMD_FMS_key_Q:once()
		elseif scratch == "R" then
			simCMD_FMS_key_R:once()
		elseif scratch == "S" then
			simCMD_FMS_key_S:once()
		elseif scratch == "T" then
			simCMD_FMS_key_T:once()
		elseif scratch == "U" then
			simCMD_FMS_key_U:once()
		elseif scratch == "V" then
			simCMD_FMS_key_V:once()
		elseif scratch == "W" then
			simCMD_FMS_key_W:once()
		elseif scratch == "X" then
			simCMD_FMS_key_X:once()
		elseif scratch == "Y" then
			simCMD_FMS_key_Y:once()
		elseif scratch == "Z" then
			simCMD_FMS_key_Z:once()
		elseif scratch == "/" then
			simCMD_FMS_key_slash:once()
		end
	end


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


function B738_set_anim_value2(current_value, target, min, max, speed, limit)

    local mmm = 0
	if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        mmm = math.abs((target - current_value) * (speed * SIM_PERIOD))
		if mmm > limit then
			if target > current_value then
				return current_value + limit
			else
				return current_value - limit
			end
		else
			return current_value + ((target - current_value) * (speed * SIM_PERIOD))
		end
    end

end

----- RESCALE FLOAT AND CLAMP TO OUTER LIMITS -------------------------------------------

function B738_rescale(in1, out1, in2, out2, x)
    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)
end


function Angle180(angle)
    return (angle + 180) % 360
end



function spaces_before(strings, max_num)
	local temp_strings = ""
	local num_strings = string.len(strings)
	local num1 = 0
	
	if num_strings > max_num then
		return string.sub(strings, 1, max_num)
	else
		if num_strings == max_num then
			return strings
		else
			temp_strings = strings
			for num1 = num_strings, max_num do
				temp_strings = " " .. temp_strings
			end
			return temp_strings
		end
	
	end
end

function spaces_after(strings, max_num)
	local temp_strings = ""
	local num_strings = string.len(strings)
	local num1 = 0
	
	if num_strings > max_num then
		return string.sub(strings, 1, max_num)
	else
		if num_strings == max_num then
			return strings
		else
			temp_strings = strings
			for num1 = num_strings, max_num do
				temp_strings = temp_strings .. " "
			end
			return temp_strings
		end
	
	end
end


function wind_alt_order()

	local swap_alt = ""
	local swap_alt_num = 0
	local swap_dir = ""
	local swap_spd = ""
	
	if forec_alt_2_num > forec_alt_1_num then
		-- swap 2 - 1
		swap_alt = forec_alt_2
		swap_alt_num = forec_alt_2_num
		swap_dir = forec_dir_2
		swap_spd = forec_spd_2
		forec_alt_2 = forec_alt_1
		forec_alt_2_num = forec_alt_1_num
		forec_dir_2 = forec_dir_1
		forec_spd_2 = forec_spd_1
		forec_alt_1 = swap_alt
		forec_alt_1_num = swap_alt_num
		forec_dir_1 = swap_dir
		forec_spd_1 = swap_spd
	end
	if forec_alt_3_num > forec_alt_2_num then
		if forec_alt_3_num > forec_alt_1_num then
			-- swap 3 - 1
			swap_alt = forec_alt_3
			swap_alt_num = forec_alt_3_num
			swap_dir = forec_dir_3
			swap_spd = forec_spd_3
			forec_alt_3 = forec_alt_1
			forec_alt_3_num = forec_alt_1_num
			forec_dir_3 = forec_dir_1
			forec_spd_3 = forec_spd_1
			forec_alt_1 = swap_alt
			forec_alt_1_num = swap_alt_num
			forec_dir_1 = swap_dir
			forec_spd_1 = swap_spd
			-- swap 3 - 2
			swap_alt = forec_alt_3
			swap_alt_num = forec_alt_3_num
			swap_dir = forec_dir_3
			swap_spd = forec_spd_3
			forec_alt_3 = forec_alt_2
			forec_alt_3_num = forec_alt_2_num
			forec_dir_3 = forec_dir_2
			forec_spd_3 = forec_spd_2
			forec_alt_2 = swap_alt
			forec_alt_2_num = swap_alt_num
			forec_dir_2 = swap_dir
			forec_spd_2 = swap_spd
		else
		-- swap 3 - 2
			swap_alt = forec_alt_3
			swap_alt_num = forec_alt_3_num
			swap_dir = forec_dir_3
			swap_spd = forec_spd_3
			forec_alt_3 = forec_alt_2
			forec_alt_3_num = forec_alt_2_num
			forec_dir_3 = forec_dir_2
			forec_spd_3 = forec_spd_2
			forec_alt_2 = swap_alt
			forec_alt_2_num = swap_alt_num
			forec_dir_2 = swap_dir
			forec_spd_2 = swap_spd
		end
	end

end


function read_navdata()
	
	local line = "" 	--{}
	local i = 0
	local j = 0
	local k = 0
	local build = ""
	local cycle = ""
	local line_trim = ""
	local line_char = ""
	local line_lenght = 0
	local old_lat = ""
	local old_lon = ""
	local old_id = ""
	local old_freq = ""
	local old_icao = ""
	local old_type = 0
	local skip = 0
	local words = {}
	
	file_name = "Custom Data/earth_nav.dat"
	file_navdata = io.open(file_name, "r")
	if file_navdata == nil then
		file_name = "Resources/default data/earth_nav.dat"
		file_navdata = io.open(file_name, "r")
		if file_navdata == nil then
			--B738_navdata = ""
			--B738_navdata_active = ""
		else
			-- looking for AIRAC
			line = file_navdata:read()
			while line do
				i,j = string.find(line, "cycle ")
				if i ~= nil then
					break
				end
				line = file_navdata:read()
			end
			if i ~= nil then
				cycle = string.sub(line, (j+1), (j+4))
				i,j = string.find(line, "build ")
				build = string.sub(line, (j+1), (j+8))
				--B738_navdata = string.sub(build, 3, 8) .. cycle
				-- looking for NAV
				line = file_navdata:read()
				while line do
					i = 0
					j = 0
					line_trim = ""
					line_char = ""
					line_lenght = string.len(line)
					if line_lenght > 0 then
						for k = 1, line_lenght do
							line_char = string.sub(line, k, k)
							if line_char == " " then
								if i == 1 then
									j = j + 1
									words[j] = line_trim
									i = 0
									line_trim = ""
								end
							else
								line_trim = line_trim .. line_char
								i = 1
							end
						end
						if string.len(line_trim) > 0 then
							j = j + 1
							words[j] = line_trim
						end
						if j > 11 then
							
							
							
							-- ILS navaids
							if words[1] == "4" then
								ils_nav_num = ils_nav_num + 1
								ils_nav[ils_nav_num] = {}
								ils_nav[ils_nav_num][1] = words[8]				--id
								ils_nav[ils_nav_num][2] = tonumber(words[2]) 	--lat
								ils_nav[ils_nav_num][3] = tonumber(words[3]) 	--lon
								ils_nav[ils_nav_num][4] = words[11] 			--runway
								ils_nav[ils_nav_num][5] = tonumber(words[7])	--course
								ils_nav[ils_nav_num][6] = tonumber(words[5]) 	--frequency
								ils_nav[ils_nav_num][7] = words[9] 				--ICAO
							end
							
							
							
							if old_id == words[8] and old_freq == words[5] then
								if old_type == 1 and words[1] == "12" then -- VOR-DME, VORTAG
									earth_nav[earth_nav_num][1] = 2
									old_type = 2
								end
							end
							if old_type == 5 and words[1] == "12" and old_icao == words[9] then -- ILS -> APT
								skip = 1
							elseif old_type == 5 and words[1] == "6" and old_icao == words[9] then -- ILS -> APT
								skip = 1
							elseif old_type == 5 and words[1] == "4" and old_icao == words[9] then -- ILS -> APT
								skip = 1
							end
							if skip == 1 then
								skip = 0
								old_id = words[8]
								old_freq = words[5]
								old_icao = words[9]
							else
								if words[1] == "3" then	-- VOR
									earth_nav_num = earth_nav_num + 1
									earth_nav[earth_nav_num] = {}  		--new row
									earth_nav[earth_nav_num][1] = 1			--type 1-VOR
									earth_nav[earth_nav_num][2] = tonumber(words[2])  --lat
									earth_nav[earth_nav_num][3] = tonumber(words[3])  --lon
									earth_nav[earth_nav_num][4] = words[8]  --id
									earth_nav[earth_nav_num][5] = words[9]  --ICAO
									earth_nav[earth_nav_num][6] = words[5] --freq
									earth_nav[earth_nav_num][7] = words[11] --name
									earth_nav[earth_nav_num][8] = words[10] --reg_code
									old_type = 1
									old_freq = words[5]
									old_icao = "" --words[9]
									old_id = words[8]
								elseif words[1] == "2" then	-- NDB
									earth_nav_num = earth_nav_num + 1
									earth_nav[earth_nav_num] = {}  		--new row
									earth_nav[earth_nav_num][1] = 3			--type 3-NDB
									earth_nav[earth_nav_num][2] = tonumber(words[2])  --lat
									earth_nav[earth_nav_num][3] = tonumber(words[3])  --lon
									earth_nav[earth_nav_num][4] = words[8]  --id
									earth_nav[earth_nav_num][5] = words[9]  --ICAO
									earth_nav[earth_nav_num][6] = words[5] --freq
									earth_nav[earth_nav_num][7] = words[11] --name
									earth_nav[earth_nav_num][8] = words[10] --reg_code
									old_type = 3
									old_freq = words[5]
									old_icao = "" --words[9]
									old_id = words[8]
								end
							end
						--------
						end
					end
					line = file_navdata:read()
					------------
				end
			end
			file_navdata:close()
			-- fixes
			file_name = "Resources/default data/earth_fix.dat"
			file_navdata = io.open(file_name, "r")
			if file_navdata ~= nil then
				-- looking for fix
				line = file_navdata:read()
				line = file_navdata:read()
				line = file_navdata:read()
				while line do
					i = 0
					j = 0
					line_trim = ""
					line_char = ""
					line_lenght = string.len(line)
					if line_lenght > 0 then
						for k = 1, line_lenght do
							line_char = string.sub(line, k, k)
							if line_char == " " then
								if i == 1 then
									j = j + 1
									words[j] = line_trim
									i = 0
									line_trim = ""
								end
							else
								line_trim = line_trim .. line_char
								i = 1
							end
						end
						if string.len(line_trim) > 0 then
							j = j + 1
							words[j] = line_trim
						end
						if j > 4 then
							earth_nav_num = earth_nav_num + 1
							earth_nav[earth_nav_num] = {}  		--new row
							earth_nav[earth_nav_num][1] = 4			--type 4-FIX
							earth_nav[earth_nav_num][2] = tonumber(words[1])  --lat
							earth_nav[earth_nav_num][3] = tonumber(words[2])  --lon
							earth_nav[earth_nav_num][4] = words[3]  --id
							earth_nav[earth_nav_num][5] = words[4]  --ICAO
							earth_nav[earth_nav_num][6] = "" --freq
							earth_nav[earth_nav_num][7] = "" --name
							earth_nav[earth_nav_num][8] = words[5] --reg_code
						end
					end
					line = file_navdata:read()
				end
				file_navdata:close()
			end
		end
	else
		-- looking for AIRAC
		line = file_navdata:read()
		while line do
			i,j = string.find(line, "cycle ")
			if i ~= nil then
				break
			end
			line = file_navdata:read()
		end
		if i ~= nil then
			cycle = string.sub(line, (j+1), (j+4))
			i,j = string.find(line, "build ")
			build = string.sub(line, (j+1), (j+8))
			--B738_navdata = string.sub(build, 3, 8) .. cycle
			-- looking for NAV
			line = file_navdata:read()
			while line do
				i = 0
				j = 0
				line_trim = ""
				line_char = ""
				line_lenght = string.len(line)
				if line_lenght > 0 then
					for k = 1, line_lenght do
						line_char = string.sub(line, k, k)
						if line_char == " " then
							if i == 1 then
								j = j + 1
								words[j] = line_trim
								i = 0
								line_trim = ""
							end
						else
							line_trim = line_trim .. line_char
							i = 1
						end
					end
					if string.len(line_trim) > 0 then
						j = j + 1
						words[j] = line_trim
					end
					if j > 11 then
						
						
						
						-- ILS navaids
						if words[1] == "4" then
							ils_nav_num = ils_nav_num + 1
							ils_nav[ils_nav_num] = {}
							ils_nav[ils_nav_num][1] = words[8]				--id
							ils_nav[ils_nav_num][2] = tonumber(words[2]) 	--lat
							ils_nav[ils_nav_num][3] = tonumber(words[3]) 	--lon
							ils_nav[ils_nav_num][4] = words[11] 			--runway
							ils_nav[ils_nav_num][5] = tonumber(words[7])	--course
							ils_nav[ils_nav_num][6] = tonumber(words[5]) 	--frequency
							ils_nav[ils_nav_num][7] = words[9] 				--ICAO
						end
						
						
						
						if old_id == words[8] and old_freq == words[5] then
							if old_type == 1 and words[1] == "12" then -- VOR-DME, VORTAG
								earth_nav[earth_nav_num][1] = 2
								old_type = 2
							end
						end
						if old_type == 5 and words[1] == "12" and old_icao == words[9] then -- ILS -> APT
							skip = 1
						elseif old_type == 5 and words[1] == "6" and old_icao == words[9] then -- ILS -> APT
							skip = 1
						elseif old_type == 5 and words[1] == "4" and old_icao == words[9] then -- ILS -> APT
							skip = 1
						end
						if skip == 1 then
							skip = 0
							old_id = words[8]
							old_freq = words[5]
							old_icao = words[9]
						else
							if words[1] == "3" then	-- VOR
								earth_nav_num = earth_nav_num + 1
								earth_nav[earth_nav_num] = {}  		--new row
								earth_nav[earth_nav_num][1] = 1			--type 1-VOR
								earth_nav[earth_nav_num][2] = tonumber(words[2])  --lat
								earth_nav[earth_nav_num][3] = tonumber(words[3])  --lon
								earth_nav[earth_nav_num][4] = words[8]  --id
								earth_nav[earth_nav_num][5] = words[9]  --ICAO
								earth_nav[earth_nav_num][6] = words[5] --freq
								earth_nav[earth_nav_num][7] = words[11] --name
								earth_nav[earth_nav_num][8] = words[10] --reg_code
								old_type = 1
								old_freq = words[5]
								old_icao = "" --words[9]
								old_id = words[8]
							elseif words[1] == "2" then	-- NDB
								earth_nav_num = earth_nav_num + 1
								earth_nav[earth_nav_num] = {}  		--new row
								earth_nav[earth_nav_num][1] = 3			--type 3-NDB
								earth_nav[earth_nav_num][2] = tonumber(words[2])  --lat
								earth_nav[earth_nav_num][3] = tonumber(words[3])  --lon
								earth_nav[earth_nav_num][4] = words[8]  --id
								earth_nav[earth_nav_num][5] = words[9]  --ICAO
								earth_nav[earth_nav_num][6] = words[5] --freq
								earth_nav[earth_nav_num][7] = words[11] --name
								earth_nav[earth_nav_num][8] = words[10] --reg_code
								old_type = 3
								old_freq = words[5]
								old_icao = "" --words[9]
								old_id = words[8]
							end
						end
					--------
					end
				end
				line = file_navdata:read()
				------------
			end
		end
		file_navdata:close()
		-- fixes
		file_name = "Custom Data/earth_fix.dat"
		file_navdata = io.open(file_name, "r")
		if file_navdata ~= nil then
			-- looking for fix
			line = file_navdata:read()
			line = file_navdata:read()
			line = file_navdata:read()
			while line do
				i = 0
				j = 0
				line_trim = ""
				line_char = ""
				line_lenght = string.len(line)
				if line_lenght > 0 then
					for k = 1, line_lenght do
						line_char = string.sub(line, k, k)
						if line_char == " " then
							if i == 1 then
								j = j + 1
								words[j] = line_trim
								i = 0
								line_trim = ""
							end
						else
							line_trim = line_trim .. line_char
							i = 1
						end
					end
					if string.len(line_trim) > 0 then
						j = j + 1
						words[j] = line_trim
					end
					if j > 4 then
						earth_nav_num = earth_nav_num + 1
						earth_nav[earth_nav_num] = {}  		--new row
						earth_nav[earth_nav_num][1] = 4			--type 4-FIX
						earth_nav[earth_nav_num][2] = tonumber(words[1])  --lat
						earth_nav[earth_nav_num][3] = tonumber(words[2])  --lon
						earth_nav[earth_nav_num][4] = words[3]  --id
						earth_nav[earth_nav_num][5] = words[4]  --ICAO
						earth_nav[earth_nav_num][6] = "" --freq
						earth_nav[earth_nav_num][7] = "" --name
						earth_nav[earth_nav_num][8] = words[5] --reg_code
					end
				end
				line = file_navdata:read()
			end
			file_navdata:close()
		end
	end
end


function detect_apt_dat()

	local navdata_ok = 1
	local apt_line = ""
	
	local file_navdata_log = io.open("Log.txt", "r")
	if file_navdata_log ~= nil then
		log_line = file_navdata_log:read()
	end
	file_navdata_log:close()

	local file_navdata2 = io.open("Output/FMS plans/B738X_apt.dat", "r")
	if file_navdata2 == nil then
		navdata_ok = 0
	else
		apt_line = file_navdata2:read()
		file_navdata2:close()
		if apt_line ~= log_line then
			navdata_ok = 0
		end
	end
	
	local file_navdata3 = io.open("Output/FMS plans/B738X_rnw.dat", "r")
	if file_navdata3 == nil then
		navdata_ok = 0
	else
		apt_line = file_navdata3:read()
		file_navdata3:close()
		if apt_line ~= log_line then
			navdata_ok = 0
		end
	end
	
	if navdata_ok == 0 then
		create_apt_rnw_dat2()
	end
	
end

function create_apt_rnw_dat()

	local apt_line = ""
	local apt_word = {}
	local ii = 0
	local jj = 0
	local kk = 0
	local ll = 0
	local mm = 0
	local token = ""
	local line_trim = ""
	local line_char = ""
	local line_lenght = 0
	local save_airport = 0
	
	local apt_icao = ""
	local apt_lat = "0"
	local apt_lon = "0"
	local apt_tns_alt = "0"
	local apt_tns_lvl = "0"
	local apt_rnw0 = ""
	local apt_rnw_lat0 = ""
	local apt_rnw_lon0 = ""
	local apt_rnw1 = ""
	local apt_rnw_lat1 = ""
	local apt_rnw_lon1 = ""
	local apt_rnw_lenght = "0"
	local num_rnw = 0
	local apt_rnw = {}
	local apt_rnw_lat_start = {}
	local apt_rnw_lon_start = {}
	local apt_rnw_lat_end = {}
	local apt_rnw_lon_end = {}
	local apt_len = {}
	local apt_rnw_crs = {}
	local apt_idx = {}
	
	local sort_rnw = ""
	local sort_rnw_lat_start = ""
	local sort_rnw_lon_start = ""
	local sort_rnw_lat_end = ""
	local sort_rnw_lon_end = ""
	local sort_len = ""
	local sort_rnw_crs = ""
	local sort_idx = 0
	local temp_idx = 0
	
	local lat_temp = "0"
	local lon_temp = "0"
	local longest_rnw = 0
	
	local nd_lat = 0
	local nd_lon = 0
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_x = 0
	local nd_y = 0
	local nd_dis = 0
	local nd_hdg = 0

	local fms_line = ""

	
	local apt_file_name = "Resources/default scenery/default apt dat/Earth nav data/apt.dat"
	local file_aptdata = io.open(apt_file_name, "r")
	if file_aptdata ~= nil then
		
		local file_navdata2 = io.open("Output/FMS plans/B738X_apt.dat", "w")
		if file_navdata2 == nil then
			file_aptdata:close()
			return
		end
		
		local file_navdata3 = io.open("Output/FMS plans/B738X_rnw.dat", "w")
		if file_navdata3 == nil then
			file_navdata2:close()
			file_aptdata:close()
			return
		end
		
		if log_line ~= nil then
			fms_line = log_line .. "\n"
			file_navdata2:write(fms_line)
			file_navdata3:write(fms_line)
			fms_line = ""
		end
		
		apt_line = file_aptdata:read()
		while apt_line do
			ii = 0
			jj = 0
			line_trim = ""
			line_char = ""
			line_lenght = string.len(apt_line)
			if line_lenght > 0 then
				for kk = 1, line_lenght do
					line_char = string.sub(apt_line, kk, kk)
					if line_char == " " then
						if ii == 1 then
							jj = jj + 1
							apt_word[jj] = line_trim
							ii = 0
							line_trim = ""
						end
					else
						line_trim = line_trim .. line_char
						ii = 1
					end
				end
				if string.len(line_trim) > 0 then
					jj = jj + 1
					apt_word[jj] = line_trim
				end
				
				-- Read airport datum_lat, datum_lon
				if jj == 3 then
					if apt_word[1] == "1302" and  apt_word[2] == "datum_lat" then
						lat_temp = apt_word[3]
					end
					if apt_word[1] == "1302" and  apt_word[2] == "datum_lon" then
						lon_temp = apt_word[3]
					end
				end
				
				if jj > 1 then		--new airport
					
					if apt_word[1] == "1302" and  apt_word[2] == "icao_code" then
						if save_airport == 1 then
							save_airport = 0
							--if apt_lat ~= "0" then
								-- Write B738X_apt.dat
								fms_line = apt_icao .. " " .. apt_lat .. " " .. apt_lon .. " " .. apt_tns_alt .. " " .. apt_tns_lvl
								fms_line = fms_line .. " " .. tostring(longest_rnw) .. "\n"
								file_navdata2:write(fms_line)
								
								-- Write B738X_rnw.dat
								if num_rnw > 1 then
									-- Sort runways
									for kk = 1, num_rnw - 1 do
										mm = kk + 1 
										for ll = mm, num_rnw do
											if apt_idx[kk] > apt_idx[ll] then
												sort_rnw = apt_rnw[kk]
												sort_rnw_lat_start = apt_rnw_lat_start[kk]
												sort_rnw_lon_start = apt_rnw_lon_start[kk]
												sort_rnw_lat_end = apt_rnw_lat_end[kk]
												sort_rnw_lon_end = apt_rnw_lon_end[kk]
												sort_len = apt_len[kk]
												sort_idx = apt_idx[kk]
												sort_rnw_crs = apt_rnw_crs[kk]
												apt_rnw[kk] = apt_rnw[ll]
												apt_rnw_lat_start[kk] = apt_rnw_lat_start[ll]
												apt_rnw_lon_start[kk] = apt_rnw_lon_start[ll]
												apt_rnw_lat_end[kk] = apt_rnw_lat_end[ll]
												apt_rnw_lon_end[kk] = apt_rnw_lon_end[ll]
												apt_len[kk] = apt_len[ll]
												apt_idx[kk] = apt_idx[ll]
												apt_rnw_crs[kk] = apt_rnw_crs[ll]
												apt_rnw[ll] = sort_rnw
												apt_rnw_lat_start[ll] = sort_rnw_lat_start
												apt_rnw_lon_start[ll] = sort_rnw_lon_start
												apt_rnw_lat_end[ll] = sort_rnw_lat_end
												apt_rnw_lon_end[ll] = sort_rnw_lon_end
												apt_len[ll] = sort_len
												apt_rnw_crs[ll] = sort_rnw_crs
												apt_idx[ll] = sort_idx
											end
										end
									end
									for kk = 1, num_rnw do
										fms_line = apt_icao .. " " .. apt_rnw[kk] .. " " .. apt_rnw_lat_start[kk] .. " " .. apt_rnw_lon_start[kk] .. " "
										fms_line = fms_line .. apt_rnw_lat_end[kk] .. " " .. apt_rnw_lon_end[kk] .. " " .. apt_len[kk] .. " "
										fms_line = fms_line .. apt_rnw_crs[kk] .. "\n"
										file_navdata3:write(fms_line)
									end
								end
							--end
							------------
							apt_icao = ""
							apt_lat = "0"
							apt_lon = "0"
							apt_tns_alt = "0"
							apt_tns_lvl = "0"
							apt_rnw0 = ""
							apt_rnw1 = ""
							apt_rnw_lat0 = ""
							apt_rnw_lon0 = ""
							apt_rnw_lat1 = ""
							apt_rnw_lon1 = ""
							apt_rnw_lenght = "0"
							num_rnw = 0
							apt_rnw = {}
							apt_rnw_lat_start = {}
							apt_rnw_lon_start = {}
							apt_rnw_lat_end = {}
							apt_rnw_lon_end = {}
							apt_len = {}
							apt_rnw_crs = {}
							apt_idx = {}
							longest_rnw = 0
						end
						if jj == 3 then
							save_airport = 1
							apt_icao = apt_word[3]
							apt_lat = lat_temp
							apt_lon = lon_temp
						end
						lat_temp = "0"
						lon_temp = "0"
					end
				end
				
				-- Read runway data
				if save_airport == 1 then
					if jj == 3 then
						if apt_word[1] == "1302" and  apt_word[2] == "transition_alt" then
							apt_tns_alt = apt_word[3]
						end
						if apt_word[1] == "1302" and  apt_word[2] == "transition_level" then
							apt_tns_lvl = apt_word[3]
						end
					end
					if jj > 0 then
						if apt_word[1] == "100" then
							apt_rnw0 = apt_word[9]
							apt_rnw_lat0 = apt_word[10]
							apt_rnw_lon0 = apt_word[11]
							apt_rnw1 = apt_word[18]
							apt_rnw_lat1 = apt_word[19]
							apt_rnw_lon1 = apt_word[20]
							-- calc runway lenght
							
							nd_lat = math.rad(tonumber(apt_rnw_lat0))
							nd_lon = math.rad(tonumber(apt_rnw_lon0))
							nd_lat2 = math.rad(tonumber(apt_rnw_lat1))
							nd_lon2 = math.rad(tonumber(apt_rnw_lon1))
							
							nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
							nd_y = nd_lat2 - nd_lat
							nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	-- in nm
							nd_dis = nd_dis * 1852	-- in m
							nd_dis = math.floor(nd_dis + 0.5)
							
							nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
							nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
							nd_hdg = math.atan2(nd_y, nd_x)
							nd_hdg = math.deg(nd_hdg)
							--nd_hdg = math.floor(nd_hdg + 0.5)
							nd_hdg = (nd_hdg + 360) % 360
							
							apt_rnw_lenght = tostring(nd_dis)
							num_rnw = num_rnw + 1
							apt_rnw[num_rnw] = apt_rnw0
							apt_rnw_lat_start[num_rnw] = apt_rnw_lat0
							apt_rnw_lon_start[num_rnw] = apt_rnw_lon0
							apt_rnw_lat_end[num_rnw] = apt_rnw_lat1
							apt_rnw_lon_end[num_rnw] = apt_rnw_lon1
							apt_len[num_rnw] = apt_rnw_lenght
							apt_rnw_crs[num_rnw] = tostring(nd_hdg)
							
							temp_idx = tonumber(apt_rnw0)
							if temp_idx == nil then
								temp_idx = tonumber(string.sub(apt_rnw0, 1, -2))
								if temp_idx == nil then
									apt_idx[num_rnw] = 0
								else
									apt_idx[num_rnw] = temp_idx
								end
								if string.sub(apt_rnw0, -1, -1) == "L" then
									apt_idx[num_rnw] = apt_idx[num_rnw] + 0.3
								elseif string.sub(apt_rnw0, -1, -1) == "R" then
									apt_idx[num_rnw] = apt_idx[num_rnw] + 0.7
								end
							else
								apt_idx[num_rnw] = temp_idx
							end
							
							num_rnw = num_rnw + 1
							nd_hdg = (nd_hdg + 180) % 360
							apt_rnw[num_rnw] = apt_rnw1
							apt_rnw_lat_start[num_rnw] = apt_rnw_lat1
							apt_rnw_lon_start[num_rnw] = apt_rnw_lon1
							apt_rnw_lat_end[num_rnw] = apt_rnw_lat0
							apt_rnw_lon_end[num_rnw] = apt_rnw_lon0
							apt_len[num_rnw] = apt_rnw_lenght
							apt_rnw_crs[num_rnw] = tostring(nd_hdg)
							temp_idx = tonumber(apt_rnw1)
							if temp_idx == nil then
								temp_idx = tonumber(string.sub(apt_rnw1, 1, -2))
								if temp_idx == nil then
									apt_idx[num_rnw] = 0
								else
									apt_idx[num_rnw] = temp_idx
								end
								if string.sub(apt_rnw1, -1, -1) == "L" then
									apt_idx[num_rnw] = apt_idx[num_rnw] + 0.3
								elseif string.sub(apt_rnw1, -1, -1) == "R" then
									apt_idx[num_rnw] = apt_idx[num_rnw] + 0.7
								end
							else
								apt_idx[num_rnw] = temp_idx
							end
							if longest_rnw < nd_dis then
								longest_rnw = nd_dis
							end
						end
					end
				end
				
				-- END OF FILE
				if jj > 0 then
					if apt_word[1] == "99" then
						if save_airport == 1 then
							save_airport = 0
							--if apt_lat ~= "0" then
								-- Write B738X_apt.dat
								fms_line = apt_icao .. " " .. apt_lat .. " " .. apt_lon .. " " .. apt_tns_alt .. " " .. apt_tns_lvl
								fms_line = fms_line .. " " .. tostring(longest_rnw) .. "\n"
								file_navdata2:write(fms_line)
								
								-- Write B738X_rnw.dat
								if num_rnw > 1 then
									-- Sort runways
									for kk = 1, num_rnw - 1 do
										mm = kk + 1
										for ll = mm, num_rnw do
											if apt_idx[kk] < apt_idx[ll] then
												sort_rnw = apt_rnw[kk]
												sort_rnw_lat_start = apt_rnw_lat_start[kk]
												sort_rnw_lon_start = apt_rnw_lon_start[kk]
												sort_rnw_lat_end = apt_rnw_lat_end[kk]
												sort_rnw_lon_end = apt_rnw_lon_end[kk]
												sort_len = apt_len[kk]
												sort_idx = apt_idx[kk]
												sort_rnw_crs = apt_rnw_crs[kk]
												apt_rnw[kk] = apt_rnw[ll]
												apt_rnw_lat_start[kk] = apt_rnw_lat_start[ll]
												apt_rnw_lon_start[kk] = apt_rnw_lon_start[ll]
												apt_rnw_lat_end[kk] = apt_rnw_lat_end[ll]
												apt_rnw_lon_end[kk] = apt_rnw_lon_end[ll]
												apt_len[kk] = apt_len[ll]
												apt_idx[kk] = apt_idx[ll]
												apt_rnw_crs[kk] = apt_rnw_crs[ll]
												apt_rnw[ll] = sort_rnw
												apt_rnw_lat_start[ll] = sort_rnw_lat_start
												apt_rnw_lon_start[ll] = sort_rnw_lon_start
												apt_rnw_lat_end[ll] = sort_rnw_lat_end
												apt_rnw_lon_end[ll] = sort_rnw_lon_end
												apt_len[ll] = sort_len
												apt_rnw_crs[ll] = sort_rnw_crs
												apt_idx[ll] = sort_idx
											end
										end
									end
									for kk = 1, num_rnw do
										fms_line = apt_icao .. " " .. apt_rnw[kk] .. " " .. apt_rnw_lat_start[kk] .. " " .. apt_rnw_lon_start[kk] .. " "
										fms_line = fms_line .. apt_rnw_lat_end[kk] .. " " .. apt_rnw_lon_end[kk] .. " " .. apt_len[kk] .. " "
										fms_line = fms_line .. apt_rnw_crs[kk] .. "\n"
										file_navdata3:write(fms_line)
									end
								end
							--end
							------------
							apt_icao = ""
							apt_lat = "0"
							apt_lon = "0"
							apt_tns_alt = "0"
							apt_tns_lvl = "0"
							apt_rnw0 = ""
							apt_rnw1 = ""
							apt_rnw_lat0 = ""
							apt_rnw_lon0 = ""
							apt_rnw_lat1 = ""
							apt_rnw_lon1 = ""
							apt_rnw_lenght = "0"
							num_rnw = 0
							apt_rnw = {}
							apt_rnw_lat_start = {}
							apt_rnw_lon_start = {}
							apt_rnw_lat_end = {}
							apt_rnw_lon_end = {}
							apt_len = {}
							apt_rnw_crs = {}
							apt_idx = {}
							longest_rnw = 0
						end
					end
				end
			end
			apt_line = file_aptdata:read()
		end
		file_aptdata:close()
		file_navdata2:close()
		file_navdata3:close()
	end

end

function create_apt_rnw_dat2()

	local apt_line = ""
	local apt_word = {}
	local ii = 0
	local jj = 0
	local kk = 0
	local ll = 0
	local mm = 0
	local token = ""
	local line_trim = ""
	local line_char = ""
	local line_lenght = 0
	
	local apt_icao = ""
	local apt_lat = "0"
	local apt_lon = "0"
	local apt_tns_alt = "0"
	local apt_tns_lvl = "0"
	local apt_rnw0 = ""
	local apt_rnw_lat0 = ""
	local apt_rnw_lon0 = ""
	local apt_rnw1 = ""
	local apt_rnw_lat1 = ""
	local apt_rnw_lon1 = ""
	local apt_rnw_lenght = "0"
	local num_rnw = 0
	local apt_rnw = {}
	local apt_rnw_lat_start = {}
	local apt_rnw_lon_start = {}
	local apt_rnw_lat_end = {}
	local apt_rnw_lon_end = {}
	local apt_len = {}
	local apt_rnw_crs = {}
	local apt_idx = {}
	
	local sort_rnw = ""
	local sort_rnw_lat_start = ""
	local sort_rnw_lon_start = ""
	local sort_rnw_lat_end = ""
	local sort_rnw_lon_end = ""
	local sort_len = ""
	local sort_rnw_crs = ""
	local sort_idx = 0
	local temp_idx = 0
	
	local lat_temp = "0"
	local lon_temp = "0"
	local longest_rnw = 0
	
	local nd_lat = 0
	local nd_lon = 0
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_x = 0
	local nd_y = 0
	local nd_dis = 0
	local nd_hdg = 0

	local fms_line = ""

	
	local apt_file_name = "Resources/default scenery/default apt dat/Earth nav data/apt.dat"
	local file_aptdata = io.open(apt_file_name, "r")
	if file_aptdata ~= nil then
		
		local file_navdata2 = io.open("Output/FMS plans/B738X_apt.dat", "w")
		if file_navdata2 == nil then
			file_aptdata:close()
			return
		end
		
		local file_navdata3 = io.open("Output/FMS plans/B738X_rnw.dat", "w")
		if file_navdata3 == nil then
			file_navdata2:close()
			file_aptdata:close()
			return
		end
		
		if log_line ~= nil then
			fms_line = log_line .. "\n"
			file_navdata2:write(fms_line)
			file_navdata3:write(fms_line)
			fms_line = ""
		end
		
		apt_line = file_aptdata:read()
		while apt_line do
			ii = 0
			jj = 0
			line_trim = ""
			line_char = ""
			line_lenght = string.len(apt_line)
			if line_lenght > 0 then
				for kk = 1, line_lenght do
					line_char = string.sub(apt_line, kk, kk)
					if line_char == " " then
						if ii == 1 then
							jj = jj + 1
							apt_word[jj] = line_trim
							ii = 0
							line_trim = ""
						end
					else
						line_trim = line_trim .. line_char
						ii = 1
					end
				end
				if string.len(line_trim) > 0 then
					jj = jj + 1
					apt_word[jj] = line_trim
				end
				
				-- Read airport datum_lat, datum_lon
				
				if jj > 5 then		--new airport
					
					if apt_word[1] == "1" or apt_word[1] == "16" or apt_word[1] == "17" then
						if apt_icao ~= "" then
							-- Write B738X_apt.dat
							fms_line = apt_icao .. " " .. apt_lat .. " " .. apt_lon .. " " .. apt_tns_alt .. " " .. apt_tns_lvl
							fms_line = fms_line .. " " .. tostring(longest_rnw) .. "\n"
							file_navdata2:write(fms_line)
							
							-- Write B738X_rnw.dat
							if num_rnw > 1 then
								-- Sort runways
								for kk = 1, num_rnw - 1 do
									mm = kk + 1 
									for ll = mm, num_rnw do
										if apt_idx[kk] > apt_idx[ll] then
											sort_rnw = apt_rnw[kk]
											sort_rnw_lat_start = apt_rnw_lat_start[kk]
											sort_rnw_lon_start = apt_rnw_lon_start[kk]
											sort_rnw_lat_end = apt_rnw_lat_end[kk]
											sort_rnw_lon_end = apt_rnw_lon_end[kk]
											sort_len = apt_len[kk]
											sort_idx = apt_idx[kk]
											sort_rnw_crs = apt_rnw_crs[kk]
											apt_rnw[kk] = apt_rnw[ll]
											apt_rnw_lat_start[kk] = apt_rnw_lat_start[ll]
											apt_rnw_lon_start[kk] = apt_rnw_lon_start[ll]
											apt_rnw_lat_end[kk] = apt_rnw_lat_end[ll]
											apt_rnw_lon_end[kk] = apt_rnw_lon_end[ll]
											apt_len[kk] = apt_len[ll]
											apt_idx[kk] = apt_idx[ll]
											apt_rnw_crs[kk] = apt_rnw_crs[ll]
											apt_rnw[ll] = sort_rnw
											apt_rnw_lat_start[ll] = sort_rnw_lat_start
											apt_rnw_lon_start[ll] = sort_rnw_lon_start
											apt_rnw_lat_end[ll] = sort_rnw_lat_end
											apt_rnw_lon_end[ll] = sort_rnw_lon_end
											apt_len[ll] = sort_len
											apt_rnw_crs[ll] = sort_rnw_crs
											apt_idx[ll] = sort_idx
										end
									end
								end
								for kk = 1, num_rnw do
									fms_line = apt_icao .. " " .. apt_rnw[kk] .. " " .. apt_rnw_lat_start[kk] .. " " .. apt_rnw_lon_start[kk] .. " "
									fms_line = fms_line .. apt_rnw_lat_end[kk] .. " " .. apt_rnw_lon_end[kk] .. " " .. apt_len[kk] .. " "
									fms_line = fms_line .. apt_rnw_crs[kk] .. "\n"
									file_navdata3:write(fms_line)
								end
							end
						end
						
						apt_icao = ""
						apt_lat = "0"
						apt_lon = "0"
						apt_tns_alt = "0"
						apt_tns_lvl = "0"
						apt_rnw0 = ""
						apt_rnw1 = ""
						apt_rnw_lat0 = ""
						apt_rnw_lon0 = ""
						apt_rnw_lat1 = ""
						apt_rnw_lon1 = ""
						apt_rnw_lenght = "0"
						num_rnw = 0
						apt_rnw = {}
						apt_rnw_lat_start = {}
						apt_rnw_lon_start = {}
						apt_rnw_lat_end = {}
						apt_rnw_lon_end = {}
						apt_len = {}
						apt_rnw_crs = {}
						apt_idx = {}
						longest_rnw = 0
						
					end
				end
				
				if jj == 3 then
					if apt_word[1] == "1302" and apt_word[2] == "datum_lat" then
						lat_temp = apt_word[3]
					end
					if apt_word[1] == "1302" and apt_word[2] == "datum_lon" then
						lon_temp = apt_word[3]
					end
					if apt_word[1] == "1302" and apt_word[2] == "transition_alt" then
						apt_tns_alt = apt_word[3]
					end
					if apt_word[1] == "1302" and apt_word[2] == "transition_level" then
						apt_tns_lvl = apt_word[3]
					end
				end
				
				if apt_word[1] == "1302" and  apt_word[2] == "icao_code" then
					if jj == 3 then
						--save_airport = 1
						apt_icao = apt_word[3]
						apt_lat = lat_temp
						apt_lon = lon_temp
					end
					lat_temp = "0"
					lon_temp = "0"
				end
				
				
				-- Read runway data
				if jj > 0 then
					if apt_word[1] == "100" then
						apt_rnw0 = apt_word[9]
						apt_rnw_lat0 = apt_word[10]
						apt_rnw_lon0 = apt_word[11]
						apt_rnw1 = apt_word[18]
						apt_rnw_lat1 = apt_word[19]
						apt_rnw_lon1 = apt_word[20]
						-- calc runway lenght
						
						nd_lat = math.rad(tonumber(apt_rnw_lat0))
						nd_lon = math.rad(tonumber(apt_rnw_lon0))
						nd_lat2 = math.rad(tonumber(apt_rnw_lat1))
						nd_lon2 = math.rad(tonumber(apt_rnw_lon1))
						
						nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
						nd_y = nd_lat2 - nd_lat
						nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	-- in nm
						nd_dis = nd_dis * 1852	-- in m
						nd_dis = math.floor(nd_dis + 0.5)
						
						nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
						nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
						nd_hdg = math.atan2(nd_y, nd_x)
						nd_hdg = math.deg(nd_hdg)
						--nd_hdg = math.floor(nd_hdg + 0.5)
						nd_hdg = (nd_hdg + 360) % 360
						
						apt_rnw_lenght = tostring(nd_dis)
						num_rnw = num_rnw + 1
						apt_rnw[num_rnw] = apt_rnw0
						apt_rnw_lat_start[num_rnw] = apt_rnw_lat0
						apt_rnw_lon_start[num_rnw] = apt_rnw_lon0
						apt_rnw_lat_end[num_rnw] = apt_rnw_lat1
						apt_rnw_lon_end[num_rnw] = apt_rnw_lon1
						apt_len[num_rnw] = apt_rnw_lenght
						apt_rnw_crs[num_rnw] = tostring(nd_hdg)
						
						temp_idx = tonumber(apt_rnw0)
						if temp_idx == nil then
							temp_idx = tonumber(string.sub(apt_rnw0, 1, -2))
							if temp_idx == nil then
								apt_idx[num_rnw] = 0
							else
								apt_idx[num_rnw] = temp_idx
							end
							if string.sub(apt_rnw0, -1, -1) == "L" then
								apt_idx[num_rnw] = apt_idx[num_rnw] + 0.3
							elseif string.sub(apt_rnw0, -1, -1) == "R" then
								apt_idx[num_rnw] = apt_idx[num_rnw] + 0.7
							end
						else
							apt_idx[num_rnw] = temp_idx
						end
						
						num_rnw = num_rnw + 1
						nd_hdg = (nd_hdg + 180) % 360
						apt_rnw[num_rnw] = apt_rnw1
						apt_rnw_lat_start[num_rnw] = apt_rnw_lat1
						apt_rnw_lon_start[num_rnw] = apt_rnw_lon1
						apt_rnw_lat_end[num_rnw] = apt_rnw_lat0
						apt_rnw_lon_end[num_rnw] = apt_rnw_lon0
						apt_len[num_rnw] = apt_rnw_lenght
						apt_rnw_crs[num_rnw] = tostring(nd_hdg)
						temp_idx = tonumber(apt_rnw1)
						if temp_idx == nil then
							temp_idx = tonumber(string.sub(apt_rnw1, 1, -2))
							if temp_idx == nil then
								apt_idx[num_rnw] = 0
							else
								apt_idx[num_rnw] = temp_idx
							end
							if string.sub(apt_rnw1, -1, -1) == "L" then
								apt_idx[num_rnw] = apt_idx[num_rnw] + 0.3
							elseif string.sub(apt_rnw1, -1, -1) == "R" then
								apt_idx[num_rnw] = apt_idx[num_rnw] + 0.7
							end
						else
							apt_idx[num_rnw] = temp_idx
						end
						if longest_rnw < nd_dis then
							longest_rnw = nd_dis
						end
					end
				end
				
				-- END OF FILE
				if jj > 0 then
					if apt_word[1] == "99" then
						if apt_word[1] == "1" or apt_word[1] == "16" or apt_word[1] == "17" then
							if apt_icao ~= "" then
								-- Write B738X_apt.dat
								fms_line = apt_icao .. " " .. apt_lat .. " " .. apt_lon .. " " .. apt_tns_alt .. " " .. apt_tns_lvl
								fms_line = fms_line .. " " .. tostring(longest_rnw) .. "\n"
								file_navdata2:write(fms_line)
								
								-- Write B738X_rnw.dat
								if num_rnw > 1 then
									-- Sort runways
									for kk = 1, num_rnw - 1 do
										mm = kk + 1
										for ll = mm, num_rnw do
											if apt_idx[kk] < apt_idx[ll] then
												sort_rnw = apt_rnw[kk]
												sort_rnw_lat_start = apt_rnw_lat_start[kk]
												sort_rnw_lon_start = apt_rnw_lon_start[kk]
												sort_rnw_lat_end = apt_rnw_lat_end[kk]
												sort_rnw_lon_end = apt_rnw_lon_end[kk]
												sort_len = apt_len[kk]
												sort_idx = apt_idx[kk]
												sort_rnw_crs = apt_rnw_crs[kk]
												apt_rnw[kk] = apt_rnw[ll]
												apt_rnw_lat_start[kk] = apt_rnw_lat_start[ll]
												apt_rnw_lon_start[kk] = apt_rnw_lon_start[ll]
												apt_rnw_lat_end[kk] = apt_rnw_lat_end[ll]
												apt_rnw_lon_end[kk] = apt_rnw_lon_end[ll]
												apt_len[kk] = apt_len[ll]
												apt_idx[kk] = apt_idx[ll]
												apt_rnw_crs[kk] = apt_rnw_crs[ll]
												apt_rnw[ll] = sort_rnw
												apt_rnw_lat_start[ll] = sort_rnw_lat_start
												apt_rnw_lon_start[ll] = sort_rnw_lon_start
												apt_rnw_lat_end[ll] = sort_rnw_lat_end
												apt_rnw_lon_end[ll] = sort_rnw_lon_end
												apt_len[ll] = sort_len
												apt_rnw_crs[ll] = sort_rnw_crs
												apt_idx[ll] = sort_idx
											end
										end
									end
									for kk = 1, num_rnw do
										fms_line = apt_icao .. " " .. apt_rnw[kk] .. " " .. apt_rnw_lat_start[kk] .. " " .. apt_rnw_lon_start[kk] .. " "
										fms_line = fms_line .. apt_rnw_lat_end[kk] .. " " .. apt_rnw_lon_end[kk] .. " " .. apt_len[kk] .. " "
										fms_line = fms_line .. apt_rnw_crs[kk] .. "\n"
										file_navdata3:write(fms_line)
									end
								end
							end
							------------
							apt_icao = ""
							apt_lat = "0"
							apt_lon = "0"
							apt_tns_alt = "0"
							apt_tns_lvl = "0"
							apt_rnw0 = ""
							apt_rnw1 = ""
							apt_rnw_lat0 = ""
							apt_rnw_lon0 = ""
							apt_rnw_lat1 = ""
							apt_rnw_lon1 = ""
							apt_rnw_lenght = "0"
							num_rnw = 0
							apt_rnw = {}
							apt_rnw_lat_start = {}
							apt_rnw_lon_start = {}
							apt_rnw_lat_end = {}
							apt_rnw_lon_end = {}
							apt_len = {}
							apt_rnw_crs = {}
							apt_idx = {}
							longest_rnw = 0
						end
					end
				end
			end
			apt_line = file_aptdata:read()
		end
		file_aptdata:close()
		file_navdata2:close()
		file_navdata3:close()
	end

end


function read_apt_dat()

	local ii = 0
	local jj = 0
	local kk = 0
	local line_trim = ""
	local line_char = ""
	local line_lenght = 0
	local apt_line = ""
	local apt_word = {}
	
	local apt_first = 0
	
	apt_data_num = 0
	apt_data = {}
	
	local file_navdata2 = io.open("Output/FMS plans/B738X_apt.dat", "r")
	if file_navdata2 ~= nil then
		apt_line = file_navdata2:read()
		while apt_line do
			if apt_first ~= 0 then
				ii = 0
				jj = 0
				line_trim = ""
				line_char = ""
				line_lenght = string.len(apt_line)
				if line_lenght > 0 then
					for kk = 1, line_lenght do
						line_char = string.sub(apt_line, kk, kk)
						if line_char == " " then
							if ii == 1 then
								jj = jj + 1
								apt_word[jj] = line_trim
								ii = 0
								line_trim = ""
							end
						else
							line_trim = line_trim .. line_char
							ii = 1
						end
					end
					if string.len(line_trim) > 0 then
						jj = jj + 1
						apt_word[jj] = line_trim
					end
					
					if jj == 6 then
						apt_data_num = apt_data_num + 1
						apt_data[apt_data_num] = {}
						apt_data[apt_data_num][1] = apt_word[1]		-- ICAO
						apt_data[apt_data_num][2] = tonumber(apt_word[2])		-- lat
						apt_data[apt_data_num][3] = tonumber(apt_word[3])		-- lon
						apt_data[apt_data_num][4] = tonumber(apt_word[4])		-- trans alt
						apt_data[apt_data_num][5] = tonumber(apt_word[5])		-- trans lvl
						apt_data[apt_data_num][6] = tonumber(apt_word[6])		-- longest rnw
					end
				end
			end
			apt_first = 1
			apt_line = file_navdata2:read()
		end
		file_navdata2:close()
	end

end

function read_rnw_dat()

	local ii = 0
	local jj = 0
	local kk = 0
	local line_trim = ""
	local line_char = ""
	local line_lenght = 0
	local apt_line = ""
	local apt_word = {}
	
	local apt_first = 0
	
	local file_navdata2 = io.open("Output/FMS plans/B738X_rnw.dat", "r")
	if file_navdata2 ~= nil then
		apt_line = file_navdata2:read()
		while apt_line do
			if apt_first ~= 0 then
				ii = 0
				jj = 0
				line_trim = ""
				line_char = ""
				line_lenght = string.len(apt_line)
				if line_lenght > 0 then
					for kk = 1, line_lenght do
						line_char = string.sub(apt_line, kk, kk)
						if line_char == " " then
							if ii == 1 then
								jj = jj + 1
								apt_word[jj] = line_trim
								ii = 0
								line_trim = ""
							end
						else
							line_trim = line_trim .. line_char
							ii = 1
						end
					end
					if string.len(line_trim) > 0 then
						jj = jj + 1
						apt_word[jj] = line_trim
					end
					
					if jj == 8 then
						rnw_data_num = rnw_data_num + 1
						rnw_data[rnw_data_num] = {}
						rnw_data[rnw_data_num][1] = apt_word[1]		-- ICAO
						rnw_data[rnw_data_num][2] = apt_word[2]		-- runway
						rnw_data[rnw_data_num][3] = tonumber(apt_word[3])		-- lat start
						rnw_data[rnw_data_num][4] = tonumber(apt_word[4])		-- lon start
						rnw_data[rnw_data_num][5] = tonumber(apt_word[5])		-- lat end
						rnw_data[rnw_data_num][6] = tonumber(apt_word[6])		-- lon end
						rnw_data[rnw_data_num][7] = tonumber(apt_word[7])		-- lenght
						rnw_data[rnw_data_num][8] = tonumber(apt_word[8])		-- course
					end
				end
			end
			apt_first = 1
			apt_line = file_navdata2:read()
		end
		file_navdata2:close()
		
	end

end


function read_awy_dat()

	local ii = 0
	local jj = 0
	local kk = 0
	local ll = 0
	local line_trim = ""
	local line_char = ""
	local line_lenght = 0
	local apt_line = ""
	local apt_word = {}
	
	local apt_first = 0
	local awy_temp = ""
	local awy_tempx = ""
	local awy_skip = 0
	local awy_skip_txt = ""
	local awy_skip_txt2 = ""
	
	awy_data_num = 0
	awy_data = {}
	
	local file_navdata2 = io.open("Custom Data/earth_awy.dat", "r")
	if file_navdata2 == nil then
		file_navdata2 = io.open("Resources/default data/earth_awy.dat", "r")
		if file_navdata2 == nil then
			return
		end
	end
	
	-- read data
	apt_line = file_navdata2:read()
	while apt_line do
		space_first = 0
		if apt_first ~= 0 then
			ii = 0
			jj = 0
			line_trim = ""
			line_char = ""
			line_lenght = string.len(apt_line)
			if line_lenght > 0 then
				for kk = 1, line_lenght do
					line_char = string.sub(apt_line, kk, kk)
					if line_char == " " then
						if ii == 1 then
							jj = jj + 1
							apt_word[jj] = line_trim
							ii = 0
							line_trim = ""
						end
					else
						line_trim = line_trim .. line_char
						ii = 1
					end
				end
				if string.len(line_trim) > 0 then
					jj = jj + 1
					apt_word[jj] = line_trim
				end
				
				if jj == 11 then
					awy_skip_txt = apt_word[11] .. apt_word[1] .. apt_word[4]
					awy_temp = apt_word[11]
					jj, kk = string.find(awy_temp, "-")
					if jj == nil then
						awy_data_num = awy_data_num + 1
						awy_data[awy_data_num] = {}
						awy_data[awy_data_num][1] = apt_word[11]	-- airway
						awy_data[awy_data_num][2] = apt_word[1]		-- navaid from
						awy_data[awy_data_num][3] = apt_word[4]		-- navaid to
						awy_data[awy_data_num][4] = apt_word[2]		-- region code from
						awy_data[awy_data_num][5] = apt_word[5]		-- region code to
					else
						while jj ~= nil do 
							awy_tempx = string.sub(awy_temp, 1, jj - 1)
							awy_data_num = awy_data_num + 1
							awy_data[awy_data_num] = {}
							awy_data[awy_data_num][1] = awy_tempx	-- airway
							awy_data[awy_data_num][2] = apt_word[1]		-- navaid
							awy_data[awy_data_num][3] = apt_word[4]		-- navaid
							awy_data[awy_data_num][4] = apt_word[2]		-- region code from
							awy_data[awy_data_num][5] = apt_word[5]		-- region code to
							awy_temp = string.sub(awy_temp, jj + 1, -1)
							jj, kk = string.find(awy_temp, "-")
						end
						awy_data_num = awy_data_num + 1
						awy_data[awy_data_num] = {}
						awy_data[awy_data_num][1] = awy_temp	-- airway
						awy_data[awy_data_num][2] = apt_word[1]		-- navaid
						awy_data[awy_data_num][3] = apt_word[4]		-- navaid
						awy_data[awy_data_num][4] = apt_word[2]		-- region code from
						awy_data[awy_data_num][5] = apt_word[5]		-- region code to
					end
				end
			end
		end
		apt_first = 1
		apt_line = file_navdata2:read()
	end
	file_navdata2:close()
	
end

function find_awy(awy_from, awy_from_rc, awy)
	
	local ii = 0
	local from_find = 0
	local kk = 0
	local compare1 = ""
	local compare2 = ""
	
	local awy_temp = {}
	local awy_temp_num = 0
	
	awy_temp2 = {}
	awy_temp_num2 = 0
	
	if string.len(awy_from_rc) > 0 then
		kk = 1
	end
	
	if awy_data_num > 0 then
		for ii = 1, awy_data_num  do
			if awy_data[ii][1] == awy then
				awy_temp_num = awy_temp_num + 1
				awy_temp[awy_temp_num] = {}
				awy_temp[awy_temp_num][1] = awy_data[ii][1]
				awy_temp[awy_temp_num][2] = awy_data[ii][2]
				awy_temp[awy_temp_num][3] = awy_data[ii][3]
				awy_temp[awy_temp_num][4] = awy_data[ii][4]
				awy_temp[awy_temp_num][5] = awy_data[ii][5]
				awy_temp[awy_temp_num][6] = 0
				if kk == 0 then
					if awy_data[ii][2] == awy_from or awy_data[ii][3] == awy_from then
						from_find = 1
					end
				else
					if awy_data[ii][2] == awy_from and awy_data[ii][4] == awy_from_rc then
						from_find = 1
					end
					if awy_data[ii][3] == awy_from and awy_data[ii][5] == awy_from_rc then
						from_find = 1
					end
				end
			end
		end
	end
	
	-- delete the same airways
	if awy_temp_num == 1 then
		awy_temp_num2 = awy_temp_num2 + 1
		awy_temp2[awy_temp_num2] = {}
		for kk = 1, 6 do
			awy_temp2[awy_temp_num2][kk] = awy_temp[1][kk]
		end
	elseif awy_temp_num > 1 then
		compare1 = awy_temp[1][1] .. awy_temp[1][2] .. awy_temp[1][3]
		awy_temp_num2 = awy_temp_num2 + 1
		awy_temp2[awy_temp_num2] = {}
		for kk = 1, 6 do
			awy_temp2[awy_temp_num2][kk] = awy_temp[1][kk]
		end
		for ii = 2, awy_temp_num do
			compare2 = awy_temp[ii][1] .. awy_temp[ii][2] .. awy_temp[ii][3]
			if compare1 ~= compare2 then
				awy_temp_num2 = awy_temp_num2 + 1
				awy_temp2[awy_temp_num2] = {}
				for kk = 1, 6 do
					awy_temp2[awy_temp_num2][kk] = awy_temp[ii][kk]
				end
			end
			compare1 = compare2
		end
	end
	
	if from_find == 0 then
		awy_temp_num2 = 0
	end
	
	--dump_awy()
	
	return from_find

end


function find_awy_path(awy_from, awy_from_rc, awy_to, awy_to_rc, awy)

	local ii = 0
	local jj = 0
	local kk = 0
	local ll = 0
	local awy_idx = 0
	local awy_idx2 = 0
	local from_tmp = awy_from
	local from_tmp_rc = awy_from_rc
	local to_find = 0
	local awy_repeat_n = 0
	local awy_repeat = 0
	
	awy_path = {}
	awy_path_num = 0
	
	if string.len(awy_from_rc) > 0 then
		kk = 1
	end
	
	if string.len(awy_to_rc) > 0 then
		ll = 1
	end
	
	if awy_temp_num2 > 0 then --and from_find == 1 then
		
		for ii = 1, awy_temp_num2 do 
			awy_temp2[ii][6] = 0	-- not used
			if kk == 0 then
				if awy_temp2[ii][2] == from_tmp then
					awy_repeat_n = awy_repeat_n + 1
				elseif awy_temp2[ii][3] == from_tmp then
					awy_repeat_n = awy_repeat_n + 1
				end
			else
				if awy_temp2[ii][2] == from_tmp and awy_temp2[ii][4] == from_tmp_rc then
					awy_repeat_n = awy_repeat_n + 1
				elseif awy_temp2[ii][3] == from_tmp and awy_temp2[ii][5] == from_tmp_rc then
					awy_repeat_n = awy_repeat_n + 1
				end
			end
		end
		
		if awy_repeat_n > 0 then
			for awy_repeat = 1, awy_repeat_n do
				
				awy_path = {}
				awy_path_num = 0
				
				for jj = 1, awy_temp_num2 do 
					for ii = 1, awy_temp_num2 do
						if awy_temp2[ii][6] == 0 then
							if kk == 0 then --and awy_path_num == 0 then
								if awy_temp2[ii][2] == from_tmp then
									awy_path_num = awy_path_num + 1
									awy_path[awy_path_num] = {}
									awy_path[awy_path_num][1] = awy_temp2[ii][3]
									awy_path[awy_path_num][2] = awy_temp2[ii][5]
									awy_temp2[ii][6] = 1	-- used
									from_tmp = awy_temp2[ii][3]
									from_tmp_rc = awy_temp2[ii][5]
								elseif awy_temp2[ii][3] == from_tmp then
									awy_path_num = awy_path_num + 1
									awy_path[awy_path_num] = {}
									awy_path[awy_path_num][1] = awy_temp2[ii][2]
									awy_path[awy_path_num][2] = awy_temp2[ii][4]
									awy_temp2[ii][6] = 1	-- used
									from_tmp = awy_temp2[ii][2]
									from_tmp_rc = awy_temp2[ii][4]
								end
							else
								if awy_temp2[ii][2] == from_tmp and awy_temp2[ii][4] == from_tmp_rc then
									awy_path_num = awy_path_num + 1
									awy_path[awy_path_num] = {}
									awy_path[awy_path_num][1] = awy_temp2[ii][3]
									awy_path[awy_path_num][2] = awy_temp2[ii][5]
									awy_temp2[ii][6] = 1	-- used
									from_tmp = awy_temp2[ii][3]
									from_tmp_rc = awy_temp2[ii][5]
								elseif awy_temp2[ii][3] == from_tmp and awy_temp2[ii][5] == from_tmp_rc then
									awy_path_num = awy_path_num + 1
									awy_path[awy_path_num] = {}
									awy_path[awy_path_num][1] = awy_temp2[ii][2]
									awy_path[awy_path_num][2] = awy_temp2[ii][4]
									awy_temp2[ii][6] = 1	-- used
									from_tmp = awy_temp2[ii][2]
									from_tmp_rc = awy_temp2[ii][4]
								end
							end
							
							if ll == 0 then
								if awy_to == from_tmp then
									to_find = 1
									break
								end
							else
								if awy_to == from_tmp and awy_to_rc == from_tmp_rc then
									to_find = 1
									break
								end
							end
						end
					end
					if to_find == 1 then
						break
					end
				end
				if to_find == 1 then
					break
				end
				
				from_tmp = awy_from
				from_tmp_rc = awy_from_rc
			end
		end
	end
	
	return to_find

end


function via_via_check()
	
	if calc_rte_enable2 == 0 then
		if via_via_ok == 1 then
			fpln_num2 = fpln_num2 + 1
			fpln_data2[fpln_num2] = {}
			fpln_data2[fpln_num2][1] = ""
			fpln_data2[fpln_num2][2] = via_via_entry
			fpln_data2[fpln_num2][3] = ""
			fpln_data2[fpln_num2][4] = 1	--legs_data_idx
			fpln_data2[fpln_num2][5] = 0	-- num_legs_data
			via_via_entry = ""
			via_via_ok = 0
			rte_exec = 1
			
			find_awy(fpln_data2[fpln_num2-1][1], fpln_data2[fpln_num2-1][3], fpln_data2[fpln_num2][2])
		end
	end
end

function via_via_add()
	
	via_via_ok = 0
	
	if find_via_via(fpln_data2[fpln_num2-1][1], fpln_data2[fpln_num2-1][3], fpln_data2[fpln_num2][2], entry) == 0 then
		entry = ">INVALID ENTRY"
	else
		fpln_data2[fpln_num2][4] = fpln_data2[fpln_num2-1][4] + fpln_data2[fpln_num2-1][5]	--legs_data_idx
		idx_tmp = fpln_data2[fpln_num2][4] + fpln_data2[fpln_num2][5]
		fpln_data2[fpln_num2][5] = awy_path_num
		
		-- add airways waypoints
		idx_tmp2 = fpln_data2[fpln_num2][4]
		fpln_add_leg_dir2(idx_tmp, idx_tmp2, fpln_data2[fpln_num2][2])
		
		via_via_entry = entry
		via_via_ok = 1
		
		entry = ""
		rte_exec = 1
	
	end
	
end

function find_via_via(awy_from, awy_from_rc, awy1, awy2)
	
	local ii = 0
	local jj = 0
	local kk = 0
	local ll = 0
	local awy_idx = 0
	local awy_idx2 = 0
	local from_tmp = awy_from
	local from_tmp_rc = awy_from_rc
	local to_find = 0
	
	local check_awy = 0
	local awy_repeat_n = 0
	local awy_repeat = 0
	
	awy_path = {}
	awy_path_num = 0
	
	if string.len(awy_from_rc) > 0 then
		kk = 1
	end
	
	
	if awy_temp_num2 > 0 then --and from_find == 1 then
		for ii = 1, awy_temp_num2 do 
			awy_temp2[ii][6] = 0	-- not used
			if kk == 0 then
				if awy_temp2[ii][2] == from_tmp then
					awy_repeat_n = awy_repeat_n + 1
				elseif awy_temp2[ii][3] == from_tmp then
					awy_repeat_n = awy_repeat_n + 1
				end
			else
				if awy_temp2[ii][2] == from_tmp and awy_temp2[ii][4] == from_tmp_rc then
					awy_repeat_n = awy_repeat_n + 1
				elseif awy_temp2[ii][3] == from_tmp and awy_temp2[ii][5] == from_tmp_rc then
					awy_repeat_n = awy_repeat_n + 1
				end
			end
		end
		
		if awy_repeat_n > 0 then
			for awy_repeat = 1, awy_repeat_n do
				
				awy_path = {}
				awy_path_num = 0
				
				for jj = 1, awy_temp_num2 do 
					for ii = 1, awy_temp_num2 do
						if awy_temp2[ii][6] == 0 then
							if kk == 0 then --and awy_path_num == 0 then
								if awy_temp2[ii][2] == from_tmp then
									awy_path_num = awy_path_num + 1
									awy_path[awy_path_num] = {}
									awy_path[awy_path_num][1] = awy_temp2[ii][3]
									awy_path[awy_path_num][2] = awy_temp2[ii][5]
									awy_temp2[ii][6] = 1	-- used
									from_tmp = awy_temp2[ii][3]
									from_tmp_rc = awy_temp2[ii][5]
									check_awy = 1
								elseif awy_temp2[ii][3] == from_tmp then
									awy_path_num = awy_path_num + 1
									awy_path[awy_path_num] = {}
									awy_path[awy_path_num][1] = awy_temp2[ii][2]
									awy_path[awy_path_num][2] = awy_temp2[ii][4]
									awy_temp2[ii][6] = 1	-- used
									from_tmp = awy_temp2[ii][2]
									from_tmp_rc = awy_temp2[ii][4]
									check_awy = 1
								end
							else
								if awy_temp2[ii][2] == from_tmp and awy_temp2[ii][4] == from_tmp_rc then
									awy_path_num = awy_path_num + 1
									awy_path[awy_path_num] = {}
									awy_path[awy_path_num][1] = awy_temp2[ii][3]
									awy_path[awy_path_num][2] = awy_temp2[ii][5]
									awy_temp2[ii][6] = 1	-- used
									from_tmp = awy_temp2[ii][3]
									from_tmp_rc = awy_temp2[ii][5]
									check_awy = 1
								elseif awy_temp2[ii][3] == from_tmp and awy_temp2[ii][5] == from_tmp_rc then
									awy_path_num = awy_path_num + 1
									awy_path[awy_path_num] = {}
									awy_path[awy_path_num][1] = awy_temp2[ii][2]
									awy_path[awy_path_num][2] = awy_temp2[ii][4]
									awy_temp2[ii][6] = 1	-- used
									from_tmp = awy_temp2[ii][2]
									from_tmp_rc = awy_temp2[ii][4]
									check_awy = 1
								end
							end
							
							if check_awy == 1 then
								if awy_data_num > 0 then
									for ii = 1, awy_data_num  do
										if awy_data[ii][1] ~= awy1 then
											if awy_data[ii][1] == awy2 then
												if awy_data[ii][2] == from_tmp and awy_data[ii][4] == from_tmp_rc then
													to_find = 1
												end
												if awy_data[ii][3] == from_tmp and awy_data[ii][5] == from_tmp_rc then
													to_find = 1
												end
												if to_find == 1 then
													break
												end
											end
										end
									end
								end
							end
							
							check_awy = 0
							
							if to_find == 1 then
								break
							end
						end
					end
					if to_find == 1 then
						break
					end
				end
				if to_find == 1 then
					break
				end
				
				from_tmp = awy_from
				from_tmp_rc = awy_from_rc
			end
		end
	end
	
	return to_find

end


function via_add(awy_from2, awy_from_rc2)
	
	-- check via
	if find_awy(awy_from2, awy_from_rc2, entry) == 0 then
		entry = ">INVALID ENTRY"
	else
		-- add fpln -> via
		fpln_num2 = fpln_num2 + 1
		fpln_data2[fpln_num2] = {}
		fpln_data2[fpln_num2][1] = ""
		fpln_data2[fpln_num2][2] = entry
		fpln_data2[fpln_num2][3] = ""
		fpln_data2[fpln_num2][4] = 1	--legs_data_idx
		fpln_data2[fpln_num2][5] = 0	-- num_legs_data
		entry = ""
		rte_exec = 1
	end
	
end

function via_chg(awy_from2, awy_from_rc2, via_id)
	
	local idx_tmp = 0
	local idx_tmp2 = 0
	
	-- check via
	if find_awy(awy_from2, awy_from_rc2, entry) == 0 then
		entry = ">INVALID ENTRY"
	else
		if fpln_data2[via_id][1] == "" then
			fpln_data2[via_id][2] = entry
			idx_tmp = fpln_data2[via_id-1][4] + fpln_data2[via_id-1][5]
			legs_data2[idx_tmp][9] = entry
		else
			if find_awy_path(awy_from2, awy_from_rc2, fpln_data2[via_id][1], fpln_data2[via_id][3], entry) == 0 then
				entry = ">INVALID ENTRY"
			else
				if via_id == 1 then
					fpln_data2[via_id][4] = 2	--legs_data_idx
					idx_tmp = fpln_data2[via_id][4] + fpln_data2[via_id][5]
					fpln_data2[via_id][5] = awy_path_num
				else
					fpln_data2[via_id][4] = fpln_data2[via_id-1][4] + fpln_data2[via_id-1][5]	--legs_data_idx
					idx_tmp = fpln_data2[via_id][4] + fpln_data2[via_id][5]
					fpln_data2[via_id][5] = awy_path_num
				end
				
				-- add airways waypoints
				idx_tmp2 = fpln_data2[via_id][4]
				fpln_add_leg_dir2(idx_tmp, idx_tmp2, entry)
			end
		end
		--dump_leg()
		
		entry = ""
		rte_exec = 1
	end
	
end


function dir_via_add(awy_from2, awy_from_rc2, awy_to2, awy_to_rc2, via2, via_idx)
	
	local idx_tmp = 0
	local idx_tmp2 = 0
	
	dir_change = 0
	dir_idx = via_idx
	dir_disco = 0
	
	if via2 == "" then
		-- check navaid
		-- nav mode => distance from 0-PPOS, 1-REF ICAO, 2-DES ICAO
		find_navaid(entry, "", 0, "")
		if navaid_list_n == 0 then
			fmc_message_num = fmc_message_num + 1
			fmc_message[fmc_message_num] = NOT_IN_DATABASE
		elseif navaid_list_n == 1 then
			-- add fpln -> direct navaid
			if via_idx > fpln_num2 then
				fpln_num2 = fpln_num2 + 1
				fpln_data2[fpln_num2] = {}
				fpln_data2[via_idx][1] = navaid_list[1][4]	--entry
				fpln_data2[via_idx][2] = "DIRECT"
				fpln_data2[via_idx][3] = navaid_list[1][8]	--reg_code
				if via_idx == 1 then
					fpln_data2[via_idx][4] = 2	--legs_data_idx
					fpln_data2[via_idx][5] = 1
				else
					fpln_data2[via_idx][4] = fpln_data2[via_idx-1][4] + fpln_data2[via_idx-1][5]	--legs_data_idx
					fpln_data2[via_idx][5] = 1
				end
				idx_tmp = fpln_data2[via_idx][4]
				idx_tmp2 = idx_tmp
			else
				fpln_data2[via_idx][1] = navaid_list[1][4]	--entry
				fpln_data2[via_idx][2] = "DIRECT"
				fpln_data2[via_idx][3] = navaid_list[1][8]	--reg_code
				
				idx_tmp = fpln_data2[via_idx][4] + fpln_data2[via_idx][5]
				idx_tmp2 = fpln_data2[via_idx][4]
				fpln_data2[via_idx][5] = 1
				
				-- add DISCONTINUITY
				if via_idx < fpln_num2 then
					if legs_data2[idx_tmp][1] ~= fpln_data2[via_idx][1] then
						dir_disco = 1
					end
				end
			end
			
			-- add legs direct waypoint
			fpln_add_leg_dir(idx_tmp, idx_tmp2, "DIRECT", 1)
			
			entry = ""
			rte_exec = 1
			create_fpln()
		else
			-- more navaids
			page_sel_wpt2 = 1
			page_rte_init = 0
			act_page_old = act_page
			act_page = 1
			entry = ""
		end
	elseif via2 == "DIRECT" then
		find_navaid(entry, "", 0, "")
		if navaid_list_n == 0 then
			fmc_message_num = fmc_message_num + 1
			fmc_message[fmc_message_num] = NOT_IN_DATABASE
		elseif navaid_list_n == 1 then
			fpln_data2[via_idx][1] = navaid_list[1][4]	--entry
			fpln_data2[via_idx][2] = "DIRECT"
			fpln_data2[via_idx][3] = navaid_list[1][8]	--reg_code
			
			idx_tmp = fpln_data2[via_idx][4] + fpln_data2[via_idx][5]
			idx_tmp2 = fpln_data2[via_idx][4]
			fpln_data2[via_idx][5] = 1
			
			-- add DISCONTINUITY
			if via_idx < fpln_num2 then
				if legs_data2[idx_tmp][1] ~= fpln_data2[via_idx][1] then
					dir_disco = 1
				end
			end
			
			-- change legs direct waypoint
			fpln_add_leg_dir(idx_tmp, idx_tmp2, "DIRECT", 1)
			
			entry = ""
			rte_exec = 1
			create_fpln()
		else
			-- more navaids
			page_sel_wpt2 = 1
			page_rte_init = 0
			act_page_old = act_page
			act_page = 1
			entry = ""
			dir_change = 1
		end
	else
		-- add fpln -> via navaid
		if find_awy_path(awy_from2, awy_from_rc2, awy_to2, awy_to_rc2, via2) == 0 then
			entry = ">INVALID ENTRY"
		else
			fpln_data2[via_idx][1] = awy_path[awy_path_num][1]	--entry
			fpln_data2[via_idx][3] = awy_path[awy_path_num][2]	--reg_code
			
			if via_idx == 1 then
				fpln_data2[via_idx][4] = 2	--legs_data_idx
				idx_tmp = fpln_data2[via_idx][4] + fpln_data2[via_idx][5]
				fpln_data2[via_idx][5] = awy_path_num
			else
				fpln_data2[via_idx][4] = fpln_data2[via_idx-1][4] + fpln_data2[via_idx-1][5]	--legs_data_idx
				idx_tmp = fpln_data2[via_idx][4] + fpln_data2[via_idx][5]
				fpln_data2[via_idx][5] = awy_path_num
			end
			
			-- add airways waypoints
			idx_tmp2 = fpln_data2[via_idx][4]
			fpln_add_leg_dir2(idx_tmp, idx_tmp2, via2)
			
			entry = ""
			rte_exec = 1
		end
	end
	
end

function dir_add(awy_idx)
	
	local idx_tmp = 0
	local idx_tmp2 = 0
	
	if dir_change == 0 then
		-- add navaid
		if dir_idx >  fpln_num2 then
			fpln_num2 = fpln_num2 + 1
			fpln_data2[fpln_num2] = {}
			fpln_data2[dir_idx][1] = navaid_list[awy_idx][4]
			fpln_data2[dir_idx][2] = "DIRECT"
			fpln_data2[dir_idx][3] = navaid_list[awy_idx][8]
			if dir_idx == 1 then
				fpln_data2[dir_idx][4] = 2	--legs_data_idx
				fpln_data2[dir_idx][5] = 1
			else
				fpln_data2[dir_idx][4] = fpln_data2[dir_idx-1][4] + fpln_data2[dir_idx-1][5]	--legs_data_idx
				fpln_data2[dir_idx][5] = 1
			end
			idx_tmp = fpln_data2[dir_idx][4]
			idx_tmp2 = idx_tmp
		else
			fpln_data2[dir_idx][1] = navaid_list[awy_idx][4]
			fpln_data2[dir_idx][2] = "DIRECT"
			fpln_data2[dir_idx][3] = navaid_list[awy_idx][8]
			idx_tmp = fpln_data2[dir_idx][4] + fpln_data2[dir_idx][5]
			idx_tmp2 = fpln_data2[dir_idx][4]
			fpln_data2[dir_idx][5] = 1
			
			-- add DISCONTINUITY
			if dir_idx < fpln_num2 then
				if legs_data2[idx_tmp][1] ~= fpln_data2[dir_idx][1] then
					dir_disco = 1
				end
			end
		
		end
		
		
		-- add legs direct waypoint
		fpln_add_leg_dir(idx_tmp, idx_tmp2, "DIRECT", awy_idx)
		
	else
		-- change navaid
		fpln_data2[dir_idx][1] = navaid_list[awy_idx][4]
		fpln_data2[dir_idx][2] = "DIRECT"
		fpln_data2[dir_idx][3] = navaid_list[awy_idx][8]
		idx_tmp = fpln_data2[dir_idx][4] + fpln_data2[dir_idx][5]
		idx_tmp2 = fpln_data2[dir_idx][4]
		fpln_data2[dir_idx][5] = 1
		
		-- add DISCONTINUITY
		if dir_idx < fpln_num2 then
			if legs_data2[idx_tmp][1] ~= fpln_data2[dir_idx][1] then
				dir_disco = 1
			end
		end
		
		-- change legs direct waypoint
		fpln_add_leg_dir(idx_tmp, idx_tmp2, "DIRECT", awy_idx)
	end
	
	entry = ""
	rte_exec = 1
	page_sel_wpt2 = 0
	page_rte_init = 1
	act_page = act_page_old
	--create_fpln()
	
end


function del_via(via_id)
	
	local idx_tmp = 0
	local idx_tmp2 = 0
	
	if fpln_data2[via_id][2] ~= "DIRECT" and fpln_data2[via_id][1] ~= "" then
		
		fpln_data2[via_id][2] = "DIRECT"
		idx_tmp = fpln_data2[via_id][4] + fpln_data2[via_id][5] - 1
		idx_tmp2 = fpln_data2[via_id][4]
		fpln_data2[via_id][5] = 1
		
		fpln_del_leg(idx_tmp, idx_tmp2)
		
		--entry = ""
		rte_exec = 1
	elseif fpln_data2[via_id][2] ~= "DIRECT" and fpln_data2[via_id][1] == "" then
		fpln_data2[via_id][2] = ""
		idx_tmp = fpln_data2[via_id][4] + fpln_data2[via_id][5]
		legs_data2[idx_tmp][9] = ""
		rte_exec = 1
	end
	
	entry = ""
	
end


function fpln_del_leg(idx_copy, idx_first)
	
	if idx_first > 1 and idx_first <= legs_num2 then
		legs_data2[idx_copy][9] = "DIRECT"
		rte_copy(idx_copy)
		rte_paste(idx_first)
		legs_delete = 1
		calc_rte_enable2 = 1
		--dump_leg()
	end
	
end

function fpln_add_leg_disco(idx_disco)
	
	-- create DISCONTINUITY
	legs_num2 = idx_disco
	legs_data2[legs_num2] = {}
	legs_data2[legs_num2][1] = "DISCONTINUITY"
	legs_data2[legs_num2][2] = 0		-- brg
	legs_data2[legs_num2][3] = 0		-- distance
	legs_data2[legs_num2][4] = 0		-- speed
	legs_data2[legs_num2][5] = 0		-- altitude
	legs_data2[legs_num2][6] = 0	-- altitude type
	legs_data2[legs_num2][7] = 0		-- latitude
	legs_data2[legs_num2][8] = 0		-- longitude
	legs_data2[legs_num2][9] = ""			-- via id
	legs_data2[legs_num2][10] = 0		-- calc speed
	legs_data2[legs_num2][11] = 0		-- calc altitude
	legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
	legs_data2[legs_num2][13] = 0
	legs_data2[legs_num2][14] = 0		-- rest alt
	legs_data2[legs_num2][15] = 0		-- last fuel
	legs_data2[legs_num2][16] = ""
	legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
	legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
	legs_data2[legs_num2][19] = 0		-- 0-none, 1-SID, 2-STAR/APP, 3-DISCONTINUITY
	legs_data2[legs_num2][20] = 0
	legs_data2[legs_num2][21] = -1
	legs_data2[legs_num2][22] = 0
	legs_data2[legs_num2][23] = 0
	legs_data2[legs_num2][24] = 0
	legs_data2[legs_num2][25] = 0
	legs_data2[legs_num2][26] = 0
	
end

function fpln_add_leg_dir2(idx_copy, idx_paste, idx_via)
	
	local leg_wpt_id = ""
	local leg_wpt_rg = ""
	local legs_num_tmp = legs_num2
	
	rte_copy(idx_copy)
	legs_num2 = idx_paste - 1
	
	if awy_path_num > 0 then
		
		for ii = 1, awy_path_num do
			
			
			leg_wpt_id = awy_path[ii][1]
			leg_wpt_rg = awy_path[ii][2]
			find_navaid(leg_wpt_id, "", 0, leg_wpt_rg)
			
			legs_num2 = legs_num2 + 1
			if navaid_list_n ~= 0 then
				legs_data2[legs_num2] = {}
				legs_data2[legs_num2][1] = navaid_list[1][4]	--entry
				legs_data2[legs_num2][2] = 0		-- brg
				legs_data2[legs_num2][3] = 0		-- distance
				legs_data2[legs_num2][4] = 0		-- speed
				legs_data2[legs_num2][5] = 0		-- altitude
				legs_data2[legs_num2][6] = 0	-- altitude type
				legs_data2[legs_num2][7] = navaid_list[1][2]		-- latitude
				legs_data2[legs_num2][8] = navaid_list[1][3]		-- longitude
				legs_data2[legs_num2][9] = idx_via			-- via id
				legs_data2[legs_num2][10] = 0		-- calc speed
				legs_data2[legs_num2][11] = 0		-- calc altitude
				legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
				legs_data2[legs_num2][13] = 0
				legs_data2[legs_num2][14] = 0		-- rest alt
				legs_data2[legs_num2][15] = 0		-- last fuel
				legs_data2[legs_num2][16] = navaid_list[1][8]		-- reg code
				legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
				legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
				legs_data2[legs_num2][19] = 0		-- 0-none, 1-SID, 2-STAR/APP, 3-DISCONTINUITY
				legs_data2[legs_num2][20] = 0
				legs_data2[legs_num2][21] = -1
				legs_data2[legs_num2][22] = 0
				legs_data2[legs_num2][23] = 0
				legs_data2[legs_num2][24] = 0
				legs_data2[legs_num2][25] = 0
				legs_data2[legs_num2][26] = 0
			else
				legs_data2[legs_num2] = {}
				legs_data2[legs_num2][1] = leg_wpt_id	--entry
				legs_data2[legs_num2][2] = 0		-- brg
				legs_data2[legs_num2][3] = 0		-- distance
				legs_data2[legs_num2][4] = 0		-- speed
				legs_data2[legs_num2][5] = 0		-- altitude
				legs_data2[legs_num2][6] = 0	-- altitude type
				legs_data2[legs_num2][7] = 0		-- latitude
				legs_data2[legs_num2][8] = 0		-- longitude
				legs_data2[legs_num2][9] = idx_via			-- via id
				legs_data2[legs_num2][10] = 0		-- calc speed
				legs_data2[legs_num2][11] = 0		-- calc altitude
				legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
				legs_data2[legs_num2][13] = 0
				legs_data2[legs_num2][14] = 0		-- rest alt
				legs_data2[legs_num2][15] = 0		-- last fuel
				legs_data2[legs_num2][16] = leg_wpt_rg		-- reg code
				legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
				legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
				legs_data2[legs_num2][19] = 0		-- 0-none, 1-SID, 2-STAR/APP, 3-DISCONTINUITY
				legs_data2[legs_num2][20] = 0
				legs_data2[legs_num2][21] = -1
				legs_data2[legs_num2][22] = 0
				legs_data2[legs_num2][23] = 0
				legs_data2[legs_num2][24] = 0
				legs_data2[legs_num2][25] = 0
				legs_data2[legs_num2][26] = 0
			end
			
		end
		
		if dir_disco == 1 then
			legs_num2 = legs_num2 + 1
			legs_data2[legs_num2] = {}
			fpln_add_leg_disco(legs_num2)
		else
			if legs_data2_tmp_n > 1 then
				legs_num2 = legs_num2 - 1
				-- change last WAYPOINT to DIRECT
				legs_data2_tmp[1][9] = "DIRECT"
				legs_data2_tmp[1][19] = 4
			end
		end
		
	else
		legs_num2 = legs_num_tmp
	end
	
	dir_disco = 0
	rte_paste(legs_num2 + 1)
	legs_delete = 1
	calc_rte_enable2 = 1
end


function fpln_add_leg_dir(idx_copy, idx_paste, idx_via, wpt_idx)
	
	rte_copy(idx_copy)
	legs_num2 = idx_paste
	
	legs_data2[legs_num2] = {}
	legs_data2[legs_num2][1] = navaid_list[wpt_idx][4]	--entry
	legs_data2[legs_num2][2] = 0		-- brg
	legs_data2[legs_num2][3] = 0		-- distance
	legs_data2[legs_num2][4] = 0		-- speed
	legs_data2[legs_num2][5] = 0		-- altitude
	legs_data2[legs_num2][6] = 0	-- altitude type
	legs_data2[legs_num2][7] = navaid_list[wpt_idx][2]		-- latitude
	legs_data2[legs_num2][8] = navaid_list[wpt_idx][3]		-- longitude
	legs_data2[legs_num2][9] = idx_via			-- via id
	legs_data2[legs_num2][10] = 0		-- calc speed
	legs_data2[legs_num2][11] = 0		-- calc altitude
	legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
	legs_data2[legs_num2][13] = 0
	legs_data2[legs_num2][14] = 0		-- rest alt
	legs_data2[legs_num2][15] = 0		-- last fuel
	legs_data2[legs_num2][16] = navaid_list[wpt_idx][8]		-- reg code
	legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
	legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
	legs_data2[legs_num2][19] = 0		-- 0-none, 1-SID, 2-STAR/APP, 3-DISCONTINUITY
	legs_data2[legs_num2][20] = 0
	legs_data2[legs_num2][21] = -1
	legs_data2[legs_num2][22] = 0
	legs_data2[legs_num2][23] = 0
	legs_data2[legs_num2][24] = 0
	legs_data2[legs_num2][25] = 0
	legs_data2[legs_num2][26] = 0
		
	if dir_disco == 1 then
		-- add DISCO
		legs_num2 = legs_num2 + 1
		legs_data2[legs_num2] = {}
		fpln_add_leg_disco(legs_num2)
	else
		if legs_data2_tmp_n > 1 then
			legs_num2 = legs_num2 - 1
		-- change last WAYPOINT to DIRECT
			legs_data2_tmp[1][9] = "DIRECT"
			legs_data2_tmp[1][19] = 4
		end
	end
	dir_disco = 0
	
	rte_paste(legs_num2 + 1)
	legs_delete = 1
	calc_rte_enable2 = 1
end



function del_fpln(via_id)
	
	fpln_num2 = via_id - 1
	entry = ""
	rte_exec = 1
	
end


function copy_fpln(fpln_idx)

	local ii = 0
	local jj = 0
	
	fpln_data_tmp_n = 0
	fpln_data_tmp = {}
	
	if fpln_idx <= fpln_num2 and fpln_idx > 0 then
		for ii = fpln_idx, fpln_num2 do
			fpln_data_tmp_n = fpln_data_tmp_n + 1
			fpln_data_tmp[fpln_data_tmp_n] = {}
			for jj = 1, 5 do
				fpln_data_tmp[fpln_data_tmp_n][jj] = fpln_data2[ii][jj]
			end
		end
	end
	
end

function paste_fpln(fpln_idx)

	local ii = 0
	local jj = 0
	local kk = fpln_num2 + 1
	
	if fpln_idx <= kk and fpln_idx > 0 and fpln_data_tmp_n > 0 then
		fpln_num2 = fpln_num2 - 1
		for ii = 1, fpln_data_tmp_n do
			fpln_num2 = fpln_num2 + 1
			fpln_data2[fpln_num2] = {}
			for jj = 1, 5 do
				fpln_data2[fpln_num2][jj] = fpln_data_tmp[ii][jj]
			end
		end
	end
	
end


function create_fpln()

	local ii = 0
	local compare_txt = ""
	
	fpln_num2 = 0
	fpln_data2 = {}
	
	--dump_leg()
	
	if legs_num2 == 2 then
		--fpln_num2 = 0
		--fpln_data2 = {}
		
		if string.sub(legs_data2[2][1], 1, 2) ~= "RW" then
			fpln_num2 = fpln_num2 + 1
			fpln_data2[fpln_num2] = {}
			if legs_data2[2][1] == "DISCONTINUITY" then
				fpln_data2[fpln_num2][1] = ""
				fpln_data2[fpln_num2][2] = legs_data2[2][9]
				fpln_data2[fpln_num2][3] = ""
				fpln_data2[fpln_num2][4] = 2
				fpln_data2[fpln_num2][5] = 1
			else
				if legs_data2[2][19] == 3 then
					legs_data2[2][9] = "DIRECT"
					legs_data2[2][19] = 0
				end
				fpln_data2[fpln_num2][1] = legs_data2[2][1]
				fpln_data2[fpln_num2][2] = legs_data2[2][9]
				fpln_data2[fpln_num2][3] = legs_data2[2][16]
				fpln_data2[fpln_num2][4] = 2
				fpln_data2[fpln_num2][5] = 1
			end
		end
	elseif legs_num2 > 2 then
		--fpln_num2 = 0
		--fpln_data2 = {}
		
		if string.sub(legs_data2[2][1], 1, 2) ~= "RW" then
			fpln_num2 = fpln_num2 + 1
			fpln_data2[fpln_num2] = {}
			if legs_data2[2][1] == "DISCONTINUITY" then
				fpln_data2[fpln_num2][1] = ""
				fpln_data2[fpln_num2][2] = legs_data2[2][9]
				fpln_data2[fpln_num2][3] = ""
				fpln_data2[fpln_num2][4] = 2
				fpln_data2[fpln_num2][5] = 1
			else
				if legs_data2[2][19] == 3 then
					legs_data2[2][9] = "DIRECT"
					legs_data2[2][19] = 0
				end
				fpln_data2[fpln_num2][1] = legs_data2[2][1]
				fpln_data2[fpln_num2][2] = legs_data2[2][9]
				fpln_data2[fpln_num2][3] = legs_data2[2][16]
				fpln_data2[fpln_num2][4] = 2
				fpln_data2[fpln_num2][5] = 1
			end
			compare_txt = legs_data2[2][9]
			if compare_txt == "DIRECT" then
				compare_txt = compare_txt .. "Z"
			end
			for ii = 3, legs_num2 do
				if legs_data2[ii][9] ~= compare_txt then
					fpln_num2 = fpln_num2 + 1
					fpln_data2[fpln_num2] = {}
					if legs_data2[ii][1] == "DISCONTINUITY" then
						fpln_data2[fpln_num2][1] = ""
						fpln_data2[fpln_num2][2] = legs_data2[ii][9]
						fpln_data2[fpln_num2][3] = ""
						fpln_data2[fpln_num2][4] = ii
						fpln_data2[fpln_num2][5] = 1
					else
						if legs_data2[ii][19] == 3 then
							legs_data2[ii][9] = "DIRECT"
							legs_data2[ii][19] = 0
						end
						fpln_data2[fpln_num2][1] = legs_data2[ii][1]
						fpln_data2[fpln_num2][2] = legs_data2[ii][9]
						fpln_data2[fpln_num2][3] = legs_data2[ii][16]
						fpln_data2[fpln_num2][4] = ii
						fpln_data2[fpln_num2][5] = 1
					end
				else
					if legs_data2[ii][1] == "DISCONTINUITY" then
						fpln_data2[fpln_num2][5] = fpln_data2[fpln_num2][5] + 1
					else
						fpln_data2[fpln_num2][1] = legs_data2[ii][1]
						fpln_data2[fpln_num2][3] = legs_data2[ii][16]
						fpln_data2[fpln_num2][5] = fpln_data2[fpln_num2][5] + 1
					end
				end
				compare_txt = legs_data2[ii][9]
				if compare_txt == "DIRECT" then
					compare_txt = compare_txt .. "Z"
				end
			end
		else
			if legs_num2 > 3 then
				fpln_num2 = fpln_num2 + 1
				fpln_data2[fpln_num2] = {}
				if legs_data2[3][1] == "DISCONTINUITY" then
					fpln_data2[fpln_num2][1] = ""
					fpln_data2[fpln_num2][2] = legs_data2[3][9]
					fpln_data2[fpln_num2][3] = ""
					fpln_data2[fpln_num2][4] = 3
					fpln_data2[fpln_num2][5] = 1
				else
					if legs_data2[3][19] == 3 then
						legs_data2[3][9] = "DIRECT"
						legs_data2[3][19] = 0
					end
					fpln_data2[fpln_num2][1] = legs_data2[3][1]
					fpln_data2[fpln_num2][2] = legs_data2[3][9]
					fpln_data2[fpln_num2][3] = legs_data2[3][16]
					fpln_data2[fpln_num2][4] = 3
					fpln_data2[fpln_num2][5] = 1
				end
				compare_txt = legs_data2[3][9]
				if compare_txt == "DIRECT" then
					compare_txt = compare_txt .. "Z"
				end
				for ii = 4, legs_num2 do
					if legs_data2[ii][9] ~= compare_txt then
						fpln_num2 = fpln_num2 + 1
						fpln_data2[fpln_num2] = {}
						if legs_data2[ii][1] == "DISCONTINUITY" then
							fpln_data2[fpln_num2][1] = ""
							fpln_data2[fpln_num2][2] = legs_data2[ii][9]
							fpln_data2[fpln_num2][3] = ""
							fpln_data2[fpln_num2][4] = ii
							fpln_data2[fpln_num2][5] = 1
						else
							if legs_data2[ii][19] == 3 then
								legs_data2[ii][9] = "DIRECT"
								legs_data2[ii][19] = 0
							end
							fpln_data2[fpln_num2][1] = legs_data2[ii][1]
							fpln_data2[fpln_num2][2] = legs_data2[ii][9]
							fpln_data2[fpln_num2][3] = legs_data2[ii][16]
							fpln_data2[fpln_num2][4] = ii
							fpln_data2[fpln_num2][5] = 1
						end
					else
						if legs_data2[ii][1] == "DISCONTINUITY" then
							fpln_data2[fpln_num2][5] = fpln_data2[fpln_num2][5] + 1
						else
							fpln_data2[fpln_num2][1] = legs_data2[ii][1]
							fpln_data2[fpln_num2][3] = legs_data2[ii][16]
							fpln_data2[fpln_num2][5] = fpln_data2[fpln_num2][5] + 1
						end
					end
					compare_txt = legs_data2[ii][9]
					if compare_txt == "DIRECT" then
						compare_txt = compare_txt .. "Z"
					end
				end
			else
				fpln_num2 = fpln_num2 + 1
				fpln_data2[fpln_num2] = {}
				if legs_data2[3][1] == "DISCONTINUITY" then
					fpln_data2[fpln_num2][1] = ""
					fpln_data2[fpln_num2][2] = legs_data2[3][9]
					fpln_data2[fpln_num2][3] = ""
					fpln_data2[fpln_num2][4] = 3
					fpln_data2[fpln_num2][5] = 1
				else
					if legs_data2[3][19] == 3 then
						legs_data2[3][9] = "DIRECT"
						legs_data2[3][19] = 0
					end
					fpln_data2[fpln_num2][1] = legs_data2[3][1]
					fpln_data2[fpln_num2][2] = legs_data2[3][9]
					fpln_data2[fpln_num2][3] = legs_data2[3][16]
					fpln_data2[fpln_num2][4] = 3
					fpln_data2[fpln_num2][5] = 1
				end
			end
		end
	end
	--dump_leg()
	--dump_fpln2()
end

function copy_to_fpln()
	
	local ii = 0
	
	fpln_num = 0
	fpln_data = {}
	
	if fpln_num2 > 0 then
		for ii = 1, fpln_num2 do
			fpln_num = fpln_num + 1
			fpln_data[fpln_num] = {}
			fpln_data[fpln_num][1] = fpln_data2[ii][1]
			fpln_data[fpln_num][2] = fpln_data2[ii][2]
			fpln_data[fpln_num][3] = fpln_data2[ii][3]
			fpln_data[fpln_num][4] = fpln_data2[ii][4]
			fpln_data[fpln_num][5] = fpln_data2[ii][5]
		end
	end
	
end


function copy_to_fpln2()
	
	local ii = 0
	
	fpln_num2 = 0
	fpln_data2 = {}
	
	if fpln_num > 0 then
		for ii = 1, fpln_num do
			fpln_num2 = fpln_num2 + 1
			fpln_data2[fpln_num2] = {}
			fpln_data2[fpln_num2][1] = fpln_data[ii][1]
			fpln_data2[fpln_num2][2] = fpln_data[ii][2]
			fpln_data2[fpln_num2][3] = fpln_data[ii][3]
			fpln_data2[fpln_num2][4] = fpln_data[ii][4]
			fpln_data2[fpln_num2][5] = fpln_data[ii][5]
		end
	end
	
end

function dump_fpln2()
	local vvv = 0
	local fms_line = ""
	
	local file_name2 = "legs.txt"
	local file_navdata2 = io.open(file_name2, "w")
	
	if file_navdata2 ~= nil then
		if fpln_num2 > 0 then
			for vvv = 1, fpln_num2  do
--				if awy_temp2[vvv][1] == "R232" then
					fms_line = fpln_data2[vvv][1] .. "," .. fpln_data2[vvv][2] .. "," .. fpln_data2[vvv][3] .. "," 
					fms_line = fms_line .. tostring(fpln_data2[vvv][4]) .. "," .. tostring(fpln_data2[vvv][5]) .. "\n"
					file_navdata2:write(fms_line)
--				end
			end
		end
		file_navdata2:close()
	end
end


function dump_awy()
	local vvv = 0
	local fms_line = ""
	
	local file_name2 = "legs.txt"
	local file_navdata2 = io.open(file_name2, "w")
	
	if file_navdata2 ~= nil then
		if awy_temp_num2 > 0 then
			for vvv = 1, awy_temp_num2  do
--				if awy_temp2[vvv][1] == "R232" then
					fms_line = awy_temp2[vvv][1] .. "," .. awy_temp2[vvv][2] .. "," .. awy_temp2[vvv][4] .. "," .. awy_temp2[vvv][3] .. "," .. awy_temp2[vvv][5] .. "\n"
					file_navdata2:write(fms_line)
--				end
			end
		end
		file_navdata2:close()
	end
end

function dump_awy2()
	local vvv = 0
	local fms_line = ""
	
	local file_name2 = "legs.txt"
	local file_navdata2 = io.open(file_name2, "w")
	
	if file_navdata2 ~= nil then
		if awy_path_num > 0 then
			for vvv = 1, awy_path_num  do
				fms_line = awy_path[vvv] .. "\n"
				file_navdata2:write(fms_line)
			end
		else
			fms_line = "NOT FOUND" .. "\n"
			file_navdata2:write(fms_line)
		end
		file_navdata2:close()
	end
end

function find_rnw_data()

	local ii = 0
	local jj = 0
	local kk = 0
	local rnw_temp0 = ""
	des_rnw = ""
	
	ref_runway_lenght = 0
	ref_runway_lat = 0
	ref_runway_lon = 0
	ref_runway_crs = 0
	des_runway_lenght = 0
	des_runway_lat = 0
	des_runway_lon = 0
	des_runway_crs = 0
	
	
	if string.sub(ref_rwy, -1, -1) == " " then
		rnw_temp0 = string.sub(ref_rwy, 1, -2)
	else
		rnw_temp0 = ref_rwy
	end
	
	if string.sub(des_app, 1, 2) == "RW" then
		des_rnw = string.sub(des_app, 3, -1)
	else
		if string.len(des_app) > 4 then
			jj, kk = string.find(des_app, "-")
			if jj == nil then
				des_rnw = string.sub(des_app, 2, -2)
			else
				des_rnw = string.sub(des_app, 2, jj-1)
			end
		else
			des_rnw = string.sub(des_app, 2, -1)
		end
		-- des_rnw = string.sub(des_app, 2, -1)
		-- if string.len(des_rnw) > 3 then
			-- des_rnw = string.sub(des_app, 2, -2)
		-- end
	end
	
	if rnw_data_num > 0 then
		for ii = 1, rnw_data_num do
			if ref_icao == rnw_data[ii][1] and rnw_temp0 == rnw_data[ii][2] then
				ref_runway_lenght = rnw_data[ii][7]
				ref_runway_lat = rnw_data[ii][3]
				ref_runway_lon = rnw_data[ii][4]
				ref_runway_crs = rnw_data[ii][8]
			end
			if des_icao == rnw_data[ii][1] and des_rnw == rnw_data[ii][2] then
				des_runway_lenght = rnw_data[ii][7]
				des_runway_lat = rnw_data[ii][3]
				des_runway_lon = rnw_data[ii][4]
				des_runway_crs = rnw_data[ii][8]
			end
			if ref_runway_lenght > 0 and des_runway_lenght > 0 then
				break
			end
		end
	end

end

function import_fms()
	local ii = 0
	local jj = 0
	local kk = 0
	local line_trim = ""
	local line_char = ""
	local line_lenght = 0
	local apt_line = ""
	local apt_word = {}
	local apt_ok = 0
	
	rte_data_num = 0
	rte_data = {}
	
	local file_name_imp = "Output/FMS plans/" .. entry .. ".fms"
	local file_navdata2 = io.open(file_name_imp, "r")
	if file_navdata2 ~= nil then
		apt_line = file_navdata2:read()
		while apt_line do
			ii = 0
			jj = 0
			line_trim = ""
			line_char = ""
			line_lenght = string.len(apt_line)
			if line_lenght > 0 then
				for kk = 1, line_lenght do
					line_char = string.sub(apt_line, kk, kk)
					if line_char == " " then
						if ii == 1 then
							jj = jj + 1
							apt_word[jj] = line_trim
							ii = 0
							line_trim = ""
						end
					else
						line_trim = line_trim .. line_char
						ii = 1
					end
				end
				if string.len(line_trim) > 0 then
					jj = jj + 1
					apt_word[jj] = line_trim
				end
				
				if jj > 4 then
					if apt_word[1] == "1" or apt_word[1] == "2" or apt_word[1] == "3" or apt_word[1] == "11" or apt_word[1] == "28" then
						
						if string.len(apt_word[2]) > 7 then
							apt_word[2] = string.sub(apt_word[2], 1, 7)
						end
						
						rte_data_num = rte_data_num + 1
						rte_data[rte_data_num] = {}
						rte_data[rte_data_num][1] = tonumber(apt_word[1])		-- type
						rte_data[rte_data_num][2] = apt_word[2]		-- id name
						rte_data[rte_data_num][3] = apt_word[3]		-- alt
						rte_data[rte_data_num][4] = tonumber(apt_word[4])		-- lat
						rte_data[rte_data_num][5] = tonumber(apt_word[5])		-- lon
						rte_data[rte_data_num][6] = "DIRECT"		-- via
						rte_data[rte_data_num][7] = ""		-- reg code
					end
				end
			end
			apt_line = file_navdata2:read()
		end
		file_navdata2:close()
		use_import_data()
	end
	
end

function use_import_data()

	local ii = 0
	local jj = 0
	local kk = 0
	local apt_ok = 0
	
	-- USE DATA
	if rte_data_num > 2 then
		if rte_data[1][1] == 1 and rte_data[rte_data_num][1] == 1 then
			
			copy_to_legsdata2()
			kk = 0		-- no error
			legs_num = 0
			legs_data = {}
			
			-- REF ICAO
			apt_ok = 0	-- no error
			ref_icao = rte_data[1][2]
			file_name = "Custom Data/CIFP/" .. ref_icao
			file_name = file_name .. ".dat"
			file_navdata = io.open(file_name, "r")
			if file_navdata == nil then
				file_name = "Resources/default data/CIFP/" .. ref_icao
				file_name = file_name .. ".dat"
				file_navdata = io.open(file_name, "r")
				if file_navdata == nil then
					if apt_exist(ref_icao) == true then
						apt_ok = 1
					end
				else
					read_ref_data()		-- read reference airport data
					file_navdata:close()
					apt_ok = 1
				end
			else
				read_ref_data()		-- read reference airport data
				file_navdata:close()
				apt_ok = 1
			end
			
			if apt_ok == 1 then
				des_icao = "****"
				ref_gate = "-----"
				trans_alt = "-----"
				ref_rwy = "-----"
				ref_sid = "------"
				ref_sid_tns = "------"
				des_app = "------"
				des_app_tns = "------"
				des_star = "------"
				des_star_trans = "------"
				----
				ref_rwy2 = "-----"
				ref_sid2 = "------"
				ref_sid_tns2 = "------"
				des_app2 = "------"
				des_app_tns2 = "------"
				des_star2 = "------"
				des_star_trans2 = "------"
				----
				crz_alt = "*****"
				crz_alt_num = 0
				crz_alt_num2 = 0
				offset = 0
				if apt_exist(ref_icao) == true then
					ref_icao_lat = icao_latitude
					ref_icao_lon = icao_longitude
					ref_tns_alt = icao_tns_alt
					ref_tns_lvl = icao_tns_lvl
				else
					ref_tns_alt = 0
					ref_tns_lvl = 0
				end
				if ref_tns_alt == 0 then
					trans_alt = "-----"
				else
					trans_alt = string.format("%5d", ref_tns_alt)
				end
				
				legs_num = legs_num + 1
				legs_data[legs_num] = {}
				legs_data[legs_num][1] = ref_icao	--entry
				legs_data[legs_num][2] = 0		-- brg
				legs_data[legs_num][3] = 0		-- distance
				legs_data[legs_num][4] = 0		-- speed
				legs_data[legs_num][5] = 0		-- altitude
				legs_data[legs_num][6] = 0	-- altitude type
				legs_data[legs_num][7] = ref_icao_lat		-- latitude
				legs_data[legs_num][8] = ref_icao_lon		-- longitude
				legs_data[legs_num][9] = ""			-- via id
				legs_data[legs_num][10] = 0		-- calc speed
				legs_data[legs_num][11] = 0		-- calc altitude
				legs_data[legs_num][12] = 0		-- calc altitude vnav pth
				legs_data[legs_num][13] = 0
				legs_data[legs_num][14] = 0		-- rest alt
				legs_data[legs_num][15] = 0		-- last fuel
				legs_data[legs_num][16] = ""
				legs_data[legs_num][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
				legs_data[legs_num][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
				legs_data[legs_num][19] = 0		-- 0-none, 1-SID, 2-STAR/APP, 3-DISCONTINUITY
				legs_data[legs_num][20] = 0
				legs_data[legs_num][21] = -1		-- none HOLD
				legs_data[legs_num][22] = 0
				legs_data[legs_num][23] = 0
				legs_data[legs_num][24] = 0
				legs_data[legs_num][25] = 0
				legs_data[legs_num][26] = 0
			else
				kk = 1
			end
			
			-- ROUTE
			jj = rte_data_num - 1
			for ii = 2, jj do
				legs_num = legs_num + 1
				legs_data[legs_num] = {}
				legs_data[legs_num][1] = rte_data[ii][2]	--entry
				legs_data[legs_num][2] = 0		-- brg
				legs_data[legs_num][3] = 0		-- distance
				legs_data[legs_num][4] = 0		-- speed
				legs_data[legs_num][5] = 0		-- altitude
				legs_data[legs_num][6] = 0	-- altitude type
				legs_data[legs_num][7] = rte_data[ii][4]		-- latitude
				legs_data[legs_num][8] = rte_data[ii][5]		-- longitude
				legs_data[legs_num][9] = rte_data[ii][6]			-- via id
				legs_data[legs_num][10] = 0		-- calc speed
				legs_data[legs_num][11] = 0		-- calc altitude
				legs_data[legs_num][12] = 0		-- calc altitude vnav pth
				legs_data[legs_num][13] = 0
				legs_data[legs_num][14] = 0		-- rest alt
				legs_data[legs_num][15] = 0		-- last fuel
				if rte_data[ii][7] == "" then
					find_lat = rte_data[ii][4]
					find_lon = rte_data[ii][5]
					find_navaid(rte_data[ii][2], "", 3, "")
					if navaid_list_n > 0 then
						rte_data[ii][7] = navaid_list[1][8]
					end
				end
				legs_data[legs_num][16] = rte_data[ii][7]
				legs_data[legs_num][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
				legs_data[legs_num][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
				legs_data[legs_num][19] = 0		-- 0-none, 1-SID, 2-STAR/APP, 3-DISCONTINUITY
				legs_data[legs_num][20] = 0
				legs_data[legs_num][21] = -1
				legs_data[legs_num][22] = 0
				legs_data[legs_num][23] = 0
				legs_data[legs_num][24] = 0
				legs_data[legs_num][25] = 0
				legs_data[legs_num][26] = 0
			end
			
			-- DES ICAO
			apt_ok = 0	-- no error
			des_icao = rte_data[rte_data_num][2]
			file_name = "Custom Data/CIFP/" .. des_icao
			file_name = file_name .. ".dat"
			file_navdata = io.open(file_name, "r")
			if file_navdata == nil then
				file_name = "Resources/default data/CIFP/" .. des_icao
				file_name = file_name .. ".dat"
				file_navdata = io.open(file_name, "r")
				if file_navdata == nil then
					if apt_exist(des_icao) == true then
						apt_ok = 1
					end
				else
					read_des_data()		-- read destination airport data
					file_navdata:close()
					apt_ok = 1
				end
			else
				read_des_data()		-- read destination airport data
				file_navdata:close()
				apt_ok = 1
				
			end
			
			if apt_ok == 1 then
				
				offset = 1
				des_app = "------"
				des_app_tns = "------"
				des_star = "------"
				des_star_trans = "------"
				----
				des_app2 = "------"
				des_app_tns2 = "------"
				des_star2 = "------"
				des_star_trans2 = "------"
				----
				des_icao_x = des_icao
				if apt_exist(des_icao) == true then
					des_icao_lat = icao_latitude
					des_icao_lon = icao_longitude
					des_tns_alt = icao_tns_alt
					des_tns_lvl = icao_tns_lvl
				else
					des_tns_alt = 0
					des_tns_lvl = 0
				end
				if des_tns_lvl == 0 then
					trans_lvl = "-----"
				else
					apt_ok = des_tns_lvl
					trans_lvl = "FL" .. string.format("%03d", apt_ok)
				end
				
				legs_num = legs_num + 1
				legs_data[legs_num] = {}
				legs_data[legs_num][1] = des_icao	--entry
				legs_data[legs_num][2] = 0		-- brg
				legs_data[legs_num][3] = 0		-- distance
				legs_data[legs_num][4] = 0		-- speed
				legs_data[legs_num][5] = 0		-- altitude
				legs_data[legs_num][6] = 0	-- altitude type
				legs_data[legs_num][7] = des_icao_lat		-- latitude
				legs_data[legs_num][8] = des_icao_lon		-- longitude
				legs_data[legs_num][9] = ""			-- via id
				legs_data[legs_num][10] = 0		-- calc speed
				legs_data[legs_num][11] = 0		-- calc altitude
				legs_data[legs_num][12] = 0		-- calc altitude vnav pth
				legs_data[legs_num][13] = 0
				legs_data[legs_num][14] = 0		-- rest alt
				legs_data[legs_num][15] = 0		-- last fuel
				legs_data[legs_num][16] = ""
				legs_data[legs_num][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
				legs_data[legs_num][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
				legs_data[legs_num][19] = 0		-- 0-none, 1-SID, 2-STAR/APP, 3-DISCONTINUITY
				legs_data[legs_num][20] = 0
				legs_data[legs_num][21] = -1		-- none HOLD
				legs_data[legs_num][22] = 0
				legs_data[legs_num][23] = 0
				legs_data[legs_num][24] = 0
				legs_data[legs_num][25] = 0
				legs_data[legs_num][26] = 0
			else
				kk = 1
			end
			
			legs_num = legs_num - 1
			
			if kk == 0 then
				co_route = entry
				calc_rte_enable = 1
				calc_rte_act = 0
				rte_calc_lat = 0
				rte_calc_lon = 0
			else
				copy_to_legsdata() 
				ref_icao = "----"
				des_icao = "****"
				ref_gate = "-----"
				co_route = "------------"
				trans_alt = "-----"
				ref_rwy = "-----"
				ref_sid = "------"
				ref_sid_tns = "------"
				des_app = "------"
				des_app_tns = "------"
				des_star = "------"
				des_star_trans = "------"
				----
				ref_rwy2 = "-----"
				ref_sid2 = "------"
				ref_sid_tns2 = "------"
				des_app2 = "------"
				des_app_tns2 = "------"
				des_star2 = "------"
				des_star_trans2 = "------"
				----
				crz_alt = "*****"
				crz_alt_num = 0
				crz_alt_num2 = 0
				offset = 0
				legs_num = 0
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = "LOAD ROUTE ERR"
			end
		else
			fmc_message_num = fmc_message_num + 1
			fmc_message[fmc_message_num] = "LOAD ROUTE ERR"
		end
	else
		fmc_message_num = fmc_message_num + 1
		fmc_message[fmc_message_num] = "LOAD ROUTE ERR"
	end
	
	entry = ""
	
end

function export_fms()
	
	local vvv = 0
	local www = 0
	local fms_line = ""
	local file_name2 = ""
	
	if fpln_num2 > 0 then
		file_name2 = "Output/FMS plans/" .. entry .. ".fms"
		local file_navdata2 = io.open(file_name2, "w")
		
		if file_navdata2 ~= nil then
			
			-- header
			fms_line = "I\n"
			file_navdata2:write(fms_line)
			fms_line = "3 version\n"
			file_navdata2:write(fms_line)
			fms_line = "0\n"
			file_navdata2:write(fms_line)
			
			-- num waypoints
			www = fpln_num2 + 1
			fms_line = tostring(www) .. "\n"
			file_navdata2:write(fms_line)
			
			-- save REF airport
			fms_line = "1 " .. ref_icao .. " 0 " .. tostring(legs_data[1][7]) .. " " .. tostring(legs_data[1][8]) .. "\n"
			file_navdata2:write(fms_line)
			
			-- save waypoints
			for vvv = 1, fpln_num2 do
				www = fpln_data2[vvv][4] + fpln_data2[vvv][5] - 1
				if www <= legs_num and www > 0 then
					fms_line = "11 " .. fpln_data2[vvv][1] .. " 0 " .. tostring(legs_data[www][7]) .. " " .. tostring(legs_data[www][8]) .. "\n"
				end
				file_navdata2:write(fms_line)
			end
			
			www = legs_num + 1
			-- save DES airport
			fms_line = "1 " .. des_icao .. " 0 " .. tostring(legs_data[www][7]) .. " " .. tostring(legs_data[www][8]) .. "\n"
			file_navdata2:write(fms_line)
			
			-- empty line
			fms_line = "\n"
			file_navdata2:write(fms_line)
			
			file_navdata2:close()
		end
	end
	
end

function import_fmx()
	
	local fms_line = ""
	local fms_word = {}
	local ii = 0
	local token = ""
	
	rte_data_num = 0
	rte_data = {}

	local file_name2 = "Output/FMS plans/" .. entry .. ".fmx"
	local file_navdata2 = io.open(file_name2, "r")
	
	if file_navdata2 ~= nil then
		fms_line = file_navdata2:read()
		while fms_line do
			-- read Flight number
			if string.len (fms_line) > 11 then
				if string.sub(fms_line, 1, 11) == "FLIGHT_NUM:" then
				end
			end
			
			-- split DATA
			fms_word = {}
			ii = 0
			for token in string.gmatch(fms_line, "[^,]+") do
				ii = ii + 1
				fms_word[ii] = token
			end
			
			if ii == 5 then
				rte_data_num = rte_data_num + 1
				rte_data[rte_data_num] = {}
				rte_data[rte_data_num][1] = 0		-- type
				rte_data[rte_data_num][2] = fms_word[1]		-- id name
				rte_data[rte_data_num][3] = 0		-- alt
				rte_data[rte_data_num][4] = tonumber(fms_word[4])		-- lat
				rte_data[rte_data_num][5] = tonumber(fms_word[5])		-- lon
				if string.len(fms_word[3]) > 2 then
					if string.sub(fms_word[1], 1, 2) == "RW" then
						rte_data[rte_data_num][6] = ""
					else
						rte_data[rte_data_num][6] = fms_word[3]		-- via
					end
				end
				rte_data[rte_data_num][7] = fms_word[2]		-- reg_code
			end
			if rte_data_num > 0 then
				rte_data[1][1] = 1
				rte_data[rte_data_num][1] = 1
			end
			
			fms_line = file_navdata2:read()
		end
		file_navdata2:close()
		use_import_data()
	end
	
end

function import_fml()
	local fms_line = ""
	local fms_word = {}
	local ii = 0
	local jj = 0
	local kk = 0
	local token = ""
	
	-- ref_rwy_map = {}
	-- ref_rwy_map_num = 0
	
	-- fpln_data2 = {}
	-- fpln_num2 = 0
	
	local fpln_active = 0
	local ref_icao_active = 0
	local ref_icao_found = 0
	local des_icao_active = 0
	local des_icao_found = 0
	local ref_rwy_found = 0
	local des_rwy_found = 0
	local trans_alt_found = 0
	local ref_rwy_map_active = 0
	local ref_rwy_map_found = 0
	
	-- legs_data = {}
	-- legs_num = 0
	local leg_enable = 0
	local leg_entry = 0
	local leg_id = ""
	local leg_brg = 0
	local leg_spd = 0
	local leg_alt = 0
	local leg_alt_type = 0
	local leg_dis = 0
	local leg_lat = 0
	local leg_lon = 0
	local via_id = ""
	local leg_vpa = 0
	local leg_hld_trk = -1
	local leg_hld_out_trk = 0
	local leg_hld_lft = 0
	local leg_hld_len_nm = 0
	local leg_hld_len_min = 0
	local leg_hld_spd_kts = 0
	local lat_lon_disable = 0
	local last_leg_id = ""
	local next_waypoint = 0
	local ref_idx = 0
	
	local www = des_app
	
	msg_chk_alt_constr = 0
	
	
	
	local ref_sid_imp = "-"
	local ref_sid_tns_imp = "-"
	local des_star_imp = "-"
	local des_star_tns_imp = "-"
	local des_app_imp = "-"
	local des_app_tns_imp = "-"
	
	rte_data_num = 0
	rte_data = {}
	
	rte_data_temp = {}
	
	-------------
	-- rte_data_num = rte_data_num + 1
	-- rte_data[rte_data_num] = {}
	-- rte_data[rte_data_num][1] = tonumber(apt_word[1])		-- type
	-- rte_data[rte_data_num][2] = apt_word[2]		-- id name
	-- rte_data[rte_data_num][3] = apt_word[3]		-- alt
	-- rte_data[rte_data_num][4] = tonumber(apt_word[4])		-- lat
	-- rte_data[rte_data_num][5] = tonumber(apt_word[5])		-- lon
	-- rte_data[rte_data_num][6] = "DIRECT"		-- via
	-- rte_data[rte_data_num][7] = ""		-- reg code
	----------------
	
	
	-- file_name = "Output/FMS plans/B738X.fml"
	-- file_navdata = io.open(file_name, "r")
	
	local file_name2 = "Output/FMS plans/" .. entry .. ".fml"
	local file_navdata2 = io.open(file_name2, "r")
	if file_navdata2 ~= nil then
		fms_line = file_navdata2:read()
		while fms_line do
			
			-- Reference ICAO
			if ref_icao_found == 0 then
				ii,jj = string.find(fms_line, 'class_id="37"')
				if ii ~= nill then
					ref_icao_active = 1
				end
			end
			if ref_icao_active == 1 then
				-- lat and lon
				ii,jj = string.find(fms_line, "<rad_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</rad_>")
					jj = ii - 1
					if kk > jj then
						leg_lat = 0
						leg_lon = 0
					else
						if ref_idx == 0 then
							leg_lat = string.sub(fms_line, kk, jj)
						elseif ref_idx == 1 then
							leg_lon = string.sub(fms_line, kk, jj)
						end
					end
					ref_idx = ref_idx + 1
				end
				
				ii,jj = string.find(fms_line, "<id_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</id_>")
					jj = ii - 1
					if kk > jj then
						ref_icao = "----"
					else
						rte_data_num = rte_data_num + 1
						rte_data[rte_data_num] = {}
						rte_data[rte_data_num][1] = 1		-- type
						rte_data[rte_data_num][2] = string.sub(fms_line, kk, jj)		-- id name
						rte_data[rte_data_num][3] = 0	-- alt
						rte_data[rte_data_num][4] = math.deg(tonumber(leg_lat))		-- lat
						rte_data[rte_data_num][5] = math.deg(tonumber(leg_lon))		-- lon
						rte_data[rte_data_num][6] = ""		-- via
						rte_data[rte_data_num][7] = ""		-- reg code
						
						-- ref_icao = string.sub(fms_line, kk, jj)
						-- legs_num = legs_num + 1
						-- legs_data[legs_num] = {}
						-- legs_data[legs_num][1] = ref_icao			-- id
						-- legs_data[legs_num][2] = leg_brg		-- brg
						-- legs_data[legs_num][3] = leg_dis		-- distance
						-- legs_data[legs_num][4] = leg_spd		-- speed
						-- legs_data[legs_num][5] = leg_alt		-- altitude
						-- legs_data[legs_num][6] = leg_alt_type	-- altitude type
						-- legs_data[legs_num][7] = leg_lat		-- latitude
						-- legs_data[legs_num][8] = leg_lon		-- longitude
						-- legs_data[legs_num][9] = via_id			-- via id
						-- legs_data[legs_num][10] = 0		-- calc speed
						-- legs_data[legs_num][11] = 0		-- calc altitude
						-- legs_data[legs_num][12] = 0		-- calc altitude vnav pth
						-- legs_data[legs_num][13] = 0
						-- legs_data[legs_num][14] = 0		-- rest alt
						-- legs_data[legs_num][15] = 0		-- last fuel
						-- legs_data[legs_num][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
						-- legs_data[legs_num][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
						-- legs_data[legs_num][20] = leg_vpa
						-- legs_data[legs_num][21] = leg_hld_trk
						-- legs_data[legs_num][22] = leg_hld_out_trk
						-- legs_data[legs_num][23] = leg_hld_lft
						-- legs_data[legs_num][24] = leg_hld_len_nm
						-- legs_data[legs_num][25] = leg_hld_len_min
						-- legs_data[legs_num][26] = leg_hld_spd_kts
						-- leg_lat = 0
						-- leg_lon = 0
					end
					ref_icao_found = 1
					ref_icao_active = 0
				end
			end
			
			-- -- Reference runway map
			-- if ref_rwy_map_found == 0 then
				-- ii,jj = string.find(fms_line, "<runway_map_")
				-- if ii ~= nill then
					-- ref_rwy_map_active = 1
				-- end
				-- ii,jj = string.find(fms_line, "</runway_map_>")
				-- if ii ~= nill then
					-- ref_rwy_map_found = 1
					-- ref_rwy_map_active = 0
				-- end
			-- end
			-- if ref_rwy_map_active == 1 then
				-- ii,jj = string.find(fms_line, "<id_>")
				-- if ii ~= nill then
					-- kk = jj + 1
					-- ii,jj = string.find(fms_line, "</id_>")
					-- jj = ii - 1
					-- if kk < jj then
						-- ref_rwy_map_num = ref_rwy_map_num + 1
						-- ref_rwy_map[ref_rwy_map_num] = string.sub(fms_line, kk, jj)
					-- end
				-- end
			-- end
			
			
			-- -- Destination runway
			-- if ref_rwy_found == 1 and des_rwy_found == 0 then
				-- ii,jj = string.find(fms_line, "<active_runway_id>")
				-- if ii ~= nill then
					-- kk = jj + 3
					-- ii,jj = string.find(fms_line, "</active_runway_id>")
					-- jj = ii - 1
					-- if kk > jj then
						-- des_rwy = "----"
					-- else
						-- des_rwy = string.sub(fms_line, kk, jj)
						-- if string.len(des_rwy) == 2 then
							-- des_rwy = des_rwy .. " "
						-- end
					-- end
					-- des_rwy_found = 1
				-- end
			-- end
			
			-- -- Reference runway
			-- if ref_rwy_found == 0 then
				-- ii,jj = string.find(fms_line, "<active_runway_id>")
				-- if ii ~= nill then
					-- kk = jj + 3
					-- ii,jj = string.find(fms_line, "</active_runway_id>")
					-- jj = ii - 1
					-- if kk > jj then
						-- ref_rwy = "-----"
					-- else
						-- ref_rwy = string.sub(fms_line, kk, jj)
						-- if string.len(ref_rwy) == 2 then
							-- ref_rwy = ref_rwy .. " "
						-- end
					-- end
					-- ref_rwy_found = 1
				-- end
			-- end
			
			-- -- Transition altitude
			-- if trans_alt_found == 0 then
				-- ii,jj = string.find(fms_line, "<transition_alt_ft_>")
				-- if ii ~= nill then
					-- trans_alt_found = 1
				-- end
			-- end
			-- if trans_alt_found == 1 then
				-- ii,jj = string.find(fms_line, "<m_rep>")
				-- if ii ~= nill then
					-- kk = jj + 1
					-- ii,jj = string.find(fms_line, "</m_rep>")
					-- jj = ii - 1
					-- if kk > jj then
						-- ref_trans_alt = 0
					-- else
						-- ref_trans_alt = tonumber(string.sub(fms_line, kk, jj))
					-- end
					-- trans_alt_found = 2
				-- end
			-- end
			
			-- SID
			ii,jj = string.find(fms_line, "<sid_id_>")
			if ii ~= nill then
				kk = jj + 1
				ii,jj = string.find(fms_line, "</sid_id_>")
				jj = ii - 1
				if kk > jj then
					ref_sid_imp = "-"
				else
					ref_sid_imp = string.sub(fms_line, kk, jj)
				end
			end
			
			-- SID TRANSITION
			ii,jj = string.find(fms_line, "<sid_trans_id_>")
			if ii ~= nill then
				kk = jj + 1
				ii,jj = string.find(fms_line, "</sid_trans_id_>")
				jj = ii - 1
				if kk > jj then
					ref_sid_tns_imp = "-"
				else
					ref_sid_tns_imp = string.sub(fms_line, kk, jj)
				end
			end
			
			-- STAR
			ii,jj = string.find(fms_line, "<star_id_>")
			if ii ~= nill then
				kk = jj + 1
				ii,jj = string.find(fms_line, "</star_id_>")
				jj = ii - 1
				if kk > jj then
					des_star_imp = "-"
				else
					des_star_imp = string.sub(fms_line, kk, jj)
				end
			end
			
			-- STAR TRANSITION
			ii,jj = string.find(fms_line, "<star_trans_id_>")
			if ii ~= nill then
				kk = jj + 1
				ii,jj = string.find(fms_line, "</star_trans_id_>")
				jj = ii - 1
				if kk > jj then
					des_star_tns_imp = "-"
				else
					des_star_tns_imp = string.sub(fms_line, kk, jj)
				end
			end
			
			-- APP
			ii,jj = string.find(fms_line, "<approach_id_>")
			if ii ~= nill then
				kk = jj + 1
				ii,jj = string.find(fms_line, "</approach_id_>")
				jj = ii - 1
				if kk > jj then
					des_app_imp = "-"
				else
					des_app_imp = string.sub(fms_line, kk, jj)
				end
			end
			
			-- APP TRANSITION
			ii,jj = string.find(fms_line, "<approach_trans_id_>")
			if ii ~= nill then
				kk = jj + 1
				ii,jj = string.find(fms_line, "</approach_trans_id_>")
				jj = ii - 1
				if kk > jj then
					des_app_tns_imp = "-"
				else
					des_app_tns_imp = string.sub(fms_line, kk, jj)
				end
			end
			
			-- -- FPLN ROUTE
			-- ii,jj = string.find(fms_line, "<icao_list_")
			-- if ii ~= nil then
				-- fpln_active = 1
			-- end
			-- ii,jj = string.find(fms_line, "</icao_list_>")
			-- if ii ~= nil then
				-- fpln_active = 0
			-- end
			-- if fpln_active == 1 then
				-- ii,jj = string.find(fms_line, "<item>")
				-- if ii ~= nil then
					-- kk = jj + 1
					-- ii,jj = string.find(fms_line, "</item>")
					-- jj = ii - 1
					-- fpln_num2 = fpln_num2 + 1
					-- fpln_data2[fpln_num2] = string.sub(fms_line, kk, jj)
				-- end
			-- end
			
			-- LEGS
			if des_icao_found == 0 then
			
			ii,jj = string.find(fms_line, "<trkToWpt>")
			if ii ~= nil then
				leg_enable = 1
				leg_entry = 4
			end
			if leg_enable == 1 then
				
				-- brg
				if leg_entry == 4 then
					ii,jj = string.find(fms_line, "<rad_>")
					if ii ~= nill then
						kk = jj + 1
						ii,jj = string.find(fms_line, "</rad_>")
						jj = ii - 1
						if kk < jj then
							leg_brg = tonumber(string.sub(fms_line, kk, jj))
						end
						leg_entry = 0
					end
				end
				
				-- distance, speed, altitude
				if leg_entry > 0 then
					ii,jj = string.find(fms_line, "<m_rep>")
					if ii ~= nil then
						kk = jj + 1
						ii,jj = string.find(fms_line, "</m_rep>")
						jj = ii - 1
						if kk < jj then
							if leg_entry == 1 then
								leg_dis = tonumber(string.sub(fms_line, kk, jj))
							elseif leg_entry == 2 then
								leg_spd = tonumber(string.sub(fms_line, kk, jj))
							elseif leg_entry == 3 then
								leg_alt = tonumber(string.sub(fms_line, kk, jj))
							end
						end
						leg_entry = 5	--0
					end
				end
				--lat, lon
				if leg_entry > 4 then
					ii,jj = string.find(fms_line, "<rad_>")
					if ii ~= nill then
						kk = jj + 1
						ii,jj = string.find(fms_line, "</rad_>")
						jj = ii - 1
						if kk < jj then
							if leg_entry == 5 then
								if lat_lon_disable == 0 then
									leg_lat = tonumber(string.sub(fms_line, kk, jj))
								end
							else
								if lat_lon_disable == 0 then
									leg_lon = tonumber(string.sub(fms_line, kk, jj))
									lat_lon_disable = 1
								end
							end
						end
						leg_entry = 0
					end
				end
				ii,jj = string.find(fms_line, "<distToWptNM>")
				if ii == nil then
					ii,jj = string.find(fms_line, "<speed_restriction_kts_>")
					if ii == nil then
						ii,jj = string.find(fms_line, "<altitude_restriction1_ft_>")
						if ii == nil then
							ii,jj = string.find(fms_line, "<lat_>")
							if ii == nil then
								ii,jj = string.find(fms_line, "<lon_>")
								if ii ~= nil then
									leg_entry = 6	-- longitude
								end
							else
								leg_entry = 5	-- latitude
							end
						else
							leg_entry = 3	-- alt restriction
						end
					else
						leg_entry = 2	-- speed restriction
					end
				else
					leg_entry = 1	-- distance
				end
				
				-- altitude type
				ii,jj = string.find(fms_line, "<altitude_restriction_type_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</altitude_restriction_type_>")
					jj = ii - 1
					if kk < jj then
						leg_alt_type = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				
				-- id
				ii,jj = string.find(fms_line, "<id_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</id_>")
					jj = ii - 1
					if kk < jj then
						if leg_id == "" then
							leg_id = string.sub(fms_line, kk, jj)
						end
					end
				end
				
				-- via id
				ii,jj = string.find(fms_line, "<via_id_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</via_id_>")
					jj = ii - 1
					if kk < jj then
						via_id = string.sub(fms_line, kk, jj)
					else
						via_id = ""
					end
					if leg_id == "" then
						leg_id = "-----"
					end
				end
				-- vpa
				ii,jj = string.find(fms_line, "<vpa_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</vpa_>")
					jj = ii - 1
					if kk < jj then
						leg_vpa = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- holding track
				ii,jj = string.find(fms_line, "<holding_track_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</holding_track_>")
					jj = ii - 1
					if kk < jj then
						leg_hld_trk = tonumber(string.sub(fms_line, kk, jj))
						--leg_id = last_leg_id
						if via_id == "" or leg_id == "-----" then
							leg_id = last_leg_id
						--else
							--leg_id = via_id
						end
						last_leg_id = ""
					end
				end
				-- holding out track
				ii,jj = string.find(fms_line, "<holding_out_track_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</holding_out_track_>")
					jj = ii - 1
					if kk < jj then
						leg_hld_out_trk = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- holding left or right
				ii,jj = string.find(fms_line, "<is_left_holding_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</is_left_holding_>")
					jj = ii - 1
					if kk <= jj then
						leg_hld_lft = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- holding lenght nm
				ii,jj = string.find(fms_line, "<hold_leg_length_nm_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</hold_leg_length_nm_>")
					jj = ii - 1
					if kk < jj then
						leg_hld_len_nm = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- holding lenght min
				ii,jj = string.find(fms_line, "<hold_leg_length_min_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</hold_leg_length_min_>")
					jj = ii - 1
					if kk < jj then
						leg_hld_len_min = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- holding speed limit kts
				ii,jj = string.find(fms_line, "<speed_limit_kts_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</speed_limit_kts_>")
					jj = ii - 1
					if kk < jj then
						leg_hld_spd_kts = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- save waypoint data
				next_waypoint = 0
				ii,jj = string.find(fms_line, "</item>")
				if ii ~= nill then
					next_waypoint = 1
				end
				ii,jj = string.find(fms_line, "<item>")
				if ii ~= nill then
					next_waypoint = 1
				end
				
				if next_waypoint == 1 then
					rte_data_num = rte_data_num + 1
					rte_data[rte_data_num] = {}
					rte_data[rte_data_num][1] = 11		-- type
					rte_data[rte_data_num][2] = leg_id		-- id name
					rte_data[rte_data_num][3] = 0		-- alt
					rte_data[rte_data_num][4] = math.deg(tonumber(leg_lat))		-- lat
					rte_data[rte_data_num][5] = math.deg(tonumber(leg_lon))		-- lon
					rte_data[rte_data_num][6] = via_id		-- via
					rte_data[rte_data_num][7] = ""		-- reg code
					
					
					-- legs_num = legs_num + 1
					-- legs_data[legs_num] = {}
					-- legs_data[legs_num][1] = leg_id			-- id
					-- legs_data[legs_num][2] = leg_brg		-- brg
					-- legs_data[legs_num][3] = leg_dis		-- distance
					-- legs_data[legs_num][4] = leg_spd		-- speed
					-- legs_data[legs_num][5] = leg_alt		-- altitude
					-- legs_data[legs_num][6] = leg_alt_type	-- altitude type
					-- legs_data[legs_num][7] = leg_lat		-- latitude
					-- legs_data[legs_num][8] = leg_lon		-- longitude
					-- legs_data[legs_num][9] = via_id			-- via id
					-- legs_data[legs_num][10] = 0		-- calc speed
					-- legs_data[legs_num][11] = 0		-- calc altitude
					-- legs_data[legs_num][12] = 0		-- calc altitude vnav pth
					-- legs_data[legs_num][13] = 0
					-- legs_data[legs_num][14] = 0		-- rest alt
					-- legs_data[legs_num][15] = 0		-- last fuel
					-- legs_data[legs_num][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
					-- legs_data[legs_num][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
					-- legs_data[legs_num][20] = leg_vpa
					-- legs_data[legs_num][21] = leg_hld_trk
					-- legs_data[legs_num][22] = leg_hld_out_trk
					-- legs_data[legs_num][23] = leg_hld_lft
					-- legs_data[legs_num][24] = leg_hld_len_nm
					-- legs_data[legs_num][25] = leg_hld_len_min
					-- legs_data[legs_num][26] = leg_hld_spd_kts
					last_leg_id = leg_id
					leg_id = ""
					leg_brg = 0
					leg_dis = 0
					leg_spd = 0
					leg_alt = 0
					leg_alt_type = 0
					leg_lat = 0
					leg_lon = 0
					via_id = ""
					leg_vpa = 0
					leg_hld_trk = -1
					leg_hld_out_trk = 0
					leg_hld_lft = 0
					leg_hld_len_nm = 0
					leg_hld_len_min = 0
					leg_hld_spd_kts = 0
					leg_entry = 0
					leg_enable = 0
					lat_lon_disable = 0
				end
			end
			
			end
			
			fms_line = file_navdata2:read()
		end
		file_navdata2:close()
		
		-- if trans_alt == "-----" and ref_trans_alt ~= 0 then
			-- trans_alt = string.format("%5d",ref_trans_alt)
			-- --trans_lvl = ""
		-- end
		-- B738_legs_num_first = legs_num
		
		if rte_data_num > 0 then
			
			if ref_sid_tns_imp == "-" then
				-- delete SID waypoints
				if ref_sid_imp ~= "-" then
					leg_brg = 0
					leg_spd = 0
					for ii = 1, rte_data_num do
						if rte_data[ii][6] == ref_sid_imp then
							if leg_brg == 0 then
								leg_brg = ii
							end
							leg_spd = ii
						end
					end
					if leg_brg > 0 then
						jj = leg_spd - leg_brg
						rte_data[leg_spd][6] = ""
						if jj > 0 then
							jj = leg_brg - 1
							for ii = leg_spd, rte_data_num do
								jj = jj + 1
								for kk = 1, 7 do
									rte_data[jj][kk] = rte_data[ii][kk]
								end
								
							end
							rte_data_num = jj
						end
					end
				end
			else
				-- delete SID waypoints
				if ref_sid_imp ~= "-" then
					ii = 1
					while ii <= rte_data_num do
						if rte_data[ii][6] == ref_sid_imp then
							for kk = 1, 7 do
								rte_data_temp[kk] = rte_data[ii][kk]
							end
							if ii < rte_data_num then
								for jj = ii + 1, rte_data_num do
									for kk = 1, 7 do
										rte_data[jj-1][kk] = rte_data[jj][kk] 
									end
								end
							end
							rte_data_num = rte_data_num - 1
						else
							ii = ii + 1
						end
					end
				end
				
				-- delete SID TNS waypoints
				if ref_sid_tns_imp ~= "-" then
					leg_brg = 0
					leg_spd = 0
					for ii = 1, rte_data_num do
						if rte_data[ii][6] == ref_sid_tns_imp then
							if leg_brg == 0 then
								leg_brg = ii
							end
							leg_spd = ii
						end
					end
					if leg_brg > 0 then
						jj = leg_spd - leg_brg
						rte_data[leg_spd][6] = ""
						if jj > 0 then
							jj = leg_brg - 1
							for ii = leg_spd, rte_data_num do
								jj = jj + 1
								for kk = 1, 7 do
									rte_data[jj][kk] = rte_data[ii][kk]
								end
								
							end
							rte_data_num = jj
						end
					end
				end
			end
			
			-- delete STAR TNS waypoints
			if des_star_tns_imp ~= "-" then
				ii = 1
				while ii <= rte_data_num do
					if rte_data[ii][6] == des_star_tns_imp then
						for kk = 1, 7 do
							rte_data_temp[kk] = rte_data[ii][kk]
						end
						if ii < rte_data_num then
							for jj = ii + 1, rte_data_num do
								for kk = 1, 7 do
									rte_data[jj-1][kk] = rte_data[jj][kk] 
								end
							end
						end
						rte_data_num = rte_data_num - 1
					else
						ii = ii + 1
					end
				end
			end
			
			-- delete STAR waypoints
			if des_star_imp ~= "-" then
				ii = 1
				while ii <= rte_data_num do
					if rte_data[ii][6] == des_star_imp then
						for kk = 1, 7 do
							rte_data_temp[kk] = rte_data[ii][kk]
						end
						if ii < rte_data_num then
							for jj = ii + 1, rte_data_num do
								for kk = 1, 7 do
									rte_data[jj-1][kk] = rte_data[jj][kk] 
								end
							end
						end
						rte_data_num = rte_data_num - 1
					else
						ii = ii + 1
					end
				end
			end
			
			-- delete APP TNS waypoints
			if des_app_tns_imp ~= "-" then
				ii = 1
				while ii <= rte_data_num do
					if rte_data[ii][6] == des_app_tns_imp then
						for kk = 1, 7 do
							rte_data_temp[kk] = rte_data[ii][kk]
						end
						if ii < rte_data_num then
							for jj = ii + 1, rte_data_num do
								for kk = 1, 7 do
									rte_data[jj-1][kk] = rte_data[jj][kk] 
								end
							end
						end
						rte_data_num = rte_data_num - 1
					else
						ii = ii + 1
					end
				end
			end
			
			-- delete APP waypoints
			if des_app_imp ~= "-" then
				ii = 1
				while ii <= rte_data_num do
					if rte_data[ii][6] == des_app_imp then
						for kk = 1, 7 do
							rte_data_temp[kk] = rte_data[ii][kk]
						end
						if ii < rte_data_num then
							for jj = ii + 1, rte_data_num do
								for kk = 1, 7 do
									rte_data[jj-1][kk] = rte_data[jj][kk] 
								end
							end
						end
						rte_data_num = rte_data_num - 1
					else
						ii = ii + 1
					end
				end
			end
			
			if string.len(rte_data[rte_data_num][2]) == 4 then
				rte_data[rte_data_num][1] = 1
			end
		end
		
		--dump_rte_data()
		
		use_import_data()
		
	end
	
end


function dump_rte_data()
	local vvv = 0
	local fms_line = ""
	
	local file_name2 = "legs.txt"
	local file_navdata2 = io.open(file_name2, "w")
	
	if file_navdata2 ~= nil then
		if rte_data_num > 0 then
			for vvv = 1, rte_data_num  do
--				if awy_temp2[vvv][1] == "R232" then
					fms_line = tostring(rte_data[vvv][1]) .. "," .. rte_data[vvv][2] .. "," .. rte_data[vvv][3] .. "," .. tostring(rte_data[vvv][4]) 
					fms_line = fms_line .. "," .. tostring(rte_data[vvv][5]) .. "," .. rte_data[vvv][6] .. "\n"
					file_navdata2:write(fms_line)
--				end
			end
		end
		file_navdata2:close()
	end
end


function load_fpln()
	
	local file_name2 = "Output/FMS plans/" .. entry .. ".fmx"
	local file_navdata2 = io.open(file_name2, "r")
	
	if file_navdata2 == nil then
		file_name2 = "Output/FMS plans/" .. entry .. ".fml"
		file_navdata2 = io.open(file_name2, "r")
	
		if file_navdata2 == nil then
			import_fms()
		else
			file_navdata2:close()
			import_fml()
		end
	else
		file_navdata2:close()
		import_fmx()
	end
	
end


function export_fmx()
	
	local vvv = 0
	local www = 0
	local fms_line = ""
	local file_name2 = ""
	
	if legs_num > 1 then
		file_name2 = "Output/FMS plans/" .. entry .. ".fmx"
		local file_navdata2 = io.open(file_name2, "w")
		
		if file_navdata2 ~= nil then
			-- save legs (id_name, reg_code, via, latitude, longitude)
			www = legs_num + 1
			for vvv = 1, www do
				fms_line = legs_data[vvv][1] .. "," 
				if legs_data[vvv][16] == "" then
					fms_line = fms_line .. " " .. ","
				else
					fms_line = fms_line .. legs_data[vvv][16] .. ","
				end
				if legs_data[vvv][9] == "" then
					fms_line = fms_line .. " " .. ","
				else
					fms_line = fms_line .. legs_data[vvv][9] .. ","
				end
				fms_line = fms_line .. tostring(legs_data[vvv][7]) .. "," .. tostring(legs_data[vvv][8]) .. "\n"
				file_navdata2:write(fms_line)
			end
			
			-- save data
			fms_line = "FLIGHT_NUM:" .. flt_num .. "\n"
			file_navdata2:write(fms_line)
			
			file_navdata2:close()
		end
	end
	
end

function save_fpln()
	
	if B738DR_fpln_format == 0 then
		export_fmx()
	else
		export_fms()
	end
	
end

------------------------------------------

function B738_calc_rte2()

	local ii = 0
	local jj = 0
	local nd_lat = 0
	local nd_lon = 0
	local mag_hdg = 0
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_lat3 = 0
	local nd_lon3 = 0
	local nd_dis = 0
	local nd_x = 0
	local nd_y = 0
	local nd_a = 0
	local nd_b = 0
	local nd_c = 0
	local nd_xy = 0
	local nd_brg1 = 0
	local nd_brg2 = 0
	local nd_brg12 = 0
	local nd_brg21 = 0
	local nd_hdg = 0
	local find_txt = ""
	local fix_brg = 0
	local pi = 3.141592653589 --math.pi()
	local protect = 0
	
	if calc_rte_enable2 == 1 then
			calc_rte_enable2 = 2
			calc_rte_act2 = 0
			rte_calc_lat2 = 0
			rte_calc_lon2 = 0
			if calc_rte_enable == 2 then
				calc_rte_enable = 0
			end
			
	elseif calc_rte_enable2 == 2 then
		calc_rte_act2 = calc_rte_act2 + 1
		ii = legs_num2 + 1
		if calc_rte_act2 > ii then
			calc_rte_enable2 = 0
			create_fpln()
			-- calc_rte_act = 0
			-- rte_calc_lat = 0
			-- rte_calc_lon = 0
			--copy_to_legsdata2()
			--B738_find_rnav()
		else
			fix_brg = 0
			if legs_data2[calc_rte_act2][1] == "DISCONTINUITY" then
					legs_data2[calc_rte_act2][7] = rte_calc_lat2
					legs_data2[calc_rte_act2][8] = rte_calc_lon2
					legs_data2[calc_rte_act2][2] = legs_data2[calc_rte_act2-1][2]		-- brg
					legs_data2[calc_rte_act2][3] = 0		-- distance
					fix_brg = 1
			elseif legs_data2[calc_rte_act2][1] == "VECTORS" then
					legs_data2[calc_rte_act2][7] = rte_calc_lat2
					legs_data2[calc_rte_act2][8] = rte_calc_lon2
					legs_data2[calc_rte_act2][3] = 0		-- distance
					fix_brg = 1
			else
				
				if calc_rte_act2 == 1 then
					rte_calc_lat2 = legs_data2[1][7]
					rte_calc_lon2 = legs_data2[1][8]
					find_rnw_data()
				else
				
					if legs_data2[calc_rte_act2][7] == 0 and legs_data2[calc_rte_act2][8] == 0 then
					
						if legs_data2[calc_rte_act2][1] == "(INTC)" and calc_rte_act2 <= legs_num then
							
							fix_brg = 1
							-- first waypoint
							nd_lat1 = math.rad(legs_data2[calc_rte_act2-1][7])
							nd_lon1 = math.rad(legs_data2[calc_rte_act2-1][8])
							nd_brg1 = legs_data2[calc_rte_act2][2]
							
							-- second waypoint
							find_txt = legs_data2[calc_rte_act2+1][1]
							if legs_data2[calc_rte_act2+1][19] == 1 then
								find_navaid(find_txt, ref_icao, 1, "")
								if navaid_list_n == 0 then
									find_navaid(find_txt, "", 1, "")
								end
								if navaid_list_n == 0 and string.sub(find_txt, 1, 2) == "RW" then
									rte_calc_lat = ref_runway_lat
									rte_calc_lon = ref_runway_lon
								end
							elseif legs_data2[calc_rte_act2+1][19] == 2 then
								-- find_navaid(find_txt, des_icao, 2, "")
								-- if navaid_list_n == 0 then
									-- find_navaid(find_txt, "", 2, "")
								-- end
								-- if navaid_list_n == 0 and string.sub(find_txt, 1, 2) == "RW" then
									-- rte_calc_lat = des_runway_lat
									-- rte_calc_lon = des_runway_lon
								-- end
								if string.sub(find_txt, 1, 2) == "RW" then
									rte_calc_lat = des_runway_lat
									rte_calc_lon = des_runway_lon
									navaid_list_n = 0
								else
									find_navaid(find_txt, des_icao, 2, "")
									if navaid_list_n == 0 then
										find_navaid(find_txt, "", 2, "")
									end
								end
							else
								--find_navaid(find_txt, "", 0, "")
								find_navaid(find_txt, "", 0, legs_data2[calc_rte_act2+1][16])
							end
							
							if navaid_list_n > 0 then
								nd_lat2 = math.rad(navaid_list[1][2])
								nd_lon2 = math.rad(navaid_list[1][3])
								nd_brg2 = legs_data2[calc_rte_act2+1][2]
								
								-- -- calculate intercept two waypoints
								nd_xy = 2 * math.asin(math.sqrt((math.sin((nd_lat1-nd_lat2)/2))^2+math.cos(nd_lat1)*math.cos(nd_lat2)*math.sin((nd_lon1-nd_lon2)/2)^2))
								
								
								nd_x = math.sin(nd_lon2 - nd_lon1)
								if nd_x < 0 then
									nd_brg12 = math.acos((math.sin(nd_lat2)-math.sin(nd_lat1)*math.cos(nd_xy))/(math.sin(nd_xy)*math.cos(nd_lat1)))
									nd_brg21 = 2 * pi-math.acos((math.sin(nd_lat1)-math.sin(nd_lat2)*math.cos(nd_xy))/(math.sin(nd_xy)*math.cos(nd_lat2)))
								else
									nd_brg12 = 2 * pi-math.acos((math.sin(nd_lat2)-math.sin(nd_lat1)*math.cos(nd_xy))/(math.sin(nd_xy)*math.cos(nd_lat1)))
									nd_brg21 = math.acos((math.sin(nd_lat1)-math.sin(nd_lat2)*math.cos(nd_xy))/(math.sin(nd_xy)*math.cos(nd_lat2)))
								end
								
								nd_a = math.rad(((math.deg(nd_brg1) - math.deg(nd_brg12)) + 360) % 360)
								nd_b = math.rad(((math.deg(nd_brg21) - math.deg(nd_brg2)) + 360) % 360)
								
								if (math.sin(nd_a) == 0 and math.sin(nd_b) == 0) then
									-- infinity of intersections
									legs_data2[calc_rte_act2][7] = rte_calc_lat		-- latitude
									legs_data2[calc_rte_act2][8] = rte_calc_lon		-- longitude
									legs_data2[calc_rte_act2][2] = legs_data2[calc_rte_act2-1][2]		-- brg
								elseif (math.sin(nd_a) * math.sin(nd_b)) < 0 then
									-- intersection ambiguous
									legs_data2[calc_rte_act2][7] = rte_calc_lat		-- latitude
									legs_data2[calc_rte_act2][8] = rte_calc_lon		-- longitude
									legs_data2[calc_rte_act2][2] = legs_data2[calc_rte_act2-1][2]		-- brg
								else
									nd_a = math.abs(nd_a)
									nd_b = math.abs(nd_b)
									nd_c = math.acos(-math.cos(nd_a)*math.cos(nd_b)+math.sin(nd_a)*math.sin(nd_b)*math.cos(nd_xy))
									
									nd_x = math.atan2(math.sin(nd_xy)*math.sin(nd_a)*math.sin(nd_b),math.cos(nd_b)+math.cos(nd_a)*math.cos(nd_c))
									nd_lat = math.asin(math.sin(nd_lat1)*math.cos(nd_x)+math.cos(nd_lat1)*math.sin(nd_x)*math.cos(nd_brg1))
									nd_lon = math.atan2(math.sin(nd_brg1)*math.sin(nd_x)*math.cos(nd_lat1),math.cos(nd_x)-math.sin(nd_lat1)*math.sin(nd_lat))
									nd_lon = ((nd_lon1-nd_lon+pi) % (2*pi)) - pi
									
									legs_data2[calc_rte_act2][7] = math.deg(nd_lat)		-- latitude
									legs_data2[calc_rte_act2][8] = math.deg(nd_lon)		-- longitude
								end
								-----------------------------------------------------
								
							else
							
								legs_data2[calc_rte_act2][7] = rte_calc_lat		-- latitude
								legs_data2[calc_rte_act2][8] = rte_calc_lon		-- longitude
								legs_data2[calc_rte_act2][2] = legs_data2[calc_rte_act2-1][2]		-- brg
							end
						
						elseif string.sub(legs_data2[calc_rte_act2][1], 1, 1) == "(" then
							legs_data2[calc_rte_act2][7] = rte_calc_lat		-- latitude
							legs_data2[calc_rte_act2][8] = rte_calc_lon		-- longitude
							legs_data2[calc_rte_act2][2] = legs_data2[calc_rte_act2-1][2]		-- brg
							fix_brg = 1
							
						else
						
						
							if calc_rte_act2 <= legs_num2 then
								find_txt = legs_data2[calc_rte_act2][1]
								if string.len(find_txt) < 2 then
									find_txt = "ZZZZZZZZ"
								end
								if legs_data2[calc_rte_act2][19] == 1 then
									find_navaid(find_txt, ref_icao, 1, "")
									if navaid_list_n == 0 then
										find_navaid(find_txt, "", 1, "")
									end
									if navaid_list_n == 0 and string.sub(find_txt, 1, 2) == "RW" then
										rte_calc_lat2 = ref_runway_lat
										rte_calc_lon2 = ref_runway_lon
									end
								elseif legs_data2[calc_rte_act2][19] == 2 then
									-- find_navaid(find_txt, des_icao, 2, "")
									-- if navaid_list_n == 0 then
										-- find_navaid(find_txt, "", 2, "")
									-- end
									-- if navaid_list_n == 0 and string.sub(find_txt, 1, 2) == "RW" then
										-- rte_calc_lat2 = des_runway_lat
										-- rte_calc_lon2 = des_runway_lon
									-- end
									if string.sub(find_txt, 1, 2) == "RW" then
										rte_calc_lat = des_runway_lat
										rte_calc_lon = des_runway_lon
										navaid_list_n = 0
									else
										find_navaid(find_txt, des_icao, 2, "")
										if navaid_list_n == 0 then
											find_navaid(find_txt, "", 2, "")
										end
									end
								else
									--find_navaid(find_txt, "", 0, "")
									find_navaid(find_txt, "", 0, legs_data2[calc_rte_act2][16])
								end
								if navaid_list_n > 0 then
									rte_calc_lat2 = navaid_list[1][2]
									rte_calc_lon2 = navaid_list[1][3]
								else
									navaid_list_n = 1	-- protect for not found wpt
								end
							else
								navaid_list_n = 1
								rte_calc_lat2 = legs_data2[calc_rte_act2][7]
								rte_calc_lon2 = legs_data2[calc_rte_act2][8]
							end
							if navaid_list_n > 0 then
								legs_data2[calc_rte_act2][7] = rte_calc_lat2		-- latitude
								legs_data2[calc_rte_act2][8] = rte_calc_lon2		-- longitude
							end
						end
					end
					
					-- if string.sub(legs_data2[calc_rte_act2][1], 1, 2) == "RW" then
						-- fix_brg = 1
					-- end
					
					rte_calc_lat2 = legs_data2[calc_rte_act2][7]
					rte_calc_lon2 = legs_data2[calc_rte_act2][8]
					
					jj = calc_rte_act2 - 1
					nd_lat = math.rad(legs_data2[jj][7])
					nd_lon = math.rad(legs_data2[jj][8])
					
					nd_lat2 = math.rad(rte_calc_lat2)
					nd_lon2 = math.rad(rte_calc_lon2)
					
					nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
					nd_y = nd_lat2 - nd_lat
					nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
					
					protect = 0
					if nd_dis > 200 then
						if legs_data2[calc_rte_act2][19] == 1 then
							protect = 1
						elseif legs_data2[calc_rte_act2][19] == 2 and legs_data2[calc_rte_act2-1][19] == 2 then
							protect = 1
						end
					end
					
					if protect == 0 then
						nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
						nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
						nd_hdg = math.atan2(nd_y, nd_x)
						nd_hdg = math.deg(nd_hdg)
						nd_hdg = (nd_hdg + 360) % 360
					else
						-- protect large distance
						nd_dis = 0
						legs_data2[calc_rte_act2][7] = legs_data2[calc_rte_act2-1][7]
						legs_data2[calc_rte_act2][8] = legs_data2[calc_rte_act2-1][8]
						legs_data2[calc_rte_act2][2] = legs_data2[calc_rte_act2-1][2]		-- brg
						rte_calc_lat2 = legs_data2[calc_rte_act2][7]
						rte_calc_lon2 = legs_data2[calc_rte_act2][8]
						fix_brg = 1
					end
					
					if legs_data2[calc_rte_act2][21] ~= nil then
						if legs_data2[calc_rte_act2][21] == -1 and fix_brg == 0 then	-- not HOLD
							legs_data2[calc_rte_act2][2] = math.rad(nd_hdg)		-- brg
						end
					else
						if fix_brg == 0 then
							legs_data2[calc_rte_act2][2] = math.rad(nd_hdg)		-- brg
						end
					end
					legs_data2[calc_rte_act2][3] = nd_dis		-- distance
					
				end
			end
		end
	end

end


function B738_calc_rte()

	local ii = 0
	local jj = 0
	local nd_lat = 0
	local nd_lon = 0
	local mag_hdg = 0
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_lat3 = 0
	local nd_lon3 = 0
	local nd_dis = 0
	local nd_x = 0
	local nd_y = 0
	local nd_a = 0
	local nd_b = 0
	local nd_c = 0
	local nd_xy = 0
	local nd_brg1 = 0
	local nd_brg2 = 0
	local nd_brg12 = 0
	local nd_brg21 = 0
	local nd_hdg = 0
	local find_txt = ""
	local fix_brg = 0
	local pi = 3.141592653589 --math.pi()
	local protect = 0
	
	if calc_rte_enable == 1 then
			calc_rte_enable = 2
			calc_rte_act = 0
			rte_calc_lat = 0
			rte_calc_lon = 0
			if calc_rte_enable2 == 2 then
				calc_rte_enable2 = 0
			end
	elseif calc_rte_enable == 2 then
		calc_rte_act = calc_rte_act + 1
		ii = legs_num + 1
		if calc_rte_act > ii then
			--entry = entry .. ".CALC OK"
			calc_rte_enable = 0
			-- calc_rte_act = 0
			-- rte_calc_lat = 0
			-- rte_calc_lon = 0
			--dump_leg()
			copy_to_legsdata2()
			create_fpln()
			B738_find_rnav()
		else
			--entry = tostring(calc_rte_act) .. ">" .. legs_data[calc_rte_act][1] .. "<"
			fix_brg = 0
			if legs_data[calc_rte_act][1] == "DISCONTINUITY" then
					legs_data[calc_rte_act][7] = rte_calc_lat
					legs_data[calc_rte_act][8] = rte_calc_lon
					legs_data[calc_rte_act][2] = legs_data[calc_rte_act-1][2]		-- brg
					legs_data[calc_rte_act][3] = 0		-- distance
					fix_brg = 1
			elseif legs_data[calc_rte_act][1] == "VECTORS" then
					legs_data[calc_rte_act][7] = rte_calc_lat
					legs_data[calc_rte_act][8] = rte_calc_lon
					legs_data[calc_rte_act][3] = 0		-- distance
					fix_brg = 1
			else
				
				if calc_rte_act == 1 then
					rte_calc_lat = legs_data[1][7]
					rte_calc_lon = legs_data[1][8]
					find_rnw_data()
				else
				
					if legs_data[calc_rte_act][7] == 0 and legs_data[calc_rte_act][8] == 0 then
					
						if legs_data[calc_rte_act][1] == "(INTC)" and calc_rte_act <= legs_num then
							
							fix_brg = 1
							-- first waypoint
							nd_lat1 = math.rad(legs_data[calc_rte_act-1][7])
							nd_lon1 = math.rad(legs_data[calc_rte_act-1][8])
							nd_brg1 = legs_data[calc_rte_act][2]
							
							-- second waypoint
							find_txt = legs_data[calc_rte_act+1][1]
							if legs_data[calc_rte_act+1][19] == 1 then
								find_navaid(find_txt, ref_icao, 1, "")
								if navaid_list_n == 0 then
									find_navaid(find_txt, "", 1, "")
								end
								if navaid_list_n == 0 and string.sub(find_txt, 1, 2) == "RW" then
									rte_calc_lat = ref_runway_lat
									rte_calc_lon = ref_runway_lon
								end
							elseif legs_data[calc_rte_act+1][19] == 2 then
								-- find_navaid(find_txt, des_icao, 2, "")
								-- if navaid_list_n == 0 then
									-- find_navaid(find_txt, "", 2, "")
								-- end
								-- if navaid_list_n == 0 and string.sub(find_txt, 1, 2) == "RW" then
									-- rte_calc_lat = des_runway_lat
									-- rte_calc_lon = des_runway_lon
								-- end
								if string.sub(find_txt, 1, 2) == "RW" then
									rte_calc_lat = des_runway_lat
									rte_calc_lon = des_runway_lon
									navaid_list_n = 0
								else
									find_navaid(find_txt, des_icao, 2, "")
									if navaid_list_n == 0 then
										find_navaid(find_txt, "", 2, "")
									end
								end
							else
								--find_navaid(find_txt, "", 0, "")
								find_navaid(find_txt, "", 0, legs_data[calc_rte_act+1][16])
							end
							
							if navaid_list_n > 0 then
								nd_lat2 = math.rad(navaid_list[1][2])
								nd_lon2 = math.rad(navaid_list[1][3])
								nd_brg2 = legs_data[calc_rte_act+1][2]
								
								-- -- calculate intercept two waypoints
								nd_xy = 2 * math.asin(math.sqrt((math.sin((nd_lat1-nd_lat2)/2))^2+math.cos(nd_lat1)*math.cos(nd_lat2)*math.sin((nd_lon1-nd_lon2)/2)^2))
								
								
								nd_x = math.sin(nd_lon2 - nd_lon1)
								if nd_x < 0 then
									nd_brg12 = math.acos((math.sin(nd_lat2)-math.sin(nd_lat1)*math.cos(nd_xy))/(math.sin(nd_xy)*math.cos(nd_lat1)))
									nd_brg21 = 2 * pi-math.acos((math.sin(nd_lat1)-math.sin(nd_lat2)*math.cos(nd_xy))/(math.sin(nd_xy)*math.cos(nd_lat2)))
								else
									nd_brg12 = 2 * pi-math.acos((math.sin(nd_lat2)-math.sin(nd_lat1)*math.cos(nd_xy))/(math.sin(nd_xy)*math.cos(nd_lat1)))
									nd_brg21 = math.acos((math.sin(nd_lat1)-math.sin(nd_lat2)*math.cos(nd_xy))/(math.sin(nd_xy)*math.cos(nd_lat2)))
								end
								
								nd_a = math.rad(((math.deg(nd_brg1) - math.deg(nd_brg12)) + 360) % 360)
								nd_b = math.rad(((math.deg(nd_brg21) - math.deg(nd_brg2)) + 360) % 360)
								
								if (math.sin(nd_a) == 0 and math.sin(nd_b) == 0) then
									-- infinity of intersections
									legs_data[calc_rte_act][7] = rte_calc_lat		-- latitude
									legs_data[calc_rte_act][8] = rte_calc_lon		-- longitude
									legs_data[calc_rte_act][2] = legs_data[calc_rte_act-1][2]		-- brg
								elseif (math.sin(nd_a) * math.sin(nd_b)) < 0 then
									-- intersection ambiguous
									legs_data[calc_rte_act][7] = rte_calc_lat		-- latitude
									legs_data[calc_rte_act][8] = rte_calc_lon		-- longitude
									legs_data[calc_rte_act][2] = legs_data[calc_rte_act-1][2]		-- brg
								else
									nd_a = math.abs(nd_a)
									nd_b = math.abs(nd_b)
									nd_c = math.acos(-math.cos(nd_a)*math.cos(nd_b)+math.sin(nd_a)*math.sin(nd_b)*math.cos(nd_xy))
									
									nd_x = math.atan2(math.sin(nd_xy)*math.sin(nd_a)*math.sin(nd_b),math.cos(nd_b)+math.cos(nd_a)*math.cos(nd_c))
									nd_lat = math.asin(math.sin(nd_lat1)*math.cos(nd_x)+math.cos(nd_lat1)*math.sin(nd_x)*math.cos(nd_brg1))
									nd_lon = math.atan2(math.sin(nd_brg1)*math.sin(nd_x)*math.cos(nd_lat1),math.cos(nd_x)-math.sin(nd_lat1)*math.sin(nd_lat))
									nd_lon = ((nd_lon1-nd_lon+pi) % (2*pi)) - pi
									
									legs_data[calc_rte_act][7] = math.deg(nd_lat)		-- latitude
									legs_data[calc_rte_act][8] = math.deg(nd_lon)		-- longitude
								end
								-----------------------------------------------------
								
							else
							
								legs_data[calc_rte_act][7] = rte_calc_lat		-- latitude
								legs_data[calc_rte_act][8] = rte_calc_lon		-- longitude
								legs_data[calc_rte_act][2] = legs_data[calc_rte_act-1][2]		-- brg
							end
						
						elseif string.sub(legs_data[calc_rte_act][1], 1, 1) == "(" then
							legs_data[calc_rte_act][7] = rte_calc_lat		-- latitude
							legs_data[calc_rte_act][8] = rte_calc_lon		-- longitude
							legs_data[calc_rte_act][2] = legs_data[calc_rte_act-1][2]		-- brg
							fix_brg = 1
							
						else
						
							if calc_rte_act <= legs_num then
								find_txt = legs_data[calc_rte_act][1]
								if string.len(find_txt) < 2 then
									find_txt = "ZZZZZZZZ"
								end
								
								if legs_data[calc_rte_act][19] == 1 then
									find_navaid(find_txt, ref_icao, 1, "")
									if navaid_list_n == 0 then
										find_navaid(find_txt, "", 1, "")
									end
									if navaid_list_n == 0 and string.sub(find_txt, 1, 2) == "RW" then
										rte_calc_lat = ref_runway_lat
										rte_calc_lon = ref_runway_lon
										legs_data[calc_rte_act][7] = ref_runway_lat
										legs_data[calc_rte_act][8] = ref_runway_lon
										fix_brg = 1
									end
								elseif legs_data[calc_rte_act][19] == 2 then
									-- find_navaid(find_txt, des_icao, 2, "")
									-- if navaid_list_n == 0 then
										-- find_navaid(find_txt, "", 2, "")
									-- end
									-- if navaid_list_n == 0 and string.sub(find_txt, 1, 2) == "RW" then
										-- rte_calc_lat = des_runway_lat
										-- rte_calc_lon = des_runway_lon
									-- end
									if string.sub(find_txt, 1, 2) == "RW" then
										rte_calc_lat = des_runway_lat
										rte_calc_lon = des_runway_lon
										navaid_list_n = 0
									else
										find_navaid(find_txt, des_icao, 2, "")
										if navaid_list_n == 0 then
											find_navaid(find_txt, "", 2, "")
										end
									end
								else
									--find_navaid(find_txt, "", 0, "")
									find_navaid(find_txt, "", 0, legs_data[calc_rte_act][16])
								end
								
								if navaid_list_n > 0 then
									rte_calc_lat = navaid_list[1][2]
									rte_calc_lon = navaid_list[1][3]
								else
									navaid_list_n = 1	-- protect for not found wpt
								end
							else
								navaid_list_n = 1
								rte_calc_lat = legs_data[calc_rte_act][7]
								rte_calc_lon = legs_data[calc_rte_act][8]
							end
							
							if navaid_list_n > 0 then
								legs_data[calc_rte_act][7] = rte_calc_lat		-- latitude
								legs_data[calc_rte_act][8] = rte_calc_lon		-- longitude
							end
						end
					end
					
					-- if string.sub(legs_data[calc_rte_act][1], 1, 2) == "RW" then
						-- fix_brg = 1
					-- end
					
					rte_calc_lat = legs_data[calc_rte_act][7]
					rte_calc_lon = legs_data[calc_rte_act][8]
					
					jj = calc_rte_act - 1
					nd_lat = math.rad(legs_data[jj][7])
					nd_lon = math.rad(legs_data[jj][8])
					
					nd_lat2 = math.rad(rte_calc_lat)
					nd_lon2 = math.rad(rte_calc_lon)
					
					nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
					nd_y = nd_lat2 - nd_lat
					nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
					
					protect = 0
					if nd_dis > 200 then
						if legs_data[calc_rte_act][19] == 1 then
							protect = 1
						elseif legs_data[calc_rte_act][19] == 2 and legs_data[calc_rte_act-1][19] == 2 then
							protect = 1
						end
					end
					
					if protect == 0 then
						nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
						nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
						nd_hdg = math.atan2(nd_y, nd_x)
						nd_hdg = math.deg(nd_hdg)
						nd_hdg = (nd_hdg + 360) % 360
					else
						-- protect large distance
						nd_dis = 0
						legs_data[calc_rte_act][7] = legs_data[calc_rte_act-1][7]
						legs_data[calc_rte_act][8] = legs_data[calc_rte_act-1][8]
						legs_data[calc_rte_act][2] = legs_data[calc_rte_act-1][2]		-- brg
						rte_calc_lat = legs_data[calc_rte_act][7]
						rte_calc_lon = legs_data[calc_rte_act][8]
						fix_brg = 1
					end
					
					if legs_data[calc_rte_act][21] ~= nil then
						if legs_data[calc_rte_act][21] == -1 and fix_brg == 0 then 	-- not HOLD
							legs_data[calc_rte_act][2] = math.rad(nd_hdg)		-- brg
						end
					else
						if fix_brg == 0 then
							legs_data[calc_rte_act][2] = math.rad(nd_hdg)		-- brg
						end
					end
					legs_data[calc_rte_act][3] = nd_dis		-- distance
					
				end
			end
		end
	end

end


-- nav mode => distance from 0-PPOS, 1-REF ICAO, 2-DES ICAO, 3-By lat,lon (find_lat, find_lon)
function find_navaid(nav_id, nav_icao, nav_mode, nav_reg_code)
	
	local ii = 0
	local jj = 0
	local kk = 0
	local ll = 0
	local nav_id_ok = 0
	local nd_lat = 0
	local nd_lon = 0
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_dis = 0
	local nd_x = 0
	local nd_y = 0
	
	--local temp_nav_sort = {}
	
	if string.len(nav_icao) > 0 then
		kk = 1
	end
	if string.len(nav_reg_code) > 0 then
		ll = 1
	end
	
	navaid_list = {}
	navaid_list_n = 0
	
	if earth_nav_num > 0 then
		for ii = 1, earth_nav_num do
			nav_id_ok = 0
			if kk == 0 then
				if ll == 0 then
					if nav_id == earth_nav[ii][4] then
						nav_id_ok = 1
					end
				else
					if nav_id == earth_nav[ii][4] and nav_reg_code == earth_nav[ii][8] then
						nav_id_ok = 1
					end
				end
			else
				if ll == 0 then
					if nav_id == earth_nav[ii][4] and nav_icao == earth_nav[ii][5] then
						nav_id_ok = 1
					end
				else
					if nav_id == earth_nav[ii][4] and nav_icao == earth_nav[ii][5] and nav_reg_code == earth_nav[ii][8] then
						nav_id_ok = 1
					end
				end
			end
			if nav_id_ok == 1 then
				navaid_list_n = navaid_list_n + 1
				navaid_list[navaid_list_n] = {}
				for jj = 1, 8 do
					navaid_list[navaid_list_n][jj] = earth_nav[ii][jj]
				end
			end
			
		end
	end
	if kk == 0 then 
		if apt_data_num > 0 then
			for ii = 1, apt_data_num do
				if nav_id == apt_data[ii][1] then
					navaid_list_n = navaid_list_n + 1
					navaid_list[navaid_list_n] = {}
					navaid_list[navaid_list_n][1] = 9	-- APT
					navaid_list[navaid_list_n][2] = apt_data[ii][2]
					navaid_list[navaid_list_n][3] = apt_data[ii][3]
					navaid_list[navaid_list_n][4] = apt_data[ii][1]
					navaid_list[navaid_list_n][5] = ""
					navaid_list[navaid_list_n][6] = ""
					navaid_list[navaid_list_n][7] = ""
					navaid_list[navaid_list_n][8] = ""
				end
			end
		end
	end
	
	-- calc distance
	if navaid_list_n > 1 then
		if nav_mode == 0 then
			nd_lat = math.rad(simDR_latitude)
			nd_lon = math.rad(simDR_longitude)
		elseif nav_mode == 1 then
			nd_lat = math.rad(ref_icao_lat)
			nd_lon = math.rad(ref_icao_lon)
		elseif nav_mode == 2 then
			nd_lat = math.rad(des_icao_lat)
			nd_lon = math.rad(des_icao_lon)
		elseif nav_mode == 3 then
			nd_lat = math.rad(find_lat)
			nd_lon = math.rad(find_lon)
		end
		for ii = 1, navaid_list_n do
			
			nd_lat2 = math.rad(navaid_list[ii][2])
			nd_lon2 = math.rad(navaid_list[ii][3])
			
			nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
			nd_y = nd_lat2 - nd_lat
			nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
			
			navaid_list[ii][9] = nd_dis
			
		end
	end
	
	-- sort by nearest
	if navaid_list_n > 1 then
		for ii = 1, navaid_list_n - 1 do
			nd_x = ii + 1
			for jj = nd_x, navaid_list_n do
				if navaid_list[ii][9] > navaid_list[jj][9] then
					temp_nav_sort = {}
					for kk = 1, 9 do
						temp_nav_sort[kk] = navaid_list[ii][kk]
						navaid_list[ii][kk] = navaid_list[jj][kk]
						navaid_list[jj][kk] = temp_nav_sort[kk]
					end
				end
			end
		end
	end

end

function rte_del_spec(bbb)
	
	local ii = 0
	local jj = 0
	local sid_leg_idx = 0
	
	if legs_num2 > 0 then
		if bbb == 1 then	-- SID
			for ii = legs_num2, 1, -1 do
				if legs_data2[ii][19] ~= nil then
					if legs_data2[ii][19] == bbb then
						sid_leg_idx = ii
						break
					end
				end
			end
			if sid_leg_idx ~= 0 then
				sid_leg_idx = sid_leg_idx + 1
				if legs_data2[sid_leg_idx][1] == "DISCONTINUITY" then
					sid_leg_idx = sid_leg_idx + 1
				end
				rte_copy(sid_leg_idx)
				rte_paste(2)
			end
		elseif bbb == 2 then	-- STAR
			for ii = 1, legs_num2 do
				if legs_data2[ii][19] ~= nil then
					if legs_data2[ii][19] == bbb then
						sid_leg_idx = ii
						break
					end
				end
			end
			if sid_leg_idx ~= 0 then
				rte_copy(legs_num2 + 1)
				-- find DISCONTINUITY
				jj = sid_leg_idx - 1
				if legs_data2[jj][1] == "DISCONTINUITY" then
					sid_leg_idx = jj
				end
				rte_paste(sid_leg_idx)
			end
		end
	end

end

function copy_to_legsdata()

	local ii = 0
	local jj = 0
	
	legs_num = 0
	legs_data = {}
	
	if legs_num2 > 0 then
		for ii = 1, legs_num2 + 1 do
			legs_data[ii] = {}
			for jj = 1, 26 do
				legs_data[ii][jj] = legs_data2[ii][jj]
			end
		end
		legs_num = legs_num2
	end
	calc_rte_enable = 1

end

function copy_to_legsdata2()

	local ii = 0
	local jj = 0
	
	legs_num2 = 0
	legs_data2 = {}
	
	if legs_num > 0 then
		for ii = 1, legs_num + 1 do
			legs_data2[ii] = {}
			for jj = 1, 26 do
				legs_data2[ii][jj] = legs_data[ii][jj]
			end
		end
		legs_num2 = legs_num
	end

end


function rte_copy(aaa)

	local tt1 = 0
	local tt2 = 0
	local tt3 = 0
	
	legs_data2_tmp_n = 0
	legs_data2_tmp = {}
	
	tt3 = legs_num2 + 1
	if aaa <= tt3 and aaa > 0 then
		for tt1 = aaa, tt3 do
			legs_data2_tmp_n = legs_data2_tmp_n + 1
			legs_data2_tmp[legs_data2_tmp_n] = {}
			for tt2 = 1, 26 do
				legs_data2_tmp[legs_data2_tmp_n][tt2] = legs_data2[tt1][tt2]
			end
		end
	end
	
	
end

function rte_paste(aaa)

	local tt1 = 0
	local tt2 = 0
	local cnt_leg = aaa - 1
	
	if legs_data2_tmp_n > 0 then
	
		for tt1 = 1, legs_data2_tmp_n do
			cnt_leg = cnt_leg + 1
			legs_data2[cnt_leg] = {}
			for tt2 = 1, 26 do
				legs_data2[cnt_leg][tt2] = legs_data2_tmp[tt1][tt2]
			end
		end
		legs_num2 = cnt_leg - 1
	end
	
end


function rte_add_wpt2(wpt_idx)
	
	if wpt_idx <= navaid_list_n and wpt_idx ~= 0 then
			
			legs_data2[legs_num2] = {}
			legs_data2[legs_num2][1] = navaid_list[wpt_idx][4]	--entry
			legs_data2[legs_num2][2] = 0		-- brg
			legs_data2[legs_num2][3] = 0		-- distance
			legs_data2[legs_num2][4] = 0		-- speed
			legs_data2[legs_num2][5] = 0		-- altitude
			legs_data2[legs_num2][6] = 0	-- altitude type
			legs_data2[legs_num2][7] = navaid_list[wpt_idx][2]		-- latitude
			legs_data2[legs_num2][8] = navaid_list[wpt_idx][3]		-- longitude
			legs_data2[legs_num2][9] = "DIRECT"			-- via id
			legs_data2[legs_num2][10] = 0		-- calc speed
			legs_data2[legs_num2][11] = 0		-- calc altitude
			legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
			legs_data2[legs_num2][13] = 0
			legs_data2[legs_num2][14] = 0		-- rest alt
			legs_data2[legs_num2][15] = 0		-- last fuel
			legs_data2[legs_num2][16] = navaid_list[wpt_idx][8]		-- reg code
			legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
			legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
			legs_data2[legs_num2][19] = 0		-- 0-none, 1-SID, 2-STAR/APP, 3-DISCONTINUITY
			legs_data2[legs_num2][20] = 0
			legs_data2[legs_num2][21] = -1
			legs_data2[legs_num2][22] = 0
			legs_data2[legs_num2][23] = 0
			legs_data2[legs_num2][24] = 0
			legs_data2[legs_num2][25] = 0
			legs_data2[legs_num2][26] = 0
			rte_lat = legs_data2[legs_num2][7]
			rte_lon = legs_data2[legs_num2][8]
			
			if add_disco == 1 then
				-- create discontinuity
				legs_num2 = legs_num2 + 1
				rte_add_disco(legs_num2)
			end
			
			rte_paste(legs_num2 + 1)
			calc_rte_enable2 = 1
	end
	page_sel_wpt = 0
	page_legs = 1
	act_page = act_page_old
	
end

function rte_add_wpt(aaa)

	local ii = aaa + 1
	local jj = legs_num2 + 1
	
	-- add WPT
	if legs_data2[aaa][1] ~= entry and legs_data2[aaa-1][1] ~= entry then
	
		find_navaid(entry, "", 0, "")
		if navaid_list_n > 0 then
		
			
			if legs_data2[aaa][1] == "DISCONTINUITY" then
				rte_copy(ii)
				add_disco = 0
			else
				rte_copy(aaa)
				if aaa == jj then
					add_disco = 0
				else
					add_disco = 1
				end
			end
			
			legs_num2 = aaa
			
			if navaid_list_n == 1 then
			
				legs_data2[legs_num2] = {}
				legs_data2[legs_num2][1] = navaid_list[1][4]	--entry
				legs_data2[legs_num2][2] = 0		-- brg
				legs_data2[legs_num2][3] = 0		-- distance
				legs_data2[legs_num2][4] = 0		-- speed
				legs_data2[legs_num2][5] = 0		-- altitude
				legs_data2[legs_num2][6] = 0	-- altitude type
				legs_data2[legs_num2][7] = navaid_list[1][2]		-- latitude
				legs_data2[legs_num2][8] = navaid_list[1][3]		-- longitude
				legs_data2[legs_num2][9] = "DIRECT"			-- via id
				legs_data2[legs_num2][10] = 0		-- calc speed
				legs_data2[legs_num2][11] = 0		-- calc altitude
				legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
				legs_data2[legs_num2][13] = 0
				legs_data2[legs_num2][14] = 0		-- rest alt
				legs_data2[legs_num2][15] = 0		-- last fuel
				legs_data2[legs_num2][16] = navaid_list[1][8]		-- reg code
				legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
				legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
				legs_data2[legs_num2][19] = 0		-- 0-none, 1-SID, 2-STAR/APP, 3-DISCONTINUITY
				legs_data2[legs_num2][20] = 0
				legs_data2[legs_num2][21] = -1
				legs_data2[legs_num2][22] = 0
				legs_data2[legs_num2][23] = 0
				legs_data2[legs_num2][24] = 0
				legs_data2[legs_num2][25] = 0
				legs_data2[legs_num2][26] = 0
				rte_lat = legs_data2[legs_num2][7]
				rte_lon = legs_data2[legs_num2][8]
				
				if add_disco == 1 then
					-- create discontinuity
					legs_num2 = legs_num2 + 1
					rte_add_disco(legs_num2)
				end
				
				ii = legs_num2 + 1
				rte_paste(ii)
				legs_delete = 1
				calc_rte_enable2 = 1
			
			else
				page_sel_wpt = 1
				page_legs = 0
				act_page_old = act_page
				act_page = 1
			end
			
		else
			fmc_message_num = fmc_message_num + 1
			fmc_message[fmc_message_num] = NOT_IN_DATABASE
		end
	end
	entry = ""
	

end


function rte_add_disco(aaa)
	
	-- create DISCONTINUITY
	legs_num2 = aaa
	legs_data2[aaa] = {}
	legs_data2[aaa][1] = "DISCONTINUITY"
	legs_data2[aaa][2] = 0		-- brg
	legs_data2[aaa][3] = 0		-- distance
	legs_data2[aaa][4] = 0		-- speed
	legs_data2[aaa][5] = 0		-- altitude
	legs_data2[aaa][6] = 0	-- altitude type
	legs_data2[aaa][7] = rte_lat		-- latitude
	legs_data2[aaa][8] = rte_lon		-- longitude
	legs_data2[aaa][9] = ""			-- via id
	legs_data2[aaa][10] = 0		-- calc speed
	legs_data2[aaa][11] = 0		-- calc altitude
	legs_data2[aaa][12] = 0		-- calc altitude vnav pth
	legs_data2[aaa][13] = 0
	legs_data2[aaa][14] = 0		-- rest alt
	legs_data2[aaa][15] = 0		-- last fuel
	legs_data2[aaa][16] = ""
	legs_data2[aaa][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
	legs_data2[aaa][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
	legs_data2[aaa][19] = 0		-- 0-none, 1-SID, 2-STAR/APP, 3-DISCONTINUITY
	legs_data2[aaa][20] = 0
	legs_data2[aaa][21] = -1
	legs_data2[aaa][22] = 0
	legs_data2[aaa][23] = 0
	legs_data2[aaa][24] = 0
	legs_data2[aaa][25] = 0
	legs_data2[aaa][26] = 0
	
end

function rte_add_sid()
	
	local ii = 0
	local gg = 0
	local gg2 = 0
	local xx_temp = 0
	local rnw_ok  = 0
	local rnw_added = 0
	local rnw_txt = ""
	local rnw_txt2 = ""
	local add_ok = 0
	local tns_ok = 0
	local disco_status = 0
	
	--delete previous SID
	rte_del_spec(1)
	
	rte_lat = 0
	rte_lon = 0
	
	--add RWxx
	if rnw_data_num > 0 then
		for ii = 1, rnw_data_num do
			if ref_icao == rnw_data[ii][1] and ref_rwy == rnw_data[ii][2] then
				if add_ok == 0 and rnw_added == 0 then
					if legs_data2[2][1] == "DISCONTINUITY" then
						rte_copy(3)
					else
						rte_copy(2)
					end
					rnw_added = 1
					legs_num2 = 2
					legs_data2[legs_num2] = {}
					legs_data2[legs_num2][1] = "RW" .. ref_rwy
					legs_data2[legs_num2][2] = math.rad(rnw_data[ii][8])		-- brg
					legs_data2[legs_num2][3] = 0		-- distance
					legs_data2[legs_num2][4] = 0		-- speed
					legs_data2[legs_num2][5] = 0		-- altitude
					legs_data2[legs_num2][6] = 0	-- altitude type
					legs_data2[legs_num2][7] = rnw_data[ii][3]		-- latitude
					legs_data2[legs_num2][8] = rnw_data[ii][4]		-- longitude
					legs_data2[legs_num2][9] = ref_icao			-- via id
					legs_data2[legs_num2][10] = 0		-- calc speed
					legs_data2[legs_num2][11] = 0		-- calc altitude
					legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
					legs_data2[legs_num2][13] = 0
					legs_data2[legs_num2][14] = 0		-- rest alt
					legs_data2[legs_num2][15] = 0		-- last fuel
					legs_data2[legs_num2][16] = ""
					legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
					legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
					legs_data2[legs_num2][19] = 1		-- 0-none, 1-SID, 2-STAR, 3-APP
					legs_data2[legs_num2][20] = 0
					legs_data2[legs_num2][21] = -1
					legs_data2[legs_num2][22] = 0
					legs_data2[legs_num2][23] = 0
					legs_data2[legs_num2][24] = 0
					legs_data2[legs_num2][25] = 0
					legs_data2[legs_num2][26] = 0
				end
				--break
			end
		end
	end
	--dump_leg()
	
	-- add SID
	if rte_sid_num > 0 then
		
		rte_lat = 0
		rte_lon = 0
		if ref_sid ~= "------" then
			for gg = 1, rte_sid_num do
				rnw_ok = 0
				rnw_txt = "RW" .. ref_rwy
				rnw_txt2 = "RW"
				if rte_sid[gg][2] == "ALL" or rte_sid[gg][2] == "" then
					rnw_ok = 1
				end
				if rte_sid[gg][2] == rnw_txt then
					rnw_ok = 1
				end
				
				-- RWxxB -> L, R, C
				if string.sub(rte_sid[gg][2], -1, -1) == "B" then
					if string.len(rnw_txt) > 4 then
						rnw_txt2 = string.sub(rnw_txt, 1, -2)
					end
					if string.sub(rte_sid[gg][2], 1, -2) == rnw_txt2 then
						rnw_ok = 1
					end
				end
				
				tns_ok = 0
				if rte_sid[gg][2] == ref_sid_tns then
					tns_ok = 1
				end
				
				if rte_sid[gg][1] == ref_sid then
					if rnw_ok == 1 or tns_ok == 1 then
						if rte_sid[gg][3] ~= legs_data2[legs_num2][1] then
							if add_ok == 0 and rnw_added == 0 then
								if legs_data2[2][1] == "DISCONTINUITY" then
									rte_copy(3)
								else
									rte_copy(2)
								end
								legs_num2 = 1
							end
							add_ok = 1
							legs_num2 = legs_num2 + 1
							legs_data2[legs_num2] = {}
							legs_data2[legs_num2][1] = rte_sid[gg][3]
							xx_temp = tonumber(rte_sid[gg][7])
							if xx_temp == nil then
								xx_temp = 0
							end
							xx_temp = xx_temp / 10
							legs_data2[legs_num2][2] = math.rad(xx_temp)		-- brg
							legs_data2[legs_num2][3] = 0		-- distance
							xx_temp = tonumber(rte_sid[gg][4])
							if xx_temp == nil then
								xx_temp = 0
							end
							legs_data2[legs_num2][4] = xx_temp		-- speed
							xx_temp = tonumber(rte_sid[gg][5])
							if xx_temp == nil then
								xx_temp = 0
							end
							if string.sub(rte_sid[gg][5], 1, 2) == "FL" then
								xx_temp = tonumber(string.sub(rte_sid[gg][5], 3, -1)) * 100
							else
								xx_temp = tonumber(rte_sid[gg][5])
							end
							if xx_temp == nil then
								xx_temp = 0
							end
							legs_data2[legs_num2][5] = xx_temp		-- altitude
							xx_temp = 0
							if rte_sid[gg][6] == "+" then
								xx_temp = 43
							elseif rte_sid[gg][6] == "-" then
								xx_temp = 45
							end
							legs_data2[legs_num2][6] = xx_temp	-- altitude type
							legs_data2[legs_num2][7] = 0		-- latitude
							legs_data2[legs_num2][8] = 0		-- longitude
							legs_data2[legs_num2][9] = ref_sid			-- via id
							legs_data2[legs_num2][10] = 0		-- calc speed
							legs_data2[legs_num2][11] = 0		-- calc altitude
							legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
							legs_data2[legs_num2][13] = 0
							legs_data2[legs_num2][14] = 0		-- rest alt
							legs_data2[legs_num2][15] = 0		-- last fuel
							legs_data2[legs_num2][16] = ""
							legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
							legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
							legs_data2[legs_num2][19] = 1		-- 0-none, 1-SID, 2-STAR, 3-APP
							legs_data2[legs_num2][20] = rte_sid[gg][8]	-- vpa
							legs_data2[legs_num2][21] = -1
							legs_data2[legs_num2][22] = 0
							legs_data2[legs_num2][23] = 0
							legs_data2[legs_num2][24] = 0
							legs_data2[legs_num2][25] = 0
							legs_data2[legs_num2][26] = 0
						end
					end
				end
			end
		end
	end
	if add_ok == 1 or rnw_added == 1 then
		if legs_data2_tmp[1][1] ~= legs_data2[legs_num2][1] and legs_data2_tmp_n > 1 
		and legs_data2_tmp[1][1] ~= "DISCONTINUITY" then
			if legs_data2_tmp[1][9] ~= "DIRECT" then
				-- create DISCONTINUITY
				legs_num2 = legs_num2 + 1
				rte_add_disco(legs_num2)
				rte_paste(legs_num2 + 1)
			else
				rte_paste(legs_num2 + 1)
			end
		else
			if legs_data2_tmp[1][1] == legs_data2[legs_num2][1] then
				-- change to SID
				legs_data2_tmp[1][9] = ref_sid
				legs_data2_tmp[1][19] = 3
				---
				rte_paste(legs_num2)
			else
				rte_paste(legs_num2 + 1)
			end
		end
	end
	
	--B738_legs_num2 = legs_num2
	--offset = 1
	
	--dump_leg()
end

function rte_add_star_app()
	
	local ii = 0
	local jj = 0
	local kk = 0
	local gg = 0
	local gg2 = 0
	local xx_temp = 0
	local rnw_ok  = 0
	local rnw_txt = ""
	local rnw_txt2 = ""
	local add_ok = 0
	local tns_ok = 0
	local disco_status = 0
	
	---
	-- local vvv = 0
	-- local fms_line = ""
	
	-- local file_name2 = "legs.txt"
	-- local file_navdata2 = io.open(file_name2, "w")
	----
	
	--delete previous STAR and APP
	rte_del_spec(2)
	--dump_leg()
	rte_lat = 0
	rte_lon = 0
	
	-- add STAR and TRANS STAR
	if rte_star_num > 0 then
		
		if des_star ~= "------" then
			for gg = 1, rte_star_num do
				rnw_ok = 0
				rnw_txt = "RW"
				rnw_txt2 = "RW"
				if des_app ~= "------" then
					if string.len(des_app) > 4 then
						jj, kk = string.find(des_app, "-")
						if jj == nil then
							rnw_txt = rnw_txt .. string.sub(des_app, 2, -2)
						else
							rnw_txt = rnw_txt .. string.sub(des_app, 2, jj-1)
						end
					else
						rnw_txt = rnw_txt .. string.sub(des_app, 2, -1)
					end
				end
				-- RWxx
				if rte_star[gg][2] == rnw_txt then
					rnw_ok = 1
				end
				
				-- RWxxB -> L, R, C
				if string.sub(rte_star[gg][2], -1, -1) == "B" then
					if string.len(rnw_txt) > 4 then
						rnw_txt2 = string.sub(rnw_txt, 1, -2)
					end
					if string.sub(rte_star[gg][2], 1, -2) == rnw_txt2 then
						rnw_ok = 1
					end
				end
				
				-- ALL
				if rte_star[gg][2] == "ALL" or rte_star[gg][2] == " " then
					rnw_ok = 1
				end
				
				tns_ok = 0
				if rte_star[gg][2] == des_star_trans then
					tns_ok = 1
				end
				
				if rte_star[gg][1] == des_star then
					if rnw_ok == 1 or tns_ok == 1 then
						if rte_star[gg][3] ~= legs_data2[legs_num2][1] or string.sub(rte_star[gg][3], 1, 1) == "(" then
							if add_ok == 0 then
								rte_copy(legs_num2 + 1)
								--legs_num2 = legs_num2 - 1
							end
							if disco_status == 0 then
								-- create DISCONTINUITY
								if legs_data2[legs_num2][1] ~= "DISCONTINUITY" then
									legs_num2 = legs_num2 + 1
									rte_add_disco(legs_num2)
								end
							end
							disco_status = 1
							add_ok = 1
							legs_num2 = legs_num2 + 1
							legs_data2[legs_num2] = {}
							legs_data2[legs_num2][1] = rte_star[gg][3]
							xx_temp = tonumber(rte_star[gg][7])
							if xx_temp == nil then
								xx_temp = 0
							end
							xx_temp = xx_temp / 10
							legs_data2[legs_num2][2] = math.rad(xx_temp)		-- brg
							legs_data2[legs_num2][3] = 0		-- distance
							xx_temp = tonumber(rte_star[gg][4])
							if xx_temp == nil then
								xx_temp = 0
							end
							legs_data2[legs_num2][4] = xx_temp		-- speed
							if string.sub(rte_star[gg][5], 1, 2) == "FL" then
								xx_temp = tonumber(string.sub(rte_star[gg][5], 3, -1)) * 100
							else
								xx_temp = tonumber(rte_star[gg][5])
							end
							if xx_temp == nil then
								xx_temp = 0
							end
							legs_data2[legs_num2][5] = xx_temp		-- altitude
							xx_temp = 0
							if rte_star[gg][6] == "+" or rte_star[gg][6] == "A" then
								xx_temp = 43
							elseif rte_star[gg][6] == "-" or rte_star[gg][6] == "B" then
								xx_temp = 45
							end
							legs_data2[legs_num2][6] = xx_temp	-- altitude type
							
							legs_data2[legs_num2][7] = 0		-- latitude
							legs_data2[legs_num2][8] = 0		-- longitude
							legs_data2[legs_num2][9] = des_star			-- via id
							legs_data2[legs_num2][10] = 0		-- calc speed
							legs_data2[legs_num2][11] = 0		-- calc altitude
							legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
							legs_data2[legs_num2][13] = 0
							legs_data2[legs_num2][14] = 0		-- rest alt
							legs_data2[legs_num2][15] = 0		-- last fuel
							legs_data2[legs_num2][16] = ""
							legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
							legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
							legs_data2[legs_num2][19] = 2		-- 0-none, 1-SID, 2-STAR, 3-APP
							legs_data2[legs_num2][20] = rte_star[gg][8]	-- vpa
							legs_data2[legs_num2][21] = -1
							legs_data2[legs_num2][22] = 0
							legs_data2[legs_num2][23] = 0
							legs_data2[legs_num2][24] = 0
							legs_data2[legs_num2][25] = 0
							legs_data2[legs_num2][26] = 0
						else
							disco_status = 1
							-- TO DO add HOLD
							if rte_star[gg][9] >=0 then
								legs_num2 = legs_num2 + 1
								legs_data2[legs_num2] = {}
								legs_data2[legs_num2][1] = rte_star[gg][3]
								xx_temp = tonumber(rte_star[gg][7])
								if xx_temp == nil then
									xx_temp = 0
								end
								xx_temp = xx_temp / 10
								legs_data2[legs_num2][2] = math.rad(xx_temp)		-- brg
								legs_data2[legs_num2][3] = 0		-- distance
								xx_temp = tonumber(rte_star[gg][4])
								if xx_temp == nil then
									xx_temp = 0
								end
								legs_data2[legs_num2][4] = xx_temp		-- speed
								if string.sub(rte_star[gg][5], 1, 2) == "FL" then
									xx_temp = tonumber(string.sub(rte_star[gg][5], 3, -1)) * 100
								else
									xx_temp = tonumber(rte_star[gg][5])
								end
								if xx_temp == nil then
									xx_temp = 0
								end
								legs_data2[legs_num2][5] = xx_temp		-- altitude
								xx_temp = 0
								if rte_star[gg][6] == "+" or rte_star[gg][6] == "A" then
									xx_temp = 43
								elseif rte_star[gg][6] == "-" or rte_star[gg][6] == "B" then
									xx_temp = 45
								end
								legs_data2[legs_num2][6] = xx_temp	-- altitude type
								find_navaid(rte_star[gg][3], "", 2, "")
								legs_data2[legs_num2][7] = 0		-- latitude
								legs_data2[legs_num2][8] = 0		-- longitude
								legs_data2[legs_num2][9] = des_star			-- via id
								legs_data2[legs_num2][10] = 0		-- calc speed
								legs_data2[legs_num2][11] = 0		-- calc altitude
								legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
								legs_data2[legs_num2][13] = 0
								legs_data2[legs_num2][14] = 0		-- rest alt
								legs_data2[legs_num2][15] = 0		-- last fuel
								legs_data2[legs_num2][16] = ""
								legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
								legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
								legs_data2[legs_num2][19] = 2		-- 0-none, 1-SID, 2-STAR, 3-APP
								legs_data2[legs_num2][20] = rte_star[gg][8]	-- vpa
								legs_data2[legs_num2][21] = rte_star[gg][9]
								legs_data2[legs_num2][22] = 0
								legs_data2[legs_num2][23] = 0
								legs_data2[legs_num2][24] = 0
								legs_data2[legs_num2][25] = 0
								legs_data2[legs_num2][26] = 0
							end
						end
					end
				end
			end
		end
		
	end
	
	
	-- add APP and TRANS APP
	disco_status = 0
	if rte_app_num > 0 then
		
		if des_app ~= "------" then
			for gg = 1, rte_app_num do
				
				tns_ok = 0
				if rte_app[gg][2] == des_app_tns then
					tns_ok = 1
				end
				if rte_app[gg][2] == " " then
					tns_ok = 1
				end
				
				-- if file_navdata2 ~= nil then
					-- fms_line = rte_app[gg][1] .. "->" .. des_app .. "," .. rte_app[gg][2] .. "->" .. rnw_txt .. "," .. des_app_tns .. "\n"
					-- file_navdata2:write(fms_line)
				-- end
				
				if rte_app[gg][1] == des_app then
					if tns_ok == 1 then
						if rte_app[gg][3] ~= legs_data2[legs_num2][1] or string.sub(rte_app[gg][3], 1, 1) == "(" then
							if add_ok == 0 then
								rte_copy(legs_num2 + 1)
								--legs_num2 = legs_num2 - 1
							end
							add_ok = 1
							if disco_status == 0 then
								-- create DISCONTINUITY
								if legs_num2 > 2 and legs_data2[legs_num2][1] == "VECTORS" then
									if legs_data2[legs_num2 - 1][1] == rte_app[gg][3] then
										disco_status = 1
										legs_num2 = legs_num2 - 2
									end
								end
							end
							if disco_status == 0 then
								if legs_data2[legs_num2][1] ~= "DISCONTINUITY" then
									legs_num2 = legs_num2 + 1
									rte_add_disco(legs_num2)
								end
							end
							disco_status = 1
							legs_num2 = legs_num2 + 1
							legs_data2[legs_num2] = {}
							legs_data2[legs_num2][1] = rte_app[gg][3]
							xx_temp = tonumber(rte_app[gg][7])
							if xx_temp == nil then
								xx_temp = 0
							end
							xx_temp = xx_temp / 10
							legs_data2[legs_num2][2] = math.rad(xx_temp)		-- brg
							legs_data2[legs_num2][3] = 0		-- distance
							xx_temp = tonumber(rte_app[gg][4])
							if xx_temp == nil then
								xx_temp = 0
							end
							legs_data2[legs_num2][4] = xx_temp		-- speed
							if string.sub(rte_app[gg][5], 1, 2) == "FL" then
								xx_temp = tonumber(string.sub(rte_app[gg][5], 3, -1)) * 100
							else
								xx_temp = tonumber(rte_app[gg][5])
							end
							if xx_temp == nil then
								xx_temp = 0
							end
							legs_data2[legs_num2][5] = xx_temp		-- altitude
							xx_temp = 0
							if rte_app[gg][6] == "+" or rte_app[gg][6] == "A" then
								xx_temp = 43
							elseif rte_app[gg][6] == "-" or rte_app[gg][6] == "B" then
								xx_temp = 45
							end
							legs_data2[legs_num2][6] = xx_temp	-- altitude type
							
							legs_data2[legs_num2][7] = 0		-- latitude
							legs_data2[legs_num2][8] = 0		-- longitude
							legs_data2[legs_num2][9] = des_app			-- via id
							legs_data2[legs_num2][10] = 0		-- calc speed
							legs_data2[legs_num2][11] = 0		-- calc altitude
							legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
							legs_data2[legs_num2][13] = 0
							legs_data2[legs_num2][14] = 0		-- rest alt
							legs_data2[legs_num2][15] = 0		-- last fuel
							legs_data2[legs_num2][16] = ""
							legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
							legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
							legs_data2[legs_num2][19] = 2		-- 0-none, 1-SID, 2-STAR, 3-APP
							legs_data2[legs_num2][20] = rte_app[gg][8]	-- vpa
							legs_data2[legs_num2][21] = -1
							legs_data2[legs_num2][22] = 0
							legs_data2[legs_num2][23] = 0
							legs_data2[legs_num2][24] = 0
							legs_data2[legs_num2][25] = 0
							legs_data2[legs_num2][26] = 0
						else
							disco_status = 1
							-- TO DO add HOLD 
							if rte_app[gg][9] >=0 then
								legs_num2 = legs_num2 + 1
								legs_data2[legs_num2] = {}
								legs_data2[legs_num2][1] = rte_app[gg][3]
								xx_temp = tonumber(rte_app[gg][7])
								if xx_temp == nil then
									xx_temp = 0
								end
								xx_temp = xx_temp / 10
								legs_data2[legs_num2][2] = math.rad(xx_temp)		-- brg
								legs_data2[legs_num2][3] = 0		-- distance
								xx_temp = tonumber(rte_app[gg][4])
								if xx_temp == nil then
									xx_temp = 0
								end
								legs_data2[legs_num2][4] = xx_temp		-- speed
								if string.sub(rte_app[gg][5], 1, 2) == "FL" then
									xx_temp = tonumber(string.sub(rte_app[gg][5], 3, -1)) * 100
								else
									xx_temp = tonumber(rte_app[gg][5])
								end
								if xx_temp == nil then
									xx_temp = 0
								end
								legs_data2[legs_num2][5] = xx_temp		-- altitude
								xx_temp = 0
								if rte_app[gg][6] == "+" or rte_app[gg][6] == "A" then
									xx_temp = 43
								elseif rte_app[gg][6] == "-" or rte_app[gg][6] == "B" then
									xx_temp = 45
								end
								legs_data2[legs_num2][6] = xx_temp	-- altitude type
							
								legs_data2[legs_num2][7] = 0		-- latitude
								legs_data2[legs_num2][8] = 0		-- longitude
								legs_data2[legs_num2][9] = des_app			-- via id
								legs_data2[legs_num2][10] = 0		-- calc speed
								legs_data2[legs_num2][11] = 0		-- calc altitude
								legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
								legs_data2[legs_num2][13] = 0
								legs_data2[legs_num2][14] = 0		-- rest alt
								legs_data2[legs_num2][15] = 0		-- last fuel
								legs_data2[legs_num2][16] = ""
								legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
								legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
								legs_data2[legs_num2][19] = 2		-- 0-none, 1-SID, 2-STAR, 3-APP
								legs_data2[legs_num2][20] = rte_app[gg][8]	-- vpa
								legs_data2[legs_num2][21] = rte_app[gg][9]
								legs_data2[legs_num2][22] = 0
								legs_data2[legs_num2][23] = 0
								legs_data2[legs_num2][24] = 0
								legs_data2[legs_num2][25] = 0
								legs_data2[legs_num2][26] = 0
							end
						end
					end
				end
				if file_navdata2 ~= nil then
					fms_line = "-> OK\n"
					file_navdata2:write(fms_line)
				end
			
			
			end
		end
	end
	
	
	if add_ok == 1 then
		rte_paste(legs_num2 + 1)
	end
	
	
	-- if file_navdata2 ~= nil then
		-- file_navdata2:close()
	-- end
	
	--B738_legs_num2 = legs_num2
	--offset = 1
	--entry = "." .. rte_star[1][2] .. "." .. rnw_txt .. "."
	
	--dump_leg2()
	--dump_leg()
end


function dump_leg2()
	local vvv = 0
	local fms_line = ""
	
	local file_name2 = "legs.txt"
	local file_navdata2 = io.open(file_name2, "w")
	
	if file_navdata2 ~= nil then
		if earth_nav_num > 0 then
			for vvv = 1, earth_nav_num  do
				fms_line = tostring(earth_nav[vvv][2]) .. "," .. tostring(earth_nav[vvv][3]) .. "," .. earth_nav[vvv][4] .. "," .. earth_nav[vvv][5] .. "\n"
				file_navdata2:write(fms_line)
			end
		end
		file_navdata2:close()
	end
end


function read_ref_data()
	
	local fms_line = ""
	local fms_word = {}
	local ii = 0
	local jj = 0
	local kk = 0
	local token = ""
	local old_sid = ""
	local temp_sid = ""
	local old_sid_tns = ""
	local old_star = ""
	local old_star_tns = ""
	local old_app = ""
	local old_app_tns = ""
	local temp_str = ""
	local temp_num = 0
	
	ref_data = {}
	rwy_num = 0
	ref_data_sid = {}
	sid_num = 0
	ref_data_star = {}
	star_num = 0
	ref_data_star_tns = {}
	ref_data_star_tns_n = 0
	ref_data_app = {}
	ref_data_app_n = 0
	ref_data_app_tns = {}
	ref_data_app_tns_n = 0
	ref_ed_app = {}
	ref_ed_app_n = 0
	
	local rte_temp = ""
	local rte_temp_old = ""
	rte_sid = {}
	rte_sid_num = 0
	
	local compare = 0
	
	fms_line = file_navdata:read()
	while fms_line do
		-- read RUNWAYs
		if string.sub(fms_line, 1, 4) == "RWY:" then
			rwy_num = rwy_num + 1
			ref_data[rwy_num] = {}
			ref_data[rwy_num][1] = string.sub(fms_line, 7, 9)		-- RWY
			ref_data[rwy_num][2] = 0	-- used rwy
			--ref_data[rwy_num][2] = string.sub(fms_line, -26, -18)	-- lat
			--ref_data[rwy_num][3] = string.sub(fms_line, -16, -7)	-- lon
		end
		
		-- split DATA
		fms_word = {}
		ii = 0
		for token in string.gmatch(fms_line, "[^,]+") do	--(fms_line, "([^,]+),%s*") do
			ii = ii + 1
			fms_word[ii] = token
		end
		
		-- read SIDs and TRANSs
		if string.sub(fms_word[1], 1, 4) == "SID:" then
			-- read SIDs
			if string.sub(fms_word[4], 1, 2) == "RW" or fms_word[4] == "ALL" then
				temp_sid = fms_word[3] .. fms_word[4]
				if old_sid ~= temp_sid then 
					sid_num = sid_num + 1
					ref_data_sid[sid_num] = {}
					ref_data_sid[sid_num][1] = fms_word[3]		-- id SID
					ref_data_sid[sid_num][2] = fms_word[4]		-- id runway
					old_sid = fms_word[3] .. fms_word[4]
				end
			else
				-- read TRANSs
				fms_word[4] = string.gsub(fms_word[4], "%s+", "")
				if fms_word[4] ~= "" then
					temp_sid = fms_word[3] .. fms_word[4]
					if old_sid_tns ~= temp_sid then
						tns_num = tns_num + 1
						ref_data_tns[tns_num] = {}
						ref_data_tns[tns_num][1] = fms_word[3]		-- id SID
						ref_data_tns[tns_num][2] = fms_word[4]		-- id trans
						old_sid_tns = fms_word[3] .. fms_word[4]
					end
				end
			end
			-- read Route SID
			rte_sid_num = rte_sid_num + 1
			rte_sid[rte_sid_num] = {}
			rte_sid[rte_sid_num][1] = fms_word[3]	-- id SID
			rte_sid[rte_sid_num][2] = fms_word[4]	-- id RW / trans
			if fms_word[5] == " " then
				temp_str = ""
				temp_num = tonumber(fms_word[22])
				
				if fms_word[14] == " " then
					-- INTC
					rte_sid[rte_sid_num][3] = "(INTC)"	-- id WPT
				else
					-- to XXX after DME
					temp_str = "(" .. fms_word[14] .. "-"
					if temp_num ~= nil then
						temp_num = temp_num / 10
						temp_str = temp_str .. string.format("%02d", temp_num)
					end
					temp_str = temp_str .. ")"
					rte_sid[rte_sid_num][3] = temp_str
				end
			else
				if fms_word[12] == "HM" then		-- HOLD
					rte_sid[rte_sid_num][3] = fms_word[5]	-- id WPT
					if fms_word[10] == "L" then
						rte_sid[rte_sid_num][9] = 0		-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
					else
						rte_sid[rte_sid_num][9] = 1		-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
					end
				elseif fms_word[12] == "VM" or fms_word[12] == "FM" then		-- VECTORS
					rte_sid[rte_sid_num][3] = "VECTORS"	-- id WPT
					rte_sid[rte_sid_num][9] = -1	-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
				else
					rte_sid[rte_sid_num][3] = fms_word[5]	-- id WPT
					rte_sid[rte_sid_num][9] = -1	-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
				end
			end
			rte_sid[rte_sid_num][4] = fms_word[28]	-- restrict speed
			rte_sid[rte_sid_num][5] = fms_word[24]	-- restrict altitude
			rte_sid[rte_sid_num][6] = fms_word[23]	-- restrict altitude +,-,B
			rte_sid[rte_sid_num][7] = fms_word[21]	-- course
			rte_sid[rte_sid_num][8] = fms_word[29]	-- vpa
			rte_sid[rte_sid_num][10] = fms_word[22]	-- distance
		end
		
		-- read STARs
		if string.sub(fms_word[1], 1, 5) == "STAR:" then
			if string.sub(fms_word[4], 1, 2) == "RW" or fms_word[4] == "ALL" then
				temp_sid = fms_word[3] .. fms_word[4]
				if old_star ~= temp_sid then
					star_num = star_num + 1
					ref_data_star[star_num] = {}
					ref_data_star[star_num][1] = fms_word[3]		-- id STAR
					ref_data_star[star_num][2] = fms_word[4]		-- id runway
					old_star = fms_word[3] .. fms_word[4]
				end
			else
				temp_sid = fms_word[3] .. fms_word[4]
				if old_star_tns ~= temp_sid then
					ref_data_star_tns_n = ref_data_star_tns_n + 1
					ref_data_star_tns[ref_data_star_tns_n] = {}
					ref_data_star_tns[ref_data_star_tns_n][1] = fms_word[3]		-- id STAR
					ref_data_star_tns[ref_data_star_tns_n][2] = fms_word[4]		-- id trans
					old_star_tns = fms_word[3] .. fms_word[4]
				end
			end
		end
		
		-- read APPROACHs
		if string.sub(fms_word[1], 1, 6) == "APPCH:" then
			if fms_word[2] == "A" then
				temp_sid = fms_word[3] .. fms_word[4]
				if old_app_tns ~= temp_sid then
					ref_data_app_tns_n = ref_data_app_tns_n + 1
					ref_data_app_tns[ref_data_app_tns_n] = {}
					ref_data_app_tns[ref_data_app_tns_n][1] = fms_word[3]		-- id APP
					ref_data_app_tns[ref_data_app_tns_n][2] = fms_word[4]		-- id trans
					ref_data_app_tns[ref_data_app_tns_n][3] = fms_word[5]		-- id E/D
					old_app_tns = fms_word[3] .. fms_word[4]
				end
			else
				if old_app ~= fms_word[3] then
					ref_data_app_n = ref_data_app_n + 1
					ref_data_app[ref_data_app_n] = fms_word[3]		-- id APP
					old_app = fms_word[3]
				end
				if fms_word[9] == "E  F" then	-- E/D
					ref_ed_app_n = ref_ed_app_n + 1
					ref_ed_app[ref_ed_app_n] = {}
					ref_ed_app[ref_ed_app_n][1] = fms_word[3]	-- id APP
					ref_ed_app[ref_ed_app_n][2] = fms_word[5]	-- id E/D
				end
			end
		end
		
		fms_line = file_navdata:read()
	end
	
	if rwy_num > 0 and rnw_data_num > 0 then
		-- find unknown runways
		for jj = 1, rnw_data_num do
			if rnw_data[jj][1] == entry then
				rnw_data[jj][9] = 0
				for ii = 1, rwy_num do
					if rnw_data[jj][2] == ref_data[ii][1] then
						rnw_data[jj][9] = 1
						ref_data[ii][2] = 1
					end
				end
			end
		end
		
		-- compare runways and change to CIFP data
		for ii = 1, rwy_num do
			if ref_data[ii][2] == 0 then
				for jj = 1, rnw_data_num do
					if rnw_data[jj][1] == entry and rnw_data[jj][9] == 0 then
						compare = 0
						kk = string.len(ref_data[ii][1])
						if kk ==  string.len(rnw_data[jj][2]) then
							if kk > 2 then
								if string.sub(ref_data[ii][1], -1, -1) == string.sub(rnw_data[jj][2], -1, -1) then
									compare = 1
								end
							else
								compare = 1
							end
						end
						
						if compare == 1 then
							if string.len(ref_data[ii][1]) > 2 then
								temp_num =  tonumber(string.sub(ref_data[ii][1], 1, -2))
							else
								temp_num =  tonumber(ref_data[ii][1])
							end
							if temp_num ~= nil then
								kk = temp_num
								if string.len(rnw_data[jj][2]) > 2 then
									temp_num =  tonumber(string.sub(rnw_data[jj][2], 1, -2))
								else
									temp_num =  tonumber(rnw_data[jj][2])
								end
								if temp_num ~= nil then
									kk = ((kk - temp_num) + 360) % 360
									if kk > 180 then
										kk = kk - 360
									end
									if kk < 0 then
										kk = -kk
									end
									if kk < 3 then
										rnw_data[jj][2] = ref_data[ii][1]		-- runway
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	--dump_sid()
	
end

function dump_sid()
	local vvv = 0
	local fms_line = ""
	
	local file_name2 = "legs.txt"
	local file_navdata2 = io.open(file_name2, "w")
	
	if file_navdata2 ~= nil then
		if rte_sid_num > 0 then
			for vvv = 1, rte_sid_num  do
				fms_line = rte_sid[vvv][1] .. "," .. rte_sid[vvv][2] .. "," .. rte_sid[vvv][3] .. "\n"
				file_navdata2:write(fms_line)
			end
		end
		file_navdata2:close()
	end
end


function read_des_data()
	
	local fms_line = ""
	local fms_word = {}
	local ii = 0
	local jj = 0
	local kk = 0
	local token = ""
	local temp_sid = ""
	local old_star = ""
	local old_star_tns = ""
	local old_app = ""
	local old_app_tns = ""
	local temp_str = ""
	local temp_num = 0
	local compare = 0
	
	des_data = {}
	des_rwy_num = 0
	data_des_star = {}
	data_des_star_n = 0
	data_des_star_tns = {}
	data_des_star_tns_n = 0
	data_des_app = {}
	data_des_app_n = 0
	data_des_app_tns = {}
	data_des_app_tns_n = 0
	ed_app_num = 0
	ed_app = {}
	
	rte_star = {}
	rte_star_num = 0
	rte_app = {}
	rte_app_num = 0
	
	fms_line = file_navdata:read()
	while fms_line do
		
		-- split DATA
		fms_word = {}
		ii = 0
		for token in string.gmatch(fms_line, "[^,]+") do 		--%s*") do
			ii = ii + 1
			fms_word[ii] = token
		end
		
		-- read RUNWAYs
		if string.sub(fms_line, 1, 4) == "RWY:" then
			des_rwy_num = des_rwy_num + 1
			des_data[des_rwy_num] = {}
			des_data[des_rwy_num][1] = string.sub(fms_line, 5, 9)		-- RWY
			des_data[des_rwy_num][2] = string.sub(fms_line, -26, -18)	-- lat
			des_data[des_rwy_num][3] = string.sub(fms_line, -16, -7)	-- lon
			des_data[des_rwy_num][4] = fms_word[6]						-- id ILS
			des_data[des_rwy_num][5] = 0
		end
		
		-- read STARs
		if string.sub(fms_word[1], 1, 5) == "STAR:" then
			if string.sub(fms_word[4], 1, 2) == "RW" or fms_word[4] == "ALL" then
				temp_sid = fms_word[3] .. fms_word[4]
				if old_star ~= temp_sid then
					data_des_star_n = data_des_star_n + 1
					data_des_star[data_des_star_n] = {}
					data_des_star[data_des_star_n][1] = fms_word[3]		-- id STAR
					data_des_star[data_des_star_n][2] = fms_word[4]		-- id runway
					old_star = fms_word[3] .. fms_word[4]
				end
			else
				temp_sid = fms_word[3] .. fms_word[4]
				if old_star_tns ~= temp_sid then
					data_des_star_tns_n = data_des_star_tns_n + 1
					data_des_star_tns[data_des_star_tns_n] = {}
					data_des_star_tns[data_des_star_tns_n][1] = fms_word[3]		-- id STAR
					data_des_star_tns[data_des_star_tns_n][2] = fms_word[4]		-- id trans
					old_star_tns = fms_word[3] .. fms_word[4]
				end
			end
			-- read Route STAR
			--fms_word[4] = string.gsub(fms_word[4], "%s+", "")
			rte_star_num = rte_star_num + 1
			rte_star[rte_star_num] = {}
			rte_star[rte_star_num][1] = fms_word[3]	-- id STAR
			rte_star[rte_star_num][2] = fms_word[4]	-- id RW / trans
			if fms_word[12] == "HM" then		-- HOLD
				rte_star[rte_star_num][3] = fms_word[5]	-- id WPT
				if fms_word[10] == "L" then
					rte_star[rte_star_num][9] = 0		-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
				else
					rte_star[rte_star_num][9] = 1		-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
				end
			elseif fms_word[12] == "VM" or fms_word[12] == "FM" then		-- VECTORS
				rte_star[rte_star_num][3] = "VECTORS"	-- id WPT
				rte_star[rte_star_num][9] = -1	-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
			else
				rte_star[rte_star_num][3] = fms_word[5]	-- id WPT
				rte_star[rte_star_num][9] = -1	-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
			end
			rte_star[rte_star_num][4] = fms_word[28]	-- restrict speed
			rte_star[rte_star_num][5] = fms_word[24]	-- restrict altitude
			rte_star[rte_star_num][6] = fms_word[23]	-- restrict altitude +,-,B
			rte_star[rte_star_num][7] = fms_word[21]	-- course
			rte_star[rte_star_num][8] = fms_word[29]	-- vpa
			rte_star[rte_star_num][10] = fms_word[22]	-- distance
		end
		
		-- read APPROACHs
		if string.sub(fms_word[1], 1, 6) == "APPCH:" then
			if fms_word[2] == "A" then
				temp_sid = fms_word[3] .. fms_word[4]
				if old_app_tns ~= temp_sid then
					data_des_app_tns_n = data_des_app_tns_n + 1
					data_des_app_tns[data_des_app_tns_n] = {}
					data_des_app_tns[data_des_app_tns_n][1] = fms_word[3]		-- id APP
					data_des_app_tns[data_des_app_tns_n][2] = fms_word[4]		-- id trans
					data_des_app_tns[data_des_app_tns_n][3] = fms_word[5]		-- id E/D
					old_app_tns = fms_word[3] .. fms_word[4]
				end
			else
				if old_app ~= fms_word[3] then
					data_des_app_n = data_des_app_n + 1
					data_des_app[data_des_app_n] = fms_word[3]		-- id APP
					old_app = fms_word[3]
				end
				if fms_word[9] == "E  F" then	-- E/D
					ed_app_num = ed_app_num + 1
					ed_app[ed_app_num] = {}
					ed_app[ed_app_num][1] = fms_word[3]	-- id APP
					ed_app[ed_app_num][2] = fms_word[5]	-- id E/D
				end
			end
			-- read Route APP
			--fms_word[4] = string.gsub(fms_word[4], "%s+", "")
			rte_app_num = rte_app_num + 1
			rte_app[rte_app_num] = {}
			rte_app[rte_app_num][1] = fms_word[3]	-- id SID
			rte_app[rte_app_num][2] = fms_word[4]	-- id RW / trans
			if fms_word[5] == " " then
				temp_str = ""
				temp_num = tonumber(fms_word[22])
				
				if fms_word[14] == " " then
					-- INTC
					rte_app[rte_app_num][3] = "(INTC)"	-- id WPT
				else
					-- to XXX after DME
					temp_str = "(" .. fms_word[14] .. "-"
					if temp_num ~= nil then
						temp_num = temp_num / 10
						temp_str = temp_str .. string.format("%02d", temp_num)
					end
					temp_str = temp_str .. ")"
					rte_app[rte_app_num][3] = temp_str
				end
			else
				if fms_word[12] == "HM" then		-- HOLD
					rte_app[rte_app_num][3] = fms_word[5]	-- id WPT
					if fms_word[10] == "L" then
						rte_app[rte_app_num][9] = 0		-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
					else
						rte_app[rte_app_num][9] = 1		-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
					end
				elseif fms_word[12] == "VM" or fms_word[12] == "FM" then		-- VECTORS
					rte_app[rte_app_num][3] = "VECTORS"	-- id WPT
					rte_app[rte_app_num][9] = -1	-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
				else
					rte_app[rte_app_num][3] = fms_word[5]	-- id WPT
					rte_app[rte_app_num][9] = -1	-- HOLD: -1 -> no hold, 0 -> L, 1 -> R
				end
			end
			rte_app[rte_app_num][4] = fms_word[28]	-- restrict speed
			rte_app[rte_app_num][5] = fms_word[24]	-- restrict altitude
			rte_app[rte_app_num][6] = fms_word[23]	-- restrict altitude +,-,B
			rte_app[rte_app_num][7] = fms_word[21]	-- course
			rte_app[rte_app_num][8] = fms_word[29]	-- vpa
			rte_app[rte_app_num][10] = fms_word[22]	-- distance
		end
		
		fms_line = file_navdata:read()
	end
	
	if des_rwy_num > 0 and rnw_data_num > 0 then
	
		-- find unknown runways
		for jj = 1, rnw_data_num do
			if rnw_data[jj][1] == entry then
				rnw_data[jj][9] = 0
				for ii = 1, des_rwy_num do
					if rnw_data[jj][2] == des_data[ii][1] then
						rnw_data[jj][9] = 1
						des_data[ii][5] = 1
					end
				end
			end
		end
		
		-- compare runways and change to CIFP data
		for ii = 1, des_rwy_num do
			if des_data[ii][5] == 0 then
				for jj = 1, rnw_data_num do
					if rnw_data[jj][1] == entry and rnw_data[jj][9] == 0 then
						compare = 0
						kk = string.len(des_data[ii][1])
						if kk ==  string.len(rnw_data[jj][2]) then
							if kk > 2 then
								if string.sub(des_data[ii][1], -1, -1) == string.sub(rnw_data[jj][2], -1, -1) then
									compare = 1
								end
							else
								compare = 1
							end
						end
						
						if compare == 1 then
							if string.len(des_data[ii][1]) > 2 then
								temp_num =  tonumber(string.sub(des_data[ii][1], 1, -2))
							else
								temp_num =  tonumber(des_data[ii][1])
							end
							if temp_num ~= nil then
								kk = temp_num
								if string.len(rnw_data[jj][2]) > 2 then
									temp_num =  tonumber(string.sub(rnw_data[jj][2], 1, -2))
								else
									temp_num =  tonumber(rnw_data[jj][2])
								end
								if temp_num ~= nil then
									kk = ((kk - temp_num) + 360) % 360
									if kk > 180 then
										kk = kk - 360
									end
									if kk < 0 then
										kk = -kk
									end
									if kk < 3 then
										rnw_data[jj][2] = des_data[ii][1]		-- runway
									end
								end
							end
						end
					end
				end
			end
		end
	end

	--dump_star()
	
end


function dump_star()
	local vvv = 0
	local fms_line = ""
	
	local file_name2 = "legs.txt"
	local file_navdata2 = io.open(file_name2, "w")
	
	if file_navdata2 ~= nil then
		if rte_star_num > 0 then
			for vvv = 1, rte_star_num  do
				fms_line = rte_star[vvv][1] .. "," .. rte_star[vvv][2] .. "," .. rte_star[vvv][3] .. "\n"
				file_navdata2:write(fms_line)
			end
		end
		file_navdata2:close()
	end
end


function B738_detect_fmod()
	
	local fms_line = ""
	local temp_fmod = 0
	
	--file_name = "Aircraft/B737-800X/fmod/b738.snd"
	file_name = file_path .. "fmod/b738.snd"
	file_navdata = io.open(file_name, "r")
	if file_navdata == nil then
		fmod_version = ">NOT FOUND<"
	else
		fmod_version = ">UNKNOWN<"
		fms_line = file_navdata:read()
		while fms_line do
			if string.sub(fms_line, 1, 9) == "#version=" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 9 then
					fmod_version = string.sub(fms_line, 10, -1)
				end
				break
			end
			fms_line = file_navdata:read()
		end
		file_navdata:close()
	end
	
end


function B738_find_path()
	local i = 0
	local j = 0
	local k = 0
	local ii = 0
	local jj = 0
	local line_trim = ""
	local line_char = ""
	local line_lenght = 0
	local words = {}
	local line = ""
	file_path = ""
	
	file_name = "Log.txt"
	file_navdata = io.open(file_name, "r")
	if file_navdata ~= nil then
		line = file_navdata:read()
		while line do
			i = 0
			j = 0
			line_trim = ""
			line_char = ""
			line_lenght = string.len(line)
			if line_lenght > 0 then
				for k = 1, line_lenght do
					line_char = string.sub(line, k, k)
					if line_char == " " then
						if i == 1 then
							j = j + 1
							words[j] = line_trim
							i = 0
							line_trim = ""
							ii,jj = string.find(words[j], "/b738.acf")
							if ii ~= nil then
								file_path = string.sub(words[j], 1, ii)
								break
							end
						end
					else
						line_trim = line_trim .. line_char
						i = 1
					end
				end
				if string.len(line_trim) > 0 then
					j = j + 1
					words[j] = line_trim
				end
			end
			line = file_navdata:read()
		end
		file_navdata:close()
	end
	
end


function B738_default_fmod_config()

	-- DEFAULT value
	B738DR_enable_pax_boarding = 1
	B738DR_enable_gyro = 0
	B738DR_enable_crew = 1
	B738DR_enable_chatter = 1
	B738DR_airport_set = 2
	B738DR_vol_int_ducker = 0
	B738DR_vol_int_eng = 10
	B738DR_vol_int_start = 10
	B738DR_vol_int_ac = 10
	B738DR_vol_int_gyro = 10
	B738DR_vol_int_roll = 10
	B738DR_vol_int_bump = 10
	B738DR_vol_int_pax = 5
	B738DR_vol_int_pax_applause = 1
	B738DR_vol_int_wind = 10
	B738DR_enable_mutetrim = 0
	B738DR_vol_airport = 5
	
end

function B738_default_others_config()
		B738DR_align_time = 0
		simDR_hide_yoke = 1
		B738DR_toe_brakes_ovr = 0
		B738DR_chock_status = 0
		B738DR_pause_td = 0
		B738DR_lock_idle_thrust = 0
		B738DR_engine_no_running_state = 0
		B738DR_parkbrake_remove_chock = 1
		B738DR_throttle_noise = 0
		B738DR_fuelgauge = 0
		B738DR_nosewheel = 0
		B738DR_fpln_format = 0
		units = 0
end


function B738_load_config()
	
	local fms_line = ""
	local temp_fmod = 0
	
	--file_name = file_path .. "b738x.cfg"
	file_name = "b738x.cfg"
	file_navdata = io.open(file_name, "r")
	if file_navdata ~= nil then
		fms_line = file_navdata:read()
		while fms_line do
			-- FMOD
			if string.sub(fms_line, 1, 16) == "PAX BOARDING   =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_enable_pax_boarding = 1
						else
							B738DR_enable_pax_boarding = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "GYRO VIBRATORS =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_enable_gyro = 1
						else
							B738DR_enable_gyro = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "CREW ANNOUN    =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_enable_crew = 1
						else
							B738DR_enable_crew = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "CHATTER PASS   =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_enable_chatter = 1
						else
							B738DR_enable_chatter = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "AIRPORT SET    =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_airport_set = 1
						elseif temp_fmod == 2 then
							B738DR_airport_set = 2
						else
							B738DR_airport_set = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "INTERNAL VOL   =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_vol_int_ducker = 1
						else
							B738DR_vol_int_ducker = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "INT ENG SND    =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						 temp_fmod = roundUpToIncrement(temp_fmod, 1 )
						if temp_fmod >= 0 and  temp_fmod < 10 then
							B738DR_vol_int_eng = temp_fmod
						else
							B738DR_vol_int_eng = 10
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "INT ENG START  =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						 temp_fmod = roundUpToIncrement(temp_fmod, 1 )
						if temp_fmod >= 0 and  temp_fmod < 10 then
							B738DR_vol_int_start = temp_fmod
						else
							B738DR_vol_int_start = 10
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "AC FANS        =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						 temp_fmod = roundUpToIncrement(temp_fmod, 1 )
						if temp_fmod >= 0 and  temp_fmod < 10 then
							B738DR_vol_int_ac = temp_fmod
						else
							B738DR_vol_int_ac = 10
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "GYRO VOL       =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						 temp_fmod = roundUpToIncrement(temp_fmod, 1 )
						if temp_fmod >= 0 and  temp_fmod < 10 then
							B738DR_vol_int_gyro = temp_fmod
						else
							B738DR_vol_int_gyro = 10
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "ROLL VOL       =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						 temp_fmod = roundUpToIncrement(temp_fmod, 1 )
						if temp_fmod >= 0 and  temp_fmod < 10 then
							B738DR_vol_int_roll = temp_fmod
						else
							B738DR_vol_int_roll = 10
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "BUMP INTENS    =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						 temp_fmod = roundUpToIncrement(temp_fmod, 1 )
						if temp_fmod >= 0 and  temp_fmod < 10 then
							B738DR_vol_int_bump = temp_fmod
						else
							B738DR_vol_int_bump = 10
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "PAX VOLUME     =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						 temp_fmod = roundUpToIncrement(temp_fmod, 1 )
						if temp_fmod >= 0 and  temp_fmod < 10 then
							B738DR_vol_int_pax = temp_fmod
						else
							B738DR_vol_int_pax = 5
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "PAX APPLAUSE   =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_vol_int_pax_applause = 1
						else
							B738DR_vol_int_pax_applause = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "INT WIND       =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						 temp_fmod = roundUpToIncrement(temp_fmod, 1 )
						if temp_fmod >= 0 and  temp_fmod < 10 then
							B738DR_vol_int_wind = temp_fmod
						else
							B738DR_vol_int_wind = 10
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "MUTE TRIM WH   =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_enable_mutetrim = 1
						else
							B738DR_enable_mutetrim = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "AIRPORT VOL    =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						 temp_fmod = roundUpToIncrement(temp_fmod, 1 )
						if temp_fmod >= 0 and  temp_fmod < 10 then
							B738DR_vol_airport = temp_fmod
						else
							B738DR_vol_airport = 10
						end
					end
				end
			-- OTHERS
			elseif string.sub(fms_line, 1, 16) == "UNITS          =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							units = 1
						else
							units = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "ALIGN TIME     =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_align_time = 1
						elseif temp_fmod == 2 then
							B738DR_align_time = 2
						else
							B738DR_align_time = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "HIDE YOKE      =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							simDR_hide_yoke = 1
						else
							simDR_hide_yoke = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "PAUSE AT T/D   =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_pause_td = 1
						else
							B738DR_pause_td = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "TOE BRAKE AXIS =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_toe_brakes_ovr = 1
						else
							B738DR_toe_brakes_ovr = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "LOCK IDLE THR  =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_lock_idle_thrust = 1
						else
							B738DR_lock_idle_thrust = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "ENG NO RUNNING =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_engine_no_running_state = 1
						else
							B738DR_engine_no_running_state = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "BRAKE REM CHOCK=" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_parkbrake_remove_chock = 1
						else
							B738DR_parkbrake_remove_chock = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "THROTTLE NOISE =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						 temp_fmod = roundUpToIncrement(temp_fmod, 1 )
						if temp_fmod >= 0 and  temp_fmod < 10 then
							B738DR_throttle_noise = temp_fmod
						else
							B738DR_throttle_noise = 10
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "FUEL GAUGE     =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_fuelgauge = 1
						else
							B738DR_fuelgauge = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "NOSEWHEEL AXIS =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_nosewheel = 1
						else
							B738DR_nosewheel = 0
						end
					end
				end
			elseif string.sub(fms_line, 1, 16) == "FPLN SAVE FMT  =" then
				temp_fmod = string.len(fms_line)
				if temp_fmod > 16 then
					temp_fmod = tonumber(string.sub(fms_line, 17, -1))
					if temp_fmod ~= nil then
						if temp_fmod == 1 then
							B738DR_fpln_format = 1
						else
							B738DR_fpln_format = 0
						end
					end
				end
			end
			fms_line = file_navdata:read()
		end
		file_navdata:close()
	end
end

function B738_save_config()
	
	local fms_line = ""
	
	--file_name = file_path .. "b738x.cfg"
	file_name = "b738x.cfg"
	file_navdata = io.open(file_name, "w")
	if file_navdata ~= nil then
		-- OTHERS
		fms_line = "*** B737-800X ZIBO MOD ***\n"
		file_navdata:write(fms_line)
		fms_line = "*** Config file        ***\n"
		file_navdata:write(fms_line)
		fms_line = "UNITS          = " .. string.format("%1d", B738DR_fmc_units) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "ALIGN TIME     = " .. string.format("%1d", B738DR_align_time) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "HIDE YOKE      = " .. string.format("%1d", simDR_hide_yoke) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "PAUSE AT T/D   = " .. string.format("%1d", B738DR_pause_td) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "TOE BRAKE AXIS = " .. string.format("%1d", B738DR_toe_brakes_ovr) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "LOCK IDLE THR  = " .. string.format("%1d", B738DR_lock_idle_thrust) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "ENG NO RUNNING = " .. string.format("%1d", B738DR_engine_no_running_state) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "BRAKE REM CHOCK= " .. string.format("%1d", B738DR_parkbrake_remove_chock) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "THROTTLE NOISE = " .. string.format("%1d", B738DR_throttle_noise) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "FUEL GAUGE     = " .. string.format("%1d", B738DR_fuelgauge) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "NOSEWHEEL AXIS = " .. string.format("%1d", B738DR_nosewheel) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "FPLN SAVE FMT  = " .. string.format("%1d", B738DR_fpln_format) .. "\n"
		file_navdata:write(fms_line)
		-- FMOD
		fms_line = "\n*** FMOD by AudioBird XP ***\n"
		file_navdata:write(fms_line)
		fms_line = "PAX BOARDING   = " .. string.format("%1d", B738DR_enable_pax_boarding) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "GYRO VIBRATORS = " .. string.format("%1d", B738DR_enable_gyro) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "CREW ANNOUN    = " .. string.format("%1d", B738DR_enable_crew) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "CHATTER PASS   = " .. string.format("%1d", B738DR_enable_chatter) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "AIRPORT SET    = " .. string.format("%1d", B738DR_airport_set) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "INTERNAL VOL   = " .. string.format("%1d", B738DR_vol_int_ducker) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "INT ENG SND    = " .. string.format("%1d", B738DR_vol_int_eng) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "INT ENG START  = " .. string.format("%1d", B738DR_vol_int_start) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "AC FANS        = " .. string.format("%1d", B738DR_vol_int_ac) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "GYRO VOL       = " .. string.format("%1d", B738DR_vol_int_gyro) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "ROLL VOL       = " .. string.format("%1d", B738DR_vol_int_roll) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "BUMP INTENS    = " .. string.format("%1d", B738DR_vol_int_bump) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "PAX VOLUME     = " .. string.format("%1d", B738DR_vol_int_pax) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "PAX APPLAUSE   = " .. string.format("%1d", B738DR_vol_int_pax_applause) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "INT WIND       = " .. string.format("%1d", B738DR_vol_int_wind) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "MUTE TRIM WH   = " .. string.format("%1d", B738DR_enable_mutetrim) .. "\n"
		file_navdata:write(fms_line)
		fms_line = "AIRPORT VOL    = " .. string.format("%1d", B738DR_vol_airport) .. "\n"
		file_navdata:write(fms_line)
		-- fms_line = "XP INT VOL     = " .. string.format("%1d", B738DR_xp_int_vol) .. "\n"
		-- file_navdata:write(fms_line)
		file_navdata:close()
	end
	
end


function dump_leg()
	local vvv = 0
	local fms_line = ""
	
	local file_name2 = "legs.txt"
	local file_navdata2 = io.open(file_name2, "w")
	
	if file_navdata2 ~= nil then
		if legs_num2 > 0 then
			for vvv = 1, legs_num2 + 1 do
				fms_line = legs_data2[vvv][1] .. "," .. legs_data2[vvv][16] .. "," .. legs_data2[vvv][9] .. ","
				fms_line = fms_line .. "" .. "," .. "" .. "\n"
				--fms_line = legs_data2[vvv][1] .. "\n"
				file_navdata2:write(fms_line)
			end
		end
		file_navdata2:close()
	end
end

function read_ref_data2()

	file_name = "Custom Data/CIFP/" .. ref_icao
	file_name = file_name .. ".dat"
	file_navdata = io.open(file_name, "r")
	if file_navdata == nil then
		file_name = "Resources/default data/CIFP/" .. ref_icao
		file_name = file_name .. ".dat"
		file_navdata = io.open(file_name, "r")
		if file_navdata ~= nil then
			read_ref_data()		-- read reference airport data
			file_navdata:close()
		end
	else
		read_ref_data()		-- read reference airport data
		file_navdata:close()
	end

end


function read_des_data2()

	file_name = "Custom Data/CIFP/" .. des_icao
	file_name = file_name .. ".dat"
	file_navdata = io.open(file_name, "r")
	if file_navdata == nil then
		file_name = "Resources/default data/CIFP/" .. des_icao
		file_name = file_name .. ".dat"
		file_navdata = io.open(file_name, "r")
		if file_navdata ~= nil then
			read_des_data()		-- read reference airport data
			file_navdata:close()
		end
	else
		read_des_data()		-- read reference airport data
		file_navdata:close()
	end
	
	--offset = 1

end


function read_fpln2()
	local fms_line = ""
	local fms_word = {}
	local ii = 0
	local jj = 0
	local kk = 0
	local token = ""
	
	ref_rwy_map = {}
	ref_rwy_map_num = 0
	
	fpln_data2 = {}
	fpln_num2 = 0
	
	local fpln_active = 0
	local ref_icao_active = 0
	local ref_icao_found = 0
	local des_icao_active = 0
	local des_icao_found = 0
	local ref_rwy_found = 0
	local des_rwy_found = 0
	local trans_alt_found = 0
	local ref_rwy_map_active = 0
	local ref_rwy_map_found = 0
	
	legs_data = {}
	legs_num = 0
	local leg_enable = 0
	local leg_entry = 0
	local leg_id = ""
	local leg_brg = 0
	local leg_spd = 0
	local leg_alt = 0
	local leg_alt_type = 0
	local leg_dis = 0
	local leg_lat = 0
	local leg_lon = 0
	local via_id = ""
	local leg_vpa = 0
	local leg_hld_trk = -1
	local leg_hld_out_trk = 0
	local leg_hld_lft = 0
	local leg_hld_len_nm = 0
	local leg_hld_len_min = 0
	local leg_hld_spd_kts = 0
	local lat_lon_disable = 0
	local last_leg_id = ""
	local next_waypoint = 0
	local ref_idx = 0
	
	local www = des_app
	
	msg_chk_alt_constr = 0
	
	file_name = "Output/FMS plans/B738X.fml"
	file_navdata = io.open(file_name, "r")
	if file_navdata ~= nil then
		fms_line = file_navdata:read()
		while fms_line do
			
			-- Reference ICAO
			if ref_icao_found == 0 then
				ii,jj = string.find(fms_line, 'class_id="37"')
				if ii ~= nill then
					ref_icao_active = 1
				end
			end
			if ref_icao_active == 1 then
				-- lat and lon
				ii,jj = string.find(fms_line, "<rad_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</rad_>")
					jj = ii - 1
					if kk > jj then
						leg_lat = 0
						leg_lon = 0
					else
						if ref_idx == 0 then
							leg_lat = string.sub(fms_line, kk, jj)
						elseif ref_idx == 1 then
							leg_lon = string.sub(fms_line, kk, jj)
						end
					end
					ref_idx = ref_idx + 1
				end
				
				ii,jj = string.find(fms_line, "<id_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</id_>")
					jj = ii - 1
					if kk > jj then
						ref_icao = "----"
					else
						ref_icao = string.sub(fms_line, kk, jj)
						legs_num = legs_num + 1
						legs_data[legs_num] = {}
						legs_data[legs_num][1] = ref_icao			-- id
						legs_data[legs_num][2] = leg_brg		-- brg
						legs_data[legs_num][3] = leg_dis		-- distance
						legs_data[legs_num][4] = leg_spd		-- speed
						legs_data[legs_num][5] = leg_alt		-- altitude
						legs_data[legs_num][6] = leg_alt_type	-- altitude type
						legs_data[legs_num][7] = leg_lat		-- latitude
						legs_data[legs_num][8] = leg_lon		-- longitude
						legs_data[legs_num][9] = via_id			-- via id
						legs_data[legs_num][10] = 0		-- calc speed
						legs_data[legs_num][11] = 0		-- calc altitude
						legs_data[legs_num][12] = 0		-- calc altitude vnav pth
						legs_data[legs_num][13] = 0
						legs_data[legs_num][14] = 0		-- rest alt
						legs_data[legs_num][15] = 0		-- last fuel
						legs_data[legs_num][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
						legs_data[legs_num][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
						legs_data[legs_num][20] = leg_vpa
						legs_data[legs_num][21] = leg_hld_trk
						legs_data[legs_num][22] = leg_hld_out_trk
						legs_data[legs_num][23] = leg_hld_lft
						legs_data[legs_num][24] = leg_hld_len_nm
						legs_data[legs_num][25] = leg_hld_len_min
						legs_data[legs_num][26] = leg_hld_spd_kts
						leg_lat = 0
						leg_lon = 0
					end
					ref_icao_found = 1
					ref_icao_active = 0
				end
			end
			
			-- Reference runway map
			if ref_rwy_map_found == 0 then
				ii,jj = string.find(fms_line, "<runway_map_")
				if ii ~= nill then
					ref_rwy_map_active = 1
				end
				ii,jj = string.find(fms_line, "</runway_map_>")
				if ii ~= nill then
					ref_rwy_map_found = 1
					ref_rwy_map_active = 0
				end
			end
			if ref_rwy_map_active == 1 then
				ii,jj = string.find(fms_line, "<id_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</id_>")
					jj = ii - 1
					if kk < jj then
						ref_rwy_map_num = ref_rwy_map_num + 1
						ref_rwy_map[ref_rwy_map_num] = string.sub(fms_line, kk, jj)
					end
				end
			end
			
			-- -- Destination ICAO
			-- if des_icao_found == 0 and ref_icao_found == 1 then
				-- ii,jj = string.find(fms_line, 'class_id_reference="1"')
				-- if ii ~= nill then
					-- des_icao_active = 1
				-- end
			-- end
			-- if des_icao_active == 1 then
				-- ii,jj = string.find(fms_line, "<id_>")
				-- if ii ~= nill then
					-- kk = jj + 1
					-- ii,jj = string.find(fms_line, "</id_>")
					-- jj = ii - 1
					-- if kk > jj then
						-- des_icao = "****"
					-- else
						-- des_icao = string.sub(fms_line, kk, jj)
					-- end
					-- -- des_icao_found = 1
					-- -- des_icao_active = 0
				-- end
				-- ii,jj = string.find(fms_line, "<runway_map_>")
				-- if ii ~= nill then
					-- des_icao_found = 1
					-- des_icao_active = 0
					-- -- save last legs - des ICAO
					-- legs_num = legs_num + 1
					-- legs_data[legs_num] = {}
					-- legs_data[legs_num][1] = leg_id			-- id
					-- legs_data[legs_num][2] = leg_brg		-- brg
					-- legs_data[legs_num][3] = leg_dis		-- distance
					-- legs_data[legs_num][4] = leg_spd		-- speed
					-- legs_data[legs_num][5] = leg_alt		-- altitude
					-- legs_data[legs_num][6] = leg_alt_type	-- altitude type
					-- legs_data[legs_num][7] = leg_lat		-- latitude
					-- legs_data[legs_num][8] = leg_lon		-- longitude
					-- legs_data[legs_num][9] = via_id			-- via id
					-- legs_data[legs_num][10] = 0
					-- legs_data[legs_num][11] = 0
					-- legs_data[legs_num][12] = 0
					-- legs_data[legs_num][13] = 0
					-- legs_data[legs_num][14] = 0
					-- legs_data[legs_num][20] = leg_vpa
					-- legs_data[legs_num][21] = leg_hld_trk
					-- legs_data[legs_num][22] = leg_hld_out_trk
					-- legs_data[legs_num][23] = leg_hld_lft
					-- legs_data[legs_num][24] = leg_hld_len_nm
					-- legs_data[legs_num][25] = leg_hld_len_min
					-- legs_data[legs_num][26] = leg_hld_spd_kts
					-- leg_id = ""
					-- leg_brg = 0
					-- leg_dis = 0
					-- leg_spd = 0
					-- leg_alt = 0
					-- leg_alt_type = 0
					-- leg_lat = 0
					-- leg_lon = 0
					-- leg_vpa = 0
					-- leg_hld_trk = -1
					-- leg_hld_out_trk = 0
					-- leg_hld_lft = 0
					-- leg_hld_len_nm = 0
					-- leg_hld_len_min = 0
					-- leg_hld_spd_kts = 0
					-- leg_entry = 0
					-- leg_enable = 0
					-- via_id = ""
					-- lat_lon_disable = 0
				-- end
			-- end
			
			-- Destination runway
			if ref_rwy_found == 1 and des_rwy_found == 0 then
				ii,jj = string.find(fms_line, "<active_runway_id>")
				if ii ~= nill then
					kk = jj + 3
					ii,jj = string.find(fms_line, "</active_runway_id>")
					jj = ii - 1
					if kk > jj then
						des_rwy = "----"
					else
						des_rwy = string.sub(fms_line, kk, jj)
						if string.len(des_rwy) == 2 then
							des_rwy = des_rwy .. " "
						end
					end
					des_rwy_found = 1
				end
			end
			
			-- Reference runway
			if ref_rwy_found == 0 then
				ii,jj = string.find(fms_line, "<active_runway_id>")
				if ii ~= nill then
					kk = jj + 3
					ii,jj = string.find(fms_line, "</active_runway_id>")
					jj = ii - 1
					if kk > jj then
						ref_rwy = "-----"
					else
						ref_rwy = string.sub(fms_line, kk, jj)
						if string.len(ref_rwy) == 2 then
							ref_rwy = ref_rwy .. " "
						end
					end
					ref_rwy_found = 1
				end
			end
			
			-- Transition altitude
			if trans_alt_found == 0 then
				ii,jj = string.find(fms_line, "<transition_alt_ft_>")
				if ii ~= nill then
					trans_alt_found = 1
				end
			end
			if trans_alt_found == 1 then
				ii,jj = string.find(fms_line, "<m_rep>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</m_rep>")
					jj = ii - 1
					if kk > jj then
						ref_trans_alt = 0
					else
						ref_trans_alt = tonumber(string.sub(fms_line, kk, jj))
					end
					trans_alt_found = 2
				end
			end
			
			-- SID
			ii,jj = string.find(fms_line, "<sid_id_>")
			if ii ~= nill then
				kk = jj + 1
				ii,jj = string.find(fms_line, "</sid_id_>")
				jj = ii - 1
				if kk > jj then
					ref_sid = "------"
				else
					ref_sid = string.sub(fms_line, kk, jj)
				end
			end
			
			-- STAR
			ii,jj = string.find(fms_line, "<star_id_>")
			if ii ~= nill then
				kk = jj + 1
				ii,jj = string.find(fms_line, "</star_id_>")
				jj = ii - 1
				if kk > jj then
					des_star = "------"
				else
					des_star = string.sub(fms_line, kk, jj)
				end
			end
			
			-- APP
			ii,jj = string.find(fms_line, "<approach_id_>")
			if ii ~= nill then
				kk = jj + 1
				ii,jj = string.find(fms_line, "</approach_id_>")
				jj = ii - 1
				if kk > jj then
					des_app = "------"
				else
					des_app = string.sub(fms_line, kk, jj)
				end
			end
			
			-- APP TRANSITION
			ii,jj = string.find(fms_line, "<approach_trans_id_>")
			if ii ~= nill then
				kk = jj + 1
				ii,jj = string.find(fms_line, "</approach_trans_id_>")
				jj = ii - 1
				if kk > jj then
					des_app_tns = "------"
				else
					des_app_tns = string.sub(fms_line, kk, jj)
				end
			end
			
			-- FPLN ROUTE
			ii,jj = string.find(fms_line, "<icao_list_")
			if ii ~= nil then
				fpln_active = 1
			end
			ii,jj = string.find(fms_line, "</icao_list_>")
			if ii ~= nil then
				fpln_active = 0
			end
			if fpln_active == 1 then
				ii,jj = string.find(fms_line, "<item>")
				if ii ~= nil then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</item>")
					jj = ii - 1
					fpln_num2 = fpln_num2 + 1
					fpln_data2[fpln_num2] = string.sub(fms_line, kk, jj)
				end
			end
			
			-- LEGS
			if des_icao_found == 0 then
			
			ii,jj = string.find(fms_line, "<trkToWpt>")
			if ii ~= nil then
				leg_enable = 1
				leg_entry = 4
			end
			if leg_enable == 1 then
				
				-- brg
				if leg_entry == 4 then
					ii,jj = string.find(fms_line, "<rad_>")
					if ii ~= nill then
						kk = jj + 1
						ii,jj = string.find(fms_line, "</rad_>")
						jj = ii - 1
						if kk < jj then
							leg_brg = tonumber(string.sub(fms_line, kk, jj))
						end
						leg_entry = 0
					end
				end
				
				-- distance, speed, altitude
				if leg_entry > 0 then
					ii,jj = string.find(fms_line, "<m_rep>")
					if ii ~= nil then
						kk = jj + 1
						ii,jj = string.find(fms_line, "</m_rep>")
						jj = ii - 1
						if kk < jj then
							if leg_entry == 1 then
								leg_dis = tonumber(string.sub(fms_line, kk, jj))
							elseif leg_entry == 2 then
								leg_spd = tonumber(string.sub(fms_line, kk, jj))
							elseif leg_entry == 3 then
								leg_alt = tonumber(string.sub(fms_line, kk, jj))
							end
						end
						leg_entry = 5	--0
					end
				end
				--lat, lon
				if leg_entry > 4 then
					ii,jj = string.find(fms_line, "<rad_>")
					if ii ~= nill then
						kk = jj + 1
						ii,jj = string.find(fms_line, "</rad_>")
						jj = ii - 1
						if kk < jj then
							if leg_entry == 5 then
								if lat_lon_disable == 0 then
									leg_lat = tonumber(string.sub(fms_line, kk, jj))
								end
							else
								if lat_lon_disable == 0 then
									leg_lon = tonumber(string.sub(fms_line, kk, jj))
									lat_lon_disable = 1
								end
							end
						end
						leg_entry = 0
					end
				end
				ii,jj = string.find(fms_line, "<distToWptNM>")
				if ii == nil then
					ii,jj = string.find(fms_line, "<speed_restriction_kts_>")
					if ii == nil then
						ii,jj = string.find(fms_line, "<altitude_restriction1_ft_>")
						if ii == nil then
							ii,jj = string.find(fms_line, "<lat_>")
							if ii == nil then
								ii,jj = string.find(fms_line, "<lon_>")
								if ii ~= nil then
									leg_entry = 6	-- longitude
								end
							else
								leg_entry = 5	-- latitude
							end
						else
							leg_entry = 3	-- alt restriction
						end
					else
						leg_entry = 2	-- speed restriction
					end
				else
					leg_entry = 1	-- distance
				end
				
				-- altitude type
				ii,jj = string.find(fms_line, "<altitude_restriction_type_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</altitude_restriction_type_>")
					jj = ii - 1
					if kk < jj then
						leg_alt_type = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				
				-- id
				ii,jj = string.find(fms_line, "<id_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</id_>")
					jj = ii - 1
					if kk < jj then
						if leg_id == "" then
							leg_id = string.sub(fms_line, kk, jj)
						end
					end
				end
				
				-- via id
				ii,jj = string.find(fms_line, "<via_id_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</via_id_>")
					jj = ii - 1
					if kk < jj then
						via_id = string.sub(fms_line, kk, jj)
					else
						via_id = ""
					end
					if leg_id == "" then
						leg_id = "-----"
					end
				end
				-- vpa
				ii,jj = string.find(fms_line, "<vpa_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</vpa_>")
					jj = ii - 1
					if kk < jj then
						leg_vpa = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- holding track
				ii,jj = string.find(fms_line, "<holding_track_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</holding_track_>")
					jj = ii - 1
					if kk < jj then
						leg_hld_trk = tonumber(string.sub(fms_line, kk, jj))
						--leg_id = last_leg_id
						if via_id == "" or leg_id == "-----" then
							leg_id = last_leg_id
						--else
							--leg_id = via_id
						end
						last_leg_id = ""
					end
				end
				-- holding out track
				ii,jj = string.find(fms_line, "<holding_out_track_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</holding_out_track_>")
					jj = ii - 1
					if kk < jj then
						leg_hld_out_trk = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- holding left or right
				ii,jj = string.find(fms_line, "<is_left_holding_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</is_left_holding_>")
					jj = ii - 1
					if kk <= jj then
						leg_hld_lft = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- holding lenght nm
				ii,jj = string.find(fms_line, "<hold_leg_length_nm_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</hold_leg_length_nm_>")
					jj = ii - 1
					if kk < jj then
						leg_hld_len_nm = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- holding lenght min
				ii,jj = string.find(fms_line, "<hold_leg_length_min_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</hold_leg_length_min_>")
					jj = ii - 1
					if kk < jj then
						leg_hld_len_min = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- holding speed limit kts
				ii,jj = string.find(fms_line, "<speed_limit_kts_>")
				if ii ~= nill then
					kk = jj + 1
					ii,jj = string.find(fms_line, "</speed_limit_kts_>")
					jj = ii - 1
					if kk < jj then
						leg_hld_spd_kts = tonumber(string.sub(fms_line, kk, jj))
					end
				end
				-- save waypoint data
				next_waypoint = 0
				ii,jj = string.find(fms_line, "</item>")
				if ii ~= nill then
					next_waypoint = 1
				end
				ii,jj = string.find(fms_line, "<item>")
				if ii ~= nill then
					next_waypoint = 1
				end
				
				if next_waypoint == 1 then
					legs_num = legs_num + 1
					legs_data[legs_num] = {}
					legs_data[legs_num][1] = leg_id			-- id
					legs_data[legs_num][2] = leg_brg		-- brg
					legs_data[legs_num][3] = leg_dis		-- distance
					legs_data[legs_num][4] = leg_spd		-- speed
					legs_data[legs_num][5] = leg_alt		-- altitude
					legs_data[legs_num][6] = leg_alt_type	-- altitude type
					legs_data[legs_num][7] = leg_lat		-- latitude
					legs_data[legs_num][8] = leg_lon		-- longitude
					legs_data[legs_num][9] = via_id			-- via id
					legs_data[legs_num][10] = 0		-- calc speed
					legs_data[legs_num][11] = 0		-- calc altitude
					legs_data[legs_num][12] = 0		-- calc altitude vnav pth
					legs_data[legs_num][13] = 0
					legs_data[legs_num][14] = 0		-- rest alt
					legs_data[legs_num][15] = 0		-- last fuel
					legs_data[legs_num][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
					legs_data[legs_num][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
					legs_data[legs_num][20] = leg_vpa
					legs_data[legs_num][21] = leg_hld_trk
					legs_data[legs_num][22] = leg_hld_out_trk
					legs_data[legs_num][23] = leg_hld_lft
					legs_data[legs_num][24] = leg_hld_len_nm
					legs_data[legs_num][25] = leg_hld_len_min
					legs_data[legs_num][26] = leg_hld_spd_kts
					last_leg_id = leg_id
					leg_id = ""
					leg_brg = 0
					leg_dis = 0
					leg_spd = 0
					leg_alt = 0
					leg_alt_type = 0
					leg_lat = 0
					leg_lon = 0
					via_id = ""
					leg_vpa = 0
					leg_hld_trk = -1
					leg_hld_out_trk = 0
					leg_hld_lft = 0
					leg_hld_len_nm = 0
					leg_hld_len_min = 0
					leg_hld_spd_kts = 0
					leg_entry = 0
					leg_enable = 0
					lat_lon_disable = 0
				end
			end
			
			end
			
			fms_line = file_navdata:read()
		end
		file_navdata:close()
		if trans_alt == "-----" and ref_trans_alt ~= 0 then
			trans_alt = string.format("%5d",ref_trans_alt)
			--trans_lvl = ""
		end
		B738_legs_num_first = legs_num
		if legs_num ~= 0 then
			------- dest ICAO
			if string.len(legs_data[legs_num][1]) == 4 then
				if legs_num == 1 then
					des_icao = "****"
					legs_num = 0
					offset = 0
				else
					des_icao = legs_data[legs_num][1]
					legs_num = legs_num - 1
				end
			else
				des_icao = "****"
				legs_num = 0
				offset = 0
			end
			if des_icao == "PPOS" then
				des_icao = "****"
				legs_num = 0
				offset = 0
			end
			-- find id E/D
			id_ed = ""
			if des_icao ~= "****" and des_app ~= "------" then
				read_des_data2()
				if ed_app_num > 0 then
					for ii = 1, ed_app_num do
						if des_app == ed_app[ii][1] then
							id_ed = ed_app[ii][2]
						end
					end
				end
			end
			offset = math.min(offset, legs_num)
			offset = math.max(offset, 1)
		else
			ref_icao = "----"
			des_icao = "****"
			ref_gate = "-----"
			co_route = "------------"
			ref_rwy = "-----"
			trans_alt = "-----"
			ref_sid = "------"
			ref_sid_tns = "------"
			des_app = "------"
			des_app_tns = "------"
			des_star = "------"
			des_star_trans = "------"
			entry = ""
			offset = 0
			legs_num = 0
		end
		
		B738_legs_num_before = legs_num
		--dump_leg()
		
		-- legs
		idx_ed = 0
		rnav_idx_first = 0
		rnav_idx_last = 0
		rnav_alt = 0
		rnav_vpa = 0
		if legs_num > 0 then
			for ii = 1, legs_num do
				if legs_data[ii][1] == id_ed and idx_ed == 0 then
					idx_ed = ii
					alt_ed = legs_data[ii][5]
					alt_type_ed = legs_data[ii][6]
					-- find first and last RNAV wpt
					rnav_idx_first = idx_ed + 1
					if rnav_idx_first > legs_num then
						rnav_idx_first = 0
					else
						rnav_alt = legs_data[rnav_idx_first][5]
						rnav_vpa = legs_data[rnav_idx_first][20]
						rnav_idx_last = rnav_idx_first
						--if rnav_vpa >= 0 then
							jj = rnav_idx_last + 1
							while jj < legs_num do
								if legs_data[jj][20] < 0 then	--vpa < 0
									rnav_idx_last = jj
									rnav_alt = legs_data[rnav_idx_last][5]
									rnav_vpa = legs_data[rnav_idx_last][20]
									break
								end
								jj = jj + 1
							end
						--end
					end
					jj = idx_ed
					if alt_type_ed ~= 43 then	-- not alt Above
						jj = jj - 1
						while jj > 1 do
							if legs_data[jj][5] == alt_ed and legs_data[jj][6] ~= 43 then	-- previous fix alt
								idx_ed = jj
								id_ed = legs_data[idx_ed][1]
								alt_ed = legs_data[idx_ed][5]
								alt_type_ed = legs_data[idx_ed][6]
							else
								break
							end
							jj = jj - 1
						end
					end
				end
				-- if ii > 1 and legs_data[ii][1] == des_icao then	-- find des ICAO
					-- legs_num = ii - 1
					-- break
				-- end
			end
		end
		
		if des_app_from_apt == 1 then
			des_app = www
		end
			
		B738_legs_num = legs_num
		
		airport_pos()
		
		--dump_leg()
		
		-- if idx_ed == 0 then
			-- if des_icao ~= "****" then
				-- read_des_data2()
				-- if data_des_app_tns_n > 0 then
					-- for ii = 1, data_des_app_tns_n do
						-- if des_app == data_des_app_tns[ii][1] then
							-- id_ed = data_des_app_tns[ii][3]
						-- end
					-- end
				-- end
			-- end
			-- if legs_num > 1 then
				-- for ii = 1, legs_num do
					-- if legs_data[ii][1] == id_ed then
						-- idx_ed = ii
						-- alt_ed = legs_data[ii][5]
						-- alt_type_ed = legs_data[ii][6]
					-- end
				-- end
			-- end
		-- end
	end
	
	--find_rnw_data()
	
	vnav_update = 1

end


function B738_find_rnav()
	
	local ii = 0
	
	--if legs_delete == 0 and calc_rte_enable == 0 then
	
		-- find id E/D
		id_ed = ""
		if des_icao ~= "****" and des_app ~= "------" then
			read_des_data2()
			if ed_app_num > 0 then
				for ii = 1, ed_app_num do
					if des_app == ed_app[ii][1] then
						id_ed = ed_app[ii][2]
					end
				end
			end
		end
		offset = math.min(offset, legs_num)
		offset = math.max(offset, 1)
			
		-- legs
		idx_ed = 0
		rnav_idx_first = 0
		rnav_idx_last = 0
		rnav_alt = 0
		rnav_vpa = 0
		if legs_num > 0 then
			for ii = 1, legs_num do
				if legs_data[ii][1] == id_ed and idx_ed == 0 then
					idx_ed = ii
					alt_ed = legs_data[ii][5]
					alt_type_ed = legs_data[ii][6]
					
					-- find first and last RNAV wpt
					rnav_idx_first = idx_ed + 1
					if rnav_idx_first > legs_num then
						rnav_idx_first = 0
					else
						rnav_alt = legs_data[rnav_idx_first][5]
						rnav_vpa = legs_data[rnav_idx_first][20]
						rnav_idx_last = rnav_idx_first
						jj = rnav_idx_last + 1
						while jj < legs_num do
							if legs_data[jj][20] < 0 then	--vpa < 0
								rnav_idx_last = jj
								rnav_alt = legs_data[rnav_idx_last][5]
								rnav_vpa = legs_data[rnav_idx_last][20]
								break
							end
							jj = jj + 1
						end
					end
					jj = idx_ed
					if alt_type_ed ~= 43 then	-- not alt Above
						jj = jj - 1
						while jj > 1 do
							if legs_data[jj][5] == alt_ed and legs_data[jj][6] ~= 43 then	-- previous fix alt
								idx_ed = jj
								id_ed = legs_data[idx_ed][1]
								alt_ed = legs_data[idx_ed][5]
								alt_type_ed = legs_data[idx_ed][6]
							else
								break
							end
							jj = jj - 1
						end
					end
				end
			end
		end
	
	--end
	
	vnav_update = 1

end
---------------------------------------------------------------

-- eee -> icao
function apt_exist(eee)
	
	local ii = 0
	local res = false
	
	icao_latitude = 0
	icao_longitude = 0
	
	if apt_data_num > 0 then
		for ii = 1, apt_data_num do
			if eee == apt_data[ii][1] then
				icao_latitude = apt_data[ii][2]
				icao_longitude = apt_data[ii][3]
				icao_tns_alt = apt_data[ii][4]
				icao_tns_lvl = apt_data[ii][5]
				res = true
				break
			end
		end
	end
	return res
	
end

-- eee -> icao, rrr -> runway
function rnw_exist(eee, rrr)
	
	local ii = 0
	local res = false
	
	if rnw_data_num > 0 then
		for ii = 1, rnw_data_num do
			if eee == rnw_data[ii][1] and rrr == rnw_data[ii][2] then
				res = true
				break
			end
		end
	end
	return res
	
end

---------------------------------------------------------------


-- 1LSK
function B738_fmc1_1L_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_1L:once()
			entry = ""
		else
		
		if page_dep == 1 then
			if ref_sid2 == "------" then
				if ref_sid_sel[1] ~= "------" then
					ref_sid2 = ref_sid_sel[1]
					ref_sid_tns2 = "------"
					if ref_rwy2 == "-----" then
						create_rnw_list()
					end
					create_tns_list()
					act_page = 1
					ref_sid_exec = 1
				end
			else
				ref_sid2 = "------"
				ref_sid_tns2 = "------"
				if ref_rwy2 == "-----" then
					create_rnw_list()
				end
				create_sid_list()
				act_page = 1
				ref_sid_exec = 1
			end
		elseif page_arr == 1 then
			if des_star2 == "------" then
				if des_star_sel[1] ~= "------" then
					des_star2 = des_star_sel[1]
					des_star_trans2 = "------"
					if des_app2 == "------" then
						create_des_app_list()
					end
					create_star_tns_list()
					act_page = 1
					des_star_exec = 1
				end
			else
				des_star2 = "------"
				des_star_trans2 = "------"
				if des_app2 == "------" then
					create_des_app_list()
				end
				create_star_list()
				act_page = 1
				des_star_exec = 1
			end
		elseif page_rte_init == 1 and in_flight_mode == 0 then	-- only on the groundthen
			if act_page == 1 then
				-- entry Ref airport ICAO
				local apt_ok = 0
				if entry == ">DELETE" then
					ref_icao = "----"
					des_icao = "****"
					des_icao_x = "****"
					ref_gate = "-----"
					co_route = "------------"
					trans_alt = "-----"
					ref_rwy = "-----"
					ref_sid = "------"
					ref_sid_tns = "------"
					des_app = "------"
					des_app_tns = "------"
					des_star = "------"
					des_star_trans = "------"
					----
					ref_rwy2 = "-----"
					ref_sid2 = "------"
					ref_sid_tns2 = "------"
					des_app2 = "------"
					des_app_tns2 = "------"
					des_star2 = "------"
					des_star_trans2 = "------"
					----
					crz_alt = "*****"
					crz_alt_num = 0
					crz_alt_num2 = 0
					entry = ""
					offset = 0
					legs_num = 0
				else
					if string.len(entry) == 4 then
						file_name = "Custom Data/CIFP/" .. entry
						file_name = file_name .. ".dat"
						file_navdata = io.open(file_name, "r")
						if file_navdata == nil then
							file_name = "Resources/default data/CIFP/" .. entry
							file_name = file_name .. ".dat"
							file_navdata = io.open(file_name, "r")
							if file_navdata == nil then
								if apt_exist(entry) == true then
									apt_ok = 1
								end
							else
								read_ref_data()		-- read reference airport data
								file_navdata:close()
								apt_ok = 1
							end
						else
							read_ref_data()		-- read reference airport data
							file_navdata:close()
							apt_ok = 1
						end
						
						if apt_ok == 0 then
							fmc_message_num = fmc_message_num + 1
							fmc_message[fmc_message_num] = NOT_IN_DATABASE
						else
							ref_icao = entry
							des_icao = "****"
							des_icao_x = "****"
							des_app_from_apt = 0
							ref_gate = "-----"
							co_route = "------------"
							trans_alt = "-----"
							ref_rwy = "-----"
							ref_sid = "------"
							ref_sid_tns = "------"
							des_app = "------"
							des_app_tns = "------"
							des_star = "------"
							des_star_trans = "------"
							----
							ref_rwy2 = "-----"
							ref_sid2 = "------"
							ref_sid_tns2 = "------"
							des_app2 = "------"
							des_app_tns2 = "------"
							des_star2 = "------"
							des_star_trans2 = "------"
							----
							legs_num = 0
							crz_alt = "*****"
							crz_alt_num = 0
							crz_alt_num2 = 0
							offset = 0
							if apt_exist(entry) == true then
								ref_icao_lat = icao_latitude
								ref_icao_lon = icao_longitude
								ref_tns_alt = icao_tns_alt
								ref_tns_lvl = icao_tns_lvl
							else
								ref_tns_alt = 0
								ref_tns_lvl = 0
							end
							if ref_tns_alt == 0 then
								trans_alt = "-----"
							else
								trans_alt = string.format("%5d", ref_tns_alt)
							end
							entry = ""
						end
					elseif entry == "" and ref_icao ~= "----" then
						entry = ref_icao
					else
						entry = INVALID_INPUT
					end
				end
				arr_data = 0
				airport_pos()
				create_rnw_list()
				create_sid_list()
			else
				local item = 0
				local button = 1	-- button 1 LSK
				local tmp_tmp = 0
				
				item = (act_page - 2) * 5 + button
				tmp_tmp = fpln_num2 + 1
				--if fpln_num2 > 1 then
				if item > 1 then
					if entry == ">DELETE" then
						del_via(item)
					else
						if item == tmp_tmp then
							if fpln_data2[fpln_num2][1] == "" and fpln_data2[fpln_num2][2] ~= "" then
								-- add new via via
								via_via_add()
							elseif fpln_data2[fpln_num2][1] ~= "" then
								-- add new via
								via_add(fpln_data2[fpln_num2][1], fpln_data2[fpln_num2][3])
							end
						elseif item <= fpln_num2 then --and fpln_num2 > 1 then
							-- change via
							via_chg(fpln_data2[item-1][1], fpln_data2[item-1][3], item)
						end
					end
				else
					entry = ">INVALID ENTRY"
				end
			end
		elseif page_dep_arr == 1 and in_flight_mode == 0 then	-- only on the ground
			-- SID departures
			local prev_repeat = 20
			if ref_icao ~= "----" and des_icao ~= "****" then
				page_dep = 1
				page_dep_arr = 0
				arr_data = 0
				---
				ref_rwy2 = ref_rwy
				ref_sid2 = ref_sid
				ref_sid_tns2 = ref_sid_tns
				---
				create_rnw_list()
				create_sid_list()
				create_tns_list()
			end
		elseif page_sel_wpt == 1 then
			
			local item = 0
			local button = 1	-- button 1 LSK
			
			item = (act_page - 1) * 5 + button
			if item <= navaid_list_n then
				-- select item
				rte_add_wpt2(item)
				legs_delete = 1
			end
		elseif page_sel_wpt2 == 1 then
			
			local item = 0
			local button = 1	-- button 1 LSK
			
			item = (act_page - 1) * 5 + button
			if item <= navaid_list_n then
				-- select item
				dir_add(item)
			end
		elseif page_legs == 1 then
			
			local item = 0
			local button = 1	-- button 1 LSK
			local tmp_tmp = 0
			
			item = (act_page - 1) * 5 + offset - 1 + button
			if item > legs_num2 then
				tmp_tmp = legs_num2 + 1
				if item == tmp_tmp and item_sel == 0 
				and string.len(entry) > 1 and string.len(entry) < 6 then
					-- add waypoint last
						rte_add_wpt(item)
						item_sel = 0
				else
					entry = INVALID_INPUT
				end
			else
				if entry == ">DELETE" then
					-- delete waypoint
					if act_page == 1 then
						entry = INVALID_INPUT
					else
						if item == legs_num2 then
							rte_copy(legs_num2 + 1)
							rte_paste(legs_num2)
							calc_rte_enable2 = 1
						else
							if legs_data2[item+1][1] == "DISCONTINUITY" then
								rte_copy(item + 1)
								rte_paste(item)
							else
								tmp_tmp = legs_num2
								rte_add_disco(item)
								legs_num2 = tmp_tmp
							end
							calc_rte_enable2 = 1
						end
						legs_delete = 1
						entry = ""
					end
					item_sel = 0
				elseif string.len(entry) > 1 and string.len(entry) < 6 and item_sel == 0 then
					-- add waypoint
						rte_add_wpt(item)
						item_sel = 0
				elseif item_sel == 0 then
					-- select item
					if legs_data2[item][1] == "DISCONTINUITY" then
						entry = INVALID_INPUT
						item_sel = 0
					else
						item_sel = item
						entry = legs_data2[item][1]
					end
				else
					-- entry item
					if item_sel > item then
						rte_copy(item_sel)
						rte_paste(item)
						calc_rte_enable2 = 1
						if act_page == 1 then
							legs_intdir = 1
						end
					elseif item_sel < item then
						item_sel = item_sel + 1
						item = item + 1
						rte_copy(item)
						rte_paste(item_sel)
						calc_rte_enable2 = 1
					else
						entry = INVALID_INPUT
					end
					entry = ""
					item_sel = 0
					legs_delete = 1
				end
			end
		elseif page_takeoff == 1 then
			-- entry flaps
			if entry == "1" then
				flaps = " 1"
				if v1_set == "---" and vr_set == "---" and v2_set == "---" then
					entry = ""
				else
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
					--entry = VERIFY_TO_SPEEDS
					fms_msg_sound = 1
				end
				v1_set = "---"
				vr_set = "---"
				v2_set = "---"
			elseif entry == "5" then
				flaps = " 5"
				if v1_set == "---" and vr_set == "---" and v2_set == "---" then
					entry = ""
				else
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
					--entry = VERIFY_TO_SPEEDS
					fms_msg_sound = 1
				end
				v1_set = "---"
				vr_set = "---"
				v2_set = "---"
			elseif entry == "10" then
				flaps = "10"
				if v1_set == "---" and vr_set == "---" and v2_set == "---" then
					entry = ""
				else
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
					--entry = VERIFY_TO_SPEEDS
					fms_msg_sound = 1
				end
				v1_set = "---"
				vr_set = "---"
				v2_set = "---"
			elseif entry == "15" then
				flaps = "15"
				if v1_set == "---" and vr_set == "---" and v2_set == "---" then
					entry = ""
				else
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
					--entry = VERIFY_TO_SPEEDS
					fms_msg_sound = 1
				end
				v1_set = "---"
				vr_set = "---"
				v2_set = "---"
			elseif entry == "25" then
				flaps = "25"
				if v1_set == "---" and vr_set == "---" and v2_set == "---" then
					entry = ""
				else
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
					--entry = VERIFY_TO_SPEEDS
					fms_msg_sound = 1
				end
				v1_set = "---"
				vr_set = "---"
				v2_set = "---"
			else
				if entry == ">DELETE" then
					flaps = "**"
					if v1_set == "---" and vr_set == "---" and v2_set == "---" then
						entry = ""
					else
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
						--entry = VERIFY_TO_SPEEDS
						fms_msg_sound = 1
					end
					v1_set = "---"
					vr_set = "---"
					v2_set = "---"
				else
					entry = INVALID_INPUT
				end
			end
			display_update = 1
		elseif page_init == 1 then
			-- go to Ident page
			page_ident = 1
			page_init = 0
			display_update = 1
		elseif page_menu == 1 then
			-- go to Ident page
			page_ident = 1
			page_menu = 0
		elseif page_pos_init == 2 then
			if fmc_pos == "-----.-------.-" then
				entry = ""
			else
				entry = fmc_pos
			end
		elseif page_perf == 1 or page_approach == 1 then
			-- entry GW
			local strlen = string.len(entry)
			local n = tonumber(entry)
			if strlen == 0 then
				gw = gw_calc
				zfw = zfw_calc
				if units == 0 then
					gw_lbs = gw
					gw_kgs = string.format("%5.1f", (tonumber(gw) / 2.204))
					zfw_lbs = zfw
					zfw_kgs = string.format("%5.1f", (tonumber(zfw) / 2.204))
				else
					gw_kgs = gw
					gw_lbs = string.format("%5.1f", (tonumber(gw) * 2.204))
					zfw_kgs = zfw
					zfw_lbs = string.format("%5.1f", (tonumber(zfw) * 2.204))
				end
			else
				if entry == ">DELETE" then
					gw = "***.*"
					gw_lbs = gw
					gw_kgs = gw
					zfw = "***.*"
					zfw_kgs = zfw
					zfw_lbs = zfw
					if v1_set == "---" and vr_set == "---" and v2_set == "---" then
						entry = ""
					else
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
						--entry = VERIFY_TO_SPEEDS
						fms_msg_sound = 1
					end
					v1_set = "---"
					vr_set = "---"
					v2_set = "---"
				else
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < weight_min or n > weight_max then	-- GW min and max
							entry = INVALID_INPUT
						else
							gw = string.format("%5.1f", n)
							if units == 0 then
								gw_lbs = gw
								gw_kgs = string.format("%5.1f", (tonumber(gw) / 2.204))		-- to kgs
								local weight_lbs = (simDR_fuel_weight / 1000) * 2.204		-- to lbs
								local xxx = tonumber(gw_lbs)
								xxx = xxx - weight_lbs
								zfw = string.format("%5.1f", (tonumber(xxx)))
								zfw_lbs = zfw
								zfw_kgs = string.format("%5.1f", (tonumber(zfw) / 2.204))	-- to kgs
							else
								gw_kgs = gw
								gw_lbs = string.format("%5.1f", (tonumber(gw) * 2.204))		-- to lbs
								local weight_lbs = (simDR_fuel_weight / 1000) * 2.204		-- to lbs
								local xxx = tonumber(gw_lbs)
								xxx = xxx - weight_lbs
								zfw_lbs = string.format("%5.1f", (tonumber(xxx)))
								zfw_kgs = string.format("%5.1f", (tonumber(zfw_lbs) / 2.204))	-- to kgs
								zfw = zfw_kgs
							end
							if v1_set == "---" and vr_set == "---" and v2_set == "---" then
								entry = ""
							else
								fmc_message_num = fmc_message_num + 1
								fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
								--entry = VERIFY_TO_SPEEDS
								fms_msg_sound = 1
							end
							v1_set = "---"
							vr_set = "---"
							v2_set = "---"
						end
					end
				end
			end
			B738_calc_vnav_spd()
		elseif page_descent_forecast == 1 then
			-- entry Trans level
			local strlen = string.len(entry)
			local n = tonumber(entry)
			local nn = 0
			local n_str = ""
			if strlen > 0 then
				if entry == ">DELETE" then
					trans_lvl = "-----"
					entry = ""
				else
					if strlen == 3 then
						if n == nil then
							entry = INVALID_INPUT
						else
							if n < 30 or n > 410 then
								entry = INVALID_INPUT
							else
								trans_lvl = "FL" .. string.format("%03d", n)
								entry = ""
								nn = n * 100
								if forec_alt_1 ~= "-----" then
									n_str = string.sub(forec_alt_1, 1, 2)
									if forec_alt_1_num > nn then
										if n_str ~= "FL" then
											n = tonumber(forec_alt_1) / 100
											forec_alt_1 = "FL" .. string.format("%03d", n)
										end
									else
										if n_str == "FL" then
											n_str = string.sub(forec_alt_1, 3, 5)
											n = tonumber(n_str) * 100
											forec_alt_1 = string.format("%5d", n)
										end
									end
								end
								if forec_alt_2 ~= "-----" then
									n_str = string.sub(forec_alt_2, 1, 2)
									if forec_alt_2_num > nn then
										if n_str ~= "FL" then
											n = tonumber(forec_alt_2) / 100
											forec_alt_2 = "FL" .. string.format("%03d", n)
										end
									else
										if n_str == "FL" then
											n_str = string.sub(forec_alt_2, 3, 5)
											n = tonumber(n_str) * 100
											forec_alt_2 = string.format("%5d", n)
										end
									end
								end
								if forec_alt_3 ~= "-----" then
									n_str = string.sub(forec_alt_3, 1, 2)
									if forec_alt_3_num > nn then
										if n_str ~= "FL" then
											n = tonumber(forec_alt_3) / 100
											forec_alt_3 = "FL" .. string.format("%03d", n)
										end
									else
										if n_str == "FL" then
											n_str = string.sub(forec_alt_3, 3, 5)
											n = tonumber(n_str) * 100
											forec_alt_3 = string.format("%5d", n)
										end
									end
								end
							end
						end
					elseif strlen == 5 then
						if string.sub(entry, 1, 2) == "FL" then
							n = tonumber(string.sub(entry, 3, 5))
							if n == nil then
								entry = INVALID_INPUT
							else
								if n < 30 or n > 410 then
									entry = INVALID_INPUT
								else
									trans_lvl = "FL" .. string.format("%03d", n)
									entry = ""
									nn = n * 100
									if forec_alt_1 ~= "-----" then
										n_str = string.sub(forec_alt_1, 1, 2)
										if forec_alt_1_num > nn then
											if n_str ~= "FL" then
												n = tonumber(forec_alt_1) / 100
												forec_alt_1 = "FL" .. string.format("%03d", n)
											end
										else
											if n_str == "FL" then
												n_str = string.sub(forec_alt_1, 3, 5)
												n = tonumber(n_str) * 100
												forec_alt_1 = string.format("%5d", n)
											end
										end
									end
									if forec_alt_2 ~= "-----" then
										n_str = string.sub(forec_alt_2, 1, 2)
										if forec_alt_2_num > nn then
											if n_str ~= "FL" then
												n = tonumber(forec_alt_2) / 100
												forec_alt_2 = "FL" .. string.format("%03d", n)
											end
										else
											if n_str == "FL" then
												n_str = string.sub(forec_alt_2, 3, 5)
												n = tonumber(n_str) * 100
												forec_alt_2 = string.format("%5d", n)
											end
										end
									end
									if forec_alt_3 ~= "-----" then
										n_str = string.sub(forec_alt_3, 1, 2)
										if forec_alt_3_num > nn then
											if n_str ~= "FL" then
												n = tonumber(forec_alt_3) / 100
												forec_alt_3 = "FL" .. string.format("%03d", n)
											end
										else
											if n_str == "FL" then
												n_str = string.sub(forec_alt_3, 3, 5)
												n = tonumber(n_str) * 100
												forec_alt_3 = string.format("%5d", n)
											end
										end
									end
								end
							end
						else
							entry = INVALID_INPUT
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_takeoff == 2 then
			-- entry RW WIND
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					rw_wind_dir = "---"
					rw_wind_spd = "---"
					if v1_set == "---" and vr_set == "---" and v2_set == "---" then
						entry = ""
					else
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
						--entry = VERIFY_TO_SPEEDS
						fms_msg_sound = 1
					end
					v1_set = "---"
					vr_set = "---"
					v2_set = "---"
				else
					if strlen > 4 and strlen < 8 and string.sub(entry, 4, 4) == "/" then
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n < 0 or n > 359 then		-- wind heading 0 - 359
								entry = INVALID_INPUT
							else
								local wind_dir = string.format("%03d", n)
								n = tonumber(string.sub(entry, 5, strlen))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < 1 or n > 199 then	-- wind speed 1 - 199
										entry = INVALID_INPUT
									else
										rw_wind_dir = wind_dir
										rw_wind_spd = string.format("%03d", n)
										if v1_set == "---" and vr_set == "---" and v2_set == "---" then
											entry = ""
										else
											fmc_message_num = fmc_message_num + 1
											fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
											--entry = VERIFY_TO_SPEEDS
											fms_msg_sound = 1
										end
										v1_set = "---"
										vr_set = "---"
										v2_set = "---"
									end
								end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_perf == 2 then
			-- Time Error
			local strlen = string.len(entry)
			local n = tonumber(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					time_err = "  "
					entry = ""
				else
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 5 or n > 30 then	-- Time error min and max
							entry = INVALID_INPUT
						else
							time_err = string.format("%2d", n)
							entry = ""
						end
					end
				end
			end
		elseif page_climb == 1 and B738DR_flight_phase < 2 then
			-- Change cruise alt
			local strlen = string.len(entry)
			if strlen > 0 then
				if strlen == 5 and string.sub(entry, 1, 2) == "FL" then
					local n = tonumber(string.sub(entry, 3, 5))
					if n == nil then
						entry = INVALID_INPUT
					else
						local nn = crz_alt_num / 100
						if n < nn or n > 410 then	-- Cruise level FLxxx min and max
							entry = INVALID_INPUT
						else
							crz_alt_num = n * 100
							if crz_alt_num >= B738DR_trans_alt then
								--n = n / 100
								crz_alt = "FL" .. string.format("%03d", n)
							else
								n = n * 100
								crz_alt = string.format("%5d", n)
							end
							B738DR_fmc_cruise_alt = crz_alt_num
							-- write to fmc
							-- simCMD_FMS_key_crz:once()
							-- simCMD_FMS_key_delete:once()
							-- simCMD_FMS_key_clear:once()
							-- simCMD_FMS_key_clear:once()
							-- type_to_fmc(crz_alt)
							-- simCMD_FMS_key_1R:once()
							entry = ""
							msg_unavaible_crz_alt = 0
						end
					end
				else
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if strlen == 3 then
							local nn = crz_alt_num / 100
							if n < nn or n > 410 then	-- Cruise level FLxxx min and max
								entry = INVALID_INPUT
							else
								crz_alt_num = n * 100
								if crz_alt_num >= B738DR_trans_alt then
									--n = n / 100
									crz_alt = "FL" .. string.format("%03d", n)
								else
									n = n * 100
									crz_alt = string.format("%5d", n)
								end
								B738DR_fmc_cruise_alt = crz_alt_num
								-- write to fmc
								-- simCMD_FMS_key_crz:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- type_to_fmc(crz_alt)
								-- simCMD_FMS_key_1R:once()
								entry = ""
								msg_unavaible_crz_alt = 0
							end
						else
							if n < crz_alt_num or n > 41000 then	-- Cruise alt min and max
								entry = INVALID_INPUT
							else
								crz_alt_num = n
								if crz_alt_num >= B738DR_trans_alt then
									n = n / 100
									crz_alt = "FL" .. string.format("%03d", n)
								else
									crz_alt = string.format("%5d", n)
								end
								B738DR_fmc_cruise_alt = crz_alt_num
								-- write to fmc
								-- simCMD_FMS_key_crz:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- type_to_fmc(crz_alt)
								-- simCMD_FMS_key_1R:once()
								entry = ""
								msg_unavaible_crz_alt = 0
							end
						end
					end
				end
			end
		elseif page_cruise == 1 then
			-- Change cruise alt
			local strlen = string.len(entry)
			if strlen > 0 then
				-- if entry == ">DELETE" and crz_exec == 0 then
					-- crz_alt = "*****"
					-- crz_alt_num = 0
					-- entry = ""
				if strlen == 5 and string.sub(entry, 1, 2) == "FL" then
					local n = tonumber(string.sub(entry, 3, 5))
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 10 or n > 410 then	-- Cruise level FLxxx min and max
							entry = INVALID_INPUT
						else
							if B738DR_autopilot_vnav_status == 1 then
								if B738DR_flight_phase == 2 or B738DR_flight_phase == 3 or B738DR_flight_phase == 4 then
									crz_alt_num2 = n * 100
									if crz_alt_num ~= crz_alt_num2 then
										-- crz_alt_old = crz_alt
										crz_alt_old = "FL" .. string.format("%03d", (crz_alt_num/100))
										crz_alt = "FL" .. string.format("%03d", n)
										if B738DR_flight_phase == 2 then
											if crz_alt_num2 > crz_alt_num then
												crz_exec = 1	-- CRZ CLB
											else
												crz_exec = 2	-- CRZ DES
											end
										else
											if crz_alt_num2 > simDR_altitude_pilot then
												crz_exec = 1	-- CRZ CLB
											else
												crz_exec = 2	-- CRZ DES
											end
										end
										exec1_light = 1
									end
								else
									crz_alt_num = n * 100
									if crz_alt_num >= B738DR_trans_alt then
										--n = n / 100
										crz_alt = "FL" .. string.format("%03d", n)
									else
										n = n * 100
										crz_alt = string.format("%5d", n)
									end
									B738DR_fmc_cruise_alt = crz_alt_num
									-- write to fmc
									-- simCMD_FMS_key_crz:once()
									-- simCMD_FMS_key_delete:once()
									-- simCMD_FMS_key_clear:once()
									-- simCMD_FMS_key_clear:once()
									-- type_to_fmc(crz_alt)
									-- simCMD_FMS_key_1R:once()
									crz_alt_num2 = 0
									crz_alt_old = "     "
								end
							else
								crz_alt_num = n * 100
								if crz_alt_num >= B738DR_trans_alt then
									--n = n / 100
									crz_alt = "FL" .. string.format("%03d", n)
								else
									n = n * 100
									crz_alt = string.format("%5d", n)
								end
								B738DR_fmc_cruise_alt = crz_alt_num
								-- write to fmc
								-- simCMD_FMS_key_crz:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- type_to_fmc(crz_alt)
								-- simCMD_FMS_key_1R:once()
								crz_alt_num2 = 0
								crz_alt_old = "     "
							end
							entry = ""
						end
					end
				else
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if strlen == 3 then
							if n < 10 or n > 410 then	-- Cruise level FLxxx min and max
								entry = INVALID_INPUT
							else
								if B738DR_flight_phase == 2 or B738DR_flight_phase == 3 or B738DR_flight_phase == 4 then
									crz_alt_num2 = n * 100
									if crz_alt_num ~= crz_alt_num2 then
										-- crz_alt_old = crz_alt
										crz_alt_old = "FL" .. string.format("%03d", (crz_alt_num/100))
										crz_alt = "FL" .. string.format("%03d", n)
										if B738DR_flight_phase == 2 then
											if crz_alt_num2 > crz_alt_num then
												crz_exec = 1	-- CRZ CLB
											else
												crz_exec = 2	-- CRZ DES
											end
										else
											if crz_alt_num2 > simDR_altitude_pilot then
												crz_exec = 1	-- CRZ CLB
											else
												crz_exec = 2	-- CRZ DES
											end
										end
										exec1_light = 1
									end
								else
									crz_alt_num = n * 100
									if crz_alt_num >= B738DR_trans_alt then
										--n = n / 100
										crz_alt = "FL" .. string.format("%03d", n)
									else
										n = n * 100
										crz_alt = string.format("%5d", n)
									end
									B738DR_fmc_cruise_alt = crz_alt_num
									-- write to fmc
									-- simCMD_FMS_key_crz:once()
									-- simCMD_FMS_key_delete:once()
									-- simCMD_FMS_key_clear:once()
									-- simCMD_FMS_key_clear:once()
									-- type_to_fmc(crz_alt)
									-- simCMD_FMS_key_1R:once()
									crz_alt_num2 = 0
									crz_alt_old = "     "
								end
								entry = ""
							end
						else
							if n < 1000 or n > 41000 then	-- Cruise alt min and max
								entry = INVALID_INPUT
							else
								if B738DR_flight_phase == 2 or B738DR_flight_phase == 3 or B738DR_flight_phase == 4  then
									crz_alt_num2 = n
									if crz_alt_num ~= crz_alt_num2 then
											--crz_alt_old = crz_alt
											crz_alt_old = "FL" .. string.format("%03d", (crz_alt_num/100))
											crz_alt = string.format("%5d", n)
										if B738DR_flight_phase == 2 then
											if crz_alt_num2 > crz_alt_num then
												crz_exec = 1	-- CRZ CLB
											else
												crz_exec = 2	-- CRZ DES
											end
										else
											if crz_alt_num2 > simDR_altitude_pilot then
												crz_exec = 1	-- CRZ CLB
											else
												crz_exec = 2	-- CRZ DES
											end
										end
										exec1_light = 1
									end
								else
									crz_alt_num = n
									if crz_alt_num >= B738DR_trans_alt then
										n = n / 100
										crz_alt = "FL" .. string.format("%03d", n)
									else
										crz_alt = string.format("%5d", n)
									end
									B738DR_fmc_cruise_alt = crz_alt_num
									-- write to fmc
									-- simCMD_FMS_key_crz:once()
									-- simCMD_FMS_key_delete:once()
									-- simCMD_FMS_key_clear:once()
									-- simCMD_FMS_key_clear:once()
									-- type_to_fmc(crz_alt)
									-- simCMD_FMS_key_1R:once()
									crz_alt_num2 = 0
									crz_alt_old = "     "
								end
								entry = ""
							end
						end
					end
				end
			end
		elseif page_n1_limit == 1 then
			if in_flight_mode == 0 then
				-- entry SEL TEMP and OAT
				local strlen = string.len(entry)
				local n = 0
				if strlen > 0 then
					if entry == ">DELETE" then
						sel_temp = "----"
						oat = "    "
						sel_temp_f = "----"
						oat_f = "    "
						oat_unit = "`C"
						if v1_set == "---" and vr_set == "---" and v2_set == "---" then
							entry = ""
						else
							fmc_message_num = fmc_message_num + 1
							fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
							--entry = VERIFY_TO_SPEEDS
							fms_msg_sound = 1
						end
						v1_set = "---"
						vr_set = "---"
						v2_set = "---"
					else
						if strlen > 0 and strlen < 6 then
							local oat_set = 0
							if string.sub(entry, 1, 1) == "/" and strlen > 1 then
								oat_set = 1		-- entry OAT
								entry = string.sub(entry, 2, strlen)
								strlen = strlen -1
							end
							
							local n_str = string.sub(entry, strlen, strlen)
							if n_str == "C" then 
								n = tonumber(string.sub(entry, 1, strlen-1))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < -20 or n > 70 then	-- Celsius min and max
										entry = INVALID_INPUT
									else
										oat_unit = "`C"
										if oat_set == 0 then
											if n < 0 then
												sel_temp = string.format("%4d", n)
											else
												if n < 10 then
													sel_temp = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													sel_temp = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
											n = (n * 9 / 5) + 32
											sel_temp_f = string.format("%4d", n)
										else
											if n < 0 then
												oat = string.format("%4d", n)
											else
												if n < 10 then
													oat = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													oat = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
											n = (n * 9 / 5) + 32
											oat_f = string.format("%4d", n)
										end
										if v1_set == "---" and vr_set == "---" and v2_set == "---" then
											entry = ""
										else
											fmc_message_num = fmc_message_num + 1
											fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
											--entry = VERIFY_TO_SPEEDS
											fms_msg_sound = 1
										end
										v1_set = "---"
										vr_set = "---"
										v2_set = "---"
									end
								end
							elseif n_str == "F" then
								n = tonumber(string.sub(entry, 1, strlen-1))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < -4 or n > 158 then	-- Fahrenheit min and max
										entry = INVALID_INPUT
									else
										oat_unit = "`F"
										if oat_set == 0 then
											sel_temp_f = string.format("%4d", n)
											n = (n - 32) * 5 / 9
											if n < 0 then
												sel_temp = string.format("%4d", n)
											else
												if n < 10 then
													sel_temp = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													sel_temp = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
										else
											oat_f = string.format("%4d", n)
											n = (n - 32) * 5 / 9
											if n < 0 then
												oat = string.format("%4d", n)
											else
												if n < 10 then
													oat = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													oat = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
										end
										if v1_set == "---" and vr_set == "---" and v2_set == "---" then
											entry = ""
										else
											fmc_message_num = fmc_message_num + 1
											fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
											--entry = VERIFY_TO_SPEEDS
											fms_msg_sound = 1
										end
										v1_set = "---"
										vr_set = "---"
										v2_set = "---"
									end
								end
							else
								n = tonumber(string.sub(entry, 1, strlen))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < -20 or n > 70 then	-- Celsius min and max
										entry = INVALID_INPUT
									else
										oat_unit = "`C"
										if oat_set == 0 then
											if n < 0 then
												sel_temp = string.format("%4d", n)
											else
												if n < 10 then
													sel_temp = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													sel_temp = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
											n = (n * 9 / 5) + 32
											sel_temp_f = string.format("%4d", n)
										else
											if n < 0 then
												oat = string.format("%4d", n)
											else
												if n < 10 then
													oat = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													oat = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
											n = (n * 9 / 5) + 32
											oat_f = string.format("%4d", n)
										end
										if v1_set == "---" and vr_set == "---" and v2_set == "---" then
											entry = ""
										else
											fmc_message_num = fmc_message_num + 1
											fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
											--entry = VERIFY_TO_SPEEDS
											fms_msg_sound = 1
										end
										v1_set = "---"
										vr_set = "---"
										v2_set = "---"
									end
								end
							end
							
							
						else
							entry = INVALID_INPUT
						end
					end
				end
			else
				-- select AUTO
				auto_act = "<ACT>"
				ga_act = "     "
				con_act = "     "
				clb_act = "     "
				crz_act = "     "
			end
		elseif page_xtras == 1 then
			-- FMOD SOUNDS menu
			page_xtras = 0
			page_xtras_fmod = 1
		elseif page_xtras_fmod == 1 then
			-- FMOD Pax Boarding
			B738CMD_enable_pax_boarding:once()
		elseif page_xtras_fmod == 2 then
			-- FMOD Internal all sounds
			B738CMD_vol_int_ducker:once()
		elseif page_xtras_fmod == 3 then
			-- FMOD Internal roll volume
			B738CMD_vol_int_roll:once()
		elseif page_xtras_fmod == 4 then
			-- FMOD Mute trim wheel
			B738CMD_enable_mutetrim:once()
		elseif page_xtras_others == 1 then
			-- OTHERS - Align time
			if B738DR_align_time == 0 then
				B738DR_align_time = 1
			elseif B738DR_align_time == 1 then
				B738DR_align_time = 2
			else
				B738DR_align_time = 0
			end
		elseif page_xtras_others == 2 then
			if B738DR_engine_no_running_state == 0 then
				B738DR_engine_no_running_state = 1
			else
				B738DR_engine_no_running_state = 0
			end
		elseif page_xtras_others == 3 then
			if B738DR_fpln_format == 0 then
				B738DR_fpln_format = 1
			else
				B738DR_fpln_format = 0
			end
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 2LSK
function B738_fmc1_2L_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_2L:once()
			entry = ""
		else
		if page_dep == 1 then
			if ref_sid2 == "------" then
				if ref_sid_sel[2] ~= "------" then
					ref_sid2 = ref_sid_sel[2]
					ref_sid_tns2 = "------"
					if ref_rwy2 == "-----" then
						create_rnw_list()
					end
					create_tns_list()
					act_page = 1
					ref_sid_exec = 1
				end
			else
				if ref_sid_tns2 == "------" then
					if ref_tns_sel[2] ~= "------" then
						ref_sid_tns2 = ref_tns_sel[2]
						act_page = 1
						ref_tns_exec = 1
					end
				else
					ref_sid_tns2 = "------"
					act_page = 1
					ref_tns_exec = 1
				end
			end
		elseif page_arr == 1 then
			if des_star2 == "------" then
				if des_star_sel[2] ~= "------" then
					des_star2 = des_star_sel[2]
					des_star_trans2 = "------"
					if des_app2 == "------" then
						create_des_app_list()
					end
					create_star_tns_list()
					act_page = 1
					des_star_exec = 1
				end
			else
				if des_star_trans2 == "------" then
					if des_star_tns_sel[2] ~= "------" then
						des_star_trans2 = des_star_tns_sel[2]
						des_star_tns_exec = 1
						act_page = 1
					end
				else
					des_star_trans2 = "------"
					act_page = 1
					des_star_tns_exec = 1
				end
			end
		elseif page_sel_wpt == 1 then
			
			local item = 0
			local button = 2	-- button 2 LSK
			
			item = (act_page - 1) * 5 + button
			if item <= navaid_list_n then
				-- select item
				rte_add_wpt2(item)
				legs_delete = 1
			end
		elseif page_sel_wpt2 == 1 then
			
			local item = 0
			local button = 2	-- button 2 LSK
			
			item = (act_page - 1) * 5 + button
			if item <= navaid_list_n then
				-- select item
				dir_add(item)
			end
		elseif page_xtras == 1 then
			-- OTHERS menu
			page_xtras = 0
			page_xtras_others = 1
		elseif page_xtras_fmod == 1 then
			-- FMOD Chatter
			B738CMD_enable_chatter:once()
		elseif page_xtras_fmod == 2 then
			-- FMOD Internal engine sounds
			B738CMD_vol_int_eng:once()
		elseif page_xtras_fmod == 3 then
			-- FMOD Internal bump volume
			B738CMD_vol_int_bump:once()
		elseif page_xtras_fmod == 4 then
			-- FMOD Airport volume
			B738CMD_vol_airport:once()
		elseif page_xtras_others == 1 then
			if simDR_hide_yoke == 0 then
				simDR_hide_yoke = 1
			else
				simDR_hide_yoke = 0
			end
		elseif page_xtras_others == 2 then
			if B738DR_parkbrake_remove_chock == 0 then
				B738DR_parkbrake_remove_chock = 1
			else
				B738DR_parkbrake_remove_chock = 0
			end
		elseif page_legs == 1 then
			
			local item = 0
			local button = 2	-- button 2 LSK
			local tmp_tmp = 0
			
			item = (act_page - 1) * 5 + offset - 1 + button
			if item > legs_num2 then
				tmp_tmp = legs_num2 + 1
				if item == tmp_tmp and item_sel == 0 then
					-- add waypoint last
					rte_add_wpt(item)
					item_sel = 0
				else
					entry = INVALID_INPUT
				end
			else
				if entry == ">DELETE" then
					-- delete waypoint
					if item == legs_num2 then
						rte_copy(legs_num2 + 1)
						rte_paste(legs_num2)
						calc_rte_enable2 = 1
					else
						if legs_data2[item+1][1] == "DISCONTINUITY" then
							rte_copy(item + 1)
							rte_paste(item)
						else
							tmp_tmp = legs_num2
							rte_add_disco(item)
							legs_num2 = tmp_tmp
						end
						calc_rte_enable2 = 1
					end
					legs_delete = 1
					entry = ""
				elseif string.len(entry) > 1 and string.len(entry) < 6 and item_sel == 0 then
					-- add waypoint
						rte_add_wpt(item)
						item_sel = 0
				elseif item_sel == 0 then
					-- select item
					if legs_data2[item][1] == "DISCONTINUITY" then
						entry = INVALID_INPUT
						item_sel = 0
					else
						item_sel = item
						entry = legs_data2[item][1]
					end
				else
					-- entry item
					if item_sel > item then
						rte_copy(item_sel)
						rte_paste(item)
						calc_rte_enable2 = 1
					elseif item_sel < item then
						item_sel = item_sel + 1
						item = item + 1
						rte_copy(item)
						rte_paste(item_sel)
						calc_rte_enable2 = 1
					else
						entry = INVALID_INPUT
					end
					entry = ""
					item_sel = 0
					legs_delete = 1
				end
			end
		elseif page_pos_init == 1 and in_flight_mode == 0 then	-- only on the ground
			-- entry Ref airport ICAO
			local apt_ok = 0
			if entry == ">DELETE" then
				ref_icao = "----"
				des_icao = "****"
				ref_gate = "-----"
				co_route = "------------"
				trans_alt = "-----"
				ref_rwy = "-----"
				ref_sid = "------"
				ref_sid_tns = "------"
				des_app = "------"
				des_app_tns = "------"
				des_star = "------"
				des_star_trans = "------"
				----
				ref_rwy2 = "-----"
				ref_sid2 = "------"
				ref_sid_tns2 = "------"
				des_app2 = "------"
				des_app_tns2 = "------"
				des_star2 = "------"
				des_star_trans2 = "------"
				----
				crz_alt = "*****"
				crz_alt_num = 0
				crz_alt_num2 = 0
				entry = ""
				offset = 0
				legs_num = 0
			else
				if string.len(entry) == 4 then
					file_name = "Custom Data/CIFP/" .. entry
					file_name = file_name .. ".dat"
					file_navdata = io.open(file_name, "r")
					if file_navdata == nil then
						file_name = "Resources/default data/CIFP/" .. entry
						file_name = file_name .. ".dat"
						file_navdata = io.open(file_name, "r")
						if file_navdata == nil then
							if apt_exist(entry) == true then
								apt_ok = 1
							end
						else
							read_ref_data()		-- read reference airport data
							file_navdata:close()
							apt_ok = 1
						end
					else
						read_ref_data()		-- read reference airport data
						file_navdata:close()
						apt_ok = 1
					end
					
					if apt_ok == 0 then
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = NOT_IN_DATABASE
					else
						ref_icao = entry
						des_icao = "****"
						des_app_from_apt = 0
						ref_gate = "-----"
						co_route = "------------"
						trans_alt = "-----"
						ref_rwy = "-----"
						ref_sid = "------"
						ref_sid_tns = "------"
						des_app = "------"
						des_app_tns = "------"
						des_star = "------"
						des_star_trans = "------"
						----
						ref_rwy2 = "-----"
						ref_sid2 = "------"
						ref_sid_tns2 = "------"
						des_app2 = "------"
						des_app_tns2 = "------"
						des_star2 = "------"
						des_star_trans2 = "------"
						----
						legs_num = 0
						crz_alt = "*****"
						crz_alt_num = 0
						crz_alt_num2 = 0
						offset = 0
						if apt_exist(entry) == true then
							ref_icao_lat = icao_latitude
							ref_icao_lon = icao_longitude
							ref_tns_alt = icao_tns_alt
							ref_tns_lvl = icao_tns_lvl
						else
							ref_tns_alt = 0
							ref_tns_lvl = 0
						end
						if ref_tns_alt == 0 then
							trans_alt = "-----"
						else
							trans_alt = string.format("%5d", ref_tns_alt)
						end
						entry = ""
					end
				elseif entry == "" and ref_icao ~= "----" then
					entry = ref_icao
				else
					entry = INVALID_INPUT
				end
			end
			arr_data = 0
			airport_pos()
			create_rnw_list()
			create_sid_list()
		elseif page_rte_init == 1 then
			if act_page == 1 then
				-- entry CO ROUTE
				local ii = 0
				if entry == ">DELETE" then
					co_route = "------------"
					entry = ""
				else
					ii = string.len(entry)
					if ii > 0 and ii < 13 then
						load_fpln()
					else
						entry = INVALID_INPUT
					end
				end
			else
				local item = 0
				local button = 2	-- button 2 LSK
				local tmp_tmp = 0
				
				item = (act_page - 2) * 5 + button
				tmp_tmp = fpln_num2 + 1
				if fpln_num2 > 0 then
					if entry == ">DELETE" then
						del_via(item)
					else
						if item == tmp_tmp then
							if fpln_data2[fpln_num2][1] == "" and fpln_data2[fpln_num2][2] ~= "" then
								-- add new via via
								via_via_add()
							elseif fpln_data2[fpln_num2][1] ~= "" then
								-- add new via
								via_add(fpln_data2[fpln_num2][1], fpln_data2[fpln_num2][3])
							end
						elseif item <= fpln_num2 and fpln_num2 > 1 then
							-- change via
							via_chg(fpln_data2[item-1][1], fpln_data2[item-1][3], item)
						end
					end
				else
					entry = ">INVALID ENTRY"
				end
			end
		elseif page_init == 1 then
			-- go to Pos init page
			page_init = 0
			page_pos_init = 1
			display_update = 1
		elseif page_pos_init == 2 then
			if B738DR_irs_pos == "-----.-------.-" then
				entry = ""
			else
				entry = B738DR_irs_pos
			end
		elseif page_perf == 1 then
			-- entry Plan weight
			local strlen = string.len(entry)
			local n = tonumber(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					plan_weight = "---.-"
					plan_weight_lbs = plan_weight
					plan_weight_kgs = plan_weight
					entry = ""
				else
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < weight_min or n > weight_max then	-- Plan min and max
							entry = INVALID_INPUT
						else
							plan_weight = string.format("%5.1f", n)
							if units == 0 then
								plan_weight_lbs = plan_weight
								plan_weight_kgs = string.format("%5.1f", (tonumber(plan_weight) / 2.204))
							else
								plan_weight_kgs = plan_weight
								plan_weight_lbs = string.format("%5.1f", (tonumber(plan_weight) * 2.204))
							end
							entry = ""
						end
					end
				end
			end
		elseif page_n1_limit == 1 then
			if in_flight_mode == 0 then
				-- select TO
				to = "<ACT>"
				to_1 = "     "
				to_2 = "     "
				if sel_clb_thr == 0 then
					clb = "<SEL>"
					clb_1 = "     "
					clb_2 = "     "
				end
				if v1_set == "---" and vr_set == "---" and v2_set == "---" then
					entry = ""
				else
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
					--entry = VERIFY_TO_SPEEDS
					fms_msg_sound = 1
				end
				v1_set = "---"
				vr_set = "---"
				v2_set = "---"
			else
				-- select GA
				auto_act = "     "
				ga_act = "<ACT>"
				con_act = "     "
				clb_act = "     "
				crz_act = "     "
			end
		elseif page_takeoff == 2 then
			-- entry RW SLOPE / HDG
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					rw_slope = "--.-"
					rw_hdg = "---"
					if v1_set == "---" and vr_set == "---" and v2_set == "---" then
						entry = ""
					else
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
						--entry = VERIFY_TO_SPEEDS
						fms_msg_sound = 1
					end
					v1_set = "---"
					vr_set = "---"
					v2_set = "---"
				else
					if strlen == 4 then
						if string.sub(entry, 1, 1) == "/" then
							local n = tonumber(string.sub(entry, 2, 4))
							if n == nil then
								entry = INVALID_INPUT
							else
								if n < 0 or n > 359 then	-- HDG min and max
									entry = INVALID_INPUT
								else
									rw_hdg = string.format("%03d", n)
									if v1_set == "---" and vr_set == "---" and v2_set == "---" then
										entry = ""
									else
										fmc_message_num = fmc_message_num + 1
										fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
										--entry = VERIFY_TO_SPEEDS
										fms_msg_sound = 1
									end
									v1_set = "---"
									vr_set = "---"
									v2_set = "---"
								end
							end
						elseif string.sub(entry, 3, 3) == "." then
							local up_down = string.sub(entry, 1, 1)
							if up_down == "D" or up_down == "U" then
								local n = tonumber(string.sub(entry, 2, 4))
								if n == nil then
									entry = INVALID_INPUT
								else
									rw_slope = up_down .. string.format("%03.1f", n)
									if v1_set == "---" and vr_set == "---" and v2_set == "---" then
										entry = ""
									else
										fmc_message_num = fmc_message_num + 1
										fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
										--entry = VERIFY_TO_SPEEDS
										fms_msg_sound = 1
									end
									v1_set = "---"
									vr_set = "---"
									v2_set = "---"
								end
							else
								entry = INVALID_INPUT
							end
						else
							entry = INVALID_INPUT
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
			elseif page_descent == 1 then	--and B738DR_flight_phase < 5 then
			-- DES speed kts/mach
			local strlen = string.len(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					entry = ""
				else
					if strlen > 2 and  strlen < 6 and string.sub(entry, 1, 2) == "/." then		-- only mach
						local n = tonumber(string.sub(entry, 2, strlen))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(des_max_mach)
							local nnn = tonumber(des_min_mach)
							if nn == nil then
								nn = 0.820		-- max
							else
								nn = nn / 1000
							end
							if nnn == nil then
								nnn = 0.400		-- min
							end
							if n < nnn or n > nn then
								entry = INVALID_INPUT
							else
								B738DR_fmc_descent_speed_mach = n
								n = n * 1000
								simCMD_FMS_key_des:once()
								simCMD_FMS_key_delete:once()
								simCMD_FMS_key_clear:once()
								simCMD_FMS_key_clear:once()
								entry = "/." .. string.format("%03d", n)
								type_to_fmc(entry)
								simCMD_FMS_key_1L:once()
								-- --- vpa
								-- simCMD_FMS_key_des:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- entry = string.format("%4.2f", B738_rescale(700, 2.0, 760, 2.5, n))
								-- type_to_fmc(entry)
								-- simCMD_FMS_key_3R:once()
								entry = ""
								B738DR_descent_mode = 2
							end
						end
					elseif strlen == 3 then			-- only kts
						local n = tonumber(entry)
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(des_max_kts)
							local nnn = tonumber(des_min_kts)
							if nn == nil then
								nn = 340
							end
							if nnn == nil then
								nnn = 100		-- min
							end
							if n < nnn or n > nn then
								entry = INVALID_INPUT
							else
								simCMD_FMS_key_des:once()
								simCMD_FMS_key_delete:once()
								simCMD_FMS_key_clear:once()
								simCMD_FMS_key_clear:once()
								entry = string.format("%03d", n)
								type_to_fmc(entry)
								simCMD_FMS_key_1L:once()
								--- vpa
								simCMD_FMS_key_des:once()
								simCMD_FMS_key_delete:once()
								simCMD_FMS_key_clear:once()
								simCMD_FMS_key_clear:once()
								entry = string.format("%4.2f", B738_rescale(260, 2.0, 300, 2.5, n))
								type_to_fmc(entry)
								simCMD_FMS_key_3R:once()
								entry = ""
								B738DR_descent_mode = 2
								B738DR_fmc_descent_speed = n
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
			elseif page_climb == 1 then
			-- CLB speed kts/mach
			local strlen = string.len(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					entry = ""
				else
					if strlen > 2 and  strlen < 6 and string.sub(entry, 1, 2) == "/." then		-- only mach
						local n = tonumber(string.sub(entry, 2, strlen))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(clb_max_mach)
							local nnn = tonumber(clb_min_mach)
							if nn == nil then
								nn = 0.820		-- max
							else
								nn = nn / 1000
							end
							if nnn == nil then
								nnn = 0.400		-- min
							end
							if n < nnn or n > nn then
								entry = INVALID_INPUT
							else
								B738DR_fmc_climb_speed_mach = n
								n = n * 1000
								simCMD_FMS_key_clb:once()
								simCMD_FMS_key_delete:once()
								simCMD_FMS_key_clear:once()
								simCMD_FMS_key_clear:once()
								entry = "/." .. string.format("%03d", n)
								type_to_fmc(entry)
								simCMD_FMS_key_1L:once()
								entry = ""
								B738DR_climb_mode = 3
							end
						end
					elseif strlen == 3 then			-- only kts
						local n = tonumber(entry)
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(clb_max_kts)
							local nnn = tonumber(clb_min_kts)
							if nn == nil then
								nn = 340
							end
							if nnn == nil then
								nnn = 100		-- min
							end
							if n < nnn or n > nn then
								entry = INVALID_INPUT
							else
								B738DR_fmc_climb_speed = n
								simCMD_FMS_key_clb:once()
								simCMD_FMS_key_delete:once()
								simCMD_FMS_key_clear:once()
								simCMD_FMS_key_clear:once()
								entry = string.format("%03d", n)
								type_to_fmc(entry)
								simCMD_FMS_key_1L:once()
								entry = ""
								B738DR_climb_mode = 3
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_cruise == 1 then
			-- CRZ speed kts/mach
			local strlen = string.len(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					entry = ""
				else
					if strlen > 2 and  strlen < 6 and string.sub(entry, 1, 2) == "/." then		-- only mach
						local n = tonumber(string.sub(entry, 2, strlen))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(crz_max_mach)
							local nnn = tonumber(crz_min_mach)
							if nn == nil then
								nn = 0.820		-- max
							else
								nn = nn / 1000
							end
							if nnn == nil then
								nnn = 0.400		-- min
							end
							if n < nnn or n > nn then
								entry = INVALID_INPUT
							else
								B738DR_fmc_cruise_speed_mach = n
								n = n * 1000
								simCMD_FMS_key_crz:once()
								simCMD_FMS_key_delete:once()
								simCMD_FMS_key_clear:once()
								simCMD_FMS_key_clear:once()
								entry = "/." .. string.format("%03d", n)
								type_to_fmc(entry)
								simCMD_FMS_key_1L:once()
								entry = ""
								B738DR_cruise_mode = 2
							end
						end
					elseif strlen == 3 then			-- only kts
						local n = tonumber(entry)
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(crz_max_kts)
							local nnn = tonumber(crz_min_kts)
							if nn == nil then
								nn = 340
							end
							if nnn == nil then
								nnn = 100		-- min
							end
							if n < nnn or n > nn then
								entry = INVALID_INPUT
							else
								B738DR_fmc_cruise_speed = n
								simCMD_FMS_key_crz:once()
								simCMD_FMS_key_delete:once()
								simCMD_FMS_key_clear:once()
								simCMD_FMS_key_clear:once()
								entry = string.format("%03d", n)
								type_to_fmc(entry)
								simCMD_FMS_key_1L:once()
								entry = ""
								B738DR_cruise_mode = 2
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_perf == 2 then
			-- CLB min speed kts/mach
			local strlen = string.len(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					clb_min_kts = "   "
					clb_min_mach = "   "
					entry = ""
				else
					if strlen > 2 and  strlen < 6 and string.sub(entry, 1, 2) == "/." then		-- only mach
						local n = tonumber(string.sub(entry, 2, strlen))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(clb_max_mach)
							if nn == nil then
								nn = 0.82
							else
								nn = nn / 1000
							end
							if n < 0.4 or n > nn then
								entry = INVALID_INPUT
							else
								n = n * 1000
								clb_min_mach = string.format("%03d", n)
								entry = ""
							end
						end
					elseif strlen == 3 then			-- only kts
						local n = tonumber(entry)
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(clb_max_kts)
							if nn == nil then
								nn = 340
							end
							if n < 100 or n > nn then
								entry = INVALID_INPUT
							else
								clb_min_kts = string.format("%03d", n)
								entry = ""
							end
						end
					elseif strlen > 5 and strlen < 9 and string.sub(entry, 4, 5) == "/." then 	-- kts and mach
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(clb_max_kts)
							if nn == nil then
								nn = 340
							end
							if n < 100 or n > nn then
								entry = INVALID_INPUT
							else
								local kts = string.format("%03d", n)
									n = tonumber(string.sub(entry, 5, strlen))
									if n == nil then
										entry = INVALID_INPUT
									else
										nn = tonumber(clb_max_mach)
										if nn == nil then
											nn = 0.82
										else
											nn = nn / 1000
										end
										if n < 0.4 or n > nn then
											entry = INVALID_INPUT
										else
											n = n * 1000
											clb_min_kts = kts
											clb_min_mach = string.format("%03d", n)
											entry = ""
										end
									end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		-----------
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 3LSK
function B738_fmc1_3L_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_3L:once()
			entry = ""
		else
		
		if page_dep == 1 then
			if ref_sid2 == "------" then
				if ref_sid_sel[3] ~= "------" then
					ref_sid2 = ref_sid_sel[3]
					ref_sid_tns2 = "------"
					if ref_rwy2 == "-----" then
						create_rnw_list()
					end
					create_tns_list()
					act_page = 1
					ref_sid_exec = 1
				end
			else
				if ref_sid_tns2 == "------" then
					if ref_tns_sel[3] ~= "------" then
						ref_sid_tns2 = ref_tns_sel[3]
						act_page = 1
						ref_tns_exec = 1
					end
				end
			end
		elseif page_sel_wpt == 1 then
			
			local item = 0
			local button = 3	-- button 3 LSK
			
			item = (act_page - 1) * 5 + button
			if item <= navaid_list_n then
				-- select item
				rte_add_wpt2(item)
				legs_delete = 1
			end
		elseif page_sel_wpt2 == 1 then
			
			local item = 0
			local button = 3	-- button 3 LSK
			
			item = (act_page - 1) * 5 + button
			if item <= navaid_list_n then
				-- select item
				dir_add(item)
			end
		elseif page_xtras_fmod == 1 then
			-- FMOD Crew
			B738CMD_enable_crew:once()
		elseif page_xtras_fmod == 2 then
			-- FMOD Internal engine Start/Stop
			B738CMD_vol_int_start:once()
		elseif page_xtras_fmod == 3 then
			-- FMOD PAX volume
			B738CMD_vol_int_pax:once()
		elseif page_xtras_others == 1 then
			B738CMD_chock_toggle:once()
		elseif page_xtras_others == 2 then
			B738DR_throttle_noise = B738DR_throttle_noise + 1
			if B738DR_throttle_noise > 10 then
				B738DR_throttle_noise = 0
			end
		elseif page_arr == 1 then
			if des_star2 == "------" then
				if des_star_sel[3] ~= "------" then
					des_star2 = des_star_sel[3]
					des_star_trans2 = "------"
					if des_app2 == "------" then
						create_des_app_list()
					end
					create_star_tns_list()
					act_page = 1
					des_star_exec = 1
				end
			else
				if des_star_trans2 == "------" then
					if des_star_tns_sel[3] ~= "------" then
						des_star_trans2 = des_star_tns_sel[3]
						des_star_tns_exec = 1
						act_page = 1
					end
				end
			end
		elseif page_rte_init == 1 then
			if act_page == 1 and ref_icao ~= "----" then
				-- entry RWY
				if entry == ">DELETE" then
					-- if ref_rwy ~= "-----" then
						-- simCMD_FMS_key_dep_arr:once()
						-- simCMD_FMS_key_1L:once()
						-- simCMD_FMS_key_1R:once()
						-- simCMD_FMS_key_exec:once()
					-- end
					ref_rwy = "-----"
					entry = ""
				else
					--local ii = 0
					--local rwy_found = 0
					--local rwy1 = ""
					if rnw_exist(ref_icao, entry) == false then
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = NOT_IN_DATABASE
					else
						ref_rwy = entry
						entry = ""
					end
				end
			else
				local item = 0
				local button = 3	-- button 3 LSK
				local tmp_tmp = 0
				
				item = (act_page - 2) * 5 + button
				tmp_tmp = fpln_num2 + 1
				if fpln_num2 > 0 then
					if entry == ">DELETE" then
						del_via(item)
					else
						if item == tmp_tmp then
							if fpln_data2[fpln_num2][1] == "" and fpln_data2[fpln_num2][2] ~= "" then
								-- add new via via
								via_via_add()
							elseif fpln_data2[fpln_num2][1] ~= "" then
								-- add new via
								via_add(fpln_data2[fpln_num2][1], fpln_data2[fpln_num2][3])
							end
						elseif item <= fpln_num2 and fpln_num2 > 1 then
							-- change via
							via_chg(fpln_data2[item-1][1], fpln_data2[item-1][3], item)
						end
					end
				else
					entry = ">INVALID ENTRY"
				end
			end
		elseif page_legs == 1 then
			
			local item = 0
			local button = 3	-- button 3 LSK
			local tmp_tmp = 0
			
			item = (act_page - 1) * 5 + offset - 1 + button
			if item > legs_num2 then
				tmp_tmp = legs_num2 + 1
				if item == tmp_tmp and item_sel == 0 then
					-- add waypoint last
						rte_add_wpt(item)
						item_sel = 0
				else
					entry = INVALID_INPUT
				end
			else
				if entry == ">DELETE" then
					-- delete waypoint
					if item == legs_num2 then
						rte_copy(legs_num2 + 1)
						rte_paste(legs_num2)
						calc_rte_enable2 = 1
					else
						if legs_data2[item+1][1] == "DISCONTINUITY" then
							rte_copy(item + 1)
							rte_paste(item)
						else
							tmp_tmp = legs_num2
							rte_add_disco(item)
							legs_num2 = tmp_tmp
						end
						calc_rte_enable2 = 1
					end
					legs_delete = 1
					entry = ""
				elseif string.len(entry) > 1 and string.len(entry) < 6 and item_sel == 0 then
					-- add waypoint
						rte_add_wpt(item)
						item_sel = 0
				elseif item_sel == 0 then
					-- select item
					if legs_data2[item][1] == "DISCONTINUITY" then
						entry = INVALID_INPUT
						item_sel = 0
					else
						item_sel = item
						entry = legs_data2[item][1]
					end
				else
					-- entry item
					if item_sel > item then
						rte_copy(item_sel)
						rte_paste(item)
						calc_rte_enable2 = 1
					elseif item_sel < item then
						item_sel = item_sel + 1
						item = item + 1
						rte_copy(item)
						rte_paste(item_sel)
						calc_rte_enable2 = 1
					else
						entry = INVALID_INPUT
					end
					entry = ""
					item_sel = 0
					legs_delete = 1
				end
			end
		elseif page_takeoff == 1 then
			-- CG entry
			local strlen = string.len(entry)
			local n = tonumber(entry)
			if strlen == 0 then
				n = ((simDR_cg + 0.3429) / 3.907) * 100
				if n < 6 or n > 36 then	-- CG min and max
					entry = INVALID_INPUT
				else
					cg = string.format("%4.1f", n)
					if v1_set == "---" and vr_set == "---" and v2_set == "---" then
						entry = ""
					else
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
						--entry = VERIFY_TO_SPEEDS
						fms_msg_sound = 1
					end
					v1_set = "---"
					vr_set = "---"
					v2_set = "---"
				end
			else
				if entry == ">DELETE" then
					cg = "--.-"
					if v1_set == "---" and vr_set == "---" and v2_set == "---" then
						entry = ""
					else
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
						--entry = VERIFY_TO_SPEEDS
						fms_msg_sound = 1
					end
					v1_set = "---"
					vr_set = "---"
					v2_set = "---"
				else
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 6 or n > 36 then	-- CG min and max
							entry = INVALID_INPUT
						else
							cg = string.format("%4.1f", n)
							if v1_set == "---" and vr_set == "---" and v2_set == "---" then
								entry = ""
							else
								fmc_message_num = fmc_message_num + 1
								fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
								--entry = VERIFY_TO_SPEEDS
								fms_msg_sound = 1
							end
							v1_set = "---"
							vr_set = "---"
							v2_set = "---"
						end
					end
				end
			end
		elseif page_init == 1 then
			-- go to Perf init page
			page_init = 0
			page_perf = 1
			display_update = 1
		elseif page_pos_init == 2 then
			if B738DR_irs2_pos == "-----.-------.-" then
				entry = ""
			else
				entry = B738DR_irs2_pos
			end
		elseif page_pos_init == 1 and disable_POS_3L == 0 then
			-- entry Gate
			if entry == ">DELETE" then
				ref_gate = "-----"
				entry = ""
			else
				if string.len(entry) > 0 and string.len(entry) < 6 then
					ref_gate = entry
					local lenstr = string.len(ref_gate)
					if lenstr == 1 then
						ref_gate = ref_gate .. "    "
					elseif lenstr == 2 then
						ref_gate = ref_gate .. "   "
					elseif lenstr == 3 then
						ref_gate = ref_gate .. "  "
					elseif lenstr == 4 then
						ref_gate = ref_gate .. " "
					end
					entry = ""
				else
					entry = INVALID_INPUT
				end
			end
		elseif page_perf == 1 then
			-- entry ZFW
			local strlen = string.len(entry)
			local n = tonumber(entry)
			if strlen == 0 then
				zfw = zfw_calc
				if units == 0 then
					zfw_lbs = zfw
					zfw_kgs = string.format("%5.1f", (tonumber(zfw) / 2.204))
				else
					zfw_kgs = zfw
					zfw_lbs = string.format("%5.1f", (tonumber(zfw) * 2.204))
				end
			else
				if entry == ">DELETE" then
					zfw = "***.*"
					zfw_lbs = zfw
					zfw_kgs = zfw
					if v1_set == "---" and vr_set == "---" and v2_set == "---" then
						entry = ""
					else
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
						--entry = VERIFY_TO_SPEEDS
						fms_msg_sound = 1
					end
					v1_set = "---"
					vr_set = "---"
					v2_set = "---"
				else
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < weight_min or n > weight_max then	-- ZFW min and max
							entry = INVALID_INPUT
						else
							zfw = string.format("%5.1f", n)
							if units == 0 then
								zfw_lbs = zfw
								zfw_kgs = string.format("%5.1f", (tonumber(zfw) / 2.204))
							else
								zfw_kgs = zfw
								zfw_lbs = string.format("%5.1f", (tonumber(zfw) * 2.204))
							end
							if v1_set == "---" and vr_set == "---" and v2_set == "---" then
								entry = ""
							else
								fmc_message_num = fmc_message_num + 1
								fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
								--entry = VERIFY_TO_SPEEDS
								fms_msg_sound = 1
							end
							v1_set = "---"
							vr_set = "---"
							v2_set = "---"
						end
					end
				end
			end
		elseif page_n1_limit == 1 then
			if in_flight_mode == 0 then
				-- select TO-1
				to_1 = "<ACT>"
				to = "     "
				to_2 = "     "
				if sel_clb_thr == 0 then
					clb = "     "
					clb_1 = "<SEL>"
					clb_2 = "     "
				end
				if v1_set == "---" and vr_set == "---" and v2_set == "---" then
					entry = ""
				else
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
					--entry = VERIFY_TO_SPEEDS
					fms_msg_sound = 1
				end
				v1_set = "---"
				vr_set = "---"
				v2_set = "---"
			else
				-- select CON
				auto_act = "     "
				ga_act = "     "
				con_act = "<ACT>"
				clb_act = "     "
				crz_act = "     "
			end
		elseif page_descent_forecast == 1 then
			-- entry WIND ALT LAYER 1
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					forec_alt_1 = "-----"
					forec_alt_1_num = 0
					entry = ""
				elseif strlen == 5 and string.sub(entry, 1, 2) == "FL" then
					local n = tonumber(string.sub(entry, 3, 5))
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 10 or n > 410 then	-- FLxxx min and max
							entry = INVALID_INPUT
						else
							forec_alt_1_num = n * 100
							if forec_alt_1_num > B738DR_trans_lvl then
								--n = n / 100
								forec_alt_1 = "FL" .. string.format("%03d", n)
							else
								n = n * 100
								forec_alt_1 = string.format("%5d", n)
							end
							entry = ""
							wind_alt_order()
						end
					end
				else
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if strlen == 3 then
							if n < 10 or n > 410 then	-- FLxxx min and max
								entry = INVALID_INPUT
							else
								forec_alt_1_num = n * 100
								if forec_alt_1_num > B738DR_trans_lvl then
									--n = n / 100
									forec_alt_1 = "FL" .. string.format("%03d", n)
								else
									n = n * 100
									forec_alt_1 = string.format("%5d", n)
								end
								entry = ""
								wind_alt_order()
							end
						else
							if n < 1000 or n > 41000 then	-- Alt min and max
								entry = INVALID_INPUT
							else
								forec_alt_1_num = n
								if forec_alt_1_num > B738DR_trans_lvl then
									n = n / 100
									forec_alt_1 = "FL" .. string.format("%03d", n)
								else
									forec_alt_1 = string.format("%5d", n)
								end
								entry = ""
								wind_alt_order()
							end
						end
					end
				end
			end
		elseif page_perf == 2 then
			-- CRZ min speed kts/mach
			local strlen = string.len(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					crz_min_kts = "   "
					crz_min_mach = "   "
					entry = ""
				else
					if strlen > 2 and  strlen < 6 and string.sub(entry, 1, 2) == "/." then		-- only mach
						local n = tonumber(string.sub(entry, 2, strlen))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(crz_max_mach)
							if nn == nil then
								nn = 0.82
							else
								nn = nn / 1000
							end
							if n < 0.4 or n > nn then
								entry = INVALID_INPUT
							else
								n = n * 1000
								crz_min_mach = string.format("%03d", n)
								entry = ""
							end
						end
					elseif strlen == 3 then			-- only kts
						local n = tonumber(entry)
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(crz_max_kts)
							if nn == nil then
								nn = 340
							end
							if n < 100 or n > nn then
								entry = INVALID_INPUT
							else
								crz_min_kts = string.format("%03d", n)
								entry = ""
							end
						end
					elseif strlen > 5 and strlen < 9 and string.sub(entry, 4, 5) == "/." then 	-- kts and mach
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(crz_max_kts)
							if nn == nil then
								nn = 340
							end
							if n < 100 or n > nn then
								entry = INVALID_INPUT
							else
								local kts = string.format("%03d", n)
									n = tonumber(string.sub(entry, 5, strlen))
									if n == nil then
										entry = INVALID_INPUT
									else
										nn = tonumber(crz_max_mach)
										if nn == nil then
											nn = 0.82
										else
											nn = nn / 1000
										end
										if n < 0.4 or n > nn then
											entry = INVALID_INPUT
										else
											n = n * 1000
											crz_min_kts = kts
											crz_min_mach = string.format("%03d", n)
											entry = ""
										end
									end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		-----------
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 4LSK
function B738_fmc1_4L_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_4L:once()
			entry = ""
		else
		
		if page_dep == 1 then
			if ref_sid2 == "------" then
				if ref_sid_sel[4] ~= "------" then
					ref_sid2 = ref_sid_sel[4]
					ref_sid_tns2 = "------"
					if ref_rwy2 == "-----" then
						create_rnw_list()
					end
					create_tns_list()
					act_page = 1
					ref_sid_exec = 1
				end
			else
				if ref_sid_tns2 == "------" then
					if ref_tns_sel[4] ~= "------" then
						ref_sid_tns2 = ref_tns_sel[4]
						act_page = 1
						ref_tns_exec = 1
					end
				end
			end
		elseif page_sel_wpt == 1 then
			
			local item = 0
			local button = 4	-- button 4 LSK
			
			item = (act_page - 1) * 5 + button
			if item <= navaid_list_n then
				-- select item
				rte_add_wpt2(item)
				legs_delete = 1
			end
		elseif page_sel_wpt2 == 1 then
			
			local item = 0
			local button = 4	-- button 4 LSK
			
			item = (act_page - 1) * 5 + button
			if item <= navaid_list_n then
				-- select item
				dir_add(item)
			end
		elseif page_rte_init == 1 then
			if act_page > 1 then
				local item = 0
				local button = 4	-- button 4 LSK
				local tmp_tmp = 0
				
				item = (act_page - 2) * 5 + button
				tmp_tmp = fpln_num2 + 1
				if fpln_num2 > 0 then
					if entry == ">DELETE" then
						del_via(item)
					else
						if item == tmp_tmp then
							if fpln_data2[fpln_num2][1] == "" and fpln_data2[fpln_num2][2] ~= "" then
								-- add new via via
								via_via_add()
							elseif fpln_data2[fpln_num2][1] ~= "" then
								-- add new via
								via_add(fpln_data2[fpln_num2][1], fpln_data2[fpln_num2][3])
							end
						elseif item <= fpln_num2 and fpln_num2 > 1 then
							-- change via
							via_chg(fpln_data2[item-1][1], fpln_data2[item-1][3], item)
						end
					end
				else
					entry = ">INVALID ENTRY"
				end
			end
		elseif page_xtras_fmod == 1 then
			-- FMOD Airport ambience
			B738CMD_airport_set:once()
		elseif page_xtras_fmod == 2 then
			-- FMOD Internal AC fans volume
			B738CMD_vol_int_ac:once()
		elseif page_xtras_fmod == 3 then
			-- FMOD PAX applause enable
			B738CMD_vol_int_pax_applause:once()
		elseif page_xtras_others == 1 then
			B738CMD_pause_td_toggle:once()
		elseif page_xtras_others == 2 then
			if B738DR_fuelgauge == 0 then
				B738DR_fuelgauge = 1
			else
				B738DR_fuelgauge = 0
			end
		elseif page_arr == 1 then
			if des_star2 == "------" then
				if des_star_sel[4] ~= "------" then
					des_star2 = des_star_sel[4]
					des_star_trans2 = "------"
					if des_app2 == "------" then
						create_des_app_list()
					end
					create_star_tns_list()
					act_page = 1
					des_star_exec = 1
				end
			else
				if des_star_trans2 == "------" then
					if des_star_tns_sel[4] ~= "------" then
						des_star_trans2 = des_star_tns_sel[4]
						des_star_tns_exec = 1
						act_page = 1
					end
				end
			end
		elseif page_legs == 1 then
			
			local item = 0
			local button = 4	-- button 4 LSK
			local tmp_tmp = 0
			
			item = (act_page - 1) * 5 + offset - 1 + button
			if item > legs_num2 then
				tmp_tmp = legs_num2 + 1
				if item == tmp_tmp and item_sel == 0 then
					-- add waypoint last
						rte_add_wpt(item)
						item_sel = 0
				else
					entry = INVALID_INPUT
				end
			else
				if entry == ">DELETE" then
					-- delete waypoint
					if item == legs_num2 then
						rte_copy(legs_num2 + 1)
						rte_paste(legs_num2)
						calc_rte_enable2 = 1
					else
						if legs_data2[item+1][1] == "DISCONTINUITY" then
							rte_copy(item + 1)
							rte_paste(item)
						else
							tmp_tmp = legs_num2
							rte_add_disco(item)
							legs_num2 = tmp_tmp
						end
						calc_rte_enable2 = 1
					end
					legs_delete = 1
					entry = ""
				elseif string.len(entry) > 1 and string.len(entry) < 6 and item_sel == 0 then
					-- add waypoint
						rte_add_wpt(item)
						item_sel = 0
				elseif item_sel == 0 then
					-- select item
					if legs_data2[item][1] == "DISCONTINUITY" then
						entry = INVALID_INPUT
						item_sel = 0
					else
						item_sel = item
						entry = legs_data2[item][1]
					end
				else
					-- entry item
					if item_sel > item then
						rte_copy(item_sel)
						rte_paste(item)
						calc_rte_enable2 = 1
					elseif item_sel < item then
						item_sel = item_sel + 1
						item = item + 1
						rte_copy(item)
						rte_paste(item_sel)
						calc_rte_enable2 = 1
					else
						entry = INVALID_INPUT
					end
					entry = ""
					item_sel = 0
					legs_delete = 1
				end
			end
		elseif page_init == 1 then
			if B738DR_flight_phase == 1 then
				-- go to Climb page
				page_menu = 0
				page_init = 0
				page_ident = 0
				page_takeoff = 0
				page_approach = 0
				page_perf = 0
				page_n1_limit = 0
				page_pos_init = 0
				page_climb = 1
				page_cruise = 0
			elseif B738DR_flight_phase == 2 then
				-- go to Cruise page
				page_menu = 0
				page_init = 0
				page_ident = 0
				page_takeoff = 0
				page_approach = 0
				page_perf = 0
				page_n1_limit = 0
				page_pos_init = 0
				page_climb = 0
				page_cruise = 1
--			elseif B738DR_flight_phase == 2 then
				-- go to Descent page
				-- page_menu = 0
				-- page_init = 0
				-- page_ident = 0
				-- page_takeoff = 0
				-- page_approach = 0
				-- page_perf = 0
				-- page_n1_limit = 0
				-- page_pos_init = 0
				-- page_climb = 0
				-- page_cruise = 0
			else
				-- go to Takeoff page
				page_takeoff = 1
				page_init = 0
				page_menu = 0
				page_ident = 0
				page_approach = 0
				page_perf = 0
				page_n1_limit = 0
				page_pos_init = 0
				page_climb = 0
				page_cruise = 0
			end
		elseif page_pos_init == 2 then
			if B738DR_gps_pos == "-----.-------.-" then
				entry = ""
			else
				entry = B738DR_gps_pos
			end
		elseif page_climb == 1 then
			-- CLB ECON
			simCMD_FMS_key_clb:once()
			simCMD_FMS_key_delete:once()
			simCMD_FMS_key_clear:once()
			simCMD_FMS_key_clear:once()
			entry = "/." .. string.format("%03d", (econ_clb_spd_mach * 1000))
			type_to_fmc(entry)
			simCMD_FMS_key_1L:once()
			simCMD_FMS_key_clb:once()
			simCMD_FMS_key_delete:once()
			simCMD_FMS_key_clear:once()
			simCMD_FMS_key_clear:once()
			entry = string.format("%03d", econ_clb_spd)
			type_to_fmc(entry)
			simCMD_FMS_key_1L:once()
			entry = ""
			B738DR_climb_mode = 0
			B738DR_fmc_climb_speed_mach = econ_clb_spd_mach		-- temporary
			B738DR_fmc_climb_speed = econ_clb_spd				-- temporary
		elseif page_descent_forecast == 1 then
			-- entry WIND ALT LAYER 2
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					forec_alt_2 = "-----"
					forec_alt_2_num = 0
					entry = ""
				elseif strlen == 5 and string.sub(entry, 1, 2) == "FL" then
					local n = tonumber(string.sub(entry, 3, 5))
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 10 or n > 410 then	-- FLxxx min and max
							entry = INVALID_INPUT
						else
							forec_alt_2_num = n * 100
							if forec_alt_2_num >= B738DR_trans_lvl then
								--n = n / 100
								forec_alt_2 = "FL" .. string.format("%03d", n)
							else
								n = n * 100
								forec_alt_2 = string.format("%5d", n)
							end
							entry = ""
							wind_alt_order()
						end
					end
				else
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if strlen == 3 then
							if n < 10 or n > 410 then	-- FLxxx min and max
								entry = INVALID_INPUT
							else
								forec_alt_2_num = n * 100
								if forec_alt_2_num > B738DR_trans_lvl then
									--n = n / 100
									forec_alt_2 = "FL" .. string.format("%03d", n)
								else
									n = n * 100
									forec_alt_2 = string.format("%5d", n)
								end
								entry = ""
								wind_alt_order()
							end
						else
							if n < 1000 or n > 41000 then	-- Alt min and max
								entry = INVALID_INPUT
							else
								forec_alt_2_num = n
								if forec_alt_2_num > B738DR_trans_lvl then
									n = n / 100
									forec_alt_2 = "FL" .. string.format("%03d", n)
								else
									forec_alt_2 = string.format("%5d", n)
								end
								entry = ""
								wind_alt_order()
							end
						end
					end
				end
			end
		elseif page_perf == 1 then
			-- entry Reserve fuel
			local strlen = string.len(entry)
			local n = tonumber(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					reserves = "**.*"
					reserves_lbs = reserves
					reserves_kgs = reserves
					entry = ""
				else
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 0 or n > 99.9 then	-- Reserves min and max
							entry = INVALID_INPUT
						else
							reserves = string.format("%4.1f", n)
							if units == 0 then
								reserves_lbs = reserves
								reserves_kgs = string.format("%4.1f", (tonumber(reserves) / 2.204))
							else
								reserves_kgs = reserves
								reserves_lbs = string.format("%4.1f", (tonumber(reserves) * 2.204))
							end
							entry = ""
						end
					end
				end
			end
		elseif page_n1_limit == 1 then
			if in_flight_mode == 0 then
				-- select TO-2
				to_2 = "<ACT>"
				to = "     "
				to_1 = "     "
				if sel_clb_thr == 0 then
					clb = "     "
					clb_1 = "     "
					clb_2 = "<SEL>"
				end
				if v1_set == "---" and vr_set == "---" and v2_set == "---" then
					entry = ""
				else
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
					--entry = VERIFY_TO_SPEEDS
					fms_msg_sound = 1
				end
				v1_set = "---"
				vr_set = "---"
				v2_set = "---"
			else
				-- select CLB
				auto_act = "     "
				ga_act = "     "
				con_act = "     "
				clb_act = "<ACT>"
				crz_act = "     "
			end
		elseif page_takeoff == 2 then
				-- entry SEL TEMP and OAT
				local strlen = string.len(entry)
				local n = 0
				if strlen > 0 then
					if entry == ">DELETE" then
						sel_temp = "----"
						oat = "    "
						sel_temp_f = "----"
						oat_f = "    "
						oat_unit = "`C"
						if v1_set == "---" and vr_set == "---" and v2_set == "---" then
							entry = ""
						else
							fmc_message_num = fmc_message_num + 1
							fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
							--entry = VERIFY_TO_SPEEDS
							fms_msg_sound = 1
						end
						v1_set = "---"
						vr_set = "---"
						v2_set = "---"
					else
						if strlen > 0 and strlen < 6 then
							local oat_set = 0
							if string.sub(entry, 1, 1) == "/" and strlen > 1 then
								oat_set = 1		-- entry OAT
								entry = string.sub(entry, 2, strlen)
								strlen = strlen -1
							end
							
							local n_str = string.sub(entry, strlen, strlen)
							if n_str == "C" then 
								n = tonumber(string.sub(entry, 1, strlen-1))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < -20 or n > 70 then	-- Celsius min and max
										entry = INVALID_INPUT
									else
										oat_unit = "`C"
										if oat_set == 0 then
											if n < 0 then
												sel_temp = string.format("%4d", n)
											else
												if n < 10 then
													sel_temp = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													sel_temp = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
											n = (n * 9 / 5) + 32
											sel_temp_f = string.format("%4d", n)
										else
											if n < 0 then
												oat = string.format("%4d", n)
											else
												if n < 10 then
													oat = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													oat = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
											n = (n * 9 / 5) + 32
											oat_f = string.format("%4d", n)
										end
										if v1_set == "---" and vr_set == "---" and v2_set == "---" then
											entry = ""
										else
											fmc_message_num = fmc_message_num + 1
											fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
											--entry = VERIFY_TO_SPEEDS
											fms_msg_sound = 1
										end
										v1_set = "---"
										vr_set = "---"
										v2_set = "---"
									end
								end
							elseif n_str == "F" then
								n = tonumber(string.sub(entry, 1, strlen-1))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < -4 or n > 158 then	-- Fahrenheit min and max
										entry = INVALID_INPUT
									else
										oat_unit = "`F"
										if oat_set == 0 then
											sel_temp_f = string.format("%4d", n)
											n = (n - 32) * 5 / 9
											if n < 0 then
												sel_temp = string.format("%4d", n)
											else
												if n < 10 then
													sel_temp = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													sel_temp = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
										else
											oat_f = string.format("%4d", n)
											n = (n - 32) * 5 / 9
											if n < 0 then
												oat = string.format("%4d", n)
											else
												if n < 10 then
													oat = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													oat = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
										end
										if v1_set == "---" and vr_set == "---" and v2_set == "---" then
											entry = ""
										else
											fmc_message_num = fmc_message_num + 1
											fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
											--entry = VERIFY_TO_SPEEDS
											fms_msg_sound = 1
										end
										v1_set = "---"
										vr_set = "---"
										v2_set = "---"
									end
								end
							else
								n = tonumber(string.sub(entry, 1, strlen))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < -20 or n > 70 then	-- Celsius min and max
										entry = INVALID_INPUT
									else
										oat_unit = "`C"
										if oat_set == 0 then
											if n < 0 then
												sel_temp = string.format("%4d", n)
											else
												if n < 10 then
													sel_temp = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													sel_temp = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
											n = (n * 9 / 5) + 32
											sel_temp_f = string.format("%4d", n)
										else
											if n < 0 then
												oat = string.format("%4d", n)
											else
												if n < 10 then
													oat = "  +" .. string.sub(string.format("%4d", n), 4, 4)
												else
													oat = " +" .. string.sub(string.format("%4d", n), 3, 4)
												end
											end
											n = (n * 9 / 5) + 32
											oat_f = string.format("%4d", n)
										end
										if v1_set == "---" and vr_set == "---" and v2_set == "---" then
											entry = ""
										else
											fmc_message_num = fmc_message_num + 1
											fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
											--entry = VERIFY_TO_SPEEDS
											fms_msg_sound = 1
										end
										v1_set = "---"
										vr_set = "---"
										v2_set = "---"
									end
								end
							end
							
							
						else
							entry = INVALID_INPUT
						end
					end
				end
		elseif page_perf == 2 then
			-- DES min speed kts/mach
			local strlen = string.len(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					des_min_kts = "   "
					des_min_mach = "   "
					entry = ""
				else
					if strlen > 2 and  strlen < 6 and string.sub(entry, 1, 2) == "/." then		-- only mach
						local n = tonumber(string.sub(entry, 2, strlen))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(des_max_mach)
							if nn == nil then
								nn = 0.82
							else
								nn = nn / 1000
							end
							if n < 0.4 or n > nn then
								entry = INVALID_INPUT
							else
								n = n * 1000
								des_min_mach = string.format("%03d", n)
								entry = ""
							end
						end
					elseif strlen == 3 then			-- only kts
						local n = tonumber(entry)
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(des_max_kts)
							if nn == nil then
								nn = 340
							end
							if n < 100 or n > nn then
								entry = INVALID_INPUT
							else
								des_min_kts = string.format("%03d", n)
								entry = ""
							end
						end
					elseif strlen > 5 and strlen < 9 and string.sub(entry, 4, 5) == "/." then 	-- kts and mach
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(des_max_kts)
							if nn == nil then
								nn = 340
							end
							if n < 100 or n > nn then
								entry = INVALID_INPUT
							else
								local kts = string.format("%03d", n)
									n = tonumber(string.sub(entry, 5, strlen))
									if n == nil then
										entry = INVALID_INPUT
									else
										nn = tonumber(des_max_mach)
										if nn == nil then
											nn = 0.82
										else
											nn = nn / 1000
										end
										if n < 0.4 or n > nn then
											entry = INVALID_INPUT
										else
											n = n * 1000
											des_min_kts = kts
											des_min_mach = string.format("%03d", n)
											entry = ""
										end
									end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		-----------
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 5LSK
function B738_fmc1_5L_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_5L:once()
			entry = ""
		else
		
		if page_dep == 1 then
			if ref_sid2 == "------" then
				if ref_sid_sel[5] ~= "------" then
					ref_sid2 = ref_sid_sel[5]
					ref_sid_tns2 = "------"
					if ref_rwy2 == "-----" then
						create_rnw_list()
					end
					create_tns_list()
					act_page = 1
					ref_sid_exec = 1
				end
			else
				if ref_sid_tns2 == "------" then
					if ref_tns_sel[5] ~= "------" then
						ref_sid_tns2 = ref_tns_sel[5]
						act_page = 1
						ref_tns_exec = 1
					end
				end
			end
		elseif page_sel_wpt == 1 then
			
			local item = 0
			local button = 5	-- button 5 LSK
			
			item = (act_page - 1) * 5 + button
			if item <= navaid_list_n then
				-- select item
				rte_add_wpt2(item)
				legs_delete = 1
			end
		
		elseif page_sel_wpt2 == 1 then
			
			local item = 0
			local button = 5	-- button 5 LSK
			
			item = (act_page - 1) * 5 + button
			if item <= navaid_list_n then
				-- select item
				dir_add(item)
			end
		elseif page_rte_init == 1 then
			if act_page > 1 then
				local item = 0
				local button = 5	-- button 5 LSK
				local tmp_tmp = 0
				
				item = (act_page - 2) * 5 + button
				tmp_tmp = fpln_num2 + 1
				if fpln_num2 > 0 then
					if entry == ">DELETE" then
						del_via(item)
					else
						if item == tmp_tmp then
							if fpln_data2[fpln_num2][1] == "" and fpln_data2[fpln_num2][2] ~= "" then
								-- add new via via
								via_via_add()
							elseif fpln_data2[fpln_num2][1] ~= "" then
								-- add new via
								via_add(fpln_data2[fpln_num2][1], fpln_data2[fpln_num2][3])
							end
						elseif item <= fpln_num2 and fpln_num2 > 1 then
							-- change via
							via_chg(fpln_data2[item-1][1], fpln_data2[item-1][3], item)
						end
					end
				else
					entry = ">INVALID ENTRY"
				end
			end
		elseif page_xtras_fmod == 1 then
			-- FMOD Gyro vibrators
			B738CMD_enable_gyro:once()
		elseif page_xtras_fmod == 2 then
			-- FMOD Internal GYRO volume
			B738CMD_vol_int_gyro:once()
		elseif page_xtras_fmod == 3 then
			-- FMOD Internal WIND volume
			B738CMD_vol_int_wind:once()
		elseif page_xtras_others == 1 then
			if B738DR_toe_brakes_ovr == 0 then
				B738DR_toe_brakes_ovr = 1
			else
				B738DR_toe_brakes_ovr = 0
			end
		elseif page_xtras_others == 2 then
			if B738DR_nosewheel == 0 then
				B738DR_nosewheel = 1
			else
				B738DR_nosewheel = 0
			end
		elseif page_arr == 1 then
			if des_star2 == "------" then
				if des_star_sel[5] ~= "------" then
					des_star2 = des_star_sel[5]
					des_star_trans2 = "------"
					if des_app2 == "------" then
						create_des_app_list()
					end
					create_star_tns_list()
					act_page = 1
					des_star_exec = 1
				end
			else
				if des_star_trans2 == "------" then
					if des_star_tns_sel[5] ~= "------" then
						des_star_trans2 = des_star_tns_sel[5]
						des_star_tns_exec = 1
						act_page = 1
					end
				end
			end
		elseif page_legs == 1 then
			
			local item = 0
			local button = 5	-- button 5 LSK
			local tmp_tmp = 0
			
			item = (act_page - 1) * 5 + offset - 1 + button
			if item > legs_num2 then
				tmp_tmp = legs_num2 + 1
				if item == tmp_tmp and item_sel == 0 then
					-- add waypoint last
						rte_add_wpt(item)
						item_sel = 0
				else
					entry = INVALID_INPUT
				end
			else
				if entry == ">DELETE" then
					-- delete waypoint
					if item == legs_num2 then
						rte_copy(legs_num2 + 1)
						rte_paste(legs_num2)
					else
						if legs_data2[item+1][1] == "DISCONTINUITY" then
							rte_copy(item + 1)
							rte_paste(item)
						else
							tmp_tmp = legs_num2
							rte_add_disco(item)
							legs_num2 = tmp_tmp
						end
					end
					calc_rte_enable2 = 1
					legs_delete = 1
					entry = ""
				elseif string.len(entry) > 1 and string.len(entry) < 6 and item_sel == 0 then
					-- add waypoint
						rte_add_wpt(item)
						item_sel = 0
				elseif item_sel == 0 then
					-- select item
					if legs_data2[item][1] == "DISCONTINUITY" then
						entry = INVALID_INPUT
						item_sel = 0
					else
						item_sel = item
						entry = legs_data2[item][1]
					end
				else
					-- entry item
					if item_sel > item then
						rte_copy(item_sel)
						rte_paste(item)
						calc_rte_enable2 = 1
					elseif item_sel < item then
						item_sel = item_sel + 1
						item = item + 1
						rte_copy(item)
						rte_paste(item_sel)
						calc_rte_enable2 = 1
					else
						entry = INVALID_INPUT
					end
					entry = ""
					item_sel = 0
					legs_delete = 1
				end
			end
		elseif page_init == 1 then
			-- go to Approach page
			page_init = 0
			page_approach = 1
			display_update = 1
		elseif page_pos_init == 2 then
			if B738DR_gps2_pos == "-----.-------.-" then
				entry = ""
			else
				entry = B738DR_gps2_pos
			end
		elseif page_approach == 1 then
			-- G/S enable/disable
			if des_app ~= "------" then
				if simDR_glideslope_status == 0 then
					if B738DR_fms_ils_disable == 0 then
						B738DR_fms_ils_disable = 1
					else
						B738DR_fms_ils_disable = 0
					end
				end
			end
		elseif page_perf == 1 then --and was_on_air == 0 then	-- only on ground
			-- entry Cost Index
			local strlen = string.len(entry)
			local n = tonumber(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					cost_index = "***"
					entry = ""
				else
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 0 or n > 500 then	-- Cost Index min and max
							entry = INVALID_INPUT
						else
							cost_index = string.format("%3d", n)
							B738_calc_vnav_spd()
							entry = ""
						end
					end
				end
			end
		elseif page_cruise == 1 then
			-- CRZ ECON
			simCMD_FMS_key_crz:once()
			simCMD_FMS_key_delete:once()
			simCMD_FMS_key_clear:once()
			simCMD_FMS_key_clear:once()
			entry = "/." .. string.format("%03d", (econ_crz_spd_mach * 1000))
			type_to_fmc(entry)
			simCMD_FMS_key_1L:once()
			simCMD_FMS_key_crz:once()
			simCMD_FMS_key_delete:once()
			simCMD_FMS_key_clear:once()
			simCMD_FMS_key_clear:once()
			entry = string.format("%03d", econ_crz_spd)
			type_to_fmc(entry)
			simCMD_FMS_key_1L:once()
			entry = ""
			B738DR_cruise_mode = 0
			B738DR_fmc_cruise_speed_mach = econ_crz_spd_mach		-- temporary
			B738DR_fmc_cruise_speed = econ_crz_spd				-- temporary
		elseif page_descent == 1 and B738DR_flight_phase < 5 and simDR_vnav_tod_nm > 15 then
			-- DES ECON
			--- speed mach
			simCMD_FMS_key_des:once()
			simCMD_FMS_key_delete:once()
			simCMD_FMS_key_clear:once()
			simCMD_FMS_key_clear:once()
			entry = "/." .. string.format("%03d", (econ_des_spd_mach * 1000))
			type_to_fmc(entry)
			simCMD_FMS_key_1L:once()
			--- speed kts
			simCMD_FMS_key_des:once()
			simCMD_FMS_key_delete:once()
			simCMD_FMS_key_clear:once()
			simCMD_FMS_key_clear:once()
			entry = string.format("%03d", econ_des_spd)
			type_to_fmc(entry)
			simCMD_FMS_key_1L:once()
			--- vpa
			simCMD_FMS_key_des:once()
			simCMD_FMS_key_delete:once()
			simCMD_FMS_key_clear:once()
			simCMD_FMS_key_clear:once()
			entry = string.format("%4.2f", econ_des_vpa)
			type_to_fmc(entry)
			simCMD_FMS_key_3R:once()
			entry = ""
			B738DR_descent_mode = 0
			B738DR_fmc_descent_speed_mach = econ_des_spd_mach		-- temporary
			B738DR_fmc_descent_speed = econ_des_spd				-- temporary
		elseif page_n1_limit == 1 then
			if in_flight_mode == 1 then
				-- select CRZ
				auto_act = "     "
				ga_act = "     "
				con_act = "     "
				clb_act = "     "
				crz_act = "<ACT>"
			end
		elseif page_descent_forecast == 1 then
			-- entry WIND ALT LAYER 3
			local strlen = string.len(entry)
			local n = 0
			if strlen > 0 then
				if entry == ">DELETE" then
					forec_alt_3 = "-----"
					forec_alt_3_num = 0
					entry = ""
				elseif strlen == 5 and string.sub(entry, 1, 2) == "FL" then
					n = tonumber(string.sub(entry, 3, 5))
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 10 or n > 410 then	-- FLxxx min and max
							entry = INVALID_INPUT
						else
							forec_alt_3_num = n * 100
							if forec_alt_3_num > B738DR_trans_lvl then
								--n = n / 100
								forec_alt_3 = "FL" .. string.format("%03d", n)
							else
								n = n * 100
								forec_alt_3 = string.format("%5d", n)
							end
							entry = ""
							wind_alt_order()
						end
					end
				else
					n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if strlen == 3 then
							if n < 10 or n > 410 then	-- FLxxx min and max
								entry = INVALID_INPUT
							else
								forec_alt_3_num = n * 100
								if forec_alt_3_num > B738DR_trans_lvl then
									--n = n / 100
									forec_alt_3 = "FL" .. string.format("%03d", n)
								else
									n = n * 100
									forec_alt_3 = string.format("%5d", n)
								end
								entry = ""
								wind_alt_order()
							end
						else
							if n < 1000 or n > 41000 then	-- Alt min and max
								entry = INVALID_INPUT
							else
								forec_alt_3_num = n
								if forec_alt_3_num > B738DR_trans_lvl then
									n = n / 100
									forec_alt_3 = "FL" .. string.format("%03d", n)
								else
									forec_alt_3 = string.format("%5d", n)
								end
								entry = ""
								wind_alt_order()
							end
						end
					end
				end
			end
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 6LSK
function B738_fmc1_6L_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_6L:once()
			entry = ""
		else
		
		if page_takeoff ~= 0  then
			if pre_flt_pos_init == 0 then
				-- go to Pos init
				page_pos_init = 1
			elseif pre_flt_rte == 0 then
				-- go to Route init
				page_rte_init = 1
			elseif pre_flt_dep == 0 then
				-- go to Departure
				page_dep = 1
			elseif pre_flt_perf_init == 0 then
				-- go to Perf_init
				page_perf = 1
			else
				-- go to Index page
				page_init = 1
			end
			page_takeoff = 0
			display_update = 1
		elseif page_dep == 1 then
			if ref_sid_exec == 1 or ref_rwy_exec == 1 or ref_tns_exec == 1 then --or ref_app_tns_exec == 1 then
				ref_rwy2 = ref_rwy
				ref_sid2 = ref_sid
				ref_sid_tns2 = ref_sid_tns
				ref_sid_exec = 0
				ref_rwy_exec = 0
				ref_tns_exec = 0
				ref_app_tns_exec = 0
				act_page = 1
			end
		elseif page_arr == 1 then
			if des_star_exec == 1 or des_star_tns_exec == 1 or des_app_exec == 1 or des_app_tns_exec == 1 then
				des_app2 = des_app
				des_app_tns2 = des_app_tns
				des_star2 = des_star
				des_star_trans2 = des_star_trans
				des_star_exec = 0
				des_star_tns_exec = 0
				des_app_exec = 0
				des_app_tns_exec = 0
				act_page = 1
				if arr_data == 1 then
					arr_data = 0
					page_arr = 0
					page_dep_arr = 1
				end
			end
		elseif page_rte_init == 1 then
			-- if ref_icao ~= "----" and des_icao ~= "****" then
				-- page_rte_init = 0
				-- page_route = 1
				-- page_clear = 1
				-- simCMD_FMS_key_fpln:once()
			-- end
			if refdes_exec == 1 then
				des_icao_x = des_icao
				refdes_exec = 0
			end
			if rte_exec == 1 then
				--copy_to_fpln2()
				legs_delete = 0
				copy_to_legsdata2()
				create_fpln()
				rte_exec = 0
			end
		elseif page_legs == 1 then
			-- cancel MOD
			if B738DR_fms_exec_light_pilot == 1 then
				if legs_delete == 1 then
					legs_delete = 0
					copy_to_legsdata2()
				end
			end
		-- elseif page_sel_wpt == 1 then
			-- -- cancel MOD
			-- if legs_delete == 1 then
				-- legs_delete = 0
				-- copy_to_legsdata2()
				-- page_legs = 1
				-- page_sel_wpt = 0
			-- end
		elseif page_ident == 1 then
			-- go to Index page
			page_ident = 0
			page_init = 1
			display_update = 1
		elseif page_approach == 1 then
			-- go to Index page
			page_approach = 0
			page_init = 1
			display_update = 1
		elseif page_n1_limit == 1 and disable_N1_6L == 0 then
			if in_flight_mode == 0 then
				-- go to Perf init page
				page_n1_limit = 0
				page_perf = 1
				display_update = 1
			else
				-- select / deselect CLB-1
				if clb_1 == "<SEL>" then
					clb = "<SEL>"
					clb_1 = "     "
					clb_2 = "     "
				else
					clb = "     "
					clb_1 = "<SEL>"
					clb_2 = "     "
				end
				sel_clb_thr = 1
			end
		elseif page_perf ~= 0 then
			-- go to Index page
			page_perf = 0
			page_init = 1
			display_update = 1
		elseif page_pos_init == 1 then
			-- go to Index page
			page_pos_init = 0
			page_init = 1
			display_update = 1
		elseif page_descent == 1 then
			page_descent = 0
			page_descent_forecast = 1
			display_update = 1
		elseif page_xtras == 1 then
			-- SAVE CONFIG
			B738_save_config()
			fmc_message_num = fmc_message_num + 1
			fmc_message[fmc_message_num] = CONFIG_SAVED
			fms_msg_sound = 1
			--entry = CONFIG_SAVED
		elseif page_xtras_fmod > 0 then
			-- DEFAULT value
			B738_default_fmod_config()
		elseif page_xtras_others > 0 then
			-- DEFAULT value
			B738_default_others_config()
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 1RSK
function B738_fmc1_1R_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_1R:once()
			entry = ""
		else
		
		if page_dep == 1 then
			if ref_rwy2 == "-----" then
				if ref_rwy_sel[1] ~= "-----" then
					ref_rwy2 = ref_rwy_sel[1]
					if ref_sid2 == "------" then
						create_sid_list()
					end
					act_page = 1
					ref_rwy_exec = 1
				end
			else
				ref_rwy2 = "-----"
				if ref_sid2 == "------" then
					create_sid_list()
				end
				create_rnw_list()
				act_page = 1
				ref_rwy_exec = 1
			end
		elseif page_arr == 1 then
			if des_app2 == "------" then
				if des_app_sel[1] ~= "------" then
					des_app2 = des_app_sel[1]
					if des_star2 == "------" then
						create_star_list()
					end
					des_app_tns2 = "------"
					act_page = 1
					des_app_exec = 1
					create_app_tns_list()
				end
			else
				des_app2 = "------"
				if des_star2 == "------" then
					create_star_list()
				end
				des_app_tns2 = "------"
				create_des_app_list()
				act_page = 1
				des_app_exec = 1
			end
		elseif page_dep_arr == 1 then
			-- Reference ARR
			if des_icao ~= "****" and ref_icao ~= "----" then
				arr_data = 1
				if des_icao == ref_icao then
					page_arr = 1
					page_dep_arr = 0
					--arr_data = 1
					---
					des_app2 = des_app
					des_app_tns2 = des_app_tns
					des_star2 = des_star
					des_star_trans2 = des_star_trans
					---
					create_star_list()
					create_star_tns_list()
					create_des_app_list()
					create_app_tns_list()
				else
					page_arr = 1
					page_dep_arr = 0
					--arr_data = 1
					---
					des_app2 = "------"
					des_app_tns2 = "------"
					des_star2 = "------"
					des_star_trans2 = "------"
					---
					create_star_list()
					create_star_tns_list()
					create_des_app_list()
					create_app_tns_list()
				end
			end
		elseif page_rte_init == 1 then
			if act_page == 1 then
				-- entry Destination airport ICAO
				local xy = 0
				local apt_ok = 0
				if ref_icao ~= "----" then
					if entry == ">DELETE" then
						--des_icao = "****"
						-- legs_num = 0
						-- des_app = "------"
						-- des_app_tns = "------"
						-- des_star = "------"
						-- des_star_trans = "------"
						-- ----
						-- des_app2 = "------"
						-- des_app_tns2 = "------"
						-- des_star2 = "------"
						-- des_star_trans2 = "------"
						-- ----
						-- co_route = "------------"
						-- legs_num = 0
						
						des_icao_x = "****"
						entry = ""
						refdes_exec = 1
					else
						if string.len(entry) == 4 then
							des_app_from_apt = 0
							file_name = "Custom Data/CIFP/" .. entry
							file_name = file_name .. ".dat"
							file_navdata = io.open(file_name, "r")
							if file_navdata == nil then
								file_name = "Resources/default data/CIFP/" .. entry
								file_name = file_name .. ".dat"
								file_navdata = io.open(file_name, "r")
								if file_navdata == nil then
									if apt_exist(entry) == true then
										apt_ok = 1
									end
								else
									read_des_data()		-- read destination airport data
									file_navdata:close()
									apt_ok = 1
								end
							else
								read_des_data()		-- read destination airport data
								file_navdata:close()
								apt_ok = 1
							end
							
							if apt_ok == 0 then
								fmc_message_num = fmc_message_num + 1
								fmc_message[fmc_message_num] = NOT_IN_DATABASE
							else
								-- offset = 1
								-- des_app = "------"
								-- des_app_tns = "------"
								-- des_star = "------"
								-- des_star_trans = "------"
								-- ----
								-- des_app2 = "------"
								-- des_app_tns2 = "------"
								-- des_star2 = "------"
								-- des_star_trans2 = "------"
								-- ----
								-- co_route = "------------"
								-- legs_num = 0
								
								des_icao_x = entry
								if apt_exist(entry) == true then
									des_icao_lat = icao_latitude
									des_icao_lon = icao_longitude
									des_tns_alt = icao_tns_alt
									des_tns_lvl = icao_tns_lvl
								else
									des_tns_alt = 0
									des_tns_lvl = 0
								end
								if des_tns_lvl == 0 then
									trans_lvl = "-----"
								else
									apt_ok = des_tns_lvl
									trans_lvl = "FL" .. string.format("%03d", apt_ok)
								end
								entry = ""
								refdes_exec = 1
							end
						elseif entry == "" and des_icao ~= "****" then
							entry = des_icao
						else
							entry = INVALID_INPUT
						end
					end
					arr_data = 0
					create_rnw_list()
					create_star_list()
					create_des_app_list()
				end
			else
				local item = 0
				local button = 1	-- button 1 RSK
				local tmp_tmp = 0
				
				item = (act_page - 2) * 5 + button
				tmp_tmp = fpln_num2 + 1
				if fpln_num2 > 0 then
					if item == tmp_tmp then
						--if fpln_data2[fpln_num2][1] ~= "" then
							-- add new direct to navaid
							dir_via_add("", "", entry, "", "", item)
						--end
					elseif item <= fpln_num2 then --and fpln_num2 > 1 then
						if item == 1 then
							dir_via_add("", "", entry, "", "", item)
						else
							dir_via_add(fpln_data2[item-1][1], fpln_data2[item-1][3], entry, "", fpln_data2[item][2], item)
						end
					end
				else
					-- first waypoint
					if item == tmp_tmp then
						-- add new direct to navaid
						dir_via_add("", "", entry, "", "", item)
					end
				end
			end
		elseif page_legs == 1 then
			if B738DR_fms_exec_light_pilot == 0 then
				local item = 0
				local button = 1	-- button 1 RSK
				local n = 0
				local nn = 0
				local nnn = 0
				local strlen = string.len(entry)
				
				item = (act_page - 1) * 5 + offset - 1 + button
				if item > legs_num then
					entry = INVALID_INPUT
				elseif legs_data[item][1] == "DISCONTINUITY" then
					entry = INVALID_INPUT
				elseif entry == ">DELETE" then
					legs_data[item][4] = 0
					legs_data[item][5] = 0
					legs_data[item][6] = 0
					entry = ""
					msg_chk_alt_constr = 0
					vnav_update = 1
				else
					if strlen == 4 and string.sub(entry, -1, -1) == "/" then		-- speed: xxx
						n = tonumber(string.sub(entry, 1, -2))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n > 100 and n < 340 then
								legs_data[item][4] = n		-- speed
								vnav_update = 1
								msg_chk_alt_constr = 0
								entry = ""
							else
								entry = INVALID_INPUT
							end
						end
					elseif strlen > 4 and strlen < 7 and string.sub(entry, 1, 2) == "FL" then		-- alt: FLxxx or FLxxxX
						if string.sub(entry, -1, -1) == "A" then
							nn = 43
							n = tonumber(string.sub(entry, 3, -2))
						elseif string.sub(entry, -1, -1) == "B" then
							nn = 45
							n = tonumber(string.sub(entry, 3, -2))
						else
							if strlen == 7 then
								n = nil
							else
								nn = 32
								n = tonumber(string.sub(entry, 3, -1))
							end
						end
						if n == nil then
							entry = INVALID_INPUT
						else
							legs_data[item][5] = n * 100
							legs_data[item][6] = nn
							msg_chk_alt_constr = 0
							vnav_update = 1
							entry = ""
						end
					elseif strlen > 2 and  strlen < 7 then	-- alt: xxx or xxxx or xxxxx with X
						if string.sub(entry, -1, -1) == "A" then
							nn = 43
							n = tonumber(string.sub(entry, 1, -2))
						elseif string.sub(entry, -1, -1) == "B" then
							nn = 45
							n = tonumber(string.sub(entry, 1, -2))
						else
							nn = 32
							n = tonumber(string.sub(entry, 1, -1))
						end
						if n == nil then
							entry = INVALID_INPUT
						else
							legs_data[item][5] = n
							legs_data[item][6] = nn
							msg_chk_alt_constr = 0
							vnav_update = 1
							entry = ""
						end
					elseif strlen > 6 and  strlen < 11 and string.sub(entry, 4, 4) == "/" then		-- alt: xxx/FLxxx or xxx/FLxxxX
						-- speed
						n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n > 100 and n < 340 then
								if string.sub(entry, 5, 6) == "FL" then
									if string.sub(entry, -1, -1) == "A" then
										nn = 43
										nnn = tonumber(string.sub(entry, 7, -2))
									elseif string.sub(entry, -1, -1) == "B" then
										nn = 45
										nnn = tonumber(string.sub(entry, 7, -2))
									else
										nn = 32
										nnn = tonumber(string.sub(entry, 7, -1))
									end
								else
									if string.sub(entry, -1, -1) == "A" then
										nn = 43
										nnn = tonumber(string.sub(entry, 5, -2))
									elseif string.sub(entry, -1, -1) == "B" then
										nn = 45
										nnn = tonumber(string.sub(entry, 5, -2))
									else
										nn = 32
										nnn = tonumber(string.sub(entry, 5, -1))
									end
								end
								if nnn == nil then
									entry = INVALID_INPUT
								else
									if string.sub(entry, 5, 6) == "FL" then
										nnn = nnn * 100
									end
									legs_data[item][4] = n
									legs_data[item][5] = nnn
									legs_data[item][6] = nn
									msg_chk_alt_constr = 0
									vnav_update = 1
									entry = ""
								end
							else
								entry = INVALID_INPUT
							end
						end
						
					end
				end
			end
		elseif page_takeoff == 1 then
			-- entry V1
			if entry == "" then
				if v1 ~= "---" and qrh == "OFF" then
					v1_set = v1
				end
			else
				-- from scratch (test speed correct)
				if entry == ">DELETE" then
					v1_set = "---"
					entry = ""
				else
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if n > 99 and n < 170 then
							v1_set = entry
							entry = ""
						else
							entry = INVALID_INPUT
						end
					end
				end
			end
			display_update = 1
		elseif page_takeoff == 2 then
			if rw_cond == 2 then
				rw_cond = 0
			else
				rw_cond = rw_cond + 1
			end
			if v1_set == "---" and vr_set == "---" and v2_set == "---" then
				entry = ""
			else
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = VERIFY_TO_SPEEDS
				--entry = VERIFY_TO_SPEEDS
				fms_msg_sound = 1
				B738DR_fmc_message_warn = 1
			end
			v1_set = "---"
			vr_set = "---"
			v2_set = "---"
		elseif page_menu == 1 then
			simCMD_FMS_reset:once()
			--B738_init()
			B738_init2()
			--fmc_message_num = 0
		elseif page_approach == 1 then
			-- select flaps 15
			if vref_15 == "---" then
				entry = ""
			else
				if flaps_app == "15" then
					app_flap = "15"
					app_spd = vref_15
					flaps_app = "  "
				else
					flaps_app = "15"
				end
			end
		elseif page_perf == 1 then --and was_on_air == 0 then	-- only on ground
			-- entry Cruise alt
			local strlen = string.len(entry)
			local alt_temp = 0
			if strlen > 0 then
				if entry == ">DELETE" then
					crz_alt = "*****"
					crz_alt_num = 0
					entry = ""
				elseif strlen == 5 and string.sub(entry, 1, 2) == "FL" then
					local n = tonumber(string.sub(entry, 3, 5))
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 10 or n > 410 then	-- Cruise level FLxxx min and max
							entry = INVALID_INPUT
						else
							crz_alt_num = n * 100
							if crz_alt_num >= B738DR_trans_alt then
								--n = n / 100
								crz_alt = "FL" .. string.format("%03d", n)
							else
								n = n * 100
								crz_alt = string.format("%5d", n)
							end
							entry = ""
							vnav_update = 1
							msg_unavaible_crz_alt = 0
							B738DR_fmc_cruise_alt = crz_alt_num
							-- write to fmc
							-- simCMD_FMS_key_crz:once()
							-- simCMD_FMS_key_delete:once()
							-- simCMD_FMS_key_clear:once()
							-- simCMD_FMS_key_clear:once()
							-- type_to_fmc(crz_alt)
							-- simCMD_FMS_key_1R:once()
							-- calc TC OAT
							if isa_dev_c ~= "---" then
								n = tonumber(isa_dev_c)
								alt_temp = math.min(crz_alt_num, 37000)
								tc_oat_c = string.format("%3d", (B738_rescale(0, 15, 37000, -56.5, alt_temp) + n))
								n = tonumber(tc_oat_c)
								n = (n * 9 / 5) + 32
								tc_oat_f = string.format("%3d", n)
							end
						end
					end
				else
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if strlen == 3 then
							if n < 10 or n > 410 then	-- Cruise level FLxxx min and max
								entry = INVALID_INPUT
							else
								crz_alt_num = n * 100
								if crz_alt_num >= B738DR_trans_alt then
									--n = n / 100
									crz_alt = "FL" .. string.format("%03d", n)
								else
									n = n * 100
									crz_alt = string.format("%5d", n)
								end
								entry = ""
								vnav_update = 1
								msg_unavaible_crz_alt = 0
								B738DR_fmc_cruise_alt = crz_alt_num
								-- write to fmc
								-- simCMD_FMS_key_crz:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- type_to_fmc(crz_alt)
								-- simCMD_FMS_key_1R:once()
								-- calc TC OAT
								if isa_dev_c ~= "---" then
									n = tonumber(isa_dev_c)
									alt_temp = math.min(crz_alt_num, 37000)
									tc_oat_c = string.format("%3d", (B738_rescale(0, 15, 37000, -56.5, alt_temp) + n))
									n = tonumber(tc_oat_c)
									n = (n * 9 / 5) + 32
									tc_oat_f = string.format("%3d", n)
								end
							end
						else
							if n < 1000 or n > 41000 then	-- Cruise alt min and max
								entry = INVALID_INPUT
							else
								crz_alt_num = n
								if crz_alt_num >= B738DR_trans_alt then
									n = n / 100
									crz_alt = "FL" .. string.format("%03d", n)
								else
									crz_alt = string.format("%5d", n)
								end
								entry = ""
								vnav_update = 1
								msg_unavaible_crz_alt = 0
								B738DR_fmc_cruise_alt = crz_alt_num
								-- write to fmc
								-- simCMD_FMS_key_crz:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- type_to_fmc(crz_alt)
								-- simCMD_FMS_key_1R:once()
								-- calc TC OAT
								if isa_dev_c ~= "---" then
									n = tonumber(isa_dev_c)
									alt_temp = math.min(crz_alt_num, 37000)
									tc_oat_c = string.format("%3d", (B738_rescale(0, 15, 37000, -56.5, alt_temp) + n))
									n = tonumber(tc_oat_c)
									n = (n * 9 / 5) + 32
									tc_oat_f = string.format("%3d", n)
								end
							end
						end
					end
				end
			end
			B738_calc_vnav_spd()
		elseif page_pos_init == 1 then
			entry = last_pos
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 2RSK
function B738_fmc1_2R_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_2R:once()
			entry = ""
		else
		
		if page_dep == 1 then
			if ref_rwy2 == "-----" then
				if ref_rwy_sel[2] ~= "-----" then
					ref_rwy2 = ref_rwy_sel[2]
					if ref_sid2 == "------" then
						create_sid_list()
					end
					act_page = 1
					ref_rwy_exec = 1
				end
			end
		elseif page_arr == 1 then
			if des_app2 == "------" then
				if des_app_sel[2] ~= "------" then
					des_app2 = des_app_sel[2]
					if des_star2 == "------" then
						create_star_list()
					end
					des_app_tns2 = "------"
					act_page = 1
					des_app_exec = 1
					create_app_tns_list()
				end
			else
				if des_app_tns2 == "------" then
					if des_tns_sel[2] ~= "------" then
						des_app_tns2 = des_tns_sel[2]
						act_page = 1
						des_app_tns_exec = 1
					end
				else
					des_app_tns2 = "------"
					act_page = 1
					des_app_tns_exec = 1
				end
			end
		elseif page_dep_arr == 1 then
			-- Destination ARR
			if des_icao ~= "****" and des_icao ~= ref_icao then
				page_arr = 1
				page_dep_arr = 0
				arr_data = 0
				---
				des_app2 = des_app
				des_app_tns2 = des_app_tns
				des_star2 = des_star
				des_star_trans2 = des_star_trans
				---
				create_star_list()
				create_star_tns_list()
				create_des_app_list()
				create_app_tns_list()
			end
		elseif page_rte_init == 1 then
			-- entry FLIGHT NUMBER
			if act_page == 1 then
				if entry == ">DELETE" then
					flt_num = "--------"
					entry = ""
				else
					if string.len(entry) > 8 then
						entry = INVALID_INPUT
					else
						flt_num = entry
						simCMD_FMS_key_fpln:once()
						type_to_fmc(entry)
						simCMD_FMS_key_3R:once()
						simCMD_FMS_key_exec:once()
						entry = ""
					end
				end
			else
				local item = 0
				local button = 2	-- button 2 RSK
				local tmp_tmp = 0
				
				item = (act_page - 2) * 5 + button
				tmp_tmp = fpln_num2 + 1
				if fpln_num2 > 0 then
					if item == tmp_tmp then
						--if fpln_data2[fpln_num2][1] ~= "" then
							-- add new direct to navaid
							dir_via_add("", "", entry, "", "", item)
						--end
					elseif item <= fpln_num2 then --and fpln_num2 > 1 then
						-- add new via to navaid
						if item == 1 then
							dir_via_add("", "", entry, "", "", item)
						else
							dir_via_add(fpln_data2[item-1][1], fpln_data2[item-1][3], entry, "", fpln_data2[item][2], item)
						end
					end
				end
			end
		elseif page_legs == 1 then
			if B738DR_fms_exec_light_pilot == 0 then
				local item = 0
				local button = 2	-- button 2 RSK
				local n = 0
				local nn = 0
				local nnn = 0
				local strlen = string.len(entry)
				
				item = (act_page - 1) * 5 + offset - 1 + button
				if item > legs_num then
					entry = INVALID_INPUT
				elseif legs_data[item][1] == "DISCONTINUITY" then
					entry = INVALID_INPUT
				elseif entry == ">DELETE" then
					legs_data[item][4] = 0
					legs_data[item][5] = 0
					legs_data[item][6] = 0
					entry = ""
					msg_chk_alt_constr = 0
					vnav_update = 1
				else
					if strlen == 4 and string.sub(entry, -1, -1) == "/" then		-- speed: xxx
						n = tonumber(string.sub(entry, 1, -2))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n > 100 and n < 340 then
								legs_data[item][4] = n		-- speed
								vnav_update = 1
								msg_chk_alt_constr = 0
								entry = ""
							else
								entry = INVALID_INPUT
							end
						end
					elseif strlen > 4 and strlen < 7 and string.sub(entry, 1, 2) == "FL" then		-- alt: FLxxx or FLxxxX
						if string.sub(entry, -1, -1) == "A" then
							nn = 43
							n = tonumber(string.sub(entry, 3, -2))
						elseif string.sub(entry, -1, -1) == "B" then
							nn = 45
							n = tonumber(string.sub(entry, 3, -2))
						else
							if strlen == 7 then
								n = nil
							else
								nn = 32
								n = tonumber(string.sub(entry, 3, -1))
							end
						end
						if n == nil then
							entry = INVALID_INPUT
						else
							legs_data[item][5] = n * 100
							legs_data[item][6] = nn
							msg_chk_alt_constr = 0
							vnav_update = 1
							entry = ""
						end
					elseif strlen > 2 and  strlen < 7 then	-- alt: xxx or xxxx or xxxxx with X
						if string.sub(entry, -1, -1) == "A" then
							nn = 43
							n = tonumber(string.sub(entry, 1, -2))
						elseif string.sub(entry, -1, -1) == "B" then
							nn = 45
							n = tonumber(string.sub(entry, 1, -2))
						else
							nn = 32
							n = tonumber(string.sub(entry, 1, -1))
						end
						if n == nil then
							entry = INVALID_INPUT
						else
							legs_data[item][5] = n
							legs_data[item][6] = nn
							msg_chk_alt_constr = 0
							vnav_update = 1
							entry = ""
						end
					elseif strlen > 6 and  strlen < 11 and string.sub(entry, 4, 4) == "/" then		-- alt: xxx/FLxxx or xxx/FLxxxX
						-- speed
						n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n > 100 and n < 340 then
								if string.sub(entry, 5, 6) == "FL" then
									if string.sub(entry, -1, -1) == "A" then
										nn = 43
										nnn = tonumber(string.sub(entry, 7, -2))
									elseif string.sub(entry, -1, -1) == "B" then
										nn = 45
										nnn = tonumber(string.sub(entry, 7, -2))
									else
										nn = 32
										nnn = tonumber(string.sub(entry, 7, -1))
									end
								else
									if string.sub(entry, -1, -1) == "A" then
										nn = 43
										nnn = tonumber(string.sub(entry, 5, -2))
									elseif string.sub(entry, -1, -1) == "B" then
										nn = 45
										nnn = tonumber(string.sub(entry, 5, -2))
									else
										nn = 32
										nnn = tonumber(string.sub(entry, 5, -1))
									end
								end
								if nnn == nil then
									entry = INVALID_INPUT
								else
									if string.sub(entry, 5, 6) == "FL" then
										nnn = nnn * 100
									end
									legs_data[item][4] = n
									legs_data[item][5] = nnn
									legs_data[item][6] = nn
									msg_chk_alt_constr = 0
									vnav_update = 1
									entry = ""
								end
							else
								entry = INVALID_INPUT
							end
						end
						
					end
				end
			end
		elseif page_takeoff == 1 then
			-- entry VR
			if entry == "" then
				if vr ~= "---" and qrh == "OFF" then
					vr_set = vr
				end
			else
				-- from scratch (test speed correct)
				if entry == ">DELETE" then
					vr_set = "---"
					entry = ""
				else
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if n > 99 and n < 170 then
							vr_set = entry
							entry = ""
						else
							entry = INVALID_INPUT
						end
					end
				end
			end
			display_update = 1
		elseif page_approach == 1 then
			-- select flaps 30
			if vref_30 == "---" then
				entry = ""
			else
				if flaps_app == "30" then
					app_flap = "30"
					app_spd = vref_30
					flaps_app = "  "
				else
					flaps_app = "30"
				end
			end
		elseif page_n1_limit == 1 then
			-- select CLB
			clb = "<SEL>"
			clb_1 = "     "
			clb_2 = "     "
			sel_clb_thr = 1
		elseif page_descent_forecast == 1 then
			-- entry ISA DEV / QNH
			local strlen = string.len(entry)
			local n = tonumber(entry)
			local n_str = ""
			if strlen > 0 then
				if entry == ">DELETE" then
					forec_isa_dev = "---"
					forec_qnh = "------"
					entry = ""
				else
					if strlen == 5 then		-- QNH /XXXX
						if string.sub(entry, 1, 1) == "/" then
							n = tonumber(string.sub(entry, 2, 5))
							if n == nil then
								entry = INVALID_INPUT
							else
								if n < 0 or n > 1355 then
									entry = INVALID_INPUT
								else
									forec_qnh = "  " .. string.sub(entry, 2, 5)
									entry = ""
									-- set preselect baro hpa -> in hg
									n = 0.02952998751 * n * 100
									n = math.floor(n + 0.5) / 100
									if B738DR_baro_set_std_pilot == 1 then
										B738DR_baro_sel_in_hg_pilot = n
									end
									if B738DR_baro_set_std_copilot == 1 then
										B738DR_baro_sel_in_hg_copilot = n
									end
								end
							end
						else
							entry = INVALID_INPUT
						end
					elseif strlen == 6 then		-- QNH /XX.XX in hg
						if string.sub(entry, 1, 1) == "/" and string.sub(entry, 4, 4) == "." then
							n = tonumber(string.sub(entry, 2, 6))
							if n == nil then
								entry = INVALID_INPUT
							else
								if n < 0 or n > 40.0 then
									entry = INVALID_INPUT
								else
									forec_qnh = " " .. string.sub(entry, 2, 6)
									entry = ""
									-- set preselect baro in hg
									if B738DR_baro_set_std_pilot == 1 then
										B738DR_baro_sel_in_hg_pilot = n
									end
									if B738DR_baro_set_std_copilot == 1 then
										B738DR_baro_sel_in_hg_copilot = n
									end
								end
							end
						else
							entry = INVALID_INPUT
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_menu == 1 then
			-- select Units
			if units == 0 then
				units = 1
			else
				units = 0
			end
			units_recalc = 1
		elseif page_perf == 1 then
			-- entry CRZ WIND
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					crz_wind_dir = "---"
					crz_wind_spd = "---"
					entry = ""
				else
					if strlen > 4 and strlen < 8 and string.sub(entry, 4, 4) == "/" then
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n < 0 or n > 359 then		-- wind heading 0 - 359
								entry = INVALID_INPUT
							else
								local wind_dir = string.format("%03d", n)
								n = tonumber(string.sub(entry, 5, strlen))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < 1 or n > 199 then	-- wind speed 1 - 199
										entry = INVALID_INPUT
									else
										crz_wind_dir = wind_dir
										crz_wind_spd = string.format("%3d", n)
										entry = ""
									end
								end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_perf == 2 then
			-- CLB max speed kts/mach
			local strlen = string.len(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					clb_max_kts = "   "
					clb_max_mach = "   "
					entry = ""
				else
					if strlen > 2 and  strlen < 6 and string.sub(entry, 1, 2) == "/." then		-- only mach
						local n = tonumber(string.sub(entry, 2, strlen))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(clb_min_mach)
							if nn == nil then
								nn = 0.4
							else
								nn = nn / 1000
							end
							if n > 0.82 or n < nn then
								entry = INVALID_INPUT
							else
								n = n * 1000
								clb_max_mach = string.format("%03d", n)
								-- simCMD_FMS_key_clb:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- entry = "/." .. clb_max_mach
								-- type_to_fmc(entry)
								-- simCMD_FMS_key_1L:once()
								entry = ""
							end
						end
					elseif strlen == 3 then			-- only kts
						local n = tonumber(entry)
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(clb_min_kts)
							if nn == nil then
								nn = 100
							end
							if n > 340  or n < nn then
								entry = INVALID_INPUT
							else
								clb_max_kts = string.format("%03d", n)
								-- simCMD_FMS_key_clb:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- entry = clb_max_kts
								-- type_to_fmc(entry)
								-- simCMD_FMS_key_1L:once()
								entry = ""
							end
						end
					elseif strlen > 5 and strlen < 9 and string.sub(entry, 4, 5) == "/." then 	-- kts and mach
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(clb_min_kts)
							if nn == nil then
								nn = 100
							end
							if n > 340 or n < nn then
								entry = INVALID_INPUT
							else
								local kts = string.format("%03d", n)
									n = tonumber(string.sub(entry, 5, strlen))
									if n == nil then
										entry = INVALID_INPUT
									else
										nn = tonumber(clb_min_mach)
										if nn == nil then
											nn = 0.4
										else
											nn = nn / 1000
										end
										if n > 0.82 or n < nn then
											entry = INVALID_INPUT
										else
											n = n * 1000
											clb_max_kts = kts
											clb_max_mach = string.format("%03d", n)
											-- simCMD_FMS_key_clb:once()
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_clear:once()
											-- simCMD_FMS_key_clear:once()
											-- entry = clb_max_kts
											-- type_to_fmc(entry)
											-- simCMD_FMS_key_1L:once()
											-- entry = "/." .. clb_max_mach
											-- type_to_fmc(entry)
											-- simCMD_FMS_key_1L:once()
											entry = ""
										end
									end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		----
		elseif page_pos_init == 1 then
			if ref_icao_pos ~= "               " then
				entry = ref_icao_pos
			end
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 3RSK
function B738_fmc1_3R_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_3R:once()
			entry = ""
		else
		
		if page_dep == 1 then
			if ref_rwy2 == "-----" then
				if ref_rwy_sel[3] ~= "-----" then
					ref_rwy2 = ref_rwy_sel[3]
					if ref_sid2 == "------" then
						create_sid_list()
					end
					act_page = 1
					ref_rwy_exec = 1
				end
			end
		elseif page_menu == 1 then
			-- go to XTRAS menu
			page_menu = 0
			page_xtras = 1
			act_page = 1
		-- elseif page_arr == 1 then
			-- local prev_repeat = 40
-- --			if des_star ~= "------" then
				-- if des_app == "------" then
					-- if des_app_sel[3] ~= "------" then
						-- des_app = des_app_sel[3]
						-- simCMD_FMS_key_3R:once()
						-- ref_rwy_exec = 1
						-- while prev_repeat > 1 do
							-- prev_repeat = prev_repeat - 1
							-- simCMD_FMS_key_prev:once()
						-- end
						-- act_page = 1
					-- end
				-- else
					-- if des_app_tns == "------" then
						-- if des_tns_sel[3] ~= "------" then
							-- des_app_tns = des_tns_sel[3]
							-- simCMD_FMS_key_3R:once()
							-- ref_app_tns_exec = 1
							-- while prev_repeat > 1 do
								-- prev_repeat = prev_repeat - 1
								-- simCMD_FMS_key_prev:once()
							-- end
							-- act_page = 1
						-- end
						-- if des_num_app_tns == 0 then
							-- if simDR_glideslope_status == 0 then
								-- if B738DR_fms_ils_disable == 0 then
									-- B738DR_fms_ils_disable = 1
								-- else
									-- B738DR_fms_ils_disable = 0
								-- end
							-- end
						-- end
					-- else
						-- if simDR_glideslope_status == 0 then
							-- if B738DR_fms_ils_disable == 0 then
								-- B738DR_fms_ils_disable = 1
							-- else
								-- B738DR_fms_ils_disable = 0
							-- end
						-- end
					-- end
				-- end
-- --			end
		elseif page_arr == 1 then
			if des_app2 == "------" then
				if des_app_sel[3] ~= "------" then
					des_app2 = des_app_sel[3]
					if des_star2 == "------" then
						create_star_list()
					end
					act_page = 1
					des_app_exec = 1
					create_app_tns_list()
				end
			else
				if des_app_tns2 == "------" then
					if des_tns_sel[3] ~= "------" then
						des_app_tns2 = des_tns_sel[3]
						act_page = 1
						des_app_tns_exec = 1
					end
					if des_app_tns_list_num == 0 then
						if simDR_glideslope_status == 0 then
							if B738DR_fms_ils_disable == 0 then
								B738DR_fms_ils_disable = 1
							else
								B738DR_fms_ils_disable = 0
							end
						end
					end
				else
					if simDR_glideslope_status == 0 then
						if B738DR_fms_ils_disable == 0 then
							B738DR_fms_ils_disable = 1
						else
							B738DR_fms_ils_disable = 0
						end
					end
				end
			end
		elseif page_rte_init == 1 then
			if act_page == 1 then
				--save route
				if string.len(entry) == 0 or string.len(entry) > 12 then
					entry = INVALID_INPUT
				else
					save_fpln()
					co_route = entry
					entry = ""
				end
			else
				local item = 0
				local button = 3	-- button 3 RSK
				local tmp_tmp = 0
				
				item = (act_page - 2) * 5 + button
				tmp_tmp = fpln_num2 + 1
				if fpln_num2 > 0 then
					if item == tmp_tmp then
						--if fpln_data2[fpln_num2][1] ~= "" then
							-- add new direct to navaid
							dir_via_add("", "", entry, "", "", item)
						--end
					elseif item <= fpln_num2 then --and fpln_num2 > 1 then
						if item == 1 then
							dir_via_add("", "", entry, "", "", item)
						else
							dir_via_add(fpln_data2[item-1][1], fpln_data2[item-1][3], entry, "", fpln_data2[item][2], item)
						end
					end
				end
			end
		elseif page_legs == 1 then
			if B738DR_fms_exec_light_pilot == 0 then
				local item = 0
				local button = 3	-- button 3 RSK
				local n = 0
				local nn = 0
				local nnn = 0
				local strlen = string.len(entry)
				
				item = (act_page - 1) * 5 + offset - 1 + button
				if item > legs_num then
					entry = INVALID_INPUT
				elseif legs_data[item][1] == "DISCONTINUITY" then
					entry = INVALID_INPUT
				elseif entry == ">DELETE" then
					legs_data[item][4] = 0
					legs_data[item][5] = 0
					legs_data[item][6] = 0
					entry = ""
					msg_chk_alt_constr = 0
					vnav_update = 1
				else
					if strlen == 4 and string.sub(entry, -1, -1) == "/" then		-- speed: xxx
						n = tonumber(string.sub(entry, 1, -2))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n > 100 and n < 340 then
								legs_data[item][4] = n		-- speed
								vnav_update = 1
								msg_chk_alt_constr = 0
								entry = ""
							else
								entry = INVALID_INPUT
							end
						end
					elseif strlen > 4 and strlen < 7 and string.sub(entry, 1, 2) == "FL" then		-- alt: FLxxx or FLxxxX
						if string.sub(entry, -1, -1) == "A" then
							nn = 43
							n = tonumber(string.sub(entry, 3, -2))
						elseif string.sub(entry, -1, -1) == "B" then
							nn = 45
							n = tonumber(string.sub(entry, 3, -2))
						else
							if strlen == 7 then
								n = nil
							else
								nn = 32
								n = tonumber(string.sub(entry, 3, -1))
							end
						end
						if n == nil then
							entry = INVALID_INPUT
						else
							legs_data[item][5] = n * 100
							legs_data[item][6] = nn
							msg_chk_alt_constr = 0
							vnav_update = 1
							entry = ""
						end
					elseif strlen > 2 and  strlen < 7 then	-- alt: xxx or xxxx or xxxxx with X
						if string.sub(entry, -1, -1) == "A" then
							nn = 43
							n = tonumber(string.sub(entry, 1, -2))
						elseif string.sub(entry, -1, -1) == "B" then
							nn = 45
							n = tonumber(string.sub(entry, 1, -2))
						else
							nn = 32
							n = tonumber(string.sub(entry, 1, -1))
						end
						if n == nil then
							entry = INVALID_INPUT
						else
							legs_data[item][5] = n
							legs_data[item][6] = nn
							msg_chk_alt_constr = 0
							vnav_update = 1
							entry = ""
						end
					elseif strlen > 6 and  strlen < 11 and string.sub(entry, 4, 4) == "/" then		-- alt: xxx/FLxxx or xxx/FLxxxX
						-- speed
						n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n > 100 and n < 340 then
								if string.sub(entry, 5, 6) == "FL" then
									if string.sub(entry, -1, -1) == "A" then
										nn = 43
										nnn = tonumber(string.sub(entry, 7, -2))
									elseif string.sub(entry, -1, -1) == "B" then
										nn = 45
										nnn = tonumber(string.sub(entry, 7, -2))
									else
										nn = 32
										nnn = tonumber(string.sub(entry, 7, -1))
									end
								else
									if string.sub(entry, -1, -1) == "A" then
										nn = 43
										nnn = tonumber(string.sub(entry, 5, -2))
									elseif string.sub(entry, -1, -1) == "B" then
										nn = 45
										nnn = tonumber(string.sub(entry, 5, -2))
									else
										nn = 32
										nnn = tonumber(string.sub(entry, 5, -1))
									end
								end
								if nnn == nil then
									entry = INVALID_INPUT
								else
									if string.sub(entry, 5, 6) == "FL" then
										nnn = nnn * 100
									end
									legs_data[item][4] = n
									legs_data[item][5] = nnn
									legs_data[item][6] = nn
									msg_chk_alt_constr = 0
									vnav_update = 1
									entry = ""
								end
							else
								entry = INVALID_INPUT
							end
						end
						
					end
				end
			end
		elseif page_takeoff == 1 then
			-- entry V2
			if entry == "" then
				if v2 ~= "---" and qrh == "OFF" then
					v2_set = v2
				end
			else
				-- from scratch (test speed correct)
				if entry == ">DELETE" then
					v2_set = "---"
					entry = ""
				else
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if n > 99 and n < 170 then
							v2_set = entry
							entry = ""
						else
							entry = INVALID_INPUT
						end
					end
				end
			end
			display_update = 1
		elseif page_approach == 1 then
			-- select flaps 40
			if vref_40 == "---" then
				entry = ""
			else
				if flaps_app == "40" then
					app_flap = "40"
					app_spd = vref_40
					flaps_app = "  "
				else
					flaps_app = "40"
				end
			end
		elseif page_n1_limit == 1 then
			-- select CLB-1
			clb_1 = "<SEL>"
			clb = "     "
			clb_2 = "     "
			sel_clb_thr = 1
		elseif page_takeoff == 2 then
			-- enter ACCELERATION HEIGHT AGL
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					accel_alt = "----"
					accel_alt_num = 1000
					entry = ""
				elseif strlen > 2 and strlen < 5 then
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 400 or n > 9999 then	-- ACCEL HT AGL min and max
							entry = INVALID_INPUT
						else
							accel_alt = string.format("%4d", n)
							entry = ""
							accel_alt_num = n
						end
					end
				else
					entry = INVALID_INPUT
				end
			else
				entry = INVALID_INPUT
			end
		elseif page_descent_forecast == 1 then
			-- entry WIND LAYER 1
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					forec_dir_1 = "---"
					forec_spd_1 = "---"
					entry = ""
				else
					if strlen > 4 and strlen < 8 and string.sub(entry, 4, 4) == "/" then
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n < 0 or n > 359 then		-- wind heading 0 - 359
								entry = INVALID_INPUT
							else
								local wind_dir = string.format("%03d", n)
								n = tonumber(string.sub(entry, 5, strlen))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < 1 or n > 199 then	-- wind speed 1 - 199
										entry = INVALID_INPUT
									else
										forec_dir_1 = wind_dir
										forec_spd_1 = string.format("%03d", n)
										entry = ""
									end
								end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_perf == 1 and disable_PERF_3R == 0 then
			-- entry ISA DEV
			local strlen = string.len(entry)
			local alt_temp = crz_alt_num
			local n = 0
			local n_str = ""
			if strlen > 0 then
				if entry == ">DELETE" then
					isa_dev_f = "---"
					isa_dev_c = "---"
					entry = ""
				else
					--if strlen > 0 and strlen < 5 then
					if strlen < 5 then
						n = tonumber(entry)
						if n == nil and strlen > 1 then
							n = tonumber(string.sub(entry, 1, strlen-1))
							if n == nil then
								entry = INVALID_INPUT
							else
								n_str = string.sub(entry, strlen, strlen)
								if n_str == "C" then 
									if n < -20 or n > 70 then	-- ISA DEV Celsius min and max
										entry = INVALID_INPUT
									else
										isa_dev_c = string.format("%3d", n)
										n = (n * 9 / 5) + 32
										isa_dev_f = string.format("%3d", n)
										-- calc TC OAT
										n = tonumber(isa_dev_c)
										alt_temp = math.min(alt_temp, 37000)
										tc_oat_c = string.format("%3d", (B738_rescale(0, 15, 37000, -56.5, alt_temp) + n))
										n = tonumber(tc_oat_c)
										n = (n * 9 / 5) + 32
										tc_oat_f = string.format("%3d", n)
										entry = ""
									end
								elseif n_str == "F" then
									if n < -4 or n > 158 then	-- ISA DEV Fahrenheit min and max
										entry = INVALID_INPUT
									else
										isa_dev_f = string.format("%3d", n)
										n = (n - 32) * 5 / 9
										isa_dev_c = string.format("%3d", n)
										-- calc TC OAT
										n = tonumber(isa_dev_c)
										alt_temp = math.min(alt_temp, 37000)
										tc_oat_c = string.format("%3d", (B738_rescale(0, 15, 37000, -56.5, alt_temp) + n))
										n = tonumber(tc_oat_c)
										n = (n * 9 / 5) + 32
										tc_oat_f = string.format("%3d", n)
										entry = ""
									end
								else
									entry = INVALID_INPUT
								end
							end
						else
							if n == nil then
								entry = INVALID_INPUT
							else
								if B738DR_fmc_units == 0 then
									if n < -4 or n > 158 then	-- ISA DEV Fahrenheit min and max
										entry = INVALID_INPUT
									else
										isa_dev_f = string.format("%3d", n)
										n = (n - 32) * 5 / 9
										isa_dev_c = string.format("%3d", n)
										-- calc TC OAT
										n = tonumber(isa_dev_c)
										alt_temp = math.min(alt_temp, 37000)
										tc_oat_c = string.format("%3d", (B738_rescale(0, 15, 37000, -56.5, alt_temp) + n))
										n = tonumber(tc_oat_c)
										n = (n * 9 / 5) + 32
										tc_oat_f = string.format("%3d", n)
										entry = ""
									end
								else
									if n < -20 or n > 70 then	-- ISA DEV Celsius min and max
										entry = INVALID_INPUT
									else
										isa_dev_c = string.format("%3d", n)
										n = (n * 9 / 5) + 32
										isa_dev_f = string.format("%3d", n)
										-- calc TC OAT
										n = tonumber(isa_dev_c)
										alt_temp = math.min(alt_temp, 37000)
										tc_oat_c = string.format("%3d", (B738_rescale(0, 15, 37000, -56.5, alt_temp) + n))
										n = tonumber(tc_oat_c)
										n = (n * 9 / 5) + 32
										tc_oat_f = string.format("%3d", n)
										entry = ""
									end
								end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_perf == 2 then
			-- CRZ max speed kts/mach
			local strlen = string.len(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					crz_max_kts = "   "
					crz_max_mach = "   "
					entry = ""
				else
					if strlen > 2 and  strlen < 6 and string.sub(entry, 1, 2) == "/." then		-- only mach
						local n = tonumber(string.sub(entry, 2, strlen))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(crz_min_mach)
							if nn == nil then
								nn = 0.4
							else
								nn = nn / 1000
							end
							if n > 0.82 or n < nn then
								entry = INVALID_INPUT
							else
								n = n * 1000
								crz_max_mach = string.format("%03d", n)
								-- simCMD_FMS_key_crz:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- entry = "/." .. crz_max_mach
								-- type_to_fmc(entry)
								-- simCMD_FMS_key_1L:once()
								entry = ""
							end
						end
					elseif strlen == 3 then			-- only kts
						local n = tonumber(entry)
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(crz_min_kts)
							if nn == nil then
								nn = 100
							end
							if n > 340  or n < nn then
								entry = INVALID_INPUT
							else
								crz_max_kts = string.format("%03d", n)
								-- simCMD_FMS_key_crz:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- entry = crz_max_kts
								-- type_to_fmc(entry)
								-- simCMD_FMS_key_1L:once()
								entry = ""
							end
						end
					elseif strlen > 5 and strlen < 9 and string.sub(entry, 4, 5) == "/." then 	-- kts and mach
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(crz_min_kts)
							if nn == nil then
								nn = 100
							end
							if n > 340 or n < nn then
								entry = INVALID_INPUT
							else
								local kts = string.format("%03d", n)
									n = tonumber(string.sub(entry, 5, strlen))
									if n == nil then
										entry = INVALID_INPUT
									else
										nn = tonumber(crz_min_mach)
										if nn == nil then
											nn = 0.4
										else
											nn = nn / 1000
										end
										if n > 0.82 or n < nn then
											entry = INVALID_INPUT
										else
											n = n * 1000
											crz_max_kts = kts
											-- crz_max_mach = string.format("%03d", n)
											-- simCMD_FMS_key_crz:once()
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_clear:once()
											-- simCMD_FMS_key_clear:once()
											-- entry = crz_max_kts
											-- type_to_fmc(entry)
											-- simCMD_FMS_key_1L:once()
											-- simCMD_FMS_key_crz:once()
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_clear:once()
											-- simCMD_FMS_key_clear:once()
											-- entry = "/." .. crz_max_mach
											-- type_to_fmc(entry)
											-- simCMD_FMS_key_1L:once()
											entry = ""
										end
									end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		----------
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 4RSK
function B738_fmc1_4R_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_4R:once()
			entry = ""
		else
		
		-- if page_dep == 1 then
			-- local prev_repeat = 40
			-- if ref_rwy == "-----" then
				-- if ref_rwy_sel[4] ~= "-----" then
					-- ref_rwy = ref_rwy_sel[4]
					-- simCMD_FMS_key_4R:once()
					-- while prev_repeat > 1 do
						-- prev_repeat = prev_repeat - 1
						-- simCMD_FMS_key_prev:once()
					-- end
					-- ref_rwy_exec = 1
					-- act_page = 1
				-- end
				-- create_sid_list()
			-- end
		if page_dep == 1 then
			if ref_rwy2 == "-----" then
				if ref_rwy_sel[4] ~= "-----" then
					ref_rwy2 = ref_rwy_sel[4]
					if ref_sid2 == "------" then
						create_sid_list()
					end
					act_page = 1
					ref_rwy_exec = 1
				end
			end
		-- elseif page_arr == 1 then
			-- local prev_repeat = 40
-- --			if des_star ~= "------" then
				-- if des_app == "------" then
					-- if des_app_sel[4] ~= "------" then
						-- des_app = des_app_sel[4]
						-- simCMD_FMS_key_4R:once()
						-- ref_rwy_exec = 1
						-- while prev_repeat > 1 do
							-- prev_repeat = prev_repeat - 1
							-- simCMD_FMS_key_prev:once()
						-- end
						-- act_page = 1
					-- end
				-- else
					-- if des_app_tns == "------" then
						-- if des_tns_sel[4] ~= "------" then
							-- des_app_tns = des_tns_sel[4]
							-- simCMD_FMS_key_4R:once()
							-- ref_app_tns_exec = 1
							-- while prev_repeat > 1 do
								-- prev_repeat = prev_repeat - 1
								-- simCMD_FMS_key_prev:once()
							-- end
							-- act_page = 1
						-- end
					-- end
				-- end
-- --			end
		elseif page_arr == 1 then
			if des_app2 == "------" then
				if des_app_sel[4] ~= "------" then
					des_app2 = des_app_sel[4]
					if des_star2 == "------" then
						create_star_list()
					end
					act_page = 1
					des_app_exec = 1
					create_app_tns_list()
				end
			else
				if des_app_tns2 == "------" then
					if des_tns_sel[4] ~= "------" then
						des_app_tns2 = des_tns_sel[4]
						act_page = 1
						des_app_tns_exec = 1
					end
				end
			end
		elseif page_rte_init == 1 then
			if act_page > 1 then
				local item = 0
				local button = 4	-- button 4 RSK
				local tmp_tmp = 0
				
				item = (act_page - 2) * 5 + button
				tmp_tmp = fpln_num2 + 1
				if fpln_num2 > 0 then
					if item == tmp_tmp then
						--if fpln_data2[fpln_num2][1] ~= "" then
							-- add new direct to navaid
							dir_via_add("", "", entry, "", "", item)
						--end
					elseif item <= fpln_num2 then --and fpln_num2 > 1 then
						if item == 1 then
							dir_via_add("", "", entry, "", "", item)
						else
							dir_via_add(fpln_data2[item-1][1], fpln_data2[item-1][3], entry, "", fpln_data2[item][2], item)
						end
					end
				end
			end
		elseif page_legs == 1 then
			if B738DR_fms_exec_light_pilot == 0 then
				local item = 0
				local button = 4	-- button 4 RSK
				local n = 0
				local nn = 0
				local nnn = 0
				local strlen = string.len(entry)
				
				item = (act_page - 1) * 5 + offset - 1 + button
				if item > legs_num then
					entry = INVALID_INPUT
				elseif legs_data[item][1] == "DISCONTINUITY" then
					entry = INVALID_INPUT
				elseif entry == ">DELETE" then
					legs_data[item][4] = 0
					legs_data[item][5] = 0
					legs_data[item][6] = 0
					entry = ""
					msg_chk_alt_constr = 0
					vnav_update = 1
				else
					if strlen == 4 and string.sub(entry, -1, -1) == "/" then		-- speed: xxx
						n = tonumber(string.sub(entry, 1, -2))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n > 100 and n < 340 then
								legs_data[item][4] = n		-- speed
								vnav_update = 1
								msg_chk_alt_constr = 0
								entry = ""
							else
								entry = INVALID_INPUT
							end
						end
					elseif strlen > 4 and strlen < 7 and string.sub(entry, 1, 2) == "FL" then		-- alt: FLxxx or FLxxxX
						if string.sub(entry, -1, -1) == "A" then
							nn = 43
							n = tonumber(string.sub(entry, 3, -2))
						elseif string.sub(entry, -1, -1) == "B" then
							nn = 45
							n = tonumber(string.sub(entry, 3, -2))
						else
							if strlen == 7 then
								n = nil
							else
								nn = 32
								n = tonumber(string.sub(entry, 3, -1))
							end
						end
						if n == nil then
							entry = INVALID_INPUT
						else
							legs_data[item][5] = n * 100
							legs_data[item][6] = nn
							msg_chk_alt_constr = 0
							vnav_update = 1
							entry = ""
						end
					elseif strlen > 2 and  strlen < 7 then	-- alt: xxx or xxxx or xxxxx with X
						if string.sub(entry, -1, -1) == "A" then
							nn = 43
							n = tonumber(string.sub(entry, 1, -2))
						elseif string.sub(entry, -1, -1) == "B" then
							nn = 45
							n = tonumber(string.sub(entry, 1, -2))
						else
							nn = 32
							n = tonumber(string.sub(entry, 1, -1))
						end
						if n == nil then
							entry = INVALID_INPUT
						else
							legs_data[item][5] = n
							legs_data[item][6] = nn
							msg_chk_alt_constr = 0
							vnav_update = 1
							entry = ""
						end
					elseif strlen > 6 and  strlen < 11 and string.sub(entry, 4, 4) == "/" then		-- alt: xxx/FLxxx or xxx/FLxxxX
						-- speed
						n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n > 100 and n < 340 then
								if string.sub(entry, 5, 6) == "FL" then
									if string.sub(entry, -1, -1) == "A" then
										nn = 43
										nnn = tonumber(string.sub(entry, 7, -2))
									elseif string.sub(entry, -1, -1) == "B" then
										nn = 45
										nnn = tonumber(string.sub(entry, 7, -2))
									else
										nn = 32
										nnn = tonumber(string.sub(entry, 7, -1))
									end
								else
									if string.sub(entry, -1, -1) == "A" then
										nn = 43
										nnn = tonumber(string.sub(entry, 5, -2))
									elseif string.sub(entry, -1, -1) == "B" then
										nn = 45
										nnn = tonumber(string.sub(entry, 5, -2))
									else
										nn = 32
										nnn = tonumber(string.sub(entry, 5, -1))
									end
								end
								if nnn == nil then
									entry = INVALID_INPUT
								else
									if string.sub(entry, 5, 6) == "FL" then
										nnn = nnn * 100
									end
									legs_data[item][4] = n
									legs_data[item][5] = nnn
									legs_data[item][6] = nn
									msg_chk_alt_constr = 0
									vnav_update = 1
									entry = ""
								end
							else
								entry = INVALID_INPUT
							end
						end
						
					end
				end
			end
		elseif page_pos_init == 1 and disable_POS_4R == 0 then
			-- set IRS POS
			if entry == ">DELETE" then
--				B738DR_irs_pos_set = "*****.*******.*"
				irs_pos = "*****.*******.*"
				entry = ""
--				if B738DR_irs_left == 2 then
--					B738DR_irs_pos_fmc_set = irs_pos
--				end
--				if B738DR_irs_right == 2 then
--					B738DR_irs2_pos_fmc_set = irs_pos
--				end
			else
				if string.len(entry) > 0 then
					local err_pos = 0
					local n = 0
					if string.len(entry) ~= 15
					or string.sub(entry, 6, 6) ~= "."
					or  string.sub(entry, 14, 14) ~= "." then
						err_pos = 1
					end
					n = tonumber(string.sub(entry, 2, 3))
					if (n == nil) or (n < 0) or (n > 90) then
						err_pos = 1
					end
					n = tonumber(string.sub(entry, 4, 5))
					if (n == nil) or (n < 0) or (n > 59) then
						err_pos = 1
					end
					n = tonumber(string.sub(entry, 9, 11))
					if (n == nil) or (n < 0) or (n > 180) then
						err_pos = 1
					end
					n = tonumber(string.sub(entry, 12, 13))
					if (n == nil) or (n < 0) or (n > 59) then
						err_pos = 1
					end
					if string.sub(entry, 1, 1) ~= "N" 
					and string.sub(entry, 1, 1) ~= "S" then
						err_pos = 1
					end
					if string.sub(entry, 8, 8) ~= "E" 
					and string.sub(entry, 8, 8) ~= "W" then
						err_pos = 1
					end
					if err_pos == 0 then
						irs_pos = entry
--						B738DR_irs_pos_set = entry
						entry = ""
--						B738DR_irs_pos_fmc = 1
--						if B738DR_irs_left == 2 then
--							B738DR_irs_pos_fmc_set = irs_pos
--						end
--						if B738DR_irs_right == 2 then
--							B738DR_irs2_pos_fmc_set = irs_pos
--						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_n1_limit == 1 then
			-- select CLB-2
			clb_2 = "<SEL>"
			clb = "     "
			clb_1 = "     "
			sel_clb_thr = 1
		elseif page_descent_forecast == 1 then
			-- entry WIND LAYER 2
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					forec_dir_2 = "---"
					forec_spd_2 = "---"
					entry = ""
				else
					if strlen > 4 and strlen < 8 and string.sub(entry, 4, 4) == "/" then
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n < 0 or n > 359 then		-- wind heading 0 - 359
								entry = INVALID_INPUT
							else
								local wind_dir = string.format("%03d", n)
								n = tonumber(string.sub(entry, 5, strlen))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < 1 or n > 199 then	-- wind speed 1 - 199
										entry = INVALID_INPUT
									else
										forec_dir_2 = wind_dir
										forec_spd_2 = string.format("%03d", n)
										entry = ""
									end
								end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_approach == 1 then
			-- FLAP / SPD
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					app_flap = "--"
					app_spd = "---"
					entry = ""
				elseif strlen == 3 then
					if string.sub(entry, 3, 3) == "/" then
						local flp = string.sub(entry, 1, 2)
						if flp == "15" or flp == "30" or flp == "40" then
							app_flap = flp
							entry = ""
						else
							entry = INVALID_INPUT
						end
					else
						local n = tonumber(entry)
						if n == nil then
							entry = INVALID_INPUT
						else
							if vref_15 ~= "---" and vref_40 ~= "---" then
								local flp_max = tonumber(vref_15)
								local flp_min = tonumber(vref_40)
								if n > flp_max or n < flp_min then	-- SPEED min and max
									entry = INVALID_INPUT
								else
									app_spd = string.format("%3d", n)
									entry = ""
								end
							end
						end
					end
				elseif strlen == 4 then
					if string.sub(entry, 1, 1) == "/" then
						local n = tonumber(string.sub(entry, 2, 4))
						if n == nil then
							entry = INVALID_INPUT
						else
							if vref_15 ~= "---" and vref_40 ~= "---" then
								local flp_max = tonumber(vref_15)
								local flp_min = tonumber(vref_40)
								if n > flp_max or n < flp_min then	-- SPEED min and max
									entry = INVALID_INPUT
								else
									app_spd = string.format("%3d", n)
									entry = ""
								end
							end
						end
					else
						entry = INVALID_INPUT
					end
				elseif strlen == 6 then
					if string.sub(entry, 3, 3) == "/" then
						local flp = string.sub(entry, 1, 2)
						if flp == "15" or flp == "30" or flp == "40" then
							local n = tonumber(string.sub(entry, 4, 6))
							if n == nil then
								entry = INVALID_INPUT
							else
								if vref_15 ~= "---" and vref_40 ~= "---" then
									local flp_max = tonumber(vref_15)
									local flp_min = tonumber(vref_40)
									if n > flp_max or n < flp_min then	-- SPEED min and max
										entry = INVALID_INPUT
									else
										app_flap = flp
										app_spd = string.format("%3d", n)
										entry = ""
									end
								end
							end
						else
							entry = INVALID_INPUT
						end
					else
						entry = INVALID_INPUT
					end
				else
					entry = INVALID_INPUT
				end
			end
		elseif page_perf == 1 and disable_PERF_4R == 0 then
			-- entry T/C OAT
			local strlen = string.len(entry)
			local alt_temp = crz_alt_num
			local n = 0
			local n_str = ""
			if strlen > 0 then
				if entry == ">DELETE" then
					tc_oat_f = "---"
					tc_oat_c = "---"
					entry = ""
				else
					--if strlen > 1 and strlen < 5 then
					if strlen < 5 then
						n = tonumber(entry)
						if n == nil and strlen > 1 then
							n = tonumber(string.sub(entry, 1, strlen-1))
							if n == nil then
								entry = INVALID_INPUT
							else
								n = tonumber(string.sub(entry, 1, strlen-1))
								if n == nil then
									entry = INVALID_INPUT
								else
									n_str = string.sub(entry, strlen, strlen)
									if n_str == "C" then 
										if n < -70 or n > 70 then	-- T/C OAT Celsius min and max
											entry = INVALID_INPUT
										else
											tc_oat_c = string.format("%3d", n)
											n = (n * 9 / 5) + 32
											tc_oat_f = string.format("%3d", n)
											-- calc ISA DEV
											n = tonumber(tc_oat_c)
											alt_temp = math.min(alt_temp, 37000)
											isa_dev_c = string.format("%3d", (n - B738_rescale(0, 15, 37000, -56.5, alt_temp)))
											n = tonumber(isa_dev_c)
											n = (n * 9 / 5) + 32
											isa_dev_f = string.format("%3d", n)
											entry = ""
										end
									elseif n_str == "F" then
										if n < -94 or n > 158 then	-- T/C OAT Fahrenheit min and max
											entry = INVALID_INPUT
										else
											tc_oat_f = string.format("%3d", n)
											n = (n - 32) * 5 / 9
											tc_oat_c = string.format("%3d", n)
											-- calc ISA DEV
											n = tonumber(tc_oat_c)
											alt_temp = math.min(alt_temp, 37000)
											isa_dev_c = string.format("%3d", (n - B738_rescale(0, 15, 37000, -56.5, alt_temp)))
											n = tonumber(isa_dev_c)
											n = (n * 9 / 5) + 32
											isa_dev_f = string.format("%3d", n)
											entry = ""
										end
									else
										entry = INVALID_INPUT
									end
								end
							end
						else
							if n == nil then
								entry = INVALID_INPUT
							else
								if B738DR_fmc_units == 0 then
									if n < -94 or n > 158 then	-- T/C OAT Fahrenheit min and max
										entry = INVALID_INPUT
									else
										tc_oat_f = string.format("%3d", n)
										n = (n - 32) * 5 / 9
										tc_oat_c = string.format("%3d", n)
										-- calc ISA DEV
										n = tonumber(tc_oat_c)
										alt_temp = math.min(alt_temp, 37000)
										isa_dev_c = string.format("%3d", (n - B738_rescale(0, 15, 37000, -56.5, alt_temp)))
										n = tonumber(isa_dev_c)
										n = (n * 9 / 5) + 32
										isa_dev_f = string.format("%3d", n)
										entry = ""
									end
								else
									if n < -70 or n > 70 then	-- T/C OAT Celsius min and max
										entry = INVALID_INPUT
									else
										tc_oat_c = string.format("%3d", n)
										n = (n * 9 / 5) + 32
										tc_oat_f = string.format("%3d", n)
										-- calc ISA DEV
										n = tonumber(tc_oat_c)
										alt_temp = math.min(alt_temp, 37000)
										isa_dev_c = string.format("%3d", (n - B738_rescale(0, 15, 37000, -56.5, alt_temp)))
										n = tonumber(isa_dev_c)
										n = (n * 9 / 5) + 32
										isa_dev_f = string.format("%3d", n)
										entry = ""
									end
								end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_perf == 2 then
			-- DES max speed kts/mach
			local strlen = string.len(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					des_max_kts = "   "
					des_max_mach = "   "
					entry = ""
				else
					if strlen > 2 and  strlen < 6 and string.sub(entry, 1, 2) == "/." then		-- only mach
						local n = tonumber(string.sub(entry, 2, strlen))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(des_min_mach)
							if nn == nil then
								nn = 0.4
							else
								nn = nn / 1000
							end
							if n > 0.82 or n < nn then
								entry = INVALID_INPUT
							else
								n = n * 1000
								des_max_mach = string.format("%03d", n)
								-- simCMD_FMS_key_des:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- entry = "/." .. des_max_mach
								-- type_to_fmc(entry)
								-- simCMD_FMS_key_1L:once()
								entry = ""
							end
						end
					elseif strlen == 3 then			-- only kts
						local n = tonumber(entry)
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(des_min_kts)
							if nn == nil then
								nn = 100
							end
							if n > 340  or n < nn then
								entry = INVALID_INPUT
							else
								des_max_kts = string.format("%03d", n)
								-- simCMD_FMS_key_des:once()
								-- simCMD_FMS_key_delete:once()
								-- simCMD_FMS_key_clear:once()
								-- simCMD_FMS_key_clear:once()
								-- entry = des_max_kts
								-- type_to_fmc(entry)
								-- simCMD_FMS_key_1L:once()
								entry = ""
							end
						end
					elseif strlen > 5 and strlen < 9 and string.sub(entry, 4, 5) == "/." then 	-- kts and mach
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							local nn = tonumber(des_min_kts)
							if nn == nil then
								nn = 100
							end
							if n > 340 or n < nn then
								entry = INVALID_INPUT
							else
								local kts = string.format("%03d", n)
									n = tonumber(string.sub(entry, 5, strlen))
									if n == nil then
										entry = INVALID_INPUT
									else
										nn = tonumber(des_min_mach)
										if nn == nil then
											nn = 0.4
										else
											nn = nn / 1000
										end
										if n > 0.82 or n < nn then
											entry = INVALID_INPUT
										else
											n = n * 1000
											des_max_kts = kts
											des_max_mach = string.format("%03d", n)
											-- simCMD_FMS_key_des:once()
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_clear:once()
											-- simCMD_FMS_key_clear:once()
											-- entry = des_max_kts
											-- type_to_fmc(entry)
											-- simCMD_FMS_key_1L:once()
											-- simCMD_FMS_key_des:once()
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_clear:once()
											-- simCMD_FMS_key_clear:once()
											-- entry = "/." .. des_max_mach
											-- type_to_fmc(entry)
											-- simCMD_FMS_key_1L:once()
											entry = ""
										end
									end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		----------
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 5RSK
function B738_fmc1_5R_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_5R:once()
			entry = ""
		else
		
		-- if page_dep == 1 then
			-- local prev_repeat = 40
			-- if ref_rwy == "-----" then
				-- if ref_rwy_sel[5] ~= "-----" then
					-- ref_rwy = ref_rwy_sel[5]
					-- simCMD_FMS_key_5R:once()
					-- while prev_repeat > 1 do
						-- prev_repeat = prev_repeat - 1
						-- simCMD_FMS_key_prev:once()
					-- end
					-- ref_rwy_exec = 1
					-- act_page = 1
				-- end
				-- create_sid_list()
			-- end
		if page_dep == 1 then
			if ref_rwy2 == "-----" then
				if ref_rwy_sel[5] ~= "-----" then
					ref_rwy2 = ref_rwy_sel[5]
					if ref_sid2 == "------" then
						create_sid_list()
					end
					act_page = 1
					ref_rwy_exec = 1
				end
			end
		-- elseif page_arr == 1 then
			-- local prev_repeat = 40
-- --			if des_star ~= "------" then
				-- if des_app == "------" then
					-- if des_app_sel[5] ~= "------" then
						-- des_app = des_app_sel[5]
						-- simCMD_FMS_key_5R:once()
						-- ref_rwy_exec = 1
						-- while prev_repeat > 1 do
							-- prev_repeat = prev_repeat - 1
							-- simCMD_FMS_key_prev:once()
						-- end
						-- act_page = 1
					-- end
				-- else
					-- if des_app_tns == "------" then
						-- if des_tns_sel[5] ~= "------" then
							-- des_app_tns = des_tns_sel[5]
							-- simCMD_FMS_key_5R:once()
							-- ref_app_tns_exec = 1
							-- while prev_repeat > 1 do
								-- prev_repeat = prev_repeat - 1
								-- simCMD_FMS_key_prev:once()
							-- end
							-- act_page = 1
						-- end
					-- end
				-- end
-- --			end
		elseif page_arr == 1 then
			if des_app2 == "------" then
				if des_app_sel[5] ~= "------" then
					des_app2 = des_app_sel[5]
					if des_star2 == "------" then
						create_star_list()
					end
					act_page = 1
					des_app_exec = 1
					create_app_tns_list()
				end
			else
				if des_app_tns2 == "------" then
					if des_tns_sel[5] ~= "------" then
						des_app_tns2 = des_tns_sel[5]
						act_page = 1
						des_app_tns_exec = 1
					end
				end
			end
		elseif page_rte_init == 1 then
			if act_page > 1 then
				local item = 0
				local button = 5	-- button 5 RSK
				local tmp_tmp = 0
				
				item = (act_page - 2) * 5 + button
				tmp_tmp = fpln_num2 + 1
				if fpln_num2 > 0 then
					if item == tmp_tmp then
						--if fpln_data2[fpln_num2][1] ~= "" then
							-- add new direct to navaid
							dir_via_add("", "", entry, "", "", item)
						--end
					elseif item <= fpln_num2 then --and fpln_num2 > 1 then
						if item == 1 then
							dir_via_add("", "", entry, "", "", item)
						else
							dir_via_add(fpln_data2[item-1][1], fpln_data2[item-1][3], entry, "", fpln_data2[item][2], item)
						end
					end
				end
			end
		elseif page_legs == 1 then
			if B738DR_fms_exec_light_pilot == 0 then
				local item = 0
				local button = 5	-- button 5 RSK
				local n = 0
				local nn = 0
				local nnn = 0
				local strlen = string.len(entry)
				
				item = (act_page - 1) * 5 + offset - 1 + button
				if item > legs_num then
					entry = INVALID_INPUT
				elseif legs_data[item][1] == "DISCONTINUITY" then
					entry = INVALID_INPUT
				elseif entry == ">DELETE" then
					legs_data[item][4] = 0
					legs_data[item][5] = 0
					legs_data[item][6] = 0
					entry = ""
					msg_chk_alt_constr = 0
					vnav_update = 1
				else
					if strlen == 4 and string.sub(entry, -1, -1) == "/" then		-- speed: xxx
						n = tonumber(string.sub(entry, 1, -2))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n > 100 and n < 340 then
								legs_data[item][4] = n		-- speed
								vnav_update = 1
								msg_chk_alt_constr = 0
								entry = ""
							else
								entry = INVALID_INPUT
							end
						end
					elseif strlen > 4 and strlen < 7 and string.sub(entry, 1, 2) == "FL" then		-- alt: FLxxx or FLxxxX
						if string.sub(entry, -1, -1) == "A" then
							nn = 43
							n = tonumber(string.sub(entry, 3, -2))
						elseif string.sub(entry, -1, -1) == "B" then
							nn = 45
							n = tonumber(string.sub(entry, 3, -2))
						else
							if strlen == 7 then
								n = nil
							else
								nn = 32
								n = tonumber(string.sub(entry, 3, -1))
							end
						end
						if n == nil then
							entry = INVALID_INPUT
						else
							legs_data[item][5] = n * 100
							legs_data[item][6] = nn
							msg_chk_alt_constr = 0
							vnav_update = 1
							entry = ""
						end
					elseif strlen > 2 and  strlen < 7 then	-- alt: xxx or xxxx or xxxxx with X
						if string.sub(entry, -1, -1) == "A" then
							nn = 43
							n = tonumber(string.sub(entry, 1, -2))
						elseif string.sub(entry, -1, -1) == "B" then
							nn = 45
							n = tonumber(string.sub(entry, 1, -2))
						else
							nn = 32
							n = tonumber(string.sub(entry, 1, -1))
						end
						if n == nil then
							entry = INVALID_INPUT
						else
							legs_data[item][5] = n
							legs_data[item][6] = nn
							msg_chk_alt_constr = 0
							vnav_update = 1
							entry = ""
						end
					elseif strlen > 6 and  strlen < 11 and string.sub(entry, 4, 4) == "/" then		-- alt: xxx/FLxxx or xxx/FLxxxX
						-- speed
						n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n > 100 and n < 340 then
								if string.sub(entry, 5, 6) == "FL" then
									if string.sub(entry, -1, -1) == "A" then
										nn = 43
										nnn = tonumber(string.sub(entry, 7, -2))
									elseif string.sub(entry, -1, -1) == "B" then
										nn = 45
										nnn = tonumber(string.sub(entry, 7, -2))
									else
										nn = 32
										nnn = tonumber(string.sub(entry, 7, -1))
									end
								else
									if string.sub(entry, -1, -1) == "A" then
										nn = 43
										nnn = tonumber(string.sub(entry, 5, -2))
									elseif string.sub(entry, -1, -1) == "B" then
										nn = 45
										nnn = tonumber(string.sub(entry, 5, -2))
									else
										nn = 32
										nnn = tonumber(string.sub(entry, 5, -1))
									end
								end
								if nnn == nil then
									entry = INVALID_INPUT
								else
									if string.sub(entry, 5, 6) == "FL" then
										nnn = nnn * 100
									end
									legs_data[item][4] = n
									legs_data[item][5] = nnn
									legs_data[item][6] = nn
									msg_chk_alt_constr = 0
									vnav_update = 1
									entry = ""
								end
							else
								entry = INVALID_INPUT
							end
						end
						
					end
				end
			end
		elseif page_takeoff == 2 then
			-- entry THR REDUCTION ALT AGL
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					clb_alt = "----"
					clb_alt_num = 1500
					entry = ""
				elseif strlen > 2 and strlen < 5 then
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 800 or n > 9999 then	-- THR RED ALT AGL min and max
							entry = INVALID_INPUT
						else
							clb_alt = string.format("%4d", n)
							entry = ""
							clb_alt_num = n
						end
					end
				else
					entry = INVALID_INPUT
				end
			else
				entry = INVALID_INPUT
			end
		elseif page_approach == 1 then
			-- WIND CORR
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					wind_corr = "--"
					entry = ""
				elseif strlen < 3 then
					local n = tonumber(entry)
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 5 or n > 20 then	-- WIND CORR min and max
							entry = INVALID_INPUT
						else
							wind_corr = string.format("%02d", n)
							entry = ""
						end
					end
				else
					entry = INVALID_INPUT
				end
			else
				entry = INVALID_INPUT
			end
		elseif page_descent_forecast == 1 then
			-- entry WIND LAYER 3
			local strlen = string.len(entry)
			if strlen > 0 then
				if entry == ">DELETE" then
					forec_dir_3 = "---"
					forec_spd_3 = "---"
					entry = ""
				else
					if strlen > 4 and strlen < 8 and string.sub(entry, 4, 4) == "/" then
						local n = tonumber(string.sub(entry, 1, 3))
						if n == nil then
							entry = INVALID_INPUT
						else
							if n < 0 or n > 359 then		-- wind heading 0 - 359
								entry = INVALID_INPUT
							else
								local wind_dir = string.format("%03d", n)
								n = tonumber(string.sub(entry, 5, strlen))
								if n == nil then
									entry = INVALID_INPUT
								else
									if n < 1 or n > 199 then	-- wind speed 1 - 199
										entry = INVALID_INPUT
									else
										forec_dir_3 = wind_dir
										forec_spd_3 = string.format("%03d", n)
										entry = ""
									end
								end
							end
						end
					else
						entry = INVALID_INPUT
					end
				end
			end
		elseif page_perf == 1 then
			-- entry Trans alt
			local strlen = string.len(entry)
			local n = tonumber(entry)
			local n_str = ""
			if strlen > 0 then
				if entry == ">DELETE" then
					trans_alt = "-----"
					n = 18000
					if crz_alt ~= "*****" then
						n_str = string.sub(crz_alt, 1, 2)
						if crz_alt_num >= n then
							if n_str ~= "FL" then
								--n_str = string.sub(crz_alt)
								n = tonumber(crz_alt) / 100
								crz_alt = "FL" .. string.format("%03d", n)
							end
						else
							if n_str == "FL" then
								n_str = string.sub(crz_alt, 3, 5)
								n = tonumber(n_str) * 100
								crz_alt = string.format("%5d", n)
							end
						end
					end
					entry = ""
				else
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 1000 or n > 99999 then	-- Trans alt min and max
							entry = INVALID_INPUT
						else
							trans_alt = string.format("%5d", n)
							simCMD_FMS_key_clb:once()
							simCMD_FMS_key_delete:once()
							simCMD_FMS_key_clear:once()
							simCMD_FMS_key_clear:once()
							type_to_fmc(trans_alt)
							simCMD_FMS_key_1R:once()
							if crz_alt ~= "*****" then
								n_str = string.sub(crz_alt, 1, 2)
								if crz_alt_num >= n then
									if n_str ~= "FL" then
										--n_str = string.sub(crz_alt, 3, 5)
										n = tonumber(crz_alt) / 100
										crz_alt = "FL" .. string.format("%03d", n)
									end
								else
									if n_str == "FL" then
										n_str = string.sub(crz_alt, 3, 5)
										n = tonumber(n_str) * 100
										crz_alt = string.format("%5d", n)
									end
								end
							end
							entry = ""
						end
					end
				end
			end
		elseif page_pos_init == 1 and disable_POS_5R == 0 then
			-- SET IRS HDG
			local strlen = string.len(entry)
			local n = tonumber(entry)
			if strlen == 0 then
				 entry = INVALID_INPUT
			else
				if entry == ">DELETE" then
					irs_hdg = "---`"
					entry = ""
--					if B738DR_irs_left == 3 then
--						B738DR_irs_hdg_fmc_set = "---"
--					end
--					if B738DR_irs_right == 3 then
--						B738DR_irs2_hdg_fmc_set = "---"
--					end
				else
					if n == nil then
						entry = INVALID_INPUT
					else
						if n < 0 or n > 359 or strlen ~= 3 then	-- HDG min and max
							-- TO DO INHIBIT FRAC NUMBER
							entry = INVALID_INPUT
						else
							irs_hdg = string.format("%03d", n)
--							if B738DR_irs_left == 3 then
--								B738DR_irs_hdg_fmc_set = irs_hdg
--							end
--							if B738DR_irs_right == 3 then
--								B738DR_irs2_hdg_fmc_set = irs_hdg
--							end
							irs_hdg = irs_hdg .. "`"
							entry = ""
						end
					end
				end
			end
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- 6RSK
function B738_fmc1_6R_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_6R:once()
			entry = ""
		else
		
		if page_rte_init == 1 then
			-- go to perf init
			page_perf = 1
			page_rte_init = 0
		elseif page_dep == 1 then
			-- go to route
			simCMD_FMS_key_fpln:once()
			page_climb = 0
			page_menu = 0
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 0
			page_pos_init = 0
			page_cruise = 0
			page_descent = 0
			page_clear = 0
			page_route = 0
			page_legs = 0
			page_descent_forecast = 0
			page_rte_init = 1
			page_dep_arr = 0
			page_dep = 0
			page_arr = 0
			act_page = 1
		elseif page_arr == 1 then
			-- go to route
			simCMD_FMS_key_fpln:once()
			page_climb = 0
			page_menu = 0
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 0
			page_pos_init = 0
			page_cruise = 0
			page_descent = 0
			page_clear = 0
			page_route = 0
			page_legs = 0
			page_descent_forecast = 0
			page_rte_init = 1
			page_dep_arr = 0
			page_dep = 0
			page_arr = 0
			act_page = 1
		elseif page_legs == 1 then
			if map_mode == 3 then
				legs_step = legs_step + 1
				if legs_step > legs_num or legs_step < offset then
					legs_step = offset
				end
				if legs_step > legs_num then
					legs_step = legs_num
				end
				page_legs_step = math.floor((legs_step - offset) / 5) + 1
				act_page = page_legs_step
			end
		elseif page_takeoff == 1 then
			-- set QRH on / off
			if qrh == " ON" then
				qrh = "OFF"
			else
				qrh = " ON"
			end
			display_update = 1
		elseif page_n1_limit == 1 and disable_N1_6R == 0 then
			if in_flight_mode == 0 then
				-- go to Takeoff page
				page_n1_limit = 0
				page_takeoff = 1
				display_update = 1
			else
				-- select / deselect CLB-2
				if clb_2 == "<SEL>" then
					clb = "<SEL>"
					clb_1 = "     "
					clb_2 = "     "
				else
					clb = "     "
					clb_1 = "     "
					clb_2 = "<SEL>"
				end
				sel_clb_thr = 1
			end
		elseif page_descent_forecast == 1 then
			-- ERASE
			trans_lvl = "-----"
			tai_on_alt = "-----"
			tai_off_alt = "-----"
			forec_isa_dev = "---"
			forec_qnh = "------"
			forec_alt_1 = "-----"
			forec_dir_1 = "---"
			forec_spd_1 = "---"
			forec_alt_2 = "-----"
			forec_dir_2 = "---"
			forec_spd_2 = "---"
			forec_alt_3 = "-----"
			forec_dir_3 = "---"
			forec_spd_3 = "---"
			page_descent_forecast = 0
			page_descent = 1
		elseif page_perf == 1 then
			-- go to N1 limit page
			page_perf = 0
			page_n1_limit = 1
			display_update = 1
		elseif page_perf == 2 then
			-- go to RTA progress page
			-- page_perf = 0
			-- page_rta = 1
		elseif page_pos_init == 1 then
			-- go to Route page
			page_pos_init = 0
			page_rte_init = 1
		elseif page_ident == 1 then
			-- go to Pos init page
			page_ident = 0
			page_pos_init = 1
			display_update = 1
		elseif page_cruise == 1 then
			-- ERASE change cruise alt and spd
			if crz_exec ~= 0 then
				crz_alt = crz_alt_old
				crz_exec = 0
				exec1_light = 0
				crz_alt_num2 = 0
				crz_alt_old = "     "
			end
		elseif page_descent == 1 then
			local delta_alt_crz = B738DR_fmc_cruise_alt - simDR_ap_altitude_dial_ft
			if B738DR_fms_descent_now < 2 and delta_alt_crz > 1000 and des_now_enable == 1 then
				if B738DR_fms_descent_now == 0 then
					B738DR_fms_descent_now = 1
					exec1_light = 1
				else
					B738DR_fms_descent_now = 0
					exec1_light = 0
				end
			end
		elseif page_xtras == 1 then
			-- go to MENU
			page_xtras = 0
			page_menu = 1
			act_page = 1
		elseif page_xtras_fmod > 0 then
			-- go to BACK
			page_xtras_fmod = 0
			page_xtras = 1
			act_page = 1
		elseif page_xtras_others > 0 then
			-- go to BACK
			page_xtras_others = 0
			page_xtras = 1
			act_page = 1
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- FMC NUMBER BUTTON
function B738_fmc1_0_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_0:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "0")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_1_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_1:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "1")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_2_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_2:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "2")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_3_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_3:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "3")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_4_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_4:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "4")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_5_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_5:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "5")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_6_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_6:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "6")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_7_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_7:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "7")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_8_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_8:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "8")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_9_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_9:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "9")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_period_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_period:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. ".")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_minus_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_minus:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "-")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_slash_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_slash:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "/")
			display_update = 1
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- FMC BUTTON CLR (delete last)
function B738_fmc1_clr_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		--if page_clear == 1 then
			simCMD_FMS_key_clear:once()
		--end
		
		-- local lenstr = string.len(entry)
		-- if lenstr == 1 then
			-- entry = ""
			-- display_update = 1
		-- elseif lenstr > 1 then
			-- local msgstr = string.sub(entry, 1, 1)
			-- if msgstr == "<" then
				-- entry = ""
			-- else
				-- entry = string.sub(entry, 1, -2)
			-- end
			-- display_update = 1
		-- end
		
		local lenstr = string.len(entry)
		if fmc_message_num ~= 0 then
			fmc_message_num = fmc_message_num - 1
			display_update = 1
		else
			if lenstr == 1 then
				entry = ""
				display_update = 1
			elseif lenstr > 1 then
				-- local msgstr = string.sub(entry, 1, 1)
				-- if msgstr == "<" then
					-- entry = ""
				-- else
					-- entry = string.sub(entry, 1, -2)
				-- end
				if string.sub(entry, 1, 1) == ">" then
					entry = ""
				else
					entry = string.sub(entry, 1, -2)
				end
				display_update = 1
			end
		end
		
		-- if entry == ">DELETE" then
			-- entry = ""
		-- end
		
		-- if legs_offset > 0 then
			-- legs_offset = 0
			-- entry = ""
		-- end
		item_sel = 0
		--fms_msg_cfg_saved = 0
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- FMC BUTTON DEL (delete all)
function B738_fmc1_del_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_delete:once()
		end
		-- if entry == ">DELETE" then
			-- entry = ""
		-- else
			-- entry = ">DELETE"
		-- end
		if string.len(entry) > 1 then
				if string.sub(entry, 1, 1) == ">" then
					entry = ""
				else
					entry = ">DELETE"
				end
		else
			entry = ">DELETE"
		end
		-- if legs_offset > 0 then
			-- legs_offset = 0
			-- entry = ""
		-- end
		item_sel = 0
		--fms_msg_cfg_saved = 0
		display_update = 1
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- FMC BUTTON PREVIOUS and NEXT PAGE
function B738_fmc1_prev_page_CMDhandler(phase, duration)
	if phase == 0 and prev_enable == 1 then
		B738DR_fms_key = 1
		if legs_add ~= 1 then
		
		if page_clear == 1 then
			simCMD_FMS_key_prev:once()
		end
		if act_page > 1 then
			act_page = act_page - 1
			if page_init ~= 0 then
				page_init = act_page
			elseif page_ident ~= 0 then
				page_ident = act_page
			elseif page_takeoff ~= 0 then
				page_takeoff = act_page
			elseif page_approach ~= 0 then
				page_approach = act_page
			elseif page_perf ~= 0 then
				page_perf = act_page
			elseif page_n1_limit~= 0 then
				page_n1_limit = act_page
			elseif page_pos_init ~= 0 then
				page_pos_init = act_page
			elseif page_progress ~= 0 then
				page_progress = act_page
			elseif page_xtras_fmod ~= 0 then
				page_xtras_fmod = act_page
			elseif page_xtras_others ~= 0 then
				page_xtras_others = act_page
			elseif page_xtras ~= 0 then
				page_xtras = act_page
			elseif page_legs == 1 then
				simCMD_FMS_key_prev:once()
				if map_mode == 3 then
					legs_step = offset + (5 * (act_page - 1))
				end
			elseif page_dep == 1 or page_arr == 1 or page_rte_init == 1 then
				simCMD_FMS_key_prev:once()
			end
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_next_page_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if legs_add ~= 1 then
		
		if page_clear == 1 and next_enable == 1 then
			simCMD_FMS_key_next:once()
		end
		if act_page < max_page then
			act_page = act_page + 1
			if page_init ~= 0 then
				page_init = act_page
			elseif page_ident ~= 0 then
				page_ident = act_page
			elseif page_takeoff ~= 0 then
				page_takeoff = act_page
			elseif page_approach ~= 0 then
				page_approach = act_page
			elseif page_perf ~= 0 then
				page_perf = act_page
			elseif page_n1_limit ~= 0 then
				page_n1_limit = act_page
			elseif page_pos_init ~= 0 then
				page_pos_init = act_page
			elseif page_xtras_fmod ~= 0 then
				page_xtras_fmod = act_page
			elseif page_xtras ~= 0 then
				page_xtras = act_page
			elseif page_xtras_others ~= 0 then
				page_xtras_others = act_page
			elseif page_progress ~= 0 then
				page_progress = act_page
			elseif page_legs == 1 then
				simCMD_FMS_key_next:once()
				if map_mode == 3 then
					legs_step = offset + (5 * (act_page - 1))
				end
			elseif page_dep == 1 or page_arr == 1 or page_rte_init == 1 then
				simCMD_FMS_key_next:once()
			end
		end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

function B738_fmc1_init_ref_CMDhandler(phase, duration)
	if phase == 0 then
		
		B738DR_fms_key = 1
		
		if B738DR_fms_exec_light_pilot == 0 then
		
			local irs_align_ok = 0
			if B738DR_irs_left_mode > 1 or B738DR_irs_right_mode > 1 then
				irs_align_ok = 1
			end
			local perf_init_complete = 1
			if gw == "***.*" or cost_index == "***" or reserves == "**.*" or crz_alt == "*****" then
				perf_init_complete = 0
			end
			local ref_des_icao = 1
			if ref_icao == "----" or des_icao == "****" then
				ref_des_icao = 0
			end
			if irs_align_ok == 0 then
				-- Pos Init (index) page
				page_menu = 0
				page_init = 0
				page_ident = 0
				page_takeoff = 0
				page_approach = 0
				page_perf = 0
				page_n1_limit = 0
				page_pos_init = 1
				page_climb = 0
				page_cruise = 0
				page_descent = 0
				page_descent_forecast = 0
				page_rte_init = 0
				page_dep_arr = 0
				page_dep = 0
				page_arr = 0
			elseif B738DR_flight_phase == 0 and simDR_on_ground_0 == 1 then
				if ref_des_icao == 0 then
					page_menu = 0
					page_init = 0
					page_ident = 0
					page_takeoff = 0
					page_approach = 0
					page_perf = 0
					page_n1_limit = 0
					page_pos_init = 0
					page_climb = 0
					page_cruise = 0
					page_descent = 0
					page_descent_forecast = 0
					page_rte_init = 1
					page_dep_arr = 0
					page_dep = 0
					page_arr = 0
				elseif perf_init_complete == 0 then
					-- On the graound -> Perf Init page
					page_menu = 0
					page_init = 0
					page_ident = 0
					page_takeoff = 0
					page_approach = 0
					page_perf = 1
					page_n1_limit = 0
					page_pos_init = 0
					page_climb = 0
					page_cruise = 0
					page_descent = 0
					page_descent_forecast = 0
					page_rte_init = 0
					page_dep_arr = 0
					page_dep = 0
					page_arr = 0
				else
					-- On the graound -> Takeoff page
					page_menu = 0
					page_init = 0
					page_ident = 0
					page_takeoff = 1
					page_approach = 0
					page_perf = 0
					page_n1_limit = 0
					page_pos_init = 0
					page_climb = 0
					page_cruise = 0
					page_descent = 0
					page_descent_forecast = 0
					page_rte_init = 0
					page_dep_arr = 0
					page_dep = 0
					page_arr = 0
				end
			elseif was_on_air == 1 then
				-- in fligt -> Approach page
				page_menu = 0
				page_init = 0
				page_ident = 0
				page_takeoff = 0
				page_approach = 1
				page_perf = 0
				page_n1_limit = 0
				page_pos_init = 0
				page_climb = 0
				page_cruise = 0
				page_descent = 0
				page_descent_forecast = 0
				page_rte_init = 0
				page_dep_arr = 0
				page_dep = 0
				page_arr = 0
			else
				-- Pos Init page
				page_menu = 0
				page_init = 1
				page_ident = 0
				page_takeoff = 0
				page_approach = 0
				page_perf = 0
				page_n1_limit = 0
				page_pos_init = 0
				page_climb = 0
				page_cruise = 0
				page_descent = 0
				page_descent_forecast = 0
				page_rte_init = 0
				page_dep_arr = 0
				page_dep = 0
				page_arr = 0
			end
			page_progress = 0
			page_clear = 0
			page_route = 0
			page_legs = 0
			page_hold = 0
			page_xtras_fmod = 0
			page_xtras = 0
			page_xtras_others = 0
			page_sel_wpt = 0
			page_sel_wpt2 = 0

			
		end
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_menu_CMDhandler(phase, duration)
	if phase == 0 then
		
		B738DR_fms_key = 1
		
		if B738DR_fms_exec_light_pilot == 0 then
		
			page_menu = 1
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 0
			page_pos_init = 0
			page_clear = 0
			page_climb = 0
			page_cruise = 0
			page_descent = 0
			page_route = 0
			page_legs = 0
			page_descent_forecast = 0
			page_rte_init = 0
			page_dep_arr = 0
			page_dep = 0
			page_arr = 0
			page_progress = 0
			page_hold = 0
			page_xtras_fmod = 0
			page_xtras = 0
			page_xtras_others = 0
			page_sel_wpt = 0
			page_sel_wpt2 = 0

		
		end
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_n1_lim_CMDhandler(phase, duration)
	if phase == 0 then
		
		B738DR_fms_key = 1
		
		if B738DR_fms_exec_light_pilot == 0 then
		
			page_menu = 0
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 1
			page_pos_init = 0
			page_clear = 0
			page_climb = 0
			page_cruise = 0
			page_descent = 0
			page_route = 0
			page_legs = 0
			page_descent_forecast = 0
			page_rte_init = 0
			page_dep_arr = 0
			page_dep = 0
			page_arr = 0
			page_progress = 0
			page_hold = 0
			page_xtras_fmod = 0
			page_xtras = 0
			page_xtras_others = 0
			page_sel_wpt = 0
			page_sel_wpt2 = 0

		
		end
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_rte_CMDhandler(phase, duration)
	if phase == 0 then
		
		B738DR_fms_key = 1
		
		if B738DR_fms_exec_light_pilot == 0 then
		
			simCMD_FMS_key_fpln:once()

			page_climb = 0
			page_menu = 0
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 0
			page_pos_init = 0
			page_cruise = 0
			page_descent = 0
			page_clear = 0
			page_route = 0
			page_legs = 0
			page_descent_forecast = 0
			page_rte_init = 1
			page_dep_arr = 0
			page_dep = 0
			page_arr = 0
			page_progress = 0
			page_hold = 0
			page_xtras_fmod = 0
			page_xtras = 0
			page_xtras_others = 0
			page_sel_wpt = 0
			page_sel_wpt2 = 0

			
			act_page = 1
		
		end
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

function B738_fmc1_legs_CMDhandler(phase, duration)
	if phase == 0 then
		
		B738DR_fms_key = 1
		
		if B738DR_fms_exec_light_pilot == 0 then
		
			simCMD_FMS_key_legs:once()
			
			page_dep_arr = 0
			page_climb = 0
			page_menu = 0
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 0
			page_pos_init = 0
			page_cruise = 0
			page_descent = 0
			page_clear = 0
			page_route = 0
			page_legs = 1
			page_descent_forecast = 0
			page_rte_init = 0
			page_dep = 0
			page_arr = 0
			page_progress = 0
			page_hold = 0
			page_xtras_fmod = 0
			page_xtras = 0
			page_xtras_others = 0
			page_sel_wpt = 0
			page_sel_wpt2 = 0

			
			if B738DR_capt_map_mode == 3 then
				if page_legs_step == 0 then
					page_legs_step = 1
				end
				act_page = page_legs_step
			else
				act_page = 1
			end
		
		end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_fix_CMDhandler(phase, duration)
	if phase == 0 then
		
		B738DR_fms_key = 1
		
		-- if B738DR_fms_exec_light_pilot == 0 then
		
			-- simCMD_FMS_key_fix:once()
			
			-- page_clear = 1
			-- next_enable = 1
			-- prev_enable = 1
			-- page_route = 0
			-- page_hold = 0
			-- -- page_legs = 0
		
		-- end
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_clb_CMDhandler(phase, duration)
	if phase == 0 then
		
		B738DR_fms_key = 1
		
		if B738DR_fms_exec_light_pilot == 0 then
		
			page_climb = 1
			page_menu = 0
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 0
			page_pos_init = 0
			page_cruise = 0
			page_descent = 0
			page_clear = 0
			page_route = 0
			page_legs = 0
			page_descent_forecast = 0
			page_rte_init = 0
			page_dep_arr = 0
			page_dep = 0
			page_arr = 0
			page_progress = 0
			page_hold = 0
			page_xtras_fmod = 0
			page_xtras = 0
			page_xtras_others = 0
			page_sel_wpt = 0
			page_sel_wpt2 = 0

		
		end
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_crz_CMDhandler(phase, duration)
	if phase == 0 then
		
		B738DR_fms_key = 1
		
		if B738DR_fms_exec_light_pilot == 0 then
		
			page_climb = 0
			page_menu = 0
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 0
			page_pos_init = 0
			page_cruise = 1
			page_descent = 0
			page_clear = 0
			page_route = 0
			page_legs = 0
			page_descent_forecast = 0
			page_rte_init = 0
			page_dep_arr = 0
			page_dep = 0
			page_arr = 0
			page_progress = 0
			page_hold = 0
			page_xtras_fmod = 0
			page_xtras = 0
			page_xtras_others = 0
			page_sel_wpt = 0
			page_sel_wpt2 = 0

		
		end
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_des_CMDhandler(phase, duration)
	if phase == 0 then
		
		B738DR_fms_key = 1
		
		if B738DR_fms_exec_light_pilot == 0 then
		
			page_climb = 0
			page_menu = 0
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 0
			page_pos_init = 0
			page_cruise = 0
			page_descent = 1
			page_clear = 0
			page_route = 0
			page_legs = 0
			page_descent_forecast = 0
			page_rte_init = 0
			page_dep_arr = 0
			page_dep = 0
			page_arr = 0
			page_progress = 0
			page_hold = 0
			page_xtras_fmod = 0
			page_xtras = 0
			page_xtras_others = 0
			page_sel_wpt = 0
			page_sel_wpt2 = 0

		
		end
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_dep_app_CMDhandler(phase, duration)
	if phase == 0 then
		
		B738DR_fms_key = 1
		
		if B738DR_fms_exec_light_pilot == 0 then
		
			simCMD_FMS_key_dep_arr:once()
		
			page_dep_arr = 1
			page_climb = 0
			page_menu = 0
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 0
			page_pos_init = 0
			page_cruise = 0
			page_descent = 0
			page_clear = 0
			page_route = 0
			page_legs = 0
			page_descent_forecast = 0
			page_rte_init = 0
			page_dep = 0
			page_arr = 0
			page_progress = 0
			page_hold = 0
			page_xtras_fmod = 0
			page_xtras = 0
			page_xtras_others = 0
			page_sel_wpt = 0
			page_sel_wpt2 = 0

			
			--read ref and des SIDs,STARs
			
			-- ref_rwy2 = ref_rwy
			-- ref_sid2 = ref_sid
			-- ref_sid_tns2 = ref_sid_tns
			-- des_app2 = des_app
			-- des_app_tns2 = des_app_tns
			-- des_star2 = des_star
			-- des_star_trans2 = des_star_trans
			
			-- create_rnw_list()
			-- create_sid_list()
			-- create_tns_list()
			-- create_star_list()
			-- create_star_tns_list()
			-- create_des_app_list()
			-- create_app_tns_list()
			
		end
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_hold_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		
		-- if B738DR_fms_exec_light_pilot == 0 then
		
			-- simCMD_FMS_key_hold:once()
			-- page_clear = 1
			-- next_enable = 1
			-- prev_enable = 1
			-- page_route = 0
			-- page_hold = 1
			
			-- -- temporary
			-- page_perf = 0
			-- page_dep = 0
			-- page_arr = 0
			-- page_legs = 1
			-- clr_repeat = 0
			-- page_sel_wpt = 0

		
		-- end
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_prog_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		
		if B738DR_fms_exec_light_pilot == 0 then
		
			page_dep_arr = 0
			page_climb = 0
			page_menu = 0
			page_init = 0
			page_ident = 0
			page_takeoff = 0
			page_approach = 0
			page_perf = 0
			page_n1_limit = 0
			page_pos_init = 0
			page_cruise = 0
			page_descent = 0
			page_clear = 0
			page_route = 0
			page_legs = 0
			page_descent_forecast = 0
			page_rte_init = 0
			page_dep = 0
			page_arr = 0
			page_progress = 1
			page_hold = 0
			page_xtras_fmod = 0
			page_xtras = 0
			page_xtras_others = 0
			page_sel_wpt = 0
			page_sel_wpt2 = 0

			
			-- simCMD_FMS_key_prog:once()
			
			-- page_clear = 1
			-- next_enable = 1
			-- prev_enable = 1
			-- page_route = 0
		
		end
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

-- EXECSK
function B738_fmc1_exec_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		local prev_repeat = 40
		local qq = 0
		
		-- simCMD_FMS_key_exec:once()
		-- simCMD_FMS_key_clear:once()
		
		-- if legs_add == 1 then
			-- simCMD_FMS_key_delete:once()
			-- simCMD_FMS_key_clear:once()
			-- -- save flight plan
			-- simCMD_FMS_key_fpln:once()
			-- simCMD_FMS_key_delete:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_1L:once()
			-- type_to_fmc("B738X")
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_clear:once()
			-- -- reload flight plan
			-- read_fpln2()
			-- -- to legs page
			-- simCMD_FMS_key_legs:once()
			-- legs_add = 0
			-- legs_offset = 0
			-- legs_select = 0
			-- act_page = 1
			-- --legs_add_select = 0
			-- entry = ""
		-- end
		if B738DR_flight_phase == 3 or B738DR_flight_phase == 4 then
			if crz_alt_num2 > (simDR_altitude_pilot + 200)  then
				crz_exec = 1	-- CRZ CLB
				B738DR_flight_phase = 3
			else
				crz_exec = 2	-- CRZ DES
				B738DR_flight_phase = 4
			end
		end
		
		-- CRZ CLB
		if crz_exec == 1 then
			-- -- write to fmc
			-- simCMD_FMS_key_crz:once()
			-- simCMD_FMS_key_delete:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- type_to_fmc(crz_alt)
			-- simCMD_FMS_key_1R:once()
			
			-- engage CRZ CLB
			crz_alt_num = crz_alt_num2
			B738DR_fmc_cruise_alt = crz_alt_num
			simDR_ap_altitude_dial_ft = crz_alt_num
			if B738DR_mcp_alt_dial >= crz_alt_num then
				simCMD_autopilot_lvl_chg:once()
				B738DR_flight_phase = 3
			else
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = CHECK_ALT_TGT
				--entry = CHECK_ALT_TGT
				fms_msg_sound = 1
				B738DR_vnav_disconnect = 1
				B738DR_fmc_message_warn = 1
			end
		-- CRZ DES
		elseif crz_exec == 2 then
			-- -- write to fmc
			-- simCMD_FMS_key_crz:once()
			-- simCMD_FMS_key_delete:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- type_to_fmc(crz_alt)
			-- simCMD_FMS_key_1R:once()
			
			-- engage CRZ DES
			crz_alt_num = crz_alt_num2
			B738DR_fmc_cruise_alt = crz_alt_num
			simDR_ap_altitude_dial_ft = crz_alt_num
			if B738DR_mcp_alt_dial <= crz_alt_num then
				simDR_ap_vvi_dial = -1000
				simCMD_autopilot_vs_sel:once()
				B738DR_flight_phase = 4
			else
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = CHECK_ALT_TGT
				--entry = CHECK_ALT_TGT
				fms_msg_sound = 1
				B738DR_vnav_disconnect = 1
			end
		end
		
		if B738DR_fms_descent_now == 1 then
			B738DR_fms_descent_now = 2
		end
		
		-- if page_hold == 1 then
			-- -- save flight plan
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_fpln:once()
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_1L:once()
			-- type_to_fmc("B738X")
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_clear:once()
			-- -- reload flight plan
			-- read_fpln2()
			-- -- back to route
			-- simCMD_FMS_key_hold:once()
		-- end
		
		-- if page_route == 1 then
			-- -- save flight plan
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_fpln:once()
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_1L:once()
			-- type_to_fmc("B738X")
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_clear:once()
			-- -- reload flight plan
			-- read_fpln2()
			-- -- back to route
			-- simCMD_FMS_key_fpln:once()
			-- find_rnw_data()
		-- end
		
		if legs_delete == 1 or rte_exec == 1 then
			copy_to_legsdata()
			legs_delete = 0
			copy_to_fpln()
			rte_exec = 0
			--create_fpln()
			-- -- save flight plan
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_fpln:once()
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_1L:once()
			-- type_to_fmc("B738X")
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_clear:once()
			-- -- reload flight plan
			-- read_fpln2()
			-- -- back to legs
			-- legs_delete = 0
			-- legs_delete_item = 0
			-- legs_delete_key = 0
			-- entry = ""
			-- simCMD_FMS_key_legs:once()
			-- act_page = 1
			-- -- if act_page > 1 then
				-- -- for qq = 2, act_page do
					-- -- simCMD_FMS_key_next:once()
				-- -- end
			-- -- end
		end
		
		--if legs_offset > 0 and legs_select > 0 then
		-- if legs_ovwr == 1 or legs_intdir == 1 then
			-- -- save flight plan
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_fpln:once()
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_1L:once()
			-- type_to_fmc("B738X")
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_clear:once()
			-- -- reload flight plan
			-- read_fpln2()
			-- -- back to legs
			-- --local qq = legs_select - 1
			-- legs_offset = 0
			-- legs_select = 0
			-- legs_ovwr = 0
			-- legs_intdir = 0
			-- legs_dir = 0
			-- entry = ""
			-- simCMD_FMS_key_legs:once()
			-- if map_mode ~= 4 then
				-- -- legs_step = offset
				-- -- act_page = 1
			-- -- else
				-- if act_page > 1 then
					-- for qq = 2, act_page do
						-- simCMD_FMS_key_next:once()
					-- end
				-- end
			-- end
			-- if direct_to == 1 then
				-- -- for qq = 1, legs_num do
					-- -- if legs_data[qq][1] == "-----" then
						-- -- offset = qq + 1
					-- -- end
				-- -- end
				-- direct_to = 2
			-- end
		
		-- end
		
		if legs_intdir == 1 then
			-- take current position
			last_lat = math.rad(simDR_latitude)
			last_lon = math.rad(simDR_longitude)
			legs_intdir = 0
		end
		
		
		if ref_sid_exec == 1 or ref_rwy_exec == 1 or ref_tns_exec == 1 
		or des_star_exec == 1 or des_star_tns_exec == 1 or des_app_exec == 1 or des_app_tns_exec == 1 then
			ref_rwy = ref_rwy2
			ref_sid = ref_sid2
			ref_sid_tns = ref_sid_tns2
			des_app = des_app2
			des_app_tns = des_app_tns2
			des_star = des_star2
			des_star_trans = des_star_trans2
			act_page = 1
			ref_sid_exec = 0
			ref_rwy_exec = 0
			ref_tns_exec = 0
			ref_app_tns_exec = 0
			des_star_exec = 0
			des_star_tns_exec = 0
			des_app_exec = 0
			des_app_tns_exec = 0
			-- add SID
			rte_add_sid()
			-- add STAR and APP
			rte_add_star_app()
			if arr_data == 1 then
				--arr_data = 0
				--page_arr = 0
				--page_dep_arr = 1
				if des_icao ~= ref_icao then
					des_icao = ref_icao
					des_icaox = des_icao
					des_icao_lat = ref_icao_lat
					des_icao_lon = ref_icao_lon
					des_tns_alt = ref_tns_alt
					des_tns_lvl = ref_tns_lvl
					if des_tns_lvl == 0 then
						trans_lvl = "-----"
					else
						qq = des_tns_lvl
						trans_lvl = "FL" .. string.format("%03d", qq)
					end
					legs_num2 = legs_num2 + 1
					legs_data2[legs_num2] = {}
					legs_data2[legs_num2][1] = des_icao
					legs_data2[legs_num2][2] = 0		-- brg
					legs_data2[legs_num2][3] = 0		-- distance
					legs_data2[legs_num2][4] = 0		-- speed
					legs_data2[legs_num2][5] = 0		-- altitude
					legs_data2[legs_num2][6] = 0	-- altitude type
					legs_data2[legs_num2][7] = des_icao_lat		-- latitude
					legs_data2[legs_num2][8] = des_icao_lon		-- longitude
					legs_data2[legs_num2][9] = ""			-- via id
					legs_data2[legs_num2][10] = 0		-- calc speed
					legs_data2[legs_num2][11] = 0		-- calc altitude
					legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
					legs_data2[legs_num2][13] = 0
					legs_data2[legs_num2][14] = 0		-- rest alt
					legs_data2[legs_num2][15] = 0		-- last fuel
					legs_data2[legs_num2][16] = ""
					legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
					legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
					legs_data2[legs_num2][19] = 0		-- 0-none, 1-SID, 2-STAR, 3-APP
					legs_data2[legs_num2][20] = 0
					legs_data2[legs_num2][21] = -1
					legs_data2[legs_num2][22] = 0
					legs_data2[legs_num2][23] = 0
					legs_data2[legs_num2][24] = 0
					legs_data2[legs_num2][25] = 0
					legs_data2[legs_num2][26] = 0
					legs_num2 = legs_num2 - 1
				end
			end
			copy_to_legsdata()
			--B738_legs_num = rte_sid_num	--legs_num
		end
		
		if refdes_exec == 1 then
			--offset = 1
			des_app = "------"
			des_app_tns = "------"
			des_star = "------"
			des_star_trans = "------"
			----
			des_app2 = "------"
			des_app_tns2 = "------"
			des_star2 = "------"
			des_star_trans2 = "------"
			----
			co_route = "------------"
			legs_num2 = 0
			
			des_icao = des_icao_x
			
			-- REF ICAO
			refdes_exec = 0
			legs_num2 = 1
			legs_data2[legs_num2] = {}
			legs_data2[legs_num2][1] = ref_icao
			legs_data2[legs_num2][2] = 0		-- brg
			legs_data2[legs_num2][3] = 0		-- distance
			legs_data2[legs_num2][4] = 0		-- speed
			legs_data2[legs_num2][5] = 0		-- altitude
			legs_data2[legs_num2][6] = 0	-- altitude type
			legs_data2[legs_num2][7] = ref_icao_lat		-- latitude
			legs_data2[legs_num2][8] = ref_icao_lon		-- longitude
			legs_data2[legs_num2][9] = ""			-- via id
			legs_data2[legs_num2][10] = 0		-- calc speed
			legs_data2[legs_num2][11] = 0		-- calc altitude
			legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
			legs_data2[legs_num2][13] = 0
			legs_data2[legs_num2][14] = 0		-- rest alt
			legs_data2[legs_num2][15] = 0		-- last fuel
			legs_data2[legs_num2][16] = ""
			legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
			legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
			legs_data2[legs_num2][19] = 0		-- 0-none, 1-SID, 2-STAR, 3-APP
			legs_data2[legs_num2][20] = 0
			legs_data2[legs_num2][21] = -1
			legs_data2[legs_num2][22] = 0
			legs_data2[legs_num2][23] = 0
			legs_data2[legs_num2][24] = 0
			legs_data2[legs_num2][25] = 0
			legs_data2[legs_num2][26] = 0
			
			-- DES ICAO
			legs_num2 = legs_num2 + 1
			legs_data2[legs_num2] = {}
			legs_data2[legs_num2][1] = des_icao
			legs_data2[legs_num2][2] = 0		-- brg
			legs_data2[legs_num2][3] = 0		-- distance
			legs_data2[legs_num2][4] = 0		-- speed
			legs_data2[legs_num2][5] = 0		-- altitude
			legs_data2[legs_num2][6] = 0	-- altitude type
			legs_data2[legs_num2][7] = des_icao_lat		-- latitude
			legs_data2[legs_num2][8] = des_icao_lon		-- longitude
			legs_data2[legs_num2][9] = ""			-- via id
			legs_data2[legs_num2][10] = 0		-- calc speed
			legs_data2[legs_num2][11] = 0		-- calc altitude
			legs_data2[legs_num2][12] = 0		-- calc altitude vnav pth
			legs_data2[legs_num2][13] = 0
			legs_data2[legs_num2][14] = 0		-- rest alt
			legs_data2[legs_num2][15] = 0		-- last fuel
			legs_data2[legs_num2][16] = ""
			legs_data2[legs_num2][17] = 0		-- spd flag 0-default restrict, 1-custom restrict
			legs_data2[legs_num2][18] = 0		-- alt flag 0-default restrict, 1-custom restrict
			legs_data2[legs_num2][19] = 0		-- 0-none, 1-SID, 2-STAR, 3-APP
			legs_data2[legs_num2][20] = 0
			legs_data2[legs_num2][21] = -1
			legs_data2[legs_num2][22] = 0
			legs_data2[legs_num2][23] = 0
			legs_data2[legs_num2][24] = 0
			legs_data2[legs_num2][25] = 0
			legs_data2[legs_num2][26] = 0
			legs_num2 = legs_num2 - 1
			----
			copy_to_legsdata()
		end
		
		if rte_exec == 1 then
			copy_to_fpln()
			rte_exec = 0
		end
		
		
		crz_exec = 0
		exec1_light = 0
		crz_alt_num2 = 0
		crz_alt_old = "     "
		
		item_sel = 0
		
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

function B738_fmc1_A_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_A:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "A")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_B_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_B:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "B")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_C_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_C:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "C")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_D_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_D:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "D")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_E_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_E:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "E")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_F_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_F:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "F")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_G_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_G:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "G")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_H_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_H:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "H")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_I_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_I:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "I")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_J_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_J:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "J")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_K_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_K:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "K")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_L_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_L:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "L")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_M_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_M:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "M")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_N_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_N:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "N")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_O_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_O:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "O")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_P_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_P:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "P")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_Q_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_Q:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "Q")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_R_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_R:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "R")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_S_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_S:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "S")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_T_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_T:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "T")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_U_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_U:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "U")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_V_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_V:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "V")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_W_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_W:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "W")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_X_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_X:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "X")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_Y_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_Y:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "Y")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_Z_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_Z:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. "Z")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end
function B738_fmc1_SP_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_fms_key = 1
		if page_clear == 1 then
			simCMD_FMS_key_SP:once()
		end
		if string.len(entry) < 24 then
			entry = (entry .. " ")
		end
		item_sel = 0
	elseif phase == 2 then
		B738DR_fms_key = 0
	end
end

function B738_autopilot_alt_interv_CMDhandler(phase, duration)
	
	local n = 0
	local nn = 0
	local nnn = 0
	local end_idx = 0
	local temp_spd_rest = 0
	local temp_page = 0
	local temp_key = 0
	local temp_spd_txt = ""
	local restrict_deleted = 0
	local delete_enabled = 0
	--local desc_enable = 0
	
	if phase == 0 then
		B738DR_autopilot_alt_interv_pos = 1
		
		if B738DR_autopilot_vnav_status == 1 then
		
		-- if B738DR_flight_phase > 4 then
			-- desc_enable = 1
		-- end
		-- if B738DR_flight_phase == 2 or B738DR_flight_phase == 3 or B738DR_flight_phase == 4 then
			-- if B738DR_nd_vert_path == 1 and B738DR_mcp_alt_dial < (simDR_altitude_pilot - 300) then
				-- desc_enable = 1
			-- end
		-- end
		
		if vnav_alt_mode == 0 then
			if B738DR_flight_phase == 2 or B738DR_flight_phase == 3 or B738DR_flight_phase == 4 then --and desc_enable == 0 then
				crz_alt_num2 = B738DR_mcp_alt_dial
				if crz_alt_num ~= crz_alt_num2 then
	--				crz_alt_old = crz_alt
					n = crz_alt_num
					if n >= B738DR_trans_alt then
						n = n / 100
						crz_alt_old = "FL" .. string.format("%03d", n)
					else
						crz_alt_old = string.format("%5d", n)
					end
					n = crz_alt_num2
					if n >= B738DR_trans_alt then
						n = n / 100
						crz_alt = "FL" .. string.format("%03d", n)
					else
						crz_alt = string.format("%5d", n)
					end
					if B738DR_flight_phase == 2 then
						if crz_alt_num2 > crz_alt_num then
							crz_exec = 1	-- CRZ CLB
						else
							crz_exec = 2	-- CRZ DES
						end
					else
						if crz_alt_num2 > simDR_altitude_pilot then
							crz_exec = 1	-- CRZ CLB
						else
							crz_exec = 2	-- CRZ DES
						end
					end
					exec1_light = 1
					-- display Cruise page
					page_dep_arr = 0
					page_climb = 0
					page_menu = 0
					page_init = 0
					page_ident = 0
					page_takeoff = 0
					page_approach = 0
					page_perf = 0
					page_n1_limit = 0
					page_pos_init = 0
					page_cruise = 1
					page_descent = 0
					page_clear = 0
					page_route = 0
					page_legs = 0
					page_descent_forecast = 0
					page_rte_init = 0
					page_dep = 0
					page_arr = 0
					page_progress = 0
					page_hold = 0
					page_xtras_fmod = 0
					page_xtras = 0
					page_xtras_others = 0
				end
			else
				-- climb
				if B738DR_flight_phase < 2 then
					if B738DR_mcp_alt_dial > crz_alt_num then
						crz_alt_num = B738DR_mcp_alt_dial
						B738DR_fmc_cruise_alt = crz_alt_num
						n = crz_alt_num
						if n >= B738DR_trans_alt then
							n = n / 100
							crz_alt = "FL" .. string.format("%03d", n)
						else
							crz_alt = string.format("%5d", n)
						end
						-- write to fmc
						-- simCMD_FMS_key_crz:once()
						-- simCMD_FMS_key_delete:once()
						-- simCMD_FMS_key_clear:once()
						-- simCMD_FMS_key_clear:once()
						-- type_to_fmc(crz_alt)
						-- simCMD_FMS_key_1R:once()
					end
					crz_alt_num2 = 0
					crz_alt_old = "     "
				-- descent
				end
			end
		else
			if B738DR_flight_phase < 2 and B738DR_mcp_alt_dial > (simDR_altitude_pilot + 300) then
				vnav_alt_mode = 0
			end
			if B738DR_flight_phase > 4 and B738DR_mcp_alt_dial < (simDR_altitude_pilot - 300) then
				vnav_alt_mode = 0
			end
			if B738DR_flight_phase > 1 and B738DR_flight_phase < 5 then
				vnav_alt_mode = 0
			end
		end
		if B738DR_flight_phase < 2 then
			if B738DR_mcp_alt_dial <= crz_alt_num and B738DR_mcp_alt_dial > (simDR_altitude_pilot + 300) then
			-- delete alt restricts to MCP alt
				end_idx = tc_idx - 1
				if end_idx > offset then
					for n = offset, end_idx do
						-- find alt restrict
						if legs_restr_alt_n > 0 then	-- if exist alt restricts
							for nn = 1, legs_restr_alt_n do
								if legs_restr_alt[nn][2] > end_idx then
									-- no alt restricts to T/C
									break
								end
								delete_enabled = 0
								if legs_restr_alt[nn][2] == n and legs_restr_alt[nn][3] < B738DR_mcp_alt_dial then	-- alt restrict found
									delete_enabled = 1
								end
								if legs_restr_alt[nn][2] == n and legs_restr_alt[nn][3] == B738DR_mcp_alt_dial and legs_restr_alt[nn][4] == 45 then	-- B alt restrict found
									delete_enabled = 1
								end
								if delete_enabled == 1 then
									-- exist spd restrict
									temp_spd_rest = 0
									if legs_restr_spd_n > 0 then
										for nnn = 1, legs_restr_spd_n do
											if legs_restr_spd[nnn][2] == n then
												temp_spd_rest = legs_restr_spd[nnn][3]
												break
											end
										end
									end
									--if n == offset then
										-- not write to default FMC
										legs_data[n][5] = 0
										legs_data[n][6] = 0
										if temp_spd_rest > 0 then
											legs_data[n][4] = temp_spd_rest
										end
									--else
										-- write to default FMC
										-- legs_data[n][5] = 0
										-- legs_data[n][6] = 0
										-- if temp_spd_rest > 0 then
											-- legs_data[n][4] = temp_spd_rest
										-- end
										
										-- restrict_deleted = 1
										-- simCMD_FMS_key_legs:once()
										-- -- find page on default FMC
										-- temp_page = math.floor ((n-offset) / 5)
										-- --temp_page = (n-offset) % 5
										-- temp_key = temp_page * 5 + (n-offset+1)
										-- while temp_page > 0 do
											-- simCMD_FMS_key_next:once()
											-- temp_page = temp_page - 1
										-- end
										-- if temp_key == 1 then
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_2R:once()
											-- temp_spd_txt = string.format("%3d",temp_spd_rest) .. "/"
											-- type_to_fmc(temp_spd_txt)
											-- simCMD_FMS_key_2R:once()
										-- elseif temp_key == 2 then
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_3R:once()
											-- temp_spd_txt = string.format("%3d",temp_spd_rest) .. "/"
											-- type_to_fmc(temp_spd_txt)
											-- simCMD_FMS_key_3R:once()
										-- elseif temp_key == 3 then
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_4R:once()
											-- temp_spd_txt = string.format("%3d",temp_spd_rest) .. "/"
											-- type_to_fmc(temp_spd_txt)
											-- simCMD_FMS_key_4R:once()
										-- elseif temp_key == 4 then
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_5R:once()
											-- temp_spd_txt = string.format("%3d",temp_spd_rest) .. "/"
											-- type_to_fmc(temp_spd_txt)
											-- simCMD_FMS_key_5R:once()
										-- elseif temp_key == 5 then
											-- simCMD_FMS_key_next:once()
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_1R:once()
											-- temp_spd_txt = string.format("%3d",temp_spd_rest) .. "/"
											-- type_to_fmc(temp_spd_txt)
											-- simCMD_FMS_key_1R:once()
										-- end
									--end
								end
							end
						end
					end
				end
			end
		elseif B738DR_flight_phase > 4 then
		--elseif desc_enable == 1 then
			if B738DR_mcp_alt_dial < (simDR_altitude_pilot - 300) then
			-- delete alt restricts to MCP alt
				end_idx = legs_num
				if end_idx > offset then
					for n = offset, end_idx do
						-- find alt restrict
						if legs_restr_alt_n > 0 then	-- if exist alt restricts
							for nn = 1, legs_restr_alt_n do
								if legs_restr_alt[nn][2] > end_idx then
									-- no alt restricts to END of ROUTE
									break
								end
								delete_enabled = 0
								if legs_restr_alt[nn][2] == n and legs_restr_alt[nn][3] > B738DR_mcp_alt_dial then	-- alt restrict found
									delete_enabled = 1
								end
								if legs_restr_alt[nn][2] == n and legs_restr_alt[nn][3] == B738DR_mcp_alt_dial and legs_restr_alt[nn][4] == 43 then	-- A alt restrict found
									delete_enabled = 1
								end
								if delete_enabled == 1 then
									-- exist spd restrict
									temp_spd_rest = 0
									if legs_restr_spd_n > 0 then
										for nnn = 1, legs_restr_spd_n do
											if legs_restr_spd[nnn][2] == n then
												temp_spd_rest = legs_restr_spd[nnn][3]
												break
											end
										end
									end
									--if n == offset then
										-- not write to default FMC
										legs_data[n][5] = 0
										legs_data[n][6] = 0
										if temp_spd_rest > 0 then
											legs_data[n][4] = temp_spd_rest
										end
									--else
										-- write to default FMC
										-- legs_data[n][5] = 0
										-- legs_data[n][6] = 0
										-- if temp_spd_rest > 0 then
											-- legs_data[n][4] = temp_spd_rest
										-- end
										
										-- restrict_deleted = 1
										-- simCMD_FMS_key_legs:once()
										-- -- find page on default FMC
										-- temp_page = math.floor ((n-offset) / 5)
										-- --temp_page = (n-offset) % 5
										-- temp_key = temp_page * 5 + (n-offset+1)
										-- while temp_page > 0 do
											-- simCMD_FMS_key_next:once()
											-- temp_page = temp_page - 1
										-- end
										-- if temp_key == 1 then
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_2R:once()
											-- temp_spd_txt = string.format("%3d",temp_spd_rest) .. "/"
											-- type_to_fmc(temp_spd_txt)
											-- simCMD_FMS_key_2R:once()
										-- elseif temp_key == 2 then
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_3R:once()
											-- temp_spd_txt = string.format("%3d",temp_spd_rest) .. "/"
											-- type_to_fmc(temp_spd_txt)
											-- simCMD_FMS_key_3R:once()
										-- elseif temp_key == 3 then
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_4R:once()
											-- temp_spd_txt = string.format("%3d",temp_spd_rest) .. "/"
											-- type_to_fmc(temp_spd_txt)
											-- simCMD_FMS_key_4R:once()
										-- elseif temp_key == 4 then
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_5R:once()
											-- temp_spd_txt = string.format("%3d",temp_spd_rest) .. "/"
											-- type_to_fmc(temp_spd_txt)
											-- simCMD_FMS_key_5R:once()
										-- elseif temp_key == 5 then
											-- simCMD_FMS_key_next:once()
											-- simCMD_FMS_key_delete:once()
											-- simCMD_FMS_key_1R:once()
											-- temp_spd_txt = string.format("%3d",temp_spd_rest) .. "/"
											-- type_to_fmc(temp_spd_txt)
											-- simCMD_FMS_key_1R:once()
										-- end
									--end
								end
							end
						end
					end
				end
			end
		end
		-- if restrict_deleted == 1 then
			-- -- reload flightplan
			-- simCMD_FMS_key_delete:once()
			-- simCMD_FMS_key_clear:once()
			-- -- save flight plan
			-- simCMD_FMS_key_fpln:once()
			-- simCMD_FMS_key_delete:once()
			-- simCMD_FMS_key_clear:once()
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_1L:once()
			-- type_to_fmc("B738X")
			-- simCMD_FMS_key_6L:once()
			-- simCMD_FMS_key_clear:once()
			-- -- reload flight plan
			-- read_fpln2()
			-- -- to dep_arr
			-- simCMD_FMS_key_legs:once()
			-- act_page = 1
		-- end
		
		end	-- vnav status == 1
		
	elseif phase == 2 then
		B738DR_autopilot_alt_interv_pos = 0
	end
end

--*************************************************************************************--
--** 				                 X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

B738CMD_fmc1_1L = create_command("laminar/B738/button/fmc1_1L", "FMC capt 1L", B738_fmc1_1L_CMDhandler)
B738CMD_fmc1_2L = create_command("laminar/B738/button/fmc1_2L", "FMC capt 2L", B738_fmc1_2L_CMDhandler)
B738CMD_fmc1_3L = create_command("laminar/B738/button/fmc1_3L", "FMC capt 3L", B738_fmc1_3L_CMDhandler)
B738CMD_fmc1_4L = create_command("laminar/B738/button/fmc1_4L", "FMC capt 4L", B738_fmc1_4L_CMDhandler)
B738CMD_fmc1_5L = create_command("laminar/B738/button/fmc1_5L", "FMC capt 5L", B738_fmc1_5L_CMDhandler)
B738CMD_fmc1_6L = create_command("laminar/B738/button/fmc1_6L", "FMC capt 6L", B738_fmc1_6L_CMDhandler)

B738CMD_fmc1_1R = create_command("laminar/B738/button/fmc1_1R", "FMC capt 1R", B738_fmc1_1R_CMDhandler)
B738CMD_fmc1_2R = create_command("laminar/B738/button/fmc1_2R", "FMC capt 2R", B738_fmc1_2R_CMDhandler)
B738CMD_fmc1_3R = create_command("laminar/B738/button/fmc1_3R", "FMC capt 3R", B738_fmc1_3R_CMDhandler)
B738CMD_fmc1_4R = create_command("laminar/B738/button/fmc1_4R", "FMC capt 4R", B738_fmc1_4R_CMDhandler)
B738CMD_fmc1_5R = create_command("laminar/B738/button/fmc1_5R", "FMC capt 5R", B738_fmc1_5R_CMDhandler)
B738CMD_fmc1_6R = create_command("laminar/B738/button/fmc1_6R", "FMC capt 6R", B738_fmc1_6R_CMDhandler)

B738CMD_fmc1_0 = create_command("laminar/B738/button/fmc1_0", "FMC capt 0", B738_fmc1_0_CMDhandler)
B738CMD_fmc1_1 = create_command("laminar/B738/button/fmc1_1", "FMC capt 1", B738_fmc1_1_CMDhandler)
B738CMD_fmc1_2 = create_command("laminar/B738/button/fmc1_2", "FMC capt 2", B738_fmc1_2_CMDhandler)
B738CMD_fmc1_3 = create_command("laminar/B738/button/fmc1_3", "FMC capt 3", B738_fmc1_3_CMDhandler)
B738CMD_fmc1_4 = create_command("laminar/B738/button/fmc1_4", "FMC capt 4", B738_fmc1_4_CMDhandler)
B738CMD_fmc1_5 = create_command("laminar/B738/button/fmc1_5", "FMC capt 5", B738_fmc1_5_CMDhandler)
B738CMD_fmc1_6 = create_command("laminar/B738/button/fmc1_6", "FMC capt 6", B738_fmc1_6_CMDhandler)
B738CMD_fmc1_7 = create_command("laminar/B738/button/fmc1_7", "FMC capt 7", B738_fmc1_7_CMDhandler)
B738CMD_fmc1_8 = create_command("laminar/B738/button/fmc1_8", "FMC capt 8", B738_fmc1_8_CMDhandler)
B738CMD_fmc1_9 = create_command("laminar/B738/button/fmc1_9", "FMC capt 9", B738_fmc1_9_CMDhandler)

B738CMD_fmc1_period = create_command("laminar/B738/button/fmc1_period", "FMC capt .", B738_fmc1_period_CMDhandler)
B738CMD_fmc1_minus = create_command("laminar/B738/button/fmc1_minus", "FMC capt -", B738_fmc1_minus_CMDhandler)
B738CMD_fmc1_slash = create_command("laminar/B738/button/fmc1_slash", "FMC capt SLASH", B738_fmc1_slash_CMDhandler)

B738CMD_fmc1_A = create_command("laminar/B738/button/fmc1_A", "FMC capt A", B738_fmc1_A_CMDhandler)
B738CMD_fmc1_B = create_command("laminar/B738/button/fmc1_B", "FMC capt B", B738_fmc1_B_CMDhandler)
B738CMD_fmc1_C = create_command("laminar/B738/button/fmc1_C", "FMC capt C", B738_fmc1_C_CMDhandler)
B738CMD_fmc1_D = create_command("laminar/B738/button/fmc1_D", "FMC capt D", B738_fmc1_D_CMDhandler)
B738CMD_fmc1_E = create_command("laminar/B738/button/fmc1_E", "FMC capt E", B738_fmc1_E_CMDhandler)
B738CMD_fmc1_F = create_command("laminar/B738/button/fmc1_F", "FMC capt F", B738_fmc1_F_CMDhandler)
B738CMD_fmc1_G = create_command("laminar/B738/button/fmc1_G", "FMC capt G", B738_fmc1_G_CMDhandler)
B738CMD_fmc1_H = create_command("laminar/B738/button/fmc1_H", "FMC capt H", B738_fmc1_H_CMDhandler)
B738CMD_fmc1_I = create_command("laminar/B738/button/fmc1_I", "FMC capt I", B738_fmc1_I_CMDhandler)
B738CMD_fmc1_J = create_command("laminar/B738/button/fmc1_J", "FMC capt J", B738_fmc1_J_CMDhandler)
B738CMD_fmc1_K = create_command("laminar/B738/button/fmc1_K", "FMC capt K", B738_fmc1_K_CMDhandler)
B738CMD_fmc1_L = create_command("laminar/B738/button/fmc1_L", "FMC capt L", B738_fmc1_L_CMDhandler)
B738CMD_fmc1_M = create_command("laminar/B738/button/fmc1_M", "FMC capt M", B738_fmc1_M_CMDhandler)
B738CMD_fmc1_N = create_command("laminar/B738/button/fmc1_N", "FMC capt N", B738_fmc1_N_CMDhandler)
B738CMD_fmc1_O = create_command("laminar/B738/button/fmc1_O", "FMC capt O", B738_fmc1_O_CMDhandler)
B738CMD_fmc1_P = create_command("laminar/B738/button/fmc1_P", "FMC capt P", B738_fmc1_P_CMDhandler)
B738CMD_fmc1_Q = create_command("laminar/B738/button/fmc1_Q", "FMC capt Q", B738_fmc1_Q_CMDhandler)
B738CMD_fmc1_R = create_command("laminar/B738/button/fmc1_R", "FMC capt R", B738_fmc1_R_CMDhandler)
B738CMD_fmc1_S = create_command("laminar/B738/button/fmc1_S", "FMC capt S", B738_fmc1_S_CMDhandler)
B738CMD_fmc1_T = create_command("laminar/B738/button/fmc1_T", "FMC capt T", B738_fmc1_T_CMDhandler)
B738CMD_fmc1_U = create_command("laminar/B738/button/fmc1_U", "FMC capt U", B738_fmc1_U_CMDhandler)
B738CMD_fmc1_V = create_command("laminar/B738/button/fmc1_V", "FMC capt V", B738_fmc1_V_CMDhandler)
B738CMD_fmc1_W = create_command("laminar/B738/button/fmc1_W", "FMC capt W", B738_fmc1_W_CMDhandler)
B738CMD_fmc1_X = create_command("laminar/B738/button/fmc1_X", "FMC capt X", B738_fmc1_X_CMDhandler)
B738CMD_fmc1_Y = create_command("laminar/B738/button/fmc1_Y", "FMC capt Y", B738_fmc1_Y_CMDhandler)
B738CMD_fmc1_Z = create_command("laminar/B738/button/fmc1_Z", "FMC capt Z", B738_fmc1_Z_CMDhandler)
B738CMD_fmc1_SP = create_command("laminar/B738/button/fmc1_SP", "FMC capt Z", B738_fmc1_SP_CMDhandler)



B738CMD_fmc1_clr = create_command("laminar/B738/button/fmc1_clr", "FMC capt CLR", B738_fmc1_clr_CMDhandler)
B738CMD_fmc1_del = create_command("laminar/B738/button/fmc1_del", "FMC capt DEL", B738_fmc1_del_CMDhandler)

B738CMD_fmc1_prev_page = create_command("laminar/B738/button/fmc1_prev_page", "FMC capt PREV PAGE", B738_fmc1_prev_page_CMDhandler)
B738CMD_fmc1_next_page = create_command("laminar/B738/button/fmc1_next_page", "FMC capt NEXT PAGE", B738_fmc1_next_page_CMDhandler)

B738CMD_fmc1_init_ref = create_command("laminar/B738/button/fmc1_init_ref", "FMC capt INIT REF", B738_fmc1_init_ref_CMDhandler)
B738CMD_fmc1_menu = create_command("laminar/B738/button/fmc1_menu", "FMC capt MENU", B738_fmc1_menu_CMDhandler)
B738CMD_fmc1_n1_lim = create_command("laminar/B738/button/fmc1_n1_lim", "FMC capt N1 LIMIT", B738_fmc1_n1_lim_CMDhandler)
B738CMD_fmc1_rte = create_command("laminar/B738/button/fmc1_rte", "FMC capt RTE", B738_fmc1_rte_CMDhandler)
B738CMD_fmc1_legs = create_command("laminar/B738/button/fmc1_legs", "FMC capt LEGS", B738_fmc1_legs_CMDhandler)
B738CMD_fmc1_fix = create_command("laminar/B738/button/fmc1_fix", "FMC capt FIX", B738_fmc1_fix_CMDhandler)
B738CMD_fmc1_clb = create_command("laminar/B738/button/fmc1_clb", "FMC capt CLB", B738_fmc1_clb_CMDhandler)
B738CMD_fmc1_crz = create_command("laminar/B738/button/fmc1_crz", "FMC capt CRZ", B738_fmc1_crz_CMDhandler)
B738CMD_fmc1_des = create_command("laminar/B738/button/fmc1_des", "FMC capt DES", B738_fmc1_des_CMDhandler)
B738CMD_fmc1_dep_app = create_command("laminar/B738/button/fmc1_dep_app", "FMC capt DEP/APP", B738_fmc1_dep_app_CMDhandler)
B738CMD_fmc1_hold = create_command("laminar/B738/button/fmc1_hold", "FMC capt HOLD", B738_fmc1_hold_CMDhandler)
B738CMD_fmc1_prog = create_command("laminar/B738/button/fmc1_prog", "FMC capt PROG", B738_fmc1_prog_CMDhandler)
B738CMD_fmc1_exec = create_command("laminar/B738/button/fmc1_exec", "FMC capt EXEC", B738_fmc1_exec_CMDhandler)

B738CMD_autopilot_alt_interv		= create_command("laminar/B738/autopilot/alt_interv", "ALT intervention", B738_autopilot_alt_interv_CMDhandler)


--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

----- ANIMATION UTILITY -----------------------------------------------------------------
function B738_set_animation_position(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * SIM_PERIOD))
    end

end

------------------------------------------


----------------------------------------------------------------------------------------------------



function B738_fmc_menu()

	if page_menu == 1 then
		act_page = 1
		max_page = 1
		local units_str_l = "   /KGS>"
		local units_str_s = "LBS     "
		if units == 0 then
			units_str_l = "LBS/   >"
			units_str_s = "    KGS "
		end
		line0_l = "         MENU           "
		line0_s = "                        "
		line1_x = "                        "
		line1_l = "<FMC              RESET>"
		line1_s = "                        "
		line2_x = "                  UNITS "
		line2_l = "<ACARS          " .. units_str_l
		line2_s = "                " .. units_str_s
		line3_x = "                        "
		line3_l = "                  XTRAS>"
		line3_s = "                        "
		-- line4_x = "                        "
		-- line4_l = "  Z I B O               "
		-- line4_s = "           M O D  " .. version
		-- line5_x = "                        "
		-- line5_l = "                        "
		-- line5_s = "                        "
		-- line6_x = "FLIGHT MODEL            "
		-- line6_l = "         A   S  D  G    "
		-- line6_s = "      BY  ERO IM EV ROUP"
		---------
		line4_x = "                        "
		line4_l = "  Z I B O               "
		line4_s = "           M O D  " .. version
		line5_x = "FLIGHT MODEL V3.0       "
		line5_l = "         A   S  D  G    "
		line5_s = "      BY  ERO IM EV ROUP"
		line6_x = "SOUND PACK "
		if string.len(fmod_version) > 13 then
			line6_x = line6_x .. string.sub(fmod_version, 1, 13)
		else
			line6_x = line6_x .. fmod_version
		end
		line6_l = "            A    B    XP"
		line6_s = "         BY  UDIO IRD   "
		---------
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end

function B738_fmc_xtras()

	if page_xtras == 1 then
		act_page = 1
		max_page = 1
		
		line0_l = "       XTRAS MENU       "
		line0_s = "                    1/1 "
		line1_x = "                        "
		line1_l = "<FMOD SOUNDS            "
		line1_s = "                        "
		line2_x = "                        "
		line2_l = "<OTHERS                 "
		line2_s = "                        "
		line3_x = "                        "
		line3_l = "                        "
		line3_s = "                        "
		line4_x = "                        "
		line4_l = "                        "
		line4_s = "                        "
		line5_x = "                        "
		line5_l = "                        "
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<SAVE              MENU>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end
end

function B738_fmc_xtras_fmod()

	if page_xtras_fmod == 1 then
		act_page = 1
		max_page = 4
		
		line0_l = "       FMOD SOUNDS      "
		line0_s = "                    1/4 "
		line1_x = " PAX BOARD              "
		if B738DR_enable_pax_boarding == 0 then
			line1_l = "<  /                    "
			line1_g = "    OFF                 "
			line1_s = " ON                     "
		else
			line1_l = "<  /                    "
			line1_g = " ON                     "
			line1_s = "    OFF                  "
		end
		line2_x = " CHATTER PASS           "
		if B738DR_enable_chatter == 0 then
			line2_l = "<  /                    "
			line2_g = "    OFF                 "
			line2_s = " ON                     "
		else
			line2_l = "<  /                    "
			line2_g = " ON                     "
			line2_s = "    OFF                 "
		end
		line3_x = " CREW ANNOUN            "
		if B738DR_enable_crew == 0 then
			line3_l = "<  /                    "
			line3_g = "    OFF                 "
			line3_s = " ON                     "
		else
			line3_l = "<  /                    "
			line3_g = " ON                     "
			line3_s = "    OFF                 "
		end
		line4_x = " AIRPORT                "
		if B738DR_airport_set == 1 then
			line4_l = "<   /    /              "
			line4_g = " REG                    "
			line4_s = "     BUSY OFF           "
		elseif B738DR_airport_set == 2 then
			line4_l = "<   /    /              "
			line4_g = "     BUSY               "
			line4_s = " REG      OFF           "
		else
			line4_l = "<   /    /              "
			line4_g = "          OFF           "
			line4_s = " REG BUSY               "
		end
		line5_x = " GYRO VIBRATORS         "
		if B738DR_enable_gyro == 0 then
			line5_l = "<  /                    "
			line5_g = "    OFF                 "
			line5_s = " ON                     "
		else
			line5_l = "<  /                    "
			line5_g = " ON                     "
			line5_s = "    OFF                 "
		end
	
		line6_x = "                        "
		line6_l = "<DEFAULT           BACK>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	
	elseif page_xtras_fmod == 2 then
		act_page = 2
		max_page = 4
		
		line0_l = "       FMOD SOUNDS      "
		line0_s = "                    2/4 "
		line1_x = " INTERNAL VOL           "
		if B738DR_vol_int_ducker == 0 then
			line1_l = "<  /                    "
			line1_g = " ON                     "
			line1_s = "    DUCK                "
		else
			line1_l = "<  /                    "
			line1_g = "    DUCK                "
			line1_s = " ON                     "
		end
		line2_x = " INT ENGINE SOUNDS      "
		line2_g = "  " .. string.format("%2d", B738DR_vol_int_eng)
		line2_l = "<     /0-10/"
		line2_s = "                        "
		line3_x = " INT ENG START/STOP     "
		line3_g = "  " .. string.format("%2d", B738DR_vol_int_start)
		line3_l = "<     /0-10/"
		line3_s = "                        "
		line4_x = " AC FANS                "
		line4_g = "  " .. string.format("%2d", B738DR_vol_int_ac)
		line4_l = "<     /0-10/"
		line4_s = "                        "
		line5_x = " GYRO VOL               "
		line5_g = "  " .. string.format("%2d", B738DR_vol_int_gyro)
		line5_l = "<     /0-10/"
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<DEFAULT           BACK>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	elseif page_xtras_fmod == 3 then
		act_page = 3
		max_page = 4
		
		line0_l = "       FMOD SOUNDS      "
		line0_s = "                    3/4 "
		line1_x = " ROLL VOL               "
		line1_g = "  " .. string.format("%2d", B738DR_vol_int_roll)
		line1_l = "<     /0-10/"
		line1_s = "                        "
		line2_x = " BUMP INTENS            "
		line2_g = "  " .. string.format("%2d", B738DR_vol_int_bump)
		line2_l = "<     /0-10/"
		line2_s = "                        "
		line3_x = " PAX VOLUME             "
		line3_g = "  " .. string.format("%2d", B738DR_vol_int_pax)
		line3_l = "<     /0-10/"
		line3_s = "                        "
		line4_x = " PAX APPLAUSE           "
		if B738DR_vol_int_pax_applause == 0 then
			line4_l = "<  /                    "
			line4_g = "    OFF                 "
			line4_s = " ON                     "
		else
			line4_l = "<  /                    "
			line4_g = " ON                     "
			line4_s = "    OFF                 "
		end
		line5_x = " INT WIND VOL           "
		line5_g = "  " .. string.format("%2d", B738DR_vol_int_wind)
		line5_l = "<     /0-10/"
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<DEFAULT           BACK>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	elseif page_xtras_fmod == 4 then
		act_page = 4
		max_page = 4
		line0_l = "       FMOD SOUNDS      "
		line0_s = "                    4/4 "
		line1_x = " MUTE TRIM WHEEL        "
		if B738DR_enable_mutetrim == 0 then
			line1_l = "<  /                    "
			line1_g = "    OFF                 "
			line1_s = " ON                     "
		else
			line1_l = "<  /                    "
			line1_g = " ON                     "
			line1_s = "    OFF                  "
		end
		line2_x = " AIRPORT IN/OUT VOL     "
		line2_g = "  " .. string.format("%2d", B738DR_vol_airport)
		line2_l = "<     /0-10/"
		line2_s = "                        "
		line3_x = ""
		line3_l = ""
		line3_s = ""
		line4_x = ""
		line4_l = ""
		line4_s = ""
		line5_x = ""
		line5_l = ""
		line5_s = ""
		line6_x = "                        "
		line6_l = "<DEFAULT           BACK>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end
end

function B738_fmc_xtras_others()

	if page_xtras_others == 1 then
		act_page = 1
		max_page = 3
		
		line0_l = "       OTHERS           "
		line0_s = "                    1/3 "
		line1_x = " ALIGN TIME             "
		if B738DR_align_time == 0 then
			line1_l = "<    /    /             "
			line1_g = " REAL                   "
			line1_s = "      LONG SHORT        "
		elseif B738DR_align_time == 1 then
			line1_l = "<    /    /             "
			line1_g = "      LONG              "
			line1_s = " REAL      SHORT        "
		else
			line1_l = "<    /    /             "
			line1_g = "           SHORT        "
			line1_s = " REAL LONG              "
		end
		line2_x = " HIDE YOKE              "
		if simDR_hide_yoke == 0 then
			line2_l = "<    /                  "
			line2_g = " HIDE                   "
			line2_s = "      SHOW              "
		else
			line2_l = "<    /                  "
			line2_g = "      SHOW              "
			line2_s = " HIDE                   "
		end
		line3_x = " CHOCK                  "
		if B738DR_chock_status == 0 then
			line3_l = "<   /                   "
			line3_g = " OFF                    "
			line3_s = "     ON                 "
		else
			line3_l = "<   /                   "
			line3_g = "     ON                 "
			line3_s = " OFF                    "
		end
		line4_x = " PAUSE AT T/D           "
		if B738DR_pause_td == 0 then
			line4_l = "<   /                   "
			line4_g = " OFF                    "
			line4_s = "     ON                 "
		else
			line4_l = "<   /                   "
			line4_g = "     ON                 "
			line4_s = " OFF                    "
		end
		line5_x = " TOE BRAKE AXIS         "
		if B738DR_toe_brakes_ovr == 0 then
			line5_l = "<   /                   "
			line5_g = "     ON                 "
			line5_s = " OFF                    "
		else
			line5_l = "<   /                   "
			line5_g = " OFF                    "
			line5_s = "     ON                 "
		end
		line6_x = "                        "
		line6_l = "<DEFAULT           BACK>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	elseif page_xtras_others == 2 then
		act_page = 2
		max_page = 3
		
		line0_l = "       OTHERS           "
		line0_s = "                    2/3 "
		line1_x = " ENGINE NO RUNNING STATE"
		if B738DR_engine_no_running_state == 0 then
			line1_l = "<         /             "
			line1_g = " COLD-DARK              "
			line1_s = "           TURN AROUND  "
		else
			line1_l = "<         /             "
			line1_g = "           TURN AROUND  "
			line1_s = " COLD-DARK              "
		end
		line2_x = " PARKBRAKE REMOVE CHOCKS"
		if B738DR_parkbrake_remove_chock == 0 then
			line2_l = "<   /                   "
			line2_g = " OFF                    "
			line2_s = "     ON                 "
		else
			line2_l = "<   /                   "
			line2_g = "     ON                 "
			line2_s = " OFF                    "
		end
		line3_x = " THROTTLE NOISE LOCK    "
		if B738DR_throttle_noise == 0 then
			line3_g = " OFF"
		else
			line3_g = "  " .. string.format("%2d", B738DR_throttle_noise)
		end
		line3_l = "<     /OFF,1-10/"
		line3_s = "                        "
		line4_x = " FUEL GAUAGE            "
		if B738DR_fuelgauge == 0 then
			line4_l = "<          /            "
			line4_g = " SIDEBYSIDE             "
			line4_s = "            OVERUNDER   "
		else
			line4_l = "<          /            "
			line4_g = "            OVERUNDER   "
			line4_s = " SIDEBYSIDE             "
		end
		line5_x = " NOSEWHEEL AXIS         "
		if B738DR_nosewheel == 0 then
			line5_l = "<  /                    "
			line5_g = " ON                     "
			line5_s = "    YAW                 "
		else
			line5_l = "<  /                    "
			line5_g = "    YAW                 "
			line5_s = " ON                     "
		end
		line6_x = "                        "
		line6_l = "<DEFAULT           BACK>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	elseif page_xtras_others == 3 then
		act_page = 3
		max_page = 3
		
		line0_l = "       OTHERS           "
		line0_s = "                    3/3 "
		line1_x = " FLIGHTPLAN SAVE FORMAT "
		if B738DR_fpln_format == 0 then
			line1_l = "<   /                   "
			line1_g = " FMX                    "
			line1_s = "     FMS                "
		else
			line1_l = "<   /                   "
			line1_g = "     FMS                "
			line1_s = " FMX                    "
		end
	end
end

function B738_fmc_ident()

	if page_ident == 1 then
		act_page = 1
		max_page = 1
		line0_l = "      IDENT             "
		line0_s = "                    1/2 "
		line1_x = " MODEL        ENG RATING"
		line1_l = "737-800WL            26K"
		line1_s = "                        "
		line2_x = " NAV DATA         ACTIVE"
		line2_l = B738_navdata .. " "
		line2_l = line2_l .. B738_navdata_active
		--line2_l = "0428170103 APR28MAY28/17"
		line2_s = "                        "
		line3_x = "                        "
		line3_l = "                        "	--JAN02FEB01/17"
		line3_s = "                        "
		line4_x = " OP PROGRAM             "
		line4_l = "556909-001  (U11.0)     "
		line4_s = "                        "
		line5_x = "               SUPP DATA"
		line5_l = "                        "
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<INDEX         POS INIT>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	elseif page_ident == 2 then
		act_page = 2
		max_page = 2
		line0_l = "      IDENT             "
		line0_s = "                    2/2 "
		line1_x = " MODEL        ENG RATING"
		line1_l = "737-800WL            26K"
		line1_s = "                        "
		line2_x = " NAV DATA         ACTIVE"
		line2_l = "0402170101 FEB04MAR04/17"
		line2_s = "                        "
		line3_x = "                        "
		line3_l = "           JAN02FEB01/17"
		line3_s = "                        "
		line4_x = " OP PROGRAM             "
		line4_l = "556909-001  (U11.0)     "
		line4_s = "                        "
		line5_x = "               SUPP DATA"
		line5_l = "                        "
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<INDEX         POS INIT>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end

function pos_to_str(pos_pos)
	local position2 = pos_pos
	local pos_str2 = ""
	pos_str2 = string.sub(position2, 1, 3) .. "`"
	pos_str2 = pos_str2 .. string.sub(position2, 4, 7)
	pos_str2 = pos_str2 .. " "
	pos_str2 = pos_str2 .. string.sub(position2, 8, 11)
	pos_str2 = pos_str2 .. "`"
	pos_str2 = pos_str2 .. string.sub(position2, 12, 15)
	return pos_str2
end

function B738_fmc_pos_init()

	if page_pos_init == 1 then
		act_page = 1
		max_page = 2
		line0_l = "    POS INIT            "
		line0_s = "                    1/3 "
		pos_str = pos_to_str(last_pos)
		line1_x = "                LAST POS"
		line1_l = "      " .. pos_str
		line1_s = "                        "
		line2_x = "REF AIRPORT             "
		--line2_l = ref_icao .. "                    "
		line2_l = ref_icao
		if ref_icao_pos ~= "               " then
			line2_l = line2_l .. "  ".. pos_to_str(ref_icao_pos)
		end
		line2_s = "                        "
		line3_x = "GATE                    "
		line3_l = (ref_gate .. "                   ")
		line3_s = "                        "
		local align_mode = 0
		
		if B738DR_irs_left_mode == 1 and B738DR_irs_left == 2 then
			align_mode = 1
		end
		if B738DR_irs_right_mode == 1 and B738DR_irs_right == 2 then
			align_mode = 1
		end
		if B738DR_irs_left_mode == 2 or B738DR_irs_right_mode == 2 then
			align_mode = 0
		end
		if align_mode == 1 then
			pos_str = pos_to_str(irs_pos)
			line4_x = "             SET IRS POS"
			line4_l = "      " .. pos_str
			disable_POS_4R = 0
		else
			line4_x = "                        "
			line4_l = "                        "
			-- if entry == ENTER_IRS_POS then
				-- entry = ""
			-- end
			disable_POS_4R = 1
			irs_pos = ""
			--irs_pos = "*****.*******.*"
		end
		
		-- if B738DR_irs_left_mode == 1 and B738DR_irs_left == 2 then
			-- align_mode = 1
		-- end
		-- if B738DR_irs_right_mode == 1 and B738DR_irs_right == 2 then
			-- align_mode = 1
		-- end
		-- -- if B738DR_irs_left_mode > 1 or B738DR_irs_right_mode > 1 then
			-- -- align_mode = 2
		-- -- end
		-- if B738DR_irs_left_mode == 2 or B738DR_irs_right_mode == 2 then
			-- align_mode = 2
		-- end
		-- line4_x = "             SET IRS POS"
		-- -- pos_str = pos_to_str(irs_pos)
		-- -- line4_l = "      " .. pos_str
		-- disable_POS_4R = 0
		-- if align_mode > 0 then
			-- --pos_str = pos_to_str(irs_pos)
			-- --line4_x = "             SET IRS POS"
			-- --line4_l = "      " .. pos_str
			-- --disable_POS_4R = 0
			-- --irs_pos = last_pos
			-- pos_str = pos_to_str(irs_pos)
			-- line4_l = "      " .. pos_str
		-- else
			-- if entry == ENTER_IRS_POS then
				-- entry = ""
			-- end
			-- -- if B738DR_irs_left_mode > 1 or B738DR_irs_right_mode > 1 then
				-- -- pos_str = pos_to_str(irs_pos)
			-- -- else
			-- --line4_x = "                        "
			-- --line4_l = "                        "
			-- --disable_POS_4R = 0
				-- irs_pos = "*****.*******.*"
			-- -- end
			-- pos_str = pos_to_str(irs_pos)
			-- line4_l = "      " .. pos_str
			-- --irs_pos = last_pos
		-- end
		
		
		line4_s = "                        "
		align_mode = 0
		if B738DR_irs_left_mode == 1 and B738DR_irs_left == 3 then
			align_mode = 1
		end
		if B738DR_irs_right_mode == 1 and B738DR_irs_right == 3 then
			align_mode = 1
		end
		if B738DR_irs_left_mode == 3 or B738DR_irs_right_mode == 3 then
			align_mode = 0
		end
		if align_mode == 1 then
			line5_x = "GMT-MON/DY   SET IRS HDG"
			line5_l = zulu_time .. "       "
			line5_l = line5_l .. irs_hdg
			disable_POS_5R = 0
		else
			line5_x = "GMT-MON/DY              "
			line5_l = zulu_time .. "           "
			-- if entry == ENTER_IRS_HDG then
				-- entry = ""
			-- end
			disable_POS_5R = 1
			irs_hdg = "---`"
		end
		line5_s = "                        "
		line6_x = "------------------------"
		line6_l = "<INDEX            ROUTE>"
		line6_s = "                        "
		if ref_icao == "----" then
			disable_POS_3L = 1
		else
			disable_POS_3L = 0
		end
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	elseif page_pos_init == 2 then
		act_page = 2
		max_page = 2
		line0_l = "    POS REF             "
		line0_s = "                    2/3 "
		line1_x = " FMC POS              GS"
		line1_l = pos_to_str(fmc_pos) .. " "
		line1_l = line1_l .. fmc_gs
		line1_s = "                      KT"
		pos_str = pos_to_str(B738DR_irs_pos)
		line2_x = " IRS L                  "
		line2_l = pos_str .. " "
		line2_l = line2_l .. irs_gs
		line2_s = "                      KT"
		pos_str = pos_to_str(B738DR_irs2_pos)
		line3_x = " IRS R                  "
		line3_l = pos_str .. " "
		line3_l = line3_l .. irs2_gs
		line3_s = "                      KT"
		pos_str = pos_to_str(B738DR_gps_pos)
		line4_x = " GPS L                  "
		line4_l = pos_str .. "     "
		line4_s = "                        "
		pos_str = pos_to_str(B738DR_gps2_pos)
		line5_x = " GPS R                  "
		line5_l = pos_str .. "     "
		line5_s = "                        "
		line6_x = " RADIO                  "
		line6_l = "                        "
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end

function B738_fmc_rte_init()

	if page_rte_init == 1 then
		--act_page = 1
		
		local ref_icao_disp = ""
		local ii = 0
		local fpln_len = 0
		
		local ii = 0
		local jj = 0
		local kk = 0
		local ll = 0
		
		local temp_str = ""
		local temp_num = 0
		local temp_num2 = 0
		
		local max_page_fpln = 0
		
		local left_line = {}
		left_line[1] = ""
		left_line[2] = ""
		left_line[3] = ""
		left_line[4] = ""
		left_line[5] = ""
		local right_line = {}
		right_line[1] = ""
		right_line[2] = ""
		right_line[3] = ""
		right_line[4] = ""
		right_line[5] = ""
		local left_line_x = {}
		left_line_x[1] = ""
		left_line_x[2] = ""
		left_line_x[3] = ""
		left_line_x[4] = ""
		left_line_x[5] = ""
		left_line_x[6] = "------------------------"
		
		local sid_len = 0
		local txt_dspl = ""
		
		if ref_icao == "----" then
			ref_icao_disp = "****"
		else
			if simDR_radio_height_pilot_ft > 50 then
				ref_icao_disp = "    "
			else
				ref_icao_disp = ref_icao
			end
		end
		
		if act_page == 1 then
			if B738DR_fms_exec_light_pilot == 1 then
				line0_inv = " MOD"
				line0_l   = "     "
			else
				if ref_icao == "----" or des_icao == "****" then
					line0_l = "     "
				else
					line0_l = " ACT "
				end
				line0_inv = ""
			end
			line1_x = " ORIGIN             DEST"
			line1_l = ref_icao_disp .. "                "
			line1_l = line1_l .. des_icao_x
			line1_s = "                        "
			line2_x = " CO ROUTE        FLT NO."
			--line2_l = "--------        --------"
			temp_str = co_route
			if co_route ~= "------------" then
				temp_num2 = string.len(temp_str)
				if temp_num2 < 12 then
					for temp_num = temp_num2, 11 do
						temp_str = temp_str .. " "
					end
				end
			end
			line2_l = temp_str .. "    "
			temp_str = flt_num
			if flt_num ~= "--------" then
				temp_num2 = string.len(temp_str)
				if temp_num2 < 8 then
					for temp_num = temp_num2, 7 do
						temp_str = " " .. temp_str
					end
				end
			end
			line2_l = line2_l .. temp_str
			line2_s = "                        "
			line3_x = " RUNWAY                 "
			if was_on_air == 1 or ref_icao == "----" then
				line3_x = ""
				line3_l = "             SAVE ROUTE>"
			else
				line3_x = " RUNWAY                 "
				txt_dspl = ref_rwy
				sid_len = string.len(ref_rwy)
				if sid_len < 13 then
					for jj = sid_len, 12 do
						txt_dspl = txt_dspl .. " "
					end
				end
				line3_l = txt_dspl .. "SAVE ROUTE>"
			end
			line3_s = "                        "
			line4_x = "------------------------"
			line4_l = "                        "
			line4_s = "                        "
		
		end
		
		-- Flight plan
		if ref_icao == "----" or des_icao == "****" then
			max_page_fpln = 0
		else
			jj = math.floor(fpln_num2 / 5)
			kk = fpln_num2 % 5
			max_page_fpln = jj + 2
		end
		
		if act_page > 1 then
			
			if B738DR_fms_exec_light_pilot == 1 then
				line0_inv = " MOD"
				line0_l   = "     "
			else
				line0_l = " ACT "
				line0_inv = ""
			end
			
			kk = (act_page - 2) * 5
			for ii = 1, 5 do
				jj = kk + ii --(ii * 2) + 1
				
				
				if jj > fpln_num2 then
					if jj == fpln_num2 + 1 then
						if fpln_num2 > 1 then
							if fpln_data2[fpln_num2][2] ~= "" and fpln_data2[fpln_num2][1] == "" then
								left_line[ii] = "-----"
								right_line[ii] = ""
							else
								left_line[ii] = "-----"
								right_line[ii] = "-----"
							end
						elseif fpln_num2 > 0 then
							if fpln_data2[fpln_num2][2] ~= "" and fpln_data2[fpln_num2][1] == "" then
								left_line[ii] = ""
								right_line[ii] = ""
							else
								left_line[ii] = "-----"
								right_line[ii] = "-----"
							end
						else
							left_line[ii] = "-----"
							right_line[ii] = "-----"
						end
					else
						left_line[ii] = ""
						right_line[ii] = ""
					end
				else
					if fpln_data2[jj][2] == "" and fpln_data2[jj][1] == "" then
						left_line[ii] = "*****"
						right_line[ii] = "*****"
						left_line_x[ii+1] = "---- DISCONTINUITY -----"
					elseif fpln_data2[jj][2] == "" and fpln_data2[jj][1] ~= "" then
						left_line[ii] = "DIRECT"
						right_line[ii] = fpln_data2[jj][1]
					else
						left_line[ii] = fpln_data2[jj][2]
						if fpln_data2[jj][1] == "" then
							right_line[ii] = "*****"
							-- create discontinuity to line_x
							left_line_x[ii+1] = "---- DISCONTINUITY -----"
						else
							right_line[ii] = fpln_data2[jj][1]
						end
					end
				end
			end
			
			-- display engine
			for ii = 1, 5 do
				sid_len = string.len(left_line[ii])
				if sid_len < 12 then
					for jj = sid_len, 11 do
						left_line[ii] = left_line[ii] .. " "
					end
				end
				sid_len = string.len(right_line[ii])
				if sid_len < 12 then
					for jj = sid_len, 11 do
						right_line[ii] = " " .. right_line[ii]
					end
				end
			end
			line1_x = " VIA                 TO "
			-- line2_x = "                        "
			-- line3_x = "                        "
			-- line4_x = "                        "
			-- line5_x = "                        "
			line2_x = left_line_x[2]
			line3_x = left_line_x[3]
			line4_x = left_line_x[4]
			line5_x = left_line_x[5]
			line6_x = left_line_x[6]
			line1_l = left_line[1] .. right_line[1]
			line2_l = left_line[2] .. right_line[2]
			line3_l = left_line[3] .. right_line[3]
			line4_l = left_line[4] .. right_line[4]
			line5_l = left_line[5] .. right_line[5]
		
		end
		
		max_page = math.max(max_page_fpln, 1)
		
		line0_s = "                    " .. string.format("%1d",act_page)
		line0_s = line0_s .. "/"
		line0_s = line0_s .. string.format("%1d",max_page)
		
		line5_s = "                        "
		--line6_x = "------------------------"
		
		line0_l = line0_l .. "RTE                "
		
		if B738DR_fms_exec_light_pilot == 1 then
			-- line0_inv = " MOD"
			-- line0_l   = "     "
			line6_l = "<ERASE        PERF INIT>"
		else
			line6_l = "              PERF INIT>"
		end
		--line6_s = "                        "
		--line0_inv = ""
		--line1_inv = ""
		--line2_inv = ""
		--line3_inv = ""
		--line4_inv = ""
		--line5_inv = ""
		--line6_inv = ""
	end
	-- elseif page_rte_init > 1 then
		
		-- local max_page_rte = 0
		-- local act_page_rte = 0
		
		-- max_page = max_page_rte + 1
		-- act_page_rte = act_page - 1
		
		-- if simDR_fms_exec_light1 == 1 then
			-- line0_inv = " MOD"
			-- line0_l   = "     "
		-- else
			-- if fpln_num2 > 1 then
				-- line0_l = " ACT "
			-- else
				-- line0_l = "     "
			-- end
			-- line0_inv = ""
		-- end
		-- line0_l = line0_l .. "RTE                "
		
		-- --fpln_rte_data
		-- --fpln_rte_data_num
		
		
		
		-- --line0_l = line0_l .. "RTE                "
		-- --line0_l = "    INIT/REF INDEX      "
		-- --line0_s = "                    1/1 "
		-- line1_x = " VIA                  TO"
		-- line1_l = "LANU1B.LANUX       LANUX"
		-- line1_s = "                        "
		
		
		
		-- line2_x = "                        "
		-- line2_l = "DIRECT             TABEM"
		-- line2_s = "                        "
		-- line3_x = "                        "
		-- line3_l = "V336                 VLM"
		-- line3_s = "                        "
		-- line4_x = "                        "
		-- line4_l = "-----              -----"
		-- line4_s = "                        "
		-- line5_x = "                        "
		-- line5_l = "                        "
		-- line5_s = "                        "
		-- line6_x = "                        "
		-- line6_l = "               ACTIVATE>"
		-- line6_s = "                        "
		
		-- max_page = max_page_rte + 1
		-- line0_s = "                    " .. string.format("%1d",act_page)
		-- line0_s = line0_s .. "/"
		-- line0_s = line0_s .. string.format("%1d",max_page)
		
		-- -- displayed only during modifications
		-- --line6_l = "ERASE          ACTIVATE>"
		
		-- -- after activate route, ked nie je kompletne vyplnene
		-- --line6_l = "              PERF INIT>"
		-- --line6_l = "                TAKEOFF>"
		
		-- -- INVALID ENTRY
	-- end

end

function B738_fmc_dep_arr()

	if page_dep_arr == 1 then
		act_page = 1
		max_page = 1
		line0_l = "      DEP/ARR INDEX     "
		line0_s = "                    1/1 "
		line1_x = "                        "
		--line1_l = "<DEP      XXXX      ARR>"
		if ref_icao == "-----" then
			line1_l = ""
		else
			line1_l = "<DEP      " .. ref_icao
			line1_l = line1_l .. "      ARR>"
		end
		line1_s = "                        "
		line2_x = "                        "
		--line2_l = "          XXXX      ARR>"
		if des_icao == "****" then
			line2_l = ""
		else
			line2_l = "          " .. des_icao
			line2_l = line2_l .. "      ARR>"
		end
		line2_s = "                        "
		line3_x = "                        "
		line3_l = "                        "
		line3_s = "                        "
		line4_x = "                        "
		line4_l = "                        "
		line4_s = "                        "
		line5_x = "                        "
		line5_l = "                        "
		line5_s = "                        "
		line6_x = " DEP                ARR "
		line6_l = "<----    OTHER     ---->"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end


function create_rnw_list()

	local rnw_temp = ""
	local temp_str1 = ""
	local temp_str2 = ""
	local ii = 0
	local jj = 0
	
	ref_rnw_list = {}
	ref_rnw_list_num = 0
	ref_rnw_list2 = {}
	ref_rnw_list_num2 = 0
	des_rnw_list = {}
	des_rnw_list_num = 0
	
	if rnw_data_num > 0 then
		for ii = 1, rnw_data_num do
			if ref_icao == rnw_data[ii][1] then
				ref_rnw_list_num2 = ref_rnw_list_num2 + 1
				ref_rnw_list2[ref_rnw_list_num2] = {}
				ref_rnw_list2[ref_rnw_list_num2][1] = rnw_data[ii][1]
				ref_rnw_list2[ref_rnw_list_num2][2] = rnw_data[ii][2]
				ref_rnw_list2[ref_rnw_list_num2][3] = rnw_data[ii][3]
				ref_rnw_list2[ref_rnw_list_num2][4] = rnw_data[ii][4]
				ref_rnw_list2[ref_rnw_list_num2][5] = rnw_data[ii][5]
				ref_rnw_list2[ref_rnw_list_num2][6] = rnw_data[ii][6]
				ref_rnw_list2[ref_rnw_list_num2][7] = rnw_data[ii][7]
				ref_rnw_list2[ref_rnw_list_num2][8] = rnw_data[ii][8]
				if ref_sid2 == "------" then
					ref_rnw_list_num = ref_rnw_list_num + 1
					ref_rnw_list[ref_rnw_list_num] = {}
					ref_rnw_list[ref_rnw_list_num][1] = rnw_data[ii][1]
					ref_rnw_list[ref_rnw_list_num][2] = rnw_data[ii][2]
					ref_rnw_list[ref_rnw_list_num][3] = rnw_data[ii][3]
					ref_rnw_list[ref_rnw_list_num][4] = rnw_data[ii][4]
					ref_rnw_list[ref_rnw_list_num][5] = rnw_data[ii][5]
					ref_rnw_list[ref_rnw_list_num][6] = rnw_data[ii][6]
					ref_rnw_list[ref_rnw_list_num][7] = rnw_data[ii][7]
					ref_rnw_list[ref_rnw_list_num][8] = rnw_data[ii][8]
				else
					-- runways by SID
					rnw_temp = "RW" .. rnw_data[ii][2]
					for jj = 1, sid_num do
						if ref_data_sid[jj][1] == ref_sid2 then
							if string.sub(ref_data_sid[jj][2],-1,-1) == "B" then
								temp_str1 = string.sub(ref_data_sid[jj][2],1,-2)
								temp_str2 = string.sub(rnw_temp,1,-2)
							else
								temp_str1 = "A"
								temp_str2 = "B"
							end
							if rnw_temp == ref_data_sid[jj][2] or ref_data_sid[jj][2] == "ALL" or temp_str1 == temp_str2 then
								ref_rnw_list_num = ref_rnw_list_num + 1
								ref_rnw_list[ref_rnw_list_num] = {}
								ref_rnw_list[ref_rnw_list_num][1] = rnw_data[ii][1]
								ref_rnw_list[ref_rnw_list_num][2] = rnw_data[ii][2]
								ref_rnw_list[ref_rnw_list_num][3] = rnw_data[ii][3]
								ref_rnw_list[ref_rnw_list_num][4] = rnw_data[ii][4]
								ref_rnw_list[ref_rnw_list_num][5] = rnw_data[ii][5]
								ref_rnw_list[ref_rnw_list_num][6] = rnw_data[ii][6]
								ref_rnw_list[ref_rnw_list_num][7] = rnw_data[ii][7]
								ref_rnw_list[ref_rnw_list_num][8] = rnw_data[ii][8]
								break
							end
						end
					end
				end
			end
			
			if des_icao == rnw_data[ii][1] then
				--if des_star == "------" then
					des_rnw_list_num = des_rnw_list_num + 1
					des_rnw_list[des_rnw_list_num] = {}
					des_rnw_list[des_rnw_list_num][1] = rnw_data[ii][1]
					des_rnw_list[des_rnw_list_num][2] = rnw_data[ii][2]
					des_rnw_list[des_rnw_list_num][3] = rnw_data[ii][3]
					des_rnw_list[des_rnw_list_num][4] = rnw_data[ii][4]
					des_rnw_list[des_rnw_list_num][5] = rnw_data[ii][5]
					des_rnw_list[des_rnw_list_num][6] = rnw_data[ii][6]
					des_rnw_list[des_rnw_list_num][7] = rnw_data[ii][7]
					des_rnw_list[des_rnw_list_num][8] = rnw_data[ii][8]
				-- else
					-- -- runways by STAR
					-- rnw_temp = "RW" .. rnw_data[ii][2]
					-- for jj = 1, star_num do
						-- if data_des_star[jj][1] == des_star then
							-- if string.sub(data_des_star[jj][2],-1,-1) == "B" then
								-- temp_str1 = string.sub(data_des_star[jj][2],1,-2)
								-- temp_str2 = string.sub(rnw_temp,1,-2)
							-- else
								-- temp_str1 = "A"
								-- temp_str2 = "B"
							-- end
							-- if rnw_temp == data_des_star[jj][2] or data_des_star[jj][2] == "ALL" or temp_str1 == temp_str2 then
								-- des_rnw_list_num = des_rnw_list_num + 1
								-- des_rnw_list[des_rnw_list_num] = {}
								-- des_rnw_list[des_rnw_list_num][1] = rnw_data[ii][1]
								-- des_rnw_list[des_rnw_list_num][2] = rnw_data[ii][2]
								-- des_rnw_list[des_rnw_list_num][3] = rnw_data[ii][3]
								-- des_rnw_list[des_rnw_list_num][4] = rnw_data[ii][4]
								-- des_rnw_list[des_rnw_list_num][5] = rnw_data[ii][5]
								-- des_rnw_list[des_rnw_list_num][6] = rnw_data[ii][6]
								-- des_rnw_list[des_rnw_list_num][7] = rnw_data[ii][7]
								-- des_rnw_list[des_rnw_list_num][8] = rnw_data[ii][8]
								-- break
							-- end
						-- end
					-- end
				--end
			end
		end
	end

end


function create_sid_list()
	
	local ii = 0
	local jj = 0
	local kk = 0
	local rnw_temp = ""
	local temp_str1 = ""
	local temp_str2 = ""
	local sid_len = 0
	
	sid_list = {}
	sid_list_num = 0
	
	if sid_num > 0 then
		-- Create list of SIDs
		for ii = 1, sid_num do
			if ref_rwy2 == "-----" then
				sid_list_num = sid_list_num + 1
				sid_list[sid_list_num] = {}
				sid_list[sid_list_num][1] = ref_data_sid[ii][1]
				sid_list[sid_list_num][2] = ref_data_sid[ii][2]
			else
			-- SIDs by runway
				rnw_temp = "RW" .. ref_rwy2
				if string.sub(ref_data_sid[ii][2],-1,-1) == "B" then
					temp_str1 = string.sub(ref_data_sid[ii][2],1,-2)
					temp_str2 = string.sub(rnw_temp,1,-2)
				else
					temp_str1 = "A"
					temp_str2 = "B"
				end
				if rnw_temp == ref_data_sid[ii][2] or ref_data_sid[ii][2] == "ALL" or temp_str1 == temp_str2 then
					sid_list_num = sid_list_num + 1
					sid_list[sid_list_num] = {}
					sid_list[sid_list_num][1] = ref_data_sid[ii][1]
					sid_list[sid_list_num][2] = ref_data_sid[ii][2]
				end
			end
		end
		
		-- Create the one SID for more runways
		if sid_list_num > 1 then
			
			temp_list = {}
			temp_list_num = 0
			
			temp_list_num = temp_list_num + 1
			temp_list[temp_list_num] = {}
			temp_list[temp_list_num][1] = sid_list[1][1]
			temp_list[temp_list_num][2] = sid_list[1][2]
			temp_str1 = sid_list[1][1]
			
			for ii = 2, sid_list_num do
				if sid_list[ii][1] ~= temp_str1 then
					temp_list_num = temp_list_num + 1
					temp_list[temp_list_num] = {}
					temp_list[temp_list_num][1] = sid_list[ii][1]
					temp_list[temp_list_num][2] = sid_list[ii][2]
					temp_str1 = sid_list[ii][1]
				end
			end
			
			sid_list = {}
			sid_list_num = 0
			for ii = 1, temp_list_num do
				sid_list_num = sid_list_num + 1
				sid_list[sid_list_num] = {}
				sid_list[sid_list_num][1] = temp_list[ii][1]
				sid_list[sid_list_num][2] = temp_list[ii][2]
			end
		end
	end
	
end

function create_tns_list()
	
	local ii = 0
	
	sid_tns_list = {}
	sid_tns_list_num = 0
	
	if tns_num > 0 then
		for ii = 1, tns_num do
			if ref_data_tns[ii][1] == ref_sid2 then
				sid_tns_list_num = sid_tns_list_num + 1
				sid_tns_list[sid_tns_list_num] = ref_data_tns[ii][2]
			end
		end
	end

end

function B738_fmc_dep99()
	if page_dep == 1 then
		
		clr_repeat = 1
		
		local ii = 0
		local jj = 0
		local kk = 0
		local ll = 0
		
		local max_page_rwy = 0
		local max_page_sid = 0
		local max_page_tns = 0
		
		local left_line = {}
		left_line[1] = ""
		left_line[2] = ""
		left_line[3] = ""
		left_line[4] = ""
		left_line[5] = ""
		local right_line = {}
		right_line[1] = ""
		right_line[2] = ""
		right_line[3] = ""
		right_line[4] = ""
		right_line[5] = ""
		
		local sid_len = 0
		
		local temp_str1 = ""
		local temp_str2 = ""
		
		-- Create Runways
		jj = math.floor(ref_rnw_list_num / 5)
		kk = ref_rnw_list_num % 5
		if kk > 0 then
			max_page_rwy = jj + 1
		else
			max_page_rwy = jj
		end
		
		if ref_rwy2 == "-----" then
			kk = (act_page - 1) * 5
			for ii = 1, 5 do
				jj = kk + ii
				if jj > ref_rnw_list_num then
					right_line[ii] = ""
					ref_rwy_sel[ii] = "-----"
				else
					right_line[ii] = ref_rnw_list[jj][2]
					ref_rwy_sel[ii] = ref_rnw_list[jj][2]
				end
			end
		else
			if ref_rwy_exec == 1 then
				right_line[1] = "<SEL>   " .. ref_rwy2
			else
				right_line[1] = "<ACT>   " .. ref_rwy2
			end
			max_page_rwy = 1
		end
		
		-- Create SIDs
		jj = math.floor(sid_list_num / 5)
		kk = sid_list_num % 5
		if kk > 0 then
			max_page_sid = jj + 1
		else
			max_page_sid = jj
		end
		if ref_sid2 == "------" then
			kk = (act_page - 1) * 5
			for ii = 1, 5 do
				jj = kk + ii
				if jj > sid_list_num then
					if sid_list_num == 0 and ii == 1 then
						left_line[ii] = "-NONE-"
					else
						left_line[ii] = ""
					end
					ref_sid_sel[ii] = "------"
				else
					left_line[ii] = sid_list[jj][1]
					ref_sid_sel[ii] = sid_list[jj][1]
				end
			end
		else
			if ref_sid_exec == 1 then
				left_line[1] = ref_sid2 .. " <SEL>"
			else
				left_line[1] = ref_sid2 .. " <ACT>"
			end
			max_page_sid = 1
		end
		
		-- Create Transitions
		if ref_sid2 ~= "------" then
			line2_x = " TRANS"
			if sid_tns_list_num == 0 then
				ref_tns_sel[1] = "------"
				ref_tns_sel[2] = "------"
				ref_tns_sel[3] = "------"
				ref_tns_sel[4] = "------"
				ref_tns_sel[5] = "------"
				left_line[2] = "-NONE-"
			else
				jj = math.floor(sid_tns_list_num / 4)
				kk = sid_tns_list_num % 4
				if kk > 0 then
					max_page_tns = jj + 1
				else
					max_page_tns = jj
				end
				if ref_sid_tns2 == "------" then
					kk = (act_page - 1) * 4
					for ii = 2, 5 do
						jj = kk + ii - 1
						if jj > sid_tns_list_num then
							left_line[ii] = ""
							ref_tns_sel[ii] = "------"
						else
							left_line[ii] = sid_tns_list[jj]
							ref_tns_sel[ii] = sid_tns_list[jj]
						end
					end
				else
					if ref_tns_exec == 1 then
						left_line[2] = ref_sid_tns2 .. " <SEL>"
					else
						left_line[2] = ref_sid_tns2 .. " <ACT>"
					end
					max_page_tns = 1
				end
			end
		end
		
		-- Display engine
		for ii = 1, 5 do
			sid_len = string.len(left_line[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					left_line[ii] = left_line[ii] .. " "
				end
			end
			sid_len = string.len(right_line[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					right_line[ii] = " " .. right_line[ii]
				end
			end
		end
		
		line1_l = left_line[1] .. right_line[1]
		line2_l = left_line[2] .. right_line[2]
		line3_l = left_line[3] .. right_line[3]
		line4_l = left_line[4] .. right_line[4]
		line5_l = left_line[5] .. right_line[5]
		
		max_page = math.max(1, max_page_rwy, max_page_sid, max_page_tns)
		
		line0_l = "   " .. ref_icao
		line0_l = line0_l .. " DEPARTURES      "
		line0_s = "                    " .. string.format("%1d",act_page)
		line0_s = line0_s .. "/"
		line0_s = line0_s .. string.format("%1d",max_page)
		line1_x = " SIDS            RUNWAYS"
		if ref_sid_exec == 1 or ref_rwy_exec == 1 or ref_tns_exec == 1 or ref_app_tns_exec == 1 then
			line6_l = "<ERASE            ROUTE>"
		else
			line6_l = "                  ROUTE>"
		end
		line6_x = "------------------------"
	end
end

function B738_fmc_dep()
		
	if page_dep == 1 then
		
		clr_repeat = 1
		
		local ii = 0
		local jj = 0
		local kk = 0
		local ll = 0
		
		local max_page_rwy = 0
		local max_page_sid = 0
		local max_page_tns = 0
		
		local left_line = {}
		left_line[1] = ""
		left_line[2] = ""
		left_line[3] = ""
		left_line[4] = ""
		left_line[5] = ""
		local right_line = {}
		right_line[1] = ""
		right_line[2] = ""
		right_line[3] = ""
		right_line[4] = ""
		right_line[5] = ""
		
		local sid_len = 0
		
		local temp_str1 = ""
		local temp_str2 = ""
		
		-- Create Runways
		jj = math.floor(ref_rwy_map_num / 5)
		kk = ref_rwy_map_num % 5
		if kk > 0 then
			max_page_rwy = jj + 1
		else
			max_page_rwy = jj
		end
		
		if ref_rwy == "-----" then
			kk = (act_page - 1) * 5
			for ii = 1, 5 do
				jj = kk + ii
				if jj > ref_rwy_map_num then
					right_line[ii] = ""
					ref_rwy_sel[ii] = "-----"
				else
					right_line[ii] = string.sub(ref_rwy_map[jj], 3, -1)
					ref_rwy_sel[ii] = string.sub(ref_rwy_map[jj], 3, -1)
				end
			end
		else
			if simDR_fms_exec_light1 == 1 and ref_rwy_exec == 1 then
				right_line[1] = "<SEL>   " .. ref_rwy
			else
				right_line[1] = "<ACT>   " .. ref_rwy
			end
			max_page_rwy = 1
		end
		
		if ref_rwy ~= "-----" then
			-- create SIDs for selected runway
			local ref_rwy_act = ""
			ref_rwy_act = "RW" .. ref_rwy
			if string.sub(ref_rwy_act, -1, -1) == " " then
				ref_rwy_act = string.sub(ref_rwy_act,1, -2)
			end
			sid_num_act = 0
			ref_data_sid_act = {}
				for ii = 1, sid_num do
					if string.sub(ref_data_sid[ii][2],-1,-1) == "B" then
						if des_icao == "KSEA" then	-- fix KSEA ignore xxC
							if string.sub(ref_rwy_act,-1,-1) == "C" then
								temp_str1 = "A"
								temp_str2 = "B"
							else
								temp_str1 = string.sub(ref_data_sid[ii][2],1,-2)
								temp_str2 = string.sub(ref_rwy_act,1,-2)
							end
						else
							temp_str1 = string.sub(ref_data_sid[ii][2],1,-2)
							temp_str2 = string.sub(ref_rwy_act,1,-2)
						end
					else
						temp_str1 = "A"
						temp_str2 = "B"
					end
					if ref_rwy_act == ref_data_sid[ii][2] or ref_data_sid[ii][2] == "ALL" or temp_str1 == temp_str2 then
						sid_num_act = sid_num_act + 1
						ref_data_sid_act[sid_num_act] = {}
						ref_data_sid_act[sid_num_act][1] = ref_data_sid[ii][1]
						ref_data_sid_act[sid_num_act][2] = ref_data_sid[ii][2]
					end
				end
			
			jj = math.floor(sid_num_act / 5)
			kk = sid_num_act % 5
			if kk > 0 then
				max_page_sid = jj + 1
			else
				max_page_sid = jj
			end
			
			if ref_sid == "------" then
				kk = (act_page - 1) * 5
				for ii = 1, 5 do
					jj = kk + ii
					if jj > sid_num_act then
						if sid_num_act == 0 and jj == 1 then
							left_line[ii] = "-NONE-"
						else
							left_line[ii] = ""
						end
						ref_sid_sel[ii] = "------"
					else
						left_line[ii] = ref_data_sid_act[jj][1]
						ref_sid_sel[ii] = ref_data_sid_act[jj][1]
					end
				end
			else
				if simDR_fms_exec_light1 == 1 and ref_sid_exec == 1 then
					left_line[1] = ref_sid .. " <SEL>"
				else
					left_line[1] = ref_sid .. " <ACT>"
				end
				max_page_sid = 1
			end
		else
			max_page_sid = 1
		end
		
		-- Create Transitions
		if ref_sid ~= "------" and ref_rwy ~= "------" then
			line2_x = " TRANS                  "
			ref_num_sid_tns = 0
			ref_data_sid_tns = {}
			for ii = 1, tns_num do
				if ref_data_tns[ii][1] == ref_sid then
					ref_num_sid_tns = ref_num_sid_tns + 1
					ref_data_sid_tns[ref_num_sid_tns] = ref_data_tns[ii][2]
				end
			end
			
			--tns_num
			--ref_data_tns
			
			if ref_num_sid_tns == 0 then
				ref_tns_sel[1] = "------"
				ref_tns_sel[2] = "------"
				ref_tns_sel[3] = "------"
				ref_tns_sel[4] = "------"
				ref_tns_sel[5] = "------"
				line2_x = "                        "
				line2_x = " TRANS"
				left_line[2] = "-NONE-"
			else
				jj = math.floor(ref_num_sid_tns / 4)
				kk = ref_num_sid_tns % 4
				if kk > 0 then
					max_page_tns = jj + 1
				else
					max_page_tns = jj
				end
				
				if ref_sid_tns == "------" then
					ref_tns_sel[1] = "------"
					kk = (act_page - 1) * 4
					
					ref_tns_sel[1] = "------"
					
					for ii = 2, 5 do
						jj = kk + ii - 1
						if jj > ref_num_sid_tns then
							left_line[ii] = ""
							ref_tns_sel[ii] = "------"
						else
							left_line[ii] = ref_data_sid_tns[jj]
							ref_tns_sel[ii] = ref_data_sid_tns[jj]
						end
					end
				else
					if simDR_fms_exec_light1 == 1 and ref_tns_exec == 1 then
						left_line[2] = ref_sid_tns .. " <SEL>"
					else
						left_line[2] = ref_sid_tns .. " <ACT>"
					end
					max_page_tns = 1
				end
			end
		else
			max_page_tns = 1
			line2_x = "                        "
		end
		
		-- display engine
		for ii = 1, 5 do
			sid_len = string.len(left_line[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					left_line[ii] = left_line[ii] .. " "
				end
			end
			sid_len = string.len(right_line[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					right_line[ii] = " " .. right_line[ii]
				end
			end
		end
		
		line1_l = left_line[1] .. right_line[1]
		line2_l = left_line[2] .. right_line[2]
		line3_l = left_line[3] .. right_line[3]
		line4_l = left_line[4] .. right_line[4]
		line5_l = left_line[5] .. right_line[5]
		
		max_page = math.max(max_page_rwy, max_page_sid, max_page_tns)
		
		line0_l = "   " .. ref_icao
		line0_l = line0_l .. " DEPARTURES      "
		--line0_s = "                    1/1 "
		line0_s = "                    " .. string.format("%1d",act_page)
		line0_s = line0_s .. "/"
		line0_s = line0_s .. string.format("%1d",max_page)
		line1_x = " SIDS            RUNWAYS"
		
		line6_x = "------------------------"
		line6_l = "                  ROUTE>"
		line6_s = "                        "
		
		line1_s = "                        "
		line2_s = "                        "
		line3_s = "                        "
		line4_s = "                        "
		line5_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end


function B738_fmc_dep_old()
		
	if page_dep == 1 then
		
		
		local ii = 0
		local jj = 0
		local kk = 0
		local ll = 0
		
		local max_page_rwy = 0
		local max_page_sid = 0
		local max_page_tns = 0
		
		local left_line = {}
		left_line[1] = ""
		left_line[2] = ""
		left_line[3] = ""
		left_line[4] = ""
		left_line[5] = ""
		local right_line = {}
		right_line[1] = ""
		right_line[2] = ""
		right_line[3] = ""
		right_line[4] = ""
		right_line[5] = ""
		
		local sid_len = 0
		
		local temp_str1 = ""
		local temp_str2 = ""
		
		-- Create Runways
		jj = math.floor(rwy_num / 5)
		kk = rwy_num % 5
		if kk > 0 then
			max_page_rwy = jj + 1
		else
			max_page_rwy = jj
		end
		
		if ref_rwy == "-----" then
			kk = (act_page - 1) * 5
			for ii = 1, 5 do
				jj = kk + ii
				if jj > rwy_num then
					right_line[ii] = ""
					ref_rwy_sel[ii] = "-----"
				else
					right_line[ii] = string.sub(ref_data[jj][1],3, -1)
					ref_rwy_sel[ii] = string.sub(ref_data[jj][1],3, -1)
				end
			end
		else
			if simDR_fms_exec_light1 == 1 and ref_rwy_exec == 1 then
				right_line[1] = "<SEL>   " .. ref_rwy
			else
				right_line[1] = "<ACT>   " .. ref_rwy
			end
			max_page_rwy = 1
		end
		
		if ref_rwy ~= "-----" then
			-- create SIDs for selected runway
			local ref_rwy_act = ""
			ref_rwy_act = "RW" .. ref_rwy
			if string.sub(ref_rwy_act, -1, -1) == " " then
				ref_rwy_act = string.sub(ref_rwy_act,1, -2)
			end
			sid_num_act = 0
			ref_data_sid_act = {}
				for ii = 1, sid_num do
					if string.sub(ref_data_sid[ii][2],-1,-1) == "B" then
						if string.sub(ref_rwy_act,-1,-1) == "C" then
							temp_str1 = "A"
							temp_str2 = "B"
						else
							temp_str1 = string.sub(ref_data_sid[ii][2],1,-2)
							temp_str2 = string.sub(ref_rwy_act,1,-2)
						end
					else
						temp_str1 = "A"
						temp_str2 = "B"
					end
					if ref_rwy_act == ref_data_sid[ii][2] or ref_data_sid[ii][2] == "ALL" or temp_str1 == temp_str2 then
						sid_num_act = sid_num_act + 1
						ref_data_sid_act[sid_num_act] = {}
						ref_data_sid_act[sid_num_act][1] = ref_data_sid[ii][1]
						ref_data_sid_act[sid_num_act][2] = ref_data_sid[ii][2]
					end
				end
			
			jj = math.floor(sid_num_act / 5)
			kk = sid_num_act % 5
			if kk > 0 then
				max_page_sid = jj + 1
			else
				max_page_sid = jj
			end
			
			if ref_sid == "------" then
				kk = (act_page - 1) * 5
				for ii = 1, 5 do
					jj = kk + ii
					if jj > sid_num_act then
						left_line[ii] = ""
						ref_sid_sel[ii] = "------"
					else
						left_line[ii] = ref_data_sid_act[jj][1]
						ref_sid_sel[ii] = ref_data_sid_act[jj][1]
					end
				end
			else
				if simDR_fms_exec_light1 == 1 and ref_sid_exec == 1 then
					left_line[1] = ref_sid .. " <SEL>"
				else
					left_line[1] = ref_sid .. " <ACT>"
				end
				max_page_sid = 1
			end
		else
			max_page_sid = 1
		end
		
		-- Create Transitions
		if ref_sid ~= "------" and ref_rwy ~= "------" then
			line2_x = " TRANS                  "
			ref_num_sid_tns = 0
			ref_data_sid_tns = {}
			for ii = 1, tns_num do
				if ref_data_tns[ii][1] == ref_sid then
					ref_num_sid_tns = ref_num_sid_tns + 1
					ref_data_sid_tns[ref_num_sid_tns] = ref_data_tns[ii][2]
				end
			end
			
			--tns_num
			--ref_data_tns
			
			if ref_num_sid_tns == 0 then
				ref_tns_sel[1] = "------"
				ref_tns_sel[2] = "------"
				ref_tns_sel[3] = "------"
				ref_tns_sel[4] = "------"
				ref_tns_sel[5] = "------"
				line2_x = "                        "
			else
				jj = math.floor(ref_num_sid_tns / 4)
				kk = ref_num_sid_tns % 4
				if kk > 0 then
					max_page_tns = jj + 1
				else
					max_page_tns = jj
				end
				
				if ref_sid_tns == "------" then
					ref_tns_sel[1] = "------"
					kk = (act_page - 1) * 4
					
					ref_tns_sel[1] = "------"
					
					for ii = 2, 5 do
						jj = kk + ii - 1
						if jj > ref_num_sid_tns then
							left_line[ii] = ""
							ref_tns_sel[ii] = "------"
						else
							left_line[ii] = ref_data_sid_tns[jj]
							ref_tns_sel[ii] = ref_data_sid_tns[jj]
						end
					end
				else
					if simDR_fms_exec_light1 == 1 and ref_tns_exec == 1 then
						left_line[2] = ref_sid_tns .. " <SEL>"
					else
						left_line[2] = ref_sid_tns .. " <ACT>"
					end
					max_page_tns = 1
				end
			end
		else
			max_page_tns = 1
			line2_x = "                        "
		end
		
		-- display engine
		for ii = 1, 5 do
			sid_len = string.len(left_line[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					left_line[ii] = left_line[ii] .. " "
				end
			end
			sid_len = string.len(right_line[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					right_line[ii] = " " .. right_line[ii]
				end
			end
		end
		
		line1_l = left_line[1] .. right_line[1]
		line2_l = left_line[2] .. right_line[2]
		line3_l = left_line[3] .. right_line[3]
		line4_l = left_line[4] .. right_line[4]
		line5_l = left_line[5] .. right_line[5]
		
		max_page = math.max(max_page_rwy, max_page_sid, max_page_tns)
		
		line0_l = "   " .. ref_icao
		line0_l = line0_l .. " DEPARTURES      "
		--line0_s = "                    1/1 "
		line0_s = "                    " .. string.format("%1d",act_page)
		line0_s = line0_s .. "/"
		line0_s = line0_s .. string.format("%1d",max_page)
		line1_x = " SIDS            RUNWAYS"
		
		line6_x = "------------------------"
		line6_l = "<ERASE            ROUTE>"
		line6_s = "                        "
		
		line1_s = "                        "
		line2_s = "                        "
		line3_s = "                        "
		line4_s = "                        "
		line5_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end




function create_star_list()
	
	local ii = 0
	local jj = 0
	local kk = 0
	local rnw_temp = ""
	local temp_str1 = ""
	local temp_str2 = ""
	local sid_len = 0
	
	star_list = {}
	star_list_num = 0
	
	if arr_data == 0 then	-- Des ICAO
	
		if data_des_star_n > 0 then
			-- Create list of STARs
			for ii = 1, data_des_star_n do
				if des_app2 == "------" then
					star_list_num = star_list_num + 1
					star_list[star_list_num] = {}
					star_list[star_list_num][1] = data_des_star[ii][1]
					star_list[star_list_num][2] = data_des_star[ii][2]
				else
				-- STARs by APP
					rnw_temp = ""
					if string.len(des_app2) > 4 then
						jj, kk = string.find(des_app2, "-")
						if jj == nil then
							rnw_temp = "RW" .. string.sub(des_app2, 2, -2)
						else
							rnw_temp = "RW" .. string.sub(des_app2, 2, jj-1)
						end
					else
						rnw_temp = "RW" .. string.sub(des_app2, 2, -1)
					end
					if string.sub(data_des_star[ii][2],-1,-1) == "B" then
						temp_str1 = string.sub(data_des_star[ii][2],1,-2)
						temp_str2 = string.sub(rnw_temp,1,-2)
					else
						temp_str1 = "A"
						temp_str2 = "B"
					end
					if rnw_temp == data_des_star[ii][2] or data_des_star[ii][2] == "ALL" or temp_str1 == temp_str2 then
						star_list_num = star_list_num + 1
						star_list[star_list_num] = {}
						star_list[star_list_num][1] = data_des_star[ii][1]
						star_list[star_list_num][2] = data_des_star[ii][2]
					end
				end
			end
		end
		
		-- Create the one SID for more runways
		if star_list_num > 1 then
			
			temp_list = {}
			temp_list_num = 0
			
			temp_list_num = temp_list_num + 1
			temp_list[temp_list_num] = {}
			temp_list[temp_list_num][1] = star_list[1][1]
			temp_list[temp_list_num][2] = star_list[1][2]
			temp_str1 = star_list[1][1]
			
			for ii = 2, star_list_num do
				if star_list[ii][1] ~= temp_str1 then
					temp_list_num = temp_list_num + 1
					temp_list[temp_list_num] = {}
					temp_list[temp_list_num][1] = star_list[ii][1]
					temp_list[temp_list_num][2] = star_list[ii][2]
					temp_str1 = star_list[ii][1]
				end
			end
			
			star_list = {}
			star_list_num = 0
			for ii = 1, temp_list_num do
				star_list_num = star_list_num + 1
				star_list[star_list_num] = {}
				star_list[star_list_num][1] = temp_list[ii][1]
				star_list[star_list_num][2] = temp_list[ii][2]
			end
		end
	
	elseif arr_data == 1 then	-- Ref ICAO
		
		if star_num > 0 then
			-- Create list of STARs
			for ii = 1, star_num do
				if des_app2 == "------" then
					star_list_num = star_list_num + 1
					star_list[star_list_num] = {}
					star_list[star_list_num][1] = ref_data_star[ii][1]
					star_list[star_list_num][2] = ref_data_star[ii][2]
				else
				-- STARs by APP
					rnw_temp = ""
					if string.len(des_app2) > 4 then
						jj, kk = string.find(des_app2, "-")
						if jj == nil then
							rnw_temp = "RW" .. string.sub(des_app2, 2, -2)
						else
							rnw_temp = "RW" .. string.sub(des_app2, 2, jj-1)
						end
					else
						rnw_temp = "RW" .. string.sub(des_app2, 2, -1)
					end
					if string.sub(ref_data_star[ii][2],-1,-1) == "B" then
						temp_str1 = string.sub(ref_data_star[ii][2],1,-2)
						temp_str2 = string.sub(rnw_temp,1,-2)
					else
						temp_str1 = "A"
						temp_str2 = "B"
					end
					if rnw_temp == ref_data_star[ii][2] or ref_data_star[ii][2] == "ALL" or temp_str1 == temp_str2 then
						star_list_num = star_list_num + 1
						star_list[star_list_num] = {}
						star_list[star_list_num][1] = ref_data_star[ii][1]
						star_list[star_list_num][2] = ref_data_star[ii][2]
					end
				end
			end
			
			-- Create the one SID for more runways
			if star_list_num > 1 then
				
				temp_list = {}
				temp_list_num = 0
				
				temp_list_num = temp_list_num + 1
				temp_list[temp_list_num] = {}
				temp_list[temp_list_num][1] = star_list[1][1]
				temp_list[temp_list_num][2] = star_list[1][2]
				temp_str1 = star_list[1][1]
				
				for ii = 2, star_list_num do
					if star_list[ii][1] ~= temp_str1 then
						temp_list_num = temp_list_num + 1
						temp_list[temp_list_num] = {}
						temp_list[temp_list_num][1] = star_list[ii][1]
						temp_list[temp_list_num][2] = star_list[ii][2]
						temp_str1 = star_list[ii][1]
					end
				end
				
				star_list = {}
				star_list_num = 0
				for ii = 1, temp_list_num do
					star_list_num = star_list_num + 1
					star_list[star_list_num] = {}
					star_list[star_list_num][1] = temp_list[ii][1]
					star_list[star_list_num][2] = temp_list[ii][2]
				end
			end
		end
	end
	
end


function create_star_tns_list()
	
	local ii = 0
	
	star_tns_list = {}
	star_tns_list_num = 0
	
	if arr_data == 0 then	-- Des ICAO
		if data_des_star_tns_n > 0 then
			for ii = 1, data_des_star_tns_n do
				if data_des_star_tns[ii][1] == des_star2 then
					star_tns_list_num = star_tns_list_num + 1
					star_tns_list[star_tns_list_num] = data_des_star_tns[ii][2]
				end
			end
		end
	
	elseif arr_data == 1 then	-- Ref ICAO
		if ref_data_star_tns_n > 0 then
			for ii = 1, ref_data_star_tns_n do
				if ref_data_star_tns[ii][1] == des_star2 then
					star_tns_list_num = star_tns_list_num + 1
					star_tns_list[star_tns_list_num] = ref_data_star_tns[ii][2]
				end
			end
		end
	end

end

function create_des_app_list()
	
	local ii = 0
	local jj = 0
	local kk = 0
	local rnw_temp = ""
	local rnw_temp2 = ""
	local temp_str1 = ""
	local temp_str2 = ""
	local sid_len = 0
	local rw_numeric = 0
	
	des_app_list = {}
	des_app_list_num = 0
	
	if arr_data == 0 then	-- Des ICAO
	
		if data_des_app_n > 0 then
			-- Create list of APPs
			for ii = 1, data_des_app_n do
				if des_star2 == "------" then
					des_app_list_num = des_app_list_num + 1
					des_app_list[des_app_list_num] = {}
					rnw_temp = ""
					if string.len(data_des_app[ii]) > 4 then
						jj, kk = string.find(data_des_app[ii], "-")
						if jj == nil then
							rnw_temp = "RW" .. string.sub(data_des_app[ii], 2, -2)
						else
							rnw_temp = "RW" .. string.sub(data_des_app[ii], 2, jj-1)
						end
					else
						rnw_temp = "RW" .. string.sub(data_des_app[ii], 2, -1)
					end
					des_app_list[des_app_list_num][1] = data_des_app[ii]
					des_app_list[des_app_list_num][2] = rnw_temp
					if string.len(rnw_temp) > 4 then
						temp_str1 = string.sub(rnw_temp, 3, -2)
					else
						temp_str1 = string.sub(rnw_temp, 3, -1)
					end
					rw_numeric = tonumber(temp_str1)
					if rw_numeric == nil then
						des_app_list[des_app_list_num][3] = 0
					else
						des_app_list[des_app_list_num][3] = rw_numeric
					end
				else
				-- APPs by STAR
					rnw_temp2 = ""
					rnw_temp = ""
					if string.len(data_des_app[ii]) > 4 then
						jj, kk = string.find(data_des_app[ii], "-")
						if jj == nil then
							rnw_temp = "RW" .. string.sub(data_des_app[ii], 2, -2)
						else
							rnw_temp = "RW" .. string.sub(data_des_app[ii], 2, jj-1)
						end
					else
						rnw_temp = "RW" .. string.sub(data_des_app[ii], 2, -1)
					end
					for jj = 1, data_des_star_n do
						if data_des_star[jj][1] == des_star2 then
							rnw_temp2 = data_des_star[jj][2]
							if string.sub(rnw_temp2,-1,-1) == "B" then
								temp_str1 = string.sub(rnw_temp2,1,-2)
								temp_str2 = string.sub(rnw_temp,1,-2)
							else
								temp_str1 = "A"
								temp_str2 = "B"
							end
							if rnw_temp == rnw_temp2 or rnw_temp2 == "ALL" or temp_str1 == temp_str2 then
								des_app_list_num = des_app_list_num + 1
								des_app_list[des_app_list_num] = {}
								des_app_list[des_app_list_num][1] = data_des_app[ii]
								des_app_list[des_app_list_num][2] = rnw_temp
								if string.len(rnw_temp) > 4 then
									temp_str1 = string.sub(rnw_temp, 3, -2)
								else
									temp_str1 = string.sub(rnw_temp, 3, -1)
								end
								rw_numeric = tonumber(temp_str1)
								if rw_numeric == nil then
									des_app_list[des_app_list_num][3] = 0
								else
									des_app_list[des_app_list_num][3] = rw_numeric
								end
							end
						end
					end
				end
			end
			
			-- order approach by runway
			if des_app_list_num > 1 then
				for ii = 1, des_app_list_num - 1 do
					for jj = ii + 1, des_app_list_num do
						if des_app_list[ii][3] > des_app_list[jj][3] then
							temp_str1 = des_app_list[ii][1]
							temp_str2 = des_app_list[ii][2]
							rw_numeric = des_app_list[ii][3]
							des_app_list[ii][1] = des_app_list[jj][1]
							des_app_list[ii][2] = des_app_list[jj][2]
							des_app_list[ii][3] = des_app_list[jj][3]
							des_app_list[jj][1] = temp_str1
							des_app_list[jj][2] = temp_str2
							des_app_list[jj][3] = rw_numeric
						end
					end
				end
			end
			
		else
			if des_rnw_list_num > 0 then
				for ii = 1, des_rnw_list_num do
					des_app_list_num = des_app_list_num + 1
					des_app_list[des_app_list_num] = {}
					des_app_list[des_app_list_num][1] = "RW" .. des_rnw_list[ii][2]
					des_app_list[des_app_list_num][2] = "RW" .. des_rnw_list[ii][2]
					if string.len(des_rnw_list[ii][2]) > 2 then
						temp_str1 = string.sub(des_rnw_list[ii][2], 1, -2)
					else
						temp_str1 = des_rnw_list[ii][2]
					end
					des_app_list[des_app_list_num][3] = tonumber(temp_str1)
				end
			end
		end

	elseif arr_data == 1 then	-- Ref ICAO
		if ref_data_app_n > 0 then
			-- Create list of APPs
			for ii = 1, ref_data_app_n do
				if des_star2 == "------" then
					des_app_list_num = des_app_list_num + 1
					des_app_list[des_app_list_num] = {}
					rnw_temp = ""
					if string.len(ref_data_app[ii]) > 4 then
						jj, kk = string.find(ref_data_app[ii], "-")
						if jj == nil then
							rnw_temp = "RW" .. string.sub(data_des_app[ii], 2, -2)
						else
							rnw_temp = "RW" .. string.sub(ref_data_app[ii], 2, jj-1)
						end
					else
						rnw_temp = "RW" .. string.sub(ref_data_app[ii], 2, -1)
					end
					des_app_list[des_app_list_num][1] = ref_data_app[ii]
					des_app_list[des_app_list_num][2] = rnw_temp
					if string.len(rnw_temp) > 4 then
						temp_str1 = string.sub(rnw_temp, 3, -2)
					else
						temp_str1 = string.sub(rnw_temp, 3, -1)
					end
					rw_numeric = tonumber(temp_str1)
					if rw_numeric == nil then
						des_app_list[des_app_list_num][3] = 0
					else
						des_app_list[des_app_list_num][3] = rw_numeric
					end
				else
				-- APPs by STAR
					rnw_temp2 = ""
					rnw_temp = ""
					if string.len(ref_data_app[ii]) > 4 then
						jj, kk = string.find(ref_data_app[ii], "-")
						if jj == nil then
							rnw_temp = "RW" .. string.sub(data_des_app[ii], 2, -2)
						else
							rnw_temp = "RW" .. string.sub(ref_data_app[ii], 2, jj-1)
						end
					else
						rnw_temp = "RW" .. string.sub(ref_data_app[ii], 2, -1)
					end
					for jj = 1, star_num do
						if ref_data_star[jj][1] == des_star2 then
							rnw_temp2 = ref_data_star[jj][2]
							if string.sub(rnw_temp2,-1,-1) == "B" then
								temp_str1 = string.sub(rnw_temp2,1,-2)
								temp_str2 = string.sub(rnw_temp,1,-2)
							else
								temp_str1 = "A"
								temp_str2 = "B"
							end
							if rnw_temp == rnw_temp2 or rnw_temp2 == "ALL" or temp_str1 == temp_str2 then
								des_app_list_num = des_app_list_num + 1
								des_app_list[des_app_list_num] = {}
								des_app_list[des_app_list_num][1] = ref_data_app[ii]
								des_app_list[des_app_list_num][2] = rnw_temp
								if string.len(rnw_temp) > 4 then
									temp_str1 = string.sub(rnw_temp, 3, -2)
								else
									temp_str1 = string.sub(rnw_temp, 3, -1)
								end
								rw_numeric = tonumber(temp_str1)
								if rw_numeric == nil then
									des_app_list[des_app_list_num][3] = 0
								else
									des_app_list[des_app_list_num][3] = rw_numeric
								end
							end
						end
					end
				end
			end
			
			-- order approach by runway
			if des_app_list_num > 1 then
				for ii = 1, des_app_list_num - 1 do
					for jj = ii + 1, des_app_list_num do
						if des_app_list[ii][3] > des_app_list[jj][3] then
							temp_str1 = des_app_list[ii][1]
							temp_str2 = des_app_list[ii][2]
							rw_numeric = des_app_list[ii][3]
							des_app_list[ii][1] = des_app_list[jj][1]
							des_app_list[ii][2] = des_app_list[jj][2]
							des_app_list[ii][3] = des_app_list[jj][3]
							des_app_list[jj][1] = temp_str1
							des_app_list[jj][2] = temp_str2
							des_app_list[jj][3] = rw_numeric
						end
					end
				end
			end
			
		else
			if ref_rnw_list_num2 > 0 then
				for ii = 1, ref_rnw_list_num2 do
					des_app_list_num = des_app_list_num + 1
					des_app_list[des_app_list_num] = {}
					des_app_list[des_app_list_num][1] = "RW" .. ref_rnw_list2[ii][2]
					des_app_list[des_app_list_num][2] = "RW" .. ref_rnw_list2[ii][2]
					if string.len(ref_rnw_list2[ii][2]) > 2 then
						temp_str1 = string.sub(ref_rnw_list2[ii][2], 1, -2)
					else
						temp_str1 = ref_rnw_list2[ii][2]
					end
					des_app_list[des_app_list_num][3] = tonumber(temp_str1)
				end
			end
		end
	
	end

end

function create_app_tns_list()
	
	local ii = 0
	
	des_app_tns_list = {}
	des_app_tns_list_num = 0
	
	if arr_data == 0 then	-- Des ICAO
		if data_des_app_tns_n > 0 then
			for ii = 1, data_des_app_tns_n do
				if data_des_app_tns[ii][1] == des_app2 then
					des_app_tns_list_num = des_app_tns_list_num + 1
					des_app_tns_list[des_app_tns_list_num] = data_des_app_tns[ii][2]
				end
			end
		end
	
	elseif arr_data == 1 then	-- Ref ICAO
		if ref_data_app_tns_n > 0 then
			for ii = 1, ref_data_app_tns_n do
				if ref_data_app_tns[ii][1] == des_app2 then
					des_app_tns_list_num = des_app_tns_list_num + 1
					des_app_tns_list[des_app_tns_list_num] = ref_data_app_tns[ii][2]
				end
			end
		end
	end

end


function B738_fmc_arr99()
	
	
	if page_arr == 1 then
		
		clr_repeat = 1
		
		local ii = 0
		local jj = 0
		local kk = 0
		local ll = 0
		
		local max_page_star = 0
		local max_page_star_tns = 0
		local max_page_app = 0
		local max_page_tns = 0
		
		local left_line = {}
		left_line[1] = ""
		left_line[2] = ""
		left_line[3] = ""
		left_line[4] = ""
		left_line[5] = ""
		local right_line = {}
		right_line[1] = ""
		right_line[2] = ""
		right_line[3] = ""
		right_line[4] = ""
		right_line[5] = ""
		
		local sid_len = 0
		local right_len = 0
		local temp_str = ""
		
		
		-- Create STARs
		jj = math.floor(star_list_num / 5)
		kk = star_list_num % 5
		if kk > 0 then
			max_page_star = jj + 1
		else
			max_page_star = jj
		end
		
		if des_star2 == "------" then
			kk = (act_page - 1) * 5
			for ii = 1, 5 do
				jj = kk + ii
				if jj > star_list_num then
					left_line[ii] = ""
					des_star_sel[ii] = "------"
				else
					left_line[ii] = star_list[jj][1]
					des_star_sel[ii] = star_list[jj][1]
				end
			end
		else
			if des_star_exec == 1 then
				left_line[1] = des_star2 .. " <SEL>"
			else
				left_line[1] = des_star2 .. " <ACT>"
			end
			max_page_star = 1
		end
		
		-- Create STAR Transitions
		if des_star2 ~= "------" then
			line2_x = " TRANS      "
			if star_tns_list_num == 0 then
				des_star_tns_sel[1] = "------"
				des_star_tns_sel[2] = "------"
				des_star_tns_sel[3] = "------"
				des_star_tns_sel[4] = "------"
				des_star_tns_sel[5] = "------"
				left_line[2] = "-NONE-"
			else
				jj = math.floor(star_tns_list_num / 4)
				kk = star_tns_list_num % 4
				if kk > 0 then
					max_page_tns = jj + 1
				else
					max_page_tns = jj
				end
				if des_star_trans2 == "------" then
					kk = (act_page - 1) * 4
					for ii = 2, 5 do
						jj = kk + ii - 1
						if jj > star_tns_list_num then
							left_line[ii] = ""
							des_star_tns_sel[ii] = "------"
						else
							left_line[ii] = star_tns_list[jj]
							des_star_tns_sel[ii] = star_tns_list[jj]
						end
					end
				else
					if des_star_tns_exec == 1 then
						left_line[2] = des_star_trans2 .. " <SEL>"
					else
						left_line[2] = des_star_trans2 .. " <ACT>"
					end
					max_page_tns = 1
				end
			end
		else
			line2_x = "            "
			max_page_tns = 1
		end
		
		-- Create APPs
		jj = math.floor(des_app_list_num / 5)
		kk = des_app_list_num % 5
		if kk > 0 then
			max_page_app = jj + 1
		else
			max_page_app = jj
		end
		
		if des_app2 == "------" then
			kk = (act_page - 1) * 5
			for ii = 1, 5 do
				jj = kk + ii
				if jj > des_app_list_num then
					right_line[ii] = ""
					des_app_sel[ii] = "------"
				else
					temp_str = string.sub(des_app_list[jj][1], 1, 1)
					right_line[ii] = "     "
					if string.sub(des_app_list[jj][1], 1, 2) == "RW" then
						right_line[ii] = right_line[ii] .. string.sub(des_app_list[jj][1], 3, -1)
					elseif temp_str == "I" then
						right_line[ii] = right_line[ii] .. "ILS"
						right_line[ii] = right_line[ii] .. string.sub(des_app_list[jj][1], 2, -1)
					elseif temp_str == "R" then
						right_line[ii] = right_line[ii] .. "RNV"
						right_line[ii] = right_line[ii] .. string.sub(des_app_list[jj][1], 2, -1)
					elseif temp_str == "D" then
						right_line[ii] = right_line[ii] .. "VDM"
						right_line[ii] = right_line[ii] .. string.sub(des_app_list[jj][1], 2, -1)
					elseif temp_str == "S" then
						right_line[ii] = right_line[ii] .. "VDM"
						right_line[ii] = right_line[ii] .. string.sub(des_app_list[jj][1], 2, -1)
					elseif temp_str == "L" then
						right_line[ii] = right_line[ii] .. "LOC"
						right_line[ii] = right_line[ii] .. string.sub(des_app_list[jj][1], 2, -1)
					elseif temp_str == "Q" then
						right_line[ii] = right_line[ii] .. "NDB"
						right_line[ii] = right_line[ii] .. string.sub(des_app_list[jj][1], 2, -1)
					elseif temp_str == "N" then
						right_line[ii] = right_line[ii] .. "NDB"
						right_line[ii] = right_line[ii] .. string.sub(des_app_list[jj][1], 2, -1)
					elseif temp_str == "J" then
						right_line[ii] = right_line[ii] .. "GLS"
						right_line[ii] = right_line[ii] .. string.sub(des_app_list[jj][1], 2, -1)
					elseif temp_str == "V" then
						right_line[ii] = right_line[ii] .. "VOR"
						right_line[ii] = right_line[ii] .. string.sub(des_app_list[jj][1], 2, -1)
					else
						right_line[ii] = right_line[ii] .. des_app_list[jj][1]
					end
					des_app_sel[ii] = des_app_list[jj][1]
				end
			end
		else
			if des_app_exec == 1 then
				temp_str = string.sub(des_app2, 1, 1)
				right_line[1] = "<SEL>"
				if string.sub(des_app2, 1, 2) == "RW" then
					right_line[1] = right_line[1] .. string.sub(des_app2, 3, -1)
				elseif temp_str == "I" then
					right_line[1] = right_line[1] .. "ILS"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "R" then
					right_line[1] = right_line[1] .. "RNV"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "D" then
					right_line[1] = right_line[1] .. "VDM"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "S" then
					right_line[1] = right_line[1] .. "VDM"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "L" then
					right_line[1] = right_line[1] .. "LOC"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "Q" then
					right_line[1] = right_line[1] .. "NDB"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "N" then
					right_line[1] = right_line[1] .. "NDB"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "J" then
					right_line[1] = right_line[1] .. "GLS"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "V" then
					right_line[1] = right_line[1] .. "VOR"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				else
					right_line[1] = right_line[1] .. des_app2
				end
			else
				temp_str = string.sub(des_app2, 1, 1)
				right_line[1] = "<ACT>"
				B738DR_rnav_enable = 0
				if string.sub(des_app2, 1, 2) == "RW" then
					right_line[1] = right_line[1] .. string.sub(des_app2, 3, -1)
				elseif temp_str == "I" then
					right_line[1] = right_line[1] .. "ILS"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "R" then
					right_line[1] = right_line[1] .. "RNV"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
					B738DR_rnav_enable = 2
				elseif temp_str == "D" then
					right_line[1] = right_line[1] .. "VDM"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "S" then
					right_line[1] = right_line[1] .. "VDM"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "L" then
					right_line[1] = right_line[1] .. "LOC"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
					B738DR_rnav_enable = 1
				elseif temp_str == "Q" then
					right_line[1] = right_line[1] .. "NDB"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "N" then
					right_line[1] = right_line[1] .. "NDB"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				elseif temp_str == "J" then
					right_line[1] = right_line[1] .. "GLS"
					right_line[1] = right_line[1] .. string.sub(des_app2, 2, -1)
				else
					right_line[1] = right_line[1] .. des_app2
				end
			end
			max_page_app = 1
		end
		
		-- Create APP Transitions
		if des_app2 ~= "------" then
			line2_x = line2_x .. "       TRANS"
			
			if des_app_tns_list_num == 0 then
				des_tns_sel[1] = "------"
				des_tns_sel[2] = "------"
				des_tns_sel[3] = "------"
				des_tns_sel[4] = "------"
				des_tns_sel[5] = "------"
				--line2_x = line2_x .. "       TRANS"
				right_line[2] = "-NONE-"
			else
				jj = math.floor(des_app_tns_list_num / 4)
				kk = des_app_tns_list_num % 4
				if kk > 0 then
					max_page_tns = jj + 1
				else
					max_page_tns = jj
				end
				
				if des_app_tns2 == "------" then
					des_tns_sel[1] = "------"
					kk = (act_page - 1) * 4
					
					des_tns_sel[1] = "------"
					
					for ii = 2, 5 do
						jj = kk + ii - 1
						if jj > des_app_tns_list_num then
							right_line[ii] = ""
							des_tns_sel[ii] = "------"
						else
							right_line[ii] = des_app_tns_list[jj]
							des_tns_sel[ii] = des_app_tns_list[jj]
						end
					end
				else
					if des_app_tns_exec == 1 then
						right_line[2] = "<SEL>" .. des_app_tns2
					else
						right_line[2] = "<ACT>" .. des_app_tns2
					end
					max_page_tns = 1
				end
			end
		else
			max_page_tns = 1
			--line2_x = line2_x .. "            "
		end
		
		if des_app2 ~= "------" then
			if set_ils == 0 then
				set_ils = 1
				if string.sub(des_app2, 1, 1) == "I" then
					B738DR_fms_ils_disable = 0
				else
					B738DR_fms_ils_disable = 1
				end
			end
			if des_app_tns2 ~= "------" or des_app_tns_list_num == 0 then
				line3_x = "                    G/S "
				if B738DR_fms_ils_disable == 0 then
					right_line[3] = "  /   >"
					line3_g = "                 ON     "
					line3_s = "                    OFF "
				else
					right_line[3] = "  /   >"
					line3_g = "                    OFF "
					line3_s = "                 ON     "
				end
			else
				line3_x = "                        "
				line3_s = "                        "
			end
		else
			line3_x = "                        "
			line3_s = "                        "
			B738DR_fms_ils_disable = 0
			found_ils = 0
			set_ils = 0
		end
		
		-- Display engine
		for ii = 1, 5 do
			sid_len = string.len(left_line[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					left_line[ii] = left_line[ii] .. " "
				end
			end
			right_len = 24 - string.len(left_line[ii])
			sid_len = string.len(right_line[ii])
			if sid_len < right_len then
				for jj = sid_len, (right_len - 1) do
					right_line[ii] = " " .. right_line[ii]
				end
			end
		end
		
		line1_l = left_line[1] .. right_line[1]
		line2_l = left_line[2] .. right_line[2]
		line3_l = left_line[3] .. right_line[3]
		line4_l = left_line[4] .. right_line[4]
		line5_l = left_line[5] .. right_line[5]
		
		
		max_page = math.max(1, max_page_star, max_page_app, max_page_tns, max_page_star_tns)
		
		if arr_data == 0 then
			line0_l = "   " .. des_icao
		elseif arr_data == 1 then
			line0_l = "   " .. ref_icao
		end
		line0_l = line0_l .. " ARRIVALS        "
		line0_s = "                    " .. string.format("%1d",act_page)
		line0_s = line0_s .. "/"
		line0_s = line0_s .. string.format("%1d",max_page)
		line1_x = " STARS        APPROACHES"
		
		line6_x = "------------------------"
		if des_star_exec == 1 or des_star_tns_exec == 1 or des_app_exec == 1 or des_app_tns_exec == 1 then
			line6_l = "<ERASE            ROUTE>"
		else
			line6_l = "                  ROUTE>"
		end
	end

end





function string_pos(lat_pos, lon_pos)

	local position_min = ""
	local position_deg = ""
	local position = ""
	local temp_deg = 0
	local temp_min = 0
	local navaid_lat_deg = 0
	local navaid_lat_min = 0
	local navaid_lon_deg = 0
	local navaid_lon_min = 0
	local navaid_lat_ns = 0
	local navaid_lon_ew = 0
	
	local lat = (math.abs(lat_pos))
	local lat_min_dec = (math.fmod(lat,1.0)*600)
	navaid_lat_deg = (math.floor(lat))
	navaid_lat_min = (string.format("%06.3f",lat_min_dec))
	navaid_lat_ns = 0
	if lat_pos < 0 then
		navaid_lat_ns = 1
	end
	
	local lon = (math.abs(lon_pos))
	local lon_min_dec = (math.fmod(lon,1.0)*600)
	navaid_lon_deg = (math.floor(lon))
	navaid_lon_min = (string.format("%06.3f",lon_min_dec))
	navaid_lon_ew = 0
	if lon_pos < 0 then
		navaid_lon_ew = 1
	end
			
	temp_deg = string.format("%02d", navaid_lat_deg)
	temp_min = string.format("%05.1f", navaid_lat_min)
	if navaid_lat_ns == 1 then
		position = ("S" .. temp_deg)
	else
		position = ("N" .. temp_deg)
	end
	position = position .. string.sub(temp_min, 1, 2)
	position = position .. "."
	position = position .. string.sub(temp_min, 3, 3)
	temp_deg = string.format("%03d", navaid_lon_deg)
	temp_min = string.format("%05.1f", navaid_lon_min)
	if navaid_lon_ew == 1 then
		position = (position .. "W")
	else
		position = (position .. "E")
	end
	position = position .. temp_deg
	position = position .. string.sub(temp_min, 1, 2)
	position = position .. "."
	position = position .. string.sub(temp_min, 3, 3)
	
	return position

end

function B738_fmc_sel_wpt()

	if page_sel_wpt == 1 then
		
		--act_page = 1
		--max_page = 1
		
		local ii = 0
		local jj = 0
		local kk = 0
		local left_line = {}
		left_line[1] = ""
		left_line[2] = ""
		left_line[3] = ""
		left_line[4] = ""
		left_line[5] = ""
		local right_line = {}
		right_line[1] = ""
		right_line[2] = ""
		right_line[3] = ""
		right_line[4] = ""
		right_line[5] = ""
		local left_linex = {}
		left_linex[1] = ""
		left_linex[2] = ""
		left_linex[3] = ""
		left_linex[4] = ""
		left_linex[5] = ""
		-- local right_linex = {}
		-- right_linex[1] = ""
		-- right_linex[2] = ""
		-- right_linex[3] = ""
		-- right_linex[4] = ""
		-- right_linex[5] = ""
		
		local sid_len = 0
		local temp_str = ""
		local rw_tgt = ""
		local right_len = 0
		
		local max_page_wpt = 0
		
		jj = math.floor(navaid_list_n / 5)
		kk = navaid_list_n % 5
		
		if kk > 0 then
			max_page_wpt = jj + 1
		else
			max_page_wpt = jj
		end
		
		kk = (act_page - 1) * 5
		for ii = 1, 5 do
			jj = kk + ii
			if jj > navaid_list_n then
				left_linex[ii] = ""
				--right_linex[ii] = ""
				left_line[ii] = ""
				right_line[ii] = ""
			else
				sid_len = navaid_list[jj][1]
				if sid_len == 1 then
					left_linex[ii] = " VOR    " .. navaid_list[jj][7]
				elseif sid_len == 2 then
					left_linex[ii] = " VORDME " .. navaid_list[jj][7]
				elseif sid_len == 3 then
					left_linex[ii] = " NDB    " .. navaid_list[jj][7]
				elseif sid_len == 4 then
					left_linex[ii] = " WPT    " .. navaid_list[jj][7]
				elseif sid_len == 9 then
					left_linex[ii] = " APT    " .. navaid_list[jj][7]
				end
				--right_linex[ii] = "" --name
				
				temp_str = navaid_list[jj][6]
				sid_len = string.len(temp_str)
				if sid_len == 3 then
					temp_str = navaid_list[jj][6]
				elseif sid_len == 4 then
					temp_str = string.sub(navaid_list[jj][6], 1, 3) .. "." .. string.sub(navaid_list[jj][6], -1, -1)
				elseif sid_len == 5 then
					temp_str = string.sub(navaid_list[jj][6], 1, 3) .. "." .. string.sub(navaid_list[jj][6], -2, -1)
				else
					temp_str = ""
				end
				left_line[ii] = temp_str
				right_line[ii] = string_pos(navaid_list[jj][2], navaid_list[jj][3])
			end
		end
		
		-- line1_x = " VORTAC SYMRNA          "
		-- line1_l = "114.80 N40`38.0W064`31.5"
		-- line1_s = "                        "
		-- line2_x = " VORDME ENODAK          "
		-- line2_l = "112.40 N44`27.4E101`15.7"
		-- line2_s = "                        "
		-- line3_x = " NDB    ENOREE          "
		-- line3_l = "278.0  N34`18.7W081`38.2"
		-- line3_s = "                        "
		-- line4_x = " WPT                    "
		-- line4_l = "       N13`43.2W120`52.7"
		-- line4_s = "                        "
		-- line5_x = "                        "
		-- line5_l = "<APPROACH               "
		-- line5_s = "                        "
		-- line6_x = "                        "
		-- line6_l = "<OFFSET      NAV STATUS>"
		-- line6_s = "                        "
		
		-- Type: VOR, VORTAC, VORDME, NDB, LOC, ILS, DME, ILSDME, LOCDME, APT, WPT
		
		-- Display engine
		for ii = 1, 5 do
			sid_len = string.len(left_line[ii])
			if sid_len < 7 then
				for jj = sid_len, 6 do
					left_line[ii] = left_line[ii] .. " "
				end
			end
			right_len = 24 - string.len(left_line[ii])
			sid_len = string.len(right_line[ii])
			if sid_len < right_len then
				for jj = sid_len, (right_len - 1) do
					right_line[ii] = " " .. right_line[ii]
				end
			end
		end
		
		line1_l = left_line[1] .. right_line[1]
		line2_l = left_line[2] .. right_line[2]
		line3_l = left_line[3] .. right_line[3]
		line4_l = left_line[4] .. right_line[4]
		line5_l = left_line[5] .. right_line[5]
		
		-- for ii = 1, 5 do
			-- sid_len = string.len(left_linex[ii])
			-- if sid_len < 7 then
				-- for jj = sid_len, 6 do
					-- left_linex[ii] = left_linex[ii] .. " "
				-- end
			-- end
			-- right_len = 24 - string.len(left_linex[ii])
			-- sid_len = string.len(right_linex[ii])
			-- if sid_len < right_len then
				-- for jj = sid_len, (right_len - 1) do
					-- right_linex[ii] = " " .. right_linex[ii]
				-- end
			-- end
		-- end
		
		line1_x = left_linex[1] --.. right_linex[1] 
		line2_x = left_linex[2] --.. right_linex[2] 
		line3_x = left_linex[3] --.. right_linex[3] 
		line4_x = left_linex[4] --.. right_linex[4] 
		line5_x = left_linex[5] --.. right_linex[5] 
		
		
		max_page = math.max(1, max_page_wpt)
		
		temp_str = navaid_list[1][4]
		if string.len(temp_str) > 6 then
			temp_str = string.sub(temp_str, 1, 6)
		end
		line0_l = " SEL DESIRED " .. temp_str
		line0_s = "                    " .. string.format("%1d",act_page)
		line0_s = line0_s .. "/"
		line0_s = line0_s .. string.format("%1d",max_page)
		--line6_l = "<ERASE                  "
		
	
	end

end


function B738_fmc_sel_wpt2()

	if page_sel_wpt2 == 1 then
		
		local ii = 0
		local jj = 0
		local kk = 0
		local left_line = {}
		left_line[1] = ""
		left_line[2] = ""
		left_line[3] = ""
		left_line[4] = ""
		left_line[5] = ""
		local right_line = {}
		right_line[1] = ""
		right_line[2] = ""
		right_line[3] = ""
		right_line[4] = ""
		right_line[5] = ""
		local left_linex = {}
		left_linex[1] = ""
		left_linex[2] = ""
		left_linex[3] = ""
		left_linex[4] = ""
		left_linex[5] = ""
		
		local sid_len = 0
		local temp_str = ""
		local rw_tgt = ""
		local right_len = 0
		
		local max_page_wpt = 0
		
		jj = math.floor(navaid_list_n / 5)
		kk = navaid_list_n % 5
		
		if kk > 0 then
			max_page_wpt = jj + 1
		else
			max_page_wpt = jj
		end
		
		kk = (act_page - 1) * 5
		for ii = 1, 5 do
			jj = kk + ii
			if jj > navaid_list_n then
				left_linex[ii] = ""
				left_line[ii] = ""
				right_line[ii] = ""
			else
				sid_len = navaid_list[jj][1]
				if sid_len == 1 then
					left_linex[ii] = " VOR    " .. navaid_list[jj][7]
				elseif sid_len == 2 then
					left_linex[ii] = " VORDME " .. navaid_list[jj][7]
				elseif sid_len == 3 then
					left_linex[ii] = " NDB    " .. navaid_list[jj][7]
				elseif sid_len == 4 then
					left_linex[ii] = " WPT    " .. navaid_list[jj][7]
				elseif sid_len == 9 then
					left_linex[ii] = " APT    " .. navaid_list[jj][7]
				end
				
				temp_str = navaid_list[jj][6]
				sid_len = string.len(temp_str)
				if sid_len == 3 then
					temp_str = navaid_list[jj][6]
				elseif sid_len == 4 then
					temp_str = string.sub(navaid_list[jj][6], 1, 3) .. "." .. string.sub(navaid_list[jj][6], -1, -1)
				elseif sid_len == 5 then
					temp_str = string.sub(navaid_list[jj][6], 1, 3) .. "." .. string.sub(navaid_list[jj][6], -2, -1)
				else
					temp_str = ""
				end
				left_line[ii] = temp_str
				right_line[ii] = string_pos(navaid_list[jj][2], navaid_list[jj][3])
			end
		end
		
		-- Type: VOR, VORTAC, VORDME, NDB, LOC, ILS, DME, ILSDME, LOCDME, APT, WPT
		
		-- Display engine
		for ii = 1, 5 do
			sid_len = string.len(left_line[ii])
			if sid_len < 7 then
				for jj = sid_len, 6 do
					left_line[ii] = left_line[ii] .. " "
				end
			end
			right_len = 24 - string.len(left_line[ii])
			sid_len = string.len(right_line[ii])
			if sid_len < right_len then
				for jj = sid_len, (right_len - 1) do
					right_line[ii] = " " .. right_line[ii]
				end
			end
		end
		
		line1_l = left_line[1] .. right_line[1]
		line2_l = left_line[2] .. right_line[2]
		line3_l = left_line[3] .. right_line[3]
		line4_l = left_line[4] .. right_line[4]
		line5_l = left_line[5] .. right_line[5]
		
		
		line1_x = left_linex[1] 
		line2_x = left_linex[2]
		line3_x = left_linex[3]
		line4_x = left_linex[4]
		line5_x = left_linex[5]
		
		
		max_page = math.max(1, max_page_wpt)
		
		temp_str = navaid_list[1][4]
		if string.len(temp_str) > 6 then
			temp_str = string.sub(temp_str, 1, 6)
		end
		line0_l = " SEL DESIRED " .. temp_str
		line0_s = "                    " .. string.format("%1d",act_page)
		line0_s = line0_s .. "/"
		line0_s = line0_s .. string.format("%1d",max_page)
		
	
	end

end


function B738_fmc_arr()
		
	if page_arr == 1 then
		
		clr_repeat = 1
		
		local ii = 0
		local jj = 0
		local kk = 0
		local ll = 0
		
		local max_page_star = 0
		local max_page_star_tns = 0
		local max_page_app = 0
		local max_page_tns = 0
		
		local app_old = ""
		local des_star_all = 0
		
		local left_line = {}
		left_line[1] = ""
		left_line[2] = ""
		left_line[3] = ""
		left_line[4] = ""
		left_line[5] = ""
		local right_line = {}
		right_line[1] = ""
		right_line[2] = ""
		right_line[3] = ""
		right_line[4] = ""
		right_line[5] = ""
		
		local sid_len = 0
		local temp_str = ""
		local rw_tgt = ""
		local right_len = 0
		local des_star_tmp = ""
		local temp_str1 = ""
		local temp_str2 = ""
		local only_one  = 0
		local only_one_idx = 0
		
		local list_des_star = {}
		local list_des_star_n = 0
		local list_des_star2 = {}
		local list_des_star2_n = 0
		
		-- Create the same STARs with other RWY
		if data_des_star_n > 1 then
			temp_str = data_des_star[1][1]
			for ii = 2, data_des_star_n do
				if data_des_star[ii][1] == temp_str then
					data_des_star[ii-1][1] = data_des_star[ii-1][1] .. "."
					data_des_star[ii-1][1] = data_des_star[ii-1][1] .. string.sub(data_des_star[ii-1][2],3,-1)
					sid_len = 1
				else
					if sid_len == 1 then
						data_des_star[ii-1][1] = data_des_star[ii-1][1] .. "."
						data_des_star[ii-1][1] = data_des_star[ii-1][1] .. string.sub(data_des_star[ii-1][2],3,-1)
						sid_len = 0
					end
				end
				temp_str = data_des_star[ii][1]
			end
		end
		
		if sid_len == 1 then
			data_des_star[data_des_star_n][1] = data_des_star[data_des_star_n][1] .. "."
			data_des_star[data_des_star_n][1] = data_des_star[data_des_star_n][1] .. string.sub(data_des_star[data_des_star_n][2],3,-1)
			sid_len = 0
		end
		
		
		-- Create list STARs "B"
		if data_des_star_n > 1 then
			for ii = 1, data_des_star_n do
				
				kk,jj = string.find(data_des_star[ii][1], "%.")
				if kk ~= nil then
				
				
				-- if string.sub(data_des_star[ii][1], -1, -1) == "B" then
				if string.sub(data_des_star[ii][2], -1, -1) == "B" then
					for kk = 1, des_rwy_num do
						--if des_icao == "KSEA" or des_icao == "KORD" then	-- fix KSEA, KORD ignore xxC
						if string.sub(des_icao, 1, 1) == "K" then	-- fix Kxxx = ignore approach xxC
							if string.sub(des_data[kk][1], -1, -1) ~= "C" then
								-- if string.sub(data_des_star[ii][1], -3, -2) == string.sub(des_data[kk][1], -3, -2) then
								if string.sub(data_des_star[ii][2], -3, -2) == string.sub(des_data[kk][1], -3, -2) then
									list_des_star2_n = list_des_star2_n + 1
									list_des_star2[list_des_star2_n] = {}
									list_des_star2[list_des_star2_n][1] = string.sub(data_des_star[ii][1], 1, -2) .. string.sub(des_data[kk][1], -1, -1)
								end
							end
						else
							if string.sub(data_des_star[ii][2], -3, -2) == string.sub(des_data[kk][1], -3, -2) then
								list_des_star2_n = list_des_star2_n + 1
								list_des_star2[list_des_star2_n] = {}
								list_des_star2[list_des_star2_n][1] = string.sub(data_des_star[ii][1], 1, -2) .. string.sub(des_data[kk][1], -1, -1)
							end
						end
					end
					
				else
					list_des_star2_n = list_des_star2_n + 1
					list_des_star2[list_des_star2_n] = {}
					list_des_star2[list_des_star2_n][1] = data_des_star[ii][1]
				end
				
				else
					list_des_star2_n = list_des_star2_n + 1
					list_des_star2[list_des_star2_n] = {}
					list_des_star2[list_des_star2_n][1] = data_des_star[ii][1]
				end
				
			end
		end
		
		-- Create list STARs for display
		if list_des_star2_n > 1 then
			only_one = 0
			-- find empty trans
			ll,jj = string.find(list_des_star2[1][1], "%.")
			if ll == nil then
				des_star_tmp = list_des_star2[1][1]
			else
				des_star_tmp = string.sub(list_des_star2[1][1], 1, ll - 1)
			end
			for kk = 1, data_des_star_tns_n do 
				if des_star_tmp == data_des_star_tns[kk][1] then
					if string.sub(data_des_star_tns[kk][2],1 ,1) == " " then
						only_one = 1
					end
				end
			end
			if only_one == 0 then
				list_des_star_n = list_des_star_n + 1
				list_des_star[list_des_star_n] = {}
				list_des_star[list_des_star_n][1] = list_des_star2[1][1]
			else
				list_des_star_n = list_des_star_n + 1
				list_des_star[list_des_star_n] = {}
				list_des_star[list_des_star_n][1] = des_star_tmp
			end
			temp_str = des_star_tmp
			for ii = 2, list_des_star2_n do
				
				ll,jj = string.find(list_des_star2[ii][1], "%.")
				if ll == nil then
					des_star_tmp = list_des_star2[ii][1]
				else
					des_star_tmp = string.sub(list_des_star2[ii][1], 1, ll - 1)
				end
				
				if des_star_tmp == temp_str then
					if only_one == 0 then
						list_des_star_n = list_des_star_n + 1
						list_des_star[list_des_star_n] = {}
						list_des_star[list_des_star_n][1] = list_des_star2[ii][1]
					end
				else
					only_one = 0
					-- find empty trans
					for kk = 1, data_des_star_tns_n do 
						if des_star_tmp == data_des_star_tns[kk][1] then
							if string.sub(data_des_star_tns[kk][2],1 ,1) == " " then
								only_one = 1
							end
						end
					end
					if only_one == 0 then
						list_des_star_n = list_des_star_n + 1
						list_des_star[list_des_star_n] = {}
						list_des_star[list_des_star_n][1] = list_des_star2[ii][1]
					else
						list_des_star_n = list_des_star_n + 1
						list_des_star[list_des_star_n] = {}
						list_des_star[list_des_star_n][1] = des_star_tmp
					end
				end
				temp_str = des_star_tmp
			end
		else
			if data_des_star_n == 1 then
				list_des_star_n = list_des_star_n + 1
				list_des_star[list_des_star_n] = {}
				list_des_star[list_des_star_n][1] = data_des_star[1][1]
			end
		end
		
		-- Create STARs
		jj = math.floor(list_des_star_n / 5)
		kk = list_des_star_n % 5
		if kk > 0 then
			max_page_star = jj + 1
		else
			max_page_star = jj
		end
		
		if des_star == "------" then
			kk = (act_page - 1) * 5
			for ii = 1, 5 do
				jj = kk + ii
				if jj > list_des_star_n or des_app ~= "------" then
					left_line[ii] = ""
					des_star_sel[ii] = "------"
				else
					left_line[ii] = list_des_star[jj][1]
					des_star_sel[ii] = list_des_star[jj][1]
				end
			end
			if left_line[1] == "" then
				max_page_star = 1
				left_line[1] = "-NONE-"
			end
		else
			if simDR_fms_exec_light1 == 1 and ref_sid_exec == 1 then
				left_line[1] = des_star .. "<SEL>"
			else
				left_line[1] = des_star .. "<ACT>"
			end
			max_page_star = 1
		end
		
		
		
		
		
		
		
		
		-- -- Create STARs
		-- jj = math.floor(data_des_star_n / 5)
		-- kk = data_des_star_n % 5
		-- if kk > 0 then
			-- max_page_star = jj + 1
		-- else
			-- max_page_star = jj
		-- end
		
		-- if des_star == "------" then
			-- kk = (act_page - 1) * 5
			-- for ii = 1, 5 do
				-- jj = kk + ii
				-- if jj > data_des_star_n or des_app ~= "------" then
					-- left_line[ii] = ""
					-- des_star_sel[ii] = "------"
				-- else
					-- left_line[ii] = data_des_star[jj][1]
					-- des_star_sel[ii] = data_des_star[jj][1]
				-- end
			-- end
			-- if left_line[1] == "" then
				-- max_page_star = 1
			-- end
		-- else
			-- if simDR_fms_exec_light1 == 1 and ref_sid_exec == 1 then
				-- left_line[1] = des_star .. "<SEL>"
			-- else
				-- left_line[1] = des_star .. "<ACT>"
			-- end
			-- max_page_star = 1
		-- end
		
		-- Create STAR TRANSs
		if des_star ~= "------" then
			line2_x = " TRANS      "
			des_num_star_tns = 0
			des_data_star_tns = {}
			kk,jj = string.find(des_star, "%.")
			if kk == nil then
				des_star_tmp = des_star
			else
				des_star_tmp = string.sub(des_star, 1, kk - 1)
			end
			for ii = 1, data_des_star_tns_n do
				if data_des_star_tns[ii][1] == des_star_tmp then
					des_num_star_tns = des_num_star_tns + 1
					des_data_star_tns[des_num_star_tns] = data_des_star_tns[ii][2]
				end
			end
			
			if des_num_star_tns == 0 then
				des_star_tns_sel[1] = "------"
				des_star_tns_sel[2] = "------"
				des_star_tns_sel[3] = "------"
				des_star_tns_sel[4] = "------"
				des_star_tns_sel[5] = "------"
				line2_x = " TRANS      "
				left_line[2] = "-NONE-"
			else
				jj = math.floor(des_num_star_tns / 4)
				kk = des_num_star_tns % 4
				if kk > 0 then
					max_page_star_tns = jj + 1
				else
					max_page_star_tns = jj
				end
				
				if des_star_trans == "------" then
					des_star_tns_sel[1] = "------"
					kk = (act_page - 1) * 4
					
					des_star_tns_sel[1] = "------"
					
					for ii = 2, 5 do
						jj = kk + ii - 1
						if jj > des_num_star_tns then
							left_line[ii] = ""
							des_star_tns_sel[ii] = "------"
						else
							left_line[ii] = des_data_star_tns[jj]
							des_star_tns_sel[ii] = des_data_star_tns[jj]
						end
					end
				else
					if simDR_fms_exec_light1 == 1 and ref_tns_exec == 1 then
						left_line[2] = des_star_trans .. "<SEL>"
					else
						left_line[2] = des_star_trans .. "<ACT>"
					end
					max_page_star_tns = 1
				end
			end
		else
			max_page_star_tns = 1
			line2_x = "            "
		end
		
		-- Create APPs
		if des_star ~= "------" then	-- if selected STAR
			
			des_num_app_act = 0
			des_data_app_act = {}

			kk,jj = string.find(des_star, "%.")
			if kk == nil then
				--des_star_tmp = des_star
				for ll = 1, data_des_app_n do
				
				
				
					for ii = 1, data_des_star_n do
						kk,jj = string.find(data_des_star[ii][1], "%.")
						if kk == nil then
							des_star_tmp = data_des_star[ii][1]
						else
							des_star_tmp = string.sub(data_des_star[ii][1], 1, kk - 1)
						end
						if des_star == des_star_tmp then
							rw_tgt = data_des_star[ii][2]
						
							if string.len(data_des_app[ll]) > 3 then
								temp_str1 = string.sub(data_des_app[ll],4,4)
								if temp_str1 == "R" or temp_str1 == "L" or temp_str1 == "C" then
									temp_str = "RW" .. string.sub(data_des_app[ll],2,4)
								else
									temp_str = "RW" .. string.sub(data_des_app[ll],2,3)
								end
							else
								temp_str = "RW" .. string.sub(data_des_app[ll],2,3)
							end
							
							if string.sub(rw_tgt,-1,-1) == "B" then
								if string.sub(des_icao, 1, 1) == "K" then 
									if string.sub(temp_str,-1,-1) == "C" then
										temp_str1 = "A"
										temp_str2 = "B"
									else
										temp_str1 = string.sub(rw_tgt,1,-2)
										temp_str2 = string.sub(temp_str,1,-2)
									end
								else
									temp_str1 = string.sub(rw_tgt,1,-2)
									temp_str2 = string.sub(temp_str,1,-2)
								end
							else
								temp_str1 = "A"
								temp_str2 = "B"
							end
							
							if rw_tgt == temp_str or rw_tgt == "ALL" or temp_str1 == temp_str2 then
								des_num_app_act = des_num_app_act + 1
								des_data_app_act[des_num_app_act] = {}
								des_data_app_act[des_num_app_act][1] = data_des_app[ll]
							end
						end
						
					end
					
				end
			else
					
				rw_tgt = "RW" .. string.sub(des_star, kk + 1, -1)
				for ll = 1, data_des_app_n do
					if string.len(data_des_app[ll]) > 3 then
						temp_str1 = string.sub(data_des_app[ll],4,4)
						if temp_str1 == "R" or temp_str1 == "L" or temp_str1 == "C" then
							temp_str = "RW" .. string.sub(data_des_app[ll],2,4)
						else
							temp_str = "RW" .. string.sub(data_des_app[ll],2,3)
						end
					else
						temp_str = "RW" .. string.sub(data_des_app[ll],2,3)
					end
					
					if string.sub(rw_tgt,-1,-1) == "B" then
						if string.sub(temp_str,-1,-1) == "C" then
							temp_str1 = "A"
							temp_str2 = "B"
						else
							temp_str1 = string.sub(rw_tgt,1,-2)
							temp_str2 = string.sub(temp_str,1,-2)
						end
					else
						temp_str1 = "A"
						temp_str2 = "B"
					end
					
					if rw_tgt == temp_str or rw_tgt == "ALL" or temp_str1 == temp_str2 then
						des_num_app_act = des_num_app_act + 1
						des_data_app_act[des_num_app_act] = {}
						des_data_app_act[des_num_app_act][1] = data_des_app[ll]
					end
				end
			
			end
			
		else
			if des_app_from_apt == 0 then
			
				des_num_app_act = 0
				des_data_app_act = {}
				for ii = 1, data_des_app_n do
					des_num_app_act = des_num_app_act + 1
					des_data_app_act[des_num_app_act] = {}
					des_data_app_act[des_num_app_act][1] = data_des_app[ii]
				end
			
			end
		end
		
			jj = math.floor(des_num_app_act / 5)
			kk = des_num_app_act % 5
			if kk > 0 then
				max_page_app = jj + 1
			else
				max_page_app = jj
			end
			
			if des_app == "------" then
				kk = (act_page - 1) * 5
				for ii = 1, 5 do
					jj = kk + ii
					if jj > des_num_app_act then
						right_line[ii] = ""
						des_app_sel[ii] = "------"
					else
						temp_str = string.sub(des_data_app_act[jj][1], 1, 1)
						right_line[ii] = "     "
						if string.sub(des_data_app_act[jj][1], 1, 2) == "RW" then
							right_line[ii] = right_line[ii] .. string.sub(des_data_app_act[jj][1], 3, -1)
						elseif temp_str == "I" then
							right_line[ii] = right_line[ii] .. "ILS"
							right_line[ii] = right_line[ii] .. string.sub(des_data_app_act[jj][1], 2, -1)
						elseif temp_str == "R" then
							right_line[ii] = right_line[ii] .. "RNV"
							right_line[ii] = right_line[ii] .. string.sub(des_data_app_act[jj][1], 2, -1)
						elseif temp_str == "D" then
							right_line[ii] = right_line[ii] .. "VDM"
							right_line[ii] = right_line[ii] .. string.sub(des_data_app_act[jj][1], 2, -1)
						elseif temp_str == "S" then
							right_line[ii] = right_line[ii] .. "VDM"
							right_line[ii] = right_line[ii] .. string.sub(des_data_app_act[jj][1], 2, -1)
						elseif temp_str == "L" then
							right_line[ii] = right_line[ii] .. "LOC"
							right_line[ii] = right_line[ii] .. string.sub(des_data_app_act[jj][1], 2, -1)
						elseif temp_str == "Q" then
							right_line[ii] = right_line[ii] .. "NDB"
							right_line[ii] = right_line[ii] .. string.sub(des_data_app_act[jj][1], 2, -1)
						elseif temp_str == "N" then
							right_line[ii] = right_line[ii] .. "NDB"
							right_line[ii] = right_line[ii] .. string.sub(des_data_app_act[jj][1], 2, -1)
						elseif temp_str == "J" then
							right_line[ii] = right_line[ii] .. "GLS"
							right_line[ii] = right_line[ii] .. string.sub(des_data_app_act[jj][1], 2, -1)
						else
							right_line[ii] = right_line[ii] .. des_data_app_act[jj][1]
						end
						des_app_sel[ii] = des_data_app_act[jj][1]
					end
				end
			else
				if simDR_fms_exec_light1 == 1 and ref_rwy_exec == 1 then
					temp_str = string.sub(des_app, 1, 1)
					right_line[1] = "<SEL>"
					if string.sub(des_app, 1, 2) == "RW" then
						right_line[1] = right_line[1] .. string.sub(des_app, 3, -1)
					elseif temp_str == "I" then
						right_line[1] = right_line[1] .. "ILS"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "R" then
						right_line[1] = right_line[1] .. "RNV"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "D" then
						right_line[1] = right_line[1] .. "VDM"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "S" then
						right_line[1] = right_line[1] .. "VDM"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "L" then
						right_line[1] = right_line[1] .. "LOC"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "Q" then
						right_line[1] = right_line[1] .. "NDB"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "N" then
						right_line[1] = right_line[1] .. "NDB"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "J" then
						right_line[1] = right_line[1] .. "GLS"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					else
						right_line[1] = right_line[1] .. des_app
					end
				else
					temp_str = string.sub(des_app, 1, 1)
					right_line[1] = "<ACT>"
					B738DR_rnav_enable = 0
					if string.sub(des_app, 1, 2) == "RW" then
						right_line[1] = right_line[1] .. string.sub(des_app, 3, -1)
					elseif temp_str == "I" then
						right_line[1] = right_line[1] .. "ILS"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "R" then
						right_line[1] = right_line[1] .. "RNV"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
						B738DR_rnav_enable = 2
					elseif temp_str == "D" then
						right_line[1] = right_line[1] .. "VDM"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "S" then
						right_line[1] = right_line[1] .. "VDM"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "L" then
						right_line[1] = right_line[1] .. "LOC"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
						B738DR_rnav_enable = 1
					elseif temp_str == "Q" then
						right_line[1] = right_line[1] .. "NDB"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "N" then
						right_line[1] = right_line[1] .. "NDB"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					elseif temp_str == "J" then
						right_line[1] = right_line[1] .. "GLS"
						right_line[1] = right_line[1] .. string.sub(des_app, 2, -1)
					else
						right_line[1] = right_line[1] .. des_app
					end
				end
				max_page_app = 1
			end
		
		-- Create Transitions
		if des_app ~= "------" then		--des_star ~= "------" and des_app ~= "------" then
			line2_x = line2_x .. "       TRANS"
			des_num_app_tns = 0
			des_data_app_tns = {}
			if data_des_app_tns_n > 0 then
				for ii = 1, data_des_app_tns_n do
					if data_des_app_tns[ii][1] == des_app then
						des_num_app_tns = des_num_app_tns + 1
						
						des_data_app_tns[des_num_app_tns] = {}
						
						des_data_app_tns[des_num_app_tns][1] = data_des_app_tns[ii][2]
						des_data_app_tns[des_num_app_tns][2] = data_des_app_tns[ii][3]
					end
				end
			end
			
			if des_num_app_tns == 0 then
				des_tns_sel[1] = "------"
				des_tns_sel[2] = "------"
				des_tns_sel[3] = "------"
				des_tns_sel[4] = "------"
				des_tns_sel[5] = "------"
				line2_x = line2_x .. "       TRANS"
				right_line[2] = "-NONE-"
			else
				jj = math.floor(des_num_app_tns / 4)
				kk = des_num_app_tns % 4
				if kk > 0 then
					max_page_tns = jj + 1
				else
					max_page_tns = jj
				end
				
				if des_app_tns == "------" then
					des_tns_sel[1] = "------"
					kk = (act_page - 1) * 4
					
					des_tns_sel[1] = "------"
					
					for ii = 2, 5 do
						jj = kk + ii - 1
						if jj > des_num_app_tns then
							right_line[ii] = ""
							des_tns_sel[ii] = "------"
						else
							right_line[ii] = des_data_app_tns[jj][1]	--XXXXX
							des_tns_sel[ii] = des_data_app_tns[jj][1]
						end
					end
				else
					if simDR_fms_exec_light1 == 1 and ref_app_tns_exec == 1 then
						right_line[2] = "<SEL>" .. des_app_tns
					else
						right_line[2] = "<ACT>" .. des_app_tns
					end
					max_page_tns = 1
				end
			end
		else
			max_page_tns = 1
			line2_x = line2_x .. "            "
		end
		
		--if des_star ~= "------" and des_app ~= "------" then
		if des_app ~= "------" then
			if set_ils == 0 then
				set_ils = 1
				if string.sub(des_app, 1, 1) == "I" then --and simDR_glideslope_status == 0 then
					B738DR_fms_ils_disable = 0
				else
					B738DR_fms_ils_disable = 1
				end
			end
			-- line3_x = "                    G/S "
			-- if B738DR_fms_ils_disable == 0 then
				-- right_line[3] = "ON/   >"
				-- line3_s = "                    OFF "
			-- else
				-- right_line[3] = "  /OFF>"
				-- line3_s = "                 ON     "
			-- end
			
			if des_app_tns ~= "------" or des_num_app_tns == 0 then
				-- if set_ils == 0 then
					-- set_ils = 1
					-- if string.sub(des_app, 1, 1) == "I" then --and simDR_glideslope_status == 0 then
						-- B738DR_fms_ils_disable = 0
					-- else
						-- B738DR_fms_ils_disable = 1
					-- end
				-- end
				line3_x = "                    G/S "
				if B738DR_fms_ils_disable == 0 then
					right_line[3] = "  /   >"
					line3_g = "                 ON     "
					line3_s = "                    OFF "
				else
					right_line[3] = "  /   >"
					line3_g = "                    OFF "
					line3_s = "                 ON     "
				end
			else
				line3_x = "                        "
				line3_s = "                        "
				-- B738DR_fms_ils_disable = 0
			end
			--rw_ils = string.sub(des_app, 2, -1)
		else
			line3_x = "                        "
			line3_s = "                        "
			B738DR_fms_ils_disable = 0
			found_ils = 0
			--rw_ils = "---"
		end
		
		-- display engine
		for ii = 1, 5 do
			sid_len = string.len(left_line[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					left_line[ii] = left_line[ii] .. " "
				end
			end
			right_len = 24 - string.len(left_line[ii])
			sid_len = string.len(right_line[ii])
			if sid_len < right_len then
				for jj = sid_len, (right_len - 1) do
					right_line[ii] = " " .. right_line[ii]
				end
			end
		end
		
		line1_l = left_line[1] .. right_line[1]
		line2_l = left_line[2] .. right_line[2]
		line3_l = left_line[3] .. right_line[3]
		line4_l = left_line[4] .. right_line[4]
		line5_l = left_line[5] .. right_line[5]
		
		
		max_page = math.max(max_page_star, max_page_app, max_page_tns, max_page_star_tns)
		
		line0_l = "   " .. des_icao
		line0_l = line0_l .. " ARRIVALS        "
		line0_s = "                    " .. string.format("%1d",act_page)
		line0_s = line0_s .. "/"
		line0_s = line0_s .. string.format("%1d",max_page)
		line1_x = " STARS        APPROACHES"
		
		line6_x = "------------------------"
		if simDR_fms_exec_light1 == 1 then
			line6_l = "<CANCEL           ROUTE>"
		else
			line6_l = "                  ROUTE>"
		end
		line6_s = "                        "
		
		line1_s = "                        "
		line2_s = "                        "
		--line3_s = "                        "
		line4_s = "                        "
		line5_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end




function B738_fmc_legs2()

	if page_legs == 1 then
		--act_page = 1
		--max_page = 1
		
		local ii = 0
		local jj = 0
		local kk = 0
		local ll = 0
		--local lll = 0
		
		local max_page_legs = 0
		
		local left_line = {}
		left_line[1] = ""
		left_line[2] = ""
		left_line[3] = ""
		left_line[4] = ""
		left_line[5] = ""
		local right_line = {}
		right_line[1] = ""
		right_line[2] = ""
		right_line[3] = ""
		right_line[4] = ""
		right_line[5] = ""
		local left_line_x = {}
		left_line_x[1] = ""
		left_line_x[2] = ""
		left_line_x[3] = ""
		left_line_x[4] = ""
		left_line_x[5] = ""
		local line_s = {}
		line_s[1] = ""
		line_s[2] = ""
		line_s[3] = ""
		line_s[4] = ""
		line_s[5] = ""
		local line_ml = {}
		line_ml[1] = ""
		line_ml[2] = ""
		line_ml[3] = ""
		line_ml[4] = ""
		line_ml[5] = ""
		local line_m = {}
		line_m[1] = ""
		line_m[2] = ""
		line_m[3] = ""
		line_m[4] = ""
		line_m[5] = ""
		
		local sid_len = 0
		local temp_string = ""
		local overwrite_disc = 0
		local discon_last = 0
		
		local allign_ok = 0
		
		line1_x = ""
		line2_x = ""
		line3_x = ""
		line4_x = ""
		line5_x = ""
		line6_x = "------------------------"
		
		if B738DR_irs_left_mode > 1 or B738DR_irs_right_mode > 1 then
			allign_ok = 1
		end
		
		
		
		-- jj = math.floor((legs_num + 3 - offset - (legs_offset - legs_select)) / 5)
		-- kk = (legs_num + 3 - offset - (legs_offset - legs_select)) % 5
		jj = math.floor((legs_num2 + 2 - offset ) / 5)
		kk = (legs_num2 + 2 - offset ) % 5
		if kk > 0 then
			max_page_legs = jj + 1
		else
			max_page_legs = jj
		end
		
		if legs_num2 > 0 then --and simDR_fmc_nav_id ~= des_icao then
			
			if offset > legs_num2 then
				offset = legs_num2
			end
		
			if offset == 0 then
				offset = 1
			end
			
			if legs_step < offset then
				legs_step = offset
			end
			
			kk = (act_page - 1) * 5
			for ii = 1, 5 do
				jj = kk + ii + (offset - 1) 	-- + lll
				-- if legs_select > 0 and jj >= legs_select then
					-- jj = jj + (legs_offset - legs_select)
				-- end
				if ii == 1 then
					--line1_inv = ""
					line_m[1] = ""
					-- if jj == (legs_num2 + 1) then
						-- jj = legs_num2
					-- end
					
				end
				if jj > legs_num2 or jj == 0 then
					left_line_x[ii] = ""
					left_line[ii] = ""
					right_line[ii] = ""
				else
					if act_page == 1 and ii == 1 then
						-- is HOLD ?
						if legs_data2[jj][21] == -1 then
							-- course
							if simDR_fmc_crs == nil then
								left_line_x[ii] = " " .. "---"
							else
								left_line_x[ii] = " " .. string.format("%03d",simDR_fmc_crs)
							end
							left_line_x[ii] = left_line_x[ii] .. "`     "
							-- distance
							if simDR_fmc_dist == nil then
								left_line_x[ii] = left_line_x[ii] .. "---"
							else
								if simDR_fmc_dist < 10 then
									left_line_x[ii] = left_line_x[ii] .. string.format("%3.1f",simDR_fmc_dist)
								else
									left_line_x[ii] = left_line_x[ii] .. string.format("%3d",simDR_fmc_dist)
								end
							end
							left_line_x[ii] = left_line_x[ii] .. "NM"
							-- id
							if legs_data2[jj][1] == "DISCONTINUITY" then
								left_line_x[ii] = " THEN"
								if allign_ok == 0 then
									line_ml[1] = ""
									left_line[ii] = "*****"
								else
									line_ml[1] = "*****"
									left_line[ii] = ""
								end
								right_line[ii] = ""
								left_line_x[ii+1] = "-- ROUTE DISCONTINUITY -"
								discon_last = 1
							else
								if allign_ok == 0 or offset > legs_num2 then
									line_ml[1] = "     "
									left_line[ii] = legs_data2[jj][1]
								else
									line_ml[1] = legs_data2[jj][1]
									left_line[ii] = "     "
								end
								if map_mode == 3 and legs_step == jj then
									left_line[ii] = left_line[ii] .. "<CTR>"
								end
							end
						else
							left_line_x[ii] = " HOLD "
							if legs_data2[jj][21] == 0 then
								left_line_x[ii] = left_line_x[ii] .. "L"
							else
								left_line_x[ii] = left_line_x[ii] .. "R"
							end
							if allign_ok == 0 or offset > legs_num2 then
								left_line[ii] = legs_data2[jj][1]
								line_ml[1] = "     "
							else
								line_ml[1] = legs_data2[jj][1]
								left_line[ii] = "     "
							end
							if map_mode == 3 and legs_step == jj then
								left_line[ii] = left_line[ii] .. "<CTR>"
							end
						end
						-- speed
						if legs_data2[jj][4] == 0 then
							if legs_data2[jj][10] == 0 then
								right_line[ii] = "----"
								line_s[ii] = "                 "
								line_m[ii] = "    "
							else
								if legs_data2[jj][10] < 1 then
									temp_string = string.format("%5.3f",legs_data2[jj][10])
									temp_string = string.sub(temp_string, -4, -1)
								else
									temp_string = string.format("%4d",legs_data2[jj][10])
								end
								line_s[ii] = "             " .. temp_string
								right_line[ii] = "    "
								line_m[ii] = "    "
							end
						else
							if jj ~= B738DR_rest_wpt_spd_idx then
								right_line[ii] = string.format("%4d",legs_data2[jj][4])
								line_s[ii] = "                 "
								line_m[ii] = "    "
							else
								right_line[ii] = "    "
								line_s[ii] = "                 "
								line_m[ii] = string.format("%4d",legs_data2[jj][4])
							end
						end
						-- altitude
						if legs_data2[jj][5] == 0 then
							if legs_data2[jj][11] == 0 then
								right_line[ii] = right_line[ii] .. "/----- "
								line_m[ii] = line_m[ii] .. "       "
							else
								if legs_data2[jj][11] > B738DR_trans_alt then
									temp_string = string.format("%05d",legs_data2[jj][11])
									temp_string = " FL" .. string.sub(temp_string, 1, 3)
								else
									temp_string = " " .. string.format("%5d",legs_data2[jj][11])
								end
								line_s[ii] = line_s[ii] .. temp_string
								right_line[ii] = right_line[ii] .. "/      "
								line_m[ii] = line_m[ii] .. "       "
							end
						else
							if jj ~= B738DR_rest_wpt_alt_idx then
								if legs_data2[jj][5] > B738DR_trans_alt then
									temp_string = string.format("%05d",legs_data2[jj][5])
									temp_string = "/FL" .. string.sub(temp_string, 1, 3)
								else
									temp_string = "/" .. string.format("%5d",legs_data2[jj][5])
								end
								right_line[ii] = right_line[ii] .. temp_string
								if legs_data2[jj][6] == 43 then
									right_line[ii] = right_line[ii] .. "A"
								elseif legs_data2[jj][6] == 45 then
									right_line[ii] = right_line[ii] .. "B"
								else	-- 32 blank 
									right_line[ii] = right_line[ii] .. " "
								end
								line_m[ii] = line_m[ii] .. "       "
							else
								if legs_data2[jj][5] > B738DR_trans_alt then
									temp_string = string.format("%05d",legs_data2[jj][5])
									temp_string = " FL" .. string.sub(temp_string, 1, 3)
								else
									temp_string = " " .. string.format("%5d",legs_data2[jj][5])
								end
								right_line[ii] = right_line[ii] .. "/      "
								line_m[ii] = line_m[ii] .. temp_string
								if legs_data2[jj][6] == 43 then
									line_m[ii] = line_m[ii] .. "A"
								elseif legs_data2[jj][6] == 45 then
									line_m[ii] = line_m[ii] .. "B"
								else	-- 32 blank 
									line_m[ii] = line_m[ii] .. " "
								end
							end
						end
						
						if ii < 5 then
							left_line_x[ii+1] = ""
						end
					else
						overwrite_disc = 0
						--if legs_delete == 1 and legs_delete_item == jj then
						--	overwrite_disc = 1
						--end
						-- if ii == 2 then
							-- line2_inv = ""
						-- end
						if legs_data2[jj][1] == "DISCONTINUITY" or overwrite_disc == 1 then
							--if legs_delete_item ~= legs_num2 then
								left_line_x[ii] = " THEN"
								left_line[ii] = "*****"
								right_line[ii] = ""
								if ii == 5 then
									line6_x = "-- ROUTE DISCONTINUITY -"
								else
									left_line_x[ii+1] = "-- ROUTE DISCONTINUITY -"
								end
							--end
							discon_last = 1
							-- if ii == 2 then
								-- line2_inv = ""
							-- end
						else
							-- id
							left_line[ii] = legs_data2[jj][1]
							if map_mode == 3 and legs_step == jj then
								left_line[ii] = left_line[ii] .. "<CTR>"
							end
							-- if ii == 2 then
								-- line2_inv = ""
							-- end
							if discon_last == 1 then
								discon_last = 0
							else
								-- is HOLD ?
								if legs_data2[jj][21] == -1 then
									-- course
									if simDR_mag_variation == nil then
										sid_len = 0
									else
										sid_len = (math.deg(legs_data2[jj][2]) + simDR_mag_variation) % 360
										if sid_len < 0 then
											sid_len = sid_len + 360
										end
									end
									left_line_x[ii] = " " .. string.format("%03d",sid_len)
									left_line_x[ii] = left_line_x[ii] .. "`     "
									-- distance
									if legs_data2[jj][3] > 0 then
										if legs_data2[jj][3] < 10 then
											left_line_x[ii] = left_line_x[ii] .. string.format("%3.1f",legs_data2[jj][3])
										else
											left_line_x[ii] = left_line_x[ii] .. string.format("%3d",legs_data2[jj][3])
										end
										left_line_x[ii] = left_line_x[ii] .. "NM"
									end
								else
									left_line_x[ii] = " HOLD "
									if legs_data2[jj][21] == 0 then
										left_line_x[ii] = left_line_x[ii] .. "L"
									else
										left_line_x[ii] = left_line_x[ii] .. "R"
									end
								end
							end
						
						
						-- speed
						if legs_data2[jj][4] == 0 then
							if legs_data2[jj][10] == 0 then
								right_line[ii] = "----"
								line_s[ii] = "                 "
								line_m[ii] = "    "
							else
								if legs_data2[jj][10] < 1 then
									temp_string = string.format("%5.3f",legs_data2[jj][10])
									temp_string = string.sub(temp_string, -4, -1)
								else
									temp_string = string.format("%4d",legs_data2[jj][10])
								end
								line_s[ii] = "             " .. temp_string
								right_line[ii] = "    "
								line_m[ii] = "    "
							end
						else
							if jj ~= B738DR_rest_wpt_spd_idx then
								right_line[ii] = string.format("%4d",legs_data2[jj][4])
								line_s[ii] = "                 "
								line_ml[ii] = "    "
							else
								right_line[ii] = "    "
								line_s[ii] = "                 "
								line_m[ii] = string.format("%4d",legs_data2[jj][4])
							end
						end
						-- altitude
						if legs_data2[jj][5] == 0 then
							if legs_data2[jj][11] == 0 then
								right_line[ii] = right_line[ii] .. "/----- "
								line_m[ii] = line_m[ii] .. "       "
							else
								if legs_data2[jj][11] > B738DR_trans_alt then
									temp_string = string.format("%05d",legs_data2[jj][11])
									temp_string = " FL" .. string.sub(temp_string, 1, 3)
								else
									temp_string = " " .. string.format("%5d",legs_data2[jj][11])
								end
								line_s[ii] = line_s[ii] .. temp_string
								right_line[ii] = right_line[ii] .. "/      "
								line_m[ii] = line_m[ii] .. "       "
							end
						else
							if jj ~= B738DR_rest_wpt_alt_idx then
								if legs_data2[jj][5] > B738DR_trans_alt then
									temp_string = string.format("%05d",legs_data2[jj][5])
									temp_string = "/FL" .. string.sub(temp_string, 1, 3)
								else
									temp_string = "/" .. string.format("%5d",legs_data2[jj][5])
								end
								right_line[ii] = right_line[ii] .. temp_string
								if legs_data2[jj][6] == 43 then
									right_line[ii] = right_line[ii] .. "A"
								elseif legs_data2[jj][6] == 45 then
									right_line[ii] = right_line[ii] .. "B"
								else	-- 32 blank 
									right_line[ii] = right_line[ii] .. " "
								end
								line_m[ii] = line_m[ii] .. "       "
							else
								if legs_data2[jj][5] > B738DR_trans_alt then
									temp_string = string.format("%05d",legs_data2[jj][5])
									temp_string = " FL" .. string.sub(temp_string, 1, 3)
								else
									temp_string = " " .. string.format("%5d",legs_data2[jj][5])
								end
								right_line[ii] = right_line[ii] .. "/      "
								line_m[ii] = line_m[ii] .. temp_string
								if legs_data2[jj][6] == 43 then
									line_m[ii] = line_m[ii] .. "A"
								elseif legs_data2[jj][6] == 45 then
									line_m[ii] = line_m[ii] .. "B"
								else	-- 32 blank 
									line_m[ii] = line_m[ii] .. " "
								end
							end
						end
							
							
							-- -- speed
							-- if legs_data2[jj][4] == 0 then
								-- if legs_data2[jj][10] == 0 then
									-- right_line[ii] = "----"
									-- line_s[ii] = "                 "
								-- else
									-- if legs_data2[jj][10] < 1 then
										-- temp_string = string.format("%5.3f",legs_data2[jj][10])
										-- temp_string = string.sub(temp_string, -4, -1)
									-- else
										-- temp_string = string.format("%4d",legs_data2[jj][10])
									-- end
									-- line_s[ii] = "             " .. temp_string
									-- right_line[ii] = "    "
								-- end
							-- else
								-- right_line[ii] = string.format("%4d",legs_data2[jj][4])
								-- line_s[ii] = "                 "
							-- end
							-- -- altitude
							-- if legs_data2[jj][5] == 0 then
								-- if legs_data2[jj][11] == 0 then
									-- right_line[ii] = right_line[ii] .. "/----- "
									-- line_s[ii] = ""
								-- else
									-- if legs_data2[jj][11] > B738DR_trans_alt then
										-- temp_string = string.format("%05d",legs_data2[jj][11])
										-- temp_string = " FL" .. string.sub(temp_string, 1, 3)
									-- else
										-- temp_string = " " .. string.format("%5d",legs_data2[jj][11])
									-- end
									-- line_s[ii] = line_s[ii] .. temp_string
									-- right_line[ii] = right_line[ii] .. "/      "
								-- end
							-- else
								-- if legs_data2[jj][5] > B738DR_trans_alt then
									-- temp_string = string.format("%05d",legs_data2[jj][5])
									-- temp_string = "/FL" .. string.sub(temp_string, 1, 3)
								-- else
									-- temp_string = "/" .. string.format("%5d",legs_data2[jj][5])
								-- end
								-- right_line[ii] = right_line[ii] .. temp_string
								-- if legs_data2[jj][6] == 43 then
									-- right_line[ii] = right_line[ii] .. "A"
								-- elseif legs_data2[jj][6] == 45 then
									-- right_line[ii] = right_line[ii] .. "B"
								-- else
									-- right_line[ii] = right_line[ii] .. " "
								-- end
							-- end
							
							
							-- clear line
							if ii < 5 then
								left_line_x[ii+1] = ""
							end
						end
					end
				end
			end
		else
			max_page_legs = 1
			left_line[1] = " "
			left_line[2] = " "
			left_line[3] = " "
			left_line[4] = " "
			left_line[5] = " "
		end
		
		
		-- display engine
		for ii = 1, 5 do
			sid_len = string.len(left_line[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					left_line[ii] = left_line[ii] .. " "
				end
			end
			sid_len = string.len(right_line[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					right_line[ii] = " " .. right_line[ii]
				end
			end
		end
		
		for ii = 1, 5 do
			sid_len = string.len(line_ml[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					line_ml[ii] = line_ml[ii] .. " "
				end
			end
			sid_len = string.len(line_m[ii])
			if sid_len < 12 then
				for jj = sid_len, 11 do
					line_m[ii] = " " .. line_m[ii]
				end
			end
		end
		
		line1_l = left_line[1] .. right_line[1]
		line2_l = left_line[2] .. right_line[2]
		line3_l = left_line[3] .. right_line[3]
		line4_l = left_line[4] .. right_line[4]
		line5_l = left_line[5] .. right_line[5]
		
		line1_x = left_line_x[1]
		line2_x = left_line_x[2]
		line3_x = left_line_x[3]
		line4_x = left_line_x[4]
		line5_x = left_line_x[5]
		
		line1_s = line_s[1]
		line2_s = line_s[2]
		line3_s = line_s[3]
		line4_s = line_s[4]
		line5_s = line_s[5]
		
		line1_m = line_ml[1] .. line_m[1]
		line2_m = line_ml[2] .. line_m[2]
		line3_m = line_ml[3] .. line_m[3]
		line4_m = line_ml[4] .. line_m[4]
		line5_m = line_ml[5] .. line_m[5]
		
		max_page = max_page_legs
		
		if B738DR_fms_exec_light_pilot == 1 then
			line0_inv = " MOD"
			line0_l   = "     "
			line6_l = "<CANCEL MOD             "
		else
			if legs_num2 > 1 then
				line0_l = " ACT "
			else
				line0_l = "     "
			end
			line0_inv = ""
			if map_mode == 3 then
				line6_l = "                   STEP>"
			else
				line6_l = "               RTE DATA>"
			end
		end
		line0_l = line0_l .. "RTE   LEGS        "
		line0_s = "                    " .. string.format("%1d",act_page)
		line0_s = line0_s .. "/"
		line0_s = line0_s .. string.format("%1d",max_page)
		
		-- line0_s = "                    1/1 "
		-- line1_x = " 128`     2.0NM         "
		-- line1_l = "RUMOR         250/ 2500A"
		-- line1_s = "                        "
		-- line2_x = " 101`      87NM         "
		-- line2_l = "YKM          ----/------"
		-- line2_s = "                        "
		-- line3_x = " THEN                   "
		-- line3_l = "*****                   "
		-- line3_s = "                        "
		-- line4_x = "-- ROUTE DISCONTINUITY -"
		-- line4_l = "VAMPS         250/ 8000A"
		-- line4_s = "                        "
		-- line5_x = "  87`      47NM---------"
		-- line5_l = "LACO1        .637/FL190 "
		-- line5_s = "                        "
		-- line6_x = "------------------------"
		-- line1_s = "                        "
		-- line2_s = "                        "
		-- line3_s = "                        "
		-- line4_s = "                        "
		-- line5_s = "                        "
		line6_s = "                        "
		--line0_inv = ""
		--line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end



function B738_fmc_init()

	if page_init == 1 then
		act_page = 1
		max_page = 1
		line0_l = "    INIT/REF INDEX      "
		line0_s = "                    1/1 "
		line1_x = "                        "
		line1_l = "<IDENT         NAV DATA>"
		line1_s = "                        "
		line2_x = "                        "
		line2_l = "<POS                    "
		line2_s = "                        "
		line3_x = "                        "
		line3_l = "<PERF                   "
		line3_s = "                        "
		line4_x = "                        "
		line4_l = "<TAKEOFF                "
		line4_s = "                        "
		line5_x = "                        "
		line5_l = "<APPROACH               "
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<OFFSET      NAV STATUS>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end


function B738_fmc_takeoff()

	if page_takeoff == 1 then
		act_page = 1
		max_page = 2
		local gw_str = ""
		local rnw_len_temp = 0
		local rnw_len = ""
		
		if gw == "***.*" then
			gw_str = "---.-"
		else
			gw_str = gw
		end
		local trim_str = "TRIM"
		if trim == "    " then
			trim_str = "    "
		end
		line0_l = "     TAKEOFF REF        "
		line0_s = "                    1/2 "
		line1_x = " FLAPS          QRH   V1"
		line1_l = (flaps .. "`                  ")
		line1_l = (line1_l .. v1_set)
		if qrh == "OFF" then
			line1_s = "                " .. v1
			line1_s = line1_s .. ">"
			line2_s = "                " .. vr
			line2_s = line2_s .. ">"
			line3_s = "                " .. v2
			line3_s = line3_s .. ">"
		else	-- QRH on
			line1_s = ""
			line2_s = ""
			line3_s = ""
		end
--		line1_s = (line1_s .. "     ")
		local thr_dspl = ""
		local thr_num = 0
		if sel_temp == "----" then
			if to == "<ACT>" then
				line2_x = "    26K N1            VR"
				thr_num = B738DR_thr_takeoff_N1 * 100
				if thr_num == 0 then
					thr_dspl = "---.-"
				else
					thr_dspl = string.format("%5.1f", thr_num)
				end
			elseif to_1 == "<ACT>" then
				line2_x = "    24K N1            VR"
				thr_num = B738DR_thr_takeoff_N1 * 100
				if thr_num == 0 then
					thr_dspl = "---.-"
				else
					thr_dspl = string.format("%5.1f", thr_num)
				end
			elseif to_2 == "<ACT>" then
				line2_x = "    22K N1            VR"
				thr_num = B738DR_thr_takeoff_N1 * 100
				if thr_num == 0 then
					thr_dspl = "---.-"
				else
					thr_dspl = string.format("%5.1f", thr_num)
				end
			end
		else
			if to == "<ACT>" then
				line2_x = "RED 26K N1            VR"
				thr_num = B738DR_thr_takeoff_N1 * 100
				if thr_num == 0 then
					thr_dspl = "---.-"
				else
					thr_dspl = string.format("%5.1f", thr_num)
				end
			elseif to_1 == "<ACT>" then
				line2_x = "RED 24K N1            VR"
				thr_num = B738DR_thr_takeoff_N1 * 100
				if thr_num == 0 then
					thr_dspl = "---.-"
				else
					thr_dspl = string.format("%5.1f", thr_num)
				end
			elseif to_2 == "<ACT>" then
				line2_x = "RED 22K N1            VR"
				thr_num = B738DR_thr_takeoff_N1 * 100
				if thr_num == 0 then
					thr_dspl = "---.-"
				else
					thr_dspl = string.format("%5.1f", thr_num)
				end
			end
		end
		-- if fms_N1_to_mode_sel == 1 then
			-- line2_x = "    26K N1            VR"
			-- thr_num = fmc_full_thrust * 100
			-- thr_dspl = string.format("%5.1f", thr_num)
		-- elseif fms_N1_to_mode_sel == 2 then
			-- line2_x = "    24K N1            VR"
			-- thr_num = fmc_full_thrust * 97
			-- thr_dspl = string.format("%5.1f", thr_num)
		-- elseif fms_N1_to_mode_sel == 3 then
			-- line2_x = "    22K N1            VR"
			-- thr_num = fmc_full_thrust * 94
			-- thr_dspl = string.format("%5.1f", thr_num)
		-- elseif fms_N1_to_mode_sel == 4 then
			-- line2_x = "RED 26K N1            VR"
			-- thr_num = fmc_dto_thrust * 100
			-- thr_dspl = string.format("%5.1f", thr_num)
		-- elseif fms_N1_to_mode_sel == 5 then
			-- line2_x = "RED 24K N1            VR"
			-- thr_num = fmc_dto_thrust * 97
			-- thr_dspl = string.format("%5.1f", thr_num)
		-- elseif fms_N1_to_mode_sel == 6 then
			-- line2_x = "RED 22K N1            VR"
			-- thr_num = fmc_dto_thrust * 94
			-- thr_dspl = string.format("%5.1f", thr_num)
		-- end
		line2_l = thr_dspl .. "/"
		line2_l = line2_l .. thr_dspl
		line2_l = line2_l .. "          "
		line2_l = line2_l .. vr_set
--		line2_s = "                " .. vr
--		line2_s = line2_s .. "     "
		line3_x = " CG    " .. trim_str
		line3_x = line3_x .. "           V2"
		line3_l = cg .. "%  "
		line3_l = line3_l .. trim
		line3_l = line3_l .."          "
		line3_l = line3_l .. v2_set
--		line3_s = "                " .. v2
--		line3_s = line3_s .. "     "
		line4_x = "               GW  / TOW"
		line4_l = "              " .. gw_str
		line4_l = line4_l .. "/     "
		line4_s = "                        "
		line5_x = " RUNWAY                 "
		if ref_icao == "----" or ref_rwy == "-----" then
			line5_l = "                        "
			line5_s = "                        "
		else
			line5_l = "RW" .. ref_rwy
			rnw_len_temp = (ref_runway_lenght * 3.280839995) + 0.5
			rnw_len_temp = math.floor(rnw_len_temp)
			if rnw_len_temp == 0 then
				rnw_len = "-----"
			elseif rnw_len_temp > 99999 then
				rnw_len = "99999"
			else
				rnw_len = string.format("%5d",rnw_len_temp)
			end
			line5_l = line5_l .. "/" .. rnw_len .. "F "
			
			if ref_runway_lenght == 0 then
				rnw_len = "----"
			elseif ref_runway_lenght > 9999 then
				rnw_len = "9999"
			else
				rnw_len = string.format("%4d",ref_runway_lenght)
			end
			line5_l = line5_l .. rnw_len .. "M"
			line5_s = "           T           "
		end
		--line5_s = "                        "
		line6_x = "------------------SELECT"
		
		if pre_flt_pos_init == 0 then
			line6_l = "<POS INIT "
		elseif pre_flt_rte == 0 then
			line6_l = "<ROUTE    "
		elseif pre_flt_dep == 0 then
			line6_l = "<DEPARTURE"
		elseif pre_flt_perf_init == 0 then
			line6_l = "<PERF INIT"
		else
			line6_l = "<INDEX    "
		end
		
		line6_l = line6_l .. "      QRH " .. qrh
		
		line6_l = line6_l .. ">"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	
	elseif page_takeoff == 2 then
		act_page = 2
		max_page = 2
		local rw_str_l = ""
		local rw_str_s = ""
		if rw_cond == 0 then
			rw_str_l = "DRY/         "
			rw_str_s = "    WET/SK-R>"
		elseif rw_cond == 1 then
			rw_str_l = "    WET/     "
			rw_str_s = "DRY/    SK-R>"
		elseif rw_cond == 2 then
			rw_str_l = "        SK-R "
			rw_str_s = "DRY/WET/    >"
		end
		line0_l = "     TAKEOFF REF        "
		line0_s = "                    2/2 "
		line1_x = " RW WIND        RW COND "
		line1_l = rw_wind_dir .. "`/"
		line1_l = line1_l .. rw_wind_spd
--		line1_l = line1_l .. "   "
--		line1_l = line1_l .. rw_str_l
		line1_inv = "           " .. rw_str_l
		line1_s = "           " .. rw_str_s
		line2_x = " RW SLOPE/HDG           "
		line2_l = rw_slope .. "%/"
		line2_l = line2_l .. rw_hdg
		line2_s = "                        "
		--line3_x = "                        "
		--line3_l = "                        "
		--line3_s = "                        "
--		line4_x = " SEL/OAT          26K N1"
--		line4_l = "---/ +15`C   94.6/ 94.6%"
--		line4_s = "                        "
		line3_x = "                ACCEL HT"
		if accel_alt == "----" then
			line3_s = "                 1000AGL"
			line3_l = "                        "
		else
			line3_l = "                 " .. accel_alt
			line3_s = "                     AGL"
		end
		
		local thr_dspl = ""
		local thr_num = 0
		local sel_temp_dspl = ""
		local oat_dspl = ""
		local oat_sim_dspl =""
		
		if oat_unit == "`C" then
			sel_temp_dspl = sel_temp
			oat_dspl = oat
			oat_sim_dspl = oat_sim
		else
			sel_temp_dspl = sel_temp_f
			oat_dspl = oat_f
			oat_sim_dspl = oat_sim_f
		end
		line4_x = " SEL/OAT      "
		if fms_N1_to_mode_sel == 1 then
			line4_x = line4_x .. "    26K N1"
			thr_num = B738DR_thr_takeoff_N1 * 100
			if thr_num == 0 then
				thr_dspl = "---.-"
			else
				thr_dspl = string.format("%5.1f", thr_num)
			end
		elseif fms_N1_to_mode_sel == 2 then
			line4_x = line4_x .. "    24K N1"
			thr_num = B738DR_thr_takeoff_N1 * 100
			if thr_num == 0 then
				thr_dspl = "---.-"
			else
				thr_dspl = string.format("%5.1f", thr_num)
			end
		elseif fms_N1_to_mode_sel == 3 then
			line4_x = line4_x .. "    22K N1"
			thr_num = B738DR_thr_takeoff_N1 * 100
			if thr_num == 0 then
				thr_dspl = "---.-"
			else
				thr_dspl = string.format("%5.1f", thr_num)
			end
		elseif fms_N1_to_mode_sel == 4 then
			line4_x = line4_x .. "RED 24K N1"
			thr_num = B738DR_thr_takeoff_N1 * 100
			if thr_num == 0 then
				thr_dspl = "---.-"
			else
				thr_dspl = string.format("%5.1f", thr_num)
			end
		elseif fms_N1_to_mode_sel == 5 then
			line4_x = line4_x .. "RED 22K N1"
			thr_num = B738DR_thr_takeoff_N1 * 100
			if thr_num == 0 then
				thr_dspl = "---.-"
			else
				thr_dspl = string.format("%5.1f", thr_num)
			end
		elseif fms_N1_to_mode_sel == 6 then
			line4_x = line4_x .. "RED 20K N1"
			thr_num = B738DR_thr_takeoff_N1 * 100
			if thr_num == 0 then
				thr_dspl = "---.-"
			else
				thr_dspl = string.format("%5.1f", thr_num)
			end
		end
		line4_l = sel_temp_dspl .. "/"
		line4_l = line4_l .. oat_dspl
		line4_l = line4_l .."   "
		line4_l = line4_l .. thr_dspl
		line4_l = line4_l .. "/"
		line4_l = line4_l .. thr_dspl
		line4_l = line4_l .. "%"
		if oat == "    " then
			line4_s = "     " .. oat_sim_dspl
			line4_s = line4_s .. oat_unit
		else
			line4_s = "         " .. oat_unit
		end
		line5_x = "           THR REDUCTION"
		line5_l = "           CLB          "
		if clb == "<SEL>" then
			line5_l = "           CLB   "
		elseif clb_1 == "<SEL>" then
			line5_l = "           CLB-1 "
		elseif clb_2 == "<SEL>" then
			line5_l = "           CLB-2 "
		end
		if clb_alt == "----" then
			line5_s = "                 1500AGL"
		else
			line5_l = line5_l .. clb_alt
			line5_s = "                     AGL"
		end
		line6_x = "------------------------"
		line6_l = "<INDEX                  "
		line6_s = "                        "
		line0_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end

function B738_fmc_approach()

	if page_approach == 1 then
		act_page = 1
		max_page = 1
		local thr_dspl = ""
		local thr_num = 0
		local temp_ils = ""
		local temp_ils2 = ""
		-- local temp_ils3 = ""
		-- local temp_ils4 = ""
		local temp_ils5 = ""
		local temp_ils6 = 0
		local i_ils = 0
		local rw_ils = ""
		local app_ils = ""
		local rnw_len = ""
		local rnw_len_temp = 0
		
		line0_l = "     APPROACH REF       "
		line0_s = "                    1/1 "
		line1_x = " GROSS WT   FLAPS   VREF"
		line1_l = " " .. gw
		line1_l = line1_l .. "       15`   "
		if flaps_app == "15" then
			line1_l = (line1_l .. vref_15)
			line1_l = (line1_l .. "KT")
			line1_s = "                        "
		else
			line1_l = (line1_l .. "     ")
			line1_s = ("                   " .. vref_15)
			line1_s = (line1_s .. "KT")
		end
		line2_x = " GA N1                  "
		thr_num = fmc_ga_thrust * 100
		if thr_num == 0 then
			thr_dspl = "---.-"
		else
			thr_dspl = string.format("%5.1f", thr_num)
		end
		line2_l = thr_dspl
		line2_l = line2_l .. "/"
		line2_l = line2_l .. thr_dspl
		line2_l = line2_l .. "% 30`   "
		if flaps_app == "30" then
			line2_l = line2_l .. vref_30
			line2_l = line2_l .. "KT"
			line2_s = "                        "
		else
			line2_l = (line2_l .. "     ")
			line2_s = ("                   " .. vref_30)
			line2_s = (line2_s .. "KT")
		end
		--line3_l = "             40`   "
		if des_app ~= "------" then
			rnw_len_temp = (des_runway_lenght * 3.280839995) + 0.5
			rnw_len_temp = math.floor(rnw_len_temp)
			if rnw_len_temp == 0 then
				rnw_len = "-----"
			elseif rnw_len_temp > 99999 then
				rnw_len = "99999"
			else
				rnw_len = string.format("%5d",rnw_len_temp)
			end
			line3_l = rnw_len .. "F "
			
			if des_runway_lenght == 0 then
				rnw_len = "----"
			elseif des_runway_lenght > 9999 then
				rnw_len = "9999"
			else
				rnw_len = string.format("%4d",des_runway_lenght)
			end
			line3_l = line3_l .. rnw_len .. "M 40`   "
			
			--line3_l = "-----FT----M 40`   "
		else
			line3_l = "             40`   "
		end
		if flaps_app == "40" then
			line3_l = (line3_l .. vref_40)
			line3_l = (line3_l .. "KT")
			if des_app ~= "------" then
				line3_s = "      T                 "
			else
				line3_s = "                        "
			end
		else
			line3_l = (line3_l .. "     ")
			if des_app ~= "------" then
				line3_s = ("      T            " .. vref_40)
			else
				line3_s = ("                   " .. vref_40)
			end
			line3_s = (line3_s .. "KT")
		end
		if found_ils == 2 then
			temp_ils3 = string.format("%5d", ils_freq)
			temp_ils3 = string.sub(temp_ils3, 1, 3) .. "." .. string.sub(temp_ils3, 4, 5)
			temp_ils6 = (ils_course + simDR_mag_variation) % 360
			if temp_ils6 < 0 then
				temp_ils6 = temp_ils6 + 360
			end
			temp_ils4 = string.format("%03d", (temp_ils6)) .. "`"
			found_ils = 3
		end
		if des_app ~= "------" then
			rw_ils = string.sub(des_app, 2, -1)
			if string.len(rw_ils) > 3 then
				rw_ils = string.sub(rw_ils, 1, 3)
			end
			if string.len(rw_ils) > 2 then
				if string.sub(rw_ils, -1, -1) ~= "L" and string.sub(rw_ils, -1, -1) ~= "R" and string.sub(rw_ils, -1, -1) ~= "C" then
					rw_ils = string.sub(rw_ils, 1, 2) .. " "
				end
			else
				rw_ils = rw_ils .. " "
			end
			app_ils = string.sub(des_app, 2, -1)
			line3_x = " " .. des_icao .. rw_ils
			line4_s = "                  "
			if string.sub(des_app, 1, 1) == "I" then 	-- ILS
				temp_ils = " ILS " .. app_ils .. "/CRS"
				if string.len(app_ils) == 4 then
					temp_ils = temp_ils .. "   "
				elseif string.len(app_ils) == 2 then
					temp_ils = temp_ils .. "     "
				else
					temp_ils = temp_ils .. "    "
				end
				temp_ils2 = "RW" .. rw_ils
				for i_ils = 1, des_rwy_num do
					if des_data[i_ils][1] == temp_ils2 then
						line4_s = "      " .. des_data[i_ils][4]	--id ILS
						if found_ils == 0 then
							temp_ils5 = des_data[i_ils][4]
							while string.sub(temp_ils5, -1, -1) == " " and string.len(temp_ils5) > 1 do
								temp_ils5 = string.sub(temp_ils5, 1, -2)
							end
							ils_id = temp_ils5
							found_ils = 1
						end
					end
				end
				if ils_freq ~= 0 then
					line4_l = temp_ils3 .. "    /" .. temp_ils4 .. "   "
				else
					line4_l = "                  "
				end
			elseif string.sub(des_app, 1, 1) == "L" then 	-- LOC
				temp_ils = " LOC " .. app_ils .. "/CRS"
				if string.len(app_ils) == 4 then
					temp_ils = temp_ils .. "   "
				elseif string.len(app_ils) == 2 then
					temp_ils = temp_ils .. "     "
				else
					temp_ils = temp_ils .. "    "
				end
				temp_ils2 = "RW" .. rw_ils
				for i_ils = 1, des_rwy_num do
					if des_data[i_ils][1] == temp_ils2 then
						line4_s = "      " .. des_data[i_ils][4]	--id LOC
						if found_ils == 0 then
							temp_ils5 = des_data[i_ils][4]
							while string.sub(temp_ils5, -1, -1) == " " and string.len(temp_ils5) > 1 do
								temp_ils5 = string.sub(temp_ils5, 1, -2)
							end
							ils_id = temp_ils5
							found_ils = 1
						end
					end
				end
				if ils_freq ~= 0 then
					line4_l = temp_ils3 .. "    /" .. temp_ils4 .. "   "
				else
					line4_l = "                  "
				end
			elseif string.sub(des_app, 1, 1) == "J" then 	-- GLS
				temp_ils = " GLS " .. app_ils .. "/CRS"
				if string.len(app_ils) == 4 then
					temp_ils = temp_ils .. "   "
				elseif string.len(app_ils) == 2 then
					temp_ils = temp_ils .. "     "
				else
					temp_ils = temp_ils .. "    "
				end
				temp_ils2 = "RW" .. rw_ils
				for i_ils = 1, des_rwy_num do
					if des_data[i_ils][1] == temp_ils2 then
						line4_s = "      " .. des_data[i_ils][4]	--id GLS
						if found_ils == 0 then
							temp_ils5 = des_data[i_ils][4]
							while string.sub(temp_ils5, -1, -1) == " " and string.len(temp_ils5) > 1 do
								temp_ils5 = string.sub(temp_ils5, 1, -2)
							end
							ils_id = temp_ils5
							found_ils = 1
						end
					end
				end
				if ils_freq ~= 0 then
					line4_l = temp_ils3 .. "    /" .. temp_ils4 .. "   "
				else
					line4_l = "                  "
				end
			else
				temp_ils = "                "
				line4_s = "                  "
				line5_x = "               WIND CORR"
				line5_l = "       "
				line5_s = "       "
				line4_l = "                  "
			end
			line5_x = " G/S           WIND CORR"
			if B738DR_fms_ils_disable == 0 then
				line5_l = "<  /   "
				line5_g = " ON    "
				line5_s = "    OFF"
			else
				line5_l = "<  /   "
				line5_g = "    OFF"
				line5_s = " ON    "
			end
		else
			line3_x = ""
			temp_ils = "                "
			line4_s = "                  "
			line5_x = "               WIND CORR"
			line5_l = "       "
			line5_s = "       "
			line4_l = "                  "
			--found_ils = 0
		end
		
		--line5_l = "       "
		line4_x = temp_ils .. "FLAP/SPD"
		
		
		line4_l = line4_l .. app_flap
		line4_l = line4_l .. "/"
		line4_l = line4_l .. app_spd
		--line4_s = "                    /   "
		--line4_s = ""
		
		--line5_x = "               WIND CORR"
		if wind_corr == "--" then
			line5_l = line5_l .. ""
			--line5_s = "                   +05KT"
			line5_s = line5_s .. "            +05KT"
		else
			line5_l = line5_l .. "            +"
			line5_l = line5_l .. wind_corr
			--line5_l = line5_l
			--line5_s = "                      KT"
			line5_s = line5_s .. "               KT"
		end
		line6_x = "------------------------"
		line6_l = "<INDEX                  "
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end

function B738_fmc_perf()

	if page_perf == 1 then
		act_page = 1
		max_page = 2
		clr_repeat = 1
		local trip = "     "
		if B738DR_cruise_opt_alt > 0 then
			trip = "FL" .. string.format("%03d", (B738DR_cruise_opt_alt/100))
		end
		line0_l = "      PERF INIT         "
		line0_s = "                    1/2 "
		-- if crz_alt == "*****" then
			-- line1_x = " GW/CRZ CG  TRIP/CRZ ALT"
		-- else
			-- line1_x = " GW/CRZ CG       CRZ ALT"
		-- end
		line1_x = " GW/CRZ CG  TRIP/CRZ ALT"
		if cg == "--.-" then
			-- default CG
			line1_l = gw .. "/ 8.0%"
		else
			line1_l = gw .. "/"
			line1_l = line1_l .. cg
			line1_l = line1_l .. "%"
		end
		if gw == "**.*" then
			line1_l = line1_l .."        "
			line1_l = line1_l .. crz_alt
		else
			line1_l = line1_l .."  "
			line1_l = line1_l .. trip
			line1_l = line1_l .. "/"
			line1_l = line1_l .. crz_alt
		end
		if crz_alt == "*****" then
			--line1_x = " GW/CRZ CG  TRIP/CRZ ALT"
			line1_l = line1_l .."  "
			line1_l = line1_l .. trip
			line1_l = line1_l .. "/"
			line1_l = line1_l .. crz_alt
		else
			--line1_x = " GW/CRZ CG       CRZ ALT"
			line1_l = line1_l .."        "
			line1_l = line1_l .. crz_alt
		end
		line1_s = "                        "
		line2_x = " PLAN/FUEL      CRZ WIND"
		if simDR_flaps_ratio > 0.624 or was_on_air == 1 then
			line2_l = "     /"
		else
			line2_l = plan_weight .. "/"
		end
		line2_l = line2_l .. fuel_weight
		line2_l = line2_l .. "      "
		line2_l = line2_l .. crz_wind_dir
		line2_l = line2_l .. "`/"
		line2_l = line2_l .. crz_wind_spd
		line2_s = "                        "
		line3_x = " ZFW             "
		line3_l = zfw .. "        "
		if crz_alt == "*****" then
			isa_dev_f = "---"
			isa_dev_c = "---"
			disable_PERF_3R = 1
			line3_s =   "                        "
		else
			line3_x = line3_x .. "ISA DEV"
			line3_l = line3_l .. isa_dev_f
			line3_l = line3_l .. "   "
			line3_l = line3_l .. isa_dev_c
			line3_s =   "                `F    `C"
			disable_PERF_3R = 0
		end
		line4_x = " RESERVES        "
		line4_l = reserves .. "         "
		if crz_alt == "*****" then
			tc_oat_f = "---"
			tc_oat_c = "---"
			disable_PERF_4R = 1
			line4_s =   "                        "
		else
			line4_x = line4_x .. "T/C OAT"
			line4_l = line4_l .. tc_oat_f
			line4_l = line4_l .. "   "
			line4_l = line4_l .. tc_oat_c
			line4_s = "                `F    `C"
			disable_PERF_4R = 0
		end
		line5_x = " COST INDEX    TRANS ALT"
		line5_l = cost_index .. "                "
		if trans_alt == "-----" then
			line5_l = line5_l .. "18000"
		else
			line5_l = line5_l .. trans_alt
		end
		line5_s = "                        "
		line6_x = "------------------------"
		line6_l = "<INDEX         N1 LIMIT>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	elseif page_perf == 2 then
		act_page = 2
		max_page = 2
		line0_l = "      PERF LIMITS       "
		line0_s = "                    2/2 "
		line1_x = " TIME ERROR TOLERANCE   "
		line1_l = "  " .. time_err
		if time_err == "  " then
			line1_s = "  30 SEC AT RTA WPT     "
		else
			line1_s = "     SEC AT RTA WPT     "
		end
		line2_x = " MIN SPD --CLB-- MAX SPD"
		line2_l = clb_min_kts .. "/."
		line2_l = line2_l .. clb_min_mach
		line2_l = line2_l .. "        "
		line2_l = line2_l .. clb_max_kts
		line2_l = line2_l .. "/."
		line2_l = line2_l .. clb_max_mach
		if clb_min_kts == "   " then
			line2_s = "100  "
		else
			line2_s = "     "
		end
		if clb_min_mach == "   " then
			line2_s = line2_s .. "400        "
		else
			line2_s = line2_s .. "           "
		end
		if clb_max_kts == "   " then
			line2_s = line2_s .. "340  "
		else
			line2_s = line2_s .. "     "
		end
		if clb_max_mach == "   " then
			line2_s = line2_s .. "820"
		end
		line3_x = "         --CRZ--        "
		line3_l = crz_min_kts .. "/."
		line3_l = line3_l .. crz_min_mach
		line3_l = line3_l .. "        "
		line3_l = line3_l .. crz_max_kts
		line3_l = line3_l .. "/."
		line3_l = line3_l .. crz_max_mach
		if crz_min_kts == "   " then
			line3_s = "100  "
		else
			line3_s = "     "
		end
		if crz_min_mach == "   " then
			line3_s = line3_s .. "400        "
		else
			line3_s = line3_s .. "           "
		end
		if crz_max_kts == "   " then
			line3_s = line3_s .. "340  "
		else
			line3_s = line3_s .. "     "
		end
		if crz_max_mach == "   " then
			line3_s = line3_s .. "820"
		end
		line4_x = "         --DES--        "
		line4_l = des_min_kts .. "/."
		line4_l = line4_l .. des_min_mach
		line4_l = line4_l .. "        "
		line4_l = line4_l .. des_max_kts
		line4_l = line4_l .. "/."
		line4_l = line4_l .. des_max_mach
		if des_min_kts == "   " then
			line4_s = "100  "
		else
			line4_s = "     "
		end
		if des_min_mach == "   " then
			line4_s = line4_s .. "400        "
		else
			line4_s = line4_s .. "           "
		end
		if des_max_kts == "   " then
			line4_s = line4_s .. "340  "
		else
			line4_s = line4_s .. "     "
		end
		if des_max_mach == "   " then
			line4_s = line4_s .. "820"
		end
		line5_x = "                        "
		line5_l = "                        "
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<INDEX              RTA>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end



function B738_fmc_n1_limit()

	if page_n1_limit == 1 then
		act_page = 1
		max_page = 1
		local thr_dspl = ""
		local thr_num = 0
		
		if in_flight_mode == 0 then
			local sel_temp_dspl = ""
			local oat_dspl = ""
			local oat_sim_dspl =""
			
			if oat_unit == "`C" then
				sel_temp_dspl = sel_temp
				oat_dspl = oat
				oat_sim_dspl = oat_sim
			else
				sel_temp_dspl = sel_temp_f
				oat_dspl = oat_f
				oat_sim_dspl = oat_sim_f
			end
			
			line0_l = "      N1 LIMIT          "
			line0_s = "                    1/1 "
			line1_x = " SEL/OAT      "
			if sel_temp == "----" then
				if to == "<ACT>" then
					line1_x = line1_x .. "    26K N1"
					thr_num = B738DR_thr_takeoff_N1 * 100
					if thr_num == 0 then
						thr_dspl = "---.-"
					else
						thr_dspl = string.format("%5.1f", thr_num)
					end
				elseif to_1 == "<ACT>" then
					line1_x = line1_x .. "    24K N1"
					thr_num = B738DR_thr_takeoff_N1 * 100
					if thr_num == 0 then
						thr_dspl = "---.-"
					else
						thr_dspl = string.format("%5.1f", thr_num)
					end
				elseif to_2 == "<ACT>" then
					line1_x = line1_x .. "    22K N1"
					thr_num = B738DR_thr_takeoff_N1 * 100
					if thr_num == 0 then
						thr_dspl = "---.-"
					else
						thr_dspl = string.format("%5.1f", thr_num)
					end
				end
			else
				if to == "<ACT>" then
					line1_x = line1_x .. "RED 26K N1"
					thr_num = B738DR_thr_takeoff_N1 * 100
					if thr_num == 0 then
						thr_dspl = "---.-"
					else
						thr_dspl = string.format("%5.1f", thr_num)
					end
				elseif to_1 == "<ACT>" then
					line1_x = line1_x .. "RED 24K N1"
					thr_num = B738DR_thr_takeoff_N1 * 100
					if thr_num == 0 then
						thr_dspl = "---.-"
					else
						thr_dspl = string.format("%5.1f", thr_num)
					end
				elseif to_2 == "<ACT>" then
					line1_x = line1_x .. "RED 22K N1"
					thr_num = B738DR_thr_takeoff_N1 * 100
					if thr_num == 0 then
						thr_dspl = "---.-"
					else
						thr_dspl = string.format("%5.1f", thr_num)
					end
				end
			end
			-- if fms_N1_to_mode_sel == 1 then
				-- line1_x = line1_x .. "    26K N1"
				-- thr_num = fmc_full_thrust * 100
				-- thr_dspl = string.format("%5.1f", thr_num)
			-- elseif fms_N1_to_mode_sel == 2 then
				-- line1_x = line1_x .. "    24K N1"
				-- thr_num = fmc_full_thrust * 97
				-- thr_dspl = string.format("%5.1f", thr_num)
			-- elseif fms_N1_to_mode_sel == 3 then
				-- line1_x = line1_x .. "    22K N1"
				-- thr_num = fmc_full_thrust * 94
				-- thr_dspl = string.format("%5.1f", thr_num)
			-- elseif fms_N1_to_mode_sel == 4 then
				-- line1_x = line1_x .. "RED 24K N1"
				-- thr_num = fmc_dto_thrust * 100
				-- thr_dspl = string.format("%5.1f", thr_num)
			-- elseif fms_N1_to_mode_sel == 5 then
				-- line1_x = line1_x .. "RED 22K N1"
				-- thr_num = fmc_dto_thrust * 97
				-- thr_dspl = string.format("%5.1f", thr_num)
			-- elseif fms_N1_to_mode_sel == 6 then
				-- line1_x = line1_x .. "RED 20K N1"
				-- thr_num = fmc_dto_thrust * 94
				-- thr_dspl = string.format("%5.1f", thr_num)
			-- end
			line1_l = sel_temp_dspl .. "/"
			line1_l = line1_l .. oat_dspl
			line1_l = line1_l .."    "
			line1_l = line1_l .. thr_dspl
			line1_l = line1_l .. "/"
			line1_l = line1_l .. thr_dspl
			if oat == "    " then
				line1_s = "     " .. oat_sim_dspl
				line1_s = line1_s .. oat_unit
			else
				line1_s = "         " .. oat_unit
			end
--			if sel_temp == "----" then
--				line2_x = " 26K"
--				line3_x = " 24K"
--				line4_x = " 22K"
--			else
				line2_x = " 26K"
				line3_x = " 24K DERATE"
				line4_x = " 22K DERATE"
---			end
			line2_l = "<TO   " .. to
			line2_l = line2_l .. " "
			line2_l = line2_l .. clb
			line2_l = line2_l .. "   CLB>"
			line2_s = "                        "
			line3_l = "<TO-1 " .. to_1
			line3_l = line3_l .. " "
			line3_l = line3_l .. clb_1
			line3_l = line3_l .. " CLB-1>"
			line3_s = "                        "
			line4_l = "<TO-2 " .. to_2
			line4_l = line4_l .." "
			line4_l = line4_l .. clb_2
			line4_l = line4_l .. " CLB-2>"
			line4_s = "                        "
			line5_x = "                        "
			line5_l = "                        "
			line5_s = "                        "
			line6_x = "------------------------"
			if ground_air == 0 then
				line6_l = "<PERF INIT      TAKEOFF>"
				disable_N1_6R = 0
			else
				line6_l = "<PERF INIT"
				disable_N1_6R = 1
			end
			line6_s = "                        "
			disable_N1_6L = 0
		
		elseif in_flight_mode == 1 then
			line0_l = "      N1 LIMIT          "
			line0_s = "                    1/1 "
			line1_x = "                        "
			line1_l = "<AUTO " .. auto_act
			line1_s = "                        "
			line2_x = "                        "
			line2_l = "<GA   " .. ga_act
			line2_l = line2_l .. "  " 
			thr_num = fmc_ga_thrust * 100
			if thr_num == 0 then
				thr_dspl = "---.-"
			else
				thr_dspl = string.format("%5.1f", thr_num)
			end
			line2_l = line2_l .. thr_dspl
			line2_l = line2_l .. "/"
			line2_l = line2_l .. thr_dspl
			line2_s = "                        "
			line3_x = "                        "
--			line3_l = "<CON  <ACT>   90.5/ 90.5"
			line3_l = "<CON  " .. con_act
			line3_l = line3_l .. "  " 
			thr_num = fmc_con_thrust * 100
			if thr_num == 0 then
				thr_dspl = "---.-"
			else
				thr_dspl = string.format("%5.1f", thr_num)
			end
			line3_l = line3_l .. thr_dspl
			line3_l = line3_l .. "/"
			line3_l = line3_l .. thr_dspl
			line3_s = "                        "
			line4_x = "                        "
--			line4_l = "<CLB  <ACT>   90.5/ 90.5"
			line4_l = "<CLB  " .. clb_act
			line4_l = line4_l .. "  " 
			thr_num = fmc_clb_thrust * 100
			if thr_num == 0 then
				thr_dspl = "---.-"
			else
				thr_dspl = string.format("%5.1f", thr_num)
			end
			line4_l = line4_l .. thr_dspl
			line4_l = line4_l .. "/"
			line4_l = line4_l .. thr_dspl
			line4_s = "                        "
			line5_x = "                        "
--			line5_l = "<CRZ  <ACT>   86.8/ 86.8"
			line5_l = "<CRZ  " .. crz_act
			line5_l = line5_l .. "  " 
			thr_num = fmc_crz_thrust * 100
			if thr_num == 0 then
				thr_dspl = "---.-"
			else
				thr_dspl = string.format("%5.1f", thr_num)
			end
			line5_l = line5_l .. thr_dspl
			line5_l = line5_l .. "/"
			line5_l = line5_l .. thr_dspl
			line5_s = "                        "
			line6_x = "------REDUCED CLB-------"
			if clb == "<SEL>" then
				line6_l = "<CLB-1            CLB-2>"
			elseif clb_1 == "<SEL>" then
				line6_l = "<CLB-1 <SEL>      CLB-2>"
			elseif clb_2 == "<SEL>" then
				line6_l = "<CLB-1      <SEL> CLB-2>"
			end
			line6_s = "                        "
			if simDR_altitude_pilot > 15000 then
				disable_N1_6L = 1
				disable_N1_6R = 1
			end
			if simDR_altitude_pilot < 14900 then
				disable_N1_6L = 0
				disable_N1_6R = 0
			end
		end
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end

function B738_fmc_climb()

	if page_climb == 1 then
		act_page = 1
		max_page = 1
		local thrust = 0
		local v11 = 0
		local v21 = 0
		local clb_100 = 0
		local time_TOD = 0
		local time_TOD_h = 0
		local time_TOD_m = 0
		local time_TOD_s = 0
		local time1_TOD_h = 0
		local time1_TOD_m = 0
		local time1_TOD_s = 0
		local delta_alt = 0
		local nav_id = ""
		local rest_alt_id = ""
		local rest_alt = ""
		local ii = 0
		local tmp_wpt_eta = ""
		local tmp_wpt_eta2 = 0
		local tmp_wpt_eta3 = 0
		
		if B738DR_flight_phase < 2 and B738DR_autopilot_vnav_status == 1 then	-- phase climb
			line0_l = "  ACT "
		else
			line0_l = "      "
		end
		if B738DR_fmc_climb_speed_l == 340 
		or B738DR_fmc_climb_speed_l == 0 then
			if B738DR_climb_mode == 0 then
				line0_l = line0_l .. "ECON CLB          "
			elseif B738DR_climb_mode == 1 then
				line0_l = line0_l .. "MAX RATE CLB      "
			elseif B738DR_climb_mode == 2 then
				line0_l = line0_l .. "MAX ANGLE CLB     "
			elseif B738DR_climb_mode == 3 then
				if simDR_airspeed_is_mach == 0 then
					line0_l = line0_l .. string.format("%3d", B738DR_fmc_climb_speed)
					line0_l = line0_l .. "KT CLB         "
				else
					line0_l = line0_l .. "M."
					line0_l = line0_l .. string.format("%3d", (B738DR_fmc_climb_speed_mach * 1000))
					line0_l = line0_l .. " CLB         "
				end
			end
			line3_l = "---/-----          ---  "
			line3_inv = ""
			if B738DR_flight_phase < 2 and B738DR_autopilot_vnav_status == 1 then
				if simDR_airspeed_is_mach == 0 then
					if B738DR_ap_spd_interv_status == 0 then
						line2_m = string.format("%3d", B738DR_fmc_climb_speed)
						line2_l = "   /" .. string.sub(string.format("%5.3f", B738DR_fmc_climb_speed_mach), 2, 5)
					else
						line2_m = string.format("%3d", B738DR_mcp_speed_dial)	--simDR_airspeed_dial)
						line2_l = "   /MCP "
					end
				else
					if B738DR_ap_spd_interv_status == 0 then
						line2_l = string.format("%3d", B738DR_fmc_climb_speed) .. "/    "
						line2_m = "    " .. string.sub(string.format("%5.3f", B738DR_fmc_climb_speed_mach), 2, 5)
					else
						line2_m = string.sub(string.format("%5.3f", B738DR_mcp_speed_dial), 2, 5)	--simDR_airspeed_dial), 2, 5)
						line2_l = "   /MCP "
					end
				end
			else
				line2_l = string.format("%3d", B738DR_fmc_climb_speed) .. "/"
				line2_l = line2_l .. string.sub(string.format("%5.3f", B738DR_fmc_climb_speed_mach), 2, 5)
				line2_m = ""
			end
		else
			line0_l = line0_l .. string.format("%3d", B738DR_fmc_climb_speed_l)
			line0_l = line0_l .. "KT LIM CLB     "
			if flaps_speed == B738DR_fmc_climb_speed_l or flaps_speed < vnav_speed then
				if flaps_speed == B738DR_fmc_climb_speed_l then
					line3_m = string.format("%3d", B738DR_fmc_climb_speed_l)
					line3_l = "   /FLAPS          ---  "
				else
					line3_l = string.format("%3d", B738DR_fmc_climb_speed_l) .. "/FLAPS          ---  "
					line3_m = ""
				end
			-- elseif vnav_speed == B738DR_fmc_climb_speed_l then
				-- if simDR_gps_nav_id == nil then
					-- line3_l = "250/10000          ---  "
					-- line3_inv = ""
				-- else
					-- nav_id = simDR_gps_nav_id
					-- if string.len(nav_id) > 5 then
						-- nav_id = string.sub(nav_id, 1, 5)
					-- end
			elseif vnav_speed == B738DR_fmc_climb_speed_l then
				nav_id = B738DR_rest_wpt_spd_id
				if string.len(nav_id) > 5 then
					nav_id = string.sub(nav_id, 1, 5)
				end
				line3_m = string.format("%3d", B738DR_fmc_climb_speed_l)
				line3_l = "   /"
				line3_l = line3_l .. nav_id
				line3_l = line3_l .. "          ---  "
			else
				if B738DR_fmc_climb_speed_l == 250 then
					line3_m = "250"
					line3_l = "   /10000          ---  "
				else
					line3_l = "250/10000          ---  "
					line3_m = ""
				end
			end
			if B738DR_ap_spd_interv_status == 1 and B738DR_flight_phase < 2 then
				line2_m = string.format("%3d", B738DR_mcp_speed_dial)	--simDR_airspeed_dial)
				line2_l = "   /MCP "
			else
				line2_l = string.format("%3d", B738DR_fmc_climb_speed) .. "/"
				line2_l = line2_l .. string.sub(string.format("%5.3f", B738DR_fmc_climb_speed_mach), 2, 5)
				line2_m = ""
			end
		end
		line0_s = "                    1/1 "
		line1_s = "                        "
		--line1_x = " CRZ ALT        AT -----"
			
			--rest_alt_id == ""
		if B738DR_flight_phase > 1 then
				rest_alt_id = ""
				rest_alt = ""
		else
			if B738DR_rest_wpt_alt == 0 then
				if crz_alt == "*****" then
					rest_alt_id = ""
					rest_alt = ""
				else
					rest_alt_id = "T/C"
					rest_alt = crz_alt
				end
			else
				if string.len(B738DR_rest_wpt_alt_id) > 5 then
					rest_alt_id = string.sub(B738DR_rest_wpt_alt_id, 1, 5)
				else
					rest_alt_id = B738DR_rest_wpt_alt_id
				end
				
				if B738DR_rest_wpt_alt > B738DR_trans_alt then
					rest_alt = "FL" .. string.format("%03d", B738DR_rest_wpt_alt/100)
				else
					rest_alt = string.format("%5d",B738DR_rest_wpt_alt)
				end
				if B738DR_rest_wpt_alt_t == 43 then
					rest_alt = rest_alt .. "A"
				elseif B738DR_rest_wpt_alt_t == 45 then
					rest_alt = rest_alt .. "B"
				end
				--B738DR_rest_wpt_alt_idx
			end
		end
		line1_x = " CRZ ALT        AT " .. rest_alt_id
		line2_x = " TGT SPD        TO " .. rest_alt_id
		
		
		if B738DR_flight_phase < 2 and B738DR_autopilot_vnav_status == 1 then
			if rest_alt_id == "T/C" then
				line1_m = crz_alt
				line1_l = "                  " .. rest_alt
			else
				line1_m = crz_alt .. "             " .. rest_alt
				line1_l = ""
			end
		else
			line1_m = ""
			line1_l = crz_alt .. "             " .. rest_alt
		end
		
--		line1_l = "FL350"             10000A"
		--line1_l = crz_alt .. "              -----"
		-- if crz_alt == "*****" then
			-- line2_x = " TGT SPD        TO -----"
		-- else
			-- if B738DR_rest_wpt_alt == 0 then
				-- line2_x = " TGT SPD        TO T/C"
			-- else
				-- line2_x = " TGT SPD        TO " .. string.sub(B738DR_rest_wpt_alt_id, 1, 5)
				-- if B738DR_rest_wpt_alt_t == 43 then
					-- line2_x = line2_x .. "A"
				-- elseif B738DR_rest_wpt_alt_t == 45 then
					-- line2_x = line2_x .. "B"
				-- end
				-- --B738DR_rest_wpt_alt_idx
				-- --.. string.sub(B738DR_rest_wpt_alt_id, 1, 5)
				-- --.. crz_alt
			-- end
		-- end
		
--		line2_x = " TGT SPD        TO " .. crz_alt	--"-----"
--		line2_l = "280/.720   2004.3 / 19NM"
--		line2_l = string.format("%3d", B738DR_fmc_climb_speed) .. "/"
--		line2_l = line2_l .. string.sub(string.format("%5.3f", B738DR_fmc_climb_speed_mach), 2, 5)
--		line2_l = string.format("%3d", clb_spd) .. "/"
--		line2_l = line2_l .. string.sub(string.format("%5.3f", clb_spd_mach), 2, 5)
		if B738DR_flight_phase < 2 then
			
			if B738DR_rest_wpt_alt == 0 then
			
				-- if B738DR_flight_phase == 1 then
					-- T/C time and distance
					-- if simDR_vvi_fpm_pilot > 800 and simDR_altitude_pilot < 10000 then
							-- delta_alt = 10000 - simDR_altitude_pilot
							-- time_TOD = delta_alt / (simDR_vvi_fpm_pilot / 60)
							-- delta_alt = time_TOD
							-- time1_TOD_h = math.floor((time_TOD / 3600))
							-- time_TOD = time_TOD - (time1_TOD_h * 3600)
							-- time1_TOD_m = math.floor((time_TOD / 60))
							-- time_TOD = time_TOD - (time1_TOD_m * 60)
							-- time1_TOD_s = math.floor(time_TOD)
							-- time_TOD_s = simDR_zulu_seconds + time_TOD_s
							-- if time1_TOD_s > 59 then
								-- time1_TOD_s = time1_TOD_s - 60
								-- time1_TOD_m = time1_TOD_m + 1
							-- end
							-- time1_TOD_m = time1_TOD_m + simDR_zulu_minutes
							-- if time1_TOD_m > 59 then
								-- time1_TOD_m = time1_TOD_m - 60
								-- time1_TOD_h = time1_TOD_h + 1
							-- end
							-- time1_TOD_h = time1_TOD_h + simDR_zulu_hours
							-- if time1_TOD_h > 23 then
								-- time1_TOD_h = time1_TOD_h - 24
							-- end
							-- v11 = 300
							-- v21 = B738DR_fmc_climb_speed * (1 + (simDR_altitude_pilot / 1000 * 0.02))
							-- v11 = (v11 + v21) / 2
							-- clb_100 = v11 * 0.51444 * delta_alt * 0.00054		-- distance to 10000 ft
					-- else
						-- time1_TOD_h = simDR_zulu_hours
						-- time1_TOD_m = simDR_zulu_minutes
						-- time1_TOD_s = simDR_zulu_seconds
						-- clb_100 = 0
						-- --line2_l = line2_l .. "   ----.- /---NM"
					-- end
					-- if simDR_vvi_fpm_pilot > 800 and crz_alt_num > 10000 then
							-- if simDR_altitude_pilot < 10000 then
								-- delta_alt = crz_alt_num - 10000
							-- else
								-- delta_alt = crz_alt_num - simDR_altitude_pilot
							-- end
							-- time_TOD = delta_alt / (simDR_vvi_fpm_pilot / 60)
							-- delta_alt = time_TOD
							-- time_TOD_h = math.floor((time_TOD / 3600))
							-- time_TOD = time_TOD - (time_TOD_h * 3600)
							-- time_TOD_m = math.floor((time_TOD / 60))
							-- time_TOD = time_TOD - (time_TOD_m * 60)
							-- time_TOD_s = math.floor(time_TOD)
							-- time_TOD_s = time1_TOD_s + time_TOD_s
							-- if time_TOD_s > 59 then
								-- time_TOD_s = time_TOD_s - 60
								-- time_TOD_m = time_TOD_m + 1
							-- end
							-- time_TOD_m = time_TOD_m + time1_TOD_m
							-- if time_TOD_m > 59 then
								-- time_TOD_m = time_TOD_m - 60
								-- time_TOD_h = time_TOD_h + 1
							-- end
							-- time_TOD_h = time_TOD_h + time1_TOD_h
							-- if time_TOD_h > 23 then
								-- time_TOD_h = time_TOD_h - 24
							-- end
							-- line2_l = line2_l .. "   "
							-- line2_l = line2_l .. string.format("%02d", time_TOD_h)
							-- line2_l = line2_l .. string.format("%02d", time_TOD_m)
							-- line2_l = line2_l .. "." 
							-- line2_l = line2_l .. string.sub(string.format("%02d", time_TOD_s), 1, 1)
							-- line2_l = line2_l .. " /"
							-- if simDR_altitude_pilot < 10000 then
								-- v11 = B738DR_fmc_climb_speed * 1.2
							-- else
								-- v11 = B738DR_fmc_climb_speed * (1 + (simDR_altitude_pilot / 1000 * 0.02))
							-- end
							-- v21 = B738DR_fmc_climb_speed * (1 + (crz_alt_num / 1000 * 0.02))
							-- v11 = (v11 + v21) / 2
							-- time_TOD = v11 * 0.51444 * delta_alt * 0.00054
							-- time_TOD = time_TOD + clb_100
							-- line2_l = line2_l .. string.format("%3d", time_TOD)
							-- line2_l = line2_l .. "NM"
					-- else
						-- if clb_100 == 0 then
							-- line2_l = line2_l .. "   ----.- /---NM"
						-- else
							-- line2_l = line2_l .. "   "
							-- line2_l = line2_l .. string.format("%02d", time1_TOD_h)
							-- line2_l = line2_l .. string.format("%02d", time1_TOD_m)
							-- line2_l = line2_l .. "." 
							-- line2_l = line2_l .. string.sub(string.format("%02d", time1_TOD_s), 1, 1)
							-- line2_l = line2_l .. " /"
							-- line2_l = line2_l .. string.format("%3d", clb_100)
							-- line2_l = line2_l .. "NM"
						-- end
					-- end
					
				-- else
					-- line2_l = line2_l .. "   ----.- /---NM"
				-- end
			
				if time_tc == 0 then
					line2_l = line2_l .. "   ----.- /---NM"
				else
					tmp_wpt_eta2 = math.floor(time_tc)
					tmp_wpt_eta3 = (time_tc - tmp_wpt_eta2) * 60
					tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%04.1f", tmp_wpt_eta3)
					line2_l = line2_l .. "   "
					line2_l = line2_l .. tmp_wpt_eta .. " /"
					line2_l = line2_l .. string.format("%3d", dist_tc)
					line2_l = line2_l .. "NM"
				end
			else
				if legs_num > 1 then				
					if B738DR_rest_wpt_alt_idx == 0 then
						line2_l = line2_l .. "   ----.- /---NM"
					else
						if B738DR_rest_wpt_alt_idx == offset then
							time_TOD = simDR_fmc_dist
						else
							time_TOD = simDR_fmc_dist
							for ii = offset + 1, B738DR_rest_wpt_alt_idx do
								time_TOD = time_TOD + legs_data[ii][3]	-- to wpt idx
							end
						end
						tmp_wpt_eta2 = math.floor(legs_data[B738DR_rest_wpt_alt_idx][13])
						tmp_wpt_eta3 = (legs_data[B738DR_rest_wpt_alt_idx][13] - tmp_wpt_eta2) * 60
						tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%04.1f", tmp_wpt_eta3)
						line2_l = line2_l .. "   " 
						line2_l = line2_l .. tmp_wpt_eta
						line2_l = line2_l .. " /"
						line2_l = line2_l .. string.format("%3d", time_TOD)
						line2_l = line2_l .. "NM"
					end
					
				-- if legs_num > 1 then
					-- if B738DR_rest_wpt_alt_idx == offset then
						-- time_TOD = simDR_fmc_dist	-- distance to T/C
					-- else
						-- time_TOD = simDR_fmc_dist	-- distance to T/C
						-- for ii = offset + 1, B738DR_rest_wpt_alt_idx do
							-- time_TOD = time_TOD + legs_data[ii][3]	-- to wpt idx
						-- end
					-- end
					-- line2_l = line2_l .. "   ----.- /"
					-- line2_l = line2_l .. string.format("%3d", time_TOD)
					-- line2_l = line2_l .. "NM"
				else
					line2_l = line2_l .. "   ----.- /---NM"
				end
			end
		else
			line2_l = line2_l .. "   ----.- /---NM"
		end
--		line2_l = line2_l .. "   ----.- /---NM"
		line2_s = "                 Z      "
		line3_x = " SPD REST      ERR -----"
--		line3_l = "250/10000          ---  "
		line3_s = "                      LO"
		line4_x = "------------    "
		line4_l = "<ECON       "
		if clb == "<SEL>" then
			line4_x = line4_x .. "CLB   N1"
			thrust = B738DR_thr_climb_N1 * 100
		elseif clb_1 == "<SEL>" then
			line4_x = line4_x .. "CLB-1 N1"
			thrust = B738DR_thr_climb_N1 * 97
		elseif clb_2 == "<SEL>" then
			line4_x = line4_x .. "CLB-2 N1"
			thrust = B738DR_thr_climb_N1 * 94
		end
		if thrust == 0 then
			line4_l = line4_l .. "---.-/---.-%"
		else
			line4_l = line4_l .. string.format("%5.1f", thrust)
			line4_l = line4_l .. "/"
			line4_l = line4_l .. string.format("%5.1f", thrust)
			line4_l = line4_l .. "%"
		end
		line4_s = "                        "
		line5_x = "            ------------"
		-- if  not prompt ENG OUT
		if eng_out_prompt == 0 then
			line5_l = "<MAX RATE       ENG OUT>"
			line5_s = "                        "
		else
		-- if prompt ENG OUT
			line5_l = "<                      >"
			line5_s = " LT ENG OUT  RT ENG OUT "
		end
		line6_x = "                        "
		line6_l = "<MAX ANGLE          RTA>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
--		line2_inv = ""
--		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end

function B738_fmc_climb_rta()

	if page_climb_rta == 1 then
		act_page = 1
		max_page = 1
		line0_l = "  ACT RTA CLB           "
		line0_s = "                        "
		line1_x = " CRZ ALT        AT MACEY"
		line1_l = "FL350              6000A"
		line1_s = "                        "
		line2_x = " TGT SPD      TIME ERROR"
		line2_l = "280/.720         ON TIME"
		line2_s = "                 Z      "
		line3_x = " SPD REST               "
		line3_l = "250/10000               "
		line3_s = "                        "
		-- if  not prompt ENG OUT
		line4_x = "------------            "
		line4_l = "<ECON                   "
		line4_s = "                        "
		line5_x = "            ------------"
		line5_l = "<MAX RATE       ENG OUT>"
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<MAX ANGLE          RTA>"
		line6_s = "                        "
		-- if prompt ENG OUT
		-- line4_x = "                        "
		-- line4_l = "                        "
		-- line4_s = "                        "
		-- line5_x = "------------------------"
		-- line5_l = "<                      >"
		-- line5_s = " LT ENG OUT  RT ENG OUT "
		-- line6_x = "                        "
		-- line6_l = "                        "
		-- line6_s = "                        "
	end

end

function B738_fmc_climb_eng_out()

	if page_climb_eng_out == 1 then
		act_page = 1
		max_page = 1
		line0_l = "  ENG OUT CLB           "
		line0_s = "                        "
		line1_x = " CRZ ALT         MAX ALT"
		line1_l = "FL350              FL185"
		line1_s = "                        "
		line2_x = " ENG OUT SPD      CON N1"
		line2_l = "210KT              92.6%"
		line2_s = "                        "
		line3_x = "                        "
		line3_l = "                        "
		line3_s = "                        "
		line4_x = "------------------------"
		-- Left engine out
		line4_l = "<LT ENG OUT            >"
		line4_s = "             RT ENG OUT "
		-- Right engine out
		-- line4_l = "<            RT ENG OUT>"
		-- line4_s = " LT ENG OUT             "
		-- fix
		line5_x = "                        "
		line5_l = "                        "
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "                        "
		line6_s = "                        "
	end

end

function B738_fmc_cruise()

	if page_cruise == 1 then
		act_page = 1
		max_page = 1
		local thrust = 0
		local trip = "     "
		local max_alt = "     "
		local time_TOD = 0
		local time_TOD_h = 0
		local time_TOD_m = 0
		local time_TOD_s = 0
		local delta_alt = 0
		local tmp_wpt_eta = ""
		local tmp_wpt_eta2 = 0
		local tmp_wpt_eta3 = 0
		
		if B738DR_cruise_opt_alt > 0 then
			trip = "FL" .. string.format("%03d", (B738DR_cruise_opt_alt/100))
		end
		if B738DR_cruise_max_alt > 0 then
			max_alt = "FL" .. string.format("%03d", (B738DR_cruise_max_alt/100))
		end
		if crz_exec == 0 and B738DR_flight_phase ~= 3 and B738DR_flight_phase ~= 4 then
			if B738DR_flight_phase == 2 and B738DR_autopilot_vnav_status == 1 then	-- phase cruise
				line0_l = "  ACT "
			else
				line0_l = "      "
			end
			if B738DR_cruise_mode == 0 then
				line0_l = line0_l .. "ECON CRZ          "
			elseif B738DR_cruise_mode == 1 then
				line0_l = line0_l .. "LRC CRZ           "
			elseif B738DR_cruise_mode == 2 then
				if simDR_airspeed_is_mach == 0 then
					line0_l = line0_l .. string.format("%3d", B738DR_fmc_cruise_speed)
					line0_l = line0_l .. "KT CRZ         "
				else
					line0_l = line0_l .. "M."
					line0_l = line0_l .. string.format("%3d", (B738DR_fmc_cruise_speed_mach * 1000))
					line0_l = line0_l .. " CRZ         "
				end
			end
			line0_s = "                    1/1 "
			line1_x = " CRZ ALT  OPT/MAX       "
			if B738DR_flight_phase == 2 and B738DR_autopilot_vnav_status == 1 then
				line1_m = crz_alt
				line1_l = "        " .. trip
				line1_l = line1_l .. "/"
				line1_l = line1_l .. max_alt
			else
				line1_m = ""
				line1_l = crz_alt .. "   "
				line1_l = line1_l .. trip
				line1_l = line1_l .. "/"
				line1_l = line1_l .. max_alt
			end
			
			-- line1_l = crz_alt .. "   "
			-- line1_l = line1_l .. trip
			-- line1_l = line1_l .. "/"
			-- line1_l = line1_l .. max_alt
			line1_s = "                        "
			line2_x = " TGT SPD          TO T/D"
			if B738DR_flight_phase == 2 then
				if simDR_airspeed_is_mach == 0 then
					if B738DR_ap_spd_interv_status == 0 then
						line2_m = string.format("%3d", B738DR_fmc_cruise_speed)
						line2_l = "   /" .. string.sub(string.format("%5.3f", B738DR_fmc_cruise_speed_mach), 2, 5)
					else
						line2_m = string.format("%3d", B738DR_mcp_speed_dial)	--simDR_airspeed_dial)
						line2_l = "   /MCP "
					end
				else
					if B738DR_ap_spd_interv_status == 0 then
						line2_l = string.format("%3d", B738DR_fmc_cruise_speed) .. "/    "
						line2_m = "    " .. string.sub(string.format("%5.3f", B738DR_fmc_cruise_speed_mach), 2, 5)
					else
						line2_m = string.sub(string.format("%5.3f", B738DR_mcp_speed_dial), 2, 5)	--simDR_airspeed_dial), 2, 5)
						line2_l = "   /MCP "
					end
				end
			else
--				if B738DR_ap_spd_interv_status == 1 and B738DR_flight_phase == 2 then
--					line2_inv = string.format("%3d", simDR_airspeed_dial)
--					line2_l = "   /FMC "
--				else
					line2_l = string.format("%3d", B738DR_fmc_cruise_speed) .. "/"
					line2_l = line2_l .. string.sub(string.format("%5.3f", B738DR_fmc_cruise_speed_mach), 2, 5)
					line2_m = ""
--				end
			end
--			line2_l = string.format("%3d", B738DR_fmc_cruise_speed) .. "/"
--			line2_l = line2_l .. string.sub(string.format("%5.3f", B738DR_fmc_cruise_speed_mach), 2, 5)
			if B738DR_vnav_td_dist <= 0 then
				line2_l = line2_l .. " "
				line2_s = " "
			else
				line2_s = "                 Z      "
				if time_td == 0 then
					line2_l = line2_l .. " "
					line2_s = " "
				else
					tmp_wpt_eta2 = math.floor(time_td)
					tmp_wpt_eta3 = (time_td - tmp_wpt_eta2) * 60
					tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%04.1f", tmp_wpt_eta3)
					line2_l = line2_l .. "   "
					line2_l = line2_l .. tmp_wpt_eta .. " /"
					line2_l = line2_l .. string.format("%3d", dist_td)
					line2_l = line2_l .. "NM"
				end
				-- if B738DR_vnav_td_dist > 0 and B738DR_vnav_td_dist < 1000 and simDR_ground_spd > 70 then
					-- time_TOD = B738DR_vnav_td_dist * 1852 / simDR_ground_spd
-- --					time_TOD = time_TOD / 1000	-- in seconds
					-- --DR_test = time_TOD
					-- time_TOD_h = math.floor((time_TOD / 3600))
					-- time_TOD = time_TOD - (time_TOD_h * 3600)
					-- time_TOD_m = math.floor((time_TOD / 60))
					-- time_TOD = time_TOD - (time_TOD_m * 60)
					-- time_TOD_s = math.floor(time_TOD)
					-- time_TOD_s = simDR_zulu_seconds + time_TOD_s
					-- if time_TOD_s > 59 then
						-- time_TOD_s = time_TOD_s - 60
						-- time_TOD_m = time_TOD_m + 1
					-- end
					-- time_TOD_m = time_TOD_m + simDR_zulu_minutes
					-- if time_TOD_m > 59 then
						-- time_TOD_m = time_TOD_m - 60
						-- time_TOD_h = time_TOD_h + 1
					-- end
					-- time_TOD_h = time_TOD_h + simDR_zulu_hours
					-- if time_TOD_h > 23 then
						-- time_TOD_h = time_TOD_h - 24
					-- end
					-- line2_l = line2_l .. "   "
					-- line2_l = line2_l .. string.format("%02d", time_TOD_h)
					-- line2_l = line2_l .. string.format("%02d", time_TOD_m)
					-- line2_l = line2_l .. "." 
					-- line2_l = line2_l .. string.sub(string.format("%02d", time_TOD_s), 1, 1)
					-- line2_l = line2_l .. " /"
					-- line2_l = line2_l .. string.format("%3d", B738DR_vnav_td_dist)
				-- else
					-- line2_l = line2_l .. "   ----.- /---"
-- --					line2_l = line2_l .. "---"
				-- end
				-- line2_l = line2_l .. "NM"
				-- line2_s = "                 Z      "
			end
--			line2_l = line2_l .. "NM"
--			line2_s = "                 Z      "
			line3_x = " TURB N1     ACTUAL WIND"
	--		line3_l = " 87.3/ 87.3%    129`/ 14"
			thrust = B738DR_thr_cruise_N1 * 100
			if thrust == 0 then
				line3_l = "---.-/---.-%    "
			else
				line3_l = string.format("%5.1f", thrust) .. "/"
				line3_l = line3_l .. string.format("%5.1f", thrust)
				line3_l = line3_l .. "%    "
			end
			if simDR_wind_spd > 0.5 then
				line3_l = line3_l .. string.format("%03d", simDR_wind_hdg)
				line3_l = line3_l .. "`/"
				line3_l = line3_l .. string.format("%03d", simDR_wind_spd)
			else
				line3_l = line3_l .. "---`/---"
			end
			line3_s = "                        "
			line4_x = " FUEL AT ----           "
			line4_l = "         --.-           "
			line4_s = "                        "
			line5_x = "------------------------"
			line5_l = "<ECON           ENG OUT>"
			line5_s = "                        "
			line6_x = "                        "
			line6_l = "<LRC                RTA>"
			line6_s = "                        "
			line0_inv = ""
			line1_inv = ""
		
		-- CRZ CLB
		elseif crz_exec == 1 or B738DR_flight_phase == 3 then
			if B738DR_flight_phase == 3 and crz_exec == 0 then
				line0_l = "  ACT CRZ CLB           "
				line0_inv = ""
				line1_l = crz_alt .. "   "
				line1_inv = ""
				line6_l = "<MAX ANGLE          RTA>"
			else
--				line0_l = "  MOD CRZ CLB           "
				line0_l = "      CRZ CLB           "
				line0_inv = "  MOD"
				line1_l = "        "
				line1_inv = crz_alt
				line6_l = "<MAX ANGLE        ERASE>"
			end
			line0_s = "                    1/1 "
			line1_x = " CRZ ALT  OPT/MAX       "
--			line1_l = crz_alt .. "   "
			line1_l = line1_l .. trip
			line1_l = line1_l .. "/"
			line1_l = line1_l .. max_alt
			line1_s = "                        "
			line2_x = " TGT SPD        TO " .. crz_alt
			if simDR_airspeed_is_mach == 0 then
				if B738DR_ap_spd_interv_status == 0 then
					line2_m = string.format("%3d", B738DR_fmc_cruise_speed)
					line2_l = "   /" .. string.sub(string.format("%5.3f", B738DR_fmc_cruise_speed_mach), 2, 5)
				else
					line2_m = string.format("%3d", B738DR_mcp_speed_dial)	--simDR_airspeed_dial)
					line2_l = "   /MCP "
				end
			else
				if B738DR_ap_spd_interv_status == 0 then
					line2_l = string.format("%3d", B738DR_fmc_cruise_speed) .. "/    "
					line2_m = "    " .. string.sub(string.format("%5.3f", B738DR_fmc_cruise_speed_mach), 2, 5)
				else
					line2_m = string.sub(string.format("%5.3f", B738DR_mcp_speed_dial), 2, 5)	--simDR_airspeed_dial), 2, 5)
					line2_l = "   /MCP "
				end
			end
--			line2_l = crz_spd .. "/"
--			line2_l = line2_l .. crz_spd_mach
			if simDR_vvi_fpm_pilot > 800 then
					delta_alt = crz_alt_num - simDR_altitude_pilot
					time_TOD = delta_alt / (simDR_vvi_fpm_pilot / 60)
					delta_alt = time_TOD
					--DR_test = time_TOD
					time_TOD_h = math.floor((time_TOD / 3600))
					time_TOD = time_TOD - (time_TOD_h * 3600)
					time_TOD_m = math.floor((time_TOD / 60))
					time_TOD = time_TOD - (time_TOD_m * 60)
					time_TOD_s = math.floor(time_TOD)
					time_TOD_s = simDR_zulu_seconds + time_TOD_s
					if time_TOD_s > 59 then
						time_TOD_s = time_TOD_s - 60
						time_TOD_m = time_TOD_m + 1
					end
					time_TOD_m = time_TOD_m + simDR_zulu_minutes
					if time_TOD_m > 59 then
						time_TOD_m = time_TOD_m - 60
						time_TOD_h = time_TOD_h + 1
					end
					time_TOD_h = time_TOD_h + simDR_zulu_hours
					if time_TOD_h > 23 then
						time_TOD_h = time_TOD_h - 24
					end
					line2_l = line2_l .. "   "
					line2_l = line2_l .. string.format("%02d", time_TOD_h)
					line2_l = line2_l .. string.format("%02d", time_TOD_m)
					line2_l = line2_l .. "." 
					line2_l = line2_l .. string.sub(string.format("%02d", time_TOD_s), 1, 1)
					line2_l = line2_l .. " /"
					time_TOD = simDR_ground_spd * delta_alt * 0.00054
					line2_l = line2_l .. string.format("%3d", time_TOD)
					line2_l = line2_l .. "NM"
			else
				line2_l = line2_l .. "   ----.- /---NM"
			end
			line2_s = "                 Z      "
			line3_x = " SPD REST       EST WIND"
			line3_l = "250/10000       "
			if simDR_wind_spd > 0.5 then
				line3_l = line3_l .. string.format("%03d", simDR_wind_hdg)
				line3_l = line3_l .. "`/"
				line3_l = line3_l .. string.format("%03d", simDR_wind_spd)
			else
				line3_l = line3_l .. "---`/---"
			end
			line3_s = "                        "
			line4_x = "------------            "
			line4_l = "<ECON                   "
			line4_s = "                        "
			line5_x = "            ------------"
			line5_l = "<MAX RATE       ENG OUT>"
			line5_s = "                        "
			line6_x = "                        "
			line6_s = "                        "
		-- CRZ DES
		elseif crz_exec == 2 or B738DR_flight_phase == 4 then
			if B738DR_flight_phase == 4 and crz_exec == 0 then
				line0_l = "  ACT CRZ DES           "
				line0_inv = ""
				line1_l = crz_alt .. "   "
				line1_inv = ""
				line6_l = "<MAX ANGLE          RTA>"
			else
--				line0_l = "  MOD CRZ DES           "
				line0_l = "      CRZ DES           "
				line0_inv = "  MOD"
				line1_l = "        "
				line1_inv = crz_alt
				line6_l = "<MAX ANGLE        ERASE>"
			end
			line0_s = "                    1/1 "
			line1_x = " CRZ ALT  OPT/MAX       "
--			line1_l = crz_alt .. "   "
			line1_l = line1_l .. trip
			line1_l = line1_l .. "/"
			line1_l = line1_l .. max_alt
			line1_s = "                        "
			line2_x = " TGT SPD        TO " .. crz_alt
			if simDR_airspeed_is_mach == 0 then
				if B738DR_ap_spd_interv_status == 0 then
					line2_m = string.format("%3d", B738DR_fmc_cruise_speed)
					line2_l = "   /" .. string.sub(string.format("%5.3f", B738DR_fmc_cruise_speed_mach), 2, 5)
				else
					line2_m = string.format("%3d", B738DR_mcp_speed_dial)	--simDR_airspeed_dial)
					line2_l = "   /MCP "
				end
			else
				if B738DR_ap_spd_interv_status == 0 then
					line2_l = string.format("%3d", B738DR_fmc_cruise_speed) .. "/    "
					line2_m = "    " .. string.sub(string.format("%5.3f", B738DR_fmc_cruise_speed_mach), 2, 5)
				else
					line2_m = string.sub(string.format("%5.3f", B738DR_mcp_speed_dial), 2, 5)	--simDR_airspeed_dial), 2, 5)
					line2_l = "   /MCP "
				end
			end
--			line2_l = crz_spd .. "/"
--			line2_l = line2_l .. crz_spd_mach
			if simDR_vvi_fpm_pilot < -800 then
					delta_alt = simDR_altitude_pilot - crz_alt_num
					time_TOD = delta_alt / 16.66666 	--- 1000 ft/min = simDR_vvi_fpm_pilot / 60
					delta_alt = time_TOD
					--DR_test = time_TOD
					time_TOD_h = math.floor((time_TOD / 3600))
					time_TOD = time_TOD - (time_TOD_h * 3600)
					time_TOD_m = math.floor((time_TOD / 60))
					time_TOD = time_TOD - (time_TOD_m * 60)
					time_TOD_s = math.floor(time_TOD)
					time_TOD_s = simDR_zulu_seconds + time_TOD_s
					if time_TOD_s > 59 then
						time_TOD_s = time_TOD_s - 60
						time_TOD_m = time_TOD_m + 1
					end
					time_TOD_m = time_TOD_m + simDR_zulu_minutes
					if time_TOD_m > 59 then
						time_TOD_m = time_TOD_m - 60
						time_TOD_h = time_TOD_h + 1
					end
					time_TOD_h = time_TOD_h + simDR_zulu_hours
					if time_TOD_h > 23 then
						time_TOD_h = time_TOD_h - 24
					end
					line2_l = line2_l .. "   "
					line2_l = line2_l .. string.format("%02d", time_TOD_h)
					line2_l = line2_l .. string.format("%02d", time_TOD_m)
					line2_l = line2_l .. "." 
					line2_l = line2_l .. string.sub(string.format("%02d", time_TOD_s), 1, 1)
					line2_l = line2_l .. " /"
					time_TOD = simDR_ground_spd * delta_alt * 0.00054
					line2_l = line2_l .. string.format("%3d", time_TOD)
					line2_l = line2_l .. "NM"
			else
				line2_l = line2_l .. "   ----.- /---NM"
			end
			line2_s = "                 Z      "
			line3_x = " SPD REST       EST WIND"
			line3_l = "250/10000       "
			if simDR_wind_spd > 0.5 then
				line3_l = line3_l .. string.format("%03d", simDR_wind_hdg)
				line3_l = line3_l .. "`/"
				line3_l = line3_l .. string.format("%03d", simDR_wind_spd)
			else
				line3_l = line3_l .. "---`/---"
			end
			line3_s = "                        "
			line4_x = "------------            "
			line4_l = "<ECON                   "
			line4_s = "                        "
			line5_x = "            ------------"
			line5_l = "<MAX RATE       ENG OUT>"
			line5_s = "                        "
			line6_x = "                        "
			line6_s = "                        "
		end
--		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end

function B738_fmc_cruise_rta()

	if page_cruise_rta == 1 then
		act_page = 1
		max_page = 1
		line0_l = "  ACT RTA CRZ           "
		line0_s = "                    1/1 "
		line1_x = " CRZ ALT  OPT/MAX       "
		line1_l = "FL350   FL340/361       "
		line1_s = "                        "
		line2_x = " TGT SPD          TO T/D"
		line2_l = ".780       2004.3 /100NM"
		line2_s = "                 Z      "
		line3_x = " TIME ERROR  ACTUAL WIND"
		line3_l = "EARLY 05:31     129`/ 14"
		line3_s = "                        "
		line4_x = " FUEL AT KATL           "
		line4_l = "         12.5           "
		line4_s = "                        "
		line5_x = "------------------------"
		line5_l = "<ECON           ENG OUT>"
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<LRC                RTA>"
		line6_s = "                        "
	end

end

function B738_fmc_cruise_clb()

	if page_cruise_clb == 1 then
		act_page = 1
		max_page = 1
		line0_l = "  MOD CRZ CLB           "
		line0_s = "                    1/1 "
		line1_x = " CRZ ALT                "
		line1_l = "FL370                   "
		line1_s = "                        "
		line2_x = " TGT SPD        TO FL370"
		line2_l = ".780       2004.5 / 15NM"
		line2_s = "                 Z      "
		line3_x = " SPD REST       EST WIND"
		line3_l = "---/-----       129`/ 14"
		line3_s = "                        "
		line4_x = "------------     SAVINGS"
		line4_l = "<ECON               1.3%"
		line4_s = "                        "
		line5_x = "            ------------"
		line5_l = "<MAX RATE       ENG OUT>"
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<MAX ANGLE        ERASE>"
		line6_s = "                        "
	end

end

function B738_fmc_cruise_rta_clb()

	if page_cruise_rta_clb == 1 then
		act_page = 1
		max_page = 1
		line0_l = "  ACT RTA CRZ CLB       "
		line0_s = "                    1/1 "
		line1_x = " CRZ ALT      TIME ERROR"
		line1_l = "FL370        EARLY 01:22"
		line1_s = "                        "
		line2_x = " TGT SPD        TO FL370"
		line2_l = ".780       2004.5 / 15NM"
		line2_s = "                 Z      "
		line3_x = " SPD REST       EST WIND"
		line3_l = "---/-----       129`/ 14"
		line3_s = "                        "
		line4_x = "------------            "
		line4_l = "<ECON                   "
		line4_s = "                        "
		line5_x = "            ------------"
		line5_l = "<MAX RATE       ENG OUT>"
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<MAX ANGLE        ERASE>"
		line6_s = "                        "
	end

end

function B738_fmc_cruise_des()

	if page_cruise_des == 1 then
		act_page = 1
		max_page = 1
		line0_l = "  MOD CRZ DES           "
		line0_s = "                    1/1 "
		line1_x = " CRZ ALT                "
		line1_l = "FL370                   "
		line1_s = "                        "
		line2_x = " TGT SPD        TO FL370"
		line2_l = ".780       2004.5 / 15NM"
		line2_s = "                 Z      "
		line3_x = " SPD REST       EST WIND"
		line3_l = "---/-----       129`/ 14"
		line3_s = "                        "
		line4_x = "                 PENALTY"
		line4_l = "                    1.3%"
		line4_s = "                        "
		line5_x = "------------------------"
		line5_l = "            PLANNED DES>"
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<FORECAST         ERASE>"
		line6_s = "                        "
	end

end

function B738_fmc_cruise_rta_des()

	if page_cruise_rta_des == 1 then
		act_page = 1
		max_page = 1
		line0_l = "  ACT RTA CRZ DES       "
		line0_s = "                    1/1 "
		line1_x = " CRZ ALT      TIME ERROR"
		line1_l = "FL280         LATE 10:54"
		line1_s = "                        "
		line2_x = " TGT SPD        TO FL280"
		line2_l = ".780       2004.5 / 15NM"
		line2_s = "                 Z      "
		line3_x = " SPD REST    ACTUAL WIND"
		line3_l = "250/10000       129`/ 14"
		line3_s = "                        "
		line4_x = "                        "
		line4_l = "                        "
		line4_s = "                        "
		line5_x = "------------------------"
		line5_l = "            PLANNED DES>"
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "<FORECAST           RTA>"
		line6_s = "                        "
	end

end

function B738_fmc_cruise_eng_out()

	if page_cruise_eng_out == 1 then
		act_page = 1
		max_page = 1
		line0_l = "  ENG OUT CRZ           "
		line0_s = "                        "
		line1_x = " CRZ ALT         MAX ALT"
		line1_l = "FL350              FL185"
		line1_s = "                        "
		line2_x = " ENG OUT SPD      CON N1"
		line2_l = "210KT              92.6%"
		line2_s = "                        "
		line3_x = " CON N1                 "
		line3_l = " 91.9%                  "
		line3_s = "                        "
		line4_x = "------------------------"
		-- Left engine out
		line4_l = "<LT ENG OUT            >"
		line4_s = "             RT ENG OUT "
		-- Right engine out
		-- line4_l = "<            RT ENG OUT>"
		-- line4_s = " LT ENG OUT             "
		-- fix
		line5_x = "                        "
		line5_l = "                        "
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "                        "
		line6_s = "                        "
	end

end

function B738_fmc_descent()

	if page_descent == 1 then
		act_page = 1
		max_page = 1
		local v_s = 0
		local vpa = 0
		local ap_mcp_spd = simDR_airspeed_dial
		local temp_speed = 0
		local temp_speed2 = 0
		local econ_on = 0
		local TOD_str = ""
		local time_TOD = 0
		local time_TOD_h = 0
		local time_TOD_m = 0
		local time_TOD_s = 0
		local delta_alt = 0
		local nav_id = ""
		local str_rest_alt = ""
		local tmp_wpt_eta = ""
		local tmp_wpt_eta2 = 0
		local tmp_wpt_eta3 = 0
		
			if B738DR_flight_phase > 4 and B738DR_autopilot_vnav_status == 1 then	-- phase descent
				line0_l = "  ACT "
				if B738DR_rest_wpt_alt_idx == 0 then
					TOD_str = "   ----.- /---NM"
				else
					tmp_wpt_eta2 = math.floor(legs_data[B738DR_rest_wpt_alt_idx][13])
					tmp_wpt_eta3 = (legs_data[B738DR_rest_wpt_alt_idx][13] - tmp_wpt_eta2) * 60
					tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%04.1f", tmp_wpt_eta3)
					TOD_str = "   " .. tmp_wpt_eta
					TOD_str = TOD_str .. " /---NM"
				end
				line2_x = " TGT SPD        TO " .. B738DR_rest_wpt_alt_id
				TOD_str = "   ----.- /---NM"
				-- if simDR_airspeed_is_mach == 0 then
					-- if ap_mcp_spd < B738DR_fmc_descent_speed and B738DR_descent_mode == 1 then
						-- econ_on = 1
					-- end
				-- else
					-- if B738DR_descent_mode == 1 then
						-- econ_on = 1
					-- end
				-- end
				-- if econ_on == 0 and B738DR_descent_mode == 1 then
					-- B738DR_descent_mode = 2
				-- end
			else
				line0_l = "      "
				--if simDR_vnav_tod_nm > 0 and simDR_vnav_tod_nm < 1000 and simDR_ground_spd > 70 then
				if B738DR_vnav_td_dist > 0 and B738DR_vnav_td_dist < 1000 then
					if time_td == 0 then
						-- if B738DR_rest_wpt_alt_idx == 0 then
							-- TOD_str = "   ----.- /---NM"
						-- else
							-- tmp_wpt_eta2 = math.floor(legs_data[B738DR_rest_wpt_alt_idx][13])
							-- tmp_wpt_eta3 = (legs_data[B738DR_rest_wpt_alt_idx][13] - tmp_wpt_eta2) * 60
							-- tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%04.1f", tmp_wpt_eta3)
							-- TOD_str = "   " .. tmp_wpt_eta
							-- TOD_str = TOD_str .. " /---NM"
						-- end
						-- line2_x = " TGT SPD        TO " .. B738DR_rest_wpt_alt_id
						TOD_str = "   ----.- /---NM"
						line2_x = " TGT SPD        TO "
					else
						tmp_wpt_eta2 = math.floor(time_td)
						tmp_wpt_eta3 = (time_td - tmp_wpt_eta2) * 60
						tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%04.1f", tmp_wpt_eta3)
						TOD_str = "   " .. tmp_wpt_eta .. " /"
						TOD_str = TOD_str .. string.format("%3d", dist_td)
						TOD_str = TOD_str .. "NM"
						line2_x = " TGT SPD          TO T/D"
					end
				-- if B738DR_vnav_td_dist > 0 and B738DR_vnav_td_dist < 1000 and simDR_ground_spd > 70 then
					-- time_TOD = B738DR_vnav_td_dist * 1852 / simDR_ground_spd
					-- time_TOD_h = math.floor((time_TOD / 3600))
					-- time_TOD = time_TOD - (time_TOD_h * 3600)
					-- time_TOD_m = math.floor((time_TOD / 60))
					-- time_TOD = time_TOD - (time_TOD_m * 60)
					-- time_TOD_s = math.floor(time_TOD)
					-- time_TOD_s = simDR_zulu_seconds + time_TOD_s
					-- if time_TOD_s > 59 then
						-- time_TOD_s = time_TOD_s - 60
						-- time_TOD_m = time_TOD_m + 1
					-- end
					-- time_TOD_m = time_TOD_m + simDR_zulu_minutes
					-- if time_TOD_m > 59 then
						-- time_TOD_m = time_TOD_m - 60
						-- time_TOD_h = time_TOD_h + 1
					-- end
					-- time_TOD_h = time_TOD_h + simDR_zulu_hours
					-- if time_TOD_h > 23 then
						-- time_TOD_h = time_TOD_h - 24
					-- end
					-- TOD_str = "   " .. string.format("%02d", time_TOD_h)
					-- TOD_str = TOD_str .. string.format("%02d", time_TOD_m)
					-- TOD_str = TOD_str .. "." 
					-- TOD_str = TOD_str .. string.sub(string.format("%02d", time_TOD_s), 1, 1)
					-- TOD_str = TOD_str .. " /"
					-- TOD_str = TOD_str .. string.format("%3d", B738DR_vnav_td_dist)
					-- TOD_str = TOD_str .. "NM"
					-- line2_x = " TGT SPD          TO T/D"
				else
					TOD_str = "   ----.- /---NM"
					line2_x = " TGT SPD        TO "
					-- if B738DR_rest_wpt_alt_idx == 0 then
						-- TOD_str = "   ----.- /---NM"
					-- else
						-- tmp_wpt_eta2 = math.floor(legs_data[B738DR_rest_wpt_alt_idx][13])
						-- tmp_wpt_eta3 = (legs_data[B738DR_rest_wpt_alt_idx][13] - tmp_wpt_eta2) * 60
						-- tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%04.1f", tmp_wpt_eta3)
						-- TOD_str = "   " .. tmp_wpt_eta
						-- TOD_str = TOD_str .. " /---NM"
					-- end
					-- line2_x = " TGT SPD        TO " .. B738DR_rest_wpt_alt_id
				end
			end
			if B738DR_descent_mode == 0 then
				line0_l = line0_l .. "ECON PATH DES      "
			elseif B738DR_descent_mode == 1 then
				line0_l = line0_l .. "ECON SPD DES       "
			elseif B738DR_descent_mode == 2 then
				if B738DR_flight_phase ~= 5 then
					if simDR_airspeed_is_mach == 0 then
						ap_mcp_spd = B738DR_fmc_descent_speed
					end
				end
				if simDR_airspeed_is_mach == 0 then
					line0_l = line0_l .. string.format("%3d", ap_mcp_spd)
					line0_l = line0_l .. "KT SPD DES     "
				else
					line0_l = line0_l .. "M."
					line0_l = line0_l .. string.format("%3d", (B738DR_fmc_descent_speed_mach * 1000))
					line0_l = line0_l .. " SPD DES     "
				end
			end
		-- line0_l = "     ECON SPD DES       "
		-- line0_l = "     XXXKT PATH DES     "
		-- line0_l = "     M.XXX SPD DES      "
		line0_s = "                    1/1 "
		str_rest_alt = ""
		line1_s = ""
		if B738DR_rest_wpt_alt > 0 and B738DR_flight_phase > 4 then
			line1_x = " E/D ALT        AT " .. B738DR_rest_wpt_alt_id
			--line1_l = "2013           230/6000A"
			if B738DR_rest_wpt_alt_idx > 0 then
				if legs_data[B738DR_rest_wpt_alt_idx][4] == 0 then
					if legs_data[B738DR_rest_wpt_alt_idx][10] == 0 then
						str_rest_alt = "            "
						line1_s = "              ---"
					else
						str_rest_alt = "            "
						line1_s = "              " ..  string.format("%3d",legs_data[B738DR_rest_wpt_alt_idx][10])
					end
				else
					str_rest_alt = "         " .. string.format("%3d", legs_data[B738DR_rest_wpt_alt_idx][4])
					line1_s = ""
				end
			else
				str_rest_alt = "            "
				line1_s = ""
			end
			str_rest_alt = str_rest_alt .. " "
			if B738DR_rest_wpt_alt > B738DR_trans_lvl then
				str_rest_alt = str_rest_alt .. "FL"
				str_rest_alt = str_rest_alt .. string.sub(string.format("%05d", B738DR_rest_wpt_alt), 1, 3)
			else
				str_rest_alt = str_rest_alt .. string.format("%5d", B738DR_rest_wpt_alt)
			end
			if B738DR_rest_wpt_alt_t == 43 then
				str_rest_alt = str_rest_alt .. "A"
			elseif B738DR_rest_wpt_alt_t == 45 then
				str_rest_alt = str_rest_alt .. "B"
			end
		else
			line1_x = " E/D ALT"
		end
		if ed_alt > 0 then
			if str_rest_alt == "" then
				line1_m = ""
				line1_l = string.format("%5d", ed_alt)
			else
				line1_m = "     " .. str_rest_alt
				line1_l = string.format("%5d", ed_alt) .. "            /"
			end
		else
			if str_rest_alt == "" then
				line1_m = ""
				line1_l = ""
			else
				line1_m = "     " .. str_rest_alt
				line1_l = "                 /"
			end
			--line1_l = "     " .. str_rest_alt
		end
		
		
		--		line2_x = " TGT SPD        TO -----"
--		line2_l = "280/.720   2004.5 / 15NM"
		if B738DR_flight_phase == 5 and B738DR_autopilot_vnav_status == 1 then
			if B738DR_ap_spd_interv_status == 0 then
				ap_mcp_spd = tonumber(string.format("%3d", simDR_airspeed_dial))
				temp_speed = tonumber(string.format("%3d", B738DR_fmc_descent_speed))
				if simDR_airspeed_is_mach == 0 then
					if ap_mcp_spd == temp_speed then
						line2_m = string.format("%3d", B738DR_fmc_descent_speed)
						line2_l = "   /" .. string.sub(string.format("%5.3f", B738DR_fmc_descent_speed_mach), 2, 5)
					else
						line2_l = string.format("%3d", B738DR_fmc_descent_speed) .. "/"
						line2_l = line2_l .. string.sub(string.format("%5.3f", B738DR_fmc_descent_speed_mach), 2, 5)
						line2_m = ""
					end
				else
					line2_l = string.format("%3d", B738DR_fmc_descent_speed) .. "/    "
					line2_m = "    " .. string.sub(string.format("%5.3f", B738DR_fmc_descent_speed_mach), 2, 5)
				end
			else
				if simDR_airspeed_is_mach == 0 then
					line2_m = string.format("%3d", B738DR_mcp_speed_dial)	--simDR_airspeed_dial)
					line2_l = "   /MCP "
				else
					line2_m = string.sub(string.format("%5.3f", B738DR_mcp_speed_dial), 2, 5)	--simDR_airspeed_dial), 2, 5)
					line2_l = "   /MCP "
				end
			end
			if B738DR_rest_wpt_alt_dist > 0 then
				tmp_wpt_eta2 = math.floor(legs_data[B738DR_rest_wpt_alt_idx][13])
				tmp_wpt_eta3 = (legs_data[B738DR_rest_wpt_alt_idx][13] - tmp_wpt_eta2) * 60
				tmp_wpt_eta = "   " .. string.format("%02d", tmp_wpt_eta2)
				tmp_wpt_eta = tmp_wpt_eta .. string.format("%02d", tmp_wpt_eta3)
				tmp_wpt_eta = tmp_wpt_eta .. ".0 /"
				TOD_str = tmp_wpt_eta
				--TOD_str = "   ----.- /"
				TOD_str = TOD_str .. string.format("%3d", B738DR_rest_wpt_alt_dist)
				TOD_str = TOD_str .. "NM"
			end
		else
			line2_l = string.format("%3d", B738DR_fmc_descent_speed) .. "/"
			line2_l = line2_l .. string.sub(string.format("%5.3f", B738DR_fmc_descent_speed_mach), 2, 5)
			line2_m = ""
		end
		line2_l = line2_l .. TOD_str	--"   ----.- /---NM"
		
		
		line2_s = "                 Z      "
		line3_x = " SPD REST        WPT/ALT"
		str_rest_alt = "-----/-----"
		if B738DR_flight_phase == 5 and B738DR_autopilot_vnav_status == 1 then
			if B738DR_rest_wpt_alt > 0 then
				str_rest_alt = B738DR_rest_wpt_alt_id .. "/"
				if legs_data[B738DR_rest_wpt_alt_idx][11] == 0 then
					str_rest_alt = str_rest_alt .. "-----"
				else
					if B738DR_rest_wpt_alt > B738DR_trans_lvl then
						str_rest_alt = str_rest_alt .. "FL"
						str_rest_alt = str_rest_alt .. string.sub(string.format("%05d", legs_data[B738DR_rest_wpt_alt_idx][11]), 1, 3)
					else
						str_rest_alt = str_rest_alt .. string.format("%5d", legs_data[B738DR_rest_wpt_alt_idx][11])
					end
				end
			end
			if B738DR_ap_spd_interv_status == 0 then
				ap_mcp_spd = tonumber(string.format("%3d", simDR_airspeed_dial))
				if simDR_airspeed_dial < B738DR_fmc_descent_speed then
					temp_speed = tonumber(string.format("%3d", flaps_speed))
					temp_speed2 = tonumber(string.format("%3d", B738DR_rest_wpt_spd))
					if ap_mcp_spd == temp_speed then
						line3_l = "   /FLAPS"
						line3_l = line3_l .. "    "
						line3_l = line3_l .. str_rest_alt
						line3_m = string.format("%3d", flaps_speed)
					elseif B738DR_rest_wpt_spd > 0 and ap_mcp_spd == temp_speed2 then
						line3_l = "   /" .. B738DR_rest_wpt_spd_id
						line3_l = line3_l .. "    "
						line3_l = line3_l .. str_rest_alt
						line3_m = string.format("%3d", B738DR_rest_wpt_spd)
					elseif ap_mcp_spd == 240 and simDR_altitude_pilot < 10700 then
						line3_l = "   /10000    " .. str_rest_alt
						line3_m = "250"
					else
						line3_l = "250/10000    " .. str_rest_alt
						line3_m = ""
					end
					-- if ap_mcp_spd == 250 and simDR_altitude_pilot < 10700 then
						-- line3_l = "   /10000    " .. str_rest_alt -----/-----"
						-- line3_inv = "250"
					-- else
						-- if simDR_gps_nav_id == nil then
							-- nav_id = ""
							-- line3_l = "250/10000    " .. str_rest_alt -----/-----"
							-- line3_inv = ""
						-- else
							-- nav_id = simDR_gps_nav_id
							-- if string.len(nav_id) > 5 then
								-- nav_id = string.sub(nav_id, 1, 5)
							-- end
							-- line3_inv = string.format("%3d", ap_mcp_spd)
							-- line3_l = "   /" .. nav_id
							-- line3_l = line3_l .. "    " .. str_rest_alt -----/-----"
						-- end
					-- end
				else
					line3_l = "250/10000    " .. str_rest_alt
					line3_m = ""
				end
			else
				line3_l = "---/-----    " .. str_rest_alt
				line3_m = ""
			end
		else
			line3_l = "---/-----    -----/-----"
			line3_m = ""
		end
		line3_s = "                        "
		--if B738DR_flight_phase == 5 and simDR_vnav_status == 1 and B738DR_fms_descent_now == 3 then
		-- if B738DR_flight_phase == 5 and B738DR_autopilot_vnav_status == 1 and B738DR_fms_descent_now >= 3 
		-- and simDR_vnav_eod_alt > 0 then		--4
		if B738DR_nd_vert_path == 1 then
			line4_x = " VERT DEV   FPA V/B  V/S"
			--vpa = B738DR_vnav_err_pfd
			vpa = -B738DR_vnav_err_pfd
			if vpa < 0 then
				vpa = -vpa
				line4_s = "     LO"
			else
				line4_s = "     HI"
			end
			if vpa > 9999 then
				vpa = 9999
			end
			line4_l = string.format("%4d", vpa) .. "        "
			vpa = (simDR_vvi_fpm_pilot / 60) * 0.3048
			vpa = vpa / simDR_ground_spd
			vpa = -vpa
			if vpa < 0 then
				vpa = 0
			end
			vpa = math.atan(vpa)
			vpa = math.deg(vpa)
			--DR_test = vpa
			line4_l = line4_l .. string.format("%3.1f", vpa)
			line4_l = line4_l .. " "
			vpa = econ_des_vpa
			--vpa = -vpa
			if vpa > 0 then
				line4_l = line4_l .. string.format("%3.1f", vpa)
			else
				line4_l = line4_l .. "   "
			end
			line4_l = line4_l .. " "
			v_s = simDR_vvi_fpm_pilot
			v_s = -v_s
			v_s = roundUpToIncrement(v_s, 10)
			if v_s > 0 then
				line4_l = line4_l .. string.format("%4d", v_s)
			else
				line4_l = line4_l .. "    "
			end
		else
			line4_x = "            FPA V/B  V/S"
			line4_l = "                        "
			line4_s = "                        "
		end
		line5_x = "------------------------"
		if B738DR_flight_phase == 5 then
			line5_l = "                   PATH>"
			line6_l = "<FORECAST           RTA>"
			line6_inv = ""
		else
			line5_l = "<ECON              PATH>"
			if des_now_enable == 1 then
				if B738DR_fms_descent_now == 0 then
					line6_l = "<FORECAST       DES NOW>"
					line6_inv = ""
				else
					line6_l = "<FORECAST              >"
					line6_inv = "                DES.NOW"
				end
			else
				line6_l = "<FORECAST "
			end
		end
--		line5_l = "<ECON              PATH>"
		line5_s = "                        "
		line6_x = "                        "
--		line6_l = "<FORECAST       DES NOW>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
--		line2_inv = ""
--		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
--		line6_inv = ""
	end

end

function B738_fmc_descent_forecast()

	if page_descent_forecast == 1 then
		act_page = 1
		max_page = 1
		line0_l = "  MOD DES FORECASTS     "
		line0_s = "                    1/1 "
		line1_x = " TRANS LVL    TAI ON/OFF"
		--line1_l = "FL180        -----/-----"
		if trans_lvl == "-----" then
			line1_l = "FL" .. string.format("%03d", (B738DR_trans_alt/100))
		else
			line1_l = trans_lvl
		end
		line1_l = line1_l .. "        "
		line1_l = line1_l .. tai_on_alt
		line1_l = line1_l .. "/"
		line1_l = line1_l .. tai_off_alt
		line1_s = "                        "
		line2_x = " CABIN RATE  ISA DEV/QNH"
--		line2_l = "---         ---` /------"
		line2_l = cabin_rate .. "         "
		line2_l = line2_l .. forec_isa_dev
		line2_l = line2_l .. "` /"
		line2_l = line2_l .. forec_qnh
		line2_s = "   FPM          C       "
		line3_x = " ALT-----WIND----DIR/SPD"
--		line3_l = "-----         ---`/---  "
		line3_l = forec_alt_1 .. "         "
		line3_l = line3_l .. forec_dir_1
		line3_l = line3_l .. "`/"
		line3_l = line3_l .. forec_spd_1
		line3_s = "                      KT"
		line4_x = "                        "
--		line4_l = "-----         ---`/---  "
		line4_l = forec_alt_2 .. "         "
		line4_l = line4_l .. forec_dir_2
		line4_l = line4_l .. "`/"
		line4_l = line4_l .. forec_spd_2
		line4_s = "                      KT"
		line5_x = "                        "
--		line5_l = "-----         ---`/---  "
		line5_l = forec_alt_3 .. "         "
		line5_l = line5_l .. forec_dir_3
		line5_l = line5_l .. "`/"
		line5_l = line5_l .. forec_spd_3
		line5_s = "                      KT"
		line6_x = "              ----------"
		line6_l = "                  ERASE>"
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end

function B738_fmc_progress()

	local prev_idx = 0
	local temp_str = ""
	local tmp_wpt_eta = ""
	local tmp_wpt_eta2 = 0
	local tmp_wpt_eta3 = 0
	local temp_num = 0
	local temp_num2 = 0
	
	if page_progress == 1 then
		act_page = 1
		max_page = 2
		if flt_num == "--------" then
			temp_str = "        "
		else
			temp_str = spaces_before(flt_num, 8)
			-- temp_str = flt_num
			-- temp_num2 = string.len(temp_str)
			-- if temp_num2 < 8 then
				-- for temp_num = temp_num2, 7 do
					-- temp_str = " " .. temp_str
				-- end
			-- end
		end
		
		
		line0_l = "  " .. temp_str .. " PROGRESS     "
		--line0_l = "    FLT430 PROGRESS     "
		line0_s = "                    1/2 "
		
		line1_x = " FROM     ALT  ATA  FUEL"
		--line1_l = "CYN     FL186 1349  35.2"
		--line1_s = "                  Z     "
		if offset > 1 then
			--PREV WAYPOINT
			-- nav id
			if offset > legs_num then
				offset = legs_num
			end
			prev_idx = offset - 1
			
			line1_l = spaces_after(legs_data[prev_idx][1], 7)
			
			-- line1_l = legs_data[prev_idx][1]
			
			-- if string.len(line1_l) > 7 then
				-- line1_l = string.sub(line1_l, 1, 7)
			-- end
			-- if string.len(line1_l) == 3 then
				-- temp_str = "     "
			-- elseif string.len(line1_l) == 4 then
				-- temp_str = "    "
			-- elseif string.len(line1_l) == 5 then
				-- temp_str = "   "
			-- elseif string.len(line1_l) == 6 then
				-- temp_str = "  "
			-- else
				-- temp_str = " "
			-- end
			-- line1_l = line1_l .. temp_str
			
			-- calc alt
			if legs_data[prev_idx][11] == 0 then
				line1_l = line1_l .. "      "
			else
				if legs_data[prev_idx][11] > B738DR_trans_alt then
					line1_l = line1_l .. "FL"
					line1_l = line1_l .. string.format("%03d", (legs_data[prev_idx][11]/100))
				else
					line1_l = line1_l .. string.format("%5d", legs_data[prev_idx][11])
				end
				line1_l = line1_l .. " "
			end
			-- calc time
			if legs_data[prev_idx][13] == 0 then
				tmp_wpt_eta = "    "
				line1_s = ""
			else
				tmp_wpt_eta2 = math.floor(legs_data[prev_idx][13])
				tmp_wpt_eta3 = (legs_data[prev_idx][13] - tmp_wpt_eta2) * 60
				tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%02d", tmp_wpt_eta3)
				line1_s = "                  Z     "
			end
			line1_l = line1_l .. tmp_wpt_eta
			-- fuel qty
			line1_l = line1_l .. "  "
			if legs_data[prev_idx][15] == 0 then
				tmp_wpt_eta = "--.-"
			else
				if units == 0 then
					tmp_wpt_eta = string.format("%4.1f", (legs_data[prev_idx][15] / 1000) * 2.204)
				else
					tmp_wpt_eta = string.format("%4.1f", (legs_data[prev_idx][15] / 1000))
				end
			end
			line1_l = line1_l .. tmp_wpt_eta
			--line1_l = line1_l .. "  --.-"
			
			-- ACTUAL WAYPOINT
			-- nav id
			--line2_x = " 249`     DTG  ETA  FUEL"
			line2_x = " " .. string.format("%03d", simDR_fmc_crs)
			line2_x = line2_x .. "`     DTG  ETA  FUEL"
			
			line2_l = spaces_after(legs_data[offset][1], 8)
			
			-- line2_l = legs_data[offset][1]
			-- if string.len(line2_l) > 7 then
				-- line2_l = string.sub(line2_l, 1, 7)
			-- end
			-- if string.len(line2_l) == 3 then
				-- temp_str = "     "
			-- elseif string.len(line2_l) == 4 then
				-- temp_str = "    "
			-- elseif string.len(line2_l) == 5 then
				-- temp_str = "   "
			-- elseif string.len(line2_l) == 6 then
				-- temp_str = "  "
			-- else
				-- temp_str = " "
			-- end
			
			-- if string.len(line2_l) == 3 then
				-- temp_str = "      "
			-- elseif string.len(line2_l) == 4 then
				-- temp_str = "     "
			-- else
				-- temp_str = "    "
			-- end
			--line2_l = line2_l .. temp_str
			
			-- distance
			if simDR_fmc_dist > 9999 then
				line2_l = line2_l .. "9999"
			else
				line2_l = line2_l .. string.format("%4d", simDR_fmc_dist)
			end
			line2_l = line2_l .. " "
			-- calc time
			if legs_data[offset][13] == 0 then
				tmp_wpt_eta = "    "
				line2_s = ""
			else
				tmp_wpt_eta2 = math.floor(legs_data[offset][13])
				tmp_wpt_eta3 = (legs_data[offset][13] - tmp_wpt_eta2) * 60
				tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%02d", tmp_wpt_eta3)
				line2_s = "                  Z     "
			end
			line2_l = line2_l .. tmp_wpt_eta
			-- fuel qty
			line2_l = line2_l .. "  --.-"
			
			-- NEXT WAYPOINT
			prev_idx = offset + 1
			if prev_idx <= legs_num then
				--line3_x = " 252`                   "
				--line3_l = "GVE       192 1411  31.1"
				-- nav id
				tmp_wpt_eta2 = (math.deg(legs_data[prev_idx][2]) + simDR_mag_variation) % 360
				if tmp_wpt_eta2 < 0 then
					tmp_wpt_eta2 = tmp_wpt_eta2 + 360
				end
				line3_x = " " .. string.format("%03d", tmp_wpt_eta2) .. "`"
				
				line3_l = spaces_after(legs_data[prev_idx][1], 8)
				
				-- line3_l = legs_data[prev_idx][1]
				-- if string.len(line3_l) == 3 then
					-- temp_str = "      "
				-- elseif string.len(line3_l) == 4 then
					-- temp_str = "     "
				-- else
					-- temp_str = "    "
				-- end
				-- line3_l = line3_l .. temp_str
				
				-- distance
				if legs_data[prev_idx][3] > 9999 then
					line3_l = line3_l .. "9999"
				else
					line3_l = line3_l .. string.format("%4d", legs_data[prev_idx][3])
				end
				line3_l = line3_l .. " "
				-- calc time
				if legs_data[prev_idx][13] == 0 then
					tmp_wpt_eta = "    "
					line3_s = ""
				else
					tmp_wpt_eta2 = math.floor(legs_data[prev_idx][13])
					tmp_wpt_eta3 = (legs_data[prev_idx][13] - tmp_wpt_eta2) * 60
					tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%02d", tmp_wpt_eta3)
					line3_s = "                  Z     "
				end
				line3_l = line3_l .. tmp_wpt_eta
				-- fuel qty
				line3_l = line3_l .. "  --.-"
			else
				line3_x = ""
				line3_l = ""
				line3_s = ""
			end
			
			-- DEST ICAO
			if des_icao ~= "****" then
				prev_idx = legs_num + 1
				if B738DR_fms_exec_light_pilot == 0 then
					line4_x = ""
				else
					line4_x = " MOD"
				end
				-- nav id
				line4_l = legs_data[prev_idx][1]
				if string.len(line4_l) == 3 then
					temp_str = "      "
				elseif string.len(line4_l) == 4 then
					temp_str = "     "
				else
					temp_str = "    "
				end
				line4_l = line4_l .. temp_str
				-- distance
				if dist_dest > 10000 then
					line4_l = line4_l .. "9999"
				else
					line4_l = line4_l .. string.format("%4d", dist_dest)
				end
				line4_l = line4_l .. " "
				-- calc time
				if legs_data[prev_idx][13] == 0 then
					tmp_wpt_eta = "    "
					line4_s = ""
				else
					tmp_wpt_eta2 = math.floor(legs_data[prev_idx][13])
					tmp_wpt_eta3 = (legs_data[prev_idx][13] - tmp_wpt_eta2) * 60
					tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%02d", tmp_wpt_eta3)
					line4_s = "                  Z     "
				end
				line4_l = line4_l .. tmp_wpt_eta
				-- fuel qty
				line4_l = line4_l .. "  --.-"
			else
				line4_x = ""
				line4_l = ""
				line4_s = ""
			end
			
			if crz_alt_num > 0 and legs_num > 0 and offset > 0 and cost_index ~= "***" and ref_icao ~= "----" and des_icao ~= "****" then
				if B738DR_flight_phase < 2 and dist_tc > 0 then
					line5_x = " TO T/C         FUEL QTY"
					tmp_wpt_eta2 = math.floor(time_tc)
					tmp_wpt_eta3 = (time_tc - tmp_wpt_eta2) * 60
					tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%02d", tmp_wpt_eta3)
					line5_l = tmp_wpt_eta .. " /"
					line5_l = line5_l .. string.format("%4d", dist_tc)
					line5_l = line5_l .. "          --.-"
					--line5_l = "1355 / 32           --.-"
					line5_s = "    Z     NM            "
				elseif B738DR_flight_phase < 5 then
					if B738DR_vnav_td_dist > 0 then
						line5_x = " TO T/D         FUEL QTY"
						tmp_wpt_eta2 = math.floor(time_td)
						tmp_wpt_eta3 = (time_td - tmp_wpt_eta2) * 60
						tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%02d", tmp_wpt_eta3)
						line5_l = tmp_wpt_eta .. " /"
						line5_l = line5_l .. string.format("%4d", dist_td)
						line5_l = line5_l .. "          --.-"
						--line5_l = "1355 / 32           --.-"
						line5_s = "    Z     NM            "
					else
						line5_x = ""
						line5_l = ""
						line5_s = ""
					end
				else
					if offset <= ed_found then
						line5_x = " TO E/D         FUEL QTY"
						tmp_wpt_eta2 = math.floor(time_ed)
						tmp_wpt_eta3 = (time_ed - tmp_wpt_eta2) * 60
						tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. string.format("%02d", tmp_wpt_eta3)
						line5_l = tmp_wpt_eta .. " /"
						line5_l = line5_l .. string.format("%4d", dist_ed)
						line5_l = line5_l .. "          --.-"
						--line5_l = "1355 / 32           --.-"
						line5_s = "    Z     NM            "
					else
						line5_x = ""
						line5_l = ""
						line5_s = ""
					end
				end
			else
				line5_x = ""
				line5_l = ""
				line5_s = ""
			end
			
		else
			line1_l = ""
			line1_s = ""
			line2_l = ""
			line2_s = ""
			line2_x = "          DTG  ETA  FUEL"
			line3_x = ""
			line3_l = ""
			line3_s = ""
			line4_l = ""
			line4_s = ""
			line4_x = ""
			line5_x = ""
			line5_l = ""
			line5_s = ""
		end
		
		-- WIND
		if simDR_wind_spd > 0.5 then
			line6_x = " WIND                   "
			line6_l = string.format("%03d", simDR_wind_hdg) .. "`/"
			line6_l = line6_l .. string.format("%3d", simDR_wind_spd)
			line6_s = "        KT              "
		else
			line6_l = "        "
			line6_x = ""
			line6_s = ""
		end
		line6_l = line6_l .. "     NAV STATUS>"
		
		--line2_x = " 249`     DTG  ETA  FUEL"
		--line2_l = "ENO        61 1355  32.9"
		--line2_s = "                  Z     "
		--line3_x = " 252`                   "
		--line3_l = "GVE       192 1411  31.1"
		--line3_s = "                  Z     "
		--line4_x = " MOD                    "
		--line4_l = "KATL      606 1510  17.6"
		--line4_s = "                  Z     "
		--line5_x = " TO T/C         FUEL QTY"
		--line5_l = "1355 / 32           34.0"
		--line5_s = "    Z    NM             "
		--line6_x = " WIND                   "
		--line6_l = "080`/ 23     NAV STATUS>"
		--line6_s = "        KT              "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	elseif page_progress == 2 then
		act_page = 2
		max_page = 2
		if flt_num == "--------" then
			temp_str = "        "
		else
			temp_str = spaces_before(flt_num, 8)
			-- temp_str = flt_num
			-- temp_num2 = string.len(temp_str)
			-- if temp_num2 < 8 then
				-- for temp_num = temp_num2, 7 do
					-- temp_str = " " .. temp_str
				-- end
			-- end
		end
		line0_l = "  " .. temp_str .. " PROGRESS     "
		line0_s = "                    2/2 "
		
		--line1_x = " TAILWIND      CROSSWIND"
		--line1_l = "27      L         R  3  "
		if head_wind < 0 then
			-- tailwind
			temp_num = -head_wind
			line1_x = " HEADWIND      CROSSWIND"
			line1_l = string.format("%3d", temp_num)
		else
			-- headwind
			line1_x = " TAILWIND      CROSSWIND"
			line1_l = string.format("%3d", head_wind)
		end
		line1_l = line1_l .. "               "
		if cross_wind < 0 then
			temp_num = -cross_wind
			line1_l = line1_l .. "R"
			line1_l = line1_l .. string.format("%3d", temp_num)
		else
			line1_l = line1_l .. "L"
			line1_l = line1_l .. string.format("%3d", cross_wind)
		end
		line1_s = "   KT                 KT"
		
		-- wind
		line2_x = " WIND        SAT/ISA DEV"
		if simDR_wind_spd > 0.5 then
			line2_l = string.format("%03d", simDR_wind_hdg) .. "`/"
			line2_l = line2_l .. string.format("%3d", simDR_wind_spd)
		else
			line2_l = "        "
		end
		line2_l = line2_l .. "     "
		line2_l = line2_l .. "-40` /  0` "
		--line2_l = "104`/ 27     -40` /  0` "
		line2_s = "                 C     C"
		
		line3_x = " XTK ERROR      VERT DEV"
		--line3_l = "                  8812  "
		--line3_s = "                      HI"
		line3_l = "                  "
		line3_s = ""
		if B738DR_nd_vert_path == 1 then
			temp_num = -B738DR_vnav_err_pfd
			--vpa = -B738DR_vnav_err_pfd
			if temp_num < 0 then
				temp_num = -temp_num
				line3_s = "                      LO"
			else
				line3_s = "                      HI"
			end
			if temp_num > 9999 then
				temp_num = 9999
			end
			line3_l = line3_l .. string.format("%4d", temp_num)
		end
		
		line4_x = " GPS-L TRK           TAS"
		--line4_l = "305`T              426  "
		line4_l = "---`T              "
		if simDR_TAS < 52 then
			line4_l = line4_l .. "---"
		else
			temp_num = 1.943844 * simDR_TAS
			line4_l = line4_l .. string.format("%3d", temp_num)
		end
		line4_s = "                      KT"
		
		line5_x = "                        "
		line5_l = "                        "
		line5_s = "                        "
		line6_x = "                        "
		line6_l = "                        "
		line6_s = "                        "
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	end

end


function B738_fmc_clr_page()

	if page_clear == 1 then
		act_page = 1
		max_page = 1
		-- line0_l = ""
		-- line0_s = ""
		-- line1_x = ""
		-- line1_l = ""
		-- line1_s = ""
		-- line2_x = ""
		-- line2_l = ""
		-- line2_s = ""
		-- line3_x = ""
		-- line3_l = ""
		-- line3_s = "...STILL IN PROGRESS... "
		-- line4_x = ""
		-- line4_l = ""
		-- line4_s = ""
		-- line5_x = ""
		-- line5_l = "    USE DEFAULT FMC     "
		-- line5_s = ""
		-- line6_x = ""
		-- line6_l = ""
		-- line6_s = ""
		-- line0_inv = ""
		-- line1_inv = ""
		-- line2_inv = ""
		-- line3_inv = ""
		-- line4_inv = ""
		-- line5_inv = ""
		-- line6_inv = ""
		B7368DR_fmc1_show = 0
	else
		B7368DR_fmc1_show = 1
	end

end

function B738_fmc_display()

	if display_update == 1 then
		--display_update = 0

		B738DR_fmc1_Line00_L = line0_l
		B738DR_fmc1_Line01_L = line1_l
		B738DR_fmc1_Line02_L = line2_l
		B738DR_fmc1_Line03_L = line3_l
		B738DR_fmc1_Line04_L = line4_l
		B738DR_fmc1_Line05_L = line5_l
		B738DR_fmc1_Line06_L = line6_l

		B738DR_fmc1_Line00_S = line0_s
		B738DR_fmc1_Line01_S = line1_s
		B738DR_fmc1_Line02_S = line2_s
		B738DR_fmc1_Line03_S = line3_s
		B738DR_fmc1_Line04_S = line4_s
		B738DR_fmc1_Line05_S = line5_s
		B738DR_fmc1_Line06_S = line6_s

		B738DR_fmc1_Line01_X = line1_x
		B738DR_fmc1_Line02_X = line2_x
		B738DR_fmc1_Line03_X = line3_x
		B738DR_fmc1_Line04_X = line4_x
		B738DR_fmc1_Line05_X = line5_x
		B738DR_fmc1_Line06_X = line6_x
		
		B738DR_fmc1_Line00_M = line0_m
		B738DR_fmc1_Line01_M = line1_m
		B738DR_fmc1_Line02_M = line2_m
		B738DR_fmc1_Line03_M = line3_m
		B738DR_fmc1_Line04_M = line4_m
		B738DR_fmc1_Line05_M = line5_m
		B738DR_fmc1_Line06_M = line6_m
		
		B738DR_fmc1_Line00_G = line0_g
		B738DR_fmc1_Line01_G = line1_g
		B738DR_fmc1_Line02_G = line2_g
		B738DR_fmc1_Line03_G = line3_g
		B738DR_fmc1_Line04_G = line4_g
		B738DR_fmc1_Line05_G = line5_g
		B738DR_fmc1_Line06_G = line6_g
		
		B738DR_fmc1_Line00_I = line0_inv
		B738DR_fmc1_Line01_I = line1_inv
		B738DR_fmc1_Line02_I = line2_inv
		B738DR_fmc1_Line03_I = line3_inv
		B738DR_fmc1_Line04_I = line4_inv
		B738DR_fmc1_Line05_I = line5_inv
		B738DR_fmc1_Line06_I = line6_inv
	
		if fmc_message_num ~= 0 then
			B738DR_fmc1_Line_entry = fmc_message[fmc_message_num]
			if fmc_message_num > 1 then
				if fmc_message[fmc_message_num] == fmc_message[fmc_message_num-1] then
					fmc_message_num = fmc_message_num - 1
				end
			end
		else
			if string.len(entry) > 1 then
					if string.sub(entry, 1, 1) == ">" then
						B738DR_fmc1_Line_entry = string.sub(entry, 2,-1)
					else
						B738DR_fmc1_Line_entry = entry
					end
			else
				B738DR_fmc1_Line_entry = entry
			end
		end

		line0_l = ""
		line0_s = ""
		line0_m = ""
		line0_g = ""
		line1_x = ""
		line1_l = ""
		line1_s = ""
		line1_m = ""
		line1_g = ""
		line2_x = ""
		line2_l = ""
		line2_s = ""
		line2_m = ""
		line2_g = ""
		line3_x = ""
		line3_l = ""
		line3_s = ""
		line3_m = ""
		line3_g = ""
		line4_x = ""
		line4_l = ""
		line4_s = ""
		line4_m = ""
		line4_g = ""
		line5_x = ""
		line5_l = ""
		line5_s = ""
		line5_m = ""
		line5_g = ""
		line6_x = ""
		line6_l = ""
		line6_s = ""
		line6_m = ""
		line6_g = ""
		line0_inv = ""
		line1_inv = ""
		line2_inv = ""
		line3_inv = ""
		line4_inv = ""
		line5_inv = ""
		line6_inv = ""
	
	end

end


function B738_calc()
	
	local v = 0
	local pos_min = ""
	local pos_deg = ""
	local weight_lbs = 0
	
	if units_recalc == 1 then
		if units == 0 then
			zfw = zfw_lbs
			plan_weight = plan_weight_lbs
			reserves = reserves_lbs
		else
			zfw = zfw_kgs
			plan_weight = plan_weight_kgs
			reserves = reserves_kgs
		end
	end
	units_recalc = 0
	
	if B738DR_fms_v1_calc == 0 then
		v1 = "---"
		vr = "---"
		v2 = "---"
	else
		v1 = string.format("%3d", B738DR_fms_v1_calc)
		vr = string.format("%3d", B738DR_fms_vr_calc)
		v2 = string.format("%3d", B738DR_fms_v2_calc)
	end

	vref_15 = string.format("%3d", B738DR_fms_vref_15)
	vref_30 = string.format("%3d", B738DR_fms_vref_30)
	vref_40 = string.format("%3d", B738DR_fms_vref_40)
	
	if B738DR_trim_calc == 0 then
		trim = "    "
	else
		trim = string.format("%4.2f", B738DR_trim_calc)
	end

	weight_lbs = (simDR_total_weight / 1000) * 2.204			-- 1000 lbs
	gw_act = string.format("%5.1f", weight_lbs)
	
	-- Fuel_weight
	weight_lbs = (simDR_fuel_weight / 1000) * 2.204			-- 1000 lbs
	fuel_weight_lbs = string.format("%4.1f", weight_lbs)
	fuel_weight_kgs = string.format("%4.1f", (tonumber(fuel_weight_lbs) / 2.204))
	if units == 0 then
		fuel_weight = fuel_weight_lbs
	else
		fuel_weight = fuel_weight_kgs
	end
	
	-- ZFC calc
	v = ((simDR_total_weight / 1000) - (simDR_fuel_weight / 1000)) * 2.204		-- 1000 lbs
	zfw_calc_lbs = string.format("%5.1f", v)
	zfw_calc_kgs = string.format("%5.1f", (tonumber(zfw_calc_lbs) / 2.204))
	if units == 0 then
		zfw_calc = zfw_calc_lbs
	else
		zfw_calc = zfw_calc_kgs
	end
	
	-- CALC GW
	v = tonumber(zfw_lbs)
	if v == nil then
		gw = "***.*"
		gw_lbs = gw
		gw_kgs = gw
		v = ((simDR_total_weight / 1000) - (simDR_fuel_weight / 1000)) * 2.204		-- 1000 lbs
		v = v + tonumber(fuel_weight_lbs)
		if units == 0 then
			gw_calc = string.format("%5.1f", v)
		else
			gw_calc = string.format("%5.1f", (v / 2.204))
		end
		
	else
		v = v + tonumber(fuel_weight_lbs)
		gw_lbs = string.format("%5.1f", v)
		gw_kgs = string.format("%5.1f", (tonumber(gw_lbs) / 2.204))
		if units == 0 then
			gw = gw_lbs
		else
			gw = gw_kgs
		end
		gw_calc = gw
	end
	
	-- SET V SPEEDS
	v = tonumber(flaps)
	if v == nil then
		B738DR_fms_takeoff_flaps = 0
	else
		B738DR_fms_takeoff_flaps = v
	end
	
--	v = tonumber(flaps_app)
	v = tonumber(app_flap)
	if v == nil then
		B738DR_fms_approach_flaps = 0
	else
		B738DR_fms_approach_flaps = v
	end
	v = tonumber(app_spd)
	if v == nil then
		B738DR_fms_approach_speed = 0
	else
		B738DR_fms_approach_speed = v
	end
	v = tonumber(wind_corr)
	if v == nil then
		B738DR_fms_approach_wind_corr = 5
	else
		B738DR_fms_approach_wind_corr = v
	end
	
	
	v = tonumber(v1_set)
	if v == nil then
		B738DR_fms_v1_set = 0
	else
		B738DR_fms_v1_set = v
	end
	v = tonumber(vr_set)
	if v == nil then
		B738DR_fms_vr_set = 0
	else
		B738DR_fms_vr_set = v
	end
	v = tonumber(v2_set)
	if v == nil then
		B738DR_fms_v2_set = 0
	else
		B738DR_fms_v2_set = v
	end
	
	-- V Speed calculate enable
	if gw_lbs == "***.*" then
		vref_15 = "---"
		vref_30 = "---"
		vref_40 = "---"
		v1 = "---"
		vr = "---"
		v2 = "---"
		trim = "    "
		flaps_app = "  "
	else
		if flaps == "**" then
			B738DR_calc_spd_enable = 0
			v1 = "---"
			vr = "---"
			v2 = "---"
			trim = "    "
		end
		B738DR_calc_spd_enable = 1
		v = tonumber(gw_lbs)
		if v == nil then
			B738DR_fmc_gw = 0
		else
			B738DR_fmc_gw = v	-- GW lbs
		end
	end
	
	-- -- Pos entry to IRS
	-- if B738DR_irs_pos_set == "*****.*******.*" then
		-- B738DR_irs_pos_fmc = 0
	-- else
		-- B738DR_irs_pos_fmc = 1
	-- end
	
	-- CG
	v = tonumber(cg)
	if v == nil then
		B738DR_fmc_cg = 0
		trim = "    "
	else
		B738DR_fmc_cg = v	-- CG %MAC
	end
	
	
	-- RWY wind, slope, hdg
	v = tonumber(rw_wind_dir)
	if v == nil then
		B738DR_rw_wind_dir = -1
	else
		B738DR_rw_wind_dir = v
	end
	v = tonumber(rw_wind_spd)
	if v == nil then
		B738DR_rw_wind_spd = -1
	else
		B738DR_rw_wind_spd = v
	end
	v = tonumber(string.sub(rw_slope, 2, -1))
	if v == nil then
		B738DR_rw_slope = 0
	else
		if string.sub(rw_slope, 1, 1) == "D" then
			v = -v
		end
		B738DR_rw_slope = v
	end
	v = tonumber(rw_hdg)
	if v == nil then
		B738DR_rw_hdg = -1
	else
		B738DR_rw_hdg = v
	end
	
	-- UNITS
	B738DR_fmc_units = units
	if units == 0 then
		weight_min = 90
		weight_max = 180
	else
		weight_min = 40
		weight_max = 90
	end
	
	-- ZULU TIME
	if simDR_gps_fail == 0 or simDR_gps2_fail == 0 then
		zulu_time = string.format("%02d", simDR_zulu_hours) .. string.format("%02d", simDR_zulu_minutes)
		zulu_time = zulu_time .. "."
		zulu_time = zulu_time .. string.sub(string.format("%02d", simDR_zulu_seconds), 1, 1)
		zulu_time = zulu_time .. "z "
		zulu_time = zulu_time .. string.format("%02d", simDR_time_month)
		zulu_time = zulu_time .. "/"
		zulu_time = zulu_time .. string.format("%02d", simDR_time_day)
	else
		zulu_time = "0000.0z      "
	end
	
	-- OAT
	local temp = simDR_OAT
	local temp_str = string.format("%4d", temp)
	if temp < 0 then
		oat_sim = temp_str
	else
		if temp < 10 then
			oat_sim = "  +" .. string.sub(temp_str, 4, 4)
		else
			oat_sim = " +" .. string.sub(temp_str, 3, 4)
		end
	end
	temp = (temp * 9 / 5) + 32
	oat_sim_f = string.format("%4d", temp)
	
	-- SEL TEMP
	v = tonumber(sel_temp)
	if v == nil then
		B738DR_fmc_sel_temp = 99	-- no entry
	else
		B738DR_fmc_sel_temp = v
	end
	
	-- OUT TEMP manually
	v = tonumber(oat)
	if v == nil then
		B738DR_fmc_oat_temp = 99	-- no entry
	else
		B738DR_fmc_oat_temp = v
	end
	
	-- Runway condition
	B738DR_fmc_rw_cond = rw_cond
	
	-- Transition altitude
	if trans_alt == "-----" then
		B738DR_trans_alt = 18000
	else
		B738DR_trans_alt = tonumber(trans_alt)
	end
	
	-- Transition level
	v = tonumber(string.sub(trans_lvl, 3, 5))
	if v == nil then
		B738DR_trans_lvl = B738DR_trans_alt
	else
		B738DR_trans_lvl = v * 100
	end
	
	-- Throttle reduction alt
	B738DR_thr_red_alt = clb_alt_num
	B738DR_accel_alt = accel_alt_num
	
	-- on ground / air
	if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 or simDR_on_ground_2 == 1 then
		if was_on_air == 1 then
			was_on_air = 0
			-- on the ground
			ground_air = 0
			--disable_POS_2L = 0
			--disable_POS_3L = 0
			--ref_icao = "----"
			--ref_gate = "-----"
		end
	end
	if simDR_radio_height_pilot_ft > 50 then
		if was_on_air == 0 then
			was_on_air = 1
			-- air
			ground_air = 1
			--ref_icao = "    "
			--ref_gate = "     "
			--disable_POS_2L = 1
			--disable_POS_3L = 1
		end
	end
	-- ISA DEV C
	if isa_dev_c ~= "---" then
		n = tonumber(isa_dev_c)
		if n == nil then
			B738DR_isa_dev_c = 10
		else
			B738DR_isa_dev_c = n
		end
	end

	
end


function latitude()

local lat = (math.abs(simDR_latitude))

local lat_deg = (math.floor(lat))

local lat_min_dec = (math.fmod(lat,1.0)*600)

local lat_min_dec2 = (string.format("%06.3f",lat_min_dec))

latitude_deg = lat_deg
latitude_min = lat_min_dec2

end


function longitude()

local lon = (math.abs(simDR_longitude))

local lon_deg = (math.floor(lon))

local lon_min_dec = (math.fmod(lon,1.0)*600)

local lon_min_dec2 = (string.format("%06.3f",lon_min_dec))

longitude_deg = lon_deg
longitude_min = lon_min_dec2


end


function B738_last_pos()

	-- Last Position
	
	local gps_irs_fail = 0
	if B738DR_gps_pos == "-----.-------.-" 
	and B738DR_gps2_pos == "-----.-------.-" 
	and B738DR_irs_pos =="-----.-------.-"
	and B738DR_irs2_pos == "-----.-------.-" then
		gps_irs_fail = 1
	end
	if last_pos_enable == 1 or gps_irs_fail == 0 then
		
		latitude()
		longitude()
		
		last_pos_enable = 0
		
		local position_min = ""
		local position_deg = ""
		local position = ""

		pos_deg = string.format("%02d", B738DR_latitude_deg)
		pos_min = string.format("%05.1f", B738DR_latitude_min)
		--if B738DR_latitude_deg < 0 then
		if B738DR_latitude_NS == 1 then
			position = ("S" .. pos_deg)
		else
			position = ("N" .. pos_deg)
		end
		position = position .. string.sub(pos_min, 1, 2)
		position = position .. "."
		position = position .. string.sub(pos_min, 3, 3)
		pos_deg = string.format("%03d", B738DR_longitude_deg)
		pos_min = string.format("%05.1f", B738DR_longitude_min)
		--if B738DR_longitude_deg < 0 then
		if B738DR_longitude_EW == 1 then
			position = (position .. "W")
		else
			position = (position .. "E")
		end
		position = position .. pos_deg
		position = position .. string.sub(pos_min, 1, 2)
		position = position .. "."
		position = position .. string.sub(pos_min, 3, 3)

		last_pos = position
	end
	

end

function airport_pos(airport_icao)

	local position_min = ""
	local position_deg = ""
	local position = ""
	local temp_deg = 0
	local temp_min = 0
	local airport_lat_deg = 0
	local airport_lat_min = 0
	local airport_lon_deg = 0
	local airport_lon_min = 0
	local airport_lat_ns = 0
	local airport_lon_ew = 0
	local temp_i = 0
	
	if ref_icao == "----" then
		ref_icao_pos = "               "
	else
		
		icao_latitude = 0
		icao_longitude = 0
		
		if apt_data_num > 0 then
		
			for temp_i = 1, apt_data_num do
				if ref_icao == apt_data[temp_i][1] then
					icao_latitude = apt_data[temp_i][2]
					icao_longitude = apt_data[temp_i][3]
					break
				end
			end
		
			local lat = (math.abs(icao_latitude))
			local lat_min_dec = (math.fmod(lat,1.0)*600)
			airport_lat_deg = (math.floor(lat))
			airport_lat_min = (string.format("%06.3f",lat_min_dec))
			airport_lat_ns = 0
			if icao_latitude < 0 then
				airport_lat_ns = 1
			end
			
			local lon = (math.abs(icao_longitude))
			local lon_min_dec = (math.fmod(lon,1.0)*600)
			airport_lon_deg = (math.floor(lon))
			airport_lon_min = (string.format("%06.3f",lon_min_dec))
			airport_lon_ew = 0
			if icao_longitude < 0 then
				airport_lon_ew = 1
			end
			
			
			
			temp_deg = string.format("%02d", airport_lat_deg)
			temp_min = string.format("%05.1f", airport_lat_min)
			if airport_lat_ns == 1 then
				position = ("S" .. temp_deg)
			else
				position = ("N" .. temp_deg)
			end
			position = position .. string.sub(temp_min, 1, 2)
			position = position .. "."
			position = position .. string.sub(temp_min, 3, 3)
			temp_deg = string.format("%03d", airport_lon_deg)
			temp_min = string.format("%05.1f", airport_lon_min)
			if airport_lon_ew == 1 then
				position = (position .. "W")
			else
				position = (position .. "E")
			end
			position = position .. temp_deg
			position = position .. string.sub(temp_min, 1, 2)
			position = position .. "."
			position = position .. string.sub(temp_min, 3, 3)
			
			ref_icao_pos = position
			
		else
			ref_icao_pos = "               "
		end
	end

end

function B738_irs_sys()

	-- if B738DR_irs_left == 0 and B738DR_irs_right == 0 then
		-- msg_irs_pos = 0
		-- msg_irs_hdg = 0
--		irs_hdg = "---`"
--		irs_pos = "*****.*******.*"
	-- end
	if B738DR_irs_left_mode == 0 and B738DR_irs_right_mode == 0 then
		msg_irs_pos = 0
		msg_irs_hdg = 0
		irs_hdg = "---`"
		irs_pos = "*****.*******.*"
	end
	
	B738DR_irs_pos_fmc_set = irs_pos
	B738DR_irs_hdg_fmc_set = string.sub(irs_hdg, 1, 3)
	
--	local gs = string.format("%3d", B738_rescale(0, 0, 205, 400, simDR_ground_speed))
	local gs = string.format("%3d", (simDR_ground_speed * 1.94384))
	if B738DR_irs_left_mode > 1 then
		irs_gs = gs
		fmc_pos = B738DR_irs_pos
	else
		irs_gs = "   "
	end
	if B738DR_irs_right_mode > 1 then
		irs2_gs = gs
		fmc_pos = B738DR_irs2_pos
	else
		irs2_gs = "   "
	end
	if B738DR_irs_left_mode > 1 or B738DR_irs_right_mode > 1 then
		fmc_gs = gs
		irs_pos = ""
	else
		fmc_gs = "   "
	end
	if simDR_gps_fail ~= 0 then
		fmc_pos = B738DR_gps_pos
	end
	if simDR_gps2_fail ~= 0 then
		fmc_pos = B738DR_gps2_pos
	end
	
	if B738DR_irs_pos ~= "-----.-------.-" then
		B738DR_irs1_restart = 0
	end
	if B738DR_irs2_pos ~= "-----.-------.-" then
		B738DR_irs2_restart = 0
	end
	if B738DR_irs1_restart == 0 and B738DR_irs2_restart == 0 then
		msg_irs_motion = 0
	end
	
	if B738DR_gps_pos ~= "-----.-------.-" then
		msg_gps_l_fail = 0
	end
	
	if B738DR_gps2_pos ~= "-----.-------.-" then
		msg_gps_r_fail = 0
	end
	
	if B738DR_gps_pos ~= "-----.-------.-" 
	and B738DR_gps2_pos ~= "-----.-------.-" then
		msg_gps_lr_fail = 0
	end

end


function B738_N1_sel_thr()

	if sel_temp == "----" then
		if to == "<ACT>" then	-- 26K
			B738DR_fms_N1_to_sel = 1
		elseif to_1 == "<ACT>" then		-- 24K
			B738DR_fms_N1_to_sel = 2
		elseif to_2 == "<ACT>" then		-- 22K
			B738DR_fms_N1_to_sel = 3
		end
	else
		if to == "<ACT>" then	-- RED 26K
			B738DR_fms_N1_to_sel = 4
		elseif to_1 == "<ACT>" then		-- RED 24K
			B738DR_fms_N1_to_sel = 5
		elseif to_2 == "<ACT>" then		-- RED 22K
			B738DR_fms_N1_to_sel = 6
		end
	end

end

function B738_N1_thrust_calc()

	fmc_full_thrust = B738DR_thr_takeoff_N1
	
	fmc_dto_thrust = B738DR_thr_takeoff_N1
	
	if sel_temp == "----" then
		fmc_sel_thrust = fmc_full_thrust
	else
		fmc_sel_thrust = fmc_dto_thrust
	end
	
	fmc_clb_thrust = B738DR_thr_climb_N1
	fmc_crz_thrust = B738DR_thr_cruise_N1
	fmc_con_thrust = 0.88
	fmc_ga_thrust = fmc_full_thrust

end


function on_ground_5sec()
	takeoff_enable = 1
end


-- function B738_flight_phase()

	-- local dlt_crz_alt = 0
	-- local des_active = 0
	
	-- -- flight phase TAKEOFF
	-- if simDR_on_ground_0 == 1
	-- or simDR_on_ground_1 == 1
	-- or simDR_on_ground_2 == 1 then
		-- if is_timer_scheduled(on_ground_5sec) == false 
		-- and takeoff_enable == 0 and simDR_airspeed_pilot < 70 then
			-- run_after_time(on_ground_5sec, 5)	-- 5 seconds on the ground
		-- end
		-- if takeoff_enable == 1 then
			-- climb_enable = 1
			-- descent_enable = 0
			-- goaround_enable = 0
			-- B738DR_flight_phase = 0
			-- in_flight_mode = 0
		-- end
	-- end
	
	-- -- flight phase CLIMB
	-- if simDR_radio_height_pilot_ft > (clb_alt_num - 150)
	-- and climb_enable == 1 then
		-- takeoff_enable = 0
		-- descent_enable = 0
		-- goaround_enable = 0
		-- B738DR_flight_phase = 1
		-- in_flight_mode = 1
		-- -- if B738DR_vnav_td_dist == 0 then
			-- -- descent_enable = 1
		-- -- end
	-- end
	
	-- -- flight phase CRUISE CLIMB and CRUISE DESCENT
	-- if B738DR_flight_phase == 3 or B738DR_flight_phase == 4 then
		-- descent_enable = 0
		-- dlt_crz_alt = crz_alt_num - simDR_altitude_pilot
		-- if dlt_crz_alt < 0 then
			-- dlt_crz_alt = -dlt_crz_alt
		-- end
		-- if dlt_crz_alt < 100 then	--100
			-- takeoff_enable = 0
			-- climb_enable = 0
			-- goaround_enable = 0
			-- B738DR_flight_phase = 2
		-- end
	-- else
		-- -- flight phase CRUISE
		-- if crz_alt_num > 0 and B738DR_fms_descent_now < 2 then
			-- dlt_crz_alt = crz_alt_num - simDR_altitude_pilot
			-- if dlt_crz_alt < 0 then
				-- dlt_crz_alt = -dlt_crz_alt
			-- end
			-- if simDR_altitude_pilot >= crz_alt_num 
			-- or dlt_crz_alt < 100 then	--100
				-- takeoff_enable = 0
				-- climb_enable = 0
				-- descent_enable = 1
				-- goaround_enable = 0
				-- B738DR_flight_phase = 2
				-- in_flight_mode = 1
			-- end
		-- end
	-- end
	
	
	-- -- flight phase DESCENT
	-- -- if simDR_autopilot_altitude_mode == 4 
	-- -- or simDR_autopilot_altitude_mode == 5
	-- -- or B738DR_fms_descent_now == 2 then
		-- -- if descent_enable == 1 then
			-- -- goaround_enable = 1
			-- -- takeoff_enable = 0
			-- -- climb_enable = 0
			-- -- B738DR_flight_phase = 5
-- -- --		else
-- -- --			goaround_enable = 0
-- -- --			B738DR_flight_phase = 2
		-- -- end
	-- -- end
	
	-- -- if simDR_autopilot_altitude_mode == 4 and simDR_vvi_fpm_pilot < -50 then	-- VS
		 -- -- des_active = 1
	-- -- end
	-- dlt_crz_alt = crz_alt_num - simDR_altitude_pilot
	-- if dlt_crz_alt > 500 and crz_alt_num > 0 then
		-- if simDR_autopilot_altitude_mode == 4 and simDR_ap_vvi_dial < -50 then		-- VS
			 -- des_active = 1
		-- end
		-- if simDR_autopilot_altitude_mode == 5 and simDR_vvi_fpm_pilot < -100 then	-- LVL CHG
			 -- des_active = 1
		-- end
	-- end
	-- if B738DR_fms_descent_now > 1 then
		-- des_active = 1
	-- end
	-- if des_active == 1 and descent_enable == 1 then
			-- goaround_enable = 1
			-- takeoff_enable = 0
			-- climb_enable = 0
			-- B738DR_flight_phase = 5
	-- end
	
	-- if B738DR_flight_phase == 7 and simDR_radio_height_pilot_ft > 2500 then
		-- takeoff_enable = 0
		-- climb_enable = 0
		-- B738DR_flight_phase = 5
	-- end
	-- -- flight phase Go-Around
	-- if simDR_radio_height_pilot_ft < 2000 and simDR_vvi_fpm_pilot < -500 then
	-- --and goaround_enable == 1 then
		-- goaround_enable = 1
		-- descent_enable = 0
		-- B738DR_flight_phase = 7
	-- end
	

-- end


function B738_flight_phase2()

	local alt_temp = 0
	local descent_active = 0
	
	
		if altitude_last > crz_alt_num then
			altitude_last = crz_alt_num
		end
		
		if B738DR_flight_phase < 4 then
			alt_temp = simDR_altitude_pilot + 1500
			if altitude_last > alt_temp then
				descent_active = 1
			end
		end
		
		if simDR_radio_height_pilot_ft > 50 then
			in_flight_mode = 1
		else
			in_flight_mode = 0
		end
		
		-- flight phase TAKEOFF
		if simDR_on_ground_0 == 1
		or simDR_on_ground_1 == 1
		or simDR_on_ground_2 == 1 then
			if is_timer_scheduled(on_ground_5sec) == false 
			and takeoff_enable == 0 and simDR_airspeed_pilot < 70 then
				run_after_time(on_ground_5sec, 25)	-- 25 seconds on the ground
			end
			if takeoff_enable == 1 then
				climb_enable = 1
				descent_enable = 0
				goaround_enable = 0
				B738DR_flight_phase = 0
				altitude_last = simDR_altitude_pilot
				--in_flight_mode = 0
			end
		end
		
		if td_idx == 0 then
			if B738DR_flight_phase == 0 then
				-- flight phase CLIMB
				alt_temp = clb_alt_num - 150
				if simDR_radio_height_pilot_ft > alt_temp and climb_enable == 1 then
					takeoff_enable = 0
					descent_enable = 0
					goaround_enable = 0
					B738DR_flight_phase = 1
					--in_flight_mode = 1
				end
			else
				if descent_active == 1 and B738DR_flight_phase < 5 then
					B738DR_flight_phase = 5
					takeoff_enable = 0
					climb_enable = 0
					descent_enable = 1
					goaround_enable = 1
				end
				-- if B738DR_flight_phase == 1 then
					-- vnav_alt_mode = 1
					-- if simDR_autopilot_altitude_mode ~= 6 then
						-- simCMD_autopilot_alt_hold:once()
					-- end
				-- elseif B738DR_flight_phase == 2 then
					-- vnav_alt_mode = 1
				-- end
			end
		else
			if offset <= td_idx and B738DR_vnav_td_dist > 0 then	-- before T/D
				if B738DR_fms_descent_now < 2 then
					if crz_alt_num > 0 then
						--dlt_crz_alt = math.abs(crz_alt_num - simDR_altitude_pilot)
						-- flight phase CRUISE
						alt_temp = crz_alt_num - 70
						if simDR_altitude_pilot >= alt_temp then
						--or dlt_crz_alt < 200 then
							takeoff_enable = 0
							climb_enable = 0
							descent_enable = 1
							goaround_enable = 0
							if B738DR_flight_phase ~= 3 and B738DR_flight_phase ~= 4 then
								B738DR_flight_phase = 2
							end
							--in_flight_mode = 1
						else
							alt_temp = clb_alt_num - 150
							if simDR_radio_height_pilot_ft > alt_temp and B738DR_flight_phase == 0 then
								-- flight phase CLIMB
								takeoff_enable = 0
								descent_enable = 0
								goaround_enable = 0
								if B738DR_flight_phase < 2 then
									B738DR_flight_phase = 1
								end
							end
						end
					end
					if descent_active == 1 and B738DR_flight_phase < 5 then
						-- flight phase DESCENT
						B738DR_flight_phase = 5
						takeoff_enable = 0
						climb_enable = 0
						descent_enable = 1
						goaround_enable = 1
					end
				else
					if B738DR_flight_phase < 5 then
						-- flight phase DESCENT
						goaround_enable = 1
						takeoff_enable = 0
						climb_enable = 0
						B738DR_flight_phase = 5
					end
				end
			else
				-- if crz_alt_num > 0 and simDR_altitude_pilot < crz_alt_num 
				-- and simDR_vvi_fpm_pilot < -70 and simDR_autopilot_altitude_mode ~= 6 then
					-- -- flight phase DESCENT
					-- goaround_enable = 1
					-- takeoff_enable = 0
					-- climb_enable = 0
					-- B738DR_flight_phase = 5
				-- end
				if descent_active == 1 and B738DR_flight_phase < 5 then
					B738DR_flight_phase = 5
					takeoff_enable = 0
					climb_enable = 0
					descent_enable = 1
					goaround_enable = 1
				end
			end
		end
		
		if simDR_radio_height_pilot_ft > 2500 and simDR_radio_height_pilot_ft > clb_alt_num then
			goaround_enable = 1
		end
		if B738DR_flight_phase == 7 and simDR_radio_height_pilot_ft > 2500 then
			takeoff_enable = 0
			climb_enable = 0
			goaround_enable = 1
			B738DR_flight_phase = 5
		end
		-- flight phase Go-Around
		if simDR_radio_height_pilot_ft < 2000 and goaround_enable == 1 then
		--and goaround_enable == 1 then
			goaround_enable = 1
			descent_enable = 0
			B738DR_flight_phase = 7
		end
		
		if crz_alt_num > 0 then
			if simDR_altitude_pilot <= crz_alt_num and altitude_last < simDR_altitude_pilot then
				altitude_last = simDR_altitude_pilot
			end
		else
			if altitude_last < simDR_altitude_pilot then
				altitude_last = simDR_altitude_pilot
			end
		end
	

end




function B738_N1_thrust_set()
	fmc_takeoff_mode = 1
	fmc_goaround_mode = 1
	fmc_ga_thrust = B738DR_thr_goaround_N1
	fmc_cruise_mode = 1
	fmc_climb_mode = 1
	fmc_cont_mode = 1
	
	if simDR_altitude_pilot > 15000 then
		clb = "<SEL>"
		clb_1 = "     "
		clb_2 = "     "
	end
	
	-- mode TAKEOFF
	if B738DR_flight_phase == 0 then
		if sel_temp == "----" then
			if to == "<ACT>" then
				fms_N1_to_mode_sel = 1	-- mode TO
				fmc_auto_thrust = fmc_full_thrust
			elseif to_1 == "<ACT>" then
				fms_N1_to_mode_sel = 2	-- mode TO 1
				fmc_auto_thrust = fmc_full_thrust --* 0.97
			elseif to_2 == "<ACT>" then
				fms_N1_to_mode_sel = 3	-- mode TO 2
				fmc_auto_thrust = fmc_full_thrust --* 0.94
			end
		else
			if to == "<ACT>" then
				fms_N1_to_mode_sel = 4	-- mode D-TO
				fmc_auto_thrust = fmc_dto_thrust
			elseif to_1 == "<ACT>" then
				fms_N1_to_mode_sel = 5	-- mode D-TO 1
				fmc_auto_thrust = fmc_dto_thrust --* 0.97
			elseif to_2 == "<ACT>" then
				fms_N1_to_mode_sel = 6	-- mode D-TO 2
				fmc_auto_thrust = fmc_dto_thrust --* 0.94
			end
		end
		fms_N1_mode = fms_N1_to_mode_sel
	
	-- mode CLIMB
	elseif B738DR_flight_phase == 1 then
		if clb == "<SEL>" then
			fms_N1_clb_mode_sel = 7	-- mode CLB
			fmc_auto_thrust = fmc_clb_thrust
		elseif clb_1 == "<SEL>" then
			fms_N1_clb_mode_sel = 8	-- mode CLB 1
			fmc_auto_thrust = fmc_clb_thrust * 0.97
		elseif clb_2 == "<SEL>" then
			fms_N1_clb_mode_sel = 9	-- mode CLB 2
			fmc_auto_thrust = fmc_clb_thrust * 0.94
		end
		fms_N1_mode = fms_N1_clb_mode_sel
	
	-- mode CRUISE CLIMB
	elseif B738DR_flight_phase == 3 then
		fms_N1_clb_mode_sel = 7	-- mode CLB
		fmc_auto_thrust = fmc_clb_thrust
	
	-- mode CRUISE, CRUISE DESCENT, DESCENT, APPROACH
	elseif B738DR_flight_phase == 2 
	or B738DR_flight_phase == 4 
	or B738DR_flight_phase == 5
	or B738DR_flight_phase == 6 then
		fms_N1_mode = 10	-- mode  CRZ
		fmc_auto_thrust = fmc_crz_thrust
	
	-- mode GO AROUND
	elseif B738DR_flight_phase == 7 then
		fms_N1_mode = 11	-- mode GA
		fmc_auto_thrust = fmc_ga_thrust
	end
	
	-- SET N1 THRUST
	if B738DR_n1_set_source == 0 then	-- N1 source AUTO
		if auto_act == "<ACT>" then
			if fmc_auto_thrust == 0 then	-- FMC thrust not able
				B738DR_fms_N1_mode = 13
				B738DR_fms_N1_thrust = 1.00	-- full thrust
			else
				B738DR_fms_N1_mode = fms_N1_mode
				B738DR_fms_N1_thrust = fmc_auto_thrust
			end
		elseif ga_act == "<ACT>" then
			B738DR_fms_N1_mode = 11
			B738DR_fms_N1_thrust = fmc_ga_thrust
		elseif con_act == "<ACT>" then
			B738DR_fms_N1_mode = 12
			B738DR_fms_N1_thrust = fmc_con_thrust
		elseif clb_act == "<ACT>" then
			if clb == "<SEL>" then
				B738DR_fms_N1_mode = 7
				B738DR_fms_N1_thrust = fmc_clb_thrust
			elseif clb_1 == "<SEL>" then
				B738DR_fms_N1_mode = 8
				B738DR_fms_N1_thrust = fmc_clb_thrust * 0.97
			elseif clb_2 == "<SEL>" then
				B738DR_fms_N1_mode = 9
				B738DR_fms_N1_thrust = fmc_clb_thrust * 0.94
			end
		elseif crz_act == "<ACT>" then
			B738DR_fms_N1_mode = 10
			B738DR_fms_N1_thrust = fmc_crz_thrust
		end
	else
		B738DR_fms_N1_mode = 0
	end
end

function drag_timer()
	drag_timeout = 2
end

function rst_fms_msg()
	fms_msg_sound = 0
end

function B738_fmc_msg()

	local day_act = ""
	local month_act = ""
	local date_act = 0
	local date_temp = ""
	local align_mode = 0
	local airspeed = B738DR_mcp_speed_dial	--simDR_airspeed_dial
	local throttle_idle = 0
	local day_nav = ""
	local date_nav = 0
	local month_nav = ""
	
	if simDR_bus_volts1 > 10 or simDR_bus_volts2 > 10 then
		
		-- GPS_L_INVALID
		if B738DR_gps_pos == "-----.-------.-"  then
			if msg_gps_l_fail == 0 then
				msg_gps_l_fail = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = GPS_L_INVALID
				--entry = GPS_L_INVALID
				simCMD_nosmoking_toggle:once()
				fms_msg_sound = 1
				B738DR_fmc_message_warn = 1
			end
		end
		
		-- GPS_R_INVALID
		if B738DR_gps2_pos == "-----.-------.-"  then
			if msg_gps_r_fail == 0 then
				msg_gps_r_fail = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = GPS_R_INVALID
				--entry = GPS_R_INVALID
				simCMD_nosmoking_toggle:once()
				fms_msg_sound = 1
				B738DR_fmc_message_warn = 1
			end
		end
		
		-- GPS_LR_INVALID
		if B738DR_gps_pos == "-----.-------.-" 
		and B738DR_gps2_pos == "-----.-------.-"  then
			if msg_gps_lr_fail == 0 then
				msg_gps_lr_fail = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = GPS_LR_INVALID
				--entry = GPS_LR_INVALID
				simCMD_nosmoking_toggle:once()
				fms_msg_sound = 1
			end
		end
		
		-- IRS MOTION
		if B738DR_irs1_restart == 1 or B738DR_irs2_restart == 1 then
			if msg_irs_motion == 0 then
				msg_irs_motion = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = IRS_MOTION
				--entry = IRS_MOTION
				simCMD_nosmoking_toggle:once()
				fms_msg_sound = 1
				B738DR_fmc_message_warn = 1
			end
		end
		
		-- ENTER IRS POS
		align_mode = 0
		if B738DR_irs_left_mode == 1 and B738DR_irs_left == 2 then
			align_mode = 1
		end
		if B738DR_irs_right_mode == 1 and B738DR_irs_right == 2 then
			align_mode = 1
		end
		if B738DR_irs_left_mode == 2 or B738DR_irs_right_mode == 2 then
			align_mode = 0
		end
		if align_mode == 1 then
			if msg_irs_pos == 0 then
				msg_irs_pos = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = ENTER_IRS_POS
				--entry = ENTER_IRS_POS
				simCMD_nosmoking_toggle:once()
				fms_msg_sound = 1
				B738DR_fmc_message_warn = 1
			end
		end
		
		-- ENTER IRS HDG
		align_mode = 0
		if B738DR_irs_left_mode == 1 and B738DR_irs_left == 3 then
			align_mode = 1
		end
		if B738DR_irs_right_mode == 1 and B738DR_irs_right == 3 then
			align_mode = 1
		end
		if B738DR_irs_left_mode == 3 or B738DR_irs_right_mode == 3 then
			align_mode = 0
		end
		if align_mode == 1 then
			if msg_irs_hdg == 0 then
				msg_irs_hdg = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = ENTER_IRS_HDG
				--entry = ENTER_IRS_HDG
				simCMD_nosmoking_toggle:once()
				fms_msg_sound = 1
			end
		end
		
		-- RESET MCP ALT
		-- if simDR_vnav_tod_nm < 6 and simDR_vnav_tod_nm > 0 
		-- and B738DR_altitude_mode == 5 then -- VNAV on and 5NM before TOD
		if td_idx ~= 0 and B738DR_vnav_td_dist < 6 and B738DR_altitude_mode == 5 
		and B738DR_flight_phase == 2 then	-- VNAV on and cruise phase
			if crz_alt_num > 0 and simDR_ap_altitude_dial_ft >= crz_alt_num then
				if msg_mcp_alt == 0 then
					msg_mcp_alt = 1
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = RESET_MCP_ALT
					--entry = RESET_MCP_ALT
					simCMD_nosmoking_toggle:once()
					fms_msg_sound = 1
					B738DR_fmc_message_warn = 1
				end
			end
		end
		if B738DR_altitude_mode ~= 5 then	-- VNAV off
			msg_mcp_alt = 0
		end
		
		-- DRAG REQUIRED
		if simDR_throttle1_use < 0.1 or simDR_throttle2_use < 0.1 then
			throttle_idle = 1
		end
		if B738DR_flight_phase == 5 and B738DR_autopilot_vnav_status == 1 then
			airspeed = airspeed + 10
			if simDR_airspeed_pilot > airspeed and drag_timeout == 0 and throttle_idle == 1 then
				drag_timeout = 1
				if is_timer_scheduled(drag_timer) == false then
					run_after_time(drag_timer, 10)
				end
			end
			
			if simDR_airspeed_pilot > airspeed and B738DR_speed_ratio > -0.2 
			and msg_drag_req == 0 and drag_timeout == 2 then
				msg_drag_req = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = DRAG_REQUIRED
				--entry = DRAG_REQUIRED
				simCMD_nosmoking_toggle:once()
				fms_msg_sound = 1
			end
			
			airspeed = airspeed - 8
			if simDR_airspeed_pilot <= B738DR_mcp_speed_dial	--simDR_airspeed_dial 
			and msg_drag_req == 1 then
				stop_timer(drag_timer)
				drag_timeout = 0
				msg_drag_req = 0
			end
			if drag_timeout == 2 then
				drag_timeout = 0
			end
		end
		
		if msg_nav_data == 0 then
			day_act = os.date("%d")
			month_act = os.date("%m")
			date_act = tonumber(month_act .. day_act)
			
			date_temp = string.sub(B738_navdata_active, 6, 8) -- month
			if date_temp == "JAN" then
				month_nav = "01"
			elseif date_temp == "FEB" then
				month_nav = "02"
			elseif date_temp == "MAR" then
				month_nav = "03"
			elseif date_temp == "APR" then
				month_nav = "04"
			elseif date_temp == "MAY" then
				month_nav = "05"
			elseif date_temp == "JUN" then
				month_nav = "06"
			elseif date_temp == "JUL" then
				month_nav = "07"
			elseif date_temp == "AUG" then
				month_nav = "08"
			elseif date_temp == "SEP" then
				month_nav = "09"
			elseif date_temp == "OCT" then
				month_nav = "10"
			elseif date_temp == "NOV" then
				month_nav = "11"
			elseif date_temp == "DEC" then
				month_nav = "12"
			end
			day_nav = string.sub(B738_navdata_active, 9, 10) -- day
			date_nav = tonumber(month_nav .. day_nav)
			
			if date_act > date_nav then
				msg_nav_data = 1
			else
				msg_nav_data = 2
			end
		end
		
		if msg_nav_data == 1 then
			msg_nav_data = 2
			fmc_message_num = fmc_message_num + 1
			fmc_message[fmc_message_num] = NAV_DATA_OF_DATE
			--entry = NAV_DATA_OF_DATE
			fms_msg_sound = 1
			B738DR_fmc_message_warn = 1
		end
		
		-- UNABLE CRZ ALT
		if tc_idx > td_idx then
			if msg_unavaible_crz_alt == 0 then
				msg_unavaible_crz_alt = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = UNABLE_CRUISE_ALT
				--entry = UNABLE_CRUISE_ALT
				simCMD_nosmoking_toggle:once()
				fms_msg_sound = 1
			end
		else
			if tc_idx == td_idx and dist_tc > B738DR_vnav_td_dist then
				if msg_unavaible_crz_alt == 0 then
					msg_unavaible_crz_alt = 1
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = UNABLE_CRUISE_ALT
					--entry = UNABLE_CRUISE_ALT
					simCMD_nosmoking_toggle:once()
					fms_msg_sound = 1
				end
			end
		end
		
		-- CONFIG SAVED
		-- if entry == CONFIG_SAVED and fms_msg_cfg_saved == 0 then
			-- fms_msg_cfg_saved = 1
			-- fms_msg_sound = 1
		-- end
		
		-- TAI ABOVE 10 C
		if simDR_TAT > 10 then
			if simDR_cowl_ice_0_on == 1 or simDR_cowl_ice_1_on == 1 then
				if msg_tai_above_10 == 0 then
					msg_tai_above_10 = 1
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = TAI_ON_ABOVE_10C
					--entry = TAI_ON_ABOVE_10C
					simCMD_nosmoking_toggle:once()
					fms_msg_sound = 1
				end
			else
				msg_tai_above_10 = 0
			end
		end
		-- DISCONTINUITY
		if string.sub(B738DR_fpln_nav_id, 1, 7) == "DISCONT" then
			if B738DR_heading_mode > 3 and B738DR_heading_mode < 7 then
				B738DR_lnav_disconnect = 1
				B738DR_vnav_disconnect = 1
				fms_msg_sound = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = DISCON
				--entry = DISCON
				simCMD_nosmoking_toggle:once()
				B738DR_fmc_message_warn = 1
			end
		end
		
		-- ABOVE MAX CERT ALT
		if simDR_altitude_pilot > 41200 then
			if msg_above_max == 0 then
				msg_above_max = 1
				fms_msg_sound = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = ABOVE_MAX_CERT_ALT
				--entry = ABOVE_MAX_CERT_ALT
				simCMD_nosmoking_toggle:once()
			end
		end
		if simDR_altitude_pilot < 41000 then
			msg_above_max = 0
		end
	
		-- APPRCH VREF NOT SELECTED
		if B738DR_flight_phase > 4 and B738DR_spd_ref == 0 then
			if simDR_gear_retract > 0.1 and simDR_flaps_ratio > 0.624 then	-- gear down, flaps >= 15
				--if flaps_app == "  " and msg_vref_not_sel == 0 then
				if app_flap == "--" and msg_vref_not_sel == 0 then
					msg_vref_not_sel = 1
					fms_msg_sound = 1
					fmc_message_num = fmc_message_num + 1
					fmc_message[fmc_message_num] = APPRCH_VREF_NOT_SELECTED
					--entry = APPRCH_VREF_NOT_SELECTED 
					simCMD_nosmoking_toggle:once()
				end
			end
		else
			msg_vref_not_sel = 0
		end
		
		-- LNAV DISCONNECT
		if B738DR_heading_mode > 3 and B738DR_heading_mode < 7 and legs_num < 1 then
			B738DR_lnav_disconnect = 1
			B738DR_vnav_disconnect = 1
			fms_msg_sound = 1
			fmc_message_num = fmc_message_num + 1
			fmc_message[fmc_message_num] = LNAV_DISCON
			--entry = LNAV_DISCON
			simCMD_nosmoking_toggle:once()
			B738DR_fmc_message_warn = 1
		end
		if legs_num < 1 then
			B738DR_end_route = 1
		else
			B738DR_end_route = 0
		end
		if crz_alt_num > 0 and legs_num > 0 and offset > 0 and cost_index ~= "***" and ref_icao ~= "----" and des_icao ~= "****" then
			B738DR_no_perf = 0
		else
			B738DR_no_perf = 1
		end
	end
	
	B738DR_fms_msg_sound = fms_msg_sound
	if fms_msg_sound == 1 then
		if is_timer_scheduled(rst_fms_msg) == false then
			run_after_time(rst_fms_msg, 1)
		end
	end
	
	if fmc_message_num > 255 then
		fmc_message_num = 255
	end
	
	if fmc_message_num == 0 then
		B738DR_fmc_message = 0
	else
		B738DR_fmc_message = 1
	end


end

function B738DR_checklist()

	local to_flaps_set = 0
	if B738DR_fms_takeoff_flaps > 0 then
		if B738DR_fms_takeoff_flaps == 1 and simDR_flaps_ratio == 0.125 then
			to_flaps_set = 1
		elseif B738DR_fms_takeoff_flaps == 5 and simDR_flaps_ratio == 0.375 then
			to_flaps_set = 1
		elseif B738DR_fms_takeoff_flaps == 10 and simDR_flaps_ratio == 0.5 then
			to_flaps_set = 1
		elseif B738DR_fms_takeoff_flaps == 15 and simDR_flaps_ratio == 0.625 then
			to_flaps_set = 1
		elseif B738DR_fms_takeoff_flaps == 25 and simDR_flaps_ratio == 0.75 then
			to_flaps_set = 1
		end
	end
	B738DR_takeoff_flaps_set = to_flaps_set
	
	local app_flaps_set = 0
	if B738DR_fms_approach_flaps > 0 then
		if B738DR_fms_approach_flaps == 15 and simDR_flaps_ratio == 0.625 then
			app_flaps_set = 1
		elseif B738DR_fms_approach_flaps == 30 and simDR_flaps_ratio == 0.875 then
			app_flaps_set = 1
		elseif B738DR_fms_approach_flaps == 40 and simDR_flaps_ratio == 1 then
			app_flaps_set = 1
		end
	end
	B738DR_approach_flaps_set = app_flaps_set
	
	local to_trim_set = 0
	local trim_xxx = 0
	local trim_yyy = simDR_elevator_trim
	local trim_aaa = 0
	if B738DR_trim_calc > 0 and B738DR_trim_calc < 15 then
		--trim_xxx = B738_rescale(0, -1.0, 15, 0.588244, B738DR_trim_calc)
		--trim_xxx = B738DR_trim_calc * 0.1058829333
		--trim_xxx = trim_xxx - 1
		trim_yyy = trim_yyy + 1
		trim_xxx = B738_rescale(0, 0, 1.588244, 15, trim_yyy) - 1
		trim_aaa = B738DR_trim_calc - trim_xxx
		if trim_aaa < 0 then
			trim_aaa = -trim_aaa
		end
		if trim_aaa <= 0.15 then
			to_trim_set = 1
		end
	end
	--DR_test = trim_xxx
	B738DR_trim_set = to_trim_set
	
end

function B738_des_now()
	
	local des_now_nm = 0
	local tod_nm = 100
	-- if simDR_vnav_tod_nm ~= nil then
		-- tod_nm = simDR_vnav_tod_nm
	-- end
	if crz_alt_num >= 15000 then
		des_now_nm = B738_rescale(15000, 10, 41000, 70, crz_alt_num)
	end
	
	des_now_enable = 0
	if B738DR_flight_phase == 2 and B738DR_autopilot_vnav_status == 1 
	and des_now_nm ~= 0 and B738DR_vnav_td_dist < des_now_nm then
		des_now_enable = 1
	end
	
end


function B738_displ_wpt()


	local nd_lat = math.rad(simDR_latitude) 
	local nd_lon = math.rad(simDR_longitude) 
	local mag_hdg = 0
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_dis = 0
	local nd_x = 0
	local nd_y = 0
	local nd_hdg = 0
	local delta_hdg = 0
	local nd_on_off = 0
	local nd_zoom = 0
	local nd_corr = 0
	local n = 0
	local obj = 0
	local max_obj = 20
	local obj_enable = 0
	local nav_disable = 0
	local txt_white_id = ""
	local txt_white_alt = ""
	local txt_white_eta = ""
	local txt_cyan_id = ""
	local txt_cyan_alt = ""
	local txt_cyan_eta = ""
	local wpt_type = 0
	
	local tmp_wpt_alt = 0
	local tmp_wpt_type = 0
	local wpt_data = 0
	local tmp_wpt_eta = ""
	local tmp_wpt_eta2 = 0
	local tmp_wpt_eta3 = 0
	
	local wpt_from = 0
	local wpt_to = 0
	
	local rte_act_enable = 0
	local rte_dist = 0
	local rte_n = 0
	local rte_plan_mode = 0
	local nd_x0 = 0
	local nd_y0 = 0
	
	local nd_dist_dir = 0
	
	B738DR_rte_show_act = 0
	
	if ref_icao == "----" or des_icao == "****" then
		legs_num = 0
	end
	
	if legs_num > 0 then --and legs_step <= legs_num then
		
		-- -- find actual waypoint
		-- if simDR_fmc_nav_id ~= nil then
-- --			for n = offset, legs_num do
			-- for n = 1, legs_num do
				-- if legs_data[n][1] == simDR_fmc_nav_id then
					-- offset = n
					-- break
				-- end
			-- end
		-- end
		
		if offset > legs_num then
			offset = legs_num
		end
		if offset == 0 then
			offset = 1
		end
		
		if map_mode == 3 then
			if legs_step == 0 then
				nd_lat = math.rad(legs_data[1][7])
				nd_lon = math.rad(legs_data[1][8])
			else
				nd_lat = math.rad(legs_data[legs_step][7])
				nd_lon = math.rad(legs_data[legs_step][8])
			end
			mag_hdg = -simDR_mag_variation
			if offset == 1 then
				wpt_from = 1
			else
				wpt_from = offset - 1
			end
			rte_plan_mode = 1
		else
			if B738DR_capt_map_mode < 2 then
				mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
				if B738DR_capt_map_mode == 1 and simDR_efis_map_mode == 0 then
					nav_disable = 1
				end
				
			-- elseif simDR_efis_sub_mode == 4 then
				-- nav_disable = 1
				--mag_hdg = 4.49
			else
				mag_hdg = simDR_mag_hdg - simDR_mag_variation
			end
			if offset == 1 then
				wpt_from = 1
			else
				wpt_from = offset - 1
			end
			rte_plan_mode = 0
		end
		
		if des_app == "------" then
			wpt_to = legs_num + 1
		else
			wpt_to = legs_num
		end
		
		if nav_disable == 0 then
			for n = wpt_from, wpt_to do
			
			if legs_data[n][1] ~= "DISCONTINUITY" then --and legs_data[n][1] ~= "VECTORS" then
				
				if last_lat == 0 and last_lon == 0 then
					nd_lat2 = math.rad(legs_data[n][7])
					nd_lon2 = math.rad(legs_data[n][8])
				else
					if n == (offset - 1) and rte_plan_mode == 0 then
						
						nd_lat = last_lat
						nd_lon = last_lon
						nd_lat2 = math.rad(legs_data[offset][7])
						nd_lon2 = math.rad(legs_data[offset][8])
						
						nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
						nd_y = nd_lat2 - nd_lat
						nd_dist_dir = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
						
						nd_lat = math.rad(simDR_latitude) 
						nd_lon = math.rad(simDR_longitude) 
						nd_lat2 = last_lat
						nd_lon2 = last_lon
					else
						nd_lat2 = math.rad(legs_data[n][7])
						nd_lon2 = math.rad(legs_data[n][8])
					end
				end
				
				--nd_lat2 = math.rad(nd_lat2)
				--nd_lon2 = math.rad(nd_lon2)
				
				nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
				nd_y = nd_lat2 - nd_lat
				nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
				--nd_dis = nd_dis
				
				if nd_dis < 645 then
					
					nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
					nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
					nd_hdg = math.atan2(nd_y, nd_x)
					nd_hdg = math.deg(nd_hdg)
					nd_hdg = (nd_hdg + 360) % 360
					
					delta_hdg = ((((nd_hdg - mag_hdg) % 360) + 540) % 360) - 180
					
					if delta_hdg >= 0 and delta_hdg <= 90 then
						-- right
						nd_on_off = 1
						delta_hdg = 90 - delta_hdg
						delta_hdg = math.rad(delta_hdg)
						nd_y = nd_dis * math.sin(delta_hdg)
						nd_x = nd_dis * math.cos(delta_hdg)
					elseif delta_hdg < 0 and delta_hdg >= -90 then
						-- left
						nd_on_off = 1
						delta_hdg = 90 + delta_hdg
						delta_hdg = math.rad(delta_hdg)
						nd_y = nd_dis * math.sin(delta_hdg)
						nd_x = -nd_dis * math.cos(delta_hdg)
					elseif delta_hdg >= 90 then
						-- right back
						nd_on_off = 1
						delta_hdg = delta_hdg - 90
						delta_hdg = math.rad(delta_hdg)
						nd_y = -nd_dis * math.sin(delta_hdg)
						nd_x = nd_dis * math.cos(delta_hdg)
					elseif delta_hdg <= -90 then
						-- left back
						nd_on_off = 1
						delta_hdg = -90 - delta_hdg
						delta_hdg = math.rad(delta_hdg)
						nd_y = -nd_dis * math.sin(delta_hdg)
						nd_x = -nd_dis * math.cos(delta_hdg)
					end
					
					if B738DR_efis_map_range_capt == 0 then	-- 5 NM
						nd_zoom = 2
					elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
						nd_zoom = 1
					elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
						nd_zoom = 0.5
					elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
						nd_zoom = 0.25
					elseif B738DR_efis_map_range_capt == 4 then	-- 80 NM
						nd_zoom = 0.125
					elseif B738DR_efis_map_range_capt == 5 then	-- 160 NM
						nd_zoom = 0.0625
					elseif B738DR_efis_map_range_capt == 6 then	-- 320 NM
						nd_zoom = 0.03125
					else	-- 640 NM
						nd_zoom = 0.015625
						--nd_on_off = 0
					end
					
					nd_x = nd_x * nd_zoom		-- zoom
					nd_y = nd_y * nd_zoom		-- zoom
					if map_mode == 3 then
						nd_y = nd_y + 4.1	-- adjust center
					elseif B738DR_capt_map_mode == 0 and simDR_efis_map_mode == 0 then
						nd_y = nd_y + 4.1	-- adjust center
					else
						if B738DR_capt_map_mode == 3 then
							nd_y = nd_y + 4.1	-- adjust
						end
					end
					
					-- if nd_x < -6.0 or nd_x > 6.0 then
						-- nd_on_off = 0
					-- end
					-- if nd_x < 0 then
						-- nd_corr = B738_rescale(-6.0, 6.3, 0, 8.7, nd_x)
					-- else
						-- nd_corr = B738_rescale(0, 8.7, 6.0, 6.3, nd_x)
					-- end
					-- --if nd_y > 7.7 or nd_y < -1 then
					-- if nd_y > nd_corr or nd_y < -1 then
						-- nd_on_off = 0
					-- end
					if nd_x < -8.0 or nd_x > 8.0 then
						nd_on_off = 0
					end
					if nd_y > 11.0 or nd_y < -2 then
						nd_on_off = 0
					end
					if nd_on_off == 1 then
						-- WAYPOINTS and ROUTE
						if obj < max_obj then	-- max number displayed objects
							B738DR_wpt_x[obj] = nd_x
							B738DR_wpt_y[obj] = nd_y
							
							-- DRAW ROUTE
							if n > 0 then --and n <= legs_num then
								rte_n = legs_num + 1
								if n == rte_n then
									-- DES ICAO
									B738DR_rte_show[obj] = 0
									rte_act_enable = 1
								else
									B738DR_rte_show[obj] = 1
									B738DR_rte_x[obj] = nd_x
									B738DR_rte_y[obj] = nd_y
									if last_lat == 0 and last_lon == 0 then
										if legs_data[n+1][1] == "VECTORS" then
											B738DR_rte_rot[obj] = (math.deg(legs_data[n+1][2]) - mag_hdg - simDR_mag_variation + 360) % 360
											rte_dist = 15
										else
											B738DR_rte_rot[obj] = (math.deg(legs_data[n+1][2]) - mag_hdg ) % 360
											rte_dist = legs_data[n+1][3] * nd_zoom
											rte_dist = math.min(rte_dist, 15)
										end
									else
										if n == (offset - 1) and rte_plan_mode == 0 then
											B738DR_rte_rot[obj] = (simDR_fmc_trk - mag_hdg + 360) % 360
											rte_dist = nd_dist_dir * nd_zoom
											rte_dist = math.min(rte_dist, 15)
										else
											if legs_data[n+1][1] == "VECTORS" then
												B738DR_rte_rot[obj] = (math.deg(legs_data[n+1][2]) - mag_hdg - simDR_mag_variation + 360) % 360
												rte_dist = 15
											else
												B738DR_rte_rot[obj] = (math.deg(legs_data[n+1][2]) - mag_hdg ) % 360
												rte_dist = legs_data[n+1][3] * nd_zoom
												rte_dist = math.min(rte_dist, 15)
											end
										end
									end
									B738DR_rte_dist[obj] = rte_dist
								end
								if rte_plan_mode == 0 then
									if obj == 0 and n == offset then	--n == wpt_from then
										B738DR_rte_show_act = 1
										B738DR_rte_x_act = nd_x
										B738DR_rte_y_act = nd_y
										if last_lat == 0 and last_lon == 0 then
											B738DR_rte_rot_act = (math.deg(legs_data[n][2]) - mag_hdg + 180) % 360
										else
											B738DR_rte_rot_act = (simDR_fmc_trk - mag_hdg + 180) % 360
										end
										rte_dist = legs_data[n][3] * nd_zoom
										rte_dist = math.min(rte_dist, 15)
										B738DR_rte_dist_act = rte_dist
										rte_act_enable = 1
									end
								else
									if n <= legs_step and obj == 0 and n > 1 then
										rte_act_enable = 1
										B738DR_rte_show_act = 1
										B738DR_rte_x_act = nd_x
										B738DR_rte_y_act = nd_y
										B738DR_rte_rot_act = (math.deg(legs_data[n][2]) - mag_hdg + 180) % 360
										rte_dist = legs_data[n][3] * nd_zoom
										rte_dist = math.min(rte_dist, 15)
										B738DR_rte_dist_act = rte_dist
									end
								end
							end
							
							-- WAYPOINTS
							if n == offset then
								txt_white_id = ""
								txt_white_alt = ""
								txt_white_eta = ""
								txt_cyan_id = legs_data[n][1]
								--tmp_wpt_eta = legs_data[n][13]	--"--.--Z"	--legs_data[n][13]
								--tmp_wpt_eta = string.format("%05.2f", legs_data[n][13]) .. "Z"
								if legs_data[n][13] <= 0 then
									tmp_wpt_eta = "--.--Z"
								else
									tmp_wpt_eta2 = math.floor(legs_data[n][13])
									tmp_wpt_eta3 = (legs_data[n][13] - tmp_wpt_eta2) * 60
									tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. "."
									tmp_wpt_eta = tmp_wpt_eta .. string.format("%02d", tmp_wpt_eta3)
									tmp_wpt_eta = tmp_wpt_eta .. "Z"
								end
								
								if B738DR_efis_data_capt_status == 1 then
									wpt_data = 0
									if legs_data[n][5] > 0 then
										tmp_wpt_alt = legs_data[n][5]
										tmp_wpt_type = legs_data[n][6]
										wpt_data = 1
									elseif legs_data[n][11] > 0 then
										tmp_wpt_alt = legs_data[n][11]
										tmp_wpt_type = 32
										wpt_data = 1
									end
									if wpt_data == 1 then
										if B738DR_flight_phase < 5 then
											if tmp_wpt_alt > B738DR_trans_alt then
												txt_cyan_alt = "FL" .. string.format("%03d", (tmp_wpt_alt/100))
											else
												txt_cyan_alt = string.format("%5d", tmp_wpt_alt)
											end
										else
											if tmp_wpt_alt > B738DR_trans_lvl then
												txt_cyan_alt = "FL" .. string.format("%03d", (tmp_wpt_alt/100))
											else
												txt_cyan_alt = string.format("%5d", tmp_wpt_alt)
											end
										end
										if tmp_wpt_type == 43 then	-- Above
											txt_cyan_alt = txt_cyan_alt .. "A"
										elseif tmp_wpt_type == 45 then	-- Below
											txt_cyan_alt = txt_cyan_alt .. "B"
										end
										txt_cyan_eta = tmp_wpt_eta		--"--.--Z"
									else
										txt_cyan_alt = ""
										txt_cyan_eta = ""
									end
								else
									txt_cyan_alt = ""
									txt_cyan_eta = ""
								end
								wpt_type = 2
							else
								txt_cyan_id = ""
								txt_cyan_alt = ""
								txt_cyan_eta = ""
								if last_lat == 0 and last_lon == 0 then
									txt_white_id = legs_data[n][1]
								else
									if n == (offset-1) then
										txt_white_id = ""
									else
										txt_white_id = legs_data[n][1]
									end
								end
								--tmp_wpt_eta = legs_data[n][13]	--"--.--Z"	--legs_data[n][13]
								--tmp_wpt_eta = string.format("%05.2f", legs_data[n][13]) .. "Z"
								if legs_data[n][13] <= 0 then
									tmp_wpt_eta = "--.--Z"
								else
									tmp_wpt_eta2 = math.floor(legs_data[n][13])
									tmp_wpt_eta3 = (legs_data[n][13] - tmp_wpt_eta2) * 60
									tmp_wpt_eta = string.format("%02d", tmp_wpt_eta2) .. "."
									tmp_wpt_eta = tmp_wpt_eta .. string.format("%02d", tmp_wpt_eta3)
									tmp_wpt_eta = tmp_wpt_eta .. "Z"
								end
								if B738DR_efis_data_capt_status == 1 then
									wpt_data = 0
									if legs_data[n][5] > 0 then
										tmp_wpt_alt = legs_data[n][5]
										tmp_wpt_type = legs_data[n][6]
										wpt_data = 1
									elseif legs_data[n][11] > 0 then
										tmp_wpt_alt = legs_data[n][11]
										tmp_wpt_type = 32
										wpt_data = 1
									end
									
									if wpt_data == 1 then
										if B738DR_flight_phase < 5 then
											if tmp_wpt_alt > B738DR_trans_alt then
												txt_white_alt = "FL" .. string.format("%03d", (tmp_wpt_alt/100))
											else
												txt_white_alt = string.format("%5d", tmp_wpt_alt)
											end
										else
											if tmp_wpt_alt > B738DR_trans_lvl then
												txt_white_alt = "FL" .. string.format("%03d", (tmp_wpt_alt/100))
											else
												txt_white_alt = string.format("%5d", tmp_wpt_alt)
											end
										end
										if tmp_wpt_type == 43 then	-- Above
											txt_white_alt = txt_white_alt .. "A"
										elseif tmp_wpt_type == 45 then	-- Below
											txt_white_alt = txt_white_alt .. "B"
										end
										txt_white_eta = tmp_wpt_eta		--"--.--Z"
									else
										txt_white_alt = ""
										txt_white_eta = ""
									end
								else
									txt_white_alt = ""
									txt_white_eta = ""
								end
								wpt_type = 1
							end
							
							if legs_data[n][1] == "VECTORS" then
								wpt_type = 0
							end
							
							if obj == 0 then
								B738DR_wpt_id00w = txt_white_id
								B738DR_wpt_alt00w = txt_white_alt
								B738DR_wpt_eta00w = txt_white_eta
								B738DR_wpt_id00m = txt_cyan_id
								B738DR_wpt_alt00m = txt_cyan_alt
								B738DR_wpt_eta00m = txt_cyan_eta
								B738DR_wpt_type00 = wpt_type
							elseif obj == 1 then
								B738DR_wpt_id01w = txt_white_id
								B738DR_wpt_alt01w = txt_white_alt
								B738DR_wpt_eta01w = txt_white_eta
								B738DR_wpt_id01m = txt_cyan_id
								B738DR_wpt_alt01m = txt_cyan_alt
								B738DR_wpt_eta01m = txt_cyan_eta
								B738DR_wpt_type01 = wpt_type
							elseif obj == 2 then
								B738DR_wpt_id02w = txt_white_id
								B738DR_wpt_alt02w = txt_white_alt
								B738DR_wpt_eta02w = txt_white_eta
								B738DR_wpt_id02m = txt_cyan_id
								B738DR_wpt_alt02m = txt_cyan_alt
								B738DR_wpt_eta02m = txt_cyan_eta
								B738DR_wpt_type02 = wpt_type
							elseif obj == 3 then
								B738DR_wpt_id03w = txt_white_id
								B738DR_wpt_alt03w = txt_white_alt
								B738DR_wpt_eta03w = txt_white_eta
								B738DR_wpt_id03m = txt_cyan_id
								B738DR_wpt_alt03m = txt_cyan_alt
								B738DR_wpt_eta03m = txt_cyan_eta
								B738DR_wpt_type03 = wpt_type
							elseif obj == 4 then
								B738DR_wpt_id04w = txt_white_id
								B738DR_wpt_alt04w = txt_white_alt
								B738DR_wpt_eta04w = txt_white_eta
								B738DR_wpt_id04m = txt_cyan_id
								B738DR_wpt_alt04m = txt_cyan_alt
								B738DR_wpt_eta04m = txt_cyan_eta
								B738DR_wpt_type04 = wpt_type
							elseif obj == 5 then
								B738DR_wpt_id05w = txt_white_id
								B738DR_wpt_alt05w = txt_white_alt
								B738DR_wpt_eta05w = txt_white_eta
								B738DR_wpt_id05m = txt_cyan_id
								B738DR_wpt_alt05m = txt_cyan_alt
								B738DR_wpt_eta05m = txt_cyan_eta
								B738DR_wpt_type05 = wpt_type
							elseif obj == 6 then
								B738DR_wpt_id06w = txt_white_id
								B738DR_wpt_alt06w = txt_white_alt
								B738DR_wpt_eta06w = txt_white_eta
								B738DR_wpt_id06m = txt_cyan_id
								B738DR_wpt_alt06m = txt_cyan_alt
								B738DR_wpt_eta06m = txt_cyan_eta
								B738DR_wpt_type06 = wpt_type
							elseif obj == 7 then
								B738DR_wpt_id07w = txt_white_id
								B738DR_wpt_alt07w = txt_white_alt
								B738DR_wpt_eta07w = txt_white_eta
								B738DR_wpt_id07m = txt_cyan_id
								B738DR_wpt_alt07m = txt_cyan_alt
								B738DR_wpt_eta07m = txt_cyan_eta
								B738DR_wpt_type07 = wpt_type
							elseif obj == 8 then
								B738DR_wpt_id08w = txt_white_id
								B738DR_wpt_alt08w = txt_white_alt
								B738DR_wpt_eta08w = txt_white_eta
								B738DR_wpt_id08m = txt_cyan_id
								B738DR_wpt_alt08m = txt_cyan_alt
								B738DR_wpt_eta08m = txt_cyan_eta
								B738DR_wpt_type08 = wpt_type
							elseif obj == 9 then
								B738DR_wpt_id09w = txt_white_id
								B738DR_wpt_alt09w = txt_white_alt
								B738DR_wpt_eta09w = txt_white_eta
								B738DR_wpt_id09m = txt_cyan_id
								B738DR_wpt_alt09m = txt_cyan_alt
								B738DR_wpt_eta09m = txt_cyan_eta
								B738DR_wpt_type09 = wpt_type
							elseif obj == 10 then
								B738DR_wpt_id10w = txt_white_id
								B738DR_wpt_alt10w = txt_white_alt
								B738DR_wpt_eta10w = txt_white_eta
								B738DR_wpt_id10m = txt_cyan_id
								B738DR_wpt_alt10m = txt_cyan_alt
								B738DR_wpt_eta10m = txt_cyan_eta
								B738DR_wpt_type10 = wpt_type
							elseif obj == 11 then
								B738DR_wpt_id11w = txt_white_id
								B738DR_wpt_alt11w = txt_white_alt
								B738DR_wpt_eta11w = txt_white_eta
								B738DR_wpt_id11m = txt_cyan_id
								B738DR_wpt_alt11m = txt_cyan_alt
								B738DR_wpt_eta11m = txt_cyan_eta
								B738DR_wpt_type11 = wpt_type
							elseif obj == 12 then
								B738DR_wpt_id12w = txt_white_id
								B738DR_wpt_alt12w = txt_white_alt
								B738DR_wpt_eta12w = txt_white_eta
								B738DR_wpt_id12m = txt_cyan_id
								B738DR_wpt_alt12m = txt_cyan_alt
								B738DR_wpt_eta12m = txt_cyan_eta
								B738DR_wpt_type12 = wpt_type
							elseif obj == 13 then
								B738DR_wpt_id13w = txt_white_id
								B738DR_wpt_alt13w = txt_white_alt
								B738DR_wpt_eta13w = txt_white_eta
								B738DR_wpt_id13m = txt_cyan_id
								B738DR_wpt_alt13m = txt_cyan_alt
								B738DR_wpt_eta13m = txt_cyan_eta
								B738DR_wpt_type13 = wpt_type
							elseif obj == 14 then
								B738DR_wpt_id14w = txt_white_id
								B738DR_wpt_alt14w = txt_white_alt
								B738DR_wpt_eta14w = txt_white_eta
								B738DR_wpt_id14m = txt_cyan_id
								B738DR_wpt_alt14m = txt_cyan_alt
								B738DR_wpt_eta14m = txt_cyan_eta
								B738DR_wpt_type14 = wpt_type
							elseif obj == 15 then
								B738DR_wpt_id15w = txt_white_id
								B738DR_wpt_alt15w = txt_white_alt
								B738DR_wpt_eta15w = txt_white_eta
								B738DR_wpt_id15m = txt_cyan_id
								B738DR_wpt_alt15m = txt_cyan_alt
								B738DR_wpt_eta15m = txt_cyan_eta
								B738DR_wpt_type15 = wpt_type
							elseif obj == 16 then
								B738DR_wpt_id16w = txt_white_id
								B738DR_wpt_alt16w = txt_white_alt
								B738DR_wpt_eta16w = txt_white_eta
								B738DR_wpt_id16m = txt_cyan_id
								B738DR_wpt_alt16m = txt_cyan_alt
								B738DR_wpt_eta16m = txt_cyan_eta
								B738DR_wpt_type16 = wpt_type
							elseif obj == 17 then
								B738DR_wpt_id17w = txt_white_id
								B738DR_wpt_alt17w = txt_white_alt
								B738DR_wpt_eta17w = txt_white_eta
								B738DR_wpt_id17m = txt_cyan_id
								B738DR_wpt_alt17m = txt_cyan_alt
								B738DR_wpt_eta17m = txt_cyan_eta
								B738DR_wpt_type17 = wpt_type
							elseif obj == 18 then
								B738DR_wpt_id18w = txt_white_id
								B738DR_wpt_alt18w = txt_white_alt
								B738DR_wpt_eta18w = txt_white_eta
								B738DR_wpt_id18m = txt_cyan_id
								B738DR_wpt_alt18m = txt_cyan_alt
								B738DR_wpt_eta18m = txt_cyan_eta
								B738DR_wpt_type18 = wpt_type
							elseif obj == 19 then
								B738DR_wpt_id19w = txt_white_id
								B738DR_wpt_alt19w = txt_white_alt
								B738DR_wpt_eta19w = txt_white_eta
								B738DR_wpt_id19m = txt_cyan_id
								B738DR_wpt_alt19m = txt_cyan_alt
								B738DR_wpt_eta19m = txt_cyan_eta
								B738DR_wpt_type19 = wpt_type
							end
							
							
							obj = obj + 1
						end
					else
						--rte_act_enable = 1
						if obj == 0 and n == offset and rte_plan_mode == 0 then
							if nd_x < 0 then
								if nd_y > 0 then
									nd_x = -nd_x
									nd_x0 = (nd_x / nd_y) * 11
									nd_x0 = -nd_x0
									nd_y0 = 11
								else
									nd_x = -nd_x
									nd_y = -nd_y
									nd_x0 = (nd_x / nd_y) * 11
									nd_x0 = -nd_x0
									nd_y0 = -11
								end
							else
								if nd_y > 0 then
									nd_x0 = (nd_x / nd_y) * 11
									nd_y0 = 11
								else
									nd_y = -nd_y
									nd_x0 = (nd_x / nd_y) * 11
									nd_y0 = -11
								end
							end
							rte_act_enable = 1
							B738DR_rte_show_act = 1
							B738DR_rte_x_act = nd_x0
							B738DR_rte_y_act = nd_y0
							if last_lat == 0 and last_lon == 0 then
								B738DR_rte_rot_act = (math.deg(legs_data[n][2]) - mag_hdg + 180) % 360
							else
								B738DR_rte_rot_act = (simDR_fmc_trk - mag_hdg + 180) % 360
							end
							--B738DR_rte_rot_act = (math.deg(legs_data[n][2]) - mag_hdg + 180) % 360
							rte_dist = legs_data[n][3] * nd_zoom
							rte_dist = math.min(rte_dist, 15)
							B738DR_rte_dist_act = rte_dist
						end
					end
				end
			
			end
			
			end
		end
	end
	-- turn off unused objects
	if obj < max_obj then
		for n = obj, max_obj-1 do
			if n == 0 then
				B738DR_wpt_id00w = ""
				B738DR_wpt_alt00w = ""
				B738DR_wpt_eta00w = ""
				B738DR_wpt_id00m = ""
				B738DR_wpt_alt00m = ""
				B738DR_wpt_eta00m = ""
				B738DR_wpt_type00 = 0
			elseif n == 1 then
				B738DR_wpt_id01w = ""
				B738DR_wpt_alt01w = ""
				B738DR_wpt_eta01w = ""
				B738DR_wpt_id01m = ""
				B738DR_wpt_alt01m = ""
				B738DR_wpt_eta01m = ""
				B738DR_wpt_type01 = 0
			elseif n == 2 then
				B738DR_wpt_id02w = ""
				B738DR_wpt_alt02w = ""
				B738DR_wpt_eta02w = ""
				B738DR_wpt_id02m = ""
				B738DR_wpt_alt02m = ""
				B738DR_wpt_eta02m = ""
				B738DR_wpt_type02 = 0
			elseif n == 3 then
				B738DR_wpt_id03w = ""
				B738DR_wpt_alt03w = ""
				B738DR_wpt_eta03w = ""
				B738DR_wpt_id03m = ""
				B738DR_wpt_alt03m = ""
				B738DR_wpt_eta03m = ""
				B738DR_wpt_type03 = 0
			elseif n == 4 then
				B738DR_wpt_id04w = ""
				B738DR_wpt_alt04w = ""
				B738DR_wpt_eta04w = ""
				B738DR_wpt_id04m = ""
				B738DR_wpt_alt04m = ""
				B738DR_wpt_eta04m = ""
				B738DR_wpt_type04 = 0
			elseif n == 5 then
				B738DR_wpt_id05w = ""
				B738DR_wpt_alt05w = ""
				B738DR_wpt_eta05w = ""
				B738DR_wpt_id05m = ""
				B738DR_wpt_alt05m = ""
				B738DR_wpt_eta05m = ""
				B738DR_wpt_type05 = 0
			elseif n == 6 then
				B738DR_wpt_id06w = ""
				B738DR_wpt_alt06w = ""
				B738DR_wpt_eta06w = ""
				B738DR_wpt_id06m = ""
				B738DR_wpt_alt06m = ""
				B738DR_wpt_eta06m = ""
				B738DR_wpt_type06 = 0
			elseif n == 7 then
				B738DR_wpt_id07w = ""
				B738DR_wpt_alt07w = ""
				B738DR_wpt_eta07w = ""
				B738DR_wpt_id07m = ""
				B738DR_wpt_alt07m = ""
				B738DR_wpt_eta07m = ""
				B738DR_wpt_type07 = 0
			elseif n == 8 then
				B738DR_wpt_id08w = ""
				B738DR_wpt_alt08w = ""
				B738DR_wpt_eta08w = ""
				B738DR_wpt_id08m = ""
				B738DR_wpt_alt08m = ""
				B738DR_wpt_eta08m = ""
				B738DR_wpt_type08 = 0
			elseif n == 9 then
				B738DR_wpt_id09w = ""
				B738DR_wpt_alt09w = ""
				B738DR_wpt_eta09w = ""
				B738DR_wpt_id09m = ""
				B738DR_wpt_alt09m = ""
				B738DR_wpt_eta09m = ""
				B738DR_wpt_type09 = 0
			elseif n == 10 then
				B738DR_wpt_id10w = ""
				B738DR_wpt_alt10w = ""
				B738DR_wpt_eta10w = ""
				B738DR_wpt_id10m = ""
				B738DR_wpt_alt10m = ""
				B738DR_wpt_eta10m = ""
				B738DR_wpt_type10 = 0
			elseif n == 11 then
				B738DR_wpt_id11w = ""
				B738DR_wpt_alt11w = ""
				B738DR_wpt_eta11w = ""
				B738DR_wpt_id11m = ""
				B738DR_wpt_alt11m = ""
				B738DR_wpt_eta11m = ""
				B738DR_wpt_type11 = 0
			elseif n == 12 then
				B738DR_wpt_id12w = ""
				B738DR_wpt_alt12w = ""
				B738DR_wpt_eta12w = ""
				B738DR_wpt_id12m = ""
				B738DR_wpt_alt12m = ""
				B738DR_wpt_eta12m = ""
				B738DR_wpt_type12 = 0
			elseif n == 13 then
				B738DR_wpt_id13w = ""
				B738DR_wpt_alt13w = ""
				B738DR_wpt_eta13w = ""
				B738DR_wpt_id13m = ""
				B738DR_wpt_alt13m = ""
				B738DR_wpt_eta13m = ""
				B738DR_wpt_type13 = 0
			elseif n == 14 then
				B738DR_wpt_id14w = ""
				B738DR_wpt_alt14w = ""
				B738DR_wpt_eta14w = ""
				B738DR_wpt_id14m = ""
				B738DR_wpt_alt14m = ""
				B738DR_wpt_eta14m = ""
				B738DR_wpt_type14 = 0
			elseif n == 15 then
				B738DR_wpt_id15w = ""
				B738DR_wpt_alt15w = ""
				B738DR_wpt_eta15w = ""
				B738DR_wpt_id15m = ""
				B738DR_wpt_alt15m = ""
				B738DR_wpt_eta15m = ""
				B738DR_wpt_type15 = 0
			elseif n == 16 then
				B738DR_wpt_id16w = ""
				B738DR_wpt_alt16w = ""
				B738DR_wpt_eta16w = ""
				B738DR_wpt_id16m = ""
				B738DR_wpt_alt16m = ""
				B738DR_wpt_eta16m = ""
				B738DR_wpt_type16 = 0
			elseif n == 17 then
				B738DR_wpt_id17w = ""
				B738DR_wpt_alt17w = ""
				B738DR_wpt_eta17w = ""
				B738DR_wpt_id17m = ""
				B738DR_wpt_alt17m = ""
				B738DR_wpt_eta17m = ""
				B738DR_wpt_type17 = 0
			elseif n == 18 then
				B738DR_wpt_id18w = ""
				B738DR_wpt_alt18w = ""
				B738DR_wpt_eta18w = ""
				B738DR_wpt_id18m = ""
				B738DR_wpt_alt18m = ""
				B738DR_wpt_eta18m = ""
				B738DR_wpt_type18 = 0
			elseif n == 19 then
				B738DR_wpt_id19w = ""
				B738DR_wpt_alt19w = ""
				B738DR_wpt_eta19w = ""
				B738DR_wpt_id19m = ""
				B738DR_wpt_alt19m = ""
				B738DR_wpt_eta19m = ""
				B738DR_wpt_type19 = 0
			end
			
			B738DR_rte_show[n] = 0
		end
	end
	if rte_act_enable == 0 then
		B738DR_rte_show_act = 0
	end

end

function calc_dist(c_spd, c_vvi, c_d_alt)

	local calc_temp = 0
	local calc_time = 0
	
	calc_time = c_vvi / 60				-- ft/s
	calc_time = c_d_alt / calc_time		-- sec
	calc_temp = c_spd * 0.5144444444	-- m/s
	calc_temp = calc_temp * calc_time	-- m
	return  calc_temp * 0.0005399568	-- NM
	

end

function calc_alt(c_spd, c_vvi, c_dist)

	local calc_temp = 0
	local calc_time = 0
	
	calc_time = c_spd * 0.5144444444	-- m/s
	calc_time = c_dist * 1852 / calc_time 		-- sec
	calc_temp = c_vvi / 60				-- ft/s
	calc_temp = calc_temp * calc_time	-- sec
	return  calc_temp	-- delta alt
	

end

function vnav_timer()
	vnav_update = 1
end



function B738_vnav_calc4()

	local n = 0
	local ii = 0
	local jj = 0
	local kk = 0
	local delta_alt = 0
	local dist_10000 = 0
	local rest_idx_spd = 0
	local rest_idx_alt = 0
	local dist = 0
	local calc_wpt_alt = 0
	local calc_wpt_spd = 0
	local calc_wpt_alt_distr = 0
	local calc_vvi = 0
	local rest_idx = 0
	local rest_spd = 0
	local rest_alt = 0
	local rest_alt_t = 0
	local rest_alt_idx = 0
	local calc_spd_alt = 0
	
	local temp_d_R = 0
	local temp_brg = 0
	local temp_lat = 0
	local temp_lon = 0
	local lat_wpt = 0
	local lon_wpt = 0
	
	local from_spd = 0
	
	local td_spd_rest_loc = 0
	local skip_vpa = 0
	local discon = 0
	
	local recalc_spd = 0
	local recalc_alt = 0
	local first_idx_alt = 1
	
	local climb_calc_enable = 0
	
	
	local ed_fix_dist = 0
	local ignored = 0
	local idx_temp = 0
	local decel_idx_temp = 0
	local last_wpt_idx = 0
	local temp_idx = 0
	
	local offset2 = 0

	local nd_lat2 = 0
	local nd_lon2= 0
	local nd_lat = 0
	local nd_lon = 0
	local nd_y = 0
	local nd_x = 0
	
	local alt_calc_temp = 0
	local alt_calc_temp2 = 0
	
	local init_alt = 0
	local init_vvi = 0
	local init_distance = 0
	
	local pom5 = 0
	
	if vnav_update == 1 then
	
	if is_timer_scheduled(vnav_timer) == true then
		stop_timer(vnav_timer)
	end
	
	if crz_alt_num > 0 and legs_num > 0 and offset > 0 and cost_index ~= "***" and ref_icao ~= "----" and des_icao ~= "****" then
	
			-- if offset == 1 then
				-- offset2 = 2
			-- else
				-- offset2 = offset
			-- end
			if offset > legs_num then
				offset = legs_num
			end
			if offset == 0 then
				offset = 1
			end

			if legs_data[offset][1] == ref_icao and ground_air == 0 then
				offset2 = 2
			else
				offset2 = offset
			end

		--clear calculations data
		--if legs_num > 1 then
			for n = offset2, (legs_num + 1) do
				legs_data[n][10] = 0
				legs_data[n][11] = 0
				legs_data[n][14] = 50000
				--legs_data[n][13] = 0
			end
		--end




		------------------------------------------------
		
		-- CLIMB phase
		--tc_idx = 0
		
		--if td_idx ~= 0 and offset2 < td_idx then
		--if 1 == 2 then
		-- if discon == 0 and td_idx ~= 0 and offset2 < td_idx then
			-- climb_calc_enable = 1
		-- end
		-- if discon == 1 then
			-- climb_calc_enable = 1
		-- end
		climb_calc_enable = 0
		if B738DR_flight_phase < 2 then
			climb_calc_enable = 1
		end
		if ed_found ~= 0 then
			if offset2 > ed_found then
				climb_calc_enable = 0
			end
		end
		
		if climb_calc_enable == 1 then
			tc_idx = 0
			jj = legs_num + 1
			--for n = offset, legs_num do
			for n = offset2, (legs_num + 1) do
				if legs_data[n][1] == "DISCONTINUITY" then
					jj = n - 1
					break
				end
			end
			
			-- if simDR_radio_height_pilot_ft > 50 then
				-- calc_wpt_alt = simDR_altitude_pilot
				-- if simDR_airspeed_pilot < 160 then
					-- calc_wpt_spd = 160
				-- else
					calc_wpt_spd = simDR_airspeed_pilot
					calc_wpt_alt = simDR_altitude_pilot
				-- end
			-- else
				-- calc_wpt_alt = 0
				-- calc_wpt_spd = TAXI_SPEED	-- taxi speed
			-- end
			
			rest_idx_spd = 0
			if legs_restr_spd_n > 0 then
				for ii = 1, legs_restr_spd_n do
					rest_idx_spd = rest_idx_spd + 1
					--if legs_restr_spd[rest_idx_spd][2] >= offset then
					if legs_restr_spd[rest_idx_spd][2] >= offset2 then
						--rest_spd_found = 1
						break
					end
				end
			else
				rest_idx_spd = 1
			end
			rest_idx_alt = 0
			if legs_restr_alt_n > 0 then
				for ii = 1, legs_restr_alt_n do
					rest_idx_alt = rest_idx_alt + 1
					--if legs_restr_alt[rest_idx_alt][2] >= offset and legs_restr_alt[rest_idx_alt][2] <= jj then
					if legs_restr_alt[rest_idx_alt][2] >= offset2 and legs_restr_alt[rest_idx_alt][2] <= jj then
						first_idx_alt = rest_idx_alt
						break
					end
				end
			else
				rest_idx_alt = 1
			end
			
			--for n = offset, legs_num do
			for n = offset2, (legs_num + 1) do
			
				-- if legs_data[n][1] == "DISCONTINUITY" then
					--break
				-- end
				
				if rest_idx_spd <= legs_restr_spd_n then
					rest_spd = legs_restr_spd[rest_idx_spd][3]
					rest_idx = legs_restr_spd[rest_idx_spd][2]
				else
					rest_idx = 0
				end
			
				if rest_idx_alt <= legs_restr_alt_n then 
					rest_alt = legs_restr_alt[rest_idx_alt][3]
					rest_alt_t = legs_restr_alt[rest_idx_alt][4]
					rest_alt_idx = legs_restr_alt[rest_idx_alt][2]
				else
					rest_alt_idx = 0
				end
				
				recalc_spd = 0
				recalc_alt = 0
				
				--calc_vvi = 2250
				alt_calc_temp = math.max(3000, calc_wpt_alt)
				alt_calc_temp = math.min(41000, alt_calc_temp)
				alt_calc_temp = roundDownToIncrement(alt_calc_temp, 1000)
				alt_calc_temp2 = math.max(3000, crz_alt_num)
				alt_calc_temp2 = math.min(10000, alt_calc_temp2)
				alt_calc_temp2 = roundDownToIncrement(alt_calc_temp2, 1000)
				--roundDownToIncrement(number, increment)
				init_alt = 0
				init_vvi = 0
				for init_distance = alt_calc_temp, alt_calc_temp2, 1000 do
					init_vvi = init_vvi + vnav_vvi[init_distance]
					init_alt = init_alt + 1
				end
				if init_alt > 0 then
					calc_vvi = init_vvi / init_alt
				else
					calc_vvi = vnav_vvi[alt_calc_temp2]
				end
				-- alt_calc_temp = math.max(3000, calc_wpt_alt)
				-- alt_calc_temp = math.min(41000, alt_calc_temp)
				-- alt_calc_temp = roundUpToIncrement(alt_calc_temp, 1000)
				-- alt_calc_temp = vnav_vvi[alt_calc_temp]
				
				-- if calc_wpt_alt < 10000 then
					-- alt_calc_temp2 = math.max(3000, crz_alt_num)
					-- alt_calc_temp2 = math.min(10000, alt_calc_temp2)
					-- alt_calc_temp2 = roundUpToIncrement(alt_calc_temp2, 1000)
					-- alt_calc_temp2 = vnav_vvi[alt_calc_temp2]
				-- else
					-- alt_calc_temp2 = math.max(3000, crz_alt_num)
					-- alt_calc_temp2 = math.min(41000, alt_calc_temp2)
					-- alt_calc_temp2 = roundUpToIncrement(alt_calc_temp2, 1000)
					-- alt_calc_temp2 = vnav_vvi[alt_calc_temp2]
				-- end
				
				-- calc_vvi = (alt_calc_temp + alt_calc_temp2) / 2
					
				--if n == offset then  	--n == 1 then	--- offset == 1
				if n == offset2 then
					if rest_idx == offset2 then
						calc_wpt_spd = rest_spd
					else
						calc_wpt_spd = 250
					end
					if offset2 == 2 and offset2 ~= offset then
						calc_spd_alt = 250
						calc_wpt_alt = 0
						calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, legs_data[n][3])		-- calc alt
					elseif string.sub(B738DR_fpln_nav_id, 1, 2) == "RW" then	-- ADD == REF_ICAO !!!!!!!!!!!!!!!!
					--if simDR_radio_height_pilot_ft < 50 then
						--calc_spd_alt = calc_wpt_spd * (1 + (simDR_altitude_pilot / 1000 * 0.02))
						--calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, simDR_fmc_dist)		-- calc alt
						--calc_wpt_alt = 0
						--calc_wpt_spd = simDR_elevation_m * 3.28084
						calc_spd_alt = calc_wpt_spd
						if legs_data[n][1] ~= "VECTORS" then
							if offset2 == offset then
								calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, simDR_fmc_dist)		-- calc alt
							else
								calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, legs_data[n][3])		-- calc alt
							end
						end
					else
						calc_spd_alt = calc_wpt_spd * (1 + (simDR_altitude_pilot / 1000 * 0.02))
						--calc_wpt_alt = simDR_altitude_pilot
						if legs_data[n][1] ~= "VECTORS" then
							calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, simDR_fmc_dist)		-- calc alt
						else
							calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, legs_data[n][3])		-- calc alt
						end
					end
				else
					if calc_wpt_spd < 100 then
						calc_spd_alt = B738DR_fmc_climb_speed * (1 + (legs_data[n-1][11] / 1000 * 0.02))
					else
						calc_spd_alt = calc_wpt_spd * (1 + (legs_data[n-1][11] / 1000 * 0.02))
					end
					if legs_data[n][1] ~= "VECTORS" then
						calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, legs_data[n][3])		-- calc alt
					end
				end
				
					
				if calc_wpt_alt > crz_alt_num then
						calc_wpt_alt = crz_alt_num
					if n == 1 then		--- offset == 1
						
						delta_alt = crz_alt_num - simDR_altitude_pilot
						if calc_wpt_spd < 100 then
							calc_spd_alt = B738DR_fmc_climb_speed * (1 + (simDR_altitude_pilot / 1000 * 0.02))
						else
							calc_spd_alt = calc_wpt_spd * (1 + (simDR_altitude_pilot / 1000 * 0.02))
						end
						--calc_wpt_alt = simDR_altitude_pilot
						--calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, simDR_fmc_dist)		-- calc alt
					
						tc_dist = simDR_fmc_dist - calc_dist(calc_spd_alt, calc_vvi, delta_alt)	-- before dist
					
					else
					
						delta_alt = crz_alt_num - legs_data[n-1][11]
						
						if calc_wpt_spd < 100 then
							calc_spd_alt = B738DR_fmc_climb_speed * (1 + (legs_data[n-1][11] / 1000 * 0.02))
						else
							calc_spd_alt = calc_wpt_spd * (1 + (legs_data[n-1][11] / 1000 * 0.02))
						end
						
						tc_dist = legs_data[n][3] - calc_dist(calc_spd_alt, calc_vvi, delta_alt)	-- before dist
					
					end
						
					if tc_dist < 0 then
						tc_dist = 0
					end
					
					
					-- calc bearing
					nd_lat = math.rad(legs_data[n][7])
					nd_lon = math.rad(legs_data[n][8])
					if n == 1 then
						temp_brg = legs_data[n][2] + 3.1415926535
					else
						pom5 = n - 1
						if last_lat ~= 0 and last_lon ~= 0 and pom5 == offset2 then
							nd_lat2 = last_lat
							nd_lon2 = last_lon
						else
							nd_lat2 = math.rad(legs_data[n-1][7])
							nd_lon2 = math.rad(legs_data[n-1][8])
						end
						nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
						nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
						temp_brg = math.atan2(nd_y, nd_x)
					end
					
					tc_idx = n	-- before idx
					lat_wpt = math.rad(legs_data[n][7])
					lon_wpt = math.rad(legs_data[n][8])
					temp_d_R = tc_dist / 3440.064795					-- distance NM
					--temp_brg = legs_data[n][2] + 3.1415926535	-- back course radians
					temp_lat = math.asin(math.sin(lat_wpt)*math.cos(temp_d_R) + math.cos(lat_wpt)*math.sin(temp_d_R)*math.cos(temp_brg))
					temp_lon = lon_wpt + math.atan2(math.sin(temp_brg)*math.sin(temp_d_R)*math.cos(lat_wpt), math.cos(temp_d_R)-math.sin(lat_wpt)*math.sin(temp_lat))
					tc_lat = temp_lat
					tc_lon = temp_lon
				else
					if n == rest_idx then
						recalc_spd = 1
						calc_wpt_spd = rest_spd
					end
					if n == rest_alt_idx then
						if rest_alt_t ~= 43 then	-- not Above 
							if calc_wpt_alt > rest_alt then
								recalc_alt = 1
								--rest_wpt_alt = rest_alt
								--calc_wpt_alt = rest_alt
							end
						end
						rest_idx_alt = rest_idx_alt + 1
					end
				end
				
				if n > 1 then
					if calc_wpt_alt < 10000 then
						-- if calc_wpt_spd > 250 then
							calc_wpt_spd = 250
						-- end
					else
						if calc_wpt_alt < 26000 then
							calc_wpt_spd = B738DR_fmc_climb_speed
						else
							calc_wpt_spd = B738DR_fmc_climb_speed_mach
						end
					end
				end
				legs_data[n][10] = calc_wpt_spd
				legs_data[n][11] = calc_wpt_alt
				--legs_data[n][14] = 50000	-- rest alt
				
				-- RECALC_speed
				if recalc_spd == 1 then
				
							if rest_idx_spd == offset2 or rest_idx_spd == 1 then
								from_spd = offset2
								if simDR_radio_height_pilot_ft < 50 then
									calc_wpt_spd = TAXI_SPEED
									calc_wpt_alt = simDR_altitude_pilot	--simDR_elevation_m * 3.28084
								else
									if from_spd <= 1 then
										calc_wpt_alt = simDR_altitude_pilot --simDR_elevation_m * 3.28084
										calc_wpt_spd = TAXI_SPEED
									else
										calc_wpt_alt = simDR_altitude_pilot
										calc_wpt_spd = simDR_airspeed_pilot
									end
								end
							else
								from_spd = legs_restr_spd[rest_idx_spd-1][2]
								calc_wpt_alt = legs_data[from_spd][11]
								calc_wpt_spd = rest_spd
								from_spd = from_spd + 1
								
							end
							
							if from_spd > n then
								from_spd = n
							end
							
							for ii = from_spd, n do
								--calc_vvi = 2250
								-- alt_calc_temp = math.max(3000, calc_wpt_alt)
								-- alt_calc_temp = math.min(41000, alt_calc_temp)
								-- alt_calc_temp = roundUpToIncrement(alt_calc_temp, 1000)
				
								-- alt_calc_temp2 = math.max(3000, crz_alt_num)
								-- alt_calc_temp2 = math.min(41000, alt_calc_temp2)
								-- alt_calc_temp2 = roundUpToIncrement(alt_calc_temp2, 1000)
								-- alt_calc_temp2 = vnav_vvi[alt_calc_temp2]
								
								-- calc_vvi = (alt_calc_temp + alt_calc_temp2) / 2
								alt_calc_temp = math.max(3000, calc_wpt_alt)
								alt_calc_temp = math.min(41000, alt_calc_temp)
								alt_calc_temp = roundDownToIncrement(alt_calc_temp, 1000)
								alt_calc_temp2 = math.max(3000, crz_alt_num)
								alt_calc_temp2 = math.min(10000, alt_calc_temp2)
								alt_calc_temp2 = roundDownToIncrement(alt_calc_temp2, 1000)
								init_alt = 0
								init_vvi = 0
								for init_distance = alt_calc_temp, alt_calc_temp2, 1000 do
									init_vvi = init_vvi + vnav_vvi[init_distance]
									init_alt = init_alt + 1
								end
								if init_alt > 0 then
									calc_vvi = init_vvi / init_alt
								else
									calc_vvi = vnav_vvi[alt_calc_temp2]
								end
								
								if calc_wpt_alt < crz_alt_num then
									
									--if ii == offset then --or offset2 == 1 then
									--if ii == offset then --or offset2 == 1 then
									if ii == offset2 then
										if simDR_radio_height_pilot_ft < 50 then
											calc_wpt_spd = TAXI_SPEED
											calc_wpt_alt = simDR_altitude_pilot	--simDR_elevation_m * 3.28084
										else
											calc_spd_alt = simDR_airspeed_pilot * (1 + (simDR_altitude_pilot / 1000 * 0.02))
											calc_wpt_alt = simDR_altitude_pilot
											if legs_data[ii][1] ~= "VECTORS" then
												calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, simDR_fmc_dist)		-- calc alt
											end
										end
									else
										calc_wpt_spd = rest_spd
										calc_spd_alt = calc_wpt_spd * (1 + (legs_data[ii-1][11] / 1000 * 0.02))
										if legs_data[ii][1] ~= "VECTORS" then
											calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, legs_data[ii][3])		-- calc alt
										end
										-- if calc_wpt_spd < 100 then
											-- calc_spd_alt = B738DR_fmc_climb_speed * (1 + (legs_data[ii-1][11] / 1000 * 0.02))
										-- else
											-- calc_spd_alt = calc_wpt_spd * (1 + (legs_data[ii-1][11] / 1000 * 0.02))
										-- end
										-- calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, legs_data[ii][3])		-- calc alt
									end
									
									--calc_to_time = (legs_data[ii][3] * 1852) / (calc_spd_alt * 0.514)
									
									if calc_wpt_alt > legs_data[ii][14] then
										calc_wpt_alt = legs_data[ii][14]
									end
									
									if calc_wpt_alt > crz_alt_num then
										calc_wpt_alt = crz_alt_num
										-- T/C calc
										--if ii == offset then
										if ii == offset2 then
											delta_alt = crz_alt_num - simDR_altitude_pilot
											calc_wpt_spd = rest_spd
											calc_spd_alt = calc_wpt_spd * (1 + (simDR_altitude_pilot / 1000 * 0.02))
											tc_dist = simDR_fmc_dist - calc_dist(calc_spd_alt, calc_vvi, delta_alt)	-- before dist
											-- if calc_wpt_spd < 100 then
												-- calc_spd_alt = B738DR_fmc_climb_speed * (1 + (simDR_altitude_pilot / 1000 * 0.02))
											-- else
												-- calc_spd_alt = calc_wpt_spd * (1 + (simDR_altitude_pilot / 1000 * 0.02))
											-- end
											
											-- tc_dist = simDR_fmc_dist - calc_dist(calc_spd_alt, calc_vvi, delta_alt)	-- before dist
										else
											delta_alt = crz_alt_num - legs_data[ii-1][11]
											calc_wpt_spd = rest_spd
											calc_spd_alt = calc_wpt_spd * (1 + (legs_data[ii-1][11] / 1000 * 0.02))
											-- if calc_wpt_spd < 100 then
												-- calc_spd_alt = B738DR_fmc_climb_speed * (1 + (legs_data[ii-1][11] / 1000 * 0.02))
											-- else
												-- calc_spd_alt = calc_wpt_spd * (1 + (legs_data[ii-1][11] / 1000 * 0.02))
											-- end
											
											tc_dist = legs_data[ii][3] - calc_dist(calc_spd_alt, calc_vvi, delta_alt)	-- before dist
										end
										
										-- calc bearing
										nd_lat = math.rad(legs_data[ii][7])
										nd_lon = math.rad(legs_data[ii][8])
										if ii == 1 then
											temp_brg = legs_data[ii][2] + 3.1415926535
										else
											pom5 = ii - 1
											if last_lat ~= 0 and last_lon ~= 0 and pom5 == offset2 then
												nd_lat2 = last_lat
												nd_lon2 = last_lon
											else
												nd_lat2 = math.rad(legs_data[ii-1][7])
												nd_lon2 = math.rad(legs_data[ii-1][8])
											end
											nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
											nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
											temp_brg = math.atan2(nd_y, nd_x)
										end
										
										tc_idx = ii	-- before idx
										lat_wpt = math.rad(legs_data[ii][7])
										lon_wpt = math.rad(legs_data[ii][8])
										temp_d_R = tc_dist / 3440.064795					-- distance NM
										--temp_brg = legs_data[ii][2] + 3.1415926535	-- back course radians
										-- if ii == 1 then
											-- temp_brg = math.rad((math.deg(legs_data[ii][2]) + 180)%360)	-- back course radians
										-- else
											-- temp_lat = math.sin(lon_wpt-legs_data[ii-1][8]) * math.cos(lat_wpt)
											-- temp_lon = math.cos(lat_wpt)*math.sin(legs_data[ii-1][7])-math.sin(lat_wpt)*math.cos(legs_data[ii][7])*math.cos(lon_wpt-legs_data[ii-1][8])
											-- temp_brg = math.atan2(temp_lat,temp_lon)	-- back course radians
										-- end
										--temp_brg = math.rad((math.deg(legs_data[ii][2]) + 180)%360)	-- back course
										temp_lat = math.asin(math.sin(lat_wpt)*math.cos(temp_d_R) + math.cos(lat_wpt)*math.sin(temp_d_R)*math.cos(temp_brg))
										temp_lon = lon_wpt + math.atan2(math.sin(temp_brg)*math.sin(temp_d_R)*math.cos(lat_wpt), math.cos(temp_d_R)-math.sin(lat_wpt)*math.sin(temp_lat))
										tc_lat = temp_lat
										tc_lon = temp_lon
									end
								
								end
								if calc_wpt_alt < 10000 then
									if rest_spd > 250 then
										calc_wpt_spd = 250
									else
										calc_wpt_spd = rest_spd
									end
								else
									if calc_wpt_alt < 26000 then
										if rest_spd > B738DR_fmc_climb_speed then
											calc_wpt_spd = B738DR_fmc_climb_speed
										else
											calc_wpt_spd = rest_spd
										end
									else
										calc_wpt_spd = B738DR_fmc_climb_speed_mach
									end
								end
								legs_data[ii][11] = calc_wpt_alt
								legs_data[ii][10] = calc_wpt_spd
							end
						--end
						
--						rest_idx_spd = rest_idx_spd + 1
						
					--end
					rest_idx_spd = rest_idx_spd + 1
				end
				
				
				-- RECALC alt
				if recalc_alt == 1 then
					--if offset > 0 then
					if offset2 > 0 then
						--if rest_idx_alt == 1 then
						if rest_idx_alt == 2 then
							--from_spd = offset
							from_spd = offset2
							--calc_wpt_alt = legs_data[from_spd][11]
							--from_spd = from_spd
							--calc_wpt_spd = legs_data[from_spd][10]
						--elseif rest_idx_alt == offset then
						elseif rest_idx_alt == offset2 then
							--from_spd = offset
							from_spd = offset2
							--calc_wpt_alt = legs_data[from_spd][11]
							--from_spd = from_spd
							--calc_wpt_spd = legs_data[from_spd][10]
						else
							from_spd = legs_restr_alt[rest_idx_alt-2][2]
							--calc_wpt_alt = legs_data[from_spd][11]
							from_spd = from_spd + 1
							--calc_wpt_spd = legs_data[from_spd][10]
						end
						if from_spd > n then
							from_spd = n
						end
						
						for ii = from_spd, n do
							--calc_vvi = 2250
							--if calc_wpt_alt < crz_alt_num then
							--if calc_wpt_alt < rest_alt then
							
							calc_wpt_spd = legs_data[ii][10]
							calc_wpt_alt = legs_data[ii][11]
							
							if calc_wpt_alt > rest_alt then
								
								-- if ii == offset then --or offset2 == 1 then
									-- calc_spd_alt = simDR_airspeed_pilot * (1 + (simDR_altitude_pilot / 1000 * 0.02))
									-- calc_wpt_alt = simDR_altitude_pilot
									-- calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, simDR_fmc_dist)		-- calc alt
								-- else
									-- if calc_wpt_spd < 100 then
										-- calc_spd_alt = B738DR_fmc_climb_speed * (1 + (legs_data[ii-1][11] / 1000 * 0.02))
									-- else
										-- calc_spd_alt = calc_wpt_spd * (1 + (legs_data[ii-1][11] / 1000 * 0.02))
									-- end
									-- calc_wpt_alt = calc_wpt_alt + calc_alt(calc_spd_alt, calc_vvi, legs_data[ii][3])		-- calc alt
								-- end
								-- if calc_wpt_alt < 10000 then
									-- if calc_wpt_spd > 250 or calc_wpt_spd < 100 then
										-- calc_wpt_spd = 250
									-- end
								-- else
									-- if calc_wpt_alt < 26000 then
										-- if calc_wpt_spd > B738DR_fmc_climb_speed or calc_wpt_spd < 100 then
											-- calc_wpt_spd = B738DR_fmc_climb_speed
										-- end
									-- else
										-- if calc_wpt_spd < 100 and calc_wpt_spd > B738DR_fmc_climb_speed_mach then
											-- calc_wpt_spd = B738DR_fmc_climb_speed_mach
										-- end
									-- end
								-- end
								-- if calc_wpt_alt > crz_alt_num then
									-- calc_wpt_alt = crz_alt_num
									-- if ii == ofset then
										-- delta_alt = crz_alt_num - simDR_altitude_pilot
										-- calc_spd_alt = B738DR_fmc_climb_speed * (1 + (simDR_altitude_pilot / 1000 * 0.02))
									-- else
										-- delta_alt = crz_alt_num - legs_data[ii-1][11]
										-- if calc_wpt_spd < 100 then
											-- calc_spd_alt = B738DR_fmc_climb_speed * (1 + (legs_data[ii-1][11] / 1000 * 0.02))
										-- else
											-- calc_spd_alt = calc_wpt_spd * (1 + (legs_data[ii-1][11] / 1000 * 0.02))
										-- end
									-- end
									
									-- tc_dist = legs_data[ii][3] - calc_dist(calc_spd_alt, calc_vvi, delta_alt)	-- before dist
									
									-- tc_idx = ii	-- before idx
									-- lat_wpt = legs_data[ii][7]
									-- lon_wpt = legs_data[ii][8]
									-- temp_d_R = tc_dist / 3440.064795					-- distance NM
									-- temp_brg = math.rad((math.deg(legs_data[ii][2]) + 180)%360)	-- back course
									-- temp_lat = math.asin(math.sin(lat_wpt)*math.cos(temp_d_R) + math.cos(lat_wpt)*math.sin(temp_d_R)*math.cos(temp_brg))
									-- temp_lon = lon_wpt + math.atan2(math.sin(temp_brg)*math.sin(temp_d_R)*math.cos(lat_wpt), math.cos(temp_d_R)-math.sin(lat_wpt)*math.sin(temp_lat))
									-- tc_lat = temp_lat
									-- tc_lon = temp_lon
								-- end
								-- if calc_wpt_alt > rest_alt then
									-- calc_wpt_alt = rest_alt
								-- end
								calc_wpt_alt = rest_alt
								if calc_wpt_alt < 10000 then
									if calc_wpt_spd > 250 or calc_wpt_spd < 100 then
										calc_wpt_spd = 250
									end
								else
									if calc_wpt_alt < 26000 then
										if calc_wpt_spd > B738DR_fmc_climb_speed or calc_wpt_spd < 100 then
											calc_wpt_spd = B738DR_fmc_climb_speed
										end
									else
										if calc_wpt_spd < 100 and calc_wpt_spd > B738DR_fmc_climb_speed_mach then
											calc_wpt_spd = B738DR_fmc_climb_speed_mach
										end
									end
								end
								legs_data[ii][10] = calc_wpt_spd
								legs_data[ii][11] = calc_wpt_alt
								legs_data[ii][14] = rest_alt
								
								--legs_data[ii][11] = calc_wpt_alt
								--legs_data[ii][14] = rest_alt		-- rest alt
							-- else
								-- calc_wpt_alt = legs_data[ii][11]
							end
							--calc_wpt_spd = legs_data[ii][10]
							-- if tc_idx ~= 0 then
								-- break
							-- end
						end
					end
				end
				
			
				if tc_idx ~= 0 then
					break
				end
			end
		end
		
		
		
		
		
		-- Find E/D, T/D and DECEL
--		if B738DR_flight_phase < 5 then --and tc_idx ~= 0 then 
		if true then
			
			td_idx = 0
			--n = offset2
			
			-- find E/D
			ed_found = 0
			discon = 0
			-- if legs_num > 1 then	-- > 2
				for ii = 1, (legs_num + 1) do
					-- if legs_data[ii][1] == "DISCONTINUITY" then
						-- --discon = 1
						-- discon = 0
						-- --break
					-- end
					if legs_data[ii][1] == id_ed then
						ed_found = ii
						ed_alt = legs_data[ed_found][5]
						ed_dist = (crz_alt_num - ed_alt) / math.tan(math.rad(econ_des_vpa))		-- ft
						ed_dist = ed_dist * 0.00016458		-- NM
						break
					end
				end
			-- else
				-- discon = 1
			-- end
			
			-- find T/D
			-- discon = 0
			if discon == 0 then
				--td_found = 0
				td_dist = 0 
				decel_idx = 0
				skip_vpa = 0
				if ed_found == 0 then	-- not found e/d
					ed_found = legs_num + 1
					ed_alt = 2500	--4000
					ed_dist = (crz_alt_num - ed_alt) / math.tan(math.rad(econ_des_vpa))		-- ft
					ed_dist = ed_dist * 0.00016458		-- NM
					if legs_data[ed_found][1] == nil then
						skip_vpa = 1
					end
				end
				if skip_vpa == 0 then
					
					-- find T/D
					last_wpt_idx = 0
					for ii = ed_found, 2, -1 do
						
						if legs_data[ii][1] ~= "VECTORS" then
							td_dist = td_dist + legs_data[ii][3]
						end
						if ii == ed_found then
							calc_wpt_alt = ed_alt
						else
							calc_wpt_alt = calc_wpt_alt + ((legs_data[ii+1][3] * (math.tan(math.rad(econ_des_vpa)))) * 6076.11549) -- ft
						end
						if calc_wpt_alt > crz_alt_num then
							calc_wpt_alt = crz_alt_num
						end
						legs_data[ii][11] = calc_wpt_alt
						last_wpt_idx = ii
						
						if td_dist > ed_dist then
							
							-- calc bearing
							nd_lat = math.rad(legs_data[ii][7])
							nd_lon = math.rad(legs_data[ii][8])
							if ii == 1 then
								temp_brg = legs_data[ii][2] + 3.1415926535
							else
								pom5 = ii - 1
								if last_lat ~= 0 and last_lon ~= 0 and pom5 == offset2 then
									nd_lat2 = last_lat
									nd_lon2 = last_lon
								else
									nd_lat2 = math.rad(legs_data[ii-1][7])
									nd_lon2 = math.rad(legs_data[ii-1][8])
								end
								nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
								nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
								temp_brg = math.atan2(nd_y, nd_x)
							end
							td_dist = legs_data[ii][3] - (td_dist - ed_dist)
							td_idx = ii 	-- before idx
							lat_wpt = math.rad(legs_data[ii][7])
							lon_wpt = math.rad(legs_data[ii][8])
							temp_d_R = td_dist / 3440.064795					-- distance NM
							--temp_brg = legs_data[ii][2] + 3.1415926535
							-- temp_brg = math.rad((math.deg(legs_data[ii][2]) + 180)%360)	-- back course
							temp_lat = math.asin(math.sin(lat_wpt)*math.cos(temp_d_R) + math.cos(lat_wpt)*math.sin(temp_d_R)*math.cos(temp_brg))
							temp_lon = lon_wpt + math.atan2(math.sin(temp_brg)*math.sin(temp_d_R)*math.cos(lat_wpt), math.cos(temp_d_R)-math.sin(lat_wpt)*math.sin(temp_lat))
							td_lat = temp_lat
							td_lon = temp_lon
							break
						end
					end
					

					-- find altitude restrict between T/C and T/D
					if tc_idx == 0 then
						jj = 2	--offset
					else
						if tc_idx > td_idx then
							jj = 2
						else
							jj = tc_idx
						end
					end
					
					td_fix_dist = 0		-- distance before td_fix_idx
					td_fix_idx = 0		-- td_fix_idx
					ed_fix_found = 0	-- ed fix idx
					ed_fix_alt = 0		-- ed alt fix idx
					ed_fix_dist = 0		-- ed fix distance (local)
					ed_fix_found2 = {}
					ed_fix_alt2 = {}
					--ed_fix_dist2 = {}
					--td_fix_idx2 = {}
					--td_fix_dist2 = {}
					ed_fix_num = 0
					
					
					-- restrict alt
					for ii = 1, legs_restr_alt_n do
						if legs_restr_alt[ii][2] >= jj and legs_restr_alt[ii][2] < ed_found then
							idx_temp = legs_restr_alt[ii][2]
							ignored = 0
							if legs_restr_alt[ii][4] == 45 then	-- Below
								if legs_data[idx_temp][11] == 0 then
									if crz_alt_num <= legs_restr_alt[ii][3] then
										ignored = 1
									end
								else
									if legs_data[idx_temp][11] <= legs_restr_alt[ii][3] then
										ignored = 1
									end
								end
							elseif legs_restr_alt[ii][4] == 43 then	-- Above
								if legs_data[idx_temp][11] == 0 then
									if crz_alt_num >= legs_restr_alt[ii][3] then
										ignored = 1
									end
								else
									if legs_data[idx_temp][11] >= legs_restr_alt[ii][3] then
										ignored = 1
									end
								end
							else
								if legs_data[idx_temp][11] == 0 then
									if crz_alt_num == legs_restr_alt[ii][3] then
										ignored = 1
									end
								else
									if legs_data[idx_temp][11] == legs_restr_alt[ii][3] then
										ignored = 1
									end
								end
							end
							
							if ignored == 0 then
								
								--calculate T/D
								--td_fix_dist = 0		-- distance before td_fix_idx
								--td_fix_idx = 0		-- td_fix_idx
								
								--ed_fix_found = 0	-- ed fix idx
								--ed_fix_alt = 0		-- ed alt fix idx
								--ed_fix_dist = 0		-- ed fix distance (local)
								
								ed_fix_found = idx_temp
								
								ed_fix_num = ed_fix_num + 1
								ed_fix_found2[ed_fix_num] = ed_fix_found
								
								if ed_fix_num == 1 then
									td_dist = 0
									td_idx = 0
								end
								
								if legs_restr_alt[ii][4] == 45 then		-- Below
									ed_fix_alt = legs_restr_alt[ii][3] - 500
								else
									ed_fix_alt = legs_restr_alt[ii][3]
								end
								
								ed_fix_alt2[ed_fix_num] = ed_fix_alt
								
								
								legs_data[ed_fix_found][11] = ed_fix_alt
								
								if ed_fix_num == 1 then
									ed_dist = (crz_alt_num - ed_fix_alt) / math.tan(math.rad(econ_des_vpa))		-- ft
									ed_dist = ed_dist * 0.00016458		-- NM
									n = jj
								else
									n = ed_fix_found2[(ed_fix_num-1)] + 1
								end
								
								--ed_fix_dist2[ed_fix_found2_num] = ed_fix_dist
								
								last_wpt_idx = 0
								for kk = ed_fix_found, n, -1 do
									
									if ed_fix_num == 1 then
										if legs_data[kk][1] ~= "VECTORS" then
											td_dist = td_dist + legs_data[kk][3]
										end
									end
									if kk == ed_fix_found then
										calc_wpt_alt = ed_fix_alt
									else
										calc_wpt_alt = calc_wpt_alt + ((legs_data[kk+1][3] * (math.tan(math.rad(econ_des_vpa)))) * 6076.11549) -- ft
									end
									if calc_wpt_alt > crz_alt_num then
										calc_wpt_alt = crz_alt_num
									end
									legs_data[kk][11] = calc_wpt_alt
									last_wpt_idx = kk
									
									if td_dist > ed_dist and ed_fix_num == 1 then
										
										-- calc bearing
										nd_lat = math.rad(legs_data[kk][7])
										nd_lon = math.rad(legs_data[kk][8])
										if kk == 1 then
											temp_brg = legs_data[kk][2] + 3.1415926535
										else
											pom5 = kk - 1
											if last_lat ~= 0 and last_lon ~= 0 and pom5 == offset2 then
												nd_lat2 = last_lat
												nd_lon2 = last_lon
											else
												nd_lat2 = math.rad(legs_data[kk-1][7])
												nd_lon2 = math.rad(legs_data[kk-1][8])
											end
											nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
											nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
											temp_brg = math.atan2(nd_y, nd_x)
										end
										td_dist = legs_data[kk][3] - (td_dist - ed_dist)
										td_idx = kk 	-- before idx
										lat_wpt = math.rad(legs_data[kk][7])
										lon_wpt = math.rad(legs_data[kk][8])
										temp_d_R = td_dist / 3440.064795					-- distance NM
										--temp_brg = legs_data[kk][2] + 3.1415926535
										-- temp_brg = math.rad((math.deg(legs_data[kk][2]) + 180)%360)	-- back course
										temp_lat = math.asin(math.sin(lat_wpt)*math.cos(temp_d_R) + math.cos(lat_wpt)*math.sin(temp_d_R)*math.cos(temp_brg))
										temp_lon = lon_wpt + math.atan2(math.sin(temp_brg)*math.sin(temp_d_R)*math.cos(lat_wpt), math.cos(temp_d_R)-math.sin(lat_wpt)*math.sin(temp_lat))
										td_lat = temp_lat
										td_lon = temp_lon
										break
									end
									if ed_fix_num > 1 and calc_wpt_alt > ed_fix_alt2[ed_fix_num-1] then
										legs_data[kk][11] = ed_fix_alt2[ed_fix_num-1]
										break
									end
								end
							end -- ignored
							
						end
					end
					
					-- calculate speed for waypoints
					if td_idx == 0 then
						last_wpt_idx = offset2
					else
						last_wpt_idx = td_idx
					end
					-- set restrict idx
					rest_idx_spd = 0
					if legs_restr_spd_n > 0 then
						for ii = 1, legs_restr_spd_n do
							rest_idx_spd = rest_idx_spd + 1
							if legs_restr_spd[rest_idx_spd][2] >= last_wpt_idx then
								break
							end
						end
					else
						rest_idx_spd = 1
					end
					
					if last_wpt_idx <= ed_found then
						for ii = last_wpt_idx, ed_found do
							if rest_idx_spd <= legs_restr_spd_n then
								rest_spd = legs_restr_spd[rest_idx_spd][3]
								rest_idx = legs_restr_spd[rest_idx_spd][2]
							else
								rest_idx = 0
							end
							-- descent phase
							if ii == rest_idx then
								td_spd_rest_loc = 1
								calc_wpt_spd = rest_spd
								rest_idx_spd = rest_idx_spd + 1
								if decel_idx == 0 and ii >= offset2 then
									if ii == offset2 then
										if simDR_fmc_dist > 6.7 then
											-- DECEL calc
											
											-- calc bearing
											nd_lat = math.rad(legs_data[ii][7])
											nd_lon = math.rad(legs_data[ii][8])
											if ii == 1 then
												temp_brg = legs_data[ii][2] + 3.1415926535
											else
												pom5 = ii - 1
												if last_lat ~= 0 and last_lon ~= 0 and pom5 == offset2 then
													nd_lat2 = last_lat
													nd_lon2 = last_lon
												else
													nd_lat2 = math.rad(legs_data[ii-1][7])
													nd_lon2 = math.rad(legs_data[ii-1][8])
												end
												nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
												nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
												temp_brg = math.atan2(nd_y, nd_x)
											end
											decel_dist = 6.7 -- before dist (6.7NM)
											decel_idx = ii
											lat_wpt = math.rad(legs_data[ii][7])
											lon_wpt = math.rad(legs_data[ii][8])
											temp_d_R = decel_dist / 3440.064795					-- distance NM
											--temp_brg = legs_data[ii][2] + 3.1415926535
											--temp_brg = math.rad((math.deg(legs_data[ii][2]) + 180)%360)	-- back course
											temp_lat = math.asin(math.sin(lat_wpt)*math.cos(temp_d_R) + math.cos(lat_wpt)*math.sin(temp_d_R)*math.cos(temp_brg))
											temp_lon = lon_wpt + math.atan2(math.sin(temp_brg)*math.sin(temp_d_R)*math.cos(lat_wpt), math.cos(temp_d_R)-math.sin(lat_wpt)*math.sin(temp_lat))
											decel_lat = temp_lat
											decel_lon = temp_lon
										end
									else
										-- DECEL calc
										--decel_idx = ii
										if legs_data[ii][3] < 6.7 and ii > 1 then
											--decel_before_idx = ii - 1
											--legs_restr_spd[ii][4] = decel_before_idx
											
											---------------------------------
											-- if ii-1 is restrict wpt then
											---------------------------------
											if legs_data[ii-1][4] == 0 then		-- speed restrict
												-- calc bearing
												nd_lat = math.rad(legs_data[ii-1][7])
												nd_lon = math.rad(legs_data[ii-1][8])
												if ii == 1 then
													temp_brg = legs_data[ii][2] + 3.1415926535
												else
													pom5 = ii - 2
													if last_lat ~= 0 and last_lon ~= 0 and pom5 == offset2 then
														nd_lat2 = last_lat
														nd_lon2 = last_lon
													else
														nd_lat2 = math.rad(legs_data[ii-2][7])
														nd_lon2 = math.rad(legs_data[ii-2][8])
													end
													nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
													nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
													temp_brg = math.atan2(nd_y, nd_x)
												end
												decel_idx = ii - 1
												lat_wpt = math.rad(legs_data[ii-1][7])
												lon_wpt = math.rad(legs_data[ii-1][8])
												decel_dist = 6.7 - legs_data[ii][3]
												if legs_data[ii-1][3] < decel_dist then
													decel_dist = legs_data[ii-1][3] - 0.3
												end
											else
												decel_dist = legs_data[ii][3] - 0.3 -- 0.3 NM before
												-- calc bearing
												nd_lat = math.rad(legs_data[ii][7])
												nd_lon = math.rad(legs_data[ii][8])
												pom5 = ii - 1
												if last_lat ~= 0 and last_lon ~= 0 and pom5 == offset2 then
													nd_lat2 = last_lat
													nd_lon2 = last_lon
												else
													nd_lat2 = math.rad(legs_data[ii-1][7])
													nd_lon2 = math.rad(legs_data[ii-1][8])
												end
												nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
												nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
												temp_brg = math.atan2(nd_y, nd_x)
												decel_idx = ii
												lat_wpt = math.rad(legs_data[ii][7])
												lon_wpt = math.rad(legs_data[ii][8])
											end
										else
											decel_dist = 6.7 -- before dist (6.7NM)
											--decel_before_idx = ii
											--legs_restr_spd[ii][4] = decel_before_idx
											
											-- calc bearing
											nd_lat = math.rad(legs_data[ii][7])
											nd_lon = math.rad(legs_data[ii][8])
											if ii == 1 then
												temp_brg = legs_data[ii][2] + 3.1415926535
											else
												pom5 = ii - 1
												if last_lat ~= 0 and last_lon ~= 0 and pom5 == offset2 then
													nd_lat2 = last_lat
													nd_lon2 = last_lon
												else
													nd_lat2 = math.rad(legs_data[ii-1][7])
													nd_lon2 = math.rad(legs_data[ii-1][8])
												end
												nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
												nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
												temp_brg = math.atan2(nd_y, nd_x)
											end
											decel_idx = ii
											lat_wpt = math.rad(legs_data[ii][7])
											lon_wpt = math.rad(legs_data[ii][8])
											--temp_brg = legs_data[ii][2] + 3.1415926535
										end
										temp_d_R = decel_dist / 3440.064795					-- distance NM
										--temp_brg = math.rad((math.deg(legs_data[ii][2]) + 180)%360)	-- back course
										temp_lat = math.asin(math.sin(lat_wpt)*math.cos(temp_d_R) + math.cos(lat_wpt)*math.sin(temp_d_R)*math.cos(temp_brg))
										temp_lon = lon_wpt + math.atan2(math.sin(temp_brg)*math.sin(temp_d_R)*math.cos(lat_wpt), math.cos(temp_d_R)-math.sin(lat_wpt)*math.sin(temp_lat))
										decel_lat = temp_lat
										decel_lon = temp_lon
									end
								end
							end
							calc_wpt_alt = legs_data[ii][11]
							if td_spd_rest_loc == 0 then
								if calc_wpt_alt < 26000 then
									if calc_wpt_spd < 100 then
										calc_wpt_spd = B738DR_fmc_descent_speed
									else
										if calc_wpt_spd > B738DR_fmc_descent_speed then
											calc_wpt_spd = B738DR_fmc_descent_speed
										end
									end
								else
									calc_wpt_spd = B738DR_fmc_descent_speed_mach
								end
							end
							if calc_wpt_alt < 10000 then
								if calc_wpt_spd > 250 then
									calc_wpt_spd = 250
								end
							end
							legs_data[ii][10] = calc_wpt_spd
						end
					end
					
				end
			end
		end
		
		
		-- CRUISE
		if td_idx > 1 then
		--if 1 == 2 then
		
			calc_wpt_alt = crz_alt_num
			if crz_alt_num < 26000 then
				calc_wpt_spd = B738DR_fmc_cruise_speed
			else
				calc_wpt_spd = B738DR_fmc_cruise_speed_mach
			end
			if calc_wpt_alt < 10000 then
				if calc_wpt_spd > 250 then
					calc_wpt_spd = 250
				end
			end
			n = td_idx - 1
			if tc_idx ~= 0 and tc_idx <= td_idx then
				if tc_idx <= n then
					for ii = tc_idx, n do
						-- cruise phase
						legs_data[ii][10] = calc_wpt_spd
						legs_data[ii][11] = crz_alt_num
					end
				end
			else
				if tc_idx == 0 then
					if offset2 <= n then
						for ii = offset2, n do
							-- cruise phase
							legs_data[ii][10] = calc_wpt_spd
							legs_data[ii][11] = crz_alt_num
						end
					end
				else
					legs_data[n][10] = calc_wpt_spd 
					legs_data[n][11] = crz_alt_num
				end
			end
		end
		
	else
		if legs_num > 1 then
			for n = 1, (legs_num + 1) do
				legs_data[n][10] = 0
				legs_data[n][11] = 0
				legs_data[n][14] = 50000
			end
		end
		tc_idx = 0
		td_idx = 0
		ed_found = 0
		td_fix_idx = 0
		decel_idx = 0
		ed_fix_found = 0
		ed_fix_alt = 0
		ed_alt = 0

	
	end
	
	-- check alt constraint
	if msg_chk_alt_constr == 0 and td_idx ~= 0 then
		
		for n = td_idx, legs_num do
			if legs_data[n][5] ~= 0 and legs_data[n][11] ~= 0
			and legs_data[n][1] ~= "DISCONTINUITY" and legs_data[n][1] ~= "VECTORS" then
				if legs_data[n][6] == 45 then -- below
					if legs_data[n][11] > legs_data[n][5] then
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = ALT_CONSTRAINT .. legs_data[n][1]
						simCMD_nosmoking_toggle:once()
						fms_msg_sound = 1
					end
				elseif legs_data[n][6] == 43 then -- above
					if legs_data[n][11] < legs_data[n][5] then
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = ALT_CONSTRAINT .. legs_data[n][1]
						simCMD_nosmoking_toggle:once()
						fms_msg_sound = 1
					end
				else
					if legs_data[n][11] ~= legs_data[n][5] then
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = ALT_CONSTRAINT .. legs_data[n][1]
						simCMD_nosmoking_toggle:once()
						fms_msg_sound = 1
					end
				end
			end
		end
		msg_chk_alt_constr = 1
	end
	
	if legs_delete == 0 and calc_rte_enable == 0 then
		copy_to_legsdata2()
	end
	
	vnav_update = 0
	
	end
	
	if is_timer_scheduled(vnav_timer) == false then
		run_after_time(vnav_timer, 5)	-- 5 seconds
	end

end


function B738_displ_tc()
	local ils_lat = math.rad(simDR_latitude) 
	local ils_lon = math.rad(simDR_longitude) 
	local mag_hdg = 0
	local delta_ils_hdg = 0
	local ils_hdg = 0
	local ils_on_off = 0
	local ils_x = 0
	local ils_y = 0
	local ils_dis = 0
	local ils_zoom = 0
	local ils_disable = 0
	local ils_corr = 0
	
	if legs_num > 0 then -- and legs_step <= legs_num then
	
		-- if offset == 0 then
			-- offset = 1
		-- end
	
	if map_mode == 3 then
		if legs_step == 0 then
			ils_lat = math.rad(legs_data[1][7])
			ils_lon = math.rad(legs_data[1][8])
		else
			ils_lat = math.rad(legs_data[legs_step][7])
			ils_lon = math.rad(legs_data[legs_step][8])
		end
		mag_hdg = -simDR_mag_variation
	else
		if B738DR_capt_map_mode < 2 then
			mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
			-- if simDR_efis_map_mode == 0 then
			if B738DR_capt_map_mode == 1 and simDR_efis_map_mode == 0 then
				ils_disable = 1
			end
		-- elseif simDR_efis_sub_mode == 4 then
			-- ils_disable = 1
		else
			mag_hdg = simDR_mag_hdg - simDR_mag_variation
		end
	end
	if tc_idx == 0 or B738DR_flight_phase > 1 then
		ils_disable = 1
	end
		
		
	if ils_disable == 0 then
		
		
		-- Calculate distance
		
		ils_x = (tc_lon - ils_lon) * math.cos((ils_lat + tc_lat)/2)
		ils_y = tc_lat - ils_lat
		ils_dis = math.sqrt(ils_x*ils_x + ils_y*ils_y) * 3440.064795	--nm
		
		ils_y = math.sin(tc_lon - ils_lon) * math.cos(tc_lat)
		ils_x = math.cos(ils_lat) * math.sin(tc_lat) - math.sin(ils_lat) * math.cos(tc_lat) * math.cos(tc_lon - ils_lon)
		ils_hdg = math.atan2(ils_y, ils_x)
		ils_hdg = math.deg(ils_hdg)
		ils_hdg = (ils_hdg + 360) % 360
		
		delta_ils_hdg = ((((ils_hdg - mag_hdg) % 360) + 540) % 360) - 180
		
		if delta_ils_hdg >= 0 and delta_ils_hdg <= 90 then
			-- right
			ils_on_off = 1
			delta_ils_hdg = 90 - delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = ils_dis * math.sin(delta_ils_hdg)
			ils_x = ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg < 0 and delta_ils_hdg >= -90 then
			-- left
			ils_on_off = 1
			delta_ils_hdg = 90 + delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = ils_dis * math.sin(delta_ils_hdg)
			ils_x = -ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg >= 90 then
			-- right back
			ils_on_off = 1
			delta_ils_hdg = delta_ils_hdg - 90
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = -ils_dis * math.sin(delta_ils_hdg)
			ils_x = ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg <= -90 then
			-- left back
			ils_on_off = 1
			delta_ils_hdg = -90 - delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = -ils_dis * math.sin(delta_ils_hdg)
			ils_x = -ils_dis * math.cos(delta_ils_hdg)
		end

		if B738DR_efis_map_range_capt == 0 then	-- 5 NM
			ils_zoom = 2
		elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
			ils_zoom = 1
		elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
			ils_zoom = 0.5
		elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
			ils_zoom = 0.25
		elseif B738DR_efis_map_range_capt == 4 then	-- 80 NM
			ils_zoom = 0.125
		elseif B738DR_efis_map_range_capt == 5 then	-- 160 NM
			ils_zoom = 0.0625
		elseif B738DR_efis_map_range_capt == 6 then	-- 320 NM
			ils_zoom = 0.03125
		else	-- 640 NM
			ils_zoom = 0.015625
			--ils_on_off = 0
		end
		
		ils_x = ils_x * ils_zoom		-- zoom
		ils_y = ils_y * ils_zoom		-- zoom
		-- if simDR_efis_sub_mode == 4 then
			-- ils_y = ils_y + 4.1	-- adjust
		-- end
		
		if map_mode == 3 then
			ils_y = ils_y + 4.1	-- adjust center
		elseif B738DR_capt_map_mode == 0 and simDR_efis_map_mode == 0 then
			ils_y = ils_y + 4.1	-- adjust center
		else
			if B738DR_capt_map_mode == 3 then
				ils_y = ils_y + 4.1	-- adjust
			end
		end
		-- if ils_x < -6.0 or ils_x > 6.0 then
			-- ils_on_off = 0
		-- end
		-- if ils_x < 0 then
			-- ils_corr = B738_rescale(-6.0, 6.3, 0, 8.7, ils_x)
		-- else
			-- ils_corr = B738_rescale(0, 8.7, 6.0, 6.3, ils_x)
		-- end
		-- if ils_y > ils_corr or ils_y < -1 then
			-- ils_on_off = 0
		-- end
		if ils_x < -8.0 or ils_x > 8.0 then
			ils_on_off = 0
		end
		if ils_y > 11.0 or ils_y < -2 then
			ils_on_off = 0
		end
			
		if ils_on_off == 1 then
			B738DR_tc_x = ils_x
			B738DR_tc_y = ils_y
			B738DR_tc_id = "T/C"
			B738DR_tc_show = 1
		else
			B738DR_tc_show = 0
			B738DR_tc_id = ""
		end
	else
		B738DR_tc_show = 0
		B738DR_tc_id = ""
	end
	
	else
		B738DR_tc_show = 0
		B738DR_tc_id = ""
	end

end

function B738_displ_decel()
	local ils_lat = math.rad(simDR_latitude) 
	local ils_lon = math.rad(simDR_longitude) 
	local mag_hdg = 0
	local delta_ils_hdg = 0
	local ils_hdg = 0
	local ils_on_off = 0
	local ils_x = 0
	local ils_y = 0
	local ils_dis = 0
	local ils_zoom = 0
	local ils_disable = 0
	local ils_corr = 0
	
	if legs_num > 0 then --and legs_step <= legs_num then
	
	if map_mode == 3 then
		if legs_step == 0 then
			ils_lat = math.rad(legs_data[1][7])
			ils_lon = math.rad(legs_data[1][8])
		else
			ils_lat = math.rad(legs_data[legs_step][7])
			ils_lon = math.rad(legs_data[legs_step][8])
		end
		mag_hdg = -simDR_mag_variation
	else
		if B738DR_capt_map_mode < 2 then
			mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
			-- if simDR_efis_map_mode == 0 then
			if B738DR_capt_map_mode == 1 and simDR_efis_map_mode == 0 then
				ils_disable = 1
			end
		-- elseif simDR_efis_sub_mode == 4 then
			-- ils_disable = 1
		else
			mag_hdg = simDR_mag_hdg - simDR_mag_variation
		end
	end
	if decel_idx == 0 or was_decel == 1 then
		ils_disable = 1
	end
		
		
	if ils_disable == 0 then
		
		
		-- Calculate distance
		
		ils_x = (decel_lon - ils_lon) * math.cos((ils_lat + decel_lat)/2)
		ils_y = decel_lat - ils_lat
		ils_dis = math.sqrt(ils_x*ils_x + ils_y*ils_y) * 3440.064795	--nm
		
		ils_y = math.sin(decel_lon - ils_lon) * math.cos(decel_lat)
		ils_x = math.cos(ils_lat) * math.sin(decel_lat) - math.sin(ils_lat) * math.cos(decel_lat) * math.cos(decel_lon - ils_lon)
		ils_hdg = math.atan2(ils_y, ils_x)
		ils_hdg = math.deg(ils_hdg)
		ils_hdg = (ils_hdg + 360) % 360
		
		delta_ils_hdg = ((((ils_hdg - mag_hdg) % 360) + 540) % 360) - 180
		
		if delta_ils_hdg >= 0 and delta_ils_hdg <= 90 then
			-- right
			ils_on_off = 1
			delta_ils_hdg = 90 - delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = ils_dis * math.sin(delta_ils_hdg)
			ils_x = ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg < 0 and delta_ils_hdg >= -90 then
			-- left
			ils_on_off = 1
			delta_ils_hdg = 90 + delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = ils_dis * math.sin(delta_ils_hdg)
			ils_x = -ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg >= 90 then
			-- right back
			ils_on_off = 1
			delta_ils_hdg = delta_ils_hdg - 90
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = -ils_dis * math.sin(delta_ils_hdg)
			ils_x = ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg <= -90 then
			-- left back
			ils_on_off = 1
			delta_ils_hdg = -90 - delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = -ils_dis * math.sin(delta_ils_hdg)
			ils_x = -ils_dis * math.cos(delta_ils_hdg)
		end
		
		if B738DR_efis_map_range_capt == 0 then	-- 5 NM
			ils_zoom = 2
		elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
			ils_zoom = 1
		elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
			ils_zoom = 0.5
		elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
			ils_zoom = 0.25
		elseif B738DR_efis_map_range_capt == 4 then	-- 80 NM
			ils_zoom = 0.125
		elseif B738DR_efis_map_range_capt == 5 then	-- 160 NM
			ils_zoom = 0.0625
		elseif B738DR_efis_map_range_capt == 6 then	-- 320 NM
			ils_zoom = 0.03125
		else	-- 640 NM
			ils_zoom = 0.015625
			--ils_on_off = 0
		end
		
		ils_x = ils_x * ils_zoom		-- zoom
		ils_y = ils_y * ils_zoom		-- zoom
		-- if simDR_efis_sub_mode == 4 then
			-- ils_y = ils_y + 4.1	-- adjust
		-- end
		
		if map_mode == 3 then
			ils_y = ils_y + 4.1	-- adjust center
		elseif B738DR_capt_map_mode == 0 and simDR_efis_map_mode == 0 then
			ils_y = ils_y + 4.1	-- adjust center
		else
			if B738DR_capt_map_mode == 3 then
				ils_y = ils_y + 4.1	-- adjust
			end
		end
			
		-- if ils_x < -6.0 or ils_x > 6.0 then
			-- ils_on_off = 0
		-- end
		-- if ils_x < 0 then
			-- ils_corr = B738_rescale(-6.0, 6.3, 0, 8.7, ils_x)
		-- else
			-- ils_corr = B738_rescale(0, 8.7, 6.0, 6.3, ils_x)
		-- end
		-- if ils_y > ils_corr or ils_y < -1 then
			-- ils_on_off = 0
		-- end
		if ils_x < -8.0 or ils_x > 8.0 then
			ils_on_off = 0
		end
		if ils_y > 11.0 or ils_y < -2 then			ils_on_off = 0
		end
		
		if ils_on_off == 1 then
			B738DR_decel_x = ils_x
			B738DR_decel_y = ils_y
			B738DR_decel_id = "DECEL"
			B738DR_decel_show = 1
		else
			B738DR_decel_show = 0
			B738DR_decel_id = ""
		end
	else
		B738DR_decel_show = 0
		B738DR_decel_id = ""
	end
	
	else
		B738DR_decel_show = 0
		B738DR_decel_id = ""
	end

end

function B738_displ_td()
	local ils_lat = math.rad(simDR_latitude) 
	local ils_lon = math.rad(simDR_longitude) 
	local mag_hdg = 0
	local delta_ils_hdg = 0
	local ils_hdg = 0
	local ils_on_off = 0
	local ils_x = 0
	local ils_y = 0
	local ils_dis = 0
	local ils_zoom = 0
	local ils_disable = 0
	local ils_corr = 0
	--local crz_alt_temp = 0
	
	if legs_num > 0 then --and legs_step <= legs_num then
	
	if map_mode == 3 then
		if legs_step == 0 then
			ils_lat = math.rad(legs_data[1][7])
			ils_lon = math.rad(legs_data[1][8])
		else
			ils_lat = math.rad(legs_data[legs_step][7])
			ils_lon = math.rad(legs_data[legs_step][8])
		end
		mag_hdg = -simDR_mag_variation
	else
		if B738DR_capt_map_mode < 2 then
			mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
			-- if simDR_efis_map_mode == 0 then
			if B738DR_capt_map_mode == 1 and simDR_efis_map_mode == 0 then
				ils_disable = 1
			end
		-- elseif simDR_efis_sub_mode == 4 then
			-- ils_disable = 1
		else
			mag_hdg = simDR_mag_hdg - simDR_mag_variation
		end
	end
	-- crz_alt_temp = crz_alt_num - 500
	if td_idx == 0 or B738DR_flight_phase > 4 or B738DR_vnav_td_dist < 0.5 then
		ils_disable = 1
	end
	-- if B738DR_flight_phase > 1 and B738DR_flight_phase < 5 and simDR_altitude_pilot < crz_alt_temp then
		-- ils_disable = 1
	-- end
		
		
	if ils_disable == 0 then
		
		
		-- Calculate distance
		
		ils_x = (td_lon - ils_lon) * math.cos((ils_lat + td_lat)/2)
		ils_y = td_lat - ils_lat
		ils_dis = math.sqrt(ils_x*ils_x + ils_y*ils_y) * 3440.064795	--nm
		
		ils_y = math.sin(td_lon - ils_lon) * math.cos(td_lat)
		ils_x = math.cos(ils_lat) * math.sin(td_lat) - math.sin(ils_lat) * math.cos(td_lat) * math.cos(td_lon - ils_lon)
		ils_hdg = math.atan2(ils_y, ils_x)
		ils_hdg = math.deg(ils_hdg)
		ils_hdg = (ils_hdg + 360) % 360
		
		delta_ils_hdg = ((((ils_hdg - mag_hdg) % 360) + 540) % 360) - 180
		
		if delta_ils_hdg >= 0 and delta_ils_hdg <= 90 then
			-- right
			ils_on_off = 1
			delta_ils_hdg = 90 - delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = ils_dis * math.sin(delta_ils_hdg)
			ils_x = ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg < 0 and delta_ils_hdg >= -90 then
			-- left
			ils_on_off = 1
			delta_ils_hdg = 90 + delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = ils_dis * math.sin(delta_ils_hdg)
			ils_x = -ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg >= 90 then
			-- right back
			ils_on_off = 1
			delta_ils_hdg = delta_ils_hdg - 90
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = -ils_dis * math.sin(delta_ils_hdg)
			ils_x = ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg <= -90 then
			-- left back
			ils_on_off = 1
			delta_ils_hdg = -90 - delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = -ils_dis * math.sin(delta_ils_hdg)
			ils_x = -ils_dis * math.cos(delta_ils_hdg)
		end
		
		if B738DR_efis_map_range_capt == 0 then	-- 5 NM
			ils_zoom = 2
		elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
			ils_zoom = 1
		elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
			ils_zoom = 0.5
		elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
			ils_zoom = 0.25
		elseif B738DR_efis_map_range_capt == 4 then	-- 80 NM
			ils_zoom = 0.125
		elseif B738DR_efis_map_range_capt == 5 then	-- 160 NM
			ils_zoom = 0.0625
		elseif B738DR_efis_map_range_capt == 6 then	-- 320 NM
			ils_zoom = 0.03125
		else	-- 640 NM
			ils_zoom = 0.015625
			--ils_on_off = 0
		end
		
		ils_x = ils_x * ils_zoom		-- zoom
		ils_y = ils_y * ils_zoom		-- zoom
		-- if simDR_efis_sub_mode == 4 then
			-- ils_y = ils_y + 4.1	-- adjust
		-- end
		
		if map_mode == 3 then
			ils_y = ils_y + 4.1	-- adjust center
		elseif B738DR_capt_map_mode == 0 and simDR_efis_map_mode == 0 then
			ils_y = ils_y + 4.1	-- adjust center
		else
			if B738DR_capt_map_mode == 3 then
				ils_y = ils_y + 4.1	-- adjust
			end
		end
			
		-- if ils_x < -6.0 or ils_x > 6.0 then
			-- ils_on_off = 0
		-- end
		-- if ils_x < 0 then
			-- ils_corr = B738_rescale(-6.0, 6.3, 0, 8.7, ils_x)
		-- else
			-- ils_corr = B738_rescale(0, 8.7, 6.0, 6.3, ils_x)
		-- end
		-- if ils_y > ils_corr or ils_y < -1 then
			-- ils_on_off = 0
		-- end
		if ils_x < -8.0 or ils_x > 8.0 then
			ils_on_off = 0
		end
		if ils_y > 11.0 or ils_y < -2 then
			ils_on_off = 0
		end
		
		if ils_on_off == 1 then
			B738DR_td_x = ils_x
			B738DR_td_y = ils_y
			B738DR_td_id = "T/D"
			B738DR_td_show = 1
		else
			B738DR_td_show = 0
			B738DR_td_id = ""
		end
	else
		B738DR_td_show = 0
		B738DR_td_id = ""
	end
	
	else
		B738DR_td_show = 0
		B738DR_td_id = ""
	end

end




function B738_displ_rnw()

	local ils_lat2 = 0
	local ils_lon2 = 0
	local ils_lat = math.rad(simDR_latitude) 
	local ils_lon = math.rad(simDR_longitude) 
	local mag_hdg = 0
	local delta_ils_hdg = 0
	local ils_hdg = 0
	local ils_on_off = 0
	local ils_x = 0
	local ils_y = 0
	local ils_dis = 0
	local ils_zoom = 0
	local ils_disable = 0
	
	if legs_num > 0 then --and legs_step <= legs_num then
	
	if B738DR_capt_map_mode < 2 then
		mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
		-- if simDR_efis_map_mode == 0 then
		if B738DR_capt_map_mode == 1 and simDR_efis_map_mode == 0 then
			ils_disable = 1
		end
	-- elseif simDR_efis_sub_mode == 4 then
		-- ils_disable = 1
	elseif B738DR_capt_map_mode == 3 then
		if legs_step == 0 then
			ils_lat = math.rad(legs_data[1][7])
			ils_lon = math.rad(legs_data[1][8])
		else
			ils_lat = math.rad(legs_data[legs_step][7])
			ils_lon = math.rad(legs_data[legs_step][8])
		end
		mag_hdg = -simDR_mag_variation
	else
		mag_hdg = simDR_mag_hdg - simDR_mag_variation
	end
	if des_app == "------" then
		ils_disable = 1
	end
		
		
	if ils_disable == 0 then
		
		ils_lat2 = math.rad(des_runway_lat)
		ils_lon2 = math.rad(des_runway_lon)
		
		ils_x = (ils_lon2 - ils_lon) * math.cos((ils_lat + ils_lat2)/2)
		ils_y = ils_lat2 - ils_lat
		ils_dis = math.sqrt(ils_x*ils_x + ils_y*ils_y) * 3440.064795	--nm
		
		ils_y = math.sin(ils_lon2 - ils_lon) * math.cos(ils_lat2)
		ils_x = math.cos(ils_lat) * math.sin(ils_lat2) - math.sin(ils_lat) * math.cos(ils_lat2) * math.cos(ils_lon2 - ils_lon)
		ils_hdg = math.atan2(ils_y, ils_x)
		ils_hdg = math.deg(ils_hdg)
		ils_hdg = (ils_hdg + 360) % 360
		
		delta_ils_hdg = ((((ils_hdg - mag_hdg) % 360) + 540) % 360) - 180
		
		if delta_ils_hdg >= 0 and delta_ils_hdg <= 90 then
			-- right
			ils_on_off = 1
			delta_ils_hdg = 90 - delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = ils_dis * math.sin(delta_ils_hdg)
			ils_x = ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg < 0 and delta_ils_hdg >= -90 then
			-- left
			ils_on_off = 1
			delta_ils_hdg = 90 + delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = ils_dis * math.sin(delta_ils_hdg)
			ils_x = -ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg >= 90 then
			-- right back
			ils_on_off = 1
			delta_ils_hdg = delta_ils_hdg - 90
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = -ils_dis * math.sin(delta_ils_hdg)
			ils_x = ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg <= -90 then
			-- left back
			ils_on_off = 1
			delta_ils_hdg = -90 - delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = -ils_dis * math.sin(delta_ils_hdg)
			ils_x = -ils_dis * math.cos(delta_ils_hdg)
		end
		
		if B738DR_efis_map_range_capt == 0 then	-- 5 NM
			ils_zoom = 2
		elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
			ils_zoom = 1
		elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
			ils_zoom = 0.5
		elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
			ils_zoom = 0.25
		else
			ils_on_off = 0
		end
		
		ils_x = ils_x * ils_zoom		-- zoom
		ils_y = ils_y * ils_zoom		-- zoom
		if B738DR_capt_map_mode == 3 then
			ils_y = ils_y + 4.1	-- adjust
		elseif B738DR_capt_map_mode == 0 and simDR_efis_map_mode == 0 then
			ils_y = ils_y + 4.1	-- adjust center
		end
		
		if ils_y > 14 or ils_y < -5 then		-- 7.7 / -1
			ils_on_off = 0
		end
		if ils_x < -10.0 or ils_x > 10.0 then		-- -6.0 / 6.0
			ils_on_off = 0
		end
		-- if ils_x < -8.0 or ils_x > 8.0 then
			-- ils_on_off = 0
		-- end
		-- if ils_y > 11.0 or ils_y < -2 then
			-- ils_on_off = 0
		-- end
			
		if ils_on_off == 1 then
			-- rotate
			if B738DR_capt_map_mode == 3 then
				ils_hdg = des_runway_crs
			else
				ils_hdg = (des_runway_crs - simDR_mag_hdg) % 360
			end
			ils_hdg = (90 + ils_hdg) % 360
			ils_hdg = ils_hdg + simDR_mag_variation
			B738DR_ils_rotate = ils_hdg
			
			B738DR_ils_x = ils_x
			B738DR_ils_y = ils_y
			B738DR_ils_runway = des_rnw
			B738DR_ils_show = 1
		else
			B738DR_ils_show = 0
		end
	else
		B738DR_ils_show = 0
	end
	
	
	
	-- REF RUNWAY
	
	ils_disable = 0
	if B738DR_capt_map_mode < 2 then
		mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
		-- if simDR_efis_map_mode == 0 then
		if B738DR_capt_map_mode == 1 and simDR_efis_map_mode == 0 then
			ils_disable = 1
		end
	-- elseif simDR_efis_sub_mode == 4 then
		-- ils_disable = 1
	elseif B738DR_capt_map_mode == 3 then
		if legs_step == 0 then
			ils_lat = legs_data[1][7]
			ils_lon = legs_data[1][8]
		else
			ils_lat = legs_data[legs_step][7]
			ils_lon = legs_data[legs_step][8]
		end
		mag_hdg = -simDR_mag_variation
	else
		mag_hdg = simDR_mag_hdg - simDR_mag_variation
	end
	if ref_rwy == "-----" then
		ils_disable = 1
	end
		
	if ils_disable == 0 and ref_runway_lenght > 0 then
		
		ils_lat2 = math.rad(ref_runway_lat)
		ils_lon2 = math.rad(ref_runway_lon)
		
		ils_x = (ils_lon2 - ils_lon) * math.cos((ils_lat + ils_lat2)/2)
		ils_y = ils_lat2 - ils_lat
		ils_dis = math.sqrt(ils_x*ils_x + ils_y*ils_y) * 3440.064795	--nm
		
		ils_y = math.sin(ils_lon2 - ils_lon) * math.cos(ils_lat2)
		ils_x = math.cos(ils_lat) * math.sin(ils_lat2) - math.sin(ils_lat) * math.cos(ils_lat2) * math.cos(ils_lon2 - ils_lon)
		ils_hdg = math.atan2(ils_y, ils_x)
		ils_hdg = math.deg(ils_hdg)
		ils_hdg = (ils_hdg + 360) % 360
		
		delta_ils_hdg = ((((ils_hdg - mag_hdg) % 360) + 540) % 360) - 180
		
		if delta_ils_hdg >= 0 and delta_ils_hdg <= 90 then
			-- right
			ils_on_off = 1
			delta_ils_hdg = 90 - delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = ils_dis * math.sin(delta_ils_hdg)
			ils_x = ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg < 0 and delta_ils_hdg >= -90 then
			-- left
			ils_on_off = 1
			delta_ils_hdg = 90 + delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = ils_dis * math.sin(delta_ils_hdg)
			ils_x = -ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg >= 90 then
			-- right back
			ils_on_off = 1
			delta_ils_hdg = delta_ils_hdg - 90
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = -ils_dis * math.sin(delta_ils_hdg)
			ils_x = ils_dis * math.cos(delta_ils_hdg)
		elseif delta_ils_hdg <= -90 then
			-- left back
			ils_on_off = 1
			delta_ils_hdg = -90 - delta_ils_hdg
			delta_ils_hdg = math.rad(delta_ils_hdg)
			ils_y = -ils_dis * math.sin(delta_ils_hdg)
			ils_x = -ils_dis * math.cos(delta_ils_hdg)
		end
		
		if B738DR_efis_map_range_capt == 0 then	-- 5 NM
			ils_zoom = 2
		elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
			ils_zoom = 1
		elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
			ils_zoom = 0.5
		elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
			ils_zoom = 0.25
		else
			ils_on_off = 0
		end
		
		ils_x = ils_x * ils_zoom		-- zoom
		ils_y = ils_y * ils_zoom		-- zoom
		if B738DR_capt_map_mode == 3 then
			ils_y = ils_y + 4.1	-- adjust
		elseif B738DR_capt_map_mode == 0 and simDR_efis_map_mode == 0 then
			ils_y = ils_y + 4.1	-- adjust center
		end
		
		if ils_y > 14 or ils_y < -5 then		-- 7.7 / -1
			ils_on_off = 0
		end
		if ils_x < -10.0 or ils_x > 10.0 then		-- -6.0 / 6.0
			ils_on_off = 0
		end
		
		if ils_on_off == 1 then
			-- rotate
			if B738DR_capt_map_mode == 3 then
				ils_hdg = ref_runway_crs
			else
				ils_hdg = (ref_runway_crs - simDR_mag_hdg) % 360
			end
			ils_hdg = (90 + ils_hdg) % 360
			ils_hdg = ils_hdg + simDR_mag_variation
			B738DR_ils_rotate0 = ils_hdg
			
			B738DR_ils_x0 = ils_x
			B738DR_ils_y0 = ils_y
			B738DR_ils_runway0 = ref_rwy
			B738DR_ils_show0 = 1
		else
			B738DR_ils_show0 = 0
		end
	else
		B738DR_ils_show0 = 0
	end
	
	end

end

function B738_nd_perf()
	
	local nd_lat = math.rad(simDR_latitude) 
	local nd_lon = math.rad(simDR_longitude) 
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_dis = 0
	local nd_x = 0
	local nd_y = 0
	local n = 0
	local range = 165	-- 165 NM
	local delta_pos = 0
	local skip = 0
	
	if nd_to == apt_data_num then
		nd_teak = 0
		if first_time_apt < 2 then
			first_time_apt = first_time_apt + 1
		end
		if nd_page == 0 then
			nd_page = 1
			nd_page2_num = 0
			nd_page2 = {}
			near_apt2_dis = 999999
			near_apt2_icao = ""
		else
			nd_page = 0
			nd_page1_num = 0
			nd_page1 = {}
			near_apt1_dis = 999999
			near_apt1_icao = ""
		end
	else
		nd_teak = nd_teak + 1
	end
	-- nd_from = (nd_teak * 150) + 1
	-- nd_to = nd_from + 149
	nd_from = (nd_teak * 50) + 1
	nd_to = nd_from + 49
	if nd_to > apt_data_num then
		nd_to = apt_data_num
	end
	
	for n = nd_from, nd_to do 
		--nd_lat2 = apt_data[n][2]
		--nd_lon2 = apt_data[n][2]
		
		nd_lat2 = math.rad(apt_data[n][2])
		nd_lon2 = math.rad(apt_data[n][3])
		
		skip = 0
		delta_pos = nd_lat2 - nd_lat
		if delta_pos < 0  then
			delta_pos = -delta_pos
		end
		if delta_pos > 2 then
			skip = 1
		end
		delta_pos = nd_lon2 - nd_lon
		if delta_pos < 0  then
			delta_pos = -delta_pos
		end
		if delta_pos > 2 then
			skip = 1
		end
		if apt_data[n][6] < 1700 then	-- minimal lenght runway in m
			skip = 1
		end
		if nd_lat2 == 0 then
			skip = 1
		end
		
		if skip == 0 then
			
			nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
			nd_y = nd_lat2 - nd_lat
			nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
			
			
			if nd_dis < range then
				if nd_page == 0 then	-- create nd_page1
					nd_page1_num = nd_page1_num + 1
					nd_page1[nd_page1_num] = {}
					nd_page1[nd_page1_num][1] = apt_data[n][1]
					nd_page1[nd_page1_num][2] = apt_data[n][2]
					nd_page1[nd_page1_num][3] = apt_data[n][3]
					if nd_dis < near_apt1_dis then
						near_apt1_dis = nd_dis
						near_apt1_icao = apt_data[n][1]
					end
				else					-- create nd_page2
					nd_page2_num = nd_page2_num + 1
					nd_page2[nd_page2_num] = {}
					nd_page2[nd_page2_num][1] = apt_data[n][1]
					nd_page2[nd_page2_num][2] = apt_data[n][2]
					nd_page2[nd_page2_num][3] = apt_data[n][3]
					if nd_dis < near_apt2_dis  then
						near_apt2_dis = nd_dis
						near_apt2_icao = apt_data[n][1]
					end
				end
			end
		
		end
		
	end
end


function B738_displ_apt()

	local nd_lat = math.rad(simDR_latitude) 
	local nd_lon = math.rad(simDR_longitude) 
	local mag_hdg = 0
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_dis = 0
	local nd_x = 0
	local nd_y = 0
	local nd_hdg = 0
	local n = 0
	local nav_disable = 0
	local nd_on_off = 0
	local nd_corr = 0
	local delta_hdg = 0
	local nd_zoom = 0
	local obj = 29
	local apt_txt = ""
	local page_max = 0
	local page_1 = 0
	local page_2 = 0
	local page_3 = 0
			
	-- if simDR_efis_sub_mode < 2 then
		-- mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
		-- if simDR_efis_map_mode == 0 then
			-- nav_disable = 1
		-- end
	-- elseif simDR_efis_sub_mode == 4 then
		-- nav_disable = 1
	-- else
		-- mag_hdg = simDR_mag_hdg - simDR_mag_variation
	-- end
	-- if B738DR_efis_apt_on == 0 then
		-- nav_disable = 1
	-- end
	
	nav_disable = 1
	if B738DR_capt_map_mode == 2 and simDR_efis_map_mode ~= 0 then
		nav_disable = 0
	end
	if B738DR_efis_apt_on == 0 then
		nav_disable = 1
	end
	mag_hdg = simDR_mag_hdg - simDR_mag_variation
	
	if nd_page == 0 then
		page_max = nd_page2_num
	else
		page_max = nd_page1_num
	end
	
	if page_max > 0 then
		
		for n = 1, page_max do 
			
			nd_on_off = 0
			if nd_page == 0 then
				page_1 = nd_page2[n][1]
				page_2 = nd_page2[n][2]
				page_3 = nd_page2[n][3]
			else
				page_1 = nd_page1[n][1]
				page_2 = nd_page1[n][2]
				page_3 = nd_page1[n][3]
			end
		
		--for n = 1, apt_data_num do
			--nd_lat2 = apt_data[n][2]
			--nd_lon2 = apt_data[n][3]
			nd_lat2 = math.rad(page_2)
			nd_lon2 = math.rad(page_3)
			
			nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
			nd_y = nd_lat2 - nd_lat
			nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
			
			if nd_dis < 165 and obj >= 0 and nav_disable == 0 then
				
				nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
				nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
				nd_hdg = math.atan2(nd_y, nd_x)
				nd_hdg = math.deg(nd_hdg)
				nd_hdg = (nd_hdg + 360) % 360
				
				delta_hdg = ((((nd_hdg - mag_hdg) % 360) + 540) % 360) - 180
				
				if delta_hdg >= 0 and delta_hdg <= 90 then
					-- right
					nd_on_off = 1
					delta_hdg = 90 - delta_hdg
					delta_hdg = math.rad(delta_hdg)
					nd_y = nd_dis * math.sin(delta_hdg)
					nd_x = nd_dis * math.cos(delta_hdg)
				elseif delta_hdg < 0 and delta_hdg >= -90 then
					-- left
					nd_on_off = 1
					delta_hdg = 90 + delta_hdg
					delta_hdg = math.rad(delta_hdg)
					nd_y = nd_dis * math.sin(delta_hdg)
					nd_x = -nd_dis * math.cos(delta_hdg)
				elseif delta_hdg >= 90 then
					-- right back
					nd_on_off = 1
					delta_hdg = delta_hdg - 90
					delta_hdg = math.rad(delta_hdg)
					nd_y = -nd_dis * math.sin(delta_hdg)
					nd_x = nd_dis * math.cos(delta_hdg)
				elseif delta_hdg <= -90 then
					-- left back
					nd_on_off = 1
					delta_hdg = -90 - delta_hdg
					delta_hdg = math.rad(delta_hdg)
					nd_y = -nd_dis * math.sin(delta_hdg)
					nd_x = -nd_dis * math.cos(delta_hdg)
				end
				
				if B738DR_efis_map_range_capt == 0 then	-- 5 NM
					nd_zoom = 2
				elseif B738DR_efis_map_range_capt == 1 then	-- 10 NM
					nd_zoom = 1
				elseif B738DR_efis_map_range_capt == 2 then	-- 20 NM
					nd_zoom = 0.5
				elseif B738DR_efis_map_range_capt == 3 then	-- 40 NM
					nd_zoom = 0.25
				elseif B738DR_efis_map_range_capt == 4 then	-- 80 NM
					nd_zoom = 0.125
				elseif B738DR_efis_map_range_capt == 5 then	-- 160 NM
					nd_zoom = 0.0625
				else
					nd_on_off = 0
				end
				
				nd_x = nd_x * nd_zoom		-- zoom
				nd_y = nd_y * nd_zoom		-- zoom
				if B738DR_capt_map_mode == 3 then
					nd_y = nd_y + 4.1	-- adjust
				end
				
				-- if nd_x < -6.0 or nd_x > 6.0 then
					-- nd_on_off = 0
				-- end
				-- if nd_x < 0 then
					-- nd_corr = B738_rescale(-6.0, 6.3, 0, 8.7, nd_x)
				-- else
					-- nd_corr = B738_rescale(0, 8.7, 6.0, 6.3, nd_x)
				-- end
				-- if nd_y > nd_corr or nd_y < -1 then
					-- nd_on_off = 0
				-- end
				if nd_x < -8.0 or nd_x > 8.0 then
					nd_on_off = 0
				end
				if nd_y > 11.0 or nd_y < -2 then
					nd_on_off = 0
				end
				
				if nd_on_off == 1 then
					if obj >= 0 then
						apt_txt = page_1
						--if simDR_gps_nav_id ~= apt_txt then
						if B738DR_fpln_nav_id ~= apt_txt then
							B738DR_apt_obj[obj] = 1
							B738DR_apt_x[obj] = nd_x
							B738DR_apt_y[obj] = nd_y
							if obj == 0 then
								B738DR_apt_id00 = apt_txt
							elseif obj == 1 then
								B738DR_apt_id01 = apt_txt
							elseif obj == 2 then
								B738DR_apt_id02 = apt_txt
							elseif obj == 3 then
								B738DR_apt_id03 = apt_txt
							elseif obj == 4 then
								B738DR_apt_id04 = apt_txt
							elseif obj == 5 then
								B738DR_apt_id05 = apt_txt
							elseif obj == 6 then
								B738DR_apt_id06 = apt_txt
							elseif obj == 7 then
								B738DR_apt_id07 = apt_txt
							elseif obj == 8 then
								B738DR_apt_id08 = apt_txt
							elseif obj == 9 then
								B738DR_apt_id09 = apt_txt
							elseif obj == 10 then
								B738DR_apt_id10 = apt_txt
							elseif obj == 11 then
								B738DR_apt_id11 = apt_txt
							elseif obj == 12 then
								B738DR_apt_id12 = apt_txt
							elseif obj == 13 then
								B738DR_apt_id13 = apt_txt
							elseif obj == 14 then
								B738DR_apt_id14 = apt_txt
							elseif obj == 15 then
								B738DR_apt_id15 = apt_txt
							elseif obj == 16 then
								B738DR_apt_id16 = apt_txt
							elseif obj == 17 then
								B738DR_apt_id17 = apt_txt
							elseif obj == 18 then
								B738DR_apt_id18 = apt_txt
							elseif obj == 19 then
								B738DR_apt_id19 = apt_txt
							elseif obj == 20 then
								B738DR_apt_id20 = apt_txt
							elseif obj == 21 then
								B738DR_apt_id21 = apt_txt
							elseif obj == 22 then
								B738DR_apt_id22 = apt_txt
							elseif obj == 23 then
								B738DR_apt_id23 = apt_txt
							elseif obj == 24 then
								B738DR_apt_id24 = apt_txt
							elseif obj == 25 then
								B738DR_apt_id25 = apt_txt
							elseif obj == 26 then
								B738DR_apt_id26 = apt_txt
							elseif obj == 27 then
								B738DR_apt_id27 = apt_txt
							elseif obj == 28 then
								B738DR_apt_id28 = apt_txt
							elseif obj == 29 then
								B738DR_apt_id29 = apt_txt
							end
							obj = obj - 1
						end
					end
				end
			end
		end
	end
	if obj >= 0 then
		for n = obj, 0, -1 do
			B738DR_apt_obj[n] = 0	-- off
			if n == 0 then
				B738DR_apt_id00 = ""
			elseif n == 1 then
				B738DR_apt_id01 = ""
			elseif n == 2 then
				B738DR_apt_id02 = ""
			elseif n == 3 then
				B738DR_apt_id03 = ""
			elseif n == 4 then
				B738DR_apt_id04 = ""
			elseif n == 5 then
				B738DR_apt_id05 = ""
			elseif n == 6 then
				B738DR_apt_id06 = ""
			elseif n == 7 then
				B738DR_apt_id07 = ""
			elseif n == 8 then
				B738DR_apt_id08 = ""
			elseif n == 9 then
				B738DR_apt_id09 = ""
			elseif n == 10 then
				B738DR_apt_id10 = ""
			elseif n == 11 then
				B738DR_apt_id11 = ""
			elseif n == 12 then
				B738DR_apt_id12 = ""
			elseif n == 13 then
				B738DR_apt_id13 = ""
			elseif n == 14 then
				B738DR_apt_id14 = ""
			elseif n == 15 then
				B738DR_apt_id15 = ""
			elseif n == 16 then
				B738DR_apt_id16 = ""
			elseif n == 17 then
				B738DR_apt_id17 = ""
			elseif n == 18 then
				B738DR_apt_id18 = ""
			elseif n == 19 then
				B738DR_apt_id19 = ""
			elseif n == 20 then
				B738DR_apt_id20 = ""
			elseif n == 21 then
				B738DR_apt_id21 = ""
			elseif n == 22 then
				B738DR_apt_id22 = ""
			elseif n == 23 then
				B738DR_apt_id23 = ""
			elseif n == 24 then
				B738DR_apt_id24 = ""
			elseif n == 25 then
				B738DR_apt_id25 = ""
			elseif n == 26 then
				B738DR_apt_id26 = ""
			elseif n == 27 then
				B738DR_apt_id27 = ""
			elseif n == 28 then
				B738DR_apt_id28 = ""
			elseif n == 29 then
				B738DR_apt_id29 = ""
			end
		end
	end
	

end

function B738_restrict_data()

	local ii = 0
	local jj = 0
	local temp_alt = 0
	local td_idx_temp = 0
	
	
	if ref_icao == "----" or des_icao == "****" then
		legs_num = 0
	end
	
	
	if legs_num > 1 then
		
		if offset > legs_num then
			offset = legs_num
		end
		if offset == 0 then
			offset = 1
		end
		
		-- restrict speed
		B738DR_rest_wpt_spd_id = ""
		B738DR_rest_wpt_spd = 0
		B738DR_rest_wpt_spd_idx = 0
		if legs_restr_spd_n > 0 then
			if B738DR_flight_phase < 2 then		-- climb
				if td_idx == 0 then
					td_idx_temp = 0
				else
					if tc_idx > td_idx then
						td_idx_temp = td_idx - 1
					else
						td_idx_temp = tc_idx
					end
				end
				for ii = 1, legs_restr_spd_n do
					if legs_restr_spd[ii][2] >= offset and legs_restr_spd[ii][2] <= td_idx_temp then
						B738DR_rest_wpt_spd_id = legs_restr_spd[ii][1]
						B738DR_rest_wpt_spd = legs_restr_spd[ii][3]
						B738DR_rest_wpt_spd_idx = legs_restr_spd[ii][2]
						break
					end
				end
			end
			
			if B738DR_flight_phase == 2 then	-- cruise before T/D
				if td_idx == 0 then
					td_idx_temp = 2
				else
					td_idx_temp = td_idx
				end
				for ii = legs_restr_spd_n, 1, -1 do
					if legs_restr_spd[ii][2] == offset and legs_restr_spd[ii][2] == td_idx_temp then
						decel_dist = 6.7
						B738DR_rest_wpt_spd_id = legs_restr_spd[ii][1]
						B738DR_rest_wpt_spd = legs_restr_spd[ii][3]
						B738DR_rest_wpt_spd_idx = legs_restr_spd[ii][2]
						break
					end
				end
			end
			
			if B738DR_flight_phase > 4 then		-- descent
				-- if td_fix_idx == 0 then
					-- td_idx_temp = td_idx
				-- else
					-- td_idx_temp = td_fix_idx
				-- end
				if td_idx == 0 then
					td_idx_temp = 2
				else
					td_idx_temp = td_idx
				end
				for ii = legs_restr_spd_n, 1, -1 do
					-- if legs_restr_spd[ii][2] <= offset and legs_restr_spd[ii][2] >= td_idx_temp and legs_restr_spd[ii][3] <= B738DR_fmc_descent_speed then
						-- B738DR_rest_wpt_spd_id = legs_restr_spd[ii][1]
						-- B738DR_rest_wpt_spd = legs_restr_spd[ii][3]
						-- break
					-- end
					if legs_restr_spd[ii][2] >= td_idx_temp and legs_restr_spd[ii][3] <= B738DR_fmc_descent_speed then
						decel_before_idx = legs_restr_spd[ii][2]
						if legs_data[decel_before_idx][3] < 6.7 and decel_before_idx > 1 then
							decel_dist = 6.7 - legs_data[decel_before_idx][3]
							decel_before_idx = decel_before_idx - 1
							if legs_data[decel_before_idx][4] ~= 0 then
								decel_before_idx = legs_restr_spd[ii][2]
								decel_dist = legs_data[decel_before_idx][3] - 0.3
							else
								if legs_data[decel_before_idx][3] < decel_dist then
									decel_dist = legs_data[decel_before_idx][3] - 0.3
								end
							end
						else
							decel_dist = 6.7
						end
						if decel_before_idx <= offset then
							B738DR_rest_wpt_spd_id = legs_restr_spd[ii][1]
							B738DR_rest_wpt_spd = legs_restr_spd[ii][3]
							B738DR_rest_wpt_spd_idx = legs_restr_spd[ii][2]
							break
						end
					end
				end
				temp_alt = 0
				if B738DR_rest_wpt_spd_idx > offset then 
					temp_alt = 1
				end
				if B738DR_rest_wpt_spd_idx == offset and decel_dist > simDR_fmc_dist then
					temp_alt = 1
				end
				if temp_alt == 1 and legs_data[offset][4] == 0 and B738DR_rest_wpt_spd ~= legs_data[offset][10] then
					--B738DR_rest_wpt_spd_id = legs_data[offset][1]
					B738DR_rest_wpt_spd = legs_data[offset][10]
					--B738DR_rest_wpt_spd_idx = offset
					decel_dist = 1000
				end
			end
		end
		
		-- restrict alt
		B738DR_rest_wpt_alt_id = ""
		B738DR_rest_wpt_alt = 0
		B738DR_rest_wpt_alt_t = 0
		B738DR_rest_wpt_alt_idx = 0
		if legs_restr_alt_n > 0 then
			for ii = 1, legs_restr_alt_n do
				if B738DR_flight_phase < 2 then		-- climb
					if td_idx == 0 then
						td_idx_temp = 0
					else
						if tc_idx > td_idx then
							td_idx_temp = td_idx - 1
						else
							td_idx_temp = tc_idx
						end
					end
					if td_idx_temp > 0 then
						-- if legs_restr_alt[ii][2] >= offset and legs_restr_alt[ii][2] <= tc_idx then
							-- B738DR_rest_wpt_alt_id = legs_restr_alt[ii][1]
							-- B738DR_rest_wpt_alt = legs_restr_alt[ii][3]
							-- B738DR_rest_wpt_alt_t = legs_restr_alt[ii][4]
							-- B738DR_rest_wpt_alt_idx = legs_restr_alt[ii][2]
							-- break
						-- end
						if legs_restr_alt[ii][2] >= offset and legs_restr_alt[ii][2] <= td_idx_temp then
							temp_alt = simDR_altitude_pilot - 300
							if temp_alt < legs_restr_alt[ii][3] then
								B738DR_rest_wpt_alt_id = legs_restr_alt[ii][1]
								B738DR_rest_wpt_alt = legs_restr_alt[ii][3]
								B738DR_rest_wpt_alt_t = legs_restr_alt[ii][4]
								B738DR_rest_wpt_alt_idx = legs_restr_alt[ii][2]
								break
							end
						end
					end
				end
				if B738DR_flight_phase > 4 then		-- descent
					-- if td_fix_idx == 0 then
						-- td_idx_temp = td_idx
					-- else
						-- td_idx_temp = td_fix_idx
					-- end
					if td_idx == 0 then
						td_idx_temp = 2
					else
						td_idx_temp = td_idx
					end
					if legs_restr_alt[ii][2] >= offset and legs_restr_alt[ii][2] >= td_idx_temp then
						temp_alt = simDR_altitude_pilot + 300
						if temp_alt > legs_restr_alt[ii][3] then
							B738DR_rest_wpt_alt_id = legs_restr_alt[ii][1]
							B738DR_rest_wpt_alt = legs_restr_alt[ii][3]
							B738DR_rest_wpt_alt_t = legs_restr_alt[ii][4]
							B738DR_rest_wpt_alt_idx = legs_restr_alt[ii][2]
							break
						end
					end
				end
			end
		end
		jj = 0
		if B738DR_rest_wpt_alt_idx > 0 and B738DR_rest_wpt_alt_idx >= offset then
			for ii = offset, B738DR_rest_wpt_alt_idx do
				if ii == offset then
					jj = simDR_fmc_dist
				else
					jj = jj + legs_data[ii][3]
				end
			end
		end
		B738DR_rest_wpt_alt_dist = jj
		
		--calc SPD and ALT
		B738DR_calc_wpt_spd = legs_data[offset][10]
		B738DR_calc_wpt_alt = legs_data[offset][11]
		
	end

end

function pfd_ils()

	local pfd_txt = ""
	local pfd_num = 0
	local pfd_num2 = 0
	
	if simDR_nav1_nav_id == nil then
		pfd_txt = "    "
	else
		pfd_txt = simDR_nav1_nav_id 
	end
	pfd_num = string.len(pfd_txt)
	if pfd_num < 4 then
		pfd_num = 4 - pfd_num
		for pfd_num2 = 1, pfd_num do
			pfd_txt = pfd_txt .. " "
		end
	end
	pfd_txt = pfd_txt .. "/"
	pfd_txt = pfd_txt ..  string.format("%03d",simDR_nav1_obs_pilot)
	pfd_txt = pfd_txt .. "`"
	pfd_cpt_nav_txt1 = pfd_txt
	if simDR_nav1_has_dme == 0 then
		pfd_txt = "DME ---"
	else
		pfd_txt = "DME " .. string.format("%4.1f", simDR_nav1_dme)
	end
	pfd_cpt_nav_txt2 = pfd_txt

end


function pfd_loc()

	local pfd_txt = ""
	local pfd_num = 0
	local pfd_num2 = 0
	
	if simDR_nav1_nav_id == nil then
		pfd_txt = "    "
	else
		pfd_txt = simDR_nav1_nav_id 
	end
	pfd_num = string.len(pfd_txt)
	if pfd_num < 4 then
		pfd_num = 4 - pfd_num
		for pfd_num2 = 1, pfd_num do
			pfd_txt = pfd_txt .. " "
		end
	end
	pfd_txt = pfd_txt .. "/"
	pfd_txt = pfd_txt ..  string.format("%03d",simDR_nav1_obs_pilot)
	pfd_txt = pfd_txt .. "`"
	pfd_cpt_nav_txt1 = pfd_txt
	if simDR_nav1_has_dme == 0 then
		pfd_txt = "DME ---"
	else
		pfd_txt = "DME " .. string.format("%4.1f", simDR_nav1_dme)
	end
	pfd_cpt_nav_txt2 = pfd_txt

end

function pfd_rnav()

	local pfd_txt = ""
	local pfd_num = 0
	local pfd_num2 = 0
	
	if des_app ~= "------" and rw_dist > 0 and rw_dist < 18 then
		if string.sub(des_app, 1, 1) == "I" then 	-- ILS
			pfd_txt = "ILS" .. string.sub(des_app, 2, -1)
		elseif string.sub(des_app, 1, 1) == "L" then 	-- LOC
			pfd_txt = "LOC" .. string.sub(des_app, 2, -1)
		else
			pfd_txt = des_app
		end
		
		if rnav_idx_last > 0 and rnav_idx_last < legs_num then
			pfd_txt = pfd_txt .. "/"
			pfd_crs = (math.deg(legs_data[rnav_idx_last][2]) + simDR_mag_variation) % 360
			pfd_txt = pfd_txt .. string.format("%03d", pfd_crs)
			pfd_cpt_nav_txt1 = pfd_txt
			pfd_txt = legs_data[rnav_idx_last][1] .. " "
			if rw_dist > 0 then
				if rw_dist < 9.95 then
					pfd_txt = pfd_txt .. string.format("%4.1f", rw_dist)
				else
					pfd_txt = pfd_txt .. string.format("%3d", rw_dist)
				end
			end
			pfd_cpt_nav_txt2 = pfd_txt
		else
			pfd_cpt_nav_txt1 = pfd_txt
			pfd_cpt_nav_txt2 = ""
		end
	else
		pfd_cpt_nav_txt1 = ""
		pfd_cpt_nav_txt2 = ""
	end

end



function pfd_fo_ils()

	local pfd_txt = ""
	local pfd_num = 0
	local pfd_num2 = 0
	
	if simDR_nav1_nav_id == nil then
		pfd_txt = "    "
	else
		pfd_txt = simDR_nav1_nav_id 
	end
	pfd_num = string.len(pfd_txt)
	if pfd_num < 4 then
		pfd_num = 4 - pfd_num
		for pfd_num2 = 1, pfd_num do
			pfd_txt = pfd_txt .. " "
		end
	end
	pfd_txt = pfd_txt .. "/"
	pfd_txt = pfd_txt ..  string.format("%03d",simDR_nav1_obs_pilot)
	pfd_txt = pfd_txt .. "`"
	pfd_fo_nav_txt1 = pfd_txt
	if simDR_nav1_has_dme == 0 then
		pfd_txt = "DME ---"
	else
		pfd_txt = "DME " .. string.format("%4.1f", simDR_nav1_dme)
	end
	pfd_fo_nav_txt2 = pfd_txt

end


function pfd_fo_loc()

	local pfd_txt = ""
	local pfd_num = 0
	local pfd_num2 = 0
	
	if simDR_nav1_nav_id == nil then
		pfd_txt = "    "
	else
		pfd_txt = simDR_nav1_nav_id 
	end
	pfd_num = string.len(pfd_txt)
	if pfd_num < 4 then
		pfd_num = 4 - pfd_num
		for pfd_num2 = 1, pfd_num do
			pfd_txt = pfd_txt .. " "
		end
	end
	pfd_txt = pfd_txt .. "/"
	pfd_txt = pfd_txt ..  string.format("%03d",simDR_nav1_obs_pilot)
	pfd_txt = pfd_txt .. "`"
	pfd_fo_nav_txt1 = pfd_txt
	if simDR_nav1_has_dme == 0 then
		pfd_txt = "DME ---"
	else
		pfd_txt = "DME " .. string.format("%4.1f", simDR_nav1_dme)
	end
	pfd_fo_nav_txt2 = pfd_txt

end

function pfd_fo_rnav()

	local pfd_txt = ""
	local pfd_num = 0
	local pfd_num2 = 0
	local pfd_crs = 0
	
	if des_app ~= "------" and rw_dist > 0 and rw_dist < 18 then
		if string.sub(des_app, 1, 1) == "I" then 	-- ILS
			pfd_txt = "ILS" .. string.sub(des_app, 2, -1)
		elseif string.sub(des_app, 1, 1) == "L" then 	-- LOC
			pfd_txt = "LOC" .. string.sub(des_app, 2, -1)
		else
			pfd_txt = des_app
		end
		
		if rnav_idx_last > 0 and rnav_idx_last < legs_num then
			pfd_txt = pfd_txt .. "/"
			pfd_crs = (math.deg(legs_data[rnav_idx_last][2]) + simDR_mag_variation) % 360
			pfd_txt = pfd_txt .. string.format("%03d", pfd_crs)
			pfd_fo_nav_txt1 = pfd_txt
			pfd_txt = legs_data[rnav_idx_last][1] .. " "
			if rw_dist > 0 then
				if rw_dist < 9.95 then
					pfd_txt = pfd_txt .. string.format("%4.1f", rw_dist)
				else
					pfd_txt = pfd_txt .. string.format("%3d", rw_dist)
				end
			end
			pfd_fo_nav_txt2 = pfd_txt
		else
			pfd_fo_nav_txt1 = pfd_txt
			pfd_fo_nav_txt2 = ""
		end
	else
		pfd_fo_nav_txt1 = ""
		pfd_fo_nav_txt2 = ""
	end

end


function B738_vnav_pth()

	local n = 0
	local dist = 0
	local vnav_td_dist = 0
	local ii = 0
	local ed_found_temp = 0
	local ed_alt_temp = 0
	
	local gp_alt_err = 0
	local gp_pth_alt = 0
	local rnav_idx_last_1 = 0
	local rnav_idx_post = 0
	
	local vnav_vvi_trg = 0
	local vnav_vvi_tmp = 0
	
	local nd_lat = 0
	local nd_lon = 0
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_x = 0
	local nd_y = 0
	
	if ref_icao == "----" or des_icao == "****" then
		legs_num = 0
	end
	
	
	if crz_alt_num > 0 and legs_num > 0 and offset > 0 and cost_index ~= "***" and ref_icao ~= "----" and des_icao ~= "****" then
	
	if offset > legs_num then
		offset = legs_num
	end
	
	if td_idx == 0 or B738DR_flight_phase > 4 then
		B738DR_vnav_td_dist = 0
	else
		if offset == td_idx then
			vnav_td_dist = simDR_fmc_dist - td_dist
		else
			if offset == td_idx then
				vnav_td_dist = simDR_fmc_dist - td_dist
			else
				for ii = offset, td_idx do
					if ii == offset then
							vnav_td_dist = simDR_fmc_dist
					elseif ii < td_idx then
						vnav_td_dist = vnav_td_dist + legs_data[ii][3]
					else
						vnav_td_dist = vnav_td_dist + legs_data[ii][3] - td_dist
					end
				end
			end
		end
		B738DR_vnav_td_dist = vnav_td_dist
	end
	
	ed_found_temp = ed_found
	ed_alt_temp = ed_alt
	if ed_fix_num > 0 then
		for n = 1, ed_fix_num do
			if offset <= ed_fix_found2[n] then
				ed_found_temp = ed_fix_found2[n]
				ed_alt_temp = ed_fix_alt2[n]
				break
			end
		end
	end
	
	
	-- calculate VNAV PTH
--	if B738DR_flight_phase > 4 and crz_alt_num > 0 and legs_num > 1 and offset > 1 and cost_index ~= "***" and ed_found >= offset then	-- descent
	if crz_alt_num > 0 and legs_num > 0 and offset > 1 and cost_index ~= "***" and offset <= ed_found_temp then	-- descent
		
		if offset > legs_num then
			offset = legs_num
		end
		
		
		if vnav_td_dist == 0 or B738DR_flight_phase > 4 then
			if offset == ed_found_temp then
				--dist = simDR_fmc_dist
				dist = simDR_fmc_dist2
			else
				for n = offset, ed_found_temp do
					if n == offset then
						--dist = simDR_fmc_dist
						dist = simDR_fmc_dist2
					else
						dist = dist + legs_data[n][3]
					end
				end
			end
			ed_to_dist = dist
			B738DR_vnav_pth_alt = ed_alt_temp + ((dist * (math.tan(math.rad(econ_des_vpa)))) * 6076.11549) -- ft
			B738DR_vnav_alt_err = B738DR_vnav_pth_alt - simDR_altitude_pilot
			--B738DR_vnav_alt_err = simDR_altitude_pilot - B738DR_vnav_pth_alt
			if B738DR_vnav_alt_err > 9999 then
				B738DR_vnav_err_pfd = 9999
			else
				if B738DR_vnav_alt_err < -9999 then
					B738DR_vnav_err_pfd = -9999
				else
					B738DR_vnav_err_pfd = B738DR_vnav_alt_err
				end
			end
			
			
			B738DR_nd_vert_path = 1
			B738DR_vnav_vvi_corr = (B738DR_vnav_alt_err - 55) * B738DR_vvi_const	-- correction -55
			-- B738DR_vnav_vvi = (simDR_ground_spd * (math.tan(math.rad(econ_des_vpa))) * 6076.11549 / 60)  -- ft / min
			-- B738DR_vnav_vvi = -B738DR_vnav_vvi + B738DR_vnav_vvi_corr
			vnav_vvi_trg = (simDR_ground_spd * (math.tan(math.rad(econ_des_vpa))) * 6076.11549 / 60)  -- ft / min
			vnav_vvi_trg = -vnav_vvi_trg + B738DR_vnav_vvi_corr
			vnav_vvi_trg = vnav_vvi_trg / 1000
			vnav_vvi_trg = math.max (vnav_vvi_trg, -2.2)
			vnav_vvi_trg = math.min (vnav_vvi_trg, -0.2)
			vnav_vvi_tmp = B738DR_vnav_vvi / 1000
			if B738DR_altitude_mode == 5 and simDR_autopilot_altitude_mode ~= 6 then -- VNAV
				vnav_vvi_tmp = B738_set_anim_value2(vnav_vvi_tmp, vnav_vvi_trg, -2.2, -0.2, 2, DRindex)
				B738DR_vnav_vvi = vnav_vvi_tmp * 1000
			else
				B738DR_vnav_vvi = 0
			end
			
			if B738DR_vnav_vvi < -2500 then		-- max vvi -2400
				B738DR_vnav_vvi= -2500
			end
			if B738DR_vnav_vvi > -200 then		-- min vvi -200
				B738DR_vnav_vvi = -200
			end
		else
			--B738DR_pfd_vert_path = 0
			B738DR_nd_vert_path = 0
			B738DR_vnav_alt_err = 500
			B738DR_vnav_vvi = 0
			--B738DR_vnav_alt_err = -500
		end
	else
		--B738DR_pfd_vert_path = 0
		B738DR_nd_vert_path = 0
		B738DR_vnav_alt_err = 500
		B738DR_vnav_vvi = 0
		--B738DR_vnav_alt_err = -500
		ed_to_dist = 0
	end
	
	
	
	-- calculate RNAV
	local rnav_vpa_temp = 0
	rw_dist = 0
	if offset > 1 and ed_found ~= 0 and rnav_idx_first ~= 0 and rnav_idx_last ~= 0 then
		
		if simDR_on_ground_0 == 1 and simDR_on_ground_1 == 1 and simDR_on_ground_2 == 1 then
			B738DR_gp_active = 0
			B738DR_nd_vert_path = 0
			B738DR_vnav_alt_err = 500
		else
		
			if offset > legs_num then
				offset = legs_num
			end
			
			
			
			-- vpa exist
			--if rnav_vpa < 0 and offset >= rnav_idx_first and offset <= rnav_idx_last then	--rnaw_id == "RW" then
			if rnav_vpa < 0 then
				
				rnav_idx_post = rnav_idx_last + 1
				if rnav_idx_post > legs_num then
					rnav_idx_post = rnav_idx_last
				end
				
				--if offset <= rnav_idx_last then
				if offset <= rnav_idx_post then
					rnav_vpa_temp = -rnav_vpa
					--if offset == rnav_idx_last then
					if offset == rnav_idx_last or offset == rnav_idx_post then
						--rw_dist = simDR_fmc_dist2
						nd_lat = math.rad(simDR_latitude) 
						nd_lon = math.rad(simDR_longitude) 
						nd_lat2 = legs_data[rnav_idx_last][7]
						nd_lon2 = legs_data[rnav_idx_last][8]
						nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
						nd_y = nd_lat2 - nd_lat
						rw_dist = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
					else
						for n = offset, rnav_idx_last do
							if n == offset then
								rw_dist = simDR_fmc_dist2
							else
								rw_dist = rw_dist + legs_data[n][3]
							end
						end
					end
					gp_pth_alt = rnav_alt + ((rw_dist * (math.tan(math.rad(rnav_vpa_temp)))) * 6076.11549)	-- ft
					gp_alt_err = gp_pth_alt - simDR_altitude_pilot
					if gp_alt_err > 9999 then
						B738DR_gp_err_pfd = 9999
					else
						if gp_alt_err < -9999 then
							B738DR_gp_err_pfd = -9999
						else
							B738DR_gp_err_pfd = gp_alt_err
						end
					end
				else
					rw_dist = 0
				end
				
				rnav_idx_last_1 = rnav_idx_first - 1
				
				--if offset >= rnav_idx_first and offset <= rnav_idx_last and offset > ed_found then	--rnaw_id == "RW" then
				if offset >= rnav_idx_first and offset <= rnav_idx_post and offset > ed_found then --and rw_dist < 22 then	--rnaw_id == "RW" then
					B738DR_nd_vert_path = 1
					B738DR_gp_vvi_corr = (gp_alt_err - 55) * B738DR_vvi_const	-- correction -55
					-- B738DR_gp_vvi = (simDR_ground_spd * (math.tan(math.rad(rnav_vpa_temp))) * 6076.11549 / 60)  -- ft / min
					-- B738DR_gp_vvi = -B738DR_gp_vvi + B738DR_gp_vvi_corr
					
					vnav_vvi_trg = (simDR_ground_spd * (math.tan(math.rad(rnav_vpa_temp))) * 6076.11549 / 60)  -- ft / min
					vnav_vvi_trg = -vnav_vvi_trg + B738DR_gp_vvi_corr
					vnav_vvi_trg = vnav_vvi_trg / 1000
					vnav_vvi_trg = math.max (vnav_vvi_trg, -2.0)
					vnav_vvi_trg = math.min (vnav_vvi_trg, -0.2)
					vnav_vvi_tmp = B738DR_gp_vvi / 1000
					if simDR_autopilot_altitude_mode ~= 6 then
						if B738DR_altitude_mode == 5 or B738DR_altitude_mode == 7 then	-- VNAV or G/P
							vnav_vvi_tmp = B738_set_anim_value2(vnav_vvi_tmp, vnav_vvi_trg, -2.0, -0.2, 2, 0.08)
							B738DR_gp_vvi = vnav_vvi_tmp * 1000
						end
					else
						B738DR_gp_vvi = 0
					end
					
					if B738DR_gp_vvi < -2000 then		-- max vvi
						B738DR_gp_vvi= -2000
					end
					if B738DR_gp_vvi > -200 then		-- min vvi
						B738DR_gp_vvi = -200
					end
					B738DR_gp_active = 2
					B738DR_vnav_alt_err = gp_alt_err
					B738DR_vnav_err_pfd = B738DR_gp_err_pfd
					B738DR_vnav_vvi = B738DR_gp_vvi
				elseif offset <= rnav_idx_first and offset >= rnav_idx_last_1 then --and rw_dist < 22 then		-- 18 NM
					B738DR_gp_vvi_corr = (gp_alt_err - 55) * B738DR_vvi_const	-- correction -55
					B738DR_gp_vvi = (simDR_ground_spd * (math.tan(math.rad(rnav_vpa_temp))) * 6076.11549 / 60)  -- ft / min
					B738DR_gp_vvi = -B738DR_gp_vvi + B738DR_gp_vvi_corr
					if B738DR_gp_vvi < -2200 then		-- max vvi
						B738DR_gp_vvi= -2200
					end
					if B738DR_gp_vvi > -200 then		-- min vvi
						B738DR_gp_vvi = -200
					end
					B738DR_gp_active = 1
				else
					B738DR_gp_active = 0
				end
			end
		end
	else
		B738DR_gp_active = 0
		if offset > ed_found and ed_found ~= 0 then
			--B738DR_pfd_vert_path = 0
			B738DR_nd_vert_path = 0
			B738DR_vnav_alt_err = 500
			--B738DR_vnav_alt_err = -500
		end
	end
	
	end
	
	--- PFD DEV
	
	-- Captain

	local horz_active = 0
	if simDR_nav1_horz_dsp == 1 and simDR_nav1_flag_ft == 1 then
		horz_active = 1
	end
	
	local vert_active = 0
	if simDR_nav1_flag_gs == 0 and simDR_nav1_vert_dsp == 1 then
		vert_active = 1
	end
	
	if B738DR_fms_ils_disable == 0 then
		if vert_active == 0 then 
			if B738DR_nd_vert_path == 1 then
				B738DR_autopilot_pfd_mode = 2 	-- LNAV/VNAV
				B738DR_pfd_vert_path = 1
				pfd_rnav()
			else
				B738DR_pfd_vert_path = 0
				if B738DR_autopilot_vnav_status == 0 then
					B738DR_autopilot_pfd_mode = 0	-- none
				else
					B738DR_autopilot_pfd_mode = 2 	-- LNAV/VNAV
					pfd_cpt_nav_txt1 = ""
					pfd_cpt_nav_txt2 = ""
				end
			end
		else
			-- if horz_active == 1 then
				B738DR_autopilot_pfd_mode = 1 	-- ILS
				B738DR_pfd_vert_path = 0
				pfd_ils()
				
			-- else
				-- if B738DR_autopilot_vnav_status == 0 then
					-- B738DR_autopilot_pfd_mode = 0	-- none
					-- B738DR_pfd_vert_path = 0
				-- else
					-- B738DR_autopilot_pfd_mode = 2 	-- LNAV/VNAV
					-- B738DR_pfd_vert_path = B738DR_nd_vert_path
				-- end
			-- end
		end
	else
		if B738DR_gp_active == 0 then
			if B738DR_nd_vert_path == 0 then
				B738DR_pfd_vert_path = 0
				if B738DR_autopilot_vnav_status == 0 then
					B738DR_autopilot_pfd_mode = 0	-- none
				else
					B738DR_autopilot_pfd_mode = 2 	-- LNAV/VNAV
					pfd_cpt_nav_txt1 = ""
					pfd_cpt_nav_txt2 = ""
				end
			else
				if horz_active == 1 then
					B738DR_autopilot_pfd_mode = 3 	-- LOC/VNAV
					pfd_loc()
				else
					B738DR_autopilot_pfd_mode = 2 	-- LNAV/VNAV
					pfd_rnav()
				end
				B738DR_pfd_vert_path = 1
			end
		elseif B738DR_gp_active == 1 then
			B738DR_pfd_vert_path = 0	-- both vpath and G/P !!!!!!! add G/P diamond only
			if B738DR_nd_vert_path == 0 then
				B738DR_autopilot_pfd_mode = 0	-- none
			else
				if horz_active == 1 then
					B738DR_autopilot_pfd_mode = 3 	-- LOC/VNAV
					pfd_loc()
				else
					B738DR_autopilot_pfd_mode = 2 	-- LNAV/VNAV
					pfd_rnav()
				end
			end
		elseif B738DR_gp_active == 2 then
			if B738DR_heading_mode == 8 then	-- IAN -> LOC/VNAV G/P
				B738DR_pfd_vert_path = 0
				if horz_active == 1 then
					B738DR_autopilot_pfd_mode = 4 	-- FMC -> LOC/VNAV G/P
					pfd_rnav()
				else
					B738DR_autopilot_pfd_mode = 4 	-- FMC -> LNAV/VNAV G/P
					pfd_rnav()
				end
			else
				B738DR_pfd_vert_path = 1	-- both vpath and G/P !!!!!!! add G/P diamond only
				if horz_active == 1 then
					B738DR_autopilot_pfd_mode = 3 	-- LOC/VNAV
					pfd_loc()
				else
					B738DR_autopilot_pfd_mode = 2 	-- LNAV/VNAV
					pfd_rnav()
				end
			end
		end
	end
	if B738DR_autopilot_pfd_mode == 0 then
		pfd_cpt_nav_txt1 = ""
		pfd_cpt_nav_txt2 = ""
	end
	
	
	
	-- First Officer
	horz_active = 0
	if simDR_nav2_horz_dsp == 1 and simDR_nav2_flag_ft == 1 then
		horz_active = 1
	end
	
	vert_active = 0
	if simDR_nav2_flag_gs == 0 and simDR_nav2_vert_dsp == 1 then
		vert_active = 1
	end
	
	if B738DR_fms_ils_disable == 0 then
		if vert_active == 0 then 
			if B738DR_nd_vert_path == 1 then
				B738DR_autopilot_pfd_mode_fo = 2 	-- LNAV/VNAV
				B738DR_pfd_vert_path_fo = 1
				pfd_fo_rnav()
			else
				B738DR_pfd_vert_path_fo = 0
				if B738DR_autopilot_vnav_status == 0 then
					B738DR_autopilot_pfd_mode_fo = 0	-- none
				else
					B738DR_autopilot_pfd_mode_fo = 2 	-- LNAV/VNAV
					pfd_fo_nav_txt1 = ""
					pfd_fo_nav_txt2 = ""
				end
			end
		else
			-- if horz_active == 1 then
				B738DR_autopilot_pfd_mode_fo = 1 	-- ILS
				B738DR_pfd_vert_path_fo = 0
				pfd_fo_ils()
			-- else
				-- if B738DR_autopilot_vnav_status == 0 then
					-- B738DR_autopilot_pfd_mode_fo = 0	-- none
					-- B738DR_pfd_vert_path_fo = 0
				-- else
					-- B738DR_autopilot_pfd_mode_fo = 2 	-- LNAV/VNAV
					-- B738DR_pfd_vert_path_fo = B738DR_nd_vert_path
				-- end
			-- end
		end
	else
		if B738DR_gp_active == 0 then
			if B738DR_nd_vert_path == 0 then
				B738DR_pfd_vert_path_fo = 0
				if B738DR_autopilot_vnav_status == 0 then
					B738DR_autopilot_pfd_mode_fo = 0	-- none
				else
					B738DR_autopilot_pfd_mode_fo = 2 	-- LNAV/VNAV
					pfd_cpt_nav_txt1 = ""
					pfd_cpt_nav_txt2 = ""
				end
			else
				if horz_active == 1 then
					B738DR_autopilot_pfd_mode_fo = 3 	-- LOC/VNAV
					pfd_fo_loc()
				else
					B738DR_autopilot_pfd_mode_fo = 2 	-- LNAV/VNAV
					pfd_fo_rnav()
				end
				B738DR_pfd_vert_path_fo = 1
			end
		elseif B738DR_gp_active == 1 then
			B738DR_pfd_vert_path_fo = 0	-- both vpath and G/P !!!!!!! need add G/P diamond only
			if B738DR_nd_vert_path == 0 then
				B738DR_autopilot_pfd_mode_fo = 0	-- none
			else
				if horz_active == 1 then
					B738DR_autopilot_pfd_mode_fo = 3 	-- LOC/VNAV
					pfd_fo_loc()
				else
					B738DR_autopilot_pfd_mode_fo = 2 	-- LNAV/VNAV
					pfd_fo_rnav()
				end
			end
		elseif B738DR_gp_active == 2 then
			if B738DR_heading_mode == 8 then	-- IAN -> LOC/VNAV G/P
				B738DR_pfd_vert_path_fo = 0
				if horz_active == 1 then
					B738DR_autopilot_pfd_mode_fo = 4 	-- FMC -> LOC/VNAV G/P
					pfd_fo_loc()
				else
					B738DR_autopilot_pfd_mode_fo = 4 	-- FMC -> LNAV/VNAV G/P
					pfd_fo_rnav()
				end
			else
				B738DR_pfd_vert_path_fo = 1	-- both vpath and G/P !!!!!!! need add G/P diamond only
				if horz_active == 1 then
					B738DR_autopilot_pfd_mode_fo = 3 	-- LOC/VNAV
					pfd_fo_loc()
				else
					B738DR_autopilot_pfd_mode_fo = 2 	-- LNAV/VNAV
					pfd_fo_rnav()
				end
			end
		end
	end
	if B738DR_autopilot_pfd_mode == 0 then
		pfd_fo_nav_txt1 = ""
		pfd_fo_nav_txt2 = ""
	end
	
	
end



function B738_fmc_calc()

	local ii = 0
	local nd_lat = math.rad(simDR_latitude) 
	local nd_lon = math.rad(simDR_longitude) 
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_dis = 0
	local nd_x = 0
	local nd_y = 0
	local nd_hdg = 0
	local n = 0
	--local delta_hdg = 0
	local dist_corr = 0
	local speed_corr = 0
	local speed = simDR_airspeed_pilot
	local mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
	local offset_from = 0
	local time_zulu = 0
	local tmp_wpt_eta2 = 0
	local tmp_wpt_eta3 = 0
	local distance = 0
	
	local relative_brg = 0
	local true_brg = 0
	local true_hdg = 0
	
	local dist_thrshld = 0
	local gnd_spd = simDR_ground_spd
	local offset_1 = 0
	local temp_txt = ""
	local next_rel_brg = 0
	
	local nav_mode = 0
	
	-- eta to next waypoint
	time_zulu = simDR_zulu_hours + (simDR_zulu_minutes/60) + (simDR_zulu_seconds/3600)
	time_zulu = ((simDR_fms_time/60) + time_zulu) % 24
	tmp_wpt_eta2 = math.floor(time_zulu)
	tmp_wpt_eta3 = (time_zulu - tmp_wpt_eta2) * 60
	B738DR_fms_id_eta = tmp_wpt_eta2 + (tmp_wpt_eta3/100)
	
	if ref_icao == "----" or des_icao == "****" then
		legs_num = 0
	end
	
	if calc_rte_enable == 0 then
		if legs_num > 0 then
			B738DR_fpln_active = 1
			B738DR_fpln_active_fo = 1
			temp_txt = legs_data[offset][1]
			if string.len(temp_txt) > 5 then
				temp_txt = string.sub(temp_txt, 1, 5)
			end
			B738DR_fpln_nav_id = temp_txt
		else
			B738DR_fpln_active = 0
			B738DR_fpln_active_fo = 0
			B738DR_fpln_nav_id = ""
		end
	end
	if legs_num > 0 and calc_rte_enable == 0 then	-- > 2
		
		if offset > legs_num then
			offset = legs_num
		end
		
		
		if offset == 1 then
			offset_1 = offset + 1
		else
			offset_1 = offset
		end
		
		if offset_1 <= legs_num then
			nd_lat2 = math.rad(legs_data[offset_1][7])
			nd_lon2 = math.rad(legs_data[offset_1][8])
			
			nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
			nd_y = nd_lat2 - nd_lat
			nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
			
			gnd_spd = math.min(gnd_spd, 200)
			gnd_spd = math.max(gnd_spd, 0)
			
			if simDR_on_ground_0 == 1 or simDR_on_ground_1 == 1 or simDR_on_ground_2 == 1 then
				if offset_1 ~= offset then
					dist_thrshld = 0.6
				else
					dist_thrshld = 0.2
				end
			else
				if offset <= legs_num then
					next_rel_brg = ((math.deg(legs_data[offset+1][2]) - math.deg(legs_data[offset][2])) + 360 ) % 360
					if next_rel_brg < 0 then
						next_rel_brg = -next_rel_brg
					end
					if next_rel_brg > 110 then
						next_rel_brg = 110
					end
					max_thr = B738_rescale(0, 2.0, 110, 3.8, next_rel_brg)
				else
					max_thr = 3.5
				end
				dist_thrshld = B738_rescale(0, 0.5, 200, max_thr, gnd_spd)
			end
			
			if nd_dis < dist_thrshld then
				
				last_lat = 0
				last_lon = 0
				
				if legs_data[offset][7] ~= "VECTORS" and legs_data[offset][7] ~= "DISCONTINUITY" then
					offset = offset + 1
					nav_mode = 0
				else
					nav_mode = 2 -- vectors, continue in last course
				end
			end
			
			if offset > legs_num then
				-- end of route if selected approach
				if des_app ~= "------" then
					if B738DR_heading_mode > 3 and B738DR_heading_mode < 7 then
						B738DR_lnav_disconnect = 1
						B738DR_vnav_disconnect = 1
						fms_msg_sound = 1
						fmc_message_num = fmc_message_num + 1
						fmc_message[fmc_message_num] = LNAV_DISCON
						simCMD_nosmoking_toggle:once()
						B738DR_fmc_message_warn = 1
					end
					nav_mode = 0
				else
					-- navigate to destination ICAO
					nav_mode = 1	-- ICAO nav mode
				end
			end
			
		end
		
		if offset > legs_num then
			offset = legs_num
		end
		
		if offset == 0 then
			offset = 1
		end
		
		if nav_mode == 0 then
			
			-- navigation to next waypoint
			nd_lat2 = math.rad(legs_data[offset][7])
			nd_lon2 = math.rad(legs_data[offset][8])
				
			if last_lat == 0 and last_lon == 0 then
				simDR_fmc_trk = math.deg(legs_data[offset][2])
			else
				-- DIR INTC
				nd_lat = last_lat
				nd_lon = last_lon
				
				nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
				nd_y = nd_lat2 - nd_lat
				--nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
				
				nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
				nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
				nd_hdg = math.atan2(nd_y, nd_x)
				nd_hdg = math.deg(nd_hdg)
				nd_hdg = (nd_hdg + 360) % 360
				simDR_fmc_trk = nd_hdg
				--simDR_fmc_trk = (nd_hdg + simDR_mag_variation) % 360
				
				nd_lat = math.rad(simDR_latitude) 
				nd_lon = math.rad(simDR_longitude) 
			end
			
			--nd_lat2 = math.rad(legs_data[offset][7])
			--nd_lon2 = math.rad(legs_data[offset][8])
			
			nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
			nd_y = nd_lat2 - nd_lat
			nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
			
			nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
			nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
			nd_hdg = math.atan2(nd_y, nd_x)
			nd_hdg = math.deg(nd_hdg)
			nd_hdg = (nd_hdg + 360) % 360
			
			true_brg = (simDR_fmc_trk + simDR_mag_variation + 360) % 360
			true_hdg = simDR_mag_hdg
			
			simDR_fmc_crs = (nd_hdg + simDR_mag_variation) % 360
			--simDR_fmc_trk = math.deg(legs_data[offset][2])
			
			relative_brg = (true_brg - true_hdg + 360) % 360
			if relative_brg > 180 then
				relative_brg = relative_brg - 360
			end
			relative_brg = math.abs(relative_brg)
			relative_brg = math.min(120, relative_brg)
			
			speed = math.min(250, speed)
			speed = math.max(150, speed)
			speed_corr = B738_rescale(150, 1.8, 250, 3.0, speed)
			dist_corr = B738_rescale(0, 0, 120, speed_corr, relative_brg)
			
			simDR_fmc_dist = nd_dis
			simDR_fmc_dist2 = nd_dis + dist_corr
		
		elseif nav_mode == 1 then
			
			-- navigation to destination ICAO
			nd_lat2 = math.rad(legs_data[legs_num+1][7])
			nd_lon2 = math.rad(legs_data[legs_num+1][8])
			
			nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
			nd_y = nd_lat2 - nd_lat
			nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
			
			nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
			nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
			nd_hdg = math.atan2(nd_y, nd_x)
			nd_hdg = math.deg(nd_hdg)
			nd_hdg = (nd_hdg + 360) % 360
			
			true_brg = (math.deg(legs_data[legs_num+1][2]) + simDR_mag_variation) % 360
			true_hdg = simDR_mag_hdg
			
			simDR_fmc_crs = (nd_hdg + simDR_mag_variation) % 360
			simDR_fmc_trk = math.deg(legs_data[legs_num+1][2])
			
			relative_brg = (true_brg - true_hdg + 360) % 360
			if relative_brg > 180 then
				relative_brg = relative_brg - 360
			end
			relative_brg = math.abs(relative_brg)
			relative_brg = math.min(120, relative_brg)
			
			speed = math.min(250, speed)
			speed = math.max(150, speed)
			speed_corr = B738_rescale(150, 1.8, 250, 3.0, speed)
			dist_corr = B738_rescale(0, 0, 120, speed_corr, relative_brg)
			
			simDR_fmc_dist = nd_dis
			simDR_fmc_dist2 = nd_dis + dist_corr
		end
		
		-- create SPD and ALT restrict table
		legs_restr_spd = {}
		legs_restr_spd_n = 0
		legs_restr_alt = {}
		legs_restr_alt_n = 0
		
		for n = 1, legs_num do
			if legs_data[n][4] > 0 then
				legs_restr_spd_n = legs_restr_spd_n + 1
				legs_restr_spd[legs_restr_spd_n] = {}
				legs_restr_spd[legs_restr_spd_n][1] = legs_data[n][1]	-- id
				legs_restr_spd[legs_restr_spd_n][2] = n					-- idx
				legs_restr_spd[legs_restr_spd_n][3] = legs_data[n][4]	-- spd restrict
			end
			if legs_data[n][5] > 0 then
				legs_restr_alt_n = legs_restr_alt_n + 1
				legs_restr_alt[legs_restr_alt_n] = {}
				legs_restr_alt[legs_restr_alt_n][1] = legs_data[n][1]	-- id
				legs_restr_alt[legs_restr_alt_n][2] = n					-- idx
				legs_restr_alt[legs_restr_alt_n][3] = legs_data[n][5]	-- alt restrict
				legs_restr_alt[legs_restr_alt_n][4] = legs_data[n][6]	-- alt restrict A,B,-
			end
			distance = distance + legs_data[n][3]
		end
		nd_x = legs_num + 1
		B738DR_fpln_dist = distance + legs_data[nd_x][3]
		
		-- if last_offset ~= offset then
			-- last_lat = 0 
			-- last_lon = 0 
			-- lock_bank = 0
		-- end
		last_offset = offset
			
			
			
			
			
			
			
			
			
			
			
			
			
			-- nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
			-- nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
			-- nd_hdg = math.atan2(nd_y, nd_x)
			-- nd_hdg = math.deg(nd_hdg)
			-- nd_hdg = (nd_hdg + 360) % 360
			
			-- for ii = 1, legs_num do
				-- nd_lat2 = legs_data[ii][7]
				-- nd_lon2 = legs_data[ii][8]
				
				-- nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
				-- nd_y = nd_lat2 - nd_lat
				-- nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
				
				-- nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
				-- nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
				-- nd_hdg = math.atan2(nd_y, nd_x)
				-- nd_hdg = math.deg(nd_hdg)
				-- nd_hdg = (nd_hdg + 360) % 360
			-- end
		-- else
		
		-- end
		
		
		
		-- if simDR_fmc_nav_id ~= nil then
			-- if ground_air == 0 then
				-- offset_from = 1
			-- else
				-- if direct_to == 2 then
					-- offset = direct_to_offset
					-- direct_to = 3
				-- elseif direct_to == 3 then
					-- offset = direct_to_offset
					-- direct_to = 0
				-- end
				-- offset_from = offset
			-- end
			
			
			-- if offset_from == 0 then
				-- offset = 1
			-- end
			-- if offset_from > legs_num then
				-- offset_from = legs_num
			-- end
			
			-- offset = 0
			-- for n = offset_from, (legs_num + 1) do
				-- tmp_wpt_eta2 = string.len(legs_data[n][1])
				-- if simDR_fmc_nav_id == ref_icao and ground_air == 0 then
					-- offset = n
					-- break
				-- elseif tmp_wpt_eta2 > 10 then
					-- if string.sub(legs_data[n][1], 1, 7) == "DISCONT" then
						-- offset = n
						-- break
					-- end
				-- elseif legs_data[n][1] == simDR_fmc_nav_id then
					-- offset = n
					-- --nd_lat2 = legs_data[offset][7]
					-- --nd_lon2 = legs_data[offset][8]
					-- break
				-- end
			-- end
		-- end
			
		-- if offset == 0 then
			-- offset = 1
		-- end
		-- offset = 1
		
		-- nd_lat2 = legs_data[offset][7]
		-- nd_lon2 = legs_data[offset][8]
		
		-- nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
		-- nd_y = nd_lat2 - nd_lat
		-- nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
		
		-- nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
		-- nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
		-- nd_hdg = math.atan2(nd_y, nd_x)
		-- nd_hdg = math.deg(nd_hdg)
		-- nd_hdg = (nd_hdg + 360) % 360
		
		-- -- delta_hdg = ((((nd_hdg - mag_hdg) % 360) + 540) % 360) - 180
		-- -- if delta_hdg < 0 then
			-- -- delta_hdg = -delta_hdg
		-- -- end
		
			-- true_brg = (math.deg(legs_data[offset][2]) + simDR_mag_variation) % 360
			-- true_hdg = simDR_mag_hdg
			-- relative_brg = (true_brg - true_hdg + 360) % 360
			-- if relative_brg > 180 then
				-- relative_brg = relative_brg - 360
			-- end
			-- relative_brg = math.abs(relative_brg)
			-- relative_brg = math.min(120, relative_brg)
			
		-- speed = math.min(250, speed)
		-- speed = math.max(150, speed)
		-- speed_corr = B738_rescale(150, 1.8, 250, 3.0, speed)
		-- dist_corr = B738_rescale(0, 0, 120, speed_corr, relative_brg)
		
		-- --B738DR_lnav_dist_next = nd_dis
		-- simDR_fmc_dist = nd_dis
		-- simDR_fmc_dist2 = nd_dis + dist_corr
		
		-- -- create SPD and ALT restrict table
		-- legs_restr_spd = {}
		-- legs_restr_spd_n = 0
		-- legs_restr_alt = {}
		-- legs_restr_alt_n = 0
		
		-- for n = 1, legs_num do
			-- if legs_data[n][4] > 0 then
				-- legs_restr_spd_n = legs_restr_spd_n + 1
				-- legs_restr_spd[legs_restr_spd_n] = {}
				-- legs_restr_spd[legs_restr_spd_n][1] = legs_data[n][1]	-- id
				-- legs_restr_spd[legs_restr_spd_n][2] = n					-- idx
				-- legs_restr_spd[legs_restr_spd_n][3] = legs_data[n][4]	-- spd restrict
			-- end
			-- if legs_data[n][5] > 0 then
				-- legs_restr_alt_n = legs_restr_alt_n + 1
				-- legs_restr_alt[legs_restr_alt_n] = {}
				-- legs_restr_alt[legs_restr_alt_n][1] = legs_data[n][1]	-- id
				-- legs_restr_alt[legs_restr_alt_n][2] = n					-- idx
				-- legs_restr_alt[legs_restr_alt_n][3] = legs_data[n][5]	-- alt restrict
				-- legs_restr_alt[legs_restr_alt_n][4] = legs_data[n][6]	-- alt restrict A,B,-
			-- end
			-- distance = distance + legs_data[n][3]
		-- end
		-- nd_x = legs_num + 1
		-- B738DR_fpln_dist = distance + legs_data[nd_x][3]
		
		-- if last_offset ~= offset then
			-- last_lat = 0 
			-- last_lon = 0 
			-- lock_bank = 0
		-- end
		-- last_offset = offset
	else
		legs_restr_spd_n = 0
		legs_restr_alt_n = 0
		B738DR_fpln_dist = 0
	end
end

function B738_fmc_time_calc()

	local xx = 0
	local time_zulu = 0
	local time_temp = 0
	local speed_temp = 0
	local speed_temp1 = 0
	local speed_temp2 = 0
	local last_speed = 0
	local dist_temp = 0
	local time_calc_enable = 0
	
	
	--if crz_alt_num > 0 and legs_num > 1 and offset > 0 and cost_index ~= "***" then
	dist_dest = 0
	dist_tc = 0
	time_tc = 0
	dist_td = 0
	time_td = 0
	dist_ed = 0
	time_ed = 0
	
	if ref_icao == "----" or des_icao == "****" then
		legs_num = 0
	end
	
	--if crz_alt_num > 0 and legs_num > 1 and offset > 0 and cost_index ~= "***" and ref_icao ~= "----" and des_icao ~= "****" then
	if legs_num > 0 and offset > 0 then
		
		if offset > legs_num then
			offset = legs_num
		end
		
		if crz_alt_num > 0 and cost_index ~= "***" and ref_icao ~= "----" and des_icao ~= "****" then
			time_calc_enable = 1
			time_zulu = simDR_zulu_hours + (simDR_zulu_minutes/60) + (simDR_zulu_seconds/3600)
		end
		
		--for xx = offset, (legs_num + 1) do
		for xx = offset, (legs_num + 1) do
			if xx == 1 then
				if simDR_airspeed_pilot < 160 then
					speed_temp1  = 160
				else
					speed_temp1 = simDR_airspeed_pilot * (1 + (simDR_altitude_pilot / 1000 * 0.02))
				end
				speed_temp2 = speed_temp1
				dist_temp = simDR_fmc_dist
			elseif xx == offset then
				if  simDR_airspeed_pilot < 160 then
					speed_temp1 = 160
				else
					speed_temp1 = simDR_airspeed_pilot * (1 + (simDR_altitude_pilot / 1000 * 0.02))
				end
				speed_temp2 = simDR_airspeed_pilot * (1 + (legs_data[xx][11] / 1000 * 0.02))
				dist_temp = simDR_fmc_dist
			else
				if legs_data[xx][10] == B738DR_fmc_descent_speed_mach then
					speed_temp = B738DR_fmc_descent_speed
				elseif legs_data[xx][10] == B738DR_fmc_cruise_speed_mach then
					speed_temp = B738DR_fmc_cruise_speed
				elseif legs_data[xx][10] == B738DR_fmc_climb_speed_mach then
					speed_temp = B738DR_fmc_climb_speed
				else
					if legs_data[xx][10] == 0 then
						speed_temp = last_speed
					else
						speed_temp = legs_data[xx][10]
					end
				end
				speed_temp1 = speed_temp * (1 + (legs_data[xx-1][11] / 1000 * 0.02))
				speed_temp2 = speed_temp * (1 + (legs_data[xx][11] / 1000 * 0.02))
				dist_temp = legs_data[xx][3]
			end
			if legs_data[xx][1] == "VECTORS" then
				dist_temp = 0
			end
			if des_app == "------" then
				dist_dest = dist_dest + dist_temp
			else
				if xx <= rnav_idx_last then
					dist_dest = dist_dest + dist_temp
				end
			end
			last_speed = speed_temp2
			legs_data[xx][15] = simDR_fuel_weight
			if time_calc_enable == 1 then
				
				speed_temp1 = (speed_temp1 + speed_temp2) / 2
				
				-- calc T/C distance and time
				if tc_idx ~= 0 and B738DR_flight_phase < 2 then
					if xx <= tc_idx then
						dist_tc = dist_tc + dist_temp
						if xx == tc_idx then
							dist_tc = dist_tc - tc_dist
							time_temp = ((legs_data[xx][3] - tc_dist) * 1852) / (speed_temp1 * 0.51444)	-- seconds
							time_temp = time_temp / 3600	-- hours
							if xx == offset or xx == 1 then
								time_temp = (time_zulu + time_temp) % 24
							else
								time_temp = (legs_data[xx-1][13] + time_temp) % 24
							end
							time_tc = time_temp
						end
					end
				end
				
				-- calc T/D distance and time
				if td_idx ~= 0 and B738DR_flight_phase < 5 and offset <= td_idx then
					if xx <= td_idx then
						dist_td = dist_td + dist_temp
						if xx == td_idx then
							dist_td = dist_td - td_dist
							time_temp = ((legs_data[xx][3] - td_dist) * 1852) / (speed_temp1 * 0.51444)	-- seconds
							time_temp = time_temp / 3600	-- hours
							if xx == offset or xx == 1 then
								time_temp = (time_zulu + time_temp) % 24
							else
								time_temp = (legs_data[xx-1][13] + time_temp) % 24
							end
							time_td = time_temp
						end
					end
				end
				
				-- calc E/D distance and time
				if ed_found ~= 0 and B738DR_flight_phase > 4 and offset <= ed_found then
					if xx <= ed_found then
						dist_ed = dist_ed + dist_temp
						if xx == ed_found then
							time_temp = (legs_data[xx][3] * 1852) / (speed_temp1 * 0.51444)	-- seconds
							time_temp = time_temp / 3600	-- hours
							if xx == offset or xx == 1 then
								time_temp = (time_zulu + time_temp) % 24
							else
								time_temp = (legs_data[xx-1][13] + time_temp) % 24
							end
							time_ed = time_temp
						end
					end
				end
				
				time_temp = (dist_temp * 1852) / (speed_temp1 * 0.51444)	-- seconds
				time_temp = time_temp / 3600	-- hours
				if xx == offset or xx == 1 then
					time_temp = (time_zulu + time_temp) % 24
				else
					time_temp = (legs_data[xx-1][13] + time_temp) % 24
				end
				legs_data[xx][13] = time_temp
			end
		end
		-- if offset ~= old_idx_temp then
			-- old_id = old_id_temp
			-- old_lat = old_lat_temp
			-- old_lon = old_lon_temp
		-- end
		-- old_idx_temp = offset
		-- old_id_temp = legs_data[offset][1]		-- id string
		-- old_lat_temp = legs_data[offset][7]		-- latitude
		-- old_lon_temp = legs_data[offset][8]		-- longitude
	end

end

function clr_repeat_timer()
	clr_repeat_time = 0
end

function B738_legs_step2()

	map_mode = B738DR_capt_map_mode
	
	if legs_step < offset then
		legs_step = offset
		page_legs_step = 1
	end
	
	
	if map_mode ~= map_mode_old then		--step
		if map_mode == 3 then
			act_page = page_legs_step
		else
			act_page = 1
		end
	end
	map_mode_old = map_mode
end

function B738_legs_step()
	
	map_mode = B738DR_capt_map_mode
	--local temp_offs = legs_step
	local off_minus_1 = 0
	
	if legs_num > 0 then -- and legs_step <= legs_num then
		
		if offset == 0 then
			offset = 1
		end
		
		if offset_old ~= offset and page_legs_step ~= 0 then
			
			-- if offset > temp_offs then
				-- temp_offs = offset - 1
			-- end
			-- if legs_step < temp_offs then
				-- legs_step = legs_step + (offset - offset_old)
			-- end
			
			off_minus_1 = offset - 1
			if off_minus_1 <= 0 then
				off_minus_1 = 1
			end
			legs_step = math.max(off_minus_1, legs_step)
			
			offset_old = offset
		end
		legs_step = math.max(legs_step, 1)
		legs_step = math.min(legs_step, legs_num)
		
		if page_legs == 1 then
			if map_mode ~= map_mode_old then		--step
				if map_mode == 3 then		--step
					if page_legs_step == 0 then
						if offset < 3 then
							legs_step = 1
							page_legs_step = 1
							simCMD_FMS_key_6R:once()
						else
							page_legs_step = act_page
							simCMD_FMS_key_6R:once()
							simCMD_FMS_key_6R:once()
						end
					end
					act_page = page_legs_step
				else
					act_page = 1
					simCMD_FMS_key_legs:once()
				end
				map_mode_old = map_mode
			else
				if map_mode == 3 then
					page_legs_step = act_page
				end
			end
		end
	end
	
end


function B738_found_nav()
	if legs_add == 1 then
		if found_navaid == 0 then
			found_navaid = 1
			navaid_num = 0
			navaid = entry
			entry = ""
		end
		if found_navaid == 2 then
			found_navaid = 3
			if navaid_num == 0 then
				legs_add = 3
				simCMD_FMS_key_6L:once()
				simCMD_FMS_key_clear:once()
				simCMD_FMS_key_delete:once()
				simCMD_FMS_key_clear:once()
				--act_page = 1
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = NOT_IN_DATABASE
				--entry = NOT_IN_DATABASE
			else
				if navaid_num > 1 then
					simCMD_FMS_key_1L:once()
					act_page = 1
				end
				entry = ""
				--legs_add_select = 0
			end
		end
	end
	
	if legs_dir == 1 then
		if found_navaid == 0 then
			found_navaid = 1
			navaid_num = 0
			navaid = entry
			--entry = ""
		end
		if found_navaid == 2 then
			found_navaid = 3
			if navaid_num == 0 then
				legs_dir = 3
				-- simCMD_FMS_key_6L:once()
				-- simCMD_FMS_key_clear:once()
				-- simCMD_FMS_key_delete:once()
				-- simCMD_FMS_key_clear:once()
				--act_page = 1
				entry = ""
				legs_dir = 0
				legs_intdir = 0
				fmc_message_num = fmc_message_num + 1
				fmc_message[fmc_message_num] = NOT_IN_DATABASE
				--entry = NOT_IN_DATABASE
			else
				simCMD_FMS_key_dir_intc:once()
				type_to_fmc(entry)
				simCMD_FMS_key_1L:once()
				if navaid_num > 1 then
					simCMD_FMS_key_1L:once()
				end
				act_page = 1
				entry = ""
				last_lat = math.rad(simDR_latitude) 
				last_lon = math.rad(simDR_longitude) 
				--legs_add_select = 0
			end
		end
	end
	
	-- if legs_ovwr == 1 then
		-- if found_navaid == 0 then
			-- found_navaid = 1
			-- navaid_num = 0
			-- navaid = entry
			-- entry = ""
		-- end
		-- if found_navaid == 2 then
			-- found_navaid = 3
			-- if navaid_num == 0 then
				-- simCMD_FMS_key_6L:once()
				-- simCMD_FMS_key_clear:once()
				-- simCMD_FMS_key_delete:once()
				-- simCMD_FMS_key_clear:once()
			-- else
				-- if navaid_num > 1 then
					-- simCMD_FMS_key_1L:once()
				-- end
				-- --simCMD_FMS_key_exec:once()
				-- entry = ""
			-- end
			-- legs_ovwr = 0
			-- legs_offset = 0
			-- legs_select = 0
		-- end
	-- end

end

-- function B738_bank_angle()

	-- local off_1 = 0
	-- local temp_course = 0
	-- local temp_course2 = 0
	-- local temp_course3 = 0
	-- local relative_course = 0
	-- local relative_course2 = 0
	-- local enable_bank_angle = 0
	-- local nav_hdots = 2.5
	-- local bank = math.abs(simDR_roll)
	
	-- off_1 = offset + 1
	
	-- if B738DR_heading_mode == 1 then	-- HDG mode
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
		-- lock_bank = 0
	-- elseif B738DR_heading_mode == 2 then	-- VOR LOC mode
		-- if bank > 15 and lock_bank == 0 then
			-- lock_bank = 1
		-- end
		-- -- if nav_hdots ~= nil then
			-- -- nav_hdots = math.abs(simDR_nav1_hdef_pilot)
		-- -- end
		-- -- if nav_hdots < 0.2 and then
			-- -- lock_bank = 2
		-- -- end
		-- if bank < 5 then
			-- lock_bank = 2
		-- end
		-- if lock_bank == 2 then
			-- simDR_bank_angle = 4
		-- end
	-- elseif B738DR_heading_mode == 3 then	-- APP mode
		-- if bank > 20 and lock_bank == 0 then
			-- lock_bank = 1
		-- end
		-- if bank < 5 then
			-- lock_bank = 2
		-- end
		-- if lock_bank == 2 then
			-- simDR_bank_angle = 4
		-- end
	-- else
		-- if B738DR_heading_mode > 3 and B738DR_heading_mode < 7 then	--LNAV
		-- --if B738DR_altitude_mode == 5 then	--VNAV
			-- if off_1 <= legs_num then
				-- -- if legs_data[offset][1] == "PPOS" then
					-- -- temp_course = simDR_fmc_crs
				-- -- else
					-- -- temp_course = (math.deg(legs_data[offset][2]) + simDR_mag_variation) % 360
				-- -- end
				-- -- temp_course2 = (math.deg(legs_data[off_1][2]) + simDR_mag_variation) % 360
				-- --temp_course = simDR_fmc_crs
				-- --temp_course2 = (math.deg(legs_data[offset][2]) + simDR_mag_variation) % 360
				-- temp_course = simDR_mag_hdg
				-- temp_course2 = (math.deg(legs_data[off_1][2]) + simDR_mag_variation) % 360
				-- temp_course3 = (math.deg(legs_data[offset][2]) + simDR_mag_variation) % 360
				
				-- if temp_course2 < 0 then
					-- temp_course2 = temp_course2 + 360
				-- end
				-- relative_course = temp_course2 - temp_course
				-- if relative_course < 0 then
					-- relative_course = 360 + relative_course
				-- end
				-- if relative_course > 180 then
					-- relative_course = 360 - relative_course
				-- end
				
				-- relative_course2 = temp_course3 - temp_course
				-- if relative_course2 < 0 then
					-- relative_course2 = 360 + relative_course2
				-- end
				-- if relative_course2 > 180 then
					-- relative_course2 = 360 - relative_course2
				-- end
				-- if relative_course2 < 5 or simDR_fmc_dist < 6 then
					-- enable_bank_angle = 1
				-- end
				
				-- if enable_bank_angle == 1 then
					-- if relative_course < 5 then
						-- simDR_bank_angle = 2
					-- elseif relative_course < 45 then
						-- simDR_bank_angle = 3
					-- elseif relative_course < 100 then
						-- simDR_bank_angle = 4
					-- elseif relative_course < 120 then
						-- simDR_bank_angle = 5
					-- else
						-- simDR_bank_angle = 6
					-- end
				-- end
				-- B738DR_bank_angle = relative_course
			-- end
		-- else
			-- simDR_bank_angle = 4
		-- end
		-- lock_bank = 0
	-- end

-- end

-- function B738_bank_angle2()

	-- local relative_brg = 0
	-- local true_brg = 0
	-- local true_hdg = 0
	-- local off_1 = offset + 1
	-- local act_rel_brg = 0
	-- local next_rel_brg = 0
	
	-- if B738DR_heading_mode == 4 then	-- LNAV mode
		-- if legs_num > 0 then
			-- true_brg = (math.deg(legs_data[offset][2]) + simDR_mag_variation) % 360
			-- true_hdg = simDR_mag_hdg
			-- relative_brg = (true_brg - true_hdg + 360) % 360
			-- if relative_brg > 180 then
				-- relative_brg = relative_brg - 360
			-- end
			-- act_rel_brg = relative_brg
		-- end
		-- if lock_bank == 0 then
			-- act_rel_brg = math.abs(act_rel_brg)
			-- if act_rel_brg < 2 or simDR_fmc_dist < 6 then
				-- lock_bank = 1
				-- next_rel_brg = 0
				-- if off_1 <= legs_num then
					-- true_brg = (math.deg(legs_data[off_1][2]) + simDR_mag_variation) % 360
					-- if simDR_fmc_dist < 2 then
						-- true_hdg = simDR_mag_hdg
					-- else
						-- true_brg = (math.deg(legs_data[offset][2]) + simDR_mag_variation) % 360
					-- end
					-- relative_brg = (true_brg - true_hdg + 360) % 360
					-- if relative_brg > 180 then
						-- relative_brg = relative_brg - 360
					-- end
					-- next_rel_brg = relative_brg
				-- end
				-- next_rel_brg = math.abs(next_rel_brg)
				-- if next_rel_brg < 30 then
					-- simDR_bank_angle = 2
				-- elseif next_rel_brg < 60 then
					-- simDR_bank_angle = 3
				-- elseif next_rel_brg < 90 then
					-- simDR_bank_angle = 4
				-- elseif next_rel_brg < 120 then
					-- simDR_bank_angle = 5
				-- else
					-- simDR_bank_angle = 6
				-- end
				-- if legs_data[off_1][3] < 4 and simDR_bank_angle < 6 then
					-- simDR_bank_angle = simDR_bank_angle + 1
				-- end
				-- if legs_data[off_1][3] < 2 and simDR_bank_angle < 6 then
					-- simDR_bank_angle = simDR_bank_angle + 1
				-- end
				-- --lock_bank = 2
			-- end
		-- end
		-- --simDR_bank_angle = 5
	-- else
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
		-- lock_bank = 0
	-- end
	
	-- if legs_num > 0 then
		-- true_brg = (math.deg(legs_data[offset][2]) + simDR_mag_variation) % 360
		-- true_hdg = simDR_mag_hdg
		-- relative_brg = (true_brg - true_hdg + 360) % 360
		-- if relative_brg > 180 then
			-- relative_brg = relative_brg - 360
		-- end
		-- DR_test = relative_brg
		
		-- if off_1 <= legs_num then
			-- true_brg = (math.deg(legs_data[off_1][2]) + simDR_mag_variation) % 360
			-- true_hdg = simDR_mag_hdg
			-- relative_brg = (true_brg - true_hdg + 360) % 360
			-- if relative_brg > 180 then
				-- relative_brg = relative_brg - 360
			-- end
			-- DR_test2 = relative_brg
		-- else
			-- DR_test2 = 0
		-- end
	-- else
		-- DR_test = 0
		-- DR_test2 = 0
	-- end
	
	-- -- if B738DR_heading_mode == 1 then	-- HDG mode
		-- -- if B738DR_autopilot_bank_angle_pos == 4 then
			-- -- simDR_bank_angle = 6
		-- -- elseif B738DR_autopilot_bank_angle_pos == 3 then
			-- -- simDR_bank_angle = 5
		-- -- elseif B738DR_autopilot_bank_angle_pos == 2 then
			-- -- simDR_bank_angle = 4
		-- -- elseif B738DR_autopilot_bank_angle_pos == 1 then
			-- -- simDR_bank_angle = 3
		-- -- elseif B738DR_autopilot_bank_angle_pos == 0 then
			-- -- simDR_bank_angle = 2
		-- -- end
	-- -- elseif B738DR_heading_mode == 2 and simDR_nav_status < 2 then
		-- -- if B738DR_autopilot_bank_angle_pos == 4 then
			-- -- simDR_bank_angle = 6
		-- -- elseif B738DR_autopilot_bank_angle_pos == 3 then
			-- -- simDR_bank_angle = 5
		-- -- elseif B738DR_autopilot_bank_angle_pos == 2 then
			-- -- simDR_bank_angle = 4
		-- -- elseif B738DR_autopilot_bank_angle_pos == 1 then
			-- -- simDR_bank_angle = 3
		-- -- elseif B738DR_autopilot_bank_angle_pos == 0 then
			-- -- simDR_bank_angle = 2
		-- -- end
	-- -- elseif B738DR_heading_mode == 3 and simDR_approach_status < 2 then
		-- -- if B738DR_autopilot_bank_angle_pos == 4 then
			-- -- simDR_bank_angle = 6
		-- -- elseif B738DR_autopilot_bank_angle_pos == 3 then
			-- -- simDR_bank_angle = 5
		-- -- elseif B738DR_autopilot_bank_angle_pos == 2 then
			-- -- simDR_bank_angle = 4
		-- -- elseif B738DR_autopilot_bank_angle_pos == 1 then
			-- -- simDR_bank_angle = 3
		-- -- elseif B738DR_autopilot_bank_angle_pos == 0 then
			-- -- simDR_bank_angle = 2
		-- -- end
	-- -- else
		-- -- -- relative_hdg = math.abs(simDR_nav1_relative_hdg)
		-- -- -- if relative_hdg < 10 then 
			-- -- simDR_bank_angle = 4
		-- -- -- end
	-- -- end

-- end

function B738_disable_bank_angle()
	
	if B738DR_autopilot_bank_angle_pos == 4 then
		simDR_bank_angle = 6
	elseif B738DR_autopilot_bank_angle_pos == 3 then
		simDR_bank_angle = 5
	elseif B738DR_autopilot_bank_angle_pos == 2 then
		simDR_bank_angle = 4
	elseif B738DR_autopilot_bank_angle_pos == 1 then
		simDR_bank_angle = 3
	elseif B738DR_autopilot_bank_angle_pos == 0 then
		simDR_bank_angle = 2
	end

end

function B738_chock()
	if B738DR_chock_status == 1 then
		if simDR_on_ground_0 == 1 and simDR_on_ground_1 == 1 and simDR_on_ground_2 == 1 then
			simDR_pos_x = chock_pos_x
			simDR_pos_y = chock_pos_y
			simDR_pos_z = chock_pos_z
			simDR_pos_vx = 0
			simDR_pos_vy = 0
			simDR_pos_vz = 0
			simDR_pos_ax = 0
			simDR_pos_ay = 0
			simDR_pos_az = 0
		end
	end
end

function B738_pause_td()
	if B738DR_pause_td == 1 then
		if td_idx ~= 0 and B738DR_vnav_td_dist < 8 and pause_td_disable == 0 then
			pause_td_disable = 1
			if simDR_pause == 0 then
				simCMD_pause:once()
			end
		end
		if td_idx ~= 0 and B738DR_vnav_td_dist > 10 then
			pause_td_disable = 0
		end
		
	else
		if simDR_pause == 1 then
			simCMD_pause:once()
		end
		pause_td_disable = 0
	end
end

function B738_calc_vnav_spd()
	
	local ci = 0
	
	if cost_index ~= "***" and gw ~= "***.*" and crz_alt_num > 0 then
		ci = tonumber(cost_index)
		if crz_alt_num <= 10000 then
			econ_clb_spd = 250
			econ_clb_spd_mach = 0.67
			econ_crz_spd = 250
			econ_crz_spd_mach = 0.70
			econ_des_spd = 240
			econ_des_spd_mach = 0.67
			econ_des_vpa = 2.6		--B738_rescale(0, 2.6, 500, 3.0, ci)
		else
			econ_clb_spd = B738_rescale(0, 270, 500, 330, ci)
			econ_clb_spd_mach = B738_rescale(0, 0.665, 500, 0.82, ci)
			econ_crz_spd = B738_rescale(0, 300, 500, 330, ci)
			econ_crz_spd_mach = B738_rescale(0, 0.78, 500, 0.82, ci)
			econ_des_spd = B738_rescale(0, 270, 500, 320, ci)
			econ_des_spd_mach = B738_rescale(0, 0.665, 500, 0.80, ci)
			econ_des_vpa = B738_rescale(0, 2.6, 500, 3.0, ci)
		end
		B738DR_fmc_climb_speed_mach = econ_clb_spd_mach		-- temporary
		B738DR_fmc_climb_speed = econ_clb_spd				-- temporary
		B738DR_fmc_cruise_speed_mach = econ_crz_spd_mach	-- temporary
		B738DR_fmc_cruise_speed = econ_crz_spd				-- temporary
		B738DR_fmc_descent_speed_mach = econ_des_spd_mach	-- temporary
		B738DR_fmc_descent_speed = econ_des_spd				-- temporary
		B738DR_climb_mode = 0
		B738DR_cruise_mode = 0
		B738DR_descent_mode = 0
		vnav_update = 1
	end

end


function B738_fmc_on()
	if simDR_bus_volts1 > 10 or simDR_bus_volts2 > 10 then
		fmc_enable = 1
		if reset_fmc == 1 then
			B738_init2()
			--simCMD_FMS_reset:once()
		end
		reset_fmc = 0
	else
		fmc_enable = 0
		if reset_fmc == 0 then
			reset_fmc = 1
			B738_init2()
			--simCMD_FMS_reset:once()
		end
	end
end

function B738_vnav_desc_spd()

	local vnav_desc_spd_disable = 0
	
	if B738DR_autopilot_vnav_status == 1 then
		if legs_num > 0 and offset > 0 and  offset < (legs_num + 1) then
			if legs_data[offset][9] == des_app --or legs_data[offset][9] == des_star 
			or legs_data[offset][9] == des_app_tns --or legs_data[offset][9] == des_star_trans 
			or offset > ed_found then
				vnav_desc_spd_disable = 1
			end
		end
		if simDR_flaps_ratio > 0 then
			vnav_desc_spd_disable = 1
		end
	else
		vnav_desc_spd_disable = 1
	end
	B738DR_vnav_desc_spd_disable = vnav_desc_spd_disable

	-- if B738DR_flight_phase > 4 end
		-- if simDR_ap_altitude_mode == 5 then	-- phase descent
			-- B738DR_descent_mode = 2
		-- else
			-- B738DR_descent_mode = 0
		-- end
	-- end
	
end

function B738_pre_flt_status()
	
	pre_flt_pos_init = 1
	pre_flt_rte = 1
	pre_flt_perf_init = 1
	pre_flt_dep = 1
	
	if irs_pos == "*****.*******.*" then
		pre_flt_pos_init = 0
	end
	if legs_num == 0 then
		pre_flt_rte = 0
	end
	if gw == "***.*" or zfw == "***.*" or reserves == "**.*" or cost_index == "***" or crz_alt == "*****" then
		pre_flt_perf_init = 0
	end
	if ref_rwy == "-----" then
		pre_flt_dep = 0
	end
	
end


function B738_wind()
	
	head_wind = simDR_wind_spd * math.cos(math.rad(Angle180(simDR_wind_hdg))-math.rad(simDR_position_mag_psi))
	cross_wind = simDR_wind_spd * math.sin(math.rad(Angle180(simDR_wind_hdg))-math.rad(simDR_position_mag_psi))
	
end


function B738_detect_center_line()

	local cl_icao = ""
	local cl = 0
	local cl_crs1 = 0
	local cl_crs2 = 0
	
	local nd_lat = 0 
	local nd_lon = 0 
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_x = 0
	local nd_y = 0
	local nd_hdg = 0
	local delta_hdg = 0
	local min_delta = 0
	local lat_wpt = 0
	local lon_wpt = 0
	local temp_d_R = 0
	local temp_brg = 0
	local temp_lat = 0
	
	if simDR_radio_height_pilot_ft > 50 then
		cl_icao_found = 0
	end
	
	if simDR_on_ground_0 == 1 then	-- nosewheel on the ground
		--temp_brg = math.rad((simDR_mag_hdg - simDR_mag_variation + 360) % 360)
		temp_brg = math.rad((simDR_mag_hdg - simDR_mag_variation + 360) % 360)
		lat_wpt = math.rad(simDR_latitude)
		lon_wpt = math.rad(simDR_longitude)
		temp_d_R = 0.00842332613 / 3440.064795	--distance to nosewheel from center plane in NM
		temp_lat = math.asin(math.sin(lat_wpt)*math.cos(temp_d_R) + math.cos(lat_wpt)*math.sin(temp_d_R)*math.cos(temp_brg))
		nd_lon = lon_wpt + math.atan2(math.sin(temp_brg)*math.sin(temp_d_R)*math.cos(lat_wpt), math.cos(temp_d_R)-math.sin(lat_wpt)*math.sin(temp_lat))
		nd_lat = temp_lat
		
		if cl_icao_found == 0 then
			if nd_page == 0 then
				cl_icao = near_apt2_icao
			else
				cl_icao = near_apt1_icao
			end
			-- find runways
			cl_icao_found = 1
			cl_num = 0
			cl_lat1 = {}
			cl_lon1 = {}
			cl_lat2 = {}
			cl_lon2 = {}
			if rnw_data_num > 0 then
				for cl = 1, rnw_data_num do
					if rnw_data[cl][1] == cl_icao then
						cl_num = cl_num + 1
						cl_lat1[cl_num] = rnw_data[cl][3]
						cl_lon1[cl_num] = rnw_data[cl][4]
						cl_lat2[cl_num] = rnw_data[cl][5]
						cl_lon2[cl_num] = rnw_data[cl][6]
					end
				end
			end
		end
		-- calculate course
		min_delta = 500
		if cl_num > 0 then
			for cl = 1, cl_num do
				nd_lat2 = math.rad(cl_lat1[cl])
				nd_lon2 = math.rad(cl_lon1[cl])
				nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
				nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
				nd_hdg = math.atan2(nd_y, nd_x)
				nd_hdg = math.deg(nd_hdg)
				cl_crs1 = (nd_hdg + 360) % 360
				
				nd_lat2 = math.rad(cl_lat2[cl])
				nd_lon2 = math.rad(cl_lon2[cl])
				nd_y = math.sin(nd_lon2 - nd_lon) * math.cos(nd_lat2)
				nd_x = math.cos(nd_lat) * math.sin(nd_lat2) - math.sin(nd_lat) * math.cos(nd_lat2) * math.cos(nd_lon2 - nd_lon)
				nd_hdg = math.atan2(nd_y, nd_x)
				nd_hdg = math.deg(nd_hdg)
				cl_crs2 = (nd_hdg + 360 + 180) % 360
				
				delta_hdg = cl_crs1 - cl_crs2
				if delta_hdg < 0 then
					delta_hdg = -delta_hdg
				end
				if delta_hdg < min_delta then
					min_delta = delta_hdg
				end
			end
			if min_delta < CL_THRSHLD then		-- Center line THRSHLD
				B738DR_center_line = 1
			else
				B738DR_center_line = 0
			end
		end
	else
		B738DR_center_line = 0
	end
end




function B738_init2()
xxx_str = ""
xxx = 0


version = ""
file_navdata = 0

clr_repeat = 0
clr_repeat_time = 0

scratch_error = 0
--decode_value = 0
decode_value_mach = 0
decode_value2 = 0
--index_pos = 0
i = 0
delete_active = 0
FMS_page = 0

input_1L = 0
input_2L = 0
input_3L = 0
input_4L = 0
input_5L = 0
input_6L = 0

input_1R = 0
input_2R = 0
input_3R = 0
input_4R = 0
input_5R = 0
input_6R = 0

blank_data = 0

line0_l = ""
line1_l = ""
line2_l = ""
line3_l = ""
line4_l = ""
line5_l = ""
line6_l = ""
line0_s = ""
line1_s = ""
line2_s = ""
line3_s = ""
line4_s = ""
line5_s = ""
line6_s = ""
line1_x = ""
line2_x = ""
line3_x = ""
line4_x = ""
line5_x = ""
line6_x = ""
line0_inv = ""
line1_inv = ""
line2_inv = ""
line3_inv = ""
line4_inv = ""
line5_inv = ""
line6_inv = ""

max_page = 0
act_page = 0
act_page_old = 0
page_clear = 0

page_menu = 0
page_ident = 0
page_init = 0
page_takeoff = 0
display_update = 1
page_approach = 0
page_perf = 0
page_n1_limit = 0
page_pos_init = 0
page_route = 0
page_dep_arr = 0
page_dep = 0
page_arr = 0
page_descent = 0
page_descent_forecast = 0
page_legs = 0
page_rte_init = 0
page_climb = 0
page_cruise = 0
page_sel_wpt = 0
page_sel_wpt2 = 0


page_legs_step = 0
legs_step = 0
map_mode = 2
map_mode_old = 2

entry = ""
entry_inv = ""
entry_wind_dir = ""
entry_wind_spd = ""

FMS_popup = 0

v1 = "---"
vr = "---"
v2 = "---"
flaps = "**"
vref_15 = "   "
vref_30 = "   "
vref_40 = "   "
flaps_app = "  "

gw_act = "    "
v1_set = "---"
vr_set = "---"
v2_set = "---"
irs_pos_set = "*****.*******.*"
gps_right = "-----.-------.-"
gps_left = "-----.-------.-"
last_pos = "-----.-------.-"
fmc_pos = "-----.-------.-"
last_pos_enable = 1

ref_icao = "----"
ref_gate = "-----"
des_icao = "****"
co_route = "------------"
flt_num = "--------"
ref_rwy = "-----"
des_rwy = "----"

gw = "***.*"
gw_calc = "***.*"
gw_lbs = "***.*"
gw_kgs = "***.*"

zfw_calc = "---.-"
zfw_calc_lbs = "---.-"
zfw_calc_kgs = "---.-"

fuel_weight = "--.-"
fuel_weight_lbs = "--.-"
fuel_weight_kgs = "--.-"

plan_weight = "---.-"
plan_weight_kgs = "---.-"
plan_weight_lbs = "---.-"

zfw = "***.*"
zfw_kgs = "***.*"
zfw_lbs = "***.*"

reserves = "**.*"
reserves_kgs = "**.*"
reserves_lbs = "**.*"

cost_index = "***"
econ_clb_spd = 0
econ_clb_spd_mach = 0
econ_crz_spd = 0
econ_crz_spd_mach = 0
econ_des_spd = 0
econ_des_spd_mach = 0
econ_des_vpa = 0.0

crz_alt = "*****"
crz_alt_num = 0
crz_alt_num2 = 0
crz_spd = "---"
crz_spd_mach = ".---"
crz_alt_old = "*****"
crz_spd_old = "---"
crz_spd_mach_old = ".---"
crz_exec = 0
clb_alt = "----"
clb_alt_num = 1500
accel_alt = "----"
accel_alt_num = 1000
crz_wind_dir = "---"
crz_wind_spd = "---"
rw_wind_dir = "---"
rw_wind_spd = "---"
rw_slope = "--.-"
rw_hdg = "---"
--trans_alt = "18000"
trans_alt = "-----"

trans_lvl = "-----"
isa_dev_f = "---"
isa_dev_c = "---"
tc_oat_f = "---"
tc_oat_c = "---"

forec_alt_1 = "-----"
forec_alt_1_num = 0
forec_dir_1 = "---"
forec_spd_1 = "---"
forec_alt_2 = "-----"
forec_alt_2_num = 0
forec_dir_2 = "---"
forec_spd_2 = "---"
forec_alt_3 = "-----"
forec_alt_3_num = 0
forec_dir_3 = "---"
forec_spd_3 = "---"
cabin_rate = "---"
forec_isa_dev = "---"
forec_qnh = "------"

to = "<ACT>"
to_1 = "     "
to_2 = "     "
clb = "<SEL>"
clb_1 = "     "
clb_2 = "     "
sel_clb_thr = 0
rw_cond = 0
cg = "--.-"
trim = "    "
time_err = "  "
--units = 0
units_recalc = 0
weight_min = 90
weight_max = 180

clb_min_kts = "   "
clb_min_mach = "   "
clb_max_kts = "   "
clb_max_mach = "   "
crz_min_kts = "   "
crz_min_mach = "   "
crz_max_kts = "   "
crz_max_mach = "   "
des_min_kts = "   "
des_min_mach = "   "
des_max_kts = "   "
des_max_mach = "   "


latitude_deg = ""
latitude_min = ""
longitude_deg = ""
longitude_min = ""
irs_hdg = "---`"
irs_pos = "*****.*******.*"
--irs_pos = ""

msg_irs_pos = 0
msg_irs_hdg = 0
zulu_time = "             "
ground_air = 0
fmc_gs = ""
irs_gs = ""
irs2_gs = ""
oat_sim = "    "
oat = "    "
sel_temp = "----"
sel_temp_f = "----"
oat_f = "    "
oat_sim_f = "    "
oat_unit = "`C"

wind_corr = "--"
app_flap = "--"
app_spd = "---"

msg_to_vspeed = 0
qrh = "OFF"
msg_mcp_alt = 0
msg_gps_l_fail = 0
msg_gps_r_fail = 0
msg_gps_lr_fail = 0
msg_irs_motion = 0
msg_drag_req = 0
msg_nav_data = 0
msg_unavaible_crz_alt = 0
msg_chk_alt_tgt = 0
msg_tai_above_10 = 0

auto_act = "<ACT>"
ga_act = "     "
con_act = "     "
clb_act = "     "
crz_act = "     "

tai_on_alt = "-----"
tai_off_alt = "-----"


eng_out_prompt = 0

was_on_air = 0
takeoff_enable = 0
climb_enable = 1
descent_enable = 0
goaround_enable = 0
fmc_climb_mode = 0
fmc_cruise_mode = 0
fmc_cont_mode = 0
fmc_takeoff_mode = 0
fmc_goaround_mode = 0
fms_N1_mode = 0
fms_N1_to_mode_sel = 0
fms_N1_clb_mode_sel = 0
in_flight_mode = 0


disable_POS_2L = 0
disable_POS_3L = 0
disable_POS_4R = 0
disable_POS_5R = 0
disable_PERF_3R = 0
disable_PERF_4R = 0
disable_N1_6L = 0
disable_N1_6R = 0


fmc_full_thrust = 0.984
fmc_dto_thrust = 0.984
fmc_sel_thrust = 0.984
fmc_clb_thrust = 0.984
fmc_crz_thrust = 0.984
fmc_con_thrust = 0.984
fmc_ga_thrust = 0.984
fmc_auto_thrust = 0.984

next_enable = 1
prev_enable = 1
exec1_light = 0

des_now_enable = 0
drag_timeout = 0

file_name = ""

ref_data = {}
rwy_num = 0
ref_data_sid = {}
sid_num = 0
ref_data_star = {}
star_num = 0
ref_data_star_tns = {}
ref_data_star_tns_n = 0
ref_data_app = {}
ref_data_app_n = 0
ref_data_app_tns = {}
ref_data_app_tns_n = 0
ref_ed_app = {}
ref_ed_app_n = 0

des_data = {}
des_rwy_num = 0

-- data destination star
data_des_star = {}
data_des_star_n = 0

-- data destination star transition
data_des_star_tns = {}
data_des_star_tns_n = 0

ref_data_sid_act = {}
sid_num_act = 0

ref_data_sid_tns = {}
ref_num_sid_tns = 0

ref_data_tns = {}
tns_num = 0

des_data_app_act = {}
des_num_app_act = 0

-- data destinstion approach
data_des_app = {}
data_des_app_n = 0

-- data destination approach transition
data_des_app_tns = {}
data_des_app_tns_n = 0

ed_app_num = 0
ed_app = {}

des_num_star_tns = 0
des_data_star_tns = {}

des_num_app_tns = 0
des_data_app_tns = {}

ref_rwy_map = {}
ref_rwy_map_num = 0

ref_trans_alt = 0

ref_sid = "------"
ref_sid_tns = "------"

des_star = "------"
des_star_trans = "------"

-- transition connect STAR <-> APP
des_star_trans_con = ""

des_app = "------"

des_app_tns = "------"

ref_rwy_exec = 0
ref_sid_exec = 0
ref_tns_exec = 0
ref_app_tns_exec = 0
des_star_exec = 0
des_star_tns_exec = 0
des_app_exec = 0
des_app_tns_exec = 0

fpln_num = 0
fpln_data = {}

fpln_data2 = {}
fpln_num2 = 0

legs_data = {}
legs_num = 0

ref_rwy_sel = {}
ref_rwy_sel[1] = ""
ref_rwy_sel[2] = ""
ref_rwy_sel[3] = ""
ref_rwy_sel[4] = ""
ref_rwy_sel[5] = ""

ref_sid_sel = {}
ref_sid_sel[1] = ""
ref_sid_sel[2] = ""
ref_sid_sel[3] = ""
ref_sid_sel[4] = ""
ref_sid_sel[5] = ""

ref_tns_sel = {}
ref_tns_sel[1] = ""
ref_tns_sel[2] = ""
ref_tns_sel[3] = ""
ref_tns_sel[4] = ""
ref_tns_sel[5] = ""

des_star_sel = {}
des_star_sel[1] = ""
des_star_sel[2] = ""
des_star_sel[3] = ""
des_star_sel[4] = ""
des_star_sel[5] = ""

des_star_tns_sel = {}
des_star_tns_sel[1] = ""
des_star_tns_sel[2] = ""
des_star_tns_sel[3] = ""
des_star_tns_sel[4] = ""
des_star_tns_sel[5] = ""

des_app_sel = {}
des_app_sel[1] = ""
des_app_sel[2] = ""
des_app_sel[3] = ""
des_app_sel[4] = ""
des_app_sel[5] = ""

des_tns_sel = {}
des_tns_sel[1] = ""
des_tns_sel[2] = ""
des_tns_sel[3] = ""
des_tns_sel[4] = ""
des_tns_sel[5] = ""

set_ils = 0
--offset = 1
legs_offset = 0
legs_select = 0
legs_delete = 0
legs_delete_item = 0
legs_delete_key = 0

legs_restr_spd = {}
legs_restr_spd_n = 0

legs_restr_alt = {}
legs_restr_alt_n = 0

tc_dist = 0
--tc_idx = 0
tc_lat = 0
tc_lon = 0

--td_dist = 0
--td_idx = 0
td_lat = 0
td_lon = 0

--decel_dist = 0
--decel_idx = 0
decel_lat = 0
decel_lon = 0
was_decel = 0
--ed_found = 0
--ed_alt = 0
--td_idx_last = 0
--td_spd_rest = 0

vnav_update = 0

offset_old = 0

temp_ils3 = ""
temp_ils4 = ""

	max_page = 0
	act_page = 0
	act_page_old = 0
	page_legs_step = 0

	page_menu = 0
	page_ident = 0
	page_init = 0
	page_takeoff = 0
	display_update = 1
	page_approach = 0
	page_perf = 0
	page_n1_limit = 0
	page_pos_init = 0
	page_route = 0
	page_descent = 0
	page_descent_forecast = 0
	page_legs = 0
	page_climb = 0
	page_cruise = 0
	page_progress = 0
	page_hold = 0
	page_xtras = 0
	page_xtras_fmod = 0
	page_xtras_others = 0


	entry = ""

	FMS_popup = 0

	v1 = "---"
	vr = "---"
	v2 = "---"
	flaps = "**"
	vref_15 = "   "
	vref_30 = "   "
	vref_40 = "   "
	flaps_app = "  "

	gw_act = "    "
	v1_set = "---"
	vr_set = "---"
	v2_set = "---"
	irs_pos_set = "*****.*******.*"
	gps_right = "-----.-------.-"
	gps_left = "-----.-------.-"
	last_pos = "-----.-------.-"
	fmc_pos = "-----.-------.-"
	last_pos_enable = 1

	ref_icao = "----"
	ref_gate = "-----"

	gw = "***.*"
	gw_calc = "***.*"
	gw_lbs = "***.*"
	gw_kgs = "***.*"

	zfw_calc = "---.-"
	zfw_calc_lbs = "---.-"
	zfw_calc_kgs = "---.-"

	fuel_weight = "--.-"
	fuel_weight_lbs = "--.-"
	fuel_weight_kgs = "--.-"

	plan_weight = "---.-"
	plan_weight_kgs = "---.-"
	plan_weight_lbs = "---.-"

	zfw = "***.*"
	zfw_kgs = "***.*"
	zfw_lbs = "***.*"

	reserves = "**.*"
	reserves_kgs = "**.*"
	reserves_lbs = "**.*"

	cost_index = "***"
	crz_alt = "*****"
	crz_alt_num = 0
	crz_alt_num2 = 0
	crz_spd = "300"
	crz_spd_mach = ".800"
	crz_alt_old = "*****"
	crz_spd_old = "---"
	crz_spd_mach_old = ".---"
	crz_exec = 0
	crz_wind_dir = "---"
	crz_wind_spd = "---"
	trans_alt = "-----"
	trans_lvl = "-----"
	isa_dev_f = "---"
	isa_dev_c = "---"
	tc_oat_f = "---"
	tc_oat_c = "---"
	
	forec_alt_1 = "-----"
	forec_dir_1 = "---"
	forec_spd_1 = "---"
	forec_alt_2 = "-----"
	forec_dir_2 = "---"
	forec_spd_2 = "---"
	forec_alt_3 = "-----"
	forec_dir_3 = "---"
	forec_spd_3 = "---"
	cabin_rate = "---"
	forec_isa_dev = "---"
	forec_qnh = "------"

	to = "<ACT>"
	to_1 = "     "
	to_2 = "     "
	clb = "<SEL>"
	clb_1 = "     "
	clb_2 = "     "
	sel_clb_thr = 0
	rw_cond = 0
	cg = "--.-"
	trim = "    "
	time_err = "  "
	--units = 0
	units_recalc = 0
	weight_min = 90
	weight_max = 180

	rw_wind_dir = "---"
	rw_wind_spd = "---"
	rw_slope = "--.-"
	rw_hdg = "---"

	tai_on_alt = "-----"
	tai_off_alt = "-----"


	clb_min_kts = "   "
	clb_min_mach = "   "
	clb_max_kts = "   "
	clb_max_mach = "   "
	crz_min_kts = "   "
	crz_min_mach = "   "
	crz_max_kts = "   "
	crz_max_mach = "   "
	des_min_kts = "   "
	des_min_mach = "   "
	des_max_kts = "   "
	des_max_mach = "   "

	latitude_deg = ""
	latitude_min = ""
	longitude_deg = ""
	longitude_min = ""
	irs_hdg = "---`"
	irs_pos = "*****.*******.*"
	msg_irs_pos = 0
	msg_irs_hdg = 0
	zulu_time = "             "
	ground_air = 0
	fmc_gs = ""
	irs_gs = ""
	irs2_gs = ""
	oat_sim = "    "
	oat = "    "
	sel_temp = "----"
	sel_temp_f = "----"
	oat_f = "    "
	oat_sim_f = "    "
	oat_unit = "`C"
	auto_act = "<ACT>"
	ga_act = "     "
	con_act = "     "
	clb_act = "     "
	crz_act = "     "
	was_on_air = 0

	wind_corr = "--"
	app_flap = "--"
	app_spd = "---"
	
	eng_out_prompt = 0

	fmc_message = {}
	fmc_message_num = 0

	msg_to_vspeed = 0
	qrh = "OFF"
	msg_mcp_alt = 0
	msg_gps_l_fail = 0
	msg_gps_r_fail = 0
	msg_gps_lr_fail = 0
	msg_irs_motion = 0
	msg_drag_req = 0
	msg_above_max = 0
	msg_vref_not_sel = 0
	msg_chk_alt_constr = 0
	
	takeoff_enable = 0
	climb_enable = 1
	descent_enable = 0
	goaround_enable = 0
	fmc_climb_mode = 0
	fmc_cruise_mode = 0
	fmc_cont_mode = 0
	fmc_takeoff_mode = 0
	fmc_goaround_mode = 0
	in_flight_mode = 0


	disable_POS_2L = 0
	disable_POS_3L = 0
	disable_POS_4R = 0
	disable_POS_5R = 0
	disable_PERF_3R = 0
	disable_PERF_4R = 0
	disable_N1_6L = 0
	disable_N1_6R = 0


	B7368DR_fmc1_show = 1

	--units = 0
	page_menu = 1
	max_page = 1
	act_page = 1
	act_page_old = 0
	v1_set = "---"
	vr_set = "---"
	v2_set = "---"
	v1 = "---"
	vr = "---"
	v2 = "---"
	flaps = "**"
	gw_act = "   "
	flaps_app = " "
	gps_right = "-----.-------.-"
	gps_left = "---`--.- ----`--.-"
	to = "<ACT>"
	to_1 = "     "
	to_2 = "     "
	clb = "<SEL>"
	clb_1 = "     "
	clb_2 = "     "
	irs_pos = "*****.*******.*"
	B738DR_irs_hdg_fmc_set = "---"
	B738DR_irs2_hdg_fmc_set = "---"
	last_pos_enable = 1
	irs_hdg = "---`"
	msg_irs_pos = 0
	msg_irs_hdg = 0
	trans_alt = "-----"
	isa_dev_f = "---"
	isa_dev_c = "---"
	tc_oat_f = "---"
	tc_oat_c = "---"
	time_err = "  "
	oat = "    "
	sel_temp = "----"
	sel_temp_f = "----"
	oat_f = "    "
	oat_unit = "`C"
	FMS_popup = 0
	takeoff_enable = 1
	fms_N1_mode = 0
	fms_N1_to_mode_sel = 0
	fms_N1_clb_mode_sel = 0
	clb_alt = "----"
	clb_alt_num = 1500

	fmc_full_thrust = 0.984
	fmc_dto_thrust = 0.984
	fmc_sel_thrust = 0.984
	fmc_clb_thrust = 0.984
	fmc_crz_thrust = 0.984
	fmc_con_thrust = 0.984
	fmc_ga_thrust = 0.984
	fmc_auto_thrust = 0.984
	
	next_enable = 1
	prev_enable = 1
	
	drag_timeout = 0

-- CLIMB default
	B738DR_fmc_climb_speed			= 290
	B738DR_fmc_climb_speed_mach		= 0.74
	B738DR_fmc_climb_r_speed1		= 250
	B738DR_fmc_climb_r_alt1			= 10000
	B738DR_fmc_climb_r_speed2		= 0
	B738DR_fmc_climb_r_alt2			= 0

-- CRUISE default
	B738DR_fmc_cruise_speed			= 300
	B738DR_fmc_cruise_speed_mach	= 0.80
	B738DR_fmc_cruise_alt			= 20000

-- DESCENT default
	B738DR_fmc_descent_speed		= 290
	B738DR_fmc_descent_speed_mach	= 0.74
	B738DR_fmc_descent_alt			= 4000
	B738DR_fmc_descent_r_speed1		= 250
	B738DR_fmc_descent_r_alt1		= 10000
	B738DR_fmc_descent_r_speed2		= 0
	B738DR_fmc_descent_r_alt2		= 0
-- APPROACH default
	B738DR_fmc_approach_alt			= 4000

	econ_clb_spd = 290
	econ_clb_spd_mach = 0.740
	econ_crz_spd = 300
	econ_crz_spd_mach = 0.800
	econ_des_spd = 290
	econ_des_spd_mach = 0.740
	econ_des_vpa = 2.5	--2.5

	B738DR_climb_mode = 3		-- xxxKT/M.xxx CLB
	B738DR_cruise_mode = 2		-- xxxKT/M.xxx CRZ
	B738DR_descent_mode = 2		-- xxxKT/M.xxx SPD DES
	B738DR_flight_phase = 0
	B738DR_fms_descent_now = 0

	page_clear = 0
	
	DRindex = 0.02		--0.002
	decode_value = 0
	index_pos = 0

	exec1_light = 0
	des_now_enable = 0
	B738DR_pfd_vnav_pth = 0
	
	offset = 1
	msg_nav_data = 0
	
	tc_idx = 0
	--decel_idx = 0
	td_idx = 0
	was_decel = 0
	ed_found = 0
	ed_alt = 0
	--td_idx_last = 0
	B738DR_vvi_const = 10
	--td_spd_rest = 0
	clr_repeat = 0
	clr_repeat_time = 0
	legs_step = 1
	offset_old = 0
	--rw_ils = ""
	found_ils = 0
	temp_ils3 = ""
	temp_ils4 = ""
	rnav_idx = 0
	td_fix_dist = 0
	td_fix_idx = 0
	legs_add = 0
	legs_ovwr = 0
	legs_intdir = 0
	legs_dir = 0
	ed_fix_num = 0
	ed_fix_found2 = {}
	ed_fix_alt2 = {}
	dist_dest = 0
	dist_tc = 0
	time_tc = 0
	dist_td = 0
	time_td = 0
	dist_ed = 0
	time_ed = 0
	fms_msg_sound = 0
	legs_page = 0
	legs_button = 0
	direct_to = 0
	direct_to_offset = 0
	B738DR_pfd_vert_path = 0
	B738DR_nd_vert_path = 0
	B738DR_pfd_trk_path = 0
	ed_found = 0
	lock_bank = 0
	file_path = ""
	simDR_cg = 0.40		--0.44		-- 20% MAC   -0.03	-- 8% MAC
	pause_td_disable = 0
	pre_flt_pos_init = 0
	pre_flt_perf_init = 0
	pre_flt_rte = 0
	pre_flt_dep = 0
	last_lat = 0 
	last_lon = 0 
	last_offset = 0
	ref_runway_lenght = 0
	ref_runway_lat = 0
	ref_runway_lon = 0
	ref_runway_crs = 0
	des_runway_lenght = 0
	des_runway_lat = 0
	des_runway_lon = 0
	des_runway_crs = 0
	des_rnw = ""
	
	nd_teak = 0
	nd_from = 0
	nd_to = 0
	nd_page1 = {}
	nd_page2 = {}
	nd_page = 0
	nd_page1_num = 0
	nd_page2_num = 0
	first_time_apt = 0
	near_apt1_dis = 0
	near_apt1_icao = ""
	near_apt2_dis = 0
	near_apt2_icao = ""
	cl_icao_found = 0
	cl_num = 0
	cl_lat1 = {}
	cl_lon1 = {}
	cl_lat2 = {}
	cl_lon2 = {}
	des_app_from_apt = 0
	altitude_last = 0
	ref_icao_pos = "               "
	icao_latitude = 0
	icao_longitude = 0
	icao_tns_alt = 0
	icao_tns_lvl = 0
	
	ref_rnw_list = {}
	ref_rnw_list_num = 0
	ref_rnw_list2 = {}
	ref_rnw_list_num2 = 0
	des_rnw_list = {}
	des_rnw_list_num = 0
	
	sid_list = {}
	sid_list_num = 0
	sid_tns_list = {}
	sid_tns_list_num = 0
	
	star_list = {}
	star_list_num = 0
	star_tns_list = {}
	star_tns_list_num = 0
	des_app_list = {}
	des_app_list_num = 0
	des_app_tns_list = {}
	des_app_tns_list_num = 0
	ref_rwy2 = "-----"
	ref_sid2 = "------"
	ref_sid_tns2 = "------"
	des_app2 = "------"
	des_app_tns2 = "------"
	des_star2 = "------"
	des_star_trans2 = "------"
	refdes_exec = 0
	des_icao_x = "****"
	arr_data = 0
	
	rte_sid = {}
	rte_sid_num = 0
	rte_star = {}
	rte_star_num = 0
	rte_app = {}
	rte_app_num = 0
	
	rte_data_num = 0
	rte_data = {}
	
	item_sel = 0
	
	navaid_list = {}
	navaid_list_n = 0
	
	temp_list = {}
	temp_list_num = 0
	
	rte_lat = 0
	rte_lon = 0
	
	calc_rte_enable = 0
	calc_rte_act = 0
	rte_calc_lat = 0
	rte_calc_lon = 0
	
	calc_rte_enable2 = 0
	calc_rte_act2 = 0
	rte_calc_lat2 = 0
	rte_calc_lon2 = 0
	
	ref_icao_lat = 0
	ref_icao_lon = 0
	des_icao_lat = 0
	des_icao_lon = 0
	ref_tns_alt = 0
	ref_tns_lvl = 0
	des_tns_alt = 0
	des_tns_lvl = 0
	
	add_disco = 0
	
	rte_exec = 0
	dir_change = 0
	dir_idx = 0
	dir_disco = 0
	fpln_data_tmp_n = 0
	fpln_data_tmp = {}
	
	--legs_add_select = 0
	if simDR_startup_running ~= 0 then 
		B738_last_pos()
		irs_pos = last_pos
	end
	
	version = "v3.10O"

end

function chocks_on_start()

	if set_chock == 1 then
		if simDR_on_ground_0 == 1 and simDR_on_ground_1 == 1 and simDR_on_ground_2 == 1 then
			chock_timer = chock_timer + SIM_PERIOD
			if chock_timer > 2 then
				B738DR_chock_status = 1
				chock_pos_x = simDR_pos_x
				chock_pos_y = simDR_pos_y
				chock_pos_z = simDR_pos_z
				set_chock = 0
				chock_timer = 0
			end
		end
	else
		set_chock = 0
	end
end

function B738_exec_light()
	
	local exec_light_tmp = 0
	
	if exec1_light == 1 or legs_delete == 1 then
		exec_light_tmp = 1
	end
	if ref_sid_exec == 1 or ref_rwy_exec == 1 or ref_tns_exec == 1 then
		exec_light_tmp = 1
	end
	if des_star_exec == 1 or des_star_tns_exec == 1 then
		exec_light_tmp = 1
	end
	if des_app_exec == 1 or des_app_tns_exec == 1 then
		exec_light_tmp = 1
	end
	
	if refdes_exec == 1 then
		exec_light_tmp = 1
	end
	if rte_exec == 1 then
		exec_light_tmp = 1
	end
	
	if exec_light_tmp == 1 then
		B738DR_fms_exec_light_pilot = 1
	else
		B738DR_fms_exec_light_pilot = 0
	end

end

--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start() 

	--B738_init()
	
	read_navdata()
	detect_apt_dat()
	
	B738_init2()
	
	apt_data_num = 0
	apt_data = {}
	rnw_data_num = 0
	rnw_data = {}
	read_apt_dat()
	read_rnw_dat()
	
	awy_data_num = 0
	awy_data = {}
	read_awy_dat()
	
	awy_path = {}
	awy_path_num = 0
	
	awy_temp_num2 = 0
	awy_temp2 = {}
	
	via_via_entry = ""
	via_via_ok = 0
	
	B738_find_path()
	B738_detect_fmod()
	B738_default_fmod_config()
	B738_default_others_config()
	B738_load_config()
	simDR_kill_map_fms = 1
	--cold n dark
	if simDR_startup_running == 0 and B738DR_engine_no_running_state == 0 then
		set_chock = 1
	else
		set_chock = 0
	end
	
end

--function flight_crash() end

--function before_physics() 

--end

function after_physics() 

B738_fmc_on()

B738_calc_rte()
B738_calc_rte2()

B738_calc()
B738_fmc_calc()
B738_vnav_calc4()
B738_fmc_time_calc()
B738_vnav_pth()
B738_restrict_data()

--B738_legs_step()
B738_legs_step2()

B738_displ_tc()
B738_displ_td()
B738_displ_decel()
B738_displ_rnw()

B738_nd_perf()
if first_time_apt > 0 then
	B738_displ_apt()
end

if calc_rte_enable == 0 then
	B738_displ_wpt()
end

B738_pre_flt_status()

B738_fmc_menu()
B738_fmc_pos_init()
B738_fmc_takeoff()
B738_fmc_approach()
B738_fmc_perf()
B738_fmc_n1_limit()
B738_fmc_init()
B738_fmc_ident()
B738_fmc_climb()
B738_fmc_cruise()
B738_fmc_descent()
B738_fmc_descent_forecast()
B738_fmc_rte_init()


--B738_fmc_legs()
B738_fmc_legs2()
B738_fmc_dep_arr()

B738_fmc_dep99()
B738_fmc_arr99()

B738_fmc_sel_wpt()
B738_fmc_sel_wpt2()
--B738_fmc_dep()
--B738_fmc_arr()

B738_fmc_progress()

B738_fmc_xtras()
B738_fmc_xtras_fmod()
B738_fmc_xtras_others()

B738_fmc_clr_page()
B738_fmc_display()


--B738_flight_phase()
B738_flight_phase2()
B738_N1_thrust_calc()
B738_N1_thrust_set()
B738_N1_sel_thr()
-- last position
B738_last_pos()
B738_irs_sys()
B738_fmc_msg()
B738DR_checklist()
B738_des_now()
B738_chock()
B738_pause_td()

via_via_check()
B738_exec_light()
	
	-- if clr_repeat == 1 then
		-- if clr_repeat_time == 0 then
			-- simCMD_FMS_key_clear:once()
			-- if is_timer_scheduled(clr_repeat_timer) == false then
				-- run_after_time(clr_repeat_timer, 0.1)
				-- clr_repeat_time = 1
			-- end
		-- end
		-- clr_repeat = 0
	-- end
	B738_found_nav()
	--B738_bank_angle()
	--B738_bank_angle2()
	B738_disable_bank_angle()
	B738_vnav_desc_spd()
	B738_wind()
	if first_time_apt == 2 then
		B738_detect_center_line()
	end
	chocks_on_start()
	--map_mode = B738DR_capt_map_mode
	B738_legs_num = legs_num
	
	-- B738DR_rte_show[10] = 1
	-- B738DR_rte_rot[10] = B738DR_fms_test1
	-- B738DR_rte_dist[10] = B738DR_fms_test
	
	
	
	
end

--function after_replay() end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")


