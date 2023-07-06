# BraTS 2023

The repository contains the infrastructure for the BraTS 2023 series of challenges:

* Segmentations (Tasks 1-5)
* Inpainting (Task 8)
* Augmentations (Task 9)

[More details about the challenge(s) are available on Synapse](https://www.synapse.org/brats).

## Overview

BraTS 2023 is split into two submission phases:

* **Validation phase:** participants submit <u>predictions files</u> (segmentation masks, t1n inferences, etc.) to be evaluated using the validation dataset

* **Test phase:** participants submit <u>models</u> that will generate prediction files using the test dataset

Metrics returned and used for ranking will depend on the task:

**Task** | **Metrics** | **Ranking**
--|--|--
Segmentations | Lesion-wise dice, lesions-wise Hausdorff 95% distance (HD95), full dice, full HD95, sensitivity, specificity | Lesion-wise dice, lesion-wise HD95
Inpainting | Structural similarity index measure (SSIM), peak-signal-to-noise-ratio (PSNR), mean-square-error (MSE) | SSIM, PSNR, MSE
Augmentations | Full dice, full HD95, sensitivity, specificity | Dice mean, dice variance, HD95 mean, HD95 variance

Code for the above computations are available in the `evaluation` folder of the repo.

## Usage

Metrics can be computed using Python, Docker, or a CWL-runner.  Regardless of approach, a Synapse account will be required.

### Compute Metrics with Python

_Coming soon_


### Compute Metrics with Docker

_Coming soon_

### Compute Metrics with CWL

_Coming soon_
