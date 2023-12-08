# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Parse ← (
  ≠@\n.
  ⊜□
  ⊃(
    °□ ⊢
    =@R
  | ↘ 1
    ≡(
      °□
      ≥0-@A.
      ⊜∘
    )
  )
)

Step ← (
  ⊙(
    ⊙(≡⊢.)
    ⊗
    ⊡⊙.
  )
  ⊡+1
)
Walk ← (
  ⊙["AAA"]

  ∧(
    ⊃(
      ⋅∘
    | ⊙(⊢⇌)
      Step
    )
    ⊂
  )
)
PartOne ← (
  Parse
  ↯[100000]
  Walk
  ?
  ⊙;
  ⊗ "ZZZ"
)
---
$ RL
$ 
$ AAA = (BBB, CCC)
$ BBB = (DDD, EEE)
$ CCC = (ZZZ, GGG)
$ DDD = (DDD, DDD)
$ EEE = (EEE, EEE)
$ GGG = (GGG, GGG)
$ ZZZ = (ZZZ, ZZZ)
# Aeq 2 PartOne

$ LLR
$ 
$ AAA = (BBB, BBB)
$ BBB = (AAA, ZZZ)
$ ZZZ = (ZZZ, ZZZ)
# Aeq 6 PartOne

&p "Tests OK"

---

Aeq 0 PartOne &fras "day8.txt"
# Aeq 0 PartTwo &fras "day8.txt"
