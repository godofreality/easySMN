--[[
Craft v1.0.0

Copyright © 2021 godofreality
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of craft nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL godofreality BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name     = 'easySMN'
_addon.author   = 'godofreality'
_addon.version  = '1.0.1'

_addon.commands = {'smn'}

require('chat')
require('lists')
require('coroutine')
require('queues')
require('logger')
require('tables')
require('sets')
require('strings')

pet = false
local packets = require('packets')
local res = require('resources')
require('data/easyBP')
summons = L{'Carbuncle','Ifrit','Shiva','Garuda','Titan','Ramuh','Leviathan','Fenrir','Diabolos','Siren','Cait Sith','Light Spirit','Dark Spirit','Fire Spirit','Ice Spirit','Air Spirit','Earth Spirit','Thunder Spirit','Water Spirit'}

function file_unload()
	windower.send_command('unbind #1')
	windower.send_command('unbind #2')
	windower.send_command('unbind #3')
	windower.send_command('unbind #4')
	windower.send_command('unbind #5')
	windower.send_command('unbind #6')
	windower.send_command('unbind #7')
	windower.send_command('unbind #8')
	windower.send_command('unbind #9')
	windower.send_command('unbind #0')
	windower.send_command('bind #APPS')
	windower.send_command('bind APPS UP')
end


text = require('texts')
--These values can be changed to suit your needs
txtX = 5 				-- sets the X position of the legend
txtY = 350				-- sets the Y position of the legend
fontR = 0				-- sets the Red value of the legend text color
fontG = 255				-- sets the Green value of the legend text color
fontB = 255				-- sets the Blue value of the legend text color
fontSize = 12			-- sets the Size of the legend text 
announce = true			-- sets outputting of the BloodPact to the Party Chat (valid values true or false)

windower.send_command('bind #1 smn bp1')
windower.send_command('bind #2 smn bp2')
windower.send_command('bind #3 smn bp3')
windower.send_command('bind #4 smn bp4')
windower.send_command('bind #5 smn bp5')
windower.send_command('bind #6 smn bp6')
windower.send_command('bind #7 smn bp7')
windower.send_command('bind #8 smn bp8')
windower.send_command('bind #9 smn bp9')
windower.send_command('bind #0 smn bp10')
windower.send_command('bind #APPS smn showLegend')
windower.send_command('bind APPS UP smn hideLegend')

	function updateLegend()
		local legendBox = ''
		local BPinfo = '[#:<type>-<name>]\n'
		if windower.ffxi.get_mob_by_target('pet') then
			local pet = windower.ffxi.get_mob_by_target('pet')
			for b = 1, 10, +1 do
				if avatars[pet.name]['bp'..b] then
					thisBP = BPinfo
					if b == 10 then
						thisBP = string.gsub(thisBP,'#',0)
					else
						thisBP = string.gsub(thisBP,'#',b)
					end
					thisBP = string.gsub(thisBP,'<name>',avatars[pet.name]['bp'..b].name)
					thisBP = string.gsub(thisBP,'<type>',string.sub(avatars[pet.name]['bp'..b].bpType,0,1))
					legendBox = legendBox..thisBP
				end
			end
			thisBP = BPinfo
			thisBP = string.gsub(thisBP,'#','SP')
			thisBP = string.gsub(thisBP,'<name>',avatars[pet.name]['bpSP'].name)
			thisBP = string.gsub(thisBP,'<type>',string.sub(avatars[pet.name]['bpSP'].bpType,0,1))
			legendBox = legendBox..thisBP
			txtOutput = 'text create '..legendBox
			txtPos = 'text pos '..txtX..' '..txtY
			txtColor = 'text color '..fontR..' '..fontG..' '..fontB
			txtSize =  'text size '..fontSize
			windower.send_command('input //text '..txtOutput..';input //text '.. txtPos..';input //text '..txtColor..';input //text '..txtSize)
		else
			windower.send_command('input //text text delete')
		end
	end

	function doBP(command)
		if string.find(command,'echo') then
			if announce then
				announce = false
				windower.add_to_chat(8,'Party Announce is off')
			else
				announce = true
				windower.add_to_chat(8,'Party Announce is on')
			end
		else
			local bpinfo = string.gsub(string.gsub(avatars[pet.name][command].com,'"',''),'/pet ','')
			local bpinfo_break = string.find(string.reverse(bpinfo),' ')
			local t = string.reverse(string.sub(string.reverse(bpinfo),1,bpinfo_break-1))
			local thisbp = string.reverse(string.sub(string.reverse(bpinfo),bpinfo_break+1))
			local tellString = ''
			if announce then
				tellString = 'input /p '..thisbp..' ==>> '..t
			end
			if avatars[pet.name][command].bpType == 'Rage' then
				if windower.ffxi.get_ability_recasts()[173] > 0 then
					windower.send_command('input /echo BloodPactRage not ready yet.')
				else
					windower.send_command('input '..avatars[pet.name][command].com..';'..tellString)
				end
			elseif avatars[pet.name][command].bpType == 'Ward' then
				if windower.ffxi.get_ability_recasts()[174] > 0 then
					windower.send_command('input /echo BloodPactWard not ready yet.')
				else
					windower.send_command('input '..avatars[pet.name][command].com..';'..tellString)
				end
			end
		end
	end

windower.register_event('time change', function()
	if windower.ffxi.get_mob_by_target('pet') then	
		pet = windower.ffxi.get_mob_by_target('pet')
	else
		pet = false
	end
end)


windower.register_event('addon command', function(command, ...)
	if windower.ffxi.get_player().main_job == 'SMN' then
		if string.find(command, 'bp') and pet then
			doBP(command)
			elseif command == 'echo' then
			doBP('echo')
		elseif summons:contains(command:ucfirst()) then
			if pet then
				windower.send_command('input /ja "release" <me>;wait 1;input /ma "'..command:ucfirst()..'" <me>')
			else
				windower.send_command('input /ma "'..command:ucfirst()..'" <me>')
			end
		elseif command == 'showLegend' then
			if windower.ffxi.get_mob_by_target('pet') then
				updateLegend()
			end
		elseif command == 'hideLegend' then
			if windower.ffxi.get_mob_by_target('pet') then
				windower.send_command('input //text text delete')
			end
		end
	end
end)