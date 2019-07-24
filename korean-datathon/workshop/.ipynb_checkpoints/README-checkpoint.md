# 2019 KOREA DATATHON WORKSHOP 
![Run a query](../../images/korea-datathon-banner.png)

welcome to [2019 KOREA DATATHON WORKSHOP](http://datathon.konect.or.kr/)! Here are the materials which we will go through together for today's workshop. After the workshop you will able to 

1.  Make SQL queries with google's [Bigquery](https://cloud.google.com/bigquery/).
2. Do data analysis with the queried results using google's [Colab](https://colab.research.google.com).

*   Please be reminded that all of the queries here are made for MIMICiii dataset. For the actual upcoming Datathon, depending on the team which you would get assigned to, you would have to change the project name from `physionet-data` to `korea-datathon-data` and qeury for the right dataset and its associated tables. for example,
    
```SQL
-- cdm dataset
SELECT *
FROM `korea-datathon-data.cdm.patients` 
LIMIT 100
```
```SQL
-- cdm dataset
SELECT *
FROM `korea-datathon-data.cdm.patients` 
LIMIT 100
```

* Before going into the actual workshop, you should have all received an invitation email to [google groups]([https://groups.google.com/](https://groups.google.com/)) from your gmail account. If you have not received any of such, please let me know.  

## WORKSHOP 1: MIMIC and Bigquery(60 mins)
* For the first half of the workshop we would have a brief look the the demographics of [MIMICiii]() dataset as well as some basic queries with using google's Bigquery. MIMIC is an openly available dataset developed by the MIT Lab for Computational Physiology, comprising deidentified health data associated with ~60,000 intensive care unit admissions. It includes demographics, vital signs, laboratory tests, medications, and more. Click [here](./mimic-gcp.pdf) to proceed to the 1st part of the workshop.  


## WORKSHOP 2: Cohort selection and Modelling(60 mins)
* Now let's get started to the real thing! We will now make real queries and run some statistical models. We will go thought a step-by-step guide on how to
	1. Set cohort with exclusion criteria 
	2. Add first and secondary outcome variable 
	3. Add covariates
	4. Run statistical models to predict or find associative variables.

* We have prepared a [Python colab](http://colab.research.google.com/github/GoogleCloudPlatform/healthcare/blob/master/datathon/nusdatathon18/tutorials/bigquery_tutorial.ipynb) (a copy is available in the [tutorials](bigquery_tutorial.ipynb) folder as well) for the second part of tutorial, which is a Jupyter notebook hosted in Google Drive, and can be shared with other people for collaboration. It has the most comprehensive examples, including how to train machine learning models on the MIMIC demo dataset with [Scikit-learn](https://scikit-learn.org/stable/) and [Tensorflow](https://www.tensorflow.org/).

## TAKE AWAYS

1. Bigquery using MIMIC database 
2. Cohort extraction from MIMIC database 
3. Statistical modelling using scikit-learn and Tensorflow

For feedbacks and questions please [email](ephjys@nus.edu.sg) me :)


