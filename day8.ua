# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

# input -- program namelist links
Parse ← (
  ⊜□ ≠@\n. # split lines
  ⊃(
    °□ ⊢ # get program line
    =@R  # convert program to 0/1
  | ↘1   # drop program line
    # extract node names and links
    ≡(
      °□
      ⊃(
        ↙3                # node name
        | [⊃(↙3↘7|↙3↘12)] # left and right links
      )
    )
    ⊃(
      ∘  # keep name list for later
    | :¤ # fix name list
      ≡⊗ # lookup left & right node names
      ⍉  # put in rows
    )
  )
)

# instr node endnodes links -- newnode endnodes links
ExecuteInstruction ← (
  ⊃(
    ⊃(
      ⋅∘    # get current node
    | ⊡⊙⋅⋅∘ # pick link row from instruction
    )
    ⊡    # lookup target node
  | ⋅⋅⊙∘ # keep end list and links
  )
)

# node endnodes -- bool
EndReached ← ∊

# pc program node ends links -- pc+1 program newnode endnodes links
ProgramStep ← (
  ⊃(
    +1 # increment program counter
    ⊙∘ # keep program
  | ⧻, # get program length
    ◿  # pc mod program length
    ⊡  # get instruction
    ExecuteInstruction
  )
)

# namelist -- startnode endnodes
FindSingleStartEnd ← (
  ⊃(
    ⊗"AAA"  # index of start node
  | ¤⊗"ZZZ" # indices of end nodes
  )
)

# namelist -- startnodes endnodes
FindMultiStartEnd ← (
  ≡(⊢⇌) # last letter of each name
  ⊃(
    ⊚=@A # indices of start nodes
  | ⊚=@Z # indices of end nodes
  )
)

# program, startnode, endnodes, links
WalkToEnd ← (
  0 # program counter
  ⍢ProgramStep (¬⋅⋅EndReached)
  ⊙⋅⋅⋅; # drop state
)

# program, startnode, endnodes, links
Draw ← (
  0            # program counter
  ⊃([⋅⋅∘]|⊙⊙∘) # init trace with startnode
  ⍥(
    ⊙ProgramStep
    ⊂⊃(⊙⋅⋅∘|⋅⊙⊙∘) # add node to trace
  ) 1000
  ⊙⋅⋅⋅⋅(¤⊢⇌△) # get node count
  ≡(⬚0↯¤:°⊚)
)

Colorize ← ⍉[⊃(×⊙⋅⋅∘|×⋅⊙⋅∘|×⋅⋅∘)] °[⊙⊙∘]
Palette ← ⋯+1⇡7

DrawAll ← (
  Parse
  ⊙FindMultiStartEnd
  ⊓(¤|∘|¤|¤) # fix program, endnodes, links
  ≡Draw      # for each startnode
  ⧻.
  ⊟:3
  ↯: Palette
  ≡Colorize
  /+
  &ims
)

PartOne ← (
  Parse
  ⊙FindSingleStartEnd
  WalkToEnd
)

# program, startnodes, endnodes, links
FindPeriods ← (
  ⊓(¤|∘|¤|¤) # fix program, endnodes, links
  ≡WalkToEnd # run program for each startnode
)

GCD ← ;⍢(
  ⊃↧↥ # put smaller number on top
  ⊃◿∘ # remove smaller from larger
) (≠0)
LCM ← ×÷GCD,, # lcm(a,b) = ab/gcd(a,b)

PartTwo ← (
  Parse
  ⊙FindMultiStartEnd
  FindPeriods
  /LCM
)
---
$ RL
$
$ AAA = (BBB, CCC)
$ BBB = (DDD, EEE)
$ CCC = (ZZZ, GGG)
$ DDD = (DDD, DDD)
$ EEE = (EEE, EEE)
$ GGG = (GGG, GGG)
$ ZZZ = (ZZZ, ZZZ)
Aeq 2 PartOne

$ LLR
$
$ AAA = (BBB, BBB)
$ BBB = (AAA, ZZZ)
$ ZZZ = (ZZZ, ZZZ)
⍤⊃⋅∘≍ 6 PartOne

Aeq 0 EndReached 2 1_6_7
Aeq 1 EndReached 1 1_0

Aeq 12 GCD 36 48
Aeq 1 GCD 79 99

Aeq 42 LCM 21 6

$ LR
$
$ 11A = (11B, XXX)
$ 11B = (XXX, 11Z)
$ 11Z = (11B, XXX)
$ 22A = (22B, XXX)
$ 22B = (22C, 22C)
$ 22C = (22Z, 22Z)
$ 22Z = (22B, 22B)
$ XXX = (XXX, XXX)
Aeq 6 PartTwo

&p "Tests OK"

---
Aeq 18023 PartOne &fras "day8.txt"
Aeq 14449445933179 PartTwo &fras "day8.txt"

# DrawAll &fras "day8.txt"
