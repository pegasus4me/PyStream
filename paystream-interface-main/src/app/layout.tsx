import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";
import { headers } from "next/headers";
import { Header } from "./_components/header";
import ContextProvider from "../context/ContextProvider";
const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});
const geistMono = localFont({
  src: "./fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
  weight: "100 900",
});

export const metadata: Metadata = {
  title: "PayStreams | Stream PYUSD as you get job done",
  description: "Stream PYUSD as you get job done",
};
export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const cookies = headers().get("cookie");
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        <div className=" fixed flex match:hidden inset-0 items-center justify-center text-xl font-semibold">
          Switch to desktop to test PayStreams
        </div>
        <div className="hidden match:block">
          <ContextProvider cookies={cookies}>
            <Header />
            {children}
          </ContextProvider>
        </div>
      </body>
    </html>
  );
}
