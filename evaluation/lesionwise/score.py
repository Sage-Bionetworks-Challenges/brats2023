#!/usr/bin/env python3
"""Scoring script for Tasks 1-5.

Run lesion-wise computation and return:
  - Dice (legacy and lesion-wise)
  - Hausdorff95 (legacy and lesion-wise)
  - Sensitivity
  - Specificity
  - Number of TP, FP, FN
"""
import os
import argparse
import json

import pandas as pd
import synapseclient
import utils
import metrics


def get_args():
    """Set up command-line interface and get arguments."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--parent_id", type=str, required=True)
    parser.add_argument("-s", "--synapse_config", type=str, default="/.synapseConfig")
    parser.add_argument(
        "-p", "--predictions_file", type=str, default="/predictions.zip"
    )
    parser.add_argument(
        "-g", "--goldstandard_file", type=str, default="/goldstandard.zip"
    )
    parser.add_argument("-o", "--output", type=str, default="results.json")
    parser.add_argument("-l", "--label", type=str, default="BraTS-GLI")
    return parser.parse_args()


def calculate_per_lesion(pred, gold, label):
    """
    Run per-lesionwise computation of prediction scan against
    goldstandard.
    """
    return metrics.get_LesionWiseResults(
        pred_file=pred, gt_file=gold, challenge_name=label
    )


def extract_metrics(df, label, scan_id):
    """Get scores for three regions: ET, WT, and TC."""
    select_cols = [
        "Labels",
        "Legacy_Dice",
        "Legacy_HD95",
        "Sensitivity",
        "Specificity",
        "Num_TP",
        "Num_FP",
        "Num_FN",
    ]
    if label != "BraTS-MEN":  # FIXME after dryrunning
        select_cols[1:1] = ["LesionWise_Score_Dice", "LesionWise_Score_HD95"]
    res = (
        df.set_index("Labels")
        .filter(items=select_cols)
        .filter(items=["ET", "WT", "TC"], axis=0)
        .reset_index()
        .assign(scan_id=f"{label}-{scan_id}")
        .pivot(index="scan_id", columns="Labels")
        .rename(
            columns={
                "LesionWise_Score_Dice": "LesionWise_Dice",
                "LesionWise_Score_HD95": "LesionWise_Hausdorff95",
                "Legacy_Dice": "Dice",
                "Legacy_HD95": "Hausdorff95",
            }
        )
    )
    res.columns = ["_".join(col).strip() for col in res.columns]
    return res


def score(parent, pred_lst, label):
    """Compute and return scores for each scan."""
    scores = []
    for pred in pred_lst:
        scan_id = pred[-16:-7]
        gold = os.path.join(parent, f"{label}-{scan_id}-seg.nii.gz")
        results = calculate_per_lesion(pred, gold, label)
        scan_scores = extract_metrics(results, label, scan_id)
        scores.append(scan_scores)
    return pd.concat(scores).sort_values(by="scan_id")


def main():
    """Main function."""
    args = get_args()
    preds = utils.inspect_zip(args.predictions_file)
    golds = utils.inspect_zip(args.goldstandard_file)

    dir_name = os.path.split(golds[0])[0]
    results = score(dir_name, preds, args.label)

    # Get number of segmentations predicted by participant, as well as
    # descriptive statistics for results.
    cases_evaluated = len(results.index)
    metrics = (
        results.describe()
        .rename(index={"25%": "25quantile", "50%": "median", "75%": "75quantile"})
        .drop(["count", "min", "max"])
    )
    results = pd.concat([results, metrics])

    # CSV file of scores for all scans.
    syn = synapseclient.Synapse(configPath=args.synapse_config)
    syn.login(silent=True)

    # BraTS-MEN-RT organizers requested to only return full Dice
    # and HD95 scores back to participants.
    if args.label == "BraTS-MEN":  # FIXME after dryrunning
        results.to_csv("all_scores.csv")
    else:
        results.to_csv(
            "all_scores.csv",
            columns=[
                col
                for col in results.columns
                if col.startswith("LesionWise") or col.startswith("Num")
            ],
        )
        results.to_csv(
            "all_full_scores.csv",
            columns=[
                col
                for col in results.columns
                if not col.startswith("LesionWise") and not col.startswith("Num")
            ],
        )
        csv_full = synapseclient.File("all_full_scores.csv", parent=args.parent_id)
        csv_full = syn.store(csv_full)

    csv = synapseclient.File("all_scores.csv", parent=args.parent_id)
    csv = syn.store(csv)

    # Results file for annotations.
    with open(args.output, "w") as out:
        res_dict = {
            **results.loc["mean"],
            "cases_evaluated": cases_evaluated,
            "submission_scores": csv.id,
            "submission_status": "SCORED",
        }
        if args.label != "BraTS-MEN":
            res_dict["submission_scores_legacy"] = csv_full.id
        res_dict = {k: v for k, v in res_dict.items() if not pd.isna(v)}
        out.write(json.dumps(res_dict))


if __name__ == "__main__":
    main()
