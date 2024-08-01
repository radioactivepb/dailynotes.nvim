local M = {}

M._path = nil
M._icons = false

---@param path string?
---@return string
M._init_day_file = function(path)
	local month_dir = (path or (vim.fn.stdpath("data") .. "/dailynotes.nvim")) .. "/" .. os.date("%Y-%m")
	vim.fn.mkdir(month_dir, "p")
	local day_file = month_dir .. "/" .. os.date("%-d") .. ".md"
	if vim.fn.filereadable(day_file) == 0 then
		vim.fn.writefile({ "" }, day_file)
	end
	return day_file
end

---@return string|osdate
M._get_day = function()
	return os.date("%-d")
end

---@param day integer
M._open_daily_note_day = function(day)
	if type(day) ~= "number" or (day < 1 or day > 31) then
		return
	end
	local month_dir = (M._path or (vim.fn.stdpath("data") .. "/dailynotes.nvim")) .. "/" .. os.date("%Y-%m")
	vim.fn.mkdir(month_dir, "p")
	local day_file = month_dir .. "/" .. day .. ".md"
	if vim.fn.filereadable(day_file) == 0 then
		vim.fn.writefile({ "" }, day_file)
	end
	M.calendar()
	vim.cmd("edit " .. day_file)
end

---@param day integer
---@param cursor_pos integer[]?
M._delete_daily_note_day = function(day, cursor_pos)
	if type(day) ~= "number" or (day < 1 or day > 31) then
		return
	end
	local month_dir = (M._path or (vim.fn.stdpath("data") .. "/dailynotes.nvim")) .. "/" .. os.date("%Y-%m")
	local day_file = month_dir .. "/" .. day .. ".md"
	if vim.fn.filereadable(day_file) == 1 then
		vim.fn.delete(day_file)
	end
	M.calendar()
	M._popup(cursor_pos)
end

---@param day integer
---@param cursor_pos integer[]?
M._create_daily_note_day = function(day, cursor_pos)
	if type(day) ~= "number" or (day < 1 or day > 31) then
		return
	end
	local month_dir = (M._path or (vim.fn.stdpath("data") .. "/dailynotes.nvim")) .. "/" .. os.date("%Y-%m")
	vim.fn.mkdir(month_dir, "p")
	local day_file = month_dir .. "/" .. day .. ".md"
	if vim.fn.filereadable(day_file) == 0 then
		vim.fn.writefile({ "" }, day_file)
	end
	M.calendar()
	M._popup(cursor_pos)
end

M._help_popup = function()
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].width,
		height = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].height,
		row = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].winrow,
		col = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].wincol,
		style = "minimal",
		border = "single",
	})
	M._create_calendar_layout(buf, win)
	local lines = {}
	table.insert(lines, "  Daily Notes Calendar - Help  ")
	table.insert(lines, "           (q to close)        ")
	table.insert(lines, " [<CR>] Open/create daily note ")
	table.insert(lines, " [c]         Create daily note ")
	table.insert(lines, " [d] or [x]  Delete daily note ")
	table.insert(lines, " [q]       Close calendar/help ")
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_del_keymap(buf, "n", "?")
	vim.api.nvim_buf_del_keymap(buf, "n", "<CR>")
	vim.api.nvim_buf_del_keymap(buf, "n", "c")
	vim.api.nvim_buf_del_keymap(buf, "n", "d")
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	vim.api.nvim_set_option_value("cursorline", true, { win = win })
	vim.api.nvim_buf_set_var(buf, "dailynotes.nvim", true)
	vim.api.nvim_set_current_win(win)
	vim.api.nvim_win_set_buf(win, buf)
end

