#!/usr/bin/env python3
"""Scoring script for Pathology Task.

Run classification computation and return:
  - MCC
  - F1
  - Sensitivity
  - Specifity
"""

import argparse
import json
import subprocess

import pandas as pd

METRICS_TO_RETURN = [
    "mcc",
    "f1_global",
    "accuracy_global",
    "specificity_global"
]


def get_args():
    """Set up command-line interface and get arguments."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--synapse_config",
                        type=str, default="/.synapseConfig")
    parser.add_argument("-p", "--predictions_file",
                        type=str, default="/predictions.csv")
    parser.add_argument("-g", "--goldstandard_file",
                        type=str, default="/goldstandard.csv")
    parser.add_argument("-c", "--gandlf_config",
                        type=str, default="gandlf_config.yaml")
    parser.add_argument("-o", "--output",
                        type=str, default="results.json")
    return parser.parse_args()


def run_gandlf(config_file, input_file, output_file):
    """
    Run GanDLF classification metrics computations.
    """
    cmd = [
        "gandlf", "generate-metrics",
        "-c", config_file,
        "-i", input_file,
        "-o", output_file,
    ]
    subprocess.check_call(cmd)


def _extract_col(col, pattern_to_extract=r"(BraTSPath_Val.*png$)"):
    """Return specific content from column."""
    return col.str.extract(pattern_to_extract)


def create_gandlf_input(pred_file, gold_file, filename, penalty_label):
    """
    Create 3-col CSV file to use as input to GanDLF.
    """

    # Extract only the filename from SubjectID for easier joins.
    pred = pd.read_csv(pred_file)
    pred["SubjectID"] = _extract_col(pred.loc[:, "SubjectID"])

    gold = pd.read_csv(gold_file)
    gold["SubjectID"] = _extract_col(gold.loc[:, "SubjectID"])

    # Left join pred to gold. For missing predictions, assign "penalty"
    # label.
    res = gold.merge(pred, how="left", on="SubjectID").fillna(penalty_label)
    res["Prediction"] = res["Prediction"].astype(int)
    res.to_csv(filename, index=False)


def main():
    """Main function."""
    args = get_args()

    gandlf_input_file = "tmp.csv"
    create_gandlf_input(
        args.predictions_file,
        args.goldstandard_file,
        filename=gandlf_input_file,
        penalty_label=6,
    )

    gandlf_output_file = "tmp.json"
    run_gandlf(args.gandlf_config, gandlf_input_file, gandlf_output_file)
    with open(gandlf_output_file, encoding="utf-8") as f:
        metrics = json.load(f)

    with open(args.output, "w", encoding="utf-8") as out:
        results = {
            metric: score
            for metric, score in metrics.items()
            if metric in METRICS_TO_RETURN
        }
        out.write(json.dumps({
            **results,
            "submission_status": "SCORED"
        }))


if __name__ == "__main__":
    main()
