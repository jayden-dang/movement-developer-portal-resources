module movement::smart_table_module {
    use aptos_std::smart_table::{Self, SmartTable};
    use std::debug::print;
    use std::signer::address_of;

    struct MovementTableObject has key {
        value: SmartTable<address, u64>
    }

    fun init_module(caller: &signer) {
        let val = smart_table::new<address, u64>();
        smart_table::add(&mut val, address_of(caller), 0);
        move_to(caller, MovementTableObject {
            value: val
        });
    }

    #[test_only]
    fun test_init_module(caller: &signer) {
        init_module(caller);
    }

    #[view]
    fun get_amount_point(addr: address): u64 acquires MovementTableObject {
        let table = &borrow_global<MovementTableObject>(addr).value;
        *smart_table::borrow(table, addr)
    }

    fun plus_point(addr: address, value: u64) acquires MovementTableObject {
        let table = &mut borrow_global_mut<MovementTableObject>(addr).value;
        let point = *smart_table::borrow_mut(table, addr);
        point = point + value;
        smart_table::upsert(table, addr, point);
    }

    #[test(caller = @0x1)]
    fun test_get_amount_point(caller: &signer) acquires MovementTableObject {
        test_init_module(caller);
        let amount = get_amount_point(address_of(caller));
        print(&amount);
    }

    #[test(caller = @0x1)]
    fun test_plus_amount_point(caller: &signer) acquires MovementTableObject {
        test_init_module(caller);
        plus_point(address_of(caller), 10);
        let amount = get_amount_point(address_of(caller));
        print(&amount);
    }
}
