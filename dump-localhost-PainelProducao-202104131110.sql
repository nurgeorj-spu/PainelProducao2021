--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.20
-- Dumped by pg_dump version 11.5

-- Started on 2021-04-13 11:10:32

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 7 (class 2615 OID 37488)
-- Name: ProdNac2021; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "ProdNac2021";


--
-- TOC entry 212 (class 1255 OID 37576)
-- Name: f_trigger_ins_geoaproximacao(); Type: FUNCTION; Schema: ProdNac2021; Owner: -
--

CREATE FUNCTION "ProdNac2021".f_trigger_ins_geoaproximacao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

-- Proposito: verifica se o valor informado para o campo fk_idNacional_apro ja existe na tabela georreferenciamento ou geolocalização

BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "Producao".georreferenciamento WHERE fk_idnacional_geor = NEW.fk_idNacional_apro) and NOT EXISTS (SELECT 1 FROM "Producao".geolocalizacao WHERE fk_idnacional_geol = NEW.fk_idNacional_apro) THEN
	
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_idNacional_apro  || ', fornecido para o campo fk_idnacional_geor, ja esta em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;


--
-- TOC entry 213 (class 1255 OID 37572)
-- Name: f_trigger_ins_geolocalizacao(); Type: FUNCTION; Schema: ProdNac2021; Owner: -
--

CREATE FUNCTION "ProdNac2021".f_trigger_ins_geolocalizacao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

-- Proposito: verifica se o valor informado para o campo fk_idNacional_geol ja existe na tabela georreferenciamento ou geoaproximacao

BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "Producao".georreferenciamento WHERE fk_idnacional_geor = NEW.fk_idNacional_geol) and NOT EXISTS (SELECT 1 FROM "Producao".geoaproximacao WHERE fk_idnacional_apro = NEW.fk_idNacional_geol) THEN
	
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_idNacional_geol  || ', fornecido para o campo fk_idNacional_geol, já está em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;


--
-- TOC entry 211 (class 1255 OID 37574)
-- Name: f_trigger_ins_georreferenciamento(); Type: FUNCTION; Schema: ProdNac2021; Owner: -
--

CREATE FUNCTION "ProdNac2021".f_trigger_ins_georreferenciamento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

-- Proposito: verifica se o valor informado para o campo fk_idNacional_geor ja existe na tabela geolocalizacao ou geoaproximacao

BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "Producao".geolocalizacao WHERE fk_idnacional_geol = NEW.fk_idNacional_geor) and NOT EXISTS (SELECT 1 FROM "Producao".geoaproximacao WHERE fk_idnacional_apro = NEW.fk_idNacional_geor) THEN
	
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_idNacional_geor  || ', fornecido para o campo fk_idNacional_geor, ja esta em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;


--
-- TOC entry 214 (class 1255 OID 37585)
-- Name: f_trigger_logbd(); Type: FUNCTION; Schema: ProdNac2021; Owner: -
--

CREATE FUNCTION "ProdNac2021".f_trigger_logbd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$


/*-- Propósito: Insere na tabela logBD todas as operações realizadas na entidade CDG.
A funões verifica uma cadeia de caracteres contendo INSERT, UPDATE, ou DELETE, e informa para qual operações o gatilho foi disparado (Tipo de dado text).*/
	
BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO "Producao".logbd
		(CodLog, fk_idnacional_log, DataAlteracao, Usuario, Operacao) 
		VALUES
		(NEXTVAL('"Producao".logbd_seq'), NEW.idnacional, current_timestamp, current_user, 'INSERT');
		RETURN NEW;
	
	ELSIF (TG_OP = 'DELETE') THEN
		INSERT INTO "Producao".logbd
		(CodLog, fk_idnacional_log, DataAlteracao, Usuario, Operacao) 
		VALUES
		(NEXTVAL('"Producao".logbd_seq'), OLD.idnacional, current_timestamp, current_user, 'DELETE');
		RETURN OLD;
		
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO "Producao".logbd
		(CodLog, fk_idnacional_log, DataAlteracao, Usuario, Operacao)
		VALUES
		(NEXTVAL('"Producao".logbd_seq'), NEW.idnacional, current_timestamp, current_user, 'UPDATE');
		RETURN NEW;		
				
	END IF;
	RETURN NULL;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 188 (class 1259 OID 37499)
-- Name: cdg; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".cdg (
    idnacional character varying(7) NOT NULL,
    uf character varying(2) NOT NULL,
    cadastrador character varying(250) NOT NULL,
    prodlocali character varying(3) NOT NULL,
    nomeproduto character varying(250),
    producao character varying(100),
    patriarmazen character varying(100),
    nprocesso character varying(100),
    formatocdg character varying(50),
    produtcdg character varying(50),
    nomecolecao character varying(250),
    tipobemuni character varying(100),
    ano date,
    codmunicipio integer,
    coordpresen boolean,
    epsgpres character varying(25),
    epsg integer,
    escala integer,
    spunet_dig integer,
    spunet_analog integer
);


