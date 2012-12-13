
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
        queue push(Message new(name))
    }

    drain: func {
        while (!queue empty?()) {
            dispatch(queue pop())
        }
    }

    dispatch: func (m: Message) {
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

    add: func <T> (name: String, t: T) {
        props put(name, Property<T> new(t))
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

/**
 * The mother entity
 */
Engine: class extends Entity {

    prototypes := HashMap<String, Entity> new()
    entities := ArrayList<Entity> new()

    init: func {
        super(this, "engine")

        listen("update", |m|
            updateMessage := Message new("update")
            for (e in entities) {
                e dispatch(updateMessage)
            }
        )
    }

    start: func {
        Thread new(||
            emit("start")
            drain()

            while(true) {
                Time sleepMilli(300)
                emit("update")
                drain()
            }
        ) start(). wait()
    }

    def: func (name: String, f: Func (Entity)) {
        entity := Entity new(this, name)
        f(entity)
        prototypes put(name, entity)
    }

    make: func (name: String, f: Func (Entity)) {
        prototype := prototypes get(name)
        if (!prototype) {
            Exception new("Unknown prototype: %s" format(name)) throw()
        }

        entity := prototype clone()
        entity emit("create")
        f(entity)
    }

    clone: func {
        Exception new("Can't clone Engine") throw()
    }

    add: func (e: Entity) {
        entities add(e)
    }

}

