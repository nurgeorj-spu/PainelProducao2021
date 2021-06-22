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
-- Name: ProdNac2021; Type: SCHEMA; Schema: -; Owner: geo
--

CREATE SCHEMA "ProdNac2021";
ALTER SCHEMA "ProdNac2021" OWNER TO geo;

--
-- TOC entry 213 (class 1255 OID 38182)
-- Name: f_geoaproximacoes(); Type: FUNCTION; Schema: ProdNac2021; Owner: geo
--

CREATE FUNCTION "ProdNac2021".f_geoaproximacoes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Proposito: verifica se o valor informado para o campo fk_cdg_idcdg_geoapro ja existe na tabela georreferenciamentos ou geolocaliza��o.
BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "ProdNac2021".georreferenciamentos WHERE fk_cdg_idcdg_geor = NEW.fk_cdg_idcdg_geoapro) and NOT EXISTS (SELECT 1 FROM "ProdNac2021".geolocalizacoes WHERE fk_cdg_idcdg_geol = NEW.fk_cdg_idcdg_geoapro) THEN
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_cdg_idcdg_geoapro  || ', fornecido para o campo fk_cdg_idcdg_geor, ja esta em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;

ALTER FUNCTION "ProdNac2021".f_geoaproximacoes() OWNER TO geo;


-
-- TOC entry 214 (class 1255 OID 38183)
-- Name: f_geolocalizacoes(); Type: FUNCTION; Schema: ProdNac2021; Owner: geo
--

CREATE FUNCTION "ProdNac2021".f_geolocalizacoes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Proposito: verifica se o valor informado para o campo fk_cdg_idcdg_geol ja existe na tabela georreferenciamentos ou geoaproximacoes
BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "ProdNac2021".georreferenciamentos WHERE fk_cdg_idcdg_geor = NEW.fk_cdg_idcdg_geol) and NOT EXISTS (SELECT 1 FROM "ProdNac2021".geoaproximacoes WHERE fk_cdg_idcdg_geoapro = NEW.fk_cdg_idcdg_geol) THEN
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_cdg_idcdg_geol  || ', fornecido para o campo fk_cdg_idcdg_geol, j� est� em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;

ALTER FUNCTION "ProdNac2021".f_geolocalizacoes() OWNER TO geo;

-
-- TOC entry 215 (class 1255 OID 38184)
-- Name: f_georreferenciamentos(); Type: FUNCTION; Schema: ProdNac2021; Owner: geo
--

CREATE FUNCTION "ProdNac2021".f_georreferenciamentos() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Proposito: verifica se o valor informado para o campo fk_cdg_idcdg_geor ja existe na tabela geolocalizacoes ou geoaproximacoes
BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "ProdNac2021".geolocalizacoes WHERE fk_cdg_idcdg_geol = NEW.fk_cdg_idcdg_geor) and NOT EXISTS (SELECT 1 FROM "ProdNac2021".geoaproximacoes WHERE fk_cdg_idcdg_geoapro = NEW.fk_cdg_idcdg_geor) THEN
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_cdg_idcdg_geor  || ', fornecido para o campo fk_cdg_idcdg_geor, ja esta em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;

ALTER FUNCTION "ProdNac2021".f_georreferenciamentos() OWNER TO geo;


--
-- TOC entry 212 (class 1255 OID 38185)
-- Name: f_logbd(); Type: FUNCTION; Schema: ProdNac2021; Owner: geo
--

