import { Client } from 'pg';
import { app as config } from '../config';

const { database } = config;
const { host } = database;
const { port } = database;
const db = database.database;

export const connection = async(role) => {
  const name = 'postgres' || role;
  const { password } = database.roles[name];
  const client = new Client({
    user: name,
    password,
    host,
    port,
    database: db,
  });
  await client.connect();
  return client;
};
