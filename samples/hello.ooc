
use doll

import doll/[Engine, Dye]

use sdl, cairo, glew, glu // workaround

main: func {

    engine := Engine new()
    engine initDye()

    engine def("level", |e|
        "level being created" println()
        engine add(engine make("dye-window"))
        engine add(engine make("triangle"))

        e listen("update", |m|
            "level being updated" println()
        )
    )

    engine def("triangle", |e|
        "Triangle created!" println()
    )

    engine listen("start", |m|
        engine add(engine make("level"))
    )

    engine start()

}

