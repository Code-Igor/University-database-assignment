    CREATE DATABASE UniversidadeIgor;
	GO
	USE UniversidadeIgor;
	GO
	CREATE TABLE ALUNOS
	(
		MATRICULA INT NOT NULL IDENTITY
			CONSTRAINT PK_ALUNO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
        
	);
	GO
	CREATE TABLE CURSOS
	(
		CURSO CHAR(3) NOT NULL
			CONSTRAINT PK_CURSO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE PROFESSOR
	(
		PROFESSOR INT IDENTITY NOT NULL
			CONSTRAINT PK_PROFESSOR PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE MATERIAS
	(
		SIGLA CHAR(3) NOT NULL,
		NOME VARCHAR(50) NOT NULL,
		CARGAHORARIA INT NOT NULL,
		CURSO CHAR(3) NOT NULL,
		PROFESSOR INT
			CONSTRAINT PK_MATERIA
			PRIMARY KEY (
							SIGLA
							
						)
			CONSTRAINT FK_CURSO
			FOREIGN KEY (CURSO) REFERENCES CURSOS (CURSO),
		CONSTRAINT FK_PROFESSOR
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	GO
	INSERT ALUNOS
	(
		NOME
	)
	VALUES
	('Denis Medina Cabral'),
    ('Caio de Santana Tomaz Walendolf Borguezham Lopes');
	GO
	INSERT CURSOS
	(
		CURSO,
		NOME
	)
	VALUES
	('ENS', 'ENGENHARIA DE SOFTWARE'),
    ('CA', 'CINEMA E AUDIOVISUAL');
	GO
	INSERT PROFESSOR
	(
		NOME
	)
	VALUES
	('DORNEL'),
	('WALTER'),
	('CHAIENE'),
    ('SCORSESE'),
    ('TARANTINO'),
	('MARLENE');
	GO
	
	INSERT MATERIAS
	(
		SIGLA,
		NOME,
		CARGAHORARIA,
		CURSO,
		PROFESSOR
	)
	VALUES
	('BDA', 'BANCO DE DADOS', 144, 'ENS', 1),
	('PRG', 'PROGRAMAÇÃO', 144, 'ENS', 2),
	('ENR', 'ENGENHARIA DE REQUISITOS', 144, 'ENS', 3),
    ('FTA', 'FOTOGRAFIA', 72, 'CA', 4),
	('DIR', 'DIREÇÃO', 144, 'CA', 5),
	('CIN', 'CINEMATOGRAFIA', 144, 'CA', 6);
	GO
	CREATE TABLE MATRICULA
	(
		MATRICULA INT,
		CURSO CHAR(3),
		MATERIA CHAR(3),
		PROFESSOR INT,
		PERLETIVO INT,
		N1 FLOAT,
		N2 FLOAT,
		N3 FLOAT,
		N4 FLOAT,
		TOTALPONTOS FLOAT,
		MEDIA FLOAT,
		F1 INT,
		F2 INT,
		F3 INT,
		F4 INT,
		TOTALFALTAS INT,
		PERCFREQ FLOAT,
		RESULTADO VARCHAR(20)
			CONSTRAINT PK_MATRICULA
			PRIMARY KEY (
							MATRICULA,
							CURSO,
							MATERIA,
							PROFESSOR,
							PERLETIVO
						),
		CONSTRAINT FK_ALUNOS_MATRICULA
			FOREIGN KEY (MATRICULA)
			REFERENCES ALUNOS (MATRICULA),
		CONSTRAINT FK_CURSOS_MATRICULA
			FOREIGN KEY (CURSO)
			REFERENCES CURSOS (CURSO),
		CONSTRAINT FK_MATERIAS FOREIGN KEY (MATERIA) REFERENCES MATERIAS (SIGLA),
		CONSTRAINT FK_PROFESSOR_MATRICULA
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	GO
	ALTER TABLE MATRICULA ADD MEDIAFINAL FLOAT;
	GO
	ALTER TABLE MATRICULA ADD NOTAEXAME FLOAT;
	GO
	ALTER TABLE MATRICULA DROP COLUMN MEDIAFINALGERAL; 
	GO
	
	
	
	
	-- PROCEDURES ABAIXO
	
	
	CREATE OR ALTER PROCEDURE sp_CadastraNotas
	(
		@MATRICULA INT,
		@CURSO CHAR(3),
		@MATERIA CHAR(3),
		@PERLETIVO INT,
		@NOTA FLOAT,
		@FALTA INT,
		@BIMESTRE INT
	)
	AS
	BEGIN

		IF @BIMESTRE = 1
		    BEGIN

                UPDATE MATRICULA
                SET N1 = @NOTA,
                    F1 = @FALTA,
                    TOTALPONTOS = @NOTA,
                    TOTALFALTAS = @FALTA,
                    MEDIA = @NOTA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
		    END

        ELSE 
        
        IF @BIMESTRE = 2
            BEGIN

                UPDATE MATRICULA
                SET N2 = @NOTA,
                    F2 = @FALTA,
                    TOTALPONTOS = @NOTA + N1,
                    TOTALFALTAS = @FALTA + F1,
                    MEDIA = (@NOTA + N1) / 2
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 3
            BEGIN

                UPDATE MATRICULA
                SET N3 = @NOTA,
                    F3 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2,
                    TOTALFALTAS = @FALTA + F1 + F2,
                    MEDIA = (@NOTA + N1 + N2) / 3
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 4
            BEGIN

                DECLARE @RESULTADO VARCHAR(50),
                        @FREQUENCIA FLOAT,
                        @MEDIAFINAL FLOAT,
                        @CARGAHORA FLOAT,
                        @N1 FLOAT, 
                        @N2 FLOAT, 
                        @N3 FLOAT,
                        @TOTALFALTAS INT;
                
                SET @CARGAHORA = (
                    SELECT CARGAHORARIA FROM MATERIAS 
                    WHERE       SIGLA = @MATERIA
                            AND CURSO = @CURSO)
                            
                -- aqui vou "consertar a carga horaria" essa carga presente representa horas, se eu fizer
                -- a carga (exemplo 144) dividido pela quantiade de tempo da aula 1h30min, eu tenho os dias reais de aula
                -- segue:
                            
                SET @CARGAHORA = @CARGAHORA/1.5 --1.5 representa 1h30m
                
                SELECT TOP 1 
                    @N1 = N1,
                    @N2 = N2,
                    @N3 = N3,
                    @TOTALFALTAS = TOTALFALTAS
                FROM MATRICULA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
                

                SET @MEDIAFINAL = ((@NOTA +@N1+ @N2 + @N3) / 4);
                -- o 1.0 é para dar não dar erro,já que o total de faltas é INT e o resto é float
                SET @FREQUENCIA = (((@CARGAHORA-@TOTALFALTAS)*1.0)/@CARGAHORA)*100;
                
             
                
                IF (@MEDIAFINAL >= 7 AND @FREQUENCIA >= 75)
                BEGIN
                    SET @RESULTADO = 'APROVADO';
                END -- 
                ELSE IF (@MEDIAFINAL >= 3 AND @MEDIAFINAL < 7 AND @FREQUENCIA >= 75)
                BEGIN -- exame
                    SET @RESULTADO = 'EXAME';
                END
                ELSE
                BEGIN
                    SET @RESULTADO = 'REPROVADO';
                END
                
                
                UPDATE MATRICULA
                SET N4 = @NOTA,
                    F4 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2 + N3,
                    TOTALFALTAS = @FALTA + F1 + F2 + F3,
                    MEDIA = @MEDIAFINAL,
                    MEDIAFINAL = @MEDIAFINAL,
                    PERCFREQ = @FREQUENCIA,
                    RESULTADO = @RESULTADO     
                WHERE MATRICULA = @MATRICULA
                      AND CURSO = @CURSO
                      AND MATERIA = @MATERIA
                      AND PERLETIVO = @PERLETIVO;
                	
                	
            END
            
        ELSE 
        
        IF @BIMESTRE = 5
            BEGIN
	            
	            -- variavel para controlar se ele passou ou n no exame
	            DECLARE @NOTAAPROVACAO FLOAT;

	            SELECT TOP 1 
                    @MEDIAFINAL = MEDIA,
                    @RESULTADO = RESULTADO
                FROM MATRICULA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;

	            
	            
	     
            	SET @NOTAAPROVACAO = 10 - @MEDIAFINAL 
            	
            	-- verificando se o ser humaninho realmente está em exame para poder fazer o exame
            	IF @RESULTADO = 'EXAME'
            	BEGIN
            	    -- se a nota do exame for maior que a nota que precisa tirar, passa, caso contrario reprova
            	    IF @NOTA >= @NOTAAPROVACAO
	                BEGIN
	            	    SET @RESULTADO = 'APROVADO, PÓS EXAME';
	                END
	                ELSE  
	                BEGIN
	            	    SET @RESULTADO = 'REPROVADO, PÓS EXAME';
	                END
	                
	                -- apenas dá o update se estiver em exame
	                UPDATE MATRICULA 
	                SET NOTAEXAME = @NOTA, 
	                    MEDIAFINAL = ((@NOTA + @MEDIAFINAL)/2),
	                    RESULTADO = @RESULTADO
	                WHERE MATRICULA = @MATRICULA
	            	    AND CURSO = @CURSO
	            	    AND MATERIA = @MATERIA
	            	    AND PERLETIVO = @PERLETIVO;
	            END
	            ELSE
	            BEGIN -- se não tiver em exame dá erro ao tentar fazer o exame
	            	PRINT 'ERRO: O ALUNO PRECISA ESTAR EM EXAME PARA FAZER O EXAME'
	            END
	            
            	
	            
	          
	          
            END
            
		END




    CREATE OR ALTER PROCEDURE procMATRICULAALUNO
    
      @NOME VARCHAR(50),
      @CURSO CHAR(3),
      @PERLETIVO CHAR(4)
   
    AS
	  BEGIN
		  	
		    DECLARE @NOVAMATRICULA INT;
		  
		  	INSERT INTO ALUNOS (NOME)
            VALUES (@NOME);
		  	
		  	SET @NOVAMATRICULA = SCOPE_IDENTITY(); -- fiz isso para adcionar a matricula identity do aluno na tabela matricula
		  	
		  	INSERT INTO MATRICULA (MATRICULA, CURSO, PERLETIVO, MATERIA, PROFESSOR)
		  	SELECT 
                @NOVAMATRICULA,   -- matrícula do aluno. 
                @CURSO,
                @PERLETIVO,
                M.SIGLA,
                M.PROFESSOR -- ID da matéria da tabela MATERIA
            FROM MATERIAS M
            WHERE M.CURSO = @CURSO;
	  END
    GO

    

   -- EXECUTANDO/ TESTANDO
   -- ADICIONANDO ALUNOS 
    
EXEC procMATRICULAALUNO @NOME='DENIS GRUBBA', @CURSO='CA', @PERLETIVO=2024;


-- APROVAÇÃO DIRETA
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'DIR', @PERLETIVO = 2024, @NOTA = 4, @FALTA = 3, @BIMESTRE = 1
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'DIR', @PERLETIVO = 2024, @NOTA = 10, @FALTA = 0, @BIMESTRE = 2
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'DIR', @PERLETIVO = 2024, @NOTA = 10, @FALTA = 0, @BIMESTRE = 3
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'DIR', @PERLETIVO = 2024, @NOTA = 10, @FALTA = 0, @BIMESTRE = 4

-- APROVAÇÃO PÓS EXAME
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'CIN', @PERLETIVO = 2024, @NOTA = 6, @FALTA = 0, @BIMESTRE = 1
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'CIN', @PERLETIVO = 2024, @NOTA = 6, @FALTA = 0, @BIMESTRE = 2
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'CIN', @PERLETIVO = 2024, @NOTA = 8, @FALTA = 0, @BIMESTRE = 3
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'CIN', @PERLETIVO = 2024, @NOTA = 5, @FALTA = 0, @BIMESTRE = 4
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'CIN', @PERLETIVO = 2024, @NOTA = 5, @FALTA = 0, @BIMESTRE = 5

-- REPROVAÇÃO DIRETA POR NOTA
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'FTA', @PERLETIVO = 2024, @NOTA = 0, @FALTA = 2, @BIMESTRE = 1
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'FTA', @PERLETIVO = 2024, @NOTA = 0, @FALTA = 0, @BIMESTRE = 2
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'FTA', @PERLETIVO = 2024, @NOTA = 3, @FALTA = 0, @BIMESTRE = 3
EXEC sp_CadastraNotas @MATRICULA = 3, @CURSO = 'CA',@MATERIA = 'FTA', @PERLETIVO = 2024, @NOTA = 2, @FALTA = 0, @BIMESTRE = 4



EXEC procMATRICULAALUNO @NOME='ANDRÉ DORNEL', @CURSO='ENS', @PERLETIVO=2025;


-- REPROVAÇÃO PÓS EXAME
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'ENR', @PERLETIVO = 2025, @NOTA = 5, @FALTA = 4, @BIMESTRE = 1
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'ENR', @PERLETIVO = 2025, @NOTA = 4, @FALTA = 3, @BIMESTRE = 2
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'ENR', @PERLETIVO = 2025, @NOTA = 7, @FALTA = 0, @BIMESTRE = 3
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'ENR', @PERLETIVO = 2025, @NOTA = 6, @FALTA = 0, @BIMESTRE = 4
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'ENR', @PERLETIVO = 2025, @NOTA = 2, @FALTA = 0, @BIMESTRE = 5

-- REPROVAÇÃO DIRETA POR FALTA
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'PRG', @PERLETIVO = 2025, @NOTA = 10, @FALTA = 30, @BIMESTRE = 1
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'PRG', @PERLETIVO = 2025, @NOTA = 8, @FALTA = 10, @BIMESTRE = 2
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'PRG', @PERLETIVO = 2025, @NOTA = 9, @FALTA = 10, @BIMESTRE = 3
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'PRG', @PERLETIVO = 2025, @NOTA = 9, @FALTA = 20, @BIMESTRE = 4
-- TESTANDO FAZER O EXAME POS REPROVAÇÃO
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'PRG', @PERLETIVO = 2025, @NOTA = 10, @FALTA = 0, @BIMESTRE = 5

-- APROVAÇÃO DIRETA
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'BDA', @PERLETIVO = 2025, @NOTA = 10, @FALTA = 10, @BIMESTRE = 1
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'BDA', @PERLETIVO = 2025, @NOTA = 9, @FALTA = 0, @BIMESTRE = 2
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'BDA', @PERLETIVO = 2025, @NOTA = 6, @FALTA = 5, @BIMESTRE = 3
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'BDA', @PERLETIVO = 2025, @NOTA = 8, @FALTA = 2, @BIMESTRE = 4
-- TESTANDO FAZER O EXAME POS APROVAÇÃO
EXEC sp_CadastraNotas @MATRICULA = 16, @CURSO = 'ENS',@MATERIA = 'BDA', @PERLETIVO = 2025, @NOTA = 10, @FALTA = 0, @BIMESTRE = 5


-- SELECTS uteis que usei durante varias vezes
SELECT * FROM MATRICULA

SELECT * FROM ALUNOS

SELECT * FROM CURSOS


