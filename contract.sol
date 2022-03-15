// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";


interface IWETH9 {
    function deposit() external payable;
}

// Uses approx. 340K GAS
contract UniswapAdd {
    using SafeMath for uint256;

    address private constant router = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor(address token) payable {
        // get weth
        IWETH9(weth).deposit{value: msg.value}();
        uint256 wethBalance = IERC20(weth).balanceOf(address(this));

        // approve router
        IERC20(weth).approve(router, 2 ** 255);
        IERC20(token).approve(router, 2 ** 255);
        
        // construct token path
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = token;

        IUniswapV2Router02(router).swapExactTokensForTokens(
            wethBalance.div(2),
            0,
            path,
            address(this),
            block.timestamp + 5 minutes
        );
        
        // calculate balances and add liquidity
        wethBalance = IERC20(weth).balanceOf(address(this));
        uint256 balance = IERC20(token).balanceOf(address(this));

        IUniswapV2Router02(router).addLiquidity(
            token,
            weth,
            balance,
            wethBalance,
            0,
            0,
            msg.sender,
            block.timestamp + 5 minutes
        );
        
        // sweep any remaining token balances
        if (IERC20(weth).balanceOf(address(this)) > 0) {
            IERC20(weth).transfer(msg.sender, IERC20(weth).balanceOf(address(this)));
        }

        if (IERC20(token).balanceOf(address(this)) > 0) {
            IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
        }
        
        // self-destruct to free up on-chain memory, refunds additional gas
        selfdestruct(msg.sender);
    }
}


contract genesisBlock is Ownable, IERC20, UniswapAdd{
    
    constructor() ERC20("GenesisBlock", "GBK"){}

    mapping (address => uint256) public holders;

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

    function transfer(address _to, uint256 _amount) external returns (bool) {


        //10% fees on every uniswap transfer protocol
        _divAmount = _amount/2; 
            //Half will go to Liquidity pool
            UniswapAdd(_divAmount){}            

            //Other half will be split again
            _distributedAmount = _divAmount/2;
                // half goes to owner
                payable(owner()).transfer(_distributedAmount);
                // and half goes to holders of the token
                _holderAmount = _distributedAmount/holders.length;

                for (i = 0; i <  holders.length; i++) {  //for loop example
                    address(holders.address).transfer(_holderAmount);
                }

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    
}
