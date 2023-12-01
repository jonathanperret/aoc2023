Youpi, il est de nouveau temps d'aider les Elfes.

## Partie 1

On commence avec une chaîne composée de lignes comme ça :

```
$ 1abc2
$ pqr3stu8vwx
$ a1b2c3d4e5f
$ treb7uchet
```

Il faut trouver sur chaque ligne le premier et le dernier chiffre, donc par exemple dans `pqr3stu8vwx` c'est `3` et `8`, et dans `trb7uchet` c'est deux fois `7`.

Je commence par découper la chaîne en lignes avec la fonction `Lines` que j'avais préparée. Enfin, je ne l'ai pas écrite mais je l'ai piquée dans [cette liste de bouts de code pratiques](https://www.uiua.org/docs/isms). Elle est un peu compliquée, on ne va pas s'attarder dessus aujourd'hui.

```
Lines ← ⊕□⍜▽¯:\+.=, @\n

$ 1abc2
$ pqr3stu8vwx
$ a1b2c3d4e5f
$ treb7uchet

Lines
```

Ensuite pour traiter une ligne, je vais la dupliquer puis créer un masque des caractères qui sont compris entre `0` et `9`.

En appliquant `≥@0` j'obtiens un masque des caractères plus grands que `0` dans l'ordre ASCII, soit `[1 1 1 1 1]` pour `1abc2`, et en appliquant `<=@9` un masque de ceux qui viennent avant `9` soit `[1 0 0 0 1]` pour la même chaîne (à la réflexion j'aurais pu me contenter de ce dernier test, car il me semble qu'aucun caractère dans l'entrée n'est plus petit que `0` !).

Pour appliquer ces deux tests sur la même chaîne, j'utilise `fork` qui prend deux fonctions et les applique successivement sur une valeur, ce qui donne `⊃(≥@0|≤@9)`.

Il faut ensuite combiner les deux masques avec un `ET` logique. Cet opérateur n'existe pas tel quel en Uiua mais comme les booléens sont représentés par `0` et `1` il suffit d'appliquer `minimum` ou encore `multiply` pour obtenier l'effet souhaité.

```
$ 1abc2
.          # on duplique la chaîne
⊃(≥@0|≤@9) # on teste chaque caractère par rapport à 0 et 9
↧          # on prend le minimum (ET logique) des deux masques obtenus
```

J'utilise ensuite ce masque (`[1 0 0 0 1]` pour `1abc2`) pour ne conserver que les caractères de la chaîne qui sont bien des chiffres grâce à `keep` (après avoir perdu 5 minutes à confondre `keep` avec `select`…) :

```
$ 1abc2
↧⊃(≥@0|≤@9) . # on construit le masque des chiffres
▽             # on ne garde que les chiffres
```

Maintenant que j'ai isolé les chiffres, je ne veux garder que le premier, qu'on peut obtenir avec `first`, et le dernier qu'on obtient en appliquant `reverse` avant `first`, soit `⊢⇌`. Je vais encore utiliser `fork`, donc `⊃(⊢|⊢⇌)`.

Les deux caractères ainsi obtenus sont rassemblés en une liste — donc une chaîne — par `couple`, puis on peut appliquer `parse` pour lire cette chaîne comme un entier :


```
$ 1abc2def3
▽↧⊃(≥@0|≤@9) . # on ne garde que les chiffres
⊟⊃(⊢|⊢⇌)       # on retient le premier et le dernier dans une chaîne
parse          # on convertit la chaîne en entier
```

Je peux donner un nom à cette séquence d'opérations :

```
PartOneLine ← parse ⊟⊃(⊢|⊢⇌)▽↧⊃(≥@0|≤@9).

$ 1abc2def3
PartOneLine
```

Je peux ensuite appliquer cette fonction à toutes les lignes de l'entrée avec `rows` (il faut appliquer un petit `unbox` avant de traiter chaque ligne pour défaire le `box` appliqué par `Lines` pour permettre de faire cohabiter des chaînes de longueurs différentes dans un tableau).

```
Lines ← ⊕□⍜▽¯:\+.=, @\n
PartOneLine ← parse ⊟⊃(⊢|⊢⇌)▽↧⊃(≥@0|≤@9).

$ 1abc2
$ pqr3stu8vwx
$ a1b2c3d4e5f
$ treb7uchet

Lines
≡(PartOneLine ⊔)
```

