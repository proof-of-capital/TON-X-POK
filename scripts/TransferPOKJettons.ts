import { Address, toNano, beginCell } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';

export async function run(provider: NetworkProvider) {
    const jettonWalletAddress = Address.parseRaw('0:95ed57e700b42fb6284fae20397fd70257ded3bd82c24ff17b70b3a1bad4d716');
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    const sender = Address.parse("UQDqBQr9StrAgQv-zF3nn3LVLoFodxzDDQe4aC44gDV42tav");

    const comment = 'Transfer main jetton from ?';
    
    const body = beginCell().storeUint(0xf8a7ea5, 32).storeInt(1735144534, 64).storeCoins(toNano('300000')).storeAddress(contractAddress).storeAddress(sender).storeBit(0).storeCoins(toNano('0.1')).storeBit(1).storeRef(beginCell().storeUint(0x00000000, 32).storeStringTail(comment).endCell()).endCell();


    await provider.sender().send({
        to: jettonWalletAddress,
        value: toNano('0.14'),
        bounce: true,
        body: body,
    });

    console.log('Jettons sent to address successfully.');
}