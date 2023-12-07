Lines ← &i "tools.ua" "Lines"
Aeq ← ⍤⊃($"expected _ got _")≍

PartOneLine ← ⋕ ⊟⊃(⊢|⊢⇌)▽↧⊃(≥@0|≤@9).°□
PartOne ← /+≡(PartOneLine °□)Lines

Digits ← {"0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
          "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}
DigitRE ← ⊐/⊂↘1♭≡⊂ "|"Digits
Xeger ← ≡⇌♭regex ∩⇌

PartTwoLine ← (
  °□
  ⊟⊃(
    ⊢♭regex DigitRE
  | ⊢Xeger DigitRE
  )
  +@0≡((∘|-9)>9. ⊗ : Digits)
  ⋕
)
PartTwo ← /+≡PartTwoLine Lines

---
$ 1abc2
$ pqr3stu8vwx
$ a1b2c3d4e5f
$ treb7uchet

Aeq 142 PartOne .

Aeq 43 PartTwoLine"abc4one2threexyz"

$ two1nine
$ eightwothree
$ abcone2threexyz
$ xtwone3four
$ 4nineeightseven2
$ zoneight234
$ 7pqrstsixteen

Aeq 281 PartTwo

Aeq {"eight" "6"} Xeger DigitRE "6oneighthlf"

Aeq 68 PartTwoLine "6oneighthlf"

&p "Tests OK"

---

Aeq 55090 PartOne &fras "day1.txt"
Aeq 54845 PartTwo &fras "day1.txt"
