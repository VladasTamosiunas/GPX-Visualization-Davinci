-- Complete GPX Map Generator for DaVinci Resolve
-- Save as "GPXMapGenerator.lua"

-- Moved utils to global scope to be passed in from FuseGPXScripts
local utils

local UI = {}
local Visualization = {}

UI.Create = function()
    local ui = fu.UIManager
    local disp = bmd.UIDispatcher(ui)
    
    local mainWindow = disp:AddWindow({
        ID = "GPXMapGen",
        WindowTitle = "GPX Map Generator",
        Geometry = { 100, 100, 500, 300 },
        
        ui:VGroup{
            ID = "root",
            
            -- File select
            ui:HGroup{
                ui:Label{ Text = "GPX File: " },
                ui:LineEdit{ ID = "filepath", PlaceholderText = "Select GPX file..." },
                ui:Button{ ID = "browse", Text = "Browse" }
            },
            
            -- Style option
            ui:VGroup{
                ui:Label{ Text = "Visualization Options" },
                ui:CheckBox{ ID = "showElevation", Text = "Show Elevation Profile", Checked = true },
                ui:CheckBox{ ID = "colorByElevation", Text = "Color Path by Elevation", Checked = true }
            },
            
            -- Button
            ui:HGroup{
                ui:Button{ ID = "create", Text = "Create Visualization" },
                ui:Button{ ID = "cancel", Text = "Cancel" }
            }
        }
    })
    
    mainWindow:Find("browse").Clicked = function()
        local selectedFile = fu:RequestFile()
        if selectedFile then
            mainWindow:Find("filepath").Text = selectedFile
        end
    end
    
    mainWindow:Find("create").Clicked = function()
        local filepath = mainWindow:Find("filepath").Text
        if filepath == "" then
            disp:ShowMessageDialog("Error", "Please select a GPX file first.")
            return
        end
        
        local options = {
            showElevation = mainWindow:Find("showElevation").Checked,
            colorByElevation = mainWindow:Find("colorByElevation").Checked
        }
        
        local success = Visualization.Create(filepath, options)
        if success then
            disp:ShowMessageDialog("Success", "Visualization created successfully!")
            mainWindow:Hide()
        else
            disp:ShowMessageDialog("Error", "Failed to create visualization.")
        end
    end
    
    mainWindow:Find("cancel").Clicked = function()
        mainWindow:Hide()
    end
    
    return mainWindow
end

Visualization.Create = function(gpxFile, options)
    local comp = fusion:GetCurrentComp()
    if not comp then return false end
    
    local gpxData = utils.LoadGPXData(gpxFile)
    if not gpxData then return false end
    
    local background = comp:AddTool("Background")
    local mapPath = comp:AddTool("Polygon")
    local elevationProfile = options.showElevation and comp:AddTool("Polygon") or nil
    local trackingPoint = comp:AddTool("Circle")
    local dataText = comp:AddTool("Text")
    
    Visualization.SetupElements(comp, {
        background = background,
        mapPath = mapPath,
        elevationProfile = elevationProfile,
        trackingPoint = trackingPoint,
        dataText = dataText
    }, gpxData, options)
    
    return true
end

