#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Score Segmentations Lesion-wise

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

baseCommand: score.py
arguments:
- prefix: --parent_id
  valueFrom: $(inputs.parent_id)
- prefix: -s
  valueFrom: $(inputs.synapse_config.path)
- prefix: -p
  valueFrom: $(inputs.input_file.path)
- prefix: -g
  valueFrom: $(inputs.goldstandard.path)
- prefix: -l
  valueFrom: $(inputs.label)
- prefix: -o
  valueFrom: results.json

hints:
  DockerRequirement:
    dockerPull: docker.synapse.org/syn51156910/lesionwise-evaluation:v1
