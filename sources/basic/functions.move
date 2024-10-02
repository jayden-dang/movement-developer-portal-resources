module movement::priv_module {
    use std::debug::print;

    fun pri_func(): u8 {
        return 0
    }

    fun call_public_func() {
        let result = movement::pub_module::public_func();
        print(&result);
    }

    #[test]
    fun test_call_public_func() {
        call_public_func();
    }
}

module movement::pub_module {
    public fun public_func(): u8 {
        return 0
    }
}

module movement::function_visibilities {
    use std::string::utf8;
    use std::debug::print;

    public(friend) entry fun internal_transfer() { // public friend entry
        print(&utf8(b"internal transfer"));
    }

    public entry fun pub_transfer() { // public entry
        print(&utf8(b"public transfer"));
    }

    entry fun transfer(){ // private entry
        print(&utf8(b"transfer"));
    }
}
