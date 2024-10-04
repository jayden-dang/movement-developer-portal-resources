module movement::address_and_signer {
    use std::signer;
    use std::debug::print;

    // All structures that are saved to global storage must include the key attribute
    struct ResourceName has key {
        data: u64,
    }

    public entry fun create_resource(owner: &signer, new_data: u64) {
        move_to(owner, ResourceName{
            data: new_data
        });
        print(owner); // signer
        print(&signer::address_of(owner)); // address of signer
    }

    #[test(account = @0x1)]
    fun test_create_resource(account: &signer) {
        create_resource(account, 10);
    }
}
