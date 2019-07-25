# Google Cloud Project Setup Guide for Datathons

This guide is designed to help structured data users (e.g. healthcare datathon
organizers and participants, structured data analysis course instructors and
students) to set up a set of Google Cloud Projects, in order to host the
structured datasets and data analysis environment in a compliant and audited
way. More specifically, it explains how to create:

*  A data hosting project, where structured data is hosted both in its raw
    format in a Google Cloud Storage bucket, and as BigQuery tables ready for
    controlled data access.

The project setup is based on the Google Cloud Healthcare Deployment Manager
Templates. Please see its [documentation](../deploy/README.md) for more background information.


## Setup steps 

Before going into the set-up steps be reminded you can also replicate the same step with the friendly UI from [Google Cloud](https://cloud.google.com/gcp). The detailed steps for Google Cloud UI is [here](https://hevodata.com/blog/postgresql-to-bigquery-data-migration/). One disadvantage of using Google Cloud UI however would be that you have to upload your tables one by one, which could be time consuming for a big dataset.

### STEP 1:  Create Data-project and Googlegroups 
You can perform all the setup through Cloud Shell in Google Cloud Platform.  Lets first create a dummy project  to work in a Cloud Shell. For a first-time Google Cloud user, you need to accept the Terms of Service on
[Cloud Console](https://console.cloud.google.com) to proceed.

* Create a googlegroups account from [google group](https://groups.google.com/forum/#!overview).

* Go to [GCP](console.cloud.google.com/) and create a data hosting project.
* Switch to the project created
* Crick the  icon that looks like below to open  a Cloud Shell.
image
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
 Lets modify the **upload_data.sh** file

* go to  **data-hosting-project-only-setup** and open **upload_data.sh**
 ```shell
	cd ~/korea-datathon/organizer/datathon/data-hosting-project-only-setup/scripts
	vim upload_data.sh 
```

* You will need to change the following variables in the file
* `OWNERS_GROUP`: the googlegroups email we have created at STEP1.
* `PROJECT_ID`: the name of the data hosting project which we have create at STEP3.
* `DATASET_NAME`: name of your dataset(can be whatever you want).   
* `INPUT_DIR`: directory where It holds your .csv files(actual data). 
* `SCHEMA_DIR`:  directory where It holds your .csv.schema files(actual data) .

```
-- for example
 
OWNERS_GROUP="data-owners@googlegroups.com"
PROJECT_ID="kor-data"
DATASET_NAME="demo"
INPUT_DIR="../dataset/data"
SCHEMA_DIR="../dataset/schmas"
```
* It is your role to prepare your tables in `.csv`(comma separated)  and schemas in `.csv.schema`(optional).
* You will be able to see the schema which I created for the demo data at `../dataset/schmas`.

###  STEP4:  Run the script
* Run the following codes. If you get an error,  just re-run `./upload_data.sh`. It will start from the point where it got failed.
```shell
chmod 777 upload_data.sh
./upload_data.sh
```

Once everything is done successfully, you will be able to see your tables uploaded in your project's Bigquery. 


