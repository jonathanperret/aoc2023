# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Parse ← ⊜∘ ≠@\n.
RollRowLeft ← ⍜⊜□≡⍜°□(⊏⍖.) ≠@#.
RollNorth ← ⍜⍉ ≡RollRowLeft
CountOs ← ≡(/+=@O)
RowWeights ← +1⇌⇡⧻
ScoreGrid ← /+× ⊃RowWeights CountOs
PartOne ← (
  Parse
  RollNorth
  ScoreGrid
)
RollWest ← ⍜(⍉⇌)RollNorth
RollSouth ← ⍜(≡⇌⇌)RollNorth
RollEast ← ⍜(⇌⍉)RollNorth
Spin ← (
  RollNorth
  RollWest
  RollSouth
  RollEast
)
Loop ← (
  ⊃(⊙∘|⋅ScoreGrid)
  ;⍥(
    Spin
    ⊃(∘|⊂:ScoreGrid)
  )
)
FindCycle ← ⍜⇌(
  ⊃(↙10|∘|∘|∘)
  ¬⌕
  ⊜⧻
  ↙+1⊢
)
ProbeLength ← 300
TargetLength ← 1000000000
PartTwo ← (
  Parse
  Loop ProbeLength
  FindCycle
  ⧻.
  - ProbeLength -1 TargetLength
  ◿:
  ⊡
)
---
$ O....#....
$ O.OO#....#
$ .....##...
$ OO.#O....O
$ .O.....O#.
$ O.#..O.#.#
$ ..O..#O..O
$ .......O..
$ #....###..
$ #OO..#....

⍤⊃⋅∘≍ 136 PartOne

["O....#...."
 "O.OO#....#"
 ".....##..."
 "OO.#O....O"
 ".O.....O#."
 "O.#..O.#.#"
 "..O..#O..O"
 ".......O.."
 "#....###.."
 "#OO..#...."]
Aeq 104 ScoreGrid.

Spin
Aeq[".....#...."
    "....#...O#"
    "...OO##..."
    ".OO#......"
    ".....OOO#."
    ".O#...O#.#"
    "....O#...."
    "......OOOO"
    "#...O###.."
    "#..OO#...."].
Aeq 87 ScoreGrid.

Spin
Aeq[".....#...."
    "....#...O#"
    ".....##..."
    "..O#......"
    ".....OOO#."
    ".O#...O#.#"
    "....O#...O"
    ".......OOO"
    "#..OO###.."
    "#.OOO#...O"].
Aeq 69 ScoreGrid.

Spin
Aeq[".....#...."
    "....#...O#"
    ".....##..."
    "..O#......"
    ".....OOO#."
    ".O#...O#.#"
    "....O#...O"
    ".......OOO"
    "#...O###.O"
    "#.OOO#...O"].
Aeq 69 ScoreGrid

["O....#...."
 "O.OO#....#"
 ".....##..."
 "OO.#O....O"
 ".O.....O#."
 "O.#..O.#.#"
 "..O..#O..O"
 ".......O.."
 "#....###.."
 "#OO..#...."]

Loop 100
FindCycle
Aeq [69 69 65 64 65 63 68]

$ O....#....
$ O.OO#....#
$ .....##...
$ OO.#O....O
$ .O.....O#.
$ O.#..O.#.#
$ ..O..#O..O
$ .......O..
$ #....###..
$ #OO..#....

⍤⊃⋅∘≍ 64 PartTwo

&p "Tests OK"
---
Aeq 110128 PartOne &fras "day14.txt"
Aeq 103861 PartTwo &fras "day14.txt"
