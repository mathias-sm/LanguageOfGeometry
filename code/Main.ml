open Plotter
open Renderer
open Interpreter
open Printf
open Generator
open Unix

let _ = Random.self_init ()

let memory = Hashtbl.create 10007

let base = "enumNew"

let () =
    let counter = ref 1 in
    let sup = 1000000 in
    for i = 1 to sup do
        let c = new_canvas () in
        let p = generate_random () in
        (*pp_program Pervasives.stdout p ;*)
        (*print_newline () ;*)
        try begin
            let c = interpret c p in
            let cost = costProgram p in
            let hashable = canvas_to_hashable c in
            if Hashtbl.mem memory hashable then begin
                let (prev,id_first) = Hashtbl.find memory hashable in
                if prev > cost then begin
                    Hashtbl.replace memory hashable (cost,id_first) ;
                    Printf.printf "Found a better %d !" id_first ;
                    let oc =
                        open_out
                        (Printf.sprintf "/tmp/%s/%d.LoG" base id_first) in
                    let oc_w =
                        open_out
                        (Printf.sprintf "/tmp/%s/%d.cost" base id_first) in
                    let name =
                        Printf.sprintf "/tmp/%s/%d.png" base id_first in
                    output_canvas_png c name ;
                    pp_program oc p ;
                    Printf.fprintf oc_w "%d\n" cost ;
                    close_out oc ;
                    close_out oc_w
                    end
                else ()
                end
            else begin
                Hashtbl.add memory hashable (cost,!counter) ;
                Printf.printf "%d is new !" !counter ;
                let oc = open_out (Printf.sprintf "/tmp/%s/%d.LoG" base !counter) in
                let oc_w = open_out (Printf.sprintf "/tmp/%s/%d.cost" base
                !counter) in
                let name = Printf.sprintf "/tmp/%s/%d.png" base !counter in
                output_canvas_png c name ;
                pp_program oc p ;
                Printf.fprintf oc_w "%d\n" cost ;
                close_out oc ;
                close_out oc_w ;
                counter := !counter + 1 ;
            end
        end
        with MalformedProgram(s) -> ()
    done
