import express from 'express'
import bodyParser from 'body-parser';
import { app as configApp } from './config';
import './models';
import { auth, hotels } from './routes';

const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use('/api/v1/', auth);
app.use('/api/v1/', hotels);
const { port } = configApp;
app.listen(port);
