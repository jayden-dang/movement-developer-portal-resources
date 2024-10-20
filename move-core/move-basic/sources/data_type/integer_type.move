module movement::integer_module {
    use std::debug::print;

    fun plus_two_integer(x: u64, y: u64): u64 {
        x + y
    }

    fun plus_two_types(x: u8, y: u64): u64 {
        (x as u64) + y
    }

    fun integer_type() {
        let _a: u8 = 0;
        let _b: u16 = 1;
        let _c: u32 = 2;
        let _d: u64 = 3;
        let _e: u128 = 4;
        let _f: u256 = 5;
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

    #[test]
    fun test_plus_two_integer() {
        let result = plus_two_integer(5, 100);
        print(&result);
    }
}
