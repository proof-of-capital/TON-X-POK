import { toNano } from '@ton/core';
import { XPOK } from '../build/XPOK/XPOK_XPOK';
import { NetworkProvider } from '@ton/blueprint';
import { Address } from '@ton/core';

//npx blueprint run deployXPOK --testnet --mnemonic
export async function run(provider: NetworkProvider) {
    const owner = provider.sender().address;
    const pokJettonMasterAddress = Address.parse(''); // адрес мастера POK токена
    const marketMakerAddress = Address.parse(''); // адрес маркетмейкера
    const royaltyWalletAddress = Address.parse(''); // адрес роялти кошелька
    const startedDate = 1745899800n;
    const levelIndex = 1n;
    const lastGameIndex = 1n;
    const winningProbability = 3n;
    const maxTickets = 30000n;

    const xpok = provider.open(
        await XPOK.fromInit(
            owner!!,
            pokJettonMasterAddress,
            marketMakerAddress,
            royaltyWalletAddress,
            startedDate,
            levelIndex,
            lastGameIndex,
            winningProbability,
            maxTickets,
        ),
    );

    await xpok.send(
        provider.sender(),
        {
            value: toNano('0.5'),
        },
        null,
    );

    await provider.waitForDeploy(xpok.address);

    console.log('XPOK deployed at:', xpok.address.toString());
    console.log('Owner address:', (await xpok.getOwnerAddress()).toString());
    console.log('Is lottery started:', await xpok.getIsLotteryStarted());
}