CREATE FUNCTION "ProdNac2021".f_logbd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
/*-- Prop�sito: Insere na tabela logsbd todas as opera��es realizadas na entidade cdgs.
A fun�es verifica uma cadeia de caracteres contendo INSERT, UPDATE, ou DELETE, e informa para qual opera��es o gatilho foi disparado (Tipo de dado text).*/
BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO "ProdNac2021".logsbd
		(pk_codlog, fk_cdg_idcdg_log, dataalteracao, usuario, operacao) 
		VALUES
		(NEXTVAL('"ProdNac2021".logsbd_pk_codlog_seq'), NEW.pk_idcdg, current_timestamp, current_user, 'INSERT');
		RETURN NEW;
	ELSIF (TG_OP = 'DELETE') THEN
		INSERT INTO "ProdNac2021".logsbd
		(pk_codlog, fk_cdg_idcdg_log, dataalteracao, usuario, operacao) 
		VALUES
		(NEXTVAL('"ProdNac2021".logsbd_pk_codlog_seq'), OLD.pk_idcdg, current_timestamp, current_user, 'DELETE');
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO "ProdNac2021".logsbd
		(pk_codlog, fk_cdg_idcdg_log, dataalteracao, usuario, operacao)
		VALUES
		(NEXTVAL('"ProdNac2021".logsbd_pk_codlog_seq'), NEW.pk_idcdg, current_timestamp, current_user, 'UPDATE');
		RETURN NEW;		
	END IF;
	RETURN NULL;
END;
$$;

ALTER FUNCTION "ProdNac2021".f_logbd() OWNER TO geo;

SET default_tablespace = '';
SET default_with_oids = false;



-- Name: ty_uf; Type: Type; Schema: ProdNac2021; Owner: geo
--
CREATE TYPE "ProdNac2021".tp_uf AS ENUM (
    'AC',
    'AM',
    'RR',
    'PA',
    'AP',
    'TO',
    'MA',
    'PI',
    'CE',
    'RN',
    'PB',
    'PE',
    'AL',
    'SE',
    'BA',
    'MG',
    'ES',
    'RJ',
    'SP',
    'PR',
    'SC',
    'RS',
    'MS',
    'MT',
    'GO',
    'DF'
);


-- Name: ty_prodlocali; Type: Type; Schema: ProdNac2021; Owner: geo
--
CREATE TYPE "ProdNac2021".tp_prodlocali AS ENUM (
    'Sim',
    'Não'
);
-- Name: tp_formatocdg; Type: Type; Schema: ProdNac2021; Owner: geo
--
CREATE TYPE "ProdNac2021".tp_formatocdg AS ENUM (
    'Digital',
    'Analógico'
);

-- Name: tp_produtcdg; Type: Type; Schema: ProdNac2021; Owner: geo
--
CREATE TYPE "ProdNac2021".tp_produtcdg AS ENUM (
    'Carta Índice',
    'Carta Cadastral',
    'Foto índice',
    'Imagem Hipsométrica',
    'Planta',
    'Carta Topográfica'
);
-- Name: ty_coordpresen; Type: Type; Schema: ProdNac2021; Owner: geo
--
CREATE TYPE "ProdNac2021".tp_coordpresen AS ENUM (
    'Sim',
    'Não'
);


--
-- TOC entry 186 (class 1259 OID 38186)
-- Name: cdgs; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".cdgs (
    pk_idcdg serial NOT NULL,
    idnacional character varying(7) NOT NULL,
    uf "ProdNac2021".tp_uf,
    cadastrador character varying(250),
    prodlocali "ProdNac2021".tp_prodlocali NOT NULL,
    nomeproduto character varying(250),
    producao character varying(100),
    patriarmazen character varying(100),
    nprocesso character varying(100),
    formatocdg "ProdNac2021".tp_formatocdg NOT NULL,
    produtcdg "ProdNac2021".tp_produtcdg,
    nomecolecao character varying(250),
    tipobemuni character varying(100),
    ano integer,
    codmunicipio integer,
    coordpresen "ProdNac2021".tp_coordpresen,
    epsgpres character varying(25),
    epsg integer,
    escala integer,
    spunet_dig integer,
    spunet_analog integer
);


ALTER TABLE "ProdNac2021".cdgs OWNER TO geo;


--
-- Name: cdgs_pk_idcdg_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: geo
--

CREATE SEQUENCE "ProdNac2021".cdgs_pk_idcdg_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
	
ALTER TABLE "ProdNac2021".cdgs_pk_idcdg_seq OWNER TO geo;

