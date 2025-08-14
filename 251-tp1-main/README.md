# TP0 : Postscript - Énoncé

#### Note Obtenue: 82/100
Manque la partie dessin dû à la participation aux CSGAMES2025

Le but de ce TP est de mettre en pratique les concepts appris pendant le cours, en particulier la modélisation d'un problème avec un langage fonctionnel à typage statique fort.

Ce TP consiste à implémenter un interprète pour un langage de commandes inspiré de  Postscript, un langage de programmation simpliste à pile utilisé pour décrire des dessins, couramment utilisé pour l'impression de documents numériques. Dans ce TP, nous implémentons une version fortement réduite de ce langage, que nous appellerons MiniPostscript. Le but est de modéliser le problème de façon fonctionnellement pure, avec gestion de sortie (texte et dessins), gestion d'un état sous forme de pile, et gestion d'erreurs.

Ce travail est à faire **seul** sans utilisation d'outils d'IA générative.

## Dépôt git

Avant tout, faites un **fork privé** du dépôt `git` suivant :
https://gitlab.info.uqam.ca/inf6120/251/251-TP1

**Attention : ne pas faire de fork public de ce dépôt** (règlement 18).

Donnez accès à votre dépôt à l'utilisateur `quentin` en mode *mainteneur* (pour la correction).

Observez la structure du projet :

- le dossier `lib/` contient le fichier `tp1.ml` : là où vous devez implémenter le TP. C'est le seul fichier à modifier.
- le dossier `ps/` contient des utilitaires utiles pour le TP :
  - le fichier `instr.ml` qui contient les instructions du langage MiniPostscript, définies dans le type `instr`
  - les fichiers `lexer.mll`, `parser.mly`, `utils.ml` qui sont nécessaires pour pouvoir lire les fichiers MiniPostscript ;
  - le fichier `draw.ml` qui contient une implémentation pure de primitives de dessins, dont vous trouverez une documentation plus bas.
- le dossier `test/` contient les tests publics. Les tests et la façon de les exécuter sont détaillés plus bas.
- le dossier `bin/` contient un point d'entrée qui permet d'exécuter un fichier MiniPostscript. La façon d'exécuter le programme est détaillée plus bas.

## Dépendances

Avant tout, vérifiez que vous utilisez bien la version 4.14.2 d'OCaml :

```sh
$ ocamlc --version
4.14.2
```


La commande suivante, à lancer depuis le dossier du TP, permet d'installer les dépendances nécessaires au TP :
```sh
opam install . --deps-only
```

# À implémenter

Contrairement au TP0, la structure du fichier `tp1.ml` est assez libre : la seule fonction dont les tests dépendent est la fonction `run`. Il vous faudra cependant décomposer votre code de façon à ce qu'il soit qualitatif, en :

- définissant des fonctions supplémentaires
- définissant des types et modules supplémentaires.

Le **seul fichier d'implémentation à modifier** est le fichier `tp1.ml`.

## Stratégie recommandée

Il est recommandé de développer ce TP incrémentalement, c'est-à-dire d'ajouter le support pour les instructions présentées ci-dessous une à une. La suite de test est construite pour faciliter un tel développement.

## Exécuter un fichier MiniPostscript

La fonction `run` à définir prends deux arguments :

- `input` : une chaîne de caractère qui contient le chemin vers le programme MiniPostscript à exécuter
  - Vous pouvez utiliser `Utils.parse` pour convertir ce chemin en liste de commandes
- `output` : un chemin vers un fichier `.png` qui contiendra le dessin généré par le programme
  - Vous pouvez utiliser `Draw.output` pour émettre un état de dessin (`Draw.t`, expliqué plus bas) dans un fichier `.png`, en passant l'état de dessin en premier argument et le chemin de sortie comme second argument.
  
Cette fonction retourne un `(string list, string) result` qui contient :

- `Ok l` en cas de succès, avec `l` la liste des lignes affichées par la commande `stack` (expliquée plus bas), dans l'ordre d'affichage
- `Error e` en cas d'erreur, avec `e` une description de l'erreur qui s'est produite