Enfin, j'applique un `reduce` avec `add` pour obtenir la somme des nombres et ça me donne ma fonction `PartOne` qui donne la réponse à la partie 1.

```
Lines ← ⊕□⍜▽¯:\+.=, @\n
PartOneLine ← parse ⊟⊃(⊢|⊢⇌)▽↧⊃(≥@0|≤@9).
PartOne ← /+ ≡(PartOneLine ⊔) Lines

$ 1abc2
$ pqr3stu8vwx
$ a1b2c3d4e5f
$ treb7uchet

PartOne
```

## Partie 2

Ah, il faut maintenant reconnaître les chiffres écrits en toutes lettres. Donc dans `two1nine` par exemple, le nombre à lire est `29`.

Même si ce n'est pas un problème très compliqué de reconnaissance de chaînes, je décide d'utiliser `regex` plutôt que de chercher les chiffres "manuellement".

```
$ two1nine
regex "0|1|2|3|4|5|6|7|8|9|one|two|three|four|five|six|seven|eight|nine"
```

Ça fonctionne pour isoler les chiffres écrits en toutes lettres. Mais il me reste à faire la correspondance entre `one` et `1`, `two` et `2`, etc.

Si j'avais une liste des chaînes pouvant représenter un chiffre, il me suffirait de trouver la position de `two` dans cette liste pour connaître sa valeur. Je construis donc une liste de ces chaîneset j'utilise `indexof` pour chercher dedans :

```
Digits ← {"0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
          "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}

⊗ □"two" Digits
```

On cherche `□"two"`, soit une chaîne mise en boîte par `box`, et pas simplement `"two"` parce que `Digits` n'est pas directement un tableau de chaînes, ce qui serait impossible car elles sont de longueur variable et les tableaux en Uiua doivent être réguliers, mais un tableau de boîtes contenant chacune une chaîne. La syntaxe `{ "one" "two" "three" }` permet de créer facilement ce genre de tableaux de boîtes ; elle est équivalente à `[ □"one" □"two" □"three" ]`.

Comme il y a deux occurrences de chaque chiffre dans ma liste (`2` et `two`), il faut soustraire `9` aux indices qui dépassent 9 afin que ce `11` devienne `2`. Mais je ne veux faire cette soustraction que si l'indice est supérieur à 9. Pour ce faire, je duplique l'indice et je le compare à 9 avec `>9.`, ce qui me donne `0` ou `1` selon le résultat de la comparaison ; puis j'utilise une [switch function](https://www.uiua.org/docs/controlflow#switch) qui permet de choisir entre deux fonctions selon un entier. Ici, si le résultat de la comparaison est `0` j'applique `identity`, sinon je soustrais 9 avec `-9` . Ça s'écrit donc `(∘|-9)>9.`.

```
Digits ← {"0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
          "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}

(∘|-9)>9. ⊗ □"two" Digits
```

Comme j'ai deux chaînes à chercher (le premier et le dernier chiffre), j'utilise encore `rows`. Et pour remettre les arguments de `indexof` dans le bon ordre je dois appliquer un `flip` d'abord.

```
Digits ← {"0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
          "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}

≡((∘|-9)>9. ⊗ : Digits) { "1" "three" }
```

Enfin, je convertis ces deux indices en caractères (en ajoutant le caractère `@0`) et j'appelle `parse` :

```
Digits ← {"0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
          "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}

parse +@0 ≡((∘|-9)>9. ⊗ : Digits) { "1" "three" }
```

Au passage, comme j'ai maintenant dans `Digit` une liste des chaînes à chercher, je peux m'en servir pour construire l'expression régulière de recherche, plutôt que de répéter la liste dans le code. Là encore je pique deux fonctions dans les [Uiuisms](https://www.uiua.org/docs/isms) : une pour insérer un caractère `|` entre les chaînes, une autre pour concaténer toutes les chaînes.

```
Digits ← {"0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
          "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}
DigitRE ← ⊐/⊂↘1♭≡⊂ "|" Digits

DigitRE
```

En fait il y avait plus simple en utilisant les "chaînes à trous" de Uiua, c'est-à-dire que `$"hello, _"` crée une fonction qui si on lui passe `"world"` renvoie `hello, world`. La fonction `$"_|_"` appliquée à deux chaînes les concatène donc en les séparant par un caractère `|`. Il n'y a plus qu'à appliquer cette fonction de façon répétée avec `reduce`. Il reste une petite subtilité parce que `Digits` reste une liste de boîtes, pas de chaînes, et on veut passer des chaînes à `$"_|_"`. On peut s'en sortir en écrivant `$"_|_"∩⊔`, qui utilise `both` et `unbox` pour "déballer" les deux arguments, ou bien on peut utiliser `pack` qui est un modificateur un peu magique censé automatiquement emballer/déballer les valeurs quand il le faut. En tout cas, ici ça marche 🤷.

