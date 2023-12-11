# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Parse ← ⊜(=@#)≠@\n.
Expand ← ⍥(⍉ ▽ +1 ⊃≡(¬/↥)∘)2
Distance ← /+⌵-
SumOfAllDistances ← ÷2/+♭⊠Distance.⊚
PartOne ← SumOfAllDistances Expand Parse
PartTwo ← + ⊙×: ⊙(⊃∘- ∩SumOfAllDistances ⊃∘Expand Parse) -1

---
Aeq 9 Distance 6_1 11_5

$ ...#......
$ .......#..
$ #.........
$ ..........
$ ......#...
$ .#........
$ .........#
$ ..........
$ .......#..
$ #...#.....

Parse .
Expand

[0_0_0_0_1_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_1_0_0_0
 1_0_0_0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_1_0_0_0_0
 0_1_0_0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_0_0_0_1
 0_0_0_0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_0_0_0_0
 0_0_0_0_0_0_0_0_0_1_0_0_0
 1_0_0_0_0_1_0_0_0_0_0_0_0]
Aeq

⍤⊃⋅∘≍ 374 PartOne .

Aeq 1030 PartTwo 10 .
Aeq 8410 PartTwo 100

&p "Tests OK"

---

Aeq 9312968 PartOne &fras "day11.txt"
Aeq 597714117556 PartTwo 1e6 &fras "day11.txt"
