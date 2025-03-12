local utils

local TimeSync = {}
local UI = {}

TimeSync.LoadGPXData = function(gpxPath)
    return utils.LoadGPXData(gpxPath)
end

TimeSync.GetVideoTimestamp = function(comp)
    local timelineFrame = comp:GetCurrentTime()
    local fps = comp:GetPrefs("Comp.FrameFormat.Rate")
    return utils.FramesToTime(timelineFrame, fps)
end

TimeSync.CreateTimelineMap = function(gpxData, videoStartFrame, timeOffset, fps)
    local timeMap = {}
    local gpxStartTime = gpxData[1].timestamp
    
    for i, point in ipairs(gpxData) do
        local gpxOffset = point.timestamp - gpxStartTime
        local videoFrame = videoStartFrame + utils.TimeToFrames(gpxOffset + timeOffset, fps)
        timeMap[videoFrame] = i
    end
    
    return timeMap
end

UI.Create = function()
    local ui = fu.UIManager
    local disp = bmd.UIDispatcher(ui)
    
    local mainWindow = disp:AddWindow({
        ID = "GPXVideoSync",
        WindowTitle = "GPX Video Sync",
        Geometry = { 100, 100, 600, 400 },
        
        ui:VGroup{
            ID = "root",
            
            ui:HGroup{
                ui:Label{ Text = "GPX File: " },
                ui:LineEdit{ ID = "filepath", PlaceholderText = "Select GPX file..." },
                ui:Button{ ID = "browse", Text = "Browse" }
            },
            
            ui:VGroup{
                ui:Label{ Text = "Time Synchronization" },
                
                -- GPX start time display
                ui:HGroup{
                    ui:Label{ Text = "GPX Start Time:" },
                    ui:Label{ ID = "gpxStartTime", Text = "Not loaded" }
                },
                
                -- Video time sync
                ui:HGroup{
                    ui:Label{ Text = "Video Start Frame:" },
                    ui:SpinBox{ 
                        ID = "videoStartFrame",
                        Minimum = 0,
                        Maximum = 999999,
                        Value = 0
                    }
                },
                
                ui:Button{ 
                    ID = "setCurrentTime",
                    Text = "Set to Current Timeline Position"
                }
            },
            
            ui:VGroup{
                ui:Label{ Text = "Visualization Options" },
                ui:CheckBox{ ID = "showElevation", Text = "Show Elevation Profile", Checked = true },
                ui:CheckBox{ ID = "colorByElevation", Text = "Color Path by Elevation", Checked = true }
            },
            
            ui:HGroup{
                ui:Label{ Text = "Time Offset (seconds):" },
                ui:SpinBox{
                    ID = "timeOffset",
                    Minimum = -999999,
                    Maximum = 999999,
                    Value = 0
                }
            },
            
            ui:HGroup{
                ui:Button{ ID = "create", Text = "Create Synchronized Visualization" },
                ui:Button{ ID = "cancel", Text = "Cancel" }
            }
        }
    })
    
    local function UpdateGPXTimeDisplay(gpxPath)
        local gpxData = TimeSync.LoadGPXData(gpxPath)
        if gpxData then
            local startTime = gpxData[1].timestamp
            mainWindow:Find("gpxStartTime").Text = os.date("%Y-%m-%d %H:%M:%S", startTime)
        end
    end
    
    mainWindow:Find("browse").Clicked = function()
        local selectedFile = fu:RequestFile()
        if selectedFile then
            mainWindow:Find("filepath").Text = selectedFile
            UpdateGPXTimeDisplay(selectedFile)
        end
    end
    
    mainWindow:Find("setCurrentTime").Clicked = function()
        local comp = fusion:GetCurrentComp()
        if comp then
            local currentFrame = comp:GetCurrentTime()
            mainWindow:Find("videoStartFrame").Value = currentFrame
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
            colorByElevation = mainWindow:Find("colorByElevation").Checked,
            videoStartFrame = mainWindow:Find("videoStartFrame").Value,
            timeOffset = mainWindow:Find("timeOffset").Value
        }
        
        local success = CreateSyncedVisualization(filepath, options)
        if success then
            disp:ShowMessageDialog("Success", "Synchronized visualization created!")
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

function CreateSyncedVisualization(gpxFile, options)
    local comp = fusion:GetCurrentComp()
    if not comp then return false end
    
    local gpxData = TimeSync.LoadGPXData(gpxFile)
    if not gpxData then return false end
    
    local fps = comp:GetPrefs("Comp.FrameFormat.Rate")
    local timeMap = TimeSync.CreateTimelineMap(
        gpxData,
        options.videoStartFrame,
        options.timeOffset,
        fps
    )
    
    -- Create visualization elements - corrected reference to CreateVisualizationElements
    local background = comp:AddTool("Background")
    local mapPath = comp:AddTool("Polygon")
    local elevationProfile = options.showElevation and comp:AddTool("Polygon") or nil
    local trackingPoint = comp:AddTool("Circle")
    local dataText = comp:AddTool("Text")
    
    local elements = {
        background = background,
        mapPath = mapPath,
        elevationProfile = elevationProfile,
        trackingPoint = trackingPoint,
        dataText = dataText
    }
    
    -- Set up the time mapping - added new helper function
    for _, element in pairs(elements) do
        if element and element.AddModifier then
            local timeModifier = element:AddModifier("TimeStretcher")
            if timeModifier then
                -- Create an expression based on the timeMap
                local timeExpr = string.format([[
                function MapTime(frame)
                    local fps = %f
                    local startFrame = %d
                    local timeOffset = %f
                    
                    local videoTime = (frame - startFrame) / fps + timeOffset
                    local gpxStartTime = %d
                    
                    -- Find closest GPX point
                    local targetTime = gpxStartTime + videoTime
                    local index = 1
                    
                    for i = 1, %d do
                        if %d + (i-1) * (%f) >= targetTime then
                            index = i
                            break
                        end
                    end
                    
                    return (index - 1) / %d
                end
                
                return MapTime(frame)
                ]], 
                fps, 
                options.videoStartFrame, 
                options.timeOffset,
                gpxData[1].timestamp,
                #gpxData,
                gpxData[1].timestamp,
                (gpxData[#gpxData].timestamp - gpxData[1].timestamp) / (#gpxData - 1),
                #gpxData - 1
                )
                
                timeModifier:SetExpression("Timing", timeExpr)
            end
        end
    end
    
    return true
end

local GPXVideoSync = {
    UI = UI,
    TimeSync = TimeSync,
    
    -- Added initialization function
    Initialize = function(utilsModule)
        utils = utilsModule
    end
}

return GPXVideoSync