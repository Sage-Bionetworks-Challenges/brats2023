#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Score Segmentations Lesion-wise

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: synapse_config
  type: File
- id: input_file
  type: File
- id: goldstandard
  type: File
- id: gandlf_config
  type: File
- id: penalty_label
  type: int?
- id: check_validation_finished
  type: boolean?

outputs:
- id: results
  type: File
  outputBinding:
    glob: results.json
- id: status
  type: string
  outputBinding:
    glob: results.json
    outputEval: $(JSON.parse(self[0].contents)['submission_status'])
    loadContents: true

baseCommand: score.py
arguments:
- prefix: -s
  valueFrom: $(inputs.synapse_config.path)
- prefix: -p
  valueFrom: $(inputs.input_file.path)
- prefix: -g
  valueFrom: $(inputs.goldstandard.path)
- prefix: -c
  valueFrom: $(inputs.gandlf_config.path)
- prefix: -o
  valueFrom: results.json
- prefix: --penalty_label
  valueFrom: $(inputs.penalty_label)

hints:
  DockerRequirement:
    dockerPull: FIXME

s:author:
- class: s:Person
  s:identifier: https://orcid.org/0000-0002-5622-7998
  s:email: verena.chung@sagebase.org
  s:name: Verena Chung

s:codeRepository: https://github.com/Sage-Bionetworks-Challenges/brats2023
s:license: https://spdx.org/licenses/Apache-2.0

$namespaces:
  s: https://schema.org/
