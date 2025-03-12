local StylePreviewGenerator = {}

StylePreviewGenerator.CreatePreviews = function(utils, mapStyles)
    local comp = fusion:GetCurrentComp()
    if not comp then 
        print("Error: No active composition")
        return false 
    end
    
    local sampleGPXData = {
        { lat = 47.6062, lon = -122.3321, elevation = 10, timestamp = os.time() },
        { lat = 47.6066, lon = -122.3310, elevation = 15, timestamp = os.time() + 60 },
        { lat = 47.6075, lon = -122.3300, elevation = 25, timestamp = os.time() + 120 },
        { lat = 47.6090, lon = -122.3290, elevation = 40, timestamp = os.time() + 180 },
        { lat = 47.6110, lon = -122.3285, elevation = 35, timestamp = os.time() + 240 },
        { lat = 47.6130, lon = -122.3280, elevation = 20, timestamp = os.time() + 300 },
        { lat = 47.6150, lon = -122.3290, elevation = 5, timestamp = os.time() + 360 }
    }
    
    local styleNames = mapStyles.GetStyleNames()
    if #styleNames == 0 then
        print("Error: No map styles available")
        return false
    end
    
    local previewElements = {}
    local previewWidth = 640
    local previewHeight = 360
    local margin = 10
    local cols = 3
    local rows = math.ceil(#styleNames / cols)
    
    -- Create master background
    local masterBG = comp:AddTool("Background")
    masterBG:LoadSettings({
        Width = previewWidth * cols + margin * (cols + 1),
        Height = previewHeight * rows + margin * (rows + 1),
        TopLeftRed = 0.05,
        TopLeftGreen = 0.05,
        TopLeftBlue = 0.05,
        TopLeftAlpha = 1
    })
    
    local lastElement = masterBG
    
    for i, styleName in ipairs(styleNames) do
        print("Creating preview for style: " .. styleName)
        
        -- Create basic elements for this style
        local elements = {
            background = comp:AddTool("Background"),
            mapPath = comp:AddTool("Polygon"),
            trackingPoint = comp:AddTool("Circle"),
            dataText = comp:AddTool("Text")
        }
        
        -- Apply the style
        local style = mapStyles.Styles[styleName]
        if not style then
            print("Warning: Style not found: " .. styleName)
            goto continue
        end
        
        -- Set background size
        elements.background:LoadSettings({
            Width = previewWidth,
            Height = previewHeight,
            TopLeftRed = style.background[1],
            TopLeftGreen = style.background[2],
            TopLeftBlue = style.background[3],
            TopLeftAlpha = style.background[4]
        })
        
        -- Create path points for sample track
        local pathPoints = ""
        local minLat, maxLat = math.huge, -math.huge
        local minLon, maxLon = math.huge, -math.huge
        local minEle, maxEle = math.huge, -math.huge
        
        for _, point in ipairs(sampleGPXData) do
            minLat = math.min(minLat, point.lat)
            maxLat = math.max(maxLat, point.lat)
            minLon = math.min(minLon, point.lon)
            maxLon = math.max(maxLon, point.lon)
            minEle = math.min(minEle, point.elevation)
            maxEle = math.max(maxEle, point.elevation)
        end
        
        for j, point in ipairs(sampleGPXData) do
            local x = (point.lon - minLon) / (maxLon - minLon) * (previewWidth - 80) + 40
            local y = (1 - (point.lat - minLat) / (maxLat - minLat)) * (previewHeight - 80) + 40
            pathPoints = pathPoints .. string.format("%.2f %.2f ", x, y)
        end
        
        -- Set path properties
        elements.mapPath:LoadSettings({
            PolylinePoints = pathPoints,
            Style = "Polyline",
            Width = 5,
            Red = style.pathColor[1],
            Green = style.pathColor[2],
            Blue = style.pathColor[3],
            Alpha = style.pathColor[4]
        })
        
        -- Set tracking point properties
        elements.trackingPoint:LoadSettings({
            Width = style.trackingPointSize,
            Height = style.trackingPointSize,
            Red = style.trackingPointColor[1],
            Green = style.trackingPointColor[2],
            Blue = style.trackingPointColor[3],
            Alpha = style.trackingPointColor[4]
        })
        
        -- Position the tracking point at the middle of the path
        local midPoint = sampleGPXData[math.ceil(#sampleGPXData / 2)]
        local midX = (midPoint.lon - minLon) / (maxLon - minLon) * (previewWidth - 80) + 40
        local midY = (1 - (midPoint.lat - minLat) / (maxLat - minLat)) * (previewHeight - 80) + 40
        
        elements.trackingPoint:SetAttrs({
            TOOLB_NameSet = 1,
            TOOLS_Name = styleName .. "_Point",
            COMPT_AdjustingAttrs = 1
        })
        
        elements.trackingPoint:SetInput("Center", midX, midY)
        
        -- Set text properties
        elements.dataText:LoadSettings({
            StyledText = styleName,
            Size = 32,
            Red = style.textColor[1],
            Green = style.textColor[2],
            Blue = style.textColor[3],
            Alpha = style.textColor[4],
            VerticalJustification = "Bottom",
            HorizontalJustification = "Right"
        })
        
        -- Connect the elements
        elements.mapPath:ConnectInput("Background", elements.background:FindMainOutput())
        elements.trackingPoint:ConnectInput("Background", elements.mapPath:FindMainOutput())
        elements.dataText:ConnectInput("Background", elements.trackingPoint:FindMainOutput())
        
        -- Position this preview on the grid
        local row = math.floor((i-1) / cols)
        local col = (i-1) % cols
        local x = margin + col * (previewWidth + margin)
        local y = margin + row * (previewHeight + margin)
        
        -- Create a merge to add this preview to the master
        local merge = comp:AddTool("Merge")
        
        merge:LoadSettings({
            XOffset = x,
            YOffset = y
        })
        
        merge:ConnectInput("Background", lastElement:FindMainOutput())
        merge:ConnectInput("Foreground", elements.dataText:FindMainOutput())
        
        lastElement = merge
        
        -- Add grid and glow effects if specified
        if style.grid then
            print("Adding grid to " .. styleName)
            local grid = comp:AddTool("Grid")
            grid:LoadSettings({
                Width = previewWidth,
                Height = previewHeight,
                Red = style.gridColor and style.gridColor[1] or 0.3,
                Green = style.gridColor and style.gridColor[2] or 0.3,
                Blue = style.gridColor and style.gridColor[3] or 0.32,
                Alpha = style.gridColor and style.gridColor[4] or 0.7,
                XCells = 20,
                YCells = 20
            })
            
            -- For grid styles, connect the grid before the background
            elements.background:ConnectInput("Background", grid:FindMainOutput())
        end
        
        if style.glow then
            print("Adding glow to " .. styleName)
            local glow = comp:AddTool("Glow")
            glow:LoadSettings({
                Blend = 0.5,
                Threshold = 0.5,
                Gain = 1.5
            })
            
            glow:ConnectInput("Input", elements.mapPath:FindMainOutput())
            elements.trackingPoint:ConnectInput("Background", glow:FindMainOutput())
        end
        
        ::continue::
    end
    
    -- Create a final text header
    local headerText = comp:AddTool("Text")
    headerText:LoadSettings({
        StyledText = "GPX Visualization Map Styles",
        Size = 60,
        Red = 1,
        Green = 1,
        Blue = 1,
        Alpha = 1,
        VerticalJustification = "Top",
        HorizontalJustification = "Center"
    })
    
    local finalMerge = comp:AddTool("Merge")
    finalMerge:ConnectInput("Background", lastElement:FindMainOutput())
    finalMerge:ConnectInput("Foreground", headerText:FindMainOutput())
    
    -- Set as final output
    comp:SetActiveTool(finalMerge)
    
    return true
end

return StylePreviewGenerator
