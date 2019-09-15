const QWalletCompliance = artifacts.require("./QWalletCompliance.sol");

contract('QWalletCompliance', async accounts => {
  it('Should canTansfer return true', async () => {
    let instance = await QWalletCompliance.deployed();
    let canTransfer = await instance.canTransfer.call(accounts[0], accounts[0], accounts[1], 1000000);
    assert.equal(canTransfer, true);
  });

  it('Should canTansfer return false when isETHSent is true', async () => {
    let instance = await QWalletCompliance.deployed();
    await instance.banAddress(accounts[1]);
    let canTransfer = await instance.canTransfer.call(accounts[0], accounts[0], accounts[1], 1000000);
    assert.equal(canTransfer, false);
  });
});