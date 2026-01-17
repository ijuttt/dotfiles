return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- MATIIN SEMUA SEPARATOR
      opts.options.section_separators = { left = "", right = "" }
      opts.options.component_separators = { left = "", right = "" }

      -- MODE JADI KOTAK (1 HURUF)
      opts.sections.lualine_a = {
        {
          "mode",
          fmt = function(str)
            return str:sub(1, 1)
          end,
          padding = { left = 1, right = 1 },
        },
      }

      -- HAPUS % DAN 8:7
      opts.sections.lualine_y = {}
      opts.sections.lualine_z = {}

      return opts
    end,
  },
}
