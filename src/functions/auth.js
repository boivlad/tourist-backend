import SHA256 from 'crypto-js/sha256';
// import { tokenHelper } from './index';

// const { getTokenFromHeader, getUserRoleByToken } = tokenHelper;

export const encryptData = (data) => SHA256(data).toString();

// export const verifyAuthByBearer = async(header) => {
//   const token = getTokenFromHeader(header);
//   const verifyResult = getUserRoleByToken(token);
//   if (!verifyResult) {
//     return false;
//   }
//   const client = await connectionAnonymous();
//   const { rows: tokenData } =
//   await client.query(`SELECT * FROM tokens.blacklist WHERE token='${token}'`);
//   if (tokenData.length !== 0) {
//     return false;
//   }
//   return true;
// };
