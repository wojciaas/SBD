/*
    Procedura Albumy_Uzytkownika przyjmuje jako parametr adres email użytkownika
    i wyświetla nazwy playlist, które należą do tego użytkownika.
    Działanie procedury:
    Sprawdzenie, czy istnieje użytkownik o podanym adresie email w tabeli UZYTKOWNICY.
    Jeśli nie, zgłoszenie błędu i zakończenie procedury.
    Sprawdzenie, czy użytkownik ma jakieś playlisty w tabeli PLAYLISTY.
    Jeśli nie, zgłoszenie błędu i zakończenie procedury.
    Wyświetlenie id i nazwy playlisty dla każdego wiersza z kursora.
    Zamknięcie i zwolnienie kursora @usr_playlists i zakończenie procedury.
*/

ALTER TABLE UZYTKOWNICY ADD CONSTRAINT EMAIL_UNIQE UNIQUE (EMAIL);

ALTER PROCEDURE Albumy_Uzytkownika
    @v_mailUzytkownika nvarchar(100)
AS
BEGIN
    DECLARE @v_UserName nvarchar(50), @v_UserSurname nvarchar(50), @v_idPlaylisty integer, @v_ErrorMsg nvarchar(255)
    DECLARE @v_PlaylistName nvarchar(255)

    SELECT @v_UserName = IMIE, @v_UserSurname = NAZWISKO
    FROM UZYTKOWNICY
    WHERE EMAIL = @v_mailUzytkownika

    IF @v_UserName IS NULL OR @v_UserSurname IS NULL
    BEGIN
        SET @v_ErrorMsg = CONCAT('Użytkownik o podanym mail ', @v_mailUzytkownika, ' nie istnieje.')
        RAISERROR(@v_ErrorMsg, 16, 1)
        RETURN
    END

    IF NOT EXISTS (SELECT 1 FROM PLAYLISTY WHERE ID_UZYTKOWNIKA = (SELECT ID_UZYTKOWNIKA
                                                                   FROM UZYTKOWNICY
                                                                   WHERE EMAIL = @v_mailUzytkownika))
    BEGIN
        SET @v_ErrorMsg = CONCAT(@v_UserName, ' ', @v_UserSurname, ' nie posiada żadnych playlist.')
        RAISERROR(@v_ErrorMsg, 16, 1)
        RETURN
    END

    DECLARE playlist_cursor CURSOR FOR
    SELECT NAZWA, ID_Playlisty
    FROM PLAYLISTY
    WHERE ID_UZYTKOWNIKA = (SELECT ID_UZYTKOWNIKA FROM UZYTKOWNICY WHERE EMAIL = @v_mailUzytkownika)

    OPEN playlist_cursor
    FETCH NEXT FROM playlist_cursor INTO @v_PlaylistName, @v_idPlaylisty

    PRINT CONCAT('Playlisty użytkownika ', @v_UserName, ' ', @v_UserSurname, ': ')
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT concat('ID: ', @v_idPlaylisty, ', Nazwa: ', @v_PlaylistName)
        FETCH NEXT FROM playlist_cursor INTO @v_PlaylistName, @v_idPlaylisty
    END

END
CLOSE playlist_cursor
DEALLOCATE playlist_cursor

--Wywołujemy procedurę Albumy_Uzytkownika dla użytkownika o mailu 'example@example.com'
--Oczekiwany wynik:Błąd: Użytkownik o podanym mail example@example.com nie istnieje.
EXEC Albumy_Uzytkownika 'example@example.com'
--Wywołujemy procedurę Albumy_Uzytkownika dla użytkownika o mailu 'ex@example.com'
--Oczekiwany wynik: Błąd: Nowy Uzytkownik nie posiada żadnych playlist.
EXEC Albumy_Uzytkownika 'ex@example.com'
--Wywołujemy procedurę Albumy_Uzytkownika dla użytkownika o mailu 'jan.kowalski@example.com'
--Oczekiwany wynik: Playlisty użytkownika Jan Kowalski:
-- ID: 1, Nazwa: Hip Hop Favorites
-- ID: 2, Nazwa: Chill Vibes
-- ID: 3, Nazwa: Workout Mix
-- ID: 4, Nazwa: Old School Rap
-- ID: 5, Nazwa: Morning Commute
EXEC Albumy_Uzytkownika 'jan.kowalski@example.com'


