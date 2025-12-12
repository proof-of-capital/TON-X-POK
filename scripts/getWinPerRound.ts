import { Address, toNano } from '@ton/core';
import { XPOK } from '../build/XPOK/XPOK_XPOK';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';

export async function run(provider: NetworkProvider) {
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    
    // Открываем существующий контракт по адресу
    const superContract = provider.open(
        XPOK.fromAddress(contractAddress)
    );
    
    await superContract.send(
        provider.sender(),
        {
            value: toNano('0.05'), 
        },
        {
            $$type: 'GetWinPerRound',
            indexGame: 1n
        }
    );
}