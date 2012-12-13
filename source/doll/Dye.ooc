
use dye
import dye

use sdl, cairo, glew, glu // workaround

import doll/Engine

extend Engine {

    initDye: func {
        def("dye-window", |e|
            "Should create a dye window" println()
            dye := Dye new(640, 480, "Dye example")
            e set("dye", dye)

            e listen("update", |m|
                "Updating dye" println()
                dye render()
                e emit("key-pressed", |m|
                    m set("keycode", 27 as Int)
                )
            )

            e listen("destroy", |m|
                "Quitting dye" println()
                dye quit()
                e destroy()
            )
        )
    }

}

