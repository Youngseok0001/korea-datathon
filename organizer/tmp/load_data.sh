#ENV VAR
FRACTURE_BUCKET="datathon-siimacr"
ISIC_BUCKET="datathon-isic"

DATA_PROJECT="singapore-datathon-data"
TEAM_GROUP="nus-datathon-participants"
STORAGE_CLASS="regional"
LOCATION="ASIA-SOUTHEAST1"

#DELETE 
gsutil rm gs://${FRACTURE_BUCKET}
gsutil rm gs://${ISIC_BUCKET}

#CREATE BUCKET
gsutil mb -p ${DATA_PROJECT} -c ${STORAGE_CLASS} -l ${LOCATION} gs://${ISIC_BUCKET}
gsutil mb -p ${DATA_PROJECT} -c ${STORAGE_CLASS} -l ${LOCATION} gs://${FRACTURE_BUCKET}

#LOAD DATASET 
gsutil -o "GSUtil:parallel_process_count=16" -o "GSUtil:parallel_thread_count=1" -m cp -r * gs://${ISIC_BUCKET}
gsutil -o "GSUtil:parallel_process_count=16" -o "GSUtil:parallel_thread_count=1" -m cp -r * gs://${FRACTURE_BUCKET}

#MAKE BUCKET TO BE AVAILABLE TO ALL
gsutil iam ch group:${TEAM_GROUP}@googlegroups.com:objectViewer gs://${ISIC_BUCKET}
gsutil iam ch group:${TEAM_GROUP}@googlegroups.com:legacyBucketReader gs://${FRACTURE_BUCKET}

