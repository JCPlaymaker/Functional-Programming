# TP0 : Anagrammes - Énoncé

(Note Obtenue : 100/100)

Le but de ce TP est de mettre en pratique les concepts appris pendant le cours, en particulier la modélisation d'un problème avec un langage fonctionnel à typage statique fort.

En particulier, le but sera de trouver des anagrammes dans une liste de mot. Deux mots sont des anagrammes quand ils contiennent les même lettres, mais pas spécialement dans le même ordre. Par exemple, les mots `ateliers` et `lesterai` sont des anagrammes.

Ce travail est à faire **seul**.

## Observez la structure du projet :

- le dossier `lib/` contient le fichier `tp0.ml`, qui est là où vous devez implémenter le TP ;
- le dossier `test/` contient les tests publics ;
- le dossier `bin/` contient un point d'entrée, au cas où vous souhaitez exécuter votre code en tant que binaire. Pour ce faire, vous pouvez éditer `bin/main.ml` et lancer par exemple `dune exec -- tp0 ./small.txt`.

Vous pouvez utiliser UTop pour expérimenter avec votre implémentation : lancez `dune utop` depuis le dossier principal, ensuite vous pouvez accéder à votre code qui se trouve dans le module `Tp0`, vous pouvez donc soit faire `open Tp0` pour ouvrir l'espace de nom, ou appeler vos fonctions préfixées de `Tp0.fonction`

## Dépendances

Avant tout, vérifiez que vous utilisez bien la version 4.14.2 d'OCaml :

``` sh
$ ocamlc --version
4.14.2
```


La commande suivante, à lancer depuis le dossier du TP, permet d'installer les dépendances nécessaires au TP :
``` sh
opam install . --deps-only
```

## Fonctions à implémenter

Toute implémentation se fera dans le fichier `lib/tp0.ml`. C'est le seul fichier qui sera considéré pour la correction. On vous demande d'implémenter les fonctions détaillées ci-dessous. Vous pouvez implémenter toute autre fonction intermédiaire pour vous aider.

Vous **ne pouvez pas** changer le fichier `.mli` qui s'assure que le type des fonctions que vous définissez correspond aux attentes.

Vous **pouvez** changer des `let` en `let rec` si nécessaire.

## `explode`

Compléter la définition de la fonction `explode : string -> char list`. Pour cela, utilisez les fonctions suivantes fournie par la bibliothèque standard du langage :

