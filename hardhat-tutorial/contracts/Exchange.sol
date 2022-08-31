// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {

    address public degensTokenAddress;

    constructor(address _Degenstoken) ERC20("Degens LP Token", "DGLP") {
        require(_Degenstoken != address(0), "Token address passed is a null address");
        degensTokenAddress = _Degenstoken;
    }

    /**
    * @dev Returns the amount of `Degens Tokens` held by the contract
    */
    function getReserve() public view returns (uint) {
        return ERC20(degensTokenAddress).balanceOf(address(this));
    }

    /**
    * @dev Adds liquidity to the exchange.
    */
    function addLiquidity(uint _amount) public payable returns (uint) {
        uint liquidity;
        uint ethBalance = address(this).balance;
        uint degensTokenReserve = getReserve();
        ERC20 degensToken = ERC20(degensTokenAddress);

        if(degensTokenReserve == 0) {
            degensToken.transferFrom(msg.sender, address(this), _amount);
            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        } else {
            uint ethReserve =  ethBalance - msg.value;
            uint degensTokenAmount = (msg.value * degensTokenReserve)/(ethReserve);
            require(_amount >= degensTokenAmount, "Amount of tokens sent is less than the minimum tokens required");

            degensToken.transferFrom(msg.sender, address(this), degensTokenAmount);

            liquidity = (totalSupply() * msg.value)/ ethReserve;
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    /** 
    * @dev Returns the amount Eth/degens tokens that would be returned to the user
    * in the swap
    */
    function removeLiquidity(uint _amount) public returns (uint , uint) {
        require(_amount > 0, "_amount should be greater than zero");
        uint ethReserve = address(this).balance;
        uint _totalSupply = totalSupply();
        uint ethAmount = (ethReserve * _amount)/ _totalSupply;
        uint degensTokenAmount = (getReserve() * _amount)/ _totalSupply;

        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        ERC20(degensTokenAddress).transfer(msg.sender, degensTokenAmount);
        return (ethAmount, degensTokenAmount);
    }

    /**
    * @dev Returns the amount Eth/degens tokens that would be returned to the user in the swap
    */
    function getAmountOfTokens(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");

        uint256 inputAmountWithFee = inputAmount * 99;
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;
        return numerator / denominator;
    }

    /** 
    * @dev Swaps Eth for degens Tokens
    */
    function ethToCryptoDevToken(uint _minTokens) public payable {
        uint256 tokenReserve = getReserve();

        uint256 tokensBought = getAmountOfTokens(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );

        require(tokensBought >= _minTokens, "insufficient output amount");
        ERC20(degensTokenAddress).transfer(msg.sender, tokensBought);
    }

    /** 
    * @dev Swaps degens Tokens for Eth
    */
    function cryptoDevTokenToEth(uint _tokensSold, uint _minEth) public {
        uint256 tokenReserve = getReserve();

        uint256 ethBought = getAmountOfTokens(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );
        require(ethBought >= _minEth, "insufficient output amount");
        ERC20(degensTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _tokensSold
        );
        payable(msg.sender).transfer(ethBought);
    }
}