import { Client } from "pg";
import { app as config } from '../config';

const database = config.database;
const host = database.host;
const port = database.port;
const db = database.database;

const connection = async (role) => {
  const name = role;
  const { password } = database.roles[role];
  const client = new Client({
    user: name,
    password: password,
    host: host,
    port: port,
    database: db
  });
  await client.connect();
  return client;
}
const connectionAnonymous = () => {
  return connection('anonymous');
}
export {
  connection,
  connectionAnonymous
}
