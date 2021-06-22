-- PostgreSQL database dump

-- Dumped from database version 11.5
-- Dumped by pg_dump version 11.5

-- Started on 2021-06-18 09:37:15

--
-- Name: ProdNac2021; Type: SCHEMA; Schema: -; Owner: geo
--

CREATE SCHEMA "ProdNac2021";
ALTER SCHEMA "ProdNac2021" OWNER TO geo;

--
-- Name: tp_coordpresen; Type: TYPE; Schema: ProdNac2021; Owner: geo
--

CREATE TYPE "ProdNac2021".tp_coordpresen AS ENUM (
    'Sim',
    'Não'
);

ALTER TYPE "ProdNac2021".tp_coordpresen OWNER TO geo;

--
-- Name: tp_formatocdg; Type: TYPE; Schema: ProdNac2021; Owner: geo
--

CREATE TYPE "ProdNac2021".tp_formatocdg AS ENUM (
    'Digital',
    'Analógico'
);

ALTER TYPE "ProdNac2021".tp_formatocdg OWNER TO geo;

--
-- Name: tp_prodlocali; Type: TYPE; Schema: ProdNac2021; Owner: geo
--

CREATE TYPE "ProdNac2021".tp_prodlocali AS ENUM (
    'Sim',
    'Não'
);

ALTER TYPE "ProdNac2021".tp_prodlocali OWNER TO geo;

--
-- Name: tp_produtcdg; Type: TYPE; Schema: ProdNac2021; Owner: geo
--

CREATE TYPE "ProdNac2021".tp_produtcdg AS ENUM (
    'Carta Índice',
    'Carta Cadastral',
    'Foto índice',
    'Imagem Hipsométrica',
    'Planta',
    'Carta Topográfica'
);

ALTER TYPE "ProdNac2021".tp_produtcdg OWNER TO geo;

--
-- Name: tp_uf; Type: TYPE; Schema: ProdNac2021; Owner: geo
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

ALTER TYPE "ProdNac2021".tp_uf OWNER TO geo;

--
-- Name: f_geoaproximacoes(); Type: FUNCTION; Schema: ProdNac2021; Owner: geo
--

CREATE FUNCTION "ProdNac2021".f_geoaproximacoes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Proposito: verifica se o valor informado para o campo fk_cdg_pk_idnacional_geoapro ja existe na tabela georreferenciamentos ou geolocalizacao.
BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "ProdNac2021".georreferenciamentos WHERE fk_cdg_pk_idnacional_geor = NEW.fk_cdg_pk_idnacional_geoapro) and NOT EXISTS (SELECT 1 FROM "ProdNac2021".geolocalizacoes WHERE fk_cdg_pk_idnacional_geol = NEW.fk_cdg_pk_idnacional_geoapro) THEN
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_cdg_pk_idnacional_geoapro  || ', fornecido para o campo fk_cdg_pk_idnacional_geor, ja esta em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;

ALTER FUNCTION "ProdNac2021".f_geoaproximacoes() OWNER TO geo;

--
-- Name: f_geolocalizacoes(); Type: FUNCTION; Schema: ProdNac2021; Owner: geo
--

CREATE FUNCTION "ProdNac2021".f_geolocalizacoes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Proposito: verifica se o valor informado para o campo fk_cdg_pk_idnacional_geol ja existe na tabela georreferenciamentos ou geoaproximacoes
BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "ProdNac2021".georreferenciamentos WHERE fk_cdg_pk_idnacional_geor = NEW.fk_cdg_pk_idnacional_geol) and NOT EXISTS (SELECT 1 FROM "ProdNac2021".geoaproximacoes WHERE fk_cdg_pk_idnacional_geoapro = NEW.fk_cdg_pk_idnacional_geol) THEN
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_cdg_pk_idnacional_geol  || ', fornecido para o campo fk_cdg_pk_idnacional_geol, ja esta em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;


ALTER FUNCTION "ProdNac2021".f_geolocalizacoes() OWNER TO geo;

--
-- Name: f_georreferenciamentos(); Type: FUNCTION; Schema: ProdNac2021; Owner: geo
--

