
# Google Cloud Project Setup Guide for Datathons

This guide is designed to help structured data users (e.g. healthcare datathon
organizers and participants, structured data analysis course instructors and
students) to set up a set of Google Cloud Projects, in order to host the
structured datasets and data analysis environment in a compliant and audited
way. More specifically, it explains how to create:

1.  A data hosting project, where structured data is hosted both in its raw
    format in a Google Cloud Storage bucket, and as BigQuery tables ready for
    controlled data access.

The project setup is based on the Google Cloud Healthcare Deployment Manager
Templates. Please see its [documentation](../deploy/README.md) for more background information.


## Setup steps 

### STEP 1:  Working in Cloud Shell
You can perform all the setup through Cloud Shell in Google Cloud Platform.  Lets first create a dummy project  to work in a Cloud Shell. For a first-time Google Cloud user, you need to accept the Terms of Service on
[Cloud Console](https://console.cloud.google.com) to proceed.



* Go to [GCP](console.cloud.google.com/) and create a dummy project(This step can be omitted if you already have a project set before)
	picture
* Switch to the project created
	picture
* Crick the icon below to open  a Cloud Shell.
	picture
*  lets verify that gcloud and bq commands are executable by running the commands  below. 
```shell
	gcloud init
	## Reinitialize configuration, press [1]
	## Go for the current account, press [1]
	## Go for the project you just created 
	## Don't set default compute region, press [n]
```
		gsutil ls
		bq ls

###  STEP2: Clone Datathon repository and install requirements
* Let's download scripts and dummy dataset which we will be uploading to Bigquery.
```shell
	git clone https://github.com/nus-mornin-lab/datathon
```
* Install&update required dependancies
```shell
	cd datathon/organizer/deploy
	pip3 install -r requirements.txt
	cd ..
```
###  STEP3: Modification of "upload_data.sh" script
* Now we will be uploading a demo dataset. the file is 

