-- Funkcja wyswietlajaca paczke dla uzytkownika
CREATE OR REPLACE FUNCTION Projekt.paczka_wypisz(id int)
RETURNS TABLE (id_paczki int, _status varchar, imie_odbiorcy varchar, nazwisko_odbiorcy varchar, miasto varchar, ulica varchar, nr_ulicy int, imie_nadawcy varchar, nazwisko_nadawcy varchar, czyPaczkomat boolean) AS 
$$
    DECLARE
        t_id_paczkomatu int;
        val boolean;
        n int;
    BEGIN
        SELECT COUNT(p.id_paczki) INTO n FROM Projekt.paczka AS p;
        IF id > n THEN 
            RAISE EXCEPTION 'Brak paczki o podanym ID';
        END IF;
            SELECT pop.id_paczkomatu INTO t_id_paczkomatu FROM Projekt.punktOdbioru_paczka AS pop 
            JOIN Projekt.paczka AS p ON pop.id_paczki = p.id_paczki
            WHERE p.id_paczki = id;
        IF t_id_paczkomatu > 0 THEN 
            val := true;
            RETURN QUERY
            SELECT p.id_paczki, p._status, o.imie, o.nazwisko, pa.miasto, pa.ulica, pa.nr_ulicy, n.imie, n.nazwisko, val FROM Projekt.paczka AS p 
                JOIN Projekt.paczka_odbiorca AS po ON po.id_paczki = p.id_paczki
                JOIN Projekt.odbiorca AS o ON po.id_odbiorcy = o.id_odbiorcy
                JOIN Projekt.paczka_nadawca AS pn ON pn.id_paczki = p.id_paczki
                JOIN Projekt.nadawca AS n ON n.id_nadawcy = pn.id_nadawcy
                JOIN Projekt.punktOdbioru_paczka AS pop ON p.id_paczki = pop.id_paczki
                JOIN Projekt.paczkomat AS pa ON pa.id_paczkomatu = pop.id_paczkomatu
                WHERE p.id_paczki = id;
        ELSE 
            val := false;
            RETURN QUERY
            SELECT p.id_paczki, p._status, o.imie, o.nazwisko, d.miasto, d.ulica, d.nr_ulicy, n.imie, n.nazwisko, val FROM Projekt.paczka AS p 
                JOIN Projekt.paczka_odbiorca AS po ON po.id_paczki = p.id_paczki
                JOIN Projekt.odbiorca AS o ON po.id_odbiorcy = o.id_odbiorcy
                JOIN Projekt.paczka_nadawca AS pn ON pn.id_paczki = p.id_paczki
                JOIN Projekt.nadawca AS n ON n.id_nadawcy = pn.id_nadawcy
                JOIN Projekt.punktOdbioru_paczka AS pop ON p.id_paczki = pop.id_paczki
                JOIN Projekt.dom AS d ON d.id_domu = pop.id_domu
                WHERE p.id_paczki = id;
        END IF;
    END;
$$ LANGUAGE 'plpgsql';

