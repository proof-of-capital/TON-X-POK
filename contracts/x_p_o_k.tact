import "@stdlib/deploy";
import "@stdlib/ownable";
import "./round_contract";
import "./storage_contract";
import "./messages";

const NANO_COINS_VALUES: Int = pow(10, 9); // множитель 10 ** 9 для стандартных монет
const USDT_VALUES: Int = pow(10, 6); // множитель 10 ** 6 для USDT
const COMMISSION: Int = ton("0.05"); // константа комиссии
const TICKET_TON_PRICE: Int = ton("0.2"); // константа стоимости билета в тонов ?? закладываем ли сюда стоимость деплоя контракта
// const TICKET_TON_PRICE: Int = ton("0.005"); // константа стоимости билета в тонов ?? закладываем ли сюда стоимость деплоя контракта
const TWENTY_FOUR_HOURS: Int = 86_400; // константа 24 часов между раундами
// const TWENTY_FOUR_HOURS: Int = 300; // константа 24 часов между раундами
// const NINETY_DAYS: Int = 7_776_000; // константа 90 дней между перезапусками лотереи
const TWO_DAYS: Int = 172_800; // константа двух дней для короткой лотереи


contract XPOK with Deployable, Ownable {
    // адреса
    owner: Address; // адрес владельца
    marketMaker: Address; // адрес ММ
    usdtJettonMasterAddress: Address; // адрес контракта-мастера USDT
    usdtJettonWalletAddress: Address; // адрес контракта-кошелька USDT для контракта-лотереи
    pokJettonMasterAddress: Address; // адрес контракта-мастера POK 
    pokJettonWalletAddress: Address; // адрес контракта-кошелька POK для контракта-лотереи
    royaltyWallet: Address; // адрес роялти для вывода комиссии ?? с чего идет тогда комиссия

    additionalJettonWalletAddress: Address;
    additionalJettonMasterAddress: Address;

    // балансы
    usdtBalance: Int as coins; // баланс USDT с покупки билетов за USDT
    pokBalance: Int as coins; // баланс POK с покупки билетов в последний день и транзакции ММ ??
    additionalPrize: Int as coins; // баланс дополнительного приза на каждый раунд (первое пополнение ММ POK, разделенное на количество дней лотереи), хранит сумму на 1 раунд
    tons: Int as coins; // баланс TON, отправляемых каждый день ММ, для последнего дня ?? джекпот ?? поменять название переменной на более явную
    workTon: Int as coins; // баланс "рабочих" тонов, которыми поплняет контракт владелец
    allPOKBalance: Int as coins; // баланс всех POK, которые приходят на контракт (ввиду остутствия встроенных методов их отслеживания)

    // изменяемые цены
    ticketUSDTPrice: Int as coins; // цена билета в USDT
    ticketPOKPrice: Int as coins; // цена билета в POK
    
    // дополнительные значения по переменной
    isLotteryStarted: Bool; // Флаг старта лотереи, на случай экстренной необходимости остановки лотереии ?? нужен или нет, мало весит, так как булево значение
    indexGame: Int as uint16; // Индекс (порядковый номер) игры (необходим для деплоя раундов и отслеживания последней 30 игры)
    indexLoop: Int as uint16;
    levelIndex: Int as uint8; // Индекс с которого стартует распределение основного приза (задается при деплое)
    winningProbability: Int as uint8; // Вероятность выигрыша в соотношении 1 к n

    // переменные по билетам
    ticketsSold: Int as uint32; // Общее количество проданных билетов
    ticketsSoldBefore: Int as uint32; // Количество проданных билетов на предыдущем раунде, ?? количество проданных билетов на текущем раунде вычисляется как разность общего количества и количества на предыдущем раунде
    winTickets: Int as uint32; // Количество выигрышных билетов
    maxTickets: Int as uint64; // Максимально количество билетов на раунд (задается при деплое)

    // даты
    startedDate: Int as uint32; // Стартовая дата лотереи, то есть дата начала каждого раунда
    lockEndDate: Int as uint32; // Дата окончания лока между одним запуском лотереи и следующим

    lastGameIndex: Int as uint16;

    tonBalance: Int as coins; // баланс тонов с покупки участниками билетов

    init(owner: Address,
        usdtJettonMasterAddress: Address,
        pokJettonMasterAddress: Address,
        marketMaker: Address,
        royaltyWallet: Address,
        startedDate: Int,
        levelIndex: Int,
        lastGameIndex: Int,
        winningProbability: Int,
        maxTickets: Int) {
        self.owner = owner;
        self.marketMaker = marketMaker;
        self.royaltyWallet = royaltyWallet;
        self.usdtJettonMasterAddress = usdtJettonMasterAddress;
        self.usdtJettonWalletAddress = owner;
        self.pokJettonMasterAddress = pokJettonMasterAddress;
        self.pokJettonWalletAddress = owner;
        self.usdtBalance = 0;
        self.pokBalance = 0;
        self.additionalPrize = 0;
        self.ticketUSDTPrice = 1 * USDT_VALUES; // не задаем начальные значения цен нулевыми ??
        self.ticketPOKPrice = 1_500 * NANO_COINS_VALUES; // не задаем начальные значения цен нулевыми ??
        self.startedDate = startedDate;
        self.workTon = 0;

        self.isLotteryStarted = false;
        self.ticketsSold = 0;
        self.ticketsSoldBefore = 0;
        self.winTickets = 0;
        self.indexGame = 0;
        self.indexLoop = 0;
        self.tons = 0;
        self.tonBalance = 0;
        self.lockEndDate = 0;

        self.allPOKBalance = 0;
        self.levelIndex = levelIndex;
        self.lastGameIndex = lastGameIndex;
        self.winningProbability = winningProbability; // Коэффициент (отношение) выигрыша в формате "1 к X", для меньшего диапазона в рандоме ??

        self.maxTickets = maxTickets;

        self.additionalJettonWalletAddress = owner;
        self.additionalJettonMasterAddress = owner;

        send(SendParameters{ 
            to: self.usdtJettonMasterAddress,
            value: 0,
            mode: SendRemainingValue,
            body: ProvideWalletAddress{query_id: now(), owner_address: myAddress(), include_address: false}.toCell()
        });
    }

    receive(msg: TakeWalletAddress) { 
        let ctx: Context = context();
        require(self.usdtJettonWalletAddress != newAddress(0, 0), "Contract USDT jetton wallet id cannot be zero"); 
        require(self.pokJettonWalletAddress != newAddress(0, 0), "Contract POK jetton wallet id cannot be zero"); 
        require(ctx.sender == self.usdtJettonMasterAddress || ctx.sender == self.pokJettonMasterAddress, "Invalid jetton master USDT or POK sender"); 
        if (ctx.sender == self.usdtJettonMasterAddress) {
            self.usdtJettonWalletAddress = msg.wallet_address; 
        } else {
            self.pokJettonWalletAddress = msg.wallet_address; 
        }
        if (self.pokJettonWalletAddress == self.owner) { 
            send(SendParameters{
                to: self.pokJettonMasterAddress,
                value: 0,
                mode: SendRemainingValue,
                body: ProvideWalletAddress{query_id: now(), owner_address: myAddress(), include_address: true}.toCell()
            });
        }
        
    }

    receive(msg: AddAdditionalJettonData) {
        self.requireOwner();
        require(msg.newAdditionalJettonMasterAddress != self.pokJettonMasterAddress, "Additional jetton master address in message cannot be support master jetton");
        require(msg.newAdditionalJettonWalletAddress != self.pokJettonWalletAddress, "Additional jetton wallet address in mesage cannot be support jetton wallet");
        require(msg.newAdditionalJettonMasterAddress != newAddress(0, 0), "Additional jetton master address in message cannot be zero");
        require(msg.newAdditionalJettonWalletAddress != newAddress(0, 0), "Additional jetton wallet address in mesage cannot be zero");
        require(self.additionalJettonMasterAddress != newAddress(0, 0), "Additional jetton master address cannot be zero"); 
        require(self.additionalJettonWalletAddress != newAddress(0, 0), "Additional jetton wallet address cannot be zero");
        self.additionalJettonMasterAddress = msg.newAdditionalJettonMasterAddress;
        self.additionalJettonWalletAddress = msg.newAdditionalJettonWalletAddress;
        self.transferTokensTo(self.additionalJettonWalletAddress, sender(), msg.amount, "Send other jettons to owner");
    }

    receive(msg: ChangePrices) { 
        self.requireOwner();
        require(msg.newticketUSDTPrice != 0 || msg.newticketPOKPrice != 0, "New ticket prices cannot be null");
        if (msg.newticketUSDTPrice != 0) {
            self.ticketUSDTPrice = msg.newticketUSDTPrice * USDT_VALUES;
        }
        if (msg.newticketPOKPrice != 0) {
            self.ticketPOKPrice = msg.newticketPOKPrice * NANO_COINS_VALUES;
        }
    }

    receive(msg: StopLottery) { 
        self.requireOwner();
        self.isLotteryStarted = msg.stopFlag;
    }

    receive(msg: NewStartDate) { 
        self.requireOwner();
        self.startedDate = msg.newStartDate;
    }

    receive(msg: WithdrawAllTons) { 
        self.requireOwner();
        let returnValue: Int = myBalance() - COMMISSION;
        self.sendTon(self.owner, returnValue, "Transfer TON balance");
    }

    receive(msg: NewOwner) {
        self.requireOwner();
        require(msg.newOwnerAddress != newAddress(0, 0) && msg.newOwnerAddress != self.owner, "New owner address cannot be null or equal to current owner");
        self.owner = msg.newOwnerAddress;
    }

    receive(msg: ChangeMarketMaker) {
        self.requireOwner();
        require(msg.newMarketMakerAddress != newAddress(0, 0) && msg.newMarketMakerAddress != self.marketMaker, "New owner address cannot be null or equal to current market maker");
        self.marketMaker = msg.newMarketMakerAddress;
    }

    receive(msg: ChangeRoyalty) {
        self.requireOwner();
        require(msg.newRoyaltyAddress != newAddress(0, 0) && msg.newRoyaltyAddress != self.royaltyWallet, "New owner address cannot be null or equal to current royalty wallet");
        self.royaltyWallet = msg.newRoyaltyAddress;
    }

    receive("ticket") { 
        if (sender() == self.owner) { 
            self.workTon += context().value;
        } else {
            try {
                require(self.isLotteryStarted == true, "Lottery is not started");
                require(self.indexGame < self.lastGameIndex, "Unavailable on the last day of the lottery");
                require(context().value >= TICKET_TON_PRICE + COMMISSION * 2, "Not enough TONs to buy a ticket or to cover commission");
                require(self.ticketsSold - self.ticketsSoldBefore < self.maxTickets, "Max tickets limit reached");
                let tickets: Int = (context().value - COMMISSION * 2) / TICKET_TON_PRICE;
                let winTickets: Int = self.checkWinTickets(tickets);
                let change: Int = 0;
                let consumed: Int = gasConsumed();
                if (winTickets > 0) {
                    self.sendStorageMsg(sender(), winTickets, true);
                    change = (context().value - (COMMISSION * 2) - (TICKET_TON_PRICE * tickets)) - consumed;
                    self.tonBalance += change > 0 ? context().value - COMMISSION * 2 - change - consumed : context().value - COMMISSION * 2 - consumed;
                } else {
                    change = (context().value - (TICKET_TON_PRICE * tickets)) - consumed;
                    self.tonBalance += change > 0 ? context().value - change - consumed : context().value - consumed;
                }
                if (change > 0) {
                    self.sendTon(sender(), change, "Your change");
                }
                self.ticketsSold += tickets;
            } catch (error) {
                let errorComment: StringBuilder = beginString();
                errorComment.append("Something went wrong (");
                errorComment.append(error.toString());
                errorComment.append(")");
                self.notify(errorComment.toString().asComment());
            }
        }
    }

    receive() { 
        if (sender() == self.owner) { 
            self.workTon += context().value;
        } else {
            try {
                require(self.isLotteryStarted == true, "Lottery is not started");
                require(self.indexGame < self.lastGameIndex, "Unavailable on the last day of the lottery");
                require(context().value >= TICKET_TON_PRICE + COMMISSION * 2, "Not enough TONs to buy a ticket or to cover commission");
                require(self.ticketsSold - self.ticketsSoldBefore < self.maxTickets, "Max tickets limit reached");
                let tickets: Int = (context().value - COMMISSION * 2) / TICKET_TON_PRICE;
                // вот здесь можно еще вкрутить ограничение, 29999 + 5 = 30004
                let winTickets: Int = self.checkWinTickets(tickets);
                let change: Int = 0;
                let consumed: Int = gasConsumed();
                if (winTickets > 0) {
                    self.sendStorageMsg(sender(), winTickets, false);
                    change = (context().value - (COMMISSION * 2) - (TICKET_TON_PRICE * tickets)) - consumed;
                    self.tonBalance += change > 0 ? context().value - COMMISSION * 2 - change - consumed : context().value - COMMISSION * 2 - consumed; // что отнимаем
                } else {
                    change = (context().value - (TICKET_TON_PRICE * tickets)) - consumed;
                    self.tonBalance += change > 0 ? context().value - change - consumed : context().value - consumed;
                }
                if (change > 0) {
                    self.sendTon(sender(), change, "Your change");
                }
                self.ticketsSold += tickets;
            } catch (error) {
                let errorComment: StringBuilder = beginString();
                errorComment.append("Something went wrong (");
                errorComment.append(error.toString());
                errorComment.append(")");
                self.notify(errorComment.toString().asComment());
            }
        }
    }

    receive("win") {
        try {
            require(context().value >= COMMISSION * 3, "Not enough TONs to cover commission");
            require(self.indexGame > 1, "The first round is not over yet");
            let init: StateInit = initOf StorageContract(myAddress(), sender());
            let sendValue: Int = context().value - COMMISSION;
            send(SendParameters{
                to: contractAddress(init),
                value: sendValue,
                body: "get full win".asComment(),
                mode: SendIgnoreErrors | SendPayFwdFeesSeparately,
                code: init.code,
                data: init.data
            });
        } catch (_) {
            self.notify("Not enough TONs to cover commission or the first round is not over yet".asComment());
        }
    }

    receive("get win") {
        require(context().value >= COMMISSION, "Not enough TONs to cover commission");
        let init: StateInit = initOf StorageContract(myAddress(), sender());
        send(SendParameters{
            to: contractAddress(init),
            value: context().value,
            body: "emergency withdrawal".asComment(),
            mode: SendIgnoreErrors | SendPayFwdFeesSeparately,
            code: init.code,
            data: init.data
        });
    }

    receive("from rounds") {
        let id: Int = 1;
        repeat (self.lastGameIndex) {
            let roundIndex: Int = self.indexLoop * 1000 + id;
            let init: StateInit = initOf RoundContract(myAddress(), roundIndex);

            send(SendParameters{
                to: contractAddress(init),
                value: COMMISSION,
                body: "balance".asComment(),
                mode: SendIgnoreErrors | SendPayFwdFeesSeparately,
                code: init.code,
                data: init.data
            });
            id += 1;
        }
    }

    receive("balance from round") { }

    receive("commission") {
        require(context().value >= COMMISSION, "Not enough TONs to cover commission");
        let init: StateInit = initOf StorageContract(myAddress(), sender());
        send(SendParameters{
            to: contractAddress(init),
            body: "commission".asComment(),
            value: COMMISSION,
            mode: SendIgnoreErrors,
            code: init.code,
            data: init.data
        });
    }


    receive(msg: JettonTransferNotification) {
        require(context().value >= COMMISSION * 2, "Not enough TONs to cover commission and deploy storage");
        require(sender() == self.usdtJettonWalletAddress || sender() == self.pokJettonWalletAddress, "Only POK and USDT can be used");
        if (sender() == self.usdtJettonWalletAddress) {
            try {
                require(self.isLotteryStarted == true, "Lottery is not started");
                require(self.indexGame < self.lastGameIndex, "Unavailable on the last day of the lottery");
                require(msg.amount >= self.ticketUSDTPrice, "Not enough USDTs to buy a ticket");
                require(self.ticketsSold - self.ticketsSoldBefore < self.maxTickets, "Max tickets limit reached");
                let tickets: Int = msg.amount / self.ticketUSDTPrice;
                let winTickets: Int = self.checkWinTickets(tickets);
                let change: Int = 0;
                let consumed: Int = gasConsumed();
                if (winTickets > 0) {
                    self.sendStorageMsg(msg.sender, winTickets, false);
                    change = (context().value - COMMISSION * 2) - consumed;
                } else {
                    change = context().value - consumed;
                }
                // добавить сдачу с жетонов
                self.ticketsSold += tickets;
                self.usdtBalance += msg.amount;
            } catch (error) {
                let errorComment: StringBuilder = beginString();
                errorComment.append("Something went wrong (");
                errorComment.append(error.toString());
                errorComment.append(")");
                self.transferTokensTo(self.usdtJettonWalletAddress, msg.sender, msg.amount, errorComment.toString());
            }
        } else {
            try {
                if (self.indexGame == 0) {
                    require(msg.sender == self.owner, "Owner-only access");
                    self.additionalPrize = msg.amount / (self.lastGameIndex - 1); 
                    self.allPOKBalance += msg.amount;
                    self.indexLoop += 1;
                    self.indexGame += 1;
                    self.isLotteryStarted = true;
                    self.deployRounds();
                } else if (self.indexGame >= 1) {
                    if (msg.sender == self.marketMaker && self.indexGame < self.lastGameIndex) { // сделать отправку сообщения на контракт с ПОК для закупки (то есть отправляем все TON и USDT разными сообщениями и получаем ПОК)
                        require(self.isLotteryStarted == true, "Lottery is not started");
                        // цена ПОК в каких-то диапазонах
                        self.allPOKBalance += msg.amount;
                        if (self.usdtBalance > 0) {
                            self.transferTokensTo(self.usdtJettonWalletAddress, msg.sender, self.usdtBalance, "Buying POK for USDT");
                            self.usdtBalance = 0;
                        }
                        self.sendTon(msg.sender, self.tonBalance, "Buying POK for TON");
                        self.tonBalance = 0;
                        self.tons += context().value - COMMISSION;
                        self.sendRoundContractGetWinMsg(msg.amount, self.additionalPrize);
                        self.indexGame += 1;
                        self.startedDate += TWENTY_FOUR_HOURS;
                        self.deployRounds();
                    } else if (msg.sender == self.marketMaker && self.indexGame == self.lastGameIndex) {
                        require(self.isLotteryStarted == true, "Lottery is not started");
                        let royaltyProfit: Int = msg.amount / 10;
                        self.transferTokensTo(self.pokJettonWalletAddress, self.royaltyWallet, royaltyProfit, "Royalty profit");
                        self.allPOKBalance += msg.amount - royaltyProfit;
                        self.sendRoundContractGetWinMsg(self.pokBalance, msg.amount - royaltyProfit);
                        self.sendTon(msg.sender, self.tons, "Buying POK for TON");
                        self.tons = 0;
                        self.lockEndDate = self.startedDate + TWENTY_FOUR_HOURS + TWO_DAYS;
                        self.winTickets = 0;
                        self.isLotteryStarted = false;
                    } else {
                        require(self.indexGame == self.lastGameIndex, "Available only on the last day of the lottery");
                        require(self.isLotteryStarted == true, "Lottery is not started");
                        require(msg.amount >= self.ticketPOKPrice, "Not enough POK to buy a ticket");
                        require(self.ticketsSold - self.ticketsSoldBefore < self.maxTickets, "Max tickets limit reached");
                        let tickets: Int = msg.amount / self.ticketPOKPrice;
                        let winTickets: Int = self.checkWinTickets(tickets);
                        let change: Int = 0;
                        let consumed: Int = gasConsumed();
                        if (winTickets > 0) {
                            self.sendStorageMsg(msg.sender, winTickets, false);
                            change = (context().value - COMMISSION * 2) - consumed;
                        } else {
                            change = context().value - consumed;
                        }
                        self.ticketsSold += tickets;
                        self.pokBalance += msg.amount;
                        self.allPOKBalance += msg.amount;
                    }
                }      
            } catch (error) {
                let errorComment: StringBuilder = beginString();
                errorComment.append("Something went wrong (");
                errorComment.append(error.toString());
                errorComment.append(")");
                self.transferTokensTo(self.pokJettonWalletAddress, msg.sender, msg.amount, errorComment.toString());
            }
        }
    }

    receive(msg: WTHPOKDebug) {
        self.requireOwner();
        let pokAmount: Int = msg.pokAmount != null ? msg.pokAmount!! : self.allPOKBalance;
        self.transferTokensTo(self.pokJettonWalletAddress, sender(), pokAmount, "Transfer all POKs");
        self.allPOKBalance = 0;
        self.pokBalance = 0;
    }

    receive(msg: WTHUSDTDebug) {
        self.requireOwner();
        let usdtAmount: Int = msg.usdtAmount != null ? msg.usdtAmount!! : self.usdtBalance;
        self.transferTokensTo(self.usdtJettonWalletAddress, sender(), usdtAmount, "Transfer all USDTs");
        self.usdtBalance = 0;
    }

    receive(msg: WTHCoinsBalances) {
        self.requireOwner();
        require(now() > self.lockEndDate, "The lock is not over yet");
        self.transferTokensTo(self.pokJettonWalletAddress, sender(), self.allPOKBalance, "Transfer POKs to owner");
        self.usdtBalance = 0;
        self.pokBalance = 0;
        self.additionalPrize = 0;
        self.workTon = COMMISSION;
        self.isLotteryStarted = false;
        self.ticketsSold = 0;
        self.ticketsSoldBefore = 0;
        self.winTickets = 0;
        self.indexGame = 0;
        self.tons = 0;
        self.lockEndDate = 0;
        self.allPOKBalance = 0;
        self.pokBalance = 0;
    }

    receive(msg: FullWin) {
        try {
            require(msg.amount != 0, "You have no tickets!");
            self.transferTokensTo(self.pokJettonWalletAddress, msg.participant, msg.amount, "Your full win");
            self.allPOKBalance -= msg.amount;
        } catch (error) {
            self.sendComment(msg.participant, "You have no tickets!");
        }

    }

    fun sendComment(recipient: Address, comment: String) {
        send(SendParameters{
            to: recipient,
            body: comment.asComment(),
            value: COMMISSION,
            bounce: false
        });
    }

    fun deployRounds() {
        let sender: Address = myAddress();
        let roundIndex: Int = self.indexLoop * 1000 + self.indexGame;
        let init: StateInit = initOf RoundContract(sender, roundIndex);

        send(SendParameters{
            to: contractAddress(init),
            body: StartValues{
                levelIndex: self.levelIndex,
                winningProbability: self.winningProbability
            }.toCell(),
            value: COMMISSION,
            mode: SendPayFwdFeesSeparately,
            code: init.code,
            data: init.data,
        });
    }

    fun sendRoundContractGetWinMsg(prize: Int, addPrize: Int) {
        let sender: Address = myAddress();
        let roundIndex: Int = self.indexLoop * 1000 + self.indexGame;
        let init: StateInit = initOf RoundContract(sender, roundIndex);
        let ticketsSoldPerRound: Int = self.ticketsSold - self.ticketsSoldBefore;
        let sendValue: Int = COMMISSION * 3;
        send(SendParameters{
            to: contractAddress(init),
            body: PrizePoolForRound{amount: prize, addPrize: addPrize, ticketsSold: ticketsSoldPerRound, ticketsWin: self.winTickets}.toCell(),
            value: sendValue,
            mode: SendIgnoreErrors | SendPayFwdFeesSeparately,
        });
        self.ticketsSoldBefore = self.ticketsSold;
        self.winTickets = 0;
    }

    fun sendTon(to: Address, value: Int, comment: String) {
        send(SendParameters{
            to: to,
            value: value,
            bounce: true,
            mode: SendPayFwdFeesSeparately,
            body: comment.asComment()
        });
    }

    fun transferTokensTo(toAddress: Address, recipient: Address, amount: Int, comment: String) {

        let textComment: StringBuilder = beginString();
        textComment.append(comment);

        let forwardPayload: Cell = beginCell()
        .storeUint(0, 32)
        .storeRef(textComment.toCell())
        .endCell();

        send(SendParameters{
            to: toAddress,
            value: COMMISSION,
            body: JettonTransfer{
                queryId: now(),
                amount: amount,
                destination: recipient,
                responseDestination: recipient,
                customPayload: null,
                forwardTonAmount: 1,
                forwardPayload: forwardPayload
            }.toCell(),
        });
    }

    fun checkWinTickets(tickets: Int): Int { // поменять на поиск в диапазоне ?
        let winTickets: Int = 0;
        repeat (tickets) {
            let winFlag: Bool = random(1, self.winningProbability + 1) == 1 ? true : false;
            if (winFlag) {
                winTickets += 1;
            }
        }
        self.winTickets += winTickets;
        return winTickets;
    }

    fun sendStorageMsg(participant: Address, tickets: Int, isDeployed: Bool) {
        let sender: Address = myAddress();
        let init: StateInit = initOf StorageContract(sender, participant);
        let index: Int = self.indexLoop * 1000 + self.indexGame;

        if (!isDeployed) {
            send(SendParameters{
                to: contractAddress(init),
                body: Winners{indexGame: index, winTickets: tickets}.toCell(),
                value: COMMISSION,
                mode: SendIgnoreErrors | SendPayFwdFeesSeparately,
                code: init.code,
                data: init.data,
            });        
        } else {
            send(SendParameters{
                to: contractAddress(init),
                body: Winners{indexGame: index, winTickets: tickets}.toCell(),
                value: COMMISSION,
                mode: SendPayFwdFeesSeparately,
            });
        }
    }

    get fun balance(): Int {
        return myBalance();
    }

    get fun owner_address(): Address {
        return self.owner;
    }

    get fun contract_address(): Address {
        return myAddress();
    }

    get fun round_contract_address(indexLoop: Int, indexGame: Int): Address {
        let roundIndex: Int = indexLoop * 1000 + indexGame;
        let init: StateInit = initOf RoundContract(myAddress(), roundIndex);
        return contractAddress(init);
    }

    get fun storage_address(participant: Address): Address {
        let init: StateInit = initOf StorageContract(myAddress(), participant);
        return contractAddress(init);
    }

    get fun market_maker(): Address {
        return self.marketMaker;
    }

    get fun usdt_jetton_master(): Address {
        return self.usdtJettonMasterAddress;
    }

    get fun usdt_jetton_wallet():  Address {
        return self.usdtJettonWalletAddress;
    }

    get fun pok_jetton_master(): Address {
        return self.pokJettonMasterAddress;
    }

    get fun pok_jetton_wallet(): Address {
        return self.pokJettonWalletAddress;
    }

    get fun royalty_wallet(): Address {
        return self.royaltyWallet;
    }

    get fun add_jetton_wallet(): Address {
        return self.additionalJettonWalletAddress;
    }

    get fun add_jetton_master(): Address {
        return self.additionalJettonMasterAddress;
    }

    get fun level_index(): Int {
        return self.levelIndex;
    }

    get fun loop_index(): Int {
        return self.indexLoop;
    }

    get fun last_game_index(): Int {
        return self.lastGameIndex;
    }

    get fun winning_probability(): Int {
        return self.winningProbability;
    }

    get fun max_tickets(): Int {
        return self.maxTickets;
    }

    get fun usdt_balance(): Int {
        return self.usdtBalance / USDT_VALUES;
    }

    get fun pok_balance(): Int {
        return self.pokBalance / NANO_COINS_VALUES;
    }

    get fun ticket_usdt_price(): Int {
        return self.ticketUSDTPrice / USDT_VALUES;
    }

    get fun ticket_pok_price(): Int {
        return self.ticketPOKPrice / NANO_COINS_VALUES;
    }

    get fun ticket_ton_price(): Int {
        return TICKET_TON_PRICE / NANO_COINS_VALUES;
    }

    get fun commission(): Int {
        return COMMISSION;
    }

    get fun additional_prize(): Int {
        return self.additionalPrize;
    }

    get fun is_lottery_started(): Bool {
        return self.isLotteryStarted;
    }

    get fun tickets_sold(): Int {
        return self.ticketsSold - self.ticketsSoldBefore;
    }

    get fun tickets_sold_total(): Int {
        return self.ticketsSold;
    }

    get fun tickets_sold_before(): Int {
        return self.ticketsSoldBefore;
    }

    get fun win_tickets(): Int {
        return self.winTickets;
    }

    get fun index_game(): Int {
        return self.indexGame;
    }

    get fun started_date(): Int {
        return self.startedDate;
    }

    get fun tons_for_last_day(): Int {
        return self.tons;
    }

    get fun lock_end_date(): Int {
        return self.lockEndDate;
    }

    get fun work_ton(): Int {
        return self.workTon;
    }

    get fun all_pok_balance(): Int {
        return self.allPOKBalance;
    }

    get fun ticket_for_ton(ton: Int): Int {
        return ton / TICKET_TON_PRICE;
    }

    get fun ticket_for_usdt(usdt: Int): Int {
        return (usdt * USDT_VALUES) / self.ticketUSDTPrice;
    }

    get fun ton_balance(): Int {
        return self.tonBalance / NANO_COINS_VALUES;
    }

    get fun ticket_for_pok(pok: Int): Int {
        return (pok * NANO_COINS_VALUES) / self.ticketPOKPrice;
    }

    get fun win_commission(numRound: Int): Int {
        return (numRound * (COMMISSION * 3) + COMMISSION);
    }
}