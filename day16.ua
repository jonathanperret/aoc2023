# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Parse ← (
  ⊜∘≠@\n.
  = "./\\|-" ¤
  °[⊙⊙⊙⊙∘]
)
DropHGBD ← ;;;;
KeepHGBD ← ⊙⊙⊙∘
DropMirrors ← ;;;;;
KeepMirrors ← ⊙⊙⊙⊙∘
KeepAll ← ⊙⊙⊙⊙KeepMirrors
DropAll ← DropHGBD DropMirrors
FixMirrors ← ⊙∩∩¤ ¤

• ← 1 0 0 0 0
╱ ← 0 1 0 0 0
╲ ← 0 0 1 0 0
│ ← 0 0 0 1 0
─ ← 0 0 0 0 1
GoH ← 1 0 0 0
GoG ← 0 1 0 0
GoB ← 0 0 1 0
GoD ← 0 0 0 1

H ← ∘
G ← ⋅∘
B ← ⋅⋅∘
D ← ⋅⋅⋅∘

TopAndFifth ← ⊃(∘|⋅⋅⋅⋅∘)

F ← ↥↥↥ ⊃(↧ TopAndFifth|↧⋅TopAndFifth|↧⋅⋅TopAndFifth|↧↥↥)
SwizzleH ← ⊃(H|D|G|⋅⋅⋅⋅⊃(⋅⋅⋅(⊙;)|⊙⊙∘))
SwizzleG ← ⊃(G|B|H|⋅⋅⋅⋅⊃(⋅⋅⋅⋅∘|⊙⊙∘))
SwizzleB ← ⊃(B|G|D|⋅⋅⋅⋅⊃(⋅⋅⋅(⊙;)|⊙⊙∘))
SwizzleD ← ⊃(D|H|B|⋅⋅⋅⋅⊃(⋅⋅⋅⋅∘|⊙⊙∘))
CollectHGBD ← [KeepHGBD]
Merge ← ⊃(↥TopAndFifth|↥⋅TopAndFifth|↥⋅⋅TopAndFifth|↥⋅⋅⋅TopAndFifth)

Bounce ← ⊃(F SwizzleH|F SwizzleG|F SwizzleB|F SwizzleD)

ShiftH ← ⬚0↻1
ShiftG ← ⬚0↻0_1
ShiftB ← ⬚0↻¯1
ShiftD ← ⬚0↻0_¯1
ShiftHGBD ← ⊓(ShiftH|ShiftG|ShiftB|ShiftD)
SetupHGBDAt ← (
  ⊙(
    ⊃(...×0|∘)
    [KeepHGBD]
  )
  ⍜⊡ (⋅1)
  °[KeepHGBD]
)
SetupHGBD ← (
  SetupHGBDAt 3_0_0
)
OrHGBD ← ⊃(
  ↥TopAndFifth
| ↥⋅TopAndFifth
| ↥⋅⋅TopAndFifth
| ↥⋅⋅⋅TopAndFifth
)
Step ← (
  ⊃(Bounce ShiftHGBD|KeepAll)
  OrHGBD
)
Energized ← ↥↥↥
PeekEnergized ← ⊃Energized KeepHGBD
Count ← /+♭
VizHGBD ← (
  ≡≡°⋯⍉CollectHGBD
  ⊏:" ⫰⊸┘⫯│┐┤⟜└─┴┌├┬┼"
)
PeekHGBD ← ⊃(
  VizHGBD
| KeepHGBD
)
FirstStepAt ← (
  SetupHGBDAt
  ⊃(Bounce|⋅⋅⋅⋅KeepMirrors)
)
FirstStep ← FirstStepAt 3_0_0
RepeatToEnd ← (
  0
  ⍢(
    # in: last count, 9 matrices
    # out: last count, 9 new matrices
    ⊓(+1|Step)
  )(
    # in: last count, 9 matrices
    ⊙(Count Energized)
    ≠
  )
)
Solve ← (
  RepeatToEnd
  ⊙DropAll
)
SolveAt ← (
  FirstStepAt
  Solve
  # &p.
)
PartOne ← (
  Parse
  FirstStep
  Solve
)
PartTwo ← (
  Parse
  ⊃(△|FixMirrors)
  [
    ⊃(
      # from top
      ⊢⇡
      ≡(⊂ 2)
    | # from bottom
      ⊢⇌⇡
      ≡(⊂ 0)
    | # from left (d)
      ⍉⊢⍉⇡
      ≡(⊂ 3)
    | # from right (g)
      ⍉⊢⇌⍉⇡
      ≡(⊂ 1)
    )  ]
  ☇ 1
  ## ╭─
  ## ╷ 2 0 0
  ##   2 0 1
  ##   2 0 2
  ##   2 0 3
  ##   2 0 4
  ##   2 0 5
  ##   2 0 6
  ##   2 0 7
  ##   2 0 8
  ##   2 0 9
  ##   0 9 0
  ##   0 9 1
  ##   0 9 2
  ##   0 9 3
  ##   0 9 4
  ##   0 9 5
  ##   0 9 6
  ##   0 9 7
  ##   0 9 8
  ##   0 9 9
  ##   3 0 0
  ##   3 1 0
  ##   3 2 0
  ##   3 3 0
  ##   3 4 0
  ##   3 5 0
  ##   3 6 0
  ##   3 7 0
  ##   3 8 0
  ##   3 9 0
  ##   1 0 9
  ##   1 1 9
  ##   1 2 9
  ##   1 3 9
  ##   1 4 9
  ##   1 5 9
  ##   1 6 9
  ##   1 7 9
  ##   1 8 9
  ##   1 9 9
  ##         ╯
  ≡SolveAt
  /↥♭
)
---
$ \\.
$ ..
Parse
FirstStep
RepeatToEnd
Aeq 2
Aeq ["⫯ "
     "⫯ "] PeekHGBD
