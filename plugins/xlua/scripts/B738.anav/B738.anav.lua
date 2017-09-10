

--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--

nd_teak = 0
nd_from = 0
nd_to = 0
max_obj = 40
nd_page1 = {}
nd_page2 = {}
nd_page = 0
nd_page1_num = 0
nd_page2_num = 0

ils_teak = 0
ils_from = 0
ils_to = 0
ils_page = 0

first_time = 0
ils_first_time = 0

ils_latit1 = 0
ils_longit1 = 0
ils_crs1 = 0
ils_rnw1 = ""
ils_distance1 = 85
ils_freq1 = 0

ils_latit2 = 0
ils_longit2 = 0
ils_crs2 = 0
ils_rnw2 = ""
ils_distance2 = 85
ils_freq2 = 0

--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--



B738_navdata			= create_dataref("laminar/B738/navdata/navdata", "string")
B738_navdata_active		= create_dataref("laminar/B738/navdata/navdata_active", "string")
B738_navdata_test		= create_dataref("laminar/B738/navdata/navdata_test", "string")

earth_nav_num = 0  --number navid
earth_nav = {}
ils_nav_num = 0
ils_nav = {}
words = {}
--word = 1
line = "" 	--{}
B738_navdata = ""
B738_navdata_active = ""
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

file_name = "Custom Data/earth_nav.dat"
file_navdata = io.open(file_name, "r")
if file_navdata == nil then
	file_name = "Resources/default data/earth_nav.dat"
	file_navdata = io.open(file_name, "r")
	if file_navdata == nil then
		B738_navdata = ""
		B738_navdata_active = ""
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
			B738_navdata = string.sub(build, 3, 8) .. cycle
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
					if j > 8 then
						
						
						
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
		B738_navdata = string.sub(build, 3, 8) .. cycle
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
				if j > 8 then
					
					
					
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
				end
			end
			line = file_navdata:read()
		end
		file_navdata:close()
	end
end

--B738_navdata_test = earth_nav_num

if cycle == "1611" then
	B738_navdata_active = "OCT14NOV10/16"
elseif cycle == "1612" then
	B738_navdata_active = "NOV10DEC08/16"
elseif cycle == "1613" then
	B738_navdata_active = "DEC08JAN05/17"
elseif cycle == "1701" then
	B738_navdata_active = "JAN05FEB02/17"
elseif cycle == "1702" then
	B738_navdata_active = "FEB02MAR02/17"
elseif cycle == "1703" then
	B738_navdata_active = "MAR02MAR30/17"
elseif cycle == "1704" then
	B738_navdata_active = "MAR30APR27/17"
elseif cycle == "1705" then
	B738_navdata_active = "APR27MAY25/17"
elseif cycle == "1706" then
	B738_navdata_active = "MAY25JUN22/17"
elseif cycle == "1707" then
	B738_navdata_active = "JUN22JUL20/17"
elseif cycle == "1708" then
	B738_navdata_active = "JUL20AUG17/17"
elseif cycle == "1709" then
	B738_navdata_active = "AUG17SEP14/17"
elseif cycle == "1710" then
	B738_navdata_active = "SEP14OCT13/17"
elseif cycle == "1711" then
	B738_navdata_active = "OCT13NOV09/17"
elseif cycle == "1712" then
	B738_navdata_active = "NOV09DEC07/17"
elseif cycle == "1713" then
	B738_navdata_active = "DEC07JAN04/18"
end


--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--


