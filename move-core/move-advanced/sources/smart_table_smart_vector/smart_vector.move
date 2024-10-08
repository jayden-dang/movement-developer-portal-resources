module movement::smart_vector_module {
    use aptos_std::smart_vector::{Self, SmartVector};
    use std::debug::print;
    use std::signer::address_of;

    struct MovementObject has key {
        value: SmartVector<u64>
    }

    fun init_module(caller: &signer) {
        let smartvec = smart_vector::new<u64>();
        let i = 0;
        while (i <= 1000) {
            smart_vector::push_back(&mut smartvec, i);
            i = i + 1;
        };
        move_to(caller, MovementObject {
            value: smartvec
        });
    }

    #[test_only]
    fun test_init_module(caller: &signer) {
        init_module(caller);
    }


    #[view]
    public fun get_length(addr: address): u64 acquires MovementObject {
        let vec = &borrow_global<MovementObject>(addr).value;
        smart_vector::length(vec)
    }

    #[view]
    public fun get_value_from_index(addr: address, index: u64): u64 acquires MovementObject {
        let vec = &borrow_global<MovementObject>(addr).value;
        *smart_vector::borrow(vec, index)
    }

    #[test(caller = @0x1)]
    fun test_get_length(caller: &signer) acquires MovementObject {
        test_init_module(caller);
        let len = get_length(address_of(caller));
        print(&len);
    }

    #[test(caller = @0x1)]
    fun test_value_from_index(caller: &signer) acquires MovementObject {
        test_init_module(caller);
        let val = get_value_from_index(address_of(caller), 10);
        print(&val);
    }
}
