// using custom implementation with repo name under authors.
#import "template/custom.typ": ieee
// page numbering
#set page(numbering:"1")

#show: ieee.with(
  title: [FarSightBERT:  Enhanced Embeddings for Long-Term Disease Prediction],
  abstract: [
    The FarSight paper by Gangavarapu et al @farsight-orig demonstrated the value of unstructured clinical notes for long-term disease prediction showcasing how rich patient-specific information is often lost in structued EHR data. Building upon their innovative FarSight aggregation technique, we explore two significant extensions to their approach: use of transformer-based embeddings and mixture of expert models.
  ],
  authors: (
    (
      name: "Nikhil Kapila",
      email: "nkapila6@gatech.edu"
    ),
    (
      name: "Tejas Rathi",
      email: "trathi9@gatech.edu"
    ),
  ),
  more-details: "yeye",
  github-repo: "https://github.gatech.edu/nkapila6/FarSightBERT",
  video-link: "https://www.youtube.com/watch?v=-NYIgPllGl8",
  data-link: "https://drive.google.com/drive/folders/1J6qucEdfXWc78Q_7gjC3Z_qM4ObGMfnE?usp=sharing",
  index-terms: ("Clinical decision support systems", "Disease prediction", "Healthcare analytics", "ICD-9 code group prediction", "Precision medicine"),
  bibliography: bibliography("bibs/refs.bib"),
  figure-supplement: [Fig.],
)

// introduction
#include "1.intro.typ"

// methodology
#include "2.metho.typ"

// training
#include "3.train.typ"

// eval
#include "4.eval.typ"

// results
#include "5.results.typ"

// discussion
#include "6.discuss.typ"

// authors contribs
#include "7.authors-contrib.typ"

#include "8.appendix.typ"