CREATE FUNCTION "ProdNac2021".f_georreferenciamentos() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Proposito: verifica se o valor informado para o campo fk_cdg_pk_idnacional_geor ja existe na tabela geolocalizacoes ou geoaproximacoes
BEGIN
 -- regra 
 IF NOT EXISTS (SELECT 1 FROM "ProdNac2021".geolocalizacoes WHERE fk_cdg_pk_idnacional_geol = NEW.fk_cdg_pk_idnacional_geor) and NOT EXISTS (SELECT 1 FROM "ProdNac2021".geoaproximacoes WHERE fk_cdg_pk_idnacional_geoapro = NEW.fk_cdg_pk_idnacional_geor) THEN
   -- faz o insert
   RETURN NEW;
   -- do contrario ...
   ELSE
   -- rejeita!
   RAISE EXCEPTION 'O Valor %',  NEW.fk_cdg_pk_idnacional_geor  || ', fornecido para o campo fk_cdg_pk_idnacional_geor, ja esta em uso em outra tabela.' USING HINT = 'Corrija e tente novamente';
 END IF;
END $$;

ALTER FUNCTION "ProdNac2021".f_georreferenciamentos() OWNER TO geo;

--
-- Name: f_logbd(); Type: FUNCTION; Schema: ProdNac2021; Owner: geo
--

CREATE FUNCTION "ProdNac2021".f_logbd() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

/*-- Proposito: Insere na tabela logsbd todas as operacoes realizadas na entidade cdgs.

A funcoes verifica uma cadeia de caracteres contendo INSERT, UPDATE, ou DELETE, e informa para qual operacoes o gatilho foi disparado (Tipo de dado text).*/

BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO "ProdNac2021".logsbd
		(pk_codlog, cdg_idcdg_log, cdg_idnacional_log, dataalteracao, usuario, operacao) 
		VALUES
		(NEXTVAL('"ProdNac2021".logsbd_pk_codlog_seq'), NEW.idcdg, NEW.pk_idnacional, current_timestamp, current_user, 'INSERT');
		RETURN NEW;
	ELSIF (TG_OP = 'DELETE') THEN
		INSERT INTO "ProdNac2021".logsbd
		(pk_codlog, cdg_idcdg_log, cdg_idnacional_log, dataalteracao, usuario, operacao) 
		VALUES
		(NEXTVAL('"ProdNac2021".logsbd_pk_codlog_seq'), OLD.idcdg, OLD.pk_idnacional, current_timestamp, current_user, 'DELETE');
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO "ProdNac2021".logsbd
		(pk_codlog, cdg_idcdg_log, cdg_idnacional_log, dataalteracao, usuario, operacao) 
		VALUES
		(NEXTVAL('"ProdNac2021".logsbd_pk_codlog_seq'), NEW.idcdg, NEW.pk_idnacional, current_timestamp, current_user, 'UPDATE');
		RETURN NEW;		
	END IF;
	RETURN NULL;
END;

$$;


ALTER FUNCTION "ProdNac2021".f_logbd() OWNER TO geo;

SET default_tablespace = '';
SET default_with_oids = false;

--
-- Name: cdgs; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".cdgs (
    idcdg SERIAL NOT NULL,
    pk_idnacional character varying(7) NOT NULL,
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
    spunet_dig character varying(20),
    spunet_analog character varying(20)
);

ALTER TABLE "ProdNac2021".cdgs OWNER TO geo;

--
-- Name: geoaproximacoes; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".geoaproximacoes (
    pk_codapro serial NOT NULL,
    parecer character varying(25) NOT NULL,
    fk_cdg_pk_idnacional_geoapro character varying(7) NOT NULL
);

ALTER TABLE "ProdNac2021".geoaproximacoes OWNER TO geo;

--
-- Name: geolocalizacoes; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".geolocalizacoes (
    pk_codgeoloc serial NOT NULL,
    parecer character varying(25),
    fk_cdg_pk_idnacional_geol character varying(7)
);

ALTER TABLE "ProdNac2021".geolocalizacoes OWNER TO geo;

