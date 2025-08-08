-- ~/.config/nvim/lua/snippets/java.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("class", {
        t("public class "), i(1, "ClassName"), t({ " {", "\t" }),
        i(0),
        t({ "", "}" })
    }),
    s("record", {
        t("public record "), i(1, "RecordName"), t("("), i(2, "fields"), t({ ") {", "\t" }),
        i(0),
        t({ "", "}" })
    }),
    s("interface", {
        t("public interface "), i(1, "InterfaceName"), t({ " {", "\t" }),
        i(0),
        t({ "", "}" })
    }),
}