M._create_calendar_layout = function(buf, win)
	local lines = {}
	-- FIX:? Maybe won't work on all OSes?
	local days_in_month = os.date("*t", os.time({ year = (os.date("%Y")), month = os.date("%m") + 1, day = 0 })).day
	table.insert(lines, " Daily Notes Calendar - " .. os.date("%Y-%m"))
	table.insert(lines, "           (? for help)       ")
	for day = 1, days_in_month do
		local spacer = (" "):rep(14)
		local day_length = #tostring(day)
		local check_spacer = (" "):rep(3 - day_length)
		local file_path = M._path .. "/" .. os.date("%Y-%m") .. "/" .. day .. ".md"
		if vim.fn.filereadable(file_path) == 1 then
			if vim.fn.getfsize(file_path) > 1 then
				local contains_data = M._icons and "[]" or "[X]"
				table.insert(lines, spacer .. tostring(day) .. check_spacer .. contains_data)
			else
				local contains_no_data = M._icons and "[]" or "[-]"
				table.insert(lines, spacer .. tostring(day) .. check_spacer .. contains_no_data)
			end
		else
			table.insert(lines, spacer .. tostring(day) .. check_spacer .. "[ ]")
		end
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_keymap(buf, "n", "<Up>", "<cmd>normal! k<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<Down>", "<cmd>normal! j<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })

	-- Open help popup
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"?",
		"<cmd>lua require('dailynotes')._help_popup()<CR>",
		{ noremap = true, silent = true }
	)

	-- Open daily note in calendar
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		"<cmd>lua require('dailynotes')._open_daily_note_day(vim.fn.line('.') - 2)<CR>",
		{ noremap = true, silent = true }
	)

	-- Create daily note in calendar
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"c",
		"<cmd>lua require('dailynotes')._create_daily_note_day(vim.fn.line('.') - 2, vim.api.nvim_win_get_cursor(0))<CR>",
		{ noremap = true, silent = true }
	)

	-- Delete daily note in calendar
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"d",
		"<cmd>lua require('dailynotes')._delete_daily_note_day(vim.fn.line('.') - 2, vim.api.nvim_win_get_cursor(0))<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"x",
		"<cmd>lua require('dailynotes')._delete_daily_note_day(vim.fn.line('.') - 2, vim.api.nvim_win_get_cursor(0))<CR>",
		{ noremap = true, silent = true }
	)

	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
	vim.api.nvim_set_option_value("cursorline", true, { win = win })
	vim.api.nvim_buf_set_var(buf, "dailynotes.nvim", true)
end

---@param cursor_pos integer[]?
M._popup = function(cursor_pos)
	local buf = vim.api.nvim_create_buf(false, true)

	local popup_width = 32
	local popup_height = 33

	local window_id = vim.api.nvim_get_current_win()
	local window_info = vim.fn.getwininfo(window_id)[1]
	local real_width = window_info.width - window_info.textoff
	local real_height = window_info.height

	local window_col = (real_width / 2) - (popup_width / 2)
	local window_row = (real_height / 2) - (popup_height / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = popup_width,
		height = popup_height,
		row = window_row,
		col = window_col,
		style = "minimal",
		border = "single",
	})
	M._create_calendar_layout(buf, win)
	vim.api.nvim_set_current_win(win)
	if cursor_pos then
		vim.api.nvim_win_set_cursor(win, cursor_pos)
	else
		vim.api.nvim_win_set_cursor(win, { M._get_day() + 2, 18 })
	end
end

--- Toggles the daily notes calendar popup.
M.calendar = function()
	local windows = vim.api.nvim_list_wins()
	local window_closed = false
	for _, win in ipairs(windows) do
		local success, _ = pcall(vim.api.nvim_buf_get_var, vim.api.nvim_win_get_buf(win), "dailynotes.nvim")
		if success then
			vim.api.nvim_win_close(win, true)
			window_closed = true
		end
	end
	if not window_closed then
		M._popup()
	end
end

--- Opens the daily note for the current day.
M.today = function()
	vim.cmd("edit " .. M._init_day_file(M._path))
end

M.setup = function(opts)
	local default_opts = {
		path = vim.fn.stdpath("data") .. "/dailynotes.nvim",
		icons = false,
		disable_default_keybinds = false,
		keybinds = {
			today = "<leader>no",
			calendar = "<leader>nc",
		},
	}

	if opts.disable_default_keybinds then
		default_opts.keybinds = {}
	end

	opts = vim.tbl_deep_extend("force", default_opts, opts)

	if opts.keybinds == default_opts.keybinds then
		if package.loaded["which-key"] then
			pcall(require("which-key").add, {
				{ "<leader>n", group = "Daily Notes" },
				{ "<leader>n_", hidden = true },
				{ "<leader>nc", group = "Daily Notes Calendar" },
				{ "<leader>nc_", hidden = true },
			})
		end
	end

	for f, keybind in pairs(opts.keybinds) do
		local func = M[tostring(f)]
		if func ~= nil then
			vim.keymap.set("n", keybind, func, { noremap = true, silent = true, desc = "Daily Notes: " .. f })
		end
	end

	vim.api.nvim_create_user_command("DailyNotes", function(args)
		local arg = args["args"]
		if arg == "today" then
			M.today()
		elseif arg == "calendar" or arg == "cal" then
			M.calendar()
		end
	end, { nargs = "*" })

	M._path = opts.path
	M._icons = opts.icons
end

return M
