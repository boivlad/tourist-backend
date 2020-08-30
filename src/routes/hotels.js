import express from 'express';
import fs from 'fs';
import multer from 'multer';
import { connection } from '../database/connect';
import { tokenHelper } from '../functions';
import DB from '../database/utils';
import { verifyAuthByBearer } from '../functions/auth';
import moment from 'moment';

const { isDirector } = tokenHelper;
const router = express.Router();
const uploadPath = 'public/uploads/images';
const storage = multer.diskStorage({
  destination(req, file, cb) {
    cb(null, uploadPath);
  },
  filename(req, file, cb) {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});
const uploadFile = multer({ storage }).array('preview');

const getHotels = async (req, res) => {
  const client = await connection('anonymous');
  const result = await DB.getHotels(client);
  await client.end();
  return res.status(200).json({ hotels: result });
};
const getHotelById = async (req, res) => {
  const client = await connection('anonymous');
  const result = await DB.getHotelById(client, { hotelId: req.params.id });
  await client.end();
  return res.status(200).json({ hotel: result[0] });
};
const createHotel = async (req, res) => {
  if (!isDirector(req.headers.authorization)) {
    return res.status(403).json({ message: 'Forbidden' });
  }
  const client = await connection('director');

  uploadFile(req, res, async (err) => {
    if (err) {
      return res.status(403).json({ message: err });
    }
    const queryParams = {
      ...req.body, fileName: req.files[0].filename,
    };
    try {
      await DB.createHotel(client, queryParams);
      return res.status(201).json({
        message: 'New hotel was created successfully',
      });
    }
    catch (e) {
      fs.unlinkSync(`${uploadPath}/${req.files[0].filename}`);
      if (e.code === '23505') {
        return res.status(409).json({ message: 'Same hotel already exist' });
      }
      return res.status(422).json({ message: e });
    } finally {
      await client.end();
    }
  });
};
const getRoomsByHotelId = async (req, res) => {
  const client = await connection('anonymous');
  const result = await DB.getRoomsByHotelId(client, { hotelId: req.params.id });
  await client.end();
  return res.status(200).json({ rooms: result });
}
const createOrder = async (req, res) => {
  const userData = await verifyAuthByBearer(req.headers.authorization);
  if (!userData) {
    return res.status(401).json({ message: 'Not Authorized' });
  }
  const client = await connection(userData.role);
  const { userId } = userData;
  const { roomId, startDate, endDate, places } = req.body.data;
  const mStartDate = moment(startDate);
  const mEndDate = moment(endDate);
  const dateDiff = mEndDate.diff(mStartDate, 'days');
  if (!places || places <= 0) {
    return res.status(400).json({ message: 'Incorrect places value' });
  }
  if (!mStartDate || !mEndDate) {
    return res.status(400).json({ message: 'Incorrect start or end dates' });
  }
  if (dateDiff <= 0) {
    return res.status(400).json({ message: 'End date is earlier than start date' });
  }
  const roomData = await DB.getRoomById(client, { roomId });
  if (!roomData) {
    return res.status(400).json({ message: 'The requested room does not exist' });
  }
  const prices = dateDiff * roomData.price;
  try{
    await DB.orderRoom(client, { userId, roomId, startDate, endDate, places, prices });
    return res.status(201).json({ message: 'Reserve created successfully' });
  }catch (e){
    return res.status(409).json({ message: 'Error creating reserve' });
  }finally {
    await client.end();
  }

}
router.get('/hotels', getHotels);
router.get('/hotels/:id', getHotelById);
router.post('/hotels', createHotel);
router.post('/hotels/room/order', createOrder);
router.get('/hotels/:id/rooms', getRoomsByHotelId);
export default router;