/*
    Procedura Uluibieni_Wykonawcy przyjmuje jako parametr adres email użytkownika i liczbę wykonawców do wyświetlenia
    i wyświetla nazwy wykonawców, których utwory były najczęściej odtwarzane przez tego użytkownika.
    Działanie procedury:
    Sprawdzenie, czy istnieje użytkownik o podanym adresie email w tabeli UZYTKOWNICY.
    Jeśli nie, zgłoszenie błędu i zakończenie procedury.
    Sprawdzenie, czy użytkownik ma jakieś odtworzenia w tabeli HISTORIA_ODTWARZANIA.
    Jeśli nie, zgłoszenie błędu i zakończenie procedury.
    Wyświetlenie nazwy wykonawcy i liczby odtworzeń dla każdego wiersza z kursora.
    Zamknięcie i zwolnienie kursora @fav_artists i zakończenie procedury.
    (Założyłem, że jest to pokroju podsumowania roku jak 'Spotify Wrapped' i uzytkownicy sa aktywnymi sluchaczami, pomimp
    ze nie mam tylu rekordow w bazie danych)
*/
ALTER PROCEDURE Ulubieni_Wykonawcy
    @v_mailUzytkownika nvarchar(100),
    @v_iluWykonawcow int = 3
AS
BEGIN
    DECLARE @v_UserName nvarchar(50), @v_UserSurname nvarchar(50), @v_ErrorMsg nvarchar(255)
    DECLARE @v_Wykonawca nvarchar(100), @v_LiczbaOdtworzen int

    SELECT @v_UserName = IMIE, @v_UserSurname = NAZWISKO
    FROM UZYTKOWNICY
    WHERE EMAIL = @v_mailUzytkownika

    IF @v_UserName IS NULL OR @v_UserSurname IS NULL
    BEGIN
        SET @v_ErrorMsg = CONCAT('Użytkownik o podanym mail ', @v_mailUzytkownika, ' nie istnieje.')
        RAISERROR(@v_ErrorMsg, 16, 1)
        RETURN
    END

    IF NOT EXISTS (SELECT 1 FROM HISTORIA_ODTWARZANIA WHERE ID_UZYTKOWNIKA = (SELECT ID_UZYTKOWNIKA FROM UZYTKOWNICY WHERE EMAIL = @v_mailUzytkownika))
    BEGIN
        SET @v_ErrorMsg = CONCAT(@v_UserName, ' ', @v_UserSurname, ' nie posiada żadnych odtworzeń.')
        RAISERROR(@v_ErrorMsg, 16, 1)
        RETURN
    END

    DECLARE fav_artists_cursor CURSOR FOR
    SELECT TOP (@v_iluWykonawcow) w.NAZWA, COUNT(*)
    FROM HISTORIA_ODTWARZANIA ho
    JOIN UTWORY u ON ho.ID_UTWORU = u.ID_UTWORU
    JOIN ALBUMY a ON u.ID_ALBUMU = a.ID_ALBUMU
    JOIN WYKONAWCY w ON a.ID_WYKONAWCY = w.ID_WYKONAWCY
    WHERE ho.ID_UZYTKOWNIKA = (SELECT ID_UZYTKOWNIKA FROM UZYTKOWNICY WHERE EMAIL = @v_mailUzytkownika)
    GROUP BY w.NAZWA
    ORDER BY COUNT(*) DESC

    OPEN fav_artists_cursor
    FETCH NEXT FROM fav_artists_cursor INTO @v_Wykonawca, @v_LiczbaOdtworzen

    PRINT 'TOP ' + CAST(@v_iluWykonawcow AS nvarchar(10)) + ' ulubionych wykonawców użytkownika ' + @v_UserName + ' ' + @v_UserSurname
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Wykonawca: ' + @v_Wykonawca + ', liczba odtworzeń: ' + CAST(@v_LiczbaOdtworzen AS nvarchar(10))
        FETCH NEXT FROM fav_artists_cursor INTO @v_Wykonawca, @v_LiczbaOdtworzen
    END

