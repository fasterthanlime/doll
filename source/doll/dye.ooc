
use dye
import dye/[core, math, input]

use sdl, glew, glu // workaround

import doll/core

extend Engine {

    initDye: func {
        def("dye-window", |e|
            width  := e fallback("width", 640)
            height := e fallback("height", 480)
            title  := e fallback("title", "Dye window")

            "Should create a %dx%d dye window" printfln(width, height)
            dye := Dye new(width, height, title)
            e set("dye", dye)

            input := Input new()
            e set("input", input)

            input onEvent(|ev|
                match ev {
                    case kp: KeyPress =>
                        e emit("key-pressed", |m|
                            m set("keycode", kp code)
                        )
                    case kr: KeyRelease =>
                        e emit("key-released", |m|
                            m set("keycode", kr code)
                        )
                    case mp: MousePress =>
                        e emit("mouse-pressed", |m|
                            m set("button", mp)
                        )
                    case mr: MouseRelease =>
                        e emit("mouse-released", |m|
                            m set("button", mr)
                        )
                }
            )

            e listen("update", |m|
                input _poll()
                dye render()
            )

            e listen("destroy", |m|
                "Quitting dye" println()
                dye quit()
                e destroy()
            )
        )
    }

}

