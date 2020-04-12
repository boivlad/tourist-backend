import express from 'express';
import bCrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { app } from '../config';

const { secret } = app.jwt;
// import authHelper from '../functions';
import { connection, connectionAnonymous } from '../database/connect';

const router = express.Router();

const test = async (req, res) => {
  const { login, password } = req.body;
  const bCryptPassword = bCrypt.hashSync(password, 10);
  const client = await connection("postgres");
  const { rows } = await client.query(`SELECT * FROM users WHERE login='${login}'`);
  res.status(200).json(rows);
};

router.post('/test/', test);
export default router;
