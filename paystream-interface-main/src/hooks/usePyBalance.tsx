import { useMemo } from "react"
import { erc20Abi } from "viem"
import { useReadContract } from "wagmi"
import { Hex } from "viem"
import { PYUSD } from "@/config/constants"
export default function usePyUSD(address : Hex) {
    
    const balance = useReadContract({
        abi :erc20Abi,
        address: PYUSD as Hex,
        functionName : 'balanceOf',
        args : [address]
    })
    return useMemo(() => balance.data,[balance.data])
    
}