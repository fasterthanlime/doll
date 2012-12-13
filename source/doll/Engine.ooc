
use zeromq

import structs/[ArrayList, LinkedList, HashMap]
import threading/Thread
import os/Time

/**
 * A simple FIFO queue
 */
Queue: class <T> extends LinkedList<T> {

    init: super func

    push: func (t: T) {
        add(t) 
    }

    pop: func -> T {
        removeAt(0)
    }

}

/**
 * Everything's an entity, including the engine
 */
Entity: class {

    engine: Engine
    name: String
    receivers := ArrayList<Receiver> new()
    queue := Queue<Message> new()
    props := HashMap<String, Property> new()

    dead := false

    init: func (=engine, =name) {
        listen("update", |m|
            drain()
        )
    }

    listen: func (name: String, f: Func (Message)) {
        receivers add(Receiver new(|m|
            if (m name == name) {
                f(m)
            }
        ))
    }

    emit: func ~onlyName (name: String) {
        if (dead) return

        queue push(Message new(name))
    }

    emit: func ~withClosure (name: String, f: Func(Message)) {
        if (dead) return

        m := Message new(name)
        f(m)
        queue push(m)
    }

    drain: func {
        if (dead) return

        while (!queue empty?()) {
            dispatch(queue pop())
        }
    }

    update: func {
        emit("update")
        drain()
    }

    dispatch: func (m: Message) {
        if (dead) return

        for (r in receivers) {
            r receive(m)
        }
    }

    clone: func -> Entity {
        e := Entity new(engine, name)
        e receivers addAll(receivers)

        props each(|k, v|
            e props put(k, v clone())
        )
        e
    }

    set: func <T> (name: String, t: T) {
        p := props get(name)
        if (p) {
            p set(t)
        } else {
            props put(name, Property new(t))
        }
    }

    get: func <T> (name: String, T: Class) -> T {
        props get(name) get()
    }

    destroy: func {
        queue clear()
        dead = true
    }

}

/**
 * Can receive messages
 */
Receiver: class {

    f: Func (Message)

    init: func (=f) {}

    receive: func (message: Message) {
        f(message)
    }

}

/**
 * Primary mean of communication between entities
 */
Message: class {

    name: String
    props := HashMap<String, Property> new()

    init: func (=name) {

    }

    set: func <T> (name: String, t: T) {
        props put(name, Property<T> new(t))
    }

    get: func <T> (name: String, T: Class) -> T {
        props get(name) get()
    }

}


Property: class <T> {

    t: T

    init: func (=t) {

    }

    set: func (=t) {

    }

    get: func -> T {
        t
    }

    clone: func -> This<T> {
        This<T> new(t)
    }

}

Prototype: class {

    name: String
    constructor: Func (Entity)

    init: func (=name, =constructor)

}

/**
 * The mother entity
 */
Engine: class extends Entity {

    prototypes := HashMap<String, Prototype> new()
    entities := ArrayList<Entity> new()

    running := true

    init: func {
        super(this, "engine")

        listen("update", |m|
            println()
            "=============================================" println()
            println()

            updateMessage := Message new("update")
            iter := entities iterator()
            while (iter hasNext?()) {
                e := iter next()
                if (e dead) {
                    iter remove()
                } else {
                    e dispatch(updateMessage)
                }
            }
        )

        listen("quit", |m|
            running = false
        )
    }

    start: func {
        thread := Thread new(||
            emit("start")
            drain()

            while(running) {
                Time sleepMilli(20)
                update()
            }
        )
        thread start()
        thread wait()
    }

    def: func (name: String, f: Func (Entity)) {
        prototypes put(name, Prototype new(name, f))
    }

    make: func (name: String) -> Entity {
        prototype := prototypes get(name)
        if (!prototype) {
            Exception new("Unknown prototype: %s" format(name)) throw()
        }

        entity := Entity new(this, prototype name)
        prototype constructor(entity)
        entity
    }

    clone: func {
        Exception new("Can't clone Engine") throw()
    }

    add: func (e: Entity) {
        entities add(e)
    }

    remove: func (e: Entity) {
        entities remove(e)
    }

}