--
-- Name: georreferenciamentos; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".georreferenciamentos (
    pk_codgeorr serial NOT NULL,
    parecer character varying(25) NOT NULL,
    verificacao character varying(25),
    fk_cdg_pk_idnacional_geor character varying(7) NOT NULL
);

ALTER TABLE "ProdNac2021".georreferenciamentos OWNER TO geo;

--
-- Name: logsbd; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".logsbd (
    pk_codlog serial NOT NULL,
    dataalteracao date NOT NULL,
    usuario character varying(50) NOT NULL,
    operacao character varying(10) NOT NULL,
    cdg_idcdg_log integer NOT null,
	cdg_idnacional_log character varying(7)
);

ALTER TABLE "ProdNac2021".logsbd OWNER TO geo;

--
-- Name: procedmetodologicos; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".procedmetodologicos (
    pk_codproced serial NOT NULL,
    datap date,
    fk_profis_codprof_proced integer NOT NULL,
    fk_tipoacoes_codacao_proced integer NOT NULL,
    fk_cdgs_pk_idnacional_proced character varying(7)
);

ALTER TABLE "ProdNac2021".procedmetodologicos OWNER TO geo;

--
-- Name: profissionais; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".profissionais (
    pk_codprof serial NOT NULL,
    nomecompleto character varying(70) NOT NULL,
    uf "ProdNac2021".tp_uf NOT NULL,
    nomeformatado character varying(70) NOT NULL
);

ALTER TABLE "ProdNac2021".profissionais OWNER TO geo;


--
-- Name: cdgs_pk_idcdg_seq; Type: SEQUENCE OWNED BY; Schema: ProdNac2021; Owner: geo
--

ALTER SEQUENCE "ProdNac2021".cdgs_idcdg_seq OWNED BY "ProdNac2021".cdgs.idcdg;


--
-- Name: geoaproximacoes_pk_codapro_seq; Type: SEQUENCE OWNED BY; Schema: ProdNac2021; Owner: geo
--

ALTER SEQUENCE "ProdNac2021".geoaproximacoes_pk_codapro_seq OWNED BY "ProdNac2021".geoaproximacoes.pk_codapro;


--
-- Name: geolocalizacoes_pk_codgeoloc_seq; Type: SEQUENCE OWNED BY; Schema: ProdNac2021; Owner: geo
--

ALTER SEQUENCE "ProdNac2021".geolocalizacoes_pk_codgeoloc_seq OWNED BY "ProdNac2021".geolocalizacoes.pk_codgeoloc;


--
-- Name: georreferenciamentos_pk_codgeorr_seq; Type: SEQUENCE OWNED BY; Schema: ProdNac2021; Owner: geo
--

ALTER SEQUENCE "ProdNac2021".georreferenciamentos_pk_codgeorr_seq OWNED BY "ProdNac2021".georreferenciamentos.pk_codgeorr;


--
-- Name: logsbd_pk_codlog_seq; Type: SEQUENCE OWNED BY; Schema: ProdNac2021; Owner: geo
--

ALTER SEQUENCE "ProdNac2021".logsbd_pk_codlog_seq OWNED BY "ProdNac2021".logsbd.pk_codlog;


--
-- Name: procedmetodologicos_pk_codproced_seq; Type: SEQUENCE OWNED BY; Schema: ProdNac2021; Owner: geo
--

ALTER SEQUENCE "ProdNac2021".procedmetodologicos_pk_codproced_seq OWNED BY "ProdNac2021".procedmetodologicos.pk_codproced;


--
-- Name: profissionais_pk_codprof_seq; Type: SEQUENCE OWNED BY; Schema: ProdNac2021; Owner: geo
--

ALTER SEQUENCE "ProdNac2021".profissionais_pk_codprof_seq OWNED BY "ProdNac2021".profissionais.pk_codprof;


--
-- Name: tipoacoes; Type: TABLE; Schema: ProdNac2021; Owner: geo
--

CREATE TABLE "ProdNac2021".tipoacoes (
    pk_codacao integer NOT NULL,
    servico character varying(25) NOT NULL
);


