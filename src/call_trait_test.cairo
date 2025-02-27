use core::array::{Array, ArrayTrait};
use core::hash::{LegacyHash};
use core::serde::{Serde};
use governance::call_trait::{CallTrait, HashCall};
use governance::governance_token_test::{deploy as deploy_token};
use starknet::{contract_address_const, account::{Call}};

#[test]
#[available_gas(300000000)]
fn test_hash_empty() {
    let call = Call { to: contract_address_const::<0>(), selector: 0, calldata: ArrayTrait::new() };
    assert(
        LegacyHash::hash(
            0, @call
        ) == 0x6bf1b215edde951b1b50c19e77f7b362d23c6cb4232ae8b95bc112ff94d3956,
        'hash'
    );
}

#[test]
#[available_gas(300000000)]
fn test_hash_address_one() {
    let call = Call { to: contract_address_const::<1>(), selector: 0, calldata: ArrayTrait::new() };
    assert(
        LegacyHash::hash(
            0, @call
        ) == 0x5f6208726bc717f95f23a8e3632dd5a30f4b61d11db5ea4f4fab24bf931a053,
        'hash'
    );
}

#[test]
#[available_gas(300000000)]
fn test_hash_address_entry_point_one() {
    let call = Call { to: contract_address_const::<0>(), selector: 1, calldata: ArrayTrait::new() };
    assert(
        LegacyHash::hash(
            0, @call
        ) == 0x137c95c76862129847d0f5e3618c7a4c3822ee344f4aa80bcb897cb97d3e16,
        'hash'
    );
}

#[test]
#[available_gas(300000000)]
fn test_hash_address_data_one() {
    let mut calldata: Array<felt252> = ArrayTrait::new();
    calldata.append(1);
    let call = Call { to: contract_address_const::<0>(), selector: 0, calldata: calldata };

    assert(
        LegacyHash::hash(
            0, @call
        ) == 0x200a54d7737c13f1013835f88c566515921c2b9c7c7a50cc44ff6f176cf06b2,
        'hash'
    );
}

#[test]
#[available_gas(300000000)]
fn test_hash_address_data_one_two() {
    let mut calldata: Array<felt252> = ArrayTrait::new();
    calldata.append(1);
    calldata.append(2);
    let call = Call { to: contract_address_const::<0>(), selector: 0, calldata: calldata };

    assert(
        LegacyHash::hash(
            0, @call
        ) == 0x6f615c05fa309e4041f96f83d47a23acec3d725b47f8c1005f388aa3d26c187,
        'hash'
    );
}

#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('CONTRACT_NOT_DEPLOYED',))]
fn test_execute_contract_not_deployed() {
    let mut calldata: Array<felt252> = ArrayTrait::new();
    let call = Call { to: contract_address_const::<0>(), selector: 0, calldata: calldata };
    call.execute();
}


#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('ENTRYPOINT_NOT_FOUND',))]
fn test_execute_invalid_entry_point() {
    let (token, _) = deploy_token('TIMELOCK', 'TL', 1);

    let mut calldata: Array<felt252> = ArrayTrait::new();
    let call = Call { to: token.contract_address, selector: 0, calldata: calldata };

    call.execute();
}


#[test]
#[available_gas(300000000)]
#[should_panic(expected: ('Failed to deserialize param #1', 'ENTRYPOINT_FAILED'))]
fn test_execute_invalid_call_data_too_short() {
    let (token, _) = deploy_token('TIMELOCK', 'TL', 1);

    let mut calldata: Array<felt252> = ArrayTrait::new();
    let call = Call {
        to: token.contract_address,
        // transfer
        selector: 0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e,
        calldata: calldata
    };

    call.execute();
}


#[test]
#[available_gas(300000000)]
fn test_execute_valid_call_data() {
    let (token, _) = deploy_token('TIMELOCK', 'TL', 1);

    let mut calldata: Array<felt252> = ArrayTrait::new();
    Serde::serialize(@(contract_address_const::<1>(), 1_u256), ref calldata);

    let call = Call {
        to: token.contract_address,
        // transfer
        selector: 0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e,
        calldata: calldata
    };

    call.execute();
}