Vous pouvez exécuter le TP avec la ligne de commande suivante :

```sh
dune exec -- tp1 input.ps output.png
```

Le dossier `test/` contient un ensemble d'exemples qui seront utilisés pour valider votre implémentation.
Par exemple, le fichier `test/multistack.ps` affiche trois lignes avec la commande `stack`.
Le résultat attendu est le suivant, où on passe `/dev/null` comme chemin de sortie car on ne s'intéresse pas ici au dessin :

```
$ dune exec -- tp1 ./test/multistack.ps /dev/null
----
OUTPUT:
----
[ 1 ]
[ 2 1 ]
[ 3 2 1 ]
```

## Exécution des tests

Le dossier `test/` contient de nombreux tests. Le résultat attendu de l'exécution de chaque fichier `.ps` est donné dans un fichier `.t` correspondant.

Pour rouler un test spécifique, vous pouvez faire la commande suivante, ici pour rouler le test `multistack.ps` :

```
$ dune runtest test/multistack.t
```

S'il n'y a pas de résultat affiché, c'est que le test est passé.
Sinon, un `diff` entre le résultat attendu et le résultat obtenu est affiché.

Si vous avez un doute si le test s'exécute bien, vous pouvez toujours lancer :

```
dune clean
dune build
dune runtest test/multistack.t
```

On donnera ci-dessous le nom des tests pertinents pour chaque fonctionnalité.

# Format MiniPostscript

Un fichier MiniPostscript est composé d'une séquence d'instructions. 
Chaque instruction manipule des éléments sur la **pile de valeurs**, initialement vide.

Par exemple, le code suivant est du code MiniPostscript (et Postscript) valide :

```ps
/fib { dup 2 exch lt { dup 1 sub fib exch 2 sub fib add} { pop 1 } ifelse } def
5 fib stack
```

Chacune des instructions définie ci-dessous est représentée par une valeur de type `Instr.t`, définies dans le fichier `ps/instr.ml`.

## Commentaires

Un fichier MiniPostscript peut contenir des commentaires, commençant par un caractère `%` et continuant jusqu'à la fin de la ligne. Par exemple :

```ps
% Définition de la fonction factorielle
/fib { dup 2 exch lt { dup 1 sub fib exch 2 sub fib add} { pop 1 } ifelse} def
% Calcul de factorielle de 5
5 fib stack
```
## Premières instructions
### Constantes entières et réelles
Les constantes en MiniPostscript sont soit des entiers (par exemple `42`), soit des réels (par exemple, `3.14`).
Évaluer une constante pousse sa valeur sur la pile.

Par exemple, le programme `1`, dont l'exécution commence avec la pile vide (comme pour tout programme MiniPostscript), résulte en la pile contenant `1`, qu'on représentera `[ 1 ]`.

On fera la distinction entre valeurs entières et valeurs réelles quand nécessaire.

### Instruction `stack`
L'instruction `stack` affiche la liste des valeurs présentes dans la pile.
Le format d'affichage attendu est le suivant :

  - un caractère `[` suivi d'un espace
  - le contenu de la pile, valeur par valeur, séparées par un espace. Le sommet de la pile est à gauche.
    - les entiers s'affichent comme attendu : l'entier 42 s'affiche `42`
    - les flottants s'affichent avec exactement 2 nombres après la virgule, 42. s'affiche donc `42.00` (format `%.2f`)
    - les booléens s'affichent `true` et `false`
    - les références (cf. plus loin) s'affichent par leur nom
    - nous n'afficherons pas d'autres types de valeur
  - un espace suivi du caractère `]`
  - un passage à la ligne

Ainsi, le programme `1 2 stack` affiche `[ 2 1 ]`.

Tests pertinents :

- `dune runtest test/constfloat.t`
- `dune runtest test/constint.t`
- `dune runtest test/multistack.t`
- `dune runtest test/emptystack.t`

## Instructions de manipulation de pile
### Instruction `dup`
L'instruction `dup` duplique la valeur au sommet de la pile.
Ainsi, le programme `1 2 dup` résulte en la pile `[ 1 2 2 ]` (`2` a été dupliqué).

