import mongoose from 'mongoose';
const { Schema } = mongoose;

const userStream = new Schema({
  streamer: String,
  recipient : String, 
  token_Address: String,
  tag: String, 
  creation_date: { type: Date, default: Date.now },
});

const NewStream = mongoose.models?.Hash || mongoose.model('Hash', userStream)
export default NewStream
