import express from 'express';

import { connection } from '../database/connect';

const router = express.Router();

const getHotels = async (req, res) => {
  const client = await connection("postgres");
  const { rows } = await client.query(`SELECT * FROM getHotels()`);
  res.status(200).json(rows);
};

router.get('/hotels', getHotels);
export default router;
// CREATE OR REPLACE FUNCTION testGetHotels()
// RETURNS TABLE (id integer, title varchar, description varchar, rating integer, street varchar,city varchar, Country varchar)
// AS $$
// BEGIN
// RETURN QUERY
// SELECT h.id, h.title, h.description, h.rating, a.title AS street, c.title AS city, co.title AS Country
// FROM hotels h
// JOIN address a ON h.address=a.id
// JOIN city c ON a.city=c.id
// JOIN country co ON c.country=co.id;
// END;
// $$ LANGUAGE plpgSQL;
