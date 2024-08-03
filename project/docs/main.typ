#set page(
  paper: "a4",
  margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
  numbering: "1",
)

#set text(font: "Times New Roman", size: 11pt)
#set heading(numbering: "1.1.")

#align(center)[
  #block(text(weight: 700, size: 18pt)[Checkpoint 4 Report])
  #v(0.5cm)
  #text(size: 14pt)[Arda Gurcan, Chentian Wu]
  #v(0.3cm)
  #text(size: 12pt)[Date: #datetime.today().display()]
]

#outline(
  title: "Table of Contents",
  indent: true,
)

#pagebreak()

#include "./sections/sql.typ"
#include "./sections/interface.typ"
#include "./sections/evaluation.typ"