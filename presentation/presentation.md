---
marp: true
theme: default
paginate: true
---

# FarSight: Long-Term Disease Prediction Using Unstructured Clinical Nursing Notes

_An overview of the original FarSight paper and how subsequent work extended its contributions._

**Members**:
Team No 13, Team ID C3.
- Nikhil Kapila
- Tejas Rathi

---

# What Did FarSight Do?

**Primary Focus:**  
Unstructured **nursing notes** for predicting ICD-9 diagnostic codes.

- Recognized rich, patient-specific info often ignored in modeling.
- Emphasized early-stage detection from clinical observations.

## Techniques Used by FarSight

- Static embeddings extacted through Doc2Vec and variants of NMF-BoWs.

---

# Our Extensions Beyond FarSight

### Transformer-Based Embeddings

- Shift to **contextual models** like **BioClinicalBERT**
- Captured more **nuanced semantics** from the text

### MoE (Mixture of Experts) Models

- Tackled **data heterogeneity** through domain-specific specialization, enabling tailored processing and integration of diverse data sources.

- Aimed to improve **performance** and **interpretability**

---

# Results & Model Performance

### NMF-TW with SC's Resilience
- Semantic Coherence helped capture **conceptual relationships**
- **NMF-TW with SC:** Continued strong results (esp. with 100 topics)

### BioClinicalBERT’s Contribution
- **BioClinicalBERT:** Promising contextual performance
- Captured **context & long-range dependencies**
- Improved over simpler embedding methods
- Shows possibility of transfer learning in ICD9 prediction tasks.

---

# Mixture of Experts (MoE) Models

- **MoE Models:** Best for nuanced understanding tasks
- **Heterogeneity:** Experts specialize in data types

---

# Thank You!
