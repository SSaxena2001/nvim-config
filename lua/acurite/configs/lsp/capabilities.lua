-- Client capabilities advertised to every server. blink.cmp extends the
-- defaults with its completion capabilities, so this must be built once and
-- shared by `vim.lsp.config("*")` and any server that layers extras on top.
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

return capabilities