-- Funkcja wyswietlajaca paczki dla kuriera
CREATE OR REPLACE FUNCTION Projekt.paczki_wypisz_kurier(imie_k varchar, nazwisko_k varchar)
RETURNS TABLE (id_paczki int, _status varchar, imie_nadawcy varchar, nazwisko_nadawcy varchar, miasto_nadania varchar, ulica_nadania varchar, nr_ulicy_nadania int, czyPaczkomat_nadanie boolean, imie_odbiorcy varchar, nazwisko_odbiorcy varchar, miasto_odbioru varchar, ulica_odbioru varchar, nr_ulicy_odbioru int, czyPaczkomat_odbior boolean) AS 
$$
    DECLARE
        id int;
        t_id_k int;
        t_id_p int;
        t_id_paczkomatu int;
        n int;
        val boolean;
    BEGIN
        SELECT k.id_kuriera INTO id FROM Projekt.kurier AS k WHERE k.imie = imie_k AND k.nazwisko = nazwisko_k; 
        SELECT COUNT(pk.id_paczki) INTO n FROM Projekt.paczka_kurier AS pk;
        FOR i IN 1..n
        LOOP   
            SELECT pk.id_kuriera INTO t_id_k FROM Projekt.paczka_kurier AS pk WHERE pk.id_paczki = i;
            IF t_id_k = id THEN 
                SELECT t.id_paczki, t._status, t.imie_nadawcy, t.nazwisko_nadawcy, t.imie_odbiorcy, t.nazwisko_odbiorcy, t.miasto, t.ulica, t.nr_ulicy, t.czyPaczkomat INTO id_paczki, _status , imie_nadawcy , nazwisko_nadawcy ,imie_odbiorcy , nazwisko_odbiorcy , miasto_odbioru , ulica_odbioru , nr_ulicy_odbioru , czyPaczkomat_odbior FROM Projekt.paczka_wypisz(i) AS t;
                
                SELECT pnp.id_paczkomatu INTO t_id_paczkomatu FROM Projekt.punktNadania_paczka AS pnp 
                JOIN Projekt.paczka AS p on pnp.id_paczki = p.id_paczki 
                WHERE p.id_paczki = i;
                IF t_id_paczkomatu > 0 THEN
                    val := true;
                    SELECT pa.miasto, pa.ulica, pa.nr_ulicy, val INTO miasto_nadania, ulica_nadania, nr_ulicy_nadania, czyPaczkomat_nadanie FROM Projekt.paczkomat AS pa 
                    JOIN Projekt.punktNadania_paczka AS pnp ON pnp.id_paczkomatu = pa.id_paczkomatu
                    JOIN Projekt.paczka AS p ON p.id_paczki = pnp.id_paczki
                    WHERE p.id_paczki = i;
                ELSE
                    val := false;
                    SELECT d.miasto, d.ulica, d.nr_ulicy, val INTO miasto_nadania, ulica_nadania, nr_ulicy_nadania, czyPaczkomat_nadanie FROM Projekt.dom AS d 
                    JOIN Projekt.punktNadania_paczka AS pnp ON pnp.id_domu = d.id_domu
                    JOIN Projekt.paczka AS p ON p.id_paczki = pnp.id_paczki
                    WHERE p.id_paczki = i;
                END IF;
                RETURN NEXT;
            END IF;
        END LOOP;
    END;
$$ LANGUAGE 'plpgsql';

-- Funkcja oraz wyzwalacz dodająca dom oraz użytkownika jako nadawce
CREATE OR REPLACE FUNCTION Projekt.uzytkownik_view_dodaj() RETURNS TRIGGER AS 
$$
    DECLARE
        id_n int;
        id_d int;
        n int;
        t_miasto varchar;
        t_ulica varchar;
        t_nr_ulicy int;
    BEGIN
        SELECT COUNT(d.id_domu) INTO n FROM Projekt.dom AS d;
        FOR i IN 1..n
        LOOP 
            SELECT d.miasto INTO t_miasto FROM Projekt.dom AS d WHERE id_domu = i;
            SELECT d.ulica INTO t_ulica FROM Projekt.dom AS d WHERE id_domu = i;
            SELECT d.nr_ulicy INTO t_nr_ulicy FROM Projekt.dom AS d WHERE id_domu = i;
            IF NEW.miasto = t_miasto AND NEW.ulica = t_ulica AND NEW.nr_ulicy = t_nr_ulicy THEN
                SELECT d.id_domu INTO id_d FROM Projekt.dom AS d WHERE id_domu = i;
            ELSE
                SELECT COUNT(d.id_domu)+1 INTO id_d FROM Projekt.dom AS d;
            END IF;
        END LOOP;
        IF id_d = n+1 THEN
        INSERT INTO Projekt.dom (id_domu, miasto, ulica, nr_ulicy) VALUES
                (id_d, NEW.miasto, NEW.ulica, NEW.nr_ulicy);
        END IF;
        SELECT COUNT(id_nadawcy)+1 INTO id_n FROM Projekt.nadawca;
        INSERT INTO Projekt.nadawca (id_nadawcy, id_domu, nazwisko, imie) VALUES 
        (id_n, id_d, NEW.nazwisko, NEW.imie);
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER dodaj_view_uzytkownik INSTEAD OF INSERT ON Projekt.uzytkownik_view 
    FOR EACH ROW EXECUTE PROCEDURE uzytkownik_view_dodaj();

