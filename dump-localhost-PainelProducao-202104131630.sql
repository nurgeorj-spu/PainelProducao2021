--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.20
-- Dumped by pg_dump version 11.5

-- Started on 2021-04-13 16:30:19

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
-- TOC entry 5 (class 2615 OID 37892)
-- Name: ProdNac2021; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "ProdNac2021";


--
-- TOC entry 211 (class 1255 OID 37893)
-- Name: f_trigger_ins_geoaproximacao(); Type: FUNCTION; Schema: ProdNac2021; Owner: -
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


--
-- TOC entry 212 (class 1255 OID 37894)
-- Name: f_trigger_ins_geolocalizacao(); Type: FUNCTION; Schema: ProdNac2021; Owner: -
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


--
-- TOC entry 214 (class 1255 OID 37895)
-- Name: f_trigger_ins_georreferenciamento(); Type: FUNCTION; Schema: ProdNac2021; Owner: -
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


--
-- TOC entry 213 (class 1255 OID 37896)
-- Name: f_trigger_logbd(); Type: FUNCTION; Schema: ProdNac2021; Owner: -
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


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 186 (class 1259 OID 37897)
-- Name: cdg; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".cdg (
    idCdg integer NOT NULL,
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
    escala integer,
    spunet_dig integer,
    spunet_analog integer    
);


--
-- TOC entry 187 (class 1259 OID 37903)
-- Name: geoaproximacao; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".geoaproximacao (
    codapro integer NOT NULL,
    parecer character varying(25),
    fk_idCdg_apro integer NOT NULL
);


--
-- TOC entry 188 (class 1259 OID 37906)
-- Name: geoaproximacao_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: -
--

CREATE SEQUENCE "ProdNac2021".geoaproximacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 189 (class 1259 OID 37908)
-- Name: geolocalizacao; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".geolocalizacao (
    codgeoloc integer NOT NULL,
    parecer character varying(25),
    fk_idCdg_geol integer NOT NULL
);


--
-- TOC entry 190 (class 1259 OID 37911)
-- Name: geolocalizacao_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: -
--

CREATE SEQUENCE "ProdNac2021".geolocalizacao_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 191 (class 1259 OID 37913)
-- Name: georreferenciamento; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".georreferenciamento (
    codgeorr integer NOT NULL,
    parecer character varying(25),
    verificacao character varying(25),
    fk_idCdg_geor integer NOT NULL
);


--
-- TOC entry 192 (class 1259 OID 37916)
-- Name: georreferenciamento_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: -
--

CREATE SEQUENCE "ProdNac2021".georreferenciamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 193 (class 1259 OID 37918)
-- Name: logbd; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".logbd (
    codlog integer NOT NULL,
    dataalteracao date NOT NULL,
    usuario character varying(50) NOT NULL,
    operacao character varying(10) NOT NULL,
    fk_idCdg_log integer NOT NULL
);


--
-- TOC entry 197 (class 1259 OID 38008)
-- Name: logbd_seq; Type: SEQUENCE; Schema: ProdNac2021; Owner: -
--

CREATE SEQUENCE "ProdNac2021".logbd_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 194 (class 1259 OID 37923)
-- Name: procedmetodolog; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".procedmetodolog (
    codproced integer NOT NULL,
    datap date,
    fk_idCdg integer NOT NULL,
    fk_codprof integer NOT NULL,
    fk_codacao integer NOT NULL
);


--
-- TOC entry 195 (class 1259 OID 37926)
-- Name: profissional; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".profissional (
    codprof integer NOT NULL,
    "nomeCompleto" character varying(70),
    "UF" character varying(2),
    nomeformatado character varying(70)
);


--
-- TOC entry 196 (class 1259 OID 37929)
-- Name: tipoacao; Type: TABLE; Schema: ProdNac2021; Owner: -
--

CREATE TABLE "ProdNac2021".tipoacao (
    codacao integer NOT NULL,
    servico character varying(25) NOT NULL
);


--
-- TOC entry 2185 (class 0 OID 37897)
-- Dependencies: 186
-- Data for Name: cdg; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2186 (class 0 OID 37903)
-- Dependencies: 187
-- Data for Name: geoaproximacao; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2188 (class 0 OID 37908)
-- Dependencies: 189
-- Data for Name: geolocalizacao; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2190 (class 0 OID 37913)
-- Dependencies: 191
-- Data for Name: georreferenciamento; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2192 (class 0 OID 37918)
-- Dependencies: 193
-- Data for Name: logbd; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--

