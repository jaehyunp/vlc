--[[
Cropper Extension for VLC media player 2.0
Copyright 2014 Jaehyun Park
--]]

function descriptor()
   return {
      title = "FFmpeg Video Cropper",
      version = "1.0",
      author = "Jaehyun Park",
      shortdesc = "Uses ffmpeg to crop videos",
      description = "Uses ffmpeg to crop videos",
      capabilities = {"menu"}
   }
end

function activate()
	start_time = nil
	end_time = nil
	
	d = vlc.dialog("Cropper")
	b1 = d:add_button("A", set_start_time, 1, 1, 1, 1)
	w1 = d:add_label("Not set", 2, 1, 2, 1)
	b2 = d:add_button("B", set_end_time, 1, 2, 1, 1)
	w2 = d:add_label("Not set", 2, 2, 2, 1)
	b3 = d:add_button("Cut!", cut_video, 1, 3, 3, 1)
	b4 = d:add_button("Reset", reset_times, 1, 4, 3, 1)
end

function deactivate()
end

function close()
   vlc.deactivate()
end

function menu()
	return {"A", "B", "Reset", "Cut!"}
end

function trigger_menu(id)
	if(id == 1) then
		set_start_time()
	elseif(id == 2) then
		set_end_time()
	elseif(id == 3) then
		reset_times()
	elseif(id == 4) then
		cut_video()
	end
end

function set_start_time()
	local t = get_position()
	local fmt = format_time(t)
	w1:set_text(fmt)
	
	start_time = math.max(t-1, 0.0) -- give 1 second buffer
end

function set_end_time()
	local t = get_position()
	local fmt = format_time(t)
	w2:set_text(fmt)
	
	local dur = vlc.input.item():duration()
	end_time = math.min(t+1, dur) -- give 1 second buffer
end

function cut_video()
	fn = vlc.input.item():name()
	if(start_time == nil) then
		ssop = ""
	else
		ssop = string.format(" -ss %.3f", start_time)
	end
	if(end_time == nil) then
		toop = ""
	else
		toop = string.format(" -to %.3f", end_time)
	end
	cmd = string.format("ffmpeg -i \"%s\" %s %s -acodec copy -vcodec copy \"cut_%s\"", fn, ssop, toop, fn)
	os.execute(cmd)
end

function reset_times()
	start_time = nil
	end_time = nil
	w1:set_text("Not set")
	w2:set_text("Not set")
end

-- returns current position in seconds (floating point number)
function get_position()
	return vlc.var.get(vlc.object.input(), "time")
end

-- converts float t to hh:mm:ss.xxx format
function format_time(t) 
	local hh = math.floor(t / 3600)
	local mm = math.floor((t % 3600) / 60)
	local ss = t % 60
	return string.format("%02d:%02d:%06.3f", hh, mm, ss)
end
