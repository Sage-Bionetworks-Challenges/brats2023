#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: Update scan labels '4' to '3'

inputs:
- id: input_file
  type: File
- id: check_validation_finished
  type: boolean?

outputs:
  - id: predictions
    type: File
    outputBinding:
      glob: predictions.tar.gz

baseCommand: update_labels.sh
arguments:
  - valueFrom: $(inputs.input_file.path)

hints:
  DockerRequirement:
    dockerPull: docker.synapse.org/syn51156910/captk-evaluation:v1
