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
-- USERS ##################################
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
CREATE TABLE Tours
(
    Id          SERIAL PRIMARY KEY,
    Title       VARCHAR NOT NULL,
    Description VARCHAR NOT NULL,
    Price       integer NOT NULL,
    City        integer NOT NULL REFERENCES City (Id) ON DELETE CASCADE ON UPDATE CASCADE,
    Rating      integer NOT NULL,
    Preview     varchar NOT NULL,
    ArchivedAt  DATE DEFAULT NULL,
    UNIQUE (Title)
);
CREATE TABLE Hotels
(
    Id          SERIAL PRIMARY KEY,
    Title       VARCHAR NOT NULL,
    Description VARCHAR NOT NULL,
    Rating      integer NOT NULL,
    Address     integer NOT NULL REFERENCES Address (Id) ON DELETE CASCADE ON UPDATE CASCADE,
    Preview     varchar NOT NULL,
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
-- FUNCTIONS #############################
CREATE OR REPLACE FUNCTION getHotels()
    RETURNS TABLE
            (
                id          integer,
                title       character varying,
                description character varying,
                rating      integer,
                preview     character varying,
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
               h.preview,
               a.title  AS street,
               c.title  AS city,
               co.title AS Country
        FROM hotels h
                 JOIN address a ON h.address = a.id
                 JOIN city c ON a.city = c.id
                 JOIN country co ON c.country = co.id
        WHERE h.ArchivedAt IS NULL
        ORDER BY h.id DESC;
END;
$$ LANGUAGE plpgSQL;
CREATE OR REPLACE FUNCTION getHotels(hotelId int)
    RETURNS TABLE
            (
                id          integer,
                title       character varying,
                description character varying,
                rating      integer,
                preview     character varying,
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
               h.preview,
               a.title  AS street,
               c.title  AS city,
               co.title AS Country
        FROM hotels h
                 JOIN address a ON h.address = a.id
                 JOIN city c ON a.city = c.id
                 JOIN country co ON c.country = co.id
        WHERE h.ArchivedAt IS NULL
          AND h.id = hotelId;
END;
$$ LANGUAGE plpgSQL;
CREATE OR REPLACE FUNCTION getTours()
    RETURNS TABLE
            (
                id          integer,
                title       character varying,
                description character varying,
                price       integer,
                rating      integer,
                preview     character varying,
                city        character varying,
                country     character varying
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT t.id,
               t.title,
               t.description,
               t.price,
               t.rating,
               t.preview,
               c.title  AS city,
               co.title AS country
        FROM tours t
                 JOIN city c ON t.city = c.id
                 JOIN country co ON c.country = co.id
        WHERE t.ArchivedAt IS NULL
        ORDER BY t.id DESC;
END;
$$ LANGUAGE plpgSQL;
CREATE OR REPLACE FUNCTION getTours(tourId int)
    RETURNS TABLE
            (
                id          integer,
                title       character varying,
                description character varying,
                price       integer,
                rating      integer,
                preview     character varying,
                city        character varying,
                country     character varying
            )
AS
$$
BEGIN
    RETURN QUERY
        SELECT t.id,
               t.title,
               t.description,
               t.price,
               t.rating,
               t.preview,
               c.title  AS city,
               co.title AS country
        FROM tours t
                 JOIN city c ON t.city = c.id
                 JOIN country co ON c.country = co.id
        WHERE t.ArchivedAt IS NULL
          AND t.id = tourId;
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

-- INSERT ################################
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

-- INSERT Tours ########################
INSERT INTO Tours
    (title, description, price, city, rating, preview)
VALUES ('От Дюка до Дюка',
        'Те, кто уже стоял на люке, удивятся названию экскурсии. Обзорная экскурсия по Одессе в пять метров длиной? А вот и нет! Мы с вами пойдём в другую сторону. И таки придём к Дюку, но с другого боку.'
           , 150, 1, 5, 'link');
INSERT INTO Tours
    (title, description, price, city, rating, preview)
VALUES ('Мимо тёщиного дома',
        'Моя двоюродная мама, то бишь тёща Мария Григорьевна, живёт на углу улиц Богдана Хмельницкого и Запорожской. Как говорят в Одессе, «тот ещё райончик!». Вся бандитская Одесса выросла туточки. Полтора квартала до Еврейской больницы, Мясоедовская, Банный переулок, Прохоровская, Чумка – все тридцать три удовольствия… Сердце Молдаванки!!! Я рыдал бы вам в жилетку, если бы не два обстоятельства: первое – вы не видели, где она жила раньше!'
           , 150, 1, 5, 'link');
INSERT INTO Tours
    (title, description, price, city, rating, preview)
VALUES ('20000 лье под землей',
        'Сразу предупредим: это не экскурсия в обычном понимании этого слова. Правильнее это назвать — погружение в тайну. Чтоб не быть голословными, скажем: имея многолетний и многокилометровый опыт хождения в катакомбах, во многих участках этой подземной системы даже мы оказались впервые. Впрочем, как и большинство людей.'
           , 250, 1, 4, 'link');
INSERT INTO Tours
    (title, description, price, city, rating, preview)
VALUES ('Наше еврейское счастье',
        'Мы говорим «евреи», подразумеваем – «Одесса»! Мы говорим «Одесса», подразумеваем — «евреи». Маяковский, который в Одессе бывал, это знал наверняка. А стихи написал почему-то про Ленина и партию…'
           , 150, 1, 5, 'link');
INSERT INTO Tours
    (title, description, price, city, rating, preview)
VALUES ('Шоб Вы провалились!',
        'Как профессионалы (и люди кристально честные) мы должны признать: большинство экскурсий по Одессе похожи одна на другую – мы водим и возим наших гостей по Одессе и, показывая что-то за окном автобуса, рассказываем разные интересные истории. Хорошо, но… Но есть такая экскурсия, которую вам не проведут больше нигде! Она такая одна! Это экскурсия в одесские катакомбы.'
           , 250, 1, 5, 'link');
INSERT INTO Tours
    (title, description, price, city, rating, preview)
VALUES ('25 изюминок Киева',
        'В бесконечной спешке и суете мы зачастую пробегаем по городу, не замечая ничего вокруг. Мы не разглядываем здания и памятники, не заходим во дворики и переулочки, не присматриваемся к скверам и паркам. А там — много нового и интересного. Ведь Киев поистине неисчерпаем. Он как вкусный торт, богат изюминками, каждая из которых имеет свой особенный вкус.'
           , 120, 2, 5, 'link');
INSERT INTO Tours
    (title, description, price, city, rating, preview)
VALUES ('Шоколадная ночь в Шоколадном домике',
        'Когда опустятся на город вечерние тени и окутают его тайным предчувствием, чарующие Липки предстанут перед нами в своём несравненном архитектурном многообразии. Светотени вечера расцветят, изменят облик зданий, зажгут отблески в окнах, заиграют тонами и приоткроют двери в мир прошлого.'
           , 300, 2, 4, 'link');
INSERT INTO Tours
    (title, description, price, city, rating, preview)
VALUES ('Дренажно — штольная система «Никольская»',
        'Недалеко от Киево-Печерской лавры в глубине косогора в начале XX века была построена система подземных ходов. Старинная дренажная штольня насчитывает около трех километров подземных ходов на двух уровнях. Дело в том, что земля в этой местности очень насыщена водой, и это может привести к возникновению оползней, для искусственного осушения грунтов в глубине горы построены дренажные галереи. Строительство окончено в 1916 году, о чем свидетельствует соответствующий герб, перекрещенный якорь и топор, а под ним вышеупомянутая дата.'
           , 300, 2, 5, 'link');
INSERT INTO Tours
    (title, description, price, city, rating, preview)
VALUES ('ПЕШЕХОДНАЯ ЭКСКУРСИЯ СРЕДНЕВЕКОВЫЙ ЛЬВОВ',
        'На этой экскурсии по Львову вы узнаете, что Площадь Рынок, армянский, руський и еврейский кварталы Львова были заложены в середине XIV века и с приходом австрийцев составляли львовский центр города. То есть этот небольшой участок, площадью 600х600 метров фактически и был Львовом до конца XVIII века.'
           , 75, 3, 3, 'link');
INSERT INTO Tours
    (title, description, price, city, rating, preview)
VALUES ('ЭКСКУРСИЯ СЕМЬ ЧУДЕС ЛЬВОВА',
        'Во  Львове нет объектов, которые входят в список Семи чудес Украины. Но  для нас, украинцев, Львов – это одно большое чудо. '
           , 80, 3, 4, 'link');

-- INSERT HOTELS
INSERT INTO Hotels
(title, description, rating, address)
VALUES('Wall Street',
'Отель Wall Street расположен в Приморском районе Одессы, в 300 метрах от улицы Дерибасовской и в 700 метрах от Одесского театра оперы и балета. К услугам гостей терраса и круглосуточная стойка регистрации.'
, 4, 1);INSERT INTO Hotels
(title, description, rating, address)
VALUES('arenda24-2 Deribasovskaya',
'Комплекс «Аренда24-2 Дерибасовская» с видом на сад расположен в Приморском районе Одессы. К услугам гостей кондиционер и патио. Из апартаментов с балконом открывается вид на город.'
, 4, 2);INSERT INTO Hotels
(title, description, rating, address)
VALUES('Feeria Apartment Deribasovskaya',
'Апартаменты «Феерия Дерибасовская» расположены в Одессе, в 400 м от Одесского театра оперы и балета. К услугам гостей кондиционер, бесплатный Wi-Fi и терраса.'
, 4, 3);INSERT INTO Hotels
(title, description, rating, address)
VALUES('ibis Kiev Railway Station',
'Отель «Ibis Киев Вокзал» расположен в Киеве, всего в 2 минутах ходьбы от главного железнодорожного вокзала и остановки автобуса, следующего до международного аэропорта. К услугам гостей полностью оборудованные конференц-залы и бесплатный Wi-Fi.'
, 3, 4);INSERT INTO Hotels
(title, description, rating, address)
VALUES('irisHotels',
'Этот отель находится в 3 минутах ходьбы от станции метро «Вокзальная» и железнодорожного вокзала Киева. К услугам гостей бесплатный Wi-Fi и круглосуточная стойка регистрации. В номерах и апартаментах отеля установлен телевизор с плоским экраном.'
, 4, 5);INSERT INTO Hotels
(title, description, rating, address)
VALUES('Сити Парк Отель Откроется в новом окне',
'Бутик-отель «Сити Парк» расположен в центре Киева. К услугам гостей роскошные номера с кондиционером, бесплатным Wi-Fi и плазменным телевизором. На территории обустроена бесплатная частная парковка.'
, 4, 6);INSERT INTO Hotels
(title, description, rating, address)
VALUES('Kvartira 157B on Tashkentskaya 24/1',
'Апартаменты «157Б на Ташкентской 24/1» расположены в московском районе Выхино-Жулебино, в 12 км от Николо-Угрешского монастыря. В 14 км находится парк «Зарядье», а в 15 км — Мавзолей В. И. Ленина. Предоставляется бесплатный Wi-Fi.'
, 3, 7);INSERT INTO Hotels
(title, description, rating, address)
VALUES('Apartment on Pozhyaki',
'Апартаменты «На Пожяки» с видом на город, балконом и чайником расположены в 11 км от Международного выставочного центра. Апартаменты расположены в здании, построенном в 2015 году, в 11 км от монумента «Родина-мать зовет!» и в 12 км от музея микроминиатюр Микола Сюадрисы. Предоставляется бесплатный Wi-Fi.'
, 3, 8);INSERT INTO Hotels
(title, description, rating, address)
VALUES('Cute Apartment in the City Center',
'Апартаменты Cute in the City Center in Lviv с бесплатным Wi-Fi расположены в 400 м от Львовского национального университета имени Ивана Франко, в 800 м от собора Святого Георгия и менее чем в 1 км от дворца Потоцких. Расстояние до театра Марии Мария составляет 1,5 км, а до Львовского кафедрального собора — 1,8 км.'
, 4, 9);INSERT INTO Hotels
(title, description, rating, address)
VALUES('Two-bedroom apartment near the station',
'Апартаменты «Около вокзала» с бесплатным Wi-Fi и балконом расположены в городе Львов, в 500 метрах от церкви святого Георгия Победоносца. В числе удобств — бесплатная частная парковка. Львовский железнодорожный вокзал и центр города находятся в 20 минутах ходьбы.'
, 3, 10);
-- Token ########################
CREATE SCHEMA tokens AUTHORIZATION postgres;
CREATE TABLE tokens.blacklist
(
    id     SERIAL PRIMARY KEY,
    userId integer NOT NULL REFERENCES users (userId) ON DELETE CASCADE ON UPDATE CASCADE,
    token  VARCHAR NOT NULL
);
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO anonymous;
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO client;
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO director;
GRANT INSERT, SELECT ON TABLE tokens.blacklist TO manager;
