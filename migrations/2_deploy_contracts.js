var Poseidon = artifacts.require("./Poseidon.sol");

module.exports = function(deployer) {
  deployer.deploy(Poseidon)
    .then(() => Poseidon.deployed())
    .then(poseidon => {
      poseidon.setPoseidonAddress(process.env.ADMIN);
      poseidon.setTrxPrice(1);
      poseidon.transferOracle(process.env.ADMIN);
    });
};
