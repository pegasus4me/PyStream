"use client"
import StreamingPaymentCard from "../_components/StreamingPaymentCard"

export default function New() {
  return (
    <div className="flex w-[95%] mx-auto border border-paypalMidBlue/20 mt-20 rounded-xl items-center justify-center">
        <div className="flex items-center justify-center bg-transparent">
          <div className="">
            <StreamingPaymentCard />
          </div>
        </div>
    </div>
  );
}