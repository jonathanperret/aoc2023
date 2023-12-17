# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Parse ← ⊜(-@0)≠@\n.
Directions ← [0_1 ¯1_0 0_¯1 1_0]
# coordinate -- coordinates
ListNeighbors ← (
  +Directions ¤
)

# - graph: node-indexed matrix of boxes[box[nodes] box[weights]]
#   ( grid -- graph)
MakeGraph! ← (|1
  ⊃(
    △
    ⊃(
      ⇡ # generate coordinates
    | ¤ # fix shape
    )
  | ¤ # fix grid
  )
  # for each cell coordinate
  ⍜(☇1)≡(
    # generate neighbors
    ^1
    ⊃(
      ⊙¤ # fix shape
      # check if each is < shape and >= 0
      ≡(/↧ ↧⊃(>|+1±))
    | ∘ # keep neighbors
    )
    ▽     # keep only in-range neighbors
    {⊃∘⊡} # get edge weights for these from grid, pack together
  )
)
Opposite ← (|1
  ◿4+2
)
ListNeighborsFourD ← (|1
  ⊃(
    ⊡0 # get direction
  | ListNeighbors ↘2
    ≡(⊂0) # new count defaults to 0
  | +1⊡1  # get count
  )
  ⊃∘(
    ⊂:0    # target count of original direction
    ⍜⊡(⋅∘) # replace with new count
    ≡⊂ ⇡⧻. # add direction number in front
  )
  Opposite
  °⊚
  ⬚0↯[4]
  ¬
  # opposite direction is forbidden!
  ▽
)
ExpandGridToFourD ← (
  ↯ ⊂ 4_3 △. # expand grid to 4D by repeating
)
# - setup:
#   - best cost: infinite for all nodes except 0 for start nodes
#   - visited: all nodes 0
#   - queue: start nodes (coordinates)
#   - queuecosts: 0 for each start node
#   ( startnodes graph -- queuecosts queue visited best )
DijkstraSetup ← (|2.4
  ⊃(
    ⊃(≡⋅0)∘    # queue costs 0 for start nodes
  | ⊙(⍜⇌(↘1)△) # shape of node matrix
    ⊃(
      ⋅(≠0↯:0) # all nodes unvisited (suggest byte array)
    | ⊙(↯:∞)   # all nodes infinite cost
      ⍜⊡(∵⋅0)  # start nodes cost 0
    )
  )
)
# - pop cheapest node and cost from queue
#   ( queuecosts queue -- node cost queuecosts' queue' )
PopCheapest ← (|2.4
  ⍏.                    # get cost order
  ⊃(⊢|↘1)               # pop first
  ⊃(⊡⊙⋅;|⊡⊙;|⊏⋅∘|⊏⋅⊙⋅∘) # pick and select
)
# - check visited
#   ( node visited -- isvisited )
CheckVisited ← |2 ⊡
# - mark node visited
#   ( node visited -- visited' )
MarkVisited ← |2 ⍜⊡⋅1
# - get neighbors (with weights) of node from graph
#   ( node graph -- neighbors neighborweights )
GetNeighborsWithWeights ← |2.2 ∩°□°⊟ ⊡
# - remove visited neighbors
#   ( neighbors neighborweights visited -- neighbors' neighborweights' )
RemoveVisitedNeighbors ← (|3.2
  ⊃(
    ¬⊡ ⊙⋅∘ # get visited status
  | ⊙∘
  )
  ∩▽,: # keep non-visited in both lists
)
# - add node's cost to neighbor's weights
#   ( neighborweights cost -- neighborcosts )
AddCostToNeighborWeights ← +
# - get neighbors best costs
#   ( neighbors best -- neighborbests )
GetNeighborsBestCosts ← ⊡
# - keep neighbors where newcost < best cost
#   ( neighborbests neighbors neighborcosts -- neighbors' neighborcosts' )
KeepImprovedNeighbors ← (
  ⊃(
    < ⊙⋅∘ # mask of improved
  | ⋅⊙∘   # keep neighbors, neighborcosts
  )
  ,: # -- mask neighbors mask neighborcosts
  ∩▽ # -- neighbors' neighborcosts'
)
# - update their best costs with newcost
#   ( neighbors neighborcosts best -- best' )
UpdateNeighborsBestCosts ← (|3
  ⊙:   # bring best up
  ⍜⊡⋅∘ # replace picked with new costs
)
# - add them to the queue
#   ( neighbors neighborcosts queuecosts queue -- queuecosts' queue' )
AddNeighborsToQueue ← (|4.2
  ⊃(⋅⊙∘|⊙⋅⋅∘)
  ∩(⊂:)
)
# - Dijkstra's step:
#   -- queuecosts queue visited best graph
DijkstraStep ← (|5.5
  #   - pop cheapest node and cost from queue
  #     ( queuecosts queue -- node cost queuecosts' queue' )
  PopCheapest
  #     -- node* cost* queuecosts' queue' visited best graph
  #   - check visited
  #     ( node visited -- isvisited )
  ⊃(CheckVisited ⊙⋅⋅⋅∘|⊙⊙⊙⊙∘)
  #     -- isvisited* node cost queuecosts queue visited best graph
  #   - assert not visited
  ⍤"a node in the queue should never be already visited"=0
  #     -- node cost queuecosts queue visited best graph
  #   - mark node visited
  #     ( node visited -- visited' )
  ⊃(⊙⊙⊙∘|MarkVisited ⊙⋅⋅⋅∘)
  #     -- node cost queuecosts queue visited' best graph
  #   - get neighbors (with weights) of node from graph
  #     ( node graph -- neighbors neighborweights )
  ⊃(GetNeighborsWithWeights ⊙⋅⋅⋅⋅⋅∘|⋅⊙⊙⊙⊙⊙∘)
  #     -- neighbors* neighborweights* cost queuecosts queue visited best graph
  #   - remove visited neighbors
  #     ( neighbors neighborweights visited -- neighbors' neighborweights' )
  ⊃(RemoveVisitedNeighbors ⊙⊙⋅⋅⋅∘|⋅⋅⊙⊙⊙∘)
  #     -- neighbors' neighborweights' cost queuecosts queue visited best graph
  #   - add node's cost to neighbor's weights
  #     ( neighborweights cost -- neighborcosts )
  ⊃(∘|AddCostToNeighborWeights ⋅∘)
  #     -- neighbors neighborcosts* queuecosts queue visited best graph
  #   - get neighbors best costs
  #     ( neighbors best -- neighborbests )
  ⊃(GetNeighborsBestCosts ⊙⋅⋅⋅⋅∘|⊙⊙⊙⊙⊙∘)
  #     -- neighborbests neighbors neighborcosts queuecosts queue visited best graph
  #   - keep neighbors where newcost < best cost
  #     ( neighborbests* neighbors neighborcosts -- neighbors' neighborcosts' )
  KeepImprovedNeighbors
  #     -- neighbors' neighborcosts' queuecosts queue visited best graph
  #   - update their best costs with newcost
  #     ( neighbors neighborcosts best -- best' )
  ⊃(⊙⊙⊙⊙∘|UpdateNeighborsBestCosts ⊙⊙⋅⋅⋅∘|⋅⋅⋅⋅⋅⋅∘)
  #     -- neighbors neighborcosts queuecosts queue visited best' graph
  #   - add them to the queue
  #     ( neighbors neighborcosts queuecosts queue -- queuecosts' queue' )
  AddNeighborsToQueue
  #     -- queuecosts' queue' visited best graph
)
# ( queuecosts -- nonempty? )
QueueHasNodes ← ±⧻
# (queuecosts queue visited best graph -- best)
FrameFromBest ← (
  /↧/↧
  ⍜♭(
    =∞.
    ⍜(▽)(=0)
    ÷/↥.
  )
)
DijkstraLoop ← (
  # - repeat until queue empty:
  #   - step
  ⊃(⋅⋅(¤/↧/↧)|⊙⊙∘) # frames
  0                # counter
  ⍢(
    # -- counter frames queuecosts queue visited best graph
    ⊙⊙DijkstraStep
    # -- counter frames queuecosts queue visited best graph
    +1
    ⊃(
      ∘
    | ±◿1000.
      (
        ⊃(
          ;   # &p
            | # 
          ⋅⊙(
            ;;;
            FrameFromBest
            ⍣(&ims)(⋅;).
          )
          ⊂
        )
        | ⋅∘ # keep frames as-is
      )
    | ⋅⋅⊙⊙⊙⊙∘
    )
  )(⋅⋅QueueHasNodes)
  # -- counter frames queuecosts queue visited best graph
  ;
  ⍣(
    &p △.
    &fwa $"day17-_.gif" ⊃(↘1 △|&gife 30)
  )(⋅;)
  ⋅⋅⋅⊙;
  # -- best
)
GetEndCost ← (
  /↧  # flatten directions
  /↧  # flatten step counts
  ⊢⇌♭ # take last element
)
FourDSolve ← (
  ExpandGridToFourD
  MakeGraph!ListNeighborsFourD
  ⊃(
    # start at top left, either going right or down
    [0_0_0_0 3_0_0_0]
    DijkstraSetup
  | ∘
  )
  DijkstraLoop
  GetEndCost
)
PartOne ← FourDSolve Parse
---
$ 12
$ 25
Parse
FourDSolve
Aeq 7

