import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import { app as configApp } from './config';
import './models';
import { auth, hotels, tours, transfers } from './routes';

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(express.static('public'));
app.use('/api/v1/', auth);
app.use('/api/v1/', hotels);
app.use('/api/v1/', tours);
app.use('/api/v1/', transfers);
const { port } = configApp;
app.listen(port);