ALTER TABLE "ProdNac2021".tipoacoes OWNER TO geo;

--
-- Name: tipoacoes_pk_codacao_seq; Type: SEQUENCE OWNED BY; Schema: ProdNac2021; Owner: geo
--

ALTER SEQUENCE "ProdNac2021".tipoacoes_pk_codacao_seq OWNED BY "ProdNac2021".tipoacoes.pk_codacao;


--
-- Name: cdgs idcdg; Type: DEFAULT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".cdgs ALTER COLUMN idcdg SET DEFAULT nextval('"ProdNac2021".cdgs_idcdg_seq'::regclass);


--
-- Name: geoaproximacoes pk_codapro; Type: DEFAULT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".geoaproximacoes ALTER COLUMN pk_codapro SET DEFAULT nextval('"ProdNac2021".geoaproximacoes_pk_codapro_seq'::regclass);


--
-- Name: geolocalizacoes pk_codgeoloc; Type: DEFAULT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".geolocalizacoes ALTER COLUMN pk_codgeoloc SET DEFAULT nextval('"ProdNac2021".geolocalizacoes_pk_codgeoloc_seq'::regclass);


--
-- Name: georreferenciamentos pk_codgeorr; Type: DEFAULT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".georreferenciamentos ALTER COLUMN pk_codgeorr SET DEFAULT nextval('"ProdNac2021".georreferenciamentos_pk_codgeorr_seq'::regclass);


--
-- Name: logsbd pk_codlog; Type: DEFAULT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".logsbd ALTER COLUMN pk_codlog SET DEFAULT nextval('"ProdNac2021".logsbd_pk_codlog_seq'::regclass);


--
-- Name: procedmetodologicos pk_codproced; Type: DEFAULT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".procedmetodologicos ALTER COLUMN pk_codproced SET DEFAULT nextval('"ProdNac2021".procedmetodologicos_pk_codproced_seq'::regclass);


--
-- Name: profissionais pk_codprof; Type: DEFAULT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".profissionais ALTER COLUMN pk_codprof SET DEFAULT nextval('"ProdNac2021".profissionais_pk_codprof_seq'::regclass);



--
-- Name: cdgs_pk_idcdg_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--

SELECT pg_catalog.setval('"ProdNac2021".cdgs_idcdg_seq', 1, false);


--
-- Name: geoaproximacoes_pk_codapro_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--

SELECT pg_catalog.setval('"ProdNac2021".geoaproximacoes_pk_codapro_seq', 1, false);


--
-- Name: geolocalizacoes_pk_codgeoloc_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--

SELECT pg_catalog.setval('"ProdNac2021".geolocalizacoes_pk_codgeoloc_seq', 1, false);


--
-- Name: georreferenciamentos_pk_codgeorr_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--

SELECT pg_catalog.setval('"ProdNac2021".georreferenciamentos_pk_codgeorr_seq', 1, false);


--
-- Name: logsbd_pk_codlog_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--

SELECT pg_catalog.setval('"ProdNac2021".logsbd_pk_codlog_seq', 1, false);


--
-- Name: procedmetodologicos_pk_codproced_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--

SELECT pg_catalog.setval('"ProdNac2021".procedmetodologicos_pk_codproced_seq', 1, false);


--
-- Name: profissionais_pk_codprof_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: geo
--

SELECT pg_catalog.setval('"ProdNac2021".profissionais_pk_codprof_seq', 1, false);


--
-- Name: cdgs pk_cdgs; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".cdgs
    ADD CONSTRAINT pk_cdgs PRIMARY KEY (pk_idnacional);
	

--
-- Name: geoaproximacoes pk_geoaproximacoes; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".geoaproximacoes
    ADD CONSTRAINT pk_geoaproximacoes PRIMARY KEY (pk_codapro);


--
-- Name: geolocalizacoes pk_geolocalizacoes; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".geolocalizacoes
    ADD CONSTRAINT pk_geolocalizacoes PRIMARY KEY (pk_codgeoloc);


