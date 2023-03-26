-- Widok służący do wyświetlania listy paczkomatów
CREATE OR REPLACE VIEW Projekt.paczkomat_view (miasto, ulica, nr_ulicy) AS 
    SELECT p.miasto, p.ulica, p.nr_ulicy FROM Projekt.paczkomat AS p ORDER BY miasto, ulica, nr_ulicy;

-- Widok służący do dodawania użytkownika
CREATE OR REPLACE VIEW Projekt.uzytkownik_view (imie, nazwisko, miasto, ulica, nr_ulicy) AS
    SELECT n.imie, n.nazwisko, d.miasto, d.ulica, d.nr_ulicy FROM Projekt.nadawca AS n 
    JOIN Projekt.dom AS d ON d.id_domu = n.id_domu;

-- Widok służący do dodawania paczki
CREATE OR REPLACE VIEW Projekt.paczka_dodanie_view (imie_odbiorcy, nazwisko_odbiorcy, miasto_paczkomat_odbiorca, ulica_paczkomat_odbiorca, nr_ulicy_paczkomat_odbiorca, imie_nadawcy, nazwisko_nadawcy, miasto_paczkomat_nadawca, ulica_paczkomat_nadawca, nr_ulicy_paczkomat_nadawca) AS
    SELECT o.imie, o.nazwisko, p.miasto, p.ulica, p.nr_ulicy, n.imie, n.nazwisko, p.miasto, p.ulica, p.nr_ulicy FROM Projekt.nadawca AS n 
        JOIN Projekt.punktNadania_nadawca AS pn ON pn.id_nadawcy = n.id_nadawcy
        JOIN Projekt.paczkomat AS p ON p.id_paczkomatu = pn.id_paczkomatu
        JOIN Projekt.punktOdbioru_odbiorca AS po ON po.id_paczkomatu = p.id_paczkomatu
        JOIN Projekt.odbiorca AS o ON o.id_odbiorcy = po.id_odbiorcy;

-- Widok służący do logowania kuriera
CREATE OR REPLACE VIEW kurier_login_view (imie, nazwisko) AS 
    SELECT k.imie, k.nazwisko FROM Projekt.kurier AS k;

-- Widok służący do dodawania kuriera
CREATE OR REPLACE VIEW kurier_dodaj_view (imie, nazwisko) AS 
    SELECT k.imie, k.nazwisko FROM Projekt.kurier AS k;
