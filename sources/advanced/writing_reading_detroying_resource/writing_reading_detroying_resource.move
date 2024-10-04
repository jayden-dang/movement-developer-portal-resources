module movement::write_read_detroy_resource {
    use std::debug::print;
    use std::signer::address_of;

    struct GlobalData has key, drop {
        value: u64
    }

    const EResourceNotExist: u64 = 33;
    const ENotEqual: u64 = 10;

    public entry fun new_global(signer: &signer, value: u64) {
        let data = GlobalData {
            value: value
        } ;
        move_to(signer, data);
    }

    public entry fun change_value_from_global_storage(signer: &signer, value: u64) acquires GlobalData {
        let addr = address_of(signer);
        if (!check_global_storage_exists(addr)) {
            abort EResourceNotExist
        };

        let value_reference = &mut borrow_global_mut<GlobalData>(addr).value;
        *value_reference = *value_reference + value;
    }

    public fun check_global_storage_exists(addr: address): bool {
        exists<GlobalData>(addr)
    }

    #[view]
    public fun get_value_from_global_storage(addr: address): u64 acquires GlobalData {
        if (!check_global_storage_exists(addr)) {
            abort EResourceNotExist
        };
        let value_reference = borrow_global<GlobalData>(addr);
        print(&value_reference.value);
        value_reference.value
    }

    public entry fun remove_resource_from_global_storage(account: &signer) acquires GlobalData {
        let rev = move_from<GlobalData>(address_of(account));
    }

    #[test(account = @0x1)]
    fun test_new_global(account: &signer) {
        new_global(account, 10);
    }

    #[test(account = @0x1)]
    fun test_change_value_global(account: &signer) acquires GlobalData {
        new_global(account, 10);
        change_value_from_global_storage(account, 10); // value should be equal 20
        let value = get_value_from_global_storage(address_of(account));
        assert!(value == 20, ENotEqual);
        // remove resource
        remove_resource_from_global_storage(account);
        assert!(!check_global_storage_exists(address_of(account)), EResourceNotExist);
    }
}
