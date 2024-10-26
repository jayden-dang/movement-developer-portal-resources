module movement::swap_token {
    use aptos_framework::coin;
    use aptos_framework::account;
    use aptos_framework::resource_account;
    use aptos_framework::event;
    use aptos_std::math64;
    use std::string;
    use std::vector;
    use std::signer;

    struct LiquidPoolToken<phantom X, phantom Y> has key {}

    struct TokenPairMetadata<phantom X, phantom Y> has key {
        creator: address,
        fee_amount: coin::Coin<LiquidPoolToken<X, Y>>,
        k_last: u128,
        balance_x: coin::Coin<X>,
        balance_y: coin::Coin<Y>,
        mint_cap: coin::MintCapability<LiquidPoolToken<X, Y>>,
        burn_cap: coin::BurnCapability<LiquidPoolToken<X, Y>>,
        freeze_cap: coin::FreezeCapability<LiquidPoolToken<X, Y>>,
    }

    struct SwapInfo has key {
        signer_cap: account::SignerCapability,
        fee_to: address,
        admin: address,
        pair_created: event::EventHandle<PairCreatedEvent>
    }

    struct PairCreatedEvent has drop, store {
        user: address,
        token_x: string::String,
        token_y: string::String
    }

    /// Stores the reservation info required for the token pairs
    struct TokenPairReserve<phantom X, phantom Y> has key {
        // Represents the amount of token X currently held in the liquidity pool.
        reserve_x: u64,
        // Represents the amount of token Y currently held in the liquidity pool.
        reserve_y: u64,
        // Stores the timestamp of the last block when the reserve data was updated
        block_timestamp_last: u64
    }

    const SOURCE_ADDR: address = @source_addr;

    fun init_module(caller: &signer) {
        let admin_addr: address = signer::address_of(caller);
        let signer_cap = resource_account::retrieve_resource_account_cap(caller, SOURCE_ADDR);
        let resource_signer = account::create_signer_with_capability(&signer_cap);
        move_to(&resource_signer, SwapInfo {
            signer_cap,
            fee_to: admin_addr,
            admin: admin_addr,
            pair_created: account::new_event_handle<PairCreatedEvent>(&resource_signer)
        });
    }

    const EAlreadyInitialized: u64 = 0x00001;
    const RESOURCE_ACCOUNT: address = @movement;

    public entry fun create_pair<X, Y>(
        sender: &signer
    ) acquires SwapInfo {
        assert!(!is_pair_created<X, Y>(), EAlreadyInitialized);

        let sender_addr = signer::address_of(sender);
        let swap_info = borrow_global_mut<SwapInfo>(RESOURCE_ACCOUNT);
        let resource_signer = account::create_signer_with_capability(&swap_info.signer_cap);

        let lp_name: string::String = string::utf8(b"MMSwap-");
        let name_x = coin::symbol<X>();
        let name_y = coin::symbol<Y>();
        string::append(&mut lp_name, name_x);
        string::append_utf8(&mut lp_name, b"-");
        string::append(&mut lp_name, name_y);
        string::append_utf8(&mut lp_name, b"-LP");


        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<LiquidPoolToken<X, Y>>(
            &resource_signer,
            lp_name,
            string::utf8(b"Swap-LP"),
            8,
            true
        );

        move_to<TokenPairReserve<X, Y>>(
            &resource_signer,
            TokenPairReserve {
                reserve_x: 0,
                reserve_y: 0,
                block_timestamp_last: 0
            }
        );

        move_to<TokenPairMetadata<X, Y>>(
            &resource_signer,
            TokenPairMetadata {
                creator: sender_addr,
                fee_amount: coin::zero<LiquidPoolToken<X, Y>>(),
                k_last: 0,
                balance_x: coin::zero<X>(),
                balance_y: coin::zero<Y>(),
                mint_cap,
                burn_cap,
                freeze_cap,
            }
        );

        register_lp<X, Y>(&resource_signer);
    }

    public fun register_lp<X, Y>(sender: &signer) {
        coin::register<LiquidPoolToken<X, Y>>(sender);
    }


    public fun is_pair_created<X, Y>(): bool {
        exists<TokenPairReserve<X, Y>>(RESOURCE_ACCOUNT)
    }

    public fun lp_balance<X, Y>(addr: address): u64 {
        coin::balance<LiquidPoolToken<X, Y>>(addr)
    }

    public fun total_lp_supply<X, Y>(): u128 {
        option::get_with_default(
            &coin::supply<LiquidPoolToken<X, Y>>(),
            0u128
        )
    }

    /// Get the current reserves of T0 and T1 with the latest updated timestamp
    public fun token_reserves<X, Y>(): (u64, u64, u64) acquires TokenPairReserve {
        let reserve = borrow_global<TokenPairReserve<X, Y>>(RESOURCE_ACCOUNT);
        (
            reserve.reserve_x,
            reserve.reserve_y,
            reserve.block_timestamp_last
        )
    }

    /// The amount of balance currently in pools of the liquidity pair
    public fun token_balances<X, Y>(): (u64, u64) acquires TokenPairMetadata {
        let meta =
            borrow_global<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        (
            coin::value(&meta.balance_x),
            coin::value(&meta.balance_y)
        )
    }

    public entry fun add_lp<X, Y>(
        caller: &signer,
        x_amount: u64,
        y_amount: u64
    ) acquires TokenPairMetadata, TokenPairReserve {
        assert!(is_pair_created<Xy, Y>(RESOURCE_ACCOUNT));

        let amount_x = coin::value(&x_amount);
        let amount_y = coin::value(&y_amount);

        let (resreve_x, reserve_y) = token_reserves<X, Y>();
        let (a_x, a_y) = if (resreve_x == 0 && reserve_y == 0) {
            amount_x, amount_y
        } else {
            let amount_y_optimal = quote(amount_x, reserve_x, reserve_y);
            if (amount_y_optimal <= amount_y) {
                (amount_x, amount_y_optimal)
            } else {
                let amount_x_optimal = quote(amount_y, reserve_y, reserve_x);
                (amount_x_optimal, amount_y)
            }
        };

        let left_x = coin::extract(&mut x, amount_x - a_x);
        let left_y = coin::extract(&mut x, amount_y - a_y);

        // -->>> Region:: START  --->>>  Deposit Tokens
        let token_metadata_x = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        coin::merge(&mut token_metadata_x.balance_x, amount);

        let token_metadata_y = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);
        coin::merge(&mut token_metadata_y.balance_y, amount);
        // <<<-- Region:: END    <<<---  Deposit Tokens

        let (lp, fee_amount) =


        let (amount_x, amount_y, coin_lp, fee_amount, coin_left_x, coin_left_y) =

        let pair = borrow_global_mut<TokenPairMetadata<X, Y>>(RESOURCE_ACCOUNT);


    }

    public fun quote(amount_x: u64, reserve_x: u64, reserve_y: u64): u64 {
        (((amount_x as u128) * (reserve_y as u128) / (reserve_x as u128)) as u64)
    }

}
