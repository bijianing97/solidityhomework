// SPDX-License-Identifier: MIT

pragma solidity 0.6.2;

// Remix
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.2.0/contracts/math/SafeMath.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.2.0/contracts/token/ERC20/SafeERC20.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.2.0/contracts/utils/ReentrancyGuard.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.2.0/contracts/access/Ownable.sol";

// Hardhat
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyUniswap is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // tokenA的地址
    IERC20 public tokenA;
    // tokenB的地址
    IERC20 public tokenB;

    // x个A可以换 x * priceAToB 个B
    // x个B可以换 x / priceAToB 个A
    uint256 public priceAToB;

    // 记录是否以及初始化
    bool public initialized = false;

    // 初始化函数, 只有owner可以调用. 设置两种代币的地址, 初始化金额, 价格等参数
    function initialize(address _tokenA, uint256 tokenAInitAmount, address _tokenB, uint256 tokenBInitAmount, uint256 _priceAToB) external onlyOwner {
        require(initialized == false, "invalid initialize");
        require(_tokenA != address(0), "invalid _tokenA");
        require(_tokenB != address(0), "invalid _tokenB");
        require(_priceAToB > 0, "invalid _priceAToB");
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        priceAToB = _priceAToB;
        tokenA.safeTransferFrom(msg.sender, address(this), tokenAInitAmount);
        tokenB.safeTransferFrom(msg.sender, address(this), tokenBInitAmount);
        initialized = true;
    }

    // 用A换B
    function swapAToB(uint256 amount) external nonReentrant {
        uint256 amountOut = estimateAToB(amount);
        tokenA.safeTransferFrom(msg.sender, address(this), amount);
        tokenB.safeTransfer(msg.sender, amountOut);
    }

    // 用B换A
    function swapBToA(uint256 amount) external nonReentrant {
        uint256 amountOut = estimateBToA(amount);
        require(amountOut > 0, "invalid amountOut");
        tokenB.safeTransferFrom(msg.sender, address(this), amount);
        tokenA.safeTransfer(msg.sender, amountOut);
    }

    // 预估可以用A换出多少个B
    function estimateAToB(uint256 amount) public view returns(uint256 amountOut) {
        require(initialized, "invalid initialize");
        require(amount > 0, "invalid amount");
        amountOut = amount.mul(priceAToB);
    }

    // 预估可以用B换出多少个A
    function estimateBToA(uint256 amount) public view returns(uint256 amountOut) {
        require(initialized, "invalid initialize");
        require(amount > 0, "invalid amount");
        amountOut = amount.div(priceAToB);
    }
}
