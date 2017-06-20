---
title: The Language of Geometry
author: Mathias Sablé Meyer, Stanislas Dehaene, Marie Amalric
header-includes:
    <script src="Main.js"></script>
html_document:
    css: style.css
    toc: true
    toc_depth: 6
    toc_float:
        collapsed: false
        smooth_scroll: false
    smart: true
---

<script src="Main.js"></script>

The Language of Geometry
========================


Introduction
------------

As we believe in compositionallity and the ability to manipulate abstract
symbols in the brain, we are designing a language of geometry that allows for
this kind of operation. This is a proof of concept whose goal is to be
a proposal for a way to describe planar shapes in such a way that, with
a compositional semantics and cost function on the programs, the associated ---
unique modulo noise in the representation --- shape should match a human notion
of complexity.

The primitives were added so that relevant shapes, that we will describe
later on, feel intuitive to draw using the language. The same goes for
the complexity function.


Syntax
------


|         |     |                                                      |
| ------  | --- | -------------------------                            |
| Number  | ::= | 0, 1, 2, -1, 1.5, pi, ...                            |
|         |     |                                                      |
|         |     | Number + Number &#124;                               |
|         |     | Number - Number                                      |
|         |     |                                                      |
|         |     | Number \* Number &#124;                              |
|         |     | Number / Number                                      |
|         |     |                                                      |
|         |     |                                                      |
| Program | ::= | Program ; Program                                    |
|         |     | SetValues(t'=Number,v'=Number,v''=Number,t''=Number) |
|         |     | Save(string)                                         |
|         |     | Load(string)                                         |
|         |     | Turn(Number)                                         |
|         |     | DiscreteRepeat(Number) { Program }                   |
|         |     | Integrate(Number)                                    |
|         |     | {}                                                   |


Semantics
---------

### What is intuitive

Do not spend too much time on the semantics of `numbers`, `;` or `{}` (the
empty program), they just do what you expect.

### What is less so

#### `Save(string)` & `Load(string)`

#### `DiscreteRepeat(Number) { Program }`

#### `SetValues(...)`

#### `Integrate(Number)`



Remarks
-------

-   Basic operations are supported and `pi` = 3.14159265359 (hardcoded)
-   The syntax for numbers should be intuitive, although the semantics
    for the float to int conversion is undefined (have no fear, it
    should do what you expect though)
-   The semantics for Undefined is not defined for the moment. At some
    point this sould be used to describe "infinity" when drawing.



Input
-----

You may look for inspiration [here](./examples/)

<form><textarea id="program" rows="10">SetValues(t'=0.1,v''=0.05) ;
Integrate (1000)</textarea><div class="centerize"><button id="interpret" type="button">Interpret!</button> </div></form>