END
CLOSE fav_artists_cursor
DEALLOCATE fav_artists_cursor

--Wywołujemy procedurę Ulubieni_Wykonawcy dla użytkownika o mailu 'example@example.com' i ilości wykonawców domyslnej
--Oczekiwany wynik: Błąd: Użytkownik o podanym mail example@example.com nie istnieje.
EXEC Ulubieni_Wykonawcy 'example@example.com'
--Wywołujemy procedurę Ulubieni_Wykonawcy dla użytkownika o mailu 'ex@example.com' i ilości wykonawców domyslnej
--Oczekiwany wynik: Błąd: Nowy Uzytkownik nie posiada żadnych odtworzeń.
EXEC Ulubieni_Wykonawcy 'ex@example.com'
--Wywołujemy procedurę Ulubieni_Wykonawcy dla użytkownika o mailu 'piotr.wojcik@example.com' i ilości wykonawców domyslnej
--Oczekiwany wynik: TOP 3 ulubionych wykonawców użytkownika Piotr Wójcik
-- Wykonawca: Pink Floyd, liczba odtworzeń: 3
-- Wykonawca: AC/DC, liczba odtworzeń: 2
-- Wykonawca: Charlotte de Witte, liczba odtworzeń: 2
EXEC Ulubieni_Wykonawcy 'piotr.wojcik@example.com'
--Wywołujemy procedurę Ulubieni_Wykonawcy dla użytkownika o mailu 'piotr.wojcik@example.com' i ilości wykonawców 5
--Oczekiwany wynik: TOP 5 ulubionych wykonawców użytkownika Piotr Wójcik
-- Wykonawca: Pink Floyd, liczba odtworzeń: 3
-- Wykonawca: AC/DC, liczba odtworzeń: 2
-- Wykonawca: Charlotte de Witte, liczba odtworzeń: 2
-- Wykonawca: Greta Van Fleet, liczba odtworzeń: 1
-- Wykonawca: The Beatles, liczba odtworzeń: 1
EXEC Ulubieni_Wykonawcy 'piotr.wojcik@example.com', 5

/*
    Procedura Utwory_Uzytkownika przyjmuje jako parametr adres email użytkownika i nazwę playlisty
    i wyświetla nazwy utworów, które należą do tej playlisty.
    Działanie procedury:
    Sprawdzenie, czy istnieje użytkownik o podanym adresie email w tabeli UZYTKOWNICY.
    Jeśli nie, zgłoszenie błędu i zakończenie procedury.
    Sprawdzenie, czy użytkownik ma jakieś playlisty w tabeli PLAYLISTY.
    Jeśli nie, zgłoszenie błędu i zakończenie procedury.
    Sprawdzenie, czy użytkownik ma playlistę o podanej nazwie w tabeli PLAYLISTY.
    Jeśli nie, zgłoszenie błędu i zakończenie procedury.
    Wyświetlenie nazwy utworu wraz z jego wykonawcą dla każdego wiersza z kursora.
    Zamknięcie i zwolnienie kursora @usr_playlist_songs i zakończenie procedury.
*/
ALTER PROCEDURE Utwory_Uzytkownika_w_Playliscie
    @v_mailUzytkownika nvarchar(100),
    @v_nazwaPlaylisty nvarchar(255)
