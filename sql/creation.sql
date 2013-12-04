DROP TABLE USERS CASCADE;
DROP TABLE TRANSACTIONS CASCADE;
DROP TABLE SIGGROUPS CASCADE;
DROP TABLE EVENTS CASCADE;
DROP TABLE ORGANIZERS CASCADE;
DROP TABLE COMPANIES CASCADE;
DROP TABLE USERS_EVENTS CASCADE;
DROP TABLE USERS_SIGGROUPS CASCADE;
DROP TABLE USERS_SESSIONS CASCADE;


CREATE TABLE USERS
(
  UID SERIAL PRIMARY KEY,
  firstName VARCHAR(30),
  lastName VARCHAR(40),
  email VARCHAR(50),
  phone VARCHAR(15),
  username VARCHAR(20) UNIQUE,
  password VARCHAR(60),
  salt VARCHAR(60),
  accountCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP(0),
  accountExpires TIMESTAMP DEFAULT (CURRENT_TIMESTAMP(0) + INTERVAL '1 YEAR'),
  userlevel INTEGER DEFAULT 0
);

CREATE TABLE USERS_SESSIONS
(
  UID INTEGER PRIMARY KEY,
  HASH VARCHAR(60),
  FOREIGN KEY (UID) REFERENCES USERS ON DELETE CASCADE
);

CREATE TABLE TRANSACTIONS
(
  TID SERIAL,
  AMOUNT NUMERIC(6, 2),
  DESCRIPTION VARCHAR(40),
  TIME_INITIATED TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UID INTEGER,
  PRIMARY KEY (TID),
  FOREIGN KEY (UID) REFERENCES USERS ON DELETE CASCADE
);

CREATE TABLE ORGANIZERS
(
  OID SERIAL,
  title VARCHAR(40) UNIQUE,
  PRIMARY KEY (OID)
);

CREATE TABLE SIGGROUPS
(
  GID SERIAL, 
  DESCRIPTION VARCHAR(40),
  LEADER_ID INTEGER REFERENCES USERS(UID) ON DELETE SET NULL,
  MEETING_TIME TIMESTAMP,
  OID INTEGER NOT NULL,
  PRIMARY KEY (GID),
  FOREIGN KEY (OID) REFERENCES ORGANIZERS ON DELETE CASCADE
);

CREATE TABLE USERS_SIGGROUPS
(
  UID INTEGER REFERENCES USERS ON DELETE CASCADE,
  GID INTEGER REFERENCES SIGGROUPS ON DELETE CASCADE
);

CREATE TABLE COMPANIES
(
  CID SERIAL,
  COMPANY_NAME VARCHAR(40),
  CONTACT_PERSON VARCHAR(40),
  CONTACT_PHONE VARCHAR(20),
  CONTACT_EMAIL VARCHAR(40),
  OID INTEGER NOT NULL,
  PRIMARY KEY (CID),
  FOREIGN KEY (OID) REFERENCES ORGANIZERS ON DELETE CASCADE
);

CREATE TABLE EVENTS
(
  EID SERIAL,
  EVENT_NAME VARCHAR(30),
  LOCATION VARCHAR(20),
  EVENT_DATETIME TIMESTAMP,
  OID INTEGER,
  PRIMARY KEY (EID),
  FOREIGN KEY (OID) REFERENCES ORGANIZERS ON DELETE CASCADE
);

CREATE TABLE USERS_EVENTS
(
  UID INTEGER REFERENCES USERS ON DELETE CASCADE,
  EID INTEGER REFERENCES EVENTS ON DELETE CASCADE
);

/** VIEWS **/
DROP VIEW SIGGROUPS_VIEW;
DROP VIEW SIGGROUPS_USERS_VIEW;
DROP VIEW COMPANIES_VIEW;
DROP VIEW EVENTS_VIEW;

CREATE OR REPLACE VIEW SIGGROUPS_VIEW AS
SELECT SIGGROUPS.GID, TITLE, DESCRIPTION, (USERS.FIRSTNAME || ' ' || USERS.LASTNAME) AS LEADER, MEETING_TIME
FROM SIGGROUPS LEFT OUTER JOIN ORGANIZERS ON (SIGGROUPS.OID = ORGANIZERS.OID)
     	       LEFT OUTER JOIN USERS ON (SIGGROUPS.LEADER_ID = USERS.UID)
ORDER BY SIGGROUPS.GID; 

CREATE OR REPLACE VIEW SIGGROUPS_USERS_VIEW AS
SELECT G.GID, TITLE, (FIRSTNAME || ' ' || LASTNAME) AS NAME 
FROM SIGGROUPS AS G LEFT OUTER JOIN ORGANIZERS AS O ON (G.OID = O.OID)
     	       	    LEFT OUTER JOIN USERS_SIGGROUPS AS UG ON G.GID = UG.GID
		    LEFT OUTER JOIN USERS AS U ON UG.UID = U.UID
ORDER BY G.GID;

CREATE OR REPLACE VIEW USERS_BALANCES_VIEW AS
SELECT U.UID, (U.FIRSTNAME || ' ' || U.LASTNAME) AS NAME, (SUM(T.AMOUNT)) AS BALANCE
FROM USERS AS U LEFT OUTER JOIN TRANSACTIONS AS T ON (U.UID = T.UID)
GROUP BY U.UID
ORDER BY U.UID;

CREATE OR REPLACE VIEW COMPANIES_VIEW AS
SELECT C.CID, TITLE AS COMPANY_NAME, CONTACT_PERSON, CONTACT_PHONE, CONTACT_EMAIL
FROM COMPANIES AS C LEFT OUTER JOIN ORGANIZERS AS O ON (C.OID = O.OID)
ORDER BY C.CID; 

CREATE OR REPLACE VIEW EVENTS_VIEW AS
SELECT E.EID, E.EVENT_NAME, E.LOCATION, E.EVENT_DATETIME, O.TITLE AS ORGANIZER
FROM EVENTS AS E LEFT OUTER JOIN ORGANIZERS AS O ON (E.OID = O.OID)
ORDER BY E.EID;


/** INSERTION **/
INSERT INTO USERS(firstName, lastName, email, username, password, salt, accountCreated, accountExpires, userlevel) VALUES ( 'Test' , 'Test' , 'test.dummy@ndsu.edu' , 'admin' ,'kIsNdRuRWnANTUBR9WKyIzvs8/dkjHK3sgAVzisDon0=', 'x/nY98Me4UyjN6e2FxsR2KtlCD2ugQpZDid6AaEVuys=', '2013-10-29' , '2014-10-29' , '2');
