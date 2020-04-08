import { Client } from "pg";
import { app as config } from '../config';

const client = new Client(config.database);

client.connect(err => {
  if (err) {
    console.error('connection error', err.stack)
  } else {
    console.log('connected')
  }
})
export default client;
