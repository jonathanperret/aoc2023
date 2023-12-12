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
MatchPattern ← (
  # in: candidate, target
  ⊃(
    =      # direct match
  | ⋅(=@?) # find ?s
  )
  ↥  # each matches if either direct or `?`
  /↧ # pattern matches if all chars match
)
IsPrefixValidForGroup ← (
  # prefix length, group size, target
  ⊃(
    ⊃(-:|⋅∘)      # padding len, group size
    ⊂⊓(▽:@.|▽:@#) # make candidate string
  | ↙ ⊙;          # take prefix from target
  )
  # padded group, prefix
  MatchPattern
  # validity
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
    # group size, padding lengths, group size, target
    + # prefix lengths
    # prefix lengths, group size, target
    ⊃(
      ⊙⊙¤ # fix target
      ≡IsPrefixValidForGroup
    | ∘
    )
    ▽ # keep only valid prefix lengths
  )
)
NextGroupPrefixes ← (
  # in: next group size, paths so far, target
  # out: paths with first remaining group added
  ⊃(⋅(⇡⧻)|⋅∘|∘) # enumerate prefix lengths
  ⊙⊙⊙¤          # fix target
  ⬚0≡(
    # for each prefix length
    # prefix length, path count to prefix, group size, target
    ±, # copy path count for switch
    (
      0                 # short-circuit to 0 if no path to here
    | ⊃(⋅⋅∘|↘⊙⋅⋅∘|∘|⋅∘) # group size, suffix, prefix len, pathcount
      FindPrefixes

      +  # add saved prefix length
      °⊚ # map to binary table
      ×  # multiply by paths to prefix
    )
  )
  /+ # sum rows
)
DoGroups ← (
  # in: groups, target
  ⊙¤    # fix target
  ⊙⊙[1] # initial table: only 1 path that consumes 0 chars
  # groups, target, table
  ∧(
    # group, target, table
    ⊙:
    # group, table, target
    NextGroupPrefixes
    # table'
  )
)
ExpandTargets ← ≡⍜°□($"_?_?_?_?_" ....)
ExpandGroups ← ≡⍜°□(▽ 5)
MinPrefixLength ← -⊃(⊗ @# ⇌|⧻)
Solve ← (
  ≡(
    ∩°□
    ⊙$"._" # prepend . to avoid special case
    ⊃(⋅MinPrefixLength|DoGroups)
    ↘  # drop too short prefixes
    /+ # sum surviving
  )
  /+
)
PartOne ← Solve Parse
PartTwo ← Solve ⊓ExpandGroups ExpandTargets Parse
---
Aeq 1 MatchPattern "..#." "??#?"
Aeq 0 MatchPattern "..#." "??.?"

Aeq [2] FindPrefixes 1 ".?"
Aeq 2_3_6_7_11_12 FindPrefixes 1 ".??..??...?##."
Aeq 3_7_12_13 FindPrefixes 2 ".??..??...?##."
Aeq [13] FindPrefixes 3 ".??..??...?##."
Aeq [] FindPrefixes 4 ".??..??...?##."
Aeq [] FindPrefixes 3 "..#"

NextGroupPrefixes 3 [0 0 0 0 0 0 2 2 0 0 0 4 4] ".??..??...?##."
Aeq [0 0 0 0 0 0 0 0 0 0 0 0 0 4]

DoGroups 1_1_3 ".??..??...?##."
Aeq [0 0 0 0 0 0 0 0 0 0 0 0 0 4]

Aeq 5 MinPrefixLength ".##.#.."
Aeq 15 MinPrefixLength ".??..??...?##.#.."

$ ???.### 1,1,3
$ .??..??...?##. 1,1,3
$ ?#?#?#?#?#?#?#? 1,3,1,6
$ ????.#...#... 4,1,1
$ ????.######..#####. 1,6,5
$ ?###???????? 3,2,1
⍤⊃⋅∘≍ 21 PartOne .
⍤⊃⋅∘≍ 525152 PartTwo

&p "Tests OK"

---
Aeq 7718 PartOne &fras "day12.txt"
Aeq 128741994134728 PartTwo &fras "day12.txt"