AS
BEGIN
    DECLARE @v_UserName nvarchar(50),
            @v_UserSurname nvarchar(50),
            @v_ErrorMsg nvarchar(255),
            @v_SongName nvarchar(255),
            @v_ArtistName nvarchar(255)

    SELECT @v_UserName = IMIE, @v_UserSurname = NAZWISKO
    FROM UZYTKOWNICY
    WHERE EMAIL = @v_mailUzytkownika

    IF @v_UserName IS NULL OR @v_UserSurname IS NULL
    BEGIN
        SET @v_ErrorMsg = CONCAT('Użytkownik o podanym mail ', @v_mailUzytkownika, ' nie istnieje.')
        RAISERROR(@v_ErrorMsg, 16, 1)
        RETURN
    END

    IF NOT EXISTS (SELECT 1 FROM PLAYLISTY WHERE ID_UZYTKOWNIKA = (SELECT ID_UZYTKOWNIKA
                                                                   FROM UZYTKOWNICY
                                                                   WHERE EMAIL = @v_mailUzytkownika))
    BEGIN
        SET @v_ErrorMsg = CONCAT(@v_UserName, ' ', @v_UserSurname, ' nie posiada żadnych playlist.')
        RAISERROR(@v_ErrorMsg, 16, 1)
        RETURN
    END

    IF NOT EXISTS (SELECT 1 FROM PLAYLISTY WHERE ID_UZYTKOWNIKA = (SELECT ID_UZYTKOWNIKA
                                                                   FROM UZYTKOWNICY
                                                                   WHERE EMAIL = @v_mailUzytkownika)
                                                                   AND NAZWA = @v_nazwaPlaylisty)
    BEGIN
        SET @v_ErrorMsg = CONCAT(@v_UserName, ' ', @v_UserSurname, ' nie posiada playlisty o nazwie ', @v_nazwaPlaylisty)
        RAISERROR(@v_ErrorMsg, 16, 1)
        RETURN
    END

    DECLARE usr_playlist_songs_cursor CURSOR FOR
    SELECT u.TYTUL, w.Nazwa
    FROM Utwory_w_playliscie uwp
    JOIN PLAYLISTY p ON p.ID_PLAYLISTY = uwp.ID_PLAYLISTY
    JOIN UTWORY u ON u.ID_UTWORU = uwp.ID_UTWORU
    JOIN Albumy a ON a.ID_ALBUMU = u.ID_ALBUMU
    JOIN Wykonawcy w ON w.ID_WYKONAWCY = a.ID_WYKONAWCY
    WHERE p.ID_UZYTKOWNIKA = (SELECT ID_UZYTKOWNIKA FROM UZYTKOWNICY WHERE EMAIL = @v_mailUzytkownika)
    AND p.NAZWA = @v_nazwaPlaylisty

    OPEN usr_playlist_songs_cursor
    FETCH NEXT FROM usr_playlist_songs_cursor INTO @v_SongName, @v_ArtistName

    PRINT CONCAT('Utwory z playlisty ', @v_nazwaPlaylisty, ' użytkownika ', @v_UserName, ' ', @v_UserSurname, ': ')
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT CONCAT('Tytuł: ', @v_SongName, ', wykonawca: ', @v_ArtistName)
        FETCH NEXT FROM usr_playlist_songs_cursor INTO @v_SongName, @v_ArtistName
    END
END
CLOSE usr_playlist_songs_cursor
DEALLOCATE usr_playlist_songs_cursor

