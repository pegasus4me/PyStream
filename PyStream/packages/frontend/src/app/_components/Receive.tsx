"use client";

import { useCallback, useEffect, useState } from "react";
import { StreamWithHash } from "../new/manage/page";
import { useWriteContract } from "wagmi";
import { useReadContract } from "wagmi";
import { MdExpandMore } from "react-icons/md";
import { ContractAbi } from "@/config/ABI/contractABI";
import { CONTRACT_ADDRESS } from "@/config/constants";
import UseAnimations from "react-useanimations";
import activity from "react-useanimations/lib/activity";
import { IoRefresh } from "react-icons/io5";
import { Button } from "@/components/ui/button";
import { PYUSD_DECIMALS } from "./StreamingPaymentCard";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Hex } from "viem";
import { FaLongArrowAltRight } from "react-icons/fa"
import { Audio } from "./Stream";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { getStreamStatus } from "@/lib";

const REFRESH_INTERVAL = 1000; // Update every second
export const ADDRESS_ZERO = "0x0000000000000000000000000000000000000000" as Hex;

export function Receive({
  amount,
  duration,
  recipient,
  streamer,
  hash,
  startingTimestamp,
}: Partial<StreamWithHash>) {
  const status = getStreamStatus(Number(startingTimestamp), Number(duration));
  const { writeContract } = useWriteContract();
  const [streamRate, setStreamRate] = useState<number>(0);
  const [currentValue, setCurrentValue] = useState(0);
  const [more, setMore] = useState(false);

  // Calculate stream rate once when component mounts

  const amountStreamedSoFar = useReadContract({
    abi: ContractAbi,
    address: CONTRACT_ADDRESS,
    functionName: "getAmountToCollectFromStreamAndFeeToPay",
    args: [hash as Hex],
    query: {
      refetchInterval: 1000, // Refetch every second
    },
  });

  // ********************HOOKS CONFIG**************************
  const [vault, setVault] = useState<Hex>(ADDRESS_ZERO);
  const [
    callBeforeFundsCollected, 
    setcallBeforeFundsCollected
  ] = useState(false);
  const [callAfterFundsCollected, setcallAfterFundsCollected] = useState(false);
  const addRecipientVault = () => {
    writeContract({
      abi: ContractAbi,
      address: CONTRACT_ADDRESS,
      functionName: "setVaultForStream",
      args: [hash as Hex, vault],
    });
  };
  const setHookConfig = () => {
    const HookData = {
      callAfterStreamCreated: false,
      callBeforeFundsCollected: callBeforeFundsCollected,
      callAfterFundsCollected: callAfterFundsCollected,
      callBeforeStreamUpdated: false,
      callAfterStreamUpdated: false,
      callBeforeStreamClosed: false,
      callAfterStreamClosed: false,
      callBeforeStreamPaused: false,
      callAfterStreamPaused: false,
      callBeforeStreamUnPaused: false,
      callAfterStreamUnPaused: false,
    };
    writeContract({
      abi: ContractAbi,
      address: CONTRACT_ADDRESS,
      functionName: "setHookConfigForStream",
      args: [hash as Hex, HookData],
    });
  };

  useEffect(() => {
    if (amount && duration) {
      const ratePerSecond =
        Number(amount) / 10 ** PYUSD_DECIMALS / Number(duration);
      setStreamRate(ratePerSecond);
      setCurrentValue(Number(amount) / 10 ** PYUSD_DECIMALS);
    }
  }, [amount, duration]);
  // Update current value periodically

  const updateCurrentValue = useCallback(() => {
    if (!startingTimestamp || !amount) return;

    const now = Math.floor(Date.now() / 1000);
    const start = Number(startingTimestamp);
    const total = Number(amount) / 10 ** PYUSD_DECIMALS;
    const elapsed = now - start;

    // Check if stream has finished
    if (duration && elapsed >= Number(duration)) {
      setCurrentValue(0);
      return;
    }

    // Calculate remaining amount
    const streamed = streamRate * elapsed;
    const remaining = total - streamed;
    setCurrentValue(Math.max(0, remaining));
  }, [startingTimestamp, amount, duration, streamRate]);

  useEffect(() => {
    // Initial update
    updateCurrentValue();

    // Set up interval for continuous updates
    const intervalId = setInterval(updateCurrentValue, REFRESH_INTERVAL);

    return () => clearInterval(intervalId);
  }, [updateCurrentValue]);

  // Format the current value for display
  const format = currentValue;
  const formattedStreamRate = streamRate;
  const formattedValue = format.toFixed(6);
  const amountClamaible =
    (Number(amountStreamedSoFar.data?.[0]) +
      Number(amountStreamedSoFar.data?.[1])) /
    10 ** PYUSD_DECIMALS;
  const formattedValueClamaible = amountClamaible.toFixed(6)

  console.log('status', hash)
  return (
    <div className="border mt-4 p-2 bg-paypalBlue/5">
      <div className="flex items-center gap-2 justify-between">
        <div className="flex items-center gap-4">
          <h1 className="font-semibold text-paypalMidBlue">
            {status.isStarted && !status.isFinished
              ? "Live stream"
              : status.isFinished
              ? "Stream finished"
              : `stream starting in ${status.timeUntilStart}`}
          </h1>
          <Audio started={status.isFinished} />
        </div>
        <div className="flex items-center gap-2">
          <small className="font-medium text-paypalBlue">view more</small>
          <MdExpandMore onClick={() => setMore(!more)} />
        </div>
      </div>
      <div className="flex items-center gap-10 p-2 justify-start">
        <div className="flex flex-col p-3">
          <p className="font-medium text-paypalMidBlue text-2xl">
          {status.isFinished ? Number(amount) / 10 ** PYUSD_DECIMALS : status.timeUntilStart !== 0 ? 'starting soon' : formattedValue} <span className="italic">{status.timeUntilStart === 0 && 'PYUSD' }</span>
          </p>
          <h3 className="text-paypalBlue">
            from{" "}
            <span className="text-sm font-semibold text-PayPalCerulean">
              {streamer?.slice(0, 5) + "..." + streamer?.slice(38, 42)}
            </span>
          </h3>
        </div>
        {status.isFinished ? <FaLongArrowAltRight /> : status.timeUntilStart !== 0 ? '' : <UseAnimations animation={activity} size={40} color="#009cde" />}
        <div>
        <h3 className="text-paypalBlue">
          to{" "}
          <span className="text-sm font-semibold text-PayPalCerulean">
            {recipient?.slice(0, 5) + "..." + recipient?.slice(38, 42)} (you)
          </span>
        </h3>
        </div>
      </div>
      {more && (
        <div className="mt-4 p-4 bg-gray-50 rounded">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-sm text-gray-500">Stream Rate</p>
              <p className="font-medium">
                {formattedStreamRate.toFixed(6)} PYUSD/second
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Total Duration</p>
              <p className="font-medium">
                {(Number(duration) / (60 * 60)).toFixed(2)} hours
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-500">Start Time</p>
              <p className="font-medium">
                {new Date(Number(startingTimestamp) * 1000).toLocaleString()}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-500">PYUSD Clamaible so far</p>
              <div className="flex items-center gap-3">
                <p className="font-medium">
                  {formattedValueClamaible} /{" "}
                  <span className="text-PayPalCerulean">
                    {Number(amount) / 10 ** PYUSD_DECIMALS} PYUSD
                  </span>
                </p>
                <IoRefresh
                  onClick={() => amountStreamedSoFar}
                  className="cursor-pointer"
                />
              </div>
              <div className="mt-4">
                <Button
                  className="border px-4 py-3 rounded-lg bg-paypalMidBlue text-white hover:bg-paypalBlue hover:transition-all"
                  onClick={() => {
                    writeContract({
                      abi: ContractAbi,
                      address: CONTRACT_ADDRESS,
                      functionName: "collectFundsFromStream",
                      args: [hash as Hex],
                    });
                  }}
                >
                  Collect PYUSD
                </Button>
              </div>
            </div>
            <div>
              <p className="text-sm text-gray-500">End Time</p>
              <p className="font-medium">
                {new Date(
                  Number(startingTimestamp) * 1000 + Number(duration) * 1000
                ).toLocaleString()}
              </p>
            </div>
          </div>
          <Dialog>
            <DialogTrigger className="mt-5 border px-4 py-2 rounded-lg bg-PayPalCerulean text-white hover:bg-paypalBlue hover:transition-all">
              Set vault Address (for hooks)
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Vault Address</DialogTitle>
                <DialogDescription className="mb-5">
                  Add a Recipient Vault Address
                </DialogDescription>
                <Input
                  placeholder={"vault address"}
                  onChange={(e) => setVault(e.target.value as Hex)}
                  className="col-span-3 mt-4"
                />
                <div className="flex items-center justify-between mb-5 p-3">
                  <Label htmlFor="recurring" className="text-left">
                    Before funds are collected
                  </Label>
                  <input
                    type="checkbox"
                    checked={callBeforeFundsCollected}
                    onChange={(e) =>
                      setcallBeforeFundsCollected(e.target.checked)
                    }
                    className=""
                  />
                </div>
                <div className="flex items-center justify-between mt-4 p-3">
                  <Label htmlFor="recurring" className="text-left">
                    After funds are collected
                  </Label>
                  <input
                    type="checkbox"
                    checked={callAfterFundsCollected}
                    onChange={(e) =>
                      setcallAfterFundsCollected(e.target.checked)
                    }
                    className=""
                  />
                </div>

                <Button
                  className="bg-paypalMidBlue mt-5 shadow-none "
                  onClick={addRecipientVault}
                >
                  set
                </Button>
                <Button
                  className="bg-PayPalCerulean mt-5 shadow-none "
                  onClick={setHookConfig}
                >
                  set Hooks
                </Button>
              </DialogHeader>
            </DialogContent>
          </Dialog>
        </div>
      )}
    </div>
  );
}
