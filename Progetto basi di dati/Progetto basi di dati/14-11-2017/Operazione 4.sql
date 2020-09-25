-- -----------------------------------------------------
-- Log table post
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Progetto`.`log_post` (
  `Codice` INT NOT NULL,
  `Pubblicatore` VARCHAR(16) NOT NULL,
  `Timestamp` TIMESTAMP NULL,
  `Testo` VARCHAR(500) NULL,
  PRIMARY KEY (`Codice`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Log table allegato
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Progetto`.`log_allegato` (
  `LinkEsterno` VARCHAR(500) NOT NULL,
  `Post` INT NOT NULL,
  `Timestamp` TIMESTAMP NULL,
  PRIMARY KEY (`LinkEsterno`, `Post`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Log table risposta
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Progetto`.`log_risposta` (
  `Post` INT NOT NULL,
  `Risposta` INT NOT NULL,
  `Timestamp` TIMESTAMP NULL,
  PRIMARY KEY (`Post`, `Risposta`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Trigger inserimento post delle ultime 24 ore
-- -----------------------------------------------------
DROP TRIGGER IF EXISTS `Progetto`.`trigger_post_24_ore`;
DELIMITER $$
USE `Progetto`$$
CREATE TRIGGER `trigger_post_24_ore`
AFTER INSERT ON Post
FOR EACH ROW
	BEGIN
    
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            INSERT INTO Errore
            VALUES (CURRENT_TIMESTAMP, "Errore durante il trigger trigger_post_24_ore");
		END;
        
		INSERT INTO log_post
		VALUES (NEW.Codice, NEW.Pubblicatore, NEW.Timestamp, NEW.Testo);
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Trigger inserimento allegati delle ultime 24 ore
-- -----------------------------------------------------
DROP TRIGGER IF EXISTS `Progetto`.`trigger_allegato_24_ore`;
DELIMITER $$
USE `Progetto`$$
CREATE TRIGGER `trigger_allegato_24_ore`
AFTER INSERT ON Allegato
FOR EACH ROW
	BEGIN
    
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            INSERT INTO Errore
            VALUES (CURRENT_TIMESTAMP, "Errore durante il trigger trigger_allegato_24_ore");
		END;
        
		INSERT INTO log_allegato
		VALUES (NEW.LinkEsterno, NEW.Post, CURRENT_TIMESTAMP);
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Trigger inserimento risposte delle ultime 24 ore
-- -----------------------------------------------------
DROP TRIGGER IF EXISTS `Progetto`.`trigger_risposta_24_ore`;
DELIMITER $$
USE `Progetto`$$
CREATE TRIGGER `trigger_risposta_24_ore`
AFTER INSERT ON Risposta
FOR EACH ROW
	BEGIN
    
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            INSERT INTO Errore
            VALUES (CURRENT_TIMESTAMP, "Errore durante il trigger trigger_risposta_24_ore");
		END;
        
		INSERT INTO log_risposta
		VALUES (NEW.Post, NEW.Risposta, CURRENT_TIMESTAMP);
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Aggiornamento log tables post, allegato e risposta
-- -----------------------------------------------------
DROP EVENT IF EXISTS `Progetto`.`aggiornamento_log_post`;
DELIMITER $$
USE `Progetto`$$
CREATE EVENT `aggiornamento_log_post`
ON SCHEDULE EVERY 1 DAY
STARTS '2017-09-19 23:59:00'
DO
	BEGIN
    
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            INSERT INTO Errore
            VALUES (CURRENT_TIMESTAMP, "Errore durante l'evento aggiornamento_usura");
		END;
        
		DELETE FROM log_post
		WHERE DAY(Timestamp)<>DAY(CURRENT_DATE);
        
		DELETE FROM log_allegato
		WHERE DAY(Timestamp)<>DAY(CURRENT_DATE);
        
		DELETE FROM log_risposta
		WHERE DAY(Timestamp)<>DAY(CURRENT_DATE);
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Ricerca post amici ultime 24 ore
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`post_amici`;
DELIMITER $$
USE `Progetto`$$
CREATE PROCEDURE `post_amici` (IN cliente VARCHAR(16))
	BEGIN
    
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;	
        
		SELECT LP.*
		FROM log_post LP
             INNER JOIN
             Amicizia A
             ON (LP.Pubblicatore=A.Richiedente AND A.Ricevente=cliente)
                OR (LP.Pubblicatore=A.Ricevente AND A.Richiedente=cliente)
		WHERE LP.Pubblicatore<>cliente AND
              LP.Timestamp > (CURRENT_TIMESTAMP - INTERVAL 24 HOUR)
              AND A.Stato='Accettata'
	    ORDER BY LP.Timestamp DESC;
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Ricerca allegati di un post delle ultime 24 ore
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`allegati_post_24_ore`;
DELIMITER $$
USE `Progetto`$$
CREATE PROCEDURE `allegati_post_24_ore` (IN post INT)
	BEGIN
    
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;	
        
		SELECT LA.LinkEsterno
        FROM log_allegato LA
        WHERE LA.Post=post;
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Ricerca risposte di un post delle ultime 24 ore
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`ottieni_risposte_24_ore`;
DELIMITER $$
USE `Progetto`$$
CREATE PROCEDURE `ottieni_risposte_24_ore` (IN post INT)
	BEGIN
    
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;	
        
		SELECT LP.*
        FROM log_risposta LR
             INNER JOIN
             log_post LP
             ON LR.Risposta=LP.Codice
		WHERE LR.Post=post;
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Ricerca post di cui conosciamo una risposta
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`ottieni_post_originario`;
DELIMITER $$
USE `Progetto`$$
CREATE PROCEDURE `ottieni_post_originario` (IN post INT)
	BEGIN
    
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;
        
		SELECT P.*
        FROM log_risposta LR
             INNER JOIN
             Post P
             ON LR.Post=P.Codice
		WHERE LR.Risposta=post;
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Valori per esempi
-- -----------------------------------------------------
INSERT INTO post 
VALUES (7999,'2324129682344350',CURRENT_TIMESTAMP,'Presentiamoci! Io sono Umberto Villa e vivo a Firenze!');
INSERT INTO post 
VALUES (8000,'DFZDWJ83P06D123W',CURRENT_TIMESTAMP,'Ciao a tutti, mi chiamo Stefano Rossi, sono nato il primo Aprile del 1970 e vivo a Lucca, dove sono anche nato.');
INSERT INTO allegato 
VALUES ('www.google.com',8000);
INSERT INTO allegato 
VALUES ('www.yahoo.it',8000);
INSERT INTO risposta 
VALUES (7999,8000);
INSERT INTO post 
VALUES (8001,'1436839489568150',CURRENT_TIMESTAMP,'Piacere di conoscerti!');
INSERT INTO risposta 
VALUES (8000,8001);

-- -----------------------------------------------------
-- Chiamate
-- -----------------------------------------------------
CALL post_amici('4424212744140110');
CALL allegati_post_24_ore(8000);
CALL ottieni_risposte_24_ore(8000);
CALL ottieni_post_originario(8000);
