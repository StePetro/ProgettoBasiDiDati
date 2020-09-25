-- -----------------------------------------------------
-- Inserimento scheda allenamento
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`inserimento_scheda_allenamento`;  
DELIMITER $$  
USE `Progetto` $$  
CREATE PROCEDURE `inserimento_scheda_allenamento` (IN codice INT,  
                                                   IN cliente VARCHAR(45), 
                                                   IN data_fine DATE,
                                                   IN tutor VARCHAR(45))  
    BEGIN  
		
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;
        
        INSERT INTO Scheda_allenamento
        VALUES (codice, cliente, CURRENT_DATE, data_fine, tutor);
    END $$  
DELIMITER ; 

-- -----------------------------------------------------
-- Inserimento suddivisione
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`inserimento_suddivisione`;  
DELIMITER $$  
USE `Progetto` $$  
CREATE PROCEDURE `inserimento_suddivisione` (IN sessione VARCHAR(45),  
											 IN scheda_allenamento INT,  
											 IN giorno_settimana VARCHAR(45))  
    BEGIN  
		
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;	
        
        INSERT INTO Suddivisione
        VALUES (sessione, scheda_allenamento, giorno_settimana);
    END $$  
DELIMITER ; 

-- -----------------------------------------------------
-- Chiamate
-- -----------------------------------------------------
CALL inserimento_scheda_allenamento (8889, '1436884012978310', '2017-12-15', '2645292214304910');
CALL inserimento_suddivisione ('AvambracciA1', 8889, 'sabato');

-- -----------------------------------------------------
-- Verifica inserimento
-- -----------------------------------------------------
SELECT *
FROM Scheda_allenamento
WHERE Codice=8889 AND Cliente='1436884012978310'
      AND `Data fine`='2017-12-15' AND Tutor='2645292214304910';
	  
SELECT *
FROM Suddivisione
WHERE Sessione='AvambracciA1' AND SchedaAllenamento=8889 AND GiornoSettimana='sabato';