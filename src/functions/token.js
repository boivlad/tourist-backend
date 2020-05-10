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
const getUserRoleByToken = (token) => {
  const { role } = jwt.decode(token);
  return role;
}
const getUserIdByToken = (token) => {
  const { userId } = jwt.decode(token);
  return userId;
}
const verifyToken = (token) => {
  return jwt.verify(token, secret);
}
const getTokenFromHeader = (header) => {
  if (header && header.indexOf("Bearer ") === 0) {
    return header.split(" ")[1];
  }
  return false;
}
export default {
  createToken,
  getUserRole: getUserRoleByToken,
  verifyToken,
  getTokenFromHeader,
  getUserIdByToken,
};
