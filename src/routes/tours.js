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

const getTours = async(req, res) => {
  const client = await connection('anonymous');
  const result = await DB.getTours(client);
  client.end();
  res.status(200).json({ tours: result });
};
const createTour = async(req, res) => {
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
      await DB.createTour(client, queryParams);
      return res.status(201).json({
        message: 'New tour was created successfully',
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

router.get('/tours', getTours);
router.post('/tours', createTour);
export default router;
