// using custom implementation with repo name under authors.
#import "template/custom.typ": ieee
// #import "@preview/charged-ieee:0.1.3": ieee

#show: ieee.with(
  title: [FarSightBERT:  Enhanced Embeddings for Long-Term Disease Prediction],
  abstract: [
    //TODO
    ???
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
  github-repo: "https://github.gatech.edu/nkapila6/nlpvise",
  index-terms: ("Scientific writing", "Typesetting", "Document creation", "Syntax", "Clinical decision support systems", "Disease prediction", "Healthcare analytics", "ICD-9 code group prediction", "Precision medicine"),
  // index-terms: ("Scientific writing", "Typesetting", "Document creation", "Syntax"), //TODO
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