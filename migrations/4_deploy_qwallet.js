const web3 = require('web3');
const QWalletCompliance = artifacts.require("./QWalletCompliance.sol");
const QWallet = artifacts.require("./QWallet.sol");
const initialQQQFee = web3.utils.toWei('100', 'ether');  // 100 QQQ

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
