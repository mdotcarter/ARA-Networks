#$ -S /bin/bash

echo ${s}

cd ${TOP}

DATADIR=${TOP}/experiment/data/${s}
VALUEDIR=${DATADIR}/micfiles_pca

REGIONCOUNT=$(cat ./experiment/roi_list.txt | wc -l)

FILECOUNT=$(( (${REGIONCOUNT} * (${REGIONCOUNT} - 1)) / 2 + ${REGIONCOUNT}));

echo "regions: ${REGIONCOUNT}"
echo "expected files: ${FILECOUNT}"
echo "actual files: $(ls -1 ${VALUEDIR} | wc -l)"

if [ $(ls -1 ${VALUEDIR} | wc -l) -ne ${FILECOUNT} ]; then
	echo "Not enough MIC values!"
	echo ${s} >> ${DATADIR}/../failed_mic.txt
	exit
fi

WORKINGDIR=${DATADIR}/final_matrices
mkdir ${WORKINGDIR}

MICFILE=${WORKINGDIR}/mic_pca.txt
MASFILE=${WORKINGDIR}/mas_pca.txt
MEVFILE=${WORKINGDIR}/mev_pca.txt
MCNFILE=${WORKINGDIR}/mcn_pca.txt
NLNFILE=${WORKINGDIR}/nonlinearity_pca.txt


for((i=1;i<=${REGIONCOUNT};i++)); do

	SEEDREGION=$(sed -n ${i}p ./experiment/roi_list.txt)

	for((j=1;j<${i};j++)); do

		TARGETREGION=$(sed -n ${j}p ./experiment/roi_list.txt)

		awk 'NR==1 {printf "%.6f ", $1}' ${VALUEDIR}/micvalues_${TARGETREGION}_${SEEDREGION}.txt >> ${MICFILE}
		awk 'NR==1 {printf "%.6f ", $2}' ${VALUEDIR}/micvalues_${TARGETREGION}_${SEEDREGION}.txt >> ${MASFILE}
		awk 'NR==1 {printf "%.6f ", $3}' ${VALUEDIR}/micvalues_${TARGETREGION}_${SEEDREGION}.txt >> ${MEVFILE}
		awk 'NR==1 {printf "%.6f ", $4}' ${VALUEDIR}/micvalues_${TARGETREGION}_${SEEDREGION}.txt >> ${MCNFILE}
		awk 'NR==1 {printf "%.6f ", $5}' ${VALUEDIR}/micvalues_${TARGETREGION}_${SEEDREGION}.txt >> ${NLNFILE}

	done

	for((j=${i};j<=${REGIONCOUNT};j++)); do

		TARGETREGION=$(sed -n ${j}p ./experiment/roi_list.txt)

		awk 'NR==1 {printf "%.6f ", $1}' ${VALUEDIR}/micvalues_${SEEDREGION}_${TARGETREGION}.txt >> ${MICFILE}
		awk 'NR==1 {printf "%.6f ", $2}' ${VALUEDIR}/micvalues_${SEEDREGION}_${TARGETREGION}.txt >> ${MASFILE}
		awk 'NR==1 {printf "%.6f ", $3}' ${VALUEDIR}/micvalues_${SEEDREGION}_${TARGETREGION}.txt >> ${MEVFILE}
		awk 'NR==1 {printf "%.6f ", $4}' ${VALUEDIR}/micvalues_${SEEDREGION}_${TARGETREGION}.txt >> ${MCNFILE}
		awk 'NR==1 {printf "%.6f ", $5}' ${VALUEDIR}/micvalues_${SEEDREGION}_${TARGETREGION}.txt >> ${NLNFILE}

	done
	
	echo -e -n "\n" >> ${MICFILE}
	echo -e -n "\n" >> ${MASFILE}
	echo -e -n "\n" >> ${MEVFILE}
	echo -e -n "\n" >> ${MCNFILE}
	echo -e -n "\n" >> ${NLNFILE}

done
