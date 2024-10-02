module movement::hello_world {
    struct MoveResource has key {
        value: u64
    }

    fun init_module(caller: &signer) {
        move_to(caller, MoveResource {
            value: 10
        });
    }
}
