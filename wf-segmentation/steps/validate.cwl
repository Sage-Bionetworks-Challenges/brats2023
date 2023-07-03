#!/usr/bin/env cwl-runner
#
# Validate submission file
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: validate.py

hints:
  DockerRequirement:
    dockerPull: docker.synapse.org/syn25829070/scoring:v5

inputs:
  - id: input_file
    type: File
  - id: goldstandard
    type: File
  - id: entity_type
    type: string

arguments:
  - valueFrom: $(inputs.input_file)
    prefix: -p
  - valueFrom: $(inputs.goldstandard.path)
    prefix: -g
  - valueFrom: $(inputs.entity_type)
    prefix: -e
  - valueFrom: results.json
    prefix: -o

requirements:
  - class: InlineJavascriptRequirement
     
outputs:
  - id: results
    type: File
    outputBinding:
      glob: results.json   
  - id: status
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['submission_status'])

  - id: invalid_reasons
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['submission_errors'])