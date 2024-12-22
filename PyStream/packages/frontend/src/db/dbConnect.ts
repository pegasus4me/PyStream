import mongoose from 'mongoose'

const connection: { isConnected?: number } = {}

export async function dbConnect (): Promise<void> {
  if (connection.isConnected) {
    console.log('Already connected to database')
    return
  }

  try {
    const db = await mongoose.connect(process.env.DATABASE_URL as string)
    connection.isConnected = db.connections[0].readyState
    console.log('DB Connected Successfully')
  } catch (error) {
    console.log('Database connection failed')
    console.log(error)
    process.exit()
  }
}
export default dbConnect