-- Funkcja i wyzwalacz dodjący użytkownika do odbiorcy
CREATE OR REPLACE FUNCTION Projekt.uzytkownik_dodaj() RETURNS TRIGGER AS 
$$
    DECLARE
        id_o int;
        id_d int;
    BEGIN
        SELECT n.id_domu INTO id_d FROM Projekt.nadawca AS n WHERE 
        n.imie = NEW.imie AND n.nazwisko = NEW.nazwisko;    
        SELECT COUNT(id_odbiorcy)+1 INTO id_o FROM Projekt.odbiorca;
        INSERT INTO Projekt.odbiorca (id_odbiorcy, id_domu, nazwisko, imie) VALUES 
        (id_o, id_d, NEW.nazwisko, NEW.imie);
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER dodaj_uzytkownik AFTER INSERT ON Projekt.nadawca 
    FOR EACH ROW EXECUTE PROCEDURE Projekt.uzytkownik_dodaj();

-- Funkcja i wyzwalacz sprawdzające poprawność danych użytkownika przy dodawaniu użytkownika
CREATE OR REPLACE FUNCTION Projekt.uzytkownik_validate() RETURNS TRIGGER AS 
$$
    DECLARE
        c int := 0;
        t_nazwisko varchar;
        t_imie varchar;
    BEGIN
        IF LENGTH(NEW.nazwisko) = 0 THEN
            RAISE EXCEPTION 'Dane użytkownika nie mogą być puste';
        END IF;
        IF LENGTH(NEW.imie) = 0 THEN
            RAISE EXCEPTION 'Dane użytkownika nie mogą być puste';
        END IF;
        SELECT COUNT(*) INTO c FROM Projekt.nadawca;
        FOR id IN 1..c
        LOOP
            SELECT n.imie INTO t_imie FROM Projekt.nadawca AS n WHERE n.id_nadawcy = id;
            SELECT n.nazwisko INTO t_nazwisko FROM Projekt.nadawca AS n WHERE n.id_nadawcy = id;
            IF NEW.imie = t_imie THEN
                RAISE EXCEPTION 'Użytkownik już istnieje';
            END IF;
            IF NEW.nazwisko = t_nazwisko THEN
                RAISE EXCEPTION 'Użytkownik już istnieje';
            END IF;
        END LOOP;
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER validate_uzytkownik BEFORE INSERT ON Projekt.nadawca 
    FOR EACH ROW EXECUTE PROCEDURE Projekt.uzytkownik_validate();

-- Funkcja i wyzwalacz sprawdzające poprawność danych domu użytkownika przy dodawaniu użytkownika
CREATE OR REPLACE FUNCTION Projekt.dom_validate() RETURNS TRIGGER AS
$$
    BEGIN
        IF LENGTH(NEW.miasto) = 0 THEN
            RAISE EXCEPTION 'Dane domu nie mogą być puste';
        END IF;
        IF LENGTH(NEW.ulica) = 0 THEN
            RAISE EXCEPTION 'Dane domu nie mogą być puste';
        END IF;
        IF NEW.nr_ulicy < 0 THEN
            RAISE EXCEPTION 'Nr ulicy musi być większy od 0';
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER validate_dom BEFORE INSERT ON Projekt.dom 
    FOR EACH ROW EXECUTE PROCEDURE Projekt.dom_validate();

