--[[
Copyright © 2019, Xathe
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of Debuffed nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Xathe BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'Debuffed'
_addon.author = 'Xathe (Asura)'
_addon.version = '1.0.0.4'
_addon.commands = {'dbf','debuffed'}

config = require('config')
packets = require('packets')
res = require('resources')
texts = require('texts')
require('logger')

defaults = {}
defaults.interval = .1
defaults.mode = 'blacklist'
defaults.timers = true
defaults.hide_below_zero = false
defaults.whitelist = S{}
defaults.blacklist = S{}
defaults.colors = {}
defaults.colors.player = {}
defaults.colors.player.red = 255
defaults.colors.player.green = 255
defaults.colors.player.blue = 255
defaults.colors.others = {}
defaults.colors.others.red = 255
defaults.colors.others.green = 255
defaults.colors.others.blue = 0

settings = config.load(defaults)
box = texts.new('${current_string}', settings)
box:show()

list_commands = T{
    w = 'whitelist',
    wlist = 'whitelist',
    white = 'whitelist',
    whitelist = 'whitelist',
    b = 'blacklist',
    blist = 'blacklist',
    black = 'blacklist',
    blacklist = 'blacklist'
}

sort_commands = T{
    a = 'add',
    add = 'add',
    ['+'] = 'add',
    r = 'remove',
    remove = 'remove',
    ['-'] = 'remove'
}

player_id = 0
frame_time = 0
debuffed_mobs = {}

----Yottaxa ADDED CODES-------------------------------------------------------------------
----dont modify these-----------------------------
----dont modify these-----------------------------
----dont modify these-----------------------------
	Composure 			= 	false
	Saboteur 			= 	false
	Stymie 				=	false
	Stymie_modifier 	= 	0
	Run_Enfeble_Calc  	=	false
----end dont modify these-----------------------------
	
----BEGIN USER EDITED DATA:
----BEGIN USER EDITED DATA:
----YOU have to edit these below if they are not the same for your rdm job,
----YOU have to edit these below if they are not the same for your rdm job,
----YOU have to edit these below if they are not the same for your rdm job,

	RDM_Job_Mastered 	= 	20  -- 0-20 points enfebble duration category: leave 20 if mastered
	
----JSE neck is a *separate* term so it goes here:

	RDM_JSE_Neck_Aug 	=	1.20 -- +1 r20 Neck set to = 1.20 +2 r25 Neck = 1.25 Edit appropriatly.
	-- 1.0 if you dont have neck. partial augments 1.01-1.24 to match your % augments 1-25%
	--Assumed in all sets. Literally no reason not to.
	
	RDM_Group_2_Merrits =	5 -- put # of merits in ENFEBBLE DURATION here. Self Explanitory
	
--- READ ME SOME MORE:
--- This table below needs to be edited to match your whole setup - yes its a pain, but!
--- we get accurate numbers and its not too bad.

--- Column #1 DURATION:
--- DURATION GEAR does **NOT*** include JSE neck. JSE neck is separate term you input above.
--- Duration gear is the sum of snotra, kishar, belt, and regal cuffs. 
--- Add the total % (example 25%) to 1 as a decimal fraction so:
--- for example I have snotra, kisha and belt, which is 25% so the number is 1.25
--- SOME sets may not have all duration gear, so change each set accordingly.

--- Column #2: COMPOSURE WITH SABO is a RARE CASE of TWO or more EMPY pieces of gear
--- It accounts for the fact that Empy Hands get SWAPPED into all sets under sabo.
---	You can probably leave as it, it only really is in about 1/2 the sets.
--- CURRENTLY I only check this if under both composure and saboteur 
--- as all end game sets do not normally run more than 1 piece. (Body). 
--- This Verry Niche case accounts for sets with body and then gloves swapping in, 
---	The value is added to 1, so 1.10 for sets that have body 
--- If you dont have Emyp gloves, set all Column 2: to 1
--- If you actually run 3 pieces of Empy gear in a set or more let me know... I might invest the time to fix

--- Column #3 - Relic Head. Assumes it is present in all sets. If not, edit column 3 to reflect.
--- If not, set the third comlumn to 0.  
--- Only a factor if you have merits into Enf Duration
--- Search and Replace is your friend if changing whole columns.

enfeeb_data = {
    ["Dia"] 			= { Duration_Gear=1.25,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Dia II"] 			= { Duration_Gear=1.25,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Dia III"] 		= { Duration_Gear=1.25,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Bio"] 			= { Duration_Gear=1.25,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Bio II"] 			= { Duration_Gear=1.25,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Bio III"] 		= { Duration_Gear=1.25,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Paralyze"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Paralyze II"] 	= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
    ["Slow"] 			= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Slow II"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Addle"] 			= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Addle II"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Sleep"] 			= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Sleep II"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Sleepga"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Silence"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
    ["Inundation"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Break"] 			= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Bind"] 			= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Blind"] 			= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Blind II"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Gravity"] 		= { Duration_Gear=1.25,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Gravity II"] 		= { Duration_Gear=1.25,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Frazzle"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Frazzle II"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1},
	["Frazzle III"] 	= { Duration_Gear=1.15,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Distract"] 		= { Duration_Gear=1.15,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Distract II"] 	= { Duration_Gear=1.15,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Distract III"] 	= { Duration_Gear=1.15,Composure_Gear=1.10,Relic_Head_Equiped=1},
	["Poison"] 			= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1}, 
	["Poison II"] 		= { Duration_Gear=1.25,Composure_Gear=1.00,Relic_Head_Equiped=1}, 
	},{"Duration_Gear","Composure_Gear","Relic_Head_Equiped"}