--
-- TOC entry 187 (class 1259 OID 38192)
-- Name: geoaproximacoes; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".geoaproximacoes (
    pk_codapro serial NOT NULL,
    parecer character varying(25),
    fk_cdg_idcdg_geoapro integer NOT NULL
);

ALTER TABLE "ProdNac2021".geoaproximacoes OWNER TO geo;

--
-- TOC entry 188 (class 1259 OID 38195)
-- Name: geoaproximacoes_pk_codapro_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: geo
--

CREATE SEQUENCE "ProdNac2021".geoaproximacoes_pk_codapro_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
	
ALTER TABLE "ProdNac2021".geoaproximacoes_pk_codapro_seq OWNER TO geo;

--
-- TOC entry 189 (class 1259 OID 38197)
-- Name: geolocalizacoes; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".geolocalizacoes (
    pk_codgeoloc serial NOT NULL,
    parecer character varying(25),
    fk_cdg_idcdg_geol integer NOT NULL
);

ALTER TABLE "ProdNac2021".geolocalizacoes OWNER TO geo;

--
-- TOC entry 190 (class 1259 OID 38200)
-- Name: geolocalizacoes_pk_codgeoloc_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: geo
--

CREATE SEQUENCE "ProdNac2021".geolocalizacoes_pk_codgeoloc_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
	
ALTER TABLE "ProdNac2021".geolocalizacoes_pk_codgeoloc_seq OWNER TO geo;

--
-- TOC entry 191 (class 1259 OID 38202)
-- Name: georreferenciamentos; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".georreferenciamentos (
    pk_codgeorr serial NOT NULL,
    parecer character varying(25),
    verificacao character varying(25),
    fk_cdg_idcdg_geor integer NOT NULL
);

ALTER TABLE "ProdNac2021".georreferenciamentos OWNER TO geo;

--
-- TOC entry 192 (class 1259 OID 38205)
-- Name: seq_georreferenciamentoss; Type: SEQUENCE; Schema: ProdNac2021; Owner: geo
--

CREATE SEQUENCE "ProdNac2021".seq_georreferenciamentoss
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "ProdNac2021".seq_georreferenciamentoss OWNER TO geo;

--
-- TOC entry 193 (class 1259 OID 38207)
-- Name: logsbd; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".logsbd (
    pk_codlog serial NOT NULL,
    dataalteracao date NOT NULL,
    usuario character varying(50) NOT NULL,
    operacao character varying(10) NOT NULL,
    fk_cdg_idcdg_log integer NOT NULL
);

ALTER TABLE "ProdNac2021".logsbd OWNER TO geo;

-
-- TOC entry 198 (class 1259 OID 38327)
-- Name: logsbd_pk_codlog_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: geo
--

CREATE SEQUENCE "ProdNac2021".logsbd_pk_codlog_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "ProdNac2021".logsbd_pk_codlog_seq OWNER TO geo;

--
-- TOC entry 194 (class 1259 OID 38212)
-- Name: procedmetodologicos; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".procedmetodologicos (
    pk_codproced serial NOT NULL,
    datap date,
    fk_cdg_idcdg_proced integer NOT NULL,
    fk_profis_codprof_proced integer NOT NULL,
    fk_tipoacoes_codacao_proced integer NOT NULL,
    idnacional character varying(7)
);

ALTER TABLE "ProdNac2021".procedmetodologicos OWNER TO geo;

--
-- TOC entry 197 (class 1259 OID 38305)
-- Name: procedmetodologicos_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: geo
--

CREATE SEQUENCE "ProdNac2021".procedmetodologicos_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "ProdNac2021".procedmetodologicos_seq OWNER TO geo;

--
-- TOC entry 195 (class 1259 OID 38215)
-- Name: profissionais; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".profissionais (
    pk_codprof serial NOT NULL,
    "nomeCompleto" character varying(70),
    "UF" character varying(2),
    nomeformatado character varying(70)
);

ALTER TABLE "ProdNac2021".profissionais OWNER TO geo;

