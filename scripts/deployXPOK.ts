import { toNano } from '@ton/core';
import { XPOK } from '../build/XPOK/XPOK_XPOK';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const xPOK = provider.open(await XPOK.fromInit(BigInt(Math.floor(Math.random() * 10000)), 0n));

    await xPOK.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        null,
    );

    await provider.waitForDeploy(xPOK.address);

    console.log('ID', await xPOK.getId());
}
