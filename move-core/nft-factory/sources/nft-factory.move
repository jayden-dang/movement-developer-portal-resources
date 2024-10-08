module movement::nft_factory {
    use aptos_token_objects::collection;
    use std::string::utf8;
    use std::option;

    fun init_module(creator: &signer, max_supply: u64) {
        let royalty = option::none();
        collection::create_fixed_collection(
            creator,
            utf8(b"My Collection Description"),
            max_supply,
            utf8(b"My Collection"),
            royalty,
            utf8(b"https://mycollection.com"),
        );
    }
}
