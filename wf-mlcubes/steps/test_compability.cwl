#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Run MLCube compatibility test

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
  type: stdout

baseCommand: [medperf, test, run, --offline, --no-cache]
arguments:
- prefix: --demo_dataset_url
  valueFrom: $(inputs.dataset)
- prefix: --demo_dataset_hash
  valueFrom: $(inputs.dataset_hash)
- prefix: -m
  valueFrom: $(inputs.mlcube_file)
- prefix: -p
  valueFrom: $(inputs.data_prep_mlcube)
- prefix: -e
  valueFrom: $(inputs.metrics_mlcube)
stdout: results.txt

# hints:
#   DockerRequirement:
#     dockerPull: medperf-cli:v1

s:author:
- class: s:Person
  s:identifier: https://orcid.org/0000-0002-5622-7998
  s:email: verena.chung@sagebase.org
  s:name: Verena Chung

s:codeRepository: https://github.com/Sage-Bionetworks-Challenges/brats2023
s:license: https://spdx.org/licenses/Apache-2.0

$namespaces:
  s: https://schema.org/