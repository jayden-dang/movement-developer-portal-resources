module movement::integer_module {
    use std::debug::print;

    fun plus_two_types(x: u8, y: u64): u64 {
        (x as u64) + y
    }

    fun integer_type() {
        let a: u8 = 0;
        let b: u16 = 0;
        let c: u32 = 0;
        let d: u64 = 0;
        let e: u128 = 0;
        let f: u256 = 0;
        print(&a);
        print(&b);
        print(&c);
        print(&d);
        print(&e);
        print(&f);
    }

    #[test]
    fun test_plus_two_types() {
        let result = plus_two_types(5, 100);
        print(&result);
    }

    #[test]
    fun test_show_interger() {
        integer_type();
    }
}
