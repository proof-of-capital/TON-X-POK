message(0x2c76b973) ProvideWalletAddress {
    query_id: Int as uint64;
    owner_address: Address;
    include_address: Bool;
}

message(0xd1735400) TakeWalletAddress {
    query_id: Int as uint64;
    wallet_address: Address;
}

message(0xf8a7ea5) JettonTransfer {
    queryId: Int as uint64;
    amount: Int as coins;
    destination: Address;
    responseDestination: Address?;
    customPayload: Cell? = null;
    forwardTonAmount: Int as coins;
    forwardPayload: Cell?;
}

message(0x7362d09c) JettonTransferNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    sender: Address;
    forwardPayload: Slice as remaining;
}

message(1) BuyTickets {}

message(2) ChangePrice {
    newticketPOKPrice: Int;
}

message(3) StartStopLottery {
    isLotteryStarted: Bool;
}

message(4) WithdrawAllTons {}
message(5) WTHCoinsBalances {}

message(6) WTHPOKDebug {
    pokAmount: Int? as coins;
}

message(7) WTHUSDTDebug {
    usdtAmount: Int? as coins;
}

message(8) NewStartDate {
    newStartDate: Int;
}

message(9) Winners {
    indexGame: Int as uint16;
    winTickets: Int as uint16;
}

message(10) SendWinPerRound {
    amount: Int;
    participant: Address;
}

message(11) GetFullWin {}

message(12) TicketsForFullWin {
    participant: Address;
    tickets: Int as uint16;
}

message(13) SendWinForFull {
    amount: Int as coins;
    index: Int as uint16;
}

message(14) FullWin {
    amount: Int as coins;
    participant: Address;
}

message(15) PrizePoolForRound {
    amount: Int as coins;
    addPrize: Int as coins;
    ticketsSold: Int as uint16;
    ticketsWin: Int as uint16;
}

// message PrizePoolForRoundandAddPrize { 
//     amount: Int as coins;
//     addPrize: Int as coins;
//     ticketsSold: Int as uint16;
//     ticketsWin: Int as uint16;
// }

message(16) StartValues {
    levelIndex: Int as uint8;
    winningProbability: Int as uint8;
}

message(17) AddAdditionalJettonData {
    newAdditionalJettonMasterAddress: Address;
    newAdditionalJettonWalletAddress: Address;
    amount: Int as coins;
}

message(18) ChangeMarketMaker {
    newMarketMakerAddress: Address;
}

message(19) ChangeRoyalty {
    newRoyaltyAddress: Address;
}

message(20) NewOwner {
    newOwnerAddress: Address;
}

message(21) ChangeLastGameIndex {
    newLastGameIndex: Int as uint16;
}

message(22) ExtendLockTimeByDays {
    additionalDays: Int as uint8;
}

message(23) InitializeSeason {
    pokAmount: Int as coins;
}

message(24) WithdrawFromRound {
    roundId: Int as uint16;
}

message(25) Win {}

message(26) GetWin {}