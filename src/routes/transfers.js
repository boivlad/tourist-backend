import express from 'express';
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
// const uploadFile = multer({ storage }).array('preview');

const getTransfers = async (req, res) => {
  const client = await connection('anonymous');
  const result = await DB.getTransfers(client);
  client.end();
  return res.status(200).json({ transfers: result });
};

router.get('/transfers', getTransfers);
// router.get('/tours/:id', getToursById);
// router.post('/tours', createTour);
export default router;
