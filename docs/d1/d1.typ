#set math.equation(numbering: "(1)",  number-align: bottom)
#let sign = $"sign"$
#set document(title: [CSE 6250 - Spring 2025 - Deliverable 1],
            author: "nkapila6"
)

#show link: set text(fill: red)
#show link: underline

#set page(numbering: "1")
#align(center, text(16pt)[
  *CSE 6250 Big Data for Healthcare \ Spring 2025* \
  Deliverable 1 - 10th Feb 2025\
])
#align(center, text(13pt)[
#grid(
  columns: 2,
  gutter: 2em,
  align: (center, top),
  [
    *Nikhil Kapila* \
    nkapila6@\gatech.edu
  ],
  [
    *Tejas Rathi* \
    trathi9@\gatech.edu
  ]
)])

#set par(justify: true)
#set heading(numbering: "1.")
#show heading.where(level: 3): it =>[
    #block(it.body)
]
#set quote(block: true)
#show quote: set pad(x: 3em)
#show quote: set block(fill: gray.lighten(80%))

#show table.cell.where(y: 0): set text(
  fill: black,
  weight: "bold",
)

#set table(
  fill: (_, y) => if calc.odd(y) { rgb("EAF2F5") },
)

= Team registration
Names and GT usernames of two members.
#line()
#table(
  columns: (1fr, 1fr), inset: 10pt, align: horizon,
  table.header([Name], [GT usernames]),
  [Nikhil Kapila], [nkapila6@\gatech.edu],
  [Tejas Rathi], [trathi9@\gatech.edu],
)

= Paper Selection
Indices, titles and authors of selected papers.
#line()
#table(
  columns: (1fr, 1fr, 1fr), inset: 10pt, align: horizon,
  table.header([Indices], [Titles], [Authors],),
  [7], [AI-Driven Clinical Decision Support: Enhancing Disease Diagnosis Exploiting Patients Similarity], [CARMELA COMITO, DEBORAH FALCONE, AND AGOSTINO FORESTIERO],
  [34], [FarSight: Long-Term Disease Prediction Using Unstructured Clinical Nursing Notes], [Tushaar Gangavarapu
, Student Member, IEEE, Gokul S Krishnan, Student Member, IEEE,
Sowmya Kamath S, Senior Member, IEEE, and Jayakumar Jeganathan, MD],
  [35], [SurfCon: Synonym Discovery on Privacy-Aware Clinical Data], [Zhen Wang, Xiang Yue, Soheil Moosavinasab†, Yungui Huang†, Simon Lin†, Huan Sun],
)