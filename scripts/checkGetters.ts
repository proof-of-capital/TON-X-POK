import { Address, toNano } from '@ton/core';
import { XPOK } from '../build/XPOK/XPOK_XPOK';
import { NetworkProvider } from '@ton/blueprint';
import { CONTRACTADDRESS } from './!YOURCONTRACTADDRESS';

export async function run(provider: NetworkProvider) {
    const contractAddress = Address.parse(CONTRACTADDRESS); 
    
    const xpok = provider.open(
        XPOK.fromAddress(contractAddress)
    );
    
    console.log('LOTTERY GETTER');
    console.log('started date', await xpok.getStartedDate());
    console.log('is lottery started', await xpok.getIsLotteryStarted());
    console.log('1 round contract address', await xpok.getRoundContractAddress(1n, 1n));
    console.log('2 round contract address', await xpok.getRoundContractAddress(1n, 2n));
    console.log('ticket sold', await xpok.getTicketsSold());
    console.log('tickets win', await xpok.getWinTickets());
    console.log('owner address', await xpok.getOwner());
    console.log('royalty wallet', await xpok.getRoyaltyWallet());
    console.log('market maker', await xpok.getMarketMaker());

    console.log('pok jetton wallet', await xpok.getPokJettonWallet());

    console.log('all pok balance', await xpok.getAllPokBalance());
    console.log('round', await xpok.getIndexGame());

    console.log('win commision', await xpok.getWinCommission(2n));

    console.log('', await xpok.getTonBalance());

    console.log('pok price', await xpok.getTicketPokPrice())

}