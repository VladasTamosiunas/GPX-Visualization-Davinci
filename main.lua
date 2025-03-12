-- Main entry point for the GPX Visualization Tool
-- Created by Vladas Tamosiunas and Andrius Palivonas
-- Open source software under MIT license

local function InitializeTool()
    -- Directly require modules to avoid path issues
    local utils = dofile("GPXTool/utils.lua")
    local fusionModules = dofile("GPXTool/fusion_modules.lua")
    local GPXMapGenerator = dofile("GPXTool/GPXMapGenerator.lua")
    local GPXVideoSync = dofile("GPXTool/GPXVideoSync.lua")
    local mapStyles = dofile("GPXTool/map_styles.lua")
    
    local fusedTool = fusionModules.FuseGPXScripts(
        GPXMapGenerator,
        GPXVideoSync,
        utils,
        mapStyles
    )
    
    local mainWindow = fusedTool.UI.Create()
    if not mainWindow then
        print("Error: Failed to create main window")
        return false
    end
    
    mainWindow:Show()
    return true
end

function Main()
    if not InitializeTool() then
        print("Failed to initialize GPX Tool")
        return
    end
end

Main()