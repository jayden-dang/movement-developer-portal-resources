module movement::errors {
    const ENotHavePermission: u64 = 1;
    const ENotEven: u64 = 2;

    public fun get_enot_have_permission(): u64 {
        ENotHavePermission
    }

    public fun get_enot_even(): u64 {
        ENotEven
    }
}