Visualization.SetupElements = function(comp, elements, gpxData, options)
    local minLat, maxLat = math.huge, -math.huge
    local minLon, maxLon = math.huge, -math.huge
    local minEle, maxEle = math.huge, -math.huge
    
    for _, point in ipairs(gpxData) do
        minLat = math.min(minLat, point.lat)
        maxLat = math.max(maxLat, point.lat)
        minLon = math.min(minLon, point.lon)
        maxLon = math.max(maxLon, point.lon)
        minEle = math.min(minEle, point.elevation)
        maxEle = math.max(maxEle, point.elevation)
    end
    
    elements.background:LoadSettings({
        Width = 1920,
        Height = 1080,
        TopLeftRed = 0.1,
        TopLeftGreen = 0.1,
        TopLeftBlue = 0.1,
        TopLeftAlpha = 1
    })
    
    local pathPoints = ""
    local pathColors = {}
    
    for i, point in ipairs(gpxData) do
        local x = (point.lon - minLon) / (maxLon - minLon) * 1800 + 60
        local y = (1 - (point.lat - minLat) / (maxLat - minLat)) * 800 + 90
        pathPoints = pathPoints .. string.format("%.2f %.2f ", x, y)
        
        if options.colorByElevation then
            local color = utils.GetElevationColor(point.elevation, minEle, maxEle)
            table.insert(pathColors, {
                Time = i / #gpxData,
                Red = color.r,
                Green = color.g,
                Blue = color.b
            })
        end
    end
    
    elements.mapPath:LoadSettings({
        PolylinePoints = pathPoints,
        Style = "Polyline",
        Width = 3,
        Red = options.colorByElevation and 1 or 0.3,
        Green = options.colorByElevation and 0.5 or 0.8,
        Blue = options.colorByElevation and 0 or 1
    })
    
    if options.colorByElevation then
        elements.mapPath:SetData("ColorKeyframes", pathColors)
    end
    
    if options.showElevation and elements.elevationProfile then
        local profilePoints = ""
        local baseY = 1000
        local height = 200
        
        for i, point in ipairs(gpxData) do
            local x = (i-1) / (#gpxData-1) * 1800 + 60
            local y = baseY - (point.elevation - minEle) / (maxEle - minEle) * height
            profilePoints = profilePoints .. string.format("%.2f %.2f ", x, y)
        end
        
        elements.elevationProfile:LoadSettings({
            PolylinePoints = profilePoints,
            Style = "Polyline",
            Width = 2,
            Red = 1,
            Green = 1,
            Blue = 1
        })
    end
    
    elements.trackingPoint:LoadSettings({
        Width = 20,
        Height = 20,
        Red = 1,
        Green = 1,
        Blue = 1
    })
    
    local positions = {}
    for i, point in ipairs(gpxData) do
        local x = (point.lon - minLon) / (maxLon - minLon) * 1800 + 60
        local y = (1 - (point.lat - minLat) / (maxLat - minLat)) * 800 + 90
        table.insert(positions, {
            Time = i / #gpxData,
            Center = { X = x, Y = y }
        })
    end
    elements.trackingPoint:SetData("PositionKeyframes", positions)
    
    elements.dataText:LoadSettings({
        StyledText = [[
Latitude: %.6f
Longitude: %.6f
Elevation: %.1fm
Grade: %.1f%%]],
        Size = 40,
        Red = 1,
        Green = 1,
        Blue = 1,
        VerticalJustification = "Top",
        HorizontalJustification = "Left"
    })
    
    local textExpr = string.format([[
    function UpdateGPSData(time)
        local index = math.floor(time * %d) + 1
        if index < 1 then index = 1 end
        if index > %d then index = %d end
        
        local grade = 0
        if index > 1 then
            local elevDiff = %f - %f
            local distance = 100  -- Simplified distance calculation
            grade = (elevDiff / distance) * 100
        end
        
        return string.format(
            "Latitude: %.6f\\nLongitude: %.6f\\nElevation: %.1fm\\nGrade: %.1f%%",
            %f, %f, %f, grade
        )
    end
    
    return UpdateGPSData(time)
    ]], 
    #gpxData, #gpxData, #gpxData,
    gpxData[math.min(2, #gpxData)].elevation, gpxData[1].elevation,
    gpxData[1].lat, gpxData[1].lon, gpxData[1].elevation)
    
    elements.dataText:SetExpression("StyledText", textExpr)
    
    if options.showElevation and elements.elevationProfile then
        elements.mapPath:ConnectInput("Background", elements.elevationProfile:FindMainOutput())
        elements.elevationProfile:ConnectInput("Background", elements.background:FindMainOutput())
    else
        elements.mapPath:ConnectInput("Background", elements.background:FindMainOutput())
    end
    
    elements.trackingPoint:ConnectInput("Background", elements.mapPath:FindMainOutput())
    elements.dataText:ConnectInput("Background", elements.trackingPoint:FindMainOutput())
end

local GPXMapGenerator = {
    UI = UI,
    Visualization = Visualization,
    
    -- Exposed initialization method to set utils from outside
    Initialize = function(utilsModule)
        utils = utilsModule
    end
}

return GPXMapGenerator