--- A few were removed that didnt make sence to bother - poisonga etc. 
--Let me know if you see something missing
--END RDM USER SETUP SECTION
--END RDM USER SETUP SECTION
--END RDM USER SETUP SECTION
--END RDM USER SETUP SECTION

--dont modify this:
enfeeb_list = {
    'Dia', 'Dia II', 'Dia III','Bio', 'Bio II', 'Bio III','Paralyze', 'Paralyze II', 
    'Slow', 'Slow II', 'Addle', 'Addle II','Sleep', 'Sleep II', 'Silence', 
    'Inundation', 'Break', 'Bind', 'Blind', 'Blind II', 'Gravity', 
	'Gravity II', 'Frazzle', 'Frazzle II', 'Frazzle III', 'Distract', 
	'Distract II', 'Distract III', 'Poison', 'Poison II',
}
--------------------YTXA

function update_box()
    local lines = L{}
    local target = windower.ffxi.get_mob_by_target('t')
    
    if target and target.valid_target and (target.claim_id ~= 0 or target.spawn_type == 16) then
        local data = debuffed_mobs[target.id]
        
        if data then
            for effect, spell in pairs(data) do
                local name = res.spells[spell.id].name
                local remains = math.max(0, spell.timer - os.clock())
                
                if settings.mode == 'whitelist' and settings.whitelist:contains(name) or settings.mode == 'blacklist' and not settings.blacklist:contains(name) then
                    if settings.timers and remains > 0 then
                        lines:append('\\cs(%s)%s: %.0f\\cr':format(get_color(spell.actor), name, remains))
                    elseif remains < 0 and settings.hide_below_zero then
                        debuffed_mobs[target.id][effect] = nil
                    else
                        lines:append('\\cs(%s)%s\\cr':format(get_color(spell.actor), name))
                    end
                end
            end
        end
    end
    
    if lines:length() == 0 then
        box.current_string = ''
    else
        box.current_string = 'Debuffed [' .. target.name .. ']\n\n' .. lines:concat('\n')
    end
end

function get_color(actor)
    if actor == player_id then
        return '%s,%s,%s':format(settings.colors.player.red, settings.colors.player.green, settings.colors.player.blue)
    else
        return '%s,%s,%s':format(settings.colors.others.red, settings.colors.others.green, settings.colors.others.blue)
    end
end

function handle_overwrites(target, new, t)
    if not debuffed_mobs[target] then
        return true
    end
    
    for effect, spell in pairs(debuffed_mobs[target]) do
        local old = res.spells[spell.id].overwrites or {}
        
        -- Check if there isn't a higher priority debuff active
        if table.length(old) > 0 then
            for _,v in ipairs(old) do
                if new == v then
                    return false
                end
            end
        end
        
        -- Check if a lower priority debuff is being overwritten
        if table.length(t) > 0 then
            for _,v in ipairs(t) do
                if spell.id == v then
                    debuffed_mobs[target][effect] = nil
                end
            end
        end
    end
    return true
end

