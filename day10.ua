# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Parse ← ⊜∘ ≠@\n.
FindStart ← ⊢⊚=@S
Letters ← "SJLF7|-."
Directions ← (
  {[0_¯1 1_0 0_1 ¯1_0] # S
   [0_¯1 ¯1_0]         # J
   [¯1_0 0_1]          # L
   [0_1 1_0]           # F
   [1_0 0_¯1]          # 7
   [¯1_0 1_0]          # |
   [0_1 0_¯1]          # -
   ↯ 0_2 []}           # .
)
DirectionsFromLetter ← (
  ⊗ :Letters
  Directions # .
  °□ ⊡:
)
LetterFromDirections ← (
  Directions
  ↧⊃(⊗□|⊗□⇌):
  ⊡:Letters
)

GetStartDirections ← (
  ⊃(⊢|⊡1|⊢⇌)
  ⊃(-|-⊙;)
  ⊟
)

TryPick ← (
  .
  ≥ 0_0
  /↧
  (⋅⋅@.|⊡)
)

Neighbors ← (
  ⊙TryPick.
  ⊙DirectionsFromLetter
  +¤
)

# start -- S-neighbor
FirstStep ← (
  ⊃(
    # get neighbors of S
    Neighbors
  | ⊙∘ # keep matrix
  )
  ⊃(
    # get neighbors for each neighbor of S
    ⊙(¤;)
    ≡(□Neighbors)
  | ⊙∘ # keep S neighbors and start
  )
  # find which neighbors of S have S as a neighbor
  ⊙(¤:)
  ≡(∊: °□)
  ▽
  # pick the first one
  ⊢
)
FindNext ← (
  ⊃(
    ⊙; # drop previous
    Neighbors
  | ⊙⊙∘
  )
  ⊙⋅⊙;
  ⊃(
    ⊙¤
    ¬≡≍
  | ∘
  )
  ▽
  ⊢
)
Step ← ⊃(
  FindNext
| ⊙⋅∘ # keep current, matrix
)
HasArrived ← (
  ⊙⋅∘ # drop previous
  TryPick
  =@S
)
WalkLoop ← (
  1
  ⍢(
    +1
    ⊙Step
  ) (¬⋅HasArrived)
  ⊙⋅⋅;
)

PartOne ← (
  Parse
  # find S
  FindStart.
  # pick a neighbor of S
  ⊃(
    FirstStep
  | ⊙∘ # keep start and matrix
  )
  WalkLoop
  ÷2
)

CollectLoop ← (
  ¤,
  ⍢(
    ⊃(
      ⊂
    | ⋅Step
    )
  ) (¬⋅HasArrived)
  ⊙⋅⋅;
)

CountInside ← (
  ∧(
    # shape, region, count
    (
      (
        # nothing to do: keep region, count
        ⊙∘
        | # empty cell: add region to count
        ⊃(∘|+)
      )=@.
    | # region change
      ⊓(;|¬|∘)
    ) ∊:"F7|".
  ) ⊙(0 0) # start outside, 0 cells found inside
  ⍤⊃⋅∘≍ 0
)

FixStart ← (
  GetStartDirections.
  LetterFromDirections
  ⊙⊢
  :
  ⊙:
  ⍜⊡(;)
)
Crop ← (
  °⊟△    # get bit matrix shape
  ⊙(≡↙¤) # truncate lines
  ↙      # drop extra lines
)
KeepLoopOnly ← (
  °⊚     # convert loop to bit matrix
  ⊃∘Crop # match sizes
  (@.|∘) # replace non-loop chars with `.`
)

PartTwo ← (
  Parse
  # find S
  FindStart.
  # pick a neighbor of S
  ⊃(
    FirstStep
  | ⊙∘ # keep start and matrix
  )
  ⊃(CollectLoop|⋅⋅∘) # extract loop, keep matrix
  ⊙KeepLoopOnly.
  FixStart
  ≡CountInside
  /+
)
---
["..F7."
 ".FJ|."
 "SJ.L7"
 "|F--J"
 "LJ..."]
2_¯1
Neighbors
Aeq ↯ 0_2 []

Aeq [0_¯1 1_0 0_1 ¯1_0] DirectionsFromLetter @S
Aeq [0_¯1 ¯1_0] DirectionsFromLetter @J
Aeq [¯1_0 0_1] DirectionsFromLetter @L
Aeq [0_1 1_0] DirectionsFromLetter @F
Aeq [1_0 0_¯1] DirectionsFromLetter @7
Aeq [¯1_0 1_0] DirectionsFromLetter @|
Aeq [0_1 0_¯1] DirectionsFromLetter @-
Aeq ↯ 0_2 [] DirectionsFromLetter @.

["..F7."
 ".FJ|."
 "SJ.L7"
 "|F--J"
 "LJ..."]
# find S
FindStart.
# pick a neighbor of S
⊃(
  FirstStep
| ⊙∘ # keep start and matrix
)
WalkLoop
Aeq 16

Aeq 0 CountInside "....."
Aeq 1 CountInside ".|.|."
Aeq 0 CountInside ".|-|."
Aeq 1 CountInside ".FJ.|"

$ ..F7.
$ .FJ|.
$ SJ.L7
$ |F--J
$ LJ...

Aeq 8 PartOne.

Aeq 1 PartTwo

$ FF7FSF7F7F7F7F7F---7
$ L|LJ||||||||||||F--J
$ FL-7LJLJ||||||LJL-77
$ F--JF--7||LJLJ7F7FJ-
$ L---JF-JLJ.||-FJLJJ7
$ |F|F-JF---7F7-L7L|7|
$ |FFJF7L7F-JF7|JL---7
$ 7-L-JL7||F7|L7F-7F7|
$ L.L7LFJ|||||FJL7||LJ
$ L7JLJL-JLJLJL--JLJ.L
⍤⊃⋅∘≍ 10 PartTwo

&p "Tests OK"

---

Aeq 7102 PartOne &fras "day10.txt"
Aeq 363 PartTwo &fras "day10.txt"
