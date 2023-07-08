#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: Send email with results

requirements:
- class: InlineJavascriptRequirement
- class: InitialWorkDirRequirement
  listing:
  - entryname: email.py
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
      if annots.get('submission_status') is None:
        raise Exception("score.cwl must return submission_status as a json key")
      status = annots['submission_status']
      if status == "SCORED":
          csv_id = annots['submission_scores']
          del annots['submission_status']
          del annots['submission_scores']
          subject = f"Submission to '{evaluation.name}' scored!"
          message = [
            f"Hello {name},\n\n",
            f"Your submission (id: {sub.id}) has been scored and below are the metric averages:\n\n",
            "\n".join([i + " : " + str(annots[i]) for i in annots]),
            "\n\n",
            f"You may look at each scan's individual scores here: https://www.synapse.org/#!Synapse:{csv_id}",
            "\n\nSincerely,\nChallenge Administrator"
          ]
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
- valueFrom: email.py
- prefix: -s
  valueFrom: $(inputs.submissionid)
- prefix: -c
  valueFrom: $(inputs.synapse_config.path)
- prefix: -r
  valueFrom: $(inputs.results)

hints:
  DockerRequirement:
    dockerPull: sagebionetworks/synapsepythonclient:v2.7.2