$ 2413432311323
$ 3215453535623
$ 3255245654254
$ 3446585845452
$ 4546657867536
$ 1438598798454
$ 4457876987766
$ 3637877979653
$ 4654967986887
$ 4564679986453
$ 1224686865563
$ 2546548887735
$ 4322674655533
Aeq 102 PartOne

0_0_0_0
ListNeighborsFourD
Aeq [0_1_0_1
     1_0_¯1_0
     3_0_1_0]

0_0_4_0
ListNeighborsFourD
Aeq [0_1_4_1
     1_0_3_0
     3_0_5_0]

# - graph: node-indexed matrix of boxes[box[nodes] box[weights]]
#   ( grid -- graph)
[1_2
 3_4]
MakeGraph!ListNeighbors
Aeq [[{[0_1 1_0] [2 3]} {[0_0 1_1] [1 4]}]
     [{[1_1 0_0] [4 1]} {[0_1 1_0] [2 3]}]]

# also works in 4D
[1_2_3_4_5
 6_7_8_9_10
 6_7_8_9_10
 6_7_8_9_10
 6_7_8_9_10]
ExpandGridToFourD
MakeGraph!ListNeighborsFourD
⊃(
  ⊡ 0_0_0_0
  Aeq {
    [[0 1 0 1]
     [3 0 1 0]]
    [2 6]  }
| ⊡ 0_2_0_0
  Aeq {[[3 0 1 0]]
       [6]}
)

