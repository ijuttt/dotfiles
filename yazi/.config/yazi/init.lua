require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})
require("folder-rules"):setup()

-- Custom Linemode: Size + Last Modified
function Linemode:size_and_mtime()
	local h = self._file.cha
	local time_str = os.date("%b %d %H:%M", math.floor(h.mtime or 0))
	local size = self._file:size()
	
	local spans = {
		-- 1. Size
		ui.Span(size and ya.readable_size(size) or "-"):fg("yellow"),
		ui.Span(" | "):fg("white"),
		-- 2. Last Modified
		ui.Span(time_str):fg("blue"),
	}

	return ui.Line(spans)
end




-- Status Bar Info: Owner, Group, and Modified Time
Status:children_add(function(self)
	local h = self._current.hovered
	if not h then
		return ui.Line {}
	end

	local spans = {}
	
	-- Link info
	if h.link_to then
		table.insert(spans, ui.Span(" -> " .. tostring(h.link_to)):fg("cyan"))
	end

	-- Owner & Group (Unix only)
	if ya.target_family() == "unix" then
		local owner = ya.user_name(h.cha.uid) or tostring(h.cha.uid)
		local group = ya.group_name(h.cha.gid) or tostring(h.cha.gid)
		table.insert(spans, ui.Span(" " .. owner .. ":" .. group .. " "):fg("magenta"))
	end

	-- Modified Time
	local time = math.floor(h.cha.mtime or 0)
	local mtime = time > 0 and os.date("%Y-%m-%d %H:%M", time) or ""
	table.insert(spans, ui.Span(mtime .. " "):fg("blue"))

	return ui.Line(spans)
end, 500, Status.RIGHT)

