// using custom implementation with repo name under authors.
#import "template/custom.typ": ieee
// #import "@preview/charged-ieee:0.1.3": ieee

#show: ieee.with(
  title: [Long Term Disease Prediction Using BERT Embeddings],
  abstract: [
    The process of scientific writing is often tangled up with the intricacies of typesetting, leading to frustration and wasted time for researchers. In this paper, we introduce Typst, a new typesetting system designed specifically for scientific writing. Typst untangles the typesetting process, allowing researchers to compose papers faster. In a series of experiments we demonstrate that Typst offers several advantages, including faster document creation, simplified syntax, and increased ease-of-use.
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
  index-terms: ("Scientific writing", "Typesetting", "Document creation", "Syntax"), //TODO
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