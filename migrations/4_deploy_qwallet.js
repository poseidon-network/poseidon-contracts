const QWalletCompliance = artifacts.require("./QWalletCompliance.sol");
const QWallet = artifacts.require("./QWallet.sol");
const initialQQQFee = '100000000000000000000';  // 100 QQQ

module.exports = function(deployer) {
  deployer.deploy(QWalletCompliance).then(function(){
    return deployer.deploy(
      QWallet,
      process.env.QQQ_ADDRESS,
      initialQQQFee,
      QWalletCompliance.address,
    )
  });
};
