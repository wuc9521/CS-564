= Interface

#image("../figures/1.png")

#let i = 1
#let cnt = 5
#while i <= cnt {
  image("../figures/" + str(i) + ".png")
  i = i + 1
  if i != cnt {
    v(1em)
  }
}
