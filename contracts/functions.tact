fun sendMsgWithReserve(to: Address, msgValue: Int, msg: Cell) {
    let toLeaveOnBalance = (myBalance() - msgValue) + myStorageDue();
    nativeReserve(toLeaveOnBalance, ReserveAtMost);
    message(MessageParameters{to:to, value:0, mode: SendRemainingBalance | SendIgnoreErrors, body: msg});
}

fun sendTon(to: Address, value: Int, comment: String) {
    message(MessageParameters{
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

        message(MessageParameters{
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

inline fun sendComment(recipient: Address, comment: String) {
    message(MessageParameters{
        to: recipient,
        body: comment.asComment(),
        value: COMMISSION,
        bounce: false
    });
}