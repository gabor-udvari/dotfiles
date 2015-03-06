--
-- calendar.lua
-- Calendar for Conky
-- http://sg-cyrax.deviantart.com/art/Lua-Calendar-for-Conky-203708623
--

months = {
-- Add translations for names of months for your language
           en = { "JANUARY", "FEBRUARY", "MARCH", "APRIL",
                  "MAY", "JUNE", "JULY", "AUGUST",
                  "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER" },
           ru = { "ЯНВАРЬ", "ФЕВРАЛЬ", "МАРТ", "АПРЕЛЬ",
                  "МАЙ", "ИЮНЬ", "ИЮЛЬ", "АВГУСТ",
                  "СЕНТЯБРЬ", "ОКТЯБРЬ", "НОЯБРЬ", "ДЕКАБРЬ" }
         }
weekDays = {
-- Add translations for acronyms names days of the week for your language
             en = { "SU", "MO", "TU", "WE", "TH", "FR", "SA" },
             ru = { "ВС", "ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ" }
           }
weekDaysFull = {
-- Add translations for names days of the week for your language
                 en = { "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY",
                        "THURSDAY", "FRIDAY", "SATURDAY" },
                 ru = { "ВОСКРЕСЕНЬЕ", "ПОНЕДЕЛЬНИК", "ВТОРНИК", "СРЕДА",
                        "ЧЕТВЕРГ", "ПЯТНИЦА", "СУББОТА" }
               }

function conky_calendar ()
	local t = { lang          = "en", -- Language for display Months and Days of week
                                    -- Change it to your language, and add translations
                                    -- for into the tables named 'months', 'weekDays'
                                    -- and 'weekDaseFull' at top of this file
	            -- right_space   = 78,
	            right_space   = 80,
	            -- left_space    = 123,
	            left_space    = 50,
	            -- back_voffset  = -113,
	            back_voffset  = 0,
	            -- draw_spin     = true,
	            draw_spin     = false,
	            normal_font   = "Droid Sans:style=Bold:pixelsize=12",
	            big_font      = "Droid Sans:style=Bold:pixelsize=48",
	            grid_font     = "Ubuntu Mono:pixelsize=18",
	            weekend_color = "0075B0",
	            spin_color    = "5C8599", }
	local m, y = os.date("%m"), os.date("%Y")
	return displayCalendar(m, y, 2, t) -- Month, Year, Start of Week (1 = Sunday, 2 = Monday)
	                                   -- and parameters table :-)
	-- return ""
end

-- Display the calendar
-- Based on some examples from this page: http://lua-users.org/wiki/DisplayCalendarInHtml
function displayCalendar(month, year, weekStart, params)
	local t, wkSt = os.time{year=year, month=month+1, day=0}, weekStart or 1
	local d = os.date("*t", t)
	local mthDays, stDay = d.day, (d.wday - d.day - wkSt+1) % 7
	local wd = tonumber(os.date("%w")) + 1
	local mths = months[params.lang] or months["en"]
	local wdsf = weekDaysFull[params.lang] or weekDaysFull["en"]
	local wds = weekDays[params.lang] or weekDays["en"]

	local rs = "${alignc " .. params.right_space .. "}"
	local ls = "${goto " .. params.left_space .. "}"
	local bv = "${voffset " .. params.back_voffset .. "}"
	local df = "${font}"
	local nf = "${font " .. params.normal_font .. "}"
	local bf = "${font " .. params.big_font .. "}"
	local gf = "${font " .. params.grid_font .. "}"
	local wc = "${color " .. params.weekend_color .. "}"
	local sc = "${color " .. params.spin_color .. "}"

	local result = "\n"

	if params.draw_spin then
		-- display month with big text
		result = result .. nf .. rs .. mths[tonumber(month)] .. df .. "\n\n${voffset -10}"

		if wd == 1 or wd == 7 then
			-- display weekday with big text
			result = result .. bf .. rs .. wc .. os.date("%d") .. "${color}" .. df .. "\n\n${voffset -2}"
			result = result .. nf .. rs ..wc ..  wdsf[wd] .. "${color}" .. df .. "\n\n"
		else
			result = result .. bf .. rs .. os.date("%d") .. df .. "\n\n${voffset -2}"
			result = result .. nf .. rs .. wdsf[wd] .. df .. "\n\n"
		end
	end

	if params.draw_spin then
		result = result .. bv .. sc .. "${voffset -15}${goto 1}${hr 15}${color}\n\n${voffset -13}"
	else
		result = result .. bv .. ls
	end

	for x=0,6 do
		wd = (x + wkSt) <= 7 and x + wkSt or 1

		if wd == 1 or wd == 7 then
			result = result .. wc
		end

		result = result .. wds[wd] .. " "

		if wd == 1 or wd == 7 then
			result = result .. "${color grey}"
		end
	end

	-- divider between weekday labels and dates
	result = result .. "\n " .. ls .. string.rep("   ", stDay)

	for x = 1, mthDays do
		wd = os.date("%w", os.time{year = year, month = month, day = x}) + 1

		if wd == 1 or wd == 7 then
			result = result .. wc
		end

		if x < 10 then
			result = result .. "0"
		end

		result = result .. x .. " "

		if wd == 1 or wd == 7 then
			result = result .. "${color grey}"
		end

		if (x+stDay)%7==0 then
			result = result .. "\n " .. ls
		end
	end

	return result
end
