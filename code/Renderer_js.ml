open Gg
open Vg
open Plotter
open Dom_html

type canvas = Plotter.canvas

let d_from_origin = 100.

let paint_on_html_canvas : canvas -> Dom_html.canvasElement Js.t -> unit =
    fun (canvas, box) html_c ->
        (*Gg.Box2.pp (Format.std_formatter) box ;*)
    (*Format.pp_print_flush (Format.std_formatter) () ;*)
    (*print_newline () ;*)
    if Gg.Box2.equal box Gg.Box2.empty then ()
    else begin
        let dimensions = Gg.Box2.size box in
        (*let origin = Gg.Box2.o box in*)
        let maxdim = max (Gg.P2.x dimensions) (Gg.P2.y dimensions) in
        if maxdim = 0. then () else begin
            let (view,size,image) = Utils.get_infos d_from_origin box canvas in
            let r = Vgr.create (Vgr_htmlc.target html_c) `Other in   (* 4 *)
            ignore (Vgr.render r (`Image (size, view, image))); (* 5 *)
            ignore (Vgr.render r `End)
        end
    end