--
-- TOC entry 192 (class 1259 OID 37552)
-- Name: geoaproximacao; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".geoaproximacao (
    codapro integer NOT NULL,
    parecer character varying(25),
    fk_idnacional_apro character varying(7) NOT NULL
);


--
-- TOC entry 196 (class 1259 OID 37592)
-- Name: geoaproximacao_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: -
--

CREATE SEQUENCE "ProdNac2021".geoaproximacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 191 (class 1259 OID 37542)
-- Name: geolocalizacao; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".geolocalizacao (
    codgeoloc integer NOT NULL,
    parecer character varying(25),
    fk_idnacional_geol character varying(7) NOT NULL
);


--
-- TOC entry 195 (class 1259 OID 37590)
-- Name: geolocalizacao_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: -
--

CREATE SEQUENCE "ProdNac2021".geolocalizacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 190 (class 1259 OID 37532)
-- Name: georreferenciamento; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".georreferenciamento (
    codgeorr integer NOT NULL,
    parecer character varying(25),
    verificacao character varying(25),
    fk_idnacional_geor character varying(7) NOT NULL
);


--
-- TOC entry 194 (class 1259 OID 37588)
-- Name: georreferenciamento_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: -
--

CREATE SEQUENCE "ProdNac2021".georreferenciamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 197 (class 1259 OID 37595)
-- Name: logbd; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".logbd (
    codlog integer NOT NULL,
    dataalteracao date NOT NULL,
    usuario character varying(50) NOT NULL,
    operacao character varying(10) NOT NULL,
    fk_idnacional_log character varying(7) NOT NULL
);


--
-- TOC entry 193 (class 1259 OID 37578)
-- Name: logbd_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: -
--

CREATE SEQUENCE "ProdNac2021".logbd_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 189 (class 1259 OID 37512)
-- Name: procedmetodolog; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".procedmetodolog (
    codproced integer NOT NULL,
    datap date,
    fk_idnacional character varying(7) NOT NULL,
    fk_codprof integer NOT NULL,
    fk_codacao integer NOT NULL
);


--
-- TOC entry 187 (class 1259 OID 37494)
-- Name: profissional; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".profissional (
    codprof integer NOT NULL,
    nomesobren character varying(100) NOT NULL,
    cpf character varying(14)
);


--
-- TOC entry 186 (class 1259 OID 37489)
-- Name: tipoacao; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".tipoacao (
    codacao integer NOT NULL,
    servico character varying(25) NOT NULL
);


--
-- TOC entry 2187 (class 0 OID 37499)
-- Dependencies: 188
-- Data for Name: cdg; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2191 (class 0 OID 37552)
-- Dependencies: 192
-- Data for Name: geoaproximacao; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2190 (class 0 OID 37542)
-- Dependencies: 191
-- Data for Name: geolocalizacao; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2189 (class 0 OID 37532)
-- Dependencies: 190
-- Data for Name: georreferenciamento; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2196 (class 0 OID 37595)
-- Dependencies: 197
-- Data for Name: logbd; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2188 (class 0 OID 37512)
-- Dependencies: 189
-- Data for Name: procedmetodolog; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2186 (class 0 OID 37494)
-- Dependencies: 187
-- Data for Name: profissional; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2185 (class 0 OID 37489)
-- Dependencies: 186
-- Data for Name: tipoacao; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--

INSERT INTO "ProdNac2021".tipoacao VALUES (201, 'Digitalização');
INSERT INTO "ProdNac2021".tipoacao VALUES (202, 'Restauração');
INSERT INTO "ProdNac2021".tipoacao VALUES (203, 'Catalogação da Digital');
INSERT INTO "ProdNac2021".tipoacao VALUES (204, 'Catalogação da Analógica');
INSERT INTO "ProdNac2021".tipoacao VALUES (205, 'Validação da Digital');
INSERT INTO "ProdNac2021".tipoacao VALUES (206, 'Validação da Analógica');
INSERT INTO "ProdNac2021".tipoacao VALUES (207, 'Georreferenciamento');
INSERT INTO "ProdNac2021".tipoacao VALUES (208, 'Geolocalização');
INSERT INTO "ProdNac2021".tipoacao VALUES (209, 'Vetorização');
INSERT INTO "ProdNac2021".tipoacao VALUES (210, 'Verificação');


--
-- TOC entry 2202 (class 0 OID 0)
-- Dependencies: 196
-- Name: geoaproximacao_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: -
--

SELECT pg_catalog.setval('"ProdNac2021".geoaproximacao_seq', 1, false);


--
-- TOC entry 2203 (class 0 OID 0)
-- Dependencies: 195
-- Name: geolocalizacao_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: -
--

SELECT pg_catalog.setval('"ProdNac2021".geolocalizacao_seq', 4, true);


--
-- TOC entry 2204 (class 0 OID 0)
-- Dependencies: 194
-- Name: georreferenciamento_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: -
--

SELECT pg_catalog.setval('"ProdNac2021".georreferenciamento_seq', 4, true);


--
-- TOC entry 2205 (class 0 OID 0)
-- Dependencies: 193
-- Name: logbd_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: -
--

SELECT pg_catalog.setval('"ProdNac2021".logbd_seq', 28, true);


--
-- TOC entry 2047 (class 2606 OID 37506)
-- Name: cdg pk_cdg; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".cdg
    ADD CONSTRAINT pk_cdg PRIMARY KEY (idnacional);


--
-- TOC entry 2055 (class 2606 OID 37556)
-- Name: geoaproximacao pk_geoaproximacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".geoaproximacao
    ADD CONSTRAINT pk_geoaproximacao PRIMARY KEY (codapro);


--
-- TOC entry 2053 (class 2606 OID 37546)
-- Name: geolocalizacao pk_geolocalizacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".geolocalizacao
    ADD CONSTRAINT pk_geolocalizacao PRIMARY KEY (codgeoloc);


--
-- TOC entry 2051 (class 2606 OID 37536)
-- Name: georreferenciamento pk_georreferenciamento; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".georreferenciamento
    ADD CONSTRAINT pk_georreferenciamento PRIMARY KEY (codgeorr);


--
-- TOC entry 2057 (class 2606 OID 37599)
-- Name: logbd pk_logbd; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".logbd
    ADD CONSTRAINT pk_logbd PRIMARY KEY (codlog);


--
-- TOC entry 2049 (class 2606 OID 37516)
-- Name: procedmetodolog pk_procedmetodolog; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT pk_procedmetodolog PRIMARY KEY (codproced);


--
-- TOC entry 2045 (class 2606 OID 37498)
-- Name: profissional pk_profissional; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".profissional
    ADD CONSTRAINT pk_profissional PRIMARY KEY (codprof);


--
-- TOC entry 2043 (class 2606 OID 37493)
-- Name: tipoacao pk_tipoacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".tipoacao
    ADD CONSTRAINT pk_tipoacao PRIMARY KEY (codacao);


--
-- TOC entry 2067 (class 2620 OID 37577)
-- Name: geoaproximacao t_ins_geoaproximacao; Type: TRIGGER; Schema: ProdNac2021; Owner: -
--

CREATE TRIGGER t_ins_geoaproximacao BEFORE INSERT ON "ProdNac2021".geoaproximacao FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_geoaproximacao();


--
-- TOC entry 2066 (class 2620 OID 37573)
-- Name: geolocalizacao t_ins_geolocalizacao; Type: TRIGGER; Schema: ProdNac2021; Owner: -
--

CREATE TRIGGER t_ins_geolocalizacao BEFORE INSERT ON "ProdNac2021".geolocalizacao FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_geolocalizacao();


--
-- TOC entry 2065 (class 2620 OID 37575)
-- Name: georreferenciamento t_ins_georreferenciamento; Type: TRIGGER; Schema: ProdNac2021; Owner: -
--

CREATE TRIGGER t_ins_georreferenciamento BEFORE INSERT ON "ProdNac2021".georreferenciamento FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_georreferenciamento();


--
-- TOC entry 2064 (class 2620 OID 37594)
-- Name: cdg t_ins_logbd; Type: TRIGGER; Schema: ProdNac2021; Owner: -
--

CREATE TRIGGER t_ins_logbd AFTER INSERT OR DELETE OR UPDATE ON "ProdNac2021".cdg FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_logbd();


--
-- TOC entry 2063 (class 2606 OID 37557)
-- Name: geoaproximacao fk_geoaproximacao_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".geoaproximacao
    ADD CONSTRAINT fk_geoaproximacao_ref_cdg FOREIGN KEY (fk_idnacional_apro) REFERENCES "ProdNac2021".cdg(idnacional) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2062 (class 2606 OID 37547)
-- Name: geolocalizacao fk_geolocalizacao_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".geolocalizacao
    ADD CONSTRAINT fk_geolocalizacao_ref_cdg FOREIGN KEY (fk_idnacional_geol) REFERENCES "ProdNac2021".cdg(idnacional) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2061 (class 2606 OID 37537)
-- Name: georreferenciamento fk_georreferenciamento_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".georreferenciamento
    ADD CONSTRAINT fk_georreferenciamento_ref_cdg FOREIGN KEY (fk_idnacional_geor) REFERENCES "ProdNac2021".cdg(idnacional) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2058 (class 2606 OID 37517)
-- Name: procedmetodolog fk_procedmetodolog_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_cdg FOREIGN KEY (fk_idnacional) REFERENCES "ProdNac2021".cdg(idnacional) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2059 (class 2606 OID 37522)
-- Name: procedmetodolog fk_procedmetodolog_ref_profissional; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_profissional FOREIGN KEY (fk_codprof) REFERENCES "ProdNac2021".profissional(codprof) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2060 (class 2606 OID 37527)
-- Name: procedmetodolog fk_procedmetodolog_ref_tipoacao; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_tipoacao FOREIGN KEY (fk_codacao) REFERENCES "ProdNac2021".tipoacao(codacao) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2021-04-13 11:10:32

--
-- PostgreSQL database dump complete
--

