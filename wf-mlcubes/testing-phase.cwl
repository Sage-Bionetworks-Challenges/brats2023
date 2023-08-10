#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

label: BraTS 2023 - MLCube workflow

requirements:
  - class: StepInputExpressionRequirement

inputs:
  adminUploadSynId:
    label: Synapse Folder ID accessible by an admin
    type: string
  submissionId:
    label: Submission ID
    type: int
  submitterUploadSynId:
    label: Synapse Folder ID accessible by the submitter
    type: string
  synapseConfig:
    label: filepath to .synapseConfig file
    type: File
  workflowSynapseId:
    label: Synapse File ID that links to the workflow
    type: string
  organizers:
    label: User or team ID for challenge organizers
    type: string
    default: "3466984"

outputs: []

steps:
  organizers_log_access:
    doc: >
      Give challenge organizers `download` permissions to the submission logs
    run: |-
      https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.0/cwl/set_permissions.cwl
    in:
      - id: entityid
        source: "#submitterUploadSynId"
      - id: principalid
        source: "#organizers"
      - id: permissions
        valueFrom: "download"
      - id: synapse_config
        source: "#synapseConfig"
    out: []

  download_tarball:
    doc: Download MLCube tarball submission
    run: |-
      https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.0/cwl/get_submission.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: synapse_config
        source: "#synapseConfig"
    out:
      - id: filepath
      - id: entity_id
      - id: entity_type
      - id: evaluation_id
      - id: results
  
  get_corresponding_docker:
    doc: Check that tarball is unique and contains all necessary scripts/files
    run: steps/get_docker_sub.cwl
    in:
      - id: input_file
        source: "#download_tarball/filepath"
      - id: submissionid
        source: "#submissionId"
      - id: synapse_config
        source: "#synapseConfig"
      - id: submission_view
        valueFrom: "syn52146382"
      - id: evaluation_id
        valueFrom: "9615387"
    out:
      - id: results
      - id: status
      - id: invalid_reasons
      - id: docker_id

  download_docker:
    doc: Download MLCube Docker submission
    run: |-
      https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.0/cwl/get_submission.cwl
    in:
      - id: submissionid
        source: "#get_corresponding_docker/docker_id"
      - id: synapse_config
        source: "#synapseConfig"
    out:
      - id: filepath
      - id: entity_id
      - id: entity_type
      - id: evaluation_id
      - id: results
 
s:author:
- class: s:Person
  s:identifier: https://orcid.org/0000-0002-5622-7998
  s:email: verena.chung@sagebase.org
  s:name: Verena Chung

s:codeRepository: https://github.com/Sage-Bionetworks-Challenges/brats2023
s:license: https://spdx.org/licenses/Apache-2.0

$namespaces:
  s: https://schema.org/
