// using custom implementation with repo name under authors.
#import "template/custom.typ": ieee
// #import "@preview/charged-ieee:0.1.3": ieee

#show: ieee.with(
  title: [FarSightBERT:  Enhanced Embeddings for Long-Term Disease Prediction],
  abstract: [
    The FarSight paper by Gangavarapu et al @farsight-orig demonstrated the value of unstructured clinical notes for long-term disease prediction showcasing how rich patient-specific information is often lost in structued EHR data. Building upon their innovative FarSight aggregation technique, we explore two significant extensions to their approach: use of transformer-based embeddings and mixture of expert models.
  ],
  authors: (
    (
      name: "Nikhil Kapila",
      // department: [Co-Founder],
      // organization: [Typst GmbH],
      email: "nkapila6@gatech.edu"
    ),
    (
      name: "Tejas Rathi",
      // department: [Co-Founder],
      // organization: [Typst GmbH],
      email: "trathi9@gatech.edu"
    ),
  ),
  github-repo: "https://github.gatech.edu/nkapila6/FarSightBERT",
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