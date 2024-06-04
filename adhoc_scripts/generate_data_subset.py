"""Generate a subset of challenge data.

By default, the script will randomly select 1% of the full dataset (rounded
to the nearest integer) and save the results into a new folder.

Note: script was created due to a CBSD request for the BraTS 2025 Lighthouse
Challenge application (CBSD-4).
"""

import os
import sys
import logging
import secrets
from math import floor
from pathlib import Path
from shutil import rmtree

import typer


class IncorrectInputDataType(SystemExit):
    pass


def main(
    input_dataset: Path,
    subset_percent: float = 0.01,
    new_dataset_name: str = "BraTS-subset-data",
    cleanup: bool = False,
):
    """Main function."""

    logging.basicConfig(level=logging.DEBUG, stream=sys.stdout)
    logger = logging.getLogger()

    # Check that provided dataset is a directory, not a zipfile/tarfile.
    if not os.path.isdir(input_dataset):
        logger.error("Provided input is not a directory.")
        raise IncorrectInputDataType("Please provide a directory to subset.")

    dirs = os.listdir(Path(input_dataset))
    subset_count = floor(len(dirs) * subset_percent)
    logger.info(f"Selecting {subset_count} from {input_dataset}")

    secure_random = secrets.SystemRandom()
    selected_cases = secure_random.sample(dirs, subset_count)

    # Create new dataset directory if it doesn't already exist, then move
    # the selected images over.
    if not os.path.exists(new_dataset_name):
        os.makedirs(new_dataset_name)
    for subfolder in selected_cases:
        logger.info(f"Moving {subfolder} to {new_dataset_name}")
        Path(os.path.join(input_dataset, subfolder)).rename(
            os.path.join(new_dataset_name, subfolder)
        )

    # Remove input dataset if requested.
    if cleanup:
        logger.info(f"Cleanup - removing {input_dataset}")
        rmtree(input_dataset)


if __name__ == "__main__":
    typer.run(main)
