const D21 = artifacts.require("D21");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(D21, {from: accounts[0]});
};
