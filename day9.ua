# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Parse ← ⊜(⊜⋕ ≠@\s.)≠@\n.

Deltas ← -⊃(⍜⇌(↘1)|↘1)
FindNext ← (
  0
  ⍢(
    ⊙⊃(⊢⇌|Deltas)
    +
  )(¬≍[0]⋅⊝)
  ⊙;
)
PartOne ← (
  Parse
  ≡FindNext
  /+
)
PartTwo ← (
  Parse
  ≡(FindNext⇌)
  /+
)
---
$ 0 3 6 9 12 15
$ 1 3 6 10 15 21
$ 10 13 16 21 30 45

Parse
;

[0 3 6 9 12 15]
Deltas
[3 3 3 3 3]
Aeq

Aeq 18 FindNext [0 3 6 9 12 15]

Aeq 68 FindNext [10 13 16 21 30 45]

$ 0 3 6 9 12 15
$ 1 3 6 10 15 21
$ 10 13 16 21 30 45
⍤⊃⋅∘≍ 114 PartOne .
⍤⊃⋅∘≍ 2 PartTwo

Aeq 5 FindNext ⇌ [10 13 16 21 30 45]

&p "Tests OK"

---

Aeq 1731106378 PartOne &fras "day9.txt"
Aeq 1087 PartTwo &fras "day9.txt"