-- Funkcja i wyzwalacz sprawdzające poprawność danych oraz dodająca paczke przy dodawaniu paczki 
CREATE OR REPLACE FUNCTION Projekt.dodaj_paczke() RETURNS TRIGGER AS
$$
    DECLARE
    t_id_paczki int;
    t_imie_n varchar;
    t_nazwisko_n varchar;
    imie_n varchar;
    nazwisko_n varchar;
    t_id_n int;
    t_imie_o varchar;
    t_nazwisko_o varchar;
    imie_o varchar;
    nazwisko_o varchar;
    t_id_o int;
    t_id_paczkomatu int;
    t_id_domu int;
    isTrueN boolean := false;
    isTrueO boolean := false;
    t_id_k int;
    temp int;
    c int;
    BEGIN
        SELECT COUNT(n.id_nadawcy) INTO c FROM Projekt.nadawca AS n;
        SELECT COUNT(p.id_paczki)+1 INTO t_id_paczki FROM Projekt.paczka as p;

        IF LENGTH(NEW.imie_nadawcy) = 0 OR LENGTH(NEW.nazwisko_nadawcy) = 0 THEN
            IF LENGTH(NEW.imie_odbiorcy) = 0 OR LENGTH(NEW.nazwisko_odbiorcy) = 0 THEN
                RAISE EXCEPTION 'Dane nadawcy i odbiorcy są puste';
            END IF;
            RAISE EXCEPTION 'Dane nadawcy są puste';
        END IF;
        IF LENGTH(NEW.imie_odbiorcy) = 0 OR LENGTH(NEW.nazwisko_odbiorcy) = 0 THEN
                RAISE EXCEPTION 'Dane odbiorcy są puste';
        END IF;

        FOR id IN 1..c
        LOOP
            SELECT n.imie INTO t_imie_n FROM Projekt.nadawca AS n WHERE n.id_nadawcy = id;
            SELECT n.nazwisko INTO t_nazwisko_n FROM Projekt.nadawca AS n WHERE n.id_nadawcy = id;
            IF NEW.imie_nadawcy = t_imie_n THEN
                IF NEW.nazwisko_nadawcy = t_nazwisko_n THEN
                    INSERT INTO Projekt.paczka_nadawca (id_paczki, id_nadawcy) VALUES (t_id_paczki, id);
                    imie_n := t_imie_n;
                    nazwisko_n := t_nazwisko_n;
                    isTrueN := true;
                END IF;
            END IF;
        END LOOP;

        FOR id IN 1..c
        LOOP
            SELECT o.imie INTO t_imie_o FROM Projekt.odbiorca AS o WHERE o.id_odbiorcy = id;
            SELECT o.nazwisko INTO t_nazwisko_o FROM Projekt.odbiorca AS o WHERE o.id_odbiorcy = id;
            IF NEW.imie_odbiorcy = t_imie_o THEN
                IF NEW.nazwisko_odbiorcy = t_nazwisko_o THEN
                    INSERT INTO Projekt.paczka_odbiorca (id_paczki, id_odbiorcy) VALUES (t_id_paczki, id);
                    imie_o := t_imie_o;
                    nazwisko_o := t_nazwisko_o;
                    isTrueO := true;
                END IF;
            END IF;
        END LOOP;
        IF isTrueN = false THEN 
            IF isTrueO = false THEN
                RAISE EXCEPTION 'Odbiorca i nadawca nie są zarejestrowani';
            ELSE
                RAISE EXCEPTION 'Nadawca nie jest zarejestrowany';
            END IF;
        END IF;
        IF isTrueO = false THEN 
            RAISE EXCEPTION 'Odbiorca nie jest zarejestrowany';
        END IF;

        SELECT n.id_nadawcy INTO t_id_n FROM Projekt.nadawca AS n WHERE imie_n = n.imie AND nazwisko_n = n.nazwisko;
        SELECT COUNT(k.id_kuriera) INTO temp FROM Projekt.kurier AS k;
        SELECT FLOOR(RANDOM()*temp) INTO t_id_k;

        IF NEW.miasto_paczkomat_nadawca != '' THEN
            SELECT p.id_paczkomatu INTO t_id_paczkomatu FROM Projekt.paczkomat AS p WHERE p.miasto = NEW.miasto_paczkomat_nadawca AND p.ulica = NEW.ulica_paczkomat_nadawca AND p.nr_ulicy = NEW.nr_ulicy_paczkomat_nadawca;
            INSERT INTO Projekt.punktNadania_nadawca (id_nadawcy, id_paczkomatu, id_domu) VALUES (t_id_n, t_id_paczkomatu, 0);
            INSERT INTO Projekt.punktNadania_paczka (id_paczki, id_paczkomatu, id_domu) VALUES (t_id_paczki, t_id_paczkomatu, 0);
            INSERT INTO Projekt.punktNadania_kurier (id_kuriera, id_paczkomatu, id_domu) VALUES (t_id_k, t_id_paczkomatu, 0);
        ELSE
            SELECT n.id_domu INTO t_id_domu FROM Projekt.nadawca AS n WHERE imie_n = n.imie AND nazwisko_n = n.nazwisko;
            INSERT INTO Projekt.punktNadania_nadawca (id_nadawcy, id_domu, id_paczkomatu) VALUES (t_id_n, t_id_domu, 0);
            INSERT INTO Projekt.punktNadania_paczka (id_paczki, id_domu, id_paczkomatu) VALUES (t_id_paczki, t_id_domu, 0);
            INSERT INTO Projekt.punktNadania_kurier (id_kuriera, id_domu, id_paczkomatu) VALUES (t_id_k, t_id_domu, 0);
        END IF;

        SELECT o.id_odbiorcy INTO t_id_o FROM Projekt.odbiorca AS o WHERE imie_o = o.imie AND nazwisko_o = o.nazwisko;
        IF NEW.miasto_paczkomat_odbiorca != '' THEN
            SELECT p.id_paczkomatu INTO t_id_paczkomatu FROM Projekt.paczkomat AS p WHERE p.miasto = NEW.miasto_paczkomat_odbiorca AND p.ulica = NEW.ulica_paczkomat_odbiorca AND p.nr_ulicy = NEW.nr_ulicy_paczkomat_odbiorca;
            INSERT INTO Projekt.punktOdbioru_odbiorca (id_odbiorcy, id_paczkomatu, id_domu) VALUES (t_id_o, t_id_paczkomatu, 0);
            INSERT INTO Projekt.punktOdbioru_paczka  (id_paczki, id_paczkomatu, id_domu) VALUES (t_id_paczki, t_id_paczkomatu, 0);
            INSERT INTO Projekt.punktOdbioru_kurier  (id_kuriera, id_paczkomatu, id_domu) VALUES (t_id_k, t_id_paczkomatu, 0);
        ELSE
            SELECT o.id_domu INTO t_id_domu FROM Projekt.odbiorca AS o WHERE imie_o = o.imie AND nazwisko_o = o.nazwisko;
            INSERT INTO Projekt.punktOdbioru_odbiorca (id_odbiorcy, id_domu, id_paczkomatu) VALUES (t_id_o, t_id_domu, 0);
            INSERT INTO Projekt.punktOdbioru_paczka  (id_paczki, id_domu, id_paczkomatu) VALUES (t_id_paczki, t_id_domu, 0);
            INSERT INTO Projekt.punktOdbioru_kurier(id_kuriera, id_domu, id_paczkomatu) VALUES (t_id_k, t_id_domu, 0);
        END IF;

        INSERT INTO Projekt.paczka_kurier (id_paczki, id_kuriera) VALUES (t_id_paczki, t_id_k);
        INSERT INTO Projekt.paczka (id_paczki, _status) VALUES (t_id_paczki, 'Wysłano');
        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER dodaj_view_paczka INSTEAD OF INSERT ON Projekt.paczka_dodanie_view FOR EACH ROW EXECUTE PROCEDURE Projekt.dodaj_paczke();

