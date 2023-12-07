# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

IsDigit ← ∊:"0123456789"
ParseOne ← ⍉⊜(⊜⋕ IsDigit.)≠@\n.

DistanceFor ← (
  # chargeTime totalTime
  ⊃∘-
  # speed runningTime
  ×
)

CountWays ← (
  °⊟
  ⇡.
  DistanceFor
  <
  /+
)

PartOne ← (
  ParseOne
  ≡CountWays
  /×
)

ParseTwo ← ⍉⊜(⋕ ▽ IsDigit.)≠@\n.

PartTwo ← CountWays ParseTwo

---
$ Time:      7  15   30
$ Distance:  9  40  200
Aeq [7_9 15_40 30_200] ParseOne

Aeq 12 DistanceFor 3 7

Aeq 4 CountWays 7_9

$ Time:      7  15   30
$ Distance:  9  40  200
⍤⊃⋅∘≍ 288 PartOne

$ Time:      7  15   30
$ Distance:  9  40  200
Aeq 71530_940200 ParseTwo .
Aeq 71503 PartTwo

46828479 347152214061471

Width ← 200
⊓(
  ×÷:⇡.Width.
  DistanceFor
| ×2
)
÷:
⇌÷:⇡.⧻.
Red ← 1_0.5_0.5
Green ← 0.5_1_0.5
⊠(
  # x y
  ×⊃(
    (Red|Green)>0.5;
  | >
  )
)
&ims

&p "Tests OK"

---

Aeq 449550 PartOne &fras "day6.txt"
Aeq 28360140 PartTwo &fras "day6.txt"
