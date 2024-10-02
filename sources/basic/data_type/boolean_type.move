module movement::boolean_type {
    use std::debug::print;

    fun bool_types() {
        let a: bool = true;
        let b: bool = false;
        print(&a);  // Outputs: true
        print(&b);  // Outputs: false
    }

    #[test]
    fun test_bool_types() {
        bool_types();  // Calls the bool_types function to test its output
    }
}
