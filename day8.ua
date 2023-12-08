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
    ≡⊢.
    ⊃∘(
      ¤
      ≡(
        ⊙∘
        ⊗:
        ↘1
      )
    )
  )
)

MakeMatrices ← (
  ⊙⊙(
    ⍉
    ≡(⬚0≡°⊚)
  )
)
Step ← (
  ⊃(
    :⊙⊙;
    ⊙⊡
    ×
    /↥
  | ⋅⋅⊙∘
  )
)
Included ← (
  ⊙¬
  ×
  /↥
  ¬
)
Iter ← (
  ⊃(
    +1
    ⊙∘
  | ⊙(⧻.)
    :
    ◿
    ⊡
    Step
  )
)
FindSingleStartEnd ← (
  ⊃(≡(≍ "AAA")|≡(≍ "ZZZ"))
)
PartOne ← (
  Parse
  MakeMatrices
  ⊙FindSingleStartEnd
  0
  ⍢Iter(¬⋅⋅Included)
  ⊙⋅⋅⋅;
)
PartTwo ← (
  Parse
  MakeMatrices
  ⊙(
    ≡(⊢⇌)
    ⊃(=@A|=@Z)
  )
  0
  ⍢Iter(¬⋅⋅Included)
  ⊙⋅⋅⋅;
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
Aeq 2 PartOne

$ LLR
$
$ AAA = (BBB, BBB)
$ BBB = (AAA, ZZZ)
$ ZZZ = (ZZZ, ZZZ)
Aeq 6 PartOne

[0 0 1 0 0 0 1 0]
[1 0 0 1 0 0 0 0]
Aeq 0 Included

$ LR
$ 
$ aaA = (aaB, XXX)
$ aaB = (XXX, aaZ)
$ aaZ = (aaB, XXX)
$ bbA = (bbB, XXX)
$ bbB = (bbC, bbC)
$ bbC = (bbZ, bbZ)
$ bbZ = (bbB, bbB)
$ XXX = (XXX, XXX)
Aeq 6 PartTwo

&p "Tests OK"

---

# Aeq 18023 PartOne &fras "day8.txt"
Aeq 0 PartTwo &fras "day8.txt"