INSERT INTO "ProdNac2021".logbd VALUES (1884, '2021-04-13', 'postgres', 'DELETE', 'RJ02');
INSERT INTO "ProdNac2021".logbd VALUES (1885, '2021-04-13', 'postgres', 'DELETE', 'RJ03');
INSERT INTO "ProdNac2021".logbd VALUES (1886, '2021-04-13', 'postgres', 'DELETE', 'RJ04');
INSERT INTO "ProdNac2021".logbd VALUES (1887, '2021-04-13', 'postgres', 'DELETE', 'RJ05');
INSERT INTO "ProdNac2021".logbd VALUES (1888, '2021-04-13', 'postgres', 'DELETE', 'RJ06');
INSERT INTO "ProdNac2021".logbd VALUES (1889, '2021-04-13', 'postgres', 'DELETE', 'RJ08');
INSERT INTO "ProdNac2021".logbd VALUES (1890, '2021-04-13', 'postgres', 'DELETE', 'RJ09');
INSERT INTO "ProdNac2021".logbd VALUES (1891, '2021-04-13', 'postgres', 'DELETE', 'RJ10');
INSERT INTO "ProdNac2021".logbd VALUES (1892, '2021-04-13', 'postgres', 'DELETE', 'RJ100');
INSERT INTO "ProdNac2021".logbd VALUES (1893, '2021-04-13', 'postgres', 'DELETE', 'RJ1000');
INSERT INTO "ProdNac2021".logbd VALUES (1894, '2021-04-13', 'postgres', 'DELETE', 'RJ1001');
INSERT INTO "ProdNac2021".logbd VALUES (1895, '2021-04-13', 'postgres', 'DELETE', 'RJ1002');
INSERT INTO "ProdNac2021".logbd VALUES (1896, '2021-04-13', 'postgres', 'DELETE', 'RJ1003');
INSERT INTO "ProdNac2021".logbd VALUES (1897, '2021-04-13', 'postgres', 'DELETE', 'RJ1004');
INSERT INTO "ProdNac2021".logbd VALUES (1898, '2021-04-13', 'postgres', 'DELETE', 'RJ1005');
INSERT INTO "ProdNac2021".logbd VALUES (1899, '2021-04-13', 'postgres', 'DELETE', 'RJ1006');
INSERT INTO "ProdNac2021".logbd VALUES (1900, '2021-04-13', 'postgres', 'DELETE', 'RJ1007');
INSERT INTO "ProdNac2021".logbd VALUES (1901, '2021-04-13', 'postgres', 'DELETE', 'RJ1008');
INSERT INTO "ProdNac2021".logbd VALUES (1902, '2021-04-13', 'postgres', 'DELETE', 'RJ1009');
INSERT INTO "ProdNac2021".logbd VALUES (1903, '2021-04-13', 'postgres', 'DELETE', 'RJ101');
INSERT INTO "ProdNac2021".logbd VALUES (1904, '2021-04-13', 'postgres', 'DELETE', 'RJ1010');
INSERT INTO "ProdNac2021".logbd VALUES (1905, '2021-04-13', 'postgres', 'DELETE', 'RJ1011');
INSERT INTO "ProdNac2021".logbd VALUES (1906, '2021-04-13', 'postgres', 'DELETE', 'RJ1012');
INSERT INTO "ProdNac2021".logbd VALUES (1907, '2021-04-13', 'postgres', 'DELETE', 'RJ1013');
INSERT INTO "ProdNac2021".logbd VALUES (1908, '2021-04-13', 'postgres', 'DELETE', 'RJ1014');
INSERT INTO "ProdNac2021".logbd VALUES (1909, '2021-04-13', 'postgres', 'DELETE', 'RJ1015');
INSERT INTO "ProdNac2021".logbd VALUES (1910, '2021-04-13', 'postgres', 'DELETE', 'RJ1016');
INSERT INTO "ProdNac2021".logbd VALUES (1911, '2021-04-13', 'postgres', 'DELETE', 'RJ1017');
INSERT INTO "ProdNac2021".logbd VALUES (1912, '2021-04-13', 'postgres', 'DELETE', 'RJ1018');
INSERT INTO "ProdNac2021".logbd VALUES (1913, '2021-04-13', 'postgres', 'DELETE', 'RJ1019');
INSERT INTO "ProdNac2021".logbd VALUES (1914, '2021-04-13', 'postgres', 'DELETE', 'RJ102');
INSERT INTO "ProdNac2021".logbd VALUES (1915, '2021-04-13', 'postgres', 'DELETE', 'RJ1020');
INSERT INTO "ProdNac2021".logbd VALUES (1916, '2021-04-13', 'postgres', 'DELETE', 'RJ1021');
INSERT INTO "ProdNac2021".logbd VALUES (1917, '2021-04-13', 'postgres', 'DELETE', 'RJ1022');
INSERT INTO "ProdNac2021".logbd VALUES (1918, '2021-04-13', 'postgres', 'DELETE', 'RJ1023');
INSERT INTO "ProdNac2021".logbd VALUES (1919, '2021-04-13', 'postgres', 'DELETE', 'RJ1024');
INSERT INTO "ProdNac2021".logbd VALUES (1920, '2021-04-13', 'postgres', 'DELETE', 'RJ1025');
INSERT INTO "ProdNac2021".logbd VALUES (1921, '2021-04-13', 'postgres', 'DELETE', 'RJ1026');
INSERT INTO "ProdNac2021".logbd VALUES (1922, '2021-04-13', 'postgres', 'DELETE', 'RJ1027');
INSERT INTO "ProdNac2021".logbd VALUES (1923, '2021-04-13', 'postgres', 'DELETE', 'RJ1028');
INSERT INTO "ProdNac2021".logbd VALUES (1924, '2021-04-13', 'postgres', 'DELETE', 'RJ103');
INSERT INTO "ProdNac2021".logbd VALUES (1925, '2021-04-13', 'postgres', 'DELETE', 'RJ1030');
INSERT INTO "ProdNac2021".logbd VALUES (1926, '2021-04-13', 'postgres', 'DELETE', 'RJ1031');
INSERT INTO "ProdNac2021".logbd VALUES (1927, '2021-04-13', 'postgres', 'DELETE', 'RJ1032');
INSERT INTO "ProdNac2021".logbd VALUES (1928, '2021-04-13', 'postgres', 'DELETE', 'RJ1033');
INSERT INTO "ProdNac2021".logbd VALUES (1929, '2021-04-13', 'postgres', 'DELETE', 'RJ1034');
INSERT INTO "ProdNac2021".logbd VALUES (1930, '2021-04-13', 'postgres', 'DELETE', 'RJ1035');
INSERT INTO "ProdNac2021".logbd VALUES (1931, '2021-04-13', 'postgres', 'DELETE', 'RJ1036');
INSERT INTO "ProdNac2021".logbd VALUES (1932, '2021-04-13', 'postgres', 'DELETE', 'RJ1037');
INSERT INTO "ProdNac2021".logbd VALUES (1933, '2021-04-13', 'postgres', 'DELETE', 'RJ1038');
INSERT INTO "ProdNac2021".logbd VALUES (1934, '2021-04-13', 'postgres', 'DELETE', 'RJ1039');
INSERT INTO "ProdNac2021".logbd VALUES (1935, '2021-04-13', 'postgres', 'DELETE', 'RJ104');
INSERT INTO "ProdNac2021".logbd VALUES (1936, '2021-04-13', 'postgres', 'DELETE', 'RJ1040');
INSERT INTO "ProdNac2021".logbd VALUES (1937, '2021-04-13', 'postgres', 'DELETE', 'RJ1041');
INSERT INTO "ProdNac2021".logbd VALUES (1938, '2021-04-13', 'postgres', 'DELETE', 'RJ1042');
INSERT INTO "ProdNac2021".logbd VALUES (1939, '2021-04-13', 'postgres', 'DELETE', 'RJ1043');
INSERT INTO "ProdNac2021".logbd VALUES (1940, '2021-04-13', 'postgres', 'DELETE', 'RJ1044');
INSERT INTO "ProdNac2021".logbd VALUES (1941, '2021-04-13', 'postgres', 'DELETE', 'RJ1045');
INSERT INTO "ProdNac2021".logbd VALUES (1942, '2021-04-13', 'postgres', 'DELETE', 'RJ1046');
INSERT INTO "ProdNac2021".logbd VALUES (1943, '2021-04-13', 'postgres', 'DELETE', 'RJ1047');
INSERT INTO "ProdNac2021".logbd VALUES (1944, '2021-04-13', 'postgres', 'DELETE', 'RJ1048');
INSERT INTO "ProdNac2021".logbd VALUES (1945, '2021-04-13', 'postgres', 'DELETE', 'RJ1049');
INSERT INTO "ProdNac2021".logbd VALUES (1946, '2021-04-13', 'postgres', 'DELETE', 'RJ105');
INSERT INTO "ProdNac2021".logbd VALUES (1947, '2021-04-13', 'postgres', 'DELETE', 'RJ1050');
INSERT INTO "ProdNac2021".logbd VALUES (1948, '2021-04-13', 'postgres', 'DELETE', 'RJ1051');
INSERT INTO "ProdNac2021".logbd VALUES (1949, '2021-04-13', 'postgres', 'DELETE', 'RJ1052');
INSERT INTO "ProdNac2021".logbd VALUES (1950, '2021-04-13', 'postgres', 'DELETE', 'RJ1053');
INSERT INTO "ProdNac2021".logbd VALUES (1951, '2021-04-13', 'postgres', 'DELETE', 'RJ1054');
INSERT INTO "ProdNac2021".logbd VALUES (1952, '2021-04-13', 'postgres', 'DELETE', 'RJ1055');
INSERT INTO "ProdNac2021".logbd VALUES (1953, '2021-04-13', 'postgres', 'DELETE', 'RJ1056');
INSERT INTO "ProdNac2021".logbd VALUES (1954, '2021-04-13', 'postgres', 'DELETE', 'RJ1057');
INSERT INTO "ProdNac2021".logbd VALUES (1955, '2021-04-13', 'postgres', 'DELETE', 'RJ1058');
INSERT INTO "ProdNac2021".logbd VALUES (1956, '2021-04-13', 'postgres', 'DELETE', 'RJ1059');
INSERT INTO "ProdNac2021".logbd VALUES (1957, '2021-04-13', 'postgres', 'DELETE', 'RJ106');
INSERT INTO "ProdNac2021".logbd VALUES (1958, '2021-04-13', 'postgres', 'DELETE', 'RJ1060');
INSERT INTO "ProdNac2021".logbd VALUES (1959, '2021-04-13', 'postgres', 'DELETE', 'RJ1061');
INSERT INTO "ProdNac2021".logbd VALUES (1960, '2021-04-13', 'postgres', 'DELETE', 'RJ1062');
INSERT INTO "ProdNac2021".logbd VALUES (1961, '2021-04-13', 'postgres', 'DELETE', 'RJ1063');
INSERT INTO "ProdNac2021".logbd VALUES (1962, '2021-04-13', 'postgres', 'DELETE', 'RJ1064');
INSERT INTO "ProdNac2021".logbd VALUES (1963, '2021-04-13', 'postgres', 'DELETE', 'RJ1065');
INSERT INTO "ProdNac2021".logbd VALUES (1964, '2021-04-13', 'postgres', 'DELETE', 'RJ1066');
INSERT INTO "ProdNac2021".logbd VALUES (1965, '2021-04-13', 'postgres', 'DELETE', 'RJ1067');
INSERT INTO "ProdNac2021".logbd VALUES (1966, '2021-04-13', 'postgres', 'DELETE', 'RJ1068');
INSERT INTO "ProdNac2021".logbd VALUES (1967, '2021-04-13', 'postgres', 'DELETE', 'RJ1069');
INSERT INTO "ProdNac2021".logbd VALUES (1968, '2021-04-13', 'postgres', 'DELETE', 'RJ107');
INSERT INTO "ProdNac2021".logbd VALUES (1969, '2021-04-13', 'postgres', 'DELETE', 'RJ1070');
INSERT INTO "ProdNac2021".logbd VALUES (1970, '2021-04-13', 'postgres', 'DELETE', 'RJ1071');
INSERT INTO "ProdNac2021".logbd VALUES (1971, '2021-04-13', 'postgres', 'DELETE', 'RJ1072');
INSERT INTO "ProdNac2021".logbd VALUES (1972, '2021-04-13', 'postgres', 'DELETE', 'RJ1073');
INSERT INTO "ProdNac2021".logbd VALUES (1973, '2021-04-13', 'postgres', 'DELETE', 'RJ1074');
INSERT INTO "ProdNac2021".logbd VALUES (1974, '2021-04-13', 'postgres', 'DELETE', 'RJ1075');
INSERT INTO "ProdNac2021".logbd VALUES (1975, '2021-04-13', 'postgres', 'DELETE', 'RJ1076');
INSERT INTO "ProdNac2021".logbd VALUES (1976, '2021-04-13', 'postgres', 'DELETE', 'RJ1077');
INSERT INTO "ProdNac2021".logbd VALUES (1977, '2021-04-13', 'postgres', 'DELETE', 'RJ1078');
INSERT INTO "ProdNac2021".logbd VALUES (1978, '2021-04-13', 'postgres', 'DELETE', 'RJ1079');
INSERT INTO "ProdNac2021".logbd VALUES (1979, '2021-04-13', 'postgres', 'DELETE', 'RJ108');
INSERT INTO "ProdNac2021".logbd VALUES (1980, '2021-04-13', 'postgres', 'DELETE', 'RJ1080');
INSERT INTO "ProdNac2021".logbd VALUES (1981, '2021-04-13', 'postgres', 'DELETE', 'RJ1081');
INSERT INTO "ProdNac2021".logbd VALUES (1982, '2021-04-13', 'postgres', 'DELETE', 'RJ1082');
INSERT INTO "ProdNac2021".logbd VALUES (1983, '2021-04-13', 'postgres', 'DELETE', 'RJ1083');
INSERT INTO "ProdNac2021".logbd VALUES (1984, '2021-04-13', 'postgres', 'DELETE', 'RJ1084');
INSERT INTO "ProdNac2021".logbd VALUES (1985, '2021-04-13', 'postgres', 'DELETE', 'RJ1085');
INSERT INTO "ProdNac2021".logbd VALUES (1986, '2021-04-13', 'postgres', 'DELETE', 'RJ1086');
INSERT INTO "ProdNac2021".logbd VALUES (1987, '2021-04-13', 'postgres', 'DELETE', 'RJ1087');
INSERT INTO "ProdNac2021".logbd VALUES (1988, '2021-04-13', 'postgres', 'DELETE', 'RJ1088');
INSERT INTO "ProdNac2021".logbd VALUES (1989, '2021-04-13', 'postgres', 'DELETE', 'RJ1089');
INSERT INTO "ProdNac2021".logbd VALUES (1990, '2021-04-13', 'postgres', 'DELETE', 'RJ109');
INSERT INTO "ProdNac2021".logbd VALUES (1991, '2021-04-13', 'postgres', 'DELETE', 'RJ1090');
INSERT INTO "ProdNac2021".logbd VALUES (1992, '2021-04-13', 'postgres', 'DELETE', 'RJ1091');
INSERT INTO "ProdNac2021".logbd VALUES (1993, '2021-04-13', 'postgres', 'DELETE', 'RJ1092');
INSERT INTO "ProdNac2021".logbd VALUES (1994, '2021-04-13', 'postgres', 'DELETE', 'RJ1093');
INSERT INTO "ProdNac2021".logbd VALUES (1995, '2021-04-13', 'postgres', 'DELETE', 'RJ1094');
INSERT INTO "ProdNac2021".logbd VALUES (1996, '2021-04-13', 'postgres', 'DELETE', 'RJ1095');
INSERT INTO "ProdNac2021".logbd VALUES (1997, '2021-04-13', 'postgres', 'DELETE', 'RJ1096');
INSERT INTO "ProdNac2021".logbd VALUES (1998, '2021-04-13', 'postgres', 'DELETE', 'RJ1097');
INSERT INTO "ProdNac2021".logbd VALUES (1999, '2021-04-13', 'postgres', 'DELETE', 'RJ1098');
INSERT INTO "ProdNac2021".logbd VALUES (2000, '2021-04-13', 'postgres', 'DELETE', 'RJ1099');
INSERT INTO "ProdNac2021".logbd VALUES (2001, '2021-04-13', 'postgres', 'DELETE', 'RJ11');
INSERT INTO "ProdNac2021".logbd VALUES (2002, '2021-04-13', 'postgres', 'DELETE', 'RJ110');
INSERT INTO "ProdNac2021".logbd VALUES (2003, '2021-04-13', 'postgres', 'DELETE', 'RJ1100');
INSERT INTO "ProdNac2021".logbd VALUES (2004, '2021-04-13', 'postgres', 'DELETE', 'RJ1101');
INSERT INTO "ProdNac2021".logbd VALUES (2005, '2021-04-13', 'postgres', 'DELETE', 'RJ1102');
INSERT INTO "ProdNac2021".logbd VALUES (2006, '2021-04-13', 'postgres', 'DELETE', 'RJ1103');
INSERT INTO "ProdNac2021".logbd VALUES (2007, '2021-04-13', 'postgres', 'DELETE', 'RJ1104');
INSERT INTO "ProdNac2021".logbd VALUES (2008, '2021-04-13', 'postgres', 'DELETE', 'RJ1105');
INSERT INTO "ProdNac2021".logbd VALUES (2009, '2021-04-13', 'postgres', 'DELETE', 'RJ1106');
INSERT INTO "ProdNac2021".logbd VALUES (2010, '2021-04-13', 'postgres', 'DELETE', 'RJ1107');
INSERT INTO "ProdNac2021".logbd VALUES (2011, '2021-04-13', 'postgres', 'DELETE', 'RJ1108');
INSERT INTO "ProdNac2021".logbd VALUES (2012, '2021-04-13', 'postgres', 'DELETE', 'RJ1109');
INSERT INTO "ProdNac2021".logbd VALUES (2013, '2021-04-13', 'postgres', 'DELETE', 'RJ111');
INSERT INTO "ProdNac2021".logbd VALUES (2014, '2021-04-13', 'postgres', 'DELETE', 'RJ1110');
INSERT INTO "ProdNac2021".logbd VALUES (2015, '2021-04-13', 'postgres', 'DELETE', 'RJ1111');
INSERT INTO "ProdNac2021".logbd VALUES (2016, '2021-04-13', 'postgres', 'DELETE', 'RJ1112');
INSERT INTO "ProdNac2021".logbd VALUES (2017, '2021-04-13', 'postgres', 'DELETE', 'RJ1113');
INSERT INTO "ProdNac2021".logbd VALUES (2018, '2021-04-13', 'postgres', 'DELETE', 'RJ1114');
INSERT INTO "ProdNac2021".logbd VALUES (2019, '2021-04-13', 'postgres', 'DELETE', 'RJ1115');
INSERT INTO "ProdNac2021".logbd VALUES (2020, '2021-04-13', 'postgres', 'DELETE', 'RJ1116');
INSERT INTO "ProdNac2021".logbd VALUES (2021, '2021-04-13', 'postgres', 'DELETE', 'RJ1117');
INSERT INTO "ProdNac2021".logbd VALUES (2022, '2021-04-13', 'postgres', 'DELETE', 'RJ1118');
INSERT INTO "ProdNac2021".logbd VALUES (2023, '2021-04-13', 'postgres', 'DELETE', 'RJ1119');
INSERT INTO "ProdNac2021".logbd VALUES (2024, '2021-04-13', 'postgres', 'DELETE', 'RJ112');
INSERT INTO "ProdNac2021".logbd VALUES (2025, '2021-04-13', 'postgres', 'DELETE', 'RJ1120');
INSERT INTO "ProdNac2021".logbd VALUES (2026, '2021-04-13', 'postgres', 'DELETE', 'RJ1121');
INSERT INTO "ProdNac2021".logbd VALUES (2027, '2021-04-13', 'postgres', 'DELETE', 'RJ1122');
INSERT INTO "ProdNac2021".logbd VALUES (2028, '2021-04-13', 'postgres', 'DELETE', 'RJ1123');
INSERT INTO "ProdNac2021".logbd VALUES (2029, '2021-04-13', 'postgres', 'DELETE', 'RJ1124');
INSERT INTO "ProdNac2021".logbd VALUES (2030, '2021-04-13', 'postgres', 'DELETE', 'RJ1125');
INSERT INTO "ProdNac2021".logbd VALUES (2031, '2021-04-13', 'postgres', 'DELETE', 'RJ1126');
INSERT INTO "ProdNac2021".logbd VALUES (2032, '2021-04-13', 'postgres', 'DELETE', 'RJ1127');
INSERT INTO "ProdNac2021".logbd VALUES (2033, '2021-04-13', 'postgres', 'DELETE', 'RJ1128');
INSERT INTO "ProdNac2021".logbd VALUES (2034, '2021-04-13', 'postgres', 'DELETE', 'RJ1129');
INSERT INTO "ProdNac2021".logbd VALUES (2035, '2021-04-13', 'postgres', 'DELETE', 'RJ113');
INSERT INTO "ProdNac2021".logbd VALUES (2036, '2021-04-13', 'postgres', 'DELETE', 'RJ1130');
INSERT INTO "ProdNac2021".logbd VALUES (2037, '2021-04-13', 'postgres', 'DELETE', 'RJ1131');
INSERT INTO "ProdNac2021".logbd VALUES (2038, '2021-04-13', 'postgres', 'DELETE', 'RJ1132');
INSERT INTO "ProdNac2021".logbd VALUES (2039, '2021-04-13', 'postgres', 'DELETE', 'RJ1133');
INSERT INTO "ProdNac2021".logbd VALUES (2040, '2021-04-13', 'postgres', 'DELETE', 'RJ1134');
INSERT INTO "ProdNac2021".logbd VALUES (2041, '2021-04-13', 'postgres', 'DELETE', 'RJ1135');
INSERT INTO "ProdNac2021".logbd VALUES (2042, '2021-04-13', 'postgres', 'DELETE', 'RJ1136');
INSERT INTO "ProdNac2021".logbd VALUES (2043, '2021-04-13', 'postgres', 'DELETE', 'RJ1137');
INSERT INTO "ProdNac2021".logbd VALUES (2044, '2021-04-13', 'postgres', 'DELETE', 'RJ1138');
INSERT INTO "ProdNac2021".logbd VALUES (2045, '2021-04-13', 'postgres', 'DELETE', 'RJ1139');
INSERT INTO "ProdNac2021".logbd VALUES (2046, '2021-04-13', 'postgres', 'DELETE', 'RJ114');
INSERT INTO "ProdNac2021".logbd VALUES (2047, '2021-04-13', 'postgres', 'DELETE', 'RJ1140');
INSERT INTO "ProdNac2021".logbd VALUES (2048, '2021-04-13', 'postgres', 'DELETE', 'RJ1141');
INSERT INTO "ProdNac2021".logbd VALUES (2049, '2021-04-13', 'postgres', 'DELETE', 'RJ1142');
INSERT INTO "ProdNac2021".logbd VALUES (2050, '2021-04-13', 'postgres', 'DELETE', 'RJ1143');
INSERT INTO "ProdNac2021".logbd VALUES (2051, '2021-04-13', 'postgres', 'DELETE', 'RJ1144');
INSERT INTO "ProdNac2021".logbd VALUES (2052, '2021-04-13', 'postgres', 'DELETE', 'RJ1145');
INSERT INTO "ProdNac2021".logbd VALUES (2053, '2021-04-13', 'postgres', 'DELETE', 'RJ1146');
INSERT INTO "ProdNac2021".logbd VALUES (2054, '2021-04-13', 'postgres', 'DELETE', 'RJ1147');
INSERT INTO "ProdNac2021".logbd VALUES (2055, '2021-04-13', 'postgres', 'DELETE', 'RJ1148');
INSERT INTO "ProdNac2021".logbd VALUES (2056, '2021-04-13', 'postgres', 'DELETE', 'RJ1149');
INSERT INTO "ProdNac2021".logbd VALUES (2057, '2021-04-13', 'postgres', 'DELETE', 'RJ115');
INSERT INTO "ProdNac2021".logbd VALUES (2058, '2021-04-13', 'postgres', 'DELETE', 'RJ1150');
INSERT INTO "ProdNac2021".logbd VALUES (2059, '2021-04-13', 'postgres', 'DELETE', 'RJ1151');
INSERT INTO "ProdNac2021".logbd VALUES (2060, '2021-04-13', 'postgres', 'DELETE', 'RJ1152');
INSERT INTO "ProdNac2021".logbd VALUES (2061, '2021-04-13', 'postgres', 'DELETE', 'RJ1153');
INSERT INTO "ProdNac2021".logbd VALUES (2062, '2021-04-13', 'postgres', 'DELETE', 'RJ1154');
INSERT INTO "ProdNac2021".logbd VALUES (2063, '2021-04-13', 'postgres', 'DELETE', 'RJ1155');
INSERT INTO "ProdNac2021".logbd VALUES (2064, '2021-04-13', 'postgres', 'DELETE', 'RJ1156');
INSERT INTO "ProdNac2021".logbd VALUES (2065, '2021-04-13', 'postgres', 'DELETE', 'RJ1157');
INSERT INTO "ProdNac2021".logbd VALUES (2066, '2021-04-13', 'postgres', 'DELETE', 'RJ1158');
INSERT INTO "ProdNac2021".logbd VALUES (2067, '2021-04-13', 'postgres', 'DELETE', 'RJ1159');
INSERT INTO "ProdNac2021".logbd VALUES (2068, '2021-04-13', 'postgres', 'DELETE', 'RJ116');
INSERT INTO "ProdNac2021".logbd VALUES (2069, '2021-04-13', 'postgres', 'DELETE', 'RJ1160');
INSERT INTO "ProdNac2021".logbd VALUES (2070, '2021-04-13', 'postgres', 'DELETE', 'RJ1161');
INSERT INTO "ProdNac2021".logbd VALUES (2071, '2021-04-13', 'postgres', 'DELETE', 'RJ1162');
INSERT INTO "ProdNac2021".logbd VALUES (2072, '2021-04-13', 'postgres', 'DELETE', 'RJ1163');
INSERT INTO "ProdNac2021".logbd VALUES (2073, '2021-04-13', 'postgres', 'DELETE', 'RJ1164');
INSERT INTO "ProdNac2021".logbd VALUES (2074, '2021-04-13', 'postgres', 'DELETE', 'RJ1165');
INSERT INTO "ProdNac2021".logbd VALUES (2075, '2021-04-13', 'postgres', 'DELETE', 'RJ1166');
INSERT INTO "ProdNac2021".logbd VALUES (2076, '2021-04-13', 'postgres', 'DELETE', 'RJ1167');
INSERT INTO "ProdNac2021".logbd VALUES (2077, '2021-04-13', 'postgres', 'DELETE', 'RJ1168');
INSERT INTO "ProdNac2021".logbd VALUES (2078, '2021-04-13', 'postgres', 'DELETE', 'RJ1169');
INSERT INTO "ProdNac2021".logbd VALUES (2079, '2021-04-13', 'postgres', 'DELETE', 'RJ117');
INSERT INTO "ProdNac2021".logbd VALUES (2080, '2021-04-13', 'postgres', 'DELETE', 'RJ1170');
INSERT INTO "ProdNac2021".logbd VALUES (2081, '2021-04-13', 'postgres', 'DELETE', 'RJ1171');
INSERT INTO "ProdNac2021".logbd VALUES (2082, '2021-04-13', 'postgres', 'DELETE', 'RJ1172');
INSERT INTO "ProdNac2021".logbd VALUES (2083, '2021-04-13', 'postgres', 'DELETE', 'RJ1173');
INSERT INTO "ProdNac2021".logbd VALUES (2084, '2021-04-13', 'postgres', 'DELETE', 'RJ1174');
INSERT INTO "ProdNac2021".logbd VALUES (2085, '2021-04-13', 'postgres', 'DELETE', 'RJ1175');
INSERT INTO "ProdNac2021".logbd VALUES (2086, '2021-04-13', 'postgres', 'DELETE', 'RJ1176');
INSERT INTO "ProdNac2021".logbd VALUES (2087, '2021-04-13', 'postgres', 'DELETE', 'RJ1177');
INSERT INTO "ProdNac2021".logbd VALUES (2088, '2021-04-13', 'postgres', 'DELETE', 'RJ1178');
INSERT INTO "ProdNac2021".logbd VALUES (2089, '2021-04-13', 'postgres', 'DELETE', 'RJ1179');
INSERT INTO "ProdNac2021".logbd VALUES (2090, '2021-04-13', 'postgres', 'DELETE', 'RJ118');
INSERT INTO "ProdNac2021".logbd VALUES (2091, '2021-04-13', 'postgres', 'DELETE', 'RJ1180');
INSERT INTO "ProdNac2021".logbd VALUES (2092, '2021-04-13', 'postgres', 'DELETE', 'RJ1181');
INSERT INTO "ProdNac2021".logbd VALUES (2093, '2021-04-13', 'postgres', 'DELETE', 'RJ1182');
INSERT INTO "ProdNac2021".logbd VALUES (2094, '2021-04-13', 'postgres', 'DELETE', 'RJ1183');
INSERT INTO "ProdNac2021".logbd VALUES (2095, '2021-04-13', 'postgres', 'DELETE', 'RJ1184');
INSERT INTO "ProdNac2021".logbd VALUES (2096, '2021-04-13', 'postgres', 'DELETE', 'RJ1185');
INSERT INTO "ProdNac2021".logbd VALUES (2097, '2021-04-13', 'postgres', 'DELETE', 'RJ1186');
INSERT INTO "ProdNac2021".logbd VALUES (2098, '2021-04-13', 'postgres', 'DELETE', 'RJ1187');
INSERT INTO "ProdNac2021".logbd VALUES (2099, '2021-04-13', 'postgres', 'DELETE', 'RJ1188');
INSERT INTO "ProdNac2021".logbd VALUES (2100, '2021-04-13', 'postgres', 'DELETE', 'RJ1189');
INSERT INTO "ProdNac2021".logbd VALUES (2101, '2021-04-13', 'postgres', 'DELETE', 'RJ119');
INSERT INTO "ProdNac2021".logbd VALUES (2102, '2021-04-13', 'postgres', 'DELETE', 'RJ1190');
INSERT INTO "ProdNac2021".logbd VALUES (2103, '2021-04-13', 'postgres', 'DELETE', 'RJ1191');
INSERT INTO "ProdNac2021".logbd VALUES (2104, '2021-04-13', 'postgres', 'DELETE', 'RJ1192');
INSERT INTO "ProdNac2021".logbd VALUES (2105, '2021-04-13', 'postgres', 'DELETE', 'RJ1193');
INSERT INTO "ProdNac2021".logbd VALUES (2106, '2021-04-13', 'postgres', 'DELETE', 'RJ1194');
INSERT INTO "ProdNac2021".logbd VALUES (2107, '2021-04-13', 'postgres', 'DELETE', 'RJ1195');
INSERT INTO "ProdNac2021".logbd VALUES (2108, '2021-04-13', 'postgres', 'DELETE', 'RJ1196');
INSERT INTO "ProdNac2021".logbd VALUES (2109, '2021-04-13', 'postgres', 'DELETE', 'RJ1197');
INSERT INTO "ProdNac2021".logbd VALUES (2110, '2021-04-13', 'postgres', 'DELETE', 'RJ1199');
INSERT INTO "ProdNac2021".logbd VALUES (2111, '2021-04-13', 'postgres', 'DELETE', 'RJ12');
INSERT INTO "ProdNac2021".logbd VALUES (2112, '2021-04-13', 'postgres', 'DELETE', 'RJ120');
INSERT INTO "ProdNac2021".logbd VALUES (2113, '2021-04-13', 'postgres', 'DELETE', 'RJ1200');
INSERT INTO "ProdNac2021".logbd VALUES (2114, '2021-04-13', 'postgres', 'DELETE', 'RJ1201');
INSERT INTO "ProdNac2021".logbd VALUES (2115, '2021-04-13', 'postgres', 'DELETE', 'RJ1202');
INSERT INTO "ProdNac2021".logbd VALUES (2116, '2021-04-13', 'postgres', 'DELETE', 'RJ1203');
INSERT INTO "ProdNac2021".logbd VALUES (2117, '2021-04-13', 'postgres', 'DELETE', 'RJ1204');
INSERT INTO "ProdNac2021".logbd VALUES (2118, '2021-04-13', 'postgres', 'DELETE', 'RJ1205');
INSERT INTO "ProdNac2021".logbd VALUES (2119, '2021-04-13', 'postgres', 'DELETE', 'RJ1206');
INSERT INTO "ProdNac2021".logbd VALUES (2120, '2021-04-13', 'postgres', 'DELETE', 'RJ1207');
INSERT INTO "ProdNac2021".logbd VALUES (2121, '2021-04-13', 'postgres', 'DELETE', 'RJ1208');
INSERT INTO "ProdNac2021".logbd VALUES (2122, '2021-04-13', 'postgres', 'DELETE', 'RJ1209');
INSERT INTO "ProdNac2021".logbd VALUES (2123, '2021-04-13', 'postgres', 'DELETE', 'RJ121');
INSERT INTO "ProdNac2021".logbd VALUES (2124, '2021-04-13', 'postgres', 'DELETE', 'RJ1210');
INSERT INTO "ProdNac2021".logbd VALUES (2125, '2021-04-13', 'postgres', 'DELETE', 'RJ1211');
INSERT INTO "ProdNac2021".logbd VALUES (2126, '2021-04-13', 'postgres', 'DELETE', 'RJ1212');
INSERT INTO "ProdNac2021".logbd VALUES (2127, '2021-04-13', 'postgres', 'DELETE', 'RJ1213');
INSERT INTO "ProdNac2021".logbd VALUES (2128, '2021-04-13', 'postgres', 'DELETE', 'RJ1214');
INSERT INTO "ProdNac2021".logbd VALUES (2129, '2021-04-13', 'postgres', 'DELETE', 'RJ1215');
INSERT INTO "ProdNac2021".logbd VALUES (2130, '2021-04-13', 'postgres', 'DELETE', 'RJ1216');
INSERT INTO "ProdNac2021".logbd VALUES (2131, '2021-04-13', 'postgres', 'DELETE', 'RJ1217');
INSERT INTO "ProdNac2021".logbd VALUES (2132, '2021-04-13', 'postgres', 'DELETE', 'RJ1218');
INSERT INTO "ProdNac2021".logbd VALUES (2133, '2021-04-13', 'postgres', 'DELETE', 'RJ1219');
INSERT INTO "ProdNac2021".logbd VALUES (2134, '2021-04-13', 'postgres', 'DELETE', 'RJ122');
INSERT INTO "ProdNac2021".logbd VALUES (2135, '2021-04-13', 'postgres', 'DELETE', 'RJ1220');
INSERT INTO "ProdNac2021".logbd VALUES (2136, '2021-04-13', 'postgres', 'DELETE', 'RJ1221');
INSERT INTO "ProdNac2021".logbd VALUES (2137, '2021-04-13', 'postgres', 'DELETE', 'RJ1222');
INSERT INTO "ProdNac2021".logbd VALUES (2138, '2021-04-13', 'postgres', 'DELETE', 'RJ1223');
INSERT INTO "ProdNac2021".logbd VALUES (2139, '2021-04-13', 'postgres', 'DELETE', 'RJ1224');
INSERT INTO "ProdNac2021".logbd VALUES (2140, '2021-04-13', 'postgres', 'DELETE', 'RJ1225');
INSERT INTO "ProdNac2021".logbd VALUES (2141, '2021-04-13', 'postgres', 'DELETE', 'RJ1226');
INSERT INTO "ProdNac2021".logbd VALUES (2142, '2021-04-13', 'postgres', 'DELETE', 'RJ123');
INSERT INTO "ProdNac2021".logbd VALUES (2143, '2021-04-13', 'postgres', 'DELETE', 'RJ124');
INSERT INTO "ProdNac2021".logbd VALUES (2144, '2021-04-13', 'postgres', 'DELETE', 'RJ125');
INSERT INTO "ProdNac2021".logbd VALUES (2145, '2021-04-13', 'postgres', 'DELETE', 'RJ126');
INSERT INTO "ProdNac2021".logbd VALUES (2146, '2021-04-13', 'postgres', 'DELETE', 'RJ127');
INSERT INTO "ProdNac2021".logbd VALUES (2147, '2021-04-13', 'postgres', 'DELETE', 'RJ128');
INSERT INTO "ProdNac2021".logbd VALUES (2148, '2021-04-13', 'postgres', 'DELETE', 'RJ129');
INSERT INTO "ProdNac2021".logbd VALUES (2149, '2021-04-13', 'postgres', 'DELETE', 'RJ13');
INSERT INTO "ProdNac2021".logbd VALUES (2150, '2021-04-13', 'postgres', 'DELETE', 'RJ130');
INSERT INTO "ProdNac2021".logbd VALUES (2151, '2021-04-13', 'postgres', 'DELETE', 'RJ131');
INSERT INTO "ProdNac2021".logbd VALUES (2152, '2021-04-13', 'postgres', 'DELETE', 'RJ132');
INSERT INTO "ProdNac2021".logbd VALUES (2153, '2021-04-13', 'postgres', 'DELETE', 'RJ133');
INSERT INTO "ProdNac2021".logbd VALUES (2154, '2021-04-13', 'postgres', 'DELETE', 'RJ134');
INSERT INTO "ProdNac2021".logbd VALUES (2155, '2021-04-13', 'postgres', 'DELETE', 'RJ135');
INSERT INTO "ProdNac2021".logbd VALUES (2156, '2021-04-13', 'postgres', 'DELETE', 'RJ136');
INSERT INTO "ProdNac2021".logbd VALUES (2157, '2021-04-13', 'postgres', 'DELETE', 'RJ137');
INSERT INTO "ProdNac2021".logbd VALUES (2158, '2021-04-13', 'postgres', 'DELETE', 'RJ138');
INSERT INTO "ProdNac2021".logbd VALUES (2159, '2021-04-13', 'postgres', 'DELETE', 'RJ139');
INSERT INTO "ProdNac2021".logbd VALUES (2160, '2021-04-13', 'postgres', 'DELETE', 'RJ14');
INSERT INTO "ProdNac2021".logbd VALUES (2161, '2021-04-13', 'postgres', 'DELETE', 'RJ140');
INSERT INTO "ProdNac2021".logbd VALUES (2162, '2021-04-13', 'postgres', 'DELETE', 'RJ141');
INSERT INTO "ProdNac2021".logbd VALUES (2163, '2021-04-13', 'postgres', 'DELETE', 'RJ142');
INSERT INTO "ProdNac2021".logbd VALUES (2164, '2021-04-13', 'postgres', 'DELETE', 'RJ143');
INSERT INTO "ProdNac2021".logbd VALUES (2165, '2021-04-13', 'postgres', 'DELETE', 'RJ144');
INSERT INTO "ProdNac2021".logbd VALUES (2166, '2021-04-13', 'postgres', 'DELETE', 'RJ145');
INSERT INTO "ProdNac2021".logbd VALUES (2167, '2021-04-13', 'postgres', 'DELETE', 'RJ146');
INSERT INTO "ProdNac2021".logbd VALUES (2168, '2021-04-13', 'postgres', 'DELETE', 'RJ147');
INSERT INTO "ProdNac2021".logbd VALUES (2169, '2021-04-13', 'postgres', 'DELETE', 'RJ148');
INSERT INTO "ProdNac2021".logbd VALUES (2170, '2021-04-13', 'postgres', 'DELETE', 'RJ149');
INSERT INTO "ProdNac2021".logbd VALUES (2171, '2021-04-13', 'postgres', 'DELETE', 'RJ15');
INSERT INTO "ProdNac2021".logbd VALUES (2172, '2021-04-13', 'postgres', 'DELETE', 'RJ150');
INSERT INTO "ProdNac2021".logbd VALUES (2173, '2021-04-13', 'postgres', 'DELETE', 'RJ151');
INSERT INTO "ProdNac2021".logbd VALUES (2174, '2021-04-13', 'postgres', 'DELETE', 'RJ152');
INSERT INTO "ProdNac2021".logbd VALUES (2175, '2021-04-13', 'postgres', 'DELETE', 'RJ153');
INSERT INTO "ProdNac2021".logbd VALUES (2176, '2021-04-13', 'postgres', 'DELETE', 'RJ154');
INSERT INTO "ProdNac2021".logbd VALUES (2177, '2021-04-13', 'postgres', 'DELETE', 'RJ155');
INSERT INTO "ProdNac2021".logbd VALUES (2178, '2021-04-13', 'postgres', 'DELETE', 'RJ156');
INSERT INTO "ProdNac2021".logbd VALUES (2179, '2021-04-13', 'postgres', 'DELETE', 'RJ157');
INSERT INTO "ProdNac2021".logbd VALUES (2180, '2021-04-13', 'postgres', 'DELETE', 'RJ158');
INSERT INTO "ProdNac2021".logbd VALUES (2181, '2021-04-13', 'postgres', 'DELETE', 'RJ159');
INSERT INTO "ProdNac2021".logbd VALUES (2182, '2021-04-13', 'postgres', 'DELETE', 'RJ16');
INSERT INTO "ProdNac2021".logbd VALUES (2183, '2021-04-13', 'postgres', 'DELETE', 'RJ160');
INSERT INTO "ProdNac2021".logbd VALUES (2184, '2021-04-13', 'postgres', 'DELETE', 'RJ161');
INSERT INTO "ProdNac2021".logbd VALUES (2185, '2021-04-13', 'postgres', 'DELETE', 'RJ162');
INSERT INTO "ProdNac2021".logbd VALUES (2186, '2021-04-13', 'postgres', 'DELETE', 'RJ163');
INSERT INTO "ProdNac2021".logbd VALUES (2187, '2021-04-13', 'postgres', 'DELETE', 'RJ164');
INSERT INTO "ProdNac2021".logbd VALUES (2188, '2021-04-13', 'postgres', 'DELETE', 'RJ165');
INSERT INTO "ProdNac2021".logbd VALUES (2189, '2021-04-13', 'postgres', 'DELETE', 'RJ166');
INSERT INTO "ProdNac2021".logbd VALUES (2190, '2021-04-13', 'postgres', 'DELETE', 'RJ167');
INSERT INTO "ProdNac2021".logbd VALUES (2191, '2021-04-13', 'postgres', 'DELETE', 'RJ168');
INSERT INTO "ProdNac2021".logbd VALUES (2192, '2021-04-13', 'postgres', 'DELETE', 'RJ169');
INSERT INTO "ProdNac2021".logbd VALUES (2193, '2021-04-13', 'postgres', 'DELETE', 'RJ17');
INSERT INTO "ProdNac2021".logbd VALUES (2194, '2021-04-13', 'postgres', 'DELETE', 'RJ170');
INSERT INTO "ProdNac2021".logbd VALUES (2195, '2021-04-13', 'postgres', 'DELETE', 'RJ171');
INSERT INTO "ProdNac2021".logbd VALUES (2196, '2021-04-13', 'postgres', 'DELETE', 'RJ172');
INSERT INTO "ProdNac2021".logbd VALUES (2197, '2021-04-13', 'postgres', 'DELETE', 'RJ173');
INSERT INTO "ProdNac2021".logbd VALUES (2198, '2021-04-13', 'postgres', 'DELETE', 'RJ174');
INSERT INTO "ProdNac2021".logbd VALUES (2199, '2021-04-13', 'postgres', 'DELETE', 'RJ175');
INSERT INTO "ProdNac2021".logbd VALUES (2200, '2021-04-13', 'postgres', 'DELETE', 'RJ176');
INSERT INTO "ProdNac2021".logbd VALUES (2201, '2021-04-13', 'postgres', 'DELETE', 'RJ177');
INSERT INTO "ProdNac2021".logbd VALUES (2202, '2021-04-13', 'postgres', 'DELETE', 'RJ178');
INSERT INTO "ProdNac2021".logbd VALUES (2203, '2021-04-13', 'postgres', 'DELETE', 'RJ179');
INSERT INTO "ProdNac2021".logbd VALUES (2204, '2021-04-13', 'postgres', 'DELETE', 'RJ180');
INSERT INTO "ProdNac2021".logbd VALUES (2205, '2021-04-13', 'postgres', 'DELETE', 'RJ181');
INSERT INTO "ProdNac2021".logbd VALUES (2206, '2021-04-13', 'postgres', 'DELETE', 'RJ1812');
INSERT INTO "ProdNac2021".logbd VALUES (2207, '2021-04-13', 'postgres', 'DELETE', 'RJ182');
INSERT INTO "ProdNac2021".logbd VALUES (2208, '2021-04-13', 'postgres', 'DELETE', 'RJ183');
INSERT INTO "ProdNac2021".logbd VALUES (2209, '2021-04-13', 'postgres', 'DELETE', 'RJ184');
INSERT INTO "ProdNac2021".logbd VALUES (2210, '2021-04-13', 'postgres', 'DELETE', 'RJ185');
INSERT INTO "ProdNac2021".logbd VALUES (2211, '2021-04-13', 'postgres', 'DELETE', 'RJ1851');
INSERT INTO "ProdNac2021".logbd VALUES (2212, '2021-04-13', 'postgres', 'DELETE', 'RJ186');
INSERT INTO "ProdNac2021".logbd VALUES (2213, '2021-04-13', 'postgres', 'DELETE', 'RJ187');
INSERT INTO "ProdNac2021".logbd VALUES (2214, '2021-04-13', 'postgres', 'DELETE', 'RJ188');
INSERT INTO "ProdNac2021".logbd VALUES (2215, '2021-04-13', 'postgres', 'DELETE', 'RJ189');
INSERT INTO "ProdNac2021".logbd VALUES (2216, '2021-04-13', 'postgres', 'DELETE', 'RJ19');
INSERT INTO "ProdNac2021".logbd VALUES (2217, '2021-04-13', 'postgres', 'DELETE', 'RJ190');
INSERT INTO "ProdNac2021".logbd VALUES (2218, '2021-04-13', 'postgres', 'DELETE', 'RJ191');
INSERT INTO "ProdNac2021".logbd VALUES (2219, '2021-04-13', 'postgres', 'DELETE', 'RJ1919');
INSERT INTO "ProdNac2021".logbd VALUES (2220, '2021-04-13', 'postgres', 'DELETE', 'RJ192');
INSERT INTO "ProdNac2021".logbd VALUES (2221, '2021-04-13', 'postgres', 'DELETE', 'RJ193');
INSERT INTO "ProdNac2021".logbd VALUES (2222, '2021-04-13', 'postgres', 'DELETE', 'RJ194');
INSERT INTO "ProdNac2021".logbd VALUES (2223, '2021-04-13', 'postgres', 'DELETE', 'RJ195');
INSERT INTO "ProdNac2021".logbd VALUES (2224, '2021-04-13', 'postgres', 'DELETE', 'RJ196');
INSERT INTO "ProdNac2021".logbd VALUES (2225, '2021-04-13', 'postgres', 'DELETE', 'RJ197');
INSERT INTO "ProdNac2021".logbd VALUES (2226, '2021-04-13', 'postgres', 'DELETE', 'RJ1972');
INSERT INTO "ProdNac2021".logbd VALUES (2227, '2021-04-13', 'postgres', 'DELETE', 'RJ198');
INSERT INTO "ProdNac2021".logbd VALUES (2228, '2021-04-13', 'postgres', 'DELETE', 'RJ1986');
INSERT INTO "ProdNac2021".logbd VALUES (2229, '2021-04-13', 'postgres', 'DELETE', 'RJ199');
INSERT INTO "ProdNac2021".logbd VALUES (2230, '2021-04-13', 'postgres', 'DELETE', 'RJ20');
INSERT INTO "ProdNac2021".logbd VALUES (2231, '2021-04-13', 'postgres', 'DELETE', 'RJ200');
INSERT INTO "ProdNac2021".logbd VALUES (2232, '2021-04-13', 'postgres', 'DELETE', 'RJ201');
INSERT INTO "ProdNac2021".logbd VALUES (2233, '2021-04-13', 'postgres', 'DELETE', 'RJ202');
INSERT INTO "ProdNac2021".logbd VALUES (2234, '2021-04-13', 'postgres', 'DELETE', 'RJ203');
INSERT INTO "ProdNac2021".logbd VALUES (2235, '2021-04-13', 'postgres', 'DELETE', 'RJ204');
INSERT INTO "ProdNac2021".logbd VALUES (2236, '2021-04-13', 'postgres', 'DELETE', 'RJ205');
INSERT INTO "ProdNac2021".logbd VALUES (2237, '2021-04-13', 'postgres', 'DELETE', 'RJ206');
INSERT INTO "ProdNac2021".logbd VALUES (2238, '2021-04-13', 'postgres', 'DELETE', 'RJ207');
INSERT INTO "ProdNac2021".logbd VALUES (2239, '2021-04-13', 'postgres', 'DELETE', 'RJ208');
INSERT INTO "ProdNac2021".logbd VALUES (2240, '2021-04-13', 'postgres', 'DELETE', 'RJ209');
INSERT INTO "ProdNac2021".logbd VALUES (2241, '2021-04-13', 'postgres', 'DELETE', 'RJ21');
INSERT INTO "ProdNac2021".logbd VALUES (2242, '2021-04-13', 'postgres', 'DELETE', 'RJ210');
INSERT INTO "ProdNac2021".logbd VALUES (2243, '2021-04-13', 'postgres', 'DELETE', 'RJ211');
INSERT INTO "ProdNac2021".logbd VALUES (2244, '2021-04-13', 'postgres', 'DELETE', 'RJ212');
INSERT INTO "ProdNac2021".logbd VALUES (2245, '2021-04-13', 'postgres', 'DELETE', 'RJ213');
INSERT INTO "ProdNac2021".logbd VALUES (2246, '2021-04-13', 'postgres', 'DELETE', 'RJ214');
INSERT INTO "ProdNac2021".logbd VALUES (2247, '2021-04-13', 'postgres', 'DELETE', 'RJ215');
INSERT INTO "ProdNac2021".logbd VALUES (2248, '2021-04-13', 'postgres', 'DELETE', 'RJ218');
INSERT INTO "ProdNac2021".logbd VALUES (2249, '2021-04-13', 'postgres', 'DELETE', 'RJ219');
INSERT INTO "ProdNac2021".logbd VALUES (2250, '2021-04-13', 'postgres', 'DELETE', 'RJ22');
INSERT INTO "ProdNac2021".logbd VALUES (2251, '2021-04-13', 'postgres', 'DELETE', 'RJ220');
INSERT INTO "ProdNac2021".logbd VALUES (2252, '2021-04-13', 'postgres', 'DELETE', 'RJ221');
INSERT INTO "ProdNac2021".logbd VALUES (2253, '2021-04-13', 'postgres', 'DELETE', 'RJ222');
INSERT INTO "ProdNac2021".logbd VALUES (2254, '2021-04-13', 'postgres', 'DELETE', 'RJ223');
INSERT INTO "ProdNac2021".logbd VALUES (2255, '2021-04-13', 'postgres', 'DELETE', 'RJ224');
INSERT INTO "ProdNac2021".logbd VALUES (2256, '2021-04-13', 'postgres', 'DELETE', 'RJ225');
INSERT INTO "ProdNac2021".logbd VALUES (2257, '2021-04-13', 'postgres', 'DELETE', 'RJ226');
INSERT INTO "ProdNac2021".logbd VALUES (2258, '2021-04-13', 'postgres', 'DELETE', 'RJ227');
INSERT INTO "ProdNac2021".logbd VALUES (2259, '2021-04-13', 'postgres', 'DELETE', 'RJ228');
INSERT INTO "ProdNac2021".logbd VALUES (2260, '2021-04-13', 'postgres', 'DELETE', 'RJ229');
INSERT INTO "ProdNac2021".logbd VALUES (2261, '2021-04-13', 'postgres', 'DELETE', 'RJ23');
INSERT INTO "ProdNac2021".logbd VALUES (2262, '2021-04-13', 'postgres', 'DELETE', 'RJ230');
INSERT INTO "ProdNac2021".logbd VALUES (2263, '2021-04-13', 'postgres', 'DELETE', 'RJ232');
INSERT INTO "ProdNac2021".logbd VALUES (2264, '2021-04-13', 'postgres', 'DELETE', 'RJ233');
INSERT INTO "ProdNac2021".logbd VALUES (2265, '2021-04-13', 'postgres', 'DELETE', 'RJ234');
INSERT INTO "ProdNac2021".logbd VALUES (2266, '2021-04-13', 'postgres', 'DELETE', 'RJ235');
INSERT INTO "ProdNac2021".logbd VALUES (2267, '2021-04-13', 'postgres', 'DELETE', 'RJ236');
INSERT INTO "ProdNac2021".logbd VALUES (2268, '2021-04-13', 'postgres', 'DELETE', 'RJ237');
INSERT INTO "ProdNac2021".logbd VALUES (2269, '2021-04-13', 'postgres', 'DELETE', 'RJ238');
INSERT INTO "ProdNac2021".logbd VALUES (2270, '2021-04-13', 'postgres', 'DELETE', 'RJ239');
INSERT INTO "ProdNac2021".logbd VALUES (2271, '2021-04-13', 'postgres', 'DELETE', 'RJ24');
INSERT INTO "ProdNac2021".logbd VALUES (2272, '2021-04-13', 'postgres', 'DELETE', 'RJ240');
INSERT INTO "ProdNac2021".logbd VALUES (2273, '2021-04-13', 'postgres', 'DELETE', 'RJ241');
INSERT INTO "ProdNac2021".logbd VALUES (2274, '2021-04-13', 'postgres', 'DELETE', 'RJ242');
INSERT INTO "ProdNac2021".logbd VALUES (2275, '2021-04-13', 'postgres', 'DELETE', 'RJ243');
INSERT INTO "ProdNac2021".logbd VALUES (2276, '2021-04-13', 'postgres', 'DELETE', 'RJ244');
INSERT INTO "ProdNac2021".logbd VALUES (2277, '2021-04-13', 'postgres', 'DELETE', 'RJ245');
INSERT INTO "ProdNac2021".logbd VALUES (2278, '2021-04-13', 'postgres', 'DELETE', 'RJ246');
INSERT INTO "ProdNac2021".logbd VALUES (2279, '2021-04-13', 'postgres', 'DELETE', 'RJ247');
INSERT INTO "ProdNac2021".logbd VALUES (2280, '2021-04-13', 'postgres', 'DELETE', 'RJ248');
INSERT INTO "ProdNac2021".logbd VALUES (2281, '2021-04-13', 'postgres', 'DELETE', 'RJ249');
INSERT INTO "ProdNac2021".logbd VALUES (2282, '2021-04-13', 'postgres', 'DELETE', 'RJ250');
INSERT INTO "ProdNac2021".logbd VALUES (2283, '2021-04-13', 'postgres', 'DELETE', 'RJ251');
INSERT INTO "ProdNac2021".logbd VALUES (2284, '2021-04-13', 'postgres', 'DELETE', 'RJ252');
INSERT INTO "ProdNac2021".logbd VALUES (2285, '2021-04-13', 'postgres', 'DELETE', 'RJ253');
INSERT INTO "ProdNac2021".logbd VALUES (2286, '2021-04-13', 'postgres', 'DELETE', 'RJ254');
INSERT INTO "ProdNac2021".logbd VALUES (2287, '2021-04-13', 'postgres', 'DELETE', 'RJ255');
INSERT INTO "ProdNac2021".logbd VALUES (2288, '2021-04-13', 'postgres', 'DELETE', 'RJ256');
INSERT INTO "ProdNac2021".logbd VALUES (2289, '2021-04-13', 'postgres', 'DELETE', 'RJ257');
INSERT INTO "ProdNac2021".logbd VALUES (2290, '2021-04-13', 'postgres', 'DELETE', 'RJ258');
INSERT INTO "ProdNac2021".logbd VALUES (2291, '2021-04-13', 'postgres', 'DELETE', 'RJ259');
INSERT INTO "ProdNac2021".logbd VALUES (2292, '2021-04-13', 'postgres', 'DELETE', 'RJ260');
INSERT INTO "ProdNac2021".logbd VALUES (2293, '2021-04-13', 'postgres', 'DELETE', 'RJ261');
INSERT INTO "ProdNac2021".logbd VALUES (2294, '2021-04-13', 'postgres', 'DELETE', 'RJ262');
INSERT INTO "ProdNac2021".logbd VALUES (2295, '2021-04-13', 'postgres', 'DELETE', 'RJ263');
INSERT INTO "ProdNac2021".logbd VALUES (2296, '2021-04-13', 'postgres', 'DELETE', 'RJ264');
INSERT INTO "ProdNac2021".logbd VALUES (2297, '2021-04-13', 'postgres', 'DELETE', 'RJ265');
INSERT INTO "ProdNac2021".logbd VALUES (2298, '2021-04-13', 'postgres', 'DELETE', 'RJ266');
INSERT INTO "ProdNac2021".logbd VALUES (2299, '2021-04-13', 'postgres', 'DELETE', 'RJ267');
INSERT INTO "ProdNac2021".logbd VALUES (2300, '2021-04-13', 'postgres', 'DELETE', 'RJ268');
INSERT INTO "ProdNac2021".logbd VALUES (2301, '2021-04-13', 'postgres', 'DELETE', 'RJ269');
INSERT INTO "ProdNac2021".logbd VALUES (2302, '2021-04-13', 'postgres', 'DELETE', 'RJ27');
INSERT INTO "ProdNac2021".logbd VALUES (2303, '2021-04-13', 'postgres', 'DELETE', 'RJ270');
INSERT INTO "ProdNac2021".logbd VALUES (2304, '2021-04-13', 'postgres', 'DELETE', 'RJ271');
INSERT INTO "ProdNac2021".logbd VALUES (2305, '2021-04-13', 'postgres', 'DELETE', 'RJ272');
INSERT INTO "ProdNac2021".logbd VALUES (2306, '2021-04-13', 'postgres', 'DELETE', 'RJ273');
INSERT INTO "ProdNac2021".logbd VALUES (2307, '2021-04-13', 'postgres', 'DELETE', 'RJ274');
INSERT INTO "ProdNac2021".logbd VALUES (2308, '2021-04-13', 'postgres', 'DELETE', 'RJ275');
INSERT INTO "ProdNac2021".logbd VALUES (2309, '2021-04-13', 'postgres', 'DELETE', 'RJ276');
INSERT INTO "ProdNac2021".logbd VALUES (2310, '2021-04-13', 'postgres', 'DELETE', 'RJ277');
INSERT INTO "ProdNac2021".logbd VALUES (2311, '2021-04-13', 'postgres', 'DELETE', 'RJ278');
INSERT INTO "ProdNac2021".logbd VALUES (2312, '2021-04-13', 'postgres', 'DELETE', 'RJ279');
INSERT INTO "ProdNac2021".logbd VALUES (2313, '2021-04-13', 'postgres', 'DELETE', 'RJ28');
INSERT INTO "ProdNac2021".logbd VALUES (2314, '2021-04-13', 'postgres', 'DELETE', 'RJ280');
INSERT INTO "ProdNac2021".logbd VALUES (2315, '2021-04-13', 'postgres', 'DELETE', 'RJ281');
INSERT INTO "ProdNac2021".logbd VALUES (2316, '2021-04-13', 'postgres', 'DELETE', 'RJ282');
INSERT INTO "ProdNac2021".logbd VALUES (2317, '2021-04-13', 'postgres', 'DELETE', 'RJ283');
INSERT INTO "ProdNac2021".logbd VALUES (2318, '2021-04-13', 'postgres', 'DELETE', 'RJ284');
INSERT INTO "ProdNac2021".logbd VALUES (2319, '2021-04-13', 'postgres', 'DELETE', 'RJ285');
INSERT INTO "ProdNac2021".logbd VALUES (2320, '2021-04-13', 'postgres', 'DELETE', 'RJ286');
INSERT INTO "ProdNac2021".logbd VALUES (2321, '2021-04-13', 'postgres', 'DELETE', 'RJ287');
INSERT INTO "ProdNac2021".logbd VALUES (2322, '2021-04-13', 'postgres', 'DELETE', 'RJ288');
INSERT INTO "ProdNac2021".logbd VALUES (2323, '2021-04-13', 'postgres', 'DELETE', 'RJ289');
INSERT INTO "ProdNac2021".logbd VALUES (2324, '2021-04-13', 'postgres', 'DELETE', 'RJ29');
INSERT INTO "ProdNac2021".logbd VALUES (2325, '2021-04-13', 'postgres', 'DELETE', 'RJ290');
INSERT INTO "ProdNac2021".logbd VALUES (2326, '2021-04-13', 'postgres', 'DELETE', 'RJ291');
INSERT INTO "ProdNac2021".logbd VALUES (2327, '2021-04-13', 'postgres', 'DELETE', 'RJ292');
INSERT INTO "ProdNac2021".logbd VALUES (2328, '2021-04-13', 'postgres', 'DELETE', 'RJ293');
INSERT INTO "ProdNac2021".logbd VALUES (2329, '2021-04-13', 'postgres', 'DELETE', 'RJ294');
INSERT INTO "ProdNac2021".logbd VALUES (2330, '2021-04-13', 'postgres', 'DELETE', 'RJ295');
INSERT INTO "ProdNac2021".logbd VALUES (2331, '2021-04-13', 'postgres', 'DELETE', 'RJ297');
INSERT INTO "ProdNac2021".logbd VALUES (2332, '2021-04-13', 'postgres', 'DELETE', 'RJ298');
INSERT INTO "ProdNac2021".logbd VALUES (2333, '2021-04-13', 'postgres', 'DELETE', 'RJ299');
INSERT INTO "ProdNac2021".logbd VALUES (2334, '2021-04-13', 'postgres', 'DELETE', 'RJ30');
INSERT INTO "ProdNac2021".logbd VALUES (2335, '2021-04-13', 'postgres', 'DELETE', 'RJ300');
INSERT INTO "ProdNac2021".logbd VALUES (2336, '2021-04-13', 'postgres', 'DELETE', 'RJ301');
INSERT INTO "ProdNac2021".logbd VALUES (2337, '2021-04-13', 'postgres', 'DELETE', 'RJ302');
INSERT INTO "ProdNac2021".logbd VALUES (2338, '2021-04-13', 'postgres', 'DELETE', 'RJ303');
INSERT INTO "ProdNac2021".logbd VALUES (2339, '2021-04-13', 'postgres', 'DELETE', 'RJ304');
INSERT INTO "ProdNac2021".logbd VALUES (2340, '2021-04-13', 'postgres', 'DELETE', 'RJ305');
INSERT INTO "ProdNac2021".logbd VALUES (2341, '2021-04-13', 'postgres', 'DELETE', 'RJ306');
INSERT INTO "ProdNac2021".logbd VALUES (2342, '2021-04-13', 'postgres', 'DELETE', 'RJ307');
INSERT INTO "ProdNac2021".logbd VALUES (2343, '2021-04-13', 'postgres', 'DELETE', 'RJ308');
INSERT INTO "ProdNac2021".logbd VALUES (2344, '2021-04-13', 'postgres', 'DELETE', 'RJ309');
INSERT INTO "ProdNac2021".logbd VALUES (2345, '2021-04-13', 'postgres', 'DELETE', 'RJ31');
INSERT INTO "ProdNac2021".logbd VALUES (2346, '2021-04-13', 'postgres', 'DELETE', 'RJ310');
INSERT INTO "ProdNac2021".logbd VALUES (2347, '2021-04-13', 'postgres', 'DELETE', 'RJ311');
INSERT INTO "ProdNac2021".logbd VALUES (2348, '2021-04-13', 'postgres', 'DELETE', 'RJ312');
INSERT INTO "ProdNac2021".logbd VALUES (2349, '2021-04-13', 'postgres', 'DELETE', 'RJ313');
INSERT INTO "ProdNac2021".logbd VALUES (2350, '2021-04-13', 'postgres', 'DELETE', 'RJ314');
INSERT INTO "ProdNac2021".logbd VALUES (2351, '2021-04-13', 'postgres', 'DELETE', 'RJ315');
INSERT INTO "ProdNac2021".logbd VALUES (2352, '2021-04-13', 'postgres', 'DELETE', 'RJ316');
INSERT INTO "ProdNac2021".logbd VALUES (2353, '2021-04-13', 'postgres', 'DELETE', 'RJ317');
INSERT INTO "ProdNac2021".logbd VALUES (2354, '2021-04-13', 'postgres', 'DELETE', 'RJ318');
INSERT INTO "ProdNac2021".logbd VALUES (2355, '2021-04-13', 'postgres', 'DELETE', 'RJ319');
INSERT INTO "ProdNac2021".logbd VALUES (2356, '2021-04-13', 'postgres', 'DELETE', 'RJ32');
INSERT INTO "ProdNac2021".logbd VALUES (2357, '2021-04-13', 'postgres', 'DELETE', 'RJ320');
INSERT INTO "ProdNac2021".logbd VALUES (2358, '2021-04-13', 'postgres', 'DELETE', 'RJ321');
INSERT INTO "ProdNac2021".logbd VALUES (2359, '2021-04-13', 'postgres', 'DELETE', 'RJ322');
INSERT INTO "ProdNac2021".logbd VALUES (2360, '2021-04-13', 'postgres', 'DELETE', 'RJ323');
INSERT INTO "ProdNac2021".logbd VALUES (2361, '2021-04-13', 'postgres', 'DELETE', 'RJ324');
INSERT INTO "ProdNac2021".logbd VALUES (2362, '2021-04-13', 'postgres', 'DELETE', 'RJ325');
INSERT INTO "ProdNac2021".logbd VALUES (2363, '2021-04-13', 'postgres', 'DELETE', 'RJ326');
INSERT INTO "ProdNac2021".logbd VALUES (2364, '2021-04-13', 'postgres', 'DELETE', 'RJ327');
INSERT INTO "ProdNac2021".logbd VALUES (2365, '2021-04-13', 'postgres', 'DELETE', 'RJ328');
INSERT INTO "ProdNac2021".logbd VALUES (2366, '2021-04-13', 'postgres', 'DELETE', 'RJ329');
INSERT INTO "ProdNac2021".logbd VALUES (2367, '2021-04-13', 'postgres', 'DELETE', 'RJ33');
INSERT INTO "ProdNac2021".logbd VALUES (2368, '2021-04-13', 'postgres', 'DELETE', 'RJ330');
INSERT INTO "ProdNac2021".logbd VALUES (2369, '2021-04-13', 'postgres', 'DELETE', 'RJ331');
INSERT INTO "ProdNac2021".logbd VALUES (2370, '2021-04-13', 'postgres', 'DELETE', 'RJ332');
INSERT INTO "ProdNac2021".logbd VALUES (2371, '2021-04-13', 'postgres', 'DELETE', 'RJ333');
INSERT INTO "ProdNac2021".logbd VALUES (2372, '2021-04-13', 'postgres', 'DELETE', 'RJ334');
INSERT INTO "ProdNac2021".logbd VALUES (2373, '2021-04-13', 'postgres', 'DELETE', 'RJ335');
INSERT INTO "ProdNac2021".logbd VALUES (2374, '2021-04-13', 'postgres', 'DELETE', 'RJ336');
INSERT INTO "ProdNac2021".logbd VALUES (2375, '2021-04-13', 'postgres', 'DELETE', 'RJ337');
INSERT INTO "ProdNac2021".logbd VALUES (2376, '2021-04-13', 'postgres', 'DELETE', 'RJ338');
INSERT INTO "ProdNac2021".logbd VALUES (2377, '2021-04-13', 'postgres', 'DELETE', 'RJ339');
INSERT INTO "ProdNac2021".logbd VALUES (2378, '2021-04-13', 'postgres', 'DELETE', 'RJ34');
INSERT INTO "ProdNac2021".logbd VALUES (2379, '2021-04-13', 'postgres', 'DELETE', 'RJ340');
INSERT INTO "ProdNac2021".logbd VALUES (2380, '2021-04-13', 'postgres', 'DELETE', 'RJ341');
INSERT INTO "ProdNac2021".logbd VALUES (2381, '2021-04-13', 'postgres', 'DELETE', 'RJ342');
INSERT INTO "ProdNac2021".logbd VALUES (2382, '2021-04-13', 'postgres', 'DELETE', 'RJ343');
INSERT INTO "ProdNac2021".logbd VALUES (2383, '2021-04-13', 'postgres', 'DELETE', 'RJ344');
INSERT INTO "ProdNac2021".logbd VALUES (2384, '2021-04-13', 'postgres', 'DELETE', 'RJ345');
INSERT INTO "ProdNac2021".logbd VALUES (2385, '2021-04-13', 'postgres', 'DELETE', 'RJ346');
INSERT INTO "ProdNac2021".logbd VALUES (2386, '2021-04-13', 'postgres', 'DELETE', 'RJ347');
INSERT INTO "ProdNac2021".logbd VALUES (2387, '2021-04-13', 'postgres', 'DELETE', 'RJ348');
INSERT INTO "ProdNac2021".logbd VALUES (2388, '2021-04-13', 'postgres', 'DELETE', 'RJ349');
INSERT INTO "ProdNac2021".logbd VALUES (2389, '2021-04-13', 'postgres', 'DELETE', 'RJ35');
INSERT INTO "ProdNac2021".logbd VALUES (2390, '2021-04-13', 'postgres', 'DELETE', 'RJ350');
INSERT INTO "ProdNac2021".logbd VALUES (2391, '2021-04-13', 'postgres', 'DELETE', 'RJ351');
INSERT INTO "ProdNac2021".logbd VALUES (2392, '2021-04-13', 'postgres', 'DELETE', 'RJ352');
INSERT INTO "ProdNac2021".logbd VALUES (2393, '2021-04-13', 'postgres', 'DELETE', 'RJ353');
INSERT INTO "ProdNac2021".logbd VALUES (2394, '2021-04-13', 'postgres', 'DELETE', 'RJ354');
INSERT INTO "ProdNac2021".logbd VALUES (2395, '2021-04-13', 'postgres', 'DELETE', 'RJ355');
INSERT INTO "ProdNac2021".logbd VALUES (2396, '2021-04-13', 'postgres', 'DELETE', 'RJ356');
INSERT INTO "ProdNac2021".logbd VALUES (2397, '2021-04-13', 'postgres', 'DELETE', 'RJ357');
INSERT INTO "ProdNac2021".logbd VALUES (2398, '2021-04-13', 'postgres', 'DELETE', 'RJ358');
INSERT INTO "ProdNac2021".logbd VALUES (2399, '2021-04-13', 'postgres', 'DELETE', 'RJ359');
INSERT INTO "ProdNac2021".logbd VALUES (2400, '2021-04-13', 'postgres', 'DELETE', 'RJ36');
INSERT INTO "ProdNac2021".logbd VALUES (2401, '2021-04-13', 'postgres', 'DELETE', 'RJ360');
INSERT INTO "ProdNac2021".logbd VALUES (2402, '2021-04-13', 'postgres', 'DELETE', 'RJ361');
INSERT INTO "ProdNac2021".logbd VALUES (2403, '2021-04-13', 'postgres', 'DELETE', 'RJ362');
INSERT INTO "ProdNac2021".logbd VALUES (2404, '2021-04-13', 'postgres', 'DELETE', 'RJ363');
INSERT INTO "ProdNac2021".logbd VALUES (2405, '2021-04-13', 'postgres', 'DELETE', 'RJ364');
INSERT INTO "ProdNac2021".logbd VALUES (2406, '2021-04-13', 'postgres', 'DELETE', 'RJ365');
INSERT INTO "ProdNac2021".logbd VALUES (2407, '2021-04-13', 'postgres', 'DELETE', 'RJ366');
INSERT INTO "ProdNac2021".logbd VALUES (2408, '2021-04-13', 'postgres', 'DELETE', 'RJ367');
INSERT INTO "ProdNac2021".logbd VALUES (2409, '2021-04-13', 'postgres', 'DELETE', 'RJ368');
INSERT INTO "ProdNac2021".logbd VALUES (2410, '2021-04-13', 'postgres', 'DELETE', 'RJ369');
INSERT INTO "ProdNac2021".logbd VALUES (2411, '2021-04-13', 'postgres', 'DELETE', 'RJ37');
INSERT INTO "ProdNac2021".logbd VALUES (2412, '2021-04-13', 'postgres', 'DELETE', 'RJ370');
INSERT INTO "ProdNac2021".logbd VALUES (2413, '2021-04-13', 'postgres', 'DELETE', 'RJ371');
INSERT INTO "ProdNac2021".logbd VALUES (2414, '2021-04-13', 'postgres', 'DELETE', 'RJ372');
INSERT INTO "ProdNac2021".logbd VALUES (2415, '2021-04-13', 'postgres', 'DELETE', 'RJ373');
INSERT INTO "ProdNac2021".logbd VALUES (2416, '2021-04-13', 'postgres', 'DELETE', 'RJ374');
INSERT INTO "ProdNac2021".logbd VALUES (2417, '2021-04-13', 'postgres', 'DELETE', 'RJ375');
INSERT INTO "ProdNac2021".logbd VALUES (2418, '2021-04-13', 'postgres', 'DELETE', 'RJ376');
INSERT INTO "ProdNac2021".logbd VALUES (2419, '2021-04-13', 'postgres', 'DELETE', 'RJ377');
INSERT INTO "ProdNac2021".logbd VALUES (2420, '2021-04-13', 'postgres', 'DELETE', 'RJ378');
INSERT INTO "ProdNac2021".logbd VALUES (2421, '2021-04-13', 'postgres', 'DELETE', 'RJ379');
INSERT INTO "ProdNac2021".logbd VALUES (2422, '2021-04-13', 'postgres', 'DELETE', 'RJ38');
INSERT INTO "ProdNac2021".logbd VALUES (2423, '2021-04-13', 'postgres', 'DELETE', 'RJ380');
INSERT INTO "ProdNac2021".logbd VALUES (2424, '2021-04-13', 'postgres', 'DELETE', 'RJ381');
INSERT INTO "ProdNac2021".logbd VALUES (2425, '2021-04-13', 'postgres', 'DELETE', 'RJ382');
INSERT INTO "ProdNac2021".logbd VALUES (2426, '2021-04-13', 'postgres', 'DELETE', 'RJ383');
INSERT INTO "ProdNac2021".logbd VALUES (2427, '2021-04-13', 'postgres', 'DELETE', 'RJ384');
INSERT INTO "ProdNac2021".logbd VALUES (2428, '2021-04-13', 'postgres', 'DELETE', 'RJ385');
INSERT INTO "ProdNac2021".logbd VALUES (2429, '2021-04-13', 'postgres', 'DELETE', 'RJ386');
INSERT INTO "ProdNac2021".logbd VALUES (2430, '2021-04-13', 'postgres', 'DELETE', 'RJ387');
INSERT INTO "ProdNac2021".logbd VALUES (2431, '2021-04-13', 'postgres', 'DELETE', 'RJ388');
INSERT INTO "ProdNac2021".logbd VALUES (2432, '2021-04-13', 'postgres', 'DELETE', 'RJ389');
INSERT INTO "ProdNac2021".logbd VALUES (2433, '2021-04-13', 'postgres', 'DELETE', 'RJ39');
INSERT INTO "ProdNac2021".logbd VALUES (2434, '2021-04-13', 'postgres', 'DELETE', 'RJ390');
INSERT INTO "ProdNac2021".logbd VALUES (2435, '2021-04-13', 'postgres', 'DELETE', 'RJ391');
INSERT INTO "ProdNac2021".logbd VALUES (2436, '2021-04-13', 'postgres', 'DELETE', 'RJ392');
INSERT INTO "ProdNac2021".logbd VALUES (2437, '2021-04-13', 'postgres', 'DELETE', 'RJ393');
INSERT INTO "ProdNac2021".logbd VALUES (2438, '2021-04-13', 'postgres', 'DELETE', 'RJ394');
INSERT INTO "ProdNac2021".logbd VALUES (2439, '2021-04-13', 'postgres', 'DELETE', 'RJ395');
INSERT INTO "ProdNac2021".logbd VALUES (2440, '2021-04-13', 'postgres', 'DELETE', 'RJ396');
INSERT INTO "ProdNac2021".logbd VALUES (2441, '2021-04-13', 'postgres', 'DELETE', 'RJ397');
INSERT INTO "ProdNac2021".logbd VALUES (2442, '2021-04-13', 'postgres', 'DELETE', 'RJ398');
INSERT INTO "ProdNac2021".logbd VALUES (2443, '2021-04-13', 'postgres', 'DELETE', 'RJ399');
INSERT INTO "ProdNac2021".logbd VALUES (2444, '2021-04-13', 'postgres', 'DELETE', 'RJ40');
INSERT INTO "ProdNac2021".logbd VALUES (2445, '2021-04-13', 'postgres', 'DELETE', 'RJ400');
INSERT INTO "ProdNac2021".logbd VALUES (2446, '2021-04-13', 'postgres', 'DELETE', 'RJ401');
INSERT INTO "ProdNac2021".logbd VALUES (2447, '2021-04-13', 'postgres', 'DELETE', 'RJ402');
INSERT INTO "ProdNac2021".logbd VALUES (2448, '2021-04-13', 'postgres', 'DELETE', 'RJ403');
INSERT INTO "ProdNac2021".logbd VALUES (2449, '2021-04-13', 'postgres', 'DELETE', 'RJ404');
INSERT INTO "ProdNac2021".logbd VALUES (2450, '2021-04-13', 'postgres', 'DELETE', 'RJ405');
INSERT INTO "ProdNac2021".logbd VALUES (2451, '2021-04-13', 'postgres', 'DELETE', 'RJ406');
INSERT INTO "ProdNac2021".logbd VALUES (2452, '2021-04-13', 'postgres', 'DELETE', 'RJ407');
INSERT INTO "ProdNac2021".logbd VALUES (2453, '2021-04-13', 'postgres', 'DELETE', 'RJ408');
INSERT INTO "ProdNac2021".logbd VALUES (2454, '2021-04-13', 'postgres', 'DELETE', 'RJ409');
INSERT INTO "ProdNac2021".logbd VALUES (2455, '2021-04-13', 'postgres', 'DELETE', 'RJ41');
INSERT INTO "ProdNac2021".logbd VALUES (2456, '2021-04-13', 'postgres', 'DELETE', 'RJ410');
INSERT INTO "ProdNac2021".logbd VALUES (2457, '2021-04-13', 'postgres', 'DELETE', 'RJ411');
INSERT INTO "ProdNac2021".logbd VALUES (2458, '2021-04-13', 'postgres', 'DELETE', 'RJ412');
INSERT INTO "ProdNac2021".logbd VALUES (2459, '2021-04-13', 'postgres', 'DELETE', 'RJ413');
INSERT INTO "ProdNac2021".logbd VALUES (2460, '2021-04-13', 'postgres', 'DELETE', 'RJ414');
INSERT INTO "ProdNac2021".logbd VALUES (2461, '2021-04-13', 'postgres', 'DELETE', 'RJ415');
INSERT INTO "ProdNac2021".logbd VALUES (2462, '2021-04-13', 'postgres', 'DELETE', 'RJ416');
INSERT INTO "ProdNac2021".logbd VALUES (2463, '2021-04-13', 'postgres', 'DELETE', 'RJ417');
INSERT INTO "ProdNac2021".logbd VALUES (2464, '2021-04-13', 'postgres', 'DELETE', 'RJ418');
INSERT INTO "ProdNac2021".logbd VALUES (2465, '2021-04-13', 'postgres', 'DELETE', 'RJ419');
INSERT INTO "ProdNac2021".logbd VALUES (2466, '2021-04-13', 'postgres', 'DELETE', 'RJ42');
INSERT INTO "ProdNac2021".logbd VALUES (2467, '2021-04-13', 'postgres', 'DELETE', 'RJ420');
INSERT INTO "ProdNac2021".logbd VALUES (2468, '2021-04-13', 'postgres', 'DELETE', 'RJ421');
INSERT INTO "ProdNac2021".logbd VALUES (2469, '2021-04-13', 'postgres', 'DELETE', 'RJ422');
INSERT INTO "ProdNac2021".logbd VALUES (2470, '2021-04-13', 'postgres', 'DELETE', 'RJ423');
INSERT INTO "ProdNac2021".logbd VALUES (2471, '2021-04-13', 'postgres', 'DELETE', 'RJ424');
INSERT INTO "ProdNac2021".logbd VALUES (2472, '2021-04-13', 'postgres', 'DELETE', 'RJ425');
INSERT INTO "ProdNac2021".logbd VALUES (2473, '2021-04-13', 'postgres', 'DELETE', 'RJ426');
INSERT INTO "ProdNac2021".logbd VALUES (2474, '2021-04-13', 'postgres', 'DELETE', 'RJ427');
INSERT INTO "ProdNac2021".logbd VALUES (2475, '2021-04-13', 'postgres', 'DELETE', 'RJ428');
INSERT INTO "ProdNac2021".logbd VALUES (2476, '2021-04-13', 'postgres', 'DELETE', 'RJ429');
INSERT INTO "ProdNac2021".logbd VALUES (2477, '2021-04-13', 'postgres', 'DELETE', 'RJ43');
INSERT INTO "ProdNac2021".logbd VALUES (2478, '2021-04-13', 'postgres', 'DELETE', 'RJ430');
INSERT INTO "ProdNac2021".logbd VALUES (2479, '2021-04-13', 'postgres', 'DELETE', 'RJ431');
INSERT INTO "ProdNac2021".logbd VALUES (2480, '2021-04-13', 'postgres', 'DELETE', 'RJ432');
INSERT INTO "ProdNac2021".logbd VALUES (2481, '2021-04-13', 'postgres', 'DELETE', 'RJ4328');
INSERT INTO "ProdNac2021".logbd VALUES (2482, '2021-04-13', 'postgres', 'DELETE', 'RJ4329');
INSERT INTO "ProdNac2021".logbd VALUES (2483, '2021-04-13', 'postgres', 'DELETE', 'RJ433');
INSERT INTO "ProdNac2021".logbd VALUES (2484, '2021-04-13', 'postgres', 'DELETE', 'RJ4330');
INSERT INTO "ProdNac2021".logbd VALUES (2485, '2021-04-13', 'postgres', 'DELETE', 'RJ4331');
INSERT INTO "ProdNac2021".logbd VALUES (2486, '2021-04-13', 'postgres', 'DELETE', 'RJ4332');
INSERT INTO "ProdNac2021".logbd VALUES (2487, '2021-04-13', 'postgres', 'DELETE', 'RJ4333');
INSERT INTO "ProdNac2021".logbd VALUES (2488, '2021-04-13', 'postgres', 'DELETE', 'RJ4334');
INSERT INTO "ProdNac2021".logbd VALUES (2489, '2021-04-13', 'postgres', 'DELETE', 'RJ4335');
INSERT INTO "ProdNac2021".logbd VALUES (2490, '2021-04-13', 'postgres', 'DELETE', 'RJ4336');
INSERT INTO "ProdNac2021".logbd VALUES (2491, '2021-04-13', 'postgres', 'DELETE', 'RJ4337');
INSERT INTO "ProdNac2021".logbd VALUES (2492, '2021-04-13', 'postgres', 'DELETE', 'RJ4338');
INSERT INTO "ProdNac2021".logbd VALUES (2493, '2021-04-13', 'postgres', 'DELETE', 'RJ4339');
INSERT INTO "ProdNac2021".logbd VALUES (2494, '2021-04-13', 'postgres', 'DELETE', 'RJ434');
INSERT INTO "ProdNac2021".logbd VALUES (2495, '2021-04-13', 'postgres', 'DELETE', 'RJ4340');
INSERT INTO "ProdNac2021".logbd VALUES (2496, '2021-04-13', 'postgres', 'DELETE', 'RJ4341');
INSERT INTO "ProdNac2021".logbd VALUES (2497, '2021-04-13', 'postgres', 'DELETE', 'RJ4342');
INSERT INTO "ProdNac2021".logbd VALUES (2498, '2021-04-13', 'postgres', 'DELETE', 'RJ4343');
INSERT INTO "ProdNac2021".logbd VALUES (2499, '2021-04-13', 'postgres', 'DELETE', 'RJ4344');
INSERT INTO "ProdNac2021".logbd VALUES (2500, '2021-04-13', 'postgres', 'DELETE', 'RJ4345');
INSERT INTO "ProdNac2021".logbd VALUES (2501, '2021-04-13', 'postgres', 'DELETE', 'RJ4346');
INSERT INTO "ProdNac2021".logbd VALUES (2502, '2021-04-13', 'postgres', 'DELETE', 'RJ4347');
INSERT INTO "ProdNac2021".logbd VALUES (2503, '2021-04-13', 'postgres', 'DELETE', 'RJ4348');
INSERT INTO "ProdNac2021".logbd VALUES (2504, '2021-04-13', 'postgres', 'DELETE', 'RJ4349');
INSERT INTO "ProdNac2021".logbd VALUES (2505, '2021-04-13', 'postgres', 'DELETE', 'RJ435');
INSERT INTO "ProdNac2021".logbd VALUES (2506, '2021-04-13', 'postgres', 'DELETE', 'RJ4350');
INSERT INTO "ProdNac2021".logbd VALUES (2507, '2021-04-13', 'postgres', 'DELETE', 'RJ4351');
INSERT INTO "ProdNac2021".logbd VALUES (2508, '2021-04-13', 'postgres', 'DELETE', 'RJ4352');
INSERT INTO "ProdNac2021".logbd VALUES (2509, '2021-04-13', 'postgres', 'DELETE', 'RJ4353');
INSERT INTO "ProdNac2021".logbd VALUES (2510, '2021-04-13', 'postgres', 'DELETE', 'RJ4354');
INSERT INTO "ProdNac2021".logbd VALUES (2511, '2021-04-13', 'postgres', 'DELETE', 'RJ4355');
INSERT INTO "ProdNac2021".logbd VALUES (2512, '2021-04-13', 'postgres', 'DELETE', 'RJ4356');
INSERT INTO "ProdNac2021".logbd VALUES (2513, '2021-04-13', 'postgres', 'DELETE', 'RJ4357');
INSERT INTO "ProdNac2021".logbd VALUES (2514, '2021-04-13', 'postgres', 'DELETE', 'RJ4358');
INSERT INTO "ProdNac2021".logbd VALUES (2515, '2021-04-13', 'postgres', 'DELETE', 'RJ4359');
INSERT INTO "ProdNac2021".logbd VALUES (2516, '2021-04-13', 'postgres', 'DELETE', 'RJ436');
INSERT INTO "ProdNac2021".logbd VALUES (2517, '2021-04-13', 'postgres', 'DELETE', 'RJ4360');
INSERT INTO "ProdNac2021".logbd VALUES (2518, '2021-04-13', 'postgres', 'DELETE', 'RJ4361');
INSERT INTO "ProdNac2021".logbd VALUES (2519, '2021-04-13', 'postgres', 'DELETE', 'RJ4362');
INSERT INTO "ProdNac2021".logbd VALUES (2520, '2021-04-13', 'postgres', 'DELETE', 'RJ4363');
INSERT INTO "ProdNac2021".logbd VALUES (2521, '2021-04-13', 'postgres', 'DELETE', 'RJ4364');
INSERT INTO "ProdNac2021".logbd VALUES (2522, '2021-04-13', 'postgres', 'DELETE', 'RJ4365');
INSERT INTO "ProdNac2021".logbd VALUES (2523, '2021-04-13', 'postgres', 'DELETE', 'RJ4366');
INSERT INTO "ProdNac2021".logbd VALUES (2524, '2021-04-13', 'postgres', 'DELETE', 'RJ4367');
INSERT INTO "ProdNac2021".logbd VALUES (2525, '2021-04-13', 'postgres', 'DELETE', 'RJ4368');
INSERT INTO "ProdNac2021".logbd VALUES (2526, '2021-04-13', 'postgres', 'DELETE', 'RJ4369');
INSERT INTO "ProdNac2021".logbd VALUES (2527, '2021-04-13', 'postgres', 'DELETE', 'RJ437');
INSERT INTO "ProdNac2021".logbd VALUES (2528, '2021-04-13', 'postgres', 'DELETE', 'RJ4370');
INSERT INTO "ProdNac2021".logbd VALUES (2529, '2021-04-13', 'postgres', 'DELETE', 'RJ4371');
INSERT INTO "ProdNac2021".logbd VALUES (2530, '2021-04-13', 'postgres', 'DELETE', 'RJ4372');
INSERT INTO "ProdNac2021".logbd VALUES (2531, '2021-04-13', 'postgres', 'DELETE', 'RJ4373');
INSERT INTO "ProdNac2021".logbd VALUES (2532, '2021-04-13', 'postgres', 'DELETE', 'RJ4374');
INSERT INTO "ProdNac2021".logbd VALUES (2533, '2021-04-13', 'postgres', 'DELETE', 'RJ4375');
INSERT INTO "ProdNac2021".logbd VALUES (2534, '2021-04-13', 'postgres', 'DELETE', 'RJ4376');
INSERT INTO "ProdNac2021".logbd VALUES (2535, '2021-04-13', 'postgres', 'DELETE', 'RJ4377');
INSERT INTO "ProdNac2021".logbd VALUES (2536, '2021-04-13', 'postgres', 'DELETE', 'RJ4378');
INSERT INTO "ProdNac2021".logbd VALUES (2537, '2021-04-13', 'postgres', 'DELETE', 'RJ4379');
INSERT INTO "ProdNac2021".logbd VALUES (2538, '2021-04-13', 'postgres', 'DELETE', 'RJ438');
INSERT INTO "ProdNac2021".logbd VALUES (2539, '2021-04-13', 'postgres', 'DELETE', 'RJ4380');
INSERT INTO "ProdNac2021".logbd VALUES (2540, '2021-04-13', 'postgres', 'DELETE', 'RJ4381');
INSERT INTO "ProdNac2021".logbd VALUES (2541, '2021-04-13', 'postgres', 'DELETE', 'RJ4382');
INSERT INTO "ProdNac2021".logbd VALUES (2542, '2021-04-13', 'postgres', 'DELETE', 'RJ4383');
INSERT INTO "ProdNac2021".logbd VALUES (2543, '2021-04-13', 'postgres', 'DELETE', 'RJ4384');
INSERT INTO "ProdNac2021".logbd VALUES (2544, '2021-04-13', 'postgres', 'DELETE', 'RJ4385');
INSERT INTO "ProdNac2021".logbd VALUES (2545, '2021-04-13', 'postgres', 'DELETE', 'RJ4386');
INSERT INTO "ProdNac2021".logbd VALUES (2546, '2021-04-13', 'postgres', 'DELETE', 'RJ4387');
INSERT INTO "ProdNac2021".logbd VALUES (2547, '2021-04-13', 'postgres', 'DELETE', 'RJ4388');
INSERT INTO "ProdNac2021".logbd VALUES (2548, '2021-04-13', 'postgres', 'DELETE', 'RJ4389');
INSERT INTO "ProdNac2021".logbd VALUES (2549, '2021-04-13', 'postgres', 'DELETE', 'RJ439');
INSERT INTO "ProdNac2021".logbd VALUES (2550, '2021-04-13', 'postgres', 'DELETE', 'RJ4390');
INSERT INTO "ProdNac2021".logbd VALUES (2551, '2021-04-13', 'postgres', 'DELETE', 'RJ4391');
INSERT INTO "ProdNac2021".logbd VALUES (2552, '2021-04-13', 'postgres', 'DELETE', 'RJ4392');
INSERT INTO "ProdNac2021".logbd VALUES (2553, '2021-04-13', 'postgres', 'DELETE', 'RJ4393');
INSERT INTO "ProdNac2021".logbd VALUES (2554, '2021-04-13', 'postgres', 'DELETE', 'RJ4394');
INSERT INTO "ProdNac2021".logbd VALUES (2555, '2021-04-13', 'postgres', 'DELETE', 'RJ4395');
INSERT INTO "ProdNac2021".logbd VALUES (2556, '2021-04-13', 'postgres', 'DELETE', 'RJ4396');
INSERT INTO "ProdNac2021".logbd VALUES (2557, '2021-04-13', 'postgres', 'DELETE', 'RJ4397');
INSERT INTO "ProdNac2021".logbd VALUES (2558, '2021-04-13', 'postgres', 'DELETE', 'RJ4398');
INSERT INTO "ProdNac2021".logbd VALUES (2559, '2021-04-13', 'postgres', 'DELETE', 'RJ4399');
INSERT INTO "ProdNac2021".logbd VALUES (2560, '2021-04-13', 'postgres', 'DELETE', 'RJ44');
INSERT INTO "ProdNac2021".logbd VALUES (2561, '2021-04-13', 'postgres', 'DELETE', 'RJ440');
INSERT INTO "ProdNac2021".logbd VALUES (2562, '2021-04-13', 'postgres', 'DELETE', 'RJ4400');
INSERT INTO "ProdNac2021".logbd VALUES (2563, '2021-04-13', 'postgres', 'DELETE', 'RJ4401');
INSERT INTO "ProdNac2021".logbd VALUES (2564, '2021-04-13', 'postgres', 'DELETE', 'RJ4402');
INSERT INTO "ProdNac2021".logbd VALUES (2565, '2021-04-13', 'postgres', 'DELETE', 'RJ4403');
INSERT INTO "ProdNac2021".logbd VALUES (2566, '2021-04-13', 'postgres', 'DELETE', 'RJ4404');
INSERT INTO "ProdNac2021".logbd VALUES (2567, '2021-04-13', 'postgres', 'DELETE', 'RJ4405');
INSERT INTO "ProdNac2021".logbd VALUES (2568, '2021-04-13', 'postgres', 'DELETE', 'RJ4406');
INSERT INTO "ProdNac2021".logbd VALUES (2569, '2021-04-13', 'postgres', 'DELETE', 'RJ4407');
INSERT INTO "ProdNac2021".logbd VALUES (2570, '2021-04-13', 'postgres', 'DELETE', 'RJ4408');
INSERT INTO "ProdNac2021".logbd VALUES (2571, '2021-04-13', 'postgres', 'DELETE', 'RJ4409');
INSERT INTO "ProdNac2021".logbd VALUES (2572, '2021-04-13', 'postgres', 'DELETE', 'RJ441');
INSERT INTO "ProdNac2021".logbd VALUES (2573, '2021-04-13', 'postgres', 'DELETE', 'RJ4410');
INSERT INTO "ProdNac2021".logbd VALUES (2574, '2021-04-13', 'postgres', 'DELETE', 'RJ4411');
INSERT INTO "ProdNac2021".logbd VALUES (2575, '2021-04-13', 'postgres', 'DELETE', 'RJ4412');
INSERT INTO "ProdNac2021".logbd VALUES (2576, '2021-04-13', 'postgres', 'DELETE', 'RJ4413');
INSERT INTO "ProdNac2021".logbd VALUES (2577, '2021-04-13', 'postgres', 'DELETE', 'RJ4414');
INSERT INTO "ProdNac2021".logbd VALUES (2578, '2021-04-13', 'postgres', 'DELETE', 'RJ4415');
INSERT INTO "ProdNac2021".logbd VALUES (2579, '2021-04-13', 'postgres', 'DELETE', 'RJ4416');
INSERT INTO "ProdNac2021".logbd VALUES (2580, '2021-04-13', 'postgres', 'DELETE', 'RJ4417');
INSERT INTO "ProdNac2021".logbd VALUES (2581, '2021-04-13', 'postgres', 'DELETE', 'RJ4418');
INSERT INTO "ProdNac2021".logbd VALUES (2582, '2021-04-13', 'postgres', 'DELETE', 'RJ4419');
INSERT INTO "ProdNac2021".logbd VALUES (2583, '2021-04-13', 'postgres', 'DELETE', 'RJ442');
INSERT INTO "ProdNac2021".logbd VALUES (2584, '2021-04-13', 'postgres', 'DELETE', 'RJ4420');
INSERT INTO "ProdNac2021".logbd VALUES (2585, '2021-04-13', 'postgres', 'DELETE', 'RJ4421');
INSERT INTO "ProdNac2021".logbd VALUES (2586, '2021-04-13', 'postgres', 'DELETE', 'RJ4422');
INSERT INTO "ProdNac2021".logbd VALUES (2587, '2021-04-13', 'postgres', 'DELETE', 'RJ4423');
INSERT INTO "ProdNac2021".logbd VALUES (2588, '2021-04-13', 'postgres', 'DELETE', 'RJ4424');
INSERT INTO "ProdNac2021".logbd VALUES (2589, '2021-04-13', 'postgres', 'DELETE', 'RJ4425');
INSERT INTO "ProdNac2021".logbd VALUES (2590, '2021-04-13', 'postgres', 'DELETE', 'RJ4426');
INSERT INTO "ProdNac2021".logbd VALUES (2591, '2021-04-13', 'postgres', 'DELETE', 'RJ4427');
INSERT INTO "ProdNac2021".logbd VALUES (2592, '2021-04-13', 'postgres', 'DELETE', 'RJ4428');
INSERT INTO "ProdNac2021".logbd VALUES (2593, '2021-04-13', 'postgres', 'DELETE', 'RJ4429');
INSERT INTO "ProdNac2021".logbd VALUES (2594, '2021-04-13', 'postgres', 'DELETE', 'RJ443');
INSERT INTO "ProdNac2021".logbd VALUES (2595, '2021-04-13', 'postgres', 'DELETE', 'RJ4430');
INSERT INTO "ProdNac2021".logbd VALUES (2596, '2021-04-13', 'postgres', 'DELETE', 'RJ4431');
INSERT INTO "ProdNac2021".logbd VALUES (2597, '2021-04-13', 'postgres', 'DELETE', 'RJ4432');
INSERT INTO "ProdNac2021".logbd VALUES (2598, '2021-04-13', 'postgres', 'DELETE', 'RJ4433');
INSERT INTO "ProdNac2021".logbd VALUES (2599, '2021-04-13', 'postgres', 'DELETE', 'RJ4434');
INSERT INTO "ProdNac2021".logbd VALUES (2600, '2021-04-13', 'postgres', 'DELETE', 'RJ4435');
INSERT INTO "ProdNac2021".logbd VALUES (2601, '2021-04-13', 'postgres', 'DELETE', 'RJ4436');
INSERT INTO "ProdNac2021".logbd VALUES (2602, '2021-04-13', 'postgres', 'DELETE', 'RJ4437');
INSERT INTO "ProdNac2021".logbd VALUES (2603, '2021-04-13', 'postgres', 'DELETE', 'RJ4438');
INSERT INTO "ProdNac2021".logbd VALUES (2604, '2021-04-13', 'postgres', 'DELETE', 'RJ4439');
INSERT INTO "ProdNac2021".logbd VALUES (2605, '2021-04-13', 'postgres', 'DELETE', 'RJ444');
INSERT INTO "ProdNac2021".logbd VALUES (2606, '2021-04-13', 'postgres', 'DELETE', 'RJ4440');
INSERT INTO "ProdNac2021".logbd VALUES (2607, '2021-04-13', 'postgres', 'DELETE', 'RJ4441');
INSERT INTO "ProdNac2021".logbd VALUES (2608, '2021-04-13', 'postgres', 'DELETE', 'RJ4442');
INSERT INTO "ProdNac2021".logbd VALUES (2609, '2021-04-13', 'postgres', 'DELETE', 'RJ4443');
INSERT INTO "ProdNac2021".logbd VALUES (2610, '2021-04-13', 'postgres', 'DELETE', 'RJ4444');
INSERT INTO "ProdNac2021".logbd VALUES (2611, '2021-04-13', 'postgres', 'DELETE', 'RJ4445');
INSERT INTO "ProdNac2021".logbd VALUES (2612, '2021-04-13', 'postgres', 'DELETE', 'RJ4446');
INSERT INTO "ProdNac2021".logbd VALUES (2613, '2021-04-13', 'postgres', 'DELETE', 'RJ4447');
INSERT INTO "ProdNac2021".logbd VALUES (2614, '2021-04-13', 'postgres', 'DELETE', 'RJ4448');
INSERT INTO "ProdNac2021".logbd VALUES (2615, '2021-04-13', 'postgres', 'DELETE', 'RJ4449');
INSERT INTO "ProdNac2021".logbd VALUES (2616, '2021-04-13', 'postgres', 'DELETE', 'RJ445');
INSERT INTO "ProdNac2021".logbd VALUES (2617, '2021-04-13', 'postgres', 'DELETE', 'RJ4450');
INSERT INTO "ProdNac2021".logbd VALUES (2618, '2021-04-13', 'postgres', 'DELETE', 'RJ4451');
INSERT INTO "ProdNac2021".logbd VALUES (2619, '2021-04-13', 'postgres', 'DELETE', 'RJ4452');
INSERT INTO "ProdNac2021".logbd VALUES (2620, '2021-04-13', 'postgres', 'DELETE', 'RJ4453');
INSERT INTO "ProdNac2021".logbd VALUES (2621, '2021-04-13', 'postgres', 'DELETE', 'RJ4454');
INSERT INTO "ProdNac2021".logbd VALUES (2622, '2021-04-13', 'postgres', 'DELETE', 'RJ4455');
INSERT INTO "ProdNac2021".logbd VALUES (2623, '2021-04-13', 'postgres', 'DELETE', 'RJ4456');
INSERT INTO "ProdNac2021".logbd VALUES (2624, '2021-04-13', 'postgres', 'DELETE', 'RJ4457');
INSERT INTO "ProdNac2021".logbd VALUES (2625, '2021-04-13', 'postgres', 'DELETE', 'RJ4458');
INSERT INTO "ProdNac2021".logbd VALUES (2626, '2021-04-13', 'postgres', 'DELETE', 'RJ4459');
INSERT INTO "ProdNac2021".logbd VALUES (2627, '2021-04-13', 'postgres', 'DELETE', 'RJ446');
INSERT INTO "ProdNac2021".logbd VALUES (2628, '2021-04-13', 'postgres', 'DELETE', 'RJ4460');
INSERT INTO "ProdNac2021".logbd VALUES (2629, '2021-04-13', 'postgres', 'DELETE', 'RJ4461');
INSERT INTO "ProdNac2021".logbd VALUES (2630, '2021-04-13', 'postgres', 'DELETE', 'RJ4462');
INSERT INTO "ProdNac2021".logbd VALUES (2631, '2021-04-13', 'postgres', 'DELETE', 'RJ4463');
INSERT INTO "ProdNac2021".logbd VALUES (2632, '2021-04-13', 'postgres', 'DELETE', 'RJ4464');
INSERT INTO "ProdNac2021".logbd VALUES (2633, '2021-04-13', 'postgres', 'DELETE', 'RJ4465');
INSERT INTO "ProdNac2021".logbd VALUES (2634, '2021-04-13', 'postgres', 'DELETE', 'RJ4466');
INSERT INTO "ProdNac2021".logbd VALUES (2635, '2021-04-13', 'postgres', 'DELETE', 'RJ4467');
INSERT INTO "ProdNac2021".logbd VALUES (2636, '2021-04-13', 'postgres', 'DELETE', 'RJ4468');
INSERT INTO "ProdNac2021".logbd VALUES (2637, '2021-04-13', 'postgres', 'DELETE', 'RJ4469');
INSERT INTO "ProdNac2021".logbd VALUES (2638, '2021-04-13', 'postgres', 'DELETE', 'RJ447');
INSERT INTO "ProdNac2021".logbd VALUES (2639, '2021-04-13', 'postgres', 'DELETE', 'RJ4470');
INSERT INTO "ProdNac2021".logbd VALUES (2640, '2021-04-13', 'postgres', 'DELETE', 'RJ4471');
INSERT INTO "ProdNac2021".logbd VALUES (2641, '2021-04-13', 'postgres', 'DELETE', 'RJ4472');
INSERT INTO "ProdNac2021".logbd VALUES (2642, '2021-04-13', 'postgres', 'DELETE', 'RJ4473');
INSERT INTO "ProdNac2021".logbd VALUES (2643, '2021-04-13', 'postgres', 'DELETE', 'RJ4474');
INSERT INTO "ProdNac2021".logbd VALUES (2644, '2021-04-13', 'postgres', 'DELETE', 'RJ4475');
INSERT INTO "ProdNac2021".logbd VALUES (2645, '2021-04-13', 'postgres', 'DELETE', 'RJ4476');
INSERT INTO "ProdNac2021".logbd VALUES (2646, '2021-04-13', 'postgres', 'DELETE', 'RJ4477');
INSERT INTO "ProdNac2021".logbd VALUES (2647, '2021-04-13', 'postgres', 'DELETE', 'RJ4478');
INSERT INTO "ProdNac2021".logbd VALUES (2648, '2021-04-13', 'postgres', 'DELETE', 'RJ4479');
INSERT INTO "ProdNac2021".logbd VALUES (2649, '2021-04-13', 'postgres', 'DELETE', 'RJ448');
INSERT INTO "ProdNac2021".logbd VALUES (2650, '2021-04-13', 'postgres', 'DELETE', 'RJ4480');
INSERT INTO "ProdNac2021".logbd VALUES (2651, '2021-04-13', 'postgres', 'DELETE', 'RJ4481');
INSERT INTO "ProdNac2021".logbd VALUES (2652, '2021-04-13', 'postgres', 'DELETE', 'RJ4482');
INSERT INTO "ProdNac2021".logbd VALUES (2653, '2021-04-13', 'postgres', 'DELETE', 'RJ4483');
INSERT INTO "ProdNac2021".logbd VALUES (2654, '2021-04-13', 'postgres', 'DELETE', 'RJ4484');
INSERT INTO "ProdNac2021".logbd VALUES (2655, '2021-04-13', 'postgres', 'DELETE', 'RJ4485');
INSERT INTO "ProdNac2021".logbd VALUES (2656, '2021-04-13', 'postgres', 'DELETE', 'RJ4486');
INSERT INTO "ProdNac2021".logbd VALUES (2657, '2021-04-13', 'postgres', 'DELETE', 'RJ4487');
INSERT INTO "ProdNac2021".logbd VALUES (2658, '2021-04-13', 'postgres', 'DELETE', 'RJ4488');
INSERT INTO "ProdNac2021".logbd VALUES (2659, '2021-04-13', 'postgres', 'DELETE', 'RJ4489');
INSERT INTO "ProdNac2021".logbd VALUES (2660, '2021-04-13', 'postgres', 'DELETE', 'RJ449');
INSERT INTO "ProdNac2021".logbd VALUES (2661, '2021-04-13', 'postgres', 'DELETE', 'RJ4490');
INSERT INTO "ProdNac2021".logbd VALUES (2662, '2021-04-13', 'postgres', 'DELETE', 'RJ4491');
INSERT INTO "ProdNac2021".logbd VALUES (2663, '2021-04-13', 'postgres', 'DELETE', 'RJ4492');
INSERT INTO "ProdNac2021".logbd VALUES (2664, '2021-04-13', 'postgres', 'DELETE', 'RJ4493');
INSERT INTO "ProdNac2021".logbd VALUES (2665, '2021-04-13', 'postgres', 'DELETE', 'RJ4494');
INSERT INTO "ProdNac2021".logbd VALUES (2666, '2021-04-13', 'postgres', 'DELETE', 'RJ4495');
INSERT INTO "ProdNac2021".logbd VALUES (2667, '2021-04-13', 'postgres', 'DELETE', 'RJ4496');
INSERT INTO "ProdNac2021".logbd VALUES (2668, '2021-04-13', 'postgres', 'DELETE', 'RJ4497');
INSERT INTO "ProdNac2021".logbd VALUES (2669, '2021-04-13', 'postgres', 'DELETE', 'RJ4498');
INSERT INTO "ProdNac2021".logbd VALUES (2670, '2021-04-13', 'postgres', 'DELETE', 'RJ4499');
INSERT INTO "ProdNac2021".logbd VALUES (2671, '2021-04-13', 'postgres', 'DELETE', 'RJ45');
INSERT INTO "ProdNac2021".logbd VALUES (2672, '2021-04-13', 'postgres', 'DELETE', 'RJ450');
INSERT INTO "ProdNac2021".logbd VALUES (2673, '2021-04-13', 'postgres', 'DELETE', 'RJ4500');
INSERT INTO "ProdNac2021".logbd VALUES (2674, '2021-04-13', 'postgres', 'DELETE', 'RJ4501');
INSERT INTO "ProdNac2021".logbd VALUES (2675, '2021-04-13', 'postgres', 'DELETE', 'RJ4502');
INSERT INTO "ProdNac2021".logbd VALUES (2676, '2021-04-13', 'postgres', 'DELETE', 'RJ4503');
INSERT INTO "ProdNac2021".logbd VALUES (2677, '2021-04-13', 'postgres', 'DELETE', 'RJ4504');
INSERT INTO "ProdNac2021".logbd VALUES (2678, '2021-04-13', 'postgres', 'DELETE', 'RJ4505');
INSERT INTO "ProdNac2021".logbd VALUES (2679, '2021-04-13', 'postgres', 'DELETE', 'RJ4506');
INSERT INTO "ProdNac2021".logbd VALUES (2680, '2021-04-13', 'postgres', 'DELETE', 'RJ4507');
INSERT INTO "ProdNac2021".logbd VALUES (2681, '2021-04-13', 'postgres', 'DELETE', 'RJ4508');
INSERT INTO "ProdNac2021".logbd VALUES (2682, '2021-04-13', 'postgres', 'DELETE', 'RJ4509');
INSERT INTO "ProdNac2021".logbd VALUES (2683, '2021-04-13', 'postgres', 'DELETE', 'RJ451');
INSERT INTO "ProdNac2021".logbd VALUES (2684, '2021-04-13', 'postgres', 'DELETE', 'RJ4510');
INSERT INTO "ProdNac2021".logbd VALUES (2685, '2021-04-13', 'postgres', 'DELETE', 'RJ4511');
INSERT INTO "ProdNac2021".logbd VALUES (2686, '2021-04-13', 'postgres', 'DELETE', 'RJ4512');
INSERT INTO "ProdNac2021".logbd VALUES (2687, '2021-04-13', 'postgres', 'DELETE', 'RJ4513');
INSERT INTO "ProdNac2021".logbd VALUES (2688, '2021-04-13', 'postgres', 'DELETE', 'RJ4514');
INSERT INTO "ProdNac2021".logbd VALUES (2689, '2021-04-13', 'postgres', 'DELETE', 'RJ4515');
INSERT INTO "ProdNac2021".logbd VALUES (2690, '2021-04-13', 'postgres', 'DELETE', 'RJ4516');
INSERT INTO "ProdNac2021".logbd VALUES (2691, '2021-04-13', 'postgres', 'DELETE', 'RJ4517');
INSERT INTO "ProdNac2021".logbd VALUES (2692, '2021-04-13', 'postgres', 'DELETE', 'RJ4518');
INSERT INTO "ProdNac2021".logbd VALUES (2693, '2021-04-13', 'postgres', 'DELETE', 'RJ4519');
INSERT INTO "ProdNac2021".logbd VALUES (2694, '2021-04-13', 'postgres', 'DELETE', 'RJ452');
INSERT INTO "ProdNac2021".logbd VALUES (2695, '2021-04-13', 'postgres', 'DELETE', 'RJ4520');
INSERT INTO "ProdNac2021".logbd VALUES (2696, '2021-04-13', 'postgres', 'DELETE', 'RJ4521');
INSERT INTO "ProdNac2021".logbd VALUES (2697, '2021-04-13', 'postgres', 'DELETE', 'RJ4522');
INSERT INTO "ProdNac2021".logbd VALUES (2698, '2021-04-13', 'postgres', 'DELETE', 'RJ4523');
INSERT INTO "ProdNac2021".logbd VALUES (2699, '2021-04-13', 'postgres', 'DELETE', 'RJ4524');
INSERT INTO "ProdNac2021".logbd VALUES (2700, '2021-04-13', 'postgres', 'DELETE', 'RJ4525');
INSERT INTO "ProdNac2021".logbd VALUES (2701, '2021-04-13', 'postgres', 'DELETE', 'RJ4526');
INSERT INTO "ProdNac2021".logbd VALUES (2702, '2021-04-13', 'postgres', 'DELETE', 'RJ4527');
INSERT INTO "ProdNac2021".logbd VALUES (2703, '2021-04-13', 'postgres', 'DELETE', 'RJ4528');
INSERT INTO "ProdNac2021".logbd VALUES (2704, '2021-04-13', 'postgres', 'DELETE', 'RJ4529');
INSERT INTO "ProdNac2021".logbd VALUES (2705, '2021-04-13', 'postgres', 'DELETE', 'RJ453');
INSERT INTO "ProdNac2021".logbd VALUES (2706, '2021-04-13', 'postgres', 'DELETE', 'RJ4530');
INSERT INTO "ProdNac2021".logbd VALUES (2707, '2021-04-13', 'postgres', 'DELETE', 'RJ4531');
INSERT INTO "ProdNac2021".logbd VALUES (2708, '2021-04-13', 'postgres', 'DELETE', 'RJ4532');
INSERT INTO "ProdNac2021".logbd VALUES (2709, '2021-04-13', 'postgres', 'DELETE', 'RJ4533');
INSERT INTO "ProdNac2021".logbd VALUES (2710, '2021-04-13', 'postgres', 'DELETE', 'RJ4534');
INSERT INTO "ProdNac2021".logbd VALUES (2711, '2021-04-13', 'postgres', 'DELETE', 'RJ4535');
INSERT INTO "ProdNac2021".logbd VALUES (2712, '2021-04-13', 'postgres', 'DELETE', 'RJ4536');
INSERT INTO "ProdNac2021".logbd VALUES (2713, '2021-04-13', 'postgres', 'DELETE', 'RJ4537');
INSERT INTO "ProdNac2021".logbd VALUES (2714, '2021-04-13', 'postgres', 'DELETE', 'RJ4538');
INSERT INTO "ProdNac2021".logbd VALUES (2715, '2021-04-13', 'postgres', 'DELETE', 'RJ4539');
INSERT INTO "ProdNac2021".logbd VALUES (2716, '2021-04-13', 'postgres', 'DELETE', 'RJ454');
INSERT INTO "ProdNac2021".logbd VALUES (2717, '2021-04-13', 'postgres', 'DELETE', 'RJ4540');
INSERT INTO "ProdNac2021".logbd VALUES (2718, '2021-04-13', 'postgres', 'DELETE', 'RJ4541');
INSERT INTO "ProdNac2021".logbd VALUES (2719, '2021-04-13', 'postgres', 'DELETE', 'RJ4542');
INSERT INTO "ProdNac2021".logbd VALUES (2720, '2021-04-13', 'postgres', 'DELETE', 'RJ4543');
INSERT INTO "ProdNac2021".logbd VALUES (2721, '2021-04-13', 'postgres', 'DELETE', 'RJ4544');
INSERT INTO "ProdNac2021".logbd VALUES (2722, '2021-04-13', 'postgres', 'DELETE', 'RJ4545');
INSERT INTO "ProdNac2021".logbd VALUES (2723, '2021-04-13', 'postgres', 'DELETE', 'RJ4546');
INSERT INTO "ProdNac2021".logbd VALUES (2724, '2021-04-13', 'postgres', 'DELETE', 'RJ4547');
INSERT INTO "ProdNac2021".logbd VALUES (2725, '2021-04-13', 'postgres', 'DELETE', 'RJ4548');
INSERT INTO "ProdNac2021".logbd VALUES (2726, '2021-04-13', 'postgres', 'DELETE', 'RJ4549');
INSERT INTO "ProdNac2021".logbd VALUES (2727, '2021-04-13', 'postgres', 'DELETE', 'RJ455');
INSERT INTO "ProdNac2021".logbd VALUES (2728, '2021-04-13', 'postgres', 'DELETE', 'RJ4550');
INSERT INTO "ProdNac2021".logbd VALUES (2729, '2021-04-13', 'postgres', 'DELETE', 'RJ4551');
INSERT INTO "ProdNac2021".logbd VALUES (2730, '2021-04-13', 'postgres', 'DELETE', 'RJ4552');
INSERT INTO "ProdNac2021".logbd VALUES (2731, '2021-04-13', 'postgres', 'DELETE', 'RJ4553');
INSERT INTO "ProdNac2021".logbd VALUES (2732, '2021-04-13', 'postgres', 'DELETE', 'RJ4554');
INSERT INTO "ProdNac2021".logbd VALUES (2733, '2021-04-13', 'postgres', 'DELETE', 'RJ4555');
INSERT INTO "ProdNac2021".logbd VALUES (2734, '2021-04-13', 'postgres', 'DELETE', 'RJ4556');
INSERT INTO "ProdNac2021".logbd VALUES (2735, '2021-04-13', 'postgres', 'DELETE', 'RJ4557');
INSERT INTO "ProdNac2021".logbd VALUES (2736, '2021-04-13', 'postgres', 'DELETE', 'RJ4558');
INSERT INTO "ProdNac2021".logbd VALUES (2737, '2021-04-13', 'postgres', 'DELETE', 'RJ4559');
INSERT INTO "ProdNac2021".logbd VALUES (2738, '2021-04-13', 'postgres', 'DELETE', 'RJ456');
INSERT INTO "ProdNac2021".logbd VALUES (2739, '2021-04-13', 'postgres', 'DELETE', 'RJ4560');
INSERT INTO "ProdNac2021".logbd VALUES (2740, '2021-04-13', 'postgres', 'DELETE', 'RJ4561');
INSERT INTO "ProdNac2021".logbd VALUES (2741, '2021-04-13', 'postgres', 'DELETE', 'RJ4562');
INSERT INTO "ProdNac2021".logbd VALUES (2742, '2021-04-13', 'postgres', 'DELETE', 'RJ4563');
INSERT INTO "ProdNac2021".logbd VALUES (2743, '2021-04-13', 'postgres', 'DELETE', 'RJ4564');
INSERT INTO "ProdNac2021".logbd VALUES (2744, '2021-04-13', 'postgres', 'DELETE', 'RJ4565');
INSERT INTO "ProdNac2021".logbd VALUES (2745, '2021-04-13', 'postgres', 'DELETE', 'RJ4566');
INSERT INTO "ProdNac2021".logbd VALUES (2746, '2021-04-13', 'postgres', 'DELETE', 'RJ4567');
INSERT INTO "ProdNac2021".logbd VALUES (2747, '2021-04-13', 'postgres', 'DELETE', 'RJ4568');
INSERT INTO "ProdNac2021".logbd VALUES (2748, '2021-04-13', 'postgres', 'DELETE', 'RJ4569');
INSERT INTO "ProdNac2021".logbd VALUES (2749, '2021-04-13', 'postgres', 'DELETE', 'RJ457');
INSERT INTO "ProdNac2021".logbd VALUES (2750, '2021-04-13', 'postgres', 'DELETE', 'RJ4570');
INSERT INTO "ProdNac2021".logbd VALUES (2751, '2021-04-13', 'postgres', 'DELETE', 'RJ4571');
INSERT INTO "ProdNac2021".logbd VALUES (2752, '2021-04-13', 'postgres', 'DELETE', 'RJ4572');
INSERT INTO "ProdNac2021".logbd VALUES (2753, '2021-04-13', 'postgres', 'DELETE', 'RJ4573');
INSERT INTO "ProdNac2021".logbd VALUES (2754, '2021-04-13', 'postgres', 'DELETE', 'RJ4574');
INSERT INTO "ProdNac2021".logbd VALUES (2755, '2021-04-13', 'postgres', 'DELETE', 'RJ4575');
INSERT INTO "ProdNac2021".logbd VALUES (2756, '2021-04-13', 'postgres', 'DELETE', 'RJ4576');
INSERT INTO "ProdNac2021".logbd VALUES (2757, '2021-04-13', 'postgres', 'DELETE', 'RJ4577');
INSERT INTO "ProdNac2021".logbd VALUES (2758, '2021-04-13', 'postgres', 'DELETE', 'RJ4578');
INSERT INTO "ProdNac2021".logbd VALUES (2759, '2021-04-13', 'postgres', 'DELETE', 'RJ4579');
INSERT INTO "ProdNac2021".logbd VALUES (2760, '2021-04-13', 'postgres', 'DELETE', 'RJ458');
INSERT INTO "ProdNac2021".logbd VALUES (2761, '2021-04-13', 'postgres', 'DELETE', 'RJ4580');
INSERT INTO "ProdNac2021".logbd VALUES (2762, '2021-04-13', 'postgres', 'DELETE', 'RJ4581');
INSERT INTO "ProdNac2021".logbd VALUES (2763, '2021-04-13', 'postgres', 'DELETE', 'RJ4582');
INSERT INTO "ProdNac2021".logbd VALUES (2764, '2021-04-13', 'postgres', 'DELETE', 'RJ4583');
INSERT INTO "ProdNac2021".logbd VALUES (2765, '2021-04-13', 'postgres', 'DELETE', 'RJ4584');
INSERT INTO "ProdNac2021".logbd VALUES (2766, '2021-04-13', 'postgres', 'DELETE', 'RJ4585');
INSERT INTO "ProdNac2021".logbd VALUES (2767, '2021-04-13', 'postgres', 'DELETE', 'RJ4586');
INSERT INTO "ProdNac2021".logbd VALUES (2768, '2021-04-13', 'postgres', 'DELETE', 'RJ4587');
INSERT INTO "ProdNac2021".logbd VALUES (2769, '2021-04-13', 'postgres', 'DELETE', 'RJ4588');
INSERT INTO "ProdNac2021".logbd VALUES (2770, '2021-04-13', 'postgres', 'DELETE', 'RJ4589');
INSERT INTO "ProdNac2021".logbd VALUES (2771, '2021-04-13', 'postgres', 'DELETE', 'RJ459');
INSERT INTO "ProdNac2021".logbd VALUES (2772, '2021-04-13', 'postgres', 'DELETE', 'RJ4590');
INSERT INTO "ProdNac2021".logbd VALUES (2773, '2021-04-13', 'postgres', 'DELETE', 'RJ4591');
INSERT INTO "ProdNac2021".logbd VALUES (2774, '2021-04-13', 'postgres', 'DELETE', 'RJ4592');
INSERT INTO "ProdNac2021".logbd VALUES (2775, '2021-04-13', 'postgres', 'DELETE', 'RJ4593');
INSERT INTO "ProdNac2021".logbd VALUES (2776, '2021-04-13', 'postgres', 'DELETE', 'RJ4594');
INSERT INTO "ProdNac2021".logbd VALUES (2777, '2021-04-13', 'postgres', 'DELETE', 'RJ4595');
INSERT INTO "ProdNac2021".logbd VALUES (2778, '2021-04-13', 'postgres', 'DELETE', 'RJ4596');
INSERT INTO "ProdNac2021".logbd VALUES (2779, '2021-04-13', 'postgres', 'DELETE', 'RJ4597');
INSERT INTO "ProdNac2021".logbd VALUES (2780, '2021-04-13', 'postgres', 'DELETE', 'RJ4598');
INSERT INTO "ProdNac2021".logbd VALUES (2781, '2021-04-13', 'postgres', 'DELETE', 'RJ4599');
INSERT INTO "ProdNac2021".logbd VALUES (2782, '2021-04-13', 'postgres', 'DELETE', 'RJ46');
INSERT INTO "ProdNac2021".logbd VALUES (2783, '2021-04-13', 'postgres', 'DELETE', 'RJ460');
INSERT INTO "ProdNac2021".logbd VALUES (2784, '2021-04-13', 'postgres', 'DELETE', 'RJ4600');
INSERT INTO "ProdNac2021".logbd VALUES (2785, '2021-04-13', 'postgres', 'DELETE', 'RJ4601');
INSERT INTO "ProdNac2021".logbd VALUES (2786, '2021-04-13', 'postgres', 'DELETE', 'RJ4602');
INSERT INTO "ProdNac2021".logbd VALUES (2787, '2021-04-13', 'postgres', 'DELETE', 'RJ4603');
INSERT INTO "ProdNac2021".logbd VALUES (2788, '2021-04-13', 'postgres', 'DELETE', 'RJ4604');
INSERT INTO "ProdNac2021".logbd VALUES (2789, '2021-04-13', 'postgres', 'DELETE', 'RJ4605');
INSERT INTO "ProdNac2021".logbd VALUES (2790, '2021-04-13', 'postgres', 'DELETE', 'RJ4606');
INSERT INTO "ProdNac2021".logbd VALUES (2791, '2021-04-13', 'postgres', 'DELETE', 'RJ4607');
INSERT INTO "ProdNac2021".logbd VALUES (2792, '2021-04-13', 'postgres', 'DELETE', 'RJ4608');
INSERT INTO "ProdNac2021".logbd VALUES (2793, '2021-04-13', 'postgres', 'DELETE', 'RJ4609');
INSERT INTO "ProdNac2021".logbd VALUES (2794, '2021-04-13', 'postgres', 'DELETE', 'RJ461');
INSERT INTO "ProdNac2021".logbd VALUES (2795, '2021-04-13', 'postgres', 'DELETE', 'RJ4610');
INSERT INTO "ProdNac2021".logbd VALUES (2796, '2021-04-13', 'postgres', 'DELETE', 'RJ4611');
INSERT INTO "ProdNac2021".logbd VALUES (2797, '2021-04-13', 'postgres', 'DELETE', 'RJ4612');
INSERT INTO "ProdNac2021".logbd VALUES (2798, '2021-04-13', 'postgres', 'DELETE', 'RJ4613');
INSERT INTO "ProdNac2021".logbd VALUES (2799, '2021-04-13', 'postgres', 'DELETE', 'RJ4614');
INSERT INTO "ProdNac2021".logbd VALUES (2800, '2021-04-13', 'postgres', 'DELETE', 'RJ4615');
INSERT INTO "ProdNac2021".logbd VALUES (2801, '2021-04-13', 'postgres', 'DELETE', 'RJ4616');
INSERT INTO "ProdNac2021".logbd VALUES (2802, '2021-04-13', 'postgres', 'DELETE', 'RJ4617');
INSERT INTO "ProdNac2021".logbd VALUES (2803, '2021-04-13', 'postgres', 'DELETE', 'RJ4618');
INSERT INTO "ProdNac2021".logbd VALUES (2804, '2021-04-13', 'postgres', 'DELETE', 'RJ4619');
INSERT INTO "ProdNac2021".logbd VALUES (2805, '2021-04-13', 'postgres', 'DELETE', 'RJ462');
INSERT INTO "ProdNac2021".logbd VALUES (2806, '2021-04-13', 'postgres', 'DELETE', 'RJ4620');
INSERT INTO "ProdNac2021".logbd VALUES (2807, '2021-04-13', 'postgres', 'DELETE', 'RJ4621');
INSERT INTO "ProdNac2021".logbd VALUES (2808, '2021-04-13', 'postgres', 'DELETE', 'RJ4622');
INSERT INTO "ProdNac2021".logbd VALUES (2809, '2021-04-13', 'postgres', 'DELETE', 'RJ4623');
INSERT INTO "ProdNac2021".logbd VALUES (2810, '2021-04-13', 'postgres', 'DELETE', 'RJ4624');
INSERT INTO "ProdNac2021".logbd VALUES (2811, '2021-04-13', 'postgres', 'DELETE', 'RJ4625');
INSERT INTO "ProdNac2021".logbd VALUES (2812, '2021-04-13', 'postgres', 'DELETE', 'RJ4626');
INSERT INTO "ProdNac2021".logbd VALUES (2813, '2021-04-13', 'postgres', 'DELETE', 'RJ4627');
INSERT INTO "ProdNac2021".logbd VALUES (2814, '2021-04-13', 'postgres', 'DELETE', 'RJ4628');
INSERT INTO "ProdNac2021".logbd VALUES (2815, '2021-04-13', 'postgres', 'DELETE', 'RJ4629');
INSERT INTO "ProdNac2021".logbd VALUES (2816, '2021-04-13', 'postgres', 'DELETE', 'RJ463');
INSERT INTO "ProdNac2021".logbd VALUES (2817, '2021-04-13', 'postgres', 'DELETE', 'RJ4630');
INSERT INTO "ProdNac2021".logbd VALUES (2818, '2021-04-13', 'postgres', 'DELETE', 'RJ4631');
INSERT INTO "ProdNac2021".logbd VALUES (2819, '2021-04-13', 'postgres', 'DELETE', 'RJ4632');
INSERT INTO "ProdNac2021".logbd VALUES (2820, '2021-04-13', 'postgres', 'DELETE', 'RJ4633');
INSERT INTO "ProdNac2021".logbd VALUES (2821, '2021-04-13', 'postgres', 'DELETE', 'RJ4634');
INSERT INTO "ProdNac2021".logbd VALUES (2822, '2021-04-13', 'postgres', 'DELETE', 'RJ4635');
INSERT INTO "ProdNac2021".logbd VALUES (2823, '2021-04-13', 'postgres', 'DELETE', 'RJ4636');
INSERT INTO "ProdNac2021".logbd VALUES (2824, '2021-04-13', 'postgres', 'DELETE', 'RJ4637');
INSERT INTO "ProdNac2021".logbd VALUES (2825, '2021-04-13', 'postgres', 'DELETE', 'RJ4638');
INSERT INTO "ProdNac2021".logbd VALUES (2826, '2021-04-13', 'postgres', 'DELETE', 'RJ4639');
INSERT INTO "ProdNac2021".logbd VALUES (2827, '2021-04-13', 'postgres', 'DELETE', 'RJ464');
INSERT INTO "ProdNac2021".logbd VALUES (2828, '2021-04-13', 'postgres', 'DELETE', 'RJ4640');
INSERT INTO "ProdNac2021".logbd VALUES (2829, '2021-04-13', 'postgres', 'DELETE', 'RJ4641');
INSERT INTO "ProdNac2021".logbd VALUES (2830, '2021-04-13', 'postgres', 'DELETE', 'RJ4642');
INSERT INTO "ProdNac2021".logbd VALUES (2831, '2021-04-13', 'postgres', 'DELETE', 'RJ4643');
INSERT INTO "ProdNac2021".logbd VALUES (2832, '2021-04-13', 'postgres', 'DELETE', 'RJ4644');
INSERT INTO "ProdNac2021".logbd VALUES (2833, '2021-04-13', 'postgres', 'DELETE', 'RJ4645');
INSERT INTO "ProdNac2021".logbd VALUES (2834, '2021-04-13', 'postgres', 'DELETE', 'RJ4646');
INSERT INTO "ProdNac2021".logbd VALUES (2835, '2021-04-13', 'postgres', 'DELETE', 'RJ4647');
INSERT INTO "ProdNac2021".logbd VALUES (2836, '2021-04-13', 'postgres', 'DELETE', 'RJ4648');
INSERT INTO "ProdNac2021".logbd VALUES (2837, '2021-04-13', 'postgres', 'DELETE', 'RJ4649');
INSERT INTO "ProdNac2021".logbd VALUES (2838, '2021-04-13', 'postgres', 'DELETE', 'RJ465');
INSERT INTO "ProdNac2021".logbd VALUES (2839, '2021-04-13', 'postgres', 'DELETE', 'RJ4650');
INSERT INTO "ProdNac2021".logbd VALUES (2840, '2021-04-13', 'postgres', 'DELETE', 'RJ4651');
INSERT INTO "ProdNac2021".logbd VALUES (2841, '2021-04-13', 'postgres', 'DELETE', 'RJ4652');
INSERT INTO "ProdNac2021".logbd VALUES (2842, '2021-04-13', 'postgres', 'DELETE', 'RJ4653');
INSERT INTO "ProdNac2021".logbd VALUES (2843, '2021-04-13', 'postgres', 'DELETE', 'RJ4654');
INSERT INTO "ProdNac2021".logbd VALUES (2844, '2021-04-13', 'postgres', 'DELETE', 'RJ4655');
INSERT INTO "ProdNac2021".logbd VALUES (2845, '2021-04-13', 'postgres', 'DELETE', 'RJ4656');
INSERT INTO "ProdNac2021".logbd VALUES (2846, '2021-04-13', 'postgres', 'DELETE', 'RJ4657');
INSERT INTO "ProdNac2021".logbd VALUES (2847, '2021-04-13', 'postgres', 'DELETE', 'RJ4658');
INSERT INTO "ProdNac2021".logbd VALUES (2848, '2021-04-13', 'postgres', 'DELETE', 'RJ4659');
INSERT INTO "ProdNac2021".logbd VALUES (2849, '2021-04-13', 'postgres', 'DELETE', 'RJ466');
INSERT INTO "ProdNac2021".logbd VALUES (2850, '2021-04-13', 'postgres', 'DELETE', 'RJ4660');
INSERT INTO "ProdNac2021".logbd VALUES (2851, '2021-04-13', 'postgres', 'DELETE', 'RJ4661');
INSERT INTO "ProdNac2021".logbd VALUES (2852, '2021-04-13', 'postgres', 'DELETE', 'RJ4662');
INSERT INTO "ProdNac2021".logbd VALUES (2853, '2021-04-13', 'postgres', 'DELETE', 'RJ4663');
INSERT INTO "ProdNac2021".logbd VALUES (2854, '2021-04-13', 'postgres', 'DELETE', 'RJ4664');
INSERT INTO "ProdNac2021".logbd VALUES (2855, '2021-04-13', 'postgres', 'DELETE', 'RJ4665');
INSERT INTO "ProdNac2021".logbd VALUES (2856, '2021-04-13', 'postgres', 'DELETE', 'RJ4666');
INSERT INTO "ProdNac2021".logbd VALUES (2857, '2021-04-13', 'postgres', 'DELETE', 'RJ4667');
INSERT INTO "ProdNac2021".logbd VALUES (2858, '2021-04-13', 'postgres', 'DELETE', 'RJ4668');
INSERT INTO "ProdNac2021".logbd VALUES (2859, '2021-04-13', 'postgres', 'DELETE', 'RJ4669');
INSERT INTO "ProdNac2021".logbd VALUES (2860, '2021-04-13', 'postgres', 'DELETE', 'RJ467');
INSERT INTO "ProdNac2021".logbd VALUES (2861, '2021-04-13', 'postgres', 'DELETE', 'RJ4670');
INSERT INTO "ProdNac2021".logbd VALUES (2862, '2021-04-13', 'postgres', 'DELETE', 'RJ4671');
INSERT INTO "ProdNac2021".logbd VALUES (2863, '2021-04-13', 'postgres', 'DELETE', 'RJ4672');
INSERT INTO "ProdNac2021".logbd VALUES (2864, '2021-04-13', 'postgres', 'DELETE', 'RJ4673');
INSERT INTO "ProdNac2021".logbd VALUES (2865, '2021-04-13', 'postgres', 'DELETE', 'RJ4674');
INSERT INTO "ProdNac2021".logbd VALUES (2866, '2021-04-13', 'postgres', 'DELETE', 'RJ4675');
INSERT INTO "ProdNac2021".logbd VALUES (2867, '2021-04-13', 'postgres', 'DELETE', 'RJ4676');
INSERT INTO "ProdNac2021".logbd VALUES (2868, '2021-04-13', 'postgres', 'DELETE', 'RJ4677');
INSERT INTO "ProdNac2021".logbd VALUES (2869, '2021-04-13', 'postgres', 'DELETE', 'RJ4678');
INSERT INTO "ProdNac2021".logbd VALUES (2870, '2021-04-13', 'postgres', 'DELETE', 'RJ4679');
INSERT INTO "ProdNac2021".logbd VALUES (2871, '2021-04-13', 'postgres', 'DELETE', 'RJ468');
INSERT INTO "ProdNac2021".logbd VALUES (2872, '2021-04-13', 'postgres', 'DELETE', 'RJ4680');
INSERT INTO "ProdNac2021".logbd VALUES (2873, '2021-04-13', 'postgres', 'DELETE', 'RJ4681');
INSERT INTO "ProdNac2021".logbd VALUES (2874, '2021-04-13', 'postgres', 'DELETE', 'RJ4682');
INSERT INTO "ProdNac2021".logbd VALUES (2875, '2021-04-13', 'postgres', 'DELETE', 'RJ4683');
INSERT INTO "ProdNac2021".logbd VALUES (2876, '2021-04-13', 'postgres', 'DELETE', 'RJ4684');
INSERT INTO "ProdNac2021".logbd VALUES (2877, '2021-04-13', 'postgres', 'DELETE', 'RJ4685');
INSERT INTO "ProdNac2021".logbd VALUES (2878, '2021-04-13', 'postgres', 'DELETE', 'RJ4686');
INSERT INTO "ProdNac2021".logbd VALUES (2879, '2021-04-13', 'postgres', 'DELETE', 'RJ4687');
INSERT INTO "ProdNac2021".logbd VALUES (2880, '2021-04-13', 'postgres', 'DELETE', 'RJ4688');
INSERT INTO "ProdNac2021".logbd VALUES (2881, '2021-04-13', 'postgres', 'DELETE', 'RJ4689');
INSERT INTO "ProdNac2021".logbd VALUES (2882, '2021-04-13', 'postgres', 'DELETE', 'RJ469');
INSERT INTO "ProdNac2021".logbd VALUES (2883, '2021-04-13', 'postgres', 'DELETE', 'RJ4690');
INSERT INTO "ProdNac2021".logbd VALUES (2884, '2021-04-13', 'postgres', 'DELETE', 'RJ4691');
INSERT INTO "ProdNac2021".logbd VALUES (2885, '2021-04-13', 'postgres', 'DELETE', 'RJ4692');
INSERT INTO "ProdNac2021".logbd VALUES (2886, '2021-04-13', 'postgres', 'DELETE', 'RJ4693');
INSERT INTO "ProdNac2021".logbd VALUES (2887, '2021-04-13', 'postgres', 'DELETE', 'RJ4694');
INSERT INTO "ProdNac2021".logbd VALUES (2888, '2021-04-13', 'postgres', 'DELETE', 'RJ4695');
INSERT INTO "ProdNac2021".logbd VALUES (2889, '2021-04-13', 'postgres', 'DELETE', 'RJ4696');
INSERT INTO "ProdNac2021".logbd VALUES (2890, '2021-04-13', 'postgres', 'DELETE', 'RJ4697');
INSERT INTO "ProdNac2021".logbd VALUES (2891, '2021-04-13', 'postgres', 'DELETE', 'RJ4698');
INSERT INTO "ProdNac2021".logbd VALUES (2892, '2021-04-13', 'postgres', 'DELETE', 'RJ4699');
INSERT INTO "ProdNac2021".logbd VALUES (2893, '2021-04-13', 'postgres', 'DELETE', 'RJ47');
INSERT INTO "ProdNac2021".logbd VALUES (2894, '2021-04-13', 'postgres', 'DELETE', 'RJ470');
INSERT INTO "ProdNac2021".logbd VALUES (2895, '2021-04-13', 'postgres', 'DELETE', 'RJ4700');
INSERT INTO "ProdNac2021".logbd VALUES (2896, '2021-04-13', 'postgres', 'DELETE', 'RJ4701');
INSERT INTO "ProdNac2021".logbd VALUES (2897, '2021-04-13', 'postgres', 'DELETE', 'RJ4702');
INSERT INTO "ProdNac2021".logbd VALUES (2898, '2021-04-13', 'postgres', 'DELETE', 'RJ4703');
INSERT INTO "ProdNac2021".logbd VALUES (2899, '2021-04-13', 'postgres', 'DELETE', 'RJ4704');
INSERT INTO "ProdNac2021".logbd VALUES (2900, '2021-04-13', 'postgres', 'DELETE', 'RJ4705');
INSERT INTO "ProdNac2021".logbd VALUES (2901, '2021-04-13', 'postgres', 'DELETE', 'RJ4706');
INSERT INTO "ProdNac2021".logbd VALUES (2902, '2021-04-13', 'postgres', 'DELETE', 'RJ4707');
INSERT INTO "ProdNac2021".logbd VALUES (2903, '2021-04-13', 'postgres', 'DELETE', 'RJ4708');
INSERT INTO "ProdNac2021".logbd VALUES (2904, '2021-04-13', 'postgres', 'DELETE', 'RJ4709');
INSERT INTO "ProdNac2021".logbd VALUES (2905, '2021-04-13', 'postgres', 'DELETE', 'RJ471');
INSERT INTO "ProdNac2021".logbd VALUES (2906, '2021-04-13', 'postgres', 'DELETE', 'RJ4710');
INSERT INTO "ProdNac2021".logbd VALUES (2907, '2021-04-13', 'postgres', 'DELETE', 'RJ4711');
INSERT INTO "ProdNac2021".logbd VALUES (2908, '2021-04-13', 'postgres', 'DELETE', 'RJ4712');
INSERT INTO "ProdNac2021".logbd VALUES (2909, '2021-04-13', 'postgres', 'DELETE', 'RJ4713');
INSERT INTO "ProdNac2021".logbd VALUES (2910, '2021-04-13', 'postgres', 'DELETE', 'RJ4714');
INSERT INTO "ProdNac2021".logbd VALUES (2911, '2021-04-13', 'postgres', 'DELETE', 'RJ4715');
INSERT INTO "ProdNac2021".logbd VALUES (2912, '2021-04-13', 'postgres', 'DELETE', 'RJ4716');
INSERT INTO "ProdNac2021".logbd VALUES (2913, '2021-04-13', 'postgres', 'DELETE', 'RJ4717');
INSERT INTO "ProdNac2021".logbd VALUES (2914, '2021-04-13', 'postgres', 'DELETE', 'RJ4718');
INSERT INTO "ProdNac2021".logbd VALUES (2915, '2021-04-13', 'postgres', 'DELETE', 'RJ4719');
INSERT INTO "ProdNac2021".logbd VALUES (2916, '2021-04-13', 'postgres', 'DELETE', 'RJ472');
INSERT INTO "ProdNac2021".logbd VALUES (2917, '2021-04-13', 'postgres', 'DELETE', 'RJ4720');
INSERT INTO "ProdNac2021".logbd VALUES (2918, '2021-04-13', 'postgres', 'DELETE', 'RJ4721');
INSERT INTO "ProdNac2021".logbd VALUES (2919, '2021-04-13', 'postgres', 'DELETE', 'RJ4722');
INSERT INTO "ProdNac2021".logbd VALUES (2920, '2021-04-13', 'postgres', 'DELETE', 'RJ4723');
INSERT INTO "ProdNac2021".logbd VALUES (2921, '2021-04-13', 'postgres', 'DELETE', 'RJ4724');
INSERT INTO "ProdNac2021".logbd VALUES (2922, '2021-04-13', 'postgres', 'DELETE', 'RJ4725');
INSERT INTO "ProdNac2021".logbd VALUES (2923, '2021-04-13', 'postgres', 'DELETE', 'RJ4726');
INSERT INTO "ProdNac2021".logbd VALUES (2924, '2021-04-13', 'postgres', 'DELETE', 'RJ4727');
INSERT INTO "ProdNac2021".logbd VALUES (2925, '2021-04-13', 'postgres', 'DELETE', 'RJ4728');
INSERT INTO "ProdNac2021".logbd VALUES (2926, '2021-04-13', 'postgres', 'DELETE', 'RJ4729');
INSERT INTO "ProdNac2021".logbd VALUES (2927, '2021-04-13', 'postgres', 'DELETE', 'RJ473');
INSERT INTO "ProdNac2021".logbd VALUES (2928, '2021-04-13', 'postgres', 'DELETE', 'RJ4730');
INSERT INTO "ProdNac2021".logbd VALUES (2929, '2021-04-13', 'postgres', 'DELETE', 'RJ4731');
INSERT INTO "ProdNac2021".logbd VALUES (2930, '2021-04-13', 'postgres', 'DELETE', 'RJ4732');
INSERT INTO "ProdNac2021".logbd VALUES (2931, '2021-04-13', 'postgres', 'DELETE', 'RJ4733');
INSERT INTO "ProdNac2021".logbd VALUES (2932, '2021-04-13', 'postgres', 'DELETE', 'RJ4734');
INSERT INTO "ProdNac2021".logbd VALUES (2933, '2021-04-13', 'postgres', 'DELETE', 'RJ4735');
INSERT INTO "ProdNac2021".logbd VALUES (2934, '2021-04-13', 'postgres', 'DELETE', 'RJ4736');
INSERT INTO "ProdNac2021".logbd VALUES (2935, '2021-04-13', 'postgres', 'DELETE', 'RJ4737');
INSERT INTO "ProdNac2021".logbd VALUES (2936, '2021-04-13', 'postgres', 'DELETE', 'RJ4738');
INSERT INTO "ProdNac2021".logbd VALUES (2937, '2021-04-13', 'postgres', 'DELETE', 'RJ4739');
INSERT INTO "ProdNac2021".logbd VALUES (2938, '2021-04-13', 'postgres', 'DELETE', 'RJ474');
INSERT INTO "ProdNac2021".logbd VALUES (2939, '2021-04-13', 'postgres', 'DELETE', 'RJ4740');
INSERT INTO "ProdNac2021".logbd VALUES (2940, '2021-04-13', 'postgres', 'DELETE', 'RJ4741');
INSERT INTO "ProdNac2021".logbd VALUES (2941, '2021-04-13', 'postgres', 'DELETE', 'RJ4742');
INSERT INTO "ProdNac2021".logbd VALUES (2942, '2021-04-13', 'postgres', 'DELETE', 'RJ4743');
INSERT INTO "ProdNac2021".logbd VALUES (2943, '2021-04-13', 'postgres', 'DELETE', 'RJ4744');
INSERT INTO "ProdNac2021".logbd VALUES (2944, '2021-04-13', 'postgres', 'DELETE', 'RJ4745');
INSERT INTO "ProdNac2021".logbd VALUES (2945, '2021-04-13', 'postgres', 'DELETE', 'RJ4746');
INSERT INTO "ProdNac2021".logbd VALUES (2946, '2021-04-13', 'postgres', 'DELETE', 'RJ4747');
INSERT INTO "ProdNac2021".logbd VALUES (2947, '2021-04-13', 'postgres', 'DELETE', 'RJ4748');
INSERT INTO "ProdNac2021".logbd VALUES (2948, '2021-04-13', 'postgres', 'DELETE', 'RJ4749');
INSERT INTO "ProdNac2021".logbd VALUES (2949, '2021-04-13', 'postgres', 'DELETE', 'RJ475');
INSERT INTO "ProdNac2021".logbd VALUES (2950, '2021-04-13', 'postgres', 'DELETE', 'RJ4750');
INSERT INTO "ProdNac2021".logbd VALUES (2951, '2021-04-13', 'postgres', 'DELETE', 'RJ4751');
INSERT INTO "ProdNac2021".logbd VALUES (2952, '2021-04-13', 'postgres', 'DELETE', 'RJ4752');
INSERT INTO "ProdNac2021".logbd VALUES (2953, '2021-04-13', 'postgres', 'DELETE', 'RJ4753');
INSERT INTO "ProdNac2021".logbd VALUES (2954, '2021-04-13', 'postgres', 'DELETE', 'RJ4754');
INSERT INTO "ProdNac2021".logbd VALUES (2955, '2021-04-13', 'postgres', 'DELETE', 'RJ4755');
INSERT INTO "ProdNac2021".logbd VALUES (2956, '2021-04-13', 'postgres', 'DELETE', 'RJ4756');
INSERT INTO "ProdNac2021".logbd VALUES (2957, '2021-04-13', 'postgres', 'DELETE', 'RJ4757');
INSERT INTO "ProdNac2021".logbd VALUES (2958, '2021-04-13', 'postgres', 'DELETE', 'RJ4758');
INSERT INTO "ProdNac2021".logbd VALUES (2959, '2021-04-13', 'postgres', 'DELETE', 'RJ4759');
INSERT INTO "ProdNac2021".logbd VALUES (2960, '2021-04-13', 'postgres', 'DELETE', 'RJ476');
INSERT INTO "ProdNac2021".logbd VALUES (2961, '2021-04-13', 'postgres', 'DELETE', 'RJ4760');
INSERT INTO "ProdNac2021".logbd VALUES (2962, '2021-04-13', 'postgres', 'DELETE', 'RJ4761');
INSERT INTO "ProdNac2021".logbd VALUES (2963, '2021-04-13', 'postgres', 'DELETE', 'RJ4762');
INSERT INTO "ProdNac2021".logbd VALUES (2964, '2021-04-13', 'postgres', 'DELETE', 'RJ4763');
INSERT INTO "ProdNac2021".logbd VALUES (2965, '2021-04-13', 'postgres', 'DELETE', 'RJ4764');
INSERT INTO "ProdNac2021".logbd VALUES (2966, '2021-04-13', 'postgres', 'DELETE', 'RJ4765');
INSERT INTO "ProdNac2021".logbd VALUES (2967, '2021-04-13', 'postgres', 'DELETE', 'RJ4766');
INSERT INTO "ProdNac2021".logbd VALUES (2968, '2021-04-13', 'postgres', 'DELETE', 'RJ4767');
INSERT INTO "ProdNac2021".logbd VALUES (2969, '2021-04-13', 'postgres', 'DELETE', 'RJ4768');
INSERT INTO "ProdNac2021".logbd VALUES (2970, '2021-04-13', 'postgres', 'DELETE', 'RJ4769');
INSERT INTO "ProdNac2021".logbd VALUES (2971, '2021-04-13', 'postgres', 'DELETE', 'RJ477');
INSERT INTO "ProdNac2021".logbd VALUES (2972, '2021-04-13', 'postgres', 'DELETE', 'RJ4770');
INSERT INTO "ProdNac2021".logbd VALUES (2973, '2021-04-13', 'postgres', 'DELETE', 'RJ4771');
INSERT INTO "ProdNac2021".logbd VALUES (2974, '2021-04-13', 'postgres', 'DELETE', 'RJ4772');
INSERT INTO "ProdNac2021".logbd VALUES (2975, '2021-04-13', 'postgres', 'DELETE', 'RJ4773');
INSERT INTO "ProdNac2021".logbd VALUES (2976, '2021-04-13', 'postgres', 'DELETE', 'RJ4774');
INSERT INTO "ProdNac2021".logbd VALUES (2977, '2021-04-13', 'postgres', 'DELETE', 'RJ4775');
INSERT INTO "ProdNac2021".logbd VALUES (2978, '2021-04-13', 'postgres', 'DELETE', 'RJ4776');
INSERT INTO "ProdNac2021".logbd VALUES (2979, '2021-04-13', 'postgres', 'DELETE', 'RJ4777');
INSERT INTO "ProdNac2021".logbd VALUES (2980, '2021-04-13', 'postgres', 'DELETE', 'RJ4778');
INSERT INTO "ProdNac2021".logbd VALUES (2981, '2021-04-13', 'postgres', 'DELETE', 'RJ4779');
INSERT INTO "ProdNac2021".logbd VALUES (2982, '2021-04-13', 'postgres', 'DELETE', 'RJ478');
INSERT INTO "ProdNac2021".logbd VALUES (2983, '2021-04-13', 'postgres', 'DELETE', 'RJ4780');
INSERT INTO "ProdNac2021".logbd VALUES (2984, '2021-04-13', 'postgres', 'DELETE', 'RJ4781');
INSERT INTO "ProdNac2021".logbd VALUES (2985, '2021-04-13', 'postgres', 'DELETE', 'RJ4782');
INSERT INTO "ProdNac2021".logbd VALUES (2986, '2021-04-13', 'postgres', 'DELETE', 'RJ4783');
INSERT INTO "ProdNac2021".logbd VALUES (2987, '2021-04-13', 'postgres', 'DELETE', 'RJ4784');
INSERT INTO "ProdNac2021".logbd VALUES (2988, '2021-04-13', 'postgres', 'DELETE', 'RJ4785');
INSERT INTO "ProdNac2021".logbd VALUES (2989, '2021-04-13', 'postgres', 'DELETE', 'RJ4786');
INSERT INTO "ProdNac2021".logbd VALUES (2990, '2021-04-13', 'postgres', 'DELETE', 'RJ4787');
INSERT INTO "ProdNac2021".logbd VALUES (2991, '2021-04-13', 'postgres', 'DELETE', 'RJ4788');
INSERT INTO "ProdNac2021".logbd VALUES (2992, '2021-04-13', 'postgres', 'DELETE', 'RJ4789');
INSERT INTO "ProdNac2021".logbd VALUES (2993, '2021-04-13', 'postgres', 'DELETE', 'RJ479');
INSERT INTO "ProdNac2021".logbd VALUES (2994, '2021-04-13', 'postgres', 'DELETE', 'RJ4790');
INSERT INTO "ProdNac2021".logbd VALUES (2995, '2021-04-13', 'postgres', 'DELETE', 'RJ4791');
INSERT INTO "ProdNac2021".logbd VALUES (2996, '2021-04-13', 'postgres', 'DELETE', 'RJ4792');
INSERT INTO "ProdNac2021".logbd VALUES (2997, '2021-04-13', 'postgres', 'DELETE', 'RJ4793');
INSERT INTO "ProdNac2021".logbd VALUES (2998, '2021-04-13', 'postgres', 'DELETE', 'RJ4794');
INSERT INTO "ProdNac2021".logbd VALUES (2999, '2021-04-13', 'postgres', 'DELETE', 'RJ4795');
INSERT INTO "ProdNac2021".logbd VALUES (3000, '2021-04-13', 'postgres', 'DELETE', 'RJ4796');
INSERT INTO "ProdNac2021".logbd VALUES (3001, '2021-04-13', 'postgres', 'DELETE', 'RJ4797');
INSERT INTO "ProdNac2021".logbd VALUES (3002, '2021-04-13', 'postgres', 'DELETE', 'RJ4798');
INSERT INTO "ProdNac2021".logbd VALUES (3003, '2021-04-13', 'postgres', 'DELETE', 'RJ4799');
INSERT INTO "ProdNac2021".logbd VALUES (3004, '2021-04-13', 'postgres', 'DELETE', 'RJ48');
INSERT INTO "ProdNac2021".logbd VALUES (3005, '2021-04-13', 'postgres', 'DELETE', 'RJ480');
INSERT INTO "ProdNac2021".logbd VALUES (3006, '2021-04-13', 'postgres', 'DELETE', 'RJ4800');
INSERT INTO "ProdNac2021".logbd VALUES (3007, '2021-04-13', 'postgres', 'DELETE', 'RJ4801');
INSERT INTO "ProdNac2021".logbd VALUES (3008, '2021-04-13', 'postgres', 'DELETE', 'RJ4802');
INSERT INTO "ProdNac2021".logbd VALUES (3009, '2021-04-13', 'postgres', 'DELETE', 'RJ4803');
INSERT INTO "ProdNac2021".logbd VALUES (3010, '2021-04-13', 'postgres', 'DELETE', 'RJ4804');
INSERT INTO "ProdNac2021".logbd VALUES (3011, '2021-04-13', 'postgres', 'DELETE', 'RJ4805');
INSERT INTO "ProdNac2021".logbd VALUES (3012, '2021-04-13', 'postgres', 'DELETE', 'RJ4806');
INSERT INTO "ProdNac2021".logbd VALUES (3013, '2021-04-13', 'postgres', 'DELETE', 'RJ4807');
INSERT INTO "ProdNac2021".logbd VALUES (3014, '2021-04-13', 'postgres', 'DELETE', 'RJ4808');
INSERT INTO "ProdNac2021".logbd VALUES (3015, '2021-04-13', 'postgres', 'DELETE', 'RJ4809');
INSERT INTO "ProdNac2021".logbd VALUES (3016, '2021-04-13', 'postgres', 'DELETE', 'RJ481');
INSERT INTO "ProdNac2021".logbd VALUES (3017, '2021-04-13', 'postgres', 'DELETE', 'RJ4810');
INSERT INTO "ProdNac2021".logbd VALUES (3018, '2021-04-13', 'postgres', 'DELETE', 'RJ4811');
INSERT INTO "ProdNac2021".logbd VALUES (3019, '2021-04-13', 'postgres', 'DELETE', 'RJ4812');
INSERT INTO "ProdNac2021".logbd VALUES (3020, '2021-04-13', 'postgres', 'DELETE', 'RJ4813');
INSERT INTO "ProdNac2021".logbd VALUES (3021, '2021-04-13', 'postgres', 'DELETE', 'RJ4814');
INSERT INTO "ProdNac2021".logbd VALUES (3022, '2021-04-13', 'postgres', 'DELETE', 'RJ4815');
INSERT INTO "ProdNac2021".logbd VALUES (3023, '2021-04-13', 'postgres', 'DELETE', 'RJ4816');
INSERT INTO "ProdNac2021".logbd VALUES (3024, '2021-04-13', 'postgres', 'DELETE', 'RJ4817');
INSERT INTO "ProdNac2021".logbd VALUES (3025, '2021-04-13', 'postgres', 'DELETE', 'RJ4818');
INSERT INTO "ProdNac2021".logbd VALUES (3026, '2021-04-13', 'postgres', 'DELETE', 'RJ4819');
INSERT INTO "ProdNac2021".logbd VALUES (3027, '2021-04-13', 'postgres', 'DELETE', 'RJ482');
INSERT INTO "ProdNac2021".logbd VALUES (3028, '2021-04-13', 'postgres', 'DELETE', 'RJ4820');
INSERT INTO "ProdNac2021".logbd VALUES (3029, '2021-04-13', 'postgres', 'DELETE', 'RJ4821');
INSERT INTO "ProdNac2021".logbd VALUES (3030, '2021-04-13', 'postgres', 'DELETE', 'RJ4822');
INSERT INTO "ProdNac2021".logbd VALUES (3031, '2021-04-13', 'postgres', 'DELETE', 'RJ4823');
INSERT INTO "ProdNac2021".logbd VALUES (3032, '2021-04-13', 'postgres', 'DELETE', 'RJ4824');
INSERT INTO "ProdNac2021".logbd VALUES (3033, '2021-04-13', 'postgres', 'DELETE', 'RJ4825');
INSERT INTO "ProdNac2021".logbd VALUES (3034, '2021-04-13', 'postgres', 'DELETE', 'RJ4826');
INSERT INTO "ProdNac2021".logbd VALUES (3035, '2021-04-13', 'postgres', 'DELETE', 'RJ4827');
INSERT INTO "ProdNac2021".logbd VALUES (3036, '2021-04-13', 'postgres', 'DELETE', 'RJ4828');
INSERT INTO "ProdNac2021".logbd VALUES (3037, '2021-04-13', 'postgres', 'DELETE', 'RJ4829');
INSERT INTO "ProdNac2021".logbd VALUES (3038, '2021-04-13', 'postgres', 'DELETE', 'RJ483');
INSERT INTO "ProdNac2021".logbd VALUES (3039, '2021-04-13', 'postgres', 'DELETE', 'RJ4830');
INSERT INTO "ProdNac2021".logbd VALUES (3040, '2021-04-13', 'postgres', 'DELETE', 'RJ4831');
INSERT INTO "ProdNac2021".logbd VALUES (3041, '2021-04-13', 'postgres', 'DELETE', 'RJ4832');
INSERT INTO "ProdNac2021".logbd VALUES (3042, '2021-04-13', 'postgres', 'DELETE', 'RJ4833');
INSERT INTO "ProdNac2021".logbd VALUES (3043, '2021-04-13', 'postgres', 'DELETE', 'RJ4834');
INSERT INTO "ProdNac2021".logbd VALUES (3044, '2021-04-13', 'postgres', 'DELETE', 'RJ4835');
INSERT INTO "ProdNac2021".logbd VALUES (3045, '2021-04-13', 'postgres', 'DELETE', 'RJ4836');
INSERT INTO "ProdNac2021".logbd VALUES (3046, '2021-04-13', 'postgres', 'DELETE', 'RJ4837');
INSERT INTO "ProdNac2021".logbd VALUES (3047, '2021-04-13', 'postgres', 'DELETE', 'RJ4838');
INSERT INTO "ProdNac2021".logbd VALUES (3048, '2021-04-13', 'postgres', 'DELETE', 'RJ4839');
INSERT INTO "ProdNac2021".logbd VALUES (3049, '2021-04-13', 'postgres', 'DELETE', 'RJ484');
INSERT INTO "ProdNac2021".logbd VALUES (3050, '2021-04-13', 'postgres', 'DELETE', 'RJ4840');
INSERT INTO "ProdNac2021".logbd VALUES (3051, '2021-04-13', 'postgres', 'DELETE', 'RJ4841');
INSERT INTO "ProdNac2021".logbd VALUES (3052, '2021-04-13', 'postgres', 'DELETE', 'RJ4842');
INSERT INTO "ProdNac2021".logbd VALUES (3053, '2021-04-13', 'postgres', 'DELETE', 'RJ4843');
INSERT INTO "ProdNac2021".logbd VALUES (3054, '2021-04-13', 'postgres', 'DELETE', 'RJ4844');
INSERT INTO "ProdNac2021".logbd VALUES (3055, '2021-04-13', 'postgres', 'DELETE', 'RJ4845');
INSERT INTO "ProdNac2021".logbd VALUES (3056, '2021-04-13', 'postgres', 'DELETE', 'RJ4846');
INSERT INTO "ProdNac2021".logbd VALUES (3057, '2021-04-13', 'postgres', 'DELETE', 'RJ4847');
INSERT INTO "ProdNac2021".logbd VALUES (3058, '2021-04-13', 'postgres', 'DELETE', 'RJ4848');
INSERT INTO "ProdNac2021".logbd VALUES (3059, '2021-04-13', 'postgres', 'DELETE', 'RJ4849');
INSERT INTO "ProdNac2021".logbd VALUES (3060, '2021-04-13', 'postgres', 'DELETE', 'RJ485');
INSERT INTO "ProdNac2021".logbd VALUES (3061, '2021-04-13', 'postgres', 'DELETE', 'RJ4850');
INSERT INTO "ProdNac2021".logbd VALUES (3062, '2021-04-13', 'postgres', 'DELETE', 'RJ4851');
INSERT INTO "ProdNac2021".logbd VALUES (3063, '2021-04-13', 'postgres', 'DELETE', 'RJ4852');
INSERT INTO "ProdNac2021".logbd VALUES (3064, '2021-04-13', 'postgres', 'DELETE', 'RJ4853');
INSERT INTO "ProdNac2021".logbd VALUES (3065, '2021-04-13', 'postgres', 'DELETE', 'RJ4854');
INSERT INTO "ProdNac2021".logbd VALUES (3066, '2021-04-13', 'postgres', 'DELETE', 'RJ4855');
INSERT INTO "ProdNac2021".logbd VALUES (3067, '2021-04-13', 'postgres', 'DELETE', 'RJ4856');
INSERT INTO "ProdNac2021".logbd VALUES (3068, '2021-04-13', 'postgres', 'DELETE', 'RJ4857');
INSERT INTO "ProdNac2021".logbd VALUES (3069, '2021-04-13', 'postgres', 'DELETE', 'RJ4858');
INSERT INTO "ProdNac2021".logbd VALUES (3070, '2021-04-13', 'postgres', 'DELETE', 'RJ4859');
INSERT INTO "ProdNac2021".logbd VALUES (3071, '2021-04-13', 'postgres', 'DELETE', 'RJ486');
INSERT INTO "ProdNac2021".logbd VALUES (3072, '2021-04-13', 'postgres', 'DELETE', 'RJ4860');
INSERT INTO "ProdNac2021".logbd VALUES (3073, '2021-04-13', 'postgres', 'DELETE', 'RJ4861');
INSERT INTO "ProdNac2021".logbd VALUES (3074, '2021-04-13', 'postgres', 'DELETE', 'RJ4862');
INSERT INTO "ProdNac2021".logbd VALUES (3075, '2021-04-13', 'postgres', 'DELETE', 'RJ4863');
INSERT INTO "ProdNac2021".logbd VALUES (3076, '2021-04-13', 'postgres', 'DELETE', 'RJ4864');
INSERT INTO "ProdNac2021".logbd VALUES (3077, '2021-04-13', 'postgres', 'DELETE', 'RJ4865');
INSERT INTO "ProdNac2021".logbd VALUES (3078, '2021-04-13', 'postgres', 'DELETE', 'RJ4866');
INSERT INTO "ProdNac2021".logbd VALUES (3079, '2021-04-13', 'postgres', 'DELETE', 'RJ4867');
INSERT INTO "ProdNac2021".logbd VALUES (3080, '2021-04-13', 'postgres', 'DELETE', 'RJ4868');
INSERT INTO "ProdNac2021".logbd VALUES (3081, '2021-04-13', 'postgres', 'DELETE', 'RJ4869');
INSERT INTO "ProdNac2021".logbd VALUES (3082, '2021-04-13', 'postgres', 'DELETE', 'RJ487');
INSERT INTO "ProdNac2021".logbd VALUES (3083, '2021-04-13', 'postgres', 'DELETE', 'RJ4870');
INSERT INTO "ProdNac2021".logbd VALUES (3084, '2021-04-13', 'postgres', 'DELETE', 'RJ4871');
INSERT INTO "ProdNac2021".logbd VALUES (3085, '2021-04-13', 'postgres', 'DELETE', 'RJ4872');
INSERT INTO "ProdNac2021".logbd VALUES (3086, '2021-04-13', 'postgres', 'DELETE', 'RJ4873');
INSERT INTO "ProdNac2021".logbd VALUES (3087, '2021-04-13', 'postgres', 'DELETE', 'RJ4874');
INSERT INTO "ProdNac2021".logbd VALUES (3088, '2021-04-13', 'postgres', 'DELETE', 'RJ4875');
INSERT INTO "ProdNac2021".logbd VALUES (3089, '2021-04-13', 'postgres', 'DELETE', 'RJ4876');
INSERT INTO "ProdNac2021".logbd VALUES (3090, '2021-04-13', 'postgres', 'DELETE', 'RJ4877');
INSERT INTO "ProdNac2021".logbd VALUES (3091, '2021-04-13', 'postgres', 'DELETE', 'RJ4878');
INSERT INTO "ProdNac2021".logbd VALUES (3092, '2021-04-13', 'postgres', 'DELETE', 'RJ4879');
INSERT INTO "ProdNac2021".logbd VALUES (3093, '2021-04-13', 'postgres', 'DELETE', 'RJ488');
INSERT INTO "ProdNac2021".logbd VALUES (3094, '2021-04-13', 'postgres', 'DELETE', 'RJ4880');
INSERT INTO "ProdNac2021".logbd VALUES (3095, '2021-04-13', 'postgres', 'DELETE', 'RJ4881');
INSERT INTO "ProdNac2021".logbd VALUES (3096, '2021-04-13', 'postgres', 'DELETE', 'RJ4882');
INSERT INTO "ProdNac2021".logbd VALUES (3097, '2021-04-13', 'postgres', 'DELETE', 'RJ4883');
INSERT INTO "ProdNac2021".logbd VALUES (3098, '2021-04-13', 'postgres', 'DELETE', 'RJ4884');
INSERT INTO "ProdNac2021".logbd VALUES (3099, '2021-04-13', 'postgres', 'DELETE', 'RJ4885');
INSERT INTO "ProdNac2021".logbd VALUES (3100, '2021-04-13', 'postgres', 'DELETE', 'RJ4886');
INSERT INTO "ProdNac2021".logbd VALUES (3101, '2021-04-13', 'postgres', 'DELETE', 'RJ4887');
INSERT INTO "ProdNac2021".logbd VALUES (3102, '2021-04-13', 'postgres', 'DELETE', 'RJ4888');
INSERT INTO "ProdNac2021".logbd VALUES (3103, '2021-04-13', 'postgres', 'DELETE', 'RJ4889');
INSERT INTO "ProdNac2021".logbd VALUES (3104, '2021-04-13', 'postgres', 'DELETE', 'RJ489');
INSERT INTO "ProdNac2021".logbd VALUES (3105, '2021-04-13', 'postgres', 'DELETE', 'RJ4890');
INSERT INTO "ProdNac2021".logbd VALUES (3106, '2021-04-13', 'postgres', 'DELETE', 'RJ4891');
INSERT INTO "ProdNac2021".logbd VALUES (3107, '2021-04-13', 'postgres', 'DELETE', 'RJ4892');
INSERT INTO "ProdNac2021".logbd VALUES (3108, '2021-04-13', 'postgres', 'DELETE', 'RJ4893');
INSERT INTO "ProdNac2021".logbd VALUES (3109, '2021-04-13', 'postgres', 'DELETE', 'RJ4894');
INSERT INTO "ProdNac2021".logbd VALUES (3110, '2021-04-13', 'postgres', 'DELETE', 'RJ4895');
INSERT INTO "ProdNac2021".logbd VALUES (3111, '2021-04-13', 'postgres', 'DELETE', 'RJ4896');
INSERT INTO "ProdNac2021".logbd VALUES (3112, '2021-04-13', 'postgres', 'DELETE', 'RJ4897');
INSERT INTO "ProdNac2021".logbd VALUES (3113, '2021-04-13', 'postgres', 'DELETE', 'RJ4898');
INSERT INTO "ProdNac2021".logbd VALUES (3114, '2021-04-13', 'postgres', 'DELETE', 'RJ4899');
INSERT INTO "ProdNac2021".logbd VALUES (3115, '2021-04-13', 'postgres', 'DELETE', 'RJ49');
INSERT INTO "ProdNac2021".logbd VALUES (3116, '2021-04-13', 'postgres', 'DELETE', 'RJ490');
INSERT INTO "ProdNac2021".logbd VALUES (3117, '2021-04-13', 'postgres', 'DELETE', 'RJ4900');
INSERT INTO "ProdNac2021".logbd VALUES (3118, '2021-04-13', 'postgres', 'DELETE', 'RJ4901');
INSERT INTO "ProdNac2021".logbd VALUES (3119, '2021-04-13', 'postgres', 'DELETE', 'RJ4902');
INSERT INTO "ProdNac2021".logbd VALUES (3120, '2021-04-13', 'postgres', 'DELETE', 'RJ4903');
INSERT INTO "ProdNac2021".logbd VALUES (3121, '2021-04-13', 'postgres', 'DELETE', 'RJ4904');
INSERT INTO "ProdNac2021".logbd VALUES (3122, '2021-04-13', 'postgres', 'DELETE', 'RJ4905');
INSERT INTO "ProdNac2021".logbd VALUES (3123, '2021-04-13', 'postgres', 'DELETE', 'RJ4906');
INSERT INTO "ProdNac2021".logbd VALUES (3124, '2021-04-13', 'postgres', 'DELETE', 'RJ4907');
INSERT INTO "ProdNac2021".logbd VALUES (3125, '2021-04-13', 'postgres', 'DELETE', 'RJ4908');
INSERT INTO "ProdNac2021".logbd VALUES (3126, '2021-04-13', 'postgres', 'DELETE', 'RJ4909');
INSERT INTO "ProdNac2021".logbd VALUES (3127, '2021-04-13', 'postgres', 'DELETE', 'RJ491');
INSERT INTO "ProdNac2021".logbd VALUES (3128, '2021-04-13', 'postgres', 'DELETE', 'RJ4910');
INSERT INTO "ProdNac2021".logbd VALUES (3129, '2021-04-13', 'postgres', 'DELETE', 'RJ4911');
INSERT INTO "ProdNac2021".logbd VALUES (3130, '2021-04-13', 'postgres', 'DELETE', 'RJ4912');
INSERT INTO "ProdNac2021".logbd VALUES (3131, '2021-04-13', 'postgres', 'DELETE', 'RJ4913');
INSERT INTO "ProdNac2021".logbd VALUES (3132, '2021-04-13', 'postgres', 'DELETE', 'RJ4914');
INSERT INTO "ProdNac2021".logbd VALUES (3133, '2021-04-13', 'postgres', 'DELETE', 'RJ4915');
INSERT INTO "ProdNac2021".logbd VALUES (3134, '2021-04-13', 'postgres', 'DELETE', 'RJ4916');
INSERT INTO "ProdNac2021".logbd VALUES (3135, '2021-04-13', 'postgres', 'DELETE', 'RJ4917');
INSERT INTO "ProdNac2021".logbd VALUES (3136, '2021-04-13', 'postgres', 'DELETE', 'RJ4918');
INSERT INTO "ProdNac2021".logbd VALUES (3137, '2021-04-13', 'postgres', 'DELETE', 'RJ4919');
INSERT INTO "ProdNac2021".logbd VALUES (3138, '2021-04-13', 'postgres', 'DELETE', 'RJ492');
INSERT INTO "ProdNac2021".logbd VALUES (3139, '2021-04-13', 'postgres', 'DELETE', 'RJ4920');
INSERT INTO "ProdNac2021".logbd VALUES (3140, '2021-04-13', 'postgres', 'DELETE', 'RJ4921');
INSERT INTO "ProdNac2021".logbd VALUES (3141, '2021-04-13', 'postgres', 'DELETE', 'RJ4922');
INSERT INTO "ProdNac2021".logbd VALUES (3142, '2021-04-13', 'postgres', 'DELETE', 'RJ4923');
INSERT INTO "ProdNac2021".logbd VALUES (3143, '2021-04-13', 'postgres', 'DELETE', 'RJ4924');
INSERT INTO "ProdNac2021".logbd VALUES (3144, '2021-04-13', 'postgres', 'DELETE', 'RJ4925');
INSERT INTO "ProdNac2021".logbd VALUES (3145, '2021-04-13', 'postgres', 'DELETE', 'RJ4926');
INSERT INTO "ProdNac2021".logbd VALUES (3146, '2021-04-13', 'postgres', 'DELETE', 'RJ4927');
INSERT INTO "ProdNac2021".logbd VALUES (3147, '2021-04-13', 'postgres', 'DELETE', 'RJ4928');
INSERT INTO "ProdNac2021".logbd VALUES (3148, '2021-04-13', 'postgres', 'DELETE', 'RJ4929');
INSERT INTO "ProdNac2021".logbd VALUES (3149, '2021-04-13', 'postgres', 'DELETE', 'RJ493');
INSERT INTO "ProdNac2021".logbd VALUES (3150, '2021-04-13', 'postgres', 'DELETE', 'RJ4930');
INSERT INTO "ProdNac2021".logbd VALUES (3151, '2021-04-13', 'postgres', 'DELETE', 'RJ4931');
INSERT INTO "ProdNac2021".logbd VALUES (3152, '2021-04-13', 'postgres', 'DELETE', 'RJ4932');
INSERT INTO "ProdNac2021".logbd VALUES (3153, '2021-04-13', 'postgres', 'DELETE', 'RJ4933');
INSERT INTO "ProdNac2021".logbd VALUES (3154, '2021-04-13', 'postgres', 'DELETE', 'RJ4934');
INSERT INTO "ProdNac2021".logbd VALUES (3155, '2021-04-13', 'postgres', 'DELETE', 'RJ4935');
INSERT INTO "ProdNac2021".logbd VALUES (3156, '2021-04-13', 'postgres', 'DELETE', 'RJ4936');
INSERT INTO "ProdNac2021".logbd VALUES (3157, '2021-04-13', 'postgres', 'DELETE', 'RJ4937');
INSERT INTO "ProdNac2021".logbd VALUES (3158, '2021-04-13', 'postgres', 'DELETE', 'RJ4938');
INSERT INTO "ProdNac2021".logbd VALUES (3159, '2021-04-13', 'postgres', 'DELETE', 'RJ4939');
INSERT INTO "ProdNac2021".logbd VALUES (3160, '2021-04-13', 'postgres', 'DELETE', 'RJ494');
INSERT INTO "ProdNac2021".logbd VALUES (3161, '2021-04-13', 'postgres', 'DELETE', 'RJ4940');
INSERT INTO "ProdNac2021".logbd VALUES (3162, '2021-04-13', 'postgres', 'DELETE', 'RJ4941');
INSERT INTO "ProdNac2021".logbd VALUES (3163, '2021-04-13', 'postgres', 'DELETE', 'RJ4942');
INSERT INTO "ProdNac2021".logbd VALUES (3164, '2021-04-13', 'postgres', 'DELETE', 'RJ4943');
INSERT INTO "ProdNac2021".logbd VALUES (3165, '2021-04-13', 'postgres', 'DELETE', 'RJ4944');
INSERT INTO "ProdNac2021".logbd VALUES (3166, '2021-04-13', 'postgres', 'DELETE', 'RJ4945');
INSERT INTO "ProdNac2021".logbd VALUES (3167, '2021-04-13', 'postgres', 'DELETE', 'RJ4946');
INSERT INTO "ProdNac2021".logbd VALUES (3168, '2021-04-13', 'postgres', 'DELETE', 'RJ4947');
INSERT INTO "ProdNac2021".logbd VALUES (3169, '2021-04-13', 'postgres', 'DELETE', 'RJ4948');
INSERT INTO "ProdNac2021".logbd VALUES (3170, '2021-04-13', 'postgres', 'DELETE', 'RJ4949');
INSERT INTO "ProdNac2021".logbd VALUES (3171, '2021-04-13', 'postgres', 'DELETE', 'RJ495');
INSERT INTO "ProdNac2021".logbd VALUES (3172, '2021-04-13', 'postgres', 'DELETE', 'RJ4950');
INSERT INTO "ProdNac2021".logbd VALUES (3173, '2021-04-13', 'postgres', 'DELETE', 'RJ4951');
INSERT INTO "ProdNac2021".logbd VALUES (3174, '2021-04-13', 'postgres', 'DELETE', 'RJ4952');
INSERT INTO "ProdNac2021".logbd VALUES (3175, '2021-04-13', 'postgres', 'DELETE', 'RJ4953');
INSERT INTO "ProdNac2021".logbd VALUES (3176, '2021-04-13', 'postgres', 'DELETE', 'RJ4954');
INSERT INTO "ProdNac2021".logbd VALUES (3177, '2021-04-13', 'postgres', 'DELETE', 'RJ4955');
INSERT INTO "ProdNac2021".logbd VALUES (3178, '2021-04-13', 'postgres', 'DELETE', 'RJ4956');
INSERT INTO "ProdNac2021".logbd VALUES (3179, '2021-04-13', 'postgres', 'DELETE', 'RJ4957');
INSERT INTO "ProdNac2021".logbd VALUES (3180, '2021-04-13', 'postgres', 'DELETE', 'RJ4958');
INSERT INTO "ProdNac2021".logbd VALUES (3181, '2021-04-13', 'postgres', 'DELETE', 'RJ4959');
INSERT INTO "ProdNac2021".logbd VALUES (3182, '2021-04-13', 'postgres', 'DELETE', 'RJ496');
INSERT INTO "ProdNac2021".logbd VALUES (3183, '2021-04-13', 'postgres', 'DELETE', 'RJ4960');
INSERT INTO "ProdNac2021".logbd VALUES (3184, '2021-04-13', 'postgres', 'DELETE', 'RJ4961');
INSERT INTO "ProdNac2021".logbd VALUES (3185, '2021-04-13', 'postgres', 'DELETE', 'RJ4962');
INSERT INTO "ProdNac2021".logbd VALUES (3186, '2021-04-13', 'postgres', 'DELETE', 'RJ4963');
INSERT INTO "ProdNac2021".logbd VALUES (3187, '2021-04-13', 'postgres', 'DELETE', 'RJ4964');
INSERT INTO "ProdNac2021".logbd VALUES (3188, '2021-04-13', 'postgres', 'DELETE', 'RJ4965');
INSERT INTO "ProdNac2021".logbd VALUES (3189, '2021-04-13', 'postgres', 'DELETE', 'RJ4966');
INSERT INTO "ProdNac2021".logbd VALUES (3190, '2021-04-13', 'postgres', 'DELETE', 'RJ4967');
INSERT INTO "ProdNac2021".logbd VALUES (3191, '2021-04-13', 'postgres', 'DELETE', 'RJ4968');
INSERT INTO "ProdNac2021".logbd VALUES (3192, '2021-04-13', 'postgres', 'DELETE', 'RJ4969');
INSERT INTO "ProdNac2021".logbd VALUES (3193, '2021-04-13', 'postgres', 'DELETE', 'RJ497');
INSERT INTO "ProdNac2021".logbd VALUES (3194, '2021-04-13', 'postgres', 'DELETE', 'RJ4970');
INSERT INTO "ProdNac2021".logbd VALUES (3195, '2021-04-13', 'postgres', 'DELETE', 'RJ4971');
INSERT INTO "ProdNac2021".logbd VALUES (3196, '2021-04-13', 'postgres', 'DELETE', 'RJ4972');
INSERT INTO "ProdNac2021".logbd VALUES (3197, '2021-04-13', 'postgres', 'DELETE', 'RJ4973');
INSERT INTO "ProdNac2021".logbd VALUES (3198, '2021-04-13', 'postgres', 'DELETE', 'RJ4974');
INSERT INTO "ProdNac2021".logbd VALUES (3199, '2021-04-13', 'postgres', 'DELETE', 'RJ4975');
INSERT INTO "ProdNac2021".logbd VALUES (3200, '2021-04-13', 'postgres', 'DELETE', 'RJ4976');
INSERT INTO "ProdNac2021".logbd VALUES (3201, '2021-04-13', 'postgres', 'DELETE', 'RJ4977');
INSERT INTO "ProdNac2021".logbd VALUES (3202, '2021-04-13', 'postgres', 'DELETE', 'RJ4978');
INSERT INTO "ProdNac2021".logbd VALUES (3203, '2021-04-13', 'postgres', 'DELETE', 'RJ4979');
INSERT INTO "ProdNac2021".logbd VALUES (3204, '2021-04-13', 'postgres', 'DELETE', 'RJ498');
INSERT INTO "ProdNac2021".logbd VALUES (3205, '2021-04-13', 'postgres', 'DELETE', 'RJ4980');
INSERT INTO "ProdNac2021".logbd VALUES (3206, '2021-04-13', 'postgres', 'DELETE', 'RJ4981');
INSERT INTO "ProdNac2021".logbd VALUES (3207, '2021-04-13', 'postgres', 'DELETE', 'RJ4982');
INSERT INTO "ProdNac2021".logbd VALUES (3208, '2021-04-13', 'postgres', 'DELETE', 'RJ4983');
INSERT INTO "ProdNac2021".logbd VALUES (3209, '2021-04-13', 'postgres', 'DELETE', 'RJ4984');
INSERT INTO "ProdNac2021".logbd VALUES (3210, '2021-04-13', 'postgres', 'DELETE', 'RJ4985');
INSERT INTO "ProdNac2021".logbd VALUES (3211, '2021-04-13', 'postgres', 'DELETE', 'RJ4986');
INSERT INTO "ProdNac2021".logbd VALUES (3212, '2021-04-13', 'postgres', 'DELETE', 'RJ4987');
INSERT INTO "ProdNac2021".logbd VALUES (3213, '2021-04-13', 'postgres', 'DELETE', 'RJ4988');
INSERT INTO "ProdNac2021".logbd VALUES (3214, '2021-04-13', 'postgres', 'DELETE', 'RJ4989');
INSERT INTO "ProdNac2021".logbd VALUES (3215, '2021-04-13', 'postgres', 'DELETE', 'RJ499');
INSERT INTO "ProdNac2021".logbd VALUES (3216, '2021-04-13', 'postgres', 'DELETE', 'RJ4990');
INSERT INTO "ProdNac2021".logbd VALUES (3217, '2021-04-13', 'postgres', 'DELETE', 'RJ4991');
INSERT INTO "ProdNac2021".logbd VALUES (3218, '2021-04-13', 'postgres', 'DELETE', 'RJ4992');
INSERT INTO "ProdNac2021".logbd VALUES (3219, '2021-04-13', 'postgres', 'DELETE', 'RJ4993');
INSERT INTO "ProdNac2021".logbd VALUES (3220, '2021-04-13', 'postgres', 'DELETE', 'RJ4994');
INSERT INTO "ProdNac2021".logbd VALUES (3221, '2021-04-13', 'postgres', 'DELETE', 'RJ4995');
INSERT INTO "ProdNac2021".logbd VALUES (3222, '2021-04-13', 'postgres', 'DELETE', 'RJ4996');
INSERT INTO "ProdNac2021".logbd VALUES (3223, '2021-04-13', 'postgres', 'DELETE', 'RJ4997');
INSERT INTO "ProdNac2021".logbd VALUES (3224, '2021-04-13', 'postgres', 'DELETE', 'RJ50');
INSERT INTO "ProdNac2021".logbd VALUES (3225, '2021-04-13', 'postgres', 'DELETE', 'RJ500');
INSERT INTO "ProdNac2021".logbd VALUES (3226, '2021-04-13', 'postgres', 'DELETE', 'RJ501');
INSERT INTO "ProdNac2021".logbd VALUES (3227, '2021-04-13', 'postgres', 'DELETE', 'RJ502');
INSERT INTO "ProdNac2021".logbd VALUES (3228, '2021-04-13', 'postgres', 'DELETE', 'RJ503');
INSERT INTO "ProdNac2021".logbd VALUES (3229, '2021-04-13', 'postgres', 'DELETE', 'RJ504');
INSERT INTO "ProdNac2021".logbd VALUES (3230, '2021-04-13', 'postgres', 'DELETE', 'RJ505');
INSERT INTO "ProdNac2021".logbd VALUES (3231, '2021-04-13', 'postgres', 'DELETE', 'RJ506');
INSERT INTO "ProdNac2021".logbd VALUES (3232, '2021-04-13', 'postgres', 'DELETE', 'RJ507');
INSERT INTO "ProdNac2021".logbd VALUES (3233, '2021-04-13', 'postgres', 'DELETE', 'RJ508');
INSERT INTO "ProdNac2021".logbd VALUES (3234, '2021-04-13', 'postgres', 'DELETE', 'RJ509');
INSERT INTO "ProdNac2021".logbd VALUES (3235, '2021-04-13', 'postgres', 'DELETE', 'RJ51');
INSERT INTO "ProdNac2021".logbd VALUES (3236, '2021-04-13', 'postgres', 'DELETE', 'RJ510');
INSERT INTO "ProdNac2021".logbd VALUES (3237, '2021-04-13', 'postgres', 'DELETE', 'RJ511');
INSERT INTO "ProdNac2021".logbd VALUES (3238, '2021-04-13', 'postgres', 'DELETE', 'RJ512');
INSERT INTO "ProdNac2021".logbd VALUES (3239, '2021-04-13', 'postgres', 'DELETE', 'RJ513');
INSERT INTO "ProdNac2021".logbd VALUES (3240, '2021-04-13', 'postgres', 'DELETE', 'RJ514');
INSERT INTO "ProdNac2021".logbd VALUES (3241, '2021-04-13', 'postgres', 'DELETE', 'RJ515');
INSERT INTO "ProdNac2021".logbd VALUES (3242, '2021-04-13', 'postgres', 'DELETE', 'RJ516');
INSERT INTO "ProdNac2021".logbd VALUES (3243, '2021-04-13', 'postgres', 'DELETE', 'RJ517');
INSERT INTO "ProdNac2021".logbd VALUES (3244, '2021-04-13', 'postgres', 'DELETE', 'RJ518');
INSERT INTO "ProdNac2021".logbd VALUES (3245, '2021-04-13', 'postgres', 'DELETE', 'RJ519');
INSERT INTO "ProdNac2021".logbd VALUES (3246, '2021-04-13', 'postgres', 'DELETE', 'RJ52');
INSERT INTO "ProdNac2021".logbd VALUES (3247, '2021-04-13', 'postgres', 'DELETE', 'RJ520');
INSERT INTO "ProdNac2021".logbd VALUES (3248, '2021-04-13', 'postgres', 'DELETE', 'RJ521');
INSERT INTO "ProdNac2021".logbd VALUES (3249, '2021-04-13', 'postgres', 'DELETE', 'RJ522');
INSERT INTO "ProdNac2021".logbd VALUES (3250, '2021-04-13', 'postgres', 'DELETE', 'RJ523');
INSERT INTO "ProdNac2021".logbd VALUES (3251, '2021-04-13', 'postgres', 'DELETE', 'RJ524');
INSERT INTO "ProdNac2021".logbd VALUES (3252, '2021-04-13', 'postgres', 'DELETE', 'RJ525');
INSERT INTO "ProdNac2021".logbd VALUES (3253, '2021-04-13', 'postgres', 'DELETE', 'RJ526');
INSERT INTO "ProdNac2021".logbd VALUES (3254, '2021-04-13', 'postgres', 'DELETE', 'RJ527');
INSERT INTO "ProdNac2021".logbd VALUES (3255, '2021-04-13', 'postgres', 'DELETE', 'RJ528');
INSERT INTO "ProdNac2021".logbd VALUES (3256, '2021-04-13', 'postgres', 'DELETE', 'RJ529');
INSERT INTO "ProdNac2021".logbd VALUES (3257, '2021-04-13', 'postgres', 'DELETE', 'RJ53');
INSERT INTO "ProdNac2021".logbd VALUES (3258, '2021-04-13', 'postgres', 'DELETE', 'RJ530');
INSERT INTO "ProdNac2021".logbd VALUES (3259, '2021-04-13', 'postgres', 'DELETE', 'RJ531');
INSERT INTO "ProdNac2021".logbd VALUES (3260, '2021-04-13', 'postgres', 'DELETE', 'RJ532');
INSERT INTO "ProdNac2021".logbd VALUES (3261, '2021-04-13', 'postgres', 'DELETE', 'RJ533');
INSERT INTO "ProdNac2021".logbd VALUES (3262, '2021-04-13', 'postgres', 'DELETE', 'RJ534');
INSERT INTO "ProdNac2021".logbd VALUES (3263, '2021-04-13', 'postgres', 'DELETE', 'RJ535');
INSERT INTO "ProdNac2021".logbd VALUES (3264, '2021-04-13', 'postgres', 'DELETE', 'RJ536');
INSERT INTO "ProdNac2021".logbd VALUES (3265, '2021-04-13', 'postgres', 'DELETE', 'RJ537');
INSERT INTO "ProdNac2021".logbd VALUES (3266, '2021-04-13', 'postgres', 'DELETE', 'RJ538');
INSERT INTO "ProdNac2021".logbd VALUES (3267, '2021-04-13', 'postgres', 'DELETE', 'RJ539');
INSERT INTO "ProdNac2021".logbd VALUES (3268, '2021-04-13', 'postgres', 'DELETE', 'RJ54');
INSERT INTO "ProdNac2021".logbd VALUES (3269, '2021-04-13', 'postgres', 'DELETE', 'RJ540');
INSERT INTO "ProdNac2021".logbd VALUES (3270, '2021-04-13', 'postgres', 'DELETE', 'RJ541');
INSERT INTO "ProdNac2021".logbd VALUES (3271, '2021-04-13', 'postgres', 'DELETE', 'RJ542');
INSERT INTO "ProdNac2021".logbd VALUES (3272, '2021-04-13', 'postgres', 'DELETE', 'RJ543');
INSERT INTO "ProdNac2021".logbd VALUES (3273, '2021-04-13', 'postgres', 'DELETE', 'RJ544');
INSERT INTO "ProdNac2021".logbd VALUES (3274, '2021-04-13', 'postgres', 'DELETE', 'RJ545');
INSERT INTO "ProdNac2021".logbd VALUES (3275, '2021-04-13', 'postgres', 'DELETE', 'RJ546');
INSERT INTO "ProdNac2021".logbd VALUES (3276, '2021-04-13', 'postgres', 'DELETE', 'RJ547');
INSERT INTO "ProdNac2021".logbd VALUES (3277, '2021-04-13', 'postgres', 'DELETE', 'RJ548');
INSERT INTO "ProdNac2021".logbd VALUES (3278, '2021-04-13', 'postgres', 'DELETE', 'RJ549');
INSERT INTO "ProdNac2021".logbd VALUES (3279, '2021-04-13', 'postgres', 'DELETE', 'RJ55');
INSERT INTO "ProdNac2021".logbd VALUES (3280, '2021-04-13', 'postgres', 'DELETE', 'RJ550');
INSERT INTO "ProdNac2021".logbd VALUES (3281, '2021-04-13', 'postgres', 'DELETE', 'RJ551');
INSERT INTO "ProdNac2021".logbd VALUES (3282, '2021-04-13', 'postgres', 'DELETE', 'RJ552');
INSERT INTO "ProdNac2021".logbd VALUES (3283, '2021-04-13', 'postgres', 'DELETE', 'RJ553');
INSERT INTO "ProdNac2021".logbd VALUES (3284, '2021-04-13', 'postgres', 'DELETE', 'RJ554');
INSERT INTO "ProdNac2021".logbd VALUES (3285, '2021-04-13', 'postgres', 'DELETE', 'RJ555');
INSERT INTO "ProdNac2021".logbd VALUES (3286, '2021-04-13', 'postgres', 'DELETE', 'RJ556');
INSERT INTO "ProdNac2021".logbd VALUES (3287, '2021-04-13', 'postgres', 'DELETE', 'RJ557');
INSERT INTO "ProdNac2021".logbd VALUES (3288, '2021-04-13', 'postgres', 'DELETE', 'RJ558');
INSERT INTO "ProdNac2021".logbd VALUES (3289, '2021-04-13', 'postgres', 'DELETE', 'RJ559');
INSERT INTO "ProdNac2021".logbd VALUES (3290, '2021-04-13', 'postgres', 'DELETE', 'RJ56');
INSERT INTO "ProdNac2021".logbd VALUES (3291, '2021-04-13', 'postgres', 'DELETE', 'RJ560');
INSERT INTO "ProdNac2021".logbd VALUES (3292, '2021-04-13', 'postgres', 'DELETE', 'RJ561');
INSERT INTO "ProdNac2021".logbd VALUES (3293, '2021-04-13', 'postgres', 'DELETE', 'RJ562');
INSERT INTO "ProdNac2021".logbd VALUES (3294, '2021-04-13', 'postgres', 'DELETE', 'RJ563');
INSERT INTO "ProdNac2021".logbd VALUES (3295, '2021-04-13', 'postgres', 'DELETE', 'RJ564');
INSERT INTO "ProdNac2021".logbd VALUES (3296, '2021-04-13', 'postgres', 'DELETE', 'RJ565');
INSERT INTO "ProdNac2021".logbd VALUES (3297, '2021-04-13', 'postgres', 'DELETE', 'RJ566');
INSERT INTO "ProdNac2021".logbd VALUES (3298, '2021-04-13', 'postgres', 'DELETE', 'RJ567');
INSERT INTO "ProdNac2021".logbd VALUES (3299, '2021-04-13', 'postgres', 'DELETE', 'RJ568');
INSERT INTO "ProdNac2021".logbd VALUES (3300, '2021-04-13', 'postgres', 'DELETE', 'RJ569');
INSERT INTO "ProdNac2021".logbd VALUES (3301, '2021-04-13', 'postgres', 'DELETE', 'RJ57');
INSERT INTO "ProdNac2021".logbd VALUES (3302, '2021-04-13', 'postgres', 'DELETE', 'RJ570');
INSERT INTO "ProdNac2021".logbd VALUES (3303, '2021-04-13', 'postgres', 'DELETE', 'RJ571');
INSERT INTO "ProdNac2021".logbd VALUES (3304, '2021-04-13', 'postgres', 'DELETE', 'RJ572');
INSERT INTO "ProdNac2021".logbd VALUES (3305, '2021-04-13', 'postgres', 'DELETE', 'RJ573');
INSERT INTO "ProdNac2021".logbd VALUES (3306, '2021-04-13', 'postgres', 'DELETE', 'RJ574');
INSERT INTO "ProdNac2021".logbd VALUES (3307, '2021-04-13', 'postgres', 'DELETE', 'RJ575');
INSERT INTO "ProdNac2021".logbd VALUES (3308, '2021-04-13', 'postgres', 'DELETE', 'RJ576');
INSERT INTO "ProdNac2021".logbd VALUES (3309, '2021-04-13', 'postgres', 'DELETE', 'RJ577');
INSERT INTO "ProdNac2021".logbd VALUES (3310, '2021-04-13', 'postgres', 'DELETE', 'RJ578');
INSERT INTO "ProdNac2021".logbd VALUES (3311, '2021-04-13', 'postgres', 'DELETE', 'RJ579');
INSERT INTO "ProdNac2021".logbd VALUES (3312, '2021-04-13', 'postgres', 'DELETE', 'RJ58');
INSERT INTO "ProdNac2021".logbd VALUES (3313, '2021-04-13', 'postgres', 'DELETE', 'RJ580');
INSERT INTO "ProdNac2021".logbd VALUES (3314, '2021-04-13', 'postgres', 'DELETE', 'RJ581');
INSERT INTO "ProdNac2021".logbd VALUES (3315, '2021-04-13', 'postgres', 'DELETE', 'RJ582');
INSERT INTO "ProdNac2021".logbd VALUES (3316, '2021-04-13', 'postgres', 'DELETE', 'RJ583');
INSERT INTO "ProdNac2021".logbd VALUES (3317, '2021-04-13', 'postgres', 'DELETE', 'RJ584');
INSERT INTO "ProdNac2021".logbd VALUES (3318, '2021-04-13', 'postgres', 'DELETE', 'RJ585');
INSERT INTO "ProdNac2021".logbd VALUES (3319, '2021-04-13', 'postgres', 'DELETE', 'RJ586');
INSERT INTO "ProdNac2021".logbd VALUES (3320, '2021-04-13', 'postgres', 'DELETE', 'RJ587');
INSERT INTO "ProdNac2021".logbd VALUES (3321, '2021-04-13', 'postgres', 'DELETE', 'RJ588');
INSERT INTO "ProdNac2021".logbd VALUES (3322, '2021-04-13', 'postgres', 'DELETE', 'RJ589');
INSERT INTO "ProdNac2021".logbd VALUES (3323, '2021-04-13', 'postgres', 'DELETE', 'RJ59');
INSERT INTO "ProdNac2021".logbd VALUES (3324, '2021-04-13', 'postgres', 'DELETE', 'RJ590');
INSERT INTO "ProdNac2021".logbd VALUES (3325, '2021-04-13', 'postgres', 'DELETE', 'RJ591');
INSERT INTO "ProdNac2021".logbd VALUES (3326, '2021-04-13', 'postgres', 'DELETE', 'RJ592');
INSERT INTO "ProdNac2021".logbd VALUES (3327, '2021-04-13', 'postgres', 'DELETE', 'RJ593');
INSERT INTO "ProdNac2021".logbd VALUES (3328, '2021-04-13', 'postgres', 'DELETE', 'RJ594');
INSERT INTO "ProdNac2021".logbd VALUES (3329, '2021-04-13', 'postgres', 'DELETE', 'RJ595');
INSERT INTO "ProdNac2021".logbd VALUES (3330, '2021-04-13', 'postgres', 'DELETE', 'RJ596');
INSERT INTO "ProdNac2021".logbd VALUES (3331, '2021-04-13', 'postgres', 'DELETE', 'RJ597');
INSERT INTO "ProdNac2021".logbd VALUES (3332, '2021-04-13', 'postgres', 'DELETE', 'RJ598');
INSERT INTO "ProdNac2021".logbd VALUES (3333, '2021-04-13', 'postgres', 'DELETE', 'RJ599');
INSERT INTO "ProdNac2021".logbd VALUES (3334, '2021-04-13', 'postgres', 'DELETE', 'RJ60');
INSERT INTO "ProdNac2021".logbd VALUES (3335, '2021-04-13', 'postgres', 'DELETE', 'RJ600');
INSERT INTO "ProdNac2021".logbd VALUES (3336, '2021-04-13', 'postgres', 'DELETE', 'RJ601');
INSERT INTO "ProdNac2021".logbd VALUES (3337, '2021-04-13', 'postgres', 'DELETE', 'RJ602');
INSERT INTO "ProdNac2021".logbd VALUES (3338, '2021-04-13', 'postgres', 'DELETE', 'RJ603');
INSERT INTO "ProdNac2021".logbd VALUES (3339, '2021-04-13', 'postgres', 'DELETE', 'RJ604');
INSERT INTO "ProdNac2021".logbd VALUES (3340, '2021-04-13', 'postgres', 'DELETE', 'RJ605');
INSERT INTO "ProdNac2021".logbd VALUES (3341, '2021-04-13', 'postgres', 'DELETE', 'RJ606');
INSERT INTO "ProdNac2021".logbd VALUES (3342, '2021-04-13', 'postgres', 'DELETE', 'RJ607');
INSERT INTO "ProdNac2021".logbd VALUES (3343, '2021-04-13', 'postgres', 'DELETE', 'RJ608');
INSERT INTO "ProdNac2021".logbd VALUES (3344, '2021-04-13', 'postgres', 'DELETE', 'RJ609');
INSERT INTO "ProdNac2021".logbd VALUES (3345, '2021-04-13', 'postgres', 'DELETE', 'RJ61');
INSERT INTO "ProdNac2021".logbd VALUES (3346, '2021-04-13', 'postgres', 'DELETE', 'RJ610');
INSERT INTO "ProdNac2021".logbd VALUES (3347, '2021-04-13', 'postgres', 'DELETE', 'RJ611');
INSERT INTO "ProdNac2021".logbd VALUES (3348, '2021-04-13', 'postgres', 'DELETE', 'RJ612');
INSERT INTO "ProdNac2021".logbd VALUES (3349, '2021-04-13', 'postgres', 'DELETE', 'RJ613');
INSERT INTO "ProdNac2021".logbd VALUES (3350, '2021-04-13', 'postgres', 'DELETE', 'RJ614');
INSERT INTO "ProdNac2021".logbd VALUES (3351, '2021-04-13', 'postgres', 'DELETE', 'RJ615');
INSERT INTO "ProdNac2021".logbd VALUES (3352, '2021-04-13', 'postgres', 'DELETE', 'RJ616');
INSERT INTO "ProdNac2021".logbd VALUES (3353, '2021-04-13', 'postgres', 'DELETE', 'RJ617');
INSERT INTO "ProdNac2021".logbd VALUES (3354, '2021-04-13', 'postgres', 'DELETE', 'RJ618');
INSERT INTO "ProdNac2021".logbd VALUES (3355, '2021-04-13', 'postgres', 'DELETE', 'RJ619');
INSERT INTO "ProdNac2021".logbd VALUES (3356, '2021-04-13', 'postgres', 'DELETE', 'RJ62');
INSERT INTO "ProdNac2021".logbd VALUES (3357, '2021-04-13', 'postgres', 'DELETE', 'RJ620');
INSERT INTO "ProdNac2021".logbd VALUES (3358, '2021-04-13', 'postgres', 'DELETE', 'RJ621');
INSERT INTO "ProdNac2021".logbd VALUES (3359, '2021-04-13', 'postgres', 'DELETE', 'RJ622');
INSERT INTO "ProdNac2021".logbd VALUES (3360, '2021-04-13', 'postgres', 'DELETE', 'RJ623');
INSERT INTO "ProdNac2021".logbd VALUES (3361, '2021-04-13', 'postgres', 'DELETE', 'RJ624');
INSERT INTO "ProdNac2021".logbd VALUES (3362, '2021-04-13', 'postgres', 'DELETE', 'RJ625');
INSERT INTO "ProdNac2021".logbd VALUES (3363, '2021-04-13', 'postgres', 'DELETE', 'RJ626');
INSERT INTO "ProdNac2021".logbd VALUES (3364, '2021-04-13', 'postgres', 'DELETE', 'RJ627');
INSERT INTO "ProdNac2021".logbd VALUES (3365, '2021-04-13', 'postgres', 'DELETE', 'RJ628');
INSERT INTO "ProdNac2021".logbd VALUES (3366, '2021-04-13', 'postgres', 'DELETE', 'RJ629');
INSERT INTO "ProdNac2021".logbd VALUES (3367, '2021-04-13', 'postgres', 'DELETE', 'RJ63');
INSERT INTO "ProdNac2021".logbd VALUES (3368, '2021-04-13', 'postgres', 'DELETE', 'RJ630');
INSERT INTO "ProdNac2021".logbd VALUES (3369, '2021-04-13', 'postgres', 'DELETE', 'RJ631');
INSERT INTO "ProdNac2021".logbd VALUES (3370, '2021-04-13', 'postgres', 'DELETE', 'RJ632');
INSERT INTO "ProdNac2021".logbd VALUES (3371, '2021-04-13', 'postgres', 'DELETE', 'RJ633');
INSERT INTO "ProdNac2021".logbd VALUES (3372, '2021-04-13', 'postgres', 'DELETE', 'RJ634');
INSERT INTO "ProdNac2021".logbd VALUES (3373, '2021-04-13', 'postgres', 'DELETE', 'RJ635');
INSERT INTO "ProdNac2021".logbd VALUES (3374, '2021-04-13', 'postgres', 'DELETE', 'RJ636');
INSERT INTO "ProdNac2021".logbd VALUES (3375, '2021-04-13', 'postgres', 'DELETE', 'RJ637');
INSERT INTO "ProdNac2021".logbd VALUES (3376, '2021-04-13', 'postgres', 'DELETE', 'RJ638');
INSERT INTO "ProdNac2021".logbd VALUES (3377, '2021-04-13', 'postgres', 'DELETE', 'RJ639');
INSERT INTO "ProdNac2021".logbd VALUES (3378, '2021-04-13', 'postgres', 'DELETE', 'RJ64');
INSERT INTO "ProdNac2021".logbd VALUES (3379, '2021-04-13', 'postgres', 'DELETE', 'RJ640');
INSERT INTO "ProdNac2021".logbd VALUES (3380, '2021-04-13', 'postgres', 'DELETE', 'RJ641');
INSERT INTO "ProdNac2021".logbd VALUES (3381, '2021-04-13', 'postgres', 'DELETE', 'RJ642');
INSERT INTO "ProdNac2021".logbd VALUES (3382, '2021-04-13', 'postgres', 'DELETE', 'RJ643');
INSERT INTO "ProdNac2021".logbd VALUES (3383, '2021-04-13', 'postgres', 'DELETE', 'RJ644');
INSERT INTO "ProdNac2021".logbd VALUES (3384, '2021-04-13', 'postgres', 'DELETE', 'RJ645');
INSERT INTO "ProdNac2021".logbd VALUES (3385, '2021-04-13', 'postgres', 'DELETE', 'RJ646');
INSERT INTO "ProdNac2021".logbd VALUES (3386, '2021-04-13', 'postgres', 'DELETE', 'RJ647');
INSERT INTO "ProdNac2021".logbd VALUES (3387, '2021-04-13', 'postgres', 'DELETE', 'RJ648');
INSERT INTO "ProdNac2021".logbd VALUES (3388, '2021-04-13', 'postgres', 'DELETE', 'RJ649');
INSERT INTO "ProdNac2021".logbd VALUES (3389, '2021-04-13', 'postgres', 'DELETE', 'RJ65');
INSERT INTO "ProdNac2021".logbd VALUES (3390, '2021-04-13', 'postgres', 'DELETE', 'RJ650');
INSERT INTO "ProdNac2021".logbd VALUES (3391, '2021-04-13', 'postgres', 'DELETE', 'RJ651');
INSERT INTO "ProdNac2021".logbd VALUES (3392, '2021-04-13', 'postgres', 'DELETE', 'RJ652');
INSERT INTO "ProdNac2021".logbd VALUES (3393, '2021-04-13', 'postgres', 'DELETE', 'RJ653');
INSERT INTO "ProdNac2021".logbd VALUES (3394, '2021-04-13', 'postgres', 'DELETE', 'RJ654');
INSERT INTO "ProdNac2021".logbd VALUES (3395, '2021-04-13', 'postgres', 'DELETE', 'RJ655');
INSERT INTO "ProdNac2021".logbd VALUES (3396, '2021-04-13', 'postgres', 'DELETE', 'RJ656');
INSERT INTO "ProdNac2021".logbd VALUES (3397, '2021-04-13', 'postgres', 'DELETE', 'RJ657');
INSERT INTO "ProdNac2021".logbd VALUES (3398, '2021-04-13', 'postgres', 'DELETE', 'RJ658');
INSERT INTO "ProdNac2021".logbd VALUES (3399, '2021-04-13', 'postgres', 'DELETE', 'RJ659');
INSERT INTO "ProdNac2021".logbd VALUES (3400, '2021-04-13', 'postgres', 'DELETE', 'RJ66');
INSERT INTO "ProdNac2021".logbd VALUES (3401, '2021-04-13', 'postgres', 'DELETE', 'RJ660');
INSERT INTO "ProdNac2021".logbd VALUES (3402, '2021-04-13', 'postgres', 'DELETE', 'RJ661');
INSERT INTO "ProdNac2021".logbd VALUES (3403, '2021-04-13', 'postgres', 'DELETE', 'RJ662');
INSERT INTO "ProdNac2021".logbd VALUES (3404, '2021-04-13', 'postgres', 'DELETE', 'RJ663');
INSERT INTO "ProdNac2021".logbd VALUES (3405, '2021-04-13', 'postgres', 'DELETE', 'RJ664');
INSERT INTO "ProdNac2021".logbd VALUES (3406, '2021-04-13', 'postgres', 'DELETE', 'RJ665');
INSERT INTO "ProdNac2021".logbd VALUES (3407, '2021-04-13', 'postgres', 'DELETE', 'RJ666');
INSERT INTO "ProdNac2021".logbd VALUES (3408, '2021-04-13', 'postgres', 'DELETE', 'RJ667');
INSERT INTO "ProdNac2021".logbd VALUES (3409, '2021-04-13', 'postgres', 'DELETE', 'RJ668');
INSERT INTO "ProdNac2021".logbd VALUES (3410, '2021-04-13', 'postgres', 'DELETE', 'RJ669');
INSERT INTO "ProdNac2021".logbd VALUES (3411, '2021-04-13', 'postgres', 'DELETE', 'RJ67');
INSERT INTO "ProdNac2021".logbd VALUES (3412, '2021-04-13', 'postgres', 'DELETE', 'RJ670');
INSERT INTO "ProdNac2021".logbd VALUES (3413, '2021-04-13', 'postgres', 'DELETE', 'RJ671');
INSERT INTO "ProdNac2021".logbd VALUES (3414, '2021-04-13', 'postgres', 'DELETE', 'RJ672');
INSERT INTO "ProdNac2021".logbd VALUES (3415, '2021-04-13', 'postgres', 'DELETE', 'RJ673');
INSERT INTO "ProdNac2021".logbd VALUES (3416, '2021-04-13', 'postgres', 'DELETE', 'RJ674');
INSERT INTO "ProdNac2021".logbd VALUES (3417, '2021-04-13', 'postgres', 'DELETE', 'RJ675');
INSERT INTO "ProdNac2021".logbd VALUES (3418, '2021-04-13', 'postgres', 'DELETE', 'RJ676');
INSERT INTO "ProdNac2021".logbd VALUES (3419, '2021-04-13', 'postgres', 'DELETE', 'RJ677');
INSERT INTO "ProdNac2021".logbd VALUES (3420, '2021-04-13', 'postgres', 'DELETE', 'RJ678');
INSERT INTO "ProdNac2021".logbd VALUES (3421, '2021-04-13', 'postgres', 'DELETE', 'RJ679');
INSERT INTO "ProdNac2021".logbd VALUES (3422, '2021-04-13', 'postgres', 'DELETE', 'RJ68');
INSERT INTO "ProdNac2021".logbd VALUES (3423, '2021-04-13', 'postgres', 'DELETE', 'RJ680');
INSERT INTO "ProdNac2021".logbd VALUES (3424, '2021-04-13', 'postgres', 'DELETE', 'RJ681');
INSERT INTO "ProdNac2021".logbd VALUES (3425, '2021-04-13', 'postgres', 'DELETE', 'RJ682');
INSERT INTO "ProdNac2021".logbd VALUES (3426, '2021-04-13', 'postgres', 'DELETE', 'RJ683');
INSERT INTO "ProdNac2021".logbd VALUES (3427, '2021-04-13', 'postgres', 'DELETE', 'RJ684');
INSERT INTO "ProdNac2021".logbd VALUES (3428, '2021-04-13', 'postgres', 'DELETE', 'RJ685');
INSERT INTO "ProdNac2021".logbd VALUES (3429, '2021-04-13', 'postgres', 'DELETE', 'RJ686');
INSERT INTO "ProdNac2021".logbd VALUES (3430, '2021-04-13', 'postgres', 'DELETE', 'RJ687');
INSERT INTO "ProdNac2021".logbd VALUES (3431, '2021-04-13', 'postgres', 'DELETE', 'RJ688');
INSERT INTO "ProdNac2021".logbd VALUES (3432, '2021-04-13', 'postgres', 'DELETE', 'RJ689');
INSERT INTO "ProdNac2021".logbd VALUES (3433, '2021-04-13', 'postgres', 'DELETE', 'RJ690');
INSERT INTO "ProdNac2021".logbd VALUES (3434, '2021-04-13', 'postgres', 'DELETE', 'RJ691');
INSERT INTO "ProdNac2021".logbd VALUES (3435, '2021-04-13', 'postgres', 'DELETE', 'RJ692');
INSERT INTO "ProdNac2021".logbd VALUES (3436, '2021-04-13', 'postgres', 'DELETE', 'RJ693');
INSERT INTO "ProdNac2021".logbd VALUES (3437, '2021-04-13', 'postgres', 'DELETE', 'RJ694');
INSERT INTO "ProdNac2021".logbd VALUES (3438, '2021-04-13', 'postgres', 'DELETE', 'RJ695');
INSERT INTO "ProdNac2021".logbd VALUES (3439, '2021-04-13', 'postgres', 'DELETE', 'RJ696');
INSERT INTO "ProdNac2021".logbd VALUES (3440, '2021-04-13', 'postgres', 'DELETE', 'RJ697');
INSERT INTO "ProdNac2021".logbd VALUES (3441, '2021-04-13', 'postgres', 'DELETE', 'RJ698');
INSERT INTO "ProdNac2021".logbd VALUES (3442, '2021-04-13', 'postgres', 'DELETE', 'RJ699');
INSERT INTO "ProdNac2021".logbd VALUES (3443, '2021-04-13', 'postgres', 'DELETE', 'RJ70');
INSERT INTO "ProdNac2021".logbd VALUES (3444, '2021-04-13', 'postgres', 'DELETE', 'RJ700');
INSERT INTO "ProdNac2021".logbd VALUES (3445, '2021-04-13', 'postgres', 'DELETE', 'RJ701');
INSERT INTO "ProdNac2021".logbd VALUES (3446, '2021-04-13', 'postgres', 'DELETE', 'RJ702');
INSERT INTO "ProdNac2021".logbd VALUES (3447, '2021-04-13', 'postgres', 'DELETE', 'RJ703');
INSERT INTO "ProdNac2021".logbd VALUES (3448, '2021-04-13', 'postgres', 'DELETE', 'RJ704');
INSERT INTO "ProdNac2021".logbd VALUES (3449, '2021-04-13', 'postgres', 'DELETE', 'RJ705');
INSERT INTO "ProdNac2021".logbd VALUES (3450, '2021-04-13', 'postgres', 'DELETE', 'RJ706');
INSERT INTO "ProdNac2021".logbd VALUES (3451, '2021-04-13', 'postgres', 'DELETE', 'RJ707');
INSERT INTO "ProdNac2021".logbd VALUES (3452, '2021-04-13', 'postgres', 'DELETE', 'RJ708');
INSERT INTO "ProdNac2021".logbd VALUES (3453, '2021-04-13', 'postgres', 'DELETE', 'RJ709');
INSERT INTO "ProdNac2021".logbd VALUES (3454, '2021-04-13', 'postgres', 'DELETE', 'RJ71');
INSERT INTO "ProdNac2021".logbd VALUES (3455, '2021-04-13', 'postgres', 'DELETE', 'RJ710');
INSERT INTO "ProdNac2021".logbd VALUES (3456, '2021-04-13', 'postgres', 'DELETE', 'RJ711');
INSERT INTO "ProdNac2021".logbd VALUES (3457, '2021-04-13', 'postgres', 'DELETE', 'RJ712');
INSERT INTO "ProdNac2021".logbd VALUES (3458, '2021-04-13', 'postgres', 'DELETE', 'RJ713');
INSERT INTO "ProdNac2021".logbd VALUES (3459, '2021-04-13', 'postgres', 'DELETE', 'RJ714');
INSERT INTO "ProdNac2021".logbd VALUES (3460, '2021-04-13', 'postgres', 'DELETE', 'RJ715');
INSERT INTO "ProdNac2021".logbd VALUES (3461, '2021-04-13', 'postgres', 'DELETE', 'RJ716');
INSERT INTO "ProdNac2021".logbd VALUES (3462, '2021-04-13', 'postgres', 'DELETE', 'RJ717');
INSERT INTO "ProdNac2021".logbd VALUES (3463, '2021-04-13', 'postgres', 'DELETE', 'RJ718');
INSERT INTO "ProdNac2021".logbd VALUES (3464, '2021-04-13', 'postgres', 'DELETE', 'RJ719');
INSERT INTO "ProdNac2021".logbd VALUES (3465, '2021-04-13', 'postgres', 'DELETE', 'RJ72');
INSERT INTO "ProdNac2021".logbd VALUES (3466, '2021-04-13', 'postgres', 'DELETE', 'RJ720');
INSERT INTO "ProdNac2021".logbd VALUES (3467, '2021-04-13', 'postgres', 'DELETE', 'RJ721');
INSERT INTO "ProdNac2021".logbd VALUES (3468, '2021-04-13', 'postgres', 'DELETE', 'RJ722');
INSERT INTO "ProdNac2021".logbd VALUES (3469, '2021-04-13', 'postgres', 'DELETE', 'RJ723');
INSERT INTO "ProdNac2021".logbd VALUES (3470, '2021-04-13', 'postgres', 'DELETE', 'RJ724');
INSERT INTO "ProdNac2021".logbd VALUES (3471, '2021-04-13', 'postgres', 'DELETE', 'RJ725');
INSERT INTO "ProdNac2021".logbd VALUES (3472, '2021-04-13', 'postgres', 'DELETE', 'RJ726');
INSERT INTO "ProdNac2021".logbd VALUES (3473, '2021-04-13', 'postgres', 'DELETE', 'RJ727');
INSERT INTO "ProdNac2021".logbd VALUES (3474, '2021-04-13', 'postgres', 'DELETE', 'RJ728');
INSERT INTO "ProdNac2021".logbd VALUES (3475, '2021-04-13', 'postgres', 'DELETE', 'RJ729');
INSERT INTO "ProdNac2021".logbd VALUES (3476, '2021-04-13', 'postgres', 'DELETE', 'RJ73');
INSERT INTO "ProdNac2021".logbd VALUES (3477, '2021-04-13', 'postgres', 'DELETE', 'RJ730');
INSERT INTO "ProdNac2021".logbd VALUES (3478, '2021-04-13', 'postgres', 'DELETE', 'RJ731');
INSERT INTO "ProdNac2021".logbd VALUES (3479, '2021-04-13', 'postgres', 'DELETE', 'RJ732');
INSERT INTO "ProdNac2021".logbd VALUES (3480, '2021-04-13', 'postgres', 'DELETE', 'RJ733');
INSERT INTO "ProdNac2021".logbd VALUES (3481, '2021-04-13', 'postgres', 'DELETE', 'RJ734');
INSERT INTO "ProdNac2021".logbd VALUES (3482, '2021-04-13', 'postgres', 'DELETE', 'RJ735');
INSERT INTO "ProdNac2021".logbd VALUES (3483, '2021-04-13', 'postgres', 'DELETE', 'RJ736');
INSERT INTO "ProdNac2021".logbd VALUES (3484, '2021-04-13', 'postgres', 'DELETE', 'RJ737');
INSERT INTO "ProdNac2021".logbd VALUES (3485, '2021-04-13', 'postgres', 'DELETE', 'RJ738');
INSERT INTO "ProdNac2021".logbd VALUES (3486, '2021-04-13', 'postgres', 'DELETE', 'RJ739');
INSERT INTO "ProdNac2021".logbd VALUES (3487, '2021-04-13', 'postgres', 'DELETE', 'RJ74');
INSERT INTO "ProdNac2021".logbd VALUES (3488, '2021-04-13', 'postgres', 'DELETE', 'RJ740');
INSERT INTO "ProdNac2021".logbd VALUES (3489, '2021-04-13', 'postgres', 'DELETE', 'RJ741');
INSERT INTO "ProdNac2021".logbd VALUES (3490, '2021-04-13', 'postgres', 'DELETE', 'RJ742');
INSERT INTO "ProdNac2021".logbd VALUES (3491, '2021-04-13', 'postgres', 'DELETE', 'RJ743');
INSERT INTO "ProdNac2021".logbd VALUES (3492, '2021-04-13', 'postgres', 'DELETE', 'RJ744');
INSERT INTO "ProdNac2021".logbd VALUES (3493, '2021-04-13', 'postgres', 'DELETE', 'RJ745');
INSERT INTO "ProdNac2021".logbd VALUES (3494, '2021-04-13', 'postgres', 'DELETE', 'RJ746');
INSERT INTO "ProdNac2021".logbd VALUES (3495, '2021-04-13', 'postgres', 'DELETE', 'RJ747');
INSERT INTO "ProdNac2021".logbd VALUES (3496, '2021-04-13', 'postgres', 'DELETE', 'RJ748');
INSERT INTO "ProdNac2021".logbd VALUES (3497, '2021-04-13', 'postgres', 'DELETE', 'RJ749');
INSERT INTO "ProdNac2021".logbd VALUES (3498, '2021-04-13', 'postgres', 'DELETE', 'RJ75');
INSERT INTO "ProdNac2021".logbd VALUES (3499, '2021-04-13', 'postgres', 'DELETE', 'RJ750');
INSERT INTO "ProdNac2021".logbd VALUES (3500, '2021-04-13', 'postgres', 'DELETE', 'RJ751');
INSERT INTO "ProdNac2021".logbd VALUES (3501, '2021-04-13', 'postgres', 'DELETE', 'RJ752');
INSERT INTO "ProdNac2021".logbd VALUES (3502, '2021-04-13', 'postgres', 'DELETE', 'RJ753');
INSERT INTO "ProdNac2021".logbd VALUES (3503, '2021-04-13', 'postgres', 'DELETE', 'RJ754');
INSERT INTO "ProdNac2021".logbd VALUES (3504, '2021-04-13', 'postgres', 'DELETE', 'RJ755');
INSERT INTO "ProdNac2021".logbd VALUES (3505, '2021-04-13', 'postgres', 'DELETE', 'RJ756');
INSERT INTO "ProdNac2021".logbd VALUES (3506, '2021-04-13', 'postgres', 'DELETE', 'RJ757');
INSERT INTO "ProdNac2021".logbd VALUES (3507, '2021-04-13', 'postgres', 'DELETE', 'RJ758');
INSERT INTO "ProdNac2021".logbd VALUES (3508, '2021-04-13', 'postgres', 'DELETE', 'RJ759');
INSERT INTO "ProdNac2021".logbd VALUES (3509, '2021-04-13', 'postgres', 'DELETE', 'RJ76');
INSERT INTO "ProdNac2021".logbd VALUES (3510, '2021-04-13', 'postgres', 'DELETE', 'RJ760');
INSERT INTO "ProdNac2021".logbd VALUES (3511, '2021-04-13', 'postgres', 'DELETE', 'RJ761');
INSERT INTO "ProdNac2021".logbd VALUES (3512, '2021-04-13', 'postgres', 'DELETE', 'RJ762');
INSERT INTO "ProdNac2021".logbd VALUES (3513, '2021-04-13', 'postgres', 'DELETE', 'RJ763');
INSERT INTO "ProdNac2021".logbd VALUES (3514, '2021-04-13', 'postgres', 'DELETE', 'RJ764');
INSERT INTO "ProdNac2021".logbd VALUES (3515, '2021-04-13', 'postgres', 'DELETE', 'RJ765');
INSERT INTO "ProdNac2021".logbd VALUES (3516, '2021-04-13', 'postgres', 'DELETE', 'RJ766');
INSERT INTO "ProdNac2021".logbd VALUES (3517, '2021-04-13', 'postgres', 'DELETE', 'RJ767');
INSERT INTO "ProdNac2021".logbd VALUES (3518, '2021-04-13', 'postgres', 'DELETE', 'RJ768');
INSERT INTO "ProdNac2021".logbd VALUES (3519, '2021-04-13', 'postgres', 'DELETE', 'RJ769');
INSERT INTO "ProdNac2021".logbd VALUES (3520, '2021-04-13', 'postgres', 'DELETE', 'RJ77');
INSERT INTO "ProdNac2021".logbd VALUES (3521, '2021-04-13', 'postgres', 'DELETE', 'RJ770');
INSERT INTO "ProdNac2021".logbd VALUES (3522, '2021-04-13', 'postgres', 'DELETE', 'RJ771');
INSERT INTO "ProdNac2021".logbd VALUES (3523, '2021-04-13', 'postgres', 'DELETE', 'RJ772');
INSERT INTO "ProdNac2021".logbd VALUES (3524, '2021-04-13', 'postgres', 'DELETE', 'RJ773');
INSERT INTO "ProdNac2021".logbd VALUES (3525, '2021-04-13', 'postgres', 'DELETE', 'RJ774');
INSERT INTO "ProdNac2021".logbd VALUES (3526, '2021-04-13', 'postgres', 'DELETE', 'RJ775');
INSERT INTO "ProdNac2021".logbd VALUES (3527, '2021-04-13', 'postgres', 'DELETE', 'RJ776');
INSERT INTO "ProdNac2021".logbd VALUES (3528, '2021-04-13', 'postgres', 'DELETE', 'RJ777');
INSERT INTO "ProdNac2021".logbd VALUES (3529, '2021-04-13', 'postgres', 'DELETE', 'RJ778');
INSERT INTO "ProdNac2021".logbd VALUES (3530, '2021-04-13', 'postgres', 'DELETE', 'RJ779');
INSERT INTO "ProdNac2021".logbd VALUES (3531, '2021-04-13', 'postgres', 'DELETE', 'RJ78');
INSERT INTO "ProdNac2021".logbd VALUES (3532, '2021-04-13', 'postgres', 'DELETE', 'RJ780');
INSERT INTO "ProdNac2021".logbd VALUES (3533, '2021-04-13', 'postgres', 'DELETE', 'RJ781');
INSERT INTO "ProdNac2021".logbd VALUES (3534, '2021-04-13', 'postgres', 'DELETE', 'RJ782');
INSERT INTO "ProdNac2021".logbd VALUES (3535, '2021-04-13', 'postgres', 'DELETE', 'RJ783');
INSERT INTO "ProdNac2021".logbd VALUES (3536, '2021-04-13', 'postgres', 'DELETE', 'RJ784');
INSERT INTO "ProdNac2021".logbd VALUES (3537, '2021-04-13', 'postgres', 'DELETE', 'RJ785');
INSERT INTO "ProdNac2021".logbd VALUES (3538, '2021-04-13', 'postgres', 'DELETE', 'RJ786');
INSERT INTO "ProdNac2021".logbd VALUES (3539, '2021-04-13', 'postgres', 'DELETE', 'RJ787');
INSERT INTO "ProdNac2021".logbd VALUES (3540, '2021-04-13', 'postgres', 'DELETE', 'RJ788');
INSERT INTO "ProdNac2021".logbd VALUES (3541, '2021-04-13', 'postgres', 'DELETE', 'RJ789');
INSERT INTO "ProdNac2021".logbd VALUES (3542, '2021-04-13', 'postgres', 'DELETE', 'RJ79');
INSERT INTO "ProdNac2021".logbd VALUES (3543, '2021-04-13', 'postgres', 'DELETE', 'RJ790');
INSERT INTO "ProdNac2021".logbd VALUES (3544, '2021-04-13', 'postgres', 'DELETE', 'RJ791');
INSERT INTO "ProdNac2021".logbd VALUES (3545, '2021-04-13', 'postgres', 'DELETE', 'RJ792');
INSERT INTO "ProdNac2021".logbd VALUES (3546, '2021-04-13', 'postgres', 'DELETE', 'RJ793');
INSERT INTO "ProdNac2021".logbd VALUES (3547, '2021-04-13', 'postgres', 'DELETE', 'RJ794');
INSERT INTO "ProdNac2021".logbd VALUES (3548, '2021-04-13', 'postgres', 'DELETE', 'RJ795');
INSERT INTO "ProdNac2021".logbd VALUES (3549, '2021-04-13', 'postgres', 'DELETE', 'RJ796');
INSERT INTO "ProdNac2021".logbd VALUES (3550, '2021-04-13', 'postgres', 'DELETE', 'RJ797');
INSERT INTO "ProdNac2021".logbd VALUES (3551, '2021-04-13', 'postgres', 'DELETE', 'RJ798');
INSERT INTO "ProdNac2021".logbd VALUES (3552, '2021-04-13', 'postgres', 'DELETE', 'RJ799');
INSERT INTO "ProdNac2021".logbd VALUES (3553, '2021-04-13', 'postgres', 'DELETE', 'RJ80');
INSERT INTO "ProdNac2021".logbd VALUES (3554, '2021-04-13', 'postgres', 'DELETE', 'RJ800');
INSERT INTO "ProdNac2021".logbd VALUES (3555, '2021-04-13', 'postgres', 'DELETE', 'RJ801');
INSERT INTO "ProdNac2021".logbd VALUES (3556, '2021-04-13', 'postgres', 'DELETE', 'RJ802');
INSERT INTO "ProdNac2021".logbd VALUES (3557, '2021-04-13', 'postgres', 'DELETE', 'RJ803');
INSERT INTO "ProdNac2021".logbd VALUES (3558, '2021-04-13', 'postgres', 'DELETE', 'RJ804');
INSERT INTO "ProdNac2021".logbd VALUES (3559, '2021-04-13', 'postgres', 'DELETE', 'RJ805');
INSERT INTO "ProdNac2021".logbd VALUES (3560, '2021-04-13', 'postgres', 'DELETE', 'RJ806');
INSERT INTO "ProdNac2021".logbd VALUES (3561, '2021-04-13', 'postgres', 'DELETE', 'RJ807');
INSERT INTO "ProdNac2021".logbd VALUES (3562, '2021-04-13', 'postgres', 'DELETE', 'RJ808');
INSERT INTO "ProdNac2021".logbd VALUES (3563, '2021-04-13', 'postgres', 'DELETE', 'RJ809');
INSERT INTO "ProdNac2021".logbd VALUES (3564, '2021-04-13', 'postgres', 'DELETE', 'RJ81');
INSERT INTO "ProdNac2021".logbd VALUES (3565, '2021-04-13', 'postgres', 'DELETE', 'RJ810');
INSERT INTO "ProdNac2021".logbd VALUES (3566, '2021-04-13', 'postgres', 'DELETE', 'RJ811');
INSERT INTO "ProdNac2021".logbd VALUES (3567, '2021-04-13', 'postgres', 'DELETE', 'RJ812');
INSERT INTO "ProdNac2021".logbd VALUES (3568, '2021-04-13', 'postgres', 'DELETE', 'RJ813');
INSERT INTO "ProdNac2021".logbd VALUES (3569, '2021-04-13', 'postgres', 'DELETE', 'RJ814');
INSERT INTO "ProdNac2021".logbd VALUES (3570, '2021-04-13', 'postgres', 'DELETE', 'RJ815');
INSERT INTO "ProdNac2021".logbd VALUES (3571, '2021-04-13', 'postgres', 'DELETE', 'RJ816');
INSERT INTO "ProdNac2021".logbd VALUES (3572, '2021-04-13', 'postgres', 'DELETE', 'RJ817');
INSERT INTO "ProdNac2021".logbd VALUES (3573, '2021-04-13', 'postgres', 'DELETE', 'RJ818');
INSERT INTO "ProdNac2021".logbd VALUES (3574, '2021-04-13', 'postgres', 'DELETE', 'RJ819');
INSERT INTO "ProdNac2021".logbd VALUES (3575, '2021-04-13', 'postgres', 'DELETE', 'RJ82');
INSERT INTO "ProdNac2021".logbd VALUES (3576, '2021-04-13', 'postgres', 'DELETE', 'RJ820');
INSERT INTO "ProdNac2021".logbd VALUES (3577, '2021-04-13', 'postgres', 'DELETE', 'RJ821');
INSERT INTO "ProdNac2021".logbd VALUES (3578, '2021-04-13', 'postgres', 'DELETE', 'RJ822');
INSERT INTO "ProdNac2021".logbd VALUES (3579, '2021-04-13', 'postgres', 'DELETE', 'RJ823');
INSERT INTO "ProdNac2021".logbd VALUES (3580, '2021-04-13', 'postgres', 'DELETE', 'RJ824');
INSERT INTO "ProdNac2021".logbd VALUES (3581, '2021-04-13', 'postgres', 'DELETE', 'RJ825');
INSERT INTO "ProdNac2021".logbd VALUES (3582, '2021-04-13', 'postgres', 'DELETE', 'RJ826');
INSERT INTO "ProdNac2021".logbd VALUES (3583, '2021-04-13', 'postgres', 'DELETE', 'RJ827');
INSERT INTO "ProdNac2021".logbd VALUES (3584, '2021-04-13', 'postgres', 'DELETE', 'RJ828');
INSERT INTO "ProdNac2021".logbd VALUES (3585, '2021-04-13', 'postgres', 'DELETE', 'RJ829');
INSERT INTO "ProdNac2021".logbd VALUES (3586, '2021-04-13', 'postgres', 'DELETE', 'RJ83');
INSERT INTO "ProdNac2021".logbd VALUES (3587, '2021-04-13', 'postgres', 'DELETE', 'RJ830');
INSERT INTO "ProdNac2021".logbd VALUES (3588, '2021-04-13', 'postgres', 'DELETE', 'RJ831');
INSERT INTO "ProdNac2021".logbd VALUES (3589, '2021-04-13', 'postgres', 'DELETE', 'RJ832');
INSERT INTO "ProdNac2021".logbd VALUES (3590, '2021-04-13', 'postgres', 'DELETE', 'RJ833');
INSERT INTO "ProdNac2021".logbd VALUES (3591, '2021-04-13', 'postgres', 'DELETE', 'RJ834');
INSERT INTO "ProdNac2021".logbd VALUES (3592, '2021-04-13', 'postgres', 'DELETE', 'RJ835');
INSERT INTO "ProdNac2021".logbd VALUES (3593, '2021-04-13', 'postgres', 'DELETE', 'RJ836');
INSERT INTO "ProdNac2021".logbd VALUES (3594, '2021-04-13', 'postgres', 'DELETE', 'RJ837');
INSERT INTO "ProdNac2021".logbd VALUES (3595, '2021-04-13', 'postgres', 'DELETE', 'RJ838');
INSERT INTO "ProdNac2021".logbd VALUES (3596, '2021-04-13', 'postgres', 'DELETE', 'RJ839');
INSERT INTO "ProdNac2021".logbd VALUES (3597, '2021-04-13', 'postgres', 'DELETE', 'RJ84');
INSERT INTO "ProdNac2021".logbd VALUES (3598, '2021-04-13', 'postgres', 'DELETE', 'RJ840');
INSERT INTO "ProdNac2021".logbd VALUES (3599, '2021-04-13', 'postgres', 'DELETE', 'RJ842');
INSERT INTO "ProdNac2021".logbd VALUES (3600, '2021-04-13', 'postgres', 'DELETE', 'RJ843');
INSERT INTO "ProdNac2021".logbd VALUES (3601, '2021-04-13', 'postgres', 'DELETE', 'RJ844');
INSERT INTO "ProdNac2021".logbd VALUES (3602, '2021-04-13', 'postgres', 'DELETE', 'RJ845');
INSERT INTO "ProdNac2021".logbd VALUES (3603, '2021-04-13', 'postgres', 'DELETE', 'RJ846');
INSERT INTO "ProdNac2021".logbd VALUES (3604, '2021-04-13', 'postgres', 'DELETE', 'RJ847');
INSERT INTO "ProdNac2021".logbd VALUES (3605, '2021-04-13', 'postgres', 'DELETE', 'RJ848');
INSERT INTO "ProdNac2021".logbd VALUES (3606, '2021-04-13', 'postgres', 'DELETE', 'RJ849');
INSERT INTO "ProdNac2021".logbd VALUES (3607, '2021-04-13', 'postgres', 'DELETE', 'RJ85');
INSERT INTO "ProdNac2021".logbd VALUES (3608, '2021-04-13', 'postgres', 'DELETE', 'RJ850');
INSERT INTO "ProdNac2021".logbd VALUES (3609, '2021-04-13', 'postgres', 'DELETE', 'RJ851');
INSERT INTO "ProdNac2021".logbd VALUES (3610, '2021-04-13', 'postgres', 'DELETE', 'RJ852');
INSERT INTO "ProdNac2021".logbd VALUES (3611, '2021-04-13', 'postgres', 'DELETE', 'RJ853');
INSERT INTO "ProdNac2021".logbd VALUES (3612, '2021-04-13', 'postgres', 'DELETE', 'RJ854');
INSERT INTO "ProdNac2021".logbd VALUES (3613, '2021-04-13', 'postgres', 'DELETE', 'RJ855');
INSERT INTO "ProdNac2021".logbd VALUES (3614, '2021-04-13', 'postgres', 'DELETE', 'RJ856');
INSERT INTO "ProdNac2021".logbd VALUES (3615, '2021-04-13', 'postgres', 'DELETE', 'RJ857');
INSERT INTO "ProdNac2021".logbd VALUES (3616, '2021-04-13', 'postgres', 'DELETE', 'RJ858');
INSERT INTO "ProdNac2021".logbd VALUES (3617, '2021-04-13', 'postgres', 'DELETE', 'RJ859');
INSERT INTO "ProdNac2021".logbd VALUES (3618, '2021-04-13', 'postgres', 'DELETE', 'RJ86');
INSERT INTO "ProdNac2021".logbd VALUES (3619, '2021-04-13', 'postgres', 'DELETE', 'RJ860');
INSERT INTO "ProdNac2021".logbd VALUES (3620, '2021-04-13', 'postgres', 'DELETE', 'RJ861');
INSERT INTO "ProdNac2021".logbd VALUES (3621, '2021-04-13', 'postgres', 'DELETE', 'RJ862');
INSERT INTO "ProdNac2021".logbd VALUES (3622, '2021-04-13', 'postgres', 'DELETE', 'RJ863');
INSERT INTO "ProdNac2021".logbd VALUES (3623, '2021-04-13', 'postgres', 'DELETE', 'RJ864');
INSERT INTO "ProdNac2021".logbd VALUES (3624, '2021-04-13', 'postgres', 'DELETE', 'RJ865');
INSERT INTO "ProdNac2021".logbd VALUES (3625, '2021-04-13', 'postgres', 'DELETE', 'RJ866');
INSERT INTO "ProdNac2021".logbd VALUES (3626, '2021-04-13', 'postgres', 'DELETE', 'RJ867');
INSERT INTO "ProdNac2021".logbd VALUES (3627, '2021-04-13', 'postgres', 'DELETE', 'RJ868');
INSERT INTO "ProdNac2021".logbd VALUES (3628, '2021-04-13', 'postgres', 'DELETE', 'RJ869');
INSERT INTO "ProdNac2021".logbd VALUES (3629, '2021-04-13', 'postgres', 'DELETE', 'RJ870');
INSERT INTO "ProdNac2021".logbd VALUES (3630, '2021-04-13', 'postgres', 'DELETE', 'RJ871');
INSERT INTO "ProdNac2021".logbd VALUES (3631, '2021-04-13', 'postgres', 'DELETE', 'RJ872');
INSERT INTO "ProdNac2021".logbd VALUES (3632, '2021-04-13', 'postgres', 'DELETE', 'RJ873');
INSERT INTO "ProdNac2021".logbd VALUES (3633, '2021-04-13', 'postgres', 'DELETE', 'RJ874');
INSERT INTO "ProdNac2021".logbd VALUES (3634, '2021-04-13', 'postgres', 'DELETE', 'RJ875');
INSERT INTO "ProdNac2021".logbd VALUES (3635, '2021-04-13', 'postgres', 'DELETE', 'RJ876');
INSERT INTO "ProdNac2021".logbd VALUES (3636, '2021-04-13', 'postgres', 'DELETE', 'RJ877');
INSERT INTO "ProdNac2021".logbd VALUES (3637, '2021-04-13', 'postgres', 'DELETE', 'RJ878');
INSERT INTO "ProdNac2021".logbd VALUES (3638, '2021-04-13', 'postgres', 'DELETE', 'RJ879');
INSERT INTO "ProdNac2021".logbd VALUES (3639, '2021-04-13', 'postgres', 'DELETE', 'RJ88');
INSERT INTO "ProdNac2021".logbd VALUES (3640, '2021-04-13', 'postgres', 'DELETE', 'RJ880');
INSERT INTO "ProdNac2021".logbd VALUES (3641, '2021-04-13', 'postgres', 'DELETE', 'RJ881');
INSERT INTO "ProdNac2021".logbd VALUES (3642, '2021-04-13', 'postgres', 'DELETE', 'RJ882');
INSERT INTO "ProdNac2021".logbd VALUES (3643, '2021-04-13', 'postgres', 'DELETE', 'RJ883');
INSERT INTO "ProdNac2021".logbd VALUES (3644, '2021-04-13', 'postgres', 'DELETE', 'RJ884');
INSERT INTO "ProdNac2021".logbd VALUES (3645, '2021-04-13', 'postgres', 'DELETE', 'RJ885');
INSERT INTO "ProdNac2021".logbd VALUES (3646, '2021-04-13', 'postgres', 'DELETE', 'RJ886');
INSERT INTO "ProdNac2021".logbd VALUES (3647, '2021-04-13', 'postgres', 'DELETE', 'RJ887');
INSERT INTO "ProdNac2021".logbd VALUES (3648, '2021-04-13', 'postgres', 'DELETE', 'RJ888');
INSERT INTO "ProdNac2021".logbd VALUES (3649, '2021-04-13', 'postgres', 'DELETE', 'RJ889');
INSERT INTO "ProdNac2021".logbd VALUES (3650, '2021-04-13', 'postgres', 'DELETE', 'RJ890');
INSERT INTO "ProdNac2021".logbd VALUES (3651, '2021-04-13', 'postgres', 'DELETE', 'RJ891');
INSERT INTO "ProdNac2021".logbd VALUES (3652, '2021-04-13', 'postgres', 'DELETE', 'RJ892');
INSERT INTO "ProdNac2021".logbd VALUES (3653, '2021-04-13', 'postgres', 'DELETE', 'RJ893');
INSERT INTO "ProdNac2021".logbd VALUES (3654, '2021-04-13', 'postgres', 'DELETE', 'RJ894');
INSERT INTO "ProdNac2021".logbd VALUES (3655, '2021-04-13', 'postgres', 'DELETE', 'RJ895');
INSERT INTO "ProdNac2021".logbd VALUES (3656, '2021-04-13', 'postgres', 'DELETE', 'RJ896');
INSERT INTO "ProdNac2021".logbd VALUES (3657, '2021-04-13', 'postgres', 'DELETE', 'RJ897');
INSERT INTO "ProdNac2021".logbd VALUES (3658, '2021-04-13', 'postgres', 'DELETE', 'RJ898');
INSERT INTO "ProdNac2021".logbd VALUES (3659, '2021-04-13', 'postgres', 'DELETE', 'RJ899');
INSERT INTO "ProdNac2021".logbd VALUES (3660, '2021-04-13', 'postgres', 'DELETE', 'RJ900');
INSERT INTO "ProdNac2021".logbd VALUES (3661, '2021-04-13', 'postgres', 'DELETE', 'RJ901');
INSERT INTO "ProdNac2021".logbd VALUES (3662, '2021-04-13', 'postgres', 'DELETE', 'RJ902');
INSERT INTO "ProdNac2021".logbd VALUES (3663, '2021-04-13', 'postgres', 'DELETE', 'RJ903');
INSERT INTO "ProdNac2021".logbd VALUES (3664, '2021-04-13', 'postgres', 'DELETE', 'RJ904');
INSERT INTO "ProdNac2021".logbd VALUES (3665, '2021-04-13', 'postgres', 'DELETE', 'RJ905');
INSERT INTO "ProdNac2021".logbd VALUES (3666, '2021-04-13', 'postgres', 'DELETE', 'RJ906');
INSERT INTO "ProdNac2021".logbd VALUES (3667, '2021-04-13', 'postgres', 'DELETE', 'RJ907');
INSERT INTO "ProdNac2021".logbd VALUES (3668, '2021-04-13', 'postgres', 'DELETE', 'RJ908');
INSERT INTO "ProdNac2021".logbd VALUES (3669, '2021-04-13', 'postgres', 'DELETE', 'RJ909');
INSERT INTO "ProdNac2021".logbd VALUES (3670, '2021-04-13', 'postgres', 'DELETE', 'RJ91');
INSERT INTO "ProdNac2021".logbd VALUES (3671, '2021-04-13', 'postgres', 'DELETE', 'RJ910');
INSERT INTO "ProdNac2021".logbd VALUES (3672, '2021-04-13', 'postgres', 'DELETE', 'RJ911');
INSERT INTO "ProdNac2021".logbd VALUES (3673, '2021-04-13', 'postgres', 'DELETE', 'RJ912');
INSERT INTO "ProdNac2021".logbd VALUES (3674, '2021-04-13', 'postgres', 'DELETE', 'RJ913');
INSERT INTO "ProdNac2021".logbd VALUES (3675, '2021-04-13', 'postgres', 'DELETE', 'RJ914');
INSERT INTO "ProdNac2021".logbd VALUES (3676, '2021-04-13', 'postgres', 'DELETE', 'RJ915');
INSERT INTO "ProdNac2021".logbd VALUES (3677, '2021-04-13', 'postgres', 'DELETE', 'RJ916');
INSERT INTO "ProdNac2021".logbd VALUES (3678, '2021-04-13', 'postgres', 'DELETE', 'RJ917');
INSERT INTO "ProdNac2021".logbd VALUES (3679, '2021-04-13', 'postgres', 'DELETE', 'RJ918');
INSERT INTO "ProdNac2021".logbd VALUES (3680, '2021-04-13', 'postgres', 'DELETE', 'RJ919');
INSERT INTO "ProdNac2021".logbd VALUES (3681, '2021-04-13', 'postgres', 'DELETE', 'RJ920');
INSERT INTO "ProdNac2021".logbd VALUES (3682, '2021-04-13', 'postgres', 'DELETE', 'RJ921');
INSERT INTO "ProdNac2021".logbd VALUES (3683, '2021-04-13', 'postgres', 'DELETE', 'RJ922');
INSERT INTO "ProdNac2021".logbd VALUES (3684, '2021-04-13', 'postgres', 'DELETE', 'RJ923');
INSERT INTO "ProdNac2021".logbd VALUES (3685, '2021-04-13', 'postgres', 'DELETE', 'RJ924');
INSERT INTO "ProdNac2021".logbd VALUES (3686, '2021-04-13', 'postgres', 'DELETE', 'RJ925');
INSERT INTO "ProdNac2021".logbd VALUES (3687, '2021-04-13', 'postgres', 'DELETE', 'RJ926');
INSERT INTO "ProdNac2021".logbd VALUES (3688, '2021-04-13', 'postgres', 'DELETE', 'RJ927');
INSERT INTO "ProdNac2021".logbd VALUES (3689, '2021-04-13', 'postgres', 'DELETE', 'RJ928');
INSERT INTO "ProdNac2021".logbd VALUES (3690, '2021-04-13', 'postgres', 'DELETE', 'RJ929');
INSERT INTO "ProdNac2021".logbd VALUES (3691, '2021-04-13', 'postgres', 'DELETE', 'RJ93');
INSERT INTO "ProdNac2021".logbd VALUES (3692, '2021-04-13', 'postgres', 'DELETE', 'RJ930');
INSERT INTO "ProdNac2021".logbd VALUES (3693, '2021-04-13', 'postgres', 'DELETE', 'RJ931');
INSERT INTO "ProdNac2021".logbd VALUES (3694, '2021-04-13', 'postgres', 'DELETE', 'RJ932');
INSERT INTO "ProdNac2021".logbd VALUES (3695, '2021-04-13', 'postgres', 'DELETE', 'RJ933');
INSERT INTO "ProdNac2021".logbd VALUES (3696, '2021-04-13', 'postgres', 'DELETE', 'RJ934');
INSERT INTO "ProdNac2021".logbd VALUES (3697, '2021-04-13', 'postgres', 'DELETE', 'RJ935');
INSERT INTO "ProdNac2021".logbd VALUES (3698, '2021-04-13', 'postgres', 'DELETE', 'RJ936');
INSERT INTO "ProdNac2021".logbd VALUES (3699, '2021-04-13', 'postgres', 'DELETE', 'RJ937');
INSERT INTO "ProdNac2021".logbd VALUES (3700, '2021-04-13', 'postgres', 'DELETE', 'RJ938');
INSERT INTO "ProdNac2021".logbd VALUES (3701, '2021-04-13', 'postgres', 'DELETE', 'RJ939');
INSERT INTO "ProdNac2021".logbd VALUES (3702, '2021-04-13', 'postgres', 'DELETE', 'RJ940');
INSERT INTO "ProdNac2021".logbd VALUES (3703, '2021-04-13', 'postgres', 'DELETE', 'RJ941');
INSERT INTO "ProdNac2021".logbd VALUES (3704, '2021-04-13', 'postgres', 'DELETE', 'RJ942');
INSERT INTO "ProdNac2021".logbd VALUES (3705, '2021-04-13', 'postgres', 'DELETE', 'RJ943');
INSERT INTO "ProdNac2021".logbd VALUES (3706, '2021-04-13', 'postgres', 'DELETE', 'RJ944');
INSERT INTO "ProdNac2021".logbd VALUES (3707, '2021-04-13', 'postgres', 'DELETE', 'RJ945');
INSERT INTO "ProdNac2021".logbd VALUES (3708, '2021-04-13', 'postgres', 'DELETE', 'RJ946');
INSERT INTO "ProdNac2021".logbd VALUES (3709, '2021-04-13', 'postgres', 'DELETE', 'RJ947');
INSERT INTO "ProdNac2021".logbd VALUES (3710, '2021-04-13', 'postgres', 'DELETE', 'RJ948');
INSERT INTO "ProdNac2021".logbd VALUES (3711, '2021-04-13', 'postgres', 'DELETE', 'RJ949');
INSERT INTO "ProdNac2021".logbd VALUES (3712, '2021-04-13', 'postgres', 'DELETE', 'RJ95');
INSERT INTO "ProdNac2021".logbd VALUES (3713, '2021-04-13', 'postgres', 'DELETE', 'RJ950');
INSERT INTO "ProdNac2021".logbd VALUES (3714, '2021-04-13', 'postgres', 'DELETE', 'RJ951');
INSERT INTO "ProdNac2021".logbd VALUES (3715, '2021-04-13', 'postgres', 'DELETE', 'RJ952');
INSERT INTO "ProdNac2021".logbd VALUES (3716, '2021-04-13', 'postgres', 'DELETE', 'RJ953');
INSERT INTO "ProdNac2021".logbd VALUES (3717, '2021-04-13', 'postgres', 'DELETE', 'RJ954');
INSERT INTO "ProdNac2021".logbd VALUES (3718, '2021-04-13', 'postgres', 'DELETE', 'RJ955');
INSERT INTO "ProdNac2021".logbd VALUES (3719, '2021-04-13', 'postgres', 'DELETE', 'RJ956');
INSERT INTO "ProdNac2021".logbd VALUES (3720, '2021-04-13', 'postgres', 'DELETE', 'RJ957');
INSERT INTO "ProdNac2021".logbd VALUES (3721, '2021-04-13', 'postgres', 'DELETE', 'RJ958');
INSERT INTO "ProdNac2021".logbd VALUES (3722, '2021-04-13', 'postgres', 'DELETE', 'RJ959');
INSERT INTO "ProdNac2021".logbd VALUES (3723, '2021-04-13', 'postgres', 'DELETE', 'RJ960');
INSERT INTO "ProdNac2021".logbd VALUES (3724, '2021-04-13', 'postgres', 'DELETE', 'RJ961');
INSERT INTO "ProdNac2021".logbd VALUES (3725, '2021-04-13', 'postgres', 'DELETE', 'RJ962');
INSERT INTO "ProdNac2021".logbd VALUES (3726, '2021-04-13', 'postgres', 'DELETE', 'RJ963');
INSERT INTO "ProdNac2021".logbd VALUES (3727, '2021-04-13', 'postgres', 'DELETE', 'RJ964');
INSERT INTO "ProdNac2021".logbd VALUES (3728, '2021-04-13', 'postgres', 'DELETE', 'RJ965');
INSERT INTO "ProdNac2021".logbd VALUES (3729, '2021-04-13', 'postgres', 'DELETE', 'RJ966');
INSERT INTO "ProdNac2021".logbd VALUES (3730, '2021-04-13', 'postgres', 'DELETE', 'RJ967');
INSERT INTO "ProdNac2021".logbd VALUES (3731, '2021-04-13', 'postgres', 'DELETE', 'RJ968');
INSERT INTO "ProdNac2021".logbd VALUES (3732, '2021-04-13', 'postgres', 'DELETE', 'RJ969');
INSERT INTO "ProdNac2021".logbd VALUES (3733, '2021-04-13', 'postgres', 'DELETE', 'RJ97');
INSERT INTO "ProdNac2021".logbd VALUES (3734, '2021-04-13', 'postgres', 'DELETE', 'RJ970');
INSERT INTO "ProdNac2021".logbd VALUES (3735, '2021-04-13', 'postgres', 'DELETE', 'RJ971');
INSERT INTO "ProdNac2021".logbd VALUES (3736, '2021-04-13', 'postgres', 'DELETE', 'RJ972');
INSERT INTO "ProdNac2021".logbd VALUES (3737, '2021-04-13', 'postgres', 'DELETE', 'RJ973');
INSERT INTO "ProdNac2021".logbd VALUES (3738, '2021-04-13', 'postgres', 'DELETE', 'RJ974');
INSERT INTO "ProdNac2021".logbd VALUES (3739, '2021-04-13', 'postgres', 'DELETE', 'RJ975');
INSERT INTO "ProdNac2021".logbd VALUES (3740, '2021-04-13', 'postgres', 'DELETE', 'RJ976');
INSERT INTO "ProdNac2021".logbd VALUES (3741, '2021-04-13', 'postgres', 'DELETE', 'RJ977');
INSERT INTO "ProdNac2021".logbd VALUES (3742, '2021-04-13', 'postgres', 'DELETE', 'RJ978');
INSERT INTO "ProdNac2021".logbd VALUES (3743, '2021-04-13', 'postgres', 'DELETE', 'RJ979');
INSERT INTO "ProdNac2021".logbd VALUES (3744, '2021-04-13', 'postgres', 'DELETE', 'RJ980');
INSERT INTO "ProdNac2021".logbd VALUES (3745, '2021-04-13', 'postgres', 'DELETE', 'RJ981');
INSERT INTO "ProdNac2021".logbd VALUES (3746, '2021-04-13', 'postgres', 'DELETE', 'RJ982');
INSERT INTO "ProdNac2021".logbd VALUES (3747, '2021-04-13', 'postgres', 'DELETE', 'RJ983');
INSERT INTO "ProdNac2021".logbd VALUES (3748, '2021-04-13', 'postgres', 'DELETE', 'RJ984');
INSERT INTO "ProdNac2021".logbd VALUES (3749, '2021-04-13', 'postgres', 'DELETE', 'RJ985');
INSERT INTO "ProdNac2021".logbd VALUES (3750, '2021-04-13', 'postgres', 'DELETE', 'RJ986');
INSERT INTO "ProdNac2021".logbd VALUES (3751, '2021-04-13', 'postgres', 'DELETE', 'RJ987');
INSERT INTO "ProdNac2021".logbd VALUES (3752, '2021-04-13', 'postgres', 'DELETE', 'RJ988');
INSERT INTO "ProdNac2021".logbd VALUES (3753, '2021-04-13', 'postgres', 'DELETE', 'RJ989');
INSERT INTO "ProdNac2021".logbd VALUES (3754, '2021-04-13', 'postgres', 'DELETE', 'RJ99');
INSERT INTO "ProdNac2021".logbd VALUES (3755, '2021-04-13', 'postgres', 'DELETE', 'RJ990');
INSERT INTO "ProdNac2021".logbd VALUES (3756, '2021-04-13', 'postgres', 'DELETE', 'RJ991');
INSERT INTO "ProdNac2021".logbd VALUES (3757, '2021-04-13', 'postgres', 'DELETE', 'RJ992');
INSERT INTO "ProdNac2021".logbd VALUES (3758, '2021-04-13', 'postgres', 'DELETE', 'RJ993');
INSERT INTO "ProdNac2021".logbd VALUES (3759, '2021-04-13', 'postgres', 'DELETE', 'RJ994');
INSERT INTO "ProdNac2021".logbd VALUES (3760, '2021-04-13', 'postgres', 'DELETE', 'RJ995');
INSERT INTO "ProdNac2021".logbd VALUES (3761, '2021-04-13', 'postgres', 'DELETE', 'RJ996');
INSERT INTO "ProdNac2021".logbd VALUES (3762, '2021-04-13', 'postgres', 'DELETE', 'RJ997');
INSERT INTO "ProdNac2021".logbd VALUES (3763, '2021-04-13', 'postgres', 'DELETE', 'RJ998');
INSERT INTO "ProdNac2021".logbd VALUES (3764, '2021-04-13', 'postgres', 'DELETE', 'RJ999');


