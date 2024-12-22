import { Hex } from "viem";
import { useMemo } from "react";
import { useWriteContract } from "wagmi";
import { erc20Abi } from "viem";
import { PYUSD } from "@/config/constants";
export function useApprouve(spender: Hex, amount: bigint ) {
    const {writeContract} = useWriteContract()
    
    const approuve = writeContract({
        abi : erc20Abi ,
        functionName : 'approve', 
        address : PYUSD ,
        args : [
            spender,
            amount
        ]   
    })
    return useMemo(() =>  approuve ,[approuve])
}