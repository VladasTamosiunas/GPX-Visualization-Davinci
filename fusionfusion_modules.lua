-- Fusion-specific functionality for GPX Visualization Tool

local FusionModules = {}

FusionModules.CreateVisualizationElements = function(comp, gpxData, timeExpr, options)
    if not comp or not gpxData then return nil end
    
    local elements = {
        background = comp:AddTool("Background"),
        mapPath = comp:AddTool("Polygon"),
        trackingPoint = comp:AddTool("Circle"),
        dataText = comp:AddTool("Text")
    }
    
    if options.showElevation then
        elements.elevationProfile = comp:AddTool("Polygon")
    end
    
    return elements
end

FusionModules.SetupTimeMapping = function(elements, timeMap, fps)
    if not elements or not timeMap then return false end
    
    for _, element in pairs(elements) do
        if element.AddModifier then
            local timeModifier = element:AddModifier("TimeStretcher")
            if timeModifier then
                timeModifier:SetExpression("Timing", timeMap)
            end
        end
    end
    
    return true
end

-- Visualization namespace to match references in other functions
FusionModules.Visualization = {
    Create = function(gpxFile, options)
        local comp = fusion:GetCurrentComp()
        if not comp then return false end
        
        -- Use the utils parameter passed to FuseGPXScripts
        local gpxData = FusionModules.utils.LoadGPXData(gpxFile)
        if not gpxData then return false end
        
        local elements = FusionModules.CreateVisualizationElements(comp, gpxData, nil, options)
        if not elements then return false end
        
        -- Get and apply the selected map style
        local selectedStyle = FusionModules.mapStyles.Styles[options.mapStyle] 
            or FusionModules.mapStyles.Styles["Default"]
        
        -- Apply custom options to the style
        local customizedStyle = {}
        for k, v in pairs(selectedStyle) do
            customizedStyle[k] = v
        end
        
        -- Override style options with user selections
        customizedStyle.grid = options.showGrid
        customizedStyle.glow = options.applyGlow
        
        -- Apply the style to the elements
        FusionModules.mapStyles.ApplyStyle(elements, customizedStyle, options)
        
        -- Set up animation and timing
        if options.autoSync then
            local fps = comp:GetPrefs("Comp.FrameFormat.Rate")
            local timeMap = FusionModules.CreateTimeMapping(gpxData, options, fps)
            FusionModules.SetupTimeMapping(elements, timeMap, fps)
        end
        
        -- Set up data text displays
        FusionModules.SetupDataDisplay(elements, gpxData, options)
        
        return true
    end,
    
    -- New function to set up data displays
    SetupDataDisplay = function(elements, gpxData, options)
        if not elements or not elements.dataText or not gpxData then return end
        
        local textElements = {}
        local displayData = ""
        
        -- Build data display based on user options
        if options.showCoordinates then
            displayData = displayData .. "Lat: %.6f\nLon: %.6f\n"
        end
        
        if options.showElevation then
            displayData = displayData .. "Elev: %.1f m\n"
        end
        
        if options.showGrade then
            displayData = displayData .. "Grade: %.1f%%\n"
        end
        
        if options.showSpeed then
            displayData = displayData .. "Speed: %.1f km/h"
        end
        
        -- Trim trailing newline if present
        if displayData:sub(-1) == "\n" then
            displayData = displayData:sub(1, -2)
        end
        
        -- If no data options were selected, provide a default
        if displayData == "" then
            displayData = "GPX Track Visualization"
        end
        
        elements.dataText:LoadSettings({
            StyledText = displayData,
            Size = 40,
            VerticalJustification = "Top",
            HorizontalJustification = "Left"
        })
        
        -- Create the expression to update the displayed data
        local textExpr = [[
        function UpdateGPSData(time)
            local index = math.floor(time * ]] .. #gpxData .. [[) + 1
            if index < 1 then index = 1 end
            if index > ]] .. #gpxData .. [[ then index = ]] .. #gpxData .. [[ end
            
            local grade = 0
            local speed = 0
            
            if index > 1 then
                -- Calculate grade
                local elevDiff = ]] .. gpxData[math.min(2, #gpxData)].elevation .. [[ - ]] .. gpxData[1].elevation .. [[
                local distance = 100  -- Simplified distance calc
                grade = (elevDiff / distance) * 100
                
                -- Calculate speed (simple approximation)
                local timeSeconds = ]] .. (gpxData[math.min(2, #gpxData)].timestamp - gpxData[1].timestamp) .. [[
                if timeSeconds > 0 then
                    -- Simple distance estimation in meters
                    local dist = 10  -- Placeholder
                    speed = (dist / timeSeconds) * 3.6  -- Convert to km/h
                end
            end
            
            return string.format("]] .. displayData .. [[",
                ]] .. gpxData[1].lat .. [[,
                ]] .. gpxData[1].lon .. [[,
                ]] .. gpxData[1].elevation .. [[,
                grade,
                speed
            )
        end
        
        return UpdateGPSData(time)
        ]]
        
        elements.dataText:SetExpression("StyledText", textExpr)
    end
}

