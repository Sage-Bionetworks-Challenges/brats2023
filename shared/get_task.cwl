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
- id: synid
  type: string
- id: label
  type: string

expression: |

  ${
    if (inputs.queue == "9615339") {
      return {
        synid: "syn51514102",
        label: "BraTS-GLI"
      };
    } else if (inputs.queue == "9615344") {
      return {
        synid: "",
        label: "BraTS-MET"
      };
    } else if (inputs.queue == "9615340") {
      return {
        synid: "syn52045897",
        label: "BraTS-SSA"
      };
    } else if (inputs.queue == "9615313") {
      return {
        synid: "syn51930262",
        label: "BraTS-MEN"
      };
    } else if (inputs.queue == "9615345") {
      return {
        synid: "syn51929881",
        label: "BraTS-PED"
      };
    } else {
      throw 'invalid queue';
    }
  }