module movement::nft_factory {
    use aptos_token_objects::collection;
    use aptos_token_objects::token::{Self, Token};
    use aptos_framework::object::{Self, Object};
    use std::string::{utf8, String};
    use std::option;
    use std::signer;

    const COLLECTION_DESCRIPTION: vector<u8> = b"Movement Non-Fungible Tokens Collection";
    const COLLECTION_NAME: vector<u8> = b"Movement NFT Collection";
    const COLLECTION_URI: vector<u8> = b"https://movementlabs.xyz";
    const MAX_SUPPLY: u64 = 10_000;
    const ENOT_CREATOR: u64 = 0;

    struct MovementPepeMeme has key {
        name: String,
        uri: String,
        description: String,
        mutator_ref: token::MutatorRef
    }

    public entry fun create_collection(creator: &signer) {
        let royalty = option::none();
        collection::create_fixed_collection(
            creator,
            utf8(COLLECTION_DESCRIPTION),
            MAX_SUPPLY,
            utf8(COLLECTION_NAME),
            royalty,
            utf8(COLLECTION_URI),
        );
    }

    public entry fun mint_nft(creator: &signer, token_name: String, uri: String, description: String) {
        let constructor_ref = token::create_named_token(
            creator,
            utf8(COLLECTION_NAME),
            utf8(COLLECTION_DESCRIPTION),
            token_name,
            option::none(),
            utf8(COLLECTION_URI)
        );
        let token_object = object::object_from_constructor_ref<Token>(&constructor_ref);
        let token_signer = object::generate_signer(&constructor_ref);
        let mutator_ref = token::generate_mutator_ref(&constructor_ref);

        move_to(&token_signer, MovementPepeMeme {
            name: token_name,
            uri,
            description,
            mutator_ref
        });

        object::transfer(creator, token_object, signer::address_of(creator));
    }

    public entry fun update_meme_description(creator: &signer, collection: String, name: String, description: String) acquires MovementPepeMeme {
        let (meme_obj, meme) = get_meme(
            &signer::address_of(creator),
            &collection,
            &name,
        );

        let creator_addr = token::creator(meme_obj);
        assert!(creator_addr == signer::address_of(creator), ENOT_CREATOR);
        token::set_description(&meme.mutator_ref, description);
    }

    inline fun get_meme(creator: &address, collection: &String, name: &String): (Object<MovementPepeMeme>, &MovementPepeMeme) {
        let token_address = token::create_token_address(
            creator,
            collection,
            name,
        );
        (object::address_to_object<MovementPepeMeme>(token_address), borrow_global<MovementPepeMeme>(token_address))
    }
}
