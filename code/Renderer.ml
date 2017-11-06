open Vg
open Gg
open Plotter

type canvas = Plotter.canvas

let d_from_origin = 100.

(*let canvas_to_hashable :*)
    (*canvas ->*)
    (*(int, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t*)
    (*option =*)
    (*fun (canvas, box) ->*)
    (*if Gg.Box2.equal box Gg.Box2.empty then None*)
    (*else begin*)
        (*Gg.Box2.pp (Format.std_formatter) box ;*)
        (*Format.pp_print_flush (Format.std_formatter) () ;*)
        (*print_newline () ;*)
        (*let dimensions = Gg.Box2.size box in*)
        (*let maxdim = max (Gg.P2.x dimensions) (Gg.P2.y dimensions) in*)
        (*if maxdim = 0. then None else begin*)
            (*let (view,size,image) = Utils.get_infos d_from_origin box canvas in*)
            (*let res = 50. /. 25.4 in*)
            (*let w = int_of_float (res *. Size2.w size) in*)
            (*let h = int_of_float (res *. Size2.h size) in*)
            (*let stride = Cairo.Image.(stride_for_width ARGB32 w) in*)
            (*let data =*)
                (*Bigarray.(Array1.create int8_unsigned c_layout (stride * h)) in*)
            (*let surface = Cairo.Image.(create_for_data8 data ARGB32 ~stride w h) in*)
            (*let ctx = Cairo.create surface in*)
            (*Cairo.scale ctx ~x:res ~y:res ;*)
            (*let target = Vgr_cairo.target ctx in*)
            (*let warn w = Vgr.pp_warning Format.err_formatter w in*)
            (*let r = Vgr.create ~warn target `Other in*)
            (*ignore (Vgr.render r (`Image (size, view, image)));*)
            (*ignore (Vgr.render r `End) ;*)
            (*Cairo.Surface.flush surface ;*)
            (*Cairo.Surface.finish surface ;*)
            (*Some data*)
        (*end*)
    (*end*)

let output_canvas_png : ?smart:bool -> ?sizes:((Gg.Box2.t*Gg.Size2.t) option)
                        -> canvas -> string -> unit =
    fun ?smart:(smart=true) ?sizes:(sizes=None) (canvas, box) fname ->
        (*Gg.Box2.pp (Format.std_formatter) box ;*)
    (*Format.pp_print_flush (Format.std_formatter) () ;*)
    (*print_newline () ;*)
    let res = 2000. (* 100dpi in dots per meters *) in
    let fmt = `Png (Size2.v res res) in
    let warn w = Vgr.pp_warning Format.err_formatter w in
    let oc = open_out fname in
    let r = Vgr.create ~warn (Vgr_cairo.stored_target fmt) (`Channel oc) in
    try begin
        let (view,size,image) = Utils.get_infos ~smart d_from_origin box canvas in
        let view,size = match sizes with
         | None -> view,size
         | Some (v,s) -> v,s in
        (*Gg.Box2.pp (Format.std_formatter) view ;*)
        (*Format.pp_print_flush (Format.std_formatter) () ;*)
        (*print_newline () ;*)
        ignore (Vgr.render r (`Image (size, view, image)));
        ignore (Vgr.render r `End) ;
        close_out oc
    end
    with Invalid_argument(_) -> begin
        let canvas = P.line (Gg.P2.v d_from_origin d_from_origin) P.empty in
        let box = Gg.Box2.v (Gg.P2.v d_from_origin d_from_origin) (Gg.Size2.v
        2. 2.) in
        let (view,size,image) = Utils.get_infos d_from_origin box canvas in
        ignore (Vgr.render r (`Image (size, view, image)));
        ignore (Vgr.render r `End) ;
        close_out oc
    end
