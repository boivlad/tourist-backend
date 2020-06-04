import jwt from 'jsonwebtoken';
import { app } from '../config';

const { secret, tokens } = app.jwt;

const createToken = (userId, role) => {
  const payload = {
    userId,
    role,
    type: tokens.access.type,
  };
  console.log(payload);
  const options = { expiresIn: tokens.access.expiresIn };
  return jwt.sign(payload, secret, options);
};
const getUserRoleByToken = (token) => {
  try {
    const { role } = jwt.decode(token);
    return role;
  } catch (e) {
    return false;
  }
};
const getUserIdByToken = (token) => {
  const { userId } = jwt.decode(token);
  return userId;
};
const verifyToken = (token) => jwt.verify(token, secret);
const getTokenFromHeader = (header) => {
  if (header && header.indexOf('Bearer ') === 0) {
    return header.split(' ')[1];
  }
  return false;
};
const isClient = (authorization) => getUserRoleByToken(getTokenFromHeader(authorization)) === 'client';
const isManager = (authorization) => getUserRoleByToken(getTokenFromHeader(authorization)) === 'manager';
const isDirector = (authorization) => getUserRoleByToken(getTokenFromHeader(authorization)) === 'director';

export default {
  createToken,
  getUserRole: getUserRoleByToken,
  verifyToken,
  getTokenFromHeader,
  getUserIdByToken,
  isClient,
  isManager,
  isDirector,
};
