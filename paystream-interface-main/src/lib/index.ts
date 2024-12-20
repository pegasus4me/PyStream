export function calculateStreamRate(amount: string, duration: string): number {
  const totalAmount = Number(amount);
  const durationHours = Number(duration);

  // Convert duration to seconds
  const durationSeconds = durationHours * 60 * 60;

  // Calculate rate per second
  const ratePerSecond = totalAmount / durationSeconds;

  return ratePerSecond;
}

// To get current amount streamed at any time:
export function getCurrentStreamed(
  streamRate: number,
  amount: number,
  startTime: Date,
  currentTime: Date
): number {
  const elapsedSeconds = (currentTime.getTime() - startTime.getTime()) / 1000;
  const streamed = streamRate * elapsedSeconds;
  const remaining = Number(amount) - streamed;

  return remaining > 0 ? remaining : 0;
}

export function millisecondsToHours(ms: bigint) {
    const dur =  Number(ms) / 1000 / 60 / 60
    return String(dur)
}

export function getStreamStatus(starting: number, duration: number) {
  // Get current time in seconds
  const now = Math.floor(Date.now() / 1000);

  // Calculate time until start in seconds
  const timeUntilStart = starting - now;

  // Check if stream has started
  const isStarted = now >= starting;

  // For live streams (no duration) or unfinished streams
  let isFinished = false;
  
  if (duration !== null) {
    const endTime = starting + duration;
    isFinished = now >= endTime;
  }

  return {
    isStarted,
    isFinished,
    timeUntilStart: Math.max(0, timeUntilStart)
  };
}