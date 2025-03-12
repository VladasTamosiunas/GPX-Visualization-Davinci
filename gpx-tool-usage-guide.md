# GPX Visualization Tool - User Guide

This guide explains how to use the enhanced GPX Visualization Tool for DaVinci Resolve to create beautiful GPS track visualizations synchronized with your video footage.

## About

GPX Visualization Tool was created by Vladas Tamosiunas and Andrius Palivonas. It is provided as open source software, allowing users to freely use, modify, and distribute the tool according to the terms of its license.

## Table of Contents

1. [Installation](#installation)
2. [Launching the Tool](#launching-the-tool)
3. [Basic Workflow](#basic-workflow)
4. [Map Styles](#map-styles)
5. [Time Synchronization](#time-synchronization)
6. [Data Display Options](#data-display-options)
7. [Advanced Features](#advanced-features)
8. [Troubleshooting](#troubleshooting)
9. [Tips and Best Practices](#tips-and-best-practices)

## Installation

1. Locate your DaVinci Resolve Fusion Scripts folder:
   - Windows: `%AppData%\Blackmagic Design\DaVinci Resolve\Fusion\Scripts\Comp`
   - Mac: `/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Comp`
   - Linux: `~/.local/share/DaVinciResolve/Fusion/Scripts/Comp`

2. Create a new folder named `GPXTool` in this location

3. Copy these files into the `GPXTool` folder:
   ```
   GPXTool/
   ├── main.lua
   ├── utils.lua
   ├── fusion_modules.lua
   ├── map_styles.lua
   ├── style_preview_generator.lua
   ├── GPXMapGenerator.lua
   └── GPXVideoSync.lua
   ```

4. Restart DaVinci Resolve

## Launching the Tool

1. Open DaVinci Resolve
2. Go to the Fusion page (press Shift+5 or click the Fusion tab)
3. From the menu bar, select: **Scripts > Comp > GPXTool > main**
4. The GPX Visualization Tool interface will appear

## Basic Workflow

1. **Prepare Your GPX File**
   - Ensure your GPX file contains trackpoints with latitude, longitude, elevation, and time data
   - Most action cameras (GoPro, DJI, etc.) and fitness apps can export GPX files

2. **Load Your GPX File**
   - Click the "Browse" button and select your GPX file
   - The tool will display the GPX start time once loaded

3. **Choose Visualization Options**
   - Select a Map Style (see [Map Styles](#map-styles) section)
   - Adjust Path Width
   - Enable/disable "Show Elevation Profile"
   - Enable/disable "Color by Elevation"

4. **Set Time Synchronization**
   - See [Time Synchronization](#time-synchronization) section for details

5. **Preview Your Visualization**
   - Click the "Preview" button to see how your visualization will look
   - You can make adjustments and preview again as needed

6. **Create the Final Visualization**
   - Once you're satisfied with the preview, click "Create"
   - The visualization will be added to your Fusion composition

7. **Connect to Your Video**
   - In the Fusion page, connect the visualization's output to a Merge node
   - Connect your video footage as the background of this Merge

## Map Styles

The tool includes several pre-designed map styles to match different types of footage:

### Default
- Standard visualization with dark background and blue track
- Versatile style that works well with most footage types

### Topographic
- Resembles topographic maps with terrain-colored elevation
- Ideal for hiking, trail running, or mountain biking videos

### Night Mode
- Dark background with glowing blue track
- Perfect for footage shot at night or in low-light conditions

### Satellite
- Mimics satellite imagery with vivid orange track
- Works well with aerial/drone footage

### Minimalist
- Clean, minimal design with light background and dark track
- Ideal for professional presentations

### Terrain
- Natural terrain colors with elevation-based gradient
- Perfect for outdoor adventure videos showing varied landscapes

### Urban
- Urban grid design with bright orange track
- Best suited for city runs, cycling, or driving footage

### Style Preview Generator
To compare all available styles:
1. Go to the Fusion page
2. From the menu, select: **Scripts > Comp > GPXTool > style_preview_generator**
3. This will create a visual comparison of all styles

## Time Synchronization

There are two ways to synchronize your GPX data with your video footage:

### Automatic Synchronization
1. Enable "Auto-detect Movement" checkbox
2. Position your timeline playhead at the frame where motion begins in your video
3. Click "Set Current Time" button
4. The tool will attempt to match this point with the start of movement in your GPX data

### Manual Synchronization
1. Disable "Auto-detect Movement" checkbox
2. Position your timeline playhead at a known reference point in your video
3. Click "Set Current Time" button
4. Adjust the "Manual Offset" value if needed to fine-tune synchronization

### Verification
- Use the "Preview" button to check your synchronization
- Look for the tracking point to match the position in your video
- Make adjustments to the offset as needed

## Data Display Options

The tool allows you to customize what data is displayed on screen:

### Speed
- Shows current speed in km/h based on GPX data
- Enable/disable with the "Show Speed" checkbox

### Grade/Incline
- Shows the current slope percentage (uphill/downhill)
- Enable/disable with the "Show Grade" checkbox

### Coordinates
- Displays current latitude and longitude
- Enable/disable with the "Show Coordinates" checkbox

### Elevation
- Shows current elevation in meters
- Visible when "Show Elevation" is enabled

## Advanced Features

### Grid Lines
- Adds coordinate grid to the visualization
- Enable with the "Show Grid Lines" checkbox
- Particularly useful with the Urban and Topographic styles

### Glow Effect
- Adds a subtle glow to the track for better visibility
- Enable with the "Apply Glow Effect" checkbox
- Especially effective with the Night Mode style

### Style Customization
Advanced users can create custom styles by modifying the `map_styles.lua` file:

1. Open `map_styles.lua` in a text editor
2. Duplicate an existing style in the `MapStyles.Styles` table
3. Customize the colors, sizes, and effects
4. Save the file and restart DaVinci Resolve

## Troubleshooting

### "Failed to load GPX file"
- Ensure your GPX file has the required elements (trkpt, ele, time)
- Check if the file is accessible and has correct permissions
- Try opening and resaving the GPX file in another application

### "Failed to create visualization"
- Check the Script Console for error messages (Workspace > Console)
- Ensure you have sufficient GPU resources for complex visualizations
- Reduce visualization complexity (disable glow effects, etc.)

### Synchronization Issues
- Try manual synchronization with careful time offset adjustment
- Check if your GPX file and video timestamps overlap
- For difficult cases, identify a clear reference point in both the GPX data and video

### Performance Issues
- Reduce path width
- Disable glow effects
- Consider using simpler map styles (Minimalist or Default)
- For long tracks, consider splitting the visualization into segments

## Tips and Best Practices

### Recording
- Start GPX recording before video recording to ensure complete data
- Keep your device stationary at the start to help with synchronization
- Use high GPS sampling rate for smoother tracks
- Note specific landmarks or actions to use as sync points

### Editing
- Save your DaVinci Resolve project before creating complex visualizations
- Work with proxy media for better performance
- For longer videos, consider creating separate visualizations for different segments
- Apply appropriate blend modes (Screen, Add, Overlay) for better integration with footage

### Style Selection
- **Action/Adventure**: Terrain or Topographic styles
- **Night Footage**: Night Mode style
- **Urban/City**: Urban style
- **Professional Work**: Minimalist style
- **Aerial/Drone**: Satellite style

### Optimization
- Adjust path complexity based on video length
- Use appropriate path width (thinner for long tracks, thicker for short tracks)
- Only enable data displays that are relevant to your content
- Place text in less busy areas of the frame for better readability