simDR_lat				= find_dataref("sim/flightmodel/position/latitude")
simDR_lon				= find_dataref("sim/flightmodel/position/longitude")
simDR_mag_hdg			= find_dataref("sim/cockpit2/gauges/indicators/ground_track_mag_pilot")
simDR_ahars_mag_hdg		= find_dataref("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
simDR_mag_variation		= find_dataref("sim/flightmodel/position/magnetic_variation")

simDR_efis_map_range	= find_dataref("sim/cockpit2/EFIS/map_range")
simDR_efis_map_mode		= find_dataref("sim/cockpit/switches/EFIS_map_mode")
simDR_efis_sub_mode		= find_dataref("sim/cockpit/switches/EFIS_map_submode")
simDR_efis_vor_on		= find_dataref("sim/cockpit2/EFIS/EFIS_vor_on")
simDR_efis_apt_on		= find_dataref("sim/cockpit2/EFIS/EFIS_airport_on")
simDR_efis_fix_on		= find_dataref("sim/cockpit2/EFIS/EFIS_fix_on")

simDR_gps_nav_id		= find_dataref("sim/cockpit2/radios/indicators/gps_nav_id")
--simDR_gps_nav_type		= find_dataref("sim/cockpit/gps/destination_type")

simDR_nav1_freq_hz		= find_dataref("sim/cockpit/radios/nav1_freq_hz")

--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

--B738CMD_apu_starter_switch_dn	= find_command("laminar/B738/spring_toggle_switch/APU_start_pos_dn")


--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

B738DR_vor1_sel_id	 		= find_dataref("laminar/B738/pfd/vor1_sel_id")
B738DR_vor2_sel_id	 		= find_dataref("laminar/B738/pfd/vor2_sel_id")
B738DR_vor1_show	 		= find_dataref("laminar/B738/pfd/vor1_show")
B738DR_vor2_show	 		= find_dataref("laminar/B738/pfd/vor2_show")

B738DR_efis_vor_on		= find_dataref("laminar/B738/EFIS/EFIS_vor_on")
B738DR_efis_apt_on		= find_dataref("laminar/B738/EFIS/EFIS_airport_on")
B738DR_efis_fix_on		= find_dataref("laminar/B738/EFIS/EFIS_fix_on")

B738DR_efis_map_range_capt 		= find_dataref("laminar/B738/EFIS/capt/map_range")
B738DR_efis_map_range_fo 		= find_dataref("laminar/B738/EFIS/fo/map_range")
B738DR_capt_map_mode		= find_dataref("laminar/B738/EFIS_control/capt/map_mode_pos")
B738DR_fo_map_mode			= find_dataref("laminar/B738/EFIS_control/fo/map_mode_pos")

B738DR_fpln_nav_id			= find_dataref("laminar/B738/fms/fpln_nav_id")
--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

-- B738DR_ils_rotate	 	= create_dataref("laminar/B738/pfd/ils_rotate", "number")
-- B738DR_ils_x	 		= create_dataref("laminar/B738/pfd/ils_x", "number")
-- B738DR_ils_y	 		= create_dataref("laminar/B738/pfd/ils_y", "number")
-- B738DR_ils_runway 		= create_dataref("laminar/B738/pfd/ils_runway", "string")
-- B738DR_ils_show	 		= create_dataref("laminar/B738/pfd/ils_show", "number")
-- B738DR_ils_copilot_show	= create_dataref("laminar/B738/pfd/ils_copilot_show", "number")

-- B738DR_wpt_x	 		= create_dataref("laminar/B738/nd/wpt_x", "array[1]")
-- B738DR_wpt_y	 		= create_dataref("laminar/B738/nd/wpt_y", "array[1]")
-- B738DR_wpt_id00w 		= create_dataref("laminar/B738/nd/wpt_id00w", "string")
-- B738DR_wpt_id00m 		= create_dataref("laminar/B738/nd/wpt_id00m", "string")
-- B738DR_wpt_type00 		= create_dataref("laminar/B738/nd/wpt_type00", "number")


B738DR_nd_object_x = 	create_dataref("laminar/B738/nd/object_x", "array[50]")
B738DR_nd_object_y = 	create_dataref("laminar/B738/nd/object_y", "array[50]")

B738DR_nd_object_id00 = create_dataref("laminar/B738/nd/object_id00", "string")
B738DR_nd_object_id01 = create_dataref("laminar/B738/nd/object_id01", "string")
B738DR_nd_object_id02 = create_dataref("laminar/B738/nd/object_id02", "string")
B738DR_nd_object_id03 = create_dataref("laminar/B738/nd/object_id03", "string")
B738DR_nd_object_id04 = create_dataref("laminar/B738/nd/object_id04", "string")
B738DR_nd_object_id05 = create_dataref("laminar/B738/nd/object_id05", "string")
B738DR_nd_object_id06 = create_dataref("laminar/B738/nd/object_id06", "string")
B738DR_nd_object_id07 = create_dataref("laminar/B738/nd/object_id07", "string")
B738DR_nd_object_id08 = create_dataref("laminar/B738/nd/object_id08", "string")
B738DR_nd_object_id09 = create_dataref("laminar/B738/nd/object_id09", "string")
B738DR_nd_object_id10 = create_dataref("laminar/B738/nd/object_id10", "string")
B738DR_nd_object_id11 = create_dataref("laminar/B738/nd/object_id11", "string")
B738DR_nd_object_id12 = create_dataref("laminar/B738/nd/object_id12", "string")
B738DR_nd_object_id13 = create_dataref("laminar/B738/nd/object_id13", "string")
B738DR_nd_object_id14 = create_dataref("laminar/B738/nd/object_id14", "string")
B738DR_nd_object_id15 = create_dataref("laminar/B738/nd/object_id15", "string")
B738DR_nd_object_id16 = create_dataref("laminar/B738/nd/object_id16", "string")
B738DR_nd_object_id17 = create_dataref("laminar/B738/nd/object_id17", "string")
B738DR_nd_object_id18 = create_dataref("laminar/B738/nd/object_id18", "string")
B738DR_nd_object_id19 = create_dataref("laminar/B738/nd/object_id19", "string")
B738DR_nd_object_id20 = create_dataref("laminar/B738/nd/object_id20", "string")
B738DR_nd_object_id21 = create_dataref("laminar/B738/nd/object_id21", "string")
B738DR_nd_object_id22 = create_dataref("laminar/B738/nd/object_id22", "string")
B738DR_nd_object_id23 = create_dataref("laminar/B738/nd/object_id23", "string")
B738DR_nd_object_id24 = create_dataref("laminar/B738/nd/object_id24", "string")
B738DR_nd_object_id25 = create_dataref("laminar/B738/nd/object_id25", "string")
B738DR_nd_object_id26 = create_dataref("laminar/B738/nd/object_id26", "string")
B738DR_nd_object_id27 = create_dataref("laminar/B738/nd/object_id27", "string")
B738DR_nd_object_id28 = create_dataref("laminar/B738/nd/object_id28", "string")
B738DR_nd_object_id29 = create_dataref("laminar/B738/nd/object_id29", "string")
B738DR_nd_object_id30 = create_dataref("laminar/B738/nd/object_id30", "string")
B738DR_nd_object_id31 = create_dataref("laminar/B738/nd/object_id31", "string")
B738DR_nd_object_id32 = create_dataref("laminar/B738/nd/object_id32", "string")
B738DR_nd_object_id33 = create_dataref("laminar/B738/nd/object_id33", "string")
B738DR_nd_object_id34 = create_dataref("laminar/B738/nd/object_id34", "string")
B738DR_nd_object_id35 = create_dataref("laminar/B738/nd/object_id35", "string")
B738DR_nd_object_id36 = create_dataref("laminar/B738/nd/object_id36", "string")
B738DR_nd_object_id37 = create_dataref("laminar/B738/nd/object_id37", "string")
B738DR_nd_object_id38 = create_dataref("laminar/B738/nd/object_id38", "string")
B738DR_nd_object_id39 = create_dataref("laminar/B738/nd/object_id39", "string")
B738DR_nd_object_id40 = create_dataref("laminar/B738/nd/object_id40", "string")
B738DR_nd_object_id41 = create_dataref("laminar/B738/nd/object_id41", "string")
B738DR_nd_object_id42 = create_dataref("laminar/B738/nd/object_id42", "string")
B738DR_nd_object_id43 = create_dataref("laminar/B738/nd/object_id43", "string")
B738DR_nd_object_id44 = create_dataref("laminar/B738/nd/object_id44", "string")
B738DR_nd_object_id45 = create_dataref("laminar/B738/nd/object_id45", "string")
B738DR_nd_object_id46 = create_dataref("laminar/B738/nd/object_id46", "string")
B738DR_nd_object_id47 = create_dataref("laminar/B738/nd/object_id47", "string")
B738DR_nd_object_id48 = create_dataref("laminar/B738/nd/object_id48", "string")
B738DR_nd_object_id49 = create_dataref("laminar/B738/nd/object_id49", "string")


B738DR_nd_object_id00w = create_dataref("laminar/B738/nd/object_id00w", "string")
B738DR_nd_object_id01w = create_dataref("laminar/B738/nd/object_id01w", "string")
B738DR_nd_object_id02w = create_dataref("laminar/B738/nd/object_id02w", "string")
B738DR_nd_object_id03w = create_dataref("laminar/B738/nd/object_id03w", "string")
B738DR_nd_object_id04w = create_dataref("laminar/B738/nd/object_id04w", "string")
B738DR_nd_object_id05w = create_dataref("laminar/B738/nd/object_id05w", "string")
B738DR_nd_object_id06w = create_dataref("laminar/B738/nd/object_id06w", "string")
B738DR_nd_object_id07w = create_dataref("laminar/B738/nd/object_id07w", "string")
B738DR_nd_object_id08w = create_dataref("laminar/B738/nd/object_id08w", "string")
B738DR_nd_object_id09w = create_dataref("laminar/B738/nd/object_id09w", "string")
B738DR_nd_object_id10w = create_dataref("laminar/B738/nd/object_id10w", "string")
B738DR_nd_object_id11w = create_dataref("laminar/B738/nd/object_id11w", "string")
B738DR_nd_object_id12w = create_dataref("laminar/B738/nd/object_id12w", "string")
B738DR_nd_object_id13w = create_dataref("laminar/B738/nd/object_id13w", "string")
B738DR_nd_object_id14w = create_dataref("laminar/B738/nd/object_id14w", "string")
B738DR_nd_object_id15w = create_dataref("laminar/B738/nd/object_id15w", "string")
B738DR_nd_object_id16w = create_dataref("laminar/B738/nd/object_id16w", "string")
B738DR_nd_object_id17w = create_dataref("laminar/B738/nd/object_id17w", "string")
B738DR_nd_object_id18w = create_dataref("laminar/B738/nd/object_id18w", "string")
B738DR_nd_object_id19w = create_dataref("laminar/B738/nd/object_id19w", "string")
B738DR_nd_object_id20w = create_dataref("laminar/B738/nd/object_id20w", "string")
B738DR_nd_object_id21w = create_dataref("laminar/B738/nd/object_id21w", "string")
B738DR_nd_object_id22w = create_dataref("laminar/B738/nd/object_id22w", "string")
B738DR_nd_object_id23w = create_dataref("laminar/B738/nd/object_id23w", "string")
B738DR_nd_object_id24w = create_dataref("laminar/B738/nd/object_id24w", "string")
B738DR_nd_object_id25w = create_dataref("laminar/B738/nd/object_id25w", "string")
B738DR_nd_object_id26w = create_dataref("laminar/B738/nd/object_id26w", "string")
B738DR_nd_object_id27w = create_dataref("laminar/B738/nd/object_id27w", "string")
B738DR_nd_object_id28w = create_dataref("laminar/B738/nd/object_id28w", "string")
B738DR_nd_object_id29w = create_dataref("laminar/B738/nd/object_id29w", "string")
B738DR_nd_object_id30w = create_dataref("laminar/B738/nd/object_id30w", "string")
B738DR_nd_object_id31w = create_dataref("laminar/B738/nd/object_id31w", "string")
B738DR_nd_object_id32w = create_dataref("laminar/B738/nd/object_id32w", "string")
B738DR_nd_object_id33w = create_dataref("laminar/B738/nd/object_id33w", "string")
B738DR_nd_object_id34w = create_dataref("laminar/B738/nd/object_id34w", "string")
B738DR_nd_object_id35w = create_dataref("laminar/B738/nd/object_id35w", "string")
B738DR_nd_object_id36w = create_dataref("laminar/B738/nd/object_id36w", "string")
B738DR_nd_object_id37w = create_dataref("laminar/B738/nd/object_id37w", "string")
B738DR_nd_object_id38w = create_dataref("laminar/B738/nd/object_id38w", "string")
B738DR_nd_object_id39w = create_dataref("laminar/B738/nd/object_id39w", "string")
B738DR_nd_object_id40w = create_dataref("laminar/B738/nd/object_id40w", "string")
B738DR_nd_object_id41w = create_dataref("laminar/B738/nd/object_id41w", "string")
B738DR_nd_object_id42w = create_dataref("laminar/B738/nd/object_id42w", "string")
B738DR_nd_object_id43w = create_dataref("laminar/B738/nd/object_id43w", "string")
B738DR_nd_object_id44w = create_dataref("laminar/B738/nd/object_id44w", "string")
B738DR_nd_object_id45w = create_dataref("laminar/B738/nd/object_id45w", "string")
B738DR_nd_object_id46w = create_dataref("laminar/B738/nd/object_id46w", "string")
B738DR_nd_object_id47w = create_dataref("laminar/B738/nd/object_id47w", "string")
B738DR_nd_object_id48w = create_dataref("laminar/B738/nd/object_id48w", "string")
B738DR_nd_object_id49w = create_dataref("laminar/B738/nd/object_id49w", "string")


B738DR_nd_object_type00 = create_dataref("laminar/B738/nd/object_type00", "number")
B738DR_nd_object_type01 = create_dataref("laminar/B738/nd/object_type01", "number")
B738DR_nd_object_type02 = create_dataref("laminar/B738/nd/object_type02", "number")
B738DR_nd_object_type03 = create_dataref("laminar/B738/nd/object_type03", "number")
B738DR_nd_object_type04 = create_dataref("laminar/B738/nd/object_type04", "number")
B738DR_nd_object_type05 = create_dataref("laminar/B738/nd/object_type05", "number")
B738DR_nd_object_type06 = create_dataref("laminar/B738/nd/object_type06", "number")
B738DR_nd_object_type07 = create_dataref("laminar/B738/nd/object_type07", "number")
B738DR_nd_object_type08 = create_dataref("laminar/B738/nd/object_type08", "number")
B738DR_nd_object_type09 = create_dataref("laminar/B738/nd/object_type09", "number")
B738DR_nd_object_type10 = create_dataref("laminar/B738/nd/object_type10", "number")
B738DR_nd_object_type11 = create_dataref("laminar/B738/nd/object_type11", "number")
B738DR_nd_object_type12 = create_dataref("laminar/B738/nd/object_type12", "number")
B738DR_nd_object_type13 = create_dataref("laminar/B738/nd/object_type13", "number")
B738DR_nd_object_type14 = create_dataref("laminar/B738/nd/object_type14", "number")
B738DR_nd_object_type15 = create_dataref("laminar/B738/nd/object_type15", "number")
B738DR_nd_object_type16 = create_dataref("laminar/B738/nd/object_type16", "number")
B738DR_nd_object_type17 = create_dataref("laminar/B738/nd/object_type17", "number")
B738DR_nd_object_type18 = create_dataref("laminar/B738/nd/object_type18", "number")
B738DR_nd_object_type19 = create_dataref("laminar/B738/nd/object_type19", "number")
B738DR_nd_object_type20 = create_dataref("laminar/B738/nd/object_type20", "number")
B738DR_nd_object_type21 = create_dataref("laminar/B738/nd/object_type21", "number")
B738DR_nd_object_type22 = create_dataref("laminar/B738/nd/object_type22", "number")
B738DR_nd_object_type23 = create_dataref("laminar/B738/nd/object_type23", "number")
B738DR_nd_object_type24 = create_dataref("laminar/B738/nd/object_type24", "number")
B738DR_nd_object_type25 = create_dataref("laminar/B738/nd/object_type25", "number")
B738DR_nd_object_type26 = create_dataref("laminar/B738/nd/object_type26", "number")
B738DR_nd_object_type27 = create_dataref("laminar/B738/nd/object_type27", "number")
B738DR_nd_object_type28 = create_dataref("laminar/B738/nd/object_type28", "number")
B738DR_nd_object_type29 = create_dataref("laminar/B738/nd/object_type29", "number")
B738DR_nd_object_type30 = create_dataref("laminar/B738/nd/object_type30", "number")
B738DR_nd_object_type31 = create_dataref("laminar/B738/nd/object_type31", "number")
B738DR_nd_object_type32 = create_dataref("laminar/B738/nd/object_type32", "number")
B738DR_nd_object_type33 = create_dataref("laminar/B738/nd/object_type33", "number")
B738DR_nd_object_type34 = create_dataref("laminar/B738/nd/object_type34", "number")
B738DR_nd_object_type35 = create_dataref("laminar/B738/nd/object_type35", "number")
B738DR_nd_object_type36 = create_dataref("laminar/B738/nd/object_type36", "number")
B738DR_nd_object_type37 = create_dataref("laminar/B738/nd/object_type37", "number")
B738DR_nd_object_type38 = create_dataref("laminar/B738/nd/object_type38", "number")
B738DR_nd_object_type39 = create_dataref("laminar/B738/nd/object_type39", "number")
B738DR_nd_object_type40 = create_dataref("laminar/B738/nd/object_type40", "number")
B738DR_nd_object_type41 = create_dataref("laminar/B738/nd/object_type41", "number")
B738DR_nd_object_type42 = create_dataref("laminar/B738/nd/object_type42", "number")
B738DR_nd_object_type43 = create_dataref("laminar/B738/nd/object_type43", "number")
B738DR_nd_object_type44 = create_dataref("laminar/B738/nd/object_type44", "number")
B738DR_nd_object_type45 = create_dataref("laminar/B738/nd/object_type45", "number")
B738DR_nd_object_type46 = create_dataref("laminar/B738/nd/object_type46", "number")
B738DR_nd_object_type47 = create_dataref("laminar/B738/nd/object_type47", "number")
B738DR_nd_object_type48 = create_dataref("laminar/B738/nd/object_type48", "number")
B738DR_nd_object_type49 = create_dataref("laminar/B738/nd/object_type49", "number")




des_icao					= find_dataref("laminar/B738/fms/des_icao")
ils_id						= find_dataref("laminar/B738/fms/ils_id")
-- found_ils => 0-no find, 1-find, 2-founded, 3-readed
found_ils					= find_dataref("laminar/B738/fms/found_ils")
ils_freq					= create_dataref("laminar/B738/fms/ils_freq", "number")
ils_course				= create_dataref("laminar/B738/fms/ils_course", "number")

navaid					= find_dataref("laminar/B738/fms/navaid")
found_navaid			= find_dataref("laminar/B738/fms/found_navaid")
navaid_num				= find_dataref("laminar/B738/fms/navaid_num")

--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--

function B738DR_nd_adjust_DRhandler()end
--function B738DR_nd_object_type01_DRhandler()end

--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--

--B738DR_nd_object_type00 = create_dataref("laminar/B738/nd/object_type00", "number", B738DR_nd_object_type00_DRhandler)
B738DR_B738DR_nd_adjust = create_dataref("laminar/B738/nd/adjust", "number", B738DR_nd_adjust_DRhandler)

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

----- RESCALE FLOAT AND CLAMP TO OUTER LIMITS -------------------------------------------
function B738_rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function B738_nd_perf()
	
	local nd_lat = math.rad(simDR_lat) 
	local nd_lon = math.rad(simDR_lon) 
	local nd_lat2 = 0
	local nd_lon2 = 0
	local nd_dis = 0
	local nd_x = 0
	local nd_y = 0
	local n = 0
	local range = 0
	local delta_pos = 0
	local skip = 0
	
	if nd_to == earth_nav_num then
		nd_teak = 0
		first_time = 1
		if nd_page == 0 then
			nd_page = 1
			nd_page2_num = 0
			nd_page2 = {}
		else
			nd_page = 0
			nd_page1_num = 0
			nd_page1 = {}
		end
	else
		nd_teak = nd_teak + 1
	end
	-- nd_from = (nd_teak * 150) + 1
	-- nd_to = nd_from + 149
	nd_from = (nd_teak * 50) + 1
	nd_to = nd_from + 49
	if nd_to > earth_nav_num then
		nd_to = earth_nav_num
	end
	
	-- if first_time == 0 then
		-- nd_from = 1
		-- nd_to = earth_nav_num
	-- end
	
	for n = nd_from, nd_to do 
		nd_lat2 = earth_nav[n][2]
		nd_lon2 = earth_nav[n][3]
		
		nd_lat2 = math.rad(nd_lat2)
		nd_lon2 = math.rad(nd_lon2)
		
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
		
		if skip == 0 then
			
			nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
			nd_y = nd_lat2 - nd_lat
			nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
			
			if earth_nav[n][1] == 4 then	-- if fix only 25 NM
				range = 25
			else
				range = 165
			end
			if B738DR_fpln_nav_id ~= nil then		-- if waypoint
				if B738DR_fpln_nav_id == earth_nav[n][4] then
					range = 185
				end
			end
			
			if nd_dis < range then
				if nd_page == 0 then	-- create nd_page1
					nd_page1_num = nd_page1_num + 1
					nd_page1[nd_page1_num] = {}
					nd_page1[nd_page1_num][1] = earth_nav[n][1]
					nd_page1[nd_page1_num][2] = earth_nav[n][2]
					nd_page1[nd_page1_num][3] = earth_nav[n][3]
					nd_page1[nd_page1_num][4] = earth_nav[n][4]
				else					-- create nd_page2
					nd_page2_num = nd_page2_num + 1
					nd_page2[nd_page2_num] = {}
					nd_page2[nd_page2_num][1] = earth_nav[n][1]
					nd_page2[nd_page2_num][2] = earth_nav[n][2]
					nd_page2[nd_page2_num][3] = earth_nav[n][3]
					nd_page2[nd_page2_num][4] = earth_nav[n][4]
				end
			end
		
		end
		
	end
	--B738_navdata_test = nd_page
end


function B738_nd()

	local nd_lat = math.rad(simDR_lat) 
	local nd_lon = math.rad(simDR_lon) 
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
	local obj = 49	--39	--0
--	local max_obj = 20
	local nav_disable = 0
	local obj_enable = 0
	local txt_white = ""
	local txt_cyan = ""
	local num_type = 0
	local vor_sel1 = B738DR_vor1_sel_id
	local vor_sel2 = B738DR_vor2_sel_id
	local page_max = 0
	local page_1 = 0
	local page_2 = 0
	local page_3 = 0
	local page_4 = ""
	local wpt_enable = 0
	
	
	if vor_sel1 ~= "" then
		if string.sub(vor_sel1, 1, 1) == " " then
			vor_sel1 = string.sub(vor_sel1, 2, -1)
		end
	end
	if vor_sel2 ~= "" then
		if string.sub(vor_sel2, 1, 1) == " " then
			vor_sel2 = string.sub(vor_sel2, 2, -1)
		end
	end
	
	-- if simDR_efis_sub_mode < 2 then
		-- mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
		-- if simDR_efis_map_mode == 0 then
			-- nav_disable = 1
		-- end
	-- if simDR_efis_map_mode == 0 then
		-- nav_disable = 1
	-- elseif simDR_efis_sub_mode < 2 then
		-- nav_disable = 1
	-- elseif simDR_efis_sub_mode == 4 then
		-- nav_disable = 1
		-- --mag_hdg = 4.49
	-- else
		-- mag_hdg = simDR_mag_hdg - simDR_mag_variation
	-- end
	
	nav_disable = 1
	if B738DR_capt_map_mode == 2 and simDR_efis_map_mode ~= 0 then
		nav_disable = 0
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
				page_4 = nd_page2[n][4]
			else
				page_1 = nd_page1[n][1]
				page_2 = nd_page1[n][2]
				page_3 = nd_page1[n][3]
				page_4 = nd_page1[n][4]
			end
			
			nd_lat2 = page_2
			nd_lon2 = page_3
			
			nd_lat2 = math.rad(nd_lat2)
			nd_lon2 = math.rad(nd_lon2)
			
			nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
			nd_y = nd_lat2 - nd_lat
			nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
			nd_dis = nd_dis
			
			if nd_dis < 165 and nav_disable == 0 then
				
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
				
				-- if nd_y > 7.7 or nd_y < -1 then
					-- nd_on_off = 0
				-- end
				-- if nd_x < -6.0 or nd_x > 6.0 then
					-- nd_on_off = 0
				-- end
				
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
					-- WAYPOINTS
					if wpt_enable == 0 then
						if B738DR_fpln_nav_id ~= nil and num_type ~= 5 then
							if B738DR_fpln_nav_id == page_4 then
								wpt_enable = 1
								-- if simDR_gps_nav_type == 11 and num_type == 4 then	-- FIX
									-- wpt_enable = 1
									-- B738DR_wpt_x[0] = nd_x
									-- B738DR_wpt_y[0] = nd_y
									-- B738DR_wpt_id00w = ""
									-- B738DR_wpt_id00m = page_4
									-- B738DR_wpt_type00 = 2
								-- elseif simDR_gps_nav_type == 2 and num_type == 3 then	-- NDB
									-- wpt_enable = 1
									-- B738DR_wpt_x[0] = nd_x
									-- B738DR_wpt_y[0] = nd_y
									-- B738DR_wpt_id00w = ""
									-- B738DR_wpt_id00m = page_4
									-- B738DR_wpt_type00 = 2
								-- else	-- VOR, VOR DME
									-- wpt_enable = 1
									-- B738DR_wpt_x[0] = nd_x
									-- B738DR_wpt_y[0] = nd_y
									-- B738DR_wpt_id00w = ""
									-- B738DR_wpt_id00m = page_4
									-- B738DR_wpt_type00 = 2
								-- end
							end
						end
					end
					-- OBJECT
					-- if obj >= 0 then	-- max number displayed objects
					if obj >= 0 then	-- max number displayed objects
						--B738_navdata_test = earth_nav[n][4] .. string.format("%4.1f", nd_dis)
						B738DR_nd_object_x[obj] = nd_x
						B738DR_nd_object_y[obj] = nd_y
						obj_enable =  0
						num_type = page_1
						if B738DR_efis_vor_on == 1 and num_type < 3 then	-- VOR, VOR DME
							obj_enable = 1
							txt_white = ""
							txt_cyan = page_4
						end
						-- if B738DR_efis_apt_on == 1 and num_type == 5 then		-- APT
							-- obj_enable = 1
							-- txt_white = ""
							-- txt_cyan = page_4
						-- end
						if B738DR_efis_fix_on == 1 and num_type == 4 then		-- WPT
							obj_enable = 1
							txt_white = page_4
							txt_cyan = ""
						end
						if B738DR_vor1_show == 1 and num_type < 3 and vor_sel1 == page_4 then
							obj_enable = 0
							txt_cyan = ""
							txt_white = ""
						end
						if B738DR_vor2_show == 1 and num_type < 3 and vor_sel2 == page_4 then
							obj_enable = 0
							txt_cyan = ""
							txt_white = ""
						end
						if B738DR_efis_map_range_capt > 2 and num_type == 4 then	-- FIX to zoom 20NM
							obj_enable = 0
							txt_cyan = ""
							txt_white = ""
							txt_magenta = ""
						end
						if B738DR_fpln_nav_id ~= nil and num_type ~= 5 then
							if B738DR_fpln_nav_id == page_4 then
								-- if simDR_gps_nav_type == 11 and num_type == 4 then	-- FIX
									-- obj_enable = 0
									-- txt_cyan = ""
									-- txt_white = ""
								-- elseif simDR_gps_nav_type == 2 and num_type == 3 then	-- NDB
									-- obj_enable = 0
									-- txt_cyan = ""
									-- txt_white = ""
								-- else	-- VOR, VOR DME
									obj_enable = 0
									txt_cyan = ""
									txt_white = ""
								-- end
							end
						end
						if obj_enable == 1 then
							if obj == 0 then
								B738DR_nd_object_id00 = txt_cyan
								B738DR_nd_object_id00w = txt_white
								B738DR_nd_object_type00 = num_type
							elseif obj == 1 then
								B738DR_nd_object_id01 = txt_cyan
								B738DR_nd_object_id01w = txt_white
								B738DR_nd_object_type01 = num_type
							elseif obj == 2 then
								B738DR_nd_object_id02 = txt_cyan
								B738DR_nd_object_id02w = txt_white
								B738DR_nd_object_type02 = num_type
							elseif obj == 3 then
								B738DR_nd_object_id03 = txt_cyan
								B738DR_nd_object_id03w = txt_white
								B738DR_nd_object_type03 = num_type
							elseif obj == 4 then
								B738DR_nd_object_id04 = txt_cyan
								B738DR_nd_object_id04w = txt_white
								B738DR_nd_object_type04 = num_type
							elseif obj == 5 then
								B738DR_nd_object_id05 = txt_cyan
								B738DR_nd_object_id05w = txt_white
								B738DR_nd_object_type05 = num_type
							elseif obj == 6 then
								B738DR_nd_object_id06 = txt_cyan
								B738DR_nd_object_id06w = txt_white
								B738DR_nd_object_type06 = num_type
							elseif obj == 7 then
								B738DR_nd_object_id07 = txt_cyan
								B738DR_nd_object_id07w = txt_white
								B738DR_nd_object_type07 = num_type
							elseif obj == 8 then
								B738DR_nd_object_id08 = txt_cyan
								B738DR_nd_object_id08w = txt_white
								B738DR_nd_object_type08 = num_type
							elseif obj == 9 then
								B738DR_nd_object_id09 = txt_cyan
								B738DR_nd_object_id09w = txt_white
								B738DR_nd_object_type09 = num_type
							elseif obj == 10 then
								B738DR_nd_object_id10 = txt_cyan
								B738DR_nd_object_id10w = txt_white
								B738DR_nd_object_type10 = num_type
							elseif obj == 11 then
								B738DR_nd_object_id11 = txt_cyan
								B738DR_nd_object_id11w = txt_white
								B738DR_nd_object_type11 = num_type
							elseif obj == 12 then
								B738DR_nd_object_id12 = txt_cyan
								B738DR_nd_object_id12w = txt_white
								B738DR_nd_object_type12 = num_type
							elseif obj == 13 then
								B738DR_nd_object_id13 = txt_cyan
								B738DR_nd_object_id13w = txt_white
								B738DR_nd_object_type13 = num_type
							elseif obj == 14 then
								B738DR_nd_object_id14 = txt_cyan
								B738DR_nd_object_id14w = txt_white
								B738DR_nd_object_type14 = num_type
							elseif obj == 15 then
								B738DR_nd_object_id15 = txt_cyan
								B738DR_nd_object_id15w = txt_white
								B738DR_nd_object_type15 = num_type
							elseif obj == 16 then
								B738DR_nd_object_id16 = txt_cyan
								B738DR_nd_object_id16w = txt_white
								B738DR_nd_object_type16 = num_type
							elseif obj == 17 then
								B738DR_nd_object_id17 = txt_cyan
								B738DR_nd_object_id17w = txt_white
								B738DR_nd_object_type17 = num_type
							elseif obj == 18 then
								B738DR_nd_object_id18 = txt_cyan
								B738DR_nd_object_id18w = txt_white
								B738DR_nd_object_type18 = num_type
							elseif obj == 19 then
								B738DR_nd_object_id19 = txt_cyan
								B738DR_nd_object_id19w = txt_white
								B738DR_nd_object_type19 = num_type
							elseif obj == 20 then
								B738DR_nd_object_id20 = txt_cyan
								B738DR_nd_object_id20w = txt_white
								B738DR_nd_object_type20 = num_type
							elseif obj == 21 then
								B738DR_nd_object_id21 = txt_cyan
								B738DR_nd_object_id21w = txt_white
								B738DR_nd_object_type21 = num_type
							elseif obj == 22 then
								B738DR_nd_object_id22 = txt_cyan
								B738DR_nd_object_id22w = txt_white
								B738DR_nd_object_type22 = num_type
							elseif obj == 23 then
								B738DR_nd_object_id23 = txt_cyan
								B738DR_nd_object_id23w = txt_white
								B738DR_nd_object_type23 = num_type
							elseif obj == 24 then
								B738DR_nd_object_id24 = txt_cyan
								B738DR_nd_object_id24w = txt_white
								B738DR_nd_object_type24 = num_type
							elseif obj == 25 then
								B738DR_nd_object_id25 = txt_cyan
								B738DR_nd_object_id25w = txt_white
								B738DR_nd_object_type25 = num_type
							elseif obj == 26 then
								B738DR_nd_object_id26 = txt_cyan
								B738DR_nd_object_id26w = txt_white
								B738DR_nd_object_type26 = num_type
							elseif obj == 27 then
								B738DR_nd_object_id27 = txt_cyan
								B738DR_nd_object_id27w = txt_white
								B738DR_nd_object_type27 = num_type
							elseif obj == 28 then
								B738DR_nd_object_id28 = txt_cyan
								B738DR_nd_object_id28w = txt_white
								B738DR_nd_object_type28 = num_type
							elseif obj == 29 then
								B738DR_nd_object_id29 = txt_cyan
								B738DR_nd_object_id29w = txt_white
								B738DR_nd_object_type29 = num_type
							elseif obj == 30 then
								B738DR_nd_object_id30 = txt_cyan
								B738DR_nd_object_id30w = txt_white
								B738DR_nd_object_type30 = num_type
							elseif obj == 31 then
								B738DR_nd_object_id31 = txt_cyan
								B738DR_nd_object_id31w = txt_white
								B738DR_nd_object_type31 = num_type
							elseif obj == 32 then
								B738DR_nd_object_id32 = txt_cyan
								B738DR_nd_object_id32w = txt_white
								B738DR_nd_object_type32 = num_type
							elseif obj == 33 then
								B738DR_nd_object_id33 = txt_cyan
								B738DR_nd_object_id33w = txt_white
								B738DR_nd_object_type33 = num_type
							elseif obj == 34 then
								B738DR_nd_object_id34 = txt_cyan
								B738DR_nd_object_id34w = txt_white
								B738DR_nd_object_type34 = num_type
							elseif obj == 35 then
								B738DR_nd_object_id35 = txt_cyan
								B738DR_nd_object_id35w = txt_white
								B738DR_nd_object_type35 = num_type
							elseif obj == 36 then
								B738DR_nd_object_id36 = txt_cyan
								B738DR_nd_object_id36w = txt_white
								B738DR_nd_object_type36 = num_type
							elseif obj == 37 then
								B738DR_nd_object_id37 = txt_cyan
								B738DR_nd_object_id37w = txt_white
								B738DR_nd_object_type37 = num_type
							elseif obj == 38 then
								B738DR_nd_object_id38 = txt_cyan
								B738DR_nd_object_id38w = txt_white
								B738DR_nd_object_type38 = num_type
							elseif obj == 39 then
								B738DR_nd_object_id39 = txt_cyan
								B738DR_nd_object_id39w = txt_white
								B738DR_nd_object_type39 = num_type
							elseif obj == 40 then
								B738DR_nd_object_id40 = txt_cyan
								B738DR_nd_object_id40w = txt_white
								B738DR_nd_object_type40 = num_type
							elseif obj == 41 then
								B738DR_nd_object_id41 = txt_cyan
								B738DR_nd_object_id41w = txt_white
								B738DR_nd_object_type41 = num_type
							elseif obj == 42 then
								B738DR_nd_object_id42 = txt_cyan
								B738DR_nd_object_id42w = txt_white
								B738DR_nd_object_type42 = num_type
							elseif obj == 43 then
								B738DR_nd_object_id43 = txt_cyan
								B738DR_nd_object_id43w = txt_white
								B738DR_nd_object_type43 = num_type
							elseif obj == 44 then
								B738DR_nd_object_id44 = txt_cyan
								B738DR_nd_object_id44w = txt_white
								B738DR_nd_object_type44 = num_type
							elseif obj == 45 then
								B738DR_nd_object_id45 = txt_cyan
								B738DR_nd_object_id45w = txt_white
								B738DR_nd_object_type45 = num_type
							elseif obj == 46 then
								B738DR_nd_object_id46 = txt_cyan
								B738DR_nd_object_id46w = txt_white
								B738DR_nd_object_type46 = num_type
							elseif obj == 47 then
								B738DR_nd_object_id47 = txt_cyan
								B738DR_nd_object_id47w = txt_white
								B738DR_nd_object_type47 = num_type
							elseif obj == 48 then
								B738DR_nd_object_id48 = txt_cyan
								B738DR_nd_object_id48w = txt_white
								B738DR_nd_object_type48 = num_type
							elseif obj == 49 then
								B738DR_nd_object_id49 = txt_cyan
								B738DR_nd_object_id49w = txt_white
								B738DR_nd_object_type49 = num_type
							end
							-- obj = obj + 1
							obj = obj - 1
						end
					end
				end
			end
		end
	
	end
	
	--B738_navdata_test = B738DR_nd_object_y[4]
	-- turn off unused objects
	-- if obj < max_obj then
		-- for n = obj, max_obj-1 do
	if obj >= 0 then
		for n = obj, 0, -1 do
			if n == 0 then
				B738DR_nd_object_type00 = 0
				B738DR_nd_object_id00 = ""
				B738DR_nd_object_id00w = ""
			elseif n == 1 then
				B738DR_nd_object_type01 = 0
				B738DR_nd_object_id01 = ""
				B738DR_nd_object_id01w = ""
			elseif n == 2 then
				B738DR_nd_object_type02 = 0
				B738DR_nd_object_id02 = ""
				B738DR_nd_object_id02w = ""
			elseif n == 3 then
				B738DR_nd_object_type03 = 0
				B738DR_nd_object_id03 = ""
				B738DR_nd_object_id03w = ""
			elseif n == 4 then
				B738DR_nd_object_type04 = 0
				B738DR_nd_object_id04 = ""
				B738DR_nd_object_id04w = ""
			elseif n == 5 then
				B738DR_nd_object_type05 = 0
				B738DR_nd_object_id05 = ""
				B738DR_nd_object_id05w = ""
			elseif n == 6 then
				B738DR_nd_object_type06 = 0
				B738DR_nd_object_id06 = ""
				B738DR_nd_object_id06w = ""
			elseif n == 7 then
				B738DR_nd_object_type07 = 0
				B738DR_nd_object_id07 = ""
				B738DR_nd_object_id07w = ""
			elseif n == 8 then
				B738DR_nd_object_type08 = 0
				B738DR_nd_object_id08 = ""
				B738DR_nd_object_id08w = ""
			elseif n == 9 then
				B738DR_nd_object_type09 = 0
				B738DR_nd_object_id09 = ""
				B738DR_nd_object_id09w = ""
			elseif n == 10 then
				B738DR_nd_object_type10 = 0
				B738DR_nd_object_id10 = ""
				B738DR_nd_object_id10w = ""
			elseif n == 11 then
				B738DR_nd_object_type11 = 0
				B738DR_nd_object_id11 = ""
				B738DR_nd_object_id11w = ""
			elseif n == 12 then
				B738DR_nd_object_type12 = 0
				B738DR_nd_object_id12 = ""
				B738DR_nd_object_id12w = ""
			elseif n == 13 then
				B738DR_nd_object_type13 = 0
				B738DR_nd_object_id13 = ""
				B738DR_nd_object_id13w = ""
			elseif n == 14 then
				B738DR_nd_object_type14 = 0
				B738DR_nd_object_id14 = ""
				B738DR_nd_object_id14w = ""
			elseif n == 15 then
				B738DR_nd_object_type15 = 0
				B738DR_nd_object_id15 = ""
				B738DR_nd_object_id15w = ""
			elseif n == 16 then
				B738DR_nd_object_type16 = 0
				B738DR_nd_object_id16 = ""
				B738DR_nd_object_id16w = ""
			elseif n == 17 then
				B738DR_nd_object_type17 = 0
				B738DR_nd_object_id17 = ""
				B738DR_nd_object_id17w = ""
			elseif n == 18 then
				B738DR_nd_object_type18 = 0
				B738DR_nd_object_id18 = ""
				B738DR_nd_object_id18w = ""
			elseif n == 19 then
				B738DR_nd_object_type19 = 0
				B738DR_nd_object_id19 = ""
				B738DR_nd_object_id19w = ""
			elseif n == 20 then
				B738DR_nd_object_type20 = 0
				B738DR_nd_object_id20 = ""
				B738DR_nd_object_id20w = ""
			elseif n == 21 then
				B738DR_nd_object_type21 = 0
				B738DR_nd_object_id21 = ""
				B738DR_nd_object_id21w = ""
			elseif n == 22 then
				B738DR_nd_object_type22 = 0
				B738DR_nd_object_id22 = ""
				B738DR_nd_object_id22w = ""
			elseif n == 23 then
				B738DR_nd_object_type23 = 0
				B738DR_nd_object_id23 = ""
				B738DR_nd_object_id23w = ""
			elseif n == 24 then
				B738DR_nd_object_type24 = 0
				B738DR_nd_object_id24 = ""
				B738DR_nd_object_id24w = ""
			elseif n == 25 then
				B738DR_nd_object_type25 = 0
				B738DR_nd_object_id25 = ""
				B738DR_nd_object_id25w = ""
			elseif n == 26 then
				B738DR_nd_object_type26 = 0
				B738DR_nd_object_id26 = ""
				B738DR_nd_object_id26w = ""
			elseif n == 27 then
				B738DR_nd_object_type27 = 0
				B738DR_nd_object_id27 = ""
				B738DR_nd_object_id27w = ""
			elseif n == 28 then
				B738DR_nd_object_type28 = 0
				B738DR_nd_object_id28 = ""
				B738DR_nd_object_id28w = ""
			elseif n == 29 then
				B738DR_nd_object_type29 = 0
				B738DR_nd_object_id29 = ""
				B738DR_nd_object_id29w = ""
			elseif n == 30 then
				B738DR_nd_object_type30 = 0
				B738DR_nd_object_id30 = ""
				B738DR_nd_object_id30w = ""
			elseif n == 31 then
				B738DR_nd_object_type31 = 0
				B738DR_nd_object_id31 = ""
				B738DR_nd_object_id31w = ""
			elseif n == 32 then
				B738DR_nd_object_type32 = 0
				B738DR_nd_object_id32 = ""
				B738DR_nd_object_id32w = ""
			elseif n == 33 then
				B738DR_nd_object_type33 = 0
				B738DR_nd_object_id33 = ""
				B738DR_nd_object_id33w = ""
			elseif n == 34 then
				B738DR_nd_object_type34 = 0
				B738DR_nd_object_id34 = ""
				B738DR_nd_object_id34w = ""
			elseif n == 35 then
				B738DR_nd_object_type35 = 0
				B738DR_nd_object_id35 = ""
				B738DR_nd_object_id35w = ""
			elseif n == 36 then
				B738DR_nd_object_type36 = 0
				B738DR_nd_object_id36 = ""
				B738DR_nd_object_id36w = ""
			elseif n == 37 then
				B738DR_nd_object_type37 = 0
				B738DR_nd_object_id37 = ""
				B738DR_nd_object_id37w = ""
			elseif n == 38 then
				B738DR_nd_object_type38 = 0
				B738DR_nd_object_id38 = ""
				B738DR_nd_object_id38w = ""
			elseif n == 39 then
				B738DR_nd_object_type39 = 0
				B738DR_nd_object_id39 = ""
				B738DR_nd_object_id39w = ""
			elseif n == 40 then
				B738DR_nd_object_type40 = 0
				B738DR_nd_object_id40 = ""
				B738DR_nd_object_id40w = ""
			elseif n == 41 then
				B738DR_nd_object_type41 = 0
				B738DR_nd_object_id41 = ""
				B738DR_nd_object_id41w = ""
			elseif n == 42 then
				B738DR_nd_object_type42 = 0
				B738DR_nd_object_id42 = ""
				B738DR_nd_object_id42w = ""
			elseif n == 43 then
				B738DR_nd_object_type43 = 0
				B738DR_nd_object_id43 = ""
				B738DR_nd_object_id43w = ""
			elseif n == 44 then
				B738DR_nd_object_type44 = 0
				B738DR_nd_object_id44 = ""
				B738DR_nd_object_id44w = ""
			elseif n == 45 then
				B738DR_nd_object_type45 = 0
				B738DR_nd_object_id45 = ""
				B738DR_nd_object_id45w = ""
			elseif n == 46 then
				B738DR_nd_object_type46 = 0
				B738DR_nd_object_id46 = ""
				B738DR_nd_object_id46w = ""
			elseif n == 47 then
				B738DR_nd_object_type47 = 0
				B738DR_nd_object_id47 = ""
				B738DR_nd_object_id47w = ""
			elseif n == 48 then
				B738DR_nd_object_type48 = 0
				B738DR_nd_object_id48 = ""
				B738DR_nd_object_id48w = ""
			elseif n == 49 then
				B738DR_nd_object_type49 = 0
				B738DR_nd_object_id49 = ""
				B738DR_nd_object_id49w = ""
			end
		end
	end
	-- if wpt_enable == 0 then
		-- B738DR_wpt_id00w = ""
		-- B738DR_wpt_id00m = ""
		-- B738DR_wpt_type00 = 0
	-- end


end


-- function B738_ils_rnw_fnd()

	
	-- local nd_lat2 = 0
	-- local nd_lon2 = 0
	-- local nd_lat = math.rad(simDR_lat)
	-- local nd_lon = math.rad(simDR_lon) 
	-- local nd_x = 0
	-- local nd_y = 0
	-- local nd_dis = 0
	
	-- local distance = 0
	
	-- --	for n = 1, ils_nav_num do
	-- if ils_to == ils_nav_num then
		-- ils_teak = 0
		-- ils_first_time = 1
		-- if ils_page == 0 then
			-- ils_page = 1
			-- ils_latit1 = 0
			-- ils_longit1 = 0
			-- ils_crs1 = 0
			-- ils_rnw1 = ""
			-- ils_distance1 = 85
		-- else
			-- ils_page = 0
			-- ils_latit2 = 0
			-- ils_longit2 = 0
			-- ils_crs2 = 0
			-- ils_rnw2 = ""
			-- ils_distance2 = 85
		-- end
	-- else
		-- ils_teak = ils_teak + 1
	-- end
	-- ils_from = (ils_teak * 100) + 1
	-- ils_to = ils_from + 99
	-- if ils_to > ils_nav_num then
		-- ils_to = ils_nav_num
	-- end
	
	-- for n = ils_from, ils_to do 
		-- nd_lat2 = ils_nav[n][2]
		-- nd_lon2 = ils_nav[n][3]
		
		-- nd_lat2 = math.rad(nd_lat2)
		-- nd_lon2 = math.rad(nd_lon2)
		
		-- nd_x = (nd_lon2 - nd_lon) * math.cos((nd_lat + nd_lat2)/2)
		-- nd_y = nd_lat2 - nd_lat
		-- nd_dis = math.sqrt(nd_x*nd_x + nd_y*nd_y) * 3440.064795	--nm
		
		-- if ils_page == 0 then
			-- distance = ils_distance2
		-- else
			-- distance = ils_distance1
		-- end
		
		-- --if simDR_nav1_freq_hz == ils_nav[n][6] and nd_dis < distance then
		-- if des_icao == ils_nav[n][7] and ils_id == ils_nav[n][1] and nd_dis < distance then
			-- if ils_page == 0 then
				-- ils_latit2 = ils_nav[n][2]
				-- ils_longit2 = ils_nav[n][3]
				-- ils_rnw2 = ils_nav[n][4]
				-- ils_crs2 = ils_nav[n][5]
				-- ils_distance2 = nd_dis
				-- ils_freq2 = ils_nav[n][6]
			-- else
				-- ils_latit1 = ils_nav[n][2]
				-- ils_longit1 = ils_nav[n][3]
				-- ils_rnw1 = ils_nav[n][4]
				-- ils_crs1 = ils_nav[n][5]
				-- ils_distance1 = nd_dis
				-- ils_freq1 = ils_nav[n][6]
			-- end
		-- end
	-- end
	-- --B738_navdata_test = ils_nav_num

-- end



-- function B738_ils_rnw()

	-- local ils_lat2 = 0
	-- local ils_lon2 = 0
	-- local ils_lat = math.rad(simDR_lat) 
	-- local ils_lon = math.rad(simDR_lon) 
	-- local mag_hdg = 0
	-- local delta_ils_hdg = 0
	-- local ils_hdg = 0
	-- local ils_on_off = 0
	-- local ils_x = 0
	-- local ils_y = 0
	-- local ils_dis = 0
	-- local ils_zoom = 0
	-- local ils_disable = 0
	
	-- local ils_latit = 0
	-- local ils_longit = 0
	-- local ils_crs = 0
	-- local ils_rnw = ""
	
	-- local temp_lon = 0
	-- local temp_lat = 0
	-- local temp_d_R = 0
	-- local temp_brg = 0

				
	-- if ils_page == 0 then	-- 0 -> display ils_latin1
		-- ils_latit = ils_latit1
		-- ils_longit = ils_longit1
		-- ils_crs = ils_crs1
		-- ils_rnw = ils_rnw1
	-- else					-- 1 -> display ils_latin2
		-- ils_latit = ils_latit2
		-- ils_longit = ils_longit2
		-- ils_crs = ils_crs2
		-- ils_rnw = ils_rnw2
	-- end

	
	
	-- if simDR_efis_sub_mode < 2 then
		-- mag_hdg = simDR_ahars_mag_hdg - simDR_mag_variation
		-- if simDR_efis_map_mode == 0 then
			-- ils_disable = 1
		-- end
	-- elseif simDR_efis_sub_mode == 4 then
		-- ils_disable = 1
		-- --mag_hdg = 4.49
	-- else
		-- mag_hdg = simDR_mag_hdg - simDR_mag_variation
	-- end
		
		
	-- if ils_disable == 0 and string.len(ils_rnw) > 0 then --and ils_dis < 85 then
		
		-- ils_lat2 = math.rad(ils_latit)
		-- ils_lon2 = math.rad(ils_longit)
		
		-- -- Move to 1.7 NM via backcourse ILS
		-- temp_d_R = 1.7/3440.064795			-- distance 1.7 NM
		-- temp_brg = math.rad((ils_crs + 180)%360)		-- back course
		-- temp_lat = math.asin(math.sin(ils_lat2)*math.cos(temp_d_R) + math.cos(ils_lat2)*math.sin(temp_d_R)*math.cos(temp_brg))
		-- temp_lon = ils_lon2 + math.atan2(math.sin(temp_brg)*math.sin(temp_d_R)*math.cos(ils_lat2), math.cos(temp_d_R)-math.sin(ils_lat2)*math.sin(temp_lat))
		
		-- -- Calculate distance
		-- ils_lat2 = temp_lat
		-- ils_lon2 = temp_lon
		
		-- ils_x = (ils_lon2 - ils_lon) * math.cos((ils_lat + ils_lat2)/2)
		-- ils_y = ils_lat2 - ils_lat
		-- ils_dis = math.sqrt(ils_x*ils_x + ils_y*ils_y) * 3440.064795	--nm
		-- --ils_dis = ils_dis 		--+ B738DR_B738DR_nd_adjust
		
		-- ils_y = math.sin(ils_lon2 - ils_lon) * math.cos(ils_lat2)
		-- ils_x = math.cos(ils_lat) * math.sin(ils_lat2) - math.sin(ils_lat) * math.cos(ils_lat2) * math.cos(ils_lon2 - ils_lon)
		-- ils_hdg = math.atan2(ils_y, ils_x)
		-- ils_hdg = math.deg(ils_hdg)
		-- ils_hdg = (ils_hdg + 360) % 360
		
		-- delta_ils_hdg = ((((ils_hdg - mag_hdg) % 360) + 540) % 360) - 180
		
		-- --B738_navdata_test = delta_ils_hdg
		
		-- if delta_ils_hdg >= 0 and delta_ils_hdg <= 90 then
			-- -- right
			-- ils_on_off = 1
			-- delta_ils_hdg = 90 - delta_ils_hdg
			-- delta_ils_hdg = math.rad(delta_ils_hdg)
			-- ils_y = ils_dis * math.sin(delta_ils_hdg)
			-- ils_x = ils_dis * math.cos(delta_ils_hdg)
		-- elseif delta_ils_hdg < 0 and delta_ils_hdg >= -90 then
			-- -- left
			-- ils_on_off = 1
			-- delta_ils_hdg = 90 + delta_ils_hdg
			-- delta_ils_hdg = math.rad(delta_ils_hdg)
			-- ils_y = ils_dis * math.sin(delta_ils_hdg)
			-- ils_x = -ils_dis * math.cos(delta_ils_hdg)
		-- elseif delta_ils_hdg >= 90 then
			-- -- right back
			-- ils_on_off = 1
			-- delta_ils_hdg = delta_ils_hdg - 90
			-- delta_ils_hdg = math.rad(delta_ils_hdg)
			-- ils_y = -ils_dis * math.sin(delta_ils_hdg)
			-- ils_x = ils_dis * math.cos(delta_ils_hdg)
		-- elseif delta_ils_hdg <= -90 then
			-- -- left back
			-- ils_on_off = 1
			-- delta_ils_hdg = -90 - delta_ils_hdg
			-- delta_ils_hdg = math.rad(delta_ils_hdg)
			-- ils_y = -ils_dis * math.sin(delta_ils_hdg)
			-- ils_x = -ils_dis * math.cos(delta_ils_hdg)
		-- end
		
		-- if simDR_efis_map_range == 0 then	-- 10 NM
			-- ils_zoom = 1
		-- elseif simDR_efis_map_range == 1 then	-- 20 NM
			-- ils_zoom = 0.5
		-- elseif simDR_efis_map_range == 2 then	-- 40 NM
			-- ils_zoom = 0.25
		-- elseif simDR_efis_map_range == 3 then	-- 80 NM
			-- ils_zoom = 0.125
		-- else
			-- ils_on_off = 0
		-- end
		
		-- ils_x = ils_x * ils_zoom		-- zoom
		-- ils_y = ils_y * ils_zoom		-- zoom
		-- if simDR_efis_sub_mode == 4 then
			-- ils_y = ils_y + 4.1	-- adjust
		-- end
		
		-- if ils_y > 14 or ils_y < -5 then		-- 7.7 / -1
			-- ils_on_off = 0
		-- end
		-- if ils_x < -10.0 or ils_x > 10.0 then		-- -6.0 / 6.0
			-- ils_on_off = 0
		-- end
			
		-- if ils_on_off == 1 then
			-- -- rotate
			-- ils_hdg = (ils_crs - simDR_mag_hdg) % 360
			-- ils_hdg = (90 + ils_hdg) % 360
			-- ils_hdg = ils_hdg + simDR_mag_variation
			-- B738DR_ils_rotate = ils_hdg
			
			-- B738DR_ils_x = ils_x
			-- B738DR_ils_y = ils_y
			-- B738DR_ils_runway = ils_rnw
			-- B738DR_ils_show = 1
		-- else
			-- B738DR_ils_show = 0
		-- end
	-- else
		-- B738DR_ils_show = 0
	-- end

-- end


function B738_find_ils()

	local ils_fnd = 0
	
	if found_ils == 1 and ils_nav_num > 0 then
		found_ils = 2
		ils_freq = 0
		ils_course = 0
		for ils_fnd = 1, ils_nav_num do
			if des_icao == ils_nav[ils_fnd][7] and ils_id == ils_nav[ils_fnd][1] then
				ils_freq = ils_nav[ils_fnd][6]
				ils_course = ils_nav[ils_fnd][5]
				break
			end
		end
	end

end

function B738_find_navaid()

	local navaid_fnd = 0
	if found_navaid == 1 then
		found_navaid = 2
		navaid_num = 0
		for navaid_fnd = 1, earth_nav_num do
			if navaid == earth_nav[navaid_fnd][4] then
				navaid_num = navaid_num + 1
			end
		end
	end

end

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

first_time = 0
nd_teak = 0
nd_from = 0
nd_to = 0
max_obj = 40

end


--function flight_crash() end

--function before_physics() end

function after_physics()

B738_nd_perf()
if first_time == 1 then
	B738_nd()
end
--B738_ils_rnw_fnd()
--if ils_first_time == 1 then
--	B738_ils_rnw()
--end
B738_find_ils()
B738_find_navaid()

end

--function after_replay() end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