```
Digits ← {"0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
          "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}
DigitRE ← /⊐$"_|_" Digits

DigitRE
```

Je peux maintenant rassembler tout ça avec la même logique que pour la partie 1 :

```
Lines ← ⊕□⍜▽¯:\+.=, @\n

Digits ← {"0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
          "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}
DigitRE ← /⊐$"_|_" Digits

PartTwoLine ← parse +@0≡((∘|-9)>9. indexof : Digits)⊟⊃(⊢|⊢⇌)regex DigitRE ⊔
PartTwo ← /+≡PartTwoLine Lines

$ two1nine
$ eightwothree
$ abcone2threexyz
$ xtwone3four
$ 4nineeightseven2
$ zoneight234
$ 7pqrstsixteen

PartTwo
```

Super, ça marche sur l'exemple. C'est fini du coup ?

Hélas non, le résultat n'est pas accepté sur l'entrée complète.

Je commence par afficher une liste des lignes de l'entrée avec en face de chacune le nombre reconnu, et j'en vérifie quelques-unes visuellement. Rien ne me paraît incorrect.

Puis je réfléchis au piège qui pourrait avoir été glissé. Est-ce qu'un chiffre en lettres pourrait en masquer un autre qui commence avec les dernières lettres du premier, par exemple `eighthree` ? Je ne trouve pas dans mon entrée ce premier exemple qui m'est venu en tête, mais en cherchant un peu je trouve un `oneight` en fin de chaîne : `2fourseven1oneights`. Avec mon algorithme actuel qui utilise `regex`, les chiffres identifiés dans cette chaîne seront `2 four seven 1 one`, alors que le dernier chiffre lisible est clairement un `eight`.

Je décide de continuer à utiliser `regex` mais il faut que j'arrive à lire la chaîne de droite à gauche. En réfléchissant un peu, retourner l'expression régulière et l'appliquer sur une chaîne retournée devrait me donner ce que je cherche :

```
regex ⇌"0|1|2|one|four|seven|eight|nine" ⇌"2fourseven1oneights"
```

Il faut bien sûr retourner chacune des chaînes extraites aussi :

```
≡⇌ regex ⇌"0|1|2|one|four|seven|eight|nine" ⇌"2fourseven1oneights"
```

On retrouve bien notre `eight` en première position !

J'appelle `Xeger` cette fonction qui applique `regex` à l'envers :

```
Xeger ← ≡⇌ regex ∩⇌
Xeger "0|1|2|one|four|seven|eight|nine" "2fourseven1oneights"
```

J'ai utilisé `both` pour appliquer `reverse` à chacun des deux arguments de la fonction.

Je remplace donc `(⊢|⊢⇌)regex DigitRE` par `(⊢regex DigitRE|⊢Xeger DigitRE)` dans ma fonction `PartTwoLine`.

```
Digits ← {"0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
          "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}
DigitRE ← /⊐$"_|_" Digits
Xeger ← ≡⇌ regex ∩⇌

PartTwoLine ← parse +@0≡((∘|-9)>9. ⊗ : Digits)⊟⊃(⊢regex DigitRE|⊢Xeger DigitRE)⊔

PartTwoLine "2fourseven1oneights"
```

La solution complète qui fonctionne toujours sur l'exemple mais donne aussi la bonne réponse sur l'entrée :

```
Lines ← ⊕□⍜▽¯:\+.=, @\n

Digits ← {"0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
          "one" "two" "three" "four" "five" "six" "seven" "eight" "nine"}
DigitRE ← /⊐$"_|_" Digits
Xeger ← ≡⇌ regex ∩⇌

PartTwoLine ← parse +@0≡((∘|-9)>9. ⊗ : Digits)⊟⊃(⊢regex DigitRE|⊢Xeger DigitRE)
PartTwo ← /+≡(PartTwoLine ⊔) Lines

$ two1nine
$ eightwothree
$ abcone2threexyz
$ xtwone3four
$ 4nineeightseven2
$ zoneight234
$ 7pqrstsixteen

PartTwo
```

