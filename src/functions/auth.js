import SHA256 from 'crypto-js/sha256';

export const encryptData = (data) => SHA256(data).toString();
