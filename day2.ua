Lines ← &i "tools.ua" "Lines"
Aeq ← ⍤⊃($"expected _ got _")≍

ExtractRGB ← (
  ≡(
    ×⊃(⊔="rgb"⊔⊢|⊔⊡1)
  )
  /↥
)
ParseRound ← (
  ♭ regex "\\d+ [rgb]"
  ≡({⊃(⊢⇌|parse⇌↘2⇌⊔)})
  ExtractRGB
)
ParseGame ← (
  ♭ regex "[^;]+" ↘8
  ≡ParseRound
)
Parse ← ≡(□ ParseGame ⊔) Lines

IsPossible ← /↧♭≡(≤12_13_14)
PartOne ← (
  Parse
  ≡(IsPossible ⊔)
  ▽:+1⇡⧻.
  /+
)

GamePower ← /×/↥
PartTwo ← /+≡(GamePower ⊔) Parse

---
Aeq 5_3_30 ExtractRGB [{@b 30} {@g 3} {@r 5}]
Aeq 0_3_30 ExtractRGB [{@b 30} {@g 3}]

$ 3 blue, 4 red
Aeq 4_0_3 ParseRound

$ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Aeq [4_0_3 1_2_6 0_2_0] ParseGame

Aeq 0 IsPossible[3_4_0 13_12_10 1_3_4]
Aeq 1 IsPossible[4_4_0 12_12_10 1_3_4]
Aeq 1 IsPossible[6_3_1 1_2_2]

Aeq 48 GamePower[4_0_3 1_2_6 0_2_0]

$ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
$ Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
$ Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
$ Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
$ Game 100: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green

Aeq 8 PartOne .

Aeq 2286 PartTwo

&p "Tests OK"

---

Aeq 3059 PartOne &fras "day2.txt"
Aeq 65371 PartTwo &fras "day2.txt"
