import { Address, toNano, beginCell } from '@ton/core';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';
import { LotteryContract } from '../wrappers/LotteryContract';

export async function run(provider: NetworkProvider) {
    const jettonWalletAddress = Address.parseRaw('0:6560aed94940770f8d354084d1bc12f3d26441f235ae7805491cd277be4929d1');
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    const sender = Address.parse("UQC6B4nBvn6JASXR-QZSW4XUJ8DYNtfp2ht8TeffMbZi3swU");

    const comment = 'Transfer main jetton from participant';
    
    const body = beginCell().storeUint(0xf8a7ea5, 32).storeInt(1735144534, 64).storeCoins(toNano('200000')).storeAddress(contractAddress).storeAddress(sender).storeBit(0).storeCoins(toNano('0.1')).storeBit(1).storeRef(beginCell().storeUint(0x00000000, 32).storeStringTail(comment).endCell()).endCell();


    await provider.sender().send({
        to: jettonWalletAddress,
        value: toNano('0.14'),
        bounce: true,
        body: body,
    });

    console.log('Jettons sent to address successfully.');
}