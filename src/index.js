import express from 'express'
import bodyParser from 'body-parser';
import { app as configApp } from './config';
import './models';
import { auth } from './routes';

const app = express();
app.use(bodyParser.json());
app.use('/api/v1/', auth);
const { port } = configApp;
app.listen(port);