-- Funckja i wyzwalacz sprawdzające dane przy logowaniu się kuriera
CREATE OR REPLACE FUNCTION kurier_login() RETURNS TRIGGER AS
$$
    DECLARE
        imie varchar;
        nazwisko varchar;
        n int;
        czyIstnieje boolean := false;
    BEGIN
        IF NEW.imie = '' OR NEW.nazwisko = '' THEN
            RAISE EXCEPTION 'Dane logowanie nie mogą być puste';
        END IF;
        SELECT COUNT(k.id_kuriera) INTO n FROM Projekt.kurier AS k;
        FOR id IN 1..n
        LOOP
            SELECT k.imie INTO imie FROM Projekt.kurier AS k WHERE k.id_kuriera = id;
            SELECT k.nazwisko INTO nazwisko FROM Projekt.kurier AS k WHERE k.id_kuriera = id;
            IF nazwisko = NEW.nazwisko AND imie = NEW.imie THEN
                czyIstnieje := true;
            END IF;
        END LOOP;
        IF czyIstnieje = false THEN
            RAISE EXCEPTION 'Brak kuriera o podanych danych';
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER login_kurier INSTEAD OF INSERT ON kurier_login_view
    FOR EACH ROW EXECUTE PROCEDURE kurier_login();

-- Funckja i wyzwalacz sprawdzające i zapisująca dane przy dodawaniu kuriera
CREATE OR REPLACE FUNCTION Projekt.dodaj_kuriera() RETURNS TRIGGER AS 
$$
    DECLARE 
        n int;
        t_imie varchar;
        t_nazwisko varchar;
    BEGIN
        IF NEW.imie = '' OR NEW.nazwisko = '' THEN
            RAISE EXCEPTION 'Dane kuriera nie mogą być puste';
        END IF;

        SELECT COUNT(k.id_kuriera) INTO n FROM Projekt.kurier AS k;

        FOR i IN 1..n 
        LOOP
            SELECT k.imie INTO t_imie FROM Projekt.kurier AS k WHERE i = k.id_kuriera;
            SELECT k.nazwisko INTO t_nazwisko FROM Projekt.kurier AS k WHERE i = k.id_kuriera;
            IF t_imie = NEW.imie AND t_nazwisko = NEW.nazwisko THEN
                RAISE EXCEPTION 'Kurier o podanych danych jest już zarejestrowany';
            END IF;
        END LOOP;
        n := n+1;
        INSERT INTO Projekt.kurier (id_kuriera, imie, nazwisko) VALUES (n, NEW.imie, NEW.nazwisko);
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER kurier_dodaj INSTEAD OF INSERT ON Projekt.kurier_dodaj_view
    FOR EACH ROW EXECUTE PROCEDURE Projekt.dodaj_kuriera();

