(* ref: https://github.com/leostera/reason-design-patterns/blob/master/patterns/smart-constructors.md *)

module Person = struct
  type t = { name : string; age : int }

  let make name age =
    if name = "" then None
    else if age < 0 then None
    else Some { name; age }

  let get_name person = person.name
  let get_age person = person.age
end

let p1 = Person.make "Alice" 30
let p2 = Person.make "" 25
let p3 = Person.make "Bob" (-5)

let () =
  let f e =
    match e with
    | Some p -> Printf.printf "Created person: %s, %d\n" (Person.get_name p) (Person.get_age p)
    | None -> Printf.printf "Failed to create person\n"
  in
    List.iter f [p1; p2 ;p3]
