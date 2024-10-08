module movement::hello_world {
    use std::string::{String, utf8};
    use std::debug::print;

    struct MoveResource has key {
        string: String
    }

    public entry fun create_first_resource(caller: &signer) {
        let greeting: String = utf8(b"Hello World!!!");
        print(&greeting);
        move_to(caller, MoveResource {
            string: greeting
        });
    }

    #[test(caller = @0x1)]
    fun test_create_first_resource(caller: &signer) {
        create_first_resource(caller);
    }
}
