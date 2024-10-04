module movement::movement_module {
    use std::signer;

    struct ResourceName has key {
        data: u64
    }

    public entry fun create_resource(owner: &signer, new_data: u64) {
        move_to(owner, ResourceName{
            data: new_data
        });
    }
}
