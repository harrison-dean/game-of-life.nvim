local GameOfLife = {}
local H = {}

GameOfLife.ns = vim.api.nvim_create_namespace(("game-of-life"))


GameOfLife.setup = function(config)
	-- export module
	_G.GameOfLife = GameOfLife

	config = H.setup_config(config)

	H.apply_config(config)
end


GameOfLife.config = {
	options = {
		width = vim.api.nvim_win_get_width(0),
		height = vim.api.nvim_win_get_height(0),
		char = "O",
	},
	inits = {
		{ 2, 2 },
		{ 5, 5 },
		{ 10, 10 },
		{ 20, 20 },
		{ 30, 30 },
	},
}

H.default_config = vim.deepcopy(GameOfLife.config)

H.setup_config = function(config)
	vim.validate({config = {config, "table", true } })
	config = vim.tbl_deep_extend("force", vim.deepcopy(H.default_config), config or {})

	vim.validate({
		options = { config.options, "table" },
	})

	vim.validate({
		["options.width"] = { config.options.width, "number" },
		["options.height"] = { config.options.height, "number" },
		["options.char"] = { config.options.char, "string" },
	})

	vim.validate({
		inits = { config.inits, "table" },
	})

	return config
end

H.apply_config = function(config)
	GameOfLife.config = config


	H.apply_options(config)
	H.apply_mappings(config)
	H.apply_autocommands(config)
end

H.apply_options = function(config)
end

H.apply_mappings = function(config)
end

H.apply_autocommands = function(config)

	vim.cmd("command! START lua startGame()")
end

GameOfLife.startGame = function()
	local config = GameOfLife.config
	local width = config.options.width
	local height = config.options.height
	local char = config.options.char
	local inits = config.inits

	local game_win, game_buf = H.open_game_win_buf(config)
	H.setup_board(game_buf, width, height)

	H.place_inits(game_buf, inits)

	H.kill_cell(game_buf, 2, 2)


end

H.open_game_win_buf = function(config)
	local buf  = vim.api.nvim_create_buf(false, true)

	local opts = {
		relative = "editor",
		width = config.options.width,
		height = config.options.height,
		row = 1,
		col = 1,
		style = "minimal",
		title = { { "Game of Life", "game-of-life" } },
		border = "single",
		}

	local win = vim.api.nvim_open_win(buf, true, opts)

	return win, buf
end

H.place_inits = function(buf, inits)
	for _, coord in ipairs(inits) do
		local x = coord[1]
		local y = coord[2]

		buf = H.spawn_cell(buf, x, y)

	end
	return buf
end

H.place_inline = function(s, pos, char)

    -- Check if the position is valid
    if pos < 1 or pos > #s then
        error("Invalid position. Position must be within the string length: "..pos)
    end

    -- Convert the string to a table of characters
    local s_table = {string.byte(s, 1, #s)}

    -- Replace the character at the specified position
    s_table[pos] = string.byte(char)

    -- Convert the table back to a string
    local amended_string = string.char(unpack(s_table))

    return amended_string
end

H.setup_board = function(buf, w, h)
	local line = string.rep(".", w-2)
	for i = 1, h do
		vim.api.nvim_buf_set_lines(buf, i-1, i, false, {line})
		i = i + 1
	end

	return buf
end

H.spawn_cell = function(buf, x, y)
	if x > GameOfLife.config.options.width or y > GameOfLife.config.options.height then
		return buf
	end

	local old_line = table.concat(vim.api.nvim_buf_get_lines(buf, y-1, y, false))
	local new_line = H.place_inline(old_line, x, GameOfLife.config.options.char)

	vim.api.nvim_buf_set_lines(buf, y-1, y, false, {new_line})

	return buf
end

H.kill_cell = function(buf, x, y)
	if x > GameOfLife.config.options.width or y > GameOfLife.config.options.height then
		return buf
	end

	local old_line = table.concat(vim.api.nvim_buf_get_lines(buf, y-1, y, false))
	local new_line = H.place_inline(old_line, x, ".")

	vim.api.nvim_buf_set_lines(buf, y-1, y, false, {new_line})

	return buf
end


return GameOfLife
