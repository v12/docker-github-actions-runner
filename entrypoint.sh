#!/bin/sh

if [ ! -z "$GITHUB_ORG" ]
then
  registration_type="orgs"
  registration_location="${GITHUB_ORG}"
  echo "Registering the agent in the organization ${GITHUB_ORG}"
elif [ ! -z "$GITHUB_OWNER" ]
then
  if [ -z "$GITHUB_REPOSITORY" ]
  then
    >&2 echo "GITHUB_REPOSITORY environment variable must be set when registering an agent"
    exit 1
  fi

  registration_type="repos"
  registration_location="${GITHUB_OWNER}/${GITHUB_REPOSITORY}"
  echo "Registering the agent in the repo ${GITHUB_OWNER}/${GITHUB_REPOSITORY}"
else
  >&2 echo "Neither GITHUB_ORG nor GITHUB_OWNER environment variables were specified"
  exit 1
fi

registration_url="https://api.github.com/${registration_type}/${registration_location}/actions/runners/registration-token"
echo "Requesting registration URL at '${registration_url}'"

payload=$(curl -sX POST -H "Authorization: token ${GITHUB_PAT}" ${registration_url})
export RUNNER_TOKEN=$(echo $payload | jq .token --raw-output)

if { [ -z "${RUNNER_TOKEN}"  ] || [ "${RUNNER_TOKEN}" = "null" ]; }
then
  >&2 echo "Unable to generate agent registration token"
  error_message=$(echo $payload | jq .message --raw-output)
  [ ! -z "$error_message" ] && >&2 echo "API returned:\n\n${payload}"
  exit 1
fi

if [ -z "$RUNNER_LABELS" ]
then
RUNNER_LABELS="docker"
fi

./config.sh \
  --name $(hostname) \
  --labels ${RUNNER_LABELS} \
  --token ${RUNNER_TOKEN} \
  --url https://github.com/${registration_location} \
  --work ${RUNNER_WORKDIR} \
  --unattended \
  --replace

remove() {
  ./config.sh remove --unattended --token "${RUNNER_TOKEN}"
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

./bin/runsvc.sh "$*" &

wait $!