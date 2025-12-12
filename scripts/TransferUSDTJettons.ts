import { Address, toNano, beginCell } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';

export async function run(provider: NetworkProvider) {
    const jettonWalletAddress = Address.parseRaw('0:45d6041b09ef5b4ed8304475876a9266ae64a1a2ef71a85675d4d2cca21a8034');
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    const marketMaker = Address.parse("UQC6B4nBvn6JASXR-QZSW4XUJ8DYNtfp2ht8TeffMbZi3swU");

    const comment = 'Transfer main jetton from ?';
    
    const body = beginCell().storeUint(0xf8a7ea5, 32).storeInt(1735144534, 64).storeCoins(1 * 10 ** 6).storeAddress(contractAddress).storeAddress(marketMaker).storeBit(0).storeCoins(toNano('0.1')).storeBit(1).storeRef(beginCell().storeUint(0x00000000, 32).storeStringTail(comment).endCell()).endCell();


    await provider.sender().send({
        to: jettonWalletAddress,
        value: toNano('0.13'),
        bounce: true,
        body: body,
    });


    console.log('Jettons sent to address successfully.');
}