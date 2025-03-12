local MapStyles = {}

MapStyles.Styles = {
    Default = {
        name = "Default",
        background = {0.1, 0.1, 0.1, 1.0},
        pathColor = {0.3, 0.8, 1.0, 1.0},
        trackingPointColor = {1.0, 1.0, 1.0, 1.0},
        trackingPointSize = 20,
        textColor = {1.0, 1.0, 1.0, 1.0},
        elevationColor = {1.0, 1.0, 1.0, 1.0},
        elevationGradient = function(normalized)
            return {
                r = normalized,
                g = 0.3 * (1 - normalized),
                b = 1 - normalized
            }
        end
    },
    
    Topographic = {
        name = "Topographic",
        background = {0.05, 0.15, 0.05, 1.0},
        pathColor = {0.8, 0.9, 0.2, 1.0},
        trackingPointColor = {1.0, 0.9, 0.2, 1.0},
        trackingPointSize = 18,
        textColor = {0.9, 1.0, 0.8, 1.0},
        elevationColor = {0.7, 0.9, 0.6, 1.0},
        gridLines = true,
        elevationGradient = function(normalized)
            if normalized < 0.5 then
                local n = normalized * 2
                return {
                    r = 0.2 + (0.6 * n),
                    g = 0.7 - (0.2 * n),
                    b = 0.1 + (0.1 * n)
                }
            else {
                local n = (normalized - 0.5) * 2
                return {
                    r = 0.8 + (0.2 * n),
                    g = 0.5 + (0.5 * n),
                    b = 0.2 + (0.8 * n)
                }
            }
        end
    },
    
    NightMode = {
        name = "Night Mode",
        background = {0.02, 0.02, 0.05, 1.0},
        pathColor = {0.3, 0.5, 1.0, 0.8},
        trackingPointColor = {0.9, 0.9, 1.0, 1.0},
        trackingPointSize = 22,
        textColor = {0.8, 0.8, 1.0, 1.0},
        elevationColor = {0.4, 0.4, 0.7, 1.0},
        glow = true,
        elevationGradient = function(normalized)
            return {
                r = 0.1 + (0.4 * normalized),
                g = 0.3 + (0.7 * normalized),
                b = 0.6 + (0.4 * normalized)
            }
        end
    },
    
    Satellite = {
        name = "Satellite",
        background = {0.15, 0.15, 0.2, 1.0},
        pathColor = {1.0, 0.4, 0.1, 1.0},
        trackingPointColor = {1.0, 1.0, 0.6, 1.0},
        trackingPointSize = 24,
        textColor = {1.0, 1.0, 0.9, 1.0},
        elevationColor = {0.8, 0.8, 0.8, 1.0},
        texture = "satellite",
        elevationGradient = function(normalized)
            return {
                r = 1.0,
                g = 0.2 + (0.8 * normalized),
                b = normalized * 0.3
            }
        end
    },
    
    Minimalist = {
        name = "Minimalist",
        background = {0.95, 0.95, 0.97, 1.0},
        pathColor = {0.2, 0.2, 0.25, 0.9},
        trackingPointColor = {0.1, 0.1, 0.15, 1.0},
        trackingPointSize = 16,
        textColor = {0.1, 0.1, 0.15, 1.0},
        elevationColor = {0.5, 0.5, 0.55, 1.0},
        simplifiedPath = true,
        elevationGradient = function(normalized)
            local value = 0.2 + (normalized * 0.6)
            return {
                r = value,
                g = value,
                b = value + 0.1
            }
        end
    },
    
    Terrain = {
        name = "Terrain",
        background = {0.75, 0.85, 0.95, 1.0},
        pathColor = {0.7, 0.3, 0.1, 1.0},
        trackingPointColor = {0.9, 0.1, 0.1, 1.0},
        trackingPointSize = 20,
        textColor = {0.2, 0.2, 0.2, 1.0},
        elevationColor = {0.6, 0.7, 0.5, 1.0},
        terrain = true,
        elevationGradient = function(normalized)
            if normalized < 0.25 then
                local n = normalized * 4
                return {
                    r = 0.1 + (0.2 * n),
                    g = 0.3 + (0.4 * n),
                    b = 0.8 - (0.2 * n)
                }
            elseif normalized < 0.5 then
                local n = (normalized - 0.25) * 4
                return {
                    r = 0.3 + (0.2 * n),
                    g = 0.7 - (0.1 * n),
                    b = 0.6 - (0.3 * n)
                }
            elseif normalized < 0.75 then
                local n = (normalized - 0.5) * 4
                return {
                    r = 0.5 + (0.3 * n),
                    g = 0.6 - (0.2 * n),
                    b = 0.3 - (0.1 * n)
                }
            else {
                local n = (normalized - 0.75) * 4
                return {
                    r = 0.8 + (0.2 * n),
                    g = 0.8 + (0.2 * n),
                    b = 0.8 + (0.2 * n)
                }
            }
        end
    },
    
    Urban = {
        name = "Urban",
        background = {0.2, 0.2, 0.22, 1.0},
        pathColor = {0.9, 0.6, 0.0, 1.0},
        trackingPointColor = {1.0, 0.8, 0.0, 1.0},
        trackingPointSize = 18,
        textColor = {0.9, 0.9, 0.9, 1.0},
        elevationColor = {0.6, 0.6, 0.6, 1.0},
        grid = true,
        gridColor = {0.3, 0.3, 0.32, 0.7},
        elevationGradient = function(normalized)
            return {
                r = 0.9 + (0.1 * normalized),
                g = 0.4 + (0.6 * normalized),
                b = normalized * 0.3
            }
        end
    }
}

