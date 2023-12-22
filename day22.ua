# Experimental!

Parse ← ↯ ¯1_2_3 ⊜⋕∊:"0123456789".

# ( range1 range2 -- bool )
RangesIntersect ← (
  # sort by min1
  ⍜⊟(⊏⍏.)
  # get max1, min2
  ⊓(⊡1|⊡0)
  # check it's at least min2
  ≤
)
# ( brick1 brick2 -- bool )
Covers ← (|2
  ⊃(
    ∩≡(⊡0)
  | ∩≡(⊡1)
  )
  ∩RangesIntersect
  ↧
)
DropAll ← (
  ⊏⍏≡(⊡0_2).              # sort bricks by increasing z
  ⊙[[[¯∞ ¯∞ ¯∞] [∞ ∞ 0]]] # dropped bricks accumulator: start with ground
  # for each brick to drop
  ∧(
    # -- dropping dropped
    ⊃(
      ⊃∘(
        ¤ # fix dropping
        # -- [dropping] dropped
        ⊃(
          ≡Covers # find potentially supporting dropped bricks
          # -- [covers?]
            | ⋅∘
        )
        # -- [covers?] dropped
        ▽
        # -- covered
        # find max zmax
        ≡(⊡ 1_2)
        /↥
      )
      # -- dropping droppedzmax
      ⊃∘(
        # distance to fall = myzmin - droppedzmax - 1
        ⊡0_2
        -1-:
      )
      # -- dropping falldist
      ⍜(⊡[0_2 1_2])(
        -:
      )
      # -- dropping
    | ⋅∘ # keep dropped
    )
    # -- dropping dropped
    # add dropping to dropped
    ⊂:
  )
  ↘1 # remove ground
)
# ( bricks -- matrix )
SupportMatrix ← (|1
  :¤. # fix a copy
  # -- bricks [bricks]
  ≡(|2
    # -- brick bricks
    ⊃(
      |2   # -- brick bricks
      ⊡0_2 # get zmin
      -1   #  find zmax of supporters
      # -- zmin-1 bricks
      ⊙(⊡1_2 ⍉) # pick zmax from bricks
      =         # match zmin-1 against zmax of bricks
    | |2        # -- brick bricks
      ¤         # fix brick
      ≡Covers   # find covered bricks mask
      # -- coveredmask
    )

    # -- justundermask coveredmask bricks
    # and masks together
    ↧
  )
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
Step ← (
  # get their supportees
  ⊃(/+▽⊙⋅∘|⋅⊙∘)
  # bump down supportercount of supportees
  -
  # find new list of falling bricks
  =0.
  # bump supportcount of fallers to -inf to avoid them falling again
  ⊃(∘|⍜▽(-∞))
)
PartTwo ← (
  Parse
  DropAll
  SupportMatrix
  # compute supporters count
  ≡/+.
  # those on the ground (no supporters) have infinite supporters
  .
  =0
  ⍜▽(+∞)
  # pre-transpose suppportmatrix: becomes list of supportees lists
  ⊙⍉
  ⊠=.⇡⊃(⋅⧻|⊙∘) # range of bricks to remove
  ⊙∩¤          # fix counts and matrix
  ≡(
    # pick a selection to remove
    # ( fallingmask supportercounts supporteesmatrix -- fallingmask' )
    ⍢(
      Step
    | # until fallingmask is all zeroes
      ±/+.
    )
    # count fallers
    ⋅(⧻⊚<0)
    # drop matrix
    ⊙;
  )
  /+
)
---
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

[[0_0_5 0_0_6]
 [0_0_3 0_0_4]]
FindKeepers
Aeq 0_1

Aeq 1 RangesIntersect [0 4][3 5]

[[0 0 3][2 3 4]]
[[1 1 9][1 2 12]]
Aeq 1 Covers

[[0 0 3][0 3 4]]
[[0 1 9][1 3 12]]
Aeq 1 Covers

[[0 0 3][0 3 4]]
[[1 1 9][1 3 12]]
Aeq 0 Covers

$ 1,0,1~1,2,1
$ 0,0,2~2,0,2
$ 0,2,3~2,2,3
$ 0,0,4~0,2,4
$ 2,0,5~2,2,5
$ 0,1,6~2,1,6
$ 1,1,8~1,1,9
Aeq 5 PartOne.

Parse
DropAll
[[1_0_1 1_2_1]
 [0_0_2 2_0_2]
 [0_2_2 2_2_2]
 [0_0_3 0_2_3]
 [2_0_3 2_2_3]
 [0_1_4 2_1_4]
 [1_1_5 1_1_6]]
Aeq

&p "Tests OK"
---
⍤⊃⋅∘≍ 437 &p⍜now PartOne &fras "day22.txt"
⍤⊃⋅∘≍ 42561 &p⍜now PartTwo &fras "day22.txt"
