#!/bin/bash 
usage=`cat <<EOF 
This script tries to stitch medial and lateral views of lh and rh in to four panel figures with a legend. It can run on multiple .nii files to generate more than one figure at once, and can also be configured to reverse the standard color coding for 'negative' images.

Usage:
quadfigure.sh (-i) [image 1] [image 2] ... 

-i will make positive values blue.
image 1, image 2 must be .nii.gz files in MNI space.

EOF`

if [ "$#" -eq 0 ]; then
    echo "ERROR: no arguments listed"
    echo "$usage"
    exit 1
fi

if [ $1 == "-i" ]; then
    iflag=1
    shift
else
    iflag=0
fi

for i in $@;
do
    if [ ! -e $1 ]; then
	echo "ERROR: $1 not found"
	exit 1
    fi
    
    n1=`echo $i | tr '/' ' ' | awk '{print $1}'`
    n2=`basename $i .nii.gz`
    name=${n1}_$n2
#make the lh medial image with a scale bar.
    mkdir -p tmp
    commonopts="pial -gray -mni152reg -invphaseflag $iflag"
    lyeo="-annotation $SUBJECTS_DIR/fsaverage/label/lh.Yeo2011_7Networks_N1000.annot -label-outline"
    ryeo="-annotation $SUBJECTS_DIR/fsaverage/label/rh.Yeo2011_7Networks_N1000.annot -label-outline"
    tksurfer fsaverage lh $commonopts -colscalebarflag 1 -colscaletext 1 -overlay $i -tcl make1image.tcl
    mv tmp/lateral.tiff tmp/scale.tiff
    tksurfer fsaverage lh $commonopts -colscalebarflag 0 -colscaletext 0 -overlay $i -tcl make2images.tcl $lyeo
    
    mv tmp/lateral.tiff tmp/lh-lateral.tiff
    mv tmp/medial.tiff tmp/lh-medial.tiff
    
    tksurfer fsaverage rh $commonopts -colscalebarflag 0 -colscaletext 0 -overlay $i -tcl make2images.tcl $ryeo
    mv tmp/lateral.tiff tmp/rh-lateral.tiff
    mv tmp/medial.tiff tmp/rh-medial.tiff

#cut off the noise
    mogrify -crop 1200x1028+0+172 tmp/*.tiff
#OK now stitch 'em together
    convert tmp/lh-lateral.tiff tmp/rh-lateral.tiff +append tmp/all-lateral.tiff
    convert tmp/lh-medial.tiff tmp/rh-medial.tiff +append tmp/all-medial.tiff
    convert tmp/all-lateral.tiff tmp/all-medial.tiff -append tmp/all.tiff
    
#extract the scale from lh lateral and blackout the remaining
    mogrify -crop 65x85+530+420 tmp/scale.tiff
    #convert -crop 135x157+1051+1030 tmp/all.tiff tmp/scale.tiff
    #mogrify -fill black -draw 'rectangle 1051,688 1185,997' tmp/all.tiff
#now expand the scale and paste it back over the image
    mogrify -scale 380x510 tmp/scale.tiff
    #mogrify -scale 270x314 tmp/scale.tiff
    composite -gravity center -geometry +0-120 tmp/scale.tiff tmp/all.tiff tmp/final.tiff

#write the final filename
    cp tmp/final.tiff ${name}.tiff
    rm -rf tmp
done
