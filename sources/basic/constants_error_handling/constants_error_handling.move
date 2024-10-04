module movement::constants_abort_error {
    use movement::errors;

    fun const_error(n: u64) {
        if (n == 5) {
            abort errors::get_enot_have_permission() // throwing error as the given constant
        }
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    fun test_const_error() {
        const_error(5);
    }
}

module movement::constants_assert_error {
    use movement::errors;

    fun is_even(num: u64) {
        assert!(num % 2 == 0, errors::get_enot_even()); // throwing error as the given constant
    }

    #[test]
    #[expected_failure(abort_code = 2)]
    fun test_is_even_failed() {
        is_even(5);
    }

    #[test]
    fun test_is_even_success() {
        is_even(4);
    }
}
