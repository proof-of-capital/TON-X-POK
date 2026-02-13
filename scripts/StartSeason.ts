import { Address, toNano } from '@ton/core';
import { XPOK } from '../build/XPOK/XPOK_XPOK';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';

export async function run(provider: NetworkProvider) {
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    let START_DATE = Math.floor(Date.now() / 1000) + 60; // Start date set to 1 minute from now
    
    const superContract = provider.open(
        XPOK.fromAddress(contractAddress)
    );
    
    await superContract.send(
        provider.sender(),
        {
            value: toNano('0.1'), 
        },
        {
            $$type: 'InitializeSeason',
            pokAmount: 0n,
            startDate: BigInt(START_DATE)
        }
    );
}