FusionModules.SetupEventHandlers = function(mainWindow, disp)
    mainWindow:Find("browse").Clicked = function()
        local selectedFile = fu:RequestFile()
        if selectedFile then
            mainWindow:Find("filepath").Text = selectedFile
            local gpxData = FusionModules.utils.LoadGPXData(selectedFile)
            if gpxData then
                local startTime = gpxData[1].timestamp
                mainWindow:Find("gpxStartTime").Text = 
                    os.date("%Y-%m-%d %H:%M:%S", startTime)
            end
        end
    end

    mainWindow:Find("setCurrentTime").Clicked = function()
        local comp = fusion:GetCurrentComp()
        if comp then
            local currentFrame = comp:GetCurrentTime()
            mainWindow:Find("timeOffset").Value = currentFrame
        end
    end
    
    mainWindow:Find("preview").Clicked = function()
        local filepath = mainWindow:Find("filepath").Text
        if filepath == "" then
            disp:ShowMessageDialog("Error", "Please select a GPX file first.")
            return
        end
        
        -- Get style selection
        local styleIndex = mainWindow:Find("mapStyle").CurrentIndex
        local styleNames = FusionModules.mapStyles.GetStyleNames()
        local styleName = styleNames[styleIndex + 1]  -- +1 because Fusion UI is 0-indexed
        
        local options = {
            autoSync = mainWindow:Find("autoSync").Checked,
            timeOffset = mainWindow:Find("timeOffset").Value,
            showElevation = mainWindow:Find("showElevation").Checked,
            colorByElevation = mainWindow:Find("colorByElevation").Checked,
            pathWidth = mainWindow:Find("pathWidth").Value,
            mapStyle = styleName,
            showGrid = mainWindow:Find("showGrid").Checked,
            applyGlow = mainWindow:Find("applyGlow").Checked,
            showSpeed = mainWindow:Find("showSpeed").Checked,
            showGrade = mainWindow:Find("showGrade").Checked,
            showCoordinates = mainWindow:Find("showCoordinates").Checked,
            previewMode = true
        }
        
        local success = FusionModules.Visualization.Create(filepath, options)
        if success then
            disp:ShowMessageDialog("Preview", "Preview created. Check the Fusion composition.")
        else
            disp:ShowMessageDialog("Error", "Failed to create preview.")
        end
    end

    mainWindow:Find("create").Clicked = function()
        local filepath = mainWindow:Find("filepath").Text
        if filepath == "" then
            disp:ShowMessageDialog("Error", "Please select a GPX file first.")
            return
        end
        
        -- Get style selection
        local styleIndex = mainWindow:Find("mapStyle").CurrentIndex
        local styleNames = FusionModules.mapStyles.GetStyleNames()
        local styleName = styleNames[styleIndex + 1]  -- +1 because Fusion UI is 0-indexed
        
        local options = {
            autoSync = mainWindow:Find("autoSync").Checked,
            timeOffset = mainWindow:Find("timeOffset").Value,
            showElevation = mainWindow:Find("showElevation").Checked,
            colorByElevation = mainWindow:Find("colorByElevation").Checked,
            pathWidth = mainWindow:Find("pathWidth").Value,
            mapStyle = styleName,
            showGrid = mainWindow:Find("showGrid").Checked,
            applyGlow = mainWindow:Find("applyGlow").Checked,
            showSpeed = mainWindow:Find("showSpeed").Checked,
            showGrade = mainWindow:Find("showGrade").Checked,
            showCoordinates = mainWindow:Find("showCoordinates").Checked
        }
        
        local success = FusionModules.Visualization.Create(filepath, options)
        if success then
            disp:ShowMessageDialog("Success", "Visualization created!")
            mainWindow:Hide()
        else
            disp:ShowMessageDialog("Error", "Failed to create visualization.")
        end
    end

    mainWindow:Find("cancel").Clicked = function()
        mainWindow:Hide()
    end
end

FusionModules.CreateTimeMapping = function(gpxData, options, fps)
    local timeMap = {}
    local startTime = gpxData[1].timestamp
    
    for i, point in ipairs(gpxData) do
        local offset = point.timestamp - startTime
        local frame = FusionModules.utils.TimeToFrames(offset, fps)
        timeMap[frame] = i
    end
    
    return timeMap
end

