# Experimental!

Parse ← ⊜∘≠@\n.
Directions ← [0_1 ¯1_0 0_¯1 1_0]
AllowedDirs ← (
  ⊗: ".>v"
  (
    Directions
  | [0_1 0_0 0_0 0_0]
  | [0_0 0_0 0_0 1_0]
  )
)
Step ← (
  # -- continue path grid next
  ⍤"flag should be 1" # drop continue flag
  ⊃(
    ⊢⇌ # last step
    ⊃(
      ⊃(⊡|∘) # look it up in grid
      AllowedDirs
      ⊙¤
      +       # get neighbor coordinates
    | ⍜⊡(⋅@#) # patch grid to avoid backtracking
    )
    ⊃(⬚@#⊡)⊙∘        # look neighbors up in grid
    ▽↥⊃(=@.|=">..v") # keep only walkable
  )∘                 # keep path
  # -- neighbors grid path next
  ⧻. # switch on count of walkable neighbors
  (
    # 0 neighbors: nothing else to do
    # -- neighbors grid path next
    ⊃(⋅⋅⋅⋅0|⋅⋅∘|⋅∘|[])
    # -- continue path grid next
  | # 1 neighbor
    # -- neighbors grid path next
    ⊃(∘|⋅⋅∘|⋅∘|⋅⋅⋅∘) # -- neighbors path grid next
    ⊂:               # add it to path
    1                # continue
  |                  # >1 neighbors
    # -- neighbors grid path next
    ⊃(
      ⊃(⋅⋅⋅⋅0|⋅⋅∘|⋅∘) # -- continue path grid
    | ∘               # next = neighbors
    )
  )
)
# ( start grid -- path next grid' )
WalkFrom ← (
  ¤    # init path with start
  ⊙⊙[] # next to explore
  1    # continue flag
  ⍢Step∘
  ⍤"continue should be 0"=0
  ⊙:
)
# ( paths grid -- grid' )
ShowPaths ← (
  +@a⇡⧻.
  ∧(
    ⊙°□
    # -- letter path grid
    # ⊃(⋅⊙∘|∘)
    # -- path grid letter
    # ⍜(⊡)(∵⋅@!)
    :
    ⊙:
    ⍜⊡(
      ≡(⋅∘)
    )
  )
  ⍜⊡(≡(⋅@ ))⊚=@#.
)
SuperStep ← (|3.3
  # -- paths' queue'' grid
  ⊙(
    ⊃(
      ↘1
    | ⊃(⊙⊙; □WalkFrom ⊢|⋅∘)
    ) # process next in queue
  )
  # -- paths queue' path next grid
  ⊃(
    ⊂ ⊙⋅∘  # append path
  | ⊂ ⋅⊙⋅∘ # append next
  )
  # -- paths' queue'' grid'
)
FinalStep ← (
  ⊃(
    # check for empty successorsets
    ±/+⍉.
    ⊙⊙⊙(∩¤)
    ≡(
      # do nothing if empty
      ∩¤:
      ∩□
    |                  # -- successorset length pathmatrix pathlengths
      ⊃(▽⊙⋅⋅∘|▽⊙⋅∘|⊙∘) # get successors lengths and successors
      # -- succlengths succsuccs successorset length pathmatrix pathlengths
      ⊃(+⊙⋅⋅∘|⋅∘) # add its length
      ∩□
      # -- totallengths succsuccs
    )
    :
    # flatten results
    ⊓(°□/⊐⊂|°□/⊐⊂)
  | ⋅⋅⊙∘
  )
)
PartOne ← (
  Parse
  [0_1] # queue
  []    # paths
  # ( paths queue grid -- paths' queue' grid' )
  ⍢(SuperStep|±⋅⧻)
  ⊙;               # drop queue
  ⊝                # remove duplicate paths
  ⊙;               # drop grid
  ≡(⊃(⊡0|⊡¯1|⧻)°□) # keep starts, ends, lengths
  -1°⊚▽+1⇡⧻.       # make matrix of start path ids
  :                # ends startmatrix lengths
  ⊠+:Directions    # get neighbors of path ends
  ⬚¯1⊡             # lookup path neighbors
  ⬚0≡(°⊚▽≥0.)      # build path adjacency matrix
  # -- pathmatrix pathlengths
  # now we just have to walk all paths through this graph
  0            # start path
  ⊃(⊡|⊡⊙;|⋅⊙∘) # get its successors and length
  ∩¤
  ⍢(FinalStep|±⧻⊚)
  # -- successorsets lengths pathmatrix pathlengths
  ⋅⊙⋅; # keep just lengths
  -1   # final fudge
  /↥   # the answer
)
---
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

$ #.#####################
$ #.......#########...###
$ #######.#########.#.###
$ ###.....#.>.>.###.#.###
$ ###v#####.#v#.###.#.###
$ ###.>...#.#.#.....#...#
$ ###v###.#.#.#########.#
$ ###...#.#.#.......#...#
$ #####.#.#.#######.#.###
$ #.....#.#.#.......#...#
$ #.#####.#.#.#########v#
$ #.#...#...#...###...>.#
$ #.#.#v#######v###.###v#
$ #...#.>.#...>.>.#.###.#
$ #####v#.#.###v#.#.###.#
$ #.....#...#...#.#.#...#
$ #.#########.###.#.#.###
$ #...###...#...#...#.###
$ ###.###.#.###v#####v###
$ #...#...#.#.>.>.#.>.###
$ #.###.###.#.###.#.#v###
$ #.....###...###...#...#
$ #####################.#
Aeq 94 PartOne

&p "Tests OK"
---
⍤⊃⋅∘≍ 2070 PartOne &fras "day23.txt"
# ⍤⊃⋅∘≍ 0 now PartTwo &fras "day23.txt"
