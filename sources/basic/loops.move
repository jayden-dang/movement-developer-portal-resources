module movement::loops {
    use std::vector;

    // Sum of first N natural numbers using while loop
    fun sum_using_while(n: u64): u64 {
        let sum = 0;
        let i = 1;
        while (i <= n) {
            sum = sum + i;
            i = i + 1;
        };
        sum
    }

    // Sum of first N natural numbers using for loop
    fun sum_using_for(n: u64): u64 {
        let sum = 0;
        for (i in 1..(n+1)) {
            sum = sum + i;
        };
        sum
    }

    // Sum of first N natural numbers using infinite loop
    fun sum_using_loop(n: u64): u64 {
        let sum = 0;
        let i = 1;
        loop {
            if (i > n) break;
            sum = sum + i;
            i = i + 1;
        };
        sum
    }

    // Sum of first N natural numbers using vector and fold
    fun sum_using_vector(n: u64): u64 {
        let numbers = vector::empty<u64>();
        let i = 1;
        while (i <= n) {
            vector::push_back(&mut numbers, i);
            i = i + 1;
        };
        vector::fold(numbers, 0, |acc, num| acc + num)
    }

    #[test_only]
    use std::debug;

    #[test]
    fun test_sum_functions() {
        let n = 10;
        let expected_sum = 55; // Sum of 1 to 10

        assert!(sum_using_while(n) == expected_sum, 0);
        assert!(sum_using_for(n) == expected_sum, 1);
        assert!(sum_using_loop(n) == expected_sum, 2);
        assert!(sum_using_vector(n) == expected_sum, 3);

        debug::print(&sum_using_while(n));
        debug::print(&sum_using_for(n));
        debug::print(&sum_using_loop(n));
        debug::print(&sum_using_vector(n));
    }
}
