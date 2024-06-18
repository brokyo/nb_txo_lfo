local mod = require 'core/mods'

if note_players == nil then
    note_players = {}
end

local function add_lfo_params(idx)
    params:add_group("txo_lfo_" .. idx, "txo lfo " .. idx, 4)

    params:add_number(
        "cyc_time_" .. idx, 
        "Cycle Time (ms)", 
        1, 
        300, 
        1,
        function(param) return param:get() / 10 .. 's' end
    )
    params:set_action("cyc_time_" .. idx, function(param)
        local ms = param * 100   
        crow.ii.txo.osc_cyc(idx, ms)
    end)

    -- sine (0) triangle (100) saw (200) pulse (300) noise (400)
    params:add_number(
        "wave_type_" .. idx,
        "Wave Type",
        0,
        400,
        0
    )
    params:set_action("wave_type_" .. idx, function(wave)
        crow.ii.txo.osc_wave(idx, wave)
    end)

    params:add_number(
        "cv_range_" .. idx,
        "CV Range",
        -100,
        100,
        0,
        function(param) return param:get() / 10 .. 'v' end
    )
    params:set_action("cv_range_" .. idx, function(param)
        local volts = param / 10
        crow.ii.txo.cv(idx, volts)
    end)

    params:add_number(
        "osc_rect_" .. idx,
        "LFO Rect",
        -2,
        2,
        0
    )
    params:set_action("osc_rect_" .. idx, function(param)
        crow.ii.txo.osc_rect(idx, param)
    end)

    params:hide("txo_lfo_" .. idx)
end

local function add_lfo(idx)
    local player = {
        count = 0,
        idx = idx
    }

    function player:add_params()
        add_lfo_params(idx)
    end

    function player:describe()
        return {
            name = "txo lfo " .. idx
        }
    end

    function player:active()
        if self.name ~= nil then
            params:show("txo_lfo_" .. idx)
            _menu.rebuild_params()

            crow.ii.txo.cv(idx, 0)
            crow.ii.txo.osc_lfo(idx, 1)
            crow.ii.txo.osc_ctr(idx, 0)
            crow.ii.txo.osc_rect(idx, 0)
        end
    end

    function player:inactive()
        if self.name ~= nil then
            params:hide("txo_lfo_" .. idx)
            _menu.rebuild_params()
        end
    end
       
    note_players["txo lfo " .. idx] = player
end

mod.hook.register("script_pre_init", "nb txo lfo pre init", function()
    for n=1,4 do
        add_lfo(n)
    end
end)