--
-- TOC entry 196 (class 1259 OID 38218)
-- Name: tipoacoes; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".tipoacoes (
    pk_codacao serial NOT NULL,
    servico character varying(25) NOT NULL
);

ALTER TABLE "ProdNac2021".tipoacoes OWNER TO geo;

--
-- TOC entry 2205 (class 0 OID 0)
-- Dependencies: 188
-- Name: geoaproximacoes_pk_codapro_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--
SELECT pg_catalog.setval('"ProdNac2021".geoaproximacoes_pk_codapro_seq', 1, false);

--
-- TOC entry 2206 (class 0 OID 0)
-- Dependencies: 190
-- Name: geolocalizacoes_pk_codgeoloc_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--
SELECT pg_catalog.setval('"ProdNac2021".geolocalizacoes_pk_codgeoloc_seq', 1, true);

--
-- TOC entry 2207 (class 0 OID 0)
-- Dependencies: 192
-- Name: seq_georreferenciamentoss; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--
SELECT pg_catalog.setval('"ProdNac2021".seq_georreferenciamentoss', 1, true);

--
-- TOC entry 2208 (class 0 OID 0)
-- Dependencies: 198
-- Name: logsbd_pk_codlog_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--
SELECT pg_catalog.setval('"ProdNac2021".logsbd_pk_codlog_seq', 1, true);

--
-- TOC entry 2209 (class 0 OID 0)
-- Dependencies: 197
-- Name: procedmetodologicos_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--
SELECT pg_catalog.setval('"ProdNac2021".procedmetodologicos_seq', 1, true);

--
-- TOC entry 2045 (class 2606 OID 38222)
-- Name: cdgs pk_cdg; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".cdgs
    ADD CONSTRAINT pk_cdgs PRIMARY KEY (pk_idcdg);

--
-- TOC entry 2047 (class 2606 OID 38224)
-- Name: geoaproximacoes pk_geoaproximacoes; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".geoaproximacoes
    ADD CONSTRAINT pk_geoaproximacoes PRIMARY KEY (pk_codapro);

--
-- TOC entry 2049 (class 2606 OID 38226)
-- Name: geolocalizacoes pk_geolocalizacoes; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".geolocalizacoes
    ADD CONSTRAINT pk_geolocalizacoes PRIMARY KEY (pk_codgeoloc);

--
-- TOC entry 2051 (class 2606 OID 38228)
-- Name: georreferenciamentos pk_georreferenciamentos; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".georreferenciamentos
    ADD CONSTRAINT pk_georreferenciamentoss PRIMARY KEY (pk_codgeorr);

--
-- TOC entry 2053 (class 2606 OID 38230)
-- Name: logsbd pk_logbd; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".logsbd
    ADD CONSTRAINT pk_logsbd PRIMARY KEY (pk_codlog);

--
-- TOC entry 2057 (class 2606 OID 38234)
-- Name: profissionais pk_profissional; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".profissionais
    ADD CONSTRAINT pk_profissionais PRIMARY KEY (pk_codprof);

--
-- TOC entry 2059 (class 2606 OID 38236)
-- Name: tipoacoes pk_tipoacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".tipoacoes
    ADD CONSTRAINT pk_tipoacoes PRIMARY KEY (pk_codacao);

--
-- TOC entry 2055 (class 2606 OID 38325)
-- Name: procedmetodologicos procedmetodologicos_pk; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".procedmetodologicos
    ADD CONSTRAINT pk_procedmetodologicosicos PRIMARY KEY (pk_codproced);

--
-- TOC entry 2067 (class 2620 OID 38237)
-- Name: geoaproximacoes t_geoaproximacoes; Type: TRIGGER; Schema: ProdNac2021; Owner: geo
--
CREATE TRIGGER t_geoaproximacoes BEFORE INSERT ON "ProdNac2021".geoaproximacoes FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_geoaproximacoes();

