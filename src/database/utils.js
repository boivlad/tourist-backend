// USERS
const getUser = async(client, { userName }) => {
  console.log('getUser', userName);
  const result = await client.query(`SELECT * FROM users WHERE login='${userName}' LIMIT 1`);
  return result.rows;
};
const createUser = async(client, {
  firstName, lastName, login, email, password, phone, address, dateOfBirth,
}) => {
  console.log('createUser', login);
  const result = await client.query(`SELECT * FROM clientRegistration('${firstName}', '${lastName}', '${login}', '${email}', '${password}', '${phone}', '${address}', '${dateOfBirth}')`);
  return result.rows;
};
const createAdmin = async(client, {
  firstName, lastName, userName, email, password, phone, address, dateOfBirth, passport,
  employmentDate,
}) => {
  console.log('createAdmin', userName);
  const result = await client.query(`SELECT FROM employeesRegistration('${firstName}', '${lastName}', '${userName}', '${email}', '${password}', '${phone}', '${address}', '${dateOfBirth}', '${employmentDate}', '${passport}')`);
  return result.rows;
};

// TOKEN
const checkToken = async(client, { token }) => {
  console.log('checkToken', token);
  const result = await client.query(`SELECT * FROM tokens.blacklist WHERE token='${token}';`);
  return !!result.rows.length;
};
const deleteToken = async(client, { userId, token }) => {
  console.log('deleteToken', token);
  await client.query(`INSERT INTO tokens.blacklist(userId, token) VALUES('${userId}','${token}');`);
  return true;
};

// HOTELS
const createHotel = async(client, {
  title, description, rating, address, fileName,
}) => {
  console.log('createHotel');
  const result = await client.query(`INSERT INTO Hotels (title, description, rating, address, preview) VALUES ('${title}', '${description}', '${rating}', '${address}', '${fileName}' );`);
  return result.rows;
};
const getHotels = async(client) => {
  console.log('getHotels');
  const result = await client.query('SELECT * FROM getHotels()');
  return result.rows;
};
const getHotelById = async(client, { hotelId }) => {
  console.log('getHotelById', hotelId);
  const result = await client.query(`SELECT * FROM getHotels(${hotelId}) LIMIT 1`);
  return result.rows;
};
const getRoomsByHotelId = async(client, { hotelId }) => {
  console.log('getRoomsByHotelId', hotelId);
  const result = await client.query(`SELECT * FROM getRooms(${hotelId})`);
  return result.rows;
};
const getRoomById = async(client, { roomId }) => {
  console.log('getRoomById', roomId);
  const result = await client.query(`SELECT * FROM rooms WHERE Id='${roomId}' LIMIT 1`);
  return result.rows[0];
};
const orderRoom = async(client, { userId, roomId, startDate, endDate, places, prices }) => {
  console.log('order room', roomId, 'for user', userId);
  await client.query(`SELECT * FROM orderRoom('${userId}','${roomId}','${startDate}','${endDate}','${places}','${prices}')`);
  return true;
};

// TOURS
const createTour = async(client, {
  title, description, rating, price, fileName, city,
}) => {
  console.log('createTour');
  const result = await client.query(`INSERT INTO tours (title, description, price, rating, city, preview) VALUES ('${title}', '${description}', '${price}', '${rating}', '${city}', '${fileName}' );`);
  return result.rows;
};
const getTours = async(client) => {
  console.log('getTours');
  const result = await client.query('SELECT * FROM getTours()');
  return result.rows;
};
const getToursById = async(client, { tourId }) => {
  console.log('getToursById', tourId);
  const result = await client.query(`SELECT * FROM getTours(${tourId}) LIMIT 1`);
  return result.rows[0];
};
const orderTour = async(client, { userId, tourId, startDate, endDate, places, prices }) => {
  console.log('order tour', tourId, 'for user', userId);
  await client.query(`SELECT * FROM orderTour('${userId}','${tourId}','${startDate}','${endDate}','${places}','${prices}')`);
  return true;
};

// TRANSFERS
const getTransfers = async(client) => {
  console.log('getTransfers');
  const result = await client.query('SELECT * FROM getTransfers()');
  return result.rows;
};
const getTransferById = async(client, { transferId }) => {
  console.log('getTransferById', transferId);
  const result = await client.query(`SELECT * FROM getTransfers(${transferId}) LIMIT 1`);
  return result.rows[0];
};
const orderTransfer = async(client, { userId, transferId, startDate, endDate, places, prices }) => {
  console.log('order transfer', transferId, 'for user', userId);
  console.log(`SELECT * FROM orderTransfer('${userId}','${transferId}','${startDate}','${endDate}','${places}','${prices}')`)
  await client.query(`SELECT * FROM orderTransfer('${userId}','${transferId}','${startDate}','${endDate}','${places}','${prices}')`);
  return true;
};
export default {
  getUser,
  createUser,
  createAdmin,
  checkToken,
  deleteToken,
  getHotels,
  getHotelById,
  getRoomsByHotelId,
  getRoomById,
  orderRoom,
  getTours,
  getToursById,
  orderTour,
  createHotel,
  createTour,
  getTransfers,
  getTransferById,
  orderTransfer,
};
