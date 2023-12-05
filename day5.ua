# Experimental!
Lines ← &i "tools.ua" "Lines"
Aeq ← ⍤⊃($"expected _ got _")≍

Sort ← ⊏ ⍏ .
Unique ← ⊕⊢⊛.⊏⍏.

ParseSeeds ← (
  ⊔
  ↘+2⊗@:.
  ⊜parse≠@\s.
)
ParseMap ← (
  ⊔
  ↘1
  ≡(⊜parse ≠@\s. ⊔)
  □
)
ParseMaps ← (
  ≠0≡⧻.
  ⊜□
  ≡ParseMap
)
Parse ← (
  Lines
  ⊃(
    ⊢
    ParseSeeds
  | ↘2
    ParseMaps
  )
)
FixTables ← ≡(
  ⊔
  0_0_∞
  ⊂:
  □
)
FindRange ← (
  ¤ # [79] [50_98_2 52_50_48]
  : # [50_98_2 52_50_48] [79]
  . # [50_98_2 52_50_48] [50_98_2 52_50_48] [79]
  ⊙≡(
    # 50_98_2 79
    ⊃(⊡2|⊡1) # 2 98 79
    ⊙-       # 2 -19(79-98)
    ⊙.       # 2 -19 -19
    ≤        # 1 (-19<=2?) -19
    ⊙(≥0)    # 1 0
    ↧        # 0 (1 && 0)
  )
  # [52_50_48 50_98_2] [0 1]
  ▽: # [50_98_2]
  ⊢  # 50_98_2
)
ApplyRange ← (
  ⊙⊃(⊡1|⊢)
  -:
  +
)
ApplyTable ← (
  # 99 [52_50_48 50_98_2]
  .          # 99 99 [52_50_48 50_98_2]
  ⊙FindRange # 99 50_98_2
  ApplyRange # 51
)
ApplyTables ← (
  # 99 {[52_50_48 50_98_2] [0_10_200]}
  :
  # {[52_50_48 50_98_2] [0_10_200]} 99
  ∧(
    # □[52_50_48 50_98_2] 99
    ⊔ # [52_50_48 50_98_2] 99
    : # 99 [52_50_48 50_98_2]
    ApplyTable
  )
)
MapSeeds ← (
  ⊙FixTables
  ⊙¤
  ≡ApplyTables
)

PartOne ← (
  Parse
  MapSeeds
  /↧
)

---
Aeq 50_98_2 FindRange 99 [52_50_48 50_98_2]
Aeq 52_50_48 FindRange 79 [50_98_2 52_50_48]

Aeq 81 ApplyRange 79 52_50_48

Aeq 81 ApplyTable 79 [50_98_2 52_50_48]
Aeq 51 ApplyTable 99 [52_50_48 50_98_2]

Aeq 41 ApplyTables 99 {[52_50_48 50_98_2] [0_10_200]}
Aeq 41 ApplyTables 99 {[52_50_48 50_98_2] [0_10_200]}

$ seeds: 79 14 55 13
$
$ seed-to-soil map:
$ 52 50 48
$ 50 98 2
$
$ soil-to-fertilizer map:
$ 0 15 37
$ 37 52 2
$ 39 0 15
$
$ fertilizer-to-water map:
$ 49 53 8
$ 0 11 42
$ 42 0 7
$ 57 7 4
$
$ water-to-light map:
$ 88 18 7
$ 18 25 70
$
$ light-to-temperature map:
$ 45 77 23
$ 81 45 19
$ 68 64 13
$
$ temperature-to-humidity map:
$ 0 69 1
$ 1 0 69
$
$ humidity-to-location map:
$ 60 56 37
$ 56 93 4

Aeq [82 43 86 35] MapSeeds Parse .

Aeq 35 PartOne

&p "Tests OK"

---

Aeq 1181555926 PartOne &fras "day5.txt"
# Aeq 0 PartTwo &fras "day5.txt"
