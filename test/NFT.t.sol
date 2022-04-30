// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/test.sol";
import "forge-std/Vm.sol";
import "../NFT.sol";

contract NFTTest is DSTest {
    using stdStorage for StdStorage;

    Vm private vm = Vm(HEVM_ADDRESS);
    NFT private nft;
    StdStorage private stdstore;

    // runs before every 
    function setUp() public {
        // Deploy our contract
        nft = new NFT("NFT_Tutorial", "TUT", "<base-uri-here>");
    }

    function testFailNoMintPricePaid() public {
        nft.mintTo(address(1));
    }

    function testMintPricePaid() public {
        nft.mintTo{value: 0.01 ether}(address(1));
    }

    function testFailMaxSupplyreached() public {
        uint256 slot = stdstore.target(address(nft).sig("currentTokenId()")).find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(10000));
        vm.store(address(nft), loc, mockedCurrentTokenId);
        nft.mintTo{value: 0.01 ether}(address(1));
    }

    function testFailMintToZeroAddress() public {
        nft.mintTo{value: 0.01 ether}(address(0));
    }

    function testNewMintOwnerRegistered() public {
        nft.mintTo{value: 0.01 ether}(address(1));
        uint256 slotOfNewOwner = stdstore
            .target(address(nft))
            .sig(nft.ownerOf.selector)
            .with_key(1)
            .find();

        uint160 ownerOfTokenIdOne = uint160(uint256((vm.load(address(nft),bytes32(abi.encode(slotOfNewOwner))))));
        assertEq(address(ownerOfTokenIdOne), address(1));
    }

    function testBalanceIncrement() public {

    }
}
