## Installation

The official OCaml website has [installation instructions](https://ocaml.org/install) for several different platforms. It mostly relies on [opam](https://opam.ocaml.org/), a package manager for the OCaml ecosystem that can also [manage virtual environments](https://opam.ocaml.org/doc/Usage.html#opam-switch).

If you just want to run OCaml code inside Jupyter Notebooks, you can get the [ocaml-jupyter kernel](https://github.com/akabe/ocaml-jupyter) to add it to your local Jupyter installation or use the `flake.nix` file in this repository if you have [Nix](https://nixos.org/) installed with flake support. For more on the flake implementation check out [jupyenv](https://github.com/tweag/jupyenv).

## Running OCaml code

OCaml files (extension `.ml`), can be compiled to bytecode executables using `ocamlc` or native executables using `ocamlopt`:

```sh
ocamlc hello.ml -o hello
ocamlopt hello -o hello_native
```

Bytecode executables are more portable across different platforms, while native executables have improved performance at the cost of little portability, longer compile time and increased filesizes.

If you want to use a REPL to evaluate code directly as you would do in a shell, you probably want [utop](https://github.com/ocaml-community/utop), which is also available through opam.

One last way of running OCaml code that is worth mentioning is in scripts. You can for instance write a file called `script.ml` with the following shebang:

```sh
#!/usr/bin/env ocaml

let () = print_endline "Hello, OCaml"
```

Supposing you are in a Linux-based system, you could then add execution permissions with `chmod +x script.ml` and you can now run this file with `./script.ml`. In this case, the `.ml` file extension is optional.

## Basic syntax

### Binding

In OCaml, what would usually called variables are actually all constants. 

The `=` operator can be used for binding a value to an identifier with the `let` keyword, but otherwise it will test for equality rather than reassigning.


```OCaml
let u = 8 ;;

u = 9
```




    val u : int = 8







    - : bool = false




If mutation is intended, you can either shadow or use `ref`:


```OCaml
let u = 7
```




    val u : int = 7





```OCaml
let r = ref 19 ;;

r
```




    val r : int ref = {contents = 19}







    - : int ref = {contents = 19}




The content of a reference can be dereferrenced with `!`:


```OCaml
!r
```




    - : int = 19




To update a reference, the `:=` operator is used:


```OCaml
r := !r + 1 ;;

r
```




    - : unit = ()







    - : int ref = {contents = 20}




> This returns `()` because changing the content of a reference is a side-effect. (A Tour of OCaml)

#### `in`

The `in` keyword can be used to use a given assignment only within a limited scope:


```OCaml
let z = 4 in z * z * z ;;

z
```




    - : int = 64





    File "[6]", line 3, characters 0-1:
    3 | z
        ^
    Error: Unbound value z



Now for a more complicated example:


```OCaml
let a = 500 in (let b = a * a in a + b)
```




    - : int = 250500




In the example above, `let b = a * a in a + b` is within parenthesis for clarity, but the same expression without parenthesis evaluates to the same value: 


```OCaml
let a = 500 in let b = a * a in a + b
```




    - : int = 250500




The expression between parenthesis will resolve `b` to the square of `a` and then add `a` and `b`. As `a` was defined to 500, we have:

$$
    \ \\
    a = 500 \\
    b = a^2 \\
    x = a + b \\
    x = 500 + 500^2 \\
    x = 250500 \\
$$


### Types and operators

OCaml has type inferrence, but types can also be explicitly declared:


```OCaml
let i = 3
let f = 3.0
```




    val i : int = 3







    val f : float = 3.





```OCaml
let c: char = 7.9
```


    File "[10]", line 1, characters 14-17:
    1 | let c: char = 7.9
                      ^^^
    Error: This expression has type float but an expression was expected of type
             char



The operators are similar to other programming languages I am familiar with:


```OCaml
2 + 2 = 4 ;;
3 - 3 = 0 ;;
1 + 6 * 2 = 13 ;;
```




    - : bool = true







    - : bool = true







    - : bool = true




If you divide integers, you will not get a float:


```OCaml
3 / 2 = 1
```




    - : bool = true




Logical operators are also similar to most other languages I am familiar with, except for the `<>` operator used for non-equality and the fact that a single `=` can be used for equality:


```OCaml
(2 = 2) && (3 > 1) && (5 <= 5) && (3 <> 0)
```




    - : bool = true




**Unlike** most languages I know, OCaml is strict about what types each operator is able to handle.

It will _not_ make its best attempt when passed expresions such as: 


```OCaml
5.0 / 2
```


    File "[14]", line 1, characters 0-3:
    1 | 5.0 / 2
        ^^^
    Error: This expression has type float but an expression was expected of type
             int




```OCaml
"type-strict" + "operators"
```


    File "[15]", line 1, characters 0-13:
    1 | "type-strict" + "operators"
        ^^^^^^^^^^^^^
    Error: This expression has type string but an expression was expected of type
             int




```OCaml
"won't even add chars to your strin" + "g"
```


    File "[16]", line 1, characters 0-36:
    1 | "won't even add chars to your strin" + "g"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    Error: This expression has type string but an expression was expected of type
             int




```OCaml
let x = 0

let y = if x then 3 else 1
```




    val x : int = 0





    File "[17]", line 3, characters 11-12:
    3 | let y = if x then 3 else 1
                   ^
    Error: This expression has type int but an expression was expected of type
             bool
           because it is in the condition of an if-statement



For operations between floats you want to use `+.`, `-.`, `*.` and `/.` instead:


```OCaml
(7.0001 -. 0.0001 = 14.0 /. 2.0) = (6.0 +. 1.0 = 3.5 *. 2.0)
```




    - : bool = true




I really like the way OCaml behaves here compared to many of the languages I studied, either with and without static typing and type inferrence, where all sorts of nonsense can happen due to operations involving different types being handled through implicit conversions.

However, you can still use comparison between chars:


```OCaml
'a' < 'z' && '@' > '&'
```




    - : bool = true




In fact, the `<` and `>` operators seem to be more flexible in this regard, also allowing for instance:


```OCaml
true > false
```




    - : bool = true





```OCaml
"a string" > "another"
```




    - : bool = false




Still, it won't compare integers and floats:


```OCaml
2 > 1.0
```


    File "[22]", line 1, characters 4-7:
    1 | 2 > 1.0
            ^^^
    Error: This expression has type float but an expression was expected of type
             int



The special keywords `max_int` and `min_int` evaluate to the corresponding minimal and maximum integer values possible:


```OCaml
max_int ;;
min_int ;;
```




    - : int = 4611686018427387903







    - : int = -4611686018427387904




If they are exceeded, they will wrap to their opposite:


```OCaml
max_int + 1 ;;
```




    - : int = -4611686018427387904




Therefore, we can say that:


```OCaml
max_int + 1 = min_int && min_int - 1 = max_int
```




    - : bool = true




### Flow control

As shown in the previous example where the integer value `0` was passed to an `if`, conditional structures are expressions in OCaml, meaning they can return values: 


```OCaml
2 * if "hello" = "world" then 3 else 5
```




    - : int = 10




Note that the whole expression must evaluate to the same type. In this example that wil be determined by the first type in the expression:


```OCaml
let x = if 100 > 99 then 0.1 else 0 ;;

x
```


    File "[27]", line 1, characters 34-35:
    1 | let x = if 100 > 99 then 0.1 else 0 ;;
                                          ^
    Error: This expression has type int but an expression was expected of type
             float
      Hint: Did you mean `0.'?



In the example above, the `0.1` value causes the `1` value to be considered wrong by the compiler as it doesn't match the type of the first value, `0.1`, a float.

Conversely, if we invert their positions, the compiler now emits an error on the second value not being an integer:


```OCaml
let x = if 100 > 99 then 0 else 0.1 ;;

x
```


    File "[28]", line 1, characters 32-35:
    1 | let x = if 100 > 99 then 0 else 0.1 ;;
                                        ^^^
    Error: This expression has type float but an expression was expected of type
             int



### Functions

This function takes `x` as an argument and returns $x^3$:


```OCaml
let cube x = x * x * x
```




    val cube : int -> int = <fun>




Notice how the interpreter response is stating `cube` is a value, printing it's signature of taking an integer and returning an integer (`int -> int`) and that it is a function.

So if we run cube on the number 4:


```OCaml
cube 4
```




    - : int = 64




Because `if` structures are expressions, they can be the body of a function:


```OCaml
let neg x = if x < 0 then true else false
```




    val neg : int -> bool = <fun>




However, the above function could be simplified to:


```OCaml
let neg x = x < 0
```




    val neg : int -> bool = <fun>




Calling the function with a negative value requires having it inside parenthesis:


```OCaml
neg (-30)
```




    - : bool = true




Whitington explains this as "We added parentheses to distinguish from neg - 30", but I did not really understand what was meant by that.

The error message is:


```OCaml
neg -30
```


    File "[34]", line 1, characters 0-3:
    1 | neg -30
        ^^^
    Error: This expression has type int -> bool
           but an expression was expected of type int



Functions with multiple parameters are possible and look just as you would expect from looking at the single-parameter ones:


```OCaml
let add j k = j+k ;;

add 8 12
```




    val add : int -> int -> int = <fun>







    - : int = 20




Notice how the signature returned by the interpreter looks like a curried function.

Recursive functions must use the `rec` keyword, otherwise the recursion call will state the function is unbound:


```OCaml
let factorial a =
  if a = 1 then 1 else a * factorial (a - 1)
```


    File "[36]", line 2, characters 27-36:
    2 |   if a = 1 then 1 else a * factorial (a - 1)
                                   ^^^^^^^^^
    Error: Unbound value factorial
    Hint: If this is a recursive definition,
    you should add the 'rec' keyword on line 1




```OCaml
let rec factorial a =
  if a = 1 then 1 else a * factorial (a - 1) ;;

factorial 4
```




    val factorial : int -> int = <fun>







    - : int = 24




The following sequence from Whitington's book was a nice, visual way to illustrate this recursion:
  factorial 4
  4 * factorial 3
  4 * (3 * factorial 2)
  4 * (3 * (2 * factorial 1))
  4 * (3 * (2 * 1))
  4 * (3 * 2)
  4 * 6
  24
OCaml is able to tell when an infinite recursion is going on:


```OCaml
factorial (-1)
```


    Stack overflow during evaluation (looping recursion?).
    Raised by primitive operation at factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    Called from factorial in file "[37]", line 2, characters 27-44
    


The built-in `not` function returns the boolean complement of its argument:


```OCaml
not false
```




    - : bool = true




> Write a function which returns true if both of its arguments are non-zero, and false otherwise. What is the type of your function? (Whitington)


```OCaml
let f a b = if a <> 0 && b <> 0 then true else false ;;

f 0 0 ;;
f 1 9 ;;
```




    val f : int -> int -> bool = <fun>







    - : bool = false







    - : bool = true




While the type of this function is `int -> int -> bool`, it could infer `float -> float -> bool` instead if 0.0 were used:


```OCaml
let f a b = if a <> 0.0 && b <> 0.0 then true else false ;;
```




    val f : float -> float -> bool = <fun>




### Pattern matching


```OCaml
let isvowel c =
  match c with
    'a' | 'e' | 'i' | 'o' | 'u' -> true
  | _ -> false ;;

isvowel 'j' ;;
isvowel 'u' ;;
```




    val isvowel : char -> bool = <fun>







    - : bool = false







    - : bool = true




## Data Structures

### Lists


```OCaml
let l = [ 1; 2; 3; ]
```




    val l : int list = [1; 2; 3]




The empty list, also called _nil_, is represented as `[]` and is of undertermined type $\alpha$ (`'a`).


```OCaml
[]
```




    - : 'a list = []




All non-empty lists have a head (its first element) and a tail. A list with a single element has this element as its head and `[]` as its tail.

The _cons_ operator, `::` , adds a single element to the front of the list:


```OCaml
0 :: l
```




    - : int list = [0; 1; 2; 3]




The _append_ operator, `@` , combines two lists together:


```OCaml
let m = [ 4; 5; 6; ] ;;

let n = l @ m
```




    val m : int list = [4; 5; 6]







    val n : int list = [1; 2; 3; 4; 5; 6]




#### Pattern matching with lists


```OCaml
let isnil l = 
  match l with
    [] -> true
  | _ -> false
```




    val isnil : 'a list -> bool = <fun>




> The argument has type α list (which OCaml prints on the screen as `’a` list) because this function does not inspect the individual elements of the list, it just checks if the list is empty. And so, this function can operate over any type of list.

> The greek letters α, β, γ etc. stand for any type. If two types are represented by the same greek letter they must have the same type. If they are not, they may have the same type, but do not have to. Functions like this are known as polymorphic. (Whitington)

The `::` operator can be used in pattern matching to deconstruct a list where in `h::t` you will obtain the head of the list assigned to `h` and the tail to `t`.:


```OCaml
let list = [ 1; 2; 3; ] ;;

let rec length l =
  match l with
    [] -> 0
  | _::t -> 1 + length t
```




    val list : int list = [1; 2; 3]







    val length : 'a list -> int = <fun>





```OCaml
length list
```




    - : int = 3




The above evaluates as follows:
    length [ 1; 2; 3; ]
=>  1 + length [ 2; 3; ]
=>  1 + (1 + length [3])
=>  1 + (1 + (1 + length []))
=>  1 + (1 + (1 + 0))
=>  1 + (1 + 1)
=>  1 + 2
=>  3
## References

Most of the examples used above are either from or adapted from John Whitington's OCaml from the Very Beginning, which is available online, for no cost, in a wonderful single-page HTML version.

- [John Whitington - OCaml from the Very Beginning](https://johnwhitington.net/ocamlfromtheverybeginning/)
- [OCaml Documentation - Compiling OCaml Projects](https://ocaml.org/docs/compiling-ocaml-projects)
- [OCaml Documentation - Basic Data Types and Pattern Matching](https://ocaml.org/docs/basic-data-types)
- [OCaml Documentation - A Tour of OCaml](https://ocaml.org/docs/tour-of-ocaml)
