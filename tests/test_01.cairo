use basecamp_04::ERC20::ERC20;
use integer::u256;
use integer::u256_from_felt252;
use starknet::contract_address_const;
use starknet::ContractAddress;
use starknet::testing::set_caller_address;

const NAME: felt252 = 'Starknet Token';
const SYMBOL: felt252 = 'STAR';

fn setup() -> (ContractAddress, u256) {
    let initial_supply: u256 = u256_from_felt252(2000);
    let account: ContractAddress = contract_address_const::<1>();
    let decimals: u8 = 18_u8;

    set_caller_address(account);

    ERC20::constructor(NAME, SYMBOL, decimals, initial_supply, account);
    (account, initial_supply)
}

#[test]
#[available_gas(2000000)]
fn test_transfer() {
    let (sender, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<2>();
    let amount: u256 = u256_from_felt252(100);
    ERC20::transfer(recipient, amount);

    assert(ERC20::balance_of(recipient) == amount, 'Balance should equal amount');
    assert(ERC20::balance_of(sender) == supply - amount, 'Should eq supply - amount');
    assert(ERC20::get_total_supply() == supply, 'Total supply should not change');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('ERC20: transfer to 0', ))]
fn test_transfer_to_zero() {
    let (sender, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<0>();
    let amount: u256 = u256_from_felt252(100);
    ERC20::transfer(recipient, amount);
}

#[test]
#[available_gas(2000000)]
fn test_transfer_from() {
    let (sender, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<2>();

    let amount: u256 = u256_from_felt252(101);
    ERC20::approve(sender, amount);
    ERC20::transfer_from(sender, recipient, amount);

    assert(ERC20::balance_of(recipient) == amount, 'Balance should equal amount');
    assert(ERC20::balance_of(sender) == supply - amount, 'Should eq supply - amount');
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected: ('u256_sub Overflow', ))]
fn test_transfer_allowance_too_low() {
    let (sender, supply) = setup();

    let recipient: ContractAddress = contract_address_const::<2>();

    let amount: u256 = u256_from_felt252(101);
    let approved_amount_toolow: u256 = u256_from_felt252(100);
    ERC20::approve(sender, approved_amount_toolow);
    ERC20::transfer_from(sender, recipient, amount);
}
