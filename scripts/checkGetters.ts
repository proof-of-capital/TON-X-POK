import { Address, toNano } from '@ton/core';
import { XPOK } from '../build/XPOK/XPOK_XPOK';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';
import { RoundContract } from '../build/XPOK/tact_RoundContract';

export async function run(provider: NetworkProvider) {
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    
    const XPOK = provider.open(
        XPOK.fromAddress(contractAddress)
    );
    
    console.log('LOTTERY GETTER');
    console.log('started date', await XPOK.getStartedDate());
    console.log('is lottery started', await XPOK.getIsLotteryStarted());
    console.log('1 round contract address', await XPOK.getRoundContractAddress(1n, 1n));
    console.log('2 round contract address', await XPOK.getRoundContractAddress(1n, 2n));
    console.log('ticket sold', await XPOK.getTicketsSold());
    console.log('tickets win', await XPOK.getWinTickets());
    console.log('owner address', await XPOK.getOwner());
    console.log('royalty wallet', await XPOK.getRoyaltyWallet());
    console.log('market maker', await XPOK.getMarketMaker());

    console.log('pok jetton wallet', await XPOK.getPokJettonWallet());
    console.log('usdt jetton wallet', await XPOK.getUsdtJettonWallet());

    console.log('all pok balance', await XPOK.getAllPokBalance());
    console.log('round', await XPOK.getIndexGame());

    console.log('win commision', await XPOK.getWinCommission(2n));

    console.log('', await XPOK.getTonBalance());

    console.log('pok price', await XPOK.getTicketPokPrice())

}