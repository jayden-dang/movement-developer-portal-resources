module movement::resource_group {
    use std::string::{utf8, String};
    use std::signer::address_of;

    #[resource_group(scope = global)]
    struct MovementGroup {}

    #[resource_group_member(group = MovementGroup)]
    struct Group1 has key {
        field1: u64,
        field2: String,
        field3: address,
        field4: bool
    }

    #[resource_group_member(group = MovementGroup)]
    struct Group2 has key {
        field5: u64,
        field6: String,
        field7: address,
        field8: bool
    }

    public entry fun create_group_resource(account: &signer) {
        let addr = address_of(account);
        let group1 = Group1 {
            field1: 100,
            field2: utf8(b"hello"),
            field3: addr,
            field4: true
        };
        move_to(account, group1);

        let group2 = Group2 {
            field5: 200,
            field6: utf8(b"hello 2"),
            field7: addr,
            field8: false
        };
        move_to(account, group2);
    }

    #[view]
    public fun get_gresource_one(addr: address): u64 acquires Group1 {
        borrow_global<Group1>(addr).field1
    }

    #[view]
    public fun get_gresource_two(addr: address): u64 acquires Group2 {
        borrow_global<Group2>(addr).field5
    }

    #[test(account = @0x1)]
    fun test_create_group(account: &signer){
        create_group_resource(account);
    }
}
