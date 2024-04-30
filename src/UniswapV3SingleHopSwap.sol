// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// address constant SWAP_ROUTER_02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
// address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
// address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

contract UniswapV3SingleHopSwap {

    address public SWAP_ROUTER_02;
    address public WETH;
    address public DAI;
    address public DAI_WETH_POOL_3000;

    IWETH weth;
    ISwapRouter02 router;
    IERC20 dai;
    I_DAI_WETH_POOL_3000 dai_weth;


    constructor(address _SWAP_ROUTER_02, address _WETH, address _DAI, address _DAI_WETH_POOL_3000) {
        require(_SWAP_ROUTER_02 != address(0), "Router address cannot be zero");
        require(_WETH != address(0), "WETH address cannot be zero");
        require(_DAI != address(0), "DAI address cannot be zero");
        require(_DAI_WETH_POOL_3000 != address(0), "DAI-WETH Pool address cannot be zero");

        
        SWAP_ROUTER_02 = _SWAP_ROUTER_02;
        WETH = _WETH;
        DAI = _DAI;
        DAI_WETH_POOL_3000 = _DAI_WETH_POOL_3000;

        router = ISwapRouter02(_SWAP_ROUTER_02);
        weth = IWETH(_WETH);
        dai = IERC20(_DAI);
        dai_weth = I_DAI_WETH_POOL_3000(_DAI_WETH_POOL_3000);
    }

    function swapExactInputSingleHop(uint256 amountIn, uint256 amountOutMin) external {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02
            .ExactInputSingleParams({
            tokenIn: address(WETH),
            tokenOut: address(DAI),
            fee: 3000,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin,
            sqrtPriceLimitX96: 0
        });

        // Call the swap and check for success
        try router.exactInputSingle(params) returns (uint256 amountOut) {
            require(amountOut >= amountOutMin, "Insufficient output amount");
        } catch {
            revert("Swap failed");
        }   
    }

    function swapExactOutputSingleHop(uint256 amountOut, uint256 amountInMax)
        external
    {
        weth.transferFrom(msg.sender, address(this), amountInMax);
        weth.approve(address(router), amountInMax);

        ISwapRouter02.ExactOutputSingleParams memory params = ISwapRouter02
            .ExactOutputSingleParams({
            tokenIn: WETH,
            tokenOut: DAI,
            fee: 3000,
            recipient: msg.sender,
            amountOut: amountOut,
            amountInMaximum: amountInMax,
            sqrtPriceLimitX96: 0
        });

        uint256 amountIn = router.exactOutputSingle(params);

        if (amountIn < amountInMax) {
            weth.approve(address(router), 0);
            weth.transfer(msg.sender, amountInMax - amountIn);
        }
    }

}
interface ISwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params)
        external
        payable
        returns (uint256 amountIn);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}


interface I_DAI_WETH_POOL_3000 {
  function burn ( int24 tickLower, int24 tickUpper, uint128 amount ) external returns ( uint256 amount0, uint256 amount1 );
  function collect ( address recipient, int24 tickLower, int24 tickUpper, uint128 amount0Requested, uint128 amount1Requested ) external returns ( uint128 amount0, uint128 amount1 );
  function collectProtocol ( address recipient, uint128 amount0Requested, uint128 amount1Requested ) external returns ( uint128 amount0, uint128 amount1 );
  function factory (  ) external view returns ( address );
  function fee (  ) external view returns ( uint24 );
  function feeGrowthGlobal0X128 (  ) external view returns ( uint256 );
  function feeGrowthGlobal1X128 (  ) external view returns ( uint256 );
  function flash ( address recipient, uint256 amount0, uint256 amount1, bytes memory data ) external;
  function increaseObservationCardinalityNext ( uint16 observationCardinalityNext ) external;
  function initialize ( uint160 sqrtPriceX96 ) external;
  function liquidity (  ) external view returns ( uint128 );
  function maxLiquidityPerTick (  ) external view returns ( uint128 );
  function mint ( address recipient, int24 tickLower, int24 tickUpper, uint128 amount, bytes memory data ) external returns ( uint256 amount0, uint256 amount1 );
  function observations ( uint256 ) external view returns ( uint32 blockTimestamp, int56 tickCumulative, uint160 secondsPerLiquidityCumulativeX128, bool initialized );
  function observe ( uint32[] memory secondsAgos ) external view returns ( int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s );
  function positions ( bytes32 ) external view returns ( uint128 liquidity, uint256 feeGrowthInside0LastX128, uint256 feeGrowthInside1LastX128, uint128 tokensOwed0, uint128 tokensOwed1 );
  function protocolFees (  ) external view returns ( uint128 token0, uint128 token1 );
  function setFeeProtocol ( uint8 feeProtocol0, uint8 feeProtocol1 ) external;
  function slot0 (  ) external view returns ( uint160 sqrtPriceX96, int24 tick, uint16 observationIndex, uint16 observationCardinality, uint16 observationCardinalityNext, uint8 feeProtocol, bool unlocked );
  function snapshotCumulativesInside ( int24 tickLower, int24 tickUpper ) external view returns ( int56 tickCumulativeInside, uint160 secondsPerLiquidityInsideX128, uint32 secondsInside );
  function swap ( address recipient, bool zeroForOne, int256 amountSpecified, uint160 sqrtPriceLimitX96, bytes memory data ) external returns ( int256 amount0, int256 amount1 );
  function tickBitmap ( int16 ) external view returns ( uint256 );
  function tickSpacing (  ) external view returns ( int24 );
  function ticks ( int24 ) external view returns ( uint128 liquidityGross, int128 liquidityNet, uint256 feeGrowthOutside0X128, uint256 feeGrowthOutside1X128, int56 tickCumulativeOutside, uint160 secondsPerLiquidityOutsideX128, uint32 secondsOutside, bool initialized );
  function token0 (  ) external view returns ( address );
  function token1 (  ) external view returns ( address );
}
