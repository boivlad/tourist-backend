import express from 'express';
import { tokenHelper } from '../functions';
import { connection } from '../database/connect';
import { verifyAuthByBearer } from '../functions/auth';
import DB from '../database/utils';

const router = express.Router();

const { createToken, getUserIdByToken, getTokenFromHeader } = tokenHelper;
const auth = async(req, res) => {
  try {
    const { userName, password } = req.body;
    const client = await connection('anonymous');
    const user = await DB.getUser(client, { userName });
    client.end();
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

const registration = async(req, res) => {
  console.log('Registration Client');
  try {
    const {
      firstName, lastName, userName: login, email, password, phone, address, dateOfBirth,
    } = req.body;
    if (!firstName) {
      res.status(400).json({ message: 'FirstName is not specified' });
    }
    if (!lastName) {
      res.status(400).json({ message: 'LastName is not specified' });
    }
    if (!login) {
      res.status(400).json({ message: 'Login is not specified' });
    }
    if (!email) {
      res.status(400).json({ message: 'Email is not specified' });
    }
    if (!password) {
      res.status(400).json({ message: 'Password is not specified' });
    }
    if (!phone) {
      res.status(400).json({ message: 'Phone is not specified' });
    }
    if (!address) {
      res.status(400).json({ message: 'Address is not specified' });
    }
    if (!dateOfBirth) {
      res.status(400).json({ message: 'Date Of Birth is not specified' });
    }
    const client = await connection('anonymous');
    await DB.createUser(client, {
      firstName, lastName, login, email, password, phone, address, dateOfBirth,
    });
    res.status(201).json({ message: 'Registration was successful' });
  } catch (e) {
    if (e.code === '23505') {
      res.status(409).json({ message: 'User already exist' });
    } else {
      res.status(422).json({ message: e });
    }
  }
};
const logout = async(req, res) => {
  const client = await connection('anonymous');
  try {
    const token = getTokenFromHeader(req.headers.authorization);
    const userId = getUserIdByToken(token);
    const checkToken = await DB.checkToken(client, { token });
    if (checkToken) {
      return res.status(203).json({ message: 'Not Authorized' });
    }
    await DB.deleteToken(client, { userId, token });
    return res.status(200).json({ message: 'User successfully logout' });
  } catch (e) {
    return res.status(203).json({
      message: 'Not Authorized',
      detail: e,
    });
  } finally {
    client.end();
  }
};
const registrationAdmin = async(req, res) => {
  console.log('Registration Manager');
  const userData = await verifyAuthByBearer(req.headers.authorization);
  if (!userData) {
    res.status(401).json({ message: 'Not Authorized' });
  }
  if (userData.role !== 'director') {
    res.status(403).json({ message: 'Forbidden' });
  }
  const client = await connection('anonymous');
  try {
    const {
      firstName, lastName, userName, email, password, phone, address, dateOfBirth, passport,
    } = req.body;
    let { employmentDate } = req.body;
    if (!firstName) {
      res.status(400).json({ message: 'FirstName is not specified' });
    }
    if (!lastName) {
      res.status(400).json({ message: 'LastName is not specified' });
    }
    if (!userName) {
      res.status(400).json({ message: 'Login is not specified' });
    }
    if (!email) {
      res.status(400).json({ message: 'Email is not specified' });
    }
    if (!password) {
      res.status(400).json({ message: 'Password is not specified' });
    }
    if (!phone) {
      res.status(400).json({ message: 'Phone is not specified' });
    }
    if (!address) {
      res.status(400).json({ message: 'Address is not specified' });
    }
    if (!dateOfBirth) {
      res.status(400).json({ message: 'Date Of Birth is not specified' });
    }
    if (!passport) {
      res.status(400).json({ message: 'Date Of Birth is not specified' });
    }
    if (!employmentDate) {
      employmentDate = new Date().toLocaleString('en-US',
        { year: 'numeric', month: 'numeric', day: '2-digit' });
    }

    await DB.createAdmin(client, {
      firstName,
      lastName,
      userName,
      email,
      password,
      phone,
      address,
      dateOfBirth,
      passport,
      employmentDate,
    });
    return res.status(201).json({ message: 'Manager registration was successful' });
  } catch (e) {
    if (e.code === '23505') {
      return res.status(409).json({ message: 'User already exist' });
    }
    return res.status(422).json({ message: e });
  } finally {
    client.end();
  }
};
router.post('/auth', auth);
router.post('/user', registration);
router.post('/admin', registrationAdmin);
router.delete('/user', logout);
export default router;
