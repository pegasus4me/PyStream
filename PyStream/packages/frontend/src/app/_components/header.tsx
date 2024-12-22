"use client";
import usePyUSD from "@/hooks/usePyBalance";
import { useAccount } from "wagmi";
import Image from "next/image";
import pyUsd from "../../static/PYSUD.png";
import Link from "next/link";
import { Hex } from "viem";
import paystream from '../../static/Paystream.png'
export function Header() {
  const account = useAccount();
  const user_balance = usePyUSD(account.address as Hex);

  const nav = [
    {
      name: "Create",
      path: '/new',
      id: 1,
    },
    {
      name: "Manage",
      path: '/new/manage',
      id: 2,
    },
    {
        name: "Track",
        path: '/track',
        id: 3,
      },
  ];

  return (
    <div className="flex justify-around p-3 text-lg font-[family-name:var(--font-geist-sans)]">
      <div className="flex items-center gap-5">
     <Image src={paystream} alt="paystream" width={200} quality={100}/>

        <div className="flex gap-3 font-geistSans">
          {nav.map((n, key) => {
            return (
              <Link
                href={n.path}
                key={key}
                className="text-PayPalCerulean hover:text-paypalMidBlue transition-all"
              >
                {n.name}
              </Link>
            );
          })}
        </div>
      </div>

      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2">
          <small>{Number(user_balance) ? (Number(user_balance) / 1_000_000).toLocaleString() : '-' }</small>
          <Image src={pyUsd} width={20} height={20} alt="pyusd_logo" />
        </div>
        <w3m-button />
      </div>
    </div>
  );
}
