pragma solidity ^0.8.0;

contract AI {
    function getPrediction() public view returns (string memory) {
        bytes memory data = abi.encodeWithSignature("getPrediction()");
        address endpoint = address(0x1234567890); // replace with the address of the external API
        bytes32 response =  address(endpoint).call(data);
        return bytes32ToString(response);
    }

    function bytes32ToString(bytes32 x) private pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        for (uint i = 0; i < 32; i++) {
            bytesString[i] = byte(bytes32(uint(x) * 2 ** (8 * i)));
        }
        return string(bytesString);
    }
}
