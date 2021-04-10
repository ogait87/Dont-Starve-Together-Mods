name = "Lureplant Farm Helper"
description = "Helps creating farms that use lureplants"
author = "ogait87"
version = "0.1.0"

icon_atlas = "modicon.xml"
icon = "modicon.tex"

dst_compatible = true
client_only_mod = true
all_clients_require_mod = false

api_version = 10

key_options = {}
for i = 1, 26 do
    local c = ("").char(64+i)
    key_options[i] = {description = c, data = c}
end

configuration_options =
{
    {
        name = "toggle_key",
        label = "Toggle Key",
        options = key_options,
        default = "O",
    }
}
