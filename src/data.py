#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-03-31 10:10:50 Monday

@author: Nikhil Kapila
"""

# using pyhealth
from pyhealth.datasets import MIMIC3Dataset

# step 1
def load_mimic3()->?:
    # tables:
        # noteevents, 
        # admissions, 
        # patients
        # diagnoses_icd
        
    return #TODO

#step 2
def cohort_selection()->?:
    # For instance, a patient p (born on TDoB), 
    # admitted to the hospital (with an admission number Ihadm) 
    # at time Tadm, with age Tadm−TDoB (must be > 15)
    # tl;dr: age > 15

    
    return #TODO

# step 3
def clean_nursing_notes()->?:
    # remove note with iserror or empty text
    
    return # TODO

# step 4
def preprocess()->?:
    # tokenize
    # remove stopwords
    # stem
    # lemmatize

    return #TODO

# step 5
def farsight_aggregation()->?:
    # each note is assigned all diagnostic codes from future notes 
    # attaching the full label set to each note for multi-label prediction.

    return #TODO

# step 6
def feat_extration()->?:
    # doc2vec --> Gensim (NLP hw4 :))
    # nmf for topic modeling

    return #TODO