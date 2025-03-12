local utils = {
    ParseGPXTime = function(timeStr)
        if not timeStr then return nil end
        
        local year, month, day, hour, min, sec = 
            timeStr:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z")
            
        if not year or not month or not day or not hour or not min or not sec then
            return nil
        end
        
        return os.time({
            year = tonumber(year),
            month = tonumber(month),
            day = tonumber(day),
            hour = tonumber(hour),
            min = tonumber(min),
            sec = tonumber(sec)
        })
    end,

    TimeToFrames = function(seconds, fps)
        if not seconds or not fps then return 0 end
        return math.floor(seconds * fps + 0.5)
    end,

    FramesToTime = function(frames, fps)
        if not frames or not fps or fps == 0 then return 0 end
        return frames / fps
    end,

    FormatTimecode = function(seconds)
        if not seconds then return "00:00:00:00" end
        
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local secs = math.floor(seconds % 60)
        local frames = math.floor((seconds % 1) * 30)  -- Assuming 30fps
        return string.format("%02d:%02d:%02d:%02d", hours, minutes, secs, frames)
    end,

    -- File operations
    LoadGPXData = function(gpxPath)
        if not gpxPath then return nil end
        
        local gpxData = {}
        local file = io.open(gpxPath, "r")
        if not file then 
            print("Error: Cannot open file: " .. gpxPath)
            return nil 
        end
        
        local content = file:read("*all")
        file:close()
        
        if not content or content == "" then
            print("Error: Empty GPX file")
            return nil
        end
        
        -- Use more robust regex pattern to handle different GPX formats
        for lat, lon, ele, time in content:gmatch(
            '<trkpt[^>]*lat="([%d.-]+)"[^>]*lon="([%d.-]+)"[^>]*>.-' ..
            '<ele>([%d.-]+)</ele>.-' ..
            '<time>([^<]+)</time>'
        ) do
            local timestamp = utils.ParseGPXTime(time)
            if timestamp then
                table.insert(gpxData, {
                    lat = tonumber(lat),
                    lon = tonumber(lon),
                    elevation = tonumber(ele),
                    timestamp = timestamp
                })
            end
        end
        
        if #gpxData == 0 then
            print("Error: No valid GPS points found in file")
            return nil
        end
        
        table.sort(gpxData, function(a, b) return a.timestamp < b.timestamp end)
        
        return gpxData
    end,

    GetElevationColor = function(elevation, minEle, maxEle)
        if not elevation or not minEle or not maxEle or minEle == maxEle then
            return { r = 0.5, g = 0.5, b = 1.0 }
        end
        
        local normalized = (elevation - minEle) / (maxEle - minEle)
        return {
            r = normalized,
            g = 0.3 * (1 - normalized),
            b = 1 - normalized
        }
    end,

    CalculateGrade = function(point1, point2, distance)
        if not point1 or not point2 or not distance or distance == 0 then
            return 0
        end
        
        local elevDiff = point2.elevation - point1.elevation
        return (elevDiff / distance) * 100
    end,

    CalculateSpeed = function(point1, point2)
        if not point1 or not point2 then return 0 end
        
        local timeDiff = point2.timestamp - point1.timestamp
        if timeDiff <= 0 then return 0 end
        
        local lat1, lon1 = math.rad(point1.lat), math.rad(point1.lon)
        local lat2, lon2 = math.rad(point2.lat), math.rad(point2.lon)
        
        local dlat = lat2 - lat1
        local dlon = lon2 - lon1
        local a = math.sin(dlat/2)^2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)^2
        local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        local distance = 6371000 * c
        
        return (distance / timeDiff) * 3.6
    end,

    ValidateGPXData = function(gpxData)
        if not gpxData or #gpxData == 0 then
            return false, "No GPX data found"
        end
        
        for i, point in ipairs(gpxData) do
            if not point.lat or not point.lon or not point.elevation or not point.timestamp then
                return false, string.format("Invalid data at point %d", i)
            end
        end
        
        return true, nil
    end
}