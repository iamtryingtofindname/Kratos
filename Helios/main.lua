--[[


██╗░░██╗███████╗██╗░░░░░██╗░█████╗░░██████╗
██║░░██║██╔════╝██║░░░░░██║██╔══██╗██╔════╝
███████║█████╗░░██║░░░░░██║██║░░██║╚█████╗░
██╔══██║██╔══╝░░██║░░░░░██║██║░░██║░╚═══██╗
██║░░██║███████╗███████╗██║╚█████╔╝██████╔╝
╚═╝░░╚═╝╚══════╝╚══════╝╚═╝░╚════╝░╚═════╝░

CREDITS:

Private file saving system made by iamtryingtofindname#9879
Used by Kratos script by iamtryingtofindname#9879

INFO:

Helios includes an advanced real-time repair system that repairs
files and missing folders as Helios is running. This avoids possible
errors and data loss, as well as makes up for any meddling a user
may have done with the files. It is designed to be repairable and
recover what can be recover and replace what need sto be replaced.

WARNING:

Helios filed are all saved in a folder titled 'Helios' in your
workspace folder, although the repair system will counter this,
it is highly advised that you refrain from editing or deleting
any files located in this folder to avoid unwanted data loss,
instead you should use the script interface that uses Helios
to modify any data properly and safely.

]]--

-- SERVICES
local Run = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local helios = {
    -- Settings
    TIME_BETWEEN_REPAIRS = 1; -- seconds
    TEXT_EXTENSION = ".json";

    -- Paths
    Main = "Helios";
    CreditsFileName = "CREDITS.txt";

    metadataPath = "data.json";
    metadata = {
        inBeta = true
    };

    -- URLs
    CreditsURL = "https://raw.githubusercontent.com/iamtryingtofindname/Kratos/main/Helios/credits.txt";

    -- private
    _initiated = false;
    _binded_to_close = {};
    _running = false;
    _last_running = 0;
}

function helios:Wait()
    return Run.RenderStepped:Wait()
end

function helios:Print(...)
    print("HELIOS:", ...)
end

function helios:Warn(...)
    warn("HELIOS:", ...)
end

function helios:reconcile(a,b)
    local final = {}

    for i,v in pairs(b) do
        local setValue = a[i]
        if setValue == nil then
            setValue = v
        end
        final[i] = setValue
    end

    return final
end

function helios:decode(str)
    local function try()
        return pcall(function()
            return HttpService:JSONDecode(str)
        end)
    end

    local success = false
    local count = 1

    while not success and count <= 3 do
        local s,r = try()

        if s then
            success = true
            return r
        elseif r == "Can't parse JSON" then
            return
        end

        count = count+1

        helios:Wait()
    end

    return
end

function helios:encode(tbl)
    local function try()
        return pcall(function()
            return HttpService:JSONEncode(tbl)
        end)
    end

    local success = false

    local count = 1

    while not success and count <= 3 do
        local s,r = try()

        if s then
            success = true
            return r
        end

        count = count+1

        helios:Wait()
    end

    return
end

function helios:get(url)
    local function try()
        return pcall(function()
            return game:HttpGet(url)
        end)
    end

    local success = false

    local count = 1

    while not success and count <= 3 do
        local s,r = try()

        if s then
            success = true
            return r
        elseif string.find(r,"(HttpError: InvalidUrl)") then
            return
        end

        count = count+1

        helios:Wait()
    end

    return
end

function helios:getDirectory(start,...)
    local dir = tostring(start)
    local args = {...}
    for _,v in ipairs(args) do
        dir = dir.."/"..tostring(v)
    end
    return dir
end

function helios:repairMain(placeId)
    if not isfolder(helios.Main) then
        makefolder(helios.Main)
    end
    if not isfolder(helios.Places) then
        makefolder(helios.Places)
    end
    local placeDir = helios:getDirectory(helios.Places,placeId)
    if not isfolder(placeDir) then
        makefolder(placeDir)
    end
end

function helios:decodeDirectory(directory,directoryLine) -- ... is for indecies
    for i,v in pairs(directoryLine) do
        local dir = helios:getDirectory(directory,i)
        local isFile,_ = string.find(i,helios.TEXT_EXTENSION)
        isFile = isFile and true

        if isFile then
            if isfile(dir) then
                local content = readfile(dir)
                if content == "" then
                    directoryLine[i] = content
                else
                    local decoded = helios:decode(content)
                    directoryLine[i] = decoded or content
                end
            end
        else
            directoryLine[i] = helios:decodeDirectory(dir,v)
        end
    end
    return directoryLine
end

