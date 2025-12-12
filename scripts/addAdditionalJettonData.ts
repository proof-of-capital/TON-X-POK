import { Address, toNano } from '@ton/core';
import { XPOK } from '../build/XPOK/XPOK_XPOK';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';


export async function run(provider: NetworkProvider) {
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    
    const superContract = provider.open(
        XPOK.fromAddress(contractAddress)
    );
    
    await superContract.send(
        provider.sender(),
        {
            value: toNano('0.05'), 
        },
        {
            $$type: 'AddAdditionalJettonData',
            newAdditionalJettonMasterAddress: Address.parse("EQBLwbwirHVTj8L2CuypFWD5R63G4DKYz2pth5vK3zQOkVGB"),
            newAdditionalJettonWalletAddress: Address.parseRaw("0:7e66596bcf4674db71208320670ec3187e59c2c27aad9d2d95af8321bf29f91b"),
            amount: toNano(10000n)
        }
    );
}