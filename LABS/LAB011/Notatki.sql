DECLARE
v_IdPracownika T_PRACOWNIK.id%type;
v_Pensja T_PRACOWNIK.pensja%type;
CURSOR c_MojKursor IS
SELECT id, pensja
FROM T_Pracownik;
BEGIN
OPEN c_MojKursor;
LOOP
FETCH c_MojKursor INTO v_IdPracownika, v_Pensja;
EXIT WHEN c_MojKursor%NotFound;
UPDATE T_PRACOWNIK
SET pensja = pensja + 1000
WHERE id = v_IdPracownika;
DBMS_OUTPUT.PUT_LINE('Pensja pracownika ' || v_IdPracownika || ' zaktualizowana');
END LOOP;
CLOSE c_MojKursor;
END;