-- -----------------------------------------------------
-- Inserimento esercizio svolto
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`inserimento_esercizio_svolto`;
DELIMITER $$
USE `Progetto` $$
CREATE PROCEDURE `inserimento_esercizio_svolto` (IN inizio TIMESTAMP,  
                                                 IN esercizio INT,  
                                                 IN cliente VARCHAR(16),  
                                                 IN calorie INT,  
                                                 IN battito INT,  
                                                 IN tempo TIME(6),  
                                                 IN recupero TIME(6),  
                                                 IN configurazione VARCHAR(45),  
                                                 IN attrezzatura INT)  
    BEGIN  
	
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;	
		
        INSERT INTO `Esercizio_Svolto`  
        VALUES (inizio, esercizio, cliente, calorie, battito, tempo, recupero, configurazione, attrezzatura);  
    END $$  
DELIMITER ;

-- -----------------------------------------------------
-- Chiamate
-- -----------------------------------------------------
CALL inserimento_esercizio_svolto('2000-05-01 12:04:57',102,'DFZDWJ83P06D123W',98,144,'00:03:40','00:00:30','panca 55°',301); 

-- -----------------------------------------------------
-- Verifica inserimento
-- -----------------------------------------------------
SELECT *
FROM `Esercizio_Svolto`
WHERE Inizio='2000-05-01 12:04:57' AND Esercizio=102 AND Cliente='DFZDWJ83P06D123W'
      AND CalorieConsumate=98 AND BattitoCardiacoMedio=144 AND TempoImpiegato='00:03:40'
	  AND TempoRecuperoMedio='00:00:30' AND Configurazione='panca 55°' AND Attrezzatura=301;