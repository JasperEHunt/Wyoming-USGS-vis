#!/usr/bin/env bash

# Create animated gif
ffmpeg -i png_frames/AET_Wyoming_%04d.png -vf "palettegen=max_colors=256:stats_mode=full" palette.png
ffmpeg -framerate 6 -i png_frames/AET_Wyoming_%04d.png -i palette.png -lavfi "paletteuse=dither=sierra2_4a" AET_timelapse.gif

# Create AVI
ffmpeg -framerate 6 -i png_frames/AET_Wyoming_%04d.png -q:v 1 AET_timelapse.avi