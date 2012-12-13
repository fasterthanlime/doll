
use dye
import dye

use sdl, cairo, glew, glu // workaround

import doll/Engine

extend Engine {

    initDye: func {
        def("dye-window", |e|
            e listen("create", |m|
                "Should create a dye window" println()
                dye := Dye new(640, 480, "Dye example")
                e set("dye", dye)
            )

            e listen("update", |m|
                dye := e get("dye", Dye)
                dye render()
            )

            e listen("destroy", |m|
                dye := e get("dye", Dye)
                dye quit()
            )
        )
    }

}