--Wywołujemy procedurę Utwory_Uzytkownika_w_Playliscie dla użytkownika o mailu 'example@example.com' i nazwie playlisty 'example'
--Oczekiwany wynik: Błąd: Użytkownik o podanym mail example@example.com nie istnieje.
EXEC Utwory_Uzytkownika_w_Playliscie 'example@example.com', 'example'
--Wywołujemy procedurę Utwory_Uzytkownika_w_Playliscie dla użytkownika o mailu 'ex@example.com' i nazwie playlisty 'example'
--Oczekiwany wynik: Błąd: Nowy Uzytkownik nie posiada żadnych playlist.
EXEC Utwory_Uzytkownika_w_Playliscie 'ex@example.com', 'example'
--Wywołujemy procedurę Utwory_Uzytkownika_w_Playliscie dla użytkownika o mailu 'karolina.borkowska@example.com' i nazwie playlisty 'example'
--Oczekiwany wynik: Błąd: Karolina Borkowska nie posiada playlisty o nazwie example
EXEC Utwory_Uzytkownika_w_Playliscie 'karolina.borkowska@example.com', 'example'
--Wywołujemy procedurę Utwory_Uzytkownika_w_Playliscie dla użytkownika o mailu 'karolina.borkowska@example.com' i nazwie playlisty 'Hip Hop Favorites'
--Oczekiwany wynik: Utwory z playlisty Hip Hop Favorites użytkownika Karolina Borkowska:
-- Tytuł: Peggy, wykonawca: Myslovitz
-- Tytuł: Kraków, wykonawca: Myslovitz
-- Tytuł: Myszy i ludzie, wykonawca: Myslovitz
-- Tytuł: Długość dźwięku samotności, wykonawca: Myslovitz
-- Tytuł: Chciałbym umrzeć z miłości, wykonawca: Myslovitz
-- Tytuł: Czerwony jak cegła, wykonawca: Dzem
-- Tytuł: Whisky, wykonawca: Dzem
-- Tytuł: Harley mój, wykonawca: Dzem
-- Tytuł: Naiwne pytania, wykonawca: Dzem
-- Tytuł: Sen o Victorii, wykonawca: Dzem
EXEC Utwory_Uzytkownika_w_Playliscie 'karolina.borkowska@example.com', 'Groovy Beats'

/*
    Wyzwalacz delete_artist pboiera z tabeli deleted
    nazwę wykonawcy i usuwa go z tabeli Wykonawcy.
    Działanie wyzwalacza:
    Sprawdzenie, czy wykonawca o podanej nazwie istnieje w tabeli Wykonawcy.
    Jeśli nie, zgłoszenie błędu i zakończenie wyzwalacza.
    Sprawdzenie, czy wykonawca o podanej nazwie jest obserwowany przez użytkowników.
    Jeśli tak, zgłoszenie błędu i zakończenie wyzwalacza.
    Usunięcie wykonawcy o podanej nazwie z tabeli Wykonawcy.
*/
ALTER TRIGGER delete_artist
ON Wykonawcy
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @v_ArtistName nvarchar(50),
            @v_ErrorMsg nvarchar(255)

    SELECT @v_ArtistName = NAZWA
    FROM deleted

    IF NOT EXISTS (SELECT 1 FROM Wykonawcy WHERE NAZWA = @v_ArtistName)
    BEGIN
        SET @v_ErrorMsg = CONCAT('Wykonawca o podanej nazwie ', @v_ArtistName, ' nie istnieje.')
        RAISERROR(@v_ErrorMsg, 16, 1)
        RETURN
    END

    IF (SELECT ID_WYKONAWCY FROM deleted) IN (SELECT ID_WYKONAWCY FROM Obserwowani_Wykonawcy)
    BEGIN
        SET @v_ErrorMsg = CONCAT('Wykonawca ', @v_ArtistName, ' jest obserwowany przez użytkowników.')
        RAISERROR(@v_ErrorMsg, 16, 1)
    END
    ELSE
    BEGIN
        DELETE FROM Wykonawcy
        WHERE ID_WYKONAWCY = (SELECT ID_WYKONAWCY FROM deleted)
        PRINT CONCAT('Usunięto wykonawcę ', @v_ArtistName)
    END
END

