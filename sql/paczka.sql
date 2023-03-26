CREATE SCHEMA Projekt;

SET SEARCH_PATH TO Projekt;

CREATE TABLE Projekt.paczka (
    id_paczki INTEGER NOT NULL,
    _status varchar(30) NOT NULL,
    PRIMARY KEY (id_paczki));

CREATE TABLE Projekt.odbiorca (
    id_odbiorcy INTEGER NOT NULL,
    id_domu INTEGER NOT NULL,
    nazwisko varchar(30) NOT NULL, 
    imie varchar(30) NOT NULL,
    PRIMARY KEY (id_odbiorcy));


CREATE TABLE Projekt.paczka_odbiorca (
    id_paczki INTEGER NOT NULL,
    id_odbiorcy INTEGER NOT NULL);

CREATE TABLE Projekt.nadawca (
    id_nadawcy INTEGER NOT NULL,
    id_domu INTEGER NOT NULL,
    nazwisko varchar(30) NOT NULL, 
    imie varchar(30) NOT NULL,
    PRIMARY KEY (id_nadawcy));


CREATE TABLE Projekt.paczka_nadawca (
    id_paczki INTEGER NOT NULL, 
    id_nadawcy INTEGER NOT NULL);


CREATE TABLE Projekt.paczkomat (
    id_paczkomatu INTEGER NOT NULL, 
    miasto varchar(30) NOT NULL, 
    ulica varchar(30) NOT NULL, 
    nr_ulicy INTEGER NOT NULL,
    PRIMARY KEY (id_paczkomatu));

CREATE TABLE Projekt.dom (
    id_domu INTEGER NOT NULL, 
    miasto varchar(30) NOT NULL, 
    ulica varchar(30) NOT NULL, 
    nr_ulicy INTEGER NOT NULL,
    PRIMARY KEY (id_domu));


CREATE TABLE Projekt.punktNadania_paczka (
    id_paczki INTEGER NOT NULL, 
    id_paczkomatu INTEGER NOT NULL, 
    id_domu INTEGER NOT NULL);


CREATE TABLE Projekt.punktOdbioru_paczka (
    id_paczki INTEGER NOT NULL UNIQUE, 
    id_paczkomatu INTEGER, 
    id_domu INTEGER);

CREATE TABLE Projekt.punktNadania_nadawca (
    id_nadawcy INTEGER NOT NULL, 
    id_paczkomatu INTEGER NOT NULL, 
    id_domu INTEGER NOT NULL);

CREATE TABLE Projekt.punktOdbioru_odbiorca (
    id_odbiorcy INTEGER NOT NULL, 
    id_paczkomatu INTEGER, 
    id_domu INTEGER);

CREATE TABLE Projekt.kurier (
    id_kuriera INTEGER NOT NULL ,
    nazwisko varchar(30) NOT NULL, 
    imie varchar(30) NOT NULL,
    PRIMARY KEY (id_kuriera));

CREATE TABLE Projekt.paczka_kurier (
    id_paczki INTEGER NOT NULL, 
    id_kuriera INTEGER NOT NULL);

CREATE TABLE Projekt.punktNadania_kurier (
    id_kuriera INTEGER NOT NULL, 
    id_paczkomatu INTEGER, 
    id_domu INTEGER
);

CREATE TABLE Projekt.punktOdbioru_kurier (
    id_kuriera INTEGER NOT NULL, 
    id_paczkomatu INTEGER, 
    id_domu INTEGER
);

INSERT INTO Projekt.paczkomat VALUES 
(1 , 'Kraków', 'Piastowska', 5),
(2 , 'Kraków', 'Opolska', 17),
(3 , 'Kraków', 'Jana Pawła', 21),
(4 , 'Kraków', 'Papieska', 37),
(5 , 'Kraków', 'Studencka', 18),
(6 , 'Warszawa', 'Krakowska', 30),
(7 , 'Warszawa', 'Uczelniana', 15),
(8 , 'Warszawa', 'Domowa', 29),
(9 , 'Warszawa', 'Katowicka', 10),
(10 , 'Warszawa', 'Marszałkowska', 28),
(11, 'Poznań', 'Cegielniana', 13),
(12 , 'Poznań', 'Studencka', 18),
(13 , 'Poznań', 'Toruńska', 21),
(14 , 'Poznań', 'Olczakowej', 30),
(15 , 'Poznań', 'Kapłańska', 50),
(16 , 'Wrocław', 'Papieska', 31),
(17 , 'Wrocław', 'Mickiewicza', 42),
(18 , 'Wrocław', 'Kościuszki', 30),
(19 , 'Wrocław', 'Wielicka', 82),
(20 , 'Wrocław', 'Piastowska', 15);


