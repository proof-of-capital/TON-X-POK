import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages";

contract RoundContract with Ownable {
    owner: Address;
    indexGame: Int as uint16;
    prizeFund: Int as coins;

    addPrize: Int as coins;

    ticketsSold: Int as uint16;
    ticketsWin: Int as uint16;

    lastLevelIndex: Int as uint8;
    levelIndex: Int as uint8;

    winningProbability: Int as uint8;

    totalTickets: Int as uint16;

    allWinners: Int as uint16 = 0;

    // хранение количества победителей и выигрышей
    winnersNum1: Int as uint16 = 0;
    winnersAmount1: Int as coins = 0;

    winnersNum2: Int as uint16 = 0;
    winnersAmount2: Int as coins = 0;

    winnersNum3: Int as uint16 = 0;
    winnersAmount3: Int as coins = 0;
    
    winnersNum4: Int as uint16 = 0;
    winnersAmount4: Int as coins = 0;

    winnersNum5: Int as uint16 = 0;
    winnersAmount5: Int as coins = 0;

    winnersNum6: Int as uint16 = 0;
    winnersAmount6: Int as coins = 0;

    winnersNum7: Int as uint16 = 0;
    winnersAmount7: Int as coins = 0;

    winnersNum8: Int as uint16 = 0;
    winnersAmount8: Int as coins = 0;

    winnersNum9: Int as uint16 = 0;
    winnersAmount9: Int as coins = 0;

    winnersNum10: Int as uint16 = 0;
    winnersAmount10: Int as coins = 0;

    winnersNum11: Int as uint16 = 0;
    winnersAmount11: Int as coins = 0;

    winnersNum12: Int as uint16 = 0;
    winnersAmount12: Int as coins = 0;

    winnersNum13: Int as uint16 = 0;
    winnersAmount13: Int as coins = 0;

    winnersNum14: Int as uint16 = 0;
    winnersAmount14: Int as coins = 0;

    winnersNum15: Int as uint16 = 0;
    winnersAmount15: Int as coins = 0;

    winnersNum16: Int as uint16 = 0;
    winnersAmount16: Int as coins = 0;

    // доп приз / джекпот
    addWinnersNum1: Int as uint16 = 0;
    addWinnersAmount1: Int as coins = 0;

    addWinnersNum2: Int as uint16 = 0;
    addWinnersAmount2: Int as coins = 0;

    addWinnersNum3: Int as uint16 = 0;
    addWinnersAmount3: Int as coins = 0;

    addWinnersNum4: Int as uint16 = 0;
    addWinnersAmount4: Int as coins = 0;

    addWinnersNum5: Int as uint16 = 0;
    addWinnersAmount5: Int as coins = 0;

    addWinnersNum6: Int as uint16 = 0;
    addWinnersAmount6: Int as coins = 0;

    addWinnersNum7: Int as uint16 = 0;
    addWinnersAmount7: Int as coins = 0;

    addWinnersNum8: Int as uint16 = 0;
    addWinnersAmount8: Int as coins = 0;

    addWinnersNum9: Int as uint16 = 0;
    addWinnersAmount9: Int as coins = 0;

    addWinnersNum10: Int as uint16 = 0;
    addWinnersAmount10: Int as coins = 0;

    winnersCount: Int as uint8 = 0;

    currentLevel: Int as uint16 = 0;

    init(owner: Address, indexGame: Int) {
        self.owner = owner;
        self.indexGame = indexGame;
        self.prizeFund = 0;
        self.addPrize = 0;
        self.ticketsSold = 0;
        self.ticketsWin = 0;
        self.lastLevelIndex = 0;
        self.levelIndex = 0;
        self.winningProbability = 0;
        self.totalTickets = 0;
    }

    receive("balance") {
        self.requireOwner();
        if (myBalance() > COMMISSION) {
            let value: Int = myBalance() - COMMISSION;
            send(SendParameters{
                to: sender(),
                value: value,
                body: "balance from round".asComment()
            });
        }
    }

    receive(msg: StartValues) {
        self.requireOwner();
        self.levelIndex = msg.levelIndex;
        self.lastLevelIndex = msg.levelIndex;
        self.winningProbability = msg.winningProbability;
    }

    receive(msg: PrizePoolForRound) {
        self.requireOwner();
        self.prizeFund = msg.amount > 0 ? msg.amount : 1; 
        self.addPrize = msg.addPrize > 0 ? msg.addPrize : 1; // защиты от нуля
        self.ticketsSold = msg.ticketsSold > 0 ? msg.ticketsSold : 1; 
        self.ticketsWin = msg.ticketsWin > 0 ? msg.ticketsWin : 1;
        self.getWinners(msg.amount);
        self.getAddWinners();
    }

    receive(msg: TicketsForFullWin) {
        let amount: Int = self.checkWin(msg.tickets);

        send(SendParameters{
            to: sender(),
            value: COMMISSION,
            body: SendWinForFull {
                amount: amount,
                index: self.indexGame
            }.toCell(),
        });
    }

    fun setWinnerVariables(iteration: Int, numWinners: Int, amount: Int) {
        if (iteration == 1) {
            self.allWinners += numWinners;
            self.winnersNum1 = numWinners;
            self.winnersAmount1 = amount;
        } else if (iteration == 2) {
            self.allWinners += numWinners;
            self.winnersNum2 = numWinners;
            self.winnersAmount2 = amount;
        } else if (iteration == 3) {
            self.allWinners += numWinners;
            self.winnersNum3 = numWinners;
            self.winnersAmount3 = amount;
        } else if (iteration == 4) {
            self.allWinners += numWinners;
            self.winnersNum4 = numWinners;
            self.winnersAmount4 = amount;
        } else if (iteration == 5) {
            self.allWinners += numWinners;
            self.winnersNum5 = numWinners;
            self.winnersAmount5 = amount;
        } else if (iteration == 6) {
            self.allWinners += numWinners;
            self.winnersNum6 = numWinners;
            self.winnersAmount6 = amount;
        } else if (iteration == 7) {
            self.allWinners += numWinners;
            self.winnersNum7 = numWinners;
            self.winnersAmount7 = amount;
        } else if (iteration == 8) {
            self.allWinners += numWinners;
            self.winnersNum8 = numWinners;
            self.winnersAmount8 = amount;
        } else if (iteration == 9) {
            self.allWinners += numWinners;
            self.winnersNum9 = numWinners;
            self.winnersAmount9 = amount;
        } else if (iteration == 10) {
            self.allWinners += numWinners;
            self.winnersNum10 = numWinners;
            self.winnersAmount10 = amount;
        } else if (iteration == 11) {
            self.allWinners += numWinners;
            self.winnersNum11 = numWinners;
            self.winnersAmount11 = amount;
        } else if (iteration == 12) {
            self.allWinners += numWinners;
            self.winnersNum12 = numWinners;
            self.winnersAmount12 = amount;
        } else if (iteration == 13) {
            self.allWinners += numWinners;
            self.winnersNum13 = numWinners;
            self.winnersAmount13 = amount;
        } else if (iteration == 14) {
            self.allWinners += numWinners;
            self.winnersNum14 = numWinners;
            self.winnersAmount14 = amount;
        } else if (iteration == 15) {
            self.allWinners += numWinners;
            self.winnersNum15 = numWinners;
            self.winnersAmount15 = amount;
        } else if (iteration == 16) {
            self.allWinners += numWinners;
            self.winnersNum16 = numWinners;
            self.winnersAmount16 = amount;
        }
    }

    fun checkWin(tickets: Int): Int {
        let amount: Int = 0;
        let checkAddWin: Int = tickets + self.totalTickets;
        if (self.allWinners > 0) {
            while (tickets > 0) {
                let winner: Int = random(1, self.allWinners + 1);
                amount += self.foundLevel(winner);
                self.totalTickets += 1;
                amount += checkAddWin >= self.currentLevel && self.currentLevel > 0 ? self.checkAddWin(self.currentLevel) : 0;
                tickets -= 1;
                self.ticketsWin -= 1;
            }
        }
        return amount;
    }

    fun foundLevel(ticket: Int): Int { 
        let total: Int = self.allWinners;        
        if (total - self.winnersNum16 < ticket) {
            self.winnersNum16 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount16;
        }
        total -= self.winnersNum16;
        if (total - self.winnersNum15 < ticket) {
            self.winnersNum15 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount15;
        }
        total -= self.winnersNum15;
        if (total - self.winnersNum14 < ticket) {
            self.winnersNum14 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount14;
        }
        total -= self.winnersNum14;
        if (total - self.winnersNum13 < ticket) {
            self.winnersNum13 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount13;
        }
        total -= self.winnersNum13;
        if (total - self.winnersNum12 < ticket) {
            self.winnersNum12 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount12;
        }
        total -= self.winnersNum12;
        if (total - self.winnersNum11 < ticket) {
            self.winnersNum11 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount11;
        }
        total -= self.winnersNum11;    
        if (total - self.winnersNum10 < ticket) {
            self.winnersNum10 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount10;
        }
        total -= self.winnersNum10;
        if (total - self.winnersNum9 < ticket) {
            self.winnersNum9 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount9;
        }
        total -= self.winnersNum9;
        if (total - self.winnersNum8 < ticket) {
            self.winnersNum8 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount8;
        }
        total -= self.winnersNum8;
        if (total - self.winnersNum7 < ticket) {
            self.winnersNum7 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount7;
        }
        total -= self.winnersNum7;
        if (total - self.winnersNum6 < ticket) {
            self.winnersNum6 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount6;
        }
        total -= self.winnersNum6;
        if (total - self.winnersNum5 < ticket) {
            self.winnersNum5 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount5;
        }
        total -= self.winnersNum5;
        if (total - self.winnersNum4 < ticket) {
            self.winnersNum4 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount4;
        }
        total -= self.winnersNum4;
        if (total - self.winnersNum3 < ticket) {
            self.winnersNum3 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount3;
        }
        total -= self.winnersNum3;
        if (total - self.winnersNum2 < ticket) {
            self.winnersNum2 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount2;
        }
        total -= self.winnersNum2;
        if (total - self.winnersNum1 < ticket) {
            self.winnersNum1 -= 1;
            self.allWinners -= 1;
            return self.winnersAmount1;
        }
        return 0;
    }

    fun setAddWinner(winTicket: Int, amount: Int) {
        if (amount == 0) {
            return;
        }

        if (self.winnersCount == 0 || winTicket < self.addWinnersNum1) {
            self.addWinnersNum10 = self.addWinnersNum9; 
            self.addWinnersAmount10 = self.addWinnersAmount9;
            self.addWinnersNum9 = self.addWinnersNum8;
            self.addWinnersAmount9 = self.addWinnersAmount8;
            self.addWinnersNum8 = self.addWinnersNum7; 
            self.addWinnersAmount8 = self.addWinnersAmount7;
            self.addWinnersNum7 = self.addWinnersNum6; 
            self.addWinnersAmount7 = self.addWinnersAmount6;
            self.addWinnersNum6 = self.addWinnersNum5; 
            self.addWinnersAmount6 = self.addWinnersAmount5;
            self.addWinnersNum5 = self.addWinnersNum4; 
            self.addWinnersAmount5 = self.addWinnersAmount4;
            self.addWinnersNum4 = self.addWinnersNum3; 
            self.addWinnersAmount4 = self.addWinnersAmount3;
            self.addWinnersNum3 = self.addWinnersNum2; 
            self.addWinnersAmount3 = self.addWinnersAmount2;
            self.addWinnersNum2 = self.addWinnersNum1; 
            self.addWinnersAmount2 = self.addWinnersAmount1;
            self.addWinnersNum1 = winTicket;
            self.addWinnersAmount1 = amount;
            self.winnersCount += 1;
            self.currentLevel = winTicket;
            return;
        } 
        if (self.winnersCount < 2 || winTicket < self.addWinnersNum2) {
            self.addWinnersNum10 = self.addWinnersNum9; 
            self.addWinnersAmount10 = self.addWinnersAmount9;
            self.addWinnersNum9 = self.addWinnersNum8;
            self.addWinnersAmount9 = self.addWinnersAmount8;
            self.addWinnersNum8 = self.addWinnersNum7; 
            self.addWinnersAmount8 = self.addWinnersAmount7;
            self.addWinnersNum7 = self.addWinnersNum6; 
            self.addWinnersAmount7 = self.addWinnersAmount6;
            self.addWinnersNum6 = self.addWinnersNum5; 
            self.addWinnersAmount6 = self.addWinnersAmount5;
            self.addWinnersNum5 = self.addWinnersNum4; 
            self.addWinnersAmount5 = self.addWinnersAmount4;
            self.addWinnersNum4 = self.addWinnersNum3; 
            self.addWinnersAmount4 = self.addWinnersAmount3;
            self.addWinnersNum3 = self.addWinnersNum2; 
            self.addWinnersAmount3 = self.addWinnersAmount2;
            self.addWinnersNum2 = winTicket;
            self.addWinnersAmount2 = amount;
            self.winnersCount += 1;
            return;
        }

        if (self.winnersCount < 3 || winTicket < self.addWinnersNum3) {
            self.addWinnersNum10 = self.addWinnersNum9; 
            self.addWinnersAmount10 = self.addWinnersAmount9;
            self.addWinnersNum9 = self.addWinnersNum8;
            self.addWinnersAmount9 = self.addWinnersAmount8;
            self.addWinnersNum8 = self.addWinnersNum7; 
            self.addWinnersAmount8 = self.addWinnersAmount7;
            self.addWinnersNum7 = self.addWinnersNum6; 
            self.addWinnersAmount7 = self.addWinnersAmount6;
            self.addWinnersNum6 = self.addWinnersNum5; 
            self.addWinnersAmount6 = self.addWinnersAmount5;
            self.addWinnersNum5 = self.addWinnersNum4; 
            self.addWinnersAmount5 = self.addWinnersAmount4;
            self.addWinnersNum4 = self.addWinnersNum3; 
            self.addWinnersAmount4 = self.addWinnersAmount3;
            self.addWinnersNum3 = winTicket;
            self.addWinnersAmount3 = amount;
            self.winnersCount += 1;
            return;
        }

        if (self.winnersCount < 4 || winTicket < self.addWinnersNum4) {
            self.addWinnersNum10 = self.addWinnersNum9; 
            self.addWinnersAmount10 = self.addWinnersAmount9;
            self.addWinnersNum9 = self.addWinnersNum8;
            self.addWinnersAmount9 = self.addWinnersAmount8;
            self.addWinnersNum8 = self.addWinnersNum7; 
            self.addWinnersAmount8 = self.addWinnersAmount7;
            self.addWinnersNum7 = self.addWinnersNum6; 
            self.addWinnersAmount7 = self.addWinnersAmount6;
            self.addWinnersNum6 = self.addWinnersNum5; 
            self.addWinnersAmount6 = self.addWinnersAmount5;
            self.addWinnersNum5 = self.addWinnersNum4; 
            self.addWinnersAmount5 = self.addWinnersAmount4;
            self.addWinnersNum4 = winTicket; 
            self.addWinnersAmount4 = amount;
            self.winnersCount += 1;
            return;
        }

        if (self.winnersCount < 5 || winTicket < self.addWinnersNum5) {
            self.addWinnersNum10 = self.addWinnersNum9; 
            self.addWinnersAmount10 = self.addWinnersAmount9;
            self.addWinnersNum9 = self.addWinnersNum8;
            self.addWinnersAmount9 = self.addWinnersAmount8;
            self.addWinnersNum8 = self.addWinnersNum7; 
            self.addWinnersAmount8 = self.addWinnersAmount7;
            self.addWinnersNum7 = self.addWinnersNum6;
            self.addWinnersAmount7 = self.addWinnersAmount6;
            self.addWinnersNum6 = self.addWinnersNum5; 
            self.addWinnersAmount6 = self.addWinnersAmount5;
            self.addWinnersNum5 = winTicket; 
            self.addWinnersAmount5 = amount;
            self.winnersCount += 1;
            return;
        }

        if (self.winnersCount < 6 || winTicket < self.addWinnersNum6) {
            self.addWinnersNum10 = self.addWinnersNum9; 
            self.addWinnersAmount10 = self.addWinnersAmount9;
            self.addWinnersNum9 = self.addWinnersNum8;
            self.addWinnersAmount9 = self.addWinnersAmount8;
            self.addWinnersNum8 = self.addWinnersNum7; 
            self.addWinnersAmount8 = self.addWinnersAmount7;
            self.addWinnersNum7 = self.addWinnersNum6;
            self.addWinnersAmount7 = self.addWinnersAmount6;
            self.addWinnersNum6 = winTicket; 
            self.addWinnersAmount6 = amount;
            self.winnersCount += 1;
            return;
        }

        if (self.winnersCount < 7 || winTicket < self.addWinnersNum7) {
            self.addWinnersNum10 = self.addWinnersNum9; 
            self.addWinnersAmount10 = self.addWinnersAmount9;
            self.addWinnersNum9 = self.addWinnersNum8;
            self.addWinnersAmount9 = self.addWinnersAmount8;
            self.addWinnersNum8 = self.addWinnersNum7;
            self.addWinnersAmount8 = self.addWinnersAmount7;
            self.addWinnersNum7 = winTicket;
            self.addWinnersAmount7 = amount;
            self.winnersCount += 1;
            return;
        }

        if (self.winnersCount < 8 || winTicket < self.addWinnersNum8) {
            self.addWinnersNum10 = self.addWinnersNum9; 
            self.addWinnersAmount10 = self.addWinnersAmount9;
            self.addWinnersNum9 = self.addWinnersNum8;
            self.addWinnersAmount9 = self.addWinnersAmount8;
            self.addWinnersNum8 = winTicket; 
            self.addWinnersAmount8 = amount;
            self.winnersCount += 1;
            return;
        }

        if (self.winnersCount < 9 || winTicket < self.addWinnersNum9) {
            self.addWinnersNum9 = winTicket;
            self.addWinnersAmount9 = amount;
            self.winnersCount += 1;
            return;
        }

        self.addWinnersNum10 = winTicket;
        self.addWinnersAmount10 = amount;
        self.winnersCount += 1;
        return;
    }

    fun checkAddWin(ticket: Int): Int {
        let amount: Int = 0;

        if (self.addWinnersNum1 == ticket) {
            amount += self.addWinnersAmount1;
            self.addWinnersNum1 = 0;
            self.currentLevel = self.addWinnersNum2;
        } 
        if (self.addWinnersNum2 == ticket) {
            amount += self.addWinnersAmount2;
            self.addWinnersNum2 = 0;
            self.currentLevel = self.addWinnersNum3;
        }
        if (self.addWinnersNum3 == ticket) {
            amount += self.addWinnersAmount3;
            self.addWinnersNum3 = 0;
            self.currentLevel = self.addWinnersNum4;
        }
        if (self.addWinnersNum4 == ticket) {
            amount += self.addWinnersAmount4;
            self.addWinnersNum4 = 0;
            self.currentLevel = self.addWinnersNum5;
        }
        if (self.addWinnersNum5 == ticket) {
            amount += self.addWinnersAmount5;
            self.addWinnersNum4 = 0;
            self.currentLevel = self.addWinnersNum6;
        }
        if (self.addWinnersNum6 == ticket) {
            amount = self.addWinnersAmount6;
            self.addWinnersNum6 = 0;
            self.currentLevel = self.addWinnersNum7;
        }
        if (self.addWinnersNum7 == ticket) {
            amount = self.addWinnersAmount7;
            self.addWinnersNum7 = 0;
            self.currentLevel = self.addWinnersNum8;
        }
        if (self.addWinnersNum8 == ticket) {
            amount = self.addWinnersAmount8;
            self.addWinnersNum8 = 0;
            self.currentLevel = self.addWinnersNum9;
        }
        if (self.addWinnersNum9 == ticket) {
            amount = self.addWinnersAmount9;
            self.addWinnersNum9 = 0;
            self.currentLevel = self.addWinnersNum10;
        }
        if (self.addWinnersNum10 == ticket) {
            amount = self.addWinnersAmount10;
            self.addWinnersNum10 = 0;
            self.currentLevel = 0;
        }
        return amount;
    }

    fun getWinners(amount: Int) { 
        let prizeFund: Int = amount;
        let levelIndex: Int = self.levelIndex;
        let tickSold: Int = self.ticketsWin * self.winningProbability;
        let remainingWinners: Int = self.ticketsWin;
        let currentWinners: Int = 0;
        let ticketPOKPrice: Int = amount / tickSold;
        let iteration: Int = 1;

        while (remainingWinners >= 1) {
            currentWinners = remainingWinners / 2;
            if (remainingWinners > 1 && remainingWinners % 2 != 0) {
                currentWinners += 1;
            }

            if (remainingWinners == 1) { 
                self.setWinnerVariables(iteration, remainingWinners, prizeFund);
                self.lastLevelIndex = iteration;
                return;
            }

            let prizePerWinner: Int = ticketPOKPrice * levelIndex;
            let totalPrizeForLevel: Int = prizePerWinner * currentWinners;

            self.setWinnerVariables(iteration, currentWinners, prizePerWinner);
            prizeFund -= totalPrizeForLevel; 
            remainingWinners -= currentWinners;
            levelIndex += 1;
            iteration += 1;
        }
    }

    fun getAddWinners() {
        let prize: Int = self.addPrize;
        let remainingPrize: Int = prize;
        let price: Int = self.prizeFund / (self.ticketsWin * self.winningProbability);

        while (remainingPrize / 3 > price) {                             
            prize = (remainingPrize * 2) / 3;
            let winTicket: Int = random(1, self.ticketsWin + 1);
            self.setAddWinner(winTicket, prize);
            remainingPrize -= prize;
        }
        let winTicket: Int = random(1, self.ticketsWin + 1);
        self.setAddWinner(winTicket, remainingPrize);
    }

    get fun check_owner(): Address {
        return self.owner;
    }

    get fun index_game(): Int {
        return self.indexGame;
    }

    get fun prize_fund(): Int {
        return self.prizeFund;
    }

    get fun contract_address(): Address {
        return myAddress();
    }

    get fun contract_balance(): Int {
        return myBalance();
    }

    get fun add_prize(): Int {
        return self.addPrize;
    }

    get fun tickets_sold(): Int {
        return self.ticketsSold;
    }

    get fun tickets_win(): Int {
        return self.ticketsWin;
    }

    get fun last_level_index(): Int {
        return self.lastLevelIndex;
    }

    get fun level_index(): Int {
        return self.levelIndex;
    }

    get fun win_probability(): Int {
        return self.winningProbability;
    }

    get fun check_winners_num(level: Int): Int {
        if (level == 1) {
            return self.winnersNum1;
        } else if (level == 2) {
            return self.winnersNum2;
        } else if (level == 3) {
            return self.winnersNum3;
        } else if (level == 4) {
            return self.winnersNum4;
        } else if (level == 5) {
            return self.winnersNum5;
        } else if (level == 6) {
            return self.winnersNum6;
        } else if (level == 7) {
            return self.winnersNum7;
        } else if (level == 8) {
            return self.winnersNum8;
        } else if (level == 9) {
            return self.winnersNum9;
        } else if (level == 10) {
            return self.winnersNum10;
        } else if (level == 11) {
            return self.winnersNum11;
        } else if (level == 12) {
            return self.winnersNum12;
        } else if (level == 13) {
            return self.winnersNum13;
        } else if (level == 14) {
            return self.winnersNum14;
        } else if (level == 15) {
            return self.winnersNum15;
        } else if (level == 16) {
            return self.winnersNum16;
        } else {
            return -1;
        }
    }

    get fun check_winners_amount(level: Int): Int {
        if (level == 1) {
            return self.winnersAmount1;
        } else if (level == 2) {
            return self.winnersAmount2;
        } else if (level == 3) {
            return self.winnersAmount3;
        } else if (level == 4) {
            return self.winnersAmount4;
        } else if (level == 5) {
            return self.winnersAmount5;
        } else if (level == 6) {
            return self.winnersAmount6;
        } else if (level == 7) {
            return self.winnersAmount7;
        } else if (level == 8) {
            return self.winnersAmount8;
        } else if (level == 9) {
            return self.winnersAmount9;
        } else if (level == 10) {
            return self.winnersAmount10;
        } else if (level == 11) {
            return self.winnersAmount11;
        } else if (level == 12) {
            return self.winnersAmount12;
        } else if (level == 13) {
            return self.winnersAmount13;
        } else if (level == 14) {
            return self.winnersAmount14;
        } else if (level == 15) {
            return self.winnersAmount15;
        } else if (level == 16) {
            return self.winnersAmount16;
        } else {
            return -1;
        }
    }

    get fun add_Level_ticket(level: Int): Int {
        if (level == 1) { return self.addWinnersNum1; }
        else if (level == 2) { return self.addWinnersNum2; }
        else if (level == 3) { return self.addWinnersNum3; }
        else if (level == 4) { return self.addWinnersNum4; }
        else if (level == 5) { return self.addWinnersNum5; }
        else if (level == 6) { return self.addWinnersNum6; }
        else if (level == 7) { return self.addWinnersNum7; }
        else if (level == 8) { return self.addWinnersNum8; }
        else if (level == 9) { return self.addWinnersNum9; }
        else if (level == 10) { return self.addWinnersNum10; }
        return -1; 
    }

    get fun add_level_amount(level: Int): Int {
        if (level == 1) { return self.addWinnersAmount1; }
        else if (level == 2) { return self.addWinnersAmount2; }
        else if (level == 3) { return self.addWinnersAmount3; }
        else if (level == 4) { return self.addWinnersAmount4; }
        else if (level == 5) { return self.addWinnersAmount5; }
        else if (level == 6) { return self.addWinnersAmount6; }
        else if (level == 7) { return self.addWinnersAmount7; }
        else if (level == 8) { return self.addWinnersAmount8; }
        else if (level == 9) { return self.addWinnersAmount9; }
        else if (level == 10) { return self.addWinnersAmount10; }
        return -1; 
    }

    get fun total_tickets(): Int {
        return self.totalTickets;
    }

    get fun all_winners(): Int {
        return self.allWinners;
    }

    get fun winners_count(): Int {
        return self.winnersCount;
    }

    get fun current_level(): Int {
        return self.currentLevel;
    }
}