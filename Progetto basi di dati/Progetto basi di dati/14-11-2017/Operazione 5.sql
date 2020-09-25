-- -----------------------------------------------------
-- Ricerca corsi
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`ricerca_corsi`;  
DELIMITER $$  
CREATE PROCEDURE `Progetto`.`ricerca_corsi` (IN centro INT)  
	BEGIN 
	
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;
		
        SELECT C.Codice, C.Nome, C.Livello, C.DataInizio, C.DataFine, CC.GiornoSettimana, CC.OrarioInizio, CC.Durata, CC.Sala  
        FROM Corso C  
             INNER JOIN  
             Calendario_corso CC  
             ON C.Codice=CC.Corso  
        WHERE C.Centro=centro  
        ORDER BY C.Codice;  
    END $$  
DELIMITER ;  

-- -----------------------------------------------------
-- Chiamate
-- -----------------------------------------------------
CALL ricerca_corsi(5037);  
