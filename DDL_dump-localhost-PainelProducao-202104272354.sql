--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.20
-- Dumped by pg_dump version 11.5

-- Started on 2021-04-27 23:54:34

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
-- TOC entry 4 (class 2615 OID 38181)
-- Name: ProdNac2021; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "ProdNac2021";
ALTER SCHEMA "ProdNac2021" OWNER TO postgres;

--
-- TOC entry 213 (class 1255 OID 38182)
-- Name: f_trigger_ins_geoaproximacao(); Type: FUNCTION; Schema: ProdNac2021; Owner: postgres
--

CREATE FUNCTION "ProdNac2021".f_trigger_ins_geoaproximacao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Proposito: verifica se o valor informado para o campo fk_idCdg_apro ja existe na tabela georreferenciamento ou geolocalização.
BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "ProdNac2021".georreferenciamento WHERE fk_idCdg_geor = NEW.fk_idCdg_apro) and NOT EXISTS (SELECT 1 FROM "ProdNac2021".geolocalizacao WHERE fk_idCdg_geol = NEW.fk_idCdg_apro) THEN
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_idCdg_apro  || ', fornecido para o campo fk_idCdg_geor, ja esta em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;

ALTER FUNCTION "ProdNac2021".f_trigger_ins_geoaproximacao() OWNER TO postgres;


-
-- TOC entry 214 (class 1255 OID 38183)
-- Name: f_trigger_ins_geolocalizacao(); Type: FUNCTION; Schema: ProdNac2021; Owner: postgres
--

CREATE FUNCTION "ProdNac2021".f_trigger_ins_geolocalizacao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Proposito: verifica se o valor informado para o campo fk_idCdg_geol ja existe na tabela georreferenciamento ou geoaproximacao
BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "ProdNac2021".georreferenciamento WHERE fk_idCdg_geor = NEW.fk_idCdg_geol) and NOT EXISTS (SELECT 1 FROM "ProdNac2021".geoaproximacao WHERE fk_idCdg_apro = NEW.fk_idCdg_geol) THEN
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_idCdg_geol  || ', fornecido para o campo fk_idCdg_geol, já está em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;

ALTER FUNCTION "ProdNac2021".f_trigger_ins_geolocalizacao() OWNER TO postgres;

-
-- TOC entry 215 (class 1255 OID 38184)
-- Name: f_trigger_ins_georreferenciamento(); Type: FUNCTION; Schema: ProdNac2021; Owner: postgres
--

CREATE FUNCTION "ProdNac2021".f_trigger_ins_georreferenciamento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Proposito: verifica se o valor informado para o campo fk_idCdg_geor ja existe na tabela geolocalizacao ou geoaproximacao
BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "ProdNac2021".geolocalizacao WHERE fk_idCdg_geol = NEW.fk_idCdg_geor) and NOT EXISTS (SELECT 1 FROM "ProdNac2021".geoaproximacao WHERE fk_idCdg_apro = NEW.fk_idCdg_geor) THEN
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_idCdg_geor  || ', fornecido para o campo fk_idCdg_geor, ja esta em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;

ALTER FUNCTION "ProdNac2021".f_trigger_ins_georreferenciamento() OWNER TO postgres;


--
-- TOC entry 212 (class 1255 OID 38185)
-- Name: f_trigger_logbd(); Type: FUNCTION; Schema: ProdNac2021; Owner: postgres
--

