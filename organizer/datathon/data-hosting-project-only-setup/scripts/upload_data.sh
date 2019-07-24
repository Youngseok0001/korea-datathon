#!/bin/bash

# Copyright 2018 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script uploads data to Google Cloud Storage and BigQuery.
# The script expects data to be compressed csv files in *.csv.gz format, and it
# will try to process all file with that format in the given input directory.

set -u -e
OWNERS_GROUP="youngseokjeon74@gmail.com"
PROJECT_ID="My Project 62469"
DATASET_NAME="demo"
INPUT_DIR="../dataset/data"
SCHEMA_DIR="../dataset/schmas"
LOCATION=asia-northeast1

# Lowercase is required for bucket name, and BigQuery dataset ID can't contain
# dash.
DATASET_NAME=`echo ${DATASET_NAME} | awk '{ print tolower($0) }' \
  | sed -e 's/-/_/g'`
BUCKET_ID=${PROJECT_ID}-${DATASET_NAME}
DATASET_ID=${DATASET_NAME}

# A list of state checkpoints for the script to resume to.
STATE_ENABLE_SERVICES="ENABLE_SERVICES"
STATE_CREATE_BQ="CREATE_BQ"
STATE_UPLOAD_GCS="UPLOAD_GCS"
STATE_UPLOAD_BQ="UPLOAD_BQ"

if [[ ! -e ${STATE_FILE} ]]; then
  echo "Creating the Google Cloud Storage bucket to host data."
  STORAGE_CLASS=regional
  gsutil mb -p ${PROJECT_ID} -c ${STORAGE_CLASS} -l ${LOCATION} gs://${BUCKET_ID}
  gsutil requesterpays set on gs://${BUCKET_ID}

  echo "Setting Google Cloud Storage bucket access."
  TEMP=`tempfile`
  cat <<EOF >>${TEMP}
{
  "bindings": [
    {
      "members": [
        "group:${OWNERS_GROUP?}"
      ],
      "role": "roles/storage.admin"
    }
  ]
}
EOF
  echo ${STATE_ENABLE_SERVICES} > ${STATE_FILE}
else
  echo "Skip creating bucket since it has previously finished."
fi

if [[ `cat ${STATE_FILE}` == ${STATE_ENABLE_SERVICES} ]]; then
  echo "Enabling the following Google Cloud Platform services"
  echo "  - Deployment Manager"
  echo "  - BigQuery"
  gcloud services enable deploymentmanager bigquery --project ${PROJECT_ID}

  echo ${STATE_CREATE_BQ} > ${STATE_FILE}
else
  echo "Skip enabling services since it has previously finished."
fi

if [[ `cat ${STATE_FILE}` == ${STATE_CREATE_BQ} ]]; then
  echo "Creating the BigQuery to host tables."
  TEMP=`tempfile`
  cat <<EOF >>${TEMP}
resources:
- name: big-query-dataset
  type: bigquery.v2.dataset
  properties:
    datasetReference:
      datasetId: "${DATASET_ID?}"
    access:
      - role: 'OWNER'
        groupByEmail: "${OWNERS_GROUP?}"
    location: "${LOCATION?}"
EOF
  gcloud deployment-manager deployments create create-bq-dataset \
    --config=${TEMP} --project ${PROJECT_ID}
  # Delete the deployment job since it's finished. The created dataset is not
  # affected.
  gcloud --quiet deployment-manager deployments delete create-bq-dataset \
    --project ${PROJECT_ID} --delete-policy=ABANDON
  echo ${STATE_UPLOAD_GCS} > ${STATE_FILE}
else
  echo "Skip creating BigQuery dataset since it has previously finished."
fi

if [[ `cat ${STATE_FILE}` == ${STATE_UPLOAD_GCS} ]]; then
  echo "Uploading data to Google Cloud Storage."
  gsutil -u ${PROJECT_ID} -m cp ${INPUT_DIR}/*.csv gs://${BUCKET_ID}
  echo ${STATE_UPLOAD_BQ} > ${STATE_FILE}
else
  echo "Skip uploading data to GCS since it has previously finished."
fi

GOEXEC=`which go`
BQ_SCHEMA_DETECTOR_PATH=`dirname "$0"`/../src/bq/bq_schema_detector.go

generate_schema() {
  local file=$1
  # Decompress the file to detect schema.
  local csv_file=${file}
  local schema_file=${file}.schema
  # Run Go program to detect the schema.
  ${GOEXEC} run ${BQ_SCHEMA_DETECTOR_PATH} -input_csv=${csv_file} \
    -output_file=${schema_file}
  # Remove the decompressed file.
  rm ${csv_file}
  # Return the schema file.
  echo ${schema_file}
}

if [[ `cat ${STATE_FILE}` == ${STATE_UPLOAD_BQ} ]]; then
  job_ids=()
  echo "Loading data from Google Cloud Storage to BigQuery."
  for file in ${INPUT_DIR}/*.csv.gz; do
    echo "Loading data file `basename ${file}` to BigQuery."
    # Assume the schema file ends with .csv.gz.schema suffix.
    schema_file=${SCHEMA_DIR}/$(basename ${file}).schema
    delete_schema_file=false
    if [[ ! -e ${schema_file} ]]; then
      # Generate the schema file if it does not already exist.
      echo "Generating schema for ${file}."
      schema_file=`generate_schema ${file}`
      delete_schema_file=true
    fi

    # Upload data to BigQuery.
    table_name=`echo $(basename ${file:0:(-3)}) | awk '{ print tolower($0) }'`

    # Asynchronously load data to BigQuery.
    job_id=${table_name}_$(date +%s)
    bq --nosync --location=${LOCATION} --project_id=${PROJECT_ID} \
      load --job_id=${job_id} --skip_leading_rows=1 --source_format=CSV \
      --replace --allow_quoted_newline "${DATASET_ID}.${table_name}" \
      gs://${BUCKET_ID}/$(basename ${file}) ${schema_file}
    job_ids+=(${job_id})

    # Remove the schema file if it's generated by this script.
    if [[ ${delete_schema_file} = true ]]; then
      rm ${schema_file}
    fi
  done

  echo "All BigQuery loading jobs have been submitted."
  echo "Waiting for jobs to finish."
  for job_id in ${job_ids[*]}; do
    # The wait command will print out real-time status of the job.
    bq wait --project_id=${PROJECT_ID} ${job_id}
  done
else
  echo "Skip uploading data to BigQuery since it has previously finished."
fi

rm -f ${STATE_FILE}

echo "Data upload for ${DATASET_NAME} has finished."
