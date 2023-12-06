# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

ParseOne ← ⍉⊜(⊜parse ∊:"0123456789".)≠@\n.
TimeFor ← (
  # chargeTime targetDistance
  ⊃∘(⌈÷)
  # chargeTime timeToDestination
  +
)

CountWays ← (
  ⍘⊟
  .
  ⊙(
    ⊓(+1⇡-1|+1¤)
    ≡TimeFor
  )
  /+≤
)

PartOne ← (
  ParseOne
  ≡CountWays
  /×
)

ParseTwo ← ⍉⊜(parse ▽ ∊:"0123456789".)≠@\n.

PartTwo ← CountWays ParseTwo

---
$ Time:      7  15   30
$ Distance:  9  40  200
Aeq [7_9 15_40 30_200] ParseOne

Aeq 7 TimeFor 3 10
Aeq 11 TimeFor 1 10
Aeq 6 TimeFor 3 9

Aeq 4 CountWays 7_9

$ Time:      7  15   30
$ Distance:  9  40  200
⍤⊃⋅∘≍ 288 PartOne

$ Time:      7  15   30
$ Distance:  9  40  200
Aeq 71530_940200 ParseTwo .
Aeq 71503 PartTwo

&p "Tests OK"

---

Aeq 449550 PartOne &fras "day6.txt"
Aeq 28360140 PartTwo &fras "day6.txt"