CREATE FUNCTION "ProdNac2021".f_trigger_logbd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/*-- Propósito: Insere na tabela logBD todas as operações realizadas na entidade CDG.
A funões verifica uma cadeia de caracteres contendo INSERT, UPDATE, ou DELETE, e informa para qual operações o gatilho foi disparado (Tipo de dado text).*/
BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO "ProdNac2021".logbd
		(codlog, fk_idCdg_log, dataalteracao, usuario, operacao) 
		VALUES
		(NEXTVAL('"ProdNac2021".logbd_seq'), NEW.idCdg, current_timestamp, current_user, 'INSERT');
		RETURN NEW;
	ELSIF (TG_OP = 'DELETE') THEN
		INSERT INTO "ProdNac2021".logbd
		(codlog, fk_idCdg_log, dataalteracao, usuario, operacao) 
		VALUES
		(NEXTVAL('"ProdNac2021".logbd_seq'), OLD.idCdg, current_timestamp, current_user, 'DELETE');
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO "ProdNac2021".logbd
		(codlog, fk_idCdg_log, dataalteracao, usuario, operacao)
		VALUES
		(NEXTVAL('"ProdNac2021".logbd_seq'), NEW.idCdg, current_timestamp, current_user, 'UPDATE');
		RETURN NEW;		
	END IF;
	RETURN NULL;
END;
$$;

ALTER FUNCTION "ProdNac2021".f_trigger_logbd() OWNER TO postgres;

SET default_tablespace = '';
SET default_with_oids = false;


--
-- TOC entry 186 (class 1259 OID 38186)
-- Name: cdg; Type: TABLE; Schema: ProdNac2021; Owner: postgres
--

CREATE TABLE "ProdNac2021".cdg (
    idcdg integer NOT NULL,
    idnacional character varying(7) NOT NULL,
    uf character varying(2),
    cadastrador character varying(250),
    prodlocali character varying(3),
    nomeproduto character varying(250),
    producao character varying(100),
    patriarmazen character varying(100),
    nprocesso character varying(100),
    formatocdg character varying(50),
    produtcdg character varying(50),
    nomecolecao character varying(250),
    tipobemuni character varying(100),
    ano integer,
    codmunicipio integer,
    coordpresen character(3),
    epsgpres character varying(25),
    epsg integer,
    escala character varying,
    spunet_dig character varying,
    spunet_analog character varying
);

ALTER TABLE "ProdNac2021".cdg OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 38192)
-- Name: geoaproximacao; Type: TABLE; Schema: ProdNac2021; Owner: postgres
--

CREATE TABLE "ProdNac2021".geoaproximacao (
    codapro integer NOT NULL,
    parecer character varying(25),
    fk_idcdg_apro integer NOT NULL
);

ALTER TABLE "ProdNac2021".geoaproximacao OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 38195)
-- Name: geoaproximacao_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: postgres
--

CREATE SEQUENCE "ProdNac2021".geoaproximacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
	
ALTER TABLE "ProdNac2021".geoaproximacao_seq OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 38197)
-- Name: geolocalizacao; Type: TABLE; Schema: ProdNac2021; Owner: postgres
--

CREATE TABLE "ProdNac2021".geolocalizacao (
    codgeoloc integer NOT NULL,
    parecer character varying(25),
    fk_idcdg_geol integer NOT NULL
);

ALTER TABLE "ProdNac2021".geolocalizacao OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 38200)
-- Name: geolocalizacao_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: postgres
--

CREATE SEQUENCE "ProdNac2021".geolocalizacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
	
ALTER TABLE "ProdNac2021".geolocalizacao_seq OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 38202)
-- Name: georreferenciamento; Type: TABLE; Schema: ProdNac2021; Owner: postgres
--

CREATE TABLE "ProdNac2021".georreferenciamento (
    codgeorr integer NOT NULL,
    parecer character varying(25),
    verificacao character varying(25),
    fk_idcdg_geor integer NOT NULL
);

ALTER TABLE "ProdNac2021".georreferenciamento OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 38205)
-- Name: georreferenciamento_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: postgres
--

CREATE SEQUENCE "ProdNac2021".georreferenciamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "ProdNac2021".georreferenciamento_seq OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 38207)
-- Name: logbd; Type: TABLE; Schema: ProdNac2021; Owner: postgres
--

CREATE TABLE "ProdNac2021".logbd (
    codlog integer NOT NULL,
    dataalteracao date NOT NULL,
    usuario character varying(50) NOT NULL,
    operacao character varying(10) NOT NULL,
    fk_idcdg_log integer NOT NULL
);