--
-- TOC entry 2068 (class 2620 OID 38238)
-- Name: geolocalizacoes t_geolocalizacoes; Type: TRIGGER; Schema: ProdNac2021; Owner: geo
--
CREATE TRIGGER t_geolocalizacoes BEFORE INSERT ON "ProdNac2021".geolocalizacoes FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_geolocalizacoes();

--
-- TOC entry 2069 (class 2620 OID 38239)
-- Name: georreferenciamentos t_georreferenciamentos; Type: TRIGGER; Schema: ProdNac2021; Owner: geo
--
CREATE TRIGGER t_georreferenciamentos BEFORE INSERT ON "ProdNac2021".georreferenciamentos FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_georreferenciamentos();

--
-- TOC entry 2066 (class 2620 OID 38240)
-- Name: cdgs t_logbd; Type: TRIGGER; Schema: ProdNac2021; Owner: geo
--
CREATE TRIGGER t_logbd AFTER INSERT OR DELETE OR UPDATE ON "ProdNac2021".cdgs FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_logbd();

--
-- TOC entry 2060 (class 2606 OID 38241)
-- Name: geoaproximacoes fk_geoaproximacoes_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".geoaproximacoes
    ADD CONSTRAINT fk_geoaproximacoes_ref_cdg FOREIGN KEY (fk_cdg_idcdg_geoapro) REFERENCES "ProdNac2021".cdgs(pk_idcdg) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2061 (class 2606 OID 38246)
-- Name: geolocalizacoes fk_geolocalizacoes_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".geolocalizacoes
    ADD CONSTRAINT fk_geolocalizacoes_ref_cdg FOREIGN KEY (fk_cdg_idcdg_geol) REFERENCES "ProdNac2021".cdgs(pk_idcdg) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2062 (class 2606 OID 38251)
-- Name: georreferenciamentos fk_georreferenciamentos_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".georreferenciamentos
    ADD CONSTRAINT fk_georreferenciamentos_ref_cdg FOREIGN KEY (fk_cdg_idcdg_geor) REFERENCES "ProdNac2021".cdgs(pk_idcdg) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2063 (class 2606 OID 38256)
-- Name: procedmetodologicos fk_procedmetodologicos_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".procedmetodologicos
    ADD CONSTRAINT fk_procedmetodologicos_ref_cdg FOREIGN KEY (fk_cdg_idcdg_proced) REFERENCES "ProdNac2021".cdgs(pk_idcdg) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2064 (class 2606 OID 38261)
-- Name: procedmetodologicos fk_procedmetodologicos_ref_profissional; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".procedmetodologicos
    ADD CONSTRAINT fk_procedmetodologicos_ref_profissional FOREIGN KEY (fk_profis_codprof_proced) REFERENCES "ProdNac2021".profissionais(pk_codprof) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- TOC entry 2065 (class 2606 OID 38266)
-- Name: procedmetodologicos fk_procedmetodologicos_ref_tipoacao; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--
ALTER TABLE ONLY "ProdNac2021".procedmetodologicos
    ADD CONSTRAINT fk_procedmetodologicos_ref_tipoacao FOREIGN KEY (fk_tipoacoes_codacao_proced) REFERENCES "ProdNac2021".tipoacoes(pk_codacao) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 398 (class 1259 OID 2529649)
-- Name: vw_georr_cdg; Type: VIEW; Schema: ; Owner: geo
--

CREATE VIEW "ProdNac2021_Ficticio".vw_georr_cdg AS
 SELECT g.pk_codgeorr,
    g.parecer,
    g.verificacao,
    g.fk_cdg_idcdg_geor,
    c.idnacional,
    c.uf,
    c.nomeproduto,
    c.nomecolecao,
    c.ano,
    c.codmunicipio,
    c.coordpresen,
    c.epsgpres,
    c.epsg,
    c.escala
   FROM ("ProdNac2021_Ficticio".georreferenciamentos g
     JOIN "ProdNac2021_Ficticio".cdgs c ON ((g.fk_cdg_idcdg_geor = c.pk_idcdg)));


ALTER TABLE "ProdNac2021_Ficticio".vw_georr_cdg OWNER TO geo;