- [String.to_seq](https://ocaml.org/manual/4.14/api/String.html#VALto_seq)
- [List.of_seq](https://ocaml.org/manual/4.14/api/List.html#VALof_seq)

Pour information, les séquences (type `Seq.t`) sont très similaires aux listes (type `List.t` ou `list`), à la seule différence que le contenu d'une séquence n'est pas évalué à sa construction. Pour cette question, cela importe peu : il se trouve simplement que le langage ne permet de transformer une chaîne de caractères qu'en séquence et pas en liste directement.

Exemple d'utilisation

``` ocaml
# Tp0.explode "anagramme";;
- : char list = ['a'; 'n'; 'a'; 'g'; 'r'; 'a'; 'm'; 'm'; 'e']
```

## module `Histogram`

Afin de déterminer si deux mots sont des anagrammes, nous allons représenter chaque mot par un *histogramme*, c'est-à-dire une structure qui compte le nombre d'occurrence de chaque lettre. Par exemple, le mot `tri` contient un `t`, un `r`, et un `i` et sera représenté par l'histogramme suivant :

```ocaml
# [('i', 1); ('r', 1); ('t', 1)];;
- : (char * int) list = [('i', 1); ('r', 1); ('t', 1)]
```

On représentera toujours un histogramme dans une forme standardisée par le tri de la bibliothèque standard. C'est-à-dire que l'histogramme ci-dessus peut-être obtenu de la façon suivante :

```ocaml
# List.sort Stdlib.compare [('t', 1); ('r', 1); ('i', 1)];;
- : (char * int) list = [('i', 1); ('r', 1); ('t', 1)]
```

On pourra alors trouver des anagrammes en comparant leur histogrammes. Par exemple, le mot `rit` possède le même histogramme :

```ocaml
# List.sort Stdlib.compare [('r', 1); ('i', 1); ('t', 1)];;
- : (char * int) list = [('i', 1); ('r', 1); ('t', 1)]
```

`rit` et `tri` sont donc des anagrammes.

Nous avons défini un module `Histogram`, qui reprend déjà une définition de type `t`, correspondant à cette structure. Dans ce module, nous allons définir des fonctions pour construire et manipuler des histogrammes.

### `Histogram.add`

Définir la fonction `add : t -> char -> t` du module `Histogram`, qui ajoute an caractère à un histogramme.

Par exemple :

``` ocaml
# let empty_histogram = [];;
val empty_histogram : Tp0.Histogram.t = []
# Tp0.Histogram.add empty_histogram 't';;
- : Tp0.Histogram.t = [('t', 1)]
# Tp0.Histogram.add (Tp0.Histogram.add empty_histogram 't') 'r';;
- : Tp0.Histogram.t = [('t', 1); ('r', 1)]
# Tp0.Histogram.add (Tp0.Histogram.add empty_histogram 't') 't';;
- : Tp0.Histogram.t = [('t', 2)]
```

### `Histogram.of_string`
Définir la fonction `of_string : string -> t` du module `Histogram` qui convertit une chaîne de caractère en histogramme. La fonction `explode` définie précédemment aidera à cette tâche. Il est important de trier l'histogramme également.

Par exemple :

``` ocaml
# Tp0.Histogram.of_string "tri";;
- : (char * int) list = [('i', 1); ('r', 1); ('t', 1)]
# Tp0.Histogram.of_string "rit";;
- : (char * int) list = [('i', 1); ('r', 1); ('t', 1)]
# Tp0.Histogram.of_string "rit" = Tp0.Histogram.of_string "tri"
bool = true
```

### `Histogram.compare`

Afin de pouvoir enregistrer les histogrammes de façon efficace dans une association (un `Map` similaire au `TreeMap` de Java), nous avons besoin de pouvoir les comparer.

Définir la fonction `compare : t -> t -> int` du module `Histogram` qui compare deux histogrammes et retourne `0` s'ils sont égaux, `1` si le premier est plus grand que le second, `-1` sinon. On définira celle-ci de la manière suivante

Les éléments de l'histogramme sont comparés un à un, et pour comparer l'élément `(c1, n1)` avec `(c2, n2)`:

- si `c1 = c2` et `n1 = n2`, alors ces éléments sont égaux et on continue
- si `c1 != c2`, le résultat de la comparaison est égal à `Stdlib.compare c1 c2`
- si `c1 = c2` mais que `n1 != n2`, le résultat de la comparaison est égal à `Stdlib.compare n1 n2`

Si :
- on se retrouve à devoir comparer deux histogrammes vides (`[]`), ils sont égaux
- on se retrouve à devoir comparer un histogramme vide avec un non-vide :
  - si le premier histogramme est vide, le résultat est `-1`
  - si le second histogramme est vide, le résultat est `1`

Pour information, `Stdlib.compare a b` retourne 1 si `a > b`, 0 si `a = b`, et `-1` si `a < b`. 
Par exemple, sur les entiers et sur les caractères, le résultat serait :

``` ocaml
# Stdlib.compare 1 2;;
# Stdlib.compare 'a' 'b';;
```

Le résultat de `Histogram.compare` devrait être le suivant

``` ocaml
# Tp0.Histogram.compare [] [];;
- : int = 0
# Tp0.Histogram.compare [('a', 1)] [('b', 1)];;
- : int = -1
# Tp0.Histogram.compare [('a', 1)] [('a', 2)];;
- : int = -1
# Tp0.Histogram.compare [('a', 1)] [('a', 1); ('b', 1)];;
- : int = -1
# Tp0.Histogram.compare [('a', 1); ('b', 1)] [('a', 1); ('b', 1)];;
- : int = 0
# Tp0.Histogram.compare [('a', 1); ('b', 1)] [('a', 1); ('b', 2)];;
- : int = -1
# Tp0.Histogram.compare [('a', 1); ('b', 1)] [('a', 1)];;
- : int = 1
# Tp0.Histogram.compare [] [('a', 1)];;
- : int = -1
# Tp0.Histogram.compare [('a', 1)] [];;
- : int = 1
```

## `are_anagrams`

Définir la fonction `are_anagrams : string -> string -> bool` qui vérifie que deux mots sont des anagrammes.

Par exemple :

``` ocaml
# Tp0.are_anagrams "tri" "rit";;
- : bool = true
# Tp0.are_anagrams "tri" "riz";;
- : bool = false
```

## `find_anagrams`

Finalement, définir la fonction `find_anagrams : string list -> string list list`. Cette fonction prends en entrée une liste de mots, et les groupe en classes d'anagrammes. On ne souhaite obtenir en résultat que des groupes d'anagrammes possédant au minimum deux mots.

Par exemple :

``` ocaml
# Tp0.find_anagrams ["riz"; "rit"; "tri"; "tir"; "ateliers"; "lesterai"];;
- : string list list = [["lesterai"; "ateliers"]; ["tir"; "tri"; "rit"]]
```

Ici:

  - `rit`, `tri`, et `tir` sont des anagrammes
  - `lesterai` et `ateliers` sont des anagrammes
  - `riz` n'est pas dans le résultat car il n'est anagramme d'aucun mot donné en entrée
  
Afin de faciliter la tâche, vous pouvez voir que le fichier `tp0.ml` contient déjà la ligne suivante :

``` ocaml
module HistogramMap = Map.Make(Histogram)
```

Cela permet de faire des associations (*map*) d'histogrammes. Le module `HistogramMap` ainsi défini contient un type `'a HistogramMap.t`, dont les valeurs associent à chaque histogramme une valeur de type `'a`. Vous pouvez vous référer au [tutoriel sur les Maps](https://ocaml.org/docs/maps) pour plus d'informations. Les fonctions suivantes vous seront utiles :

- [update](https://ocaml.org/manual/4.14/api/Map.Make.html#VALupdate)
- [empty](https://ocaml.org/manual/4.14/api/Map.Make.html#VALempty)
- [bindings](https://ocaml.org/manual/4.14/api/Map.Make.html#VALbindings)
- [filter](https://ocaml.org/manual/4.14/api/Map.Make.html#VALfilter)

Note: il n'est pas strictement nécessaire d'utiliser `HistogramMap` pour implémenter `find_anagrams`, mais il sera alors plus difficile d'obtenir une implémentation concise et efficace.

## Point d'entrée

Observer le fichier `bin/main.ml`. Celui-ci lit un fichier passé en argument, ligne par ligne, et passe toutes les lignes à `find_anagrams`, avant d'afficher le résultat. Le temps d'exécution est mesuré et également affiché.

Vous pouvez exécuter le programme de la façon suivante, sur l'un des trois exemples fournis :

```sh
dune exec -- tp0 mini.txt
dune exec -- tp0 small.txt
dune exec -- tp0 full.txt
```

À titre de référence, le nombre de lignes, d'anagrammes attendus, et le temps d'exécution de la solution de référence sont les suivants :

- `mini.txt`: 1000 lignes, 42 anagrammes, 0.002 secondes
- `small.txt`: 22740 lignes, 1584 anagrammes, 0.06 secondes
- `full.txt`: 221377 lignes, 12690 anagrammes, 0.7 secondes

# Modalités de remises
Le TP est à remettre pour le dimanche **16 février** (fin de la semaine 6).

## Checklist

- [X] Votre dépôt est un fork privé
- [X] L'enseignant et le correcteur ont été ajoutés comme *mainteneurs* du projet
- [X] Votre nom et code permanent est inscrit en commentaire au début de `lib/tp0.ml`
- [X] Le projet compile : `dune build` 
- [X] Les tests passent : `dune test`
- [X] Le linter n'émet pas d'erreurs : `dune build @lint`
- [X] Le code est documenté
- [X] Le projet respecte le [guide de style](https://inf6120.uqam.ca/style/)

# Grille de correction

| Élément                          | Pondération |
| -------------------------------- | ----------: |
| Tests `explode`                  | 10%         |
| Tests `Histogram.add`            | 15%         |
| Tests `Histogram.of_string`      | 15%         |
| Tests `Histogram.compare`        | 15%         |
| Tests `Histogram.are_anagrams`   | 10%         |
| Tests `Histogram.find_anagrams`  | 10%         |
| Résultats d'exécution            | 5%          |
| Temps d'exécution                | 5%          |
| Qualité du code et documentation | 15%         |


Tout programme qui s'exécute en dessous d'une seconde avec `dune exec -- tp0` aura 5/5 pour le temps d'exécution. La qualité du code sera évaluée selon les bonnes pratiques usuelles et selon le [guide de style](https://inf6120.uqam.ca/style/).

Pénalités :

- Si le projet ne compile pas avec `dune build`: pénalité pouvant aller jusque 100%
- Si le fichier `tp0.mli` a été modifié et que cela brise la correction: pénalité pouvant aller jusque 100%
- S'il y a des erreur de *lint* avec `dune build @lint`: pénalité pouvant aller jusque 100%
