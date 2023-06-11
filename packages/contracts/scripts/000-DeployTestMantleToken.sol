// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "forge-std/StdJson.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "../contracts/L1/local/TestMantleToken.sol";
import "../contracts/chugsplash/TransparentUpgradeableProxy.sol";

contract DeployAddressManager is Script, Test {

    function run() external {

        string memory projectRoot = vm.projectRoot();
        string memory env = vm.envOr("ENV", string("local"));
        string memory addressJsonPath = string(abi.encodePacked(projectRoot, "/deployments/addresses-", env, ".forge.json"));
        string memory deployConfigJsonPath = string(abi.encodePacked(projectRoot, "/.forge-deploy-config.json"));
        uint256 totalSupply = 10^28;

        string memory deployConfigJson = vm.readFile(deployConfigJsonPath);

        address addressManagerOwner = stdJson.readAddress(deployConfigJson, ".addresses.AddressManagerOwner");
        address l1MantleTokenAddr = stdJson.readAddress(deployConfigJson, ".addresses.L1MantleToken");
        address l1MantleTokenProxyAddr = stdJson.readAddress(deployConfigJson, ".addresses.Proxy__L1MantleToken");
        bool deployL1MantleToken = stdJson.readBool(deployConfigJson, ".L1MantleToken.deploy");

        L1MantleToken l1MantleToken;

        vm.startBroadcast();

        if(deployL1MantleToken) {
            l1MantleToken = new L1MantleToken();
            l1MantleTokenAddr = address(l1MantleToken);

            // if deploy proxy
            bool deployProxy = stdJson.readBool(deployConfigJson, ".L1MantleToken.deployProxy");
            if(deployProxy) {
                TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
                    l1MantleTokenAddr,
                    addressManagerOwner,
                    abi.encodeWithSelector(l1MantleToken.initialize.selector, totalSupply, addressManagerOwner)
                );
                string memory addr = vm.toString(address(proxy));
                stdJson.write(addr, addressJsonPath, ".Proxy__L1MantleToken");
                l1MantleTokenProxyAddr = address(proxy);
            }
        }

        stdJson.write(vm.toString(l1MantleTokenAddr), addressJsonPath, ".L1MantleToken");
        stdJson.write(vm.toString(l1MantleTokenProxyAddr), addressJsonPath, ".Proxy__L1MantleToken");

        vm.stopBroadcast();
    }
}
