open Plotter
open Renderer
open Interpreter
open Printf
open Generator
open Unix
open Images

let _ = Random.self_init ()

let memory : (int, int array array*int) Hashtbl.t = Hashtbl.create 10007

let readImage image (x,y) =
    let v = Array.make_matrix x y 0 in
    for i = 0 to x-1 do
        for j = 0 to y-1 do
            let elt = Rgba32.get image i j in
            (*let r = elt.color.r and g = elt.color.g and b = elt.color.b in*)
            let alpha = elt.alpha in
            (*assert (r = g) ;*)
            (*assert (g = b) ;*)
            (*if r > 0 then print_endline "FINALY!" ;*)
            (*if g > 0 then print_endline "FINALY!" ;*)
            (*if b > 0 then print_endline "FINALY!" ;*)
            (*print_int alpha ; print_newline () ;*)
            v.(i).(j) <- alpha
        done
    done ;
    v

let norm2Difference v1 v2 (x,y) =
    let r = ref 0. in
    for i = 0 to x-1 do
        for j = 0 to y-1 do
            let r1 = v1.(i).(j)
            and r2 = v2.(i).(j) in
            let error = float_of_int (abs (r1 - r2)) in
            r := !r +. error
        done
    done ;
    !r

let compare fname1 fname2 =
    let image1 = Png.load fname1 []
    and image2 = Png.load fname2 [] in
    let size1 = Images.size image1 and size2 = Images.size image2 in
    assert (size1 = size2) ;
    let image1 = match image1 with | Rgba32 v -> v | _ -> failwith "Nop1"
    and image2 = match image2 with | Rgba32 v -> v | _ -> failwith "Nop2" in
    let raw1 = readImage image1 size1
    and raw2 = readImage image2 size2 in
    norm2Difference raw1 raw2 size1

let base = "enumNew"
let threeshold = 100000.

let save p c name cost =
    let oc =
        open_out
        (Printf.sprintf "/tmp/%s/%s.LoG" base name) in
    let oc_w =
        open_out
        (Printf.sprintf "/tmp/%s/%s.cost" base name) in
    let name =
        Printf.sprintf "/tmp/%s/%s.png" base name in
    let s = pp_program p in
    Printf.fprintf oc "%s" s ;
    Printf.fprintf oc_w "%d\n" cost ;
    close_out oc ;
    close_out oc_w ;
    try output_canvas_png c name
    with Invalid_argument(_) -> print_endline "oopq I failed"


let findMoreExpensiveDoublon cost =
    let image = Png.load (sprintf "/tmp/%s/tmp.png" base) [] in
    let size = Images.size image in
    let image = match image with | Rgba32 v -> v | _ -> failwith "Nop3" in
    let raw = readImage image size in
    let exists = ref false in
    let shouldDiscard = ref false in
    let refId = ref (-1) in
    let toIter r_id (raw2,r_cost) =
        if (not !exists) then begin
            let distance = norm2Difference raw raw2 size in
            (*Printf.printf "Error : %f" distance ;*)
            (*print_newline () ;*)
            if (distance < threeshold) then begin
                exists := true ;
                refId := r_id ;
                if cost > r_cost then shouldDiscard := true
            end
        end
    in
    Hashtbl.iter toIter memory ;
    (raw, !exists, !shouldDiscard, !refId)

let () =
    let counter = ref 1 in
    let sup = 1000000 in
    for i = 1 to sup do
        let c = new_canvas () in
        let p = generate_random () in
        try begin
            let c = interpret c p false in
            let (path,box) = c in
            let cost = costProgram p in
            if not (Vg.P.equal path Vg.P.empty || Gg.Box2.equal box Gg.Box2.empty) then begin
                save p c "tmp" cost ;
                let (raw,exists,shouldDiscard,id) =
                    findMoreExpensiveDoublon cost in
                if exists && not (shouldDiscard) then begin
                    Hashtbl.replace memory id (raw,cost) ;
                    printf "%d was replaced" id ; print_newline () ;
                    save p c (sprintf "%d" id) cost
                end
                else if (not exists) then begin
                    Hashtbl.add memory (!counter) (raw,cost) ;
                    printf "%d is new" !counter ; print_newline () ;
                    save p c (sprintf "%d" !counter) cost ;
                    counter := !counter + 1
                end
            end
        end
        with MalformedProgram(s) -> ()
            (*let s' = pp_program p in*)
            (*Printf.printf "Error : %s in program :\n%s" s s'*)
    done

(*let () =*)
    (*let fname1 = "/tmp/enumNew/5.png"*)
    (*and fname2 = "/tmp/enumNew/3.png" in*)
    (*let v = compare fname1 fname2 in*)
    (*printf "%f" v ;*)
    (*print_newline ()*)
