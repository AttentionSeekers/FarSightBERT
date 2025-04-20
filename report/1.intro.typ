
= Introduction
//A clear, high-level description of what the original
// paper is about and what is its contribution to the wider
// research space. Cite the original paper.
The healthcare industry generates vast amounts of clinical data ranging from structured electronic health records (EHR) to unstructured clinical narratives @ehr-data. Focus of predictive modeling on clinical data has been in the EHR landscape. Unstructured text especially nursing notes contains rich, patient-specific information, captures nuanced observations are ignored in predictive modeling tasks.

Gangavarapu et al.'s FarSight @farsight-orig aggregation approach is an advancement in modeling unstructured nursing notes for disease prediction. Their work demonstrated how nursing notes when properly cleaned and aggregated can predict ICD-9 diagnostic codes with remarkable accuracy. The key idea of their FarSight aggregation mechanism was the ability to associate early clinical observations with eventual diagnoses which enabled detection of diseases at their earliest manifestations.

= Scope of Reproducibility and Novelty
// List all hypotheses from the paper you will test and
// corresponding experiments you will run.
As artificial intelligence in the text modality has continued to evolve, new opportunities emerge to enhance these approaches. In this study, we build upon the foundation laid out by FarSight and we can further advance use of unstructured clinical narratives for disease prediction. We investigate whether modern transformer-based language models like BioCLinicalBERT pre-trained on a vast corpora of biomedical text can offer richer semantic representations than document embedding techniques used in the original FarSight study. Furthermore, advances in neural architecture design especially mixture of expert models, present new posibilites for creating interpretable and efficient prediction systems.

Our work contributes to ongoing effort to develop more sophisticated clinical systems that can leverage full spectrum of available patient data by combining FarSight's aggregation model with cutting-edge language models and neural architectures.

== Transformer-Based embeddings vs Corpus Specific Representations
The original FarSight paper explored several text to vector modeling approaches for clinical nursing notes, focusing on Doc2Vec and various configurations of Non-negative Matrix Factorization. Their best results came from applying NMF to Term-Weighted (TF-IDF) matrices with Semantic Coherence (SC) using 100 topics.

These approaches derive representations directly from the text itself whereas our study investigaes potential of transfer learning through pre-trained transformer encoder-only models, specifically BioCLinicalBERT @bio_clinicalbert. BioCLinicalBERT is based on BioBERT @alsentzer-etal-2019-publicly which is a domain-specific version of BERT @devlin2019bert pretrained on biomedical literature such as PubMed abstracts and PMC full texts. BioCLinicalBERT extends BioBERT by pretraining on the large unstructured notes in the MIMIC-III @johnson2016mimic dataset and is publicly available on HuggingFace @bio_clinicalbert.

Unlike the static embeddings from vector modeling in FarSight, transformer encoder only models can generate contextual embeddings where a word's representation changes based on its surrounding context. This capability allows for more nuanced understanding of medical terminology.

We hypothesize that transformer-based contextual-aware embeddings from BioCLinicalBERT will help overcome limitations observed in the original study's modeling approaches. We anticipate that these embeddings would: (1) capture more nuanced semantic relationships compared to Bag-of-Wordsa and Doc2Vec, (2) better handle complex, specialized terminology in nursing documentation and (3) leverage the knowledge acquired during pre-training on a large medical corpus.

== Mixture of Expert (MoE) models

We further extend FarSight's approach by investigating potential of Mixture of Expert (MoE) architectures that can enhance both performance and interpretability. The FarSight study identifies several challenges in dealing with clinical notes, including their longitudinal aspect, heterogeneity, voluminous content, and complex structure. The main idea behind using MoE is inspired to handle heterogeneity by specialization. 

Each model (expert) optimizes on it's own inductive biases and hence, we expect each model to specialize on different aspects of the data. For e.g., ConvLSTMs may be better at capturing temporal pattern in notes while ConvNet may be better at identifying specific keywords in shorter, acute-event notes.

The MoE learns to combine strengths of different neural architectures to make the best overall prediction. Furthermore, this modeling approach gives potential for interpretability as we can analyze which architecture the gating network relies on most for different type of notes. This can provide insight into which architectural biases can be most useful for different clinical scenarios.