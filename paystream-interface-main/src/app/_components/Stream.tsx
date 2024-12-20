"use client";
import { CONTRACT_ADDRESS, IstreamData, PYUSD } from "@/config/constants";
import { MdExpandMore } from "react-icons/md";
import { useWriteContract } from "wagmi";
import UseAnimations from "react-useanimations";
import activity from "react-useanimations/lib/activity";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { ContractAbi } from "@/config/ABI/contractABI";
import { useCallback, useEffect, useState } from "react";
import { getStreamStatus } from "@/lib";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { DateTimePicker } from "./TimePicker";
import { erc20Abi, Hex } from "viem";
import { PYUSD_DECIMALS } from "./StreamingPaymentCard";
import { ADDRESS_ZERO } from "./Receive";

const REFRESH_INTERVAL = 1000; // Update every second

export const Audio = ({ started }: { started: boolean }) => {
  return (
    <>
      <span className="relative flex h-2 w-2 mr-2">
        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75" />
        <span
          className={`relative inline-flex rounded-full h-2 w-2 ${
            started ? "bg-red-500" : "bg-green-500"
          }`}
        />
      </span>
    </>
  );
};

interface StreamWithHash extends IstreamData {
  hash: Hex;
}
export default function Stream({
  amount,
  duration,
  recipient,
  streamer,
  hash,
  startingTimestamp,
}: Partial<StreamWithHash>) {
  const { writeContract } = useWriteContract();
  const [streamRate, setStreamRate] = useState<number>(0);
  const [currentValue, setCurrentValue] = useState(0);
  const [more, setMore] = useState(false);
  const status = getStreamStatus(Number(startingTimestamp), Number(duration));
  // updates
  const [newAmount, setNewAmount] = useState("");
  const [newStartingDate, seNewStartingDate] = useState<Date>();
  const [newDuration, setNewDuration] = useState("");
  const [recurring, setRecurring] = useState(false);

  console.log('fods', (Math.floor(new Date(newStartingDate as Date).getTime() / 1000)))
  const updateStream = () => {
    writeContract({
      abi: ContractAbi,
      address: CONTRACT_ADDRESS,
      functionName: "updateStream",
      args: [
        hash as Hex,
        BigInt(newAmount) * BigInt(10 ** PYUSD_DECIMALS),
        BigInt(Math.floor(new Date(newStartingDate as Date).getTime() / 1000)),
        BigInt(Number(newDuration) * 60 * 60 ),
        recurring,
      ],
    });
  };
  const cancelStream = () => {
    writeContract({
      abi: ContractAbi,
      address: CONTRACT_ADDRESS,
      functionName: "cancelStream",
      args: [hash as Hex],
    });
  };

  // ********************HOOKS CONFIG**************************
  const [vault, setVault] = useState<Hex>(ADDRESS_ZERO);
  const [callBeforeFundsCollected, setcallBeforeFundsCollected] =
    useState(false);
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
  // Calculate stream rate once when component mounts
  useEffect(() => {
    if (amount && duration) {
      const ratePerSecond = Number(amount) / Number(duration);
      setStreamRate(ratePerSecond);
      setCurrentValue(Number(amount));
    }
  }, [amount, duration]);

  // Update current value periodically
  const updateCurrentValue = useCallback(() => {
    if (!startingTimestamp || !amount) return;

    const now = Math.floor(Date.now() / 1000);
    const start = Number(startingTimestamp);
    const total = Number(amount);
    const elapsed = now - start;

    // Check if stream has finished
    if (duration && elapsed >= Number(duration)) {
      setCurrentValue(0);
      return;
    }

    // Calculate remaining amount
    const streamed = streamRate * (elapsed);
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
  const format = currentValue / 10 ** PYUSD_DECIMALS;
  const formattedStreamRate = streamRate / 10 ** PYUSD_DECIMALS;
  const formattedValue = format.toFixed(6);

  return (
    <div className=" mt-4 bg-paypalMidBlue/5 p-2">
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
      <div className="flex items-center gap-5 p-2 justify-evenly">
        <h3 className="text-paypalBlue">
          from{" "}
          <span className="text-sm font-semibold text-PayPalCerulean">
            {streamer?.slice(0, 5) + "..." + streamer?.slice(38, 42)}
          </span>
        </h3>
        <div className="flex gap-7 justify-center items-center">
          {!status.isFinished && <UseAnimations animation={activity} size={40} color="#009cde" />}
          <p className="font-medium text-paypalMidBlue text-2xl">
            {status.isFinished ? Number(amount) / 10 ** PYUSD_DECIMALS : status.timeUntilStart !== 0 ? 'starting soon' : formattedValue} <span className="italic">{status.timeUntilStart === 0 && 'PYUSD' }</span>
          </p>
          {!status.isFinished && <UseAnimations animation={activity} size={40} color="#009cde" />}
        </div>
        <h3 className="text-paypalBlue">
          to{" "}
          <span className="text-sm font-semibold text-PayPalCerulean">
            {recipient?.slice(0, 5) + "..." + recipient?.slice(38, 42)}
          </span>
        </h3>
      </div>
      {more && (
        <div className="mt-4 p-2 bg-paypalBlue/5">
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
              <p className="text-sm text-gray-500">End Time</p>
              <p className="font-medium">
                {new Date(
                  Number(startingTimestamp) * 1000 + (Number(duration) * 1000)
                ).toLocaleString()}
              </p>
            </div>
          </div>
          <Dialog>
            <DialogTrigger className="mt-5 border px-4 py-2 rounded-lg bg-PayPalCerulean text-white hover:bg-paypalBlue hover:transition-all">
              Update current stream
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Update</DialogTitle>
                <DialogDescription className="mb-5">
                  This action will update your current stream details
                </DialogDescription>

                <Label htmlFor="newAmount" className="text-left">
                  New Amount
                </Label>
                <Input
                  placeholder={String(Number(amount) / 10 ** PYUSD_DECIMALS)}
                  value={newAmount}
                  onChange={(e) => setNewAmount(e.target.value)}
                  className="col-span-3"
                />

                <Label htmlFor="newStartingDate" className="text-left mt-4">
                  New Starting Date
                </Label>
                <DateTimePicker
                  date={new Date()}
                  setDate={(date: Date) => {
                    seNewStartingDate(date);
                  }}
                />

                <Label htmlFor="newDuration" className="text-left mt-4">
                  New Duration (in hours)
                </Label>
                <Input
                  placeholder="e.g, 24"
                  value={newDuration}
                  onChange={(e) => setNewDuration(e.target.value)}
                  className="col-span-3"
                />

                <div className="flex items-center justify-between mt-4">
                  <Label htmlFor="recurring" className="text-left">
                    Set as Recurring
                  </Label>
                  <input
                    type="checkbox"
                    checked={recurring}
                    onChange={(e) => setRecurring(e.target.checked)}
                    className=""
                  />
                </div>
                <Button
                  className="bg-paypalMidBlue mt-5 shadow-none"
                  onClick={updateStream}
                >
                  update stream
                </Button>
                <Button
                  className="bg-paypalMidBlue mt-5 shadow-none"
                  onClick={() => {
                    writeContract({
                      abi : erc20Abi,
                      address : PYUSD,
                      functionName : 'approve',
                      args : [
                        CONTRACT_ADDRESS, 
                        BigInt(Math.floor(Number(newAmount))) / BigInt(10 ** PYUSD_DECIMALS) 
                      ]
                    })
                  }}
                >
                  approuve PYUSD
                </Button>
              </DialogHeader>
            </DialogContent>
          </Dialog>
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
          <div className="mt-4">
            <Button
              className="border px-4 py-3 rounded-lg bg-paypalMidBlue text-white hover:bg-paypalBlue hover:transition-all"
              onClick={cancelStream}
            >
              Cancel Stream
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
