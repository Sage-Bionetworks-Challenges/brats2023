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

  unzip_tarball:
    doc: Unzip MLCube config tarball, then upload file(s) to Synapse.
    run: ../shared/extract_config.cwl
    in:
      - id: input_file
        source: "#download_tarball/filepath"
      - id: synapse_config
        source: "#synapseConfig"
      - id: parent_id
        source: "#adminUploadSynId"
    out:
      - id: results
      - id: mlcube

  send_tarball_results:
    doc: Send email if submission is missing `mlcube.yaml`
    run: steps/email_invalid.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: synapse_config
        source: "#synapseConfig"
      - id: mlcube_id
        source: "#unzip_tarball/mlcube"
    out: [finished]

  check_unzip_results:
    doc: Ensure that at least MLCube yaml file is uploaded to Synapse.
    run: steps/validate_mlcube_config.cwl
    in:
      - id: mlcube
        source: "unzip_tarball/mlcube"
      - id: previous_annotation_finished
        source: "#send_tarball_results/finished"
    out: [finished]

  get_corresponding_docker:
    doc: >
      Check that tarball is unique and contains all necessary scripts/files
    run: steps/get_docker_sub.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: synapse_config
        source: "#synapseConfig"
      - id: submission_view
        valueFrom: "syn52146382"
      - id: evaluation_id
        default: 9615387
      - id: previous_annotation_finished
        source: "#check_unzip_results/finished"
    out:
      - id: results
      - id: status
      - id: docker_id
  
  send_docker_results:
    doc: Send email whether corresponding Docker image can be found
    run: steps/email_results.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: synapse_config
        source: "#synapseConfig"
      - id: status
        source: "#get_corresponding_docker/status"
    out: [finished]

  update_tarball_sub_annots:
    doc: >
      Update tarball submission with MLCube config files
    run: |-
      https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.0/cwl/annotate_submission.cwl
    in:
      - id: submissionid
        source: "#submissionId"
      - id: annotation_values
        source: "#get_corresponding_docker/results"
      - id: to_public
        default: true
      - id: force
        default: true
      - id: synapse_config
        source: "#synapseConfig"
      - id: previous_annotation_finished
        source: "#annotate_docker_sub/finished"
    out: [finished]

  check_docker_status:
    doc: >
      Check the validation status of the submission; if 'INVALID', throw an
      exception to stop the workflow - this will prevent the attempt of
      scoring invalid predictions file (which will then result in errors)
    run: |-
      https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.0/cwl/check_status.cwl
    in:
      - id: status
        source: "#get_corresponding_docker/status"
      - id: previous_email_finished
        source: "#send_docker_results/finished"
    out: [finished]

  # download_docker:
  #   doc: Download MLCube Docker submission
  #   run: |-
  #     https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.0/cwl/get_submission.cwl
  #   in:
  #     - id: submissionid
  #       source: "#get_corresponding_docker/docker_id"
  #     - id: synapse_config
  #       source: "#synapseConfig"
  #   out: []

  annotate_docker_sub:
    doc: >
      Annotate Docker submission with MLCube config files
    run: |-
      https://raw.githubusercontent.com/Sage-Bionetworks/ChallengeWorkflowTemplates/v4.0/cwl/annotate_submission.cwl
    in:
      - id: submissionid
        source: "#get_corresponding_docker/docker_id"
      - id: annotation_values
        source: "#unzip_tarball/results"
      - id: to_public
        default: true
      - id: force
        default: true
      - id: synapse_config
        source: "#synapseConfig"
      - id: previous_annotation_finished
        source: "#check_docker_status/finished"
    out: [finished]

  # get_task_entities:
  #   doc: Get parameters based on task number
  #   run: steps/get_task.cwl
  #   in:
  #     - id: queue
  #       source: "#download_tarball/evaluation_id"
  #   out:
  #     - id: dataset
  #     - id: dataset_hash
  #     - id: data_prep_mlcube
  #     - id: metrics_mlcube

  # validate_mlcube:
  #   doc: Run MLCube compatibility test for validation
  #   run: steps/test_compability.cwl
  #   in:
  #     - id: synapse_config
  #       source: "#synapseConfig"
  #     - id: mlcube_file
  #       source: "#unzip_tarball/mlcube_file"
  #     - id: dataset
  #       source: "#get_task_entities/dataset"
  #     - id: dataset_hash
  #       source: "#get_task_entities/dataset_hash"
  #     - id: data_prep_mlcube
  #       source: "#get_task_entities/data_prep_mlcube"
  #     - id: metrics_mlcube
  #       source: "#get_task_entities/metrics_mlcube"
  #   out:
  #     - id: results

  # send_results:
  #   doc: Check the results of the compatibility test and send to submitter
  #   run: steps/check_results.cwl
  #   in:
  #     - id: submissionid
  #       source: "#submissionId"
  #     - id: synapse_config
  #       source: "#synapseConfig"
  #     - id: results
  #       source: "#validate_mlcube/results"
  #   out:
  #     - id: status
 
s:author:
- class: s:Person
  s:identifier: https://orcid.org/0000-0002-5622-7998
  s:email: verena.chung@sagebase.org
  s:name: Verena Chung

s:codeRepository: https://github.com/Sage-Bionetworks-Challenges/brats2023
s:license: https://spdx.org/licenses/Apache-2.0

$namespaces:
  s: https://schema.org/
