
use doll

import doll/[Engine, Dye]

use sdl, glew, glu // workaround

main: func (argc: Int, argv: CString*) {

    engine := Engine new()
    engine initDye()

    engine def("level", |e|
        "level being created" println()

        dw := engine make("dye-window", |dw|
            dw set("width", 1024)
            dw set("height", 768)
            dw set("title", "Hello example")
        )

        dw listen("key-pressed", |m|
            "Key pressed!" println()

            match (m get("keycode", Int)) {
                case 27 =>
                    "Keycode 27, should exit" println()
                    e emit("exit")
            }
        )

        engine add(engine make("triangle"))

        e listen("update", |m|
            "level being updated" println()
            dw update()
        )

        e listen("exit", |m|
            "Destroying dw, quitting from engine" println()
            dw emit("destroy")
            e destroy()
            engine emit("quit")
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