ALTER TABLE "ProdNac2021".logbd OWNER TO postgres;

-
-- TOC entry 198 (class 1259 OID 38327)
-- Name: logbd_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: postgres
--

CREATE SEQUENCE "ProdNac2021".logbd_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "ProdNac2021".logbd_seq OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 38212)
-- Name: procedmetodolog; Type: TABLE; Schema: ProdNac2021; Owner: postgres
--

CREATE TABLE "ProdNac2021".procedmetodolog (
    codproced numeric(13,0) NOT NULL,
    datap date,
    fk_idcdg integer NOT NULL,
    fk_codprof integer NOT NULL,
    fk_codacao integer NOT NULL,
    idnacional character varying(7)
);

ALTER TABLE "ProdNac2021".procedmetodolog OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 38305)
-- Name: procedmetodolog_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: postgres
--

CREATE SEQUENCE "ProdNac2021".procedmetodolog_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "ProdNac2021".procedmetodolog_seq OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 38215)
-- Name: profissional; Type: TABLE; Schema: ProdNac2021; Owner: postgres
--

CREATE TABLE "ProdNac2021".profissional (
    codprof integer NOT NULL,
    "nomeCompleto" character varying(70),
    "UF" character varying(2),
    nomeformatado character varying(70)
);

ALTER TABLE "ProdNac2021".profissional OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 38218)
-- Name: tipoacao; Type: TABLE; Schema: ProdNac2021; Owner: postgres
--

CREATE TABLE "ProdNac2021".tipoacao (
    codacao integer NOT NULL,
    servico character varying(25) NOT NULL
);

ALTER TABLE "ProdNac2021".tipoacao OWNER TO postgres;

--
-- TOC entry 2205 (class 0 OID 0)
-- Dependencies: 188
-- Name: geoaproximacao_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: postgres
--
SELECT pg_catalog.setval('"ProdNac2021".geoaproximacao_seq', 1, false);

--
-- TOC entry 2206 (class 0 OID 0)
-- Dependencies: 190
-- Name: geolocalizacao_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: postgres
--
SELECT pg_catalog.setval('"ProdNac2021".geolocalizacao_seq', 4, true);

--
-- TOC entry 2207 (class 0 OID 0)
-- Dependencies: 192
-- Name: georreferenciamento_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: postgres
--
SELECT pg_catalog.setval('"ProdNac2021".georreferenciamento_seq', 4, true);

--
-- TOC entry 2208 (class 0 OID 0)
-- Dependencies: 198
-- Name: logbd_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: postgres
--
SELECT pg_catalog.setval('"ProdNac2021".logbd_seq', 4327, true);

--
-- TOC entry 2209 (class 0 OID 0)
-- Dependencies: 197
-- Name: procedmetodolog_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: postgres
--
SELECT pg_catalog.setval('"ProdNac2021".procedmetodolog_seq', 2691, true);

--
-- TOC entry 2045 (class 2606 OID 38222)
-- Name: cdg pk_cdg; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".cdg
    ADD CONSTRAINT pk_cdg PRIMARY KEY (idcdg);

--
-- TOC entry 2047 (class 2606 OID 38224)
-- Name: geoaproximacao pk_geoaproximacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".geoaproximacao
    ADD CONSTRAINT pk_geoaproximacao PRIMARY KEY (codapro);

--
-- TOC entry 2049 (class 2606 OID 38226)
-- Name: geolocalizacao pk_geolocalizacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".geolocalizacao
    ADD CONSTRAINT pk_geolocalizacao PRIMARY KEY (codgeoloc);

--
-- TOC entry 2051 (class 2606 OID 38228)
-- Name: georreferenciamento pk_georreferenciamento; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".georreferenciamento
    ADD CONSTRAINT pk_georreferenciamento PRIMARY KEY (codgeorr);