# - setup:
#   - best cost: infinite for all nodes except 0 for start nodes
#   - visited: all nodes 0
#   - queue: start nodes (coordinates)
#   - queuecosts: 0 for each start node
#   ( startnodes graph -- queuecosts queue visited best )
[[{[0_1 1_0] [2 3]} {[0_0 1_1] [1 4]}]
 [{[1_1 0_0] [4 1]} {[0_1 1_0] [2 3]}]]
{DijkstraSetup [0_0]}
Aeq {
  [0]   # queuecosts
  [0_0] # queue
  [0_0  # visited
   0_0]
  [0_∞ # best
   ∞_∞]}

# - pop cheapest node and cost from queue
#   ( queuecosts queue -- node cost queuecosts' queue' )
[10 2 3] [0_3 5_6 7_8]
Aeq {5_6 2 [3 10] [7_8 0_3]} {PopCheapest}

# - check visited
#   ( node visited -- isvisited )
1_1 [0_0 0_1]
Aeq 1 CheckVisited

# - mark node visited
#   ( node visited -- visited' )
0_1 [0_0 0_1]
Aeq [0_1 0_1] MarkVisited

# - get neighbors (with weights) of node from graph
#   ( node graph -- neighbors neighborweights )
[[{[0_1 1_0] [2 3]} {[0_0 1_1] [1 4]}]
 [{[1_1 0_0] [4 1]} {[0_1 1_0] [2 3]}]]
Aeq {[0_0 1_1] [1 4]} {GetNeighborsWithWeights 0_1}

# - remove visited neighbors
#   ( neighbors neighborweights visited -- neighbors' neighborweights' )
[0_0 1_1] [1 4] [[0 0] [0 1]]
RemoveVisitedNeighbors
Aeq {[0_0] [1]} {⊙∘}

# - add node's cost to neighbor's weights
#   ( neighborweights cost -- neighborcosts )
Aeq [6 9] AddCostToNeighborWeights [1 4] 5

# - get neighbors best costs
#   ( neighbors best -- neighborbests )
Aeq [5 9] GetNeighborsBestCosts [0_0 1_1] [[5 3][7 9]]

# - keep neighbors where newcost < best cost
#   ( neighborbests neighbors neighborcosts -- neighbors' neighborcosts' )
[5 9] [0_0 1_1] [6 8]
Aeq {[1_1] [8]} {KeepImprovedNeighbors}

# - update their best costs with newcost
#   ( neighbors neighborcosts best -- best' )
[1_1 0_1] [8 4] [[10 11][12 13]]
Aeq [[10 4][12 8]] UpdateNeighborsBestCosts

# - add them to the queue
#   ( neighbors neighborcosts queuecosts queue -- queuecosts' queue' )
[1_1 0_1] [8 4] [10] [1_0]
Aeq {[10 8 4] [1_0 1_1 0_1]} {AddNeighborsToQueue}

# - Dijkstra's step:
#   queuecosts queue visited best graph -- queuecosts' queue' visited' best' graph
{
  [10]  # queuecosts
  [0_0] # queue
  [0_0  # visited
   0_0]
  [∞_∞ # best
   ∞_∞]
  [[{[0_1 1_0] [2 3]} {[0_0 1_1] [1 4]}] # graph
   [{[1_1 0_0] [4 1]} {[0_1 1_0] [2 3]}]]}
⍜°{⊙⊙⊙⊙∘} DijkstraStep
Aeq {
  [12 13]   # queuecosts
  [0_1 1_0] # queue
  [1_0      # visited
   0_0]
  [∞_12 # best
   13_∞]
  [[{[0_1 1_0] [2 3]} {[0_0 1_1] [1 4]}] # graph
   [{[1_1 0_0] [4 1]} {[0_1 1_0] [2 3]}]]}

# - Dijkstra's loop:
#   ( queuecosts queue visited best graph -- best' )
{
  [10]  # queuecosts
  [0_0] # queue
  [0_0  # visited
   0_0]
  [0_∞ # best
   ∞_∞]
  [[{[0_1 1_0] [2 3]} {[0_0 1_1] [1 4]}] # graph
   [{[1_1 0_0] [4 1]} {[0_1 1_0] [2 3]}]]}
°{⊙⊙⊙⊙∘}
DijkstraLoop
Aeq [0_12
     13_16]

&p "Tests OK"
---
Aeq 907 PartOne &fras "day17.txt"
# Aeq 0 PartTwo &fras "day17.txt"
