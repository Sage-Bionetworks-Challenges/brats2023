## BraTS-GoAT 2024

Branch: `brats_goat2024`

Similar to BraTS 2023, BraTS-GoAT 2024 is split into two evaluation phases:

* **Validation phase:** participants submit <u>segmentation predictions</u> to be evaluated using the validation dataset

* **Test phase:** participants submit <u>MLCube models</u> that will generate segmentation predictions using the test dataset

Metrics returned and used for ranking are:

**Metrics** | **Ranking**
--|--
Lesion-wise dice, lesions-wise Hausdorff 95% distance (HD95), full dice, full HD95, sensitivity, specificity | Lesion-wise dice, lesion-wise HD95

## Kudos 🍻

BraTS 2023 evaluation would not be possible without the work of:

* [@FelixSteinbauer](https://github.com/FelixSteinbauer) - inpainting metrics
* [@rachitsaluja](https://github.com/rachitsaluja) - segmentation metrics

In addition to:

* [CaPTk](https://github.com/CBICA/CaPTk)
* [MedPerf](https://github.com/mlcommons/medperf)
* [FeTS-AI](https://github.com/FeTS-AI/Challenge/tree/main)
