#makeimages.tcl
move_window 400 5
resize_window 1200

make_lateral_view
scale_brain 1.54
redraw
save_tiff tmp/lateral.tiff

make_lateral_view
rotate_brain_y 180
scale_brain 1.54
redraw
save_tiff tmp/medial.tiff
exit
