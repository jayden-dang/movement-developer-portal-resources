module movement::generic_type {
    use std::string::{String, utf8};
    use std::debug::print;
    use std::signer;

    struct MoveToken has drop {
        symbol: String,
        name: String,
        decimal: u8,
        total_supply: u128
    }

    //a generic identity function that takes a value of any type and returns that value unchanged
    fun show_token<T: drop>(token: T) {
        print(&token);
    }

    #[test]
    fun test_show_all() {
        let token = MoveToken {
            symbol: utf8(b"MOVE"),
            name: utf8(b"Movement"),
            decimal: 8,
            total_supply: 1_000_000_000
        };

        let movetoken = MoveToken {
            symbol: utf8(b"MOVEMENT"),
            name: utf8(b"Movement Tokens"),
            decimal: 8,
            total_supply: 1_000_000_000
        };

        show_token(token);
        show_token(movetoken);
    }
}
