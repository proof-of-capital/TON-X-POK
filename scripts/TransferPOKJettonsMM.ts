import { Address, toNano, beginCell } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';

export async function run(provider: NetworkProvider) {
    const jettonWalletAddress = Address.parseRaw('0:9eb8abe2750e07bf4644ed33e7ecaeb510e8a42487c55beb27ee724ae26c0fdf');
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    const sender = Address.parse("UQBWOZUkRmnEf19c7KKwgY4q7FVjqTtOA19_1-97IiuU1Y_4");

    const comment = 'Transfer main jetton from MM';
    
    const body = beginCell().storeUint(0xf8a7ea5, 32).storeInt(1735144534, 64).storeCoins(toNano('67939.23')).storeAddress(contractAddress).storeAddress(sender).storeBit(0).storeCoins(toNano('0.1')).storeBit(1).storeRef(beginCell().storeUint(0x00000000, 32).storeStringTail(comment).endCell()).endCell();


    await provider.sender().send({
        to: jettonWalletAddress,
        value: toNano('0.7'),
        bounce: true,
        body: body,
    });

    console.log('Jettons sent to address successfully.');
}