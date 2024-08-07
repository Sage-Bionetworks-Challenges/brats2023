# Evaluation Workflow for BraTS 2023+

The repository contains the evaluation workflows for the [BraTS 2023 challenge and beyond],
including:

* BraTS 2023
* BraTS-GoAT 2024
* FeTS 2024
* BraTS 2024


Workflows are organized by task type, e.g. the `wf-augmentation` folder contains
the CWL workflows for the Augmentation task.  CWL scripts used by 1+ workflow
are located in the `shared` folder.

Source code of the metrics computations mentioned in the README are available
in the `evaluation` folder of this repo, organized into sub-folders by task.

[BraTS 2023 challenge and beyond]: https://www.synapse.org/brats

## BraTS 2024

Branch: `main`

BraTS 2024 is an extension to [BraTS 2023](#brats-2023), and will also follow the two
evaluation phases approach.

Metrics returned and used for ranking will depend on the task:

**Task** | **Metrics** | **Ranking**
--|--|--
Segmentations | Lesion-wise dice, lesions-wise Hausdorff 95% distance (HD95), full dice, full HD95, sensitivity, specificity | Lesion-wise dice, lesion-wise HD95
Inpainting | Structural similarity index measure (SSIM), peak-signal-to-noise-ratio (PSNR), mean-square-error (MSE) | All 3 metrics
Augmentations | Full dice, full HD95, sensitivity, specificity | Dice mean, Dice GINI index, HD95 mean, HD95 GINI index
Pathology | Matthews correlation coefficient (MCC), F1, sensitivity, specificity | All 4 metrics

## BraTS 2023

Branch: `brats2023`

BraTS 2023 is split into two evaluation phases:

* **Validation phase:** participants submit <u>predictions files</u> (segmentation masks, t1n inferences, etc.) to be evaluated using the validation dataset

* **Test phase:** participants submit <u>MLCube models</u> that will generate prediction files using the test dataset

Metrics returned and used for ranking will depend on the task:

**Task** | **Metrics** | **Ranking**
--|--|--
Segmentations | Lesion-wise dice, lesions-wise Hausdorff 95% distance (HD95), full dice, full HD95, sensitivity, specificity | Lesion-wise dice, lesion-wise HD95
Inpainting | Structural similarity index measure (SSIM), peak-signal-to-noise-ratio (PSNR), mean-square-error (MSE) | SSIM, PSNR, MSE
Augmentations | Full dice, full HD95, sensitivity, specificity | Dice mean, dice variance, HD95 mean, HD95 variance

## BraTS-GoAT 2024

Branch: `brats_goat2024`

Similar to BraTS 2023, BraTS-GoAT 2024 is split into two evaluation phases:

* **Validation phase:** participants submit <u>segmentation predictions</u> to be evaluated using the validation dataset

* **Test phase:** participants submit <u>MLCube models</u> that will generate segmentation predictions using the test dataset

Metrics returned and used for ranking are:

**Metrics** | **Ranking**
--|--
Lesion-wise dice, lesions-wise Hausdorff 95% distance (HD95), full dice, full HD95, sensitivity, specificity | Lesion-wise dice, lesion-wise HD95

## FeTS 2024

Branch: `fets2024`

FeTS 2024 has one evaluation phase facilitated by this repo:

* **Validation phase:** participants submit <u>segmentation predictions</u> to be evaluated using the validation dataset

Metrics returned are: lesion-wise dice, lesions-wise Hausdorff 95% distance (HD95), full dice, full HD95, sensitivity, specificity

The **Code submission phase** is handled by the [FeTS-AI Task 1 infrastructure].

[FeTS-AI Task 1 infrastructure]: https://github.com/FeTS-AI/Challenge/tree/main/Task_1

## Kudos 🍻

BraTS 2023+ evaluation would not be possible without the work of:

* [@FelixSteinbauer](https://github.com/FelixSteinbauer) - inpainting metrics
* [@rachitsaluja](https://github.com/rachitsaluja) - lesionwise segmentation metrics
* [@sarthakpati](https://github.com/sarthakpati) - pathology metrics

In addition to:

* [CaPTk](https://github.com/CBICA/CaPTk)
* [MedPerf](https://github.com/mlcommons/medperf)
* [FeTS-AI](https://github.com/FeTS-AI/Challenge/tree/main)
* [GaNDLF](https://github.com/mlcommons/GaNDLF)
