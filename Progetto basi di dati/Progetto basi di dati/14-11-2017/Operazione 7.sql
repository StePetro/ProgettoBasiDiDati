-- -----------------------------------------------------
-- Tabella errori
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Progetto`.`Errore` (
  `TimestampErrore` TIMESTAMP NOT NULL,
  `TestoErrore` VARCHAR(300) NOT NULL,
  PRIMARY KEY(`TimestampErrore`, `TestoErrore`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Log table utilizzo
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Progetto`.`log_utilizzo` (
  `Inizio` TIMESTAMP NOT NULL,
  `Esercizio` INT NOT NULL,
  `Cliente` VARCHAR(16) NOT NULL,
  `TempoImpiegato` TIME(6) NULL,
  `Attrezzatura` INT NULL,
  PRIMARY KEY (`Inizio`, `Esercizio`, `Cliente`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Inserimento utlizzo
-- -----------------------------------------------------
DROP TRIGGER IF EXISTS `Progetto`.`inserimento_utilizzo`;
DELIMITER $$
USE `Progetto`$$  
CREATE TRIGGER `inserimento_utilizzo`
AFTER INSERT ON Esercizio_svolto
FOR EACH ROW
	BEGIN
		
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            INSERT INTO Errore
            VALUES (CURRENT_TIMESTAMP, "Errore durante il trigger inserimento_utilizzo");
		END;
        
		INSERT INTO log_utilizzo
        VALUES (NEW.Inizio, NEW.Esercizio, NEW.Cliente, NEW.TempoImpiegato, NEW.Attrezzatura);
		
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Aggiornamento usura
-- -----------------------------------------------------
DROP EVENT IF EXISTS `Progetto`.`aggiornamento_usura`;
DELIMITER $$
USE `Progetto`$$  
CREATE EVENT `aggiornamento_usura`
ON SCHEDULE EVERY 7 DAY
STARTS '2017-09-19 23:59:00'
DO
	BEGIN
    
		DECLARE finito INT DEFAULT 0;
        DECLARE macchinario INT DEFAULT 0;
        DECLARE tempo DOUBLE DEFAULT 0;
        DECLARE coefficiente DOUBLE DEFAULT 0.000014; -- 100:(2000*60*60)
		
        DECLARE cursore CURSOR FOR
			SELECT LU.Attrezzatura, SUM(TIME_TO_SEC(LU.TempoImpiegato)) AS TempoTotale
            FROM log_utilizzo LU
            GROUP BY LU.Attrezzatura;
            
		DECLARE CONTINUE HANDLER FOR NOT FOUND
			 SET finito=1;
            
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            INSERT INTO Errore
            VALUES (CURRENT_TIMESTAMP, "Errore durante l'evento aggiornamento_usura");
		END;
		
        OPEN cursore;
        preleva: LOOP
			FETCH cursore INTO macchinario, tempo;
            IF finito=1 THEN
				LEAVE preleva;
			END IF;
            
			UPDATE Macchinario
			SET PercentualeUsura=PercentualeUsura+tempo*coefficiente
			WHERE Codice=macchinario;
            
		END LOOP preleva;
        CLOSE cursore;
        
        TRUNCATE TABLE log_utilizzo;
		
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Verifica inserimento
-- -----------------------------------------------------
INSERT INTO Esercizio_Svolto
VALUES ('2008-10-05 07:24:28',111,'4424212744140110',32,89,'00:04:30','00:00:30','bilanciere 5 kg',306);

SELECT *
FROM log_utilizzo;