Test pertinent :

- `dune runtest test/dup.t`

### Instruction `exch`
L'instruction `exch` intervertit les deux valeurs du sommet de la pile.
Ainsi, le programme `1 2 exch` résulte en la pile `[ 2 1 ]` (alors que le programme `1 2` résulte en la pile `[ 1 2 ]`).

Test pertinent :

- `dune runtest test/exch.t`

### Instruction `pop`
L'instruction `pop` enlève la valeur au sommet de la pile.
Ainsi, le programme `1 2 pop` résulte en la pile `[ 1 ]`.

Test pertinent :

- `dune runtest test/pop.t`

## Instructions arithmétique et de comparaison
### Arithmétique : `add`, `mul`, `div`, `sub`
Ces 4 instructions correspondent respectivement à l'addition, la multiplication, la division, et la soustraction.
Elles fonctionnent aussi bien sur des valeurs entières que des valeurs réelles, ou un mélange des deux.
Il y a présence de conversion implicite: ajouter un entier et un réel résulte en un réel; diviser deux entiers résulte en un réel. 
Vous êtes libres d'implémenter les conversions implicites tant que les tests sont validés.
Dans le doute, demander des précisions à l'enseignant.
Voici quelques exemples de résultats attendus :

```ps
1 2 add % sommet de la pile: 3 
1.5 2 add % Sommet de la pile: 3.5
2 3 mul % Sommet de la pile: 6
2 3.0 mul % Sommet de la pile 6.0
5 2 div % Sommet de la pile: 2.5 (division réelle)
5 2 sub % Sommet de la pile: 3
```

Test pertinent :

- `dune runtest test/add.t`

## Comparaison : `lt`, `gt`
Ces deux instructions sont les comparaisons: `lt` correspond à l'opérateur de comparaison $<$, et `gt` à l'opérateur de comparaison $>$.
Le résultat d'une comparaison est **un booléen**. (Les instructions de comparaisons sont la seule façon d'avoir des booléens à l'exécution.)

Par exemple :

```ps
1 2 lt % Sommet de la pile: true, car 1 < 2 est vrai
1 1 lt % Sommet de la pile: false, car 1 < 1 est faux
1 2 gt % Sommet de la pile: false, car 1 > 2 est faux
2 1 gt % Sommet de la pile: true, car 2 > 1 est vrai
```


Tests pertinents :

- `dune runtest test/lt.t`
- `dune runtest test/gt.t`


## Modulo : `mod`
L'instruction `mod` implémente le modulo.

Par exemple :

```ps
15 5 mod % sommet de la pile: 0
```

Test pertinent :

- `dune runtest test/mod.t`

## Instructions de contrôle
Les instructions de contrôle sont utilisées pour créer des procédure et effectuer des répétitions ainsi que des conditions.

### Création de procédure
Une procédure est crée en entourant du code d'accolades : le code `{ 1 2 }` crée une procédure qui, quand elle sera invoquée, effectuera les instructions `1 2`.
La création de procédure est représentée par une instruction `Procedure` du type `Instr.t`, contenant une liste d'instructions.

Test pertinent :

- `dune runtest test/constproc.t`

### Répétitions : `repeat`
L'instruction `repeat` prends sur la pile une procédure $f$ à invoquer, et un nombre $n$ de répétitions. La procédure $f$ sera alors invoquée $n$ fois consécutivement.

Par exemple, le programme suivant pousse le nombre `42` 10 fois sur la pile, et enlève ensuite les 5 premiers éléments de la pile :

```ps
10 { 42 } repeat
5 { pop } repeat
stack % pile résultante: [ 42 42 42 42 42 ]
```

Pour un autre exemple, le programme suivant compte de 1 à 10 :

```ps
0 % commence à compter à 0
% répéter 10 foix: dupliquer le compteur courant, y ajouter un
10 { dup 1 add } repeat
stack % résultat attendu: [ 10 9 8 7 6 5 4 3 2 1 0 ]
```

Test pertinent :

