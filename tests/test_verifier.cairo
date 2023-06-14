use array::ArrayTrait;
use result::ResultTrait;
use traits::Into;
use option::OptionTrait;

use starknet::ContractAddress;
use starknet::contract_address_const;
use integer::u128_to_felt252;

use cheatcodes::RevertedTransactionTrait;
use protostar_print::PrintTrait;

#[test]
#[available_gas(2000000)]
fn test_write_confirmation() {
    // Deploy verifier contract
    let mut params = ArrayTrait::new();
    params.append(0);
    params.append(3571077580641057962019375980836964323430604474979724507958294224671833227961);
    let contract_address = deploy_contract('verifier', @params).unwrap();

    start_prank(123, contract_address).unwrap();

    // todo mock calls when available in protostar
    // stop_mock1 = mock_call(0, "owner_of", [123])
    // stop_mock2 = mock_call(0, "set_verifier_data", [])

    // Should write confirmation
    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(1);
    invoke_calldata.append(1717096180);
    invoke_calldata.append(32782392107492722);
    invoke_calldata.append(707979046952239197);
    invoke_calldata
        .append(184358908201723306707880158438552933229114673950387468604540982997131954128, );
    invoke_calldata
        .append(3070140681966331096721750868805285693735076872634770951837263262906056945319, );

    let invoke_result = invoke(contract_address, 'write_confirmation', @invoke_calldata);
    assert(!invoke_result.is_err(), 'write_confirmation failed');

    stop_prank(123).unwrap();
}

