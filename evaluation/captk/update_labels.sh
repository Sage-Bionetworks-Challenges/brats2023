#!/usr/bin/env bash

function captk () {
    /work/CaPTk/bin/Utilities "$@"
}

case $1 in
    *.tar.gz) tar xzf  "$1" -C "pred" ;;
    *.zip)    unzip -j "$1" -d "pred" ;;
esac

for f in pred/*.nii.gz
do
    filename=$(basename $f)
    label=${filename%.*.*}
    captk \
        -i pred/${label}.nii.gz \
        -o updated-predictions/${label}.nii.gz \
        -cv 4,3
done

tar cvf predictions.tar.gz updated-predictions/*.nii.gz
