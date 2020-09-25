-- -----------------------------------------------------
-- Acquisto prodotto
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`acquisto_prodotto`;
DELIMITER $$
USE `Progetto`$$
CREATE PROCEDURE acquisto_prodotto (IN cliente_ VARCHAR(16),
                                    IN integratore_ INT,
                                    IN centro_ INT)
	BEGIN
		DECLARE presenza INT DEFAULT 0;
	
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;	
		
		SELECT COUNT(*) INTO presenza
		FROM Magazzino M
		WHERE M.Integratore=integratore_ AND M.Centro=centro_;
	
		IF presenza > 0 THEN
			INSERT INTO Acquisto
			VALUES (cliente_, integratore_, CURRENT_DATE, centro_);
            
			DELETE FROM Magazzino
			WHERE Integratore=integratore_ AND Centro=centro_;
		ELSE
			SELECT "L'integratore selezionato non e' presente nel magazzino";
		END IF;
		
END $$
DELIMITER ;

-- -----------------------------------------------------
-- Verifica presenza
-- -----------------------------------------------------
SELECT *
FROM Magazzino
WHERE Integratore=99998 AND Centro=5037;

-- -----------------------------------------------------
-- Chiamate
-- -----------------------------------------------------
CALL acquisto_prodotto('5803341448963410', 99998, 5037);

-- -----------------------------------------------------
-- Verifica cancellazione
-- -----------------------------------------------------
SELECT *
FROM Magazzino
WHERE Integratore=99998 AND Centro=5037;

-- -----------------------------------------------------
-- Verifica inserimento
-- -----------------------------------------------------
SELECT *
FROM Acquisto
WHERE Cliente='5803341448963410' AND Integratore=99998
      AND Centro=5037;