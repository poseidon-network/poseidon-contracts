const web3 = require('web3');
const QWallet = artifacts.require("./QWallet.sol");

contract('QWallet', async accounts => {
  let instance
  before(async () => {
    instance = await QWallet.deployed();
    instance.sendTransaction({ to: QWallet.address, from: accounts[1], value: web3.utils.toWei('0.01', 'ether') })
  });


  it('Should isETHTransfer default be false', async () => {
    const isETHTransfer = await instance.isETHTransfer.call(accounts[1]);
    assert.equal(isETHTransfer, false);
  });

  it('Should only allow transferETH once', async () => {
    let error;
    await instance.transferETH.sendTransaction(accounts[1], '1');
    const isETHTransfer = await instance.isETHTransfer.call(accounts[1]);
    
    try {
      await instance.transferETH.sendTransaction(accounts[1], '1');
    } catch (_error) {
      error = _error;
    }
    assert.equal(isETHTransfer, true);
    assert.notEqual(error, undefined, 'Error must be thrown');
  });
});