# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

# Constants
B ← 0
F ← 1
C ← 2
High ← 1
Low ← 0
Off ← 0
On ← 1

# Type assertions
IsID ← /↧[⊃(=⁅.|=0⧻△|=0type)]
ID ← ⍤⊃($"id _"|IsID|∘)
From ← ⊃⊙∘⊓(⍤⊃$"from _"IsID|⍤⊃$"level _"(∊:[Low High]))
To ← ⍤⊃($"dest _"|IsID|∘)
State ← ⍤⊃($"state _"|=0type|∘)
Type ← ⍤⊃($"type _"|∊:0_1_2|∘)
Inputs ← ⍤⊃($"inputs _"|±/↧≡IsID|∘)
Outputs ← ⍤⊃($"outputs _"|±/↧≡IsID|∘)

# ( text -- types names outputlists )
Parse ← (|1.3
  ⊜(⊂∩□⊃(Type ◿3 ⊗:"b%&"⊢|⊜(□) ¬∊:" ->,".▽¬∊:"&%".)) ≠@\n.
  ∩°□°⊟⍉
  ⊓(
    ≡(Type °□)
  | ≡(⊃(⊢|⍜°□(↘1)))
  )
  ⍏. # sort by type (broadcaster first)
  ⊃(≡Type ⊏|⊏⊙⋅∘|⊏⊙⋅⋅∘)
)
# ( types names outputlists -- )
Dot ← (
  ≡(
    ⊙(
      # build edges
      ∩°□
      ⊙(↘¯1 °□/⊐⊂ ≡(⍜°□($"\"_\",")))
    )
    # -- type name neighbors
    ("color=black"|"shape=Mcircle"|"shape=pentagon")
    # -- color name neighbors
    ,
    # -- name color name neighbors
    $"\"_\" [_]\n\"_\" -> _\n"
    □
  )
  $"digraph {\n_}"/⊐⊂
  &fwa "day20.dot"
)
# ( needle haystack -- index )
SafeIndexOf ← (
  ⊃(
    ⊗
  | ⋅⧻
  | ⊙∘
  )
  ⊃∘(
    # -- index len needle haystack
    ⍤⊃($"_ not found in _";;|>)
  )
)
# ( names outputlists -- outputlists' )
NamesToIDs ← (
  # -- names outputlists
  :¤
  # -- outputlists [names]
  ≡⍜°□(
    ±⧻.
    (
      ;;
      Outputs []
    | ⊙¤ # fix names
      ≡SafeIndexOf
      Outputs
    )
  )
  # -- outputlists'
)
# ( outputlists -- inputslist )
FindInputs ← (
  ⊃(⇡⧻)¤ # make ids, fix outputlists
  # -- ids outputlists
  ≡⍜°□(
    # -- id outputlists
    ≡(∊⊙°□) # membership of my index in all outputlists
    # -- membershipbits
    Inputs ⊚
  )
)

# ( nodes -- states )
InitStates ← (|1
  ≡(
    °{⊙⊙∘}↙3
    # -- type outputs inputs
    ⊙⋅∘
    # -- type inputs
    (
      # broadcaster: no state
      []
    | # flip-flop: one bit
      0
    | # conjunction: one bit per input
      ≡⋅0
    )
    □
  )
)

# ( types names nameoutputlists -- nodes<type outputs inputs name> )
Prepare ← (
  ⊓(⊂ B|⊂ □"button"|⊂ □{"broadcaster"})

  ⊃(⊙NamesToIDs|⋅∘)
  ⊙⊃∘FindInputs
  ≡{⊓(Type ∘|Outputs °□|Inputs °□|°□)}
  InitStates.
)

# ( -- pulsequeue )
NewPulseQueue ← ↯ 0_3 0 # -- [targetnode fromnode level]
# ( -- history )
NewHistory ← ↯0_3 0

# ( id nodes -- name )
LookupName ← (
  ⊡
  ⊡3
  °□
)

# ( history nodes -- string )
DumpHistory ← (|2
  ⊙¤ # fix nodes
  ≡(
    # -- pulse nodes
    ⊃(
      ⊡ 1
      LookupName
    | ⊡ 2
      ("low"|"high")
    | ⊡ 0
      LookupName
    )
    □$"_ -_-> _\n"
  )
  /⊐⊂
)

# ( pulsequeue -- pulsequeue' )
PushButton ← (
  # pulse from button to broadcaster
  ⊂ [[To 1 From 0 Low]] # -- [targetnode fromnode level]
)

# ( level outputs -- [target level] )
Broadcast ← ≡[From] :¤

# ( from level state type outputs inputs -- state' [target level] )
ApplyPulse ← (
  # switch on node type
  ⊃(⋅⋅⋅∘|⊙⊙⊙⋅∘)
  (
    # - broadcast: empty state, copy level to outputs
    # -- from level state outputs inputs
    ⊃(State []|Broadcast ⋅⊙⋅∘)
    #
  | # - flip-flop: if level low: flip state, make pulse from state
    # -- from level state outputs inputs
    ⋅⊙⊙⊙;
    # -- level state outputs
    # switch on level
    (
      # low: flip state, make pulse
      ⊃(State ¬) (Broadcast ¬)
      #
    | # high: do nothing
      ⊃(State ∘) []
    )
  | # - conjunction: set state from source, make pulse from nand state
    # -- from level state outputs inputs
    # locate from in inputs
    ⊃(⊗ ⊙⋅⋅⋅∘|⋅⊙⊙∘)
    # -- fromindex level state outputs
    State ⍜⊡⋅∘ ⊙: # patch state
    # -- state' outputs
    ⊃(State ∘) (Broadcast ¬/↧) # broadcast nand of states
  )
)

