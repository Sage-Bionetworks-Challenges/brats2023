#!/usr/bin/env python3
"""Scoring script for Task 9.

Run lesion-wise computation and return:
  - Dice
  - Hausdorff95
  - Sensitivity
  - Specificity
"""
import os
import argparse
import json

import pandas as pd
import synapseclient
import utils
import lesionwise_eval


def get_args():
    """Set up command-line interface and get arguments."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--parent_id",
                        type=str, required=True)
    parser.add_argument("-s", "--synapse_config",
                        type=str, default="/.synapseConfig")
    parser.add_argument("-p", "--predictions_file",
                        type=str, default="/predictions.zip")
    parser.add_argument("-g", "--goldstandard_file",
                        type=str, default="/goldstandard.zip")
    parser.add_argument("-o", "--output",
                        type=str, default="results.json")
    parser.add_argument("-l", "--label",
                        type=str, default="BraTS-GLI")
    return parser.parse_args()


def calculate_per_lesion(pred, gold, label):
    """
    Run per-lesionwise computation of prediction scan against
    goldstandard.
    """
    return lesionwise_eval.get_LesionWiseResults(
        pred_file=pred,
        gt_file=gold,
        challenge_name=label
    )


def gini(x):
    """Algorithm for GINI index metric (credit: @chepyle)."""
    sorted_x = np.sort(x)
    n = len(x)
    cumx = np.cumsum(sorted_x, dtype=float)
    index = (n + 1 - 2 * np.sum(cumx) / cumx[-1]) / n
    if np.isnan(index):
        return 1.0
    return index


def extract_metrics(df, label, scan_id):
    """Get scores for three regions: ET, WT, and TC.

    Metrics wanted:
      - Dice score
      - Hausdorff distance
      - specificity
      - sensitivity
    """
    res = (
        df.set_index("Labels")
        .filter(items=["Labels",
                       "Legacy_Dice",
                       "Legacy_HD95",
                       "Sensitivity",
                       "Specificity"])
        .filter(items=["ET", "WT", "TC"], axis=0)
        .reset_index()
        .assign(scan_id=f"{label}-{scan_id}")
        .pivot(index="scan_id", columns="Labels")
        .rename(columns={
            'Legacy_Dice': "Dice",
            'Legacy_HD95': "Hausdorff95"})
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
    metrics = (results
               .describe()
               .rename(index={'25%': "25quantile", '50%': "median", '75%': "75quantile"})
               .drop(["count", "min", "max"]))
    metrics.loc["variance"] = results.var()
    results = pd.concat([results, metrics])

    # CSV file of scores for all scans.
    results.to_csv("all_scores.csv")
    syn = synapseclient.Synapse(configPath=args.synapse_config)
    syn.login(silent=True)
    csv = synapseclient.File("all_scores.csv", parent=args.parent_id)
    csv = syn.store(csv)

    # Results file for annotations.
    with open(args.output, "w") as out:
        res_dict = {**results
                    .loc["mean"]
                    .rename({'Dice_ET': "Dice_ET_mean",
                             'Dice_TC': "Dice_TC_mean",
                             'Dice_WT': "Dice_WT_mean",
                             'Hausdorff95_ET': "Hausdorff95_ET_mean",
                             'Hausdorff95_TC': "Hausdorff95_TC_mean",
                             'Hausdorff95_WT': "Hausdorff95_WT_mean", }),
                    **results
                    .loc["variance"]
                    .rename({'Dice_ET': "Dice_ET_var",
                             'Dice_TC': "Dice_TC_var",
                             'Dice_WT': "Dice_WT_var",
                             'Hausdorff95_ET': "Hausdorff95_ET_var",
                             'Hausdorff95_TC': "Hausdorff95_TC_var",
                             'Hausdorff95_WT': "Hausdorff95_WT_var", }),
                    "cases_evaluated": cases_evaluated,
                    "submission_scores": csv.id,
                    "submission_status": "SCORED"}
        res_dict = {k: v for k, v in res_dict.items() if not pd.isna(v)}
        out.write(json.dumps(res_dict))


if __name__ == "__main__":
    main()