--
-- TOC entry 2193 (class 0 OID 37923)
-- Dependencies: 194
-- Data for Name: procedmetodolog; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--



--
-- TOC entry 2194 (class 0 OID 37926)
-- Dependencies: 195
-- Data for Name: profissional; Type: TABLE DATA; Schema: ProdNac2021; Owner: -
--

INSERT INTO "ProdNac2021".profissional VALUES (11, 'Maíra Silva Matos', 'RJ', 'Maíra Matos - Bolsista/Ativo');
INSERT INTO "ProdNac2021".profissional VALUES (13, 'Ruan Vargas', 'RJ', 'Ruan Vargas - Bolsista/Inativo');
INSERT INTO "ProdNac2021".profissional VALUES (8, 'João Freitas Pereira Abrantes Marques', 'RJ', 'João Freitas - Bolsista/Ativo');
INSERT INTO "ProdNac2021".profissional VALUES (4, 'Evelyn de Oliveira Meirelles', 'RJ', 'Evelyn Meirelles - Zago/Ativo');
INSERT INTO "ProdNac2021".profissional VALUES (14, 'Thiago Machado Pinho', 'RJ', 'Thiago Pinho - Zago/Inativo');
INSERT INTO "ProdNac2021".profissional VALUES (7, 'Ícaro Azevedo da Silva', 'RJ', 'Ícaro Azevedo - Servidor/Ativo');
INSERT INTO "ProdNac2021".profissional VALUES (12, 'Raphael Corrêa de Souza Coelho', 'RJ', 'Raphael Coelho - Zago/Ativo');
INSERT INTO "ProdNac2021".profissional VALUES (15, 'Diogo Guimarães dos Santos', 'RJ', 'Diogo Guimarães - Servidor/Ativo');
INSERT INTO "ProdNac2021".profissional VALUES (10, 'Luiza Ramos Felix', 'RJ', 'Luiza Felix - Bolsista/Inativo');
INSERT INTO "ProdNac2021".profissional VALUES (9, 'Laiana Lopes do Nascimento', 'RJ', 'Laiana Lopes - Bolsista/Inativo');
INSERT INTO "ProdNac2021".profissional VALUES (2, NULL, NULL, 'Sem Responsável');
INSERT INTO "ProdNac2021".profissional VALUES (3, 'Daniel da Costa Cid Neiva', 'RJ', 'Daniel Neiva - Bolsista/Inativo');
INSERT INTO "ProdNac2021".profissional VALUES (5, 'Gabriel dos Santos Duarte', 'RJ', 'Gabriel Duarte - Bolsista/Inativo');
INSERT INTO "ProdNac2021".profissional VALUES (6, 'Janaina Valeska Raposo Viana', 'RJ', 'Janaina Raposo - Servidor/Ativo');


