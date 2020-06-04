import SHA256 from 'crypto-js/sha256';
import tokenHelper from './token';
import { connection } from '../database/connect';

const { getTokenFromHeader, verifyToken } = tokenHelper;

export const encryptData = (data) => SHA256(data).toString();

export const verifyAuthByBearer = async(header) => {
  const token = getTokenFromHeader(header);
  try {
    const verifyResult = verifyToken(token);
    const client = await connection('anonymous');
    const { rows: tokenData } = await client.query(`SELECT * FROM tokens.blacklist WHERE token='${token}'`);
    if (tokenData.length !== 0) {
      return false;
    }
    return verifyResult;
  } catch (e) {
    return false;
  }
};