-- Funkcja i wyzwalacz sprawdzające i zapisujące dane dodawanego paczkomatu
CREATE OR REPLACE FUNCTION Projekt.dodaj_paczkomat() RETURNS TRIGGER AS
$$
    DECLARE
        n int;
        t_miasto varchar;
        t_ulica varchar;
        t_nr_ulicy int;
    BEGIN
        IF LENGTH(NEW.ulica) = 0 OR LENGTH(NEW.miasto) = 0 THEN
            RAISE EXCEPTION 'Adres nie może być pusty';
        END IF;
        IF NEW.nr_ulicy <= 0 THEN
            RAISE EXCEPTION 'Nr. ulicy musi być większy od 0';
        END IF;
        SELECT COUNT(pa.id_paczkomatu) INTO n FROM Projekt.paczkomat AS pa;
        FOR i IN 1..n
        LOOP
            SELECT pa.miasto, pa.ulica, pa.nr_ulicy INTO t_miasto, t_ulica, t_nr_ulicy FROM Projekt.paczkomat AS pa WHERE pa.id_paczkomatu = i;
            IF t_miasto = NEW.miasto AND t_ulica = NEW.ulica AND t_nr_ulicy = NEW.nr_ulicy THEN
                 RAISE EXCEPTION 'Paczkomat jest już dodany';
            END IF;
        END LOOP;
        n := n+1;
        INSERT INTO Projekt.paczkomat (id_paczkomatu, miasto, ulica, nr_ulicy) VALUES
        (n, NEW.miasto, NEW.ulica, NEW.nr_ulicy);
        RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER paczkomat_dodaj INSTEAD OF INSERT ON Projekt.paczkomat_view
    FOR EACH ROW EXECUTE PROCEDURE Projekt.dodaj_paczkomat();