--
-- TOC entry 2195 (class 0 OID 37929)
-- Dependencies: 196
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
-- Dependencies: 188
-- Name: geoaproximacao_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: -
--

SELECT pg_catalog.setval('"ProdNac2021".geoaproximacao_seq', 1, false);


--
-- TOC entry 2203 (class 0 OID 0)
-- Dependencies: 190
-- Name: geolocalizacao_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: -
--

SELECT pg_catalog.setval('"ProdNac2021".geolocalizacao_seq', 4, true);


--
-- TOC entry 2204 (class 0 OID 0)
-- Dependencies: 192
-- Name: georreferenciamento_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: -
--

SELECT pg_catalog.setval('"ProdNac2021".georreferenciamento_seq', 4, true);


--
-- TOC entry 2205 (class 0 OID 0)
-- Dependencies: 197
-- Name: logbd_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: -
--

SELECT pg_catalog.setval('"ProdNac2021".logbd_seq', 1, false);


--
-- TOC entry 2043 (class 2606 OID 37933)
-- Name: cdg pk_cdg; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".cdg
    ADD CONSTRAINT pk_cdg PRIMARY KEY (idCdg);


--
-- TOC entry 2045 (class 2606 OID 37935)
-- Name: geoaproximacao pk_geoaproximacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".geoaproximacao
    ADD CONSTRAINT pk_geoaproximacao PRIMARY KEY (codapro);


