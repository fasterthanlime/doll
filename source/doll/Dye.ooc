
use dye
import dye/[core, math, input]

use sdl, glew, glu // workaround

import doll/Engine

extend Engine {

    initDye: func {
        def("dye-window", |e|
            "Should create a dye window" println()
            dye := Dye new(640, 480, "Dye example")
            e set("dye", dye)

            input := Input new()
            e set("input", input)

            e listen("update", |m|
                "Updating dye" println()
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

