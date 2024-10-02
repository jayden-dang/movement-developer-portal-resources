module movement::hello_world {
    use std::string::{String, utf8};
    use std::debug::print;

    struct MoveResource has key {
        string: String
    }

    fun init_module(caller: &signer) {
        let greeting: String = utf8(b"Hello World!!!");
        print(&greeting);
        move_to(caller, MoveResource {
            string: greeting
        });
    }

    #[test(caller = @0x1)]
    fun test_init_module(caller: &signer) {
        init_module(caller);
    }
}