- `dune runtest test/repeat.t`
- `dune runtest test/repeat2.t`
- `dune runtest test/repeat3.t`

### Condition : `if`

L'instruction `if` prends sur la pile une procédure $f$ à invoquer, et un booléen $b$. Si le booléen est `true`, alors la procédure $f$ est invoquée, s'il est `false`, rien ne se passe. Si $f$ n'est pas une procédure ou $b$ n'est pas un booléen, on a une erreur de type.

Par exemple :

```ps
1 0 lt { 42 } if % résulte en la pile vide [  ] car 1 < 0 est faux
1 0 gt { 42 } if % résulte en la pile [ 42 ] car 1 > 0 est vrai
```

Test pertinent :

- `dune runtest test/if.t`

### Condition : `ifelse`

L'instruction `ifelse` est similaire à `if`, mais prends sur la pile deux procédures $f_2$ et $f_1$, et un booléen $b$. Si le booléen est `true`, alors $f_1$ est invoquée, sinon si le booléen est `false` c'est $f_2$ qui est invoquée. Si $f_1$ ou $f_2$  ne sont pas des procédures, ou que $b$ n'est pas un booléen, on a une erreur de type.

Par exemple :

```ps
1 0 lt { 42 } { 43 } ifelse % résulte en la pile [ 43 ]
```

Test pertinent :

- `dune runtest test/ifelse.t`

## Instructions de dessin

Plusieurs instructions permettent de dessiner des droites dans une image.
Les instructions de dessins doivent êtres implémentées en utilisant le module `Draw`.
Vous pouvez regarder son implémentation dans `ps/draw.ml`, ou observer sa signature avec `dune utop` :

```
# #show Tp1_ps.Draw;;
module Draw :
  sig
    type draw_action =
        MoveTo of float * float
      | RMoveTo of float * float
      | LineTo of float * float
      | RLineTo of float * float
      | Translate of float * float
      | Rotate of float
      | Stroke
    type t = draw_action list
    val empty : t
    val translate : t -> float -> float -> t
    val rotate : t -> float -> t
    val stroke : t -> t
    val move_to : t -> float -> float -> t
    val rmove_to : t -> float -> float -> t
    val line_to : t -> float -> float -> t
    val rline_to : t -> float -> float -> t
    val line_width : float
    val output : t -> string -> unit
  end
```

Le type `Draw.t` correspond à l'état actuel du dessin. C'est une structure immuable : les opérations de dessin retournent donc un nouvelle valeur de `t` à chaque appel.
Le dessin commence à la coordonnée `(0, 0)`, et les instructions de dessins déplacent la coordonnée courante tout en dessinant ce qu'il faut. **Il n'y a rien à faire de particulier pour gérer la coordonnée courante ou le dessin, au delà d'appeler les fonctions pertinentes de `Draw`**.

Les tests pertinents utilisent plusieurs instructions de dessins, et sont les suivants :

- `dune runtest test/quad.t`
- `dune runtest test/circ.t`
- `dune runtest test/wheel.t`
- `dune runtest test/eye.t`