--
-- TOC entry 2047 (class 2606 OID 37937)
-- Name: geolocalizacao pk_geolocalizacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".geolocalizacao
    ADD CONSTRAINT pk_geolocalizacao PRIMARY KEY (codgeoloc);


--
-- TOC entry 2049 (class 2606 OID 37939)
-- Name: georreferenciamento pk_georreferenciamento; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".georreferenciamento
    ADD CONSTRAINT pk_georreferenciamento PRIMARY KEY (codgeorr);


--
-- TOC entry 2051 (class 2606 OID 37941)
-- Name: logbd pk_logbd; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".logbd
    ADD CONSTRAINT pk_logbd PRIMARY KEY (codlog);


--
-- TOC entry 2053 (class 2606 OID 37943)
-- Name: procedmetodolog pk_procedmetodolog; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT pk_procedmetodolog PRIMARY KEY (codproced);


--
-- TOC entry 2055 (class 2606 OID 37945)
-- Name: profissional pk_profissional; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".profissional
    ADD CONSTRAINT pk_profissional PRIMARY KEY (codprof);


--
-- TOC entry 2057 (class 2606 OID 37947)
-- Name: tipoacao pk_tipoacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".tipoacao
    ADD CONSTRAINT pk_tipoacao PRIMARY KEY (codacao);


