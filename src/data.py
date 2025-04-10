#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-03-31 10:10:50 Monday

@author: Nikhil Kapila
"""

import pandas as pd
import nltk
import os

# step 1
def load_mimic3(files:list, path:str)->dict:
    # tables:
        # noteevents, 
        # admissions, 
        # patients
        # diagnoses_icd
    out = {}
    paths = [os.path.join(path,f) for f in files]

    for name,p in zip(files, paths):
        print(f'Loading from {p}..')
        df = pd.read_csv(p)
        print(f'{name} loaded')
        out[name] = df
        del df

    return out

#step 2.1
def cohort_selection(dfdict:dict)->tuple:
    # 2 stages
    
    # stage 1:
    # For instance, a patient p (born on TDoB), 
    # admitted to the hospital (with an admission number Ihadm) 
    # at time Tadm, with age Tadm−TDoB (must be > 15)
    # tl;dr: age > 15

    # patient.csv columns
    # ['ROW_ID', 'SUBJECT_ID', 'GENDER', 'DOB', 'DOD', 'DOD_HOSP', 'DOD_SSN',
    #    'EXPIRE_FLAG']

    # admission.csv columns
    # ['ROW_ID', 'SUBJECT_ID', 'HADM_ID', 'ADMITTIME', 'DISCHTIME',
    #    'DEATHTIME', 'ADMISSION_TYPE', 'ADMISSION_LOCATION',
    #    'DISCHARGE_LOCATION', 'INSURANCE', 'LANGUAGE', 'RELIGION',
    #    'MARITAL_STATUS', 'ETHNICITY', 'EDREGTIME', 'EDOUTTIME', 'DIAGNOSIS',
    #    'HOSPITAL_EXPIRE_FLAG', 'HAS_CHARTEVENTS_DATA']

    # selecting 
    pat_adm_df = dfdict['PATIENTS.csv'][['SUBJECT_ID', 'DOB']]\
        .merge(dfdict['ADMISSIONS.csv'][['SUBJECT_ID', 'ADMITTIME']], on='SUBJECT_ID')

    pat_adm_df['ADMITTIME'] = pd.to_datetime(pat_adm_df['ADMITTIME']).dt.date
    pat_adm_df['DOB'] = pd.to_datetime(pat_adm_df['DOB']).dt.date

    # getting age
    pat_adm_df['age'] = ((pat_adm_df['ADMITTIME'] - pat_adm_df['DOB'])/365).dt.days # age in int

    # subject_ids whose age>15
    age15subid = pat_adm_df[pat_adm_df['age']>=15]['SUBJECT_ID'].unique()

    age15subid = pd.DataFrame(age15subid, columns=['SUBJECT_ID'])

    # stage 2
    # "Furthermore, to maintain consistency in 
    # benchmarking with respect to the related works, 
    # and to avoid possible information loss during 
    # analysis, only the first admission to the ICU 
    # for each MIMIC-III subject was considered, 
    # and all the later admissions were discarded."

    adms = dfdict['ADMISSIONS.csv']
    adms = adms.sort_values(['SUBJECT_ID', 'HADM_ID']).\
        drop_duplicates('SUBJECT_ID')[['SUBJECT_ID', 'HADM_ID']]

    return age15subid, adms

# step 2.2
def get_nursing_notes(path:str='data/', category:str='Nursing')->pd.DataFrame:
    file = 'NOTEEVENTS.csv'
    notes = pd.read_csv(os.path.join(path,file),low_memory=False)

    # columns:
    # ['ROW_ID', 'SUBJECT_ID', 'HADM_ID', 'CHARTDATE', 'CHARTTIME', 
    # 'STORETIME', 'CATEGORY', 'DESCRIPTION', 'CGID', 
    # 'ISERROR', 'TEXT']
    
    # Nursing/other        822497
    # Radiology            522279
    # Nursing              223556
    # ECG                  209051
    # Physician            141624
    # Discharge summary     59652
    # Echo                  45794
    # Respiratory           31739
    # Nutrition              9418
    # General                8301
    # Rehab Services         5431
    # Social Work            2670
    # Case Management         967
    # Pharmacy                103
    # Consult                  98

    # Only selecting Nursing since the paper says:
    # "The MIMIC-III (v1.4) database contains 223,556
    # nursing notes among 2,083,180 note events
    # corresponding to 7,704 distinct patients."

    # returning only # Nursing-->223556
    return notes[notes['CATEGORY']==category]

# step 2.3: 2.1+2.2
def make_raw_data(age15subid:pd.DataFrame, adms:pd.DataFrame, notes:pd.DataFrame)->pd.DataFrame:
    
    # step 2.1: age>15
    notes = notes[notes['SUBJECT_ID'].isin(age15subid['SUBJECT_ID'])]

    # step 2.2: only first adms
    notes = pd.merge(notes, adms, on=['SUBJECT_ID', 'HADM_ID'], how='inner')

    return notes

# step 3
def filter_nursing_notes(notes:pd.DataFrame)->pd.DataFrame:
    # remove note with iserror and duplicate
    # "Several erroneous entries exist 
    # in the data extracted from MIMIC-III due to various factors such as missing values, 
    # noise, incorrect or duplicate entries, 
    # outliers, and clerical errors. 
    # First, we identified and filtered out the nursing notes with clerical errors and
    # erroneous entries using the iserror attribute of the noteevents table."

    notes = notes[notes['ISERROR'].isna()]
    notes = notes.drop_duplicates(subset=['SUBJECT_ID', 'TEXT'], keep='first')
       
    return notes


# # step 4
# def preprocess()->?:
#     # tokenize
#     from nltk.tokenize import word_tokenize
#     tokens = word_tokenize()
#     # remove stopwords
#     # stem
#     # lemmatize

#     return #TODO

# # step 5
# def farsight_aggregation()->?:
#     # each note is assigned all diagnostic codes from future notes 
#     # attaching the full label set to each note for multi-label prediction.

#     return #TODO

# # step 6
# def feat_extration()->?:
#     # doc2vec --> Gensim (NLP hw4 :))
#     # nmf for topic modeling

#     return #TODO