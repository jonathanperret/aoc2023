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
FindKeepers ← (
  ⊏⍏≡(⊡0_2). # sort bricks by increasing z
  :¤.        # fix a copy
  ≡(
    # -- brick bricks
    ⊃∘(
      ⊡0_2 # get zmin
      -1   #  find zmax of supporters
      # -- zmin-1 bricks
      ⊙(≡(⊡1_2).) # pick zmax from bricks
      =           # match zin-1 against zmax of bricks
      # keep only matching
      ▽
    )
    # -- brick justunder
    ¤             # fix brick
    ⊃(≡Covers|⋅∘) # find covered bricks
    ▽♭
    # -- supporters
    =1⧻. # only one supporter?
    # if so, keep it
    (
      ⋅[]
    | ∘
    )
    □
  )
  ≠□[].
  ≡°□▽
  ☇2
  ⊝
  # -- tokeep
)
CountRemovable ← (
  ⊃(⧻FindKeepers) ⧻
  -
)
PartOne ← (
  Parse
  DropAll
  CountRemovable
)
---
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

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
Aeq 5 PartOne

&p "Tests OK"
---
⊃⋅∘≍ 0 PartOne &fras "day22.txt"
# ⍤⊃⋅∘≍ 0 &p⍜now PartTwo &fras "day22.txt"
