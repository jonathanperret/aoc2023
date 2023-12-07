# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Sort ← ⊏⍏.
Groups ← (
  .
  ⊛
  ⊕⧻
  ⇌Sort
  ⬚0↯ [5]
)
AddGroups ← (
  Groups.
  ⊂
)
SortByHands ← (
  ≡AddGroups
  ⍏
  ⊏
)
ScoreGame ← (
  +1⇡⧻.
  ×
  /+
)
ParseHand ← ⊗:"0123456789TJQKA"
Parse ← ⊜(⊓ParseHand ⋕ ⊃(↙5|↘6)) ≠@\n.
PartOne ← (
  Parse
  SortByHands
  ScoreGame
)
ParseHandTwo ← ⊗:"0J23456789TQKA"
ParseTwo ← ⊜(⊓ParseHandTwo ⋕ ⊃(↙5|↘6)) ≠@\n.

SubAllJokers ← (
  =1.
  ∩¤
  +2⇡12
  ≡(
    ⍜(⊙▽∘)≡(⊓∘;)
  )
)
BestGroups ← (
  SubAllJokers
  ≡Groups
  .
  ⍖
  ⊢
  ⊡
)
AddBestGroups ← (
  BestGroups.
  ⊂
)
SortByHandsTwo ← (
  ≡AddBestGroups
  ⍏
  ⊏
)
PartTwo ← (
  ParseTwo
  SortByHandsTwo
  ScoreGame
)
---

$ 32T3K
Aeq 3_2_10_3_13 ParseHand

[1_2_5 1_2_3 1_2_4]
Sort
Aeq [1_2_3 1_2_4 1_2_5]

765_684_28
[3_2_10_3_13 10_5_5_11_5 13_13_6_7_7]
Aeq 765_28_684 SortByHands

765_28_684
Aeq 2873 ScoreGame

Aeq 2_1_1_1_0 Groups 3_2_10_3_13

Aeq 2_1_1_1_0_3_2_10_3_13 AddGroups 3_2_10_3_13

$ 32T3K 765
$ T55J5 684
$ KK677 28
$ KTJJT 220
$ QQQJA 483
⍤⊃⋅∘≍ 6440 PartOne

$ T55J5
ParseHandTwo
Aeq 10_5_5_1_5

10_5_5_1_1
SubAllJokers

Aeq [10_5_5_2_2
     10_5_5_3_3
     10_5_5_4_4
     10_5_5_5_5
     10_5_5_6_6
     10_5_5_7_7
     10_5_5_8_8
     10_5_5_9_9
     10_5_5_10_10
     10_5_5_11_11
     10_5_5_12_12
     10_5_5_13_13]

Aeq 4_1_0_0_0 BestGroups 10_5_5_1_1

Aeq 4_1_0_0_0_1_10_5_5_1 AddBestGroups 1_10_5_5_1

$ 32T3K 765
$ T55J5 684
$ KK677 28
$ KTJJT 220
$ QQQJA 483
⍤⊃⋅∘≍ 5905 PartTwo

&p "Tests OK"

---

Aeq 252295678 PartOne &fras "day7.txt"
Aeq 250577259 PartTwo &fras "day7.txt"
