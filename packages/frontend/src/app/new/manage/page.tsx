"use client";
import { useEffect, useState } from "react";
import { useAccount, useReadContracts, useReadContract } from "wagmi";
import { Hex } from "viem";
import Stream from "@/app/_components/Stream";
import { CONTRACT_ADDRESS } from "@/config/constants";
import { ContractAbi } from "@/config/ABI/contractABI";
import { IstreamData } from "@/config/constants";

export interface StreamWithHash extends IstreamData {
  lenght?: number;
  hash: Hex;
}

export default function Manage() {
  const { address } = useAccount();
  const [streams, setStreams] = useState<StreamWithHash[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const {
    data: hashes,
    isError: hashesError,
    isLoading: hashesLoading,
  } = useReadContract({
    address: CONTRACT_ADDRESS,
    abi: ContractAbi,
    functionName: "getStreamerStreamHashes",
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
        <p>Loading streams...</p>
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
        <p>No active streams found</p>
      </div>
    );
  }

  return (
    <div className="max-w-[60%] mx-auto border p-5 mt-10">
      {streams.map((streamData: StreamWithHash, index) => (
        <Stream
          key={index}
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
  );
}
