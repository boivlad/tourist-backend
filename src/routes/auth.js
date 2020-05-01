import express from 'express';
import { authToken } from '../functions';
import { connection } from '../database/connect';

const router = express.Router();

const { createToken } = authToken;

const auth = async (req, res) => {
  try {
    const { login, password } = req.body;
    const client = await connection("postgres");
    const { rows: user } = await client.query(`SELECT * FROM users WHERE login='${login}'`);
    if (user.length === 0) {
      res.status(401).json({ message: 'User does not exist' });
      return;
    }

    const isValid = password === user[0].password;
    if (isValid) {
      const tokens = await createToken(user[0].id, user[0].role);
      res.status(200).json({ token: tokens });
      return;
    }
    res.status(401).json({ message: 'Incorrect data' });
  }
  catch (err) {
    res.status(500).json({ Message: err.code });
  }
};

router.post('/auth', auth);
export default router;
