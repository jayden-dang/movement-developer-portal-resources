module movement::movement_token {
    use std::string;
    use std::signer;
    use aptos_framework::coin::{Self, BurnCapability, MintCapability, Coin};
    use aptos_framework::account::{Self, SignerCapability, create_resource_account, create_signer_with_capability};
    use aptos_framework::aptos_account;

    /// coin DECIMALS
    const DECIMALS: u8 = 8;
    /// pow(10,8) = 10**8
    const DECIMAL_TOTAL: u64 = 100000000;
    /// 100 million
    const MAX_SUPPLY_AMOUNT: u64 = 100000000;
    /// 15%
    const DEV_TEAM: u64 = 15000000;
    /// 70%
    const COMMUNITY: u64 = 70000000;
    /// 15%
    const FOUNDATION: u64 = 15000000;


    /// Error codes
    const ENotAdmin: u64 = 1;

    /// MOVEMENT Coin
    struct MOVEMENT has key, store, drop{}

    /// store Capability for mint and  burn
    struct CapStore has key {
        mint_cap: MintCapability<MOVEMENT>,
        burn_cap: BurnCapability<MOVEMENT>,
        resource_cap: SignerCapability
    }

    /// bank for community
    struct CommunityBank has key, store { value: Coin<MOVEMENT> }

    /// bank for dev team
    struct DevTeamBank has key, store { value: Coin<MOVEMENT> }

    /// bank for foundation
    struct FoundationBank has key, store { value: Coin<MOVEMENT> }


    /// It must be initialized first
    fun init_module(signer: &signer) {
        assert_admin_signer(signer);
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<MOVEMENT>(signer, string::utf8(b"Movement Coin"), string::utf8(b"MOVEMENT"), DECIMALS, true);
        coin::destroy_freeze_cap(freeze_cap);
        coin::register<MOVEMENT>(signer);

        let (resource, resource_cap) = create_resource_account(signer, b"movement_token");
        let resource_signer_from_cap = create_signer_with_capability(&resource_cap);
        let account_addr = signer::address_of(signer);

        let mint_coins = coin::mint<MOVEMENT>(MAX_SUPPLY_AMOUNT * DECIMAL_TOTAL, &mint_cap);
        move_to(signer, CommunityBank { value: coin::extract(&mut mint_coins, COMMUNITY * DECIMAL_TOTAL) });
        move_to(signer, DevTeamBank { value: coin::extract(&mut mint_coins, DEV_TEAM * DECIMAL_TOTAL) });
        move_to(signer, FoundationBank { value: mint_coins });
        move_to(&resource_signer_from_cap, CapStore { mint_cap, burn_cap, resource_cap });
    }


    /// Burn MOVEMENT
    public fun burn(token: coin::Coin<MOVEMENT>, resource_addr: address) acquires CapStore {
        coin::burn<MOVEMENT>(token, &borrow_global<CapStore>(resource_addr).burn_cap)
    }


    /// withdraw community bank
    public entry fun withdraw_community(_account: &signer, to: address, amount: u64) acquires CommunityBank{
        let bank = borrow_global_mut<CommunityBank>(@movement);
        coin::deposit<MOVEMENT>(to, coin::extract<MOVEMENT>(&mut bank.value, amount));
    }

    /// withdraw dev team bank using aptos_account
    public entry fun withdraw_team(account: &signer, to: address, amount: u64) acquires DevTeamBank {
        assert_admin_signer(account);
        let bank = borrow_global_mut<DevTeamBank>(@movement);
        aptos_account::deposit_coins<MOVEMENT>(to, coin::extract<MOVEMENT>(&mut bank.value, amount));
    }

    /// withdraw foundation bank
    public entry fun withdraw_foundation(account: &signer, to: address, amount: u64) acquires FoundationBank {
        assert_admin_signer(account);
        let bank = borrow_global_mut<FoundationBank>(@movement);
        coin::deposit<MOVEMENT>(to, coin::extract<MOVEMENT>(&mut bank.value, amount));
    }

    /// deposit to bank
    public entry fun deposit_community(account: &signer, amount: u64) acquires CommunityBank {
        coin::merge<MOVEMENT>(&mut borrow_global_mut<CommunityBank>(@movement).value, coin::withdraw<MOVEMENT>(account, amount));
    }

    public entry fun deposit_team(account: &signer, amount: u64) acquires DevTeamBank {
        coin::merge<MOVEMENT>(&mut borrow_global_mut<DevTeamBank>(@movement).value, coin::withdraw<MOVEMENT>(account, amount));
    }

    public entry fun deposit_foundation(account: &signer, amount: u64) acquires FoundationBank {
        coin::merge<MOVEMENT>(&mut borrow_global_mut<FoundationBank>(@movement).value, coin::withdraw<MOVEMENT>(account, amount));
    }

    /// register MOVEMENT to sender
    public entry fun register(account: &signer) { coin::register<MOVEMENT>(account); }

    /// helper must admin
    fun assert_admin_signer(sign: &signer) {
        assert!(signer::address_of(sign) == @movement, ENotAdmin);
    }
}