FusionModules.FuseGPXScripts = function(mapScript, syncScript, utils, mapStyles)
    -- Store utils and mapStyles in FusionModules to make them accessible to other functions
    FusionModules.utils = utils
    FusionModules.mapStyles = mapStyles
    
    local fusedUI = {
        Create = function()
            local ui = fu.UIManager
            local disp = bmd.UIDispatcher(ui)
            
            -- Get available style names
            local styleNames = FusionModules.mapStyles.GetStyleNames()
            
            local mainWindow = disp:AddWindow({
                ID = "FusedGPXTool",
                WindowTitle = "GPX Map & Sync Tool",
                Geometry = { 100, 100, 650, 600 },
                
                ui:VGroup{
                    ID = "root",
                    
                    ui:VGroup{
                        Weight = 0,
                        ui:HGroup{
                            ui:Label{ Text = "GPX File: ", MinimumSize = { 70, -1 } },
                            ui:LineEdit{ ID = "filepath", PlaceholderText = "Select GPX file..." },
                            ui:Button{ ID = "browse", Text = "Browse" }
                        }
                    },
                    
                    ui:VGroup{
                        Weight = 0,
                        ui:GroupBox{
                            Text = "Time Synchronization",
                            
                            ui:VGroup{
                                ui:HGroup{
                                    ui:Label{ Text = "GPX Start Time:" },
                                    ui:Label{ ID = "gpxStartTime", Text = "Not loaded" }
                                },
                                ui:HGroup{
                                    ui:CheckBox{ ID = "autoSync", Text = "Auto-detect Movement", Checked = true },
                                    ui:Button{ ID = "setCurrentTime", Text = "Set Current Time" }
                                },
                                ui:HGroup{
                                    ui:Label{ Text = "Manual Offset:" },
                                    ui:SpinBox{ ID = "timeOffset", Value = 0 }
                                }
                            }
                        }
                    },
                    
                    ui:VGroup{
                        Weight = 0,
                        ui:GroupBox{
                            Text = "Map Style",
                            
                            ui:VGroup{
                                ui:HGroup{
                                    ui:Label{ Text = "Style:" },
                                    ui:ComboBox{
                                        ID = "mapStyle",
                                        Items = styleNames
                                    }
                                },
                                ui:Label{ 
                                    ID = "styleDescription", 
                                    Text = "Select a map style to customize the visualization appearance.",
                                    WordWrap = true,
                                    MinimumSize = { -1, 40 }
                                }
                            }
                        }
                    },
                    
                    ui:VGroup{
                        Weight = 0,
                        ui:GroupBox{
                            Text = "Visualization Options",
                            
                            ui:VGroup{
                                ui:CheckBox{ ID = "showElevation", Text = "Show Elevation Profile", Checked = true },
                                ui:CheckBox{ ID = "colorByElevation", Text = "Color by Elevation", Checked = true },
                                ui:HGroup{
                                    ui:Label{ Text = "Path Width:" },
                                    ui:SpinBox{ ID = "pathWidth", Value = 3, Minimum = 1, Maximum = 10 }
                                },
                                ui:CheckBox{ ID = "showGrid", Text = "Show Grid Lines", Checked = false },
                                ui:CheckBox{ ID = "applyGlow", Text = "Apply Glow Effect", Checked = false }
                            }
                        }
                    },
                    
                    ui:VGroup{
                        Weight = 0,
                        ui:GroupBox{
                            Text = "Data Display",
                            
                            ui:VGroup{
                                ui:CheckBox{ ID = "showSpeed", Text = "Show Speed", Checked = true },
                                ui:CheckBox{ ID = "showGrade", Text = "Show Grade", Checked = true },
                                ui:CheckBox{ ID = "showCoordinates", Text = "Show Coordinates", Checked = true }
                            }
                        }
                    },
                    
                    ui:HGroup{
                        Weight = 0,
                        ui:Button{ ID = "preview", Text = "Preview" },
                        ui:Button{ ID = "create", Text = "Create" },
                        ui:Button{ ID = "cancel", Text = "Cancel" }
                    }
                }
            })
            
            -- Update style description when style is changed
            mainWindow:Find("mapStyle").CurrentIndexChanged = function(idx)
                local styleName = styleNames[idx + 1] -- Fusion UI is 0-indexed
                local description = "Style: " .. styleName .. "\n"
                
                if styleName == "Default" then
                    description = description .. "Standard visualization with blue track."
                elseif styleName == "Topographic" then
                    description = description .. "Resembles topographic maps with terrain-colored elevation."
                elseif styleName == "NightMode" then
                    description = description .. "Dark background with glowing blue track, perfect for dark scenes."
                elseif styleName == "Satellite" then
                    description = description .. "Resembles satellite imagery with vivid orange track."
                elseif styleName == "Minimalist" then
                    description = description .. "Clean, minimal design with light background and dark track."
                elseif styleName == "Terrain" then
                    description = description .. "Natural terrain colors with elevation-based gradient."
                elseif styleName == "Urban" then
                    description = description .. "Urban grid design with bright orange track."
                end
                
                mainWindow:Find("styleDescription").Text = description
            end
            
            -- Initialize with first style description
            mainWindow:Find("mapStyle").CurrentIndexChanged(0)
            
            FusionModules.SetupEventHandlers(mainWindow, disp)
            
            return mainWindow
        end
    }
    
    return {
        UI = fusedUI,
        Visualization = FusionModules.Visualization,
        utils = utils
    }
end

return FusionModules