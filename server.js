const express = require('express')
const app = express()
const path = require('path')
const pool = require("./db.js")
var cors = require('cors')
const { json } = require('body-parser')
const { url } = require('inspector')
//const { parse, deparse } = require('pgsql-parser')
const port = 21727

app.use(express.urlencoded({ extended: false }))
app.set("view engine", "ejs")
app.set("views", path.join(__dirname, "views"))
app.use(express.static(__dirname + '/public'))
app.use(express.json())
app.use(cors({ origin: "*" }))

// Endpoint strony indeksowej
app.get("/", (req, res) => {
    res.render("index")
})

// Endpoint na którym można dodać paczke
app.get("/dodajPaczke", (req, res) => {
    try {
        pool.query('SELECT * FROM Projekt.paczkomat_view', (err, result) => {
            if (err) {
                console.log(err)
            }
            let paczkomaty = []
            for (let i = 0; i < result.rowCount; i++) {
                paczkomaty[i] = `${result.rows[i].miasto}, ${result.rows[i].ulica}, ${result.rows[i].nr_ulicy}`
            }
            //console.log(paczkomaty)
            res.render("dodajPaczke", { paczkomaty: paczkomaty, ilosc: result.rowCount, errO: req.query.erro, errN: req.query.errn, err: req.query.err })
        })
    } catch (err) {
        console.log(err)
    }
})

// Endpoint który wywołujemy dodaniem paczki
app.post("/dodajPaczke", (req, res) => {
    try {
        let imieNadawcy = req.body.imieNadawcy
        let nazwiskoNadawcy = req.body.nazwiskoNadawcy
        let imieOdbiorcy = req.body.imieOdbiorcy
        let nazwiskoOdbiorcy = req.body.nazwiskoOdbiorcy
        let wysylkaCzyPaczkomat = req.body.wysylkaPaczkomatem
        let wysylkaCzyDom = req.body.wysylkaDomowa
        let odbiorCzyPaczkomat = req.body.odbiorPaczkomatem
        let odbiorCzyDom = req.body.odbiorDomowy
        console.log(imieNadawcy)
        if (typeof wysylkaCzyPaczkomat === 'undefined' && typeof wysylkaCzyDom === 'undefined') {
            if (typeof odbiorCzyPaczkomat === 'undefined' && typeof odbiorCzyDom === 'undefined') {
                let url1 = '&erro=Wybierz miejsce odbioru'
                let url = '?errn=Wybierz miejsce nadania' + url1
                res.redirect("/dodajPaczke" + url)
            }
            else {
                let url = '?errn=Wybierz miejsce nadania'
                res.redirect("/dodajPaczke" + url)
            }
        }
        else if (typeof odbiorCzyPaczkomat === 'undefined' && typeof odbiorCzyDom === 'undefined') {
            let url = '?erro=Wybierz miejsce odbioru'
            res.redirect("/dodajPaczke" + url)
        }
        else if (typeof wysylkaCzyPaczkomat === 'undefined') {
            if (typeof odbiorCzyPaczkomat === 'undefined') {
                // dom w dom o
                console.log('dom w dom o')
                pool.query("INSERT INTO Projekt.paczka_dodanie_view (imie_odbiorcy, nazwisko_odbiorcy, miasto_paczkomat_odbiorca, ulica_paczkomat_odbiorca, nr_ulicy_paczkomat_odbiorca, imie_nadawcy, nazwisko_nadawcy, miasto_paczkomat_nadawca, ulica_paczkomat_nadawca, nr_ulicy_paczkomat_nadawca) VALUES ($1, $2, '', '', 0, $3, $4, '', '', 0)", [imieOdbiorcy, nazwiskoOdbiorcy, imieNadawcy, nazwiskoNadawcy], (err, result) => {
                    if (err) {
                        console.log(err.message)
                        if (err.message === 'Dane nadawcy są puste') {
                            let url = '?errn=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Dane odbiorcy są puste') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Odbiorca nie jest zarejestrowany') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Nadawca nie jest zarejestrowany') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else {
                            let url = '?err=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                    }
                    else {
                        res.render("dodanoPaczke")
                    }
                })
            }
            else if (typeof odbiorCzyDom === 'undefined') {
                //dom w pacz o
                console.log('dom w pacz o')
                let paczkomatOdbior = req.body.listaPaczkomatowOdbior.trim()
                paczkomatOdbior = paczkomatOdbior.split(',')
                paczkomatOdbior[0] = paczkomatOdbior[0].trim()
                paczkomatOdbior[1] = paczkomatOdbior[1].trim()
                paczkomatOdbior[2] = paczkomatOdbior[2].trim()
                pool.query("INSERT INTO Projekt.paczka_dodanie_view (imie_odbiorcy, nazwisko_odbiorcy, miasto_paczkomat_odbiorca, ulica_paczkomat_odbiorca, nr_ulicy_paczkomat_odbiorca, imie_nadawcy, nazwisko_nadawcy, miasto_paczkomat_nadawca, ulica_paczkomat_nadawca, nr_ulicy_paczkomat_nadawca) VALUES ($1, $2, $3, $4, $5, $6, $7, '', '', 0)", [imieOdbiorcy, nazwiskoOdbiorcy, paczkomatOdbior[0], paczkomatOdbior[1], parseInt(paczkomatOdbior[2]), imieNadawcy, nazwiskoNadawcy], (err, result) => {
                    if (err) {
                        console.log(err.message)
                        if (err.message === 'Dane nadawcy są puste') {
                            let url = '?errn=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Dane odbiorcy są puste') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Odbiorca nie jest zarejestrowany') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Nadawca nie jest zarejestrowany') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else {
                            let url = '?err=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                    }
                    else {
                        res.render("dodanoPaczke")
                    }
                })
            }
        }
        else if (typeof wysylkaCzyDom === 'undefined') {
            let paczkomatWysylka = req.body.listaPaczkomatowWysylka.trim()
            paczkomatWysylka = paczkomatWysylka.split(',')
            paczkomatWysylka[0] = paczkomatWysylka[0].trim()
            paczkomatWysylka[1] = paczkomatWysylka[1].trim()
            paczkomatWysylka[2] = paczkomatWysylka[2].trim()
            console.log(paczkomatWysylka)
            if (typeof odbiorCzyPaczkomat === 'undefined') {
                console.log('pacz w dom o')
                // pacz w dom o
                pool.query("INSERT INTO Projekt.paczka_dodanie_view (imie_odbiorcy, nazwisko_odbiorcy, miasto_paczkomat_odbiorca, ulica_paczkomat_odbiorca, nr_ulicy_paczkomat_odbiorca, imie_nadawcy, nazwisko_nadawcy, miasto_paczkomat_nadawca, ulica_paczkomat_nadawca, nr_ulicy_paczkomat_nadawca) VALUES ($1, $2, '', '', 0, $3, $4, $5, $6, $7)", [imieOdbiorcy, nazwiskoOdbiorcy, imieNadawcy, nazwiskoNadawcy, paczkomatWysylka[0], paczkomatWysylka[1], parseInt(paczkomatWysylka[2])], (err, result) => {
                    if (err) {
                        console.log(err.message)
                        if (err.message === 'Dane nadawcy są puste') {
                            let url = '?errn=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Dane odbiorcy są puste') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Odbiorca nie jest zarejestrowany') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Nadawca nie jest zarejestrowany') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else {
                            let url = '?err=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                    }
                    else {
                        res.render("dodanoPaczke")
                    }
                })
            }
            else if (typeof odbiorCzyDom === 'undefined') {
                // pacz w pacz o
                console.log('pacz w pacz o')
                let paczkomatOdbior = req.body.listaPaczkomatowOdbior.trim()
                paczkomatOdbior = paczkomatOdbior.split(',')
                paczkomatOdbior[0] = paczkomatOdbior[0].trim()
                paczkomatOdbior[1] = paczkomatOdbior[1].trim()
                paczkomatOdbior[2] = paczkomatOdbior[2].trim()
                pool.query("INSERT INTO Projekt.paczka_dodanie_view (imie_odbiorcy, nazwisko_odbiorcy, miasto_paczkomat_odbiorca, ulica_paczkomat_odbiorca, nr_ulicy_paczkomat_odbiorca, imie_nadawcy, nazwisko_nadawcy, miasto_paczkomat_nadawca, ulica_paczkomat_nadawca, nr_ulicy_paczkomat_nadawca) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)", [imieOdbiorcy, nazwiskoOdbiorcy, paczkomatOdbior[0], paczkomatOdbior[1], parseInt(paczkomatOdbior[2]), imieNadawcy, nazwiskoNadawcy, paczkomatWysylka[0], paczkomatWysylka[1], parseInt(paczkomatWysylka[2])], (err, result) => {
                    if (err) {
                        console.log(err.message)
                        if (err.message === 'Dane nadawcy są puste') {
                            let url = '?errn=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Dane odbiorcy są puste') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Odbiorca nie jest zarejestrowany') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else if (err.message === 'Nadawca nie jest zarejestrowany') {
                            let url = '?erro=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                        else {
                            let url = '?err=' + err.message
                            res.redirect("/dodajPaczke" + url)
                        }
                    }
                    else {
                        res.render("dodanoPaczke")
                    }
                })
            }
        }
    }
    catch (err) {
        console.log(err)
    }
})

// Endpoint na którym możemy dodać użytkownika
app.get("/dodajUzytkownika", (req, res) => {
    /*
    if (req.query.err === 'Użytkownik już istnieje') {
        res.render("dodajUzytkownika", { tekst: req.query.err })
    }
    else if (req.query.err === 'Dane użytkownika nie mogą być puste') {
        res.render("dodajUzytkownika", { tekst: req.query.err })
    }
    else {
        res.render("dodajUzytkownika", { tekst: '' })
    }
    */
    res.render("dodajUzytkownika", { tekst: req.query.err })
})

// Endpoint który wywołujemy dodaniem użytkownika
app.post("/dodajUzytkownika", (req, res) => {
    try {
        let imie = req.body.imie
        let nazwisko = req.body.nazwisko
        let miasto = req.body.miasto
        let ulica = req.body.ulica
        let nr = parseInt(req.body.nr)
        //console.log(imie)
        //console.log(nazwisko)
        if (isNaN(nr)) {
            let url = '?err=Dane domu nie mogą być puste'
            res.redirect("/dodajUzytkownika" + url)
        }
        else {
            console.log(imie)
            console.log(nazwisko)
            console.log(miasto)
            console.log(ulica)
            console.log(nr)
            pool.query("INSERT INTO Projekt.uzytkownik_view (imie, nazwisko, miasto, ulica, nr_ulicy) VALUES ($1, $2, $3, $4, $5)", [imie, nazwisko, miasto, ulica, nr], (err, result) => {
                if (err) {
                    //console.log(err.message)
                    let url = '?err=' + err.message
                    res.redirect("/dodajUzytkownika" + url)
                }
                else {
                    res.render("uzytkownikDodany")
                }
            })
        }
    } catch (err) {
        console.log(err)
    }
})

// Endpoint na którym możemy sprawdzić paczkę po ID
app.get("/sprawdzPaczke", (req, res) => {
    res.render("sprawdzPaczke", { err: req.query.err })
})

// Endpoint który wywołujemy sprawdzając paczkę po ID
app.post("/sprawdzPaczke", (req, res) => {
    try {
        if (req.body.id != '') {
            pool.query('SELECT * FROM Projekt.paczka_wypisz($1)', [req.body.id], (err, result) => {
                if (err) {
                    console.log(err.message)
                    let url = "?err=" + err.message
                    res.redirect("/sprawdzPaczke" + url)
                }
                else {
                    console.log(result.rows[0])
                    res.render("znalezionoPaczke", { dane: result.rows[0] })
                }
            })
        }
        else {
            let url = '?err=ID nie może być puste'
            res.redirect("/sprawdzPaczke" + url)
        }
    } catch (err) {
        console.log(err)
    }

})

// Endpoint na którym możemy zalogować się jako kurier
app.get("/kurier/login", (req, res) => {
    res.render("kurierLogin", { err: req.query.err })
})

// Endpoint który wywołujemy logując się jako kurier
app.post("/kurier/login", (req, res) => {
    try {
        let imie = req.body.imie
        let nazwisko = req.body.nazwisko
        pool.query("INSERT into Projekt.kurier_login_view (imie, nazwisko) values ($1, $2)", [imie, nazwisko], (err, result) => {
            if (err) {
                let url = '?err=' + err.message
                res.redirect("/kurier/login" + url)
            }
            else {
                let url = '?imie=' + imie + '&nazwisko=' + nazwisko
                res.redirect("/kurier/zalogowany" + url)
            }
        })
    } catch (err) {
        console.log(err)
    }
})

// Endpoint indeksowy kuriera
app.get("/kurier/zalogowany", (req, res) => {
    let url = '?imie=' + req.query.imie + '&nazwisko=' + req.query.nazwisko
    res.render("kurierIndex", { url: url })
})

// Endpoint na którym możemy zmienić status paczki jako kurier
app.get("/kurier/zmienStatus", (req, res) => {
    try {
        let url = '?imie=' + req.query.imie + '&nazwisko=' + req.query.nazwisko
        pool.query("SELECT p.id_paczki, p._status FROM Projekt.paczka AS p JOIN Projekt.paczka_kurier AS pk ON p.id_paczki = pk.id_paczki JOIN Projekt.kurier AS k ON k.id_kuriera = pk.id_kuriera WHERE k.imie = $1 AND k.nazwisko = $2 ORDER BY p.id_paczki", [req.query.imie, req.query.nazwisko], (err, result) => {
            if (err) {
                console.log(err)
            }
            else {
                let paczki = []
                for (let i = 0; i < result.rowCount; i++) {
                    paczki[i] = '' + result.rows[i].id_paczki.toString() + '. ' + result.rows[i]._status
                }
                console.log(paczki)
                res.render("zmienStatus", { url: url, paczki: paczki, ilosc: result.rowCount })
            }
        })
    } catch (error) {
        console.log(err)
    }
})

// Endpoint który wywołujemy zmienając status paczki jako kurier
app.post("/kurier/zmienStatus", (req, res) => {
    try {
        let url = '?imie=' + req.query.imie + '&nazwisko=' + req.query.nazwisko
        let paczka = req.body.paczka.split('.')
        let id = parseInt(paczka[0])
        let status = req.body.status
        pool.query("UPDATE Projekt.paczka SET _status = $1, id_paczki = $2 WHERE id_paczki = $2", [status, id], (err, result) => {
            if (err) {
                url += '&err=' + err.message
                res.redirect("/kurier/zmienStatus" + url)
            }
            else {
                res.render("zmienionoStatus", { url: url })
            }
        })
    } catch (err) {
        console.log(err)
    }
})

// Endpoint na którym możemy dodać nowego kuriera jako kurier
app.get("/kurier/dodajKuriera", (req, res) => {
    let url = '?imie=' + req.query.imie + '&nazwisko=' + req.query.nazwisko
    res.render("dodajKuriera", { url: url, err: req.query.err })
})

// Endpoint który wywołujemy dodając nowego kuriera jako kurier
app.post("/kurier/dodajKuriera", (req, res) => {
    try {
        let url = '?imie=' + req.query.imie + '&nazwisko=' + req.query.nazwisko
        let imie = req.body.imie
        let nazwisko = req.body.nazwisko
        pool.query("INSERT INTO Projekt.kurier_dodaj_view (imie, nazwisko) values ($1 ,$2)", [imie, nazwisko], (err, result) => {
            if (err) {
                res.render("dodajKuriera", { url: url, err: err.message })
            }
            else {
                res.render("dodanoKuriera", { url: url })
            }
        })
    } catch (err) {
        console.log(err)
    }
})

// Endpoint na którym wyświetlamy wszytkie paczki kuriera
app.get("/kurier/wyswietlPaczki", (req, res) => {
    try {
        let url = '?imie=' + req.query.imie + '&nazwisko=' + req.query.nazwisko
        pool.query("SELECT * from Projekt.paczki_wypisz_kurier($1,$2)", [req.query.imie, req.query.nazwisko], (err, result) => {
            if (err) {
                console.log(err)
            }
            else {
                console.log(result.rows)
                res.render("wyswietlPaczki", { url: url, dane: result.rows, ilosc: result.rowCount })
            }
        })
    } catch (err) {
        console.log(err)
    }
})

// Endpoint na którym możemy dodać nowy paczkomat jako kurier
app.get("/kurier/dodajPaczkomat", (req, res) => {
    let url = '?imie=' + req.query.imie + '&nazwisko=' + req.query.nazwisko
    res.render("dodajPaczkomat", { url: url, err: req.query.err })
})

// Endpoint który wywołujemy dodając nowy paczkomat jako kurier
app.post("/kurier/dodajPaczkomat", (req, res) => {
    try {
        let url = '?imie=' + req.query.imie + '&nazwisko=' + req.query.nazwisko
        let nr = parseInt(req.body.nr)
        if (isNaN(nr)) {
            url += '&err=Adres nie może być pusty'
            res.redirect("/kurier/dodajPaczkomat" + url)
        }
        else {
            pool.query("INSERT INTO Projekt.paczkomat_view (miasto, ulica, nr_ulicy) VALUES ($1, $2, $3);", [req.body.miasto, req.body.ulica, nr], (err, result) => {
                if (err) {
                    url += '&err=' + err.message
                    res.redirect("/kurier/dodajPaczkomat" + url)
                }
                else {
                    res.render("dodanoPaczkomat", { url: url })
                }
            })
        }
    } catch (err) {
        console.log(err)
    }
})

app.listen(port, () => {
    console.log(`Running on port ${port}`)
})

