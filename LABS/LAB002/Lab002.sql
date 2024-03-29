--Zadanie 1--
SELECT IMIE || ' ' || T_OSOBA.NAZWISKO AS "OSOBA"
FROM T_OSOBA
WHERE NAZWISKO NOT LIKE 'E%' AND NAZWISKO NOT LIKE 'P%';

--Zadanie 2--
SELECT NAZWA, CENA
FROM T_PRODUKT
WHERE CENA = (SELECT MAX(CENA) FROM T_PRODUKT);

--Zadanie 3--
SELECT IMIE || ' ' || T_OSOBA.NAZWISKO AS "OSOBY BEZ ZAKUPOW"
FROM T_OSOBA
WHERE NOT EXISTS (
                    SELECT KLIENT
                    FROM T_ZAKUP
                    WHERE T_OSOBA.ID = T_ZAKUP.KLIENT
                );

--Zadanie 4.1--
SELECT NAZWA, CENA
FROM T_PRODUKT
WHERE CENA > ALL (
                    SELECT MAX(CENA)
                    FROM T_PRODUKT
                    INNER JOIN T_KATEGORIA ON T_PRODUKT.KATEGORIA = T_KATEGORIA.ID
                    WHERE T_KATEGORIA.NAZWA = 'fruit'
                );

--Zadanie 4.2--
SELECT NAZWA, CENA
FROM T_PRODUKT
WHERE CENA > ANY (
                    SELECT MIN(CENA)
                    FROM T_PRODUKT
                    INNER JOIN T_KATEGORIA ON T_PRODUKT.KATEGORIA = T_KATEGORIA.ID
                    WHERE T_KATEGORIA.NAZWA = 'vegetable'
                );

--Zadanie 5--
SELECT P.NAZWA AS "PRODUKT",  TL.ILOSC, TK.NAZWA
FROM T_PRODUKT P
INNER JOIN T_LISTAPRODUKTOW TL ON P.ID = TL.PRODUKT
INNER JOIN T_KATEGORIA TK on TK.ID = P.KATEGORIA
INNER JOIN T_ZAKUP TZ on TL.ZAKUP = TZ.ID
WHERE TZ.ID = 4
ORDER BY TL.ILOSC DESC;

--Zadanie 6--
SELECT
FROM