--
-- TOC entry 2053 (class 2606 OID 38230)
-- Name: logbd pk_logbd; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".logbd
    ADD CONSTRAINT pk_logbd PRIMARY KEY (codlog);

--
-- TOC entry 2057 (class 2606 OID 38234)
-- Name: profissional pk_profissional; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".profissional
    ADD CONSTRAINT pk_profissional PRIMARY KEY (codprof);

--
-- TOC entry 2059 (class 2606 OID 38236)
-- Name: tipoacao pk_tipoacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".tipoacao
    ADD CONSTRAINT pk_tipoacao PRIMARY KEY (codacao);

--
-- TOC entry 2055 (class 2606 OID 38325)
-- Name: procedmetodolog procedmetodolog_pk; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT procedmetodolog_pk PRIMARY KEY (codproced);

--
-- TOC entry 2067 (class 2620 OID 38237)
-- Name: geoaproximacao t_ins_geoaproximacao; Type: TRIGGER; Schema: ProdNac2021; Owner: postgres
--
CREATE TRIGGER t_ins_geoaproximacao BEFORE INSERT ON "ProdNac2021".geoaproximacao FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_geoaproximacao();

--
-- TOC entry 2068 (class 2620 OID 38238)
-- Name: geolocalizacao t_ins_geolocalizacao; Type: TRIGGER; Schema: ProdNac2021; Owner: postgres
--
CREATE TRIGGER t_ins_geolocalizacao BEFORE INSERT ON "ProdNac2021".geolocalizacao FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_geolocalizacao();

--
-- TOC entry 2069 (class 2620 OID 38239)
-- Name: georreferenciamento t_ins_georreferenciamento; Type: TRIGGER; Schema: ProdNac2021; Owner: postgres
--
CREATE TRIGGER t_ins_georreferenciamento BEFORE INSERT ON "ProdNac2021".georreferenciamento FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_georreferenciamento();

--
-- TOC entry 2066 (class 2620 OID 38240)
-- Name: cdg t_ins_logbd; Type: TRIGGER; Schema: ProdNac2021; Owner: postgres
--
CREATE TRIGGER t_ins_logbd AFTER INSERT OR DELETE OR UPDATE ON "ProdNac2021".cdg FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_logbd();

--
-- TOC entry 2060 (class 2606 OID 38241)
-- Name: geoaproximacao fk_geoaproximacao_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".geoaproximacao
    ADD CONSTRAINT fk_geoaproximacao_ref_cdg FOREIGN KEY (fk_idcdg_apro) REFERENCES "ProdNac2021".cdg(idcdg) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2061 (class 2606 OID 38246)
-- Name: geolocalizacao fk_geolocalizacao_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".geolocalizacao
    ADD CONSTRAINT fk_geolocalizacao_ref_cdg FOREIGN KEY (fk_idcdg_geol) REFERENCES "ProdNac2021".cdg(idcdg) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2062 (class 2606 OID 38251)
-- Name: georreferenciamento fk_georreferenciamento_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".georreferenciamento
    ADD CONSTRAINT fk_georreferenciamento_ref_cdg FOREIGN KEY (fk_idcdg_geor) REFERENCES "ProdNac2021".cdg(idcdg) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2063 (class 2606 OID 38256)
-- Name: procedmetodolog fk_procedmetodolog_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_cdg FOREIGN KEY (fk_idcdg) REFERENCES "ProdNac2021".cdg(idcdg) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2064 (class 2606 OID 38261)
-- Name: procedmetodolog fk_procedmetodolog_ref_profissional; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_profissional FOREIGN KEY (fk_codprof) REFERENCES "ProdNac2021".profissional(codprof) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2065 (class 2606 OID 38266)
-- Name: procedmetodolog fk_procedmetodolog_ref_tipoacao; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--
ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_tipoacao FOREIGN KEY (fk_codacao) REFERENCES "ProdNac2021".tipoacao(codacao) ON UPDATE CASCADE ON DELETE CASCADE;



