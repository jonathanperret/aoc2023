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

Bounce ← ⊃(F SwizzleH|F SwizzleG|F SwizzleB|F SwizzleD)

ShiftH ← ⬚0↻1
ShiftG ← ⬚0↻0_1
ShiftB ← ⬚0↻¯1
ShiftD ← ⬚0↻0_¯1
ShiftHGBD ← ⊓(ShiftH|ShiftG|ShiftB|ShiftD)
SetupHGBDAt ← (
  ⊙(
    ⊃(...<0|∘)
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
Count ← /+♭
Energized ← ↥↥↥
PeekEnergized ← ⊃Energized KeepHGBD
VizHGBD ← (
  ≡≡°⋯⍉CollectHGBD
  ⊏:" ⫰⊸┘⫯│┐┤⟜└─┴┌├┬┼"
)
PeekHGBD ← ⊃(
  VizHGBD
| KeepHGBD
)
Reps ← 1e3
FirstStepAt ← (
  SetupHGBDAt

  # ⊃(
  #   &p$"ShiftHGBD: _ms"⍜(×10)⁅×1e6 ÷ Reps ⍜now ⍥(ShiftHGBD)Reps
  # | KeepHGBD
  # )
  # ;;;;

  # &p$"Swizzle: _ms"⍜(×10)⁅×1e6 ÷ Reps ⍜now ⍥(
  #   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;⊃(SwizzleH|SwizzleG|SwizzleB|SwizzleD|KeepAll)
  # )Reps

  # &p$"Bounce: _ms"⍜(×10)⁅×1e6 ÷ Reps ⍜now ⍥(⊃(;;;;Bounce|KeepAll))Reps

  ⊃(Bounce|⋅⋅⋅⋅KeepMirrors)
)
FirstStep ← FirstStepAt 3_0_0
SignatureHGBD ← +∩(+∩Count)
RepeatToEnd ← (
  ¯1 # prev signature
  0  # latest signature
  ⍢(
    ⊙; # drop prev signature
    ⊙Step
    ⊙⊃(SignatureHGBD|KeepHGBD)
    : # shift old sig under new
  )(
    ≠
  )
  ;; # drop signatures
  ⊃(Count Energized|KeepHGBD)
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
  ⊃(⇡△|FixMirrors)
  [
    ⊃(
      # from top
      ⊢
      ≡(⊂ 2)
    | # from bottom
      ⊢⇌
      ≡(⊂ 0)
    | # from left
      ⍉⊢⍉
      ≡(⊂ 3)
    | # from right
      ⍉⊢⇌⍉
      ≡(⊂ 1)
    )  ]
  ☇ 1
  ≡(spawn SolveAt)
  wait
  /↥♭
)
---
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

Aeq [1 0 0 1] [OrHGBD 1 0 0 0 0 0 0 1]

Aeq [GoH] [Bounce GoH •]
Aeq [GoG] [Bounce GoG •]
Aeq [GoB] [Bounce GoB •]
Aeq [GoD] [Bounce GoD •]

Aeq [OrHGBD GoH GoB] [Bounce OrHGBD GoH GoB •]
Aeq [OrHGBD GoH GoG] [Bounce OrHGBD GoH GoG •]

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
Aeq [OrHGBD GoB GoH] [Bounce GoD │]
Aeq [OrHGBD GoD GoG] [Bounce GoH ─]

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
; # Aeq 46 PartOne

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
; # Aeq 51 PartTwo

&p "Tests OK"
---
Aeq 7477 &p$"part 1: _s"⍜(×1000)⁅⍜now PartOne &fras "day16.txt"
# Aeq 7853 &p ⍜now PartTwo &fras "day16.txt"