function helios:updateWithDirectory(directoryPath,_directory) -- leave _directory nil when being called
    if helios._initiated == false then
        helios:Warn("You must initiate Helios before updating a directory")
        return
    end
    assert(helios._place_directory,"Helios: ::Init method missing _place_directory update, unable to fulfil file update request")
    local directory = _directory or helios._place_directory
    for i,v in pairs(directoryPath) do
        local thisDirectory = helios:getDirectory(directory,i)
        if isfile(thisDirectory) then
            local isFile,_ = string.find(i,helios.TEXT_EXTENSION)
            if isFile then
                local setTo = v
                if typeof(setTo)=="table" then
                    setTo = helios:encode(v)
                end
                writefile(thisDirectory,setTo)
            else
                helios:updateWithDirectory(v,directory)
            end
        else
            helios:Warn("File with path '"..thisDirectory.."' was missing, this will be repaired as long as the path is set to be repaired, if not this error will persist")
        end
    end
end

function helios:repairDirectory(directory,directoryLine)
    for i,v in pairs(directoryLine) do
        local dir = helios:getDirectory(directory,i)
        local isFile,_ = string.find(i,helios.TEXT_EXTENSION)
        isFile = isFile and true

        if isFile then
            local decoded = isfile(dir) --and helios:decode(readfile(dir))
            if not decoded then
                writefile(dir,"")--v)
            end
        else
            if not isfolder(dir) then
                makefolder(dir)
            end
        end

        if not isFile then
            if type(v) == "table" then
                helios:repairDirectory(dir,v)
            else
                helios:Warn("Invalid directory index ("..typeof(v)..")")
            end
        end
    end
end

function helios:getMetaData(directory)
    local thisMetadataPath = helios:getDirectory(directory,helios.metadataPath)
    if isfile(thisMetadataPath) then
        local old = readfile(thisMetadataPath)
        local decoded = helios:decode(old)
        if decoded then
            return decoded
        end
    end
end

function helios:repairMetadata(directory,encoded) -- assuming the directory exists
    local thisMetadataPath = helios:getDirectory(directory,helios.metadataPath)
    if not isfile(thisMetadataPath) then
        writefile(thisMetadataPath,encoded)
    end
end

function helios:setMetadata(directory,encoded)
    local thisMetadataPath = helios:getDirectory(directory,helios.metadataPath)
    if isfile(thisMetadataPath) then
        writefile(thisMetadataPath,encoded)
    end
end

function helios:repairCredits(directory,content) -- meant for internal use
    local existingContent = isfile(directory) and readfile(directory)
    if existingContent ~= content then
        writefile(directory,content)
    end
end

function helios:BindToClose(callback)
    table.insert(helios._binded_to_close,callback)
end

function helios:repair(placeId,placeDirectory,directory)
    assert(helios._encoded_place_metadata and helios._encoded_metadata,"Missing encoded metadatam modify ::Init method")
    helios:repairMain(placeId)
    helios:repairDirectory(placeDirectory,directory)
    helios:repairMetadata(placeDirectory,helios._encoded_place_metadata)
    helios:repairMetadata(helios.Main,helios._encoded_metadata)
    helios:repairCredits(helios:getDirectory(helios.Main,helios.CreditsFileName),helios._credits_raw or "HELIOS INTERNAL ERROR")
end

function helios:Init(placeId,directory,metadataNow)
    if helios._initiated then
        error("Helios already initiated!")
    end

    helios._initiated = true

    helios.Places = helios:getDirectory(helios.Main,"Places")
    directory = directory or {}
    placeId = placeId or game.PlaceId

    if directory[helios.metadataPath] then
        helios:Warn(helios.metadataPath.." is reserved for place metadata, all data associated with the path has been removed")
    end
    directory[helios.metadataPath] = nil

    if helios._main_update then
        helios._main_update:Disconnect()
    end

    helios._credits_raw = helios:get(helios.CreditsURL)

    local placeDirectory = helios:getDirectory(helios.Places,placeId)
    
    helios._place_directory = placeDirectory

    helios._encoded_metadata = helios:encode(helios.metadata)
    helios._encoded_place_metadata = helios:encode(metadataNow)

    -- initial repair
    local is,ir = pcall(function()
        return helios:repair(placeId,placeDirectory,directory)
    end)
    if not is then
        helios:Warn("Initial repair error:",ir)
    end
    helios._last_running = os.clock()+helios.TIME_BETWEEN_REPAIRS*2

    local old_metadata = helios:getMetaData(placeDirectory)
    local decoded = helios:decodeDirectory(placeDirectory,directory)

    helios:setMetadata(helios.Main,helios.metadata)
    helios:setMetadata(placeDirectory,helios._encoded_place_metadata)

    helios._main_update = Run.RenderStepped:Connect(function() -- regular repairs
        if not helios._running and (os.clock()-helios._last_running)>=helios.TIME_BETWEEN_REPAIRS then
            helios._running = true
            local s,r = pcall(function()
                return helios:repair(placeId,placeDirectory,directory)
            end)
            if not s then
                helios:Warn("Repair error:",r)
            end
            helios._last_running = os.clock()
            helios._running = false
        end
    end)

    return decoded,old_metadata
end

helios._bind_to_close_event = Players.PlayerRemoving:Connect(function(p)
    if p == player then
        for _,v in pairs(helios._binded_to_close) do
            coroutine.wrap(v)()
        end
    end
end)

return helios
