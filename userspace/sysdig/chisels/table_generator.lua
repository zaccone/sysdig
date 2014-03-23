--[[

 
This program is free software: you can redistribute it and/or modify




This program is distributed in the hope that it will be useful,





along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

-- Chisel description
description = "Given two filter fields, a key and a value, this chisel creates and renders to the screen a table."
short_description = "FD bytes group by"
category = "IO"
hidden = true

-- Chisel argument list
args = 
{
	{
		name = "key", 
		description = "the filter field used for grouping", 
		argtype = "string"
	},
	{
		name = "value", 
		description = "the value to count for every key", 
		argtype = "string"
	},
	{
		name = "filter", 
		description = "the filter to apply", 
		argtype = "string"
	},
	{
		name = "top_number", 
		description = "maximum number of elements to display", 
		argtype = "string"
	},
	{
		name = "result_rendering", 
		description = "how to render the values in the result. Can be 'bytes', 'time' or 'none'.", 
		argtype = "string"
	},
}

require "common"

top_number = 0
grtable = {}
key_fld = ""
value_fld = ""
filter = ""
result_rendering = "none"

-- Argument notification callback
function on_set_arg(name, val)
	if name == "key" then
		key_fld = val
		return true
	elseif name == "value" then
		value_fld = val
		return true
	elseif name == "filter" then
		filter = val
		return true
	elseif name == "top_number" then
		top_number = tonumber(val)
		return true
	elseif name == "result_rendering" then
		result_rendering = val
		return true
	end

	return false
end

-- Initialization callback
function on_init()
	-- Request the fields we need
	fkey = chisel.request_field(key_fld)
	fvalue = chisel.request_field(value_fld)
	
	-- set the filter
	if filter == "" then
		chisel.set_filter("evt.is_io=true")
	else
		chisel.set_filter(filter)
	end
	
	return true
end

-- Event parsing callback
function on_event()
	key = evt.field(fkey)
	value = evt.field(fvalue)

	if key ~= nil and value ~= nil and value > 0 then
		entryval = grtable[key]

		if entryval == nil then
			grtable[key] = value
		else
			grtable[key] = grtable[key] + value
		end
	end

	return true
end

-- Interval callback, emits the output
function on_capture_end()
	sorted_grtable = pairs_top_by_val(grtable, top_number, function(t,a,b) return t[b] < t[a] end)
	
	etime = evt.field(ftime)
	
	for k,v in sorted_grtable do
		if result_rendering == "none" then
			print(extend_string(v, 10) .. k)
		elseif result_rendering == "bytes" then
			print(extend_string(format_bytes(v), 10) .. k)
		elseif result_rendering == "time" then
			print(extend_string(format_time_interval(v), 10) .. k)
		end
	end
	
	return true
end