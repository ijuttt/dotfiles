return {
  "crnvl96/lazydocker.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  event = "VeryLazy", -- load plugin pas dibutuhin aja
  opts = {
    window = {
      settings = {
        width = 0.8, -- 80% lebar layar
        height = 0.8, -- 80% tinggi layar
        border = "rounded",
        relative = "editor",
      },
    },
  },
  keys = {
    {
      "<leader>dd",
      function()
        require("lazydocker").toggle()
      end,
      desc = "Toggle LazyDocker",
    },
  },
}
