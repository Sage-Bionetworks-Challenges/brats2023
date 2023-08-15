#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: Send email with results

requirements:
- class: InlineJavascriptRequirement
- class: InitialWorkDirRequirement
  listing:
  - entryname: email_results.py
    entry: |
      #!/usr/bin/env python
      import synapseclient
      import argparse
      import json
      import os
      parser = argparse.ArgumentParser()
      parser.add_argument("-s", "--submissionid", required=True, help="Submission ID")
      parser.add_argument("-c", "--synapse_config", required=True, help="credentials file")
      parser.add_argument("-r", "--results", required=True, help="Resulting scores")

      args = parser.parse_args()
      syn = synapseclient.Synapse(configPath=args.synapse_config)
      syn.login()

      sub = syn.getSubmission(args.submissionid)
      participantid = sub.get("teamId")
      if participantid is not None:
        name = syn.getTeam(participantid)['name']
      else:
        participantid = sub.userId
        name = syn.getUserProfile(participantid)['userName']
      evaluation = syn.getEvaluation(sub.evaluationId)
      with open(args.results) as json_data:
        annots = json.load(json_data)
      subject = f"Submission to '{evaluation.name}' "
      message = [f"Hello {name},\n\n"]
      if annots.get("mlcube"):
          subject += "accepted!"
          message.append(
            "<b>Your MLCube has been accepted.</b> "
            "Starting Aug. 22nd, the Challenge Organizers will begin running "
            "submitted MLCubes against the unseen testing data - results will "
            "be announced at a later time.\n\n"
            "Thank you for participating in this year's BraTS 2023 Challenge!\n\n"
          )
      else:
        subject += "invalid"
        message.append(
          "<b>Your MLCube tarball is invalid.</b> "
          "Double-check that the submitted tarball has at least a "
          "`mlcube.yaml` file and please try again.\n\n"
        )
      message.append(
        "Sincerely,\n"
        "BraTS 2023 Organizers"
      )
      syn.sendMessage(
          userIds=[participantid],
          messageSubject=subject,
          messageBody="".join(message))

inputs:
- id: submissionid
  type: int
- id: synapse_config
  type: File
- id: results
  type: File

outputs:
- id: finished
  type: boolean
  outputBinding:
    outputEval: $( true )

baseCommand: python3
arguments:
- valueFrom: email_results.py
- prefix: -s
  valueFrom: $(inputs.submissionid)
- prefix: -c
  valueFrom: $(inputs.synapse_config.path)
- prefix: -r
  valueFrom: $(inputs.results)

hints:
  DockerRequirement:
    dockerPull: sagebionetworks/synapsepythonclient:v2.7.2

s:author:
- class: s:Person
  s:identifier: https://orcid.org/0000-0002-5622-7998
  s:email: verena.chung@sagebase.org
  s:name: Verena Chung

s:codeRepository: https://github.com/Sage-Bionetworks-Challenges/brats2023
s:license: https://spdx.org/licenses/Apache-2.0

$namespaces:
  s: https://schema.org/