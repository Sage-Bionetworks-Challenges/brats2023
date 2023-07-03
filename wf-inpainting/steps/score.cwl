#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Score Augmented Segmentations

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: parent_id
  type: string
- id: synapse_config
  type: File
- id: input_file
  type: File
- id: goldstandard
  type: File
- id: masks
  type: File
- id: label
  type: string
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

baseCommand: python
arguments:
- valueFrom: /app/score.py
- prefix: --parent_id
  valueFrom: $(inputs.parent_id)
- prefix: -s
  valueFrom: $(inputs.synapse_config.path)
- prefix: -p
  valueFrom: $(inputs.input_file.path)
- prefix: -g
  valueFrom: $(inputs.goldstandard.path)
- prefix: -m
  valueFrom: $(inputs.masks.path)
- prefix: -o
  valueFrom: results.json

hints:
  DockerRequirement:
    dockerPull: docker.synapse.org/syn51156910/inpainting-evaluation:v1
