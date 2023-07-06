#!/usr/bin/env python3
"""Scoring script for Task 9.

Run `BraTS Similarity Metrics Computation` command from CaPTk and return:
  - Dice
  - Hausdorff95
  - Sensitivity
  - Specificity
"""
import os
import subprocess
import argparse
import json

import pandas as pd
import synapseclient
import utils


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
    parser.add_argument("-c", "--captk_path",
                        type=str, default="/work/CaPTk")
    parser.add_argument("-l", "--label",
                        type=str, default="BraTS-GLI")
    return parser.parse_args()


def run_captk(path_to_captk, pred, gold, tmp):
    """
    Run BraTS Similarity Metrics computation of prediction scan
    against goldstandard.
    """
    cmd = [
        os.path.join(path_to_captk, "bin/Utilities"),
        "-i", gold,
        "-lsb", pred,
        "-o", tmp
    ]
    subprocess.check_call(cmd)


def extract_metrics(tmp, label, scan_id):
    """Get scores for three regions: ET, WT, and TC.

    Metrics wanted:
      - Dice score
      - Hausdorff distance
      - specificity
      - sensitivity
    """
    res = (
        pd.read_csv(tmp, index_col="Labels")
        .filter(items=["Labels", "Dice", "Hausdorff95",
                       "Sensitivity", "Specificity"])
        .filter(items=["ET", "WT", "TC"], axis=0)
        .reset_index()
        .assign(scan_id=f"{label}-{scan_id}")
        .pivot(index="scan_id", columns="Labels")
    )
    res.columns = ["_".join(col).strip() for col in res.columns]
    return res


def score(parent, pred_lst, captk_path, label, tmp_output="tmp.csv"):
    """Compute and return scores for each scan."""
    scores = []
    for pred in pred_lst:
        scan_id = pred[-16:-7]
        gold = os.path.join(parent, f"{label}-{scan_id}-seg.nii.gz")
        try:
            run_captk(captk_path, pred, gold, tmp_output)
            scan_scores = extract_metrics(tmp_output, label, scan_id)
            os.remove(tmp_output)  # Remove file, as it's no longer needed
        except subprocess.CalledProcessError:
            # If no output found, give penalized scores.
            scan_scores = (
                pd.DataFrame({
                    "scan_id": [f"{label}-{scan_id}*"],
                    "Dice_ET": [0], "Dice_TC": [0], "Dice_WT": [0],
                    "Hausdorff95_ET": [374], "Hausdorff95_TC": [374],
                    "Hausdorff95_WT": [374], "Sensitivity_ET": [0],
                    "Sensitivity_TC": [0], "Sensitivity_WT": [0],
                    "Specificity_ET": [0], "Specificity_TC": [0],
                    "Specificity_WT": [0]
                })
                .set_index("scan_id")
            )
        scores.append(scan_scores)
    return pd.concat(scores).sort_values(by="scan_id")


def main():
    """Main function."""
    args = get_args()
    preds = utils.inspect_zip(args.predictions_file)
    golds = utils.inspect_zip(args.goldstandard_file)

    dir_name = os.path.split(golds[0])[0]
    results = score(dir_name, preds, args.captk_path, args.label)

    # Get number of segmentations predicted by participant, number of
    # segmentation that could not be scored, and number of segmentations
    # that were scored.
    cases_predicted = len(results.index)
    flagged_cases = int(results.reset_index().scan_id.str.count(r"\*").sum())
    cases_evaluated = cases_predicted - flagged_cases

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