INSERT INTO Projekt.kurier 
(id_kuriera, nazwisko, imie)
VALUES 
(1, 'Filipowski', 'Judyta'), 
(2, 'Dubanowski', 'Łucjan'),
(3, 'Stasiuk', 'Natasza'),
(4, 'Wyrzyk', 'Igor'),
(5, 'Malinowski', 'Przemek'),
(6, 'Jedynak', 'Wojtek'),
(7, 'Wrona', 'Antonina'),
(8, 'Starek', 'Gabriela'),
(9, 'Łaska', 'Wacław'),
(10, 'Szwedko', 'Miłosz');

INSERT INTO Projekt.nadawca
(id_nadawcy, id_domu, nazwisko, imie) 
VALUES 
(1, 1, 'Soból', 'Więcesław'), 
(2, 2, 'Gniewek', 'Julianna'),
(3, 3, 'Niemczyk', 'Weronika'),
(4, 4, 'Wójcik', 'Inga'),
(5, 5, 'Zawisza', 'Lesław'),
(6, 6, 'Ostrowski', 'Anita'), 
(7, 7, 'Marszałek', 'Cibor'),
(8, 8, 'Kozłow', 'Jolanta'),
(9, 9, 'Grześkiewicz', 'Rozalia'),
(10, 10, 'Czajkowski', 'Jolanta');


INSERT INTO Projekt.odbiorca
(id_odbiorcy, id_domu, nazwisko, imie)
VALUES
(1, 1, 'Soból', 'Więcesław'), 
(2, 2, 'Gniewek', 'Julianna'),
(3, 3, 'Niemczyk', 'Weronika'),
(4, 4, 'Wójcik', 'Inga'),
(5, 5, 'Zawisza', 'Lesław'),
(6, 6, 'Ostrowski', 'Anita'), 
(7, 7, 'Marszałek', 'Cibor'),
(8, 8, 'Kozłow', 'Jolanta'),
(9, 9, 'Grześkiewicz', 'Rozalia'),
(10, 10, 'Czajkowski', 'Jolanta');



INSERT INTO Projekt.paczka
(id_paczki, _status)
VALUES
(1, 'Wysłana'),
(2, 'Dostarczono'),
(3, 'Wysłana'),
(4, 'Odebrana przez kuriera'),
(5, 'Wysłana');

INSERT INTO Projekt.paczka_odbiorca
(id_paczki, id_odbiorcy)
VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 5),
(5, 6);

INSERT INTO Projekt.paczka_nadawca
(id_paczki, id_nadawcy)
VALUES
(1, 7),
(2, 8),
(3, 9),
(4, 10),
(5, 1);

INSERT INTO Projekt.dom 
(id_domu, miasto, ulica, nr_ulicy)
VALUES
(1, 'Białystok', 'Niepodległości', 63),
(2, 'Rzeszów', 'Dworcowa', 106),
(3, 'Częstochowa', 'Borowska', 19),
(4, 'Warszawa', 'Papieska', 33),
(5, 'Kraków', 'Piechockiego Jana', 21),
(6, 'Olsztyn', 'Homera', 3),
(7, 'Racibórz', 'Szosa Ełcka', 36),
(8, 'Katowice', 'Grzybowa', 2),
(9, 'Koszalin', 'Fabryczna', 102),
(10, 'Wrocław', 'Dobromira', 93);


INSERT INTO Projekt.punktNadania_paczka
(id_paczki, id_domu, id_paczkomatu)
VALUES
(1, 7, 0),
(2, 8, 0),
(3, 9, 0),
(4, 0, 2),
(5, 0, 10);


INSERT INTO Projekt.punktOdbioru_paczka
(id_paczki, id_paczkomatu, id_domu)
VALUES
(1, 7, 0),
(2, 3, 0),
(3, 12, 0),
(4, 0, 5),
(5, 0, 6);


INSERT INTO Projekt.punktNadania_nadawca
(id_paczkomatu, id_nadawcy, id_domu)
VALUES
(2, 10, 0),
(10, 1, 0),
(0, 7, 7),
(0, 8, 8),
(0, 9, 9);

INSERT INTO Projekt.punktOdbioru_odbiorca
(id_paczkomatu, id_odbiorcy, id_domu)
VALUES
(7, 2, 0),
(3, 3, 0),
(12, 4, 0),
(0, 5, 5),
(0, 6, 6);

INSERT INTO Projekt.paczka_kurier
(id_paczki, id_kuriera)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO Projekt.punktOdbioru_kurier
(id_kuriera, id_paczkomatu, id_domu)
VALUES
(1, 7, 0),
(2, 3, 0),
(3, 12, 0),
(4, 0, 5),
(5, 0, 6);

INSERT INTO Projekt.punktNadania_kurier
(id_kuriera, id_domu, id_paczkomatu)
VALUES
(1, 7, 0),
(2, 8, 0),
(3, 9, 0),
(4, 0, 2),
(5, 0, 10);
