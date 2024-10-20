module movement::simple_map_module {
    use std::simple_map::{SimpleMap, Self};
    use std::debug::print;
    use std::signer;

    fun map_in_move(sign: &signer): SimpleMap<address, u64> {
        let mp: SimpleMap<address, u64> = simple_map::create();

        simple_map::add(&mut mp, signer::address_of(sign), 10);
        return mp
    }

    #[test(account = @0x1)]
    fun test_map_in_move(account: &signer) {
        let map = map_in_move(account);
        print(&map);
    }
}
