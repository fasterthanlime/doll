
use dye
import dye/[core, math, input]

use sdl, glew, glu // workaround

import doll/Engine

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

            e listen("update", |m|
                input _poll()

                if (input isPressed(Keys ESC)) {
                    e emit("key-pressed", |m|
                        m set("keycode", 27)
                    )
                }

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

