import jwt from 'jsonwebtoken';
import { app } from '../config';

const { secret, tokens } = app.jwt;

const createToken = (userId, role) => {
  const payload = {
    userId: userId,
    role: role,
    type: tokens.access.type,
  };
  console.log(payload);
  const options = { expiresIn: tokens.access.expiresIn };
  return jwt.sign(payload, secret, options);
};
export default {
  createToken,
};
