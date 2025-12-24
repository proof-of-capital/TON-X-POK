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

message(0x1) BuyTickets {
    isNewUser: Bool;
}

message(0x2) ChangePrice {
    newticketPOKPrice: Int;
}

message(0x3) StartStopLottery {
    isLotteryStarted: Bool;
}

message(0x4) WithdrawAllTons {}
message(0x5) WTHCoinsBalances {}

message(0x6) WTHPOKDebug {
    pokAmount: Int? as coins;
}

message(0x7) WTHUSDTDebug {
    usdtAmount: Int? as coins;
}

message(0x8) NewStartDate {
    newStartDate: Int;
}

message(0x9) Winners {
    indexGame: Int as uint16;
    winTickets: Int as uint16;
}

message(0xa) SendWinPerRound {
    amount: Int;
    participant: Address;
}

message(0xb) GetFullWin {}

message(0xc) TicketsForFullWin {
    participant: Address;
    tickets: Int as uint16;
}

message(0xd) SendWinForFull {
    amount: Int as coins;
    index: Int as uint16;
    tickets: Int as uint16;
}

message(0xe) FullWin {
    amount: Int as coins;
    participant: Address;
}

message(0xf) PrizePoolForRound {
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

message(0x10) StartValues {
    levelIndex: Int as uint8;
    winningProbability: Int as uint8;
}

message(0x11) AddAdditionalJettonData {
    newAdditionalJettonMasterAddress: Address;
    newAdditionalJettonWalletAddress: Address;
    amount: Int as coins;
}

message(0x12) ChangeMarketMaker {
    newMarketMakerAddress: Address;
}

message(0x13) ChangeRoyalty {
    newRoyaltyAddress: Address;
}

message(0x14) NewOwner {
    newOwnerAddress: Address;
}

message(0x15) ChangeLastGameIndex {
    newLastGameIndex: Int as uint16;
}

message(0x16) ExtendLockTimeByDays {
    additionalDays: Int as uint8;
}

message(0x17) InitializeSeason {
    pokAmount: Int as coins;
}

message(0x18) WithdrawFromRound {
    roundId: Int as uint16;
}

message(0x19) Win {}

message(0x20) GetWin {}