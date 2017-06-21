---
title: The Language of Geometry
author:
 - Mathias Sablé Meyer
 - Stanislas Dehaene
 - Marie Amalric
include-before: <script src="Main.js"></script>
css:
 - style.css
link-citations: true
---


Introduction
------------

We believe and will try to demonstrate that the human brain has the ability to
create very abstract mental representation of *pure* geometrical objects even
though all we can ever perceive are noisy representation of these.

This works through what we will designate as a *Language of Geometry*, LoG,
that can manipulate abstract rules and symbol to move between different layers
of representations, from what we noisily draw to what we see when we see
a not-quite-perfect circle.

Recurrence of simple geometrical shapes in human cognition
----------------------------------------------------------

### In a variety of cultures

![Neurospin's research lab specimen --- note both the ear rings and the
tattoo. Although finding reliable traces of this shape has proven difficult,
Buddhist mandalas contains deeply intricated geometrical regularities and seem
to date in this form at least back to the 5th century B.C. according to
@walcott2006mapping](res/NS.jpg)

Body painting is an example of long lasting traditions, have a look at the
highly abstract and geometrical
[maori](http://www.google.com/images?q=maori+tattoo+traditional&tbm=isch) tatoos
--- and compare it to the
[munduruku](http://www.google.com/images?q=munduruku+tattoo+traditional&tbm=isch)
ones.


### In prehistory

> “Nowadays, however, thanks to the attention paid to the abstract 'signs’ by
> Leroi-Gourhan, and to the discovery of similar non-figurative motifs in
> Australia and elsewhere (see above, p. 38), we have to come to terms with the
> possibility that these marks may have been of equal, if not greater,
> importance to Palaeolithic people than the 'recognizable' figures to which we
> have devoted so much attention. Certainly, it has been estimated that
> non-figurative marks are two or three times more abundant than figurative,
> and in some areas far more”
>
> -- <cite>
        *Journey Through the Ice Age* from Paul G. Bahn and Jean Vertut, page 166
    </cite>

While prehistoric figurative drawings are common in caves, especially in
western Europe --- see for example @Otte2017155, it appears that
non-figuratives shapes were also present.

One of the most common example through body painting, rock carving or drawing
are
[spirals](http://www.google.com/images?q=Kerbstones+Knowth+Newgrange&tbm=isch)
but Genevieve Von Petzinger published a comprehensive list of *abstract*
symbols you can find in various caves in France, see @vonPetzinger201437 ---
table 3 --- for a list of the symbols and where to find them.


### In the history of mathematics

In Euclid's *Elements*, as soon as the first book the notion of point is used,
as well as the notion of segment and immediately after of its potentially
infinite extension to a line. Same goes for circle, right angles and parallels.
While &#966; the golden ratio is already present in the book, the geometrical
relation to the spiral seems to absent.

### In children

Shape perception as program inference
-------------------------------------

![When we see the upper *complex* shape, don't we break it apart into its
abstract structure? And what level of granularity do we
have?](./res/ProgInference.png){ width=30% }


Our goal(s)
-----------

1. Create a model of the language of thought for the geometrical shapes.

    * This is done in the sense that the language and its implementation exist.
    You you actually play with them right [here](#sandbox-for-the-language)

    * **To do** : add weights to the language to get a notion of complexity for
    a given program, and thus for a given shape

        * The natural numbers should be weighted according to the log of the number
      according to weber's law --- see @Nieder2003149, @DEHAENE2003145 or
      @libertus2009behavioral for examples of neural correlates of this number
      line compression

        * It's a bit more tricky for the real numbers: what about &#960;? In many
      cases it will have a strong importance and thus should have a low
      complexity, but for example how should 2*&#960; compare to &#960;/2, one
      being "a full circle" while the other represents a right angle?

        * On the other hand, choices must be made so that 8 is 

    * **To do:** implement a backward inference algorithm that, given a shape,
    tries to find a program that matches it.

2. Prove that, in this model, the relevant shapes can all be generated and
   correspond to minimal program

3. Generate all the minimal programs and critically have a look at the
   corresponding shapes

4. Bootstrap with large scale experimentation

    * Subjective rating of shapes

    * Ability to remember the shape as a function of the complexity

    * Tracing/copying behaviour experiment

    * fMRI expectation: will the brain activity (Parietal? Prefrontal?) vary as
    a function of the complexity of a program?

    * MDL to link neuronal pattern to programming pattern?


The Language of Geometry (LoG)
------------------------------

### Syntax


|         |       |                                                          |
| :------ | :---: | :------------------------------------------------------- |
| Num     | ::=   | &#124; 0, 1, 2, -1, 1.5, pi, ...                         |
|         |       | &#124; Num + Num                                         |
|         |       | &#124; Num - Num                                         |
|         |       | &#124; Num \* Num                                        |
|         |       | &#124; Num / Num                                         |
|         |       |                                                          |
| Noises  | ::=   | &#124; POSITION_NOISE=Num,                               |
|         |       |   ACCELERATION_NOISE=Num,                                |
|         |       |   SECOND_ORDER_NOISE=Number                              |
|         |       |                                                          |
| Body    | ::=   | &#124; Body ; Body                                       |
|         |       | &#124; SetValues(speed=Num,accel=Num,curv=Num,curv'=Num) |
|         |       | &#124; Save(string)                                      |
|         |       | &#124; Load(string)                                      |
|         |       | &#124; Turn(Num)                                      |
|         |       | &#124; DiscreteRepeat(Num) { Body }                   |
|         |       | &#124; Integrate(Num)                                 |
|         |       | &#124; {}                                                |
|         |       |                                                          |
| Program | ::=   | &#124; Noises ; Body                                     |
|         |       | &#124; Body                                              |


### Design Choices --- Informal Semantics

A program either starts with 3 set values for the possible amount of noise or
it does not, in which case default values are used. Then the body of a program
is either a concatenation of bodys, with the usual syntax `;`, or an
instruction. Let us detail these a bit more.

#### What is intuitive

 * A `Number` is a number : simple operations are resolved, a single value is
   defined so far and this is `pi`.

    If you think we need more operations tell me or make a pull request, if it's
    easy to write in OCaml it's easy to add here.

 * `{}` is an empty program that does nothing.

 * At some point, the semantics of `Undefined` will be defined. In the
   meantime, it is not defined.

       Think of it as adding infinity to the language, but with a *I don't know
       where to stop* rather than an *I will never stop* semantics.

#### What is less so

##### `Save(string)` & `Load(string)`

These two instructions are used to respectively store and restore the current
context, or continuation. You can see it used in both the person example, with
a very simple use case of keeping positions stored, and in the star example
where it is dynamically over written.

##### `DiscreteRepeat(Num) { Program }`

This takes a Num as an argument, arbitrarily transforms it to an integer (it
just usually rounds it down, don't worry. See OCaml's Pervasive.int_of_float
for more details), executes the given Program the specified mount of time.

Note that it only concatenates the program so far: if you want to play with
backtracking, repetitions with/without modifications, and so on, you have to
play around with `Save` and `Load`.

##### `SetValues(...)` & `Integrate(Num)`

These are the core instructions to understand. Imagine the program as a set of
instructions for your hand, holding a pencil, drawing something on a piece of
paper: `SetValues(...)` prepares the movement, the acceleration, and so on,
while `Integrate(Num)` executes it during an arbitrary unit of **time**.

More specifically, you can set four values with SetValues (the order doesn't matter and there are default values for the forgotten one):

 * **speed** is the speed
 * **accel** is the acceleration
 * **curv** is the curvature (t stands for &#952;)
 * **curv'** is the variation of the curvature


The default values are respectively `speed = 1`, `accel = 0`, `curv = 0` and
`curv' = 0` which means that if you `Integrate(100)` without changing anything,
you'll go straight forward at constant speed for 100 units of times.

##### `Turn(Num)`

This operates an *on the spot* rotation of the hand, the angle depending on the
argument. The square example is the most straightforward use of this
instruction.

*Remark*: this is syntactic sugar in terms of semantics with `Turn(θ)` being
the same as `SetValues(speed=0,curv=θ) ; Integrate(1)`

#### About the noise

The first line can be used to change the amount of noise. The syntax will be
changed later on, currently what you are setting is a dB attenuation of the
noise, therefore 0 leads to infinite noise while inf leads to no noise.

The syntax may be changed but this gives interesting results as it stands:
a value over 10 leads to an almost pixel-perfect shape, while values between
0.5 and 5 lead to more noisy shapes, each value changing the type of noise.
Play around with them to make yourself an intuition.

### Formal Semantics

As everything is not completely decided yet, the semantics of a program at any
given moment is given by its operation semantics for the available interpreter
I wrote. This is going to change one we move on to adding complexity, because
by this time the semantics will need to be fully specified.

Sandbox for the language
------------------------

You may look for inspiration [here](./examples/)

<form>
    <textarea id="program" rows="10">POSITION_NOISE=0.7,ACCELERATION_NOISE=5,SECOND_ORDER_NOISE=5;
SetValues(speed=1.5,curv'=0.0001) ;
Integrate(600)
    </textarea>
    <div class="centerize">
        <button id="interpret" type="button">Interpret!</button>
        </div>
</form>
<div id="programCanvas"></div>

-------------------------------------------------------------------------------