# ( pulse states nodes -- pulses states' )
ProcessPulse ← (|3.2
  To ⊙From °{⊙⊙∘} # split pulse
  # -- to from level states nodes
  # prepare to pick target state and node
  ⊃(To ⊙⋅⋅∘|To ⊙⋅⋅∘|To ⊙⋅⋅⋅∘|⋅⊙∘)
  ⊙⊙(
    # -- to states to nodes from level
    ∩⊡
    # -- □state node from level
    ⊃(⋅⋅⊙∘|°□|⋅(°{⊙⊙∘}↙3))
    # -- from level state type outputs inputs
    ApplyPulse
    # -- state' [target level]
    State
  )
  # -- to states state' [target level]
  ⊃(
    ¤⊙⋅⋅∘
    ⊃(⋅(±⧻)|⊙∘) # check new pulses length
    (
      [] # no new pulses
    | ⊙(°⊟⍉)
      # -- [to] [target] [level]
      :
      # -- [to] [level] [target]
      ≡[⊙⊙∘]
      # -- [target to level]
    )
  | ⍜⊡⋅□ # replace state
  )
  # -- pulses states'
)

# ( history pulsequeue states nodes -- pulsequeue' states' )
ProcessNextPulse ← (|4.3
  # -- history pulsequeue states nodes
  ⊃(
    # -- history pulsequeue
    ⊂ ⊙⊢  # move first to history
  | ⋅(↘1) # pop one off
  | ⋅(
      ⊢
      # -- pulse states nodes
      ProcessPulse
    )
  )
  # -- pulsequeue' newpulses states'
  ⊙⊂ # append new pulses
)

# ( history pulsequeue states nodes -- history pulsequeue' states' nodes )
Step ← (|4.4
  ⊙⊙⊙. # save nodes ( fork alternative breaks interpreter: ⊃(ProcessNextPulse|⋅⋅∘) )
  ProcessNextPulse
)

# ( history -- score )
ScoreHistory ← (|1
  ⊢⇌⍉
  ⊃(/+|/+¬)
  ×
)

PartOne ← (
  ⊂: "\nrx ->\n"
  Parse
  Prepare
  # -- states nodes
  NewPulseQueue
  NewHistory
  # -- history pulsequeue states nodes
  ⍥(
    ⊙PushButton
    ⍢(Step|±⋅⧻)
  )1000
  ⊙(;;;)
  ScoreHistory
)
---
$ broadcaster -> a
$ %a -> inv, con
$ &inv -> b
$ %b -> con
$ &con -> output
$ output ->
Aeq 11687500 PartOne

$ broadcaster -> a, b, c
$ %a -> b
$ %b -> c
$ %c -> inv
$ &inv -> a
Aeq 32000000 PartOne

# *** ProcessNextPulse ***
# ( history pulsequeue states nodes -- history' pulsequeue' states' )
[{Type F Outputs 1_2 Inputs [3] "a"} {"t" "o" "i" "n"}]
{State On "otherstate"}
[[To 0 From ¯1 Low] [To 10 From 20 Low]]
[[To ¯1 From ¯2 High]]
ProcessNextPulse
Aeq {[[To ¯1 From ¯2 High][To 0 From ¯1 Low]]
     [[To 10 From 20 Low] [To 1 From 0 Low] [To 2 From 0 Low]]
     {State Off "otherstate"}} {⊙⊙∘}

# *** ProcessPulse ***

# ( pulse states nodes -- pulses states' )
[{Type B Outputs 1_2_3 Inputs [] "a"} {"t" "o" "i" "n"}]
{State [] "otherstate"}
[To 0 From ¯1 High]
ProcessPulse
Aeq {[[To 1 From 0 High] [To 2 From 0 High] [To 3 From 0 High]] {State [] "otherstate"}} {⊙∘}

# ( pulse states nodes -- pulses states' )
[{Type F Outputs 1_2 Inputs [3] "a"} {"t" "o" "i" "n"}]
{State On "otherstate"}
[To 0 From ¯1 Low]
ProcessPulse
Aeq {[[To 1 From 0 Low] [To 2 From 0 Low]] {State Off "otherstate"}} {⊙∘}

# *** ApplyPulse ***

# BROADCASTER
# ( from level state type outputs inputs -- state' [target level] )
From 0 High State [] Type B Outputs 1_2_3 Inputs []
ApplyPulse
Aeq {State [] [[To 1 High] [To 2 High] [To 3 High]]} {⊙∘}

# FLIP FLOP
# ( from level state type outputs inputs -- state' [target level] )
From 0 High State On Type F Outputs 1_2 Inputs [3]
ApplyPulse
Aeq {State High []} {⊙∘}

# ( from level state type outputs inputs -- state' [target level] )
From 0 Low State On Type F Outputs 1_2 Inputs [3]
ApplyPulse
Aeq {State Off [[To 1 Low] [To 2 Low]]} {⊙∘}

# CONJUNCTION
State [Low High High] Type C Outputs 1_2 Inputs 7_8_9
From 7 High
ApplyPulse
Aeq {[High High High] [[To 1 Low] [To 2 Low]]} {⊙∘}

State [Low High Low] Type C Outputs 1_2 Inputs 7_8_9
From 7 High
ApplyPulse
Aeq {[High High Low] [[To 1 High] [To 2 High]]} {⊙∘}

&p "Tests OK"
---
# Dot Parse &fras "day20.txt"
⍤⊃⋅∘≍ 839775244 PartOne &fras "day20.txt"
# Aeq 0 PartTwo &fras "day20.txt"
