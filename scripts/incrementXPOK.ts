import { Address, toNano } from '@ton/core';
import { XPOK } from '../build/XPOK/XPOK_XPOK';
import { NetworkProvider, sleep } from '@ton/blueprint';

export async function run(provider: NetworkProvider, args: string[]) {
    const ui = provider.ui();

    const address = Address.parse(args.length > 0 ? args[0] : await ui.input('XPOK address'));

    if (!(await provider.isContractDeployed(address))) {
        ui.write(`Error: Contract at address ${address} is not deployed!`);
        return;
    }

    const xPOK = provider.open(XPOK.fromAddress(address));

    const counterBefore = await xPOK.getCounter();

    await xPOK.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Add',
            amount: 1n,
        }
    );

    ui.write('Waiting for counter to increase...');

    let counterAfter = await xPOK.getCounter();
    let attempt = 1;
    while (counterAfter === counterBefore) {
        ui.setActionPrompt(`Attempt ${attempt}`);
        await sleep(2000);
        counterAfter = await xPOK.getCounter();
        attempt++;
    }

    ui.clearActionPrompt();
    ui.write('Counter increased successfully!');
}
