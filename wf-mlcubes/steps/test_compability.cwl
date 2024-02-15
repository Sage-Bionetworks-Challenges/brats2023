#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Run MLCube compatibility test

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: mlcube_file
  type: File
- id: synapse_config
  type: File
- id: dataset
  type: string
- id: dataset_hash
  type: string
- id: data_prep_mlcube
  type: string
- id: metrics_mlcube
  type: string

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
- id: invalid_reasons
  type: string
  outputBinding:
    glob: results.json
    outputEval: $(JSON.parse(self[0].contents)['submission_errors'])
    loadContents: true

baseCommand: validate.py
arguments:
- prefix: -s
  valueFrom: $(inputs.synapse_config.path)
- prefix: --dataset
  valueFrom: $(inputs.dataset)
- prefix: --dataset_hash
  valueFrom: $(inputs.dataset_hash)
- prefix: -m
  valueFrom: $(inputs.mlcube_file.path)
- prefix: -p
  valueFrom: $(inputs.data_prep_mlcube)
- prefix: -e
  valueFrom: $(inputs.metrics_mlcube)


hints:
  DockerRequirement:
    dockerPull: medperf-cli:v1

s:author:
- class: s:Person
  s:identifier: https://orcid.org/0000-0002-5622-7998
  s:email: verena.chung@sagebase.org
  s:name: Verena Chung

s:codeRepository: https://github.com/Sage-Bionetworks-Challenges/brats2023
s:license: https://spdx.org/licenses/Apache-2.0

$namespaces:
  s: https://schema.org/