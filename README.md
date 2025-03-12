# GPX Visualization Tool for DaVinci Resolve

A powerful Fusion script for DaVinci Resolve that creates beautiful GPS track visualizations synchronized with your video footage.

## About

GPX Visualization Tool allows videographers, content creators, and outdoor enthusiasts to create professional-looking GPS track visualizations directly within DaVinci Resolve. It takes GPX data from action cameras, fitness trackers, or dedicated GPS devices and transforms it into dynamic, customizable map visualizations that can be composited with your video footage.

**Created by:** Vladas Tamosiunas and Andrius Palivonas  
**License:** MIT License

## Key Features

- **Multiple Map Styles**: Choose from 7 pre-designed styles (Default, Topographic, Night Mode, Satellite, Minimalist, Terrain, Urban)
- **Auto-Synchronization**: Automatically sync GPS data with your video footage
- **Customizable Data Display**: Show speed, elevation, grade, and coordinates
- **Elevation Visualization**: Display elevation changes with color gradients
- **Style Customization**: Apply effects like grid lines and glow
- **Preview Mode**: Test your visualization before finalizing

## Installation

1. Locate your DaVinci Resolve Fusion Scripts folder:
   - Windows: `%AppData%\Blackmagic Design\DaVinci Resolve\Fusion\Scripts\Comp`
   - Mac: `/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Comp`
   - Linux: `~/.local/share/DaVinciResolve/Fusion/Scripts/Comp`

2. Create a new folder named `GPXTool` in this location

3. Copy all the script files into the `GPXTool` folder

4. Restart DaVinci Resolve

## Quick Start

1. Open DaVinci Resolve
2. Go to the Fusion page (press Shift+5)
3. Select Scripts > Comp > GPXTool > main
4. Load your GPX file
5. Choose your preferred map style and options
6. Synchronize with your video
7. Click "Create" to generate the visualization

## Requirements

- DaVinci Resolve 18 or later
- GPX file with trackpoints containing latitude, longitude, elevation, and time data

## Contributing

Contributions are welcome! Feel free to fork the repository, make improvements, and submit pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
