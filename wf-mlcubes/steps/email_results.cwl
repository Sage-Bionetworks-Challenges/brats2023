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
      parser.add_argument("-d", "--docker_id", help="submission ID for MLCube Docker")

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

      subject = f"Submission to '{evaluation.name}' "
      message = [f"Hello {name},\n\n"]
      print(args.docker_id)
      if args.docker_id == 'INVALID':
        subject += "invalid"
        message.append(
          f"<b>Your MLCube submission (ID {args.submissionid}) is invalid.</b> "
          "We could not find a Docker image associated with your MLCube "
          "config tarball. Please try again, and remember to use the "
          "<u>same submission name</u> for your MLCube tarball and MLCube "
          "Docker image.\n\n"
        )
      else:
        subject += "accepted"
        message.append(
          "Thank you for participating in the BraTS-GoAT 2024 Challenge!\n\n"
          f"<b>Your MLCube submission (ID: {args.submissionid}) has been accepted!</b> 🎉 "
          "Starting next week, we will begin running the submitted MLCubes against "
          "the unseen testing data. Results will be announced at a later time.\n\n"
          "Please note that <b>we did NOT run a compatibility test of your "
          "MLCube</b>, so your submission may be at risk to failing next week. "
          "If you haven't yet, we highly encourage you to "
          "<a href='https://www.synapse.org/#!Synapse:syn52939291/wiki/626233'>"
          "locally test your MLCube's compatibility</a> against the sample "
          "benchmarks to catch possible errors. You may submit again if needed.\n\n"
        )
      message.append(
        "Sincerely,\n"
        "BraTS Organizing Committee"
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
- id: status
  type: string

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
- prefix: -d
  valueFrom: $(inputs.status)

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