--------------------- 11/02/2021 -------------------

-- Create table tipoAcao
CREATE TABLE tipoAcao (
  codAcao INTEGER NOT NULL,
  servico VARCHAR(25) NOT NULL,
  CONSTRAINT pk_tipoAcao PRIMARY KEY (codAcao)
);

-- Create table profissional
CREATE TABLE profissional (
  codProf INTEGER NOT NULL,
  nomeSobren VARCHAR(100) NOT NULL,
  cpf VARCHAR(14),
  CONSTRAINT pk_profissional PRIMARY KEY (codProf)
);

-- Create table CDG
CREATE TABLE CDG (
  idNacional INTEGER NOT NULL,
  nomeProduto VARCHAR(250) NOT NULL,
  uf VARCHAR(2) NOT NULL,
  producao VARCHAR(100),
  PatriArmazen VARCHAR(100),
  Nprocesso VARCHAR(100),
  tipoCDG VARCHAR(50) NOT NULL,
  NomeColecao VARCHAR(250),
  conceituacao VARCHAR(100),
  Ano INTEGER,
  EstruturaOrig VARCHAR(50),
  codMunicipio INTEGER,
  escala INTEGER,
  CONSTRAINT pk_CDG PRIMARY KEY (idNacional)
);

-- Create table procedmetodolog
CREATE TABLE procedmetodolog (
  codProced INTEGER NOT NULL,
  fk_idNacional INTEGER NOT NULL,
  fk_codProf INTEGER NOT NULL,
  fk_codAcao INTEGER NOT NULL,
  CONSTRAINT pk_procedmetodolog PRIMARY KEY (codProced),
  CONSTRAINT fk_procedmetodolog_ref_CDG FOREIGN KEY (fk_idNacional) REFERENCES CDG(idNacional) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_procedmetodolog_ref_profissional FOREIGN KEY (fk_codProf) REFERENCES profissional(codProf) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_procedmetodolog_ref_tipoAcao FOREIGN KEY (fk_codAcao) REFERENCES tipoAcao(codAcao) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create table georreferenciamento
CREATE TABLE georreferenciamento (
  codGeorr INTEGER NOT NULL,
  parecerGeorref VARCHAR(3),
  parecerVerificacao VARCHAR(3),
  fk_idNacional_geor INTEGER NOT NULL,
  CONSTRAINT pk_georreferenciamento PRIMARY KEY (codGeorr),
  CONSTRAINT fk_georreferenciamento_ref_CDG FOREIGN KEY (fk_idNacional_geor) REFERENCES CDG(idNacional) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create table geolocalizacao
CREATE TABLE geolocalizacao (
  codGeoloc INTEGER NOT NULL,
  parecerGeoloc VARCHAR(3),
  fk_idNacional_geol INTEGER,
  CONSTRAINT pk_geolocalizacao PRIMARY KEY (codGeoloc),
  CONSTRAINT fk_geolocalizacao_ref_CDG FOREIGN KEY (fk_idNacional_geol) REFERENCES CDG(idNacional) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create table LogBD
CREATE TABLE LogBD (
  codLog INTEGER NOT NULL,
  dataAlteracao DATE NOT NULL,
  Usuario VARCHAR(50),
  Operacao VARCHAR(10),
  fk_idNacional_log INTEGER NOT NULL,
  CONSTRAINT pk_LogBD PRIMARY KEY (codLog),
  CONSTRAINT fk_LogBD_ref_CDG FOREIGN KEY (fk_idNacional_log) REFERENCES CDG(idNacional)
);

--------------------------- Gatilhos -------------------------------

CREATE OR REPLACE FUNCTION "Producao".f_trigger_ins_geolocalizacao()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

-- Propósito: verifica se o valor informado para o campo fk_idNacional já existe na tabela georreferenciamento

BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "Producao".georreferenciamento WHERE fk_idNacional = NEW.fk_idNacional) THEN
	
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_idNacional  || ', fornecido para o campo idNacional, já está em uso na tabela georreferenciamento.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $function$
;

-- Permissions

ALTER FUNCTION "Producao".f_trigger_ins_geolocalizacao() OWNER TO postgres;
GRANT ALL ON FUNCTION "Producao".f_trigger_ins_geolocalizacao() TO postgres;



CREATE TRIGGER t_ins_geolocalizacao BEFORE INSERT ON geolocalizacao FOR EACH ROW EXECUTE PROCEDURE f_trigger_ins_geolocalizacao();
----------------------------------------------------------------------------------------------

--------------------------- Gatilhos -------------------------------

CREATE OR REPLACE FUNCTION "Producao".f_trigger_ins_georreferenciamento()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

-- Propósito: verifica se o valor informado para o campo fk_idNacional já existe na tabela geolocalizacao

BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "Producao".geolocalizacao WHERE fk_idNacional = NEW.fk_idNacional) THEN
	
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_idNacional  || ', fornecido para o campo idNacional, já está em uso na tabela geolocalização.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $function$
;

-- Permissions

ALTER FUNCTION "Producao".f_trigger_ins_georreferenciamento() OWNER TO postgres;
GRANT ALL ON FUNCTION "Producao".f_trigger_ins_georreferenciamento() TO postgres;



CREATE TRIGGER t_ins_georreferenciamento BEFORE INSERT ON georreferenciamento FOR EACH ROW EXECUTE PROCEDURE f_trigger_ins_georreferenciamento();
----------------------------------------------------------------------------------------------

CREATE SEQUENCE logbd_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


----------------------------------------------------------------------------------------------




CREATE or REPLACE FUNCTION "Producao".f_trigger_logbd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$


/*-- Propósito: Insere na tabela logBD todas as operções realizadas na entidade CDG.
A função verifica uma cadeia de caracteres contendo INSERT, UPDATE, ou DELETE, e informa para qual operação o gatilho foi disparado (Tipo de dado text).*/
	
BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO "Producao".logbd
		(CodLog, fk_idnacional_log, DataAlteracao, Usuario, Operacao) 
		VALUES
		(NEXTVAL('"Producao".logbd_seq'), new.fk_idnacional_log, current_timestamp, current_user, 'INSERT');
		RETURN NEW;
	
	ELSIF (TG_OP = 'DELETE') THEN
		INSERT INTO "Producao".logbd
		(CodLog, fk_idnacional_log, DataAlteracao, Usuario, Operacao) 
		VALUES
		(NEXTVAL('"Producao".logbd_seq'), OLD.fk_idnacional_log, current_timestamp, current_user, 'DELETE');
		RETURN OLD;
		
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO "Producao".logbd
		(CodLog, fk_idnacional_log, DataAlteracao, Usuario, Operacao)
		VALUES
		(NEXTVAL('"Producao".logbd_seq'), NEW.fk_idnacional_log, current_timestamp, current_user, 'UPDATE');
		RETURN NEW;		
				
	END IF;
	RETURN NULL;
END;
$$;

CREATE TRIGGER t_ins_logbd BEFORE INSERT OR DELETE OR UPDATE ON "Producao".CDG FOR EACH ROW EXECUTE PROCEDURE "Producao".f_trigger_logbd();


ALTER FUNCTION producao_cartografica_spu.f_trigger_log_completo_folha() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;
