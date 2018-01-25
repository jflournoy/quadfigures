#!/bin/bash

ProjectDir=/project_space/child_emotion/new_memory_pipeline
ScriptDir=${ProjectDir}/bin
Gfeat=$1
FullPath=`find "${ProjectDir}/Group" -type d -name "${Gfeat}" -print -quit`

#Show results on FreeSurfer Brain (Katie Askren)
for GroupLevel in ${FullPath}; do
	NumCopes=`ls -d ${GroupLevel}/*.feat | wc -l`
	GDir=`basename ${Gfeat} .g`

	for cope in `seq 1 ${NumCopes}`; do
		NumStats=`ls -d ${GroupLevel}/cope${cope}.feat/stats/zstat*.nii.gz | wc -l`

		for stat in `seq 1 ${NumStats}`; do
			for surface in pial orig ; do 
					tksurfer fsaverage lh ${surface} -mni152reg -ov ${GroupLevel}/cope${cope}.feat/stats/zstat${stat}.nii.gz -colscalebarflag 1 -fthresh 2.3 -tcl ${ScriptDir}/makeimages.tcl
					mv medial.tiff ${ProjectDir}/${GDir}_cope${cope}_zstat${stat}_lh_medial"_${surface}".tiff
					mv lateral.tiff ${ProjectDir}/${GDir}_cope${cope}_zstat${stat}_lh_lateral"_${surface}".tiff
					tksurfer fsaverage rh ${surface} -mni152reg -ov ${GroupLevel}/cope${cope}.feat/stats/zstat${stat}.nii.gz -colscalebarflag 1 -fthresh 2.3 -tcl ${ScriptDir}/makeimages.tcl
					mv medial.tiff ${ProjectDir}/${GDir}_cope${cope}_zstat${stat}_rh_medial"_${surface}".tiff
					mv lateral.tiff ${ProjectDir}/${GDir}_cope${cope}_zstat${stat}_rh_lateral"_${surface}".tiff					
			done
		done
	done
done

#Convert tiff images to png
for image in `ls ${ProjectDir}/*.tiff` ; do
	echo "Converting ${image}..."
	convert ${image} `dirname ${image}`/`basename ${image} .tiff`".png"
	rm ${image}

	echo "Moving `dirname ${image}`/`basename ${image} .tiff`'.png' ..."
	mv `dirname ${image}`/`basename ${image} .tiff`".png" ${Desktop}
done

exit

#Make individual clusters and masks (Melissa Reilly)
${ProjectDir}/bin/GroupAnalyses/MMRF -g ${FullPath} -q

