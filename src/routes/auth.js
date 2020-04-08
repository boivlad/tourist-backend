import express from 'express';
import connect from '../database/connect';

const router = express.Router();

const test = async (req, res) => {
  const result = await connect.query('');
  res.status(200).json(result);
};

router.get('/hotels/', test);
export default router;
