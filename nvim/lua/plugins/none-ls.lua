return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				-- Til at formatere javascript filer
				null_ls.builtins.formatting.biome,
				null_ls.builtins.formatting.prettier,
        -- Til at formatere HTML og ERB filer
				null_ls.builtins.formatting.erb_lint,
				-- Til at formatere Ruby filer
				null_ls.builtins.formatting.rubocop,
				null_ls.builtins.diagnostics.rubocop,

				-- Til at formatere python filer
				null_ls.builtins.formatting.black,
				null_ls.builtins.formatting.isort,
				-- Til at formatere C / C++ filer
				null_ls.builtins.formatting.clang_format,
			},
		})
		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