--
-- TOC entry 2065 (class 2620 OID 37948)
-- Name: geoaproximacao t_ins_geoaproximacao; Type: TRIGGER; Schema: ProdNac2021; Owner: -
--

CREATE TRIGGER t_ins_geoaproximacao BEFORE INSERT ON "ProdNac2021".geoaproximacao FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_geoaproximacao();


--
-- TOC entry 2066 (class 2620 OID 37949)
-- Name: geolocalizacao t_ins_geolocalizacao; Type: TRIGGER; Schema: ProdNac2021; Owner: -
--

CREATE TRIGGER t_ins_geolocalizacao BEFORE INSERT ON "ProdNac2021".geolocalizacao FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_geolocalizacao();


--
-- TOC entry 2067 (class 2620 OID 37950)
-- Name: georreferenciamento t_ins_georreferenciamento; Type: TRIGGER; Schema: ProdNac2021; Owner: -
--

CREATE TRIGGER t_ins_georreferenciamento BEFORE INSERT ON "ProdNac2021".georreferenciamento FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_georreferenciamento();


--
-- TOC entry 2064 (class 2620 OID 38006)
-- Name: cdg t_ins_logbd; Type: TRIGGER; Schema: ProdNac2021; Owner: -
--

CREATE TRIGGER t_ins_logbd AFTER INSERT OR DELETE OR UPDATE ON "ProdNac2021".cdg FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_logbd();


