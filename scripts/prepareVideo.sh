#!/bin/bash
DIMENSIONS=$1
GIF_SCALE="1024"

#ffmpeg -s:v $DIMENSIONS -r 20 -f rawvideo -pix_fmt yuv420p -i qrawvideorgb24.yuv app2.mp4

# The video starts with a few blank frames, we want to know when the stop
ffprobe -f lavfi -i "movie=app.mp4,blackdetect[out0]" -show_entries tags=lavfi.black_start,lavfi.black_end -of default=nw=1 -v quiet > ffmpeg_info
END_OF_BLACK=`cat ffmpeg_info | grep end | head -n1 | cut -d'=' -f2`

# Remove grey frames at the beginning (app start and splash screen)
END_OF_BLACK=`awk "BEGIN {print $END_OF_BLACK+0.8; exit}"`

# Trim black frames at start
ffmpeg -s:v $DIMENSIONS -r 20 -i app.mp4 -ss $END_OF_BLACK app.mp4

# Generate gif palette
ffmpeg -y -s:v $DIMENSIONS -r 20 -i app.mp4 -vf "fps=10,scale=$GIF_SCALE:-1:flags=lanczos,palettegen" palette1024.png

# Create gif
ffmpeg -s:v $DIMENSIONS -r 20 -i app.mp4 -i palette1024.png -ss $END_OF_BLACK -filter_complex "fps=10,scale=$GIF_SCALE:-1:flags=lanczos[x];[x][1:v]paletteuse" app.gif

# Clean up
rm ffmpeg_info palette*.png qrawvideorgb24.yuv

mv app.mp4 ui-test_$DIMENSIONS.mp4
mv app.gif ui-test_$DIMENSIONS.gif
