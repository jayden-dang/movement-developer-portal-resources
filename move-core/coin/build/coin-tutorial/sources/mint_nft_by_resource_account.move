module movement::mint_nft_by_resource_account {
    use std::string::{Self, String};
    use aptos_token_objects::collection;
    use aptos_token_objects::token::{Self, Token};
    use aptos_framework::object;
    use std::signer;
    use std::option;

    use aptos_framework::account::{Self, SignerCapability, create_resource_account, create_signer_with_capability};

    struct ResourceInfo has key {
        source: address,
        resource_cap: SignerCapability
    }

    struct CollectionConfig has key {
        collection_name: String,
        collection_description: String,
        collection_maximum: u64,
        collection_uri: String,
        token_counter: u64,
        token_base_name: String,
        token_description: String,
    }

    public entry fun create_collection(
        account: &signer,
        collection_name: String,
        collection_description: String,
        collection_uri: String,
        collection_maximum: u64,
        // Token
        token_base_name: String,
        token_description: String,
        seeds: vector<u8>
    ) {
        let (resource, resource_cap) = create_resource_account(account, seeds);
        let resource_signer_from_cap = create_signer_with_capability(&resource_cap);
        let account_addr = signer::address_of(account);

        // Token
        move_to(&resource_signer_from_cap, ResourceInfo {
            source: account_addr,
            resource_cap: resource_cap
        });

        move_to(&resource_signer_from_cap, CollectionConfig {
            collection_name,
            collection_description,
            collection_maximum: collection_maximum,
            collection_uri,
            token_counter: 1,
            // Token
            token_base_name,
            token_description,
        });

        collection::create_fixed_collection(
            &resource_signer_from_cap,
            collection_description,
            collection_maximum,
            collection_name,
            option::none(),
            collection_uri,
        );
    }

    public entry fun mint(nft_claimer: &signer, collection_address: address, token_name: String, token_uri: String) acquires ResourceInfo, CollectionConfig {
        let nft_claimer_addr = signer::address_of(nft_claimer);

        let collection_config = borrow_global_mut<CollectionConfig>(collection_address);
        let resource_info = borrow_global_mut<ResourceInfo>(collection_address);
        let resource_signer_from_cap = account::create_signer_with_capability(&resource_info.resource_cap);

        let constructor_ref = token::create_named_token(
            &resource_signer_from_cap,
            collection_config.collection_name,
            collection_config.collection_description,
            token_name,
            option::none(),
            token_uri
        );

        let token_object = object::object_from_constructor_ref<Token>(&constructor_ref);

        object::transfer(&resource_signer_from_cap, token_object, nft_claimer_addr);
    }
}
