import express from 'express';

import { connection } from '../database/connect';

const router = express.Router();

const getHotels = async(req, res) => {
  const client = await connection('postgres');
  const { rows } = await client.query('SELECT * FROM getHotels');
  res.status(200).json(rows);
};

router.get('/hotels', getHotels);
export default router;
