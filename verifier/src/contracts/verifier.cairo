#[contract]
mod VerifierContract {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use traits::TryInto;
    use option::OptionTrait;
    use ecdsa::check_ecdsa_signature;

    struct Storage {
        blacklisted_point: LegacyMap::<felt252, bool>,
        _starknetid_contract: ContractAddress,
        _public_key: felt252,
    }

    #[abi]
    trait IStarknetID {
        fn owner_of(token_id: felt252) -> ContractAddress;

        fn set_verifier_data(token_id: felt252, field: felt252, data: felt252);
    }

    #[constructor]
    fn constructor(starknetid_contract: ContractAddress, public_key: felt252) {
        _starknetid_contract::write(starknetid_contract);
        _public_key::write(public_key);
    }

    #[external]
    fn write_confirmation(token_id: felt252, timestamp: felt252, field: felt252, data: felt252, sig: (felt252, felt252)) {
        let caller = get_caller_address();
        let starknetid_contract = _starknetid_contract::read();
        let owner =  IStarknetIDDispatcher {contract_address: starknetid_contract}.owner_of(token_id);
        assert(caller == owner, 'Caller is not owner');

        // ensure confirmation is not expired
        let current_timestamp = get_block_timestamp();
        assert(current_timestamp <= timestamp.try_into().expect('error converting felt to u64'), 'Confirmation is expired');

        let (sig_0, sig_1) = sig;
        let is_blacklisted = blacklisted_point::read(sig_0);
        assert(!is_blacklisted, 'Signature is blacklisted');

        // blacklisting r should be enough since it depends on the "secure random point" it should never be used again
        // to anyone willing to improve this check in the future, please be careful with s, as (r, -s) is also a valid signature
        blacklisted_point::write(sig_0, true);

        let message_hash: felt252 = hash::LegacyHash::hash(hash::LegacyHash::hash(hash::LegacyHash::hash(token_id, timestamp), field), data);
        let public_key = _public_key::read();
        let is_valid = check_ecdsa_signature(message_hash, public_key, sig_0, sig_1);
        assert(is_valid, 'Invalid signature');

        IStarknetIDDispatcher {contract_address: starknetid_contract}.set_verifier_data(token_id, field, data);
    }
}
