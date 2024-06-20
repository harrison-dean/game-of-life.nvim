local GameOfLife = {}
local H = {}

GameOfLife.ns = vim.api.nvim_create_namespace(("game-of-life"))


GameOfLife.setup = function(config)
	-- export module
	_G.GameOfLife = GameOfLife

	config = H.setup(config)

	H.apply_config(config)
end


GameOfLife.config = {
	options = {
		width = vim.api.nvim_win_get_width(0),
		height = vim.api.nvim_win_get_height(0),
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
		["options.width"] = { config.options.width, number },
		["options.height"] = { config.options.height, number },
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

