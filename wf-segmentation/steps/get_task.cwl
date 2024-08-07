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
expression: |2-

  ${
    if (inputs.queue == "9615542") {
      return {
        synid: "syn61790732",
        label: "BraTS-GLI"
      };
    } else if (inputs.queue == "9615545") {
      return {
        synid: "syn61453486",
        label: "BraTS-MET"
      };
    } else if (inputs.queue == "9615543") {
      return {
        synid: "syn61612353",
        label: "BraTS-SSA"
      };
    } else if (inputs.queue == "9615544") {
      return {
        synid: "syn61484747",
        label: "BraTS-MEN-RT"
      };
    } else if (inputs.queue == "9615546") {
      return {
        synid: "syn60969497",
        label: "BraTS-PED"
      };
    } else {
      throw 'invalid queue';
    }
  }
