#!/usr/bin/env bash

function captk () {
    /work/CaPTk/bin/Utilities "$@"
}

mkdir -p pred
if [[ $(file -b --mime-type $1) == 'application/zip' ]]; then
    unzip -jq "$1" -d "pred"
elif [[ $(file -b --mime-type $1) == 'application/gzip' ]]; then
    tar   -xf "$1" -C "pred" --transform='s/.*\///'
fi

for f in pred/*.nii.gz
do
    filename=$(basename $f)
    label=${filename%.*.*}
    captk \
        -i $f \
        -o updated-predictions/${label}.nii.gz \
        -cv 4,3
done

tar cf predictions.tar.gz updated-predictions/*.nii.gz