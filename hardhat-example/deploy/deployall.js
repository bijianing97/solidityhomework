const settings = require("./deploySettings");

module.exports = async function ({ deployments, getNamedAccounts }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const uniswap = await deploy("MyUniswap", {
    from: deployer,
    log: true,
    deterministicDeployment: false,
  });
  console.log("MyUniswap deployed on:", uniswap.address);
  const usdt = await deploy("usdt", {
    from: deployer,
    log: true,
    deterministicDeployment: false,
    args: [settings.name1, settings.symbol1, settings.decimals],
  });
  console.log("USDT deployed on:", usdt.address);
  const liecoin = await deploy("mytoken", {
    from: deployer,
    log: true,
    deterministicDeployment: false,
    args: [
      settings.name2,
      settings.symbol2,
      settings.decimals,
      uniswap.address,
    ],
  });
  console.log("liecoin deployed on:", liecoin.address);
};
