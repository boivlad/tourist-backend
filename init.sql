-- Database: Tourist agency
CREATE USER anonymous;
CREATE SCHEMA tokens AUTHORIZATION postgres;
GRANT USAGE ON SCHEMA tokens TO anonymous
WITH
GRANT OPTION;
GRANT ALL ON SCHEMA tokens TO client
WITH
GRANT OPTION;
GRANT ALL ON SCHEMA tokens TO director
WITH
GRANT OPTION;
GRANT ALL ON SCHEMA tokens TO manager
WITH
GRANT OPTION;

CREATE DOMAIN OrderStatus VARCHAR CHECK
(VALUE IN
('New', 'Conform', 'Ready'));
CREATE DOMAIN Roles VARCHAR CHECK
(VALUE IN
('client', 'manager', 'director', 'anonymous'));

CREATE OR REPLACE FUNCTION clientRegistration(firstName varchar, lastName varchar, login varchar,
	email varchar, password varchar, phone CHAR(13), address varchar, DateOfBirthday date)
						RETURNS Void
	AS $$
		BEGIN
			SET _new_id;
			_new_id := INSERT INTO clients(FirstName, LastName, Phone, DateOfBirthday, Address) VALUES(firstName, lastName, phone, DateOfBirthday, address) RETURNING userId;
			INSERT INTO Users(userId, login, password, email) VALUES(_new_id, login, password, email);
		END;
$$ LANGUAGE plpgSQL;
CREATE TABLE Users
(
userId SERIAL PRIMARY KEY,
login VARCHAR NOT NULL,
password VARCHAR NOT NULL,
email VARCHAR NOT NULL,
role Roles NOT NULL DEFAULT 'client'
);

CREATE TABLE tokens.auth
(
id SERIAL PRIMARY KEY,
tokenId VARCHAR NOT NULL,
userId integer NOT NULL REFERENCES public.users(userId)
);

CREATE TABLE Clients
(
UserId SERIAL PRIMARY KEY,
FirstName VARCHAR NOT NULL,
LastName VARCHAR NOT NULL,
Phone CHAR(13)NOT NULL,
DateOfBirthday DATE NOT NULL,
Address VARCHAR NOT NULL
);

CREATE TABLE Employees
(
Id SERIAL PRIMARY KEY,
FirstName VARCHAR NOT NULL,
LastName VARCHAR NOT NULL,
Email VARCHAR NOT NULL,
Phone CHAR(13)NOT NULL,
Passport VARCHAR NOT NULL,
	Address VARCHAR NOT NULL,
	DateOfBirthday DATE NOT NULL,
	Password VARCHAR NOT NULL,
	EmploymentDate DATE NOT NULL
);

CREATE TABLE Country
(
	Id SERIAL PRIMARY KEY,
	Title VARCHAR NOT NULL,
	ArchivedAt DATE DEFAULT NULL
);

CREATE TABLE City
(
	Id SERIAL PRIMARY KEY,
	Country integer NOT NULL REFERENCES Country(Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Title VARCHAR NOT NULL,
	ArchivedAt DATE DEFAULT NULL
);

CREATE TABLE Address
(
	Id SERIAL PRIMARY KEY,
	City integer NOT NULL REFERENCES City(Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Title VARCHAR NOT NULL,
	ArchivedAt DATE DEFAULT NULL
);

CREATE TABLE Hotels
(
	Id SERIAL PRIMARY KEY,
	Title VARCHAR NOT NULL,
	Description VARCHAR NOT NULL,
	Rating integer NOT NULL,
	Address integer NOT NULL REFERENCES Address(Id) ON DELETE CASCADE ON UPDATE CASCADE,
	ArchivedAt DATE DEFAULT NULL
);

CREATE TABLE Rooms
(
	Id SERIAL PRIMARY KEY,
	Title VARCHAR NOT NULL,
	Description VARCHAR NOT NULL,
	Places integer NOT NULL,
	Price integer NOT NULL,
	Hotel integer NOT NULL REFERENCES Hotels(Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Rating integer NOT NULL,
	Quantity integer NOT NULL,
	ArchivedAt DATE DEFAULT NULL
);

CREATE TABLE Tours
(
	Id SERIAL PRIMARY KEY,
	Title VARCHAR NOT NULL,
	Description VARCHAR NOT NULL,
	Price integer NOT NULL,
	City integer NOT NULL REFERENCES City(Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Rating integer NOT NULL
);

CREATE TABLE Transfers
(
	Id SERIAL PRIMARY KEY,
	Title VARCHAR NOT NULL,
	Description VARCHAR NOT NULL,
	Places integer NOT NULL,
	Price integer NOT NULL,
	City integer NOT NULL REFERENCES City(Id) ON DELETE CASCADE ON UPDATE CASCADE,
Rating integer NOT NULL
);CREATE TABLE RoomsFeedBack
(
Id SERIAL PRIMARY KEY,
Room integer NOT NULL REFERENCES Rooms(Id)ON DELETE CASCADE ON UPDATE CASCADE,
Title VARCHAR NOT NULL,
Details VARCHAR NOT NULL,
Rating integer NOT NULL,
UserId integer NOT NULL REFERENCES Clients(UserId)ON DELETE CASCADE ON UPDATE CASCADE,
Date DATE NOT NULL
);CREATE TABLE TourFeedBack
(
Id SERIAL PRIMARY KEY,
Tour integer NOT NULL REFERENCES Tours(Id)ON DELETE CASCADE ON UPDATE CASCADE,
Title VARCHAR NOT NULL,
Details VARCHAR NOT NULL,
Rating integer NOT NULL,
UserId integer NOT NULL REFERENCES Clients(UserId)ON DELETE CASCADE ON UPDATE CASCADE,
Date DATE NOT NULL
);CREATE TABLE TransferFeedBack
(
Id SERIAL PRIMARY KEY,
Transfer integer NOT NULL REFERENCES Transfers(Id)ON DELETE CASCADE ON UPDATE CASCADE,
Title VARCHAR NOT NULL,
Details VARCHAR NOT NULL,
Rating integer NOT NULL,
UserId integer NOT NULL REFERENCES Clients(UserId)ON DELETE CASCADE ON UPDATE CASCADE,
Date DATE NOT NULL
);CREATE TABLE RoomOrders
(
OrderNumber SERIAL PRIMARY KEY,
UserId integer NOT NULL REFERENCES Clients(UserId)ON DELETE CASCADE ON UPDATE CASCADE,
Room integer NOT NULL REFERENCES Rooms(Id)ON DELETE CASCADE ON UPDATE CASCADE,
StartDate DATE NOT NULL,
EndDate DATE NOT NULL,
Places integer NOT NULL,
Prices integer NOT NULL,
OrderDate DATE NOT NULL,
InsurancePolicy VARCHAR NOT NULL,
Status OrderStatus NOT NULL,
Manager integer NOT NULL REFERENCES Employees(Id)ON DELETE CASCADE ON UPDATE CASCADE
);CREATE TABLE TourOrders
(
OrderNumber SERIAL PRIMARY KEY,
UserId integer NOT NULL REFERENCES Clients(UserId)ON DELETE CASCADE ON UPDATE CASCADE,
Tour integer NOT NULL REFERENCES Tours(Id)ON DELETE CASCADE ON UPDATE CASCADE,
StartDate DATE NOT NULL,
EndDate DATE NOT NULL,
Places integer NOT NULL,
Prices integer NOT NULL,
OrderDate DATE NOT NULL,
InsurancePolicy VARCHAR NOT NULL,
Status OrderStatus NOT NULL,
Manager integer NOT NULL REFERENCES Employees(Id)ON DELETE CASCADE ON UPDATE CASCADE
);CREATE TABLE TransferOrders
(
OrderNumber SERIAL PRIMARY KEY,
UserId integer NOT NULL REFERENCES Clients(UserId)ON DELETE CASCADE ON UPDATE CASCADE,
Transfer integer NOT NULL REFERENCES Transfers(Id)ON DELETE CASCADE ON UPDATE CASCADE,
StartDate DATE NOT NULL,
EndDate DATE NOT NULL,
Places integer NOT NULL,
Prices integer NOT NULL,
OrderDate DATE NOT NULL,
InsurancePolicy VARCHAR NOT NULL,
Status OrderStatus NOT NULL,
Manager integer NOT NULL REFERENCES Employees(Id)ON DELETE CASCADE ON UPDATE CASCADE
);#--------------------------------------------------------------------------------------
# -------FUNCTIONS
DROP FUNCTION gethotels();CREATE OR REPLACE FUNCTION testGetHotels()
RETURNS table(id integer, title varchar, description varchar, rating integer, street varchar, city
varchar, Country varchar)AS $BODY$ BEGIN return query SELECT h.id, h.title, h.description, h.rating,
a.title AS street, c.title AS city, co.title AS Country FROM hotels h JOIN address a ON h.address =
a.id JOIN city c ON a.city = c.id JOIN country co ON c.country = co.id;END;$BODY$
LANGUAGE plpgsql;
# --------------------------------------------------------------------------------------
# -------INSERTS
INSERT INTO Country
(Title)
VALUES('Ukraine');INSERT INTO Country
(Title)
VALUES('USA');INSERT INTO City
(Country, title)
VALUES(1, 'Odessa');INSERT INTO City
(Country, title)
VALUES(1, 'Kiev');INSERT INTO City
(Country, title)
VALUES(1, 'Lviv');INSERT INTO City
(Country, title)
VALUES(2, 'Odessa');INSERT INTO Address
(city, title)
VALUES(1, 'Vitse Admirala Zhukova lane, 12');INSERT INTO Address
(city, title)
VALUES(4, 'площадь Соборная 12');INSERT INTO Address
(city, title)
VALUES(1, 'Дерибасовская ул.13');INSERT INTO Address
(city, title)
VALUES(2, '6 Polzunova Street4');INSERT INTO Address
(city, title)
VALUES(2, 'Zhylyanska Street 120 B');INSERT INTO Address
(city, title)
VALUES(2, 'Hospitalna Street 4');INSERT INTO Address
(city, title)
VALUES(3, 'Ulitsa Ustiyanovicha 8b, kvartira 1');INSERT INTO Address
(city, title)
VALUES(3, 'Solomii Krushel''nyts''koi Street 3/2');INSERT INTO Address
(city, title)
VALUES(3, 'улица Городоцкая 65');INSERT INTO Address
(city, title)
VALUES(3, 'Ploshcha Knyazya Svyatoslava 5');
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
, 3, 10);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный двухместный номер с 2 отдельными кроватями',
'Звукоизолированный двухместный номер с 2 отдельными кроватями, мини-баром и халатами.', 2, 250, 1,
5, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный одномесный номер', 'Звукоизолированный одномесный номер, мини-баром и халатом.',
1, 150, 1, 5, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный двухместный номер с 2 отдельными кроватями',
'Звукоизолированный двухместный номер с 2 отдельными кроватями, мини-баром и халатами.', 2, 230, 2,
4, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный одномесный номер', 'Звукоизолированный одномесный номер, мини-баром и халатом.',
1, 120, 2, 4, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный двухместный номер с 2 отдельными кроватями',
'Звукоизолированный двухместный номер с 2 отдельными кроватями, мини-баром и халатами.', 2, 245, 3,
4, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный одномесный номер', 'Звукоизолированный одномесный номер, мини-баром и халатом.',
1, 130, 3, 3, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный двухместный номер с 2 отдельными кроватями',
'Звукоизолированный двухместный номер с 2 отдельными кроватями, мини-баром и халатами.', 2, 240, 4,
4, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный одномесный номер', 'Звукоизолированный одномесный номер, мини-баром и халатом.',
1, 140, 4, 4, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный двухместный номер с 2 отдельными кроватями',
'Звукоизолированный двухместный номер с 2 отдельными кроватями, мини-баром и халатами.', 2, 225, 5,
4, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный одномесный номер', 'Звукоизолированный одномесный номер, мини-баром и халатом.',
1, 150, 5, 5, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный двухместный номер с 2 отдельными кроватями',
'Звукоизолированный двухместный номер с 2 отдельными кроватями, мини-баром и халатами.', 2, 300, 6,
5, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный одномесный номер', 'Звукоизолированный одномесный номер, мини-баром и халатом.',
1, 160, 6, 5, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный двухместный номер с 2 отдельными кроватями',
'Звукоизолированный двухместный номер с 2 отдельными кроватями, мини-баром и халатами.', 2, 260, 7,
5, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный одномесный номер', 'Звукоизолированный одномесный номер, мини-баром и халатом.',
1, 145, 7, 4, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный двухместный номер с 2 отдельными кроватями',
'Звукоизолированный двухместный номер с 2 отдельными кроватями, мини-баром и халатами.', 2, 270, 8,
5, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный одномесный номер', 'Звукоизолированный одномесный номер, мини-баром и халатом.',
1, 155, 8, 5, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный двухместный номер с 2 отдельными кроватями',
'Звукоизолированный двухместный номер с 2 отдельными кроватями, мини-баром и халатами.', 2, 280, 9,
5, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный одномесный номер', 'Звукоизолированный одномесный номер, мини-баром и халатом.',
1, 135, 9, 3, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный двухместный номер с 2 отдельными кроватями',
'Звукоизолированный двухместный номер с 2 отдельными кроватями, мини-баром и халатами.', 2, 290, 10,
5, 50);INSERT INTO Rooms
(title, description, places, price, hotel, rating, quantity)
VALUES('Стандартный одномесный номер', 'Звукоизолированный одномесный номер, мини-баром и халатом.',
1, 105, 10, 3, 50);INSERT INTO Tours
(title, description, price, city, rating)
VALUES('От Дюка до Дюка',
'Те, кто уже стоял на люке, удивятся названию экскурсии. Обзорная экскурсия по Одессе в пять метров длиной? А вот и нет! Мы с вами пойдём в другую сторону. И таки придём к Дюку, но с другого боку.'
, 150, 1, 5);INSERT INTO Tours
(title, description, price, city, rating)
VALUES('Мимо тёщиного дома',
'Моя двоюродная мама, то бишь тёща Мария Григорьевна, живёт на углу улиц Богдана Хмельницкого и Запорожской. Как говорят в Одессе, «тот ещё райончик!». Вся бандитская Одесса выросла туточки. Полтора квартала до Еврейской больницы, Мясоедовская, Банный переулок, Прохоровская, Чумка – все тридцать три удовольствия… Сердце Молдаванки!!! Я рыдал бы вам в жилетку, если бы не два обстоятельства: первое – вы не видели, где она жила раньше!'
, 150, 1, 5);INSERT INTO Tours
(title, description, price, city, rating)
VALUES('20000 лье под землей',
'Сразу предупредим: это не экскурсия в обычном понимании этого слова. Правильнее это назвать — погружение в тайну. Чтоб не быть голословными, скажем: имея многолетний и многокилометровый опыт хождения в катакомбах, во многих участках этой подземной системы даже мы оказались впервые. Впрочем, как и большинство людей.'
, 250, 1, 4);INSERT INTO Tours
(title, description, price, city, rating)
VALUES('Наше еврейское счастье',
'Мы говорим «евреи», подразумеваем – «Одесса»! Мы говорим «Одесса», подразумеваем — «евреи». Маяковский, который в Одессе бывал, это знал наверняка. А стихи написал почему-то про Ленина и партию…'
, 150, 1, 5);INSERT INTO Tours
(title, description, price, city, rating)
VALUES('Шоб Вы провалились!',
'Как профессионалы (и люди кристально честные) мы должны признать: большинство экскурсий по Одессе похожи одна на другую – мы водим и возим наших гостей по Одессе и, показывая что-то за окном автобуса, рассказываем разные интересные истории. Хорошо, но… Но есть такая экскурсия, которую вам не проведут больше нигде! Она такая одна! Это экскурсия в одесские катакомбы.'
, 250, 1, 5);INSERT INTO Tours
(title, description, price, city, rating)
VALUES('25 изюминок Киева',
'В бесконечной спешке и суете мы зачастую пробегаем по городу, не замечая ничего вокруг. Мы не разглядываем здания и памятники, не заходим во дворики и переулочки, не присматриваемся к скверам и паркам. А там — много нового и интересного. Ведь Киев поистине неисчерпаем. Он как вкусный торт, богат изюминками, каждая из которых имеет свой особенный вкус.'
, 120, 2, 5);INSERT INTO Tours
(title, description, price, city, rating)
VALUES('Шоколадная ночь в Шоколадном домике',
'Когда опустятся на город вечерние тени и окутают его тайным предчувствием, чарующие Липки предстанут перед нами в своём несравненном архитектурном многообразии. Светотени вечера расцветят, изменят облик зданий, зажгут отблески в окнах, заиграют тонами и приоткроют двери в мир прошлого.'
, 300, 2, 4);INSERT INTO Tours
(title, description, price, city, rating)
VALUES('Дренажно — штольная система «Никольская»',
'Недалеко от Киево-Печерской лавры в глубине косогора в начале XX века была построена система подземных ходов. Старинная дренажная штольня насчитывает около трех километров подземных ходов на двух уровнях. Дело в том, что земля в этой местности очень насыщена водой, и это может привести к возникновению оползней, для искусственного осушения грунтов в глубине горы построены дренажные галереи. Строительство окончено в 1916 году, о чем свидетельствует соответствующий герб, перекрещенный якорь и топор, а под ним вышеупомянутая дата.'
, 300, 2, 5);INSERT INTO Tours
(title, description, price, city, rating)
VALUES('ПЕШЕХОДНАЯ ЭКСКУРСИЯ СРЕДНЕВЕКОВЫЙ ЛЬВОВ',
'На этой экскурсии по Львову вы узнаете, что Площадь Рынок, армянский, руський и еврейский кварталы Львова были заложены в середине XIV века и с приходом австрийцев составляли львовский центр города. То есть этот небольшой участок, площадью 600х600 метров фактически и был Львовом до конца XVIII века.'
, 75, 3, 3);INSERT INTO Tours
(title, description, price, city, rating)
VALUES('ЭКСКУРСИЯ СЕМЬ ЧУДЕС ЛЬВОВА',
'Во  Львове нет объектов, которые входят в список Семи чудес Украины. Но  для нас, украинцев, Львов – это одно большое чудо. '
, 80, 3, 4);INSERT INTO Transfers
(title, description, places, price, city, rating)
VALUES('Lexus ES300H',
'Модель Lexus ES300H завоевала у наших пассажиров высокие оценки за комфорт, утонченность и роскошь. В премиальном авто Lexus ES300H Вы ощутите все преимущества наивысшего уровня тишины, системы контроля звуков и шумов.'
, 4, 700, 1, 5);INSERT INTO Transfers
(title, description, places, price, city, rating)
VALUES('Mercedes Sprinter 2009',
'Внешний вид Mercedes Sprinter отвечает современной дизайн-концепции Mercedes-Benz «Чистота восприятия». Комфортабельность микроавтобуса достигнута благодаря усовершенствованному дизайну и высокому уровню функциональности.'
, 19, 540, 1, 5);INSERT INTO Transfers
(title, description, places, price, city, rating)
VALUES('Mercedes S Class',
'В этом автомобиле элегантность и динамика, комфорт и безопасность продуманы до мельчайшей детали. Особенности оснащения экстерьера, интерьера и мастерство техники возводит модель Mercedes S Class в лигу высокомощных суперкаров. При этом автомобиль очень удобен для трансфера по городу и стране.'
, 4, 1500, 1, 5);INSERT INTO Transfers
(title, description, places, price, city, rating)
VALUES('Mercedes G55',
'Mercedes G55 – легендарный внедорожник люкс-класса компании Mercedes-Benz, получивший всемирную популярность.'
, 4, 2080, 1, 5);INSERT INTO Transfers
(title, description, places, price, city, rating)
VALUES('Chevrolet Spark',
'Новый Chevrolet Spark – компактный и стильный, способен удивить своей вместимостью и внутренним убранством салона. Компания Rental предлагает вам убедиться лично в комфорте данного автомобиля – прокат Chevrolet Spark предложен на оптимальных условиях. Спортивный экстерьер, современное техническое обеспечение, экономичность (расход топлива невелик при объеме двигателя 1,25 л), безопасность – все эти факторы способствуют увеличению популярности небольшого автомобиля у поклонников современного транспорта. Аренда Chevrolet Spark – это возможность на время стать обладателем комфортного авто за небольшую плату.'
, 4, 700, 2, 4);INSERT INTO Transfers
(title, description, places, price, city, rating)
VALUES('Suzuki Vitara III',
'Что может быть лучше высокотехнологичного компьютеризированного внедорожника японского производства? Компания Rental предлагает гостям и жителям столицы взять на прокат Suzuki Vitara III и передвигаться по любой дороге с максимальным комфортом.'
, 4, 1400, 2, 4);INSERT INTO Transfers
(title, description, places, price, city, rating)
VALUES('Ford Fiesta VI AT',
'Прокат Ford Fiesta VI AT осуществляется на оптимальных условиях. Автомобили, предлагаемые к прокату компанией Rental, проходят своевременное обслуживание и техосмотр, застрахованы и абсолютно безопасны. Необходимое условие, которое требуется соблюсти желающим воспользоваться услугами компании – аренда Ford Fiesta VI AT доступна обладателям стажа вождения не меньше 2-х лет и действующего водительского удостоверения.'
, 4, 1000, 2, 5);INSERT INTO Transfers
(title, description, places, price, city, rating)
VALUES('Chevrolet Spark',
'Внешне забавный и угловатый автомобиль с большой оптикой, несколько агрессивным задним бампером и веселым дизайном. Все большее число украинцев предпочитают взять Шевроле Спарк на прокат для загородных поездок или комфортного и безопасного передвижения по запруженным транспортом городским улицам.'
, 4, 700, 3, 4);INSERT INTO Transfers
(title, description, places, price, city, rating)
VALUES('Toyota Corolla E16/E17',
'Японский седан, который относится к среднему классу, удачно объединил в себе современные технические и дизайнерские наработки. В компании Rental вы без особых финансовых вложений оцените роскошь и комфорт салона, отличную динамику движения. Машина превосходно ведет себя на городских улицах и загородных дорогах.'
, 4, 1000, 3, 5);INSERT INTO Transfers
(title, description, places, price, city, rating)
VALUES('Mitsubishi Lancer X AT',
'Удобный седан всемирно известного японского бренда с неповторимым стилем и техническими характеристиками. Mitsubishi Lancer Х в аренду востребован для самых разных целей: выездов на природу, путешествия с семьей или компанией, деловых поездок, прочих личных потребностей.'
, 4, 1500, 3, 5);INSERT INTO Clients
(firstname, lastname, email, phone, dateofbirthday, address, password)
VALUES('Владислав', 'Бойченко', 'boyblad99@gmail.com', '0965870700', '22.10.1999',
'Одесса, Лиманский район', '435CDF467F5D017DC8D9F5B04C9607F6');INSERT INTO Clients
(firstname, lastname, email, phone, dateofbirthday, address, password)
VALUES('Павел', 'Адаменко', 'zelendoren@gmail.com', '0508475637', '13.07.1999',
'Одесса, Киевский район', 'F6B67BB3DD47C98AB085D6C109BAF6A4');INSERT INTO employees
(firstname, lastname, email, phone, passport, address, dateofbirthday, password, employmentdate)
VALUES('Эзерович', 'Дарья', 'dmelion@gmail.com', '0667529042', 'KM54862', 'Одесса, Приморский',
'04.02.2000', 'A7B5DD99F036DF9A6108BCFAC70125D6', '15.11.2019');INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(1, 'Превосходно',
'Просторный, чистый номер. Все необходимое есть в наличии. Чистое постельное белье. Хороший завтрак. Голодными не уйдёте. Рекомендую!'
, 10, 1, '13.11.2019');INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(2, 'Великолепно',
'Очень приятный и вежливый персонал. Чистые удобные номера. Хорошее расположение в центре города. В следующий раз обязательно остановимся здесь.'
, 10, 2, '12.11.2019');INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(1, 'Превосходно',
'Отель расположен в очень хорошем месте. Близко к основным достопримечательностям. Все в пешей доступности. Приветливый персонал, большие номера, новая мебель!!'
, 9, 1, '03.11.2019');INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(3, 'Очень уютный', 'Хорошее место расположение, чистые номера, вежливый персонал!', 10, 2,
'13.10.2019');INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(4, 'Великолепно',
'Удобное расположение, вкусные, разнообразные завтраки, удобные матрасы, собственная стоянка авто, отзывчивый персонал, чистые номера.'
, 10, 1, '10.11.2019');INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(5, 'Одесса - жемчужина у моря',
'Отель расположен в тихом переулке в 2 мин ходьбы от Дерибасовской. Персонал просто лучший! Сначала поселили в прокуренный номер ( в отеле курить запрещено) не успели спуститься со второго этажа и предъявить на ресепшн свои недовольные лица, а нам уже предложили номер выше классом ( горничная по рации передала, что мы хотим поменять номер). Отель новый и в номере, естественно все новое: сантехника, мебель. Особо понравился мини-бар, хороший ассортимент и умеренные цены. Очень хорошие и разнообразные завтраки. Бесплатная стоянка.'
, 10, 2, '04.11.2019');INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(6, 'Великолепно',
'Все было отлично. Отель прекрасно расположен, в центре города,в шаговой доступности от многих достопримечательностей. Приветливый персонал, вкусные, сытные завтраки. Номера большие и красивые. Кровать удобная.'
, 9, 1, '06.11.2019');INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(7, 'Великолепно',
'Новый и чистый отель в самом центре города. Не шумно, все очень стильно и аккуратно', 10, 1,
'18.10.2019');INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(8, 'Шикарно, тихо и спокойно.',
'Шикарное месторасположение в центре Одессы на тихой улочке, где идеальная тишина и спокойствие. Потрясающий запах в отеле, чистота, выдержан стиль в каждой детали. Очень удобная кровать, прекрасная система кондиционирования, продумано все до мелочей.'
, 8, 2, '13.09.2019');INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(9, 'Достаточно хорошо', 'Отсутствует питание (очень низкое касество)', 6, 2, '14.10.2019');
INSERT INTO roomsfeedback
(room, title, details, rating, userid, date)
VALUES(10, 'С виду неплохо, по факту ужасно',
'Вопросы начались при заселении, заехали в улучшенный номер, на раковине лобковые волосы (много!!!), в мусорке мусор. Позвонила на ресепш попросила убрать, убрали, но никто не извинился. Вопрос, как вообще убирали? Завтрак откровенно скудный. '
, 5, 2, '11.08.2019');INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(1, 'Превосходно',
'Просторный, чистый номер. Все необходимое есть в наличии. Чистое постельное белье. Хороший завтрак. Голодными не уйдёте. Рекомендую!'
, 10, 1, '13.11.2019');INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(2, 'Великолепно',
'Очень приятный и вежливый персонал. Чистые удобные номера. Хорошее расположение в центре города. В следующий раз обязательно остановимся здесь.'
, 10, 2, '12.11.2019');INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(1, 'Превосходно',
'Отель расположен в очень хорошем месте. Близко к основным достопримечательностям. Все в пешей доступности. Приветливый персонал, большие номера, новая мебель!!'
, 9, 1, '03.11.2019');INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(3, 'Очень уютный', 'Хорошее место расположение, чистые номера, вежливый персонал!', 10, 2,
'13.10.2019');INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(4, 'Великолепно',
'Удобное расположение, вкусные, разнообразные завтраки, удобные матрасы, собственная стоянка авто, отзывчивый персонал, чистые номера.'
, 10, 1, '10.11.2019');INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(5, 'Одесса - жемчужина у моря',
'Отель расположен в тихом переулке в 2 мин ходьбы от Дерибасовской. Персонал просто лучший! Сначала поселили в прокуренный номер ( в отеле курить запрещено) не успели спуститься со второго этажа и предъявить на ресепшн свои недовольные лица, а нам уже предложили номер выше классом ( горничная по рации передала, что мы хотим поменять номер). Отель новый и в номере, естественно все новое: сантехника, мебель. Особо понравился мини-бар, хороший ассортимент и умеренные цены. Очень хорошие и разнообразные завтраки. Бесплатная стоянка.'
, 10, 2, '04.11.2019');INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(6, 'Великолепно',
'Все было отлично. Отель прекрасно расположен, в центре города,в шаговой доступности от многих достопримечательностей. Приветливый персонал, вкусные, сытные завтраки. Номера большие и красивые. Кровать удобная.'
, 9, 1, '06.11.2019');INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(7, 'Великолепно',
'Новый и чистый отель в самом центре города. Не шумно, все очень стильно и аккуратно', 10, 1,
'18.10.2019');INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(8, 'Шикарно, тихо и спокойно.',
'Шикарное месторасположение в центре Одессы на тихой улочке, где идеальная тишина и спокойствие. Потрясающий запах в отеле, чистота, выдержан стиль в каждой детали. Очень удобная кровать, прекрасная система кондиционирования, продумано все до мелочей.'
, 8, 2, '13.09.2019');INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(9, 'Достаточно хорошо', 'Отсутствует питание (очень низкое касество)', 6, 2, '14.10.2019');
INSERT INTO tourfeedback
(tour, title, details, rating, userid, date)
VALUES(10, 'С виду неплохо, по факту ужасно',
'Вопросы начались при заселении, заехали в улучшенный номер, на раковине лобковые волосы (много!!!), в мусорке мусор. Позвонила на ресепш попросила убрать, убрали, но никто не извинился. Вопрос, как вообще убирали? Завтрак откровенно скудный. '
, 5, 2, '11.08.2019');INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(1, 'Превосходно',
'Просторный, чистый номер. Все необходимое есть в наличии. Чистое постельное белье. Хороший завтрак. Голодными не уйдёте. Рекомендую!'
, 10, 1, '13.11.2019');INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(2, 'Великолепно',
'Очень приятный и вежливый персонал. Чистые удобные номера. Хорошее расположение в центре города. В следующий раз обязательно остановимся здесь.'
, 10, 2, '12.11.2019');INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(1, 'Превосходно',
'Отель расположен в очень хорошем месте. Близко к основным достопримечательностям. Все в пешей доступности. Приветливый персонал, большие номера, новая мебель!!'
, 9, 1, '03.11.2019');INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(3, 'Очень уютный', 'Хорошее место расположение, чистые номера, вежливый персонал!', 10, 2,
'13.10.2019');INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(4, 'Великолепно',
'Удобное расположение, вкусные, разнообразные завтраки, удобные матрасы, собственная стоянка авто, отзывчивый персонал, чистые номера.'
, 10, 1, '10.11.2019');INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(5, 'Одесса - жемчужина у моря',
'Отель расположен в тихом переулке в 2 мин ходьбы от Дерибасовской. Персонал просто лучший! Сначала поселили в прокуренный номер ( в отеле курить запрещено) не успели спуститься со второго этажа и предъявить на ресепшн свои недовольные лица, а нам уже предложили номер выше классом ( горничная по рации передала, что мы хотим поменять номер). Отель новый и в номере, естественно все новое: сантехника, мебель. Особо понравился мини-бар, хороший ассортимент и умеренные цены. Очень хорошие и разнообразные завтраки. Бесплатная стоянка.'
, 10, 2, '04.11.2019');INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(6, 'Великолепно',
'Все было отлично. Отель прекрасно расположен, в центре города,в шаговой доступности от многих достопримечательностей. Приветливый персонал, вкусные, сытные завтраки. Номера большие и красивые. Кровать удобная.'
, 9, 1, '06.11.2019');INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(7, 'Великолепно',
'Новый и чистый отель в самом центре города. Не шумно, все очень стильно и аккуратно', 10, 1,
'18.10.2019');INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(8, 'Шикарно, тихо и спокойно.',
'Шикарное месторасположение в центре Одессы на тихой улочке, где идеальная тишина и спокойствие. Потрясающий запах в отеле, чистота, выдержан стиль в каждой детали. Очень удобная кровать, прекрасная система кондиционирования, продумано все до мелочей.'
, 8, 2, '13.09.2019');INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(9, 'Достаточно хорошо', 'Отсутствует питание (очень низкое касество)', 6, 2, '14.10.2019');
INSERT INTO transferfeedback
(transfer, title, details, rating, userid, date)
VALUES(10, 'С виду неплохо, по факту ужасно',
'Вопросы начались при заселении, заехали в улучшенный номер, на раковине лобковые волосы (много!!!), в мусорке мусор. Позвонила на ресепш попросила убрать, убрали, но никто не извинился. Вопрос, как вообще убирали? Завтрак откровенно скудный. '
, 5, 2, '11.08.2019');INSERT INTO roomorders
(userid, room, startdate, enddate, places, prices, orderdate, insurancepolicy, status, manager)
VALUES(1, 1, '13.11.2019', '14.11.2019', 2, 250, '11.11.2019', 'HG86783264', 'Conform', 1);INSERT
INTO roomorders
(userid, room, startdate, enddate, places, prices, orderdate, insurancepolicy, status, manager)
VALUES(2, 2, '12.11.2019', '14.11.2019', 2, 300, '10.11.2019', 'HJ38283231', 'Conform', 1);INSERT
INTO roomorders
(userid, room, startdate, enddate, places, prices, orderdate, insurancepolicy, status, manager)
VALUES(1, 3, '14.11.2019', '16.11.2019', 2, 460, '12.11.2019', 'HG86783264', 'New', 1);INSERT INTO
tourorders
(userid, tour, startdate, enddate, places, prices, orderdate, insurancepolicy, status, manager)
VALUES(1, 2, '14.11.2019', '16.11.2019', 2, 150, '12.11.2019', 'HG86783264', 'New', 1);INSERT INTO
tourorders
(userid, tour, startdate, enddate, places, prices, orderdate, insurancepolicy, status, manager)
VALUES(2, 3, '12.11.2019', '14.11.2019', 2, 500, '10.11.2019', 'HJ38283231', 'Conform', 1);INSERT
INTO tourorders
(userid, tour, startdate, enddate, places, prices, orderdate, insurancepolicy, status, manager)
VALUES(1, 4, '17.11.2019', '20.11.2019', 2, 300, '12.11.2019', 'HG86783264', 'New', 1);INSERT INTO
transferorders
(userid, transfer, startdate, enddate, places, prices, orderdate, insurancepolicy, status, manager)
VALUES(1, 2, '14.11.2019', '16.11.2019', 2, 540, '12.11.2019', 'HG86783264', 'New', 1);INSERT INTO
transferorders
(userid, transfer, startdate, enddate, places, prices, orderdate, insurancepolicy, status, manager)
VALUES(2, 3, '12.11.2019', '14.11.2019', 2, 3000, '10.11.2019', 'HJ38283231', 'Conform', 1);INSERT
INTO transferorders
(userid, transfer, startdate, enddate, places, prices, orderdate, insurancepolicy, status, manager)
VALUES(1, 4, '17.11.2019', '20.11.2019', 2, 4160, '12.11.2019', 'HG86783264', 'New', 1);



