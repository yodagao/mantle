// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "../contracts/libraries/resolver/Lib_AddressManager.sol";

contract DeployAddressManager is Script, Test {

    function run() external {

        string memory projectRoot = vm.projectRoot();
        string memory env = vm.envOr("ENV", string("local"));
        string memory addressJsonPath = string(abi.encodePacked(projectRoot, "/deployments/addresses-", env, ".forge.json"));
        string memory deployConfigJsonPath = string(abi.encodePacked(projectRoot, "/.forge-deploy-config.json"));

        string memory deployConfigJson = vm.readFile(deployConfigJsonPath);

        address addressManagerOwner = stdJson.readAddress(deployConfigJson, ".addresses.AddressManagerOwner");
        address addressManagerAddr = stdJson.readAddress(deployConfigJson, ".addresses.Lib_AddressManager");
        bool deployAddressManager = stdJson.readBool(deployConfigJson, ".AddressManager.deploy");

        Lib_AddressManager addressManager;

        vm.startBroadcast();

        // mantle
        if(deployAddressManager) {
            addressManager = new Lib_AddressManager();
            addressManagerAddr = address(addressManager);
            bool deployProxy = stdJson.readBool(deployConfigJson, ".AddressManager.deploy");
        }
        stdJson.write(vm.toString(addressManagerAddr), addressJsonPath, ".Lib_AddressManager");
        stdJson.write(vm.toString(addressManagerAddr), addressJsonPath, ".AddressManager");

        vm.stopBroadcast();
    }
}
