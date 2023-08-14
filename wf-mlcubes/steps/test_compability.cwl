#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Get MLCube config files then upload to Synapse

inputs:
- id: mlcube_file
  type: File
- id: synapse_config
  type: File

outputs:
- id: results
  type: stdout

baseCommand: [medperf, test, run, --offline, --no-cache]
arguments:
- prefix: --demo_dataset_url
  valueFrom: "synapse:syn52276402"
- prefix: --demo_dataset_hash
  valueFrom: "16526543134396b0c8fd0f0428be7c96f2142a66"
- prefix: -m
  valueFrom: $(inputs.mlcube_file)
- prefix: -p
  valueFrom: "/Users/vchung/Desktop/brats2023/test_mlcubes/prep_segmentation"
- prefix: -e
  valueFrom: "/Users/vchung/Desktop/brats2023/test_mlcubes/eval_segmentation"
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