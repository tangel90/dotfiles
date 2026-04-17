return {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {},
    keys = {
        { "<leader>tc", "<cmd>ColorizerToggle<cr>", desc = "[T]oggle [C]olorizer" },
    },
}
