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

error InvalidSignatureLength();

contract Authorization {
    function authorize(address signer, bytes32 _messageHash, bytes memory _signature) external pure returns(bool) {
        bytes32 signedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));

        (bytes32 r, bytes32 s, uint8 v) = _splitSig(_signature);
        return ecrecover(signedMessageHash, v, r, s) == signer;

    }

    function _splitSig(bytes memory sig) internal pure returns(bytes32 r, bytes32 s, uint8 v) {
        if (sig.length != 65) {
            revert InvalidSignatureLength();
        }

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }
}