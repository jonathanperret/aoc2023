# Experimental!
Lines ← &i "tools.ua" "Lines"
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

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

LeftSegment ← (
  ⊃(
    ⊢ # start of left ⇡
  | ⊓(
      /+ # end of left ⇡
    | ⊡1 # start of right ⇡
    )
    ↧ # end of left segment = leftmost
  )
  ⊙-. # compute ⧻ from start and end
  ⊟   # build left segment
)
MiddleSegment ← (
  # 40_20 52_50_48
  ⊃(
    ⊓(
      ⊢  # start of left ⇡
    | ⊡1 # start of right ⇡
    )
    ↥ # start of middle = rightmost start
  | ⊓(
      /+   # end of left ⇡
    | /+↘1 # end of right ⇡
    )
    ↧ # end of middle = leftmost end
  | ;
    - ⊃(⊡1|⊢) # offset of right ⇡
  )
  -,: # ⧻ of middle from start to end
  ⊟:  # build source middle segment
  ⍜⊢+ # apply offset to middle segment
)

RightSegment ← (
  # 80_20 52_50_40 -> 90_10
  ⊃(
    /+ # end of left ⇡ (100)
  | ⊓(
      ⊢    # start of left ⇡ (80)
    | /+↘1 # end of right ⇡ (90)
    )
    ↥ # start of right segment = rightmost (90)
  )
  -, # ⧻ of right segment
  ⊟: # build right segment
)

ValidRange ← (
  ⊡1
  >0
)

ApplyRangeToRange ← (
  # 40_20 52_50_48 -> [ 40_10 ] [ 52_10 ]

  ⊃(
    ⊟⊃(LeftSegment|RightSegment)
  | ¤ MiddleSegment
  )

  # filter out invalid ranges
  ∩(
    ▽ ≡ValidRange .
  )
)

JoinBoxed ← ∧(⊂⊔)⊙(↯0_2[])

ApplyTableToRangeStep ← (|3.2
  # on the stack: ⇡ to apply, and accumulators: ranges to process, transformed ranges
  ¤
  ≡(
    :
    ApplyRangeToRange
    ∩□
  )
  ∩(∧(⊂⊔)⊙(↯0_2[]))
  ⊙⊂
)

ConvertSeeds ← ↯¯1_2
SortRanges ← ⊏⍏≡⊢.

ApplyTableToRange ← (
  :
  ⊙(
    ¤
    ⊙(↯0_2[])
  )
  ∧ApplyTableToRangeStep
  # on the stack: untransformed ranges, transformed ranges
  # merge transformed ranges with untransformed ones
  ⊂
)

ApplyTableToRanges ← (
  ⊙¤
  ≡(□ApplyTableToRange)
  JoinBoxed
  SortRanges
)

ApplyTablesToRanges ← (
  ∧(|2
    ⊔
    :
    ApplyTableToRanges
  )
)

PartTwo ← (
  Parse
  ConvertSeeds
  :
  ApplyTablesToRanges
  ⊡ 0_0
)

---
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
Sample ←

Aeq 50_98_2 FindRange 99 [52_50_48 50_98_2]
Aeq 52_50_48 FindRange 79 [50_98_2 52_50_48]

Aeq 81 ApplyRange 79 52_50_48

Aeq 81 ApplyTable 79 [50_98_2 52_50_48]
Aeq 51 ApplyTable 99 [52_50_48 50_98_2]

Aeq 41 ApplyTables 99 {[52_50_48 50_98_2] [0_10_200]}
Aeq 41 ApplyTables 99 {[52_50_48 50_98_2] [0_10_200]}

Aeq [82 43 86 35] MapSeeds Parse Sample
Aeq 35 PartOne Sample

ApplyRangeToRange 5_10 52_50_48
Aeq [5_10]
Aeq ↯ 0_2 []

Aeq 90_10 RightSegment 80_20 52_50_40
Aeq 100_20 RightSegment 100_20 52_50_40
Aeq 90_110 RightSegment 0_200 52_50_40
Aeq 90_¯30 RightSegment 0_60 52_50_40

Aeq 10_40 LeftSegment 10_100 52_50_40
Aeq 60_¯10 LeftSegment 60_10 52_50_40
Aeq 5_10 LeftSegment 5_10 52_50_40

Aeq 52_40 MiddleSegment 10_100 52_50_40
Aeq 52_10 MiddleSegment 10_50 52_50_40
Aeq 62_30 MiddleSegment 60_50 52_50_40
Aeq 52_¯35 MiddleSegment 5_10 52_50_40
Aeq 107_¯15 MiddleSegment 105_10 52_50_40

ApplyRangeToRange 80_20 52_50_40
Aeq [90_10]
Aeq [82_10]

ApplyRangeToRange 40_20 52_50_48
Aeq [40_10]
Aeq [52_10]

ApplyTableToRangeStep 52_50_48 [60_10 5_10 0_3] ↯0_2[]
Aeq [0_3 5_10]
Aeq [62_10]

ApplyTableToRange 60_10 [52_50_48 50_98_2]
Aeq [62_10]

ApplyTableToRange 0_100 [52_50_48 50_98_2]
Aeq [0_50 50_2 52_48]

ApplyTableToRanges [60_10 0_100] [52_50_48 50_98_2]
Aeq [0_50 50_2 52_48 62_10]

Aeq 46 PartTwo Sample

&p "Tests OK"

---

Aeq 1181555926 PartOne &fras "day5.txt"
Aeq 37806486 PartTwo &fras "day5.txt"
