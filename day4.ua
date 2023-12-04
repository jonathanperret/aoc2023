# Experimental!
Lines ← &i "tools.ua" "Lines"
Aeq ← ⍤⊃($"expected _ got _")≍

ParseCard ← (
  ↘+1⊗@:.
  ≠@|.
  ⊜(
    ⊜parse ≠@\s.
    □
  )
)
Parse ← (
  ≠@\n.
  ⊜ParseCard
)
CardValue ← (
  ⊃(⊔⊡1|⊔⊢)
  ≡∊ ⊙¤
  ⧻⊚
)

CardScore ← (
  CardValue
  -1/+
  ⁿ:2
  ⌊
)
PartOne ← (
  Parse
  ≡CardScore
  /+
)

Step ← (
  ↙⊙.
  /+
  +1
  ⊂
)
Propagate ← (
  ⇌
  []
  :
  ∧Step
)
PartTwo ← (
  Parse
  ≡CardValue
  Propagate
  /+
)

---
$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53

ParseCard

Aeq {41_48_83_86_17 83_86_6_31_17_9_48_53}

Aeq 4 CardValue {41_48_83_86_17 83_86_6_31_17_9_48_53}

Aeq 8 CardScore {41_48_83_86_17 83_86_6_31_17_9_48_53}
Aeq 0 CardScore {41_48_83_86_17 123}

$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
$ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
$ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
$ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
$ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
$ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

Aeq 13 PartOne

10_20_30
2
Step
Aeq [31 10 20 30]

$ Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
$ Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
$ Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
$ Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
$ Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
$ Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11

Aeq 30PartTwo

&p "Tests OK"

---

Aeq 25004 PartOne &fras "day4.txt"
Aeq 14427616 PartTwo &fras "day4.txt"
