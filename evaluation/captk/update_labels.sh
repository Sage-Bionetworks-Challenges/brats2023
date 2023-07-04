#!/usr/bin/env bash

function captk () {
    /work/CaPTk/bin/Utilities "$@"
}

mkdir -p pred
case $1 in
    *.tar.gz)  tar   -xf "$1" -C "pred" --transform='s/.*\///' ;;
    *.zip)     unzip -jq "$1" -d "pred" ;;
esac

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
