'use client'
import Image from "next/image"
import pyUsd from "../static/PYSUD.png"
import { Button } from "@/components/ui/button"
import { useRouter } from "next/navigation";
export default function Home() {
  const router =  useRouter()
  return (
    <div className="font-[family-name:var(--font-geist-sans)] max-w-[70%] mx-auto mt-10">
      <div className="w-[100%] h-[800px] border mx-auto rounded-xl flex items-center justify-center bg-[url('../static/people.jpeg')] bg-cover bg-center bg-no-repeat relative">
        <div className="absolute inset-0 bg-gray-800/40 rounded-xl"></div>
        <div className="flex flex-col max-w-[60%] text-center z-10">
          <h1 className="text-8xl font-semibold text-white">
            Stream Money As You Work
          </h1>
          <p className="text-xl mt-4 text-semibold text-white">
            We enable money live stream from peer to peer, no need to wait the
            end of the month to be paid, get paid as you get the job done!
          </p>
          <div className="flex items-center justify-center gap-5">
            <p className="text-white font-semibold">powered by </p>
            <Image src={pyUsd} width={40} height={40} alt="pyusd_logo" />
          </div>
          <div className="p-2 flex gap-4 flex-wrap items-center justify-center">
          <Button className="bg-paypalMidBlue"
          onClick={() => router.push('/new')}
          >Create new stream</Button>
          <p className="text-white">or</p>
          <Button className="bg-PayPalCerulean"
          onClick={() => router.push('/track')}
          >track your streams</Button>
          </div>
        </div>
      </div>
    </div>
  );
}