--Wywołujemy wyzwalacz delete_artist dla wykonawcy o nazwie 'example'
--Oczekiwany wynik: Błąd: Wykonawca o podanej nazwie example nie istnieje.
DELETE FROM Wykonawcy WHERE NAZWA = 'example'
--Wywołujemy wyzwalacz delete_artist dla wykonawcy o nazwie 'Myslovitz'
--Oczekiwany wynik: Błąd: Wykonawca Myslovitz jest obserwowany przez użytkowników.
DELETE FROM Wykonawcy WHERE NAZWA = 'Myslovitz'
--Twożymy nowego wykonawce o nazwie 'example'
INSERT INTO Wykonawcy (NAZWA, Data_rozpoczecia_kariery) VALUES ('example', getdate())
--Wywołujemy wyzwalacz delete_artist dla wykonawcy o nazwie 'example'
--Oczekiwany wynik: Usunięto wykonawcę example
DELETE FROM Wykonawcy WHERE NAZWA = 'example'

/*
    Wyzwalacz new_followed_artist pobiera z tabeli inserted
    id użytkownika i id wykonawcy i dodaje go do tabeli Obserwowani_Wykonawcy.
    Działanie wyzwalacza:
    Sprawdzenie, czy użytkownik o podanym id istnieje w tabeli UZYTKOWNICY.
    Jeśli nie, zgłoszenie błędu i zakończenie wyzwalacza.
    Sprawdzenie, czy wykonawca o podanym id istnieje w tabeli Wykonawcy.
    Jeśli nie, zgłoszenie błędu i zakończenie wyzwalacza.
    Sprawdzenie, czy użytkownik o podanym id obserwuje wykonawcę o podanym id.
    Jeśli tak, zgłoszenie błędu i zakończenie wyzwalacza.
    Dodanie użytkownika o podanym id do tabeli Obserwowani_Wykonawcy.
*/
ALTER TRIGGER new_followed_artist
ON Obserwowani_Wykonawcy
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @v_UserName nvarchar(50),
            @v_UserSurname nvarchar(50),
            @v_ArtistName nvarchar(50)

    SELECT @v_UserName = IMIE, @v_UserSurname = NAZWISKO
    FROM UZYTKOWNICY
    WHERE ID_UZYTKOWNIKA = (SELECT ID_UZYTKOWNIKA FROM inserted)

    SELECT @v_ArtistName = NAZWA
    FROM WYKONAWCY
    WHERE ID_WYKONAWCY = (SELECT ID_WYKONAWCY FROM inserted)

    IF (SELECT ID_UZYTKOWNIKA FROM inserted) IN (SELECT ID_UZYTKOWNIKA FROM Obserwowani_Wykonawcy)
    AND (SELECT ID_WYKONAWCY FROM inserted) IN (SELECT ID_WYKONAWCY FROM Obserwowani_Wykonawcy)
    BEGIN
        PRINT CONCAT('Użytkownik ', @v_UserName, ' ', @v_UserSurname, ' już obserwuje wykonawcę ', @v_ArtistName)
    END
    ELSE
    BEGIN
        INSERT INTO Obserwowani_Wykonawcy (ID_UZYTKOWNIKA, ID_WYKONAWCY)
        VALUES ((SELECT ID_UZYTKOWNIKA FROM inserted), (SELECT ID_WYKONAWCY FROM inserted))
        PRINT CONCAT('Użytkownik ', @v_UserName, ' ', @v_UserSurname, ' zaczął obserwować wykonawcę ', @v_ArtistName)
    END
END

--Wywołujemy wyzwalacz new_followed_artist dla użytkownika o id 1 i wykonawcy o id 1
--Oczekiwany wynik: Użytkownik Jan Kowalski już obserwuje wykonawcę Pink Floyd
INSERT INTO Obserwowani_Wykonawcy (ID_UZYTKOWNIKA, ID_WYKONAWCY) VALUES (1, 1)
--Wywołujemy wyzwalacz new_followed_artist dla użytkownika o id 1 i wykonawcy o id 18
--Oczekiwany wynik: Użytkownik Jan Kowalski zaczął obserwować wykonawcę Jan-Rapowanie
INSERT INTO Obserwowani_Wykonawcy (ID_UZYTKOWNIKA, ID_WYKONAWCY) VALUES (1, 18)