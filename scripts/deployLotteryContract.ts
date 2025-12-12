import { Address, toNano } from '@ton/core';
import { XPOK } from '../build/XPOK/XPOK_XPOK';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {

    const owner = Address.parse("UQC6l0ZX3YjD7ux6tdHAkZGVmI1OBszhBBNcCWAaRkdoYC1x");
    const pokJettonMasterAddress = Address.parse("EQBp6FAkDdHD_lLKUBI-J-Et5zQeyJlixc6f3iKHBie85Fd-");
    const usdtJettonMasterAddress = Address.parse("EQCxE6mUtQJKFnGfaROTKOt1lZbDiiX1kCixRv7Nw2Id_sDs");
    const MarketMakerAddress = Address.parse("UQBWOZUkRmnEf19c7KKwgY4q7FVjqTtOA19_1-97IiuU1Y_4");
    const RoyaltyWalletAddress = Address.parse("UQAP3YoWUpwXIZBCMPExVtwVLEazA37etHFkuspUMCMIOTjl");
    const StartedDate = 1745899800n; // нужно передавать значение старта первой лотереи
    const LevelIndex = 2n;
    const LastGameIndex = 5n;
    const WinningProbability = 3n; // 1 к n
    const MaxTickets = 30000n;

    const XPOK = provider.open(await XPOK.fromInit(
        owner,
        usdtJettonMasterAddress,
        pokJettonMasterAddress,
        MarketMakerAddress,
        RoyaltyWalletAddress,
        StartedDate,
        LevelIndex,
        LastGameIndex,
        WinningProbability,
        MaxTickets
    ));

    await XPOK.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(XPOK.address);

    console.log(await XPOK.getOwnerAddress());
    console.log(await XPOK.getUsdtJettonMaster());
    console.log(await XPOK.getPokJettonMaster());
    console.log(await XPOK.getMarketMaker());
    console.log(await XPOK.getRoyaltyWallet());
    console.log(await XPOK.getStartedDate());

    // run methods on `XPOK`
}




