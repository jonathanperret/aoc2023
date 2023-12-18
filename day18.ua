# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Parse ← ⊜(°□⊢⊙⋕⊙∩°□°[⊙⊙∘] ⊜□ ¬∊:" #()".) ≠@\n.
Directions ← [1_0 0_¯1 ¯1_0 0_1]
DirLetters ← "RDLU"
LettersToDirections ← (
  ↘4 ⊛ ⊂ DirLetters
  ⊏ :Directions
)
ToVectors ← × LettersToDirections
PartOne ← (
  Parse
  &p
)
DropOdd ← (⍜⍉⊢ ↯ ⊂ ¯1_2 ↘1 △.)
Inside ← (
  \+.
  ∩DropOdd
  ∩⍉
  ⊓(⊢⇌|⊢)
  ×
  /+
)
Det ← /- /× ⍜⊢⇌
Border ← (
  ⊓(
    ⊂:⊢.
    ◫2LettersToDirections
    ≡(¯Det) # corner types
    /+
  | ×2/+ # perimeter * 2
  )
  +
  ÷4
)
Area ← (
  ⊃(Border|Inside ToVectors)
  +
)
PartOne ← (
  Parse
  ⊙⊙;
  Area
)
---
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

PartOne
⍤⊃⋅∘≍ 62

[5_0 0_¯3 ¯5_0 0_3]
Inside
Aeq 15

2_2_2_2
$ RDLU
Aeq 9 Area

&p "Tests OK"
---
Aeq 70026 PartOne &fras "day18.txt"
# Aeq 0 PartTwo &fras "day18.txt"
