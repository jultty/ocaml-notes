# Scripting with OCaml

OCaml can be used for scripting without much setting up. A shebang at the start of an OCaml file is ignored. Single-file scripts still get to access opam-installed libraries. 

For this script, I used an `utop` shebang:

```ocaml
#!/usr/bin/env utop
```

The goal here was to replace a simple bash function I used to edit scripts in my `PATH`:

```bash
function nvw {
  args=()
  for i in $@; do
    if [[ -f $(which "$i") ]]; then
      args+="$(which $i)"
    else
      echo "$i" not found on PATH
    fi
  done

  if [[ $args ]]; then
    echo "[nvw] Editing $args"
    nvim -p $args
  fi
}

```

While this worked as intended, at some point I wanted the function to also stage the edited files and launch an editor for the commit message, so I added the following to the bottom:

```bash
for a in "${args[*]}"; do
  dir=$(dirname $a)
  cd $dir
  git add "$a"
  git commit -e -m "$(basename $a): "
  cd -
done
```

The downside was that this didn't really check if the file had been changed at all. Adding this feature would further increase the function's complexity, so because I wanted to give OCaml scripting another try I started trying to implement it in OCaml. 

## Choosing my weapons

While searching online, I found several resources related to scripting:

- [shexp v0.16.0 (latest) · OCaml Package](https://ocaml.org/p/shexp/latest/doc/Shexp_process/index.html)
- [Cmdliner (cmdliner.Cmdliner)](https://erratique.ch/software/cmdliner/doc/Cmdliner/)
- [Unix system programming in OCaml](http://ocaml.github.io/ocamlunix/)

While `shexp` was the most popular, I couldn't find much documentation aside from the one linked above. `Cmdliner` seemed to have a bit more.

In the end, I ended up choosing to use neither as it seems that a lot is possible using just the `Unix` and `Sys` modules that are provided by the OCaml API itself:


```OCaml
open Unix ;;
open Sys ;;
```

## Utility functions

For no good reason other than toying with my first OCaml script, I wrote the following three functions in order to standardize output when logging for debug purposes.


```OCaml
let start s = print_endline ("\n,-< " ^ s)
let step s = print_endline ("| " ^ s)
```




    val start : string -> unit = <fun>







    val step : string -> unit = <fun>




Writing this script, I used the `^` operator a lot, which concatenates strings together.

`start` prints a newline and `,-< ` before its message, `step` prints a `|` before its message and `finish` prints `'-> ` before its message.

Combined, they allow output that looks like this:

```
,-< Generating hashes
| 60ce0778b6d6ae5 ...
| 9826a40a4966797 ...
| eb509d241c7f22d ...
'-> Done
```


```OCaml
let finish ?(s = "Done") () = print_endline ("'-> " ^ s) ;;
```




    val finish : ?s:string -> unit -> unit = <fun>




One useful thing I learned writing `finish`  was how to use optional arguments that have default parameter values. The `finish` method can be called with `()` as a single argument to print its default "Done" message, or with a custom one:


```OCaml
finish ~s:"A custom message" () ;;
```

    '-> A custom message





    - : unit = ()





```OCaml
finish () ;;
```

    '-> Done





    - : unit = ()




Next I define a few other utility functions.


```OCaml
let run c = input_line (open_process_in c)
```




    val run : string -> string = <fun>




`run` reads into a string the output of a command `c` called by `open_process_in`. This avoids repetition every time the output of a command is needed.


```OCaml
let confirm () = if (command "gum confirm 'Continue?'" != 0) then exit 0 else () 
```




    val confirm : unit -> unit = <fun>




The confirm dialog leverages [Charm](https://charm.sh/)'s [`gum`](https://github.com/charmbracelet/gum), which I used in my previous scripts and wanted to see how well it would fit here.

It prompts the user with a "Continue? Yes/No" dialog and exits the script if the answer is no.

## Argument parsing

Next comes the parsing of the received arguments. The first thing is discarding argument 0 (the script itself) and then converting that slice to a List:

```ocaml
let args = Array.to_list
  (Array.sub Sys.argv 1 (Array.length Sys.argv - 1)) ;;
```

Since this code runs in a Jupyter kernel, let's mock somefilepaths. The first one actually exists, the second doesn't:


```OCaml
let args = ["/home/juno/.jj/bin/nvw"; "/x/y/z"]
```




    val args : string list = ["/home/juno/.jj/bin/nvw"; "/x/y/z"]




## Path validation

Because I will use `which` to get the absolute filepaths from the environment's `PATH` variable, I also decide to use it to filter out any paths that do not correspond to a file.

To achieve this, the following function will return `true` if the exit code is `0`, meaning the file exists and is on `PATH`.


```OCaml
let get_exit c = command ("which " ^ c ^ " > /dev/null") = 0
```




    val get_exit : string -> bool = <fun>




There might be a better way to discard stdout? I did not look into it.

for the actual filtering, I use this pattern matching pattern based on an identical example [found in Cornell University's CS 3110 textbook](https://cs3110.github.io/textbook/chapters/hop/filter.html):


```OCaml
let rec filter_empty = function
  | [] -> []
  | h :: t -> if get_exit h then h :: filter_empty t else filter_empty t ;;

let existing_paths = filter_empty args ;;
```




    val filter_empty : string list -> string list = <fun>







    val existing_paths : string list = ["/home/juno/.jj/bin/nvw"]




By just looking at it at first I had no idea what it meant. After a step-by-step explanation from a friendly bot, I figured the function works like this:

1. If the received list is empty, return an empty list
2. If it's not empty, divide it into `h` (head) and `t` (tail)
  - `h` is the single first element of the list
  - `t` is all other elements
3. Apply `get_exit` to `h`
4. If `get_exit` returns `true`, prepend `h` to the result of the recursion on `t`
5. If `get_exit` returns `false`, recurse on `t` alone, effectively discarding `h`

Now that a list of valid candidates for absolute paths is available we can assemble a list of such paths.


```OCaml
let which s = run ("which " ^ s)
```




    val which : string -> string = <fun>




This `which` function takes a string and returns the full path from the output of `which` on `s`.

With this function, we can use `List.map` to produce a list of paths:


```OCaml
let paths = List.map which existing_paths ;;
```




    val paths : string list = ["/home/juno/.jj/bin/nvw"]




As intended, the mocked `/x/y/z` path didn't make it into this list.

With this list of absolute, valid paths, we can also create a single space-separated string to pass to the editor.


```OCaml
let arg_paths = String.concat " " paths ;;
```




    val arg_paths : string = "/home/juno/.jj/bin/nvw"




Note that this assumes the paths don't contain spaces. If this assumption can't be made, they should be wrapped in quotes.

## Hashing and editing

Next, we need functions to produce hashes for the files before and after the editor is called, to know if there have been any changes.

`hash_cmd` returns a string containing a sha256sum invocation using argument `f` as the filename and piping to `cut` in order to store the hash only.


```OCaml
let hash_cmd f = "sha256sum " ^ f ^ " | cut -d ' ' -f 1"
```




    val hash_cmd : string -> string = <fun>




Probably a better idea to use OCaml itself for what `cut` is being used here.

Now the returned hash from each execution of `hash_cmd` can be stored with the absolute path as the key. This is what `table_add` does:


```OCaml
let table_add t k = Hashtbl.add t k (run (hash_cmd k)) ;;
```




    val table_add : (string, string) Hashtbl.t -> string -> unit = <fun>




`table_add` takes arguments `t` (table) and `k` (key).

It then calls `Hashtbl.add` on the table with `k` as the key and the output of `run (hash_cmd k)` as the value. Since `run` was already defined to return the output of a command, the output from `sha256sum` gets stored in the hashmap as the value for a key matching the absolute filepath.

Now a table can be created using the length of the `paths` list.


```OCaml
let table = Hashtbl.create (List.length paths) ;;
List.map (table_add table) paths ;;
```




    val table : ('_weak1, '_weak2) Hashtbl.t = <abstr>







    - : unit list = [()]




By using `List.map (table_add table) paths`, each path is passed as `table_add`'s `k` argument, which produces the hash from running the assembled `hash_cmd` and stores it as the corrresponding value.

For debugging purposes, I initially had this moment freeze before launching an editor, to check for potential errors. I ended up commenting it out later, and in the end removing it entirely.


```OCaml
(* confirm () ;; *)
```

```ocaml
let config_path = "/home/user/.config/nvim/commit.lua"
let cmd = "nvim -u " ^ config_path ^ " -p " ^ arg_paths ;;
let editor_exit = command cmd ;;
```

Calling the editor would heavily depend on the user and their environment. Above is an example similar to what I used, with a custom configuration file and a `-p` flag for opening each file as a tab.

The most important thing is passing `arg_paths` to the editor so the target files can be edited. So the three lines above could also be simply:

```ocaml
command ("nvim " ^ arg_paths) ;;
```

After the editor exits, the hashes need to be recalculated and stored in a different table:


```OCaml
let post_table = Hashtbl.create (List.length paths) ;;
List.map (table_add post_table) paths ;;
```




    val post_table : ('_weak3, '_weak4) Hashtbl.t = <abstr>







    - : unit list = [()]




Here I reuse the functions initially used for populating the first table. They weren't as reusable before I had to replicate the same logic for the second table and realize I could repeat myself less.

## Committing

With files changed and pre and post-editing hashes available through their absolute paths, now we must assemble the appropriate git commands to add and commit the changes _in case_ the hashes differ.

Since file and Git root paths will be needed by Git, the following utility functions were written to supply those:


```OCaml
let get_dir f = run ("dirname " ^ f) ;;
let get_root f = run ("git rev-parse --show-toplevel " ^ get_dir f) ;;
```




    val get_dir : string -> string = <fun>







    val get_root : string -> string = <fun>




These `get_*` functions will take a given absolute path to a file and return its containing directory or the root of its Git repo.

The `git_*` commands then use these functions to assemble  full `git` commands with arguments that allow calling `nvw` from any directory and still affect only the repository where each file belongs.


```OCaml
let git_pre f = "git -C " ^ (get_dir f) ;;
let git_add f = (git_pre f) ^ " add " ^ f ;;
let git_commit f = "lazygit -p " ^ (get_root f) ;;
```




    val git_pre : string -> string = <fun>







    val git_add : string -> string = <fun>







    val git_commit : string -> string = <fun>




I prefer [`lazygit`](https://github.com/jesseduffield/lazygit) here because a lot more information becomes available and several operations are possible before exiting, as opposed to locking oneself into the editor with just commit and abort possible.

Finally, `diff_hashes` will take a single absolute path as argument and look it up on both tables, returning `true` only when they are **different**.


```OCaml
let diff_hashes k = (Hashtbl.find table k) <> (Hashtbl.find post_table k) ;;
```




    val diff_hashes : string -> bool = <fun>




Since `diff_hashes` operates on this single argument, we can wrap another function around it that will execute the assembled git commands only if `diff_hashes` returns true.


```OCaml
let call_git_if_hashes_diff f = begin
  if diff_hashes f then begin
    ignore (command (git_add f));
    ignore (command (git_commit f));
  end else
    step ("Skipped: " ^ f ^ " matched hashes") ;
end ;;
```




    val call_git_if_hashes_diff : string -> unit = <fun>




The `ignore` function is used here to discard the return values. It is not needed, but gets rid of compiler warnings regarding the unexpected return of the command's exit code.

Now, using `List.map` we can apply `call_git_if_hashes_diff` to every path. This in turn will call `diff_hashes` and compare the hashes present on both pre and post-edit tables.

If the hashes differ, it will call `git_add` and `git_commit` for each file.


```OCaml
List.map call_git_if_hashes_diff paths ;;
```

    | Skipped: /home/juno/.jj/bin/nvw matched hashes





    - : unit list = [()]



Since in this notebook the editor is never really called, the output states that the hashes have matched.
## References

- [OCaml library : Sys](https://v2.ocaml.org/api/Sys.html#top)
- [OCaml library : Unix](https://v2.ocaml.org/api/Unix.html)
- [OCaml library : List](https://v2.ocaml.org/api/List.html)
- [OCaml library : Map.S](https://v2.ocaml.org/api/Map.S.html)
- [OCaml library : String](https://v2.ocaml.org/api/String.html)
- [OCaml library : Array](https://v2.ocaml.org/api/Array.html)
- [OCaml library : Stdlib](https://v2.ocaml.org/releases/5.1/api/Stdlib.html#EXCEPTIONEnd_of_file)
- [OCaml - Labeled arguments](https://v2.ocaml.org/manual/lablexamples.html#sec43)
- [Maps and Hash Tables - Real World OCaml](https://dev.realworldocaml.org/maps-and-hashtables.html)
- [Mutability and Imperative Control Flow · OCaml Documentation](https://ocaml.org/docs/mutability-imperative-control-flow#imperative-control-flow)
- [OCaml - The OCaml language: Control structures](https://v2.ocaml.org/manual/expr.html#ss%3Aexpr-control)
- [4.3. Filter - cs3110/textbook: The CS 3110 Textbook](https://github.com/cs3110/textbook)

