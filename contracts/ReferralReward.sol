// SPDX-License-Identifier: MIT
// ===================================================================
//                                                   ▄▄
//  ▄█▀▀▀█▄█          ██          ▀████▀            ▄██
// ▄██    ▀█          ██            ██               ██
// ▀███▄     ▄██▀██▄██████ ▄█▀██▄   ██      ▄█▀██▄   ██▄████▄  ▄██▀███
//   ▀█████▄██▀   ▀██ ██  ██   ██   ██     ██   ██   ██    ▀██ ██   ▀▀
// ▄     ▀████     ██ ██   ▄█████   ██     ▄▄█████   ██     ██ ▀█████▄
// ██     ████▄   ▄██ ██  ██   ██   ██    ▄██   ██   ██▄   ▄██ █▄   ██
// █▀█████▀  ▀█████▀  ▀████████▀██▄█████████████▀██▄ █▀█████▀  ██████▀
//
// ===================================================================
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/IAuthorization.sol";

error ZeroNumber();
error BalanceInsufficient();
error MaxWithdrawBalanceExceeded(uint256 expected, uint256 actual);
error WithdrawFailed();

contract ReferralReward is Ownable, AccessControl, Pausable, ReentrancyGuard {
  constructor(address _authorization) {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

    AUTHORIZATION_CONTRACT = IAuthorization(_authorization);
  }

  IAuthorization public AUTHORIZATION_CONTRACT;

  struct WithdrawalParams {
    uint256 availableBalance;
    uint256 withdrawAmount;
    uint128 requestId;
    bytes signature;
  }

  event Withdrawal(
    address indexed user,
    uint128 withdrawId,
    uint256 amount
  );

  /**
   * @notice Withdraw
   *
   * @dev External function to withdraw coins to their wallet. Anyone with valid signature can call this function.
   * @param params withdraw parameters
   */
  function withdraw(
    WithdrawalParams calldata params
  ) external nonReentrant whenNotPaused {
    if (params.withdrawAmount == 0) {
      revert ZeroNumber();
    }
    if (params.availableBalance < params.withdrawAmount) {
      revert MaxWithdrawBalanceExceeded(
        params.availableBalance,
        params.withdrawAmount
      );
    }

    // create signature
    bytes32 message = keccak256(
      abi.encodePacked(
        _msgSender(),
        "withdraw",
        params.availableBalance,
        params.withdrawAmount,
        params.requestId
      )
    );
    
    // authorize request
    AUTHORIZATION_CONTRACT.authorize(
      message,
      params.signature
    );

    if (address(this).balance < params.withdrawAmount) {
      revert BalanceInsufficient();
    }
    (bool success, ) = payable(_msgSender()).call{
      value: params.withdrawAmount
    }("");
    if (!success) {
      revert WithdrawFailed();
    }

    emit Withdrawal(
      _msgSender(),
      params.requestId,
      params.withdrawAmount
    );
  }

  function pause() external onlyOwner whenNotPaused {
    _pause();
  }

  function unpause() external onlyOwner whenPaused {
    _unpause();
  }
}
