import express from 'express';
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
// const uploadFile = multer({ storage }).array('preview');

const getTransfers = async (req, res) => {
  const client = await connection('anonymous');
  const result = await DB.getTransfers(client);
  client.end();
  return res.status(200).json({ transfers: result });
};
const getTransferById = async(req, res) => {
  const client = await connection('anonymous');
  const result = await DB.getTransferById(client, { transferId: req.params.id });
  client.end();
  return res.status(200).json({ transfer: result });
};
const createOrder = async (req, res) => {
  const userData = await verifyAuthByBearer(req.headers.authorization);
  if (!userData) {
    return res.status(401).json({ message: 'Not Authorized' });
  }
  const client = await connection(userData.role);
  const { userId } = userData;
  const { transferId, startDate, endDate, places } = req.body.data;
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
  const transferData =  await DB.getTransferById(client, { transferId });
  if (!transferData) {
    return res.status(400).json({ message: 'The requested transfer does not exist' });
  }
  const prices = dateDiff * transferData.price;

  try{
    await DB.orderTransfer(client, { userId, transferId, startDate, endDate, places, prices });
    return res.status(201).json({ message: 'Reserve created successfully' });
  }catch (e){
    return res.status(409).json({ message: 'Error creating reserve', details: e });
  }finally {
    await client.end();
  }
}
router.get('/transfers', getTransfers);
router.get('/transfers/:id', getTransferById);
router.post('/transfers/order', createOrder);
// router.post('/transfers', createTransfer);
export default router;
