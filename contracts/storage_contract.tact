// SPDX-License-Identifier: UNLICENSED
// All rights reserved.

// This source code is provided for reference purposes only.
// You may not copy, reproduce, distribute, modify, deploy, or otherwise use this code in whole or in part without explicit written permission from the author.

// (c) 2025 https://proofofcapital.org/


import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages";
import "./round_contract";

const ONE_TICKET_GAS_USED: Int = 20_000;

contract StorageContract with Ownable {
    owner: Address;
    participant: Address;
    winTickets: map<Int as uint16, Int as uint16>; // можно хранить адрес раунда + количество выигрышных билетов либо сделать функцию, которая будет генерить адреса раундов и сверять, что типа адрес отправителя правильный
    fullWin: Int as coins;
    mapLen: Int as uint16;
    transactionsNum: Int as uint8;
    realTransactionNum: Int as uint8 = 0;

    init(owner: Address, participant: Address) {
        self.owner = owner;
        self.participant = participant;
        self.winTickets = emptyMap();
        self.fullWin = 0;
        self.mapLen = 0;

        self.transactionsNum = 0;
    }

    receive("get balance") {
        require(sender() == self.participant, "Access only for participant");
        let value: Int = myBalance() - COMMISSION;
        if (value > 0) {
            send(SendParameters{
                to: sender(),
                value: value,
            });
        }
    }

    receive("emergency withdrawal") {
        try {
            require(self.fullWin > 0, "You have no jettons");
            require(context().value >= COMMISSION * 2, "Not enough TONs to cover commission");
            let value: Int = COMMISSION * 2;
            send(SendParameters{
                to: self.owner,
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
            send(SendParameters{
                to: self.participant,
                value: COMMISSION,
                mode: SendPayFwdFeesSeparately,
                body: "Not enough TONs to cover commission.".asComment(),
            });
        }
    }

    receive(msg: Winners) { 
        self.requireOwner(); 
        let tickets: Int = self.winTickets.exists(msg.indexGame) ? self.winTickets.get(msg.indexGame)!! : 0;
        self.mapLen += self.winTickets.exists(msg.indexGame) ? 0 : 1;
        self.winTickets.set(msg.indexGame, tickets + msg.winTickets);
        if (myBalance() > COMMISSION) {
            let value: Int = myBalance() - COMMISSION;
            send(SendParameters{
                to: self.participant,
                value: value,
            });
        }
    }

    receive("get full win") { 
        try {
            self.requireOwner();
            require(self.winTickets != emptyMap(), "You have no tickets");
            let commission: Int = self.calculateTotalCommission();
            require(context().value >= commission + COMMISSION * 2, "Not enough TONs to cover commission");
            foreach (key, value in self.winTickets) {
                if (value > 0) {
                    self.sendMsgRound(key, value);
                    self.realTransactionNum += 1;
                }
            }        
        } catch (_) {
            let value: Int = context().value - COMMISSION;
            send(SendParameters{
                to: self.participant,
                value: value,
                mode: SendPayFwdFeesSeparately,
                body: "Not enough TONs to cover commission or you have no tickets.".asComment(),
            });
        }
    }

    receive(msg: SendWinForFull) {
        self.fullWin += msg.amount;
        self.transactionsNum += 1;
        self.winTickets.del(msg.index);
        if (self.transactionsNum == self.realTransactionNum) {
            let value: Int = COMMISSION * 2;
            if (myBalance() > value) {
                send(SendParameters{
                    to: self.owner,
                    value: value,
                    mode: SendPayFwdFeesSeparately,
                    body: FullWin {
                        amount: self.fullWin,
                        participant: self.participant
                    }.toCell(),
                });
                self.winTickets = emptyMap();
                self.mapLen = 0;
                self.fullWin = 0;
            }
        }
        if (self.transactionsNum == self.realTransactionNum) {
            self.transactionsNum = 0;
            self.realTransactionNum = 0;
        }
    }

    fun sendMsgRound(index: Int, tickets: Int, ) {
        let init: StateInit = initOf RoundContract(self.owner, index);
        let value: Int = self.calculateCommission(tickets);

        send(SendParameters{
            to: contractAddress(init),
            value: value,
            body: TicketsForFullWin {
                tickets: tickets,
            }.toCell(),
        });
    }

    fun calculateTotalCommission(): Int {
        let total: Int = 0;
        foreach (key, value in self.winTickets) {
            if (value > 0) {
                total += (value * ONE_TICKET_GAS_USED * ton("0.01")) / ONE_TICKET_GAS_USED;
            }
        }
        total += COMMISSION;
        return total;
    }

    fun calculateCommission(tickets: Int): Int {
        let total: Int = 0;
        total += (tickets * ONE_TICKET_GAS_USED * ton("0.01")) / ONE_TICKET_GAS_USED;
        total += COMMISSION * 2;
        return total;
    }

    get fun full_win(): Int {
        return self.fullWin / NANO_COINS_VALUES;
    }

    get fun check_owner(): Address {
        return self.owner;
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

    get fun transactions_num(): Int {
        return self.transactionsNum;
    }

    get fun real_transactions_num(): Int {
        return self.realTransactionNum;
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
        return self.calculateCommission(tickets);
    }
}