return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = { "rafamadriz/friendly-snippets" },
      config = function()
        local ls = require("luasnip")
        require("luasnip.loaders.from_vscode").lazy_load()
        ls.filetype_extend("javascript", { "jsdoc" })

        vim.keymap.set({ "i" }, "<C-s>e", function()
          ls.expand()
        end, { silent = true, desc = "Expand snippet" })

        vim.keymap.set({ "i", "s" }, "<C-s>;", function()
          ls.jump(1)
        end, { silent = true, desc = "Next snippet stop" })

        vim.keymap.set({ "i", "s" }, "<C-s>,", function()
          ls.jump(-1)
        end, { silent = true, desc = "Previous snippet stop" })

        vim.keymap.set({ "i", "s" }, "<C-E>", function()
          if ls.choice_active() then
            ls.change_choice(1)
          end
        end, { silent = true, desc = "Cycle snippet choice" })
      end,
    },
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 100 },
        { name = "luasnip", priority = 90 },
        { name = "buffer", priority = 80, keyword_length = 2 },
        { name = "path", priority = 70 },
      }),
      performance = {
        max_view_entries = 30,
      },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
    })
  end,
}
