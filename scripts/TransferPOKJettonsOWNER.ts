import { Address, toNano, beginCell } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';
import { LotteryContract } from '../wrappers/LotteryContract';

export async function run(provider: NetworkProvider) {
    const jettonWalletAddress = Address.parseRaw('0:3ec02dd6ac44a3506cb82bd1510e224679094fb84b4adcaebb7cfc12a3bc7721');
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    const sender = Address.parse("UQC6l0ZX3YjD7ux6tdHAkZGVmI1OBszhBBNcCWAaRkdoYC1x");
    const comment = 'Transfer main jetton from owner';
    
    const body = beginCell().storeUint(0xf8a7ea5, 32).storeInt(1735144534, 64).storeCoins(toNano('60000')).storeAddress(contractAddress).storeAddress(sender).storeBit(0).storeCoins(toNano('0.1')).storeBit(1).storeRef(beginCell().storeUint(0x00000000, 32).storeStringTail(comment).endCell()).endCell();


    await provider.sender().send({
        to: jettonWalletAddress,
        value: toNano('0.14'),
        bounce: true,
        body: body,
    });

    console.log('Jettons sent to address successfully.');
}