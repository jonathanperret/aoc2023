# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Parse ← ⊜(⊃(⊗:"RDLU"⊢|⋕↘2↘¯10|↘¯1↙¯7)) ≠@\n.

Directions ← [1_0 0_¯1 ¯1_0 0_1]
Inside ← /+ ⊢ × ⇌ ∩⍉ \+.
Border ← +1÷2/+
Area ← + ⊃(⋅Border|Inside × ⊏:Directions)
PartOne ← Area ⊙⊙; Parse
ParseHex ← ∧(+ ⊙(×16)) ⊙0 ◿39-@0
Decode ← ≡⊃(-@0⊢⇌|ParseHex↙5)
PartTwo ← Area ⋅⋅Decode Parse
---
ParseHex "12"
Aeq 18
$ R 6 (#70c710)
$ D 5 (#0dc571)
$ L 2 (#5713f0)
$ D 2 (#d2c081)
$ R 2 (#59c680)
$ D 2 (#411b91)
$ L 5 (#8ceee2)
$ U 2 (#caa173)
$ L 1 (#1b58a2)
$ U 2 (#caa171)
$ R 2 (#7807d2)
$ U 3 (#a77fa3)
$ L 2 (#015232)
$ U 2 (#7a21e3)

⍤⊃⋅∘≍ 62 PartOne .
⍤⊃⋅∘≍ 952408144115 PartTwo

[5_0 0_¯3 ¯5_0 0_3]
Inside
Aeq 15

2_2_2_2
0_1_2_3
Aeq 9 Area

["7a21e3"
 "015232"]
Decode
Aeq 3_2
Aeq [500254 5411]

&p "Tests OK"
---
Aeq 70026 PartOne &fras "day18.txt"
Aeq 68548301037382 PartTwo &fras "day18.txt"
