CREATE USER anonymous WITH PASSWORD '1111';
CREATE USER client WITH PASSWORD 'client';
CREATE USER director WITH PASSWORD 'director';
CREATE USER manager WITH PASSWORD 'manager';

CREATE DOMAIN OrderStatus VARCHAR CHECK
(VALUE IN
('New', 'Conform', 'Ready'));
CREATE DOMAIN Roles VARCHAR CHECK
(VALUE IN
('client', 'manager', 'director', 'anonymous'));
CREATE TABLE Clients
(
userId SERIAL PRIMARY KEY,
FirstName VARCHAR NOT NULL,
LastName VARCHAR NOT NULL,
Phone CHAR(13)NOT NULL,
DateOfBirthday DATE NOT NULL,
Address VARCHAR NOT NULL
);
CREATE TABLE Users
(
  userId integer NOT NULL REFERENCES Clients(userId) ON DELETE CASCADE ON UPDATE CASCADE,
  login VARCHAR NOT NULL,
  password VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  role Roles NOT NULL DEFAULT 'client',
	UNIQUE (login),
	UNIQUE (email)
);
GRANT SELECT ON TABLE public.users TO anonymous;
CREATE SCHEMA tokens AUTHORIZATION postgres;
CREATE TABLE tokens.blacklist
(
id SERIAL PRIMARY KEY,
userId integer NOT NULL REFERENCES Clients(userId),
token VARCHAR NOT NULL
);
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO anonymous;
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO client;
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO director;
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO manager;
CREATE OR REPLACE FUNCTION getHotels()
  RETURNS TABLE(id integer, title character varying, description character varying, rating integer, street character varying, city character varying, country character varying)
  AS $$
  BEGIN
    RETURN QUERY
      SELECT h.id, h.title, h.description, h.rating, a.title AS street, c.title AS city, co.title AS Country
      FROM hotels h
      JOIN address a ON h.address=a.id
      JOIN city c ON a.city=c.id
      JOIN country co ON c.country=co.id;
  END;
  $$ LANGUAGE plpgSQL;
CREATE OR REPLACE FUNCTION clientRegistration(firstName varchar, lastName varchar, login varchar,
	email varchar, password varchar, phone CHAR(13), address varchar, DateOfBirthday date)
	RETURNS Void
	AS $$
		DECLARE
			newId INT;
		BEGIN
			INSERT INTO clients(firstname, LastName, Phone, DateOfBirthday, Address) VALUES(firstName, lastName, phone, DateOfBirthday, address);
			newId := currval(pg_get_serial_sequence('clients','userid'));
			INSERT INTO Users(userId, login, password, email) VALUES(newId, login, password, email);
		END;
$$ LANGUAGE plpgSQL;
GRANT EXECUTE ON FUNCTION public.clientregistration(character varying, character varying, character varying, character varying, character varying, character, character varying, date) TO anonymous;
