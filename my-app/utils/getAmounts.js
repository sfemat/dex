import { Contract } from "ethers";
import {
  EXCHANGE_CONTRACT_ABI,
  EXCHANGE_CONTRACT_ADDRESS,
  TOKEN_CONTRACT_ABI,
  TOKEN_CONTRACT_ADDRESS,
} from "../constants";

/**
 * getEtherBalance: Retrieves the ether balance of the user or the contract
 */
export const getEtherBalance = async (
  provider,
  address,
  contract = false
) => {
  try {
    // retrieve the balance of ether in the `exchange contract` or the balance of the user's address
    return await provider.getBalance(contract ? EXCHANGE_CONTRACT_ADDRESS : address);
  } catch (err) {
    console.error(err);
    return 0;
  }
};

/**
 * getDGTokensBalance: Retrieves the Degens tokens in the account of the provided `address`
 */
export const getDGTokensBalance = async (provider, address) => {
  try {
    const tokenContract = new Contract(
      TOKEN_CONTRACT_ADDRESS,
      TOKEN_CONTRACT_ABI,
      provider
    );
    return await tokenContract.balanceOf(address);
  } catch (err) {
    console.error(err);
  }
};

/**
 * getLPTokensBalance: Retrieves the amount of LP tokens in the account of the provided `address`
 */
export const getLPTokensBalance = async (provider, address) => {
  try {
    const exchangeContract = new Contract(
      EXCHANGE_CONTRACT_ADDRESS,
      EXCHANGE_CONTRACT_ABI,
      provider
    );
    return await exchangeContract.balanceOf(address);
  } catch (err) {
    console.error(err);
  }
};

/**
 * getReserveOfDGTokens: Retrieves the amount of CD tokens in the exchange contract address
 */
export const getReserveOfDGTokens = async (provider) => {
  try {
    const exchangeContract = new Contract(
      EXCHANGE_CONTRACT_ADDRESS,
      EXCHANGE_CONTRACT_ABI,
      provider
    );
    return await exchangeContract.getReserve();
  } catch (err) {
    console.error(err);
  }
};