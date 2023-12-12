# Experimental!
Aeq ← ⍤⊃($"\nexpected\n_\ngot\n_")≍

Lines ← ⊜□≠@\n.
Parse ← (
  Lines
  ≡(
    °□
    °⊟⊜(□)≠@\s.
    :
    □⊜⋕≠@,.°□
  )
)
MaxHoleSize ← (
  # in: group size list, target string
  # max size of hole = len - groups sum - (groupcount-1)
  ⊃(
    /+  # groups sum
  | -1⧻ # groupcount - 1
  | ⋅⧻  # len of target
  )
  -+
)
CountAll ← (
  ∩°□
  ⊃(MaxHoleSize|⊙∘)
  ⊙(+2⧻.)
  ⁿ:
  ⊙(;;)
)

AllSplits ← (
  ↬(|2
    # in: count, length
    # out: list of splits
    =1. # test to end recursion: only one group to make?
    (
      ⊃(
        -1  # how many other groups
        -   # how much remaining for first group
        +1⇡ # possible sizes for first group
        | ⊙∘
      )
      # for each first group size
      ≡(|3
        # in: group size, count, length
        # out: list of splits
        ⊃(
          -1;     # one fewer group
            | -⊙; # remaining size
            | ∘   # keep first group size
        )
        # now on stack: remaining count, remaining length, first group size
        ↫
        # now on stack: splits, first group size
        # prepend first group size to each split
        :
        ≡⊂
        □
      )
      °□/(⊂∩°□) # join all split lists
    |           # only one group requested: just put it all in
      ⍤⊃⋅∘≍1
      [[∘]]
    )
  )
)
MakePattern ← (
  ⊙(⊂:0)
  ⍉⊟
  ≡(
    °⊟
    ⊓(▽:@.|▽:@#)
    ⊂
    □
  )
  /⊐⊂
)
MatchPattern ← (
  # in: candidate, target
  ⊃(
    =      # direct match
  | ⋅(=@?) # find ?s
  )
  ↥  # each matches if either direct or `?`
  /↧ # pattern matches if all chars match
)
CountPossible ← (
  ⊙($"._."°□)     # add holes left and right
  ⊃(+1⧻|-/+⊙⧻|⊙∘) # hole count, holes total

  AllSplits
  ⊙¤           # fix groups list
  ≡MakePattern # make all patterns
  ⊙¤           # fix target
  ≡MatchPattern
  /+ # count matching
)
PartOne ← (
  Parse
  ≡(
    ∩°□
    CountPossible
  )
  /+
)
FindPrefixes ← (
  # in: group size, target string
  # out: valid prefix lengths
  ⊃(>⊙⧻|⊙∘) # target must be longer than group
  (
    [] # otherwise, no prefix works
  | ⊃(
      ∘
    | -⊙⧻ # string length minus group size
      +1⇡ # possible `.` padding lengths
    | ⊙∘
    )
    +   # add group size -> possible prefix lengths
    ⊙∩¤ # fix size and target
    ≡(
      # prefix length, group size, target
      ⊃(
        ⊃(∘|-:|⋅∘) # prefix len, padding len, group len
        ⊃(
          ⊙⊙∘
            | ⍤⊃($"padding length (_) should be >=0"|≥0);
            | ⍤"padding and group should sum to prefix length"=⊙+
        )
        ⊙(⊂⊓(▽:@.|▽:@#))
        ⊃(
          ⍤"should have prefix length"=⊙⧻
            | ⋅∘
        )
        □
        | ⊙;
        ↙
        □
        | ∘
      )
      # padded group, prefix
      ∩°□
      MatchPattern
    )
    ▽ # keep only valid prefix lengths
  )
)
NextGroupPrefixes ← (
  # in: paths so far, remaining group sizes, target
  # out: paths with first remaining group added
  ⊙⊢   # pick next group size
  ⇡⧻.  # enumerate prefix lengths
  ⊙⊙∩¤ # fix group size and target
  ⬚0≡(
    # for each prefix length
    # prefix length, paths to prefix, group size, target
    ±, # copy possibilities for switch
    (
      0                 # short-circuit to 0 if no path to here
    | ⊃(⋅⋅∘|↘⊙⋅⋅∘|∘|⋅∘) # group size, suffix, prefix len, possibilities
      FindPrefixes

      +  # add saved prefix length
      °⊚ # map to binary table
      ×  # multiply by paths to prefix
    )
  )
  /+ # sum rows
)
Iter ← (
  ⊃(NextGroupPrefixes|⊙∘↘1;) # apply first group, drop first group, keep target
)
AllIter ← (
  ⊃(⊓⊢∘|↘1|⋅∘) # take first group size, copy target
  FindPrefixes
  °⊚ # build table: prefix len -> possibilities so far

  ⍢Iter (>0⋅⧻)
  ⊙∩;
)
ExpandTargets ← ≡⍜°□($"_?_?_?_?_" ....)
ExpandGroups ← ≡⍜°□(▽ 5)
MinPrefixLength ← -⊃(⊗ @# ⇌|⧻)
PartTwo ← (
  Parse
  ⊓ExpandGroups ExpandTargets
  ≡(
    ∩°□
    ⊙$"._"
    ⊃(⋅MinPrefixLength|AllIter)
    ↘  # drop invalid prefixes
    /+ # sum surviving
  )
  /+
)
---
Aeq [[4]] AllSplits 1 4
Aeq [1_3 2_2 3_1] AllSplits 2 4
Aeq [1_1_2 1_2_1 2_1_1] AllSplits 3 4

Aeq 1 MatchPattern "..#." "??#?"
Aeq 0 MatchPattern "..#." "??.?"

Aeq ".##.#." MakePattern [1 1 1] [2 1]

Aeq [2] FindPrefixes 1 ".?"
Aeq 2_3_6_7_11_12 FindPrefixes 1 ".??..??...?##."
Aeq 3_7_12_13 FindPrefixes 2 ".??..??...?##."
Aeq [13] FindPrefixes 3 ".??..??...?##."
Aeq [] FindPrefixes 4 ".??..??...?##."
Aeq [] FindPrefixes 3 "..#"

NextGroupPrefixes [0 0 0 0 0 0 2 2 0 0 0 4 4] [3] ".??..??...?##."
Aeq [0 0 0 0 0 0 0 0 0 0 0 0 0 4]

AllIter 1_1_3 ".??..??...?##."
Aeq [0 0 0 0 0 0 0 0 0 0 0 0 0 4]

Aeq 5 MinPrefixLength ".##.#.."
Aeq 15 MinPrefixLength ".??..??...?##.#.."

$ ???.### 1,1,3
$ .??..??...?##. 1,1,3
$ ?#?#?#?#?#?#?#? 1,3,1,6
$ ????.#...#... 4,1,1
$ ????.######..#####. 1,6,5
$ ?###???????? 3,2,1
Parse .
≡(
  ∩°□
  CountPossible
)
Aeq 1_4_1_1_4_10
⍤⊃⋅∘≍ 21 PartOne .

Parse .

≡(
  ∩°□
  ⊙$"._"
  /+AllIter
)
/+
Aeq 21

⍤⊃⋅∘≍ 525152 PartTwo

&p "Tests OK"

---
Aeq 7718 PartOne &fras "day12.txt"
Aeq 128741994134728 PartTwo &fras "day12.txt"