MapStyles.ApplyStyle = function(elements, style, options)
    if not elements or not style then return end
    
    if elements.background then
        elements.background:LoadSettings({
            TopLeftRed = style.background[1],
            TopLeftGreen = style.background[2],
            TopLeftBlue = style.background[3],
            TopLeftAlpha = style.background[4],
            BottomLeftRed = style.background[1],
            BottomLeftGreen = style.background[2],
            BottomLeftBlue = style.background[3],
            BottomLeftAlpha = style.background[4],
            TopRightRed = style.background[1],
            TopRightGreen = style.background[2],
            TopRightBlue = style.background[3],
            TopRightAlpha = style.background[4],
            BottomRightRed = style.background[1],
            BottomRightGreen = style.background[2],
            BottomRightBlue = style.background[3],
            BottomRightAlpha = style.background[4]
        })
    end
    
    if elements.mapPath and not options.colorByElevation then
        elements.mapPath:LoadSettings({
            Red = style.pathColor[1],
            Green = style.pathColor[2],
            Blue = style.pathColor[3],
            Alpha = style.pathColor[4]
        })
    end
    
    if elements.trackingPoint then
        elements.trackingPoint:LoadSettings({
            Red = style.trackingPointColor[1],
            Green = style.trackingPointColor[2],
            Blue = style.trackingPointColor[3],
            Alpha = style.trackingPointColor[4],
            Width = style.trackingPointSize,
            Height = style.trackingPointSize
        })
    end
    
    if elements.dataText then
        elements.dataText:LoadSettings({
            Red = style.textColor[1],
            Green = style.textColor[2],
            Blue = style.textColor[3],
            Alpha = style.textColor[4]
        })
    end
    
    if elements.elevationProfile then
        elements.elevationProfile:LoadSettings({
            Red = style.elevationColor[1],
            Green = style.elevationColor[2],
            Blue = style.elevationColor[3],
            Alpha = style.elevationColor[4]
        })
    end
    
    if style.grid and elements.background then
        local grid = fusion:GetCurrentComp():AddTool("Grid")
        grid:LoadSettings({
            Width = 1920,
            Height = 1080,
            Red = style.gridColor[1],
            Green = style.gridColor[2],
            Blue = style.gridColor[3],
            Alpha = style.gridColor[4],
            XCells = 20,
            YCells = 20
        })
        
        elements.background:ConnectInput("Background", grid:FindMainOutput())
    end
    
    if style.glow and elements.mapPath then
        local glow = fusion:GetCurrentComp():AddTool("Glow")
        glow:LoadSettings({
            Blend = 0.5,
            Threshold = 0.5,
            Gain = 1.5
        })
        
        glow:ConnectInput("Input", elements.mapPath:FindMainOutput())
        
        if elements.trackingPoint then
            elements.trackingPoint:ConnectInput("Background", glow:FindMainOutput())
        end
    end
    
    return elements
end

MapStyles.GetElevationGradient = function(styleName, normalized, minEle, maxEle)
    local style = MapStyles.Styles[styleName] or MapStyles.Styles.Default
    if style.elevationGradient then
        return style.elevationGradient(normalized)
    else
        return {
            r = normalized,
            g = 0.3 * (1 - normalized),
            b = 1 - normalized
        }
    end
end

MapStyles.GetStyleNames = function()
    local names = {}
    for name, _ in pairs(MapStyles.Styles) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

return MapStyles