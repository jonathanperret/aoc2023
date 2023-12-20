# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Parse ← ⊜(⊃(⊗:"RDLU"⊢|⋕↘2↘¯10|↘¯1↙¯7)) ≠@\n.

Directions ← [1_0 0_¯1 ¯1_0 0_1]

# ( dirs lengths -- points )
CenterPolygon ← \+ ×

# ( points -- area )
PolygonArea ← (
  ↻1.
  # -- x2y2s x1y1s
  ∩⍉
  ⊃(∩⊢|∩(⊢⇌))
  # -- x1 x2 y1 y2
  ⊓-+
  # -- x2-x1 y2+y1
  ×
  ⌵/+
  ÷2
)

# ( v1 v2 -- cross )
Cross ← (
  # -- [x1 y1] [x2 y2]
  ⇌
  # -- [y1 x1] [x2 y2]
  ×
  # -- [x2y1 x1y2]
  /-
  # -- x1y2 - x2y1
)
⍤⊃⋅∘≍ 1 Cross [1 0] [0 1]

# ( dirs lengths -- points )
OutsidePolygon ← (
  ⊃(
    CenterPolygon
  | # 
    # -- dirs
    ↻1.
    # -- d1s d2s
    ⊃(
      -
      # -- d1s - d2s
    | ≡Cross
      # -- d1∧d2s
    )
    ×
    ÷2
    # -- corner offsets
  )
  +
)

Area ← PolygonArea OutsidePolygon ⊏:Directions

Border ← +1÷2/+
Area ← + ⊃(⋅Border|PolygonArea CenterPolygon ⊏:Directions)

PartOne ← Area ⊙⊙; Parse
ParseHex ← ∧(+ ⊙(×16)) ⊙0 ◿39-@0
Decode ← ≡⊃(-@0⊢⇌|ParseHex↙5)
PartTwo ← Area ⋅⋅Decode Parse
Draw ← (
  ⊙⊙(÷256⍜(☇1|≡ParseHex) ↯ ¯1_3_2)
  ∩▽, # expand
  ⊏:Directions
  - ¤/↧. \+
  ⊛.
  ⊝
  ,:
  ∩⊏
  ↯:0⊂:3 +1/↥.
  :
  ⊙:
  ∧(
    ⊙:
    ⍜⊡⋅∘
  )

  # ⍜⊡(⋅∘)
  &ims
)
DrawTwo ← (
  ⋅;
  ⊃(
    Decode
    ⊃(
      ⊏:Directions
      ×
      /↥-⊃/↧/↥
      ÷:50
    | ⊙∘
    )
    ⊙(⁅×) :
  | ∘
  )
  Draw
)
---
2_4_2_4
0_1_2_3
Aeq 15 Area

["7a21e3"
 "015232"]
Decode
Aeq 3_2
Aeq [500254 5411]

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

&p "Tests OK"
---
Aeq 70026 PartOne &fras "day18.txt"
Aeq 68548301037382 PartTwo &fras "day18.txt"
# Draw Parse &fras "day18.txt"
# DrawTwo Parse &fras "day18.txt"
