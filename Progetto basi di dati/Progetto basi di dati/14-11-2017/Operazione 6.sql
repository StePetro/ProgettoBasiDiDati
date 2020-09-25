-- -----------------------------------------------------
-- Log table rata
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Progetto`.`log_rata` (
  `Scadenza` DATE NOT NULL,
  `Pagamento` INT NOT NULL,
  `Importo` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Scadenza`, `Pagamento`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Inserimento contratto
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`inserimento_contratto`;
DELIMITER $$
USE `Progetto`$$
CREATE PROCEDURE `inserimento_contratto` (IN codice_ INT,
                                          IN cliente_ VARCHAR(16),
                                          IN consulente_ VARCHAR(16),
                                          IN prezzo_ INT,
                                          IN sottoscrizione_ DATE,
                                          IN accessi_ VARCHAR(45),
                                          IN durata_ VARCHAR(45),
                                          IN tipo_ VARCHAR(45),
                                          IN saldato_ BOOL,
                                          IN centro1_ INT,
                                          IN centro2_ INT,
                                          IN centro3_ INT,
                                          IN obiettivo_ VARCHAR(45),
                                          IN rate_ BOOL,
                                          IN istituto_ VARCHAR(45),
                                          IN interesse_ INT,
                                          IN username_ VARCHAR(45),
                                          IN password_ VARCHAR(45))
	BEGIN
		DECLARE numero_contratti INT DEFAULT 0;
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;
        
        SELECT COUNT(*) INTO numero_contratti
        FROM Contratto Co
        WHERE Co.Cliente=cliente_;
        
        IF numero_contratti=0 THEN
			INSERT INTO Contratto
			VALUES (codice_, cliente_, consulente_, prezzo_, sottoscrizione_, accessi_, durata_, tipo_, saldato_);
    
			INSERT INTO Sede
			VALUES (codice_, centro1_);
        
			IF centro2_ IS NOT NULL THEN
				INSERT INTO Sede
				VALUES (codice_, centro2_);
				IF centro3_ IS NOT NULL THEN
					INSERT INTO Sede
					VALUES (codice_, centro3_);
				END IF;
			END IF;
            
            INSERT INTO Obiettivo
            VALUES (obiettivo_);
            
			INSERT INTO Scelta
			VALUES (obiettivo_, codice_);
    
			UPDATE Cliente
            SET Username=username_, Password=password_
            WHERE CodiceFiscale=cliente_;
    
			IF rate_=1 AND saldato_=0 THEN
				INSERT INTO Pagamento_rateizzato
				VALUES (codice_, istituto_, interesse_);
			END IF;
		END IF;
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Inserimento potenziamento muscolare
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`inserimento_potenziamento`;
DELIMITER $$
USE `Progetto`$$
CREATE PROCEDURE `inserimento_potenziamento` (IN obiettivo VARCHAR(45),
											  IN gruppo VARCHAR(45),
											  IN livello VARCHAR(45))
	BEGIN
    
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;
        
		IF SUBSTRING(obiettivo FROM 1 FOR 13)='Potenziamento' THEN
			INSERT INTO Potenziamento_muscolare
			VALUES (obiettivo, gruppo, livello);
		END IF;
        
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Inserimento rata
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`inserimento_rata`;
DELIMITER $$
USE `Progetto`$$
CREATE PROCEDURE `inserimento_rata` (IN contratto INT,
                                     IN scadenza DATE,
                                     IN importo VARCHAR (45))
	BEGIN
    
		DECLARE saldato TINYINT DEFAULT 0;
        DECLARE controllo_pagamento_rateizzato INT DEFAULT 0;
		DECLARE costo INT DEFAULT 0;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;
        
        SELECT COUNT(*) INTO controllo_pagamento_rateizzato
        FROM Pagamento_rateizzato PT
        WHERE PT.Contratto=contratto;
    
		SELECT C.Saldato, C.Prezzo INTO saldato, costo
		FROM Contratto C
		WHERE C.Codice=contratto;
    
		IF controllo_pagamento_rateizzato>0 AND saldato=0 AND importo<costo AND scadenza>CURRENT_DATE THEN
			INSERT INTO Rata
			VALUES (scadenza, contratto, 'non saldato', importo);
            
            INSERT INTO log_rata
            VALUES (scadenza, contratto, importo); -- serve per la business rule del controllo delle rate
		END IF;
        
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Inserimento accesso sala
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`inserimento_accesso_sala`;
DELIMITER $$
USE `Progetto`$$
CREATE PROCEDURE `inserimento_accesso_sala` (IN contratto INT,
                                             IN centro INT,
                                             IN sala VARCHAR(45),
                                             IN accessi_settimanali INT)
	BEGIN
    
		DECLARE controllo_sede_contratto INT DEFAULT 0;
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;
        
        SELECT COUNT(*) INTO controllo_sede_contratto
        FROM Sede S
        WHERE S.Contratto=contratto AND S.Centro=centro;
        
        IF controllo_sede_contratto>0 THEN
			INSERT INTO Possibilita_accesso
            VALUES (contratto, sala, centro, accessi_settimanali);
		END IF;
        
	END $$
DELIMITER ;

-- -----------------------------------------------------
-- Chiamate
-- -----------------------------------------------------
CALL inserimento_contratto (9996,'2324129460620950','MRTSRA04D46G095F', 150, '2016/09/19', 3, '3 mesi', 'silver', 0, 5036, 5037, 5040, 'Potenziamento565', 1, 'Intesa Sanpaolo SpA', 4, 'Pippo', '1234567890');
CALL inserimento_potenziamento ('Potenziamento565','Pettorali','massimo');
CALL inserimento_rata (9996, '2018-12-13', 50);
CALL inserimento_accesso_sala (9996, 5037, 'Spinning', 3);

-- -----------------------------------------------------
-- Verifica inserimento
-- -----------------------------------------------------
SELECT *
FROM Contratto
WHERE Codice=9996;

SELECT *
FROM Sede
WHERE Contratto=9996;

SELECT *
FROM Obiettivo
WHERE Scopo='Potenziamento565';

SELECT *
FROM Cliente
WHERE CodiceFiscale='2324129460620950';

SELECT *
FROM Pagamento_rateizzato
WHERE Contratto=9996;


SELECT *
FROM Potenziamento_muscolare
WHERE Obiettivo='Potenziamento565';


SELECT *
FROM Rata
WHERE Pagamento=9996;

SELECT *
FROM Possibilita_accesso
WHERE Contratto=9996;
