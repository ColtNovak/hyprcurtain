hl.on("hyprland.start", function()
    hl.exec_cmd("hyprcurtain login")
end)

local streaming = false
for _, m in ipairs(hl.get_monitors()) do
    if m.name == "STREAM" then
        streaming = true
    end
end

if streaming then
    pcall(dofile, os.getenv("XDG_RUNTIME_DIR") .. "/hyprcurtain.lua")
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= "STREAM" then
            hl.monitor({ output = m.name, disabled = true })
        end
    end
end