function apply_debuff(target, effect, spell, actor)
	--YOTTAXA ADDED VARIOUS LOCAL VARIABLES:
	local player = windower.ffxi.get_player()
	local spellname = res.spells[spell].name
	local RDM_Composure_Gear = 1.0
	local Saboteur_Bonus = 1	
	local corrected_time = 0
	
    if not debuffed_mobs[target] then
        debuffed_mobs[target] = {}
    end
    
    -- Check overwrite conditions
    local overwrites = res.spells[spell].overwrites or {}
    if not handle_overwrites(target, spell, overwrites) then
        return
    end
    --YOTTAXA ADDED TEST LOGIC AND DEV CODE Below:-----
	--YTXA ADDED TEST LOGIC AND DEV CODE-----
		
	if S(enfeeb_list):contains(spellname) then
        Run_Enfeble_Calc 	= 	true
		else
		Run_Enfeble_Calc  	=	false
    end
	
    -- Create updated timer
	if Run_Enfeble_Calc == true and actor == player_id then
	--and actor == player_id?
	
	local RDM_Gear_Duration = enfeeb_data[spellname].Duration_Gear
	local RDM_Relic_Head = 	enfeeb_data[spellname].Relic_Head_Equiped
	--local RDM_Gear_Duration = enfeeb_data[spellname].Duration_Gear
	--local RDM_Relic_Head = 	enfeeb_data[spellname].Relic_Head_Equiped
	
	if S(player.buffs):contains(419) then
        Composure 	= 	true
		else
		Composure  	=	false
    end
	
	if S(player.buffs):contains(454) then
        Saboteur 	= 	true
		Saboteur_Bonus		=	1.25
		else
		Saboteur 	= 	false
		Saboteur_Bonus		=	1
    end
	
	if S(player.buffs):contains(494) then
        Stymie 		=	true
		Stymie_modifier = 	20
		else
		Stymie 		=	false
		Stymie_modifier = 	0
    end
	
	if Composure == true and Saboteur == true then
	RDM_Composure_Gear = enfeeb_data[spellname].Composure_Gear
	else
	RDM_Composure_Gear = 1
	end
	
	
	corrected_time = math.max(0,((res.spells[spell].duration * Saboteur_Bonus) + (6 * RDM_Group_2_Merrits) + (RDM_Relic_Head * (3*RDM_Group_2_Merrits)) + RDM_Job_Mastered + Stymie_modifier) * RDM_Composure_Gear * RDM_Gear_Duration * RDM_JSE_Neck_Aug)
	
	--Main FORMULA FOR RDM DURATION
	--((Spell base × Saboteur) + (6s ×G2 Merit) + (3s ×R.H G2 Merit) + RDM EnfeeblingJP + RDM StymieJP + Gear in sec)
	-- × (Augments Composure Bonus) × (Duration listed on Gear) × (Duration Augments on Gear)
	--Debug Lines
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 COMpo "..tostring(RDM_Composure_Gear))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 Composure "..tostring(Composure))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 Saboteur "..tostring(Saboteur))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 Stymie "..tostring(Stymie))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 Spell? "..tostring(spell))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 Spell? "..tostring(spellname))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 Enf Check "..tostring(Run_Enfeble_Calc))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 Duration Gear table "..tostring(enfeeb_data[spellname].Duration_Gear))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 Duration Gear table "..tostring(RDM_Gear_Duration))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 Default Duration "..tostring(res.spells[spell].duration))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 Corrected Time "..tostring(corrected_time))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 PId "..tostring(player_id))
	--windower.add_to_chat(5,"TESTIN TESTING TESTING 123 ACTOR "..tostring(actor))
	
	debuffed_mobs[target][effect] = {id=spell, timer=(os.clock() + (corrected_time or 0)), actor=actor}
	
	else
	--Yottaxa Code changes End Here
    debuffed_mobs[target][effect] = {id=spell, timer=(os.clock() + (res.spells[spell].duration or 0)), actor=actor}
	end
end

function handle_shot(target)
    if not debuffed_mobs[target] or not debuffed_mobs[target][134] then
        return true
    end
    
    local current = debuffed_mobs[target][134].id
    if current < 26 then
        debuffed_mobs[target][134].id = current + 1
    end
end

function inc_action(act)
    if act.category ~= 4 then
        if act.category == 6 and act.param == 131 then
            handle_shot(act.targets[1].id)
        end
        return
    end
    
    -- Damaging spells
    if S{2,252}:contains(act.targets[1].actions[1].message) then
        local target = act.targets[1].id
        local spell = act.param
        local effect = res.spells[spell].status
        local actor = act.actor_id

        if effect then
            apply_debuff(target, effect, spell, actor)
        end
        
    -- Non-damaging spells
    elseif S{236,237,268,271}:contains(act.targets[1].actions[1].message) then
        local target = act.targets[1].id
        local effect = act.targets[1].actions[1].param
        local spell = act.param
        local actor = act.actor_id
        
        if res.spells[spell].status and res.spells[spell].status == effect then
            apply_debuff(target, effect, spell, actor)
        end
    end
end

function inc_action_message(arr)

    -- Unit died
    if S{6,20,113,406,605,646}:contains(arr.message_id) then
        debuffed_mobs[arr.target_id] = nil
        
    -- Debuff expired
    elseif S{64,204,206,350,531}:contains(arr.message_id) then
        if debuffed_mobs[arr.target_id] then
		local spell_id = debuffed_mobs[arr.target_id][arr.param_1].id
		local spell_name = res.spells[spell_id].name
			--windower.add_to_chat(8,"THE FOLLOWING DEBUFF HAS ENDED "..tostring(spell_name))
			windower.add_to_chat(4,"THE FOLLOWING DEBUFF HAS ENDED "..tostring(spell_name))
			play_sound(spell_name)
            debuffed_mobs[arr.target_id][arr.param_1] = nil
			--windower.add_to_chat(8,"THE FOLLOWING DEBUFF HAS ENDED "..tostring(arr.param_1))
        end
    end
