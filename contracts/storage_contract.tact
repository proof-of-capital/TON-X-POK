// SPDX-License-Identifier: UNLICENSED
// All rights reserved.

// This source code is provided for reference purposes only.
// You may not copy, reproduce, distribute, modify, deploy, or otherwise use this code in whole or in part without explicit written permission from the author.

// (c) 2025 https://proofofcapital.org/
import "./messages";
import "./round_contract";

const ONE_TICKET_GAS_USED: Int = 20_000;

contract StorageContract {
    xpok: Address;
    participant: Address;
    winTickets: map<Int as uint16, Int as uint16>; // можно хранить адрес раунда + количество выигрышных билетов либо сделать функцию, которая будет генерить адреса раундов и сверять, что типа адрес отправителя правильный
    fullWin: Int as coins;
    mapLen: Int as uint16;
    lock: Int as uint32 = 0;

    init(xpok: Address, participant: Address) {
        self.xpok = xpok;
        self.participant = participant;
        self.winTickets = emptyMap();
        self.fullWin = 0;
        self.mapLen = 0;
    }

    receive("get balance") {
        require(sender() == self.participant, "Access only for participant");
        nativeReserve(ton("0.05"), ReserveAtMost);
        message(MessageParameters{to: sender(), value: 0, mode: SendRemainingBalance});
    }

    receive(msg: GetWin) {
        throwUnless(401, sender() == self.xpok);
        try {
            //dump(self.fullWin > 0);
            //dump(context().value >= COMMISSION * 2);
            require(self.fullWin > 0, "You have no jettons");
            require(context().value >= COMMISSION * 2, "Not enough TONs to cover commission");
            let value: Int = COMMISSION * 2;
            message(MessageParameters{
                to: self.xpok,
                value: value,
                mode: SendPayFwdFeesSeparately,
                body: FullWin {
                    amount: self.fullWin,
                    participant: self.participant
                }.toCell(),
            });
            self.fullWin = 0;
            self.mapLen = 0;
        } catch (_) {
            message(MessageParameters{
                to: self.participant,
                value: COMMISSION,
                mode: SendPayFwdFeesSeparately,
                body: "Not enough TONs to cover commission.".asComment(),
            });
        }
    }

    receive(msg: Winners) { 
        throwUnless(401, sender() == self.xpok);
        let tickets: Int = self.winTickets.exists(msg.indexGame) ? self.winTickets.get(msg.indexGame)!! : 0;
        self.mapLen += self.winTickets.exists(msg.indexGame) ? 0 : 1;
        self.winTickets.set(msg.indexGame, tickets + msg.winTickets);
        cashback(self.participant);
    }

    receive(msg: GetFullWin) { 
        try {
            throwUnless(401, sender() == self.xpok);
            throwUnless(555, self.lock + 300 < now());
            require(self.winTickets != emptyMap(), "You have no tickets");
            let commission: Int = self.calculateTotalCommission();
            require(context().value >= commission + COMMISSION * 2, "Not enough TONs to cover commission");
            foreach (key, value in self.winTickets) {
                if (value > 0) {
                    message(MessageParameters{
                        to: contractAddress(initOf RoundContract(self.xpok, key)),
                        value: calculateCommission(value),
                        body: TicketsForFullWin {
                            participant:self.participant,
                            tickets: value,
                        }.toCell(),
                    });
                    self.lock = now();
                }
            }        
        } catch (_) {
            let value: Int = context().value - COMMISSION;
            message(MessageParameters{
                to: self.participant,
                value: value,
                mode: SendPayFwdFeesSeparately,
                body: "Not enough TONs to cover commission or you have no tickets.".asComment(),
            });
        }
    }

    receive(msg: SendWinForFull) {
        //отправляется раундом для отправки выигрыша за полный выигрыш        
        let init: StateInit = initOf RoundContract(self.xpok, msg.index);
        throwUnless(401, sender() == contractAddress(init));
        self.fullWin += msg.amount;
        let value: Int = COMMISSION * 2;
        if (myBalance() > value) {
            message(MessageParameters{
                    to: self.xpok,
                    value: value,
                    mode: SendPayFwdFeesSeparately,
                    body: FullWin {
                        amount: self.fullWin,
                        participant: self.participant
                    }.toCell(),
                });
            let _ = self.winTickets.del(msg.index);
            self.mapLen -= 1;
            self.fullWin = 0;
            self.lock = 0;
        }  else{
            self.fullWin -= msg.amount;
        }      
    }

    inline fun calculateTotalCommission(): Int {
        let total: Int = 0;
        foreach (key, value in self.winTickets) {
            if (value > 0) {
                total += (value * ONE_TICKET_GAS_USED * ton("0.01")) / ONE_TICKET_GAS_USED;
            }
        }
        total += COMMISSION;
        return total;
    }

    

    get fun full_win(): Int {
        return self.fullWin / NANO_COINS_VALUES;
    }

    get fun check_owner(): Address {
        return self.xpok;
    }

    get fun check_participant_address(): Address {
        return self.participant;
    }

    get fun win_tickets(indexGame: Int): Int {
        if (self.winTickets.exists(indexGame)) {
            return self.winTickets.get(indexGame)!!;
        } else {
            return 0;
        }
    } 

    get fun map_len(): Int {
        return self.mapLen;
    }

    get fun lock_until(): Int {
        return self.lock;
    }

    get fun calculate_commission_total(): Int {
        let total: Int = 0;
        foreach (key, value in self.winTickets) {
            if (value > 0) {
                total += (value * ONE_TICKET_GAS_USED * ton("0.01")) / ONE_TICKET_GAS_USED;
            }
        }
        total += COMMISSION * 2;
        return total;
    }

    get fun calculate_commission(tickets: Int): Int {
        return calculateCommission(tickets);
    }

    get fun balance(): Int {
        return myBalance();
    }
}

fun calculateCommission(tickets: Int): Int {
    let total: Int = 0;
    total += (tickets * ONE_TICKET_GAS_USED * ton("0.01")) / ONE_TICKET_GAS_USED;
    total += COMMISSION * 2;
    return total;
}