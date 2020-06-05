import express from 'express';
import fs from 'fs';
import multer from 'multer';
import { connection } from '../database/connect';
import { tokenHelper } from '../functions';
import DB from '../database/utils';

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

const getHotels = async(req, res) => {
  const client = await connection('anonymous');
  const result = await DB.getHotels(client);
  client.end();
  res.status(200).json({ hotels: result });
};
const getHotelById = async(req, res) => {
  const client = await connection('anonymous');
  const result = await DB.getHotelById(client, { hotelId: req.params.id });
  client.end();
  res.status(200).json({ hotel: result });
};
const createHotel = async(req, res) => {
  if (!isDirector(req.headers.authorization)) {
    res.status(403).json({ message: 'Forbidden' });
    return;
  }
  const client = await connection('director');

  uploadFile(req, res, async(err) => {
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
    } catch (e) {
      fs.unlinkSync(`${uploadPath}/${req.files[0].filename}`);
      if (e.code === '23505') {
        return res.status(409).json({ message: 'Same hotel already exist' });
      }
      return res.status(422).json({ message: e });
    } finally {
      client.end();
    }
  });
};

router.get('/hotels', getHotels);
router.get('/hotels/:id', getHotelById);
router.post('/hotels', createHotel);
export default router;