end

function play_sound(spell)
if spell == "Silence" then
windower.play_sound('C:/Windower/addons/Debuffed/Sounds/Silence.wav') --must be a .wav--
elseif spell == "Bind" then
windower.play_sound('C:/Windower/addons/Debuffed/Sounds/Bind.wav') --must be a .wav--
elseif spell == "Paralyze" or spell == "Paralyze II" then
windower.play_sound('C:/Windower/addons/Debuffed/Sounds/Paralyze.wav') --must be a .wav--
elseif spell == "Sleep" or spell == "Sleep II" then
windower.play_sound('C:/Windower/addons/Debuffed/Sounds/Sleep.wav') --must be a .wav--
elseif spell == "Addle" or spell == "Addle II" then
windower.play_sound('C:/Windower/addons/Debuffed/Sounds/Addle.wav') --must be a .wav--
elseif spell == "Slow" or spell == "Slow II" then
windower.play_sound('C:/Windower/addons/Debuffed/Sounds/Slow.wav') --must be a .wav--
elseif spell == "Gravity" or spell == "Gravity II" then
windower.play_sound('C:/Windower/addons/Debuffed/Sounds/Gravity.wav') --must be a .wav--
elseif spell == "Frazzle" or spell == "Frazzle II" or spell == "Frazzle III" then
windower.play_sound('C:/Windower/addons/Debuffed/Sounds/Frazzle.wav') --must be a .wav--
elseif spell == "Distract" or spell == "Distract II" or spell == "Distract III" then
windower.play_sound('C:/Windower/addons/Debuffed/Sounds/Distract.wav') --must be a .wav--
end

end

windower.register_event('login','load', function()
    player_id = (windower.ffxi.get_player() or {}).id
end)

windower.register_event('logout','zone change', function()
    debuffed_mobs = {}
end)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x028 then
        inc_action(windower.packets.parse_action(data))
    elseif id == 0x029 then
        local arr = {}
        arr.target_id = data:unpack('I',0x09)
        arr.param_1 = data:unpack('I',0x0D)
        arr.message_id = data:unpack('H',0x19)%32768
        
        inc_action_message(arr)
    end
end)

windower.register_event('prerender', function()
    local curr = os.clock()
    if curr > frame_time + settings.interval then
        frame_time = curr
        update_box()
    end
end)

windower.register_event('addon command', function(command1, command2, ...)
    local args = L{...}
    command1 = command1 and command1:lower() or nil
    command2 = command2 and command2:lower() or nil
    
    local name = args:concat(' ')
    if command1 == 'm' or command1 == 'mode' then
        if settings.mode == 'blacklist' then
            settings.mode = 'whitelist'
        else
            settings.mode = 'blacklist'
        end
        log('Changed to %s mode.':format(settings.mode))
        settings:save()
    elseif command1 == 't' or command1 == 'timers' then
        settings.timers = not settings.timers
        log('Timer display %s.':format(settings.timers and 'enabled' or 'disabled'))
        settings:save()
    elseif command1 == 'i' or command1 == 'interval' then
        settings.interval = tonumber(command2) or .1
        log('Refresh interval set to %s seconds.':format(settings.interval))
        settings:save()
    elseif command1 == 'h' or command1 == 'hide' then
        settings.hide_below_zero = not settings.hide_below_zero
        log('Timers that reach 0 will be %s.':format(settings.hide_below_zero and 'hidden' or 'shown'))
        settings:save()
    elseif list_commands:containskey(command1) then
        if sort_commands:containskey(command2) then
            local spell = res.spells:with('name', windower.wc_match-{name})
            command1 = list_commands[command1]
            command2 = sort_commands[command2]
            
            if spell == nil then
                error('No spells found that match: %s':format(name))
            elseif command2 == 'add' then
                settings[command1]:add(spell.name)
                log('Added spell to %s: %s':format(command1, spell.name))
            else
                settings[command1]:remove(spell.name)
                log('Removed spell from %s: %s':format(command1, spell.name))
            end
            settings:save()
        end
    else
        print('%s (v%s)':format(_addon.name, _addon.version))
        print('    \\cs(255,255,255)mode\\cr - Switches between blacklist and whitelist mode (default: blacklist)')
        print('    \\cs(255,255,255)timers\\cr - Toggles display of debuff timers (default: true)')
        print('    \\cs(255,255,255)interval <value>\\cr - Allows you to change the refresh interval (default: 0.1)')
        print('    \\cs(255,255,255)blacklist|whitelist add|remove <name>\\cr - Adds or removes the spell <name> to the specified list')
    end
end)