--
-- TOC entry 2058 (class 2606 OID 37952)
-- Name: geoaproximacao fk_geoaproximacao_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".geoaproximacao
    ADD CONSTRAINT fk_geoaproximacao_ref_cdg FOREIGN KEY (fk_idCdg_apro) REFERENCES "ProdNac2021".cdg(idCdg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2059 (class 2606 OID 37957)
-- Name: geolocalizacao fk_geolocalizacao_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".geolocalizacao
    ADD CONSTRAINT fk_geolocalizacao_ref_cdg FOREIGN KEY (fk_idCdg_geol) REFERENCES "ProdNac2021".cdg(idCdg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2060 (class 2606 OID 37962)
-- Name: georreferenciamento fk_georreferenciamento_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".georreferenciamento
    ADD CONSTRAINT fk_georreferenciamento_ref_cdg FOREIGN KEY (fk_idCdg_geor) REFERENCES "ProdNac2021".cdg(idCdg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2061 (class 2606 OID 37967)
-- Name: procedmetodolog fk_procedmetodolog_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_cdg FOREIGN KEY (fk_idCdg) REFERENCES "ProdNac2021".cdg(idCdg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2062 (class 2606 OID 37972)
-- Name: procedmetodolog fk_procedmetodolog_ref_profissional; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_profissional FOREIGN KEY (fk_codprof) REFERENCES "ProdNac2021".profissional(codprof) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2063 (class 2606 OID 37977)
-- Name: procedmetodolog fk_procedmetodolog_ref_tipoacao; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: -
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_tipoacao FOREIGN KEY (fk_codacao) REFERENCES "ProdNac2021".tipoacao(codacao) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2021-04-13 16:30:19

--
-- PostgreSQL database dump complete
--

