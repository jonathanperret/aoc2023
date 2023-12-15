# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Hash ← ∧(◿ 256 × 17 + -@\0) : 0
Split ← ⊜□¬∊:",\n".
PartOne ← /+≡(Hash °□) Split
EmptyBox ← ↙0 [{"x" 1}]
EmptyBoxes ← ▽ : □EmptyBox
ApplyToBox ← (
  ⊃(
    ∊ @= ; # check instruction type
  | ⋅∘     # keep box
  | ∘      # keep instruction
  )
  (
    # -
    ⊓(
      □▽ ≥@a. # keep only label, box it
    | ≡⊢.     # extract pair labels
    )
    ▽≠ # keep non-matching
  |    # 
    # =
    ∩□ ⊃(▽ ≥@a.|⋕▽ ∊:"0123456789".) # parse instruction
    ⊃(
      ⊙(≡⊢.;) # extract pair labels
      =       # match new label
    | ⊟       # prepare new pair
    )
    /+. # any label matched?
    (
      ⊂ ;   # append new pair
    | ⊢⊚    # get index of match
      ⍜⊡ ⋅∘ # replace pair
    )
  )
)
Exec ← (|2
  ⊃(
    ▽ ≥@a. # keep only label
  | ⋅∘     # keep boxes
  | ∘      # keep instruction
  )
  Hash              # find index of box
  ⍜(°□⊡) ApplyToBox # apply to right box
)
ExecAll ← ∧(Exec °□)
ScoreBox ← (
  ±⧻. # check for empty box
  (
    0
  | ≡(°□⊡1)
    +1⇡⧻.
    ×
    /+
  )
)
ScoreBoxes ← (
  ≡(ScoreBox °□)
  +1⇡⧻.
  ×
  /+
)
PartTwo ← (
  Split
  EmptyBoxes 256
  :
  ExecAll
  ScoreBoxes
)
---
$ HASH
Aeq 52 Hash

$ rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7\n
⍤⊃⋅∘≍ 1320 PartOne

Aeq [{"rn" 1}] ApplyToBox EmptyBox "rn=1"

Aeq [{"rn" 1}] ApplyToBox [{"rn" 1}] "cm-"
Aeq EmptyBox ApplyToBox [{"rn" 1}] "rn-"

Aeq [{"rn" 1}{"cm" 2}] ApplyToBox [{"rn" 1}] "cm=2"

Aeq [{"ot" 7}{"abc" 5}] ApplyToBox [{"ot" 9}{"abc" 5}] "ot=7"

EmptyBoxes 1
$ rn=1
Exec
Aeq {[{"rn" 1}]}

EmptyBoxes 4
{"rn=1" "cm-" "qp=3" "cm=2" "qp-" "pc=4" "ot=9" "ab=5" "pc-" "pc=6" "ot=7"}
ExecAll
Aeq {[{"rn" 1} {"cm" 2}] EmptyBox EmptyBox [{"ot" 7} {"ab" 5} {"pc" 6}]}

Aeq 5 ScoreBox [{"rn" 1} {"cm" 2}]
Aeq 35 ScoreBox [{"ot" 7} {"ab" 5} {"pc" 6}]
Aeq 0 ScoreBox EmptyBox

Aeq 145 ScoreBoxes {[{"rn" 1} {"cm" 2}] EmptyBox EmptyBox [{"ot" 7} {"ab" 5} {"pc" 6}]}

$ rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
⍤⊃⋅∘≍ 145 PartTwo

&p "Tests OK"
---
Aeq 514394 PartOne &fras "day15.txt"
Aeq 236358 PartTwo &fras "day15.txt"
