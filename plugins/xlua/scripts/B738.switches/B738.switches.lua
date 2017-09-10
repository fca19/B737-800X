--[[
*****************************************************************************************
* Program Script Name	:	B738.switches
*
* Author Name			:	Jim Gregory, Alex Unruh
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
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--

NUM_BTN_SW_COVERS = 10




--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--


----- BUTTON SWITCH COVER(S) ------------------------------------------------------------
local B738_button_switch_cover_position_target = {}
for i = 0, NUM_BTN_SW_COVERS-1 do B738_button_switch_cover_position_target[i] = 0 end

local B738_close_button_cover = {}
local B738_button_switch_cover_CMDhandler = {}




--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_batt_on				= find_dataref("sim/cockpit2/electrical/battery_on[0]")
simDR_stdby_batt_on			= find_dataref("sim/cockpit2/electrical/battery_on[1]")
simDR_startup_running		= find_dataref("sim/operation/prefs/startup_running")
--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_batt_on				= find_command("sim/electrical/battery_1_on")
simCMD_stdby_batt_on		= find_command("sim/electrical/battery_2_on")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

B738DR_emer_exit_lights_switch 	= find_dataref("laminar/B738/toggle_switch/emer_exit_lights")
B738DR_engine_no_running_state 	= find_dataref("laminar/B738/fms/engine_no_running_state")

--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--


----- BUTTON SWITCH COVER(S) ------------------------------------------------------------
B738DR_button_switch_cover_position = create_dataref("laminar/B738/button_switch/cover_position", "array[" .. tostring(NUM_BTN_SW_COVERS) .. "]")




--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--




--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

----- BUTTON SWITCH COVER(S) ------------------------------------------------------------
for i = 0, NUM_BTN_SW_COVERS-1 do

    -- CREATE THE CLOSE COVER FUNCTIONS
    -- B738_close_button_cover[i] = function()
        -- B738_button_switch_cover_position_target[i] = 0.0
    -- end


    -- CREATE THE COVER HANDLER FUNCTIONS
    B738_button_switch_cover_CMDhandler[i] = function(phase, duration)

        if phase == 0 then
            if B738_button_switch_cover_position_target[i] == 0.0 then
                B738_button_switch_cover_position_target[i] = 1.0
                -- if is_timer_scheduled(B738_close_button_cover[i]) then
                    -- stop_timer(B738_close_button_cover[i])
                -- end
                -- run_after_time(B738_close_button_cover[i], 5.0)
            elseif B738_button_switch_cover_position_target[i] == 1.0 then
                B738_button_switch_cover_position_target[i] = 0.0
                -- if is_timer_scheduled(B738_close_button_cover[i]) then
                    -- stop_timer(B738_close_button_cover[i])
                -- end
            end
        end
    end

end




--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

----- BUTTON SWITCH COVERS --------------------------------------------------------------
B738CMD_button_switch_cover = {}
for i = 0, NUM_BTN_SW_COVERS-1 do
    B738CMD_button_switch_cover[i] = create_command("laminar/B738/button_switch_cover" .. string.format("%02d", i), "Button Switch Cover" .. string.format("%02d", i), B738_button_switch_cover_CMDhandler[i])
end




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






----- BUTTON SWITCH COVER POSITION ANIMATION --------------------------------------------
function B738_button_switch_cover_animation()

    for i = 0, NUM_BTN_SW_COVERS-1 do
        B738DR_button_switch_cover_position[i] = B738_set_animation_position(B738DR_button_switch_cover_position[i], B738_button_switch_cover_position_target[i], 0.0, 1.0, 10.0)
    end

end



function B738_cover_turn()

	if B738DR_button_switch_cover_position[2] < 0.3
	and simDR_batt_on == 0 then
		simCMD_batt_on:once()
	end
	if B738DR_button_switch_cover_position[3] < 0.3 
	and simDR_stdby_batt_on == 0 then
		simCMD_stdby_batt_on:once()
	end
	if B738DR_button_switch_cover_position[9] < 0.3 
	and B738DR_emer_exit_lights_switch == 0 then
		B738DR_emer_exit_lights_switch = 1
	end

end


--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	if simDR_startup_running == 0 and B738DR_engine_no_running_state == 0 then
		B738_button_switch_cover_position_target[2] = 1
		B738_button_switch_cover_position_target[3] = 1
		B738DR_button_switch_cover_position[2] = 1
		B738DR_button_switch_cover_position[3] = 1
		simDR_batt_on = 0
		simDR_stdby_batt_on = 0
		B738_button_switch_cover_position_target[9] = 1		-- Emergency Exit Lights Cover
		B738DR_button_switch_cover_position[9] = 1			-- Emergency Exit Lights Cover
		B738DR_emer_exit_lights_switch = 0					-- Emergency Exit Lights
	else
		B738_button_switch_cover_position_target[2] = 0
		B738_button_switch_cover_position_target[3] = 0
		B738DR_button_switch_cover_position[2] = 0
		B738DR_button_switch_cover_position[3] = 0
		simDR_batt_on = 1
		simDR_stdby_batt_on = 1
		B738_button_switch_cover_position_target[9] = 0		-- Emergency Exit Lights Cover
		B738DR_button_switch_cover_position[9] = 0			-- Emergency Exit Lights Cover
		B738DR_emer_exit_lights_switch = 1					-- Emergency Exit Lights
	end
	

end

--function flight_crash() end

function before_physics() 
	
	B738_button_switch_cover_animation()
		
end

function after_physics() 
	
	B738_cover_turn()
	
end

--function after_replay() end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



