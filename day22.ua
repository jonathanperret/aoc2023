# Experimental!

Parse ← ↯ ¯1_2_3 ⊜⋕∊:"0123456789".

# ( bricks -- matrix )
CoverMatrix ← (
  °⊟↙2°⍉ # get xs,ys
  ↧∩(
    # for each axis
    °⊟⍉        # split 1 from 2
    ↧⊃(≥¤|≥⊙¤) # xmin1 <= xmax2 && xmin2 <= xmax1
  )
)

# ( bricks -- matrix )
UnderMatrix ← (
  =⊃(-1⊡0_2⍉)(¤⊡1_2 ⍉) # match zmin-1 against zmax of others
)

Log ← &p $"_: _"

DropAll ← Log "dropall" ⍜now(
  ⊏⍏≡(⊡0_2). # sort bricks by increasing z
  ⊃(
    ×>¤.⇡⧻.CoverMatrix # undermatrix
  | -⊃(⊡0_2|⊡1_2)⍉     # heights(-1)
  | ⇡⧻                 # indices
  | .⊡1_2⍉             # initial and saved zmaxes
  | ∘                  # saved bricks
  )
  ∧(
    # -- undermask height index zmaxes
    ⊃(
      ⊙⋅⋅∘
      +1/↥× # new zmin = max of under zmaxes + 1
    | ⋅⊙⊙∘  # -- height index zmaxes
    )
    +        # newzmax = newzmin + add my height
    ⊃(⋅⊙∘|∘) # move newzmax down
    ⍜⊡(⋅∘)   # save new zmax
  )
  # -- newzmaxes savedzmaxes bricks
  -:        # -- deltas bricks
  ⍜(⊡2°⍉)+: # add deltas to all z
)

# ( bricks -- matrix )
SupportMatrix ← Log"supportmatrix"⍜now(
  ↧⊃CoverMatrix UnderMatrix
)

# ( bricks -- keepersmask )
FindKeepers ← (|1
  # ⊏⍏≡(⊡0_2). # sort bricks by increasing z
  SupportMatrix
  # find bricks supported by a single other
  =1/+⍉.
  # find the supporters for those
  /↥▽
  # these are the keepers
  # -- tokeep
)

CountRemovable ← (
  ⊃(/+ FindKeepers|⧻)
  -
)
PartOne ← (
  Parse
  DropAll
  CountRemovable
)

# ( fallingid supportercounts supporteesmatrix -- fallercount )
Cascade ← (
  ⍢(
    ⊃(/+▽⊙⋅∘|⋅⊙∘) # get supportees of falling bricks
    -             # bump down their supportercount
    =0.           # find new list of falling bricks
    ⊃∘⍜▽(-∞)      # drop supportcount of fallers to -inf to avoid them falling again
  | /↥            # until fallingmask is all zeroes
  )
  ⋅⊙;  # cleanup
  ⧻⊚<0 # count fallers: negative supportercount
)
CascadeAll ← (
  SupportMatrix
  ⍉           # transpose suppportmatrix: becomes list of supportees lists
  /+.         # compute supporters count
  ⍜▽(+∞) =0 . # those on the ground (no supporters) have infinite supporters
  =¤.⇡⧻.      # initial fallingmasks (identity matrix)
  ⊙∩¤         # fix counts and matrix
  ≡wait≡spawn Cascade
)
PartTwo ← (
  Parse
  DropAll
  CascadeAll
  /+
)
---
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

[[0_0_5 0_0_6]
 [0_0_3 0_0_4]]
FindKeepers
Aeq 0_1

$ 1,0,1~1,2,1
$ 0,0,2~2,0,2
$ 0,2,3~2,2,3
$ 0,0,4~0,2,4
$ 2,0,5~2,2,5
$ 0,1,6~2,1,6
$ 1,1,8~1,1,9
Aeq 5 PartOne.
Aeq 7 PartTwo.

Parse.
DropAll
[[1_0_1 1_2_1]
 [0_0_2 2_0_2]
 [0_2_2 2_2_2]
 [0_0_3 0_2_3]
 [2_0_3 2_2_3]
 [0_1_4 2_1_4]
 [1_1_5 1_1_6]]
Aeq

Parse
SupportMatrix
Aeq [[0 0 0 0 0 0 0]
     [1 0 0 0 0 0 0]
     [0 0 0 0 0 0 0]
     [0 0 1 0 0 0 0]
     [0 0 0 0 0 0 0]
     [0 0 0 0 1 0 0]
     [0 0 0 0 0 0 0]]

&p "Tests OK"
---
&fras "day22.txt"
⍤⊃⋅∘≍ 437 Log"part1"⍜now PartOne.
⍤⊃⋅∘≍ 42561 Log"part2"⍜now PartTwo
