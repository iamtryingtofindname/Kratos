--[[

██╗░░██╗██████╗░░█████╗░████████╗░█████╗░░██████╗
██║░██╔╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔════╝
█████═╝░██████╔╝███████║░░░██║░░░██║░░██║╚█████╗░
██╔═██╗░██╔══██╗██╔══██║░░░██║░░░██║░░██║░╚═══██╗
██║░╚██╗██║░░██║██║░░██║░░░██║░░░╚█████╔╝██████╔╝
╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░░╚════╝░╚═════╝░

Private exploit script made by iamtryingtofindname#9879
Uses Artemis UI Library made by iamtryingtofindname#9879
Uses Helios file saving system made by iamtryingtofindname#9879

]]--

local scripts = {
    -- Jailbreak
    [606849621] = "https://raw.githubusercontent.com/iamtryingtofindname/Kratos/main/games/Jailbreak/main.lua";
    -- More in the future!
}

if scripts[game.PlaceId] then
    loadstring(game:HttpGet(scripts[game.PlaceId]))()
end
