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
    params.append(1576987121283045618657875225183003300580199140020787494777499595331436496159);
    let contract_address = deploy_contract('verifier', @params).unwrap();

    start_prank(123, contract_address).unwrap();

    // todo mock calls
    // stop_mock1 = mock_call(0, "owner_of", [123])
    // stop_mock2 = mock_call(0, "set_verifier_data", [])

    // Should write confirmation
    let mut invoke_calldata = ArrayTrait::new();
    invoke_calldata.append(1);
    invoke_calldata.append(1717096180);
    invoke_calldata.append(32782392107492722);
    invoke_calldata.append(707979046952239197);
    invoke_calldata.append(
        242178274510413660320776612725275530442992398463760124282759555533509261346,
    );
    invoke_calldata.append(
        3369339735225989044856582139053547932849348534803432731455132141425388526099,
    );
    let invoke_result = invoke(contract_address, 'write_confirmation', @invoke_calldata);
    assert(!invoke_result.is_err(), 'write_confirmation failed');

    stop_prank(123).unwrap();
}

