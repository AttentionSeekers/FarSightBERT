#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-04-01 12:25:06 Tuesday

@author: Nikhil Kapila
"""

import os, sys
import argparse
import data as step

parser = argparse.ArgumentParser()
parser.add_argument('--name')
args = parser.parse_args()
# print(args)

if args.name == None:
    print('No argument passed! Skipping execution.')

    print('\nPlease select an argument.\nAvailable arguments:\n1. `make_data` : Raw data preparation\n2. `aggregate`: Farsight aggregation')

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

if args.name == 'aggregate':
    mimic3_path = 'data/'

    if os.path.exists(os.path.join(mimic3_path, 'raw_notes.csv')):
        notes = pd.read_csv(f'{os.path.join(mimic3_path, "raw_notes.csv")}')
    else:
        print('Data not found, first prepare data using `make_data`!')
        sys.exit(1)

    
    print('Under construction')

