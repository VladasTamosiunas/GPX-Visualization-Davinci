# GPX Visualization Tool - Map Styles

The GPX Visualization Tool now includes a variety of map styles to enhance your GPS track visualizations. Each style has been carefully designed to serve different visual purposes and complement various types of footage.

## Attribution

GPX Visualization Tool was created by Vladas Tamosiunas and Andrius Palivonas. This is open source software that you are free to use, modify, and distribute according to the terms of its license.

## Available Map Styles

### Default
The original visualization style with a dark background and blue track. Provides clear visibility and works well for most footage types.

### Topographic
Resembles topographic maps with terrain-colored elevation gradients. Ideal for hiking, trail running, or mountain biking videos where elevation changes are significant.

### Night Mode
Features a dark background with glowing blue track. Perfect for footage shot at night or in low-light conditions. The glow effect helps the track stand out against dark scenes.

### Satellite
Mimics the look of satellite imagery with a vivid orange track. Works well with aerial footage or landscapes where you want the track to contrast strongly with the background.

### Minimalist
A clean, minimal design with light background and dark track. Ideal for professional presentations or when you want the focus to be on the data rather than the visualization style.

### Terrain
Uses natural terrain colors with an elevation-based gradient that transitions from blue (water) to green (vegetation) to brown (mountains) to white (snow peaks). Perfect for outdoor adventure videos.

### Urban
Features an urban grid design with a bright orange track. Best suited for city runs, cycling, or driving footage in urban environments.

## Using Map Styles

1. In the GPX Visualization Tool interface, select your desired style from the "Map Style" dropdown
2. Each style can be further customized with the following options:
   - Show Grid Lines: Adds a coordinate grid to the visualization
   - Apply Glow Effect: Adds a subtle glow to the track for better visibility
   - Path Width: Adjust the thickness of the track
   - Color by Elevation: Override the style's default colors with elevation-based coloring

## Creating Style Previews

You can generate previews of all available styles to help you choose which one works best for your project:

1. Open DaVinci Resolve
2. Go to Fusion page
3. Run the Style Preview Generator script:
   - Scripts > Comp > GPXTool > style_preview_generator

This will create a grid of preview thumbnails showing each available style with sample data.

## Customizing and Creating New Styles

Advanced users can create their own custom map styles by modifying the `map_styles.lua` file:

1. Duplicate an existing style in the `MapStyles.Styles` table
2. Customize the colors, sizes, and effects
3. Add your style name to the table

Example of creating a custom style:

```lua
-- Add this to the MapStyles.Styles table in map_styles.lua
MyCustomStyle = {
    name = "My Custom Style",
    background = {0.2, 0.0, 0.3, 1.0},  -- Purple-black background
    pathColor = {1.0, 0.7, 0.0, 1.0},   -- Gold path
    trackingPointColor = {1.0, 1.0, 1.0, 1.0},
    trackingPointSize = 24,
    textColor = {1.0, 0.8, 0.0, 1.0},
    elevationColor = {0.7, 0.6, 0.9, 1.0},
    glow = true,  -- Apply glow effect
    elevationGradient = function(normalized)
        -- Custom gradient function
        return {
            r = 0.8 + (0.2 * normalized),
            g = 0.7 * normalized,
            b = 0.9 - (0.5 * normalized)
        }
    end
}
```

## Style-Specific Features

Some styles include special features that can enhance your visualization:

### Grid Lines
The Urban and Topographic styles support coordinate grid lines that help viewers understand scale and position.

### Glow Effects
The Night Mode style uses glow effects to make the track more visible against dark backgrounds.

### Terrain Gradients
The Terrain style uses a sophisticated multi-step gradient that changes color based on elevation ranges, not just a simple linear interpolation.

### Simplified Paths
The Minimalist style supports a simplified path option that reduces the number of track points for a cleaner appearance.

## Recommended Style Usage

- **Action/Adventure Footage**: Terrain or Topographic
- **Night Footage**: Night Mode
- **Urban/City Footage**: Urban
- **Professional Presentations**: Minimalist
- **Aerial/Drone Footage**: Satellite
- **General Purpose**: Default

## Technical Notes

- Some styles may be more CPU-intensive than others, particularly those with glow effects
- For 4K+ footage, you may need to adjust text sizes for optimal readability
- Styles work best when the visualization is composited with appropriate blend modes (e.g., Screen or Add for Night Mode)
