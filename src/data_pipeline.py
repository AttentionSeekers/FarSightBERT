#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-01 12:25:06 Tuesday

@author: Nikhil Kapila
"""

import os, sys
import argparse
import pickle

import data as step
import numpy as np
import pandas as pd
import nltk
from transformers import AutoTokenizer, AutoModel

parser = argparse.ArgumentParser()
parser.add_argument('--name')
args = parser.parse_args()
# print(args)

if args.name == None:
    print('No argument passed! Skipping execution.')

    print('\nPlease select an argument.\
        \nAvailable arguments:\n1. `make_data` : Raw data preparation\
        \n2. `preprocess`: Preprocess and clean text\
        \n3. `prep_data`: Complete data preparation.\
            ')

if args.name == 'make_data': #step1-3
    print('Executing steps 1-3...')
    
    files = ['PATIENTS.csv', 'ADMISSIONS.csv', 'DIAGNOSES_ICD.csv']
    mimic3_path = 'data/'

    print('\nStep 1: Loading MIMIC data.')
    # step 1
    dfdict = step.load_mimic3(files, mimic3_path)

    print('\nStep 2.1: Cohort selection criteria.')
    # step 2.1 cohort selection: subject id and 1st admissions
    age15subids, adms = step.cohort_selection(dfdict)

    # step 2.2 getting nursing notes
    print('\nStep 2.2: Get nursing notes.')
    notes = step.get_nursing_notes() #default file name and path

    # step 2.3 merge 2.1 and 2.2 to get raw data
    print('\nStep 2.3: Get raw data using 2.1 and 2.2.')
    notes = step.make_raw_data(age15subids, adms, notes)

    # step 3
    print('\nStep 3: Filter out from 2.1-2.3 to get notes.')
    notes = step.filter_nursing_notes(notes)

    # saving notes
    print(f'\nSaving to {os.path.join(mimic3_path, "raw_notes.csv")}')
    notes.to_csv(os.path.join(mimic3_path, 'raw_notes.csv'))

if args.name == 'preprocess':
    mimic3_path = 'data/'

    if os.path.exists(os.path.join(mimic3_path, 'raw_notes.csv')):
        notes = pd.read_csv(f'{os.path.join(mimic3_path, "raw_notes.csv")}')
    else:
        print('Data not found, first prepare data using `make_data`!')
        sys.exit(1)

    print('\nStep 4.0: Downloading necessary resources.')
    # required nltk resources
    nltk.download('punkt')
    nltk.download('stopwords')
    nltk.download('wordnet')

    
    print('\nStep 4.1: Preprocessing and Cleaning Text.')
    if os.path.exists(os.path.join(mimic3_path, 'preprocess_clean_notes.pkl')):
        print('Already exists, skipping this step.')
        notes = pd.read_pickle(os.path.join(mimic3_path, 'preprocess_clean_notes.pkl'))
    else:
        notes['PTEXT'] = notes['TEXT'].apply(step.preprocess_and_clean_text)
        print(f'\nSaving to {os.path.join(mimic3_path, "preprocess_clean_notes.pkl")}')
        notes.to_pickle(os.path.join(mimic3_path, 'preprocess_clean_notes.pkl'))

    print('\nStep 4.2: Remove rare tokens (<10).')
    if os.path.exists(os.path.join(mimic3_path, 'preprocess_clean_remove_rare.pkl')):
        print('Already exists, skipping this step.')
    else:
        notes = step.remove_rare(notes)
        print(f'\nSaving to {os.path.join(mimic3_path, "preprocess_clean_remove_rare.pkl")}')
        notes.to_pickle(os.path.join(mimic3_path, 'preprocess_clean_remove_rare.pkl'))

if args.name == 'prep_data':
    mimic3_path = 'data/'

    if os.path.exists(os.path.join(mimic3_path, 'preprocess_clean_remove_rare_notes.csv')):
        notes = pd.read_csv(f'{os.path.join(mimic3_path, "preprocess_clean_remove_rare_notes.csv")}')
    else:
        print('Data not found, first clean data using `preprocess`!')
        sys.exit(1)

    files = ['PATIENTS.csv', 'ADMISSIONS.csv', 'DIAGNOSES_ICD.csv']
    mimic3_path = 'data/'

    print('\nStep 5.1: Loading MIMIC (diag) data.')
    # step 1
    dfdict = step.load_mimic3(files, mimic3_path)
    diag = dfdict['DIAGNOSES_ICD.csv']

    # step 5: adding targets
    print('\nStep 5: Adding targets to diag.')
    diag['TARGET'] = diag['ICD9_CODE'].apply(step.make_target).fillna(-1).astype(int)
    print('\nSaving pickle to data/diag_target.pkl.')
    diag.to_pickle('data/diag_target.pkl')

    # step 6: grouping targets
    print('\nStep 6: Grouping targets.')
    df = step.create_multiclass_target(diag)
    print('\nSaving pickle to data/multiclass_diag_target.pkl.')
    df.to_pickle('data/multiclass_diag_target.pkl')

    # step 7 - completed in notebook (get_embeddings.ipynb) and 
    # then ported into pipeline for reproduction
    print('\nStep 7: Converting to embeddings.')
    textdf = pd.read_pickle('data/preprocess_clean_remove_rare.pkl')

    textdf['SENT'] = textdf['FTEXT'].apply(lambda tokens: ' '.join(tokens))
    sentences = textdf['SENT'].tolist()
    embeddings = step.get_bert_embeddings(sentences)
    
    print('\nSaving np.ndarray of embeddings.')
    with open("data/embeddings.pkl", "wb") as f:
        pickle.dump(embeddings, f)

    print('\nSaving dataframe with embeddings.')
    textdf['EMBEDDING'] = list(embeddings)
    textdf.to_pickle('data/notes_with_embeddings.pkl')
    
# step 8 get final data
if args.name == 'get_final_data':
    mimic3_path = 'data/'
    
    # step 8.11
    print('\nStep 8.1: Loading data to merge.')
    if os.path.exists(os.path.join(mimic3_path, 'multiclass_diag_target.pkl')):
        diag = pd.read_pickle(f'{os.path.join(mimic3_path, "multiclass_diag_target.pkl")}')
        notes = pd.read_pickle(f'{os.path.join(mimic3_path, "notes_with_embeddings.pkl")}')
        print('Data loaded.')
    else:
        print('Data not found, first prep data using `prep_data`!')
        sys.exit(1)

    data = step.get_dataset(diag, notes)

    print('\nSaving full dataset to data/dataset_df.pkl.')
    data.to_pickle('data/dataset_df.pkl')

    X = np.stack(data['EMBEDDING'])
    y = np.stack(data['TARGETS'].apply(step.y_mhe))

    print('\nSaving X and y for dataset.')
    with open("data/X.pkl", "wb") as f:
        pickle.dump(X, f)
    
    with open("data/y.pkl", "wb") as f:
        pickle.dump(y, f)
    
    
    
