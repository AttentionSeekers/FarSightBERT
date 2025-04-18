
= Introduction
//A clear, high-level description of what the original
// paper is about and what is its contribution to the wider
// research space. Cite the original paper.

The FarSight paper @farsight-orig addresses the problem of predicting diseases using unstructured clinical notes. The premise of that paper was that while most models use electronic health records (EHR) data to model on, valuable information exists in unstructured clinical notes. The authors Gangavarapu et al develop a long-term aggregation mechanism to capture onset of diseases from earliest recorded systems.

\
The core contributions of the FarSight were:
- Novel aggregation mechanism to identify earliest signs of disease.
- The fact that unstructured nursing notes can be a valuable data source.

\
We try to extend these contributions by ??? /*TODO: add plug here.*/

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