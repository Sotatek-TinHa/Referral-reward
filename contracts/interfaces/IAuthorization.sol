// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthorization {
    function authorize(
        bytes32 _message,
        bytes memory _signature
    ) external;
}