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
CREATE TABLE Users
(
    userId   SERIAL PRIMARY KEY,
    login    VARCHAR NOT NULL,
    password VARCHAR NOT NULL,
    email    VARCHAR NOT NULL,
    role     Roles   NOT NULL DEFAULT 'client',
    UNIQUE (login),
    UNIQUE (email)
);
GRANT ALL ON TABLE public.users TO anonymous;
CREATE TABLE Clients
(
    userId         integer  NOT NULL REFERENCES users (userId) ON DELETE CASCADE ON UPDATE CASCADE,
    firstName      VARCHAR  NOT NULL,
    lastName       VARCHAR  NOT NULL,
    phone          CHAR(13) NOT NULL,
    dateOfBirthday DATE     NOT NULL,
    Address        VARCHAR  NOT NULL,
    UNIQUE (phone)
);

CREATE OR REPLACE FUNCTION getHotels()
    RETURNS TABLE
            (
                id          integer,
                title       character varying,
                description character varying,
                rating      integer,
                street      character varying,
                city        character varying,
                country     character varying
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT h.id,
               h.title,
               h.description,
               h.rating,
               a.title  AS street,
               c.title  AS city,
               co.title AS Country
        FROM hotels h
                 JOIN address a ON h.address = a.id
                 JOIN city c ON a.city = c.id
                 JOIN country co ON c.country = co.id;
END;
$$ LANGUAGE plpgSQL;
CREATE OR REPLACE FUNCTION clientRegistration(firstName varchar, lastName varchar, login varchar,
                                              email varchar, password varchar, phone CHAR(13),
                                              address varchar, DateOfBirthday date)
    RETURNS Void
AS
$$
DECLARE
    newId INT;
BEGIN
    INSERT INTO Users(login, password, email) VALUES (login, password, email);
    newId := currval(pg_get_serial_sequence('Users', 'userid'));
    INSERT INTO clients(userId, firstname, LastName, Phone, DateOfBirthday, Address)
    VALUES (newId, firstName, lastName, phone, DateOfBirthday, address);


END;
$$ LANGUAGE plpgSQL;
GRANT EXECUTE ON FUNCTION public.clientregistration(character varying, character varying, character varying, character varying, character varying, character, character varying, date) TO anonymous;

CREATE TABLE Employees
(
    userId         integer  NOT NULL REFERENCES users (userId) ON DELETE CASCADE ON UPDATE CASCADE,
    FirstName      VARCHAR  NOT NULL,
    LastName       VARCHAR  NOT NULL,
    Phone          CHAR(13) NOT NULL,
    Passport       VARCHAR  NOT NULL,
    Address        VARCHAR  NOT NULL,
    DateOfBirthday DATE     NOT NULL,
    EmploymentDate DATE     NOT NULL,
    UNIQUE (Passport),
    UNIQUE (Phone)
);

CREATE OR REPLACE FUNCTION employeesRegistration(firstName varchar, lastName varchar, login varchar,
                                                 email varchar, password varchar, phone CHAR(13),
                                                 address varchar, DateOfBirthday date,
                                                 EmploymentDate date, passport varchar)
    RETURNS Void
AS
$$
DECLARE
    newId INT;
BEGIN
    INSERT INTO Users(login, password, email, role) VALUES (login, password, email, 'manager');
    newId := currval(pg_get_serial_sequence('Users', 'userid'));
    INSERT INTO employees(userId, firstname, LastName, Phone, Passport, Address, DateOfBirthday,
                          EmploymentDate)
    VALUES (newId, firstName, lastName, phone, passport, address, DateOfBirthday, EmploymentDate);


END;
$$ LANGUAGE plpgSQL;
GRANT EXECUTE ON FUNCTION public.employeesRegistration(character varying, character varying, character varying, character varying, character varying, character, character varying, date, date, varchar) TO anonymous;

CREATE SCHEMA tokens AUTHORIZATION postgres;
CREATE TABLE tokens.blacklist
(
    id     SERIAL PRIMARY KEY,
    userId integer NOT NULL REFERENCES Clients (userId),
    token  VARCHAR NOT NULL
);
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO anonymous;
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO client;
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO director;
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO manager;

CREATE TABLE Country
(
    Id         SERIAL PRIMARY KEY,
    Title      VARCHAR NOT NULL,
    ArchivedAt DATE DEFAULT NULL,
    UNIQUE (Title)
);

CREATE TABLE City
(
    Id         SERIAL PRIMARY KEY,
    Country    integer NOT NULL REFERENCES Country (Id) ON DELETE CASCADE ON UPDATE CASCADE,
    Title      VARCHAR NOT NULL,
    ArchivedAt DATE DEFAULT NULL
);

CREATE TABLE Address
(
    Id         SERIAL PRIMARY KEY,
    City       integer NOT NULL REFERENCES City (Id) ON DELETE CASCADE ON UPDATE CASCADE,
    Title      VARCHAR NOT NULL,
    ArchivedAt DATE DEFAULT NULL
);

CREATE TABLE Hotels
(
    Id          SERIAL PRIMARY KEY,
    Title       VARCHAR NOT NULL,
    Description VARCHAR NOT NULL,
    Rating      integer NOT NULL,
    Address     integer NOT NULL REFERENCES Address (Id) ON DELETE CASCADE ON UPDATE CASCADE,
    ArchivedAt  DATE DEFAULT NULL,
    UNIQUE (Title)
);

CREATE TABLE Rooms
(
    Id          SERIAL PRIMARY KEY,
    Title       VARCHAR NOT NULL,
    Description VARCHAR NOT NULL,
    Places      integer NOT NULL,
    Price       integer NOT NULL,
    Hotel       integer NOT NULL REFERENCES Hotels (Id) ON DELETE CASCADE ON UPDATE CASCADE,
    Rating      integer NOT NULL,
    Quantity    integer NOT NULL,
    ArchivedAt  DATE DEFAULT NULL,
    UNIQUE (Title)
);
INSERT INTO Country
    (Title)
VALUES ('Ukraine');
INSERT INTO Country
    (Title)
VALUES ('USA');
INSERT INTO City
    (Country, title)
VALUES (1, 'Odessa');
INSERT INTO City
    (Country, title)
VALUES (1, 'Kiev');
INSERT INTO City
    (Country, title)
VALUES (1, 'Lviv');
INSERT INTO City
    (Country, title)
VALUES (2, 'Odessa');
INSERT INTO Address
    (city, title)
VALUES (1, 'Vitse Admirala Zhukova lane, 12');
INSERT INTO Address
    (city, title)
VALUES (4, 'площадь Соборная 12');
INSERT INTO Address
    (city, title)
VALUES (1, 'Дерибасовская ул.13');
INSERT INTO Address
    (city, title)
VALUES (2, '6 Polzunova Street4');
INSERT INTO Address
    (city, title)
VALUES (2, 'Zhylyanska Street 120 B');
INSERT INTO Address
    (city, title)
VALUES (2, 'Hospitalna Street 4');
INSERT INTO Address
    (city, title)
VALUES (3, 'Ulitsa Ustiyanovicha 8b, kvartira 1');
INSERT INTO Address
    (city, title)
VALUES (3, 'Solomii Krushel''nyts''koi Street 3/2');
INSERT INTO Address
    (city, title)
VALUES (3, 'улица Городоцкая 65');
INSERT INTO Address
    (city, title)
VALUES (3, 'Ploshcha Knyazya Svyatoslava 5');
