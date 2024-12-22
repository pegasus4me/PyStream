import dbConnect from "@/db/dbConnect";
import NewStream from "@/db/schema";
import { NextResponse } from "next/server";

export interface Stream {
  streamer: string;
  recipient: string;
  token_Address: string;
  tag: string;
}

/**
 * @Monage the user new stream save data
 */
export async function POST(req: Request) {
  await dbConnect();
  const { streamer, recipient, tag, token_Address }: Stream = await req.json();
  if (!streamer || !recipient || !tag || !token_Address)
    return NextResponse.json({ err: "you must put all the values" });

  try {
    const registerNewStream = await NewStream.create({
      streamer: streamer,
      recipient: recipient,
      token_Address: token_Address,
      tag: tag,
    });
    return NextResponse.json({
      code: 200,
      desc: "sucessfully registered",
      data: registerNewStream,
    });
  } catch (error) {
    return NextResponse.json({ error: error });
  }
}
