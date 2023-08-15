#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
label: Get goldstandard based on task number

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: queue
  type: string

outputs:
- id: dataset
  type: string
- id: dataset_hash
  type: string
- id: data_prep_mlcube
  type: string
- id: metrics_mlcube
  type: string

expression: |

  ${
    if (["9615382", "9615391", "9615392", "9615393", "9615394"].includes(inputs.queue)) {
      return {
        dataset: "synapse:syn52276402",
        label: "16526543134396b0c8fd0f0428be7c96f2142a66",
        data_prep_mlcube: "/test_mlcubes/prep_segmentation",
        metrics_mlcube: "/test_mlcubes/eval_segmentation"
      };
    } else if (inputs.queue == "9615347") {
      return {
        dataset: "synapse:syn52276402",
        label: "16526543134396b0c8fd0f0428be7c96f2142a66",
        data_prep_mlcube: "/test_mlcubes/prep_synthesis",
        metrics_mlcube: "/test_mlcubes/eval_synthesis"
      };
    } else if (inputs.queue == "9615395") {
      return {
        dataset: "synapse:syn52276405",
        label: "83cb59a06de73f2b9d08270372a243aa90ff9072",
        data_prep_mlcube: "/test_mlcubes/prep_inpainting",
        metrics_mlcube: "/test_mlcubes/eval_inpainting"
      };
    } else {
      throw 'invalid queue';
    }
  }