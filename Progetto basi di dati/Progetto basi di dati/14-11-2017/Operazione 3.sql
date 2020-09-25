-- -----------------------------------------------------
-- Inserimento accesso
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`inserimento_accesso`;  
DELIMITER $$  
USE `Progetto` $$  
CREATE PROCEDURE `inserimento_accesso` (IN cliente_ VARCHAR(16),  
                                        IN centro_ INT,  
                                        OUT armadietto_output INT,  
                                        OUT sblocco_output INT)  
    BEGIN  
        DECLARE istante_ TIMESTAMP DEFAULT CURRENT_TIMESTAMP;  
        DECLARE armadietto_ INT DEFAULT 0;  
        DECLARE sblocco_ INT DEFAULT 0; 

		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;		
  
        INSERT INTO `Accesso`  
        VALUES (istante_, cliente_, centro_, 0);  
          
        SELECT D.CodiceIdentificativo INTO armadietto_  
        FROM (SELECT @row_number:=@row_number+1 AS RowNumber, A.CodiceIdentificativo
              FROM (SELECT @row_number:=0) AS R, Armadietto A    
              WHERE A.Occupato=0 AND A.Centro=centro_) AS D  
        WHERE D.RowNumber=1;
  
        IF @row_number <> 0 THEN  
            SET sblocco_ = floor(rand()*1000000);  
            INSERT INTO Assegnamento  
            VALUES (armadietto_, istante_, sblocco_, cliente_);  
  
            UPDATE Armadietto  
            SET Occupato=1  
            WHERE CodiceIdentificativo=armadietto_;  
  
        ELSE  
            SELECT 'Non ci sono armadietti disponibili';  
        END IF; 
          
        SET armadietto_output := armadietto_;  
        SET sblocco_output := sblocco_;  
    END $$  
DELIMITER ;  
 
-- -----------------------------------------------------
-- Chiamate
-- -----------------------------------------------------
CALL inserimento_accesso('DFZDWJ83P06D123W', 5064, @armadietto, @sblocco); 

-- -----------------------------------------------------
-- Verifica inserimento
-- -----------------------------------------------------
SELECT @armadietto, @sblocco;

SELECT *
FROM Armadietto
WHERE CodiceIdentificativo=@armadietto;

SELECT *
FROM Accesso
WHERE Cliente='DFZDWJ83P06D123W' AND Centro=5064 AND Uscita=0;

SELECT *
FROM Assegnamento
WHERE Armadietto=@armadietto AND CodiceSblocco=@sblocco AND Cliente='DFZDWJ83P06D123W';

-- -----------------------------------------------------
-- Versione alternativa dell'inserimento accesso
-- -----------------------------------------------------
DROP PROCEDURE IF EXISTS `Progetto`.`inserimento_accesso`;  
DELIMITER $$  
USE `Progetto` $$  
CREATE PROCEDURE `inserimento_accesso` (IN cliente_ VARCHAR(16),  
                                        IN centro_ INT,  
                                        OUT armadietto_output INT,  
                                        OUT sblocco_output INT)  
    BEGIN  
        DECLARE istante_ TIMESTAMP DEFAULT CURRENT_TIMESTAMP;  
        DECLARE armadietto_ INT DEFAULT 0;  
        DECLARE sblocco_ INT DEFAULT 0; 

		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SELECT "Si e' verificato un errore!";
		END;		
  
        INSERT INTO `Accesso`  
        VALUES (istante_, cliente_, centro_, 0);  
        
        SELECT A.CodiceIdentificativo INTO armadietto_
        FROM Armadietto A
		WHERE A.Occupato=0 AND A.Centro=centro_
        ORDER BY RAND()
        LIMIT 1;
        
        IF armadietto_<>0 THEN
			SET sblocco_=floor(rand()*1000000);
            INSERT INTO Assegnamento
            VALUES (armadietto_, istante_, sblocco_, cliente_);
            
            UPDATE Armadietto
            SET Occupato=1
            WHERE CodiceIdentificativo=armadietto_;
		ELSE
			SELECT 'Non ci sono armadietti disponibili';
		END IF;
          
        SET armadietto_output := armadietto_;  
        SET sblocco_output := sblocco_;  
    END $$  
DELIMITER ;  

/*E' presente una versione alternativa perche'
inizialmente la stored procedure originale ideata
dava alcuni problemi. Cosi' abbiamo cercato su
internet come scegliere una row casuale dal result
set ed e' stato trovato il metodo che sfrutta la
ORDER BY RAND() e LIMIT 1. Questo metodo sceglie
veramente in maniera casuale l'armadietto da assegnare.
Invece, la stored procedure con la RowNumber fornisce
una soluzione in maniera deterministica: sugli stessi dati,
ordinati nello stesso modo, la soluzione e' la stessa.
Poiche' non era richiesto che l'attribuzione di un
armadietto fosse del tutto casuale, abbiamo preferito
lasciare la versione ideata da noi.*/