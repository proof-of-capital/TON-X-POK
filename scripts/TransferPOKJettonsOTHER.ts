import { Address, toNano, beginCell } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';

export async function run(provider: NetworkProvider) {
    const jettonWalletAddress = Address.parseRaw('0:12f6f72bcc0b2ac9335890c2a786dd875236a71c2492cf370d8a2485aa22ec62');
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    const sender = Address.parse("UQCQnrM1x6lwLxsIp6-xlrQVespGVlr2cxeoAiofIe9WyUpv");

    const comment = 'Transfer main jetton from participant';
    
    const body = beginCell().storeUint(0xf8a7ea5, 32).storeInt(1735144534, 64).storeCoins(toNano('9000')).storeAddress(contractAddress).storeAddress(sender).storeBit(0).storeCoins(toNano('0.2')).storeBit(1).storeRef(beginCell().storeUint(0x00000000, 32).storeStringTail(comment).endCell()).endCell();


    await provider.sender().send({
        to: jettonWalletAddress,
        value: toNano('0.25'),
        bounce: true,
        body: body,
    });

    console.log('Jettons sent to address successfully.');
}