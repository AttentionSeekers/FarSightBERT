#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 2025-03-31 10:10:50 Monday

@author: Nikhil Kapila
"""

import os
from typing import Optional
import re
import pandas as pd
import numpy as np

# from transformers.models.bert import BertTokenizerFast, BertModel
import nltk

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

# step 4.1 preprocess and clean
def preprocess_and_clean_text(text:str)->list:
    from nltk.corpus import stopwords
    from nltk.tokenize import word_tokenize
    from nltk.stem import PorterStemmer, WordNetLemmatizer

    # all comments contain direct quotes from the paper
    
    # "References to images (e.g., MRI_Scan.jpeg) were removed, and
    # character case folding was performed."
    text = text.lower()

    # "We employed the NLTK tokenizer to facilitate the tokenization of nursing text."
    tokens = word_tokenize(text)

    # "Utilizing the NLTK English stopword corpus, we removed
    # stopwords from the generated tokens."
    stopwords = set(stopwords.words('english'))
    tokens = [token for token in tokens if token not in stopwords]

    # First, we removed multiple spaces and special characters."
    tokens = [token for token in tokens if token.isalnum()]
    
    # forgot image references!
    # "References to images (e.g., MRI_Scan.jpeg) were removed, and
    # character case folding was performed." 
    tokens = [token for token in tokens if not token.endswith(('.jpeg', '.jpg', '.png', '.gif'))]

    # "Before any further processing, medical concept normalization
    # through disambiguation of abbreviations (into their respective
    # long forms) was facilitated using CARD, an open-source framework
    # for clinical abbreviation recognition and disambiguation."

    # CARD-2 framework no longer available
    # https://sbmi.uth.edu/ccb/resources/abbreviation.htm
    # need to find an alternative or just skip this
    # TODO

    # "Lastly, suffix stripping was performed through stemming,
    # followed by lemmatization for the conversion of the stripped
    # tokens into their respective base forms."
    stemmer = PorterStemmer()
    lemmatizer = WordNetLemmatizer()
    processed_tokens = []
    for token in tokens:
        stemmed = stemmer.stem(token)
        lemmatized = lemmatizer.lemmatize(stemmed)
        processed_tokens.append(lemmatized)

    return processed_tokens

# step 4.2
def remove_rare(df:pd.DataFrame)->pd.DataFrame:
    # "Additionally, we eliminated the tokens appearing in less than
    # ten nursing notes (e.g., spot, cope, and inch) in order to
    # lower the computational complexity of training (the total
    # number of tokens pre- and post-elimination were 188,742 and 32
    # 687 respectively) and mitigate problems arising due to
    # overfitting."

    words = []
    for t in df['PTEXT']:
        words.extend(t)
        
    counts = pd.Series(words).value_counts()
    allowed = set(counts[counts>=10].index)

    # # UDF
    # def filter(tlist:list)->list:
    #     return [t for t in tlist if t not in rare]

    df['FTEXT'] = df['PTEXT'].apply(lambda tokens: 
        [t for t in tokens if t in allowed])

    return df

# step 5 --> target labels
# UDF for .apply
def make_target(icd:str)->Optional[int]:
    # The ICD-9 codes of a given admission from MIMIC-III are mapped into 19
    # distinct diagnostic groups9. The ICD-9 code range of 760−779

    # original link does not work, using web archive
    # https://web.archive.org/web/20160308161055/http://tdrdata.com/ipd/ipd_SearchForICD9CodesAndDescriptions.aspx
    # Diagnoses
    # 001 - 139 	Infectious and Parasitic Diseases
    # 140 - 239 	Neoplasms
    # 240 - 279 	Endocrine, Nutritional, Metabolic, Immunity
    # 280 - 289 	Blood and Blood-Forming Organs
    # 290 - 319 	Mental Disorders
    # 320 - 389 	Nervous System and Sense Organs
    # 390 - 459 	Circulatory System
    # 460 - 519 	Respiratory System
    # 520 - 579 	Digestive System
    # 580 - 629 	Genitourinary System
    # 630 - 677 	Pregnancy, Childbirth, and the Puerperium
    # 680 - 709 	Skin and Subcutaneous Tissue
    # 710 - 739 	Musculoskeletal System and Connective Tissue
    # 740 - 759 	Congenital Anomalies
    # 760 - 779 	Conditions Originating in the Perinatal Period
    # 780 - 789 	Symptoms
    # 790 - 796 	Nonspecific Abnormal Findings
    # 797 - 799 	Ill-defined and Unknown Causes of Morbidity and Mortality
    # 800 - 999 	Injury and Poisoning
    # V Codes 	Supplemental V-Codes
    # Ref Codes 	Reference Codes 

    # and is usually assigned to neonates (age < 15), who are excluded
    # from this study as per the defined patient cohort (see Section 3.1).
    # Hence, our dataset does not contain any records in the ICD-9
    # code range of 760−779.
    # REMOVING 760-779

    # Furthermore, our study classifies all the
    # Reference (Ref) and supplemental V-codes into the same code
    # group, to lower the computational complexity of training.
    # V and E are SAME code group!

    diagnosis_categories = {
    1: (1, 139, "Infectious and Parasitic Diseases"),
    2: (140, 239, "Neoplasms"),
    3: (240, 279, "Endocrine, Nutritional, Metabolic, Immunity"),
    4: (280, 289, "Blood and Blood-Forming Organs"),
    5: (290, 319, "Mental Disorders"),
    6: (320, 389, "Nervous System and Sense Organs"),
    7: (390, 459, "Circulatory System"),
    8: (460, 519, "Respiratory System"),
    9: (520, 579, "Digestive System"),
    10: (580, 629, "Genitourinary System"),
    11: (630, 677, "Pregnancy, Childbirth, and the Puerperium"),
    12: (680, 709, "Skin and Subcutaneous Tissue"),
    13: (710, 739, "Musculoskeletal System and Connective Tissue"),
    14: (740, 759, "Congenital Anomalies"),
    # 15: (760, 779, "Conditions Originating in the Perinatal Period"),
    15: (780, 789, "Symptoms"),
    16: (790, 796, "Nonspecific Abnormal Findings"),
    17: (797, 799, "Ill-defined and Unknown Causes of Morbidity and Mortality"),
    18: (800, 999, "Injury and Poisoning"),
    # 19 and 20 grouped into 19
    # 19: ('V', 'V', "Supplemental V-Codes"),
    # 20: ('E', 'E', "External Causes / Reference Codes")
    }

    icd = str(icd).strip()
    if icd == 'nan':
        return None
    if icd.startswith('V') or icd.startswith('E'):
        return 19

    code = int(icd[0:3])
    
    for label, (i, j, desc) in diagnosis_categories.items():
        if i<=code<=j:
            return label
    return None

# step 6
def create_multiclass_target(df: pd.DataFrame)->pd.DataFrame:
    # "Furthermore, to maintain consistency in 
    # benchmarking with respect to the related works, 
    # and to avoid possible information loss during 
    # analysis, only the first admission to the ICU 
    # for each MIMIC-III subject was considered, 
    # and all the later admissions were discarded."

    result_df = []
    # Process each patient (SUBJECT_ID) group
    for subject_id, group in df.groupby('SUBJECT_ID'):
        # sorting
        hadm_ids = sorted(group['HADM_ID'].unique())
        
        # first admission ID
        hadmid = hadm_ids[0]
        
        # diagnostic groups for the first admission only
        diags = group[group['HADM_ID'] == hadmid]['TARGET'].unique().tolist()
        
        result_df.append({
            'SUBJECT_ID': subject_id,
            # 'FIRST_HADM_ID': hadmid,
            'TARGETS': diags
        })
        
    return pd.DataFrame(result_df)


# step 7
def get_bert_embeddings(sentences:list)->np.ndarray:
    from sentence_transformers import SentenceTransformer, models
    import torch

    word_embedding_model = models.Transformer(
        'emilyalsentzer/Bio_ClinicalBERT',
        max_seq_length=512,
        model_args={"torch_dtype": torch.float32} 
    )

    pooling_model = models.Pooling(
        word_embedding_model.get_word_embedding_dimension(),
        pooling_mode_cls_token=True,
        pooling_mode_mean_tokens=False,
        pooling_mode_max_tokens=False
    )

    # hardcoding mps
    model = SentenceTransformer(modules=[word_embedding_model, pooling_model], device='mps')
    embeddings = model.encode(sentences, batch_size=16, show_progress_bar=True)

    return embeddings

# switching from HUGGINGFACE TRANSFORMERS to SENTENCE-TRANSFORMERS
# https://sbert.net/index.html
# # step 7
# def get_bert_embeddings(tokenizer:BertTokenizerFast,
#                         model:BertModel,
#                         tokens: list, max_length:int=512, 
#                         device=None)->np.ndarray:
#     # WE USE BERT instead of training our own doc2vec
#     # https://huggingface.co/emilyalsentzer/Bio_ClinicalBERT
#     # https://arxiv.org/pdf/1904.03323
    
#     # OMITTED:
#     #  doc2vec --> Gensim (NLP hw4 :))
#     #  nmf for topic modeling
        
#     if device is None:
#         device = 'mps' if torch.backends.mps.is_available() else 'cpu'
#     model = model.to(device)
#     model.eval()
    
#     text = ' '.join(tokens)
#     inp = tokenizer(text, return_tensors="pt",
#                         max_length=512,
#                         # padding=True,
#                         truncation=True)

#     inp = {k: v.to(device) for k,v in inp.items()}

#     with torch.no_grad():
#         o = model(**inp)

#     embedding = o.last_hidden_state[:, 0, :].cpu().numpy()[0]

#     return embedding


# # step 7 : batching it for faster processing
# def get_bert_embeddings_batched(tokenizer:BertTokenizerFast,
#                                 model:BertModel,
#                                 token_list: list, 
#                                 batch_size:int=32,
#                                 max_length:int=512, 
#                                 device=None)->list:
#     embeddings = []

#     if device is None:
#         device = 'mps' if torch.backends.mps.is_available() else 'cpu'

    # model = model.to(device)
    # model.eval()
    
    # print(f'\nUsing device {device}')
    # for i in range(0, len(token_list), batch_size):
    #     batch = token_list[i:i+batch_size]
    #     texts = [' '.join(t) for t in batch]

    #     inp = tokenizer(texts, return_tensors='pt',
    #                     truncation=True, max_length=512,
    #                     padding=True)

    #     inp = {k: v.to(device) for k,v in inp.items()}

    #     with torch.no_grad():
    #         o = model(**inp)

    #     e = o.last_hidden_state[:, 0, :].cpu().numpy()[0]
    #     embeddings.extend(e)

#     return embeddings

# step 8 merge dataset
def get_final_data(diags:pd.DataFrame, text:pd.DataFrame)->pd.DataFrame:
    return pd.DataFrame()