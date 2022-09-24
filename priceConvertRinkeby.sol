// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConversion {

    AggregatorV3Interface internal priceGBPUSD;
    AggregatorV3Interface internal priceUSDETH;

    /**
     * Network: Rinkeby
     * Aggregator: ETH/USD
     * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
     */
    constructor() {
        priceGBPUSD = AggregatorV3Interface(0x7B17A813eEC55515Fb8F49F2ef51502bC54DD40F);
        priceUSDETH = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    }

    /**
     * Returns the latest price
     */
    function getUSDETH() internal view returns (uint256) {
        (
            /*uint80 roundID*/,
            int256 price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceUSDETH.latestRoundData();
        return uint256(price);
    }

    function getGBPUSD() internal view returns (uint256) {
        (
            /*uint80 roundID*/,
            int256 price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceGBPUSD.latestRoundData();
        return uint256(price);
    }

    function getGBPWEI(uint256 _number) external view returns (uint256) {
        uint256 input = _number;
        uint256 priceUSD = getGBPUSD();
        uint256 priceETH = getUSDETH();
        uint256 price = (input*1000000000000000000*priceUSD/priceETH);
        return price;
    }
}