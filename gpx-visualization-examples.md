# GPX Visualization Examples and Use Cases

This document showcases practical examples of how to use the GPX Visualization Tool for different types of projects.

## Example 1: Mountain Biking Video

### Scenario
You've recorded a mountain biking descent with a chest-mounted GoPro and want to show your route, elevation changes, and speed.

### Recommended Setup
- **Map Style**: Terrain
- **Data Display**: Speed, Grade, Elevation
- **Options**: Enable "Color by Elevation", Path Width 4

### Step-by-Step Workflow
1. Export GPX from your GoPro or bike computer
2. Import your mountain biking footage into DaVinci Resolve
3. Launch GPX Visualization Tool
4. Load your GPX file
5. Select "Terrain" map style
6. Enable "Show Elevation Profile"
7. Enable "Color by Elevation"
8. Enable "Show Speed" and "Show Grade"
9. Set path width to 4
10. Use "Set Current Time" at a recognizable point (e.g., start of descent)
11. Preview and adjust if needed
12. Create the visualization
13. Use a Merge node to composite over your video
14. Apply a slight "Glow" effect to make the track stand out against changing backgrounds

### Visual Result
The visualization will show your trail in terrain-colored elevation mapping. Viewers can see steep descents represented by color changes and the grade percentage. Speed display will highlight fast sections of your ride.

## Example 2: Night Run in Urban Area

### Scenario
You've recorded an evening run through a city with a headlamp and want to showcase your route through the urban environment.

### Recommended Setup
- **Map Style**: Night Mode or Urban
- **Data Display**: Speed, Coordinates
- **Options**: Enable "Show Grid Lines", "Apply Glow Effect", Path Width 5

### Step-by-Step Workflow
1. Export GPX from your running app
2. Import your night running footage into DaVinci Resolve
3. Launch GPX Visualization Tool
4. Load your GPX file
5. Select "Night Mode" map style
6. Enable "Show Grid Lines"
7. Enable "Apply Glow Effect"
8. Enable "Show Speed" and "Show Coordinates"
9. Set path width to 5 for better visibility
10. Synchronize at the start of your run
11. Preview and adjust if needed
12. Create the visualization
13. Use a Merge node set to "Screen" blending mode to composite over your video

### Visual Result
The visualization will show your running route with a glowing blue track against a dark background with grid lines resembling city blocks. The glowing effect makes the track stand out against the night footage.

## Example 3: Professional Hiking Route Presentation

### Scenario
You're creating an informational video about a hiking trail for a tourism website and want a clean, professional presentation of the route.

### Recommended Setup
- **Map Style**: Minimalist or Topographic
- **Data Display**: Elevation, Coordinates
- **Options**: Path Width 3, No extra effects

### Step-by-Step Workflow
1. Import your hiking footage into DaVinci Resolve
2. Launch GPX Visualization Tool
3. Load your GPX file for the trail
4. Select "Minimalist" map style
5. Enable "Show Elevation Profile"
6. Disable "Color by Elevation" for a cleaner look
7. Enable "Show Coordinates" 
8. Set path width to 3
9. Disable any extra effects for a professional appearance
10. Create the visualization
11. Use a Merge node to composite over your video
12. Add text annotations for key landmarks using DaVinci Resolve's text tools

### Visual Result
The visualization will present a clean, professional map of the hiking trail with minimal distractions. The elevation profile will clearly show the difficulty of different trail sections, and coordinates will provide precise location information.

## Example 4: Drone Flight Path

### Scenario
You've recorded footage with a drone and want to show viewers the flight path and altitude changes.

### Recommended Setup
- **Map Style**: Satellite
- **Data Display**: Elevation, Coordinates
- **Options**: Path Width 4, Enable "Color by Elevation"

### Step-by-Step Workflow
1. Export GPX from your drone controller app
2. Import your drone footage into DaVinci Resolve
3. Launch GPX Visualization Tool
4. Load your GPX file
5. Select "Satellite" map style
6. Enable "Show Elevation Profile" 
7. Enable "Color by Elevation"
8. Enable "Show Coordinates"
9. Set path width to 4
10. Synchronize using a recognizable landmark
11. Create the visualization
12. Use a Merge node to composite over your video
13. Consider animating the visualization's opacity during scenic sections

### Visual Result
The visualization will display your drone's flight path with a satellite-style background. Elevation coloring will show altitude changes, and the coordinates will help viewers understand the precise location of your aerial footage.

## Example 5: Racing or Track Day

### Scenario
You've recorded footage from a track day or race and want to show your racing line and speed.

### Recommended Setup
- **Map Style**: Default or Urban
- **Data Display**: Speed only
- **Options**: Path Width 5, Enable "Color by Elevation" (will show speed gradient)

### Step-by-Step Workflow
1. Export GPX from your racing app or GPS device
2. Import your racing footage into DaVinci Resolve
3. Launch GPX Visualization Tool
4. Load your GPX file
5. Select "Urban" map style
6. Disable "Show Elevation Profile"
7. Enable "Color by Elevation" (this will show speed variations)
8. Enable "Show Speed" only
9. Set path width to 5 for visibility at high speeds
10. Synchronize carefully using the start line or another fixed point
11. Create the visualization
12. Use a Merge node to composite over your video

### Visual Result
The visualization will clearly show your racing line around the track with color gradients indicating speed variations. Viewers can see where you accelerate and brake, and the speed display will highlight your fastest sections.

## Example 6: Multi-Day Journey

### Scenario
You're creating a documentary about a multi-day journey and want to show progress across a large geographical area.

### Recommended Setup
- **Map Style**: Topographic or Terrain
- **Data Display**: Coordinates, Elevation
- **Options**: Path Width 3, Multiple visualization segments

### Step-by-Step Workflow
1. Split your GPX file into daily segments if possible
2. Create separate visualizations for each day
3. For each segment:
   - Launch GPX Visualization Tool
   - Load the segment's GPX file
   - Select "Topographic" map style
   - Enable "Show Elevation Profile"
   - Enable "Color by Elevation"
   - Set path width to 3
   - Create the visualization
4. Use Merge nodes to composite each segment
5. Animate the opacity of each segment to match your documentary's narrative

### Visual Result
The visualization will show the progression of your journey across the terrain with clear indication of elevation changes. By animating the appearance of each day's segment, viewers can follow the journey chronologically.
