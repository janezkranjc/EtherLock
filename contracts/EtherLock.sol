pragma solidity ^0.4.0;

contract EtherLock {

    // Keep track of the original contract owner
    address owner;
    uint unlockTime;
    bool locked;

    event LogDeposit(address addr, uint amount);
    event LogWithdraw(address addr, uint amount);
    event LogUnlockTime(uint unlockTime);
    event LogContractCreated(address owner);
    event LogWithdrawAttempt(string message, address owner, address sender);
    event LogCheckTime(uint currentTime, uint unlockTime);

    // Constructor
    function EtherLock() {
        // Who owns this contract?
        owner = msg.sender;
        locked = true;
        LogContractCreated(owner);
    }

    function deposit() payable {
        LogDeposit(msg.sender, msg.value);
    }

    function withdraw() {
      LogWithdrawAttempt("Withdraw Attempt", owner, msg.sender);
        if (msg.sender == owner && !isLocked()) {
            uint amount = this.balance;
            bool success = owner.send(this.balance);
            if (success) {
                LogWithdraw(owner, amount);
            }
        } else if (msg.sender != owner) {
            LogWithdrawAttempt("Failed Withdraw, wrong sender", owner, msg.sender);
        } else if (isLocked()) {
            LogWithdrawAttempt("Failed Withdraw, funds locked", owner, msg.sender);
        }
    }

    function getAmount() constant returns(uint) {
        return this.balance;
    }

    function isLocked() constant returns(bool) {
        LogCheckTime(now, unlockTime);
        if (now < unlockTime) {
          locked = true;
        } else {
          locked = false;
        }
        return locked;
    }

    function setTime() {
        unlockTime = now + 15 seconds;
        LogUnlockTime(unlockTime);
    }

    function getTime() constant returns(uint256) {
        return unlockTime;
    }
}