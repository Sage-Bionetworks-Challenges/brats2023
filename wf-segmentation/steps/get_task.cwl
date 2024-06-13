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
    if (inputs.queue == "9615542") {
      return {
        synid: "UPDATE_ME",
        label: "BraTS-GLI"
      };
    } else if (inputs.queue == "9615545") {
      return {
        synid: "UPDATE_ME",
        label: "BraTS-MET"
      };
    } else if (inputs.queue == "9615543") {
      return {
        synid: "UPDATE_ME",
        label: "BraTS-SSA"
      };
    } else if (inputs.queue == "9615583") {
      return {
        synid: "UPDATE_ME",
        label: "BraTS-GoAT"
      };
    } else if (inputs.queue == "9615544") {
      return {
        synid: "UPDATE_ME",
        label: "BraTS-MEN-RT"
      };
    } else if (inputs.queue == "9615546") {
      return {
        synid: "UPDATE_ME",
        label: "BraTS-PED"
      };
    } else {
      throw 'invalid queue';
    }
  }