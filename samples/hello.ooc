
use doll

import doll/[Engine, Dye]

use sdl, cairo, glew, glu // workaround

main: func {

    engine := Engine new()
    engine initDye()

    engine def("level", |e|
        e listen("create", |m|
            "level being created" println()
            e engine make("dye-window", |dw|
                "Got dye window!" println()
                e engine add(dw)
            )
        )

        e listen("update", |m|
            "level being updated" println()
        )
    )

    engine listen("start", |m|
        engine make("level", |l|
            engine add(l)
        )
    )

    engine start()

}

