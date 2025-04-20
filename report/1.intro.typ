
= Introduction
//A clear, high-level description of what the original
// paper is about and what is its contribution to the wider
// research space. Cite the original paper.

The healthcare industry generates vast amounts of clinical data ranging from structured electronic health records (EHR) to unstructured clinical narratives @ehr-data. Focus of predictive modeling on clinical data has been in the EHR landscape. Unstructured text especially nursing notes contains rich, patient-specific information, captures nuanced observations are ignored in predictive modeling tasks.

Gangavarapu et al.'s FarSight @farsight-orig aggregation approach is an advancement in modeling unstructured nursing notes for disease prediction. Their work demonstrated how nursing notes when properly cleaned and aggregated can predict ICD-9 diagnostic codes with remarkable accuracy. The key idea of their FarSight aggregation mechanism was the ability to associate early clinical observations with eventual diagnoses which enabled detection of diseases at their earliest manifestations.

As artificial intelligence in the text modality has continued to evolve, new opportunities emerge to enhance these approaches. In this study, we build upon the foundation laid out by FarSight and we can further advance use of unstructured clinical narratives for disease prediction. We investigate whether modern transformer-based language models like BioCLinicalBERT pre-trained on a vast corpora of biomedical text can offer richer semantic representations than document embedding techniques used in the original FarSight study. Furthermore, advances in neural architecture design especially mixture of expert models, present new posibilites for creating interpretable and efficient prediction systems.

Our work contributes to ongoing effort to develop more sophisticated clinical systems that can leverage full spectrum of available patient data by combining FarSight's aggregation model with cutting-edge language models and neural architectures.

= Scope of Reproducibility and Novelty
// List all hypotheses from the paper you will test and
// corresponding experiments you will run.

In this study, we reuse the original data aggregation mechanism developed in FarSight. We extend the original paper with 2 novelties that we shall explain below in detail. /*TODO: repeated from above.*/

== Bidirection Contextual embeddings (BERT)
The authors in the paper use various embedding techniques, including Doc2Vec and multiple variants of Non-negative Matrix Factorization (NMF) based on Bag-of-Words (BoW) and Term Weighting (TW), with and without Semantic Coherence (SC).

We differ in our approach by using a pre-trained BERT model, Bio_ClinicalBert @bio_clinicalbert. Bio_ClinicalBert is based on BioBERT @alsentzer-etal-2019-publicly which itself is a domain-specific version of BERT @devlin2019bert pretrained on biomedical literature such as PubMed abstracts and PMC full texts. Bio_ClinicalBert extends BioBERT by pretraining on the large unstructured notes in the MIMIC-III @johnson2016mimic dataset and is publicly available on HuggingFace @bio_clinicalbert.

BERT being an encoder-only model (which gives it bidirectional context) allows the model to build better representations of vocabulary and structure of clinical narratives making it well suitable for downstream tasks such as the one in this study. 

We hypothesize that having better embeddings using BERT will help counter many problems faced by the authors when they were experimenting with different modeling approaches. To list a few: BERT will be able to better capture semantic relationships compared to BoW and Doc2Vec, handle complex medical language and be able to leverage a strong foundation from its pre-trained knowledge.

== Mixture of Expert (MoE) models
We further extend this approach by using some of the models introduced in FarSight with a powerful extension call MoE @moe-orig. The FarSight paper identifies several challenges in dealing with clinical notes, including their longitudinal aspect, heterogeneity, voluminous content, and complex structure. The idea of using MoE is inspired to handle heterogeneity by specialization. 

Each model (expert) optimizes on it's own inductive biases and hence, we expect each model to specialize on different aspects of the data. For e.g., ConvLSTMs may be better at capturing temporal pattern in notes while ConvNet may be better at identifying specific keywords in shorter, acute-event notes.

The MoE learns to combine strengths of different neural architectures to make the best overall prediction. Furthermore, this modeling approach gives potential for interpretability as we can analyze which architecture the gating network relies on most for different type of notes. This can provide insight into which architectural biases can be most useful for different clinical scenarios.