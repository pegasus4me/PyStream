"use client";
import { useAccount, useReadContracts } from "wagmi";
import { useEffect } from "react";
import { useState } from "react";
import { CONTRACT_ADDRESS } from "@/config/constants";
import { useReadContract } from "wagmi";
import { ContractAbi } from "@/config/ABI/contractABI";
import { Hex } from "viem";
import { StreamWithHash } from "../new/manage/page";
import { Receive } from "../_components/Receive";

export default function New() {
  // only withdraw funds from the stream
  // get hashes bulk getStreamerStreamHashes()
  // retrieve data getStreamData()
  // manage hooks

  const [streams, setStreams] = useState<StreamWithHash[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const { address } = useAccount();
  const {
    data: hashes,
    isError: hashesError,
    isLoading: hashesLoading,
  } = useReadContract({
    abi: ContractAbi,
    functionName: "getRecipientStreamHashes",
    address: CONTRACT_ADDRESS,
    args: [address as Hex],
  });
  const {
    data: streamsData,
    isError: streamsError,
    isLoading: streamsLoading,
  } = useReadContracts({
    contracts:
      (hashes as Hex[])?.map((hash) => ({
        address: CONTRACT_ADDRESS,
        abi: ContractAbi,
        functionName: "getStreamData",
        args: [hash],
      })) ?? [],
  });
  console.log("Hash", hashes);

  useEffect(() => {
    console.log("data", streamsData);
    if (hashesLoading || streamsLoading) {
      setIsLoading(true);
      return;
    }

    if (hashesError || streamsError) {
      setError("Failed to fetch stream data");
      setIsLoading(false);
      return;
    }

    if (streamsData && hashes) {
      const validStreams = streamsData
        .map((stream, index) => ({
           // @ts-expect-error expect spread only be created from object types
          ...stream.result,
          hash: hashes[index], // Add hash to each stream
        }))
        .filter(Boolean);

      setStreams(validStreams);
    }

    setIsLoading(false);
  }, [
    hashesLoading,
    streamsLoading,
    hashesError,
    streamsError,
    streamsData,
    hashes,
  ]);

  if (isLoading) {
    return (
      <div className="max-w-[60%] mx-auto border p-5 mt-10">
        <p>Loading income streams...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="max-w-[60%] mx-auto border p-5 mt-10">
        <p className="text-red-500">Error: {error}</p>
      </div>
    );
  }

  if (streams.length === 0) {
    return (
      <div className="max-w-[60%] mx-auto border p-5 mt-10">
        <p>No active income streams found</p>
      </div>
    );
  }
  return (
    <div className="max-w-[60%] mx-auto border p-5 mt-10">
     <div>
     {streams.map((streamData: StreamWithHash, index) => (
        <Receive
          key={index}
          lenght={streams.length}
          hash={streamData.hash} // Pass the hash here
          recipient={streamData.recipient}
          streamer={streamData.streamer}
          amount={streamData.amount}
          duration={streamData.duration}
          startingTimestamp={streamData.startingTimestamp}
          recurring={streamData.recurring}
        />
      ))}
     </div>
    </div>
  );
}
