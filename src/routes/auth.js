import express from 'express';
import { tokenHelper } from '../functions';
import { connectionAnonymous } from '../database/connect';

const router = express.Router();

const { createToken, getUserIdByToken, getTokenFromHeader } = tokenHelper;
const auth = async (req, res) => {
  try {
    const { userName, password } = req.body;
    const client = await connectionAnonymous();
    const { rows: user } = await client.query(`SELECT * FROM users WHERE login='${userName}'`);
    await client.end();
    if (user.length === 0) {
      res.status(401).json({ message: 'User does not exist' });
      return;
    }
    const isValid = password === user[0].password;
    if (isValid) {
      const token = await createToken(user[0].userid, user[0].role);
      res.status(200).json({ token });
      return;
    }
    res.status(401).json({ message: 'Incorrect data' });
  } catch (err) {
    res.status(500).json({ message: err });
  }
};

const registration = async (req, res) => {
  try {
    const {
      firstName, lastName, login, email, password, phone, address, dateOfBirthday,
    } = req.body;
    if (!firstName) { res.status(400).json({ message: 'FirstName is not specified' }); }
    if (!lastName) { res.status(400).json({ message: 'LastName is not specified' }); }
    if (!login) { res.status(400).json({ message: 'Login is not specified' }); }
    if (!email) { res.status(400).json({ message: 'Email is not specified' }); }
    if (!password) { res.status(400).json({ message: 'Password is not specified' }); }
    if (!phone) { res.status(400).json({ message: 'Phone is not specified' }); }
    if (!address) { res.status(400).json({ message: 'Address is not specified' }); }
    if (!dateOfBirthday) { res.status(400).json({ message: 'Date Of Birthday is not specified' }); }
    const client = await connectionAnonymous();
    await client.query(`SELECT FROM clientRegistration('${firstName}', '${lastName}', '${login}', '${email}', '${password}', '${phone}', '${address}', '${dateOfBirthday}')`);
    await client.end();
    res.status(201).json({ message: 'Registration was successful' });
  } catch (e) {
    res.status(500).json({ message: e.detail });
  }
};
const logout = async (req, res) => {
  try {
    const token = getTokenFromHeader(req.headers.authorization);
    const userId = getUserIdByToken(token);
    const client = await connectionAnonymous();
    console.log(`SELECT * FROM tokens.blacklist WHERE token='${token}';`);
    const { rows: tokenData } = await client.query(`SELECT * FROM tokens.blacklist WHERE token='${token}';`);
    if (tokenData.length !== 0) {
      res.status(203).json({ message: 'Not Authorized' });
      return;
    }
    console.log(`INSERT INTO tokens.blacklist(userId, token) VALUES('${userId}','${token}')`);
    const gf = await client.query(`INSERT INTO tokens.blacklist(userId, token) VALUES('${userId}','${token}');`);
    console.log(gf);
    res.status(200).json({ message: 'User successfully logout' });
  } catch (e) {
    res.status(203).json({
      message: 'Not Authorized',
      detail: e,
    });
  }
};
router.post('/auth', auth);
router.post('/registration', registration);
router.delete('/user', logout);
export default router;
