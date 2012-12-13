
use doll

import doll/Engine

main: func {

    engine := Engine new()

    engine def("level", |e|
        e listen("update", |m|
            "level being updated" println()
        )
    )

    engine listen("start", |m|
        "got start from outside engine" println()
        engine make("level", |l|
            "level made" println()
            engine add(l)
        )
    )

    engine start()

}

