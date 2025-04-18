= Methodology

== Dataset description
// • Dataset description
// – Source of the data: where the data is collected,
// provide the link if possible; if the data is synthetic
// or self-generated, explain how.
// – Statistics: dataset size, cross validation split, label
// distribution, etc
// – How do you use the data: change the class labels,
// split the dataset to train/valid/test, refining the
// dataset
// – Please use LLMs to help in writing data
// preprocessing code
// a) What was the initial prompt that you used?
// What was the initial output of the LLM?
// Validate the LLM response. How correct,
// relevant and helpful was the LLM? How
// many prompts did you use? If the initial
// prompt did not work, what was wrong with it?

MIMIC-III v1.4 @mimic3ds is a publicly available, de-identified database comprising detailed health-related data from over 40,000 patients admitted to critical care units at the Beth Israel Deaconess Medical Center in Boston, Massachusetts, between 2001 and 2012. 
The MIMIC-III v1.4 database consists of 2,083,180 note events out of which 223,556 are nursing notes from 7,704 distinct patients. We model on these nursing notes which is a huge a corpus of 5,244,541 sentences, 79,988,065 total words and 715,821 unique words.

== Dataset Cleaning and Preprocessing
=== Cohort selection
Our cohort selection approach is same as the one illustrated in the FarSight paper. We do the following: (1) we filter out neonates (age < 15), (2) keep only first ICU admissions for each MIMIC-III subject and discard later admissions, (3) identify and filter out any nursing notes with clerical error attribute, and (4) remove duplicate patient records.

The authors do (1) to maintain consistency in benchmarking with respect to related works, (2) was done because the authors found that for 94% of patients, diagnostic code groups in first admissions overlapped with those in later ones. Furthermore, using only first admissions helps avoid statistical complications that arise from having multiple admissions from same patient, this also helps in decreasing computational requirements without significant loss of information.

=== Text preprocessing
Our text preprocessing steps differs a little bit compared to the FarSight paper. Once the cohort selection has completed, we preprocess the text data in the nursing notes. We do the following: (1) the text is split into individual tokens using NLTK tokens, (2) common stopwords are eliminated using NLTK English stopword corpus, (3) we remove any punctuation marks, (4) text is converted to lowercase, (5) stemming and lemmatization is applied, and (6) tokens appearing in fewer than 10 nursing notes are eliminated.

We differ in our approach from the original paper by not doing Medical abbreviation disambiguation. It was not possible for us to find the CARD-2 framework used in the in original implementation. Furthermore, while this could not be evaluated, we leave this load on the Bio_ClinicalBert to give contextualized embeddings that take care of this for us implicitly.

=== BERT embeddings (Clinical Feature Modeling)
// TODO: copy in stuff from section 2

=== FarSight Data Aggregation
We apply FarSight's aggregation mechanism to map each nursing note to all ICD-9 diagnostic code groups observed in that patient's admission. This enables detection of disease onset with early symptoms before any formal diagnosis.

=== ICD-9 code grouping
Mapped ICD-9 diagnostic codes into 19 distinct diagonistic groups based on code ranges defined in @tdrdata_icd9_2016. ICD-9 code range of 760-779 corresponding to neonates (age < 15) are not part of our cohort and excluded in this study. Furthermore all reference and supplemental V-codes are grouped into same code group to lower computational complexity to train.


== Model description
// – Includes a citation to the original paper
// – Includes link to the original paper’s repo (if
// applicable)
// – Model architecture: layer number/size/type,
// activation function, etc
// – Training objectives: loss function, optimizer,
// weight of each loss term, etc
// – Use LLMs to help with the implementation of the
// model used
// – Others: whether the model is pretrained, Monte
// Carlo simulation for uncertainty analysis, etc

We use many different architectures in the FarSight paper.
// TODO(@trathi9): Leaving this part for you.