# Experimental!

Parse ← ⊜∘≠@\n.
Directions ← [0_1 ¯1_0 0_¯1 1_0]
AllowedDirs ← (
  ⊗: ".>v"
  (
    Directions
  | [0_1 1e3_1e3 1e3_1e3 1e3_1e3]
  | [1e3_1e3 1e3_1e3 1e3_1e3 1_0]
  | [1e3_1e3 1e3_1e3 1e3_1e3 1e3_1e3] # you're stuck, man
  )
)
WalkFromStep ← (
  # -- continue path grid next
  ⍤"flag should be 1" # drop continue flag
  ⊃(
    ⊢⇌ # get last step
    ⊃(
      ⊃(⊡|⊙∘) # look it up in grid
      AllowedDirs
      +⊙¤ # get neighbor coordinates
      ## ╭─       ╭─      ╭─      ╭─      ╭─      ╭─      ╭─      ╭─      ╭─      ╭─      ╭─      ╭─      ╭─      ╭─      ╭─            ╭─      ╭─            ╭─      ╭─      ╭─      ╭─      ╭─      ╭─      ╭─…
      ## ╷  0 2   ╷ 1 2   ╷ 1 3   ╷ 1 4   ╷ 1 5   ╷ 1 6   ╷ 1 7   ╷ 1 8   ╷ 2 8   ╷ 3 8   ╷ 3 7   ╷ 3 6   ╷ 3 5   ╷ 3 4   ╷ 1004 1003   ╷ 5 4   ╷    5    5   ╷ 5 6   ╷ 5 7   ╷ 5 8   ╷ 6 8   ╷ 7 8   ╷ 8 8   ╷ …
      ##   ¯1 1     0 1     0 2     0 3     0 4     0 5     0 6     0 7     1 7     2 7     2 6     2 5     2 4     2 3     1004 1003     4 3     1005 1004     4 5     4 6     4 7     5 7     6 7     7 7     …
      ##    0 0     1 0     1 1     1 2     1 3     1 4     1 5     1 6     2 6     3 6     3 5     3 4     3 3     3 2     1004 1003     5 2     1005 1004     5 4     5 5     5 6     6 6     7 6     8 6     …
      ##    1 1     2 1     2 2     2 3     2 4     2 5     2 6     2 7     3 7     4 7     4 6     4 5     4 4     4 3        5    3     6 3     1005 1004     6 5     6 6     6 7     7 7     8 7     9 7     …
      ##        ╯       ╯       ╯       ╯       ╯       ╯       ╯       ╯       ╯       ╯       ╯       ╯       ╯       ╯             ╯       ╯             ╯       ╯       ╯       ╯       ╯       ╯       ╯   …
      ⊃(⬚@#⊡|∘)        # look neighbors up in grid
      ▽↥⊃(=@.|=">..v") # keep only walkable
    | ⍜⊡(⋅@#)          # patch grid to avoid backtracking
    )
  )∘ # keep path
  # -- neighbors grid path next
  =1⧻. # switch on count of walkable neighbors
  (
    # -- neighbors grid path next
    ⊃(
      ⊃(⋅⋅⋅⋅0|⋅⋅∘|⋅∘) # -- continue path grid
    | ∘               # next = neighbors
    )
  | # 1 neighbor
    # -- neighbors grid path next
    ⊃(∘|⋅⋅∘|⋅∘|⋅⋅⋅∘) # -- neighbors path grid next
    ⊂:               # add it to path
    1                # continue
  )
)
# ( start grid -- path next grid' )
WalkFrom ← (
  ¤    # init path with start
  ⊙⊙[] # next to explore
  1    # continue flag
  ⍢WalkFromStep∘
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
MakePathsStep ← (|3.3
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
MakePaths ← (
  [0_1] # queue
  []    # paths
  # ( paths queue grid -- paths' queue' grid' )
  ⍢(MakePathsStep|±⋅⧻)
  ⊙; # drop queue
  ⊝  # remove duplicate paths
  ⊙; # drop grid
)
MakePathMatrix ← (
  ≡(⊃(⊡0|⊡¯1|⧻)°□) # keep starts, ends, lengths
  -1°⊚▽+1⇡⧻.       # make matrix of start path ids
  :                # ends startmatrix lengths
  ⊠+:Directions    # get neighbors of path ends
  ⬚¯1⊡             # lookup path neighbors
  ⬚0≡(°⊚▽≥0.)      # build path adjacency matrix
)
FindLongestPathStep ← (
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
FindLongestPath ← (
  # -- pathmatrix pathlengths
  # now we just have to walk all paths through this graph
  0            # start path
  ⊃(⊡|⊡⊙;|⋅⊙∘) # get its successors and length
  ∩¤
  ⍢(FindLongestPathStep|±⧻⊚)
  # -- successorsets lengths pathmatrix pathlengths
  ⋅⊙⋅; # keep just lengths
  -1   # final fudge
  /↥   # the answer
)
PartOne ← (
  Parse
  MakePaths
  MakePathMatrix
  FindLongestPath
)
# ( grid -- grid' )
AddBorder ← (
  ⬚∘(↻¯1_¯1↙+2_2△.) @#
)
FindNodes ← (
  ⊃(◫3_3|△) # assumes padded grid
  ≡≡(
    ≠@#
    ↧ ⊃(
      ⊡1_1
    | ≠2 /+ ⊡+1Directions
    )
  )
  ⬚0(↻¯1_¯1↙): # restore border lost by ◫
)
# ( start first grid -- path next grid' )
WalkFromInto ← (
  ⊃(
    ⋅∘
  | ⊙⋅∘
    ⍜⊡(⋅@#) # patch grid to avoid backtracking
  )
  WalkFrom
)

# ( start grid -- lenghts+ends )
PathsFrom ← (
  +Directions¤.
  :
  ¤
  ⊙⊙¤
  ≡(
    ⊓({⊃(⧻|⊢⇌)}|⋅;)WalkFromInto
  )
  ▽>1≡°□⊢⍉. # keep only valid paths
  ⊝
)
MakePathMatrix ← (
  AddBorder
  ⊚FindNodes.
  &p$"nodes: _"/$"_ _".
  # ⊃⊙∘(≡&p⬚0+×2°⊚)
  ⊙(¤)                          # fix grid
  ≡(□≡({⊙⊙∘}⊙°{⊙∘})⊃¤PathsFrom) # build paths
  /⊐⊂                           # flatten results
  ∩∵°□⊟°[⊙:]⍉                   # split into starts/ends + lengths
  ⍉⍜(☇1)⊛                       # number nodes
  ↯:0⊟.⊃(+1/↥♭|⊙∘)              # get node count, make empty matrix
  ⍜(⊡)(⋅∘):                     # fill matrix with lengths
  ⍤"adjacency matrix should be symmetric"≍⍉..
  # &ims÷/↥♭..
)
MakeDot ← (
  ⇡⧻.
  ≡(
    ⊓(¤|⊃(⇡⧻|∘))
    □≡(
      ↧⊃(>|>0⋅⋅∘|⊙⊙∘)
      (
        ⋅⋅;
        □""
        | □$"\"_\" -- \"_\" [label=\"_\"]\n"
      )
    )
  )
  /⊐⊂
  /⊐⊂
  &fwa "day23.dot" $"graph {\n_}\n"
)
RemoveSlopes ← (
  ⍜♭(⍜▽(∵⋅@.) ∊:">v".)
)

StartFrom ← (
  [{⊃(≠:⇡⧻:|⊡|0)}] # initial queue contents
)

UnsetVariants ← (
  ×⊙¤¬⬚0↙⊟:⊃(⧻|⧻.⬚0≡°⊚⊚)
)

# ( {available next lengthsofar} bestlength matrix -- entries )
ProcessQueueEntry ← (
  °{⊙⊙∘}
  # -- available next lengthsofar bestlength matrix
  ⊃∘(
    ×        # filter neighbors by availability
    ×⊃(+|>0) # add lengthsofar to available
  )
  # -- available nextlengths bestlength matrix
  ⊃(
    >0,                            # which neighbors are actually visitable?
    ⊃(UnsetVariants|▽ ⊙⋅⋅⋅∘|▽ ⊙⋅∘) # make queue entries (available' + next + length)
    ≡{⊙⊙∘}                         # pack new queue entries
  | ⊃(
      # compare bestlength to length for final node
      ⋅(⊢⇌)
    | ⋅⋅∘
    | ∘
    )
    >0.
    (
      # final node not reached: nothing to do
      ⋅∘
    | <,,
      (
        # ⊃(&p$"same old:_ <= _\t_"⊙⊙¬)
        ⋅∘
        | ⊃(&p$"new best: _ > _\t_"⊙⊙¬)⊙;
      )
    )
  )
)

# ( queue bestlength matrix -- queue' bestlength' )
FindLongestPathStep ← (|3.2
  ⊃(
    ↘1 # rest of queue
  | ⊢  # pop from queue
    ProcessQueueEntry
  )
  # ⊂ # prepend new queue entries (BFS)
  ⊂: # append new queue entries (DFS)
  # &p⧻.
  # -- queue bestlength matrix
)
SpawnLongestPath ← (
  spawn(
    ⊙0 # start with bestlength 0
    ⍢(⊃(FindLongestPathStep|⋅⋅∘)|±⧻)
    ⋅⊙; # drop queue and matrix
  )
)
FindLongestPath ← (
  # -- matrix
  ⊃(
    ⊃(
      [{⊃(⬚1↙:¬°⊚0_1_3⧻|⊡4|+118 105 206)}] . # initial queue contents
      SpawnLongestPath
    | [{⊃(⬚1↙:¬°⊚0_1_3⧻|⊡6|+134 105 166)}] . # initial queue contents
      SpawnLongestPath
    )

    spawnwait
  | ⊃(
      [{⊃(⬚1↙:¬°⊚0_1_10⧻|⊡6|+154 105 166)}] . # initial queue contents
      SpawnLongestPath
    | [{⊃(⬚1↙:¬°⊚0_1_10⧻|⊡13|+130 105 166)}] . # initial queue contents
      SpawnLongestPath
    )
  )
)
PartTwo ← (
  Parse

  RemoveSlopes

  MakePathMatrix
  # ⍜(⊡32)⍜(↘¯1)(×0)
  &p⊡32.
  &p⍜now(FindLongestPath)
)

---
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Aeq [0_0_1_1_1_1
     0_1_1_1_0_1] UnsetVariants [0 1 0 0 1 0] 0_1_1_1_1_1

Aeq [[0 0 0 0 1 0 1 1 1]] UnsetVariants [0 0 0 0 0 1 0 0 0] [0 0 0 0 1 1 1 1 1]

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
Aeq 94 PartOne.
; # Aeq 154 PartTwo

# &fras "day23.txt";;
&p "Tests OK"
---
&fras "day23.txt"
PartTwo
; # MakePathMatrix
# ⍤⊃⋅∘≍ 2070 PartOne &fras "day23.txt"

# ⍤⊃⋅∘≍ 0 now PartTwo &fras "day23.txt"