DropAll

$ .|
$ ..
Parse
SetupHGBD
Aeq ["⟜ "
     "  "] PeekHGBD
Step
Aeq ["⟜│"
     "  "] PeekHGBD
Step
Aeq ["⟜│"
     " ⫯"] PeekHGBD
DropAll

# f(x,y,z,t) = (x ∧ ·) ∨ (y ∧ ╱) ∨ (z ∧ ╲) ∨ ((x ∨ y ∨ z) ∧ t)`
Aeq @z F @x @y @z @t @· @╱ @╲

# `h' = f(h, d, g, │, ·, ╱, ╲)`
Aeq 1 F 1 0 0 0 1 0 0 # up through ·
Aeq 1 F 0 1 0 0 0 1 0 # right through ╱

# h' = f(h, d, g, │, ·, ╱, ╲)
Aeq "hdg│•╱╲" [⊙⊙⊙⊙⊙⊙∘] SwizzleH @h @g @b @d @• @╱ @╲ @│ @─

# g' = f(g, b, h, ─, ·, ╱, ╲)
Aeq "gbh─•╱╲" [⊙⊙⊙⊙⊙⊙∘] SwizzleG @h @g @b @d @• @╱ @╲ @│ @─

# b' = f(b, g, d, │, ·, ╱, ╲)
Aeq "bgd│•╱╲" [⊙⊙⊙⊙⊙⊙∘] SwizzleB @h @g @b @d @• @╱ @╲ @│ @─

# d' = f(d, h, b, ─, ·, ╱, ╲)
Aeq "dhb─•╱╲" [⊙⊙⊙⊙⊙⊙∘] SwizzleD @h @g @b @d @• @╱ @╲ @│ @─

Aeq [1 0 0 1] [Merge 1 0 0 0 0 0 0 1]

Aeq [GoH] [Bounce GoH •]
Aeq [GoG] [Bounce GoG •]
Aeq [GoB] [Bounce GoB •]
Aeq [GoD] [Bounce GoD •]

Aeq [Merge GoH GoB] [Bounce Merge GoH GoB •]
Aeq [Merge GoH GoG] [Bounce Merge GoH GoG •]

Aeq [GoD] [Bounce GoH ╱]
Aeq [GoB] [Bounce GoG ╱]
Aeq [GoG] [Bounce GoB ╱]
Aeq [GoH] [Bounce GoD ╱]

Aeq [GoG] [Bounce GoH ╲]
Aeq [GoH] [Bounce GoG ╲]
Aeq [GoD] [Bounce GoB ╲]
Aeq [GoB] [Bounce GoD ╲]

Aeq [GoH] [Bounce GoH │]
Aeq [GoB] [Bounce GoB │]
Aeq [Merge GoB GoH] [Bounce GoD │]
Aeq [Merge GoD GoG] [Bounce GoH ─]

$ .|...\\....
$ |.-.\\.....
$ .....|-...
$ ........|.
$ ..........
$ .........\\
$ ..../.\\\\..
$ .-.-/..|..
$ .|....-|.\\
$ ..//.|....
Parse
FirstStep
Aeq ["⟜         "
     "          "
     "          "
     "          "
     "          "
     "          "
     "          "
     "          "
     "          "
     "          "] PeekHGBD
⍥Step 8
Aeq ["⟜│        "
     " ⫯        "
     " ⫯        "
     " ⫯        "
     " ⫯        "
     " ⫯        "
     " ⫯        "
     " ─        "
     "          "
     "          "] PeekHGBD
RepeatToEnd
Aeq 46
Aeq ["⟜│⊸⊸⊸⊸    "
     " ⫯   ⫰    "
     " ⫯   │─⟜⟜⟜"
     " ⫯   ⫯⫰   "
     " ⫯   ⫯⫰   "
     " ⫯   ⫯⫰   "
     " ⫯  ⟜┌│⊸  "
     "⊸─⟜⟜⫰⫯⫯⫰  "
     " │⊸⊸⊸┐─│  "
     " ⫯   ⫯ ⫯  "] PeekHGBD
DropAll

$ .\\
$ ..
Parse
SetupHGBD
Aeq ["⟜ "
     "  "] PeekHGBD
Step
Aeq ["⟜⫯"
     "  "] PeekHGBD
Step
Aeq ["⟜⫯"
     " ⫯"] PeekHGBD
DropAll

$ .|...\\....
$ |.-.\\.....
$ .....|-...
$ ........|.
$ ..........
$ .........\\
$ ..../.\\\\..
$ .-.-/..|..
$ .|....-|.\\
$ ..//.|....
Aeq 46 PartOne

$ .|...\\....
$ |.-.\\.....
$ .....|-...
$ ........|.
$ ..........
$ .........\\
$ ..../.\\\\..
$ .-.-/..|..
$ .|....-|.\\
$ ..//.|....
Aeq 51 PartTwo

&p "Tests OK"
---
# Aeq 7477 PartOne &fras "day16.txt"
# Aeq 7853 PartTwo &fras "day16.txt"