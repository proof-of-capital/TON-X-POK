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

message ChangePrices {
    newticketUSDTPrice: Int;
    newticketPOKPrice: Int;
}

message StopLottery {
    stopFlag: Bool;
}

message WithdrawAllTons {}

message WTHCoinsBalances {}

message WTHPOKDebug {
    pokAmount: Int? as coins;
}

message WTHUSDTDebug {
    usdtAmount: Int? as coins;
}

message NewStartDate {
    newStartDate: Int;
}

message Winners {
    indexGame: Int as uint16;
    winTickets: Int as uint16;
}

message SendWinPerRound {
    amount: Int;
    participant: Address;
}

message GetFullWin {}

message TicketsForFullWin {
    tickets: Int as uint16;
}

message SendWinForFull {
    amount: Int as coins;
    index: Int as uint16;
}

message FullWin {
    amount: Int as coins;
    participant: Address;
}

message PrizePoolForRound {
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

message StartValues {
    levelIndex: Int as uint8;
    winningProbability: Int as uint8;
}

message AddAdditionalJettonData {
    newAdditionalJettonMasterAddress: Address;
    newAdditionalJettonWalletAddress: Address;
    amount: Int as coins;
}

message ChangeMarketMaker {
    newMarketMakerAddress: Address;
}

message ChangeRoyalty {
    newRoyaltyAddress: Address;
}

message NewOwner {
    newOwnerAddress: Address;
}