Vous pouvez ouvrir les fichiers `.ps` correspondant avec un visionneur de fichier Postscript (votre visionneur de fichier PDF devrait faire l'affaire) pour voir le résultat attendu.

Vous pouvez visualiser les images générées par votre implémentation avec la commande suivante, où `input.ps` correspond au fichier `.ps` du fichier de test (par exemple, `test/quad.ps`), et `output.png` sera l'image créée.
```sh
dune exec -- tp1 input.ps output.png
```

### Instruction `translate`

L'instruction `translate` effectue une translation du plan de dessin.
Elle prends deux valeurs entières ou réelles depuis la pile.
Par exemple :

```ps
100 150 translate
```

Effectue une translation de 100 sur les x et de 150 sur les y. Cela se fera avec un appel à `Draw.translate draw_state 100. 150.`, où `draw_state` et l'état courant du dessin.
Les autres instructions de dessin opèrent de manière similaire

### Instruction `rotate`
L'instruction `rotate` effectue une rotation selon un angle (entier ou réel).
Par exemple :

```ps
45 rotate
```

Fait une rotation de 45° en appelant `Draw.rotate draw_state 45.`

### Instruction `moveto`

L'instruction `moveto` effectue un déplacement à une coordonnée, composée de deux nombres entiers ou réels.

Par exemple :

```ps
10 20 moveto
```

Effectue un déplacement à la coordonnée (10, 20), en appelant `Draw.move_to 10. 20.`

### Instruction `rmoveto`

L'instruction `rmoveto` est similaire à `moveto`, mais effectue un déplacement relatif.

Par exemple :

```ps
10 20 rmoveto
```

Effectue un déplacement de 10 sur l'axe des x, 20 sur l'axe des y,  en appelant `Draw.rmove_to 10. 20.`

### Instruction `lineto`

L'instruction `lineto` effectue un déplacement à une coordonnée, composée de deux nombres entiers ou réels, tout en dessinant une ligne.

Par exemple :

```ps
10 20 lineto
```

Effectue un déplacement à la coordonnée (10, 20) en dessinant une ligne depuis le point courant, en appelant `Draw.line_to 10. 20.`

### Instruction `rlineto`

L'instruction `rlineto` est similaire à `lineto`, mais effectue un déplacement relatif.

Par exemple :

```ps
10 20 rlineto
```

Effectue un déplacement de 10 sur l'axe des x, 20 sur l'axe des y, tout en dessinant une ligne depuis le point courant,  en appelant `Draw.rline_to 10. 20.`

### Instruction `stroke`

L'instruction `stroke` indique qu'il faut dessiner le chemin qui a été dessiné jusqu'ici à coup de `lineto` et de `rlineto`.

Par exemple :

```ps
stroke
```

Conclut un chemin. Cette instruction ne prends rien de la pile. Elle appelle `Draw.stroke draw_state`.

## Instructions de manipulation de références

Il ne reste plus que trois types d'instructions qui permettent de faire des définitions et de faire référence à des définitions.

### Référence

Une référence est introduite avec un symbole commençant par le caractère `/`.
Par exemple :

```ps
/foo
```

Introduit une référence nommée `foo`. Cela est représenté par l'instruction `Reference "foo"` du type `Instr.t`.
Une référence est une valeur comme une autre, qui peut être présente sur la pile.

Une référence s'affiche avec son nom, par exemple le programme suivant affiche `[ foo ]`

```ps
/foo stack
```

Test pertinent :

- `dune runtest test/ref.t`

### Instruction `def`

L'instruction `def` assigne une valeur à une référence. Les références sont des variables globales, définies à partir du moment où `def` s'est exécuté.

Par exemple, le programme suivant associe la valeur 42 à la référence `foo`. La pile résultante est vide.

```ps
/foo 42 def
```

Il sera fréquent d'associer des procédures aux références, par exemple on défini ci-dessous une procédure appelée `inc` qui incrémentera la valeur au sommet la pile :

```ps
/inc { 1 add } def
```

Test pertinent :

- `dune runtest test/define.t`

### Utilisation de référence
Une référence peut être utilisée simplement en la nommant. Cela se fait sans utiliser de `/` devant son nom.
Nommer une référence aura pour effet de :

- si la référence est associée à une procédure, exécuter le code correspondant à cette procédure
- si la référence est associée à une autre valeur, mettre cette valeur sur le sommet de la pil

Par exemple, le programme suivant aura comme pile finale `[ 42 ]` :

```ps
/twentyone 21 def
/two 2 def
twentyone two mul
stack % [ 42 ]
```

Le programme suivant quant à lui aura également comme pile finale `[ 42 ]` :

```ps
/timestwo { 2 mul } def
21 timestwo
stack % [ 42 ]
```

Tests pertinents :

- `dune runtest test/refconst.t`
- `dune runtest test/refconst2.t`
- `dune runtest test/refproc.t`
- `dune runtest test/refproc2.t`
- `dune runtest test/fib.t`

Tests de dessins pertinents :

- `dune runtest test/fibdraw.t`
- `dune runtest test/gosper.t` (plus lent)

## Gestion des erreurs

Le type de retour de `run` est un `(string list, string) result`.
Tout ce qui a été défini jusqu'ici est pour gérer les cas de programmes corrects.
Cependant, tout programme MiniPostscript à exécuter n'est pas correct.
Par exemple, le programme suivant est incorrect :

```ps
1 2 lt 3 lt
```

L'erreur est que `1 2 lt` résulte en une pile qui contient le booléen `true`, qu'on essaye ensuite de comparer à `3`. C'est une erreur car on ne peut pas comparer un booléen et un nombre.
L'évaluation de ce programme doit échouer avec une erreur de type, ce qui sera représenté par un résultat `Error "type error"` dans ce cas.

Une autre erreur qui peut arriver est d'essayer de prendre des valeurs sur une pile vide. Par exemple, le programme suivant échoue car `add` attend deux valeurs sur la pile mais il n'y en a qu'une :

```ps
1 add
```

Dans le cas d'une erreur de pile vide, on s'attend à l'erreur `Error "empty stack"`.

Le dernier cas d'erreur est l'utilisation d'une référence non définie. Par exemple, le programme suivant donne lieu à l'erreur `Error "undefined reference"` :

```ps
foo
```


Vous devez donc gérer les erreurs de façon fonctionnellement pure dans votre TP.
Le point d'entrée se chargera d'afficher les erreurs retournées par `run`.

Tests pertinents :

- `dune runtest test/stack_error.t`
- `dune runtest test/type_error.t`
- `dune runtest test/ref_error.t`

## Explication de l'architecture choisie

Au début de votre fichier `tp1.ml`, on vous demande d'ajouter un commentaire qui explique vos choix de conception pour les éléments suivants :

- Expliquer comment les erreurs sont gérées
- Expliquer comment les résultats affichés par l'instruction `stack` sont gérés
- Expliquer un endroit où vous avez utilisé une fonction d'ordre supérieure, et pourquoi c'est utile dans ce cas.
- Expliquer un endroit où vous avez utilisé un repli (*fold*), et pourquoi c'est utile dans ce cas.

**Si vous n'avez pas utilisé de fonction d'ordre supérieure ou de repli, expliquez pourquoi cela ne s'est pas avéré nécessaire dans votre cas.**

Pour chacun de ces éléments, quelques phrases suffisent.

# Modalités de remise

Le TP est à remettre pour le dimanche **23 mars** (fin de la semaine 10).

## Checklist

- [ ] Votre dépôt est un fork privé
- [ ] L'enseignant (utilisateur `quentin`) a été ajouté comme *mainteneur* du projet
- [ ] Votre nom et code permanent sont inscrits en commentaire au début de `lib/tp1.ml`
- [ ] Le projet compile : `dune build`
- [ ] Les tests passent : `dune test`
- [ ] Le linter n'émet pas d'erreurs : `dune build @lint`
- [ ] Le résultat de `dune exec -- tp1 ./test/gosper.ps gosper.png` produit l'image attendue (à comparer avec un visualiseur Postscript)
- [ ] Le code est documenté
- [ ] Les choix architecturaux sont expliqués en commentaire au début du fichier
- [ ] Le projet respecte le [guide de style](https://inf6120.uqam.ca/style/)

# Grille de correction

| Élément                                            | Pondération |
| -------------------------------------------------- | ----------: |
| Tests                                              | 70%         |
| L'image générée par `gosper.ps` est comme attendue | 5%          |
| Temps d'exécution de `gosper.ps`                   | 5%          |
| Explication des choix                              | 10%         |
| Qualité du code et documentation                   | 10%         |


Le temps d'exécution de référence pour `gosper.ps` est de 4.35 secondes.

Pénalités :

- Si le projet ne compile pas avec `dune build`: pénalité pouvant aller jusque 100%
- Si d'autres fichiers que `tp1.ml` ont été modifiés et que cela brise la correction: pénalité pouvant aller jusque 100%
- S'il y a des erreur de *lint* avec `dune build @lint`: pénalité pouvant aller jusque 100%
- Si aucun test ne passe, les autres éléments de correction recevront automatiquement la note de 0.