--
-- Name: georreferenciamentos pk_georreferenciamentoss; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".georreferenciamentos
    ADD CONSTRAINT pk_georreferenciamentoss PRIMARY KEY (pk_codgeorr);


--
-- Name: logsbd pk_logsbd; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".logsbd
    ADD CONSTRAINT pk_logsbd PRIMARY KEY (pk_codlog);


--
-- Name: procedmetodologicos pk_procedmetodologicosicos; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".procedmetodologicos
    ADD CONSTRAINT pk_procedmetodologicosicos PRIMARY KEY (pk_codproced);


--
-- Name: profissionais pk_profissionais; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".profissionais
    ADD CONSTRAINT pk_profissionais PRIMARY KEY (pk_codprof);


--
-- Name: tipoacoes pk_tipoacoes; Type: CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".tipoacoes
    ADD CONSTRAINT pk_tipoacoes PRIMARY KEY (pk_codacao);


--
-- Name: geoaproximacoes t_geoaproximacoes; Type: TRIGGER; Schema: ProdNac2021; Owner: geo
--

CREATE TRIGGER t_geoaproximacoes BEFORE INSERT ON "ProdNac2021".geoaproximacoes FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_geoaproximacoes();


--
-- Name: geolocalizacoes t_geolocalizacoes; Type: TRIGGER; Schema: ProdNac2021; Owner: geo
--

CREATE TRIGGER t_geolocalizacoes BEFORE INSERT ON "ProdNac2021".geolocalizacoes FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_geolocalizacoes();


--
-- Name: georreferenciamentos t_georreferenciamentos; Type: TRIGGER; Schema: ProdNac2021; Owner: geo
--

CREATE TRIGGER t_georreferenciamentos BEFORE INSERT ON "ProdNac2021".georreferenciamentos FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_georreferenciamentos();


--
-- Name: cdgs t_logbd; Type: TRIGGER; Schema: ProdNac2021; Owner: geo
--

CREATE TRIGGER t_logbd AFTER INSERT OR DELETE OR UPDATE ON "ProdNac2021".cdgs FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_logbd();


--
-- Name: geoaproximacoes fk_geoaproximacoes_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".geoaproximacoes
    ADD CONSTRAINT fk_geoaproximacoes_ref_cdg FOREIGN KEY (fk_cdg_pk_idnacional_geoapro) REFERENCES "ProdNac2021".cdgs(pk_idnacional) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: geolocalizacoes fk_geolocalizacoes_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".geolocalizacoes
    ADD CONSTRAINT fk_geolocalizacoes_ref_cdg FOREIGN KEY (fk_cdg_pk_idnacional_geol) REFERENCES "ProdNac2021".cdgs(pk_idnacional) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: georreferenciamentos fk_georreferenciamentos_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".georreferenciamentos
    ADD CONSTRAINT fk_georreferenciamentos_ref_cdg FOREIGN KEY (fk_cdg_pk_idnacional_geor) REFERENCES "ProdNac2021".cdgs(pk_idnacional) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: procedmetodologicos fk_procedmetodologicos_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".procedmetodologicos
    ADD CONSTRAINT fk_procedmetodologicos_ref_cdg FOREIGN KEY (fk_cdgs_pk_idnacional_proced) REFERENCES "ProdNac2021".cdgs(pk_idnacional) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: procedmetodologicos fk_procedmetodologicos_ref_profissional; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".procedmetodologicos
    ADD CONSTRAINT fk_procedmetodologicos_ref_profissional FOREIGN KEY (fk_profis_codprof_proced) REFERENCES "ProdNac2021".profissionais(pk_codprof) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: procedmetodologicos fk_procedmetodologicos_ref_tipoacao; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: geo
--

ALTER TABLE ONLY "ProdNac2021".procedmetodologicos
    ADD CONSTRAINT fk_procedmetodologicos_ref_tipoacao FOREIGN KEY (fk_tipoacoes_codacao_proced) REFERENCES "ProdNac2021".tipoacoes(pk_codacao) ON UPDATE CASCADE ON DELETE CASCADE;

-- Completed on 2021-06-17 17:19:28

--
-- PostgreSQL database dump complete
--




