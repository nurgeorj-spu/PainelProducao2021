--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.20
-- Dumped by pg_dump version 11.5

-- Started on 2021-04-15 09:57:20

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
-- TOC entry 212 (class 1255 OID 38182)
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

--
-- TOC entry 213 (class 1255 OID 38183)
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

--
-- TOC entry 214 (class 1255 OID 38184)
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
-- TOC entry 211 (class 1255 OID 38185)
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
    escala integer,
    spunet_dig integer,
    spunet_analog integer
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

--
-- TOC entry 194 (class 1259 OID 38210)
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
-- TOC entry 195 (class 1259 OID 38212)
-- Name: procedmetodolog; Type: TABLE; Schema: ProdNac2021; Owner: postgres
--

CREATE TABLE "ProdNac2021".procedmetodolog (
    codproced integer NOT NULL,
    datap date,
    fk_idcdg integer NOT NULL,
    fk_codprof integer NOT NULL,
    fk_codacao integer NOT NULL
);


ALTER TABLE "ProdNac2021".procedmetodolog OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 38215)
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
-- TOC entry 197 (class 1259 OID 38218)
-- Name: tipoacao; Type: TABLE; Schema: ProdNac2021; Owner: postgres
--

CREATE TABLE "ProdNac2021".tipoacao (
    codacao integer NOT NULL,
    servico character varying(25) NOT NULL
);


ALTER TABLE "ProdNac2021".tipoacao OWNER TO postgres;

--
-- TOC entry 2185 (class 0 OID 38186)
-- Dependencies: 186
-- Data for Name: cdg; Type: TABLE DATA; Schema: ProdNac2021; Owner: postgres
--

INSERT INTO "ProdNac2021".cdg VALUES (3300978, 'RJ978', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '8E', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12153, 12065);
INSERT INTO "ProdNac2021".cdg VALUES (3300005, 'RJ05', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1759-E', 'SPU-RJ - Geoinformação', '117.137-MP', '89.554/54', 'Analógico', 'Carta Cadastral', '01.PlantaFaixadeMarinhaRuaSantoCristo', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 7831, 7806);
INSERT INTO "ProdNac2021".cdg VALUES (3304823, 'RJ4823', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300542, 'RJ542', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-1', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10286, 10005);
INSERT INTO "ProdNac2021".cdg VALUES (3304914, 'RJ4914', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300042, 'RJ42', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-14', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8716, 8674);
INSERT INTO "ProdNac2021".cdg VALUES (3304508, 'RJ4508', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300696, 'RJ696', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-26', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11942, 11803);
INSERT INTO "ProdNac2021".cdg VALUES (3304572, 'RJ4572', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304918, 'RJ4918', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301213, 'RJ1213', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-14', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12028, 11990);
INSERT INTO "ProdNac2021".cdg VALUES (3300314, 'RJ314', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-15', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9607, 8689);
INSERT INTO "ProdNac2021".cdg VALUES (3301165, 'RJ1165', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2290-1', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1971, NULL, 'Não', 'Não possui', 0, 1000, 12619, 12281);
INSERT INTO "ProdNac2021".cdg VALUES (3301224, 'RJ1224', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1903', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 645/55 Novo:245.239-60', 'Analógico', 'Carta Índice', '61.Gaveta19.Itacurussa_Trecho_OrlaMarinha', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 20000, 11445, 11414);
INSERT INTO "ProdNac2021".cdg VALUES (3300267, 'RJ267', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Índice', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 10000, 8212, 7645);
INSERT INTO "ProdNac2021".cdg VALUES (3304975, 'RJ4975', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304859, 'RJ4859', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300208, 'RJ208', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-35', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11025, 9359);
INSERT INTO "ProdNac2021".cdg VALUES (3304358, 'RJ4358', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301038, 'RJ1038', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300668, 'RJ668', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1896-7', 'SPU-RJ - Geoinformação', '062.987-MP', '1423/54', 'Analógico', 'Carta Cadastral', '45.Gaveta1.BarraSaoJoao-CaimiroAbreu_Trecho_CidadeSaoJoao-CasimiroAbreu', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11203, 11193);
INSERT INTO "ProdNac2021".cdg VALUES (3304413, 'RJ4413', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300796, 'RJ796', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-17', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11581, 11461);
INSERT INTO "ProdNac2021".cdg VALUES (3300172, 'RJ172', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 J', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Cadastral', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 10723, 8406);
INSERT INTO "ProdNac2021".cdg VALUES (3300365, 'RJ365', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-62', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9932, 9260);
INSERT INTO "ProdNac2021".cdg VALUES (3300889, 'RJ889', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-2', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11773, 11759);
INSERT INTO "ProdNac2021".cdg VALUES (3301037, 'RJ1037', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300428, 'RJ428', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-35', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8837, 7700);
INSERT INTO "ProdNac2021".cdg VALUES (3300944, 'RJ944', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-6', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11743, 11727);
INSERT INTO "ProdNac2021".cdg VALUES (3300427, 'RJ427', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-34', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8836, 7701);
INSERT INTO "ProdNac2021".cdg VALUES (3301040, 'RJ1040', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300130, 'RJ130', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 B', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9874, 9839);
INSERT INTO "ProdNac2021".cdg VALUES (3301108, 'RJ1108', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-3', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11872, 11834);
INSERT INTO "ProdNac2021".cdg VALUES (3304646, 'RJ4646', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301070, 'RJ1070', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '34', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300739, 'RJ739', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-6', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11280, 11264);
INSERT INTO "ProdNac2021".cdg VALUES (3304352, 'RJ4352', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304819, 'RJ4819', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304836, 'RJ4836', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304409, 'RJ4409', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304423, 'RJ4423', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304543, 'RJ4543', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300229, 'RJ229', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-12', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11042, 9548);
INSERT INTO "ProdNac2021".cdg VALUES (3300103, 'RJ103', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-C', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9683, 9628);
INSERT INTO "ProdNac2021".cdg VALUES (3300882, 'RJ882', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-99', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12831, 12471);
INSERT INTO "ProdNac2021".cdg VALUES (3300393, 'RJ393', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Índice', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 10000, 8788, 7523);
INSERT INTO "ProdNac2021".cdg VALUES (3304765, 'RJ4765', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304972, 'RJ4972', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304401, 'RJ4401', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304866, 'RJ4866', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300989, 'RJ989', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '
Carta índice', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Índice', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 10000, 11610, 11522);
INSERT INTO "ProdNac2021".cdg VALUES (3304784, 'RJ4784', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300752, 'RJ752', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-14', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11335, 11294);
INSERT INTO "ProdNac2021".cdg VALUES (3300563, 'RJ563', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2803-2', 'SPU-RJ - Geoinformação', '117.137-MP', '307.820/57', 'Analógico', 'Carta Cadastral', '38.Trecho_EstradaJacarepagua-ArroioFundo', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9958, 9936);
INSERT INTO "ProdNac2021".cdg VALUES (3300854, 'RJ854', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-72', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12786, 12371);
INSERT INTO "ProdNac2021".cdg VALUES (3300686, 'RJ686', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-16', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11924, 11719);
INSERT INTO "ProdNac2021".cdg VALUES (3300492, 'RJ492', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 12', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9052, 8207);
INSERT INTO "ProdNac2021".cdg VALUES (3300139, 'RJ139', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 K', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9886, 9857);
INSERT INTO "ProdNac2021".cdg VALUES (3304432, 'RJ4432', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304737, 'RJ4737', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304602, 'RJ4602', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300712, 'RJ712', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-42', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11968, 11885);
INSERT INTO "ProdNac2021".cdg VALUES (3300916, 'RJ916', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-5', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12191, 12171);
INSERT INTO "ProdNac2021".cdg VALUES (3300892, 'RJ892', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-5', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11926, 11762);
INSERT INTO "ProdNac2021".cdg VALUES (3300848, 'RJ848', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-66', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12781, 12364);
INSERT INTO "ProdNac2021".cdg VALUES (3300780, 'RJ780', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-1', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11554, 11435);
INSERT INTO "ProdNac2021".cdg VALUES (3304673, 'RJ4673', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300475, 'RJ475', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 7', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 9001, 8027);
INSERT INTO "ProdNac2021".cdg VALUES (3300680, 'RJ680', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-10', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11918, 11713);
INSERT INTO "ProdNac2021".cdg VALUES (3300012, 'RJ12', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 5', 'SPU-RJ - Geoinformação', '117.137-MP', '13.5305/47', 'Analógico', 'Carta Cadastral', '02.PlantaFaixadeMarinhas_PraiadeBotafogo', 'Terreno de Marinha', 1947, NULL, 'Não', 'Não possui', 0, 500, 8070, 8054);
INSERT INTO "ProdNac2021".cdg VALUES (3300438, 'RJ438', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-4', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8919, 7935);
INSERT INTO "ProdNac2021".cdg VALUES (3300667, 'RJ667', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1896-6', 'SPU-RJ - Geoinformação', '062.987-MP', '1423/54', 'Analógico', 'Carta Cadastral', '45.Gaveta1.BarraSaoJoao-CaimiroAbreu_Trecho_CidadeSaoJoao-CasimiroAbreu', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11202, 11192);
INSERT INTO "ProdNac2021".cdg VALUES (3304986, 'RJ4986', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304469, 'RJ4469', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301009, 'RJ1009', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '21', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11653, 11558);
INSERT INTO "ProdNac2021".cdg VALUES (3304713, 'RJ4713', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304514, 'RJ4514', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300924, 'RJ924', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-13', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12199, 12179);
INSERT INTO "ProdNac2021".cdg VALUES (3300235, 'RJ235', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-3', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11047, 10082);
INSERT INTO "ProdNac2021".cdg VALUES (3304427, 'RJ4427', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300283, 'RJ283', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-16', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8378, 7770);
INSERT INTO "ProdNac2021".cdg VALUES (3304672, 'RJ4672', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304416, 'RJ4416', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304920, 'RJ4920', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301119, 'RJ1119', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-14', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12035, 11846);
INSERT INTO "ProdNac2021".cdg VALUES (3300516, 'RJ516', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 4', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8854, 8257);
INSERT INTO "ProdNac2021".cdg VALUES (3301028, 'RJ1028', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '40', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11683, 11607);
INSERT INTO "ProdNac2021".cdg VALUES (3300534, 'RJ534', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2753 - 7', 'SPU-RJ - Geoinformação', '117.137-MP', '237.984/54', 'Analógico', 'Carta Cadastral', '35.Trecho_PraiaSaoCristovaoAvenidaFranciscoBicalho', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10444, 10435);
INSERT INTO "ProdNac2021".cdg VALUES (3300494, 'RJ494', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 14', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9057, 8227);
INSERT INTO "ProdNac2021".cdg VALUES (3300284, 'RJ284', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-17', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8380, 7775);
INSERT INTO "ProdNac2021".cdg VALUES (3300245, 'RJ245', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-13', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11057, 10116);
INSERT INTO "ProdNac2021".cdg VALUES (3301039, 'RJ1039', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304573, 'RJ4573', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300122, 'RJ122', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2218-3', 'SPU-RJ - Geoinformação', '117.137-MP', '41.263/52', 'Analógico', 'Carta Cadastral', '12.Trecho_RuaPedroAlves', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9768, 9753);
INSERT INTO "ProdNac2021".cdg VALUES (3304941, 'RJ4941', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300893, 'RJ893', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-6', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11927, 11763);
INSERT INTO "ProdNac2021".cdg VALUES (3304722, 'RJ4722', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304475, 'RJ4475', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301152, 'RJ1152', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-15', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12567, 11999);
INSERT INTO "ProdNac2021".cdg VALUES (3300152, 'RJ152', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2311', 'SPU-RJ - Geoinformação', '117.137-MP', '108.875/50', 'Analógico', 'Carta Índice', '15.Trecho_Jequiriçá-JoaoPizarro', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 5000, 10660, 7765);
INSERT INTO "ProdNac2021".cdg VALUES (3304876, 'RJ4876', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300837, 'RJ837', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-55', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12756, 12338);
INSERT INTO "ProdNac2021".cdg VALUES (3300747, 'RJ747', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-11', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11288, 11272);
INSERT INTO "ProdNac2021".cdg VALUES (3300810, 'RJ810', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-30', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11604, 11505);
INSERT INTO "ProdNac2021".cdg VALUES (3301179, 'RJ1179', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2096-5', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300320, 'RJ320', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-21', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9623, 8705);
INSERT INTO "ProdNac2021".cdg VALUES (3301133, 'RJ1133', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-28', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12069, 11865);
INSERT INTO "ProdNac2021".cdg VALUES (3300313, 'RJ313', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-14A', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9604, 8683);
INSERT INTO "ProdNac2021".cdg VALUES (3300593, 'RJ593', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-3', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9542, 9513);
INSERT INTO "ProdNac2021".cdg VALUES (3300623, 'RJ623', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-20', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8809, 8085);
INSERT INTO "ProdNac2021".cdg VALUES (3300767, 'RJ767', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-29', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11352, 11309);
INSERT INTO "ProdNac2021".cdg VALUES (3304531, 'RJ4531', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304545, 'RJ4545', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300272, 'RJ272', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-5', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8251, 7680);
INSERT INTO "ProdNac2021".cdg VALUES (3300117, 'RJ117', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-Q', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9731, 9677);
INSERT INTO "ProdNac2021".cdg VALUES (3300535, 'RJ535', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2753 -8', 'SPU-RJ - Geoinformação', '117.137-MP', '237.984/54', 'Analógico', 'Carta Cadastral', '35.Trecho_PraiaSaoCristovaoAvenidaFranciscoBicalho', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10445, 10436);
INSERT INTO "ProdNac2021".cdg VALUES (3304595, 'RJ4595', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304603, 'RJ4603', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300821, 'RJ821', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-41', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11621, 11518);
INSERT INTO "ProdNac2021".cdg VALUES (3304506, 'RJ4506', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304376, 'RJ4376', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300741, 'RJ741', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-8', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11282, 11266);
INSERT INTO "ProdNac2021".cdg VALUES (3300760, 'RJ760', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-22', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11344, 11302);
INSERT INTO "ProdNac2021".cdg VALUES (3301103, 'RJ1103', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-11', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11826, 11789);
INSERT INTO "ProdNac2021".cdg VALUES (3300368, 'RJ368', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-64', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9945, 9267);
INSERT INTO "ProdNac2021".cdg VALUES (3300472, 'RJ472', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 4', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 8998, 8024);
INSERT INTO "ProdNac2021".cdg VALUES (3300070, 'RJ70', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2064', 'SPU-RJ - Geoinformação', '117.137-MP', '46.155/50', 'Analógico', 'Carta Índice', '08.LinhaPreamarMedio1831_AvenidaRuyBarbosa', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 2000, 7574, 7568);
INSERT INTO "ProdNac2021".cdg VALUES (3304732, 'RJ4732', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301149, 'RJ1149', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-11', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12563, 11955);
INSERT INTO "ProdNac2021".cdg VALUES (3300849, 'RJ849', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-67', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12779, 12366);
INSERT INTO "ProdNac2021".cdg VALUES (3300203, 'RJ203', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-30', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11020, 9311);
INSERT INTO "ProdNac2021".cdg VALUES (3304748, 'RJ4748', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300631, 'RJ631', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-28', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8846, 8215);
INSERT INTO "ProdNac2021".cdg VALUES (3304719, 'RJ4719', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304845, 'RJ4845', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300627, 'RJ627', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-24', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8821, 8195);
INSERT INTO "ProdNac2021".cdg VALUES (3301195, 'RJ1195', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1790-B', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 593/53 Novo:34.981-55', 'Analógico', 'Carta Cadastral', '57.Gaveta14.Atafona_SaoJoaoBarra_Trecho_GrucaiAtafona', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 5000, 11423, 11420);
INSERT INTO "ProdNac2021".cdg VALUES (3304735, 'RJ4735', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301092, 'RJ1092', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '56', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301024, 'RJ1024', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '36', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 10000, 11678, 11597);
INSERT INTO "ProdNac2021".cdg VALUES (3300416, 'RJ416', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-23', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8824, 7674);
INSERT INTO "ProdNac2021".cdg VALUES (3300497, 'RJ497', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2720', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Índice', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 10000, 10405, 10389);
INSERT INTO "ProdNac2021".cdg VALUES (3300819, 'RJ819', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-39', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11619, 11516);
INSERT INTO "ProdNac2021".cdg VALUES (3304526, 'RJ4526', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304951, 'RJ4951', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304965, 'RJ4965', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304789, 'RJ4789', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300109, 'RJ109', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-I', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9690, 9662);
INSERT INTO "ProdNac2021".cdg VALUES (3300224, 'RJ224', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-6', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11037, 9518);
INSERT INTO "ProdNac2021".cdg VALUES (3300618, 'RJ618', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-15', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8801, 8074);
INSERT INTO "ProdNac2021".cdg VALUES (3304426, 'RJ4426', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300649, 'RJ649', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-B', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 10596, 10576);
INSERT INTO "ProdNac2021".cdg VALUES (3301082, 'RJ1082', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '46', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301014, 'RJ1014', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '26', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11663, 11572);
INSERT INTO "ProdNac2021".cdg VALUES (3304381, 'RJ4381', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300263, 'RJ263', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345A-3', 'SPU-RJ - Geoinformação', '117.137-MP', '17.225/54', 'Analógico', 'Carta Cadastral', '23.Trecho_PracaMaua-PalacioMonroe', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11156, 10333);
INSERT INTO "ProdNac2021".cdg VALUES (3300395, 'RJ395', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-2', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8791, 7622);
INSERT INTO "ProdNac2021".cdg VALUES (3300315, 'RJ315', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-16', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9610, 8693);
INSERT INTO "ProdNac2021".cdg VALUES (3301012, 'RJ1012', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '24', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11659, 11564);
INSERT INTO "ProdNac2021".cdg VALUES (3301139, 'RJ1139', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-10', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1964, NULL, 'Não', 'Não possui', 0, 1000, 12509, 11954);
INSERT INTO "ProdNac2021".cdg VALUES (3300811, 'RJ811', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-31', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11605, 11506);
INSERT INTO "ProdNac2021".cdg VALUES (3300614, 'RJ614', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-11', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8787, 8061);
INSERT INTO "ProdNac2021".cdg VALUES (3300721, 'RJ721', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-51', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12106, 11894);
INSERT INTO "ProdNac2021".cdg VALUES (3300259, 'RJ259', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-K', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11151, 10248);
INSERT INTO "ProdNac2021".cdg VALUES (3300359, 'RJ359', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-60', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9746, 9240);
INSERT INTO "ProdNac2021".cdg VALUES (3304645, 'RJ4645', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304969, 'RJ4969', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300336, 'RJ336', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-37', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9691, 9132);
INSERT INTO "ProdNac2021".cdg VALUES (3300624, 'RJ624', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-21', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8810, 8087);
INSERT INTO "ProdNac2021".cdg VALUES (3301027, 'RJ1027', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '39', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11682, 11602);
INSERT INTO "ProdNac2021".cdg VALUES (3304349, 'RJ4349', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300765, 'RJ765', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-27', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11349, 11307);
INSERT INTO "ProdNac2021".cdg VALUES (3304541, 'RJ4541', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301972, 'RJ1972', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 5', 'SPU-RJ - Geoinformação', '117.147-MP', NULL, 'Analógico', 'Carta Índice', '71.TrechoC_Parati_PontaLoba-PontaTrindade', 'Terreno de Marinha', 1980, NULL, 'Sim', 'Possui', 29193, 5000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304452, 'RJ4452', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304484, 'RJ4484', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300715, 'RJ715', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-45', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11971, 11888);
INSERT INTO "ProdNac2021".cdg VALUES (3300599, 'RJ599', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-9', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9557, 9525);
INSERT INTO "ProdNac2021".cdg VALUES (3300802, 'RJ802', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-23', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11590, 11497);
INSERT INTO "ProdNac2021".cdg VALUES (3304448, 'RJ4448', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300636, 'RJ636', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-33', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8856, 8242);
INSERT INTO "ProdNac2021".cdg VALUES (3300298, 'RJ298', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-1', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9316, 8635);
INSERT INTO "ProdNac2021".cdg VALUES (3304681, 'RJ4681', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304367, 'RJ4367', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300678, 'RJ678', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-8', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11916, 11709);
INSERT INTO "ProdNac2021".cdg VALUES (3300072, 'RJ72', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2064-2', 'SPU-RJ - Geoinformação', '117.137-MP', '46.155/50', 'Analógico', 'Carta Cadastral', '08.LinhaPreamarMedio1831_AvenidaRuyBarbosa', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8178, 7637);
INSERT INTO "ProdNac2021".cdg VALUES (3300409, 'RJ409', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-16', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8814, 7661);
INSERT INTO "ProdNac2021".cdg VALUES (3300738, 'RJ738', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-5', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11279, 11263);
INSERT INTO "ProdNac2021".cdg VALUES (3304583, 'RJ4583', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300041, 'RJ41', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-13', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8715, 8672);
INSERT INTO "ProdNac2021".cdg VALUES (3300694, 'RJ694', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-24', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11940, 11801);
INSERT INTO "ProdNac2021".cdg VALUES (3304897, 'RJ4897', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304881, 'RJ4881', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300450, 'RJ450', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-15', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8947, 7967);
INSERT INTO "ProdNac2021".cdg VALUES (3304768, 'RJ4768', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300446, 'RJ446', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-12', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8938, 7958);
INSERT INTO "ProdNac2021".cdg VALUES (3300291, 'RJ291', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2446 E', 'SPU-RJ - Geoinformação', '117.137-MP', '183.267/54', 'Analógico', 'Carta Cadastral', '25.Trecho_PraçaMaua-Gamboa', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 1000, 10022, 10004);
INSERT INTO "ProdNac2021".cdg VALUES (3304491, 'RJ4491', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300095, 'RJ95', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1506', 'SPU-RJ - Geoinformação', '163043 MP', '720/49', 'Analógico', 'Carta Cadastral', '102.Quintino_Bocaiuva-Niteroi', 'Terreno de Marinha', 1950, 0, 'Não', 'Não possui', 0, 500, 16698, 16699);
INSERT INTO "ProdNac2021".cdg VALUES (3300939, 'RJ939', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-1', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11738, 11720);
INSERT INTO "ProdNac2021".cdg VALUES (3300037, 'RJ37', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-9', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8709, 8554);
INSERT INTO "ProdNac2021".cdg VALUES (3304720, 'RJ4720', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300579, 'RJ579', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-1', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9804, 9566);
INSERT INTO "ProdNac2021".cdg VALUES (3300533, 'RJ533', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2753 - 6', 'SPU-RJ - Geoinformação', '117.137-MP', '237.984/54', 'Analógico', 'Carta Cadastral', '35.Trecho_PraiaSaoCristovaoAvenidaFranciscoBicalho', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10443, 10434);
INSERT INTO "ProdNac2021".cdg VALUES (3304414, 'RJ4414', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300753, 'RJ753', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-15', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11340, 11295);
INSERT INTO "ProdNac2021".cdg VALUES (3304453, 'RJ4453', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304474, 'RJ4474', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304785, 'RJ4785', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300575, 'RJ575', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2770-5', 'SPU-RJ - Geoinformação', '117.137-MP', '23.8551/57', 'Analógico', 'Carta Cadastral', '39.Trecho_PraçaAlbertoTorres-RioPavuna', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9845, 9827);
INSERT INTO "ProdNac2021".cdg VALUES (3304682, 'RJ4682', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301008, 'RJ1008', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '20', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11650, 11557);
INSERT INTO "ProdNac2021".cdg VALUES (3304360, 'RJ4360', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300050, 'RJ50', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-1', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8760, 8735);
INSERT INTO "ProdNac2021".cdg VALUES (3300772, 'RJ772', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-33', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 1000, 11407, 11383);
INSERT INTO "ProdNac2021".cdg VALUES (3301220, 'RJ1220', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1285-3', 'SPU-RJ - Geoinformação', '062.987-MP', '051/42', 'Analógico', 'Carta Cadastral', '59.Gaveta17.Jacone_LagoaAraruama_TrechoJacone-PontaNegra', 'Terreno de Marinha', 1977, NULL, 'Não', 'Não possui', 0, 2500, 11460, 11656);
INSERT INTO "ProdNac2021".cdg VALUES (3304750, 'RJ4750', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300963, 'RJ963', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '4B', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12128, 12041);
INSERT INTO "ProdNac2021".cdg VALUES (3300271, 'RJ271', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-4', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8245, 7678);
INSERT INTO "ProdNac2021".cdg VALUES (3300469, 'RJ469', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 1', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 8989, 8021);
INSERT INTO "ProdNac2021".cdg VALUES (3304925, 'RJ4925', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300754, 'RJ754', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-16', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11336, 11296);
INSERT INTO "ProdNac2021".cdg VALUES (3304788, 'RJ4788', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300581, 'RJ581', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-3', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9806, 9569);
INSERT INTO "ProdNac2021".cdg VALUES (3301223, 'RJ1223', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1285-6', 'SPU-RJ - Geoinformação', '062.987-MP', '051/42', 'Analógico', 'Carta Cadastral', '59.Gaveta17.Jacone_LagoaAraruama_TrechoJacone-PontaNegra', 'Terreno de Marinha', 1977, NULL, 'Não', 'Não possui', 0, 2500, 11641, 11661);
INSERT INTO "ProdNac2021".cdg VALUES (3300642, 'RJ642', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-39', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 9441, 8275);
INSERT INTO "ProdNac2021".cdg VALUES (3300635, 'RJ635', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-32', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8855, 8240);
INSERT INTO "ProdNac2021".cdg VALUES (3300300, 'RJ300', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-3', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9324, 8638);
INSERT INTO "ProdNac2021".cdg VALUES (3300276, 'RJ276', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-9', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8283, 7718);
INSERT INTO "ProdNac2021".cdg VALUES (3304928, 'RJ4928', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304831, 'RJ4831', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300703, 'RJ703', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-33', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11963, 11876);
INSERT INTO "ProdNac2021".cdg VALUES (3300501, 'RJ501', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2720-4', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 10410, 10400);
INSERT INTO "ProdNac2021".cdg VALUES (3304654, 'RJ4654', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300948, 'RJ948', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-10', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11747, 11731);
INSERT INTO "ProdNac2021".cdg VALUES (3300973, 'RJ973', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2D', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12089, 12036);
INSERT INTO "ProdNac2021".cdg VALUES (3300034, 'RJ34', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-6', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8704, 8543);
INSERT INTO "ProdNac2021".cdg VALUES (3300502, 'RJ502', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2720-5', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 10411, 10401);
INSERT INTO "ProdNac2021".cdg VALUES (3300478, 'RJ478', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 10', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 9007, 8174);
INSERT INTO "ProdNac2021".cdg VALUES (3300369, 'RJ369', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-65', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9952, 9270);
INSERT INTO "ProdNac2021".cdg VALUES (3300278, 'RJ278', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-11', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8306, 7743);
INSERT INTO "ProdNac2021".cdg VALUES (3304825, 'RJ4825', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300223, 'RJ223', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-5', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11036, 9516);
INSERT INTO "ProdNac2021".cdg VALUES (3304468, 'RJ4468', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304435, 'RJ4435', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300917, 'RJ917', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-6', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12192, 12172);
INSERT INTO "ProdNac2021".cdg VALUES (3304371, 'RJ4371', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300608, 'RJ608', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-5', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8436, 7807);
INSERT INTO "ProdNac2021".cdg VALUES (3304511, 'RJ4511', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304915, 'RJ4915', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304691, 'RJ4691', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300506, 'RJ506', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3973-1', 'SPU-RJ - Geoinformação', '117.137-MP', '09481/80', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1980, NULL, 'Não', 'Não possui', 0, 2000, 10639, 10568);
INSERT INTO "ProdNac2021".cdg VALUES (3300417, 'RJ417', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-24', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8825, 7676);
INSERT INTO "ProdNac2021".cdg VALUES (3304956, 'RJ4956', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304335, 'RJ4335', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300684, 'RJ684', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-14', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11922, 11717);
INSERT INTO "ProdNac2021".cdg VALUES (3300194, 'RJ194', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-21', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11011, 9251);
INSERT INTO "ProdNac2021".cdg VALUES (3301181, 'RJ1181', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2096-6', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300853, 'RJ853', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-71', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12784, 12370);
INSERT INTO "ProdNac2021".cdg VALUES (3304760, 'RJ4760', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304347, 'RJ4347', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300198, 'RJ198', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-25', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11015, 9272);
INSERT INTO "ProdNac2021".cdg VALUES (3300887, 'RJ887', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-104', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12838, 12476);
INSERT INTO "ProdNac2021".cdg VALUES (3301145, 'RJ1145', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-6', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12505, 11692);
INSERT INTO "ProdNac2021".cdg VALUES (3304599, 'RJ4599', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304742, 'RJ4742', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300861, 'RJ861', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-79', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12794, 12379);
INSERT INTO "ProdNac2021".cdg VALUES (3300866, 'RJ866', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-84', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12802, 12384);
INSERT INTO "ProdNac2021".cdg VALUES (3304733, 'RJ4733', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301204, 'RJ1204', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-5', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12013, 11974);
INSERT INTO "ProdNac2021".cdg VALUES (3304402, 'RJ4402', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304490, 'RJ4490', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300210, 'RJ210', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-37', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11027, 9365);
INSERT INTO "ProdNac2021".cdg VALUES (3304579, 'RJ4579', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300140, 'RJ140', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 L', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9885, 9858);
INSERT INTO "ProdNac2021".cdg VALUES (3301159, 'RJ1159', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2222-1', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12587, 12253);
INSERT INTO "ProdNac2021".cdg VALUES (3301000, 'RJ1000', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '12', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11635, 11546);
INSERT INTO "ProdNac2021".cdg VALUES (3304996, 'RJ4996', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304393, 'RJ4393', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300552, 'RJ552', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-11', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10306, 10024);
INSERT INTO "ProdNac2021".cdg VALUES (3300331, 'RJ331', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-32', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9658, 8732);
INSERT INTO "ProdNac2021".cdg VALUES (3300912, 'RJ912', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-1', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12187, 12167);
INSERT INTO "ProdNac2021".cdg VALUES (3300212, 'RJ212', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-39', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11029, 9371);
INSERT INTO "ProdNac2021".cdg VALUES (3304424, 'RJ4424', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304433, 'RJ4433', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304833, 'RJ4833', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304916, 'RJ4916', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300220, 'RJ220', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-2', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11033, 9503);
INSERT INTO "ProdNac2021".cdg VALUES (3300505, 'RJ505', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2720-8', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 10414, 10404);
INSERT INTO "ProdNac2021".cdg VALUES (3300240, 'RJ240', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-8', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11052, 10099);
INSERT INTO "ProdNac2021".cdg VALUES (3300191, 'RJ191', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-18', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11008, 9241);
INSERT INTO "ProdNac2021".cdg VALUES (3304875, 'RJ4875', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300909, 'RJ909', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1934-5', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301166, 'RJ1166', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2290-2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1971, NULL, 'Não', 'Não possui', 0, 1000, 12620, 12288);
INSERT INTO "ProdNac2021".cdg VALUES (3300940, 'RJ940', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-2', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11739, 11721);
INSERT INTO "ProdNac2021".cdg VALUES (3304437, 'RJ4437', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300073, 'RJ73', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2064-3', 'SPU-RJ - Geoinformação', '117.137-MP', '46.155/50', 'Analógico', 'Carta Cadastral', '08.LinhaPreamarMedio1831_AvenidaRuyBarbosa', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8180, 7638);
INSERT INTO "ProdNac2021".cdg VALUES (3304417, 'RJ4417', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304438, 'RJ4438', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304389, 'RJ4389', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304520, 'RJ4520', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300164, 'RJ164', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 B', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Cadastral', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 10710, 8335);
INSERT INTO "ProdNac2021".cdg VALUES (3301199, 'RJ1199', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'ÍNDICE 2344-18', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Índice', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 5000, 11953, 11952);
INSERT INTO "ProdNac2021".cdg VALUES (3304439, 'RJ4439', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300828, 'RJ828', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-48', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11749, 11528);
INSERT INTO "ProdNac2021".cdg VALUES (3304685, 'RJ4685', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300144, 'RJ144', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 P', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9889, 9866);
INSERT INTO "ProdNac2021".cdg VALUES (3304600, 'RJ4600', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304609, 'RJ4609', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304997, 'RJ4997', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304729, 'RJ4729', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300302, 'RJ302', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-5', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9332, 8654);
INSERT INTO "ProdNac2021".cdg VALUES (3300638, 'RJ638', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-35', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8862, 8248);
INSERT INTO "ProdNac2021".cdg VALUES (3304731, 'RJ4731', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300341, 'RJ341', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-42', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9700, 9159);
INSERT INTO "ProdNac2021".cdg VALUES (3300173, 'RJ173', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Índice', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 10000, 10725, 8441);
INSERT INTO "ProdNac2021".cdg VALUES (3300419, 'RJ419', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-26', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8828, 7685);
INSERT INTO "ProdNac2021".cdg VALUES (3300922, 'RJ922', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-11', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12197, 12177);
INSERT INTO "ProdNac2021".cdg VALUES (3301215, 'RJ1215', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-16', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12030, 11996);
INSERT INTO "ProdNac2021".cdg VALUES (3304483, 'RJ4483', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304957, 'RJ4957', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300148, 'RJ148', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 T', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9894, 9869);
INSERT INTO "ProdNac2021".cdg VALUES (3304333, 'RJ4333', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304489, 'RJ4489', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300337, 'RJ337', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-38', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9693, 9135);
INSERT INTO "ProdNac2021".cdg VALUES (3304835, 'RJ4835', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300706, 'RJ706', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-36', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11959, 11879);
INSERT INTO "ProdNac2021".cdg VALUES (3304496, 'RJ4496', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304565, 'RJ4565', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304911, 'RJ4911', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301053, 'RJ1053', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '17', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301080, 'RJ1080', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '44', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300743, 'RJ743', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-9', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11284, 11268);
INSERT INTO "ProdNac2021".cdg VALUES (3300895, 'RJ895', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-8', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11929, 11765);
INSERT INTO "ProdNac2021".cdg VALUES (3304793, 'RJ4793', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304838, 'RJ4838', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300928, 'RJ928', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-17', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12203, 12183);
INSERT INTO "ProdNac2021".cdg VALUES (3300476, 'RJ476', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 8', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 9005, 8172);
INSERT INTO "ProdNac2021".cdg VALUES (3304482, 'RJ4482', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300114, 'RJ114', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-N', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9725, 9674);
INSERT INTO "ProdNac2021".cdg VALUES (3304964, 'RJ4964', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300045, 'RJ45', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-17', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8721, 8680);
INSERT INTO "ProdNac2021".cdg VALUES (3304436, 'RJ4436', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300585, 'RJ585', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-7', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9810, 9797);
INSERT INTO "ProdNac2021".cdg VALUES (3300484, 'RJ484', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 4', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9031, 8184);
INSERT INTO "ProdNac2021".cdg VALUES (3304776, 'RJ4776', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300205, 'RJ205', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-32', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11022, 9338);
INSERT INTO "ProdNac2021".cdg VALUES (3300957, 'RJ957', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1972-4', 'SPU-RJ - Geoinformação', '062.987-MP', '8077/37', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1960, NULL, 'Não', 'Não possui', 0, 500, 11401, 11394);
INSERT INTO "ProdNac2021".cdg VALUES (3300260, 'RJ260', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345A', 'SPU-RJ - Geoinformação', '117.137-MP', '17.225/54', 'Analógico', 'Carta Índice', '23.Trecho_PracaMaua-PalacioMonroe', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 5000, 11152, 10264);
INSERT INTO "ProdNac2021".cdg VALUES (3300632, 'RJ632', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-29', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8848, 8219);
INSERT INTO "ProdNac2021".cdg VALUES (3300701, 'RJ701', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-31', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11947, 11808);
INSERT INTO "ProdNac2021".cdg VALUES (3304995, 'RJ4995', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300440, 'RJ440', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-6', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8931, 7948);
INSERT INTO "ProdNac2021".cdg VALUES (3300956, 'RJ956', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1972-3', 'SPU-RJ - Geoinformação', '062.987-MP', '8077/37', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1960, NULL, 'Não', 'Não possui', 0, 500, 11400, 11393);
INSERT INTO "ProdNac2021".cdg VALUES (3304889, 'RJ4889', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300716, 'RJ716', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-46', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11972, 11889);
INSERT INTO "ProdNac2021".cdg VALUES (3300311, 'RJ311', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-13', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9600, 8675);
INSERT INTO "ProdNac2021".cdg VALUES (3304741, 'RJ4741', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300382, 'RJ382', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-5', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8421, 7896);
INSERT INTO "ProdNac2021".cdg VALUES (3301172, 'RJ1172', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1809-2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304944, 'RJ4944', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300204, 'RJ204', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-31', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11021, 9329);
INSERT INTO "ProdNac2021".cdg VALUES (3300766, 'RJ766', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-28', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11350, 11308);
INSERT INTO "ProdNac2021".cdg VALUES (3301098, 'RJ1098', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-6', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11814, 11694);
INSERT INTO "ProdNac2021".cdg VALUES (3300526, 'RJ526', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 14', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8869, 8313);
INSERT INTO "ProdNac2021".cdg VALUES (3300958, 'RJ958', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1972-6', 'SPU-RJ - Geoinformação', '062.987-MP', '8077/37', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1960, NULL, 'Não', 'Não possui', 0, 500, 11402, 11395);
INSERT INTO "ProdNac2021".cdg VALUES (3301128, 'RJ1128', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-23', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12057, 11858);
INSERT INTO "ProdNac2021".cdg VALUES (3304647, 'RJ4647', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304663, 'RJ4663', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304567, 'RJ4567', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300482, 'RJ482', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 2', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9029, 8182);
INSERT INTO "ProdNac2021".cdg VALUES (3304740, 'RJ4740', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300567, 'RJ567', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2803-6', 'SPU-RJ - Geoinformação', '117.137-MP', '307.820/57', 'Analógico', 'Carta Cadastral', '38.Trecho_EstradaJacarepagua-ArroioFundo', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9965, 9943);
INSERT INTO "ProdNac2021".cdg VALUES (3304761, 'RJ4761', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300878, 'RJ878', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-95', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12827, 12464);
INSERT INTO "ProdNac2021".cdg VALUES (3300143, 'RJ143', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 O', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9890, 9863);
INSERT INTO "ProdNac2021".cdg VALUES (3301214, 'RJ1214', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-15', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12029, 11991);
INSERT INTO "ProdNac2021".cdg VALUES (3304392, 'RJ4392', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300459, 'RJ459', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-24', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8963, 7988);
INSERT INTO "ProdNac2021".cdg VALUES (3300929, 'RJ929', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-18', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12204, 12184);
INSERT INTO "ProdNac2021".cdg VALUES (3300996, 'RJ996', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '8', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11631, 11540);
INSERT INTO "ProdNac2021".cdg VALUES (3304408, 'RJ4408', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300664, 'RJ664', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1896-3', 'SPU-RJ - Geoinformação', '062.987-MP', '1423/54', 'Analógico', 'Carta Cadastral', '45.Gaveta1.BarraSaoJoao-CaimiroAbreu_Trecho_CidadeSaoJoao-CasimiroAbreu', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11199, 11189);
INSERT INTO "ProdNac2021".cdg VALUES (3300460, 'RJ460', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-25', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8964, 7989);
INSERT INTO "ProdNac2021".cdg VALUES (3304488, 'RJ4488', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304746, 'RJ4746', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304523, 'RJ4523', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300023, 'RJ23', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1815-C', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 280.255/48 Novo:10768.015327/92-12', 'Analógico', 'Carta Cadastral', '03.PlantaLinhadeMarinha_AvenidaPasteurCompostacomElementosColigidosno', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 500, 8442, 8429);
INSERT INTO "ProdNac2021".cdg VALUES (3300154, 'RJ154', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2311 A''', 'SPU-RJ - Geoinformação', '117.137-MP', '108.875/50', 'Analógico', 'Carta Cadastral', '15.Trecho_Jequiriçá-JoaoPizarro', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 10669, 7795);
INSERT INTO "ProdNac2021".cdg VALUES (3300004, 'RJ04', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1759-D', 'SPU-RJ - Geoinformação', '117.137-MP', '89.554/54', 'Analógico', 'Carta Cadastral', '01.PlantaFaixadeMarinhaRuaSantoCristo', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 7828, 7802);
INSERT INTO "ProdNac2021".cdg VALUES (3300481, 'RJ481', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 1', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9028, 8181);
INSERT INTO "ProdNac2021".cdg VALUES (3300937, 'RJ937', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'Folha 6', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', NULL, NULL, 'Não', 'Não possui', 0, 500, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301225, 'RJ1225', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1903-1', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 645/55 Novo:245.239-60', 'Analógico', 'Carta Cadastral', '61.Gaveta19.Itacurussa_Trecho_OrlaMarinha', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11447, 11437);
INSERT INTO "ProdNac2021".cdg VALUES (3300388, 'RJ388', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-11', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8444, 7910);
INSERT INTO "ProdNac2021".cdg VALUES (3301216, 'RJ1216', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-17', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12031, 11997);
INSERT INTO "ProdNac2021".cdg VALUES (3304515, 'RJ4515', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300670, 'RJ670', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346', 'SPU-RJ - Geoinformação', '062.987-MP', '0786-1371/74', 'Analógico', 'Carta Índice', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 20000, 11700, 11699);
INSERT INTO "ProdNac2021".cdg VALUES (3304386, 'RJ4386', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301011, 'RJ1011', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '23', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11658, 11563);
INSERT INTO "ProdNac2021".cdg VALUES (3300697, 'RJ697', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-27', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11943, 11804);
INSERT INTO "ProdNac2021".cdg VALUES (3304703, 'RJ4703', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300479, 'RJ479', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 11', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 9008, 8175);
INSERT INTO "ProdNac2021".cdg VALUES (3301155, 'RJ1155', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2208-3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12576, 12227);
INSERT INTO "ProdNac2021".cdg VALUES (3300768, 'RJ768', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-30', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11353, 11310);
INSERT INTO "ProdNac2021".cdg VALUES (3300062, 'RJ62', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1982', 'SPU-RJ - Geoinformação', '117.137-MP', '19.450/50', 'Analógico', 'Carta Índice', '06.LinhaPreamarMedio1831_EntreRuaJoaoPizarroeAvenidaTexeiradeCastro', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 2000, 8781, 8776);
INSERT INTO "ProdNac2021".cdg VALUES (3304887, 'RJ4887', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301919, 'RJ1919', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '237', 'SPU-RJ - Geoinformação', '117.147-MP', '2576/82', 'Analógico', 'Carta Cadastral', '70.TrechoB_Secao3_AngraReis-Parati_PontaLoba-PontaCajaiba', 'Terreno de Marinha', 1982, NULL, 'Sim', 'Possui', 29193, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300199, 'RJ199', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-26', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11016, 9277);
INSERT INTO "ProdNac2021".cdg VALUES (3300049, 'RJ49', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1880', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Índice', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 10000, 8758, 8731);
INSERT INTO "ProdNac2021".cdg VALUES (3300358, 'RJ358', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-59', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9743, 9237);
INSERT INTO "ProdNac2021".cdg VALUES (3304643, 'RJ4643', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300970, 'RJ970', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '6C', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12135, 12047);
INSERT INTO "ProdNac2021".cdg VALUES (3304534, 'RJ4534', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300112, 'RJ112', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-L', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9696, 9671);
INSERT INTO "ProdNac2021".cdg VALUES (3300792, 'RJ792', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-13', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11574, 11449);
INSERT INTO "ProdNac2021".cdg VALUES (3300873, 'RJ873', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-90', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12822, 12459);
INSERT INTO "ProdNac2021".cdg VALUES (3301161, 'RJ1161', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2222-3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12591, 12259);
INSERT INTO "ProdNac2021".cdg VALUES (3300945, 'RJ945', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-7', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11744, 11728);
INSERT INTO "ProdNac2021".cdg VALUES (3300520, 'RJ520', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 8', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8860, 8272);
INSERT INTO "ProdNac2021".cdg VALUES (3304753, 'RJ4753', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304912, 'RJ4912', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300869, 'RJ869', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046 D', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Índice', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 10000, 12809, 12452);
INSERT INTO "ProdNac2021".cdg VALUES (3304670, 'RJ4670', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300013, 'RJ13', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 6', 'SPU-RJ - Geoinformação', '117.137-MP', '13.5305/47', 'Analógico', 'Carta Cadastral', '02.PlantaFaixadeMarinhas_PraiadeBotafogo', 'Terreno de Marinha', 1947, NULL, 'Não', 'Não possui', 0, 500, 8073, 8055);
INSERT INTO "ProdNac2021".cdg VALUES (3301167, 'RJ1167', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2290-3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1971, NULL, 'Não', 'Não possui', 0, 1000, 12621, 12295);
INSERT INTO "ProdNac2021".cdg VALUES (3300100, 'RJ100', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Índice', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 10000, 9680, 9612);
INSERT INTO "ProdNac2021".cdg VALUES (3300704, 'RJ704', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-34', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11964, 11877);
INSERT INTO "ProdNac2021".cdg VALUES (3304736, 'RJ4736', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304808, 'RJ4808', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301812, 'RJ1812', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Não', '92A''', 'SPU-RJ - Geoinformação', '117.147-MP', '2576/82', 'Analógico', 'Carta Cadastral', '70.TrechoB_Secao3_AngraReis-Parati_PontaLoba-PontaCajaiba', 'Terreno de Marinha', 1982, 0, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304566, 'RJ4566', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304653, 'RJ4653', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300319, 'RJ319', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-20', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9620, 8703);
INSERT INTO "ProdNac2021".cdg VALUES (3300351, 'RJ351', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-52', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9719, 9209);
INSERT INTO "ProdNac2021".cdg VALUES (3300322, 'RJ322', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-23', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9627, 8714);
INSERT INTO "ProdNac2021".cdg VALUES (3300749, 'RJ749', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-12', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11290, 11274);
INSERT INTO "ProdNac2021".cdg VALUES (3300258, 'RJ258', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-J', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11150, 10234);
INSERT INTO "ProdNac2021".cdg VALUES (3300788, 'RJ788', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-9', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11567, 11451);
INSERT INTO "ProdNac2021".cdg VALUES (3304723, 'RJ4723', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300654, 'RJ654', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-G', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 10604, 10583);
INSERT INTO "ProdNac2021".cdg VALUES (3300435, 'RJ435', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-1', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8916, 7927);
INSERT INTO "ProdNac2021".cdg VALUES (3300914, 'RJ914', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-3', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12189, 12169);
INSERT INTO "ProdNac2021".cdg VALUES (3300101, 'RJ101', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-A', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9681, 9618);
INSERT INTO "ProdNac2021".cdg VALUES (3300280, 'RJ280', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-13', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8324, 7756);
INSERT INTO "ProdNac2021".cdg VALUES (3300790, 'RJ790', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-11', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11569, 11454);
INSERT INTO "ProdNac2021".cdg VALUES (3300745, 'RJ745', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-10', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11286, 11270);
INSERT INTO "ProdNac2021".cdg VALUES (3300244, 'RJ244', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-12', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11056, 10113);
INSERT INTO "ProdNac2021".cdg VALUES (3300565, 'RJ565', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2803-4', 'SPU-RJ - Geoinformação', '117.137-MP', '307.820/57', 'Analógico', 'Carta Cadastral', '38.Trecho_EstradaJacarepagua-ArroioFundo', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9963, 9941);
INSERT INTO "ProdNac2021".cdg VALUES (3300803, 'RJ803', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-24', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11591, 11498);
INSERT INTO "ProdNac2021".cdg VALUES (3300652, 'RJ652', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-E', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 10602, 10580);
INSERT INTO "ProdNac2021".cdg VALUES (3304563, 'RJ4563', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304677, 'RJ4677', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304822, 'RJ4822', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301006, 'RJ1006', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '18', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11647, 11552);
INSERT INTO "ProdNac2021".cdg VALUES (3304954, 'RJ4954', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300165, 'RJ165', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 C', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Cadastral', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 10716, 8336);
INSERT INTO "ProdNac2021".cdg VALUES (3301018, 'RJ1018', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '30', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11670, 11579);
INSERT INTO "ProdNac2021".cdg VALUES (3301104, 'RJ1104', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-1', 'SPU-RJ - Geoinformação', '062.987-MP', '742/52', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 1000, 12084, 12124);
INSERT INTO "ProdNac2021".cdg VALUES (3300439, 'RJ439', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-5', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8930, 7947);
INSERT INTO "ProdNac2021".cdg VALUES (3304447, 'RJ4447', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304694, 'RJ4694', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301099, 'RJ1099', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-7', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11817, 11695);
INSERT INTO "ProdNac2021".cdg VALUES (3301212, 'RJ1212', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-13', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12027, 11989);
INSERT INTO "ProdNac2021".cdg VALUES (3304704, 'RJ4704', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300665, 'RJ665', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1896-4', 'SPU-RJ - Geoinformação', '062.987-MP', '1423/54', 'Analógico', 'Carta Cadastral', '45.Gaveta1.BarraSaoJoao-CaimiroAbreu_Trecho_CidadeSaoJoao-CasimiroAbreu', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11200, 11190);
INSERT INTO "ProdNac2021".cdg VALUES (3304769, 'RJ4769', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300455, 'RJ455', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-20', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8955, 7972);
INSERT INTO "ProdNac2021".cdg VALUES (3304813, 'RJ4813', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301851, 'RJ1851', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '173', 'SPU-RJ - Geoinformação', '117.147-MP', '2576/82', 'Analógico', 'Carta Cadastral', '70.TrechoB_Secao3_AngraReis-Parati_PontaLoba-PontaCajaiba', 'Terreno de Marinha', 1982, NULL, 'Sim', 'Possui', 29193, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300044, 'RJ44', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-16', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8719, 8678);
INSERT INTO "ProdNac2021".cdg VALUES (3300413, 'RJ413', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-20', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8820, 7669);
INSERT INTO "ProdNac2021".cdg VALUES (3304512, 'RJ4512', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304680, 'RJ4680', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300048, 'RJ48', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-20', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8726, 8686);
INSERT INTO "ProdNac2021".cdg VALUES (3300054, 'RJ54', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-5', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8765, 8747);
INSERT INTO "ProdNac2021".cdg VALUES (3301217, 'RJ1217', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-18', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300762, 'RJ762', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-24', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11346, 11304);
INSERT INTO "ProdNac2021".cdg VALUES (3304738, 'RJ4738', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300651, 'RJ651', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-D', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 10599, 10579);
INSERT INTO "ProdNac2021".cdg VALUES (3300097, 'RJ97', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'Carta Cadastral', 'SPU-RJ - Geoinformação', '163043 MP', NULL, 'Analógico', 'Carta Cadastral', '103.Sacco_de_Sao_Francisco-Niteroi', 'Terreno de Marinha', 1930, 0, 'Não', 'Não possui', 0, 500, 16703, 16702);
INSERT INTO "ProdNac2021".cdg VALUES (3301094, 'RJ1094', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-2', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11792, 11687);
INSERT INTO "ProdNac2021".cdg VALUES (3300566, 'RJ566', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2803-5', 'SPU-RJ - Geoinformação', '117.137-MP', '307.820/57', 'Analógico', 'Carta Cadastral', '38.Trecho_EstradaJacarepagua-ArroioFundo', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9964, 9942);
INSERT INTO "ProdNac2021".cdg VALUES (3300071, 'RJ71', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2064-1', 'SPU-RJ - Geoinformação', '117.137-MP', '46.155/50', 'Analógico', 'Carta Cadastral', '08.LinhaPreamarMedio1831_AvenidaRuyBarbosa', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8177, 7636);
INSERT INTO "ProdNac2021".cdg VALUES (3300424, 'RJ424', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-31', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8833, 7691);
INSERT INTO "ProdNac2021".cdg VALUES (3304958, 'RJ4958', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300688, 'RJ688', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-18', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11934, 11795);
INSERT INTO "ProdNac2021".cdg VALUES (3304730, 'RJ4730', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300935, 'RJ935', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'Folha 4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', NULL, NULL, 'Não', 'Não possui', 0, 500, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300783, 'RJ783', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-4', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11559, 11440);
INSERT INTO "ProdNac2021".cdg VALUES (3301076, 'RJ1076', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '40', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300441, 'RJ441', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-7', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8932, 7954);
INSERT INTO "ProdNac2021".cdg VALUES (3304878, 'RJ4878', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300879, 'RJ879', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-96', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12828, 12466);
INSERT INTO "ProdNac2021".cdg VALUES (3300356, 'RJ356', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-57', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9735, 9231);
INSERT INTO "ProdNac2021".cdg VALUES (3304683, 'RJ4683', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304814, 'RJ4814', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301143, 'RJ1143', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12503, 11688);
INSERT INTO "ProdNac2021".cdg VALUES (3300602, 'RJ602', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-12', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9561, 9529);
INSERT INTO "ProdNac2021".cdg VALUES (3300961, 'RJ961', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2B', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12087, 12025);
INSERT INTO "ProdNac2021".cdg VALUES (3300237, 'RJ237', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-5', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11049, 10087);
INSERT INTO "ProdNac2021".cdg VALUES (3300719, 'RJ719', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-49', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12108, 11906);
INSERT INTO "ProdNac2021".cdg VALUES (3304463, 'RJ4463', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304747, 'RJ4747', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304891, 'RJ4891', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300717, 'RJ717', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-47', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11976, 11890);
INSERT INTO "ProdNac2021".cdg VALUES (3300831, 'RJ831', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-51', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11752, 11533);
INSERT INTO "ProdNac2021".cdg VALUES (3301084, 'RJ1084', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '48', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301059, 'RJ1059', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '23', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300206, 'RJ206', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-33', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11023, 9343);
INSERT INTO "ProdNac2021".cdg VALUES (3304593, 'RJ4593', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304882, 'RJ4882', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304962, 'RJ4962', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300243, 'RJ243', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-11', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11055, 10110);
INSERT INTO "ProdNac2021".cdg VALUES (3301031, 'RJ1031', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '
Carta índice', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Índice', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 10000, 12000, 11978);
INSERT INTO "ProdNac2021".cdg VALUES (3304767, 'RJ4767', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304994, 'RJ4994', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301107, 'RJ1107', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-2', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11871, 11832);
INSERT INTO "ProdNac2021".cdg VALUES (3304510, 'RJ4510', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300847, 'RJ847', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-65', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12778, 12363);
INSERT INTO "ProdNac2021".cdg VALUES (3300389, 'RJ389', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-11A', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8448, 7912);
INSERT INTO "ProdNac2021".cdg VALUES (3300695, 'RJ695', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-25', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11941, 11802);
INSERT INTO "ProdNac2021".cdg VALUES (3304978, 'RJ4978', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300442, 'RJ442', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-8', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8933, 7953);
INSERT INTO "ProdNac2021".cdg VALUES (3300596, 'RJ596', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-6', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9549, 9520);
INSERT INTO "ProdNac2021".cdg VALUES (3304412, 'RJ4412', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304529, 'RJ4529', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300036, 'RJ36', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-8', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8707, 8543);
INSERT INTO "ProdNac2021".cdg VALUES (3301986, 'RJ1986', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 56', 'SPU-RJ - Geoinformação', '117.147-MP', NULL, 'Analógico', 'Carta Cadastral', '71.TrechoC_Parati_PontaLoba-PontaTrindade', 'Terreno de Marinha', 1980, NULL, 'Sim', 'Possui', 29193, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304458, 'RJ4458', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301175, 'RJ1175', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2096-1', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301171, 'RJ1171', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1809-1', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304536, 'RJ4536', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300136, 'RJ136', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 H', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9882, 9851);
INSERT INTO "ProdNac2021".cdg VALUES (3304465, 'RJ4465', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304834, 'RJ4834', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300134, 'RJ134', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 F', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9879, 9846);
INSERT INTO "ProdNac2021".cdg VALUES (3300030, 'RJ30', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-2', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8694, 8504);
INSERT INTO "ProdNac2021".cdg VALUES (3304945, 'RJ4945', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300838, 'RJ838', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-56', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12757, 12339);
INSERT INTO "ProdNac2021".cdg VALUES (3300894, 'RJ894', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-7', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11928, 11764);
INSERT INTO "ProdNac2021".cdg VALUES (3300175, 'RJ175', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-02', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10737, 8476);
INSERT INTO "ProdNac2021".cdg VALUES (3304766, 'RJ4766', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300927, 'RJ927', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-16', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12202, 12182);
INSERT INTO "ProdNac2021".cdg VALUES (3304953, 'RJ4953', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300991, 'RJ991', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11617, 11527);
INSERT INTO "ProdNac2021".cdg VALUES (3300835, 'RJ835', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046 A-2', 'SPU-RJ - Geoinformação', '062.987-MP', '0768-16052/81', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1981, NULL, 'Não', 'Não possui', 0, 500, 11594, 11538);
INSERT INTO "ProdNac2021".cdg VALUES (3300022, 'RJ22', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1815-B', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 280.255/48 Novo:10768.015327/92-12', 'Analógico', 'Carta Cadastral', '03.PlantaLinhadeMarinha_AvenidaPasteurCompostacomElementosColigidosno', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 500, 8437, 8419);
INSERT INTO "ProdNac2021".cdg VALUES (3304559, 'RJ4559', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300082, 'RJ82', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1181 C', 'SPU-RJ - Geoinformação', '117.137-MP', '62.079/51', 'Analógico', 'Carta Cadastral', '10.LinhaPreamarMedio1831_IlhasBaiacu-Cabras-Jurubaiba', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9025, 8985);
INSERT INTO "ProdNac2021".cdg VALUES (3300306, 'RJ306', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-9', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9348, 8657);
INSERT INTO "ProdNac2021".cdg VALUES (3304630, 'RJ4630', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304675, 'RJ4675', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304734, 'RJ4734', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304843, 'RJ4843', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304714, 'RJ4714', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304444, 'RJ4444', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300611, 'RJ611', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-8', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8509, 7812);
INSERT INTO "ProdNac2021".cdg VALUES (3300691, 'RJ691', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-21', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11937, 11798);
INSERT INTO "ProdNac2021".cdg VALUES (3300310, 'RJ310', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-12', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9598, 8673);
INSERT INTO "ProdNac2021".cdg VALUES (3300307, 'RJ307', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-9A', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9591, 8660);
INSERT INTO "ProdNac2021".cdg VALUES (3300543, 'RJ543', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-2', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10287, 10006);
INSERT INTO "ProdNac2021".cdg VALUES (3304902, 'RJ4902', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304615, 'RJ4615', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300541, 'RJ541', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Índice', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 10000, 10282, 9994);
INSERT INTO "ProdNac2021".cdg VALUES (3300064, 'RJ64', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1983-B', 'SPU-RJ - Geoinformação', '117.137-MP', '19.450/50', 'Analógico', 'Carta Cadastral', '06.LinhaPreamarMedio1831_EntreRuaJoaoPizarroeAvenidaTexeiradeCastro', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8783, 8778);
INSERT INTO "ProdNac2021".cdg VALUES (3300661, 'RJ661', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1896', 'SPU-RJ - Geoinformação', '062.987-MP', '1423/54', 'Analógico', 'Carta Índice', '45.Gaveta1.BarraSaoJoao-CaimiroAbreu_Trecho_CidadeSaoJoao-CasimiroAbreu', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 5000, 11195, 11148);
INSERT INTO "ProdNac2021".cdg VALUES (3304610, 'RJ4610', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300380, 'RJ380', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-3', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8413, 7892);
INSERT INTO "ProdNac2021".cdg VALUES (3300778, 'RJ778', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-39', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 1000, 11412, 11389);
INSERT INTO "ProdNac2021".cdg VALUES (3300886, 'RJ886', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-103', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12837, 12475);
INSERT INTO "ProdNac2021".cdg VALUES (3300761, 'RJ761', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-23', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11345, 11303);
INSERT INTO "ProdNac2021".cdg VALUES (3304456, 'RJ4456', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304470, 'RJ4470', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300376, 'RJ376', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-72', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9980, 9300);
INSERT INTO "ProdNac2021".cdg VALUES (3304827, 'RJ4827', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300660, 'RJ660', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-T', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 1000, 11136, 11132);
INSERT INTO "ProdNac2021".cdg VALUES (3304338, 'RJ4338', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300084, 'RJ84', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1182 A', 'SPU-RJ - Geoinformação', '117.137-MP', '62.079/51', 'Analógico', 'Carta Cadastral', '10.LinhaPreamarMedio1831_IlhasBaiacu-Cabras-Jurubaiba', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9036, 8992);
INSERT INTO "ProdNac2021".cdg VALUES (3304857, 'RJ4857', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300128, 'RJ128', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Índice', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 5000, 9872, 9833);
INSERT INTO "ProdNac2021".cdg VALUES (3300863, 'RJ863', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-81', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12798, 12381);
INSERT INTO "ProdNac2021".cdg VALUES (3301117, 'RJ1117', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-12', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12033, 11843);
INSERT INTO "ProdNac2021".cdg VALUES (3300713, 'RJ713', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-43', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11969, 11886);
INSERT INTO "ProdNac2021".cdg VALUES (3300699, 'RJ699', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-29', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11945, 11806);
INSERT INTO "ProdNac2021".cdg VALUES (3304385, 'RJ4385', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300158, 'RJ158', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1304 INDICE', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 217.118/52 Novo:10768.015325/92-89', 'Analógico', 'Carta Índice', '16.Trecho_RuaGamboa', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 2000, 10680, 8210);
INSERT INTO "ProdNac2021".cdg VALUES (3301170, 'RJ1170', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2290-6', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1971, NULL, 'Não', 'Não possui', 0, 1000, 12626, 12300);
INSERT INTO "ProdNac2021".cdg VALUES (3300523, 'RJ523', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 11', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8865, 8296);
INSERT INTO "ProdNac2021".cdg VALUES (3301148, 'RJ1148', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-9', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12508, 11951);
INSERT INTO "ProdNac2021".cdg VALUES (3304848, 'RJ4848', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304507, 'RJ4507', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304718, 'RJ4718', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301111, 'RJ1111', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-6', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12005, 11837);
INSERT INTO "ProdNac2021".cdg VALUES (3304764, 'RJ4764', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301189, 'RJ1189', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1810-3', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 12753, 12328);
INSERT INTO "ProdNac2021".cdg VALUES (3300467, 'RJ467', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Índice', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 10000, 8984, 8015);
INSERT INTO "ProdNac2021".cdg VALUES (3304498, 'RJ4498', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304328, 'RJ4328', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300443, 'RJ443', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-9', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8935, 7959);
INSERT INTO "ProdNac2021".cdg VALUES (3304936, 'RJ4936', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300225, 'RJ225', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-7', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11038, 9522);
INSERT INTO "ProdNac2021".cdg VALUES (3300464, 'RJ464', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-29', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8970, 7997);
INSERT INTO "ProdNac2021".cdg VALUES (3301100, 'RJ1100', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-8', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11820, 11696);
INSERT INTO "ProdNac2021".cdg VALUES (3304562, 'RJ4562', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300794, 'RJ794', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-15', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11576, 11458);
INSERT INTO "ProdNac2021".cdg VALUES (3300926, 'RJ926', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-15', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12201, 12181);
INSERT INTO "ProdNac2021".cdg VALUES (3300294, 'RJ294', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2447 B', 'SPU-RJ - Geoinformação', '117.137-MP', '264.905/52', 'Analógico', 'Carta Cadastral', '26.Trecho_LadeiraRussel-PalacioMonroe', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 1000, 11163, 10656);
INSERT INTO "ProdNac2021".cdg VALUES (3300607, 'RJ607', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-4', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8468, 7801);
INSERT INTO "ProdNac2021".cdg VALUES (3301182, 'RJ1182', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1810', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Índice', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 8000, 12749, 12325);
INSERT INTO "ProdNac2021".cdg VALUES (3300055, 'RJ55', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-6', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8766, 8748);
INSERT INTO "ProdNac2021".cdg VALUES (3300171, 'RJ171', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 I', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Cadastral', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 10722, 8399);
INSERT INTO "ProdNac2021".cdg VALUES (3304493, 'RJ4493', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301129, 'RJ1129', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-24', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12059, 11860);
INSERT INTO "ProdNac2021".cdg VALUES (3304922, 'RJ4922', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300666, 'RJ666', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1896-5', 'SPU-RJ - Geoinformação', '062.987-MP', '1423/54', 'Analógico', 'Carta Cadastral', '45.Gaveta1.BarraSaoJoao-CaimiroAbreu_Trecho_CidadeSaoJoao-CasimiroAbreu', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11201, 11191);
INSERT INTO "ProdNac2021".cdg VALUES (3300626, 'RJ626', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-23', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8816, 8189);
INSERT INTO "ProdNac2021".cdg VALUES (3301035, 'RJ1035', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12004, 11993);
INSERT INTO "ProdNac2021".cdg VALUES (3301203, 'RJ1203', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-4', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12011, 11973);
INSERT INTO "ProdNac2021".cdg VALUES (3300324, 'RJ324', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-25', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9635, 8720);
INSERT INTO "ProdNac2021".cdg VALUES (3300107, 'RJ107', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-G', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9687, 9648);
INSERT INTO "ProdNac2021".cdg VALUES (3300769, 'RJ769', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-C', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Índice', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 10000, 11380, 11379);
INSERT INTO "ProdNac2021".cdg VALUES (3301041, 'RJ1041', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '5', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301004, 'RJ1004', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '16', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11639, 11550);
INSERT INTO "ProdNac2021".cdg VALUES (3300385, 'RJ385', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-8', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8430, 7904);
INSERT INTO "ProdNac2021".cdg VALUES (3300832, 'RJ832', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-52', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11753, 11534);
INSERT INTO "ProdNac2021".cdg VALUES (3300751, 'RJ751', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-13', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11339, 11293);
INSERT INTO "ProdNac2021".cdg VALUES (3300773, 'RJ773', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-34', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 1000, 11406, 11384);
INSERT INTO "ProdNac2021".cdg VALUES (3300381, 'RJ381', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-4', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8417, 7893);
INSERT INTO "ProdNac2021".cdg VALUES (3304379, 'RJ4379', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300536, 'RJ536', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2759 INDICE', 'SPU-RJ - Geoinformação', '117.137-MP', '113.824/57', 'Analógico', 'Carta Índice', '36.Trecho_PraiaPontalSernambetiba-MorroCaete', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 10000, 10488, 10471);
INSERT INTO "ProdNac2021".cdg VALUES (3300942, 'RJ942', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-4', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11741, 11725);
INSERT INTO "ProdNac2021".cdg VALUES (3304582, 'RJ4582', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300992, 'RJ992', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11618, 11531);
INSERT INTO "ProdNac2021".cdg VALUES (3300570, 'RJ570', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2770 INDICE', 'SPU-RJ - Geoinformação', '117.137-MP', '23.8551/57', 'Analógico', 'Carta Índice', '39.Trecho_PraçaAlbertoTorres-RioPavuna', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 10000, 9832, 9819);
INSERT INTO "ProdNac2021".cdg VALUES (3304500, 'RJ4500', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304601, 'RJ4601', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300138, 'RJ138', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 J', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9884, 9855);
INSERT INTO "ProdNac2021".cdg VALUES (3300830, 'RJ830', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-50', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11751, 11530);
INSERT INTO "ProdNac2021".cdg VALUES (3301033, 'RJ1033', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12002, 11987);
INSERT INTO "ProdNac2021".cdg VALUES (3300437, 'RJ437', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-3', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8918, 7936);
INSERT INTO "ProdNac2021".cdg VALUES (3300489, 'RJ489', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 9', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9049, 8205);
INSERT INTO "ProdNac2021".cdg VALUES (3300183, 'RJ183', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-10', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10875, 9160);
INSERT INTO "ProdNac2021".cdg VALUES (3304809, 'RJ4809', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304990, 'RJ4990', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304758, 'RJ4758', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304840, 'RJ4840', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300180, 'RJ180', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-07', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10861, 9104);
INSERT INTO "ProdNac2021".cdg VALUES (3300085, 'RJ85', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1182 B', 'SPU-RJ - Geoinformação', '117.137-MP', '62.079/51', 'Analógico', 'Carta Cadastral', '10.LinhaPreamarMedio1831_IlhasBaiacu-Cabras-Jurubaiba', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9047, 8993);
INSERT INTO "ProdNac2021".cdg VALUES (3304415, 'RJ4415', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300347, 'RJ347', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-48', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9712, 9192);
INSERT INTO "ProdNac2021".cdg VALUES (3304888, 'RJ4888', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300471, 'RJ471', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 3', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 8991, 8023);
INSERT INTO "ProdNac2021".cdg VALUES (3304970, 'RJ4970', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304804, 'RJ4804', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304900, 'RJ4900', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300169, 'RJ169', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 G', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Cadastral', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 10720, 8354);
INSERT INTO "ProdNac2021".cdg VALUES (3300432, 'RJ432', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-39', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8841, 7706);
INSERT INTO "ProdNac2021".cdg VALUES (3300833, 'RJ833', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-53', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11754, 11535);
INSERT INTO "ProdNac2021".cdg VALUES (3300160, 'RJ160', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1304-2', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 217.118/52 Novo:10768.015325/92-89', 'Analógico', 'Carta Cadastral', '16.Trecho_RuaGamboa', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 1000, 10686, 8236);
INSERT INTO "ProdNac2021".cdg VALUES (3301034, 'RJ1034', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12003, 11992);
INSERT INTO "ProdNac2021".cdg VALUES (3300807, 'RJ807', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-27', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11598, 11502);
INSERT INTO "ProdNac2021".cdg VALUES (3301030, 'RJ1030', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '42', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11684, 11608);
INSERT INTO "ProdNac2021".cdg VALUES (3300925, 'RJ925', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-14', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12200, 12180);
INSERT INTO "ProdNac2021".cdg VALUES (3304790, 'RJ4790', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300637, 'RJ637', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-34', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8861, 8244);
INSERT INTO "ProdNac2021".cdg VALUES (3304739, 'RJ4739', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300060, 'RJ60', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-11', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8775, 8755);
INSERT INTO "ProdNac2021".cdg VALUES (3300068, 'RJ68', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1986-2', 'SPU-RJ - Geoinformação', '117.137-MP', '103.932/50', 'Analógico', 'Carta Cadastral', '07.LinhaPremarMedio1831_AvenidaFranciscoBhering(Arpoador)', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 10104, 10090);
INSERT INTO "ProdNac2021".cdg VALUES (3300161, 'RJ161', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1304-3', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 217.118/52 Novo:10768.015325/92-89', 'Analógico', 'Carta Cadastral', '16.Trecho_RuaGamboa', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 1000, 10690, 8247);
INSERT INTO "ProdNac2021".cdg VALUES (3300789, 'RJ789', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-10', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11568, 11452);
INSERT INTO "ProdNac2021".cdg VALUES (3300683, 'RJ683', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-13', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11921, 11716);
INSERT INTO "ProdNac2021".cdg VALUES (3304633, 'RJ4633', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300979, 'RJ979', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '9E', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12160, 12076);
INSERT INTO "ProdNac2021".cdg VALUES (3301151, 'RJ1151', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-14', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12566, 11994);
INSERT INTO "ProdNac2021".cdg VALUES (3300644, 'RJ644', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-41', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 9451, 8286);
INSERT INTO "ProdNac2021".cdg VALUES (3301162, 'RJ1162', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2222-4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12593, 12260);
INSERT INTO "ProdNac2021".cdg VALUES (3300339, 'RJ339', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-40', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9697, 9144);
INSERT INTO "ProdNac2021".cdg VALUES (3300801, 'RJ801', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-22', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11589, 11496);
INSERT INTO "ProdNac2021".cdg VALUES (3304356, 'RJ4356', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304430, 'RJ4430', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304639, 'RJ4639', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300524, 'RJ524', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 12', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8866, 8297);
INSERT INTO "ProdNac2021".cdg VALUES (3300035, 'RJ35', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-7', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8706, 8539);
INSERT INTO "ProdNac2021".cdg VALUES (3300099, 'RJ99', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'Carta Cadastral', 'SPU-RJ - Geoinformação', '163043 MP', NULL, 'Analógico', 'Carta Cadastral', '104.Sacco_de_Sao_Francisco_Trecho_Praia_de_Charirtas-Niteroi', 'Terreno de Marinha', 1937, 0, 'Não', 'Não possui', 0, 2000, 16707, 16706);
INSERT INTO "ProdNac2021".cdg VALUES (3300451, 'RJ451', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-16', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8948, 7968);
INSERT INTO "ProdNac2021".cdg VALUES (3300308, 'RJ308', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-10', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9593, 8664);
INSERT INTO "ProdNac2021".cdg VALUES (3300884, 'RJ884', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-101', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12833, 12473);
INSERT INTO "ProdNac2021".cdg VALUES (3300844, 'RJ844', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-62', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12775, 12360);
INSERT INTO "ProdNac2021".cdg VALUES (3300228, 'RJ228', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-11', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11041, 9545);
INSERT INTO "ProdNac2021".cdg VALUES (3304407, 'RJ4407', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304629, 'RJ4629', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304557, 'RJ4557', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301046, 'RJ1046', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '10', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304679, 'RJ4679', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304861, 'RJ4861', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301122, 'RJ1122', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-17', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12043, 11851);
INSERT INTO "ProdNac2021".cdg VALUES (3301064, 'RJ1064', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '28', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300057, 'RJ57', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-8', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8769, 8751);
INSERT INTO "ProdNac2021".cdg VALUES (3300357, 'RJ357', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-58', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9740, 9234);
INSERT INTO "ProdNac2021".cdg VALUES (3300776, 'RJ776', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-37', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 1000, 11410, 11387);
INSERT INTO "ProdNac2021".cdg VALUES (3300340, 'RJ340', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-41', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9698, 9150);
INSERT INTO "ProdNac2021".cdg VALUES (3304366, 'RJ4366', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304955, 'RJ4955', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300993, 'RJ993', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '5', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11622, 11532);
INSERT INTO "ProdNac2021".cdg VALUES (3300629, 'RJ629', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-26', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8844, 8204);
INSERT INTO "ProdNac2021".cdg VALUES (3300027, 'RJ27', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1925', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Índice', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 1000, 8687, 8479);
INSERT INTO "ProdNac2021".cdg VALUES (3300402, 'RJ402', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-9', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8802, 7650);
INSERT INTO "ProdNac2021".cdg VALUES (3300328, 'RJ328', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-29', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9649, 8728);
INSERT INTO "ProdNac2021".cdg VALUES (3304410, 'RJ4410', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304856, 'RJ4856', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304926, 'RJ4926', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300793, 'RJ793', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-14', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11575, 11450);
INSERT INTO "ProdNac2021".cdg VALUES (3304773, 'RJ4773', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300168, 'RJ168', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 F', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Cadastral', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 10719, 8352);
INSERT INTO "ProdNac2021".cdg VALUES (3301134, 'RJ1134', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-29', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12070, 11866);
INSERT INTO "ProdNac2021".cdg VALUES (3300196, 'RJ196', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-23', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11013, 9261);
INSERT INTO "ProdNac2021".cdg VALUES (3300474, 'RJ474', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 6', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 9000, 8026);
INSERT INTO "ProdNac2021".cdg VALUES (3300115, 'RJ115', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-O', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9728, 9675);
INSERT INTO "ProdNac2021".cdg VALUES (3300984, 'RJ984', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '9G', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12161, 12078);
INSERT INTO "ProdNac2021".cdg VALUES (3304440, 'RJ4440', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304528, 'RJ4528', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304787, 'RJ4787', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304924, 'RJ4924', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300656, 'RJ656', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-I', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 10608, 10586);
INSERT INTO "ProdNac2021".cdg VALUES (3300364, 'RJ364', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-61A', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9926, 9258);
INSERT INTO "ProdNac2021".cdg VALUES (3300392, 'RJ392', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-14', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8492, 7919);
INSERT INTO "ProdNac2021".cdg VALUES (3304499, 'RJ4499', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304351, 'RJ4351', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300779, 'RJ779', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046 A', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Índice', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 10000, 11545, 11427);
INSERT INTO "ProdNac2021".cdg VALUES (3300105, 'RJ105', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-E', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9685, 9637);
INSERT INTO "ProdNac2021".cdg VALUES (3300843, 'RJ843', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-61', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12774, 12358);
INSERT INTO "ProdNac2021".cdg VALUES (3301114, 'RJ1114', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-9', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12017, 11840);
INSERT INTO "ProdNac2021".cdg VALUES (3304660, 'RJ4660', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300118, 'RJ118', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-R', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9733, 9678);
INSERT INTO "ProdNac2021".cdg VALUES (3304341, 'RJ4341', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300677, 'RJ677', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-7', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11915, 11708);
INSERT INTO "ProdNac2021".cdg VALUES (3304597, 'RJ4597', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300487, 'RJ487', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 7', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9042, 8193);
INSERT INTO "ProdNac2021".cdg VALUES (3300515, 'RJ515', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 3', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8853, 8260);
INSERT INTO "ProdNac2021".cdg VALUES (3300574, 'RJ574', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2770-4', 'SPU-RJ - Geoinformação', '117.137-MP', '23.8551/57', 'Analógico', 'Carta Cadastral', '39.Trecho_PraçaAlbertoTorres-RioPavuna', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9842, 9826);
INSERT INTO "ProdNac2021".cdg VALUES (3300547, 'RJ547', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-6', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10298, 10011);
INSERT INTO "ProdNac2021".cdg VALUES (3300648, 'RJ648', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-A', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 10595, 10575);
INSERT INTO "ProdNac2021".cdg VALUES (3300972, 'RJ972', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1D', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12165, 12082);
INSERT INTO "ProdNac2021".cdg VALUES (3304592, 'RJ4592', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300466, 'RJ466', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-31', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8975, 7998);
INSERT INTO "ProdNac2021".cdg VALUES (3304687, 'RJ4687', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304752, 'RJ4752', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304726, 'RJ4726', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304988, 'RJ4988', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304865, 'RJ4865', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304642, 'RJ4642', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304771, 'RJ4771', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300708, 'RJ708', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-38', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11962, 11881);
INSERT INTO "ProdNac2021".cdg VALUES (3301044, 'RJ1044', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '8', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300589, 'RJ589', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-11', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9816, 9801);
INSERT INTO "ProdNac2021".cdg VALUES (3300883, 'RJ883', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-100', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12832, 12472);
INSERT INTO "ProdNac2021".cdg VALUES (3300560, 'RJ560', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-19', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10323, 10278);
INSERT INTO "ProdNac2021".cdg VALUES (3300352, 'RJ352', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-53', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9721, 9214);
INSERT INTO "ProdNac2021".cdg VALUES (3301065, 'RJ1065', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '29', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301016, 'RJ1016', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '28', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11666, 11577);
INSERT INTO "ProdNac2021".cdg VALUES (3300011, 'RJ11', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 4', 'SPU-RJ - Geoinformação', '117.137-MP', '13.5305/47', 'Analógico', 'Carta Cadastral', '02.PlantaFaixadeMarinhas_PraiadeBotafogo', 'Terreno de Marinha', 1947, NULL, 'Não', 'Não possui', 0, 500, 8068, 8051);
INSERT INTO "ProdNac2021".cdg VALUES (3300362, 'RJ362', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-60C', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9756, 9244);
INSERT INTO "ProdNac2021".cdg VALUES (3304853, 'RJ4853', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300634, 'RJ634', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-31', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8850, 8237);
INSERT INTO "ProdNac2021".cdg VALUES (3300081, 'RJ81', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1181 B', 'SPU-RJ - Geoinformação', '117.137-MP', '62.079/51', 'Analógico', 'Carta Cadastral', '10.LinhaPreamarMedio1831_IlhasBaiacu-Cabras-Jurubaiba', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9022, 8982);
INSERT INTO "ProdNac2021".cdg VALUES (3300457, 'RJ457', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-22', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8957, 7974);
INSERT INTO "ProdNac2021".cdg VALUES (3300131, 'RJ131', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 C', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9877, 9841);
INSERT INTO "ProdNac2021".cdg VALUES (3300750, 'RJ750', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-B', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Índice', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 5000, 11292, 11291);
INSERT INTO "ProdNac2021".cdg VALUES (3300513, 'RJ513', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 1', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8851, 8259);
INSERT INTO "ProdNac2021".cdg VALUES (3304556, 'RJ4556', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300059, 'RJ59', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-10', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8774, 8754);
INSERT INTO "ProdNac2021".cdg VALUES (3304571, 'RJ4571', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304770, 'RJ4770', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304815, 'RJ4815', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300646, 'RJ646', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-43', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 9460, 8299);
INSERT INTO "ProdNac2021".cdg VALUES (3300628, 'RJ628', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-25', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8826, 8198);
INSERT INTO "ProdNac2021".cdg VALUES (3300865, 'RJ865', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-83', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12799, 12383);
INSERT INTO "ProdNac2021".cdg VALUES (3301113, 'RJ1113', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-8', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12012, 11839);
INSERT INTO "ProdNac2021".cdg VALUES (3300400, 'RJ400', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-7', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8799, 7646);
INSERT INTO "ProdNac2021".cdg VALUES (3300519, 'RJ519', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 7', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8859, 8271);
INSERT INTO "ProdNac2021".cdg VALUES (3300273, 'RJ273', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-6', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8264, 7712);
INSERT INTO "ProdNac2021".cdg VALUES (3300977, 'RJ977', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '7E', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12145, 12055);
INSERT INTO "ProdNac2021".cdg VALUES (3300390, 'RJ390', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-12', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8466, 7914);
INSERT INTO "ProdNac2021".cdg VALUES (3304487, 'RJ4487', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300839, 'RJ839', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-57', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12758, 12343);
INSERT INTO "ProdNac2021".cdg VALUES (3300598, 'RJ598', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-8', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9555, 9524);
INSERT INTO "ProdNac2021".cdg VALUES (3300734, 'RJ734', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-A', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Índice', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 10000, 11275, 11234);
INSERT INTO "ProdNac2021".cdg VALUES (3300121, 'RJ121', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2218-2', 'SPU-RJ - Geoinformação', '117.137-MP', '41.263/52', 'Analógico', 'Carta Cadastral', '12.Trecho_RuaPedroAlves', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9765, 9749);
INSERT INTO "ProdNac2021".cdg VALUES (3300325, 'RJ325', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-26', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9638, 8722);
INSERT INTO "ProdNac2021".cdg VALUES (3304879, 'RJ4879', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304477, 'RJ4477', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300569, 'RJ569', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2803-8', 'SPU-RJ - Geoinformação', '117.137-MP', '307.820/57', 'Analógico', 'Carta Cadastral', '38.Trecho_EstradaJacarepagua-ArroioFundo', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9975, 9949);
INSERT INTO "ProdNac2021".cdg VALUES (3300281, 'RJ281', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-14', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8327, 7763);
INSERT INTO "ProdNac2021".cdg VALUES (3304353, 'RJ4353', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304935, 'RJ4935', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300262, 'RJ262', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345A-2', 'SPU-RJ - Geoinformação', '117.137-MP', '17.225/54', 'Analógico', 'Carta Cadastral', '23.Trecho_PracaMaua-PalacioMonroe', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11154, 10283);
INSERT INTO "ProdNac2021".cdg VALUES (3304648, 'RJ4648', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304421, 'RJ4421', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300824, 'RJ824', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-44', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11625, 11521);
INSERT INTO "ProdNac2021".cdg VALUES (3304547, 'RJ4547', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304987, 'RJ4987', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300463, 'RJ463', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-28', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8969, 7996);
INSERT INTO "ProdNac2021".cdg VALUES (3300360, 'RJ360', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-60A', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9750, 9242);
INSERT INTO "ProdNac2021".cdg VALUES (3300021, 'RJ21', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1815-A', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 280.255/48 Novo:10768.015327/92-12', 'Analógico', 'Carta Cadastral', '03.PlantaLinhadeMarinha_AvenidaPasteurCompostacomElementosColigidosno', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 500, 8434, 8415);
INSERT INTO "ProdNac2021".cdg VALUES (3304606, 'RJ4606', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300655, 'RJ655', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-H', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 10607, 10584);
INSERT INTO "ProdNac2021".cdg VALUES (3304904, 'RJ4904', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300052, 'RJ52', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-3', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8762, 8743);
INSERT INTO "ProdNac2021".cdg VALUES (3300954, 'RJ954', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1972-1', 'SPU-RJ - Geoinformação', '062.987-MP', '8077/37', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1960, NULL, 'Não', 'Não possui', 0, 500, 11398, 11391);
INSERT INTO "ProdNac2021".cdg VALUES (3304905, 'RJ4905', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300150, 'RJ150', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 V', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9896, 9898);
INSERT INTO "ProdNac2021".cdg VALUES (3304418, 'RJ4418', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304619, 'RJ4619', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300192, 'RJ192', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-19', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11009, 9245);
INSERT INTO "ProdNac2021".cdg VALUES (3304598, 'RJ4598', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304684, 'RJ4684', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300592, 'RJ592', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-2', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9538, 9510);
INSERT INTO "ProdNac2021".cdg VALUES (3300407, 'RJ407', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-14', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8812, 7656);
INSERT INTO "ProdNac2021".cdg VALUES (3300511, 'RJ511', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3973-6', 'SPU-RJ - Geoinformação', '117.137-MP', '09481/80', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1980, NULL, 'Não', 'Não possui', 0, 2000, 10648, 10626);
INSERT INTO "ProdNac2021".cdg VALUES (3304466, 'RJ4466', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301066, 'RJ1066', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '30', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304554, 'RJ4554', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304744, 'RJ4744', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304778, 'RJ4778', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304938, 'RJ4938', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304624, 'RJ4624', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304754, 'RJ4754', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304828, 'RJ4828', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304363, 'RJ4363', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304907, 'RJ4907', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300447, 'RJ447', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-13', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8942, 7926);
INSERT INTO "ProdNac2021".cdg VALUES (3301105, 'RJ1105', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-2', 'SPU-RJ - Geoinformação', '062.987-MP', '742/52', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 1000, 12086, 12129);
INSERT INTO "ProdNac2021".cdg VALUES (3304441, 'RJ4441', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304623, 'RJ4623', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300600, 'RJ600', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-10', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9558, 9527);
INSERT INTO "ProdNac2021".cdg VALUES (3300898, 'RJ898', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-11', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11931, 11768);
INSERT INTO "ProdNac2021".cdg VALUES (3304949, 'RJ4949', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300065, 'RJ65', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1983-C', 'SPU-RJ - Geoinformação', '117.137-MP', '19.450/50', 'Analógico', 'Carta Cadastral', '06.LinhaPreamarMedio1831_EntreRuaJoaoPizarroeAvenidaTexeiradeCastro', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8784, 8779);
INSERT INTO "ProdNac2021".cdg VALUES (3300251, 'RJ251', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-C', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11142, 10142);
INSERT INTO "ProdNac2021".cdg VALUES (3300086, 'RJ86', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1182 C', 'SPU-RJ - Geoinformação', '117.137-MP', '62.079/51', 'Analógico', 'Carta Cadastral', '10.LinhaPreamarMedio1831_IlhasBaiacu-Cabras-Jurubaiba', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9060, 8996);
INSERT INTO "ProdNac2021".cdg VALUES (3304797, 'RJ4797', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304751, 'RJ4751', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300915, 'RJ915', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-4', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12190, 12170);
INSERT INTO "ProdNac2021".cdg VALUES (3300187, 'RJ187', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-14', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10883, 9210);
INSERT INTO "ProdNac2021".cdg VALUES (3300147, 'RJ147', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 S', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9893, 9870);
INSERT INTO "ProdNac2021".cdg VALUES (3300399, 'RJ399', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-6', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8798, 7643);
INSERT INTO "ProdNac2021".cdg VALUES (3300287, 'RJ287', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2446 A', 'SPU-RJ - Geoinformação', '117.137-MP', '183.267/54', 'Analógico', 'Carta Cadastral', '25.Trecho_PraçaMaua-Gamboa', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 1000, 10013, 9996);
INSERT INTO "ProdNac2021".cdg VALUES (3300951, 'RJ951', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-13', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11771, 11734);
INSERT INTO "ProdNac2021".cdg VALUES (3300658, 'RJ658', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-R', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 1000, 11134, 11130);
INSERT INTO "ProdNac2021".cdg VALUES (3301042, 'RJ1042', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '6', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300261, 'RJ261', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345A-1', 'SPU-RJ - Geoinformação', '117.137-MP', '17.225/54', 'Analógico', 'Carta Cadastral', '23.Trecho_PracaMaua-PalacioMonroe', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11153, 10272);
INSERT INTO "ProdNac2021".cdg VALUES (3300619, 'RJ619', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-16', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8789, 8076);
INSERT INTO "ProdNac2021".cdg VALUES (3300601, 'RJ601', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-11', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9560, 9528);
INSERT INTO "ProdNac2021".cdg VALUES (3300186, 'RJ186', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-13', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10881, 9194);
INSERT INTO "ProdNac2021".cdg VALUES (3304849, 'RJ4849', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301060, 'RJ1060', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '24', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304375, 'RJ4375', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300266, 'RJ266', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345A-6', 'SPU-RJ - Geoinformação', '117.137-MP', '17.225/54', 'Analógico', 'Carta Cadastral', '23.Trecho_PracaMaua-PalacioMonroe', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11159, 10350);
INSERT INTO "ProdNac2021".cdg VALUES (3301062, 'RJ1062', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '26', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300046, 'RJ46', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-18', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8723, 8682);
INSERT INTO "ProdNac2021".cdg VALUES (3304449, 'RJ4449', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301019, 'RJ1019', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '31', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11672, 11583);
INSERT INTO "ProdNac2021".cdg VALUES (3304564, 'RJ4564', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300564, 'RJ564', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2803-3', 'SPU-RJ - Geoinformação', '117.137-MP', '307.820/57', 'Analógico', 'Carta Cadastral', '38.Trecho_EstradaJacarepagua-ArroioFundo', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9959, 9937);
INSERT INTO "ProdNac2021".cdg VALUES (3300470, 'RJ470', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 2', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 8990, 8022);
INSERT INTO "ProdNac2021".cdg VALUES (3301201, 'RJ1201', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-2', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12008, 11957);
INSERT INTO "ProdNac2021".cdg VALUES (3300653, 'RJ653', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-F', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 10603, 10581);
INSERT INTO "ProdNac2021".cdg VALUES (3300448, 'RJ448', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-14', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8943, 7966);
INSERT INTO "ProdNac2021".cdg VALUES (3300374, 'RJ374', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-70', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9972, 9290);
INSERT INTO "ProdNac2021".cdg VALUES (3300019, 'RJ19', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 280.255/48 Novo:10768.015327/92-12', 'Analógico', 'Carta Cadastral', '03.PlantaLinhadeMarinha_AvenidaPasteurCompostacomElementosColigidosno', 'Terreno de Marinha', 1948, NULL, 'Não', 'Não possui', 0, 500, 8407, 8385);
INSERT INTO "ProdNac2021".cdg VALUES (3301043, 'RJ1043', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '7', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304420, 'RJ4420', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304664, 'RJ4664', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301050, 'RJ1050', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '14', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304459, 'RJ4459', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300610, 'RJ610', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-7', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8505, 7811);
INSERT INTO "ProdNac2021".cdg VALUES (3304387, 'RJ4387', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300093, 'RJ93', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FLS - 3', 'SPU-RJ - Geoinformação', '163043 MP', '8077-37', 'Analógico', 'Carta Cadastral', '101.Praia_de_Icarahy-Niteroi', 'Terreno de Marinha', 1937, 0, 'Não', 'Não possui', 0, 2000, 16694, 16695);
INSERT INTO "ProdNac2021".cdg VALUES (3300190, 'RJ190', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-17', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10900, 9238);
INSERT INTO "ProdNac2021".cdg VALUES (3300845, 'RJ845', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-63', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12776, 12361);
INSERT INTO "ProdNac2021".cdg VALUES (3304391, 'RJ4391', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301093, 'RJ1093', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-1', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11791, 11686);
INSERT INTO "ProdNac2021".cdg VALUES (3300903, 'RJ903', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1979-5', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 522/60 Novo:228.538-60', 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1959, NULL, 'Não', 'Não possui', 0, 500, 12322, 12315);
INSERT INTO "ProdNac2021".cdg VALUES (3300662, 'RJ662', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1896-1', 'SPU-RJ - Geoinformação', '062.987-MP', '1423/54', 'Analógico', 'Carta Cadastral', '45.Gaveta1.BarraSaoJoao-CaimiroAbreu_Trecho_CidadeSaoJoao-CasimiroAbreu', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11197, 11187);
INSERT INTO "ProdNac2021".cdg VALUES (3300367, 'RJ367', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-63', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9939, 9266);
INSERT INTO "ProdNac2021".cdg VALUES (3301121, 'RJ1121', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-16', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12040, 11848);
INSERT INTO "ProdNac2021".cdg VALUES (3304359, 'RJ4359', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301088, 'RJ1088', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '52', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300982, 'RJ982', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '7G', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12149, 12060);
INSERT INTO "ProdNac2021".cdg VALUES (3300647, 'RJ647', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-44', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 9468, 8301);
INSERT INTO "ProdNac2021".cdg VALUES (3304678, 'RJ4678', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300014, 'RJ14', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 7', 'SPU-RJ - Geoinformação', '117.137-MP', '13.5305/47', 'Analógico', 'Carta Cadastral', '02.PlantaFaixadeMarinhas_PraiadeBotafogo', 'Terreno de Marinha', 1947, NULL, 'Não', 'Não possui', 0, 500, 8075, 8056);
INSERT INTO "ProdNac2021".cdg VALUES (3300406, 'RJ406', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-13', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8811, 7657);
INSERT INTO "ProdNac2021".cdg VALUES (3304382, 'RJ4382', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304724, 'RJ4724', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300946, 'RJ946', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-8', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11745, 11729);
INSERT INTO "ProdNac2021".cdg VALUES (3300675, 'RJ675', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-5', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11913, 11706);
INSERT INTO "ProdNac2021".cdg VALUES (3300066, 'RJ66', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1983-D', 'SPU-RJ - Geoinformação', '117.137-MP', '19.450/50', 'Analógico', 'Carta Cadastral', '06.LinhaPreamarMedio1831_EntreRuaJoaoPizarroeAvenidaTexeiradeCastro', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8785, 8780);
INSERT INTO "ProdNac2021".cdg VALUES (3300249, 'RJ249', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-A', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11140, 10137);
INSERT INTO "ProdNac2021".cdg VALUES (3300017, 'RJ17', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 10', 'SPU-RJ - Geoinformação', '117.137-MP', '13.5305/47', 'Analógico', 'Carta Cadastral', '02.PlantaFaixadeMarinhas_PraiadeBotafogo', 'Terreno de Marinha', 1947, NULL, 'Não', 'Não possui', 0, 500, 8086, 8060);
INSERT INTO "ProdNac2021".cdg VALUES (3304693, 'RJ4693', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301001, 'RJ1001', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '13', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11636, 11547);
INSERT INTO "ProdNac2021".cdg VALUES (3300953, 'RJ953', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-15', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11776, 11736);
INSERT INTO "ProdNac2021".cdg VALUES (3300630, 'RJ630', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-27', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8845, 8211);
INSERT INTO "ProdNac2021".cdg VALUES (3300645, 'RJ645', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-42', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 9457, 8290);
INSERT INTO "ProdNac2021".cdg VALUES (3304443, 'RJ4443', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301187, 'RJ1187', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1810-2', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 2000, 12752, 12327);
INSERT INTO "ProdNac2021".cdg VALUES (3300091, 'RJ91', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '240', 'SPU-RJ - Geoinformação', '163043 MP', '9.106/37', 'Analógico', 'Carta Cadastral', '100. Praia_das_Charitas-Niteroi', 'Terreno de Marinha', 1938, 0, 'Não', 'Não possui', 0, 1000, 16690, 16691);
INSERT INTO "ProdNac2021".cdg VALUES (3300436, 'RJ436', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-2', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8917, 7929);
INSERT INTO "ProdNac2021".cdg VALUES (3300239, 'RJ239', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-7', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11051, 10096);
INSERT INTO "ProdNac2021".cdg VALUES (3300151, 'RJ151', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 X', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9897, 9899);
INSERT INTO "ProdNac2021".cdg VALUES (3300132, 'RJ132', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 D', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9876, 9843);
INSERT INTO "ProdNac2021".cdg VALUES (3300429, 'RJ429', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-36', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8838, 7703);
INSERT INTO "ProdNac2021".cdg VALUES (3300289, 'RJ289', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2446 C', 'SPU-RJ - Geoinformação', '117.137-MP', '183.267/54', 'Analógico', 'Carta Cadastral', '25.Trecho_PraçaMaua-Gamboa', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 1000, 10019, 10001);
INSERT INTO "ProdNac2021".cdg VALUES (3304400, 'RJ4400', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304755, 'RJ4755', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300269, 'RJ269', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-2', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8230, 7658);
INSERT INTO "ProdNac2021".cdg VALUES (3300815, 'RJ815', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-35', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11612, 11510);
INSERT INTO "ProdNac2021".cdg VALUES (3300613, 'RJ613', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-10', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8786, 7814);
INSERT INTO "ProdNac2021".cdg VALUES (3300227, 'RJ227', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-9', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11040, 9537);
INSERT INTO "ProdNac2021".cdg VALUES (3304817, 'RJ4817', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300584, 'RJ584', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-6', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9809, 9573);
INSERT INTO "ProdNac2021".cdg VALUES (3300422, 'RJ422', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-29', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8831, 7688);
INSERT INTO "ProdNac2021".cdg VALUES (3300586, 'RJ586', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-8', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9811, 9798);
INSERT INTO "ProdNac2021".cdg VALUES (3304431, 'RJ4431', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304581, 'RJ4581', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300548, 'RJ548', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-7', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10299, 10015);
INSERT INTO "ProdNac2021".cdg VALUES (3304933, 'RJ4933', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300219, 'RJ219', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-1', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11032, 9494);
INSERT INTO "ProdNac2021".cdg VALUES (3304343, 'RJ4343', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301023, 'RJ1023', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '35', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11677, 11596);
INSERT INTO "ProdNac2021".cdg VALUES (3300950, 'RJ950', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-12', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11770, 11732);
INSERT INTO "ProdNac2021".cdg VALUES (3300056, 'RJ56', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-7', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8768, 8750);
INSERT INTO "ProdNac2021".cdg VALUES (3300404, 'RJ404', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-11', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8804, 7653);
INSERT INTO "ProdNac2021".cdg VALUES (3300612, 'RJ612', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-9', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8522, 7813);
INSERT INTO "ProdNac2021".cdg VALUES (3300327, 'RJ327', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-28', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9647, 8727);
INSERT INTO "ProdNac2021".cdg VALUES (3300800, 'RJ800', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-21', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11588, 11495);
INSERT INTO "ProdNac2021".cdg VALUES (3300971, 'RJ971', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '7C', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12140, 12051);
INSERT INTO "ProdNac2021".cdg VALUES (3304909, 'RJ4909', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300458, 'RJ458', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-23', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8962, 7987);
INSERT INTO "ProdNac2021".cdg VALUES (3304810, 'RJ4810', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300727, 'RJ727', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-57', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12110, 11900);
INSERT INTO "ProdNac2021".cdg VALUES (3300705, 'RJ705', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-35', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11965, 11878);
INSERT INTO "ProdNac2021".cdg VALUES (3300485, 'RJ485', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 5', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9040, 8191);
INSERT INTO "ProdNac2021".cdg VALUES (3300868, 'RJ868', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-86', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12804, 12386);
INSERT INTO "ProdNac2021".cdg VALUES (3300236, 'RJ236', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-4', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11048, 10084);
INSERT INTO "ProdNac2021".cdg VALUES (3300348, 'RJ348', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-49', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9714, 9198);
INSERT INTO "ProdNac2021".cdg VALUES (3300009, 'RJ09', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 2', 'SPU-RJ - Geoinformação', '117.137-MP', '13.5305/47', 'Analógico', 'Carta Cadastral', '02.PlantaFaixadeMarinhas_PraiadeBotafogo', 'Terreno de Marinha', 1947, NULL, 'Não', 'Não possui', 0, 500, 8063, 8046);
INSERT INTO "ProdNac2021".cdg VALUES (3301045, 'RJ1045', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '9', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300222, 'RJ222', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-4', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11035, 9508);
INSERT INTO "ProdNac2021".cdg VALUES (3304551, 'RJ4551', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304811, 'RJ4811', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300549, 'RJ549', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-8', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10300, 10016);
INSERT INTO "ProdNac2021".cdg VALUES (3304890, 'RJ4890', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304399, 'RJ4399', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301138, 'RJ1138', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1964, NULL, 'Não', 'Não possui', 0, 1000, 12501, 11685);
INSERT INTO "ProdNac2021".cdg VALUES (3301072, 'RJ1072', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '36', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304992, 'RJ4992', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300856, 'RJ856', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-74', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12788, 12373);
INSERT INTO "ProdNac2021".cdg VALUES (3300781, 'RJ781', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-2', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11556, 11436);
INSERT INTO "ProdNac2021".cdg VALUES (3300594, 'RJ594', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-4', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9543, 9515);
INSERT INTO "ProdNac2021".cdg VALUES (3304721, 'RJ4721', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300857, 'RJ857', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-75', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12789, 12374);
INSERT INTO "ProdNac2021".cdg VALUES (3300546, 'RJ546', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-5', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10297, 10010);
INSERT INTO "ProdNac2021".cdg VALUES (3300671, 'RJ671', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-1', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11907, 11702);
INSERT INTO "ProdNac2021".cdg VALUES (3300431, 'RJ431', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-38', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8840, 7707);
INSERT INTO "ProdNac2021".cdg VALUES (3300827, 'RJ827', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-47', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11628, 11525);
INSERT INTO "ProdNac2021".cdg VALUES (3300740, 'RJ740', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-7', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11281, 11265);
INSERT INTO "ProdNac2021".cdg VALUES (3300888, 'RJ888', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-1', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11772, 11758);
INSERT INTO "ProdNac2021".cdg VALUES (3300285, 'RJ285', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-18', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8380, 7777);
INSERT INTO "ProdNac2021".cdg VALUES (3300674, 'RJ674', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-4', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11912, 11705);
INSERT INTO "ProdNac2021".cdg VALUES (3304884, 'RJ4884', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300900, 'RJ900', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1979-2', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 522/60 Novo:228.538-60', 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1959, NULL, 'Não', 'Não possui', 0, 500, 12319, 12310);
INSERT INTO "ProdNac2021".cdg VALUES (3300580, 'RJ580', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-2', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9805, 9568);
INSERT INTO "ProdNac2021".cdg VALUES (3300890, 'RJ890', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-3', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11775, 11760);
INSERT INTO "ProdNac2021".cdg VALUES (3304339, 'RJ4339', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304480, 'RJ4480', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304661, 'RJ4661', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304446, 'RJ4446', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304759, 'RJ4759', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304885, 'RJ4885', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304419, 'RJ4419', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304604, 'RJ4604', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301132, 'RJ1132', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-27', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12068, 11864);
INSERT INTO "ProdNac2021".cdg VALUES (3304692, 'RJ4692', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300371, 'RJ371', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-67', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9961, 9278);
INSERT INTO "ProdNac2021".cdg VALUES (3304540, 'RJ4540', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304791, 'RJ4791', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304657, 'RJ4657', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300176, 'RJ176', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-03', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10739, 8481);
INSERT INTO "ProdNac2021".cdg VALUES (3300556, 'RJ556', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-15', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10312, 10251);
INSERT INTO "ProdNac2021".cdg VALUES (3300676, 'RJ676', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-6', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11914, 11707);
INSERT INTO "ProdNac2021".cdg VALUES (3300728, 'RJ728', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-58', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12111, 11901);
INSERT INTO "ProdNac2021".cdg VALUES (3300582, 'RJ582', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-4', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9807, 9570);
INSERT INTO "ProdNac2021".cdg VALUES (3300167, 'RJ167', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 E', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Cadastral', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 10718, 8350);
INSERT INTO "ProdNac2021".cdg VALUES (3304422, 'RJ4422', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304796, 'RJ4796', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304850, 'RJ4850', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304350, 'RJ4350', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300116, 'RJ116', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-P', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9729, 9676);
INSERT INTO "ProdNac2021".cdg VALUES (3300798, 'RJ798', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-19', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11586, 11493);
INSERT INTO "ProdNac2021".cdg VALUES (3304665, 'RJ4665', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304394, 'RJ4394', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300067, 'RJ67', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1986-1', 'SPU-RJ - Geoinformação', '117.137-MP', '103.932/50', 'Analógico', 'Carta Cadastral', '07.LinhaPremarMedio1831_AvenidaFranciscoBhering(Arpoador)', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 10100, 10088);
INSERT INTO "ProdNac2021".cdg VALUES (3304717, 'RJ4717', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300931, 'RJ931', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'Carta índice', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Índice', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', NULL, NULL, 'Não', 'Não possui', 0, 5000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300554, 'RJ554', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-13', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10310, 10249);
INSERT INTO "ProdNac2021".cdg VALUES (3300974, 'RJ974', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '6D', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12136, 12048);
INSERT INTO "ProdNac2021".cdg VALUES (3300185, 'RJ185', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-12', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10879, 9189);
INSERT INTO "ProdNac2021".cdg VALUES (3304638, 'RJ4638', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300403, 'RJ403', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-10', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8803, 7651);
INSERT INTO "ProdNac2021".cdg VALUES (3300207, 'RJ207', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-34', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11024, 9349);
INSERT INTO "ProdNac2021".cdg VALUES (3300657, 'RJ657', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-J', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 10610, 10587);
INSERT INTO "ProdNac2021".cdg VALUES (3300782, 'RJ782', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-3', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11555, 11439);
INSERT INTO "ProdNac2021".cdg VALUES (3300201, 'RJ201', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-28', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11018, 9302);
INSERT INTO "ProdNac2021".cdg VALUES (3300414, 'RJ414', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-21', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8822, 7671);
INSERT INTO "ProdNac2021".cdg VALUES (3304668, 'RJ4668', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300682, 'RJ682', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-12', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11920, 11715);
INSERT INTO "ProdNac2021".cdg VALUES (3304983, 'RJ4983', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304336, 'RJ4336', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300454, 'RJ454', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-19', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8954, 7971);
INSERT INTO "ProdNac2021".cdg VALUES (3304486, 'RJ4486', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304802, 'RJ4802', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300076, 'RJ76', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2068-A', 'SPU-RJ - Geoinformação', '117.137-MP', '10.8873/50', 'Analógico', 'Carta Cadastral', '09.LinhaPreamarMedio1831_RuaLoboJunior-RuaJequiriça-Prolong', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8893, 8884);
INSERT INTO "ProdNac2021".cdg VALUES (3300265, 'RJ265', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345A-5', 'SPU-RJ - Geoinformação', '117.137-MP', '17.225/54', 'Analógico', 'Carta Cadastral', '23.Trecho_PracaMaua-PalacioMonroe', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11158, 10347);
INSERT INTO "ProdNac2021".cdg VALUES (3304467, 'RJ4467', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300378, 'RJ378', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-1', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8403, 7883);
INSERT INTO "ProdNac2021".cdg VALUES (3304577, 'RJ4577', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304803, 'RJ4803', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304943, 'RJ4943', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300742, 'RJ742', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-8A', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11283, 11267);
INSERT INTO "ProdNac2021".cdg VALUES (3304651, 'RJ4651', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300503, 'RJ503', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2720-6', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 10412, 10402);
INSERT INTO "ProdNac2021".cdg VALUES (3304939, 'RJ4939', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300784, 'RJ784', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-5', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11560, 11441);
INSERT INTO "ProdNac2021".cdg VALUES (3304345, 'RJ4345', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300530, 'RJ530', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2753 - 3', 'SPU-RJ - Geoinformação', '117.137-MP', '237.984/54', 'Analógico', 'Carta Cadastral', '35.Trecho_PraiaSaoCristovaoAvenidaFranciscoBicalho', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10440, 10429);
INSERT INTO "ProdNac2021".cdg VALUES (3300836, 'RJ836', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '
Carta índice', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Índice', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 10000, 12754, 12334);
INSERT INTO "ProdNac2021".cdg VALUES (3301061, 'RJ1061', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '25', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304357, 'RJ4357', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300193, 'RJ193', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-20', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11010, 9247);
INSERT INTO "ProdNac2021".cdg VALUES (3304332, 'RJ4332', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300255, 'RJ255', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-G', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11146, 10221);
INSERT INTO "ProdNac2021".cdg VALUES (3301097, 'RJ1097', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-5', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11811, 11693);
INSERT INTO "ProdNac2021".cdg VALUES (3304901, 'RJ4901', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301218, 'RJ1218', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1285-1', 'SPU-RJ - Geoinformação', '062.987-MP', '051/42', 'Analógico', 'Carta Cadastral', '59.Gaveta17.Jacone_LagoaAraruama_TrechoJacone-PontaNegra', 'Terreno de Marinha', 1977, NULL, 'Não', 'Não possui', 0, 2500, 11456, 11648);
INSERT INTO "ProdNac2021".cdg VALUES (3301219, 'RJ1219', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1285-2', 'SPU-RJ - Geoinformação', '062.987-MP', '051/42', 'Analógico', 'Carta Cadastral', '59.Gaveta17.Jacone_LagoaAraruama_TrechoJacone-PontaNegra', 'Terreno de Marinha', 1977, NULL, 'Não', 'Não possui', 0, 2500, 11457, 11655);
INSERT INTO "ProdNac2021".cdg VALUES (3300990, 'RJ990', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11616, 11526);
INSERT INTO "ProdNac2021".cdg VALUES (3304632, 'RJ4632', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301123, 'RJ1123', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-18', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12046, 11853);
INSERT INTO "ProdNac2021".cdg VALUES (3304792, 'RJ4792', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304873, 'RJ4873', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301158, 'RJ1158', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2208-6', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12583, 12231);
INSERT INTO "ProdNac2021".cdg VALUES (3300787, 'RJ787', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-8', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11566, 11444);
INSERT INTO "ProdNac2021".cdg VALUES (3300720, 'RJ720', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-50', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12107, 11893);
INSERT INTO "ProdNac2021".cdg VALUES (3300317, 'RJ317', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-18', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9615, 8699);
INSERT INTO "ProdNac2021".cdg VALUES (3300254, 'RJ254', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-F', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11145, 10217);
INSERT INTO "ProdNac2021".cdg VALUES (3300275, 'RJ275', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-8', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8277, 7714);
INSERT INTO "ProdNac2021".cdg VALUES (3304497, 'RJ4497', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300795, 'RJ795', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-16', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11580, 11459);
INSERT INTO "ProdNac2021".cdg VALUES (3300814, 'RJ814', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-34', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11611, 11509);
INSERT INTO "ProdNac2021".cdg VALUES (3300500, 'RJ500', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2720-3', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 10408, 10399);
INSERT INTO "ProdNac2021".cdg VALUES (3304590, 'RJ4590', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304860, 'RJ4860', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301124, 'RJ1124', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-19', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12049, 11854);
INSERT INTO "ProdNac2021".cdg VALUES (3300155, 'RJ155', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2311 B', 'SPU-RJ - Geoinformação', '117.137-MP', '108.875/50', 'Analógico', 'Carta Cadastral', '15.Trecho_Jequiriçá-JoaoPizarro', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 10672, 7803);
INSERT INTO "ProdNac2021".cdg VALUES (3300174, 'RJ174', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-01', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10731, 8467);
INSERT INTO "ProdNac2021".cdg VALUES (3304979, 'RJ4979', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304762, 'RJ4762', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300354, 'RJ354', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-55', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9726, 9224);
INSERT INTO "ProdNac2021".cdg VALUES (3304533, 'RJ4533', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304390, 'RJ4390', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304942, 'RJ4942', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300468, 'RJ468', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 8988, 8020);
INSERT INTO "ProdNac2021".cdg VALUES (3304460, 'RJ4460', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304917, 'RJ4917', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300826, 'RJ826', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-46', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11629, 11524);
INSERT INTO "ProdNac2021".cdg VALUES (3300133, 'RJ133', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 E', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9880, 9844);
INSERT INTO "ProdNac2021".cdg VALUES (3304725, 'RJ4725', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304968, 'RJ4968', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301002, 'RJ1002', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '14', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11637, 11548);
INSERT INTO "ProdNac2021".cdg VALUES (3300692, 'RJ692', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-22', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11938, 11799);
INSERT INTO "ProdNac2021".cdg VALUES (3304494, 'RJ4494', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300120, 'RJ120', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2218-1', 'SPU-RJ - Geoinformação', '117.137-MP', '41.263/52', 'Analógico', 'Carta Cadastral', '12.Trecho_RuaPedroAlves', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9761, 9744);
INSERT INTO "ProdNac2021".cdg VALUES (3300242, 'RJ242', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-10', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11054, 10107);
INSERT INTO "ProdNac2021".cdg VALUES (3304625, 'RJ4625', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304781, 'RJ4781', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304971, 'RJ4971', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304634, 'RJ4634', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300968, 'RJ968', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '4C', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12130, 12042);
INSERT INTO "ProdNac2021".cdg VALUES (3304659, 'RJ4659', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301174, 'RJ1174', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1809-4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300195, 'RJ195', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-22', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11012, 9257);
INSERT INTO "ProdNac2021".cdg VALUES (3300366, 'RJ366', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-62A', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9934, 9262);
INSERT INTO "ProdNac2021".cdg VALUES (3300177, 'RJ177', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-04', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10741, 8489);
INSERT INTO "ProdNac2021".cdg VALUES (3300874, 'RJ874', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-91', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12823, 12460);
INSERT INTO "ProdNac2021".cdg VALUES (3300932, 'RJ932', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'Folha 1', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', NULL, NULL, 'Não', 'Não possui', 0, 500, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300445, 'RJ445', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-11', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8937, 7961);
INSERT INTO "ProdNac2021".cdg VALUES (3304502, 'RJ4502', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300411, 'RJ411', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-18', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8818, 7664);
INSERT INTO "ProdNac2021".cdg VALUES (3301022, 'RJ1022', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '34', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11675, 11595);
INSERT INTO "ProdNac2021".cdg VALUES (3300736, 'RJ736', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-3', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11277, 11237);
INSERT INTO "ProdNac2021".cdg VALUES (3304798, 'RJ4798', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300410, 'RJ410', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-17', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8817, 7665);
INSERT INTO "ProdNac2021".cdg VALUES (3304558, 'RJ4558', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300461, 'RJ461', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-26', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8965, 7990);
INSERT INTO "ProdNac2021".cdg VALUES (3304539, 'RJ4539', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300936, 'RJ936', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'Folha 5', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', NULL, NULL, 'Não', 'Não possui', 0, 500, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300625, 'RJ625', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-22', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8815, 8188);
INSERT INTO "ProdNac2021".cdg VALUES (3304445, 'RJ4445', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300595, 'RJ595', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-5', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9546, 9517);
INSERT INTO "ProdNac2021".cdg VALUES (3300391, 'RJ391', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-13', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8469, 7917);
INSERT INTO "ProdNac2021".cdg VALUES (3300456, 'RJ456', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-21', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8956, 7973);
INSERT INTO "ProdNac2021".cdg VALUES (3300609, 'RJ609', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-6', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8465, 7809);
INSERT INTO "ProdNac2021".cdg VALUES (3300980, 'RJ980', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '7F', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12146, 12056);
INSERT INTO "ProdNac2021".cdg VALUES (3304513, 'RJ4513', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304973, 'RJ4973', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301081, 'RJ1081', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '45', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304560, 'RJ4560', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300279, 'RJ279', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-12', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8307, 7750);
INSERT INTO "ProdNac2021".cdg VALUES (3304824, 'RJ4824', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304906, 'RJ4906', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300732, 'RJ732', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-62', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12115, 11905);
INSERT INTO "ProdNac2021".cdg VALUES (3304974, 'RJ4974', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304700, 'RJ4700', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300372, 'RJ372', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-68', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9966, 9282);
INSERT INTO "ProdNac2021".cdg VALUES (3304348, 'RJ4348', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300247, 'RJ247', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-15', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95-81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11059, 10120);
INSERT INTO "ProdNac2021".cdg VALUES (3300253, 'RJ253', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-E', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11144, 10214);
INSERT INTO "ProdNac2021".cdg VALUES (3300846, 'RJ846', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-64', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12777, 12362);
INSERT INTO "ProdNac2021".cdg VALUES (3300960, 'RJ960', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'Carta índice', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Índice', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 5000, 12085, 12018);
INSERT INTO "ProdNac2021".cdg VALUES (3301109, 'RJ1109', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-4', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11873, 11835);
INSERT INTO "ProdNac2021".cdg VALUES (3301164, 'RJ1164', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2222-6', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12598, 12267);
INSERT INTO "ProdNac2021".cdg VALUES (3300344, 'RJ344', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-45', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9707, 9177);
INSERT INTO "ProdNac2021".cdg VALUES (3301005, 'RJ1005', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '17', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11646, 11551);
INSERT INTO "ProdNac2021".cdg VALUES (3301140, 'RJ1140', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-13', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1964, NULL, 'Não', 'Não possui', 0, 1000, 12565, 11988);
INSERT INTO "ProdNac2021".cdg VALUES (3304451, 'RJ4451', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300616, 'RJ616', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-13', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8795, 8067);
INSERT INTO "ProdNac2021".cdg VALUES (3301054, 'RJ1054', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '18', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304707, 'RJ4707', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304844, 'RJ4844', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301058, 'RJ1058', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '22', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300550, 'RJ550', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-9', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10301, 10017);
INSERT INTO "ProdNac2021".cdg VALUES (3300145, 'RJ145', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 Q', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9892, 9867);
INSERT INTO "ProdNac2021".cdg VALUES (3301197, 'RJ1197', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1790-D', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 593/53 Novo:34.981-55', 'Analógico', 'Carta Cadastral', '57.Gaveta14.Atafona_SaoJoaoBarra_Trecho_GrucaiAtafona', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 5000, 11425, 11422);
INSERT INTO "ProdNac2021".cdg VALUES (3300345, 'RJ345', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-46', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9709, 9180);
INSERT INTO "ProdNac2021".cdg VALUES (3300462, 'RJ462', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-27', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8968, 7995);
INSERT INTO "ProdNac2021".cdg VALUES (3300137, 'RJ137', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 I', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9883, 9852);
INSERT INTO "ProdNac2021".cdg VALUES (3300726, 'RJ726', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-56', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12109, 11899);
INSERT INTO "ProdNac2021".cdg VALUES (3304628, 'RJ4628', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300525, 'RJ525', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 13', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8868, 8314);
INSERT INTO "ProdNac2021".cdg VALUES (3300246, 'RJ246', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-14', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11058, 10118);
INSERT INTO "ProdNac2021".cdg VALUES (3304388, 'RJ4388', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304749, 'RJ4749', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300544, 'RJ544', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-3', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10288, 10007);
INSERT INTO "ProdNac2021".cdg VALUES (3300731, 'RJ731', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-61', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12114, 11904);
INSERT INTO "ProdNac2021".cdg VALUES (3300015, 'RJ15', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 8', 'SPU-RJ - Geoinformação', '117.137-MP', '13.5305/47', 'Analógico', 'Carta Cadastral', '02.PlantaFaixadeMarinhas_PraiadeBotafogo', 'Terreno de Marinha', 1947, NULL, 'Não', 'Não possui', 0, 500, 8079, 8057);
INSERT INTO "ProdNac2021".cdg VALUES (3300930, 'RJ930', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-19', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12205, 12185);
INSERT INTO "ProdNac2021".cdg VALUES (3300904, 'RJ904', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1979-6', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 522/60 Novo:228.538-60', 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1959, NULL, 'Não', 'Não possui', 0, 500, 12323, 12316);
INSERT INTO "ProdNac2021".cdg VALUES (3300729, 'RJ729', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-59', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12112, 11902);
INSERT INTO "ProdNac2021".cdg VALUES (3300643, 'RJ643', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-40', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 9446, 8284);
INSERT INTO "ProdNac2021".cdg VALUES (3300252, 'RJ252', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-D', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11143, 10147);
INSERT INTO "ProdNac2021".cdg VALUES (3300983, 'RJ983', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '8G', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12156, 12073);
INSERT INTO "ProdNac2021".cdg VALUES (3304377, 'RJ4377', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304854, 'RJ4854', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300639, 'RJ639', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-36', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8870, 8250);
INSERT INTO "ProdNac2021".cdg VALUES (3304777, 'RJ4777', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300825, 'RJ825', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-45', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11630, 11523);
INSERT INTO "ProdNac2021".cdg VALUES (3304649, 'RJ4649', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304652, 'RJ4652', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304666, 'RJ4666', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300512, 'RJ512', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Índice', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 25000, 8847, 8243);
INSERT INTO "ProdNac2021".cdg VALUES (3301101, 'RJ1101', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-9', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11821, 11698);
INSERT INTO "ProdNac2021".cdg VALUES (3304709, 'RJ4709', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304706, 'RJ4706', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304342, 'RJ4342', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300386, 'RJ386', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-9', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8435, 7906);
INSERT INTO "ProdNac2021".cdg VALUES (3300188, 'RJ188', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-15', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10888, 9221);
INSERT INTO "ProdNac2021".cdg VALUES (3300710, 'RJ710', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-40', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11960, 11883);
INSERT INTO "ProdNac2021".cdg VALUES (3300938, 'RJ938', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Índice', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 10000, 11737, 11710);
INSERT INTO "ProdNac2021".cdg VALUES (3300559, 'RJ559', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-18', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10320, 10270);
INSERT INTO "ProdNac2021".cdg VALUES (3300755, 'RJ755', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-17', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11341, 11297);
INSERT INTO "ProdNac2021".cdg VALUES (3300808, 'RJ808', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-28', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11599, 11503);
INSERT INTO "ProdNac2021".cdg VALUES (3300862, 'RJ862', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-80', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12795, 12380);
INSERT INTO "ProdNac2021".cdg VALUES (3300241, 'RJ241', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-9', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11053, 10102);
INSERT INTO "ProdNac2021".cdg VALUES (3300248, 'RJ248', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Índice', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 5000, 11139, 10133);
INSERT INTO "ProdNac2021".cdg VALUES (3300200, 'RJ200', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-27', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11017, 9288);
INSERT INTO "ProdNac2021".cdg VALUES (3300483, 'RJ483', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 3', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9030, 8183);
INSERT INTO "ProdNac2021".cdg VALUES (3304461, 'RJ4461', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304631, 'RJ4631', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301210, 'RJ1210', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-11', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12021, 11985);
INSERT INTO "ProdNac2021".cdg VALUES (3300850, 'RJ850', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-68', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12780, 12367);
INSERT INTO "ProdNac2021".cdg VALUES (3300113, 'RJ113', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-M', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9699, 9672);
INSERT INTO "ProdNac2021".cdg VALUES (3300517, 'RJ517', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 5', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8857, 8269);
INSERT INTO "ProdNac2021".cdg VALUES (3301180, 'RJ1180', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2096-7', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301135, 'RJ1135', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-30', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12072, 11867);
INSERT INTO "ProdNac2021".cdg VALUES (3300764, 'RJ764', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-26', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11348, 11306);
INSERT INTO "ProdNac2021".cdg VALUES (3300813, 'RJ813', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-33', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11609, 11508);
INSERT INTO "ProdNac2021".cdg VALUES (3300805, 'RJ805', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-26', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11593, 11500);
INSERT INTO "ProdNac2021".cdg VALUES (3304472, 'RJ4472', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304893, 'RJ4893', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301190, 'RJ1190', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1803', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Índice', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 8000, 12642, 12302);
INSERT INTO "ProdNac2021".cdg VALUES (3304839, 'RJ4839', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300518, 'RJ518', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 6', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8858, 8270);
INSERT INTO "ProdNac2021".cdg VALUES (3300587, 'RJ587', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-9', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9813, 9799);
INSERT INTO "ProdNac2021".cdg VALUES (3300001, 'RJ01', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1759-A', 'SPU-RJ - Geoinformação', '117.137-MP', '89.554/54', 'Analógico', 'Carta Cadastral', '01.PlantaFaixadeMarinhaRuaSantoCristo', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 7815, 7758);
INSERT INTO "ProdNac2021".cdg VALUES (3304479, 'RJ4479', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301136, 'RJ1136', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-31', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12077, 11868);
INSERT INTO "ProdNac2021".cdg VALUES (3304404, 'RJ4404', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304569, 'RJ4569', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304605, 'RJ4605', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304374, 'RJ4374', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304794, 'RJ4794', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300673, 'RJ673', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-3', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11911, 11704);
INSERT INTO "ProdNac2021".cdg VALUES (3300817, 'RJ817', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-37', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11614, 11514);
INSERT INTO "ProdNac2021".cdg VALUES (3300775, 'RJ775', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-36', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 1000, 11409, 11386);
INSERT INTO "ProdNac2021".cdg VALUES (3300104, 'RJ104', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-D', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9684, 9631);
INSERT INTO "ProdNac2021".cdg VALUES (3301125, 'RJ1125', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-20', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12050, 11855);
INSERT INTO "ProdNac2021".cdg VALUES (3304594, 'RJ4594', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300226, 'RJ226', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-8', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11039, 9532);
INSERT INTO "ProdNac2021".cdg VALUES (3300698, 'RJ698', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-28', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11944, 11805);
INSERT INTO "ProdNac2021".cdg VALUES (3300538, 'RJ538', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2759-2', 'SPU-RJ - Geoinformação', '117.137-MP', '113.824/57', 'Analógico', 'Carta Cadastral', '36.Trecho_PraiaPontalSernambetiba-MorroCaete', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 10491, 10481);
INSERT INTO "ProdNac2021".cdg VALUES (3304799, 'RJ4799', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304525, 'RJ4525', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300349, 'RJ349', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-50', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9715, 9200);
INSERT INTO "ProdNac2021".cdg VALUES (3304535, 'RJ4535', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300129, 'RJ129', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 A', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9873, 9837);
INSERT INTO "ProdNac2021".cdg VALUES (3300724, 'RJ724', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-54', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12103, 11897);
INSERT INTO "ProdNac2021".cdg VALUES (3300202, 'RJ202', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-29', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11019, 9305);
INSERT INTO "ProdNac2021".cdg VALUES (3304913, 'RJ4913', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300557, 'RJ557', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-16', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10318, 10268);
INSERT INTO "ProdNac2021".cdg VALUES (3301106, 'RJ1106', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-1', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11870, 11831);
INSERT INTO "ProdNac2021".cdg VALUES (3300452, 'RJ452', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-17', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8949, 7969);
INSERT INTO "ProdNac2021".cdg VALUES (3301007, 'RJ1007', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '19', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11649, 11553);
INSERT INTO "ProdNac2021".cdg VALUES (3300488, 'RJ488', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 8', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9043, 8194);
INSERT INTO "ProdNac2021".cdg VALUES (3300540, 'RJ540', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2759-4', 'SPU-RJ - Geoinformação', '117.137-MP', '113.824/57', 'Analógico', 'Carta Cadastral', '36.Trecho_PraiaPontalSernambetiba-MorroCaete', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 10493, 10483);
INSERT INTO "ProdNac2021".cdg VALUES (3300126, 'RJ126', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2260-C', 'SPU-RJ - Geoinformação', '117.137-MP', '10.404/51', 'Analógico', 'Carta Cadastral', '13.Trecho_PraiaFlamengo', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 1000, 9782, 9777);
INSERT INTO "ProdNac2021".cdg VALUES (3304959, 'RJ4959', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300465, 'RJ465', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-30', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8971, 7999);
INSERT INTO "ProdNac2021".cdg VALUES (3300493, 'RJ493', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 13', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9056, 8226);
INSERT INTO "ProdNac2021".cdg VALUES (3300234, 'RJ234', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-2', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11046, 10058);
INSERT INTO "ProdNac2021".cdg VALUES (3300885, 'RJ885', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-102', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12836, 12474);
INSERT INTO "ProdNac2021".cdg VALUES (3304960, 'RJ4960', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304985, 'RJ4985', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304883, 'RJ4883', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300633, 'RJ633', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-30', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8849, 8231);
INSERT INTO "ProdNac2021".cdg VALUES (3301086, 'RJ1086', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '50', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304492, 'RJ4492', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304862, 'RJ4862', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301156, 'RJ1156', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2208-4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12579, 12229);
INSERT INTO "ProdNac2021".cdg VALUES (3300615, 'RJ615', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-12', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8794, 8064);
INSERT INTO "ProdNac2021".cdg VALUES (3300181, 'RJ181', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-08', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10862, 9109);
INSERT INTO "ProdNac2021".cdg VALUES (3300746, 'RJ746', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-10A', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11287, 11271);
INSERT INTO "ProdNac2021".cdg VALUES (3300806, 'RJ806', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046 B', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Índice', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 10000, 11544, 11428);
INSERT INTO "ProdNac2021".cdg VALUES (3300346, 'RJ346', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-47', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9710, 9187);
INSERT INTO "ProdNac2021".cdg VALUES (3300330, 'RJ330', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-31', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9655, 8730);
INSERT INTO "ProdNac2021".cdg VALUES (3300425, 'RJ425', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-32', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8834, 7698);
INSERT INTO "ProdNac2021".cdg VALUES (3301209, 'RJ1209', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-10', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12020, 11984);
INSERT INTO "ProdNac2021".cdg VALUES (3301112, 'RJ1112', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-7', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12010, 11838);
INSERT INTO "ProdNac2021".cdg VALUES (3301183, 'RJ1183', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1803-4', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 15458, 12305);
INSERT INTO "ProdNac2021".cdg VALUES (3304589, 'RJ4589', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300553, 'RJ553', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-12', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10307, 10025);
INSERT INTO "ProdNac2021".cdg VALUES (3300033, 'RJ33', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-5', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8700, 8517);
INSERT INTO "ProdNac2021".cdg VALUES (3304667, 'RJ4667', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304852, 'RJ4852', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304981, 'RJ4981', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304779, 'RJ4779', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304984, 'RJ4984', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304614, 'RJ4614', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304504, 'RJ4504', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304869, 'RJ4869', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304820, 'RJ4820', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300528, 'RJ528', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2753 - 1', 'SPU-RJ - Geoinformação', '117.137-MP', '237.984/54', 'Analógico', 'Carta Cadastral', '35.Trecho_PraiaSaoCristovaoAvenidaFranciscoBicalho', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10438, 10423);
INSERT INTO "ProdNac2021".cdg VALUES (3300962, 'RJ962', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3B', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12090, 12038);
INSERT INTO "ProdNac2021".cdg VALUES (3300797, 'RJ797', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-18', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11582, 11462);
INSERT INTO "ProdNac2021".cdg VALUES (3300791, 'RJ791', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-12', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11570, 11455);
INSERT INTO "ProdNac2021".cdg VALUES (3300605, 'RJ605', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-2', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8317, 7789);
INSERT INTO "ProdNac2021".cdg VALUES (3300947, 'RJ947', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-9', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11746, 11730);
INSERT INTO "ProdNac2021".cdg VALUES (3301032, 'RJ1032', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12001, 11982);
INSERT INTO "ProdNac2021".cdg VALUES (3304544, 'RJ4544', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300880, 'RJ880', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-97', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12829, 12468);
INSERT INTO "ProdNac2021".cdg VALUES (3300774, 'RJ774', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-35', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 1000, 11408, 11385);
INSERT INTO "ProdNac2021".cdg VALUES (3300969, 'RJ969', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '5C', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12133, 12045);
INSERT INTO "ProdNac2021".cdg VALUES (3304471, 'RJ4471', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304546, 'RJ4546', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300029, 'RJ29', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-1', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8692, 8507);
INSERT INTO "ProdNac2021".cdg VALUES (3301003, 'RJ1003', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '15', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11638, 11549);
INSERT INTO "ProdNac2021".cdg VALUES (3300758, 'RJ758', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-20', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11338, 11300);
INSERT INTO "ProdNac2021".cdg VALUES (3300170, 'RJ170', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 H', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Cadastral', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 10721, 8395);
INSERT INTO "ProdNac2021".cdg VALUES (3304690, 'RJ4690', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301202, 'RJ1202', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-3', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12009, 11958);
INSERT INTO "ProdNac2021".cdg VALUES (3304805, 'RJ4805', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300522, 'RJ522', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 10', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8864, 8295);
INSERT INTO "ProdNac2021".cdg VALUES (3300401, 'RJ401', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-8', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8800, 7647);
INSERT INTO "ProdNac2021".cdg VALUES (3300433, 'RJ433', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-40', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8842, 7708);
INSERT INTO "ProdNac2021".cdg VALUES (3304829, 'RJ4829', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304929, 'RJ4929', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301144, 'RJ1144', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-5', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12504, 11689);
INSERT INTO "ProdNac2021".cdg VALUES (3300934, 'RJ934', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'Folha 3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', NULL, NULL, 'Não', 'Não possui', 0, 500, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301013, 'RJ1013', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '25', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11662, 11573);
INSERT INTO "ProdNac2021".cdg VALUES (3304568, 'RJ4568', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301069, 'RJ1069', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '33', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300238, 'RJ238', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-6', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11050, 10093);
INSERT INTO "ProdNac2021".cdg VALUES (3304550, 'RJ4550', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304662, 'RJ4662', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300689, 'RJ689', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-19', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11935, 11796);
INSERT INTO "ProdNac2021".cdg VALUES (3300047, 'RJ47', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-19', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8725, 8685);
INSERT INTO "ProdNac2021".cdg VALUES (3300370, 'RJ370', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-66', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9955, 9274);
INSERT INTO "ProdNac2021".cdg VALUES (3301154, 'RJ1154', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2208-2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12575, 12226);
INSERT INTO "ProdNac2021".cdg VALUES (3304940, 'RJ4940', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300558, 'RJ558', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-17', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10319, 10269);
INSERT INTO "ProdNac2021".cdg VALUES (3301193, 'RJ1193', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1803-6', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 2000, 12648, 12312);
INSERT INTO "ProdNac2021".cdg VALUES (3300722, 'RJ722', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-52', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12105, 11895);
INSERT INTO "ProdNac2021".cdg VALUES (3301211, 'RJ1211', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-12', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12022, 11986);
INSERT INTO "ProdNac2021".cdg VALUES (3304896, 'RJ4896', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300730, 'RJ730', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-60', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12113, 11903);
INSERT INTO "ProdNac2021".cdg VALUES (3300672, 'RJ672', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-2', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11910, 11703);
INSERT INTO "ProdNac2021".cdg VALUES (3304457, 'RJ4457', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300952, 'RJ952', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-14', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11774, 11735);
INSERT INTO "ProdNac2021".cdg VALUES (3304858, 'RJ4858', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300578, 'RJ578', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Índice', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 20000, 9802, 9565);
INSERT INTO "ProdNac2021".cdg VALUES (3300539, 'RJ539', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2759-3', 'SPU-RJ - Geoinformação', '117.137-MP', '113.824/57', 'Analógico', 'Carta Cadastral', '36.Trecho_PraiaPontalSernambetiba-MorroCaete', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 10492, 10482);
INSERT INTO "ProdNac2021".cdg VALUES (3304923, 'RJ4923', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300149, 'RJ149', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 U', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9895, 9871);
INSERT INTO "ProdNac2021".cdg VALUES (3300679, 'RJ679', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-9', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11917, 11712);
INSERT INTO "ProdNac2021".cdg VALUES (3300744, 'RJ744', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-9A', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11285, 11269);
INSERT INTO "ProdNac2021".cdg VALUES (3300823, 'RJ823', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-43', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11626, 11520);
INSERT INTO "ProdNac2021".cdg VALUES (3304398, 'RJ4398', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300003, 'RJ03', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1759-C', 'SPU-RJ - Geoinformação', '117.137-MP', '89.554/54', 'Analógico', 'Carta Cadastral', '01.PlantaFaixadeMarinhaRuaSantoCristo', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 7818, 7799);
INSERT INTO "ProdNac2021".cdg VALUES (3300373, 'RJ373', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-69', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9969, 9286);
INSERT INTO "ProdNac2021".cdg VALUES (3301071, 'RJ1071', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '35', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301057, 'RJ1057', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '21', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300532, 'RJ532', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2753 - 5', 'SPU-RJ - Geoinformação', '117.137-MP', '237.984/54', 'Analógico', 'Carta Cadastral', '35.Trecho_PraiaSaoCristovaoAvenidaFranciscoBicalho', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10442, 10432);
INSERT INTO "ProdNac2021".cdg VALUES (3301015, 'RJ1015', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '27', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11665, 11571);
INSERT INTO "ProdNac2021".cdg VALUES (3304780, 'RJ4780', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304821, 'RJ4821', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300408, 'RJ408', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-15', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8813, 7660);
INSERT INTO "ProdNac2021".cdg VALUES (3300955, 'RJ955', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1972-2', 'SPU-RJ - Geoinformação', '062.987-MP', '8077/37', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1960, NULL, 'Não', 'Não possui', 0, 500, 11399, 11392);
INSERT INTO "ProdNac2021".cdg VALUES (3300480, 'RJ480', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - INDICE', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Índice', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 20000, 9014, 8176);
INSERT INTO "ProdNac2021".cdg VALUES (3304899, 'RJ4899', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304428, 'RJ4428', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300870, 'RJ870', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-87', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12819, 12456);
INSERT INTO "ProdNac2021".cdg VALUES (3300785, 'RJ785', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-6', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11561, 11442);
INSERT INTO "ProdNac2021".cdg VALUES (3300899, 'RJ899', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1979-1', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 522/60 Novo:228.538-60', 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1959, NULL, 'Não', 'Não possui', 0, 500, 12318, 12311);
INSERT INTO "ProdNac2021".cdg VALUES (3300571, 'RJ571', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2770-1', 'SPU-RJ - Geoinformação', '117.137-MP', '23.8551/57', 'Analógico', 'Carta Cadastral', '39.Trecho_PraçaAlbertoTorres-RioPavuna', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9835, 9820);
INSERT INTO "ProdNac2021".cdg VALUES (3304442, 'RJ4442', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304462, 'RJ4462', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300394, 'RJ394', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-1', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8790, 7620);
INSERT INTO "ProdNac2021".cdg VALUES (3300028, 'RJ28', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8702, 8497);
INSERT INTO "ProdNac2021".cdg VALUES (3300162, 'RJ162', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 INDICE', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Índice', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 10000, 10699, 8331);
INSERT INTO "ProdNac2021".cdg VALUES (3304329, 'RJ4329', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304549, 'RJ4549', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304783, 'RJ4783', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301102, 'RJ1102', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-10', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11824, 11788);
INSERT INTO "ProdNac2021".cdg VALUES (3304384, 'RJ4384', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304826, 'RJ4826', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304699, 'RJ4699', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304701, 'RJ4701', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300387, 'RJ387', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-10', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8440, 7909);
INSERT INTO "ProdNac2021".cdg VALUES (3300303, 'RJ303', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-6', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9337, 8648);
INSERT INTO "ProdNac2021".cdg VALUES (3301222, 'RJ1222', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1285-5', 'SPU-RJ - Geoinformação', '062.987-MP', '051/42', 'Analógico', 'Carta Cadastral', '59.Gaveta17.Jacone_LagoaAraruama_TrechoJacone-PontaNegra', 'Terreno de Marinha', 1977, NULL, 'Não', 'Não possui', 0, 2500, 11464, 11660);
INSERT INTO "ProdNac2021".cdg VALUES (3300669, 'RJ669', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1896-8', 'SPU-RJ - Geoinformação', '062.987-MP', '1423/54', 'Analógico', 'Carta Cadastral', '45.Gaveta1.BarraSaoJoao-CaimiroAbreu_Trecho_CidadeSaoJoao-CasimiroAbreu', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11204, 11194);
INSERT INTO "ProdNac2021".cdg VALUES (3304989, 'RJ4989', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304522, 'RJ4522', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304867, 'RJ4867', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300061, 'RJ61', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-12', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8773, 8757);
INSERT INTO "ProdNac2021".cdg VALUES (3304584, 'RJ4584', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304473, 'RJ4473', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304640, 'RJ4640', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300473, 'RJ473', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 5', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 8999, 8025);
INSERT INTO "ProdNac2021".cdg VALUES (3300043, 'RJ43', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-15', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8718, 8676);
INSERT INTO "ProdNac2021".cdg VALUES (3301079, 'RJ1079', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '43', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304575, 'RJ4575', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301068, 'RJ1068', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '32', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300499, 'RJ499', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2720-2', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 10407, 10398);
INSERT INTO "ProdNac2021".cdg VALUES (3300020, 'RJ20', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 280.255/48 Novo:10768.015327/92-12', 'Analógico', 'Carta Cadastral', '03.PlantaLinhadeMarinha_AvenidaPasteurCompostacomElementosColigidosno', 'Terreno de Marinha', 1948, NULL, 'Não', 'Não possui', 0, 500, 8411, 8391);
INSERT INTO "ProdNac2021".cdg VALUES (3300305, 'RJ305', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-8', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9345, 8654);
INSERT INTO "ProdNac2021".cdg VALUES (3301142, 'RJ1142', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12500, 11681);
INSERT INTO "ProdNac2021".cdg VALUES (3304429, 'RJ4429', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304886, 'RJ4886', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300901, 'RJ901', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1979-3', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 522/60 Novo:228.538-60', 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1959, NULL, 'Não', 'Não possui', 0, 500, 12320, 12309);
INSERT INTO "ProdNac2021".cdg VALUES (3304495, 'RJ4495', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300733, 'RJ733', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-40', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11413, 11390);
INSERT INTO "ProdNac2021".cdg VALUES (3301176, 'RJ1176', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2096-2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300816, 'RJ816', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-36', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11613, 11513);
INSERT INTO "ProdNac2021".cdg VALUES (3304555, 'RJ4555', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304818, 'RJ4818', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300995, 'RJ995', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '7', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11624, 11537);
INSERT INTO "ProdNac2021".cdg VALUES (3300756, 'RJ756', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-18', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11337, 11298);
INSERT INTO "ProdNac2021".cdg VALUES (3300384, 'RJ384', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-7', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8426, 7901);
INSERT INTO "ProdNac2021".cdg VALUES (3304800, 'RJ4800', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304411, 'RJ4411', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300891, 'RJ891', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-4', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11925, 11761);
INSERT INTO "ProdNac2021".cdg VALUES (3300786, 'RJ786', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-7', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11565, 11443);
INSERT INTO "ProdNac2021".cdg VALUES (3304548, 'RJ4548', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304695, 'RJ4695', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304331, 'RJ4331', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304874, 'RJ4874', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300323, 'RJ323', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-24', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9633, 8717);
INSERT INTO "ProdNac2021".cdg VALUES (3304947, 'RJ4947', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304518, 'RJ4518', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300453, 'RJ453', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-18', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8950, 7970);
INSERT INTO "ProdNac2021".cdg VALUES (3300377, 'RJ377', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Índice', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 10000, 8393, 7881);
INSERT INTO "ProdNac2021".cdg VALUES (3301090, 'RJ1090', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '54', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300859, 'RJ859', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-77', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12791, 12376);
INSERT INTO "ProdNac2021".cdg VALUES (3304727, 'RJ4727', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301196, 'RJ1196', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1790-C', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 593/53 Novo:34.981-55', 'Analógico', 'Carta Cadastral', '57.Gaveta14.Atafona_SaoJoaoBarra_Trecho_GrucaiAtafona', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 5000, 11424, 11421);
INSERT INTO "ProdNac2021".cdg VALUES (3304611, 'RJ4611', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304743, 'RJ4743', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304895, 'RJ4895', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300277, 'RJ277', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-10', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8298, 7734);
INSERT INTO "ProdNac2021".cdg VALUES (3300197, 'RJ197', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-24', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11014, 9264);
INSERT INTO "ProdNac2021".cdg VALUES (3301048, 'RJ1048', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '12', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300318, 'RJ318', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-19', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9617, 8701);
INSERT INTO "ProdNac2021".cdg VALUES (3300921, 'RJ921', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-10', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12196, 12176);
INSERT INTO "ProdNac2021".cdg VALUES (3300621, 'RJ621', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-18', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8807, 8080);
INSERT INTO "ProdNac2021".cdg VALUES (3300759, 'RJ759', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-21', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11343, 11301);
INSERT INTO "ProdNac2021".cdg VALUES (3301075, 'RJ1075', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '39', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300842, 'RJ842', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-60', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12769, 12355);
INSERT INTO "ProdNac2021".cdg VALUES (3301205, 'RJ1205', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-6', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12014, 11975);
INSERT INTO "ProdNac2021".cdg VALUES (3304927, 'RJ4927', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300860, 'RJ860', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-78', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12793, 12378);
INSERT INTO "ProdNac2021".cdg VALUES (3300687, 'RJ687', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-17', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11933, 11794);
INSERT INTO "ProdNac2021".cdg VALUES (3301160, 'RJ1160', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2222-2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12588, 12258);
INSERT INTO "ProdNac2021".cdg VALUES (3300959, 'RJ959', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1972-7', 'SPU-RJ - Geoinformação', '062.987-MP', '8077/37', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1960, NULL, 'Não', 'Não possui', 0, 500, 11403, 11396);
INSERT INTO "ProdNac2021".cdg VALUES (3304669, 'RJ4669', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300178, 'RJ178', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-05', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10745, 9102);
INSERT INTO "ProdNac2021".cdg VALUES (3300343, 'RJ343', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-44', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9705, 9172);
INSERT INTO "ProdNac2021".cdg VALUES (3304851, 'RJ4851', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300876, 'RJ876', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-93', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12825, 12462);
INSERT INTO "ProdNac2021".cdg VALUES (3304362, 'RJ4362', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304763, 'RJ4763', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304705, 'RJ4705', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300309, 'RJ309', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-11', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9595, 8668);
INSERT INTO "ProdNac2021".cdg VALUES (3300430, 'RJ430', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-37', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8839, 7704);
INSERT INTO "ProdNac2021".cdg VALUES (3300182, 'RJ182', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-09', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10867, 9142);
INSERT INTO "ProdNac2021".cdg VALUES (3300355, 'RJ355', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-56', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9730, 9227);
INSERT INTO "ProdNac2021".cdg VALUES (3300159, 'RJ159', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1304-1', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 217.118/52 Novo:10768.015325/92-89', 'Analógico', 'Carta Cadastral', '16.Trecho_RuaGamboa', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 1000, 10683, 8223);
INSERT INTO "ProdNac2021".cdg VALUES (3304355, 'RJ4355', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300583, 'RJ583', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-5', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9808, 9572);
INSERT INTO "ProdNac2021".cdg VALUES (3304636, 'RJ4636', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304806, 'RJ4806', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300640, 'RJ640', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-37', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 9430, 8255);
INSERT INTO "ProdNac2021".cdg VALUES (3304537, 'RJ4537', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301021, 'RJ1021', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '33', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11674, 11585);
INSERT INTO "ProdNac2021".cdg VALUES (3300412, 'RJ412', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-19', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8819, 7670);
INSERT INTO "ProdNac2021".cdg VALUES (3304622, 'RJ4622', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301191, 'RJ1191', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1803-1', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 2000, 12644, 12303);
INSERT INTO "ProdNac2021".cdg VALUES (3300297, 'RJ297', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Índice', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 10000, 9306, 8634);
INSERT INTO "ProdNac2021".cdg VALUES (3300508, 'RJ508', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3973-3', 'SPU-RJ - Geoinformação', '117.137-MP', '09481/80', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1980, NULL, 'Não', 'Não possui', 0, 2000, 10641, 10570);
INSERT INTO "ProdNac2021".cdg VALUES (3300326, 'RJ326', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-27', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9642, 8724);
INSERT INTO "ProdNac2021".cdg VALUES (3304532, 'RJ4532', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301047, 'RJ1047', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '11', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300514, 'RJ514', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 2', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8852, 8258);
INSERT INTO "ProdNac2021".cdg VALUES (3304454, 'RJ4454', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300840, 'RJ840', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-58', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12763, 12345);
INSERT INTO "ProdNac2021".cdg VALUES (3300257, 'RJ257', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-I', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11149, 10230);
INSERT INTO "ProdNac2021".cdg VALUES (3304637, 'RJ4637', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300110, 'RJ110', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-J', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9692, 9664);
INSERT INTO "ProdNac2021".cdg VALUES (3304344, 'RJ4344', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301137, 'RJ1137', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1421', 'SPU-RJ - Geoinformação', '062.987-MP', '404-947', 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1949, NULL, 'Não', 'Não possui', 0, 2500, 12633, 12330);
INSERT INTO "ProdNac2021".cdg VALUES (3304807, 'RJ4807', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304644, 'RJ4644', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301078, 'RJ1078', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '42', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301185, 'RJ1185', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1803-7', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 15456, 12313);
INSERT INTO "ProdNac2021".cdg VALUES (3300620, 'RJ620', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-17', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8806, 8078);
INSERT INTO "ProdNac2021".cdg VALUES (3304710, 'RJ4710', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300063, 'RJ63', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1983-A', 'SPU-RJ - Geoinformação', '117.137-MP', '19.450/50', 'Analógico', 'Carta Cadastral', '06.LinhaPreamarMedio1831_EntreRuaJoaoPizarroeAvenidaTexeiradeCastro', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8782, 8777);
INSERT INTO "ProdNac2021".cdg VALUES (3300777, 'RJ777', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-38', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 1000, 11411, 11388);
INSERT INTO "ProdNac2021".cdg VALUES (3301077, 'RJ1077', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '41', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300881, 'RJ881', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-98', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12830, 12470);
INSERT INTO "ProdNac2021".cdg VALUES (3304519, 'RJ4519', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300709, 'RJ709', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-39', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11966, 11882);
INSERT INTO "ProdNac2021".cdg VALUES (3300718, 'RJ718', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-48', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11977, 11891);
INSERT INTO "ProdNac2021".cdg VALUES (3304586, 'RJ4586', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301141, 'RJ1141', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-1', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12499, 11676);
INSERT INTO "ProdNac2021".cdg VALUES (3300975, 'RJ975', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '7D', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12141, 12052);
INSERT INTO "ProdNac2021".cdg VALUES (3301194, 'RJ1194', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1803-9', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 2000, 12653, 12324);
INSERT INTO "ProdNac2021".cdg VALUES (3300799, 'RJ799', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-20', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11587, 11494);
INSERT INTO "ProdNac2021".cdg VALUES (3300477, 'RJ477', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2655 - 9', 'SPU-RJ - Geoinformação', '117.137-MP', '289.199/55', 'Analógico', 'Carta Cadastral', '31.Trecho_LargoBenfica-PraiaSaoCristovao', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 500, 9006, 8173);
INSERT INTO "ProdNac2021".cdg VALUES (3300444, 'RJ444', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-10', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Cadastral', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, 8936, 7960);
INSERT INTO "ProdNac2021".cdg VALUES (3304782, 'RJ4782', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300214, 'RJ214', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1541 B', 'SPU-RJ - Geoinformação', '117.137-MP', '176.785/45', 'Analógico', 'Carta Cadastral', '19.Trecho_SepetibaFazendaNacionalSantaCruz', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 9983, 9928);
INSERT INTO "ProdNac2021".cdg VALUES (3304795, 'RJ4795', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304812, 'RJ4812', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300933, 'RJ933', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'Folha 2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', NULL, NULL, 'Não', 'Não possui', 0, 500, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300507, 'RJ507', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3973-2', 'SPU-RJ - Geoinformação', '117.137-MP', '09481/80', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1980, NULL, 'Não', 'Não possui', 0, 2000, 10640, 10569);
INSERT INTO "ProdNac2021".cdg VALUES (3304871, 'RJ4871', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300141, 'RJ141', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 M', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9888, 9860);
INSERT INTO "ProdNac2021".cdg VALUES (3300498, 'RJ498', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2720-1', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 10406, 10397);
INSERT INTO "ProdNac2021".cdg VALUES (3300757, 'RJ757', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-19', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11342, 11299);
INSERT INTO "ProdNac2021".cdg VALUES (3300985, 'RJ985', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '8H', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12157, 12074);
INSERT INTO "ProdNac2021".cdg VALUES (3304530, 'RJ4530', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300080, 'RJ80', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1181 A', 'SPU-RJ - Geoinformação', '117.137-MP', '62.079/51', 'Analógico', 'Carta Cadastral', '10.LinhaPreamarMedio1831_IlhasBaiacu-Cabras-Jurubaiba', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9021, 8974);
INSERT INTO "ProdNac2021".cdg VALUES (3301010, 'RJ1010', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '22', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11654, 11562);
INSERT INTO "ProdNac2021".cdg VALUES (3301036, 'RJ1036', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '5', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12006, 11995);
INSERT INTO "ProdNac2021".cdg VALUES (3304903, 'RJ4903', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304880, 'RJ4880', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300335, 'RJ335', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-36', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9688, 9127);
INSERT INTO "ProdNac2021".cdg VALUES (3300871, 'RJ871', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-88', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12820, 12457);
INSERT INTO "ProdNac2021".cdg VALUES (3300316, 'RJ316', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-17', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9613, 8696);
INSERT INTO "ProdNac2021".cdg VALUES (3304618, 'RJ4618', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304656, 'RJ4656', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301208, 'RJ1208', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-9', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12019, 11981);
INSERT INTO "ProdNac2021".cdg VALUES (3304365, 'RJ4365', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300031, 'RJ31', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-3', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8695, 8510);
INSERT INTO "ProdNac2021".cdg VALUES (3300449, 'RJ449', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616-', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Índice', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 10000, 8911, 7915);
INSERT INTO "ProdNac2021".cdg VALUES (3300304, 'RJ304', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-7', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9341, 8652);
INSERT INTO "ProdNac2021".cdg VALUES (3304946, 'RJ4946', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300966, 'RJ966', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2C', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12088, 12026);
INSERT INTO "ProdNac2021".cdg VALUES (3301017, 'RJ1017', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '29', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11669, 11578);
INSERT INTO "ProdNac2021".cdg VALUES (3300923, 'RJ923', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-12', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12198, 12178);
INSERT INTO "ProdNac2021".cdg VALUES (3300659, 'RJ659', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-S', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 1000, 11135, 11131);
INSERT INTO "ProdNac2021".cdg VALUES (3300911, 'RJ911', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Índice', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 5000, 12186, 12166);
INSERT INTO "ProdNac2021".cdg VALUES (3304937, 'RJ4937', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304950, 'RJ4950', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300999, 'RJ999', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '11', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11634, 11543);
INSERT INTO "ProdNac2021".cdg VALUES (3300723, 'RJ723', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-53', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12104, 11896);
INSERT INTO "ProdNac2021".cdg VALUES (3304774, 'RJ4774', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301188, 'RJ1188', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1810-1', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 12751, 12326);
INSERT INTO "ProdNac2021".cdg VALUES (3304658, 'RJ4658', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300949, 'RJ949', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-11', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11769, 11733);
INSERT INTO "ProdNac2021".cdg VALUES (3304574, 'RJ4574', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301115, 'RJ1115', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-10', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12024, 11841);
INSERT INTO "ProdNac2021".cdg VALUES (3304919, 'RJ4919', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300420, 'RJ420', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-27', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8829, 7686);
INSERT INTO "ProdNac2021".cdg VALUES (3300998, 'RJ998', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '10', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11633, 11542);
INSERT INTO "ProdNac2021".cdg VALUES (3304832, 'RJ4832', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304980, 'RJ4980', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300423, 'RJ423', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-30', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8832, 7690);
INSERT INTO "ProdNac2021".cdg VALUES (3300804, 'RJ804', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-25', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11592, 11499);
INSERT INTO "ProdNac2021".cdg VALUES (3301226, 'RJ1226', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1903-2', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 645/55 Novo:245.239-60', 'Analógico', 'Carta Cadastral', '61.Gaveta19.Itacurussa_Trecho_OrlaMarinha', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11448, 11438);
INSERT INTO "ProdNac2021".cdg VALUES (3304396, 'RJ4396', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300405, 'RJ405', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-12', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8805, 7654);
INSERT INTO "ProdNac2021".cdg VALUES (3300681, 'RJ681', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-11', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11919, 11714);
INSERT INTO "ProdNac2021".cdg VALUES (3300770, 'RJ770', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-31', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 1000, 11404, 11381);
INSERT INTO "ProdNac2021".cdg VALUES (3300529, 'RJ529', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2753 - 2', 'SPU-RJ - Geoinformação', '117.137-MP', '237.984/54', 'Analógico', 'Carta Cadastral', '35.Trecho_PraiaSaoCristovaoAvenidaFranciscoBicalho', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10439, 10426);
INSERT INTO "ProdNac2021".cdg VALUES (3300184, 'RJ184', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-11', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10876, 9185);
INSERT INTO "ProdNac2021".cdg VALUES (3304587, 'RJ4587', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300590, 'RJ590', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3054 Articulação', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Índice', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 30000, 9531, 9497);
INSERT INTO "ProdNac2021".cdg VALUES (3300591, 'RJ591', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-1', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9534, 9504);
INSERT INTO "ProdNac2021".cdg VALUES (3301095, 'RJ1095', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-3', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11793, 11690);
INSERT INTO "ProdNac2021".cdg VALUES (3300295, 'RJ295', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2447 C', 'SPU-RJ - Geoinformação', '117.137-MP', '264.905/52', 'Analógico', 'Carta Cadastral', '26.Trecho_LadeiraRussel-PalacioMonroe', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 1000, 11165, 10658);
INSERT INTO "ProdNac2021".cdg VALUES (3300179, 'RJ179', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-06', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10750, 9103);
INSERT INTO "ProdNac2021".cdg VALUES (3300981, 'RJ981', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '8F', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12154, 12066);
INSERT INTO "ProdNac2021".cdg VALUES (3304872, 'RJ4872', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304932, 'RJ4932', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300897, 'RJ897', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-10', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11932, 11767);
INSERT INTO "ProdNac2021".cdg VALUES (3304383, 'RJ4383', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300852, 'RJ852', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-70', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12783, 12369);
INSERT INTO "ProdNac2021".cdg VALUES (3301157, 'RJ1157', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2208-5', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12581, 12230);
INSERT INTO "ProdNac2021".cdg VALUES (3304855, 'RJ4855', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300312, 'RJ312', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-14', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9602, 8679);
INSERT INTO "ProdNac2021".cdg VALUES (3300051, 'RJ51', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-2', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8761, 8742);
INSERT INTO "ProdNac2021".cdg VALUES (3300561, 'RJ561', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2803 INDICE', 'SPU-RJ - Geoinformação', '117.137-MP', '307.820/57', 'Analógico', 'Carta Índice', '38.Trecho_EstradaJacarepagua-ArroioFundo', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 10000, 9950, 9930);
INSERT INTO "ProdNac2021".cdg VALUES (3304613, 'RJ4613', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304517, 'RJ4517', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304934, 'RJ4934', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300491, 'RJ491', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 11', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9051, 8208);
INSERT INTO "ProdNac2021".cdg VALUES (3304330, 'RJ4330', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304395, 'RJ4395', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300877, 'RJ877', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-94', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12826, 12463);
INSERT INTO "ProdNac2021".cdg VALUES (3300213, 'RJ213', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-40', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11030, 9375);
INSERT INTO "ProdNac2021".cdg VALUES (3304334, 'RJ4334', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300221, 'RJ221', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-3', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11034, 9505);
INSERT INTO "ProdNac2021".cdg VALUES (3304688, 'RJ4688', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304967, 'RJ4967', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300964, 'RJ964', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '5B', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12130, 12044);
INSERT INTO "ProdNac2021".cdg VALUES (3304626, 'RJ4626', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301025, 'RJ1025', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '37', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11679, 11600);
INSERT INTO "ProdNac2021".cdg VALUES (3304403, 'RJ4403', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300834, 'RJ834', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-54', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11755, 11539);
INSERT INTO "ProdNac2021".cdg VALUES (3304931, 'RJ4931', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300016, 'RJ16', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 9', 'SPU-RJ - Geoinformação', '117.137-MP', '13.5305/47', 'Analógico', 'Carta Cadastral', '02.PlantaFaixadeMarinhas_PraiadeBotafogo', 'Terreno de Marinha', 1947, NULL, 'Não', 'Não possui', 0, 500, 8083, 8059);
INSERT INTO "ProdNac2021".cdg VALUES (3300496, 'RJ496', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 16', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9059, 8229);
INSERT INTO "ProdNac2021".cdg VALUES (3300038, 'RJ38', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-10', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8710, 8556);
INSERT INTO "ProdNac2021".cdg VALUES (3300555, 'RJ555', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-14', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10311, 10250);
INSERT INTO "ProdNac2021".cdg VALUES (3304361, 'RJ4361', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304501, 'RJ4501', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300361, 'RJ361', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-60B', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9752, 9243);
INSERT INTO "ProdNac2021".cdg VALUES (3304553, 'RJ4553', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304772, 'RJ4772', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300864, 'RJ864', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-82', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12797, 12382);
INSERT INTO "ProdNac2021".cdg VALUES (3300531, 'RJ531', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2753 - 4', 'SPU-RJ - Geoinformação', '117.137-MP', '237.984/54', 'Analógico', 'Carta Cadastral', '35.Trecho_PraiaSaoCristovaoAvenidaFranciscoBicalho', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10441, 10431);
INSERT INTO "ProdNac2021".cdg VALUES (3300396, 'RJ396', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-3', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8792, 7640);
INSERT INTO "ProdNac2021".cdg VALUES (3304674, 'RJ4674', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304686, 'RJ4686', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301177, 'RJ1177', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2096-3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300375, 'RJ375', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-71', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9978, 9295);
INSERT INTO "ProdNac2021".cdg VALUES (3304340, 'RJ4340', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304976, 'RJ4976', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304524, 'RJ4524', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304921, 'RJ4921', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300965, 'RJ965', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1C', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12164, 12081);
INSERT INTO "ProdNac2021".cdg VALUES (3304405, 'RJ4405', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304585, 'RJ4585', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300106, 'RJ106', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-F', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9686, 9644);
INSERT INTO "ProdNac2021".cdg VALUES (3304993, 'RJ4993', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301074, 'RJ1074', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '38', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304527, 'RJ4527', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300166, 'RJ166', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 D', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Cadastral', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 10717, 8340);
INSERT INTO "ProdNac2021".cdg VALUES (3300650, 'RJ650', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '527-C', 'SPU-RJ - Geoinformação', '117.137-MP', '83.714/33', 'Analógico', 'Carta Cadastral', '43.Trecho_Urca', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 10598, 10578);
INSERT INTO "ProdNac2021".cdg VALUES (3300905, 'RJ905', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1934-1', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301085, 'RJ1085', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '49', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300232, 'RJ232', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Índice', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 10000, 11044, 10056);
INSERT INTO "ProdNac2021".cdg VALUES (3300398, 'RJ398', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-5', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8797, 7642);
INSERT INTO "ProdNac2021".cdg VALUES (3300264, 'RJ264', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345A-4', 'SPU-RJ - Geoinformação', '117.137-MP', '17.225/54', 'Analógico', 'Carta Cadastral', '23.Trecho_PracaMaua-PalacioMonroe', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11157, 10342);
INSERT INTO "ProdNac2021".cdg VALUES (3304616, 'RJ4616', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304696, 'RJ4696', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304712, 'RJ4712', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300994, 'RJ994', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '6', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11623, 11536);
INSERT INTO "ProdNac2021".cdg VALUES (3304910, 'RJ4910', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300157, 'RJ157', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2311 D', 'SPU-RJ - Geoinformação', '117.137-MP', '108.875/50', 'Analógico', 'Carta Cadastral', '15.Trecho_Jequiriçá-JoaoPizarro', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 10677, 7829);
INSERT INTO "ProdNac2021".cdg VALUES (3300334, 'RJ334', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-35', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9670, 9124);
INSERT INTO "ProdNac2021".cdg VALUES (3300010, 'RJ10', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 3', 'SPU-RJ - Geoinformação', '117.137-MP', '13.5305/47', 'Analógico', 'Carta Cadastral', '02.PlantaFaixadeMarinhas_PraiadeBotafogo', 'Terreno de Marinha', 1947, NULL, 'Não', 'Não possui', 0, 500, 8066, 8049);
INSERT INTO "ProdNac2021".cdg VALUES (3300588, 'RJ588', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2737-10', 'SPU-RJ - Geoinformação', '117.137-MP', '153.158/58', 'Analógico', 'Carta Cadastral', '40.Trecho_ArroioFundo-PontaGrande_Trecho_FronteiroMargemSulLagoaJacarepagua', 'Terreno de Marinha', 1958, NULL, 'Não', 'Não possui', 0, 2000, 9814, 9800);
INSERT INTO "ProdNac2021".cdg VALUES (3300967, 'RJ967', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3C', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12127, 12039);
INSERT INTO "ProdNac2021".cdg VALUES (3304816, 'RJ4816', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300504, 'RJ504', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2720-7', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 10413, 10403);
INSERT INTO "ProdNac2021".cdg VALUES (3304542, 'RJ4542', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304406, 'RJ4406', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300509, 'RJ509', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3973-4', 'SPU-RJ - Geoinformação', '117.137-MP', '09481/80', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1980, NULL, 'Não', 'Não possui', 0, 2000, 10646, 10624);
INSERT INTO "ProdNac2021".cdg VALUES (3300606, 'RJ606', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-3', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8316, 7798);
INSERT INTO "ProdNac2021".cdg VALUES (3301120, 'RJ1120', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-15', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12037, 11847);
INSERT INTO "ProdNac2021".cdg VALUES (3304552, 'RJ4552', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300771, 'RJ771', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-32', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 1000, 11405, 11382);
INSERT INTO "ProdNac2021".cdg VALUES (3300290, 'RJ290', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2446 D', 'SPU-RJ - Geoinformação', '117.137-MP', '183.267/54', 'Analógico', 'Carta Cadastral', '25.Trecho_PraçaMaua-Gamboa', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 1000, 10020, 10002);
INSERT INTO "ProdNac2021".cdg VALUES (3304538, 'RJ4538', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300270, 'RJ270', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-3', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8238, 7663);
INSERT INTO "ProdNac2021".cdg VALUES (3304576, 'RJ4576', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300288, 'RJ288', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2446 B', 'SPU-RJ - Geoinformação', '117.137-MP', '183.267/54', 'Analógico', 'Carta Cadastral', '25.Trecho_PraçaMaua-Gamboa', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 1000, 10014, 9995);
INSERT INTO "ProdNac2021".cdg VALUES (3300156, 'RJ156', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2311 C', 'SPU-RJ - Geoinformação', '117.137-MP', '108.875/50', 'Analógico', 'Carta Cadastral', '15.Trecho_Jequiriçá-JoaoPizarro', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 10674, 7816);
INSERT INTO "ProdNac2021".cdg VALUES (3300690, 'RJ690', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-20', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11936, 11797);
INSERT INTO "ProdNac2021".cdg VALUES (3304481, 'RJ4481', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300577, 'RJ577', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2770-7', 'SPU-RJ - Geoinformação', '117.137-MP', '23.8551/57', 'Analógico', 'Carta Cadastral', '39.Trecho_PraçaAlbertoTorres-RioPavuna', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9850, 9831);
INSERT INTO "ProdNac2021".cdg VALUES (3300919, 'RJ919', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-8', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12194, 12174);
INSERT INTO "ProdNac2021".cdg VALUES (3301163, 'RJ1163', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2222-5', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12595, 12263);
INSERT INTO "ProdNac2021".cdg VALUES (3300383, 'RJ383', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-6', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8424, 7899);
INSERT INTO "ProdNac2021".cdg VALUES (3300333, 'RJ333', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-34', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9665, 8736);
INSERT INTO "ProdNac2021".cdg VALUES (3301131, 'RJ1131', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-26', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12067, 11863);
INSERT INTO "ProdNac2021".cdg VALUES (3300415, 'RJ415', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-22', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8823, 7672);
INSERT INTO "ProdNac2021".cdg VALUES (3300142, 'RJ142', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 N', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9887, 9862);
INSERT INTO "ProdNac2021".cdg VALUES (3300301, 'RJ301', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-4', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9327, 8642);
INSERT INTO "ProdNac2021".cdg VALUES (3304378, 'RJ4378', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304892, 'RJ4892', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300075, 'RJ75', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2067 INDICE', 'SPU-RJ - Geoinformação', '117.137-MP', '10.8873/50', 'Analógico', 'Carta Índice', '09.LinhaPreamarMedio1831_RuaLoboJunior-RuaJequiriça-Prolong', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 2500, 8891, 8882);
INSERT INTO "ProdNac2021".cdg VALUES (3301056, 'RJ1056', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '20', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301020, 'RJ1020', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '32', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11673, 11584);
INSERT INTO "ProdNac2021".cdg VALUES (3301127, 'RJ1127', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-22', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12054, 11857);
INSERT INTO "ProdNac2021".cdg VALUES (3300707, 'RJ707', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-37', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11961, 11880);
INSERT INTO "ProdNac2021".cdg VALUES (3301178, 'RJ1178', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2096-4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300896, 'RJ896', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2306-9', 'SPU-RJ - Geoinformação', '062.987-MP', '1096/70', 'Analógico', 'Carta Cadastral', '50.Gaveta7.Mangaratiba_Trecho_IlhaGuaiba_Passagem-Guarini', 'Terreno de Marinha', 1971, NULL, 'Não', 'Não possui', 0, 1000, 11930, 11766);
INSERT INTO "ProdNac2021".cdg VALUES (3300902, 'RJ902', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1979-4', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 522/60 Novo:228.538-60', 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1959, NULL, 'Não', 'Não possui', 0, 500, 12321, 12314);
INSERT INTO "ProdNac2021".cdg VALUES (3300293, 'RJ293', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2447 A', 'SPU-RJ - Geoinformação', '117.137-MP', '264.905/52', 'Analógico', 'Carta Cadastral', '26.Trecho_LadeiraRussel-PalacioMonroe', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 1000, 11162, 10650);
INSERT INTO "ProdNac2021".cdg VALUES (3300282, 'RJ282', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-15', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8376, 7766);
INSERT INTO "ProdNac2021".cdg VALUES (3304570, 'RJ4570', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304364, 'RJ4364', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304715, 'RJ4715', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300002, 'RJ02', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1759-B', 'SPU-RJ - Geoinformação', '117.137-MP', '89.554/54', 'Analógico', 'Carta Cadastral', '01.PlantaFaixadeMarinhaRuaSantoCristo', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 7817, 7787);
INSERT INTO "ProdNac2021".cdg VALUES (3300748, 'RJ748', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-11A', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11289, 11273);
INSERT INTO "ProdNac2021".cdg VALUES (3300851, 'RJ851', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-69', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12782, 12368);
INSERT INTO "ProdNac2021".cdg VALUES (3304608, 'RJ4608', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304711, 'RJ4711', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301221, 'RJ1221', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1285-4', 'SPU-RJ - Geoinformação', '062.987-MP', '051/42', 'Analógico', 'Carta Cadastral', '59.Gaveta17.Jacone_LagoaAraruama_TrechoJacone-PontaNegra', 'Terreno de Marinha', 1977, NULL, 'Não', 'Não possui', 0, 2500, 11463, 11657);
INSERT INTO "ProdNac2021".cdg VALUES (3300123, 'RJ123', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2260', 'SPU-RJ - Geoinformação', '117.137-MP', '10.404/51', 'Analógico', 'Carta Índice', '13.Trecho_PraiaFlamengo', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 5000, 9779, 9772);
INSERT INTO "ProdNac2021".cdg VALUES (3300342, 'RJ342', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-43', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9703, 9164);
INSERT INTO "ProdNac2021".cdg VALUES (3301207, 'RJ1207', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-8', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12016, 11980);
INSERT INTO "ProdNac2021".cdg VALUES (3301096, 'RJ1096', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2551-4', 'SPU-RJ - Geoinformação', '062.987-MP', '954/40', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 1000, 11810, 11691);
INSERT INTO "ProdNac2021".cdg VALUES (3304716, 'RJ4716', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300702, 'RJ702', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-32', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11948, 11809);
INSERT INTO "ProdNac2021".cdg VALUES (3304354, 'RJ4354', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300988, 'RJ988', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '9I', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12163, 12080);
INSERT INTO "ProdNac2021".cdg VALUES (3300215, 'RJ215', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1541 C', 'SPU-RJ - Geoinformação', '117.137-MP', '176.785/45', 'Analógico', 'Carta Cadastral', '19.Trecho_SepetibaFazendaNacionalSantaCruz', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 9985, 9931);
INSERT INTO "ProdNac2021".cdg VALUES (3300603, 'RJ603', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713 INDICE', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Índice', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 25000, 8309, 7761);
INSERT INTO "ProdNac2021".cdg VALUES (3304689, 'RJ4689', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301200, 'RJ1200', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-1', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12007, 11956);
INSERT INTO "ProdNac2021".cdg VALUES (3300714, 'RJ714', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-44', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11970, 11887);
INSERT INTO "ProdNac2021".cdg VALUES (3304505, 'RJ4505', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300976, 'RJ976', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '8D', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12150, 12061);
INSERT INTO "ProdNac2021".cdg VALUES (3304516, 'RJ4516', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300572, 'RJ572', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2770-2', 'SPU-RJ - Geoinformação', '117.137-MP', '23.8551/57', 'Analógico', 'Carta Cadastral', '39.Trecho_PraçaAlbertoTorres-RioPavuna', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9838, 9823);
INSERT INTO "ProdNac2021".cdg VALUES (3301118, 'RJ1118', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-13', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12034, 11845);
INSERT INTO "ProdNac2021".cdg VALUES (3304966, 'RJ4966', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301055, 'RJ1055', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '19', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300573, 'RJ573', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2770-3', 'SPU-RJ - Geoinformação', '117.137-MP', '23.8551/57', 'Analógico', 'Carta Cadastral', '39.Trecho_PraçaAlbertoTorres-RioPavuna', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9840, 9824);
INSERT INTO "ProdNac2021".cdg VALUES (3300078, 'RJ78', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2068-C', 'SPU-RJ - Geoinformação', '117.137-MP', '10.8873/50', 'Analógico', 'Carta Cadastral', '09.LinhaPreamarMedio1831_RuaLoboJunior-RuaJequiriça-Prolong', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8927, 8888);
INSERT INTO "ProdNac2021".cdg VALUES (3301184, 'RJ1184', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1803-5', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 15455, 12308);
INSERT INTO "ProdNac2021".cdg VALUES (3300622, 'RJ622', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-19', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8808, 8082);
INSERT INTO "ProdNac2021".cdg VALUES (3304961, 'RJ4961', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300292, 'RJ292', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'PLANTA 2447 INDICE', 'SPU-RJ - Geoinformação', '117.137-MP', '264.905/52', 'Analógico', 'Carta Índice', '26.Trecho_LadeiraRussel-PalacioMonroe', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 5000, 11160, 10354);
INSERT INTO "ProdNac2021".cdg VALUES (3304612, 'RJ4612', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304756, 'RJ4756', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300434, 'RJ434', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2616', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.797/53 Novo:10768.015508/92-59', 'Analógico', 'Carta Índice', '30.Trecho_FazendaNacionalSantaCruz_VilaGeny-Itaguai', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 10000, 8910, 7710);
INSERT INTO "ProdNac2021".cdg VALUES (3300812, 'RJ812', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-32', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11606, 11507);
INSERT INTO "ProdNac2021".cdg VALUES (3301091, 'RJ1091', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '55', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304655, 'RJ4655', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304847, 'RJ4847', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301126, 'RJ1126', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-21', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12053, 11856);
INSERT INTO "ProdNac2021".cdg VALUES (3304476, 'RJ4476', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300008, 'RJ08', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FOLHA 1', 'SPU-RJ - Geoinformação', '117.137-MP', '13.5305/47', 'Analógico', 'Carta Cadastral', '02.PlantaFaixadeMarinhas_PraiadeBotafogo', 'Terreno de Marinha', 1947, NULL, 'Não', 'Não possui', 0, 500, 8062, 7863);
INSERT INTO "ProdNac2021".cdg VALUES (3301110, 'RJ1110', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-5', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11874, 11836);
INSERT INTO "ProdNac2021".cdg VALUES (3300124, 'RJ124', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2260-A', 'SPU-RJ - Geoinformação', '117.137-MP', '10.404/51', 'Analógico', 'Carta Cadastral', '13.Trecho_PraiaFlamengo', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 1000, 9780, 9775);
INSERT INTO "ProdNac2021".cdg VALUES (3304561, 'RJ4561', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300568, 'RJ568', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2803-7', 'SPU-RJ - Geoinformação', '117.137-MP', '307.820/57', 'Analógico', 'Carta Cadastral', '38.Trecho_EstradaJacarepagua-ArroioFundo', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9974, 9948);
INSERT INTO "ProdNac2021".cdg VALUES (3304509, 'RJ4509', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300329, 'RJ329', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-30', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9654, 8729);
INSERT INTO "ProdNac2021".cdg VALUES (3301186, 'RJ1186', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1803-8', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 15457, 12317);
INSERT INTO "ProdNac2021".cdg VALUES (3300858, 'RJ858', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-76', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12790, 12375);
INSERT INTO "ProdNac2021".cdg VALUES (3304485, 'RJ4485', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304745, 'RJ4745', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304868, 'RJ4868', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300256, 'RJ256', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-H', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11147, 10223);
INSERT INTO "ProdNac2021".cdg VALUES (3304478, 'RJ4478', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300855, 'RJ855', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-73', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12787, 12372);
INSERT INTO "ProdNac2021".cdg VALUES (3300908, 'RJ908', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1934-4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300510, 'RJ510', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3973-5', 'SPU-RJ - Geoinformação', '117.137-MP', '09481/80', 'Analógico', 'Carta Cadastral', '33.Trecho_PontaMariscoLagoTijuca-EstradaJacarepagua', 'Terreno de Marinha', 1980, NULL, 'Não', 'Não possui', 0, 2000, 10647, 10625);
INSERT INTO "ProdNac2021".cdg VALUES (3300818, 'RJ818', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-38', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11615, 11515);
INSERT INTO "ProdNac2021".cdg VALUES (3300058, 'RJ58', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-9', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8772, 8753);
INSERT INTO "ProdNac2021".cdg VALUES (3301147, 'RJ1147', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-8', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12507, 11950);
INSERT INTO "ProdNac2021".cdg VALUES (3300920, 'RJ920', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-9', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12195, 12175);
INSERT INTO "ProdNac2021".cdg VALUES (3304346, 'RJ4346', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304578, 'RJ4578', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304580, 'RJ4580', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304982, 'RJ4982', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300189, 'RJ189', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-16', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 10896, 9230);
INSERT INTO "ProdNac2021".cdg VALUES (3304635, 'RJ4635', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301067, 'RJ1067', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '31', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300153, 'RJ153', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2311 A', 'SPU-RJ - Geoinformação', '117.137-MP', '108.875/50', 'Analógico', 'Carta Cadastral', '15.Trecho_Jequiriçá-JoaoPizarro', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 10662, 7788);
INSERT INTO "ProdNac2021".cdg VALUES (3301083, 'RJ1083', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '47', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300943, 'RJ943', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-5', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11742, 11726);
INSERT INTO "ProdNac2021".cdg VALUES (3300735, 'RJ735', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-2', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11276, 11236);
INSERT INTO "ProdNac2021".cdg VALUES (3300111, 'RJ111', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-K', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9694, 9669);
INSERT INTO "ProdNac2021".cdg VALUES (3304728, 'RJ4728', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300495, 'RJ495', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 15', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9058, 8228);
INSERT INTO "ProdNac2021".cdg VALUES (3300024, 'RJ24', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1815-D', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 280.255/48 Novo:10768.015327/92-12', 'Analógico', 'Carta Cadastral', '03.PlantaLinhadeMarinha_AvenidaPasteurCompostacomElementosColigidosno', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 500, 8445, 8433);
INSERT INTO "ProdNac2021".cdg VALUES (3304775, 'RJ4775', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304607, 'RJ4607', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301192, 'RJ1192', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1803-2', 'SPU-RJ - Geoinformação', '062.987-MP', '1255/53', 'Analógico', 'Carta Cadastral', '56.Gaveta13.CachoeiraCocal_BaiaMamangua_AngraReis_Trecho_ZonaBarreto_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 2000, 12645, 12304);
INSERT INTO "ProdNac2021".cdg VALUES (3301130, 'RJ1130', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-25', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12064, 11862);
INSERT INTO "ProdNac2021".cdg VALUES (3300913, 'RJ913', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-2', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12188, 12168);
INSERT INTO "ProdNac2021".cdg VALUES (3301063, 'RJ1063', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '27', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300490, 'RJ490', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 10', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9050, 8206);
INSERT INTO "ProdNac2021".cdg VALUES (3304650, 'RJ4650', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304620, 'RJ4620', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300039, 'RJ39', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-11', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8712, 8666);
INSERT INTO "ProdNac2021".cdg VALUES (3300910, 'RJ910', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1934-6', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304757, 'RJ4757', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304991, 'RJ4991', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300083, 'RJ83', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1181 D', 'SPU-RJ - Geoinformação', '117.137-MP', '62.079/51', 'Analógico', 'Carta Cadastral', '10.LinhaPreamarMedio1831_IlhasBaiacu-Cabras-Jurubaiba', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9027, 8987);
INSERT INTO "ProdNac2021".cdg VALUES (3301150, 'RJ1150', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-12', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12564, 11983);
INSERT INTO "ProdNac2021".cdg VALUES (3301049, 'RJ1049', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '13', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304397, 'RJ4397', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304842, 'RJ4842', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301168, 'RJ1168', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2290-4', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1971, NULL, 'Não', 'Não possui', 0, 1000, 12623, 12297);
INSERT INTO "ProdNac2021".cdg VALUES (3300125, 'RJ125', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2260-B', 'SPU-RJ - Geoinformação', '117.137-MP', '10.404/51', 'Analógico', 'Carta Cadastral', '13.Trecho_PraiaFlamengo', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 1000, 9781, 9776);
INSERT INTO "ProdNac2021".cdg VALUES (3301052, 'RJ1052', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '16', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300332, 'RJ332', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-33', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9663, 8733);
INSERT INTO "ProdNac2021".cdg VALUES (3300527, 'RJ527', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2753 - INDICE', 'SPU-RJ - Geoinformação', '117.137-MP', '237.984/54', 'Analógico', 'Carta Índice', '35.Trecho_PraiaSaoCristovaoAvenidaFranciscoBicalho', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 10000, 10437, 10415);
INSERT INTO "ProdNac2021".cdg VALUES (3300119, 'RJ119', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2218', 'SPU-RJ - Geoinformação', '117.137-MP', '41.263/52', 'Analógico', 'Carta Índice', '12.Trecho_RuaPedroAlves', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 5000, 9757, 9737);
INSERT INTO "ProdNac2021".cdg VALUES (3300693, 'RJ693', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-23', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11939, 11800);
INSERT INTO "ProdNac2021".cdg VALUES (3300350, 'RJ350', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-51', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9717, 9205);
INSERT INTO "ProdNac2021".cdg VALUES (3304627, 'RJ4627', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300604, 'RJ604', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-1', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8397, 7781);
INSERT INTO "ProdNac2021".cdg VALUES (3300867, 'RJ867', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-85', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12803, 12385);
INSERT INTO "ProdNac2021".cdg VALUES (3304380, 'RJ4380', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304837, 'RJ4837', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304930, 'RJ4930', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304952, 'RJ4952', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300163, 'RJ163', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1216 A', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 125.281/50 Novo:10768.015505/92-61', 'Analógico', 'Carta Cadastral', '17.Trecho_PraçaAlbertoTorres-EstradaPortoVelho', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 2000, 10706, 8333);
INSERT INTO "ProdNac2021".cdg VALUES (3304503, 'RJ4503', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304870, 'RJ4870', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301116, 'RJ1116', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1895-11', 'SPU-RJ - Geoinformação', '062.987-MP', '1071/56', 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 12032, 11842);
INSERT INTO "ProdNac2021".cdg VALUES (3300363, 'RJ363', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-61', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9924, 9254);
INSERT INTO "ProdNac2021".cdg VALUES (3300250, 'RJ250', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1600-B', 'SPU-RJ - Geoinformação', '117.137-MP', '81.579/53', 'Analógico', 'Carta Cadastral', '22. Trecho_AvNiemeyer_TrechoAvViscondeAlbuquerque-HenriqueMidosi', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11141, 10140);
INSERT INTO "ProdNac2021".cdg VALUES (3300551, 'RJ551', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-10', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10305, 10023);
INSERT INTO "ProdNac2021".cdg VALUES (3304591, 'RJ4591', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304948, 'RJ4948', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300397, 'RJ397', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-4', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8793, 7639);
INSERT INTO "ProdNac2021".cdg VALUES (3304801, 'RJ4801', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301089, 'RJ1089', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '53', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300053, 'RJ53', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1881-4', 'SPU-RJ - Geoinformação', '117.137-MP', '65.487/49', 'Analógico', 'Carta Cadastral', '05.LinhaPreamarMedio1831_EstradadoPortoVelho-RuaLoboJunior', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8763, 8745);
INSERT INTO "ProdNac2021".cdg VALUES (3304841, 'RJ4841', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300663, 'RJ663', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1896-2', 'SPU-RJ - Geoinformação', '062.987-MP', '1423/54', 'Analógico', 'Carta Cadastral', '45.Gaveta1.BarraSaoJoao-CaimiroAbreu_Trecho_CidadeSaoJoao-CasimiroAbreu', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 11198, 11188);
INSERT INTO "ProdNac2021".cdg VALUES (3304369, 'RJ4369', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300268, 'RJ268', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-1', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8220, 7652);
INSERT INTO "ProdNac2021".cdg VALUES (3301173, 'RJ1173', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1809-3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', NULL, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304434, 'RJ4434', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304702, 'RJ4702', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304898, 'RJ4898', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300997, 'RJ997', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '9', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11632, 11541);
INSERT INTO "ProdNac2021".cdg VALUES (3300986, 'RJ986', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '9H', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12162, 12079);
INSERT INTO "ProdNac2021".cdg VALUES (3304337, 'RJ4337', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304671, 'RJ4671', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300822, 'RJ822', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-42', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11627, 11519);
INSERT INTO "ProdNac2021".cdg VALUES (3300521, 'RJ521', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2713 - 9', 'SPU-RJ - Geoinformação', '117.137-MP', '341.187/56', 'Analógico', 'Carta Cadastral', '34.Trecho_EstradaVelhaBarraGuaratiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 8863, 8294);
INSERT INTO "ProdNac2021".cdg VALUES (3304373, 'RJ4373', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301206, 'RJ1206', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2344-7', 'SPU-RJ - Geoinformação', '062.987-MP', '1369/74', 'Analógico', 'Carta Cadastral', '58.Gaveta15.RiosOstras_Trecho_LitoralRioOstras', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 12015, 11979);
INSERT INTO "ProdNac2021".cdg VALUES (3300763, 'RJ763', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-25', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 715/59 Novo:292.114-62', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 500, 11347, 11305);
INSERT INTO "ProdNac2021".cdg VALUES (3300941, 'RJ941', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2345-3', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1370/74 Novo:0786.1370.74', 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1975, NULL, 'Não', 'Não possui', 0, 500, 11740, 11724);
INSERT INTO "ProdNac2021".cdg VALUES (3300737, 'RJ737', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1894-F-4', 'SPU-RJ - Geoinformação', '062.987-MP', '872/57', 'Analógico', 'Carta Cadastral', '47.Gaveta4.Macae_Trecho_PonteEFLeopoldina-ForteMHermes', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 500, 11278, 11239);
INSERT INTO "ProdNac2021".cdg VALUES (3300700, 'RJ700', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-30', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11946, 11807);
INSERT INTO "ProdNac2021".cdg VALUES (3300230, 'RJ230', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778-13', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Cadastral', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11043, 9551);
INSERT INTO "ProdNac2021".cdg VALUES (3304786, 'RJ4786', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300108, 'RJ108', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-H', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9689, 9659);
INSERT INTO "ProdNac2021".cdg VALUES (3304846, 'RJ4846', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304588, 'RJ4588', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304455, 'RJ4455', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304370, 'RJ4370', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300286, 'RJ286', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2446', 'SPU-RJ - Geoinformação', '117.137-MP', '183.267/54', 'Analógico', 'Carta Índice', '25.Trecho_PraçaMaua-Gamboa', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 5000, 10008, 9990);
INSERT INTO "ProdNac2021".cdg VALUES (3301026, 'RJ1026', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '38', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 11680, 11601);
INSERT INTO "ProdNac2021".cdg VALUES (3304450, 'RJ4450', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304877, 'RJ4877', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304977, 'RJ4977', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300074, 'RJ74', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2064-4', 'SPU-RJ - Geoinformação', '117.137-MP', '46.155/50', 'Analógico', 'Carta Cadastral', '08.LinhaPreamarMedio1831_AvenidaRuyBarbosa', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8187, 7641);
INSERT INTO "ProdNac2021".cdg VALUES (3300820, 'RJ820', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-40', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11620, 11517);
INSERT INTO "ProdNac2021".cdg VALUES (3304830, 'RJ4830', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304621, 'RJ4621', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3301073, 'RJ1073', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '37', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300426, 'RJ426', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-33', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8835, 7697);
INSERT INTO "ProdNac2021".cdg VALUES (3300127, 'RJ127', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2260-D', 'SPU-RJ - Geoinformação', '117.137-MP', '10.404/51', 'Analógico', 'Carta Cadastral', '13.Trecho_PraiaFlamengo', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 1000, 9783, 9778);
INSERT INTO "ProdNac2021".cdg VALUES (3300537, 'RJ537', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2759-1', 'SPU-RJ - Geoinformação', '117.137-MP', '113.824/57', 'Analógico', 'Carta Cadastral', '36.Trecho_PraiaPontalSernambetiba-MorroCaete', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 10490, 10480);
INSERT INTO "ProdNac2021".cdg VALUES (3304464, 'RJ4464', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300209, 'RJ209', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-36', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11026, 9362);
INSERT INTO "ProdNac2021".cdg VALUES (3300576, 'RJ576', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2770-6', 'SPU-RJ - Geoinformação', '117.137-MP', '23.8551/57', 'Analógico', 'Carta Cadastral', '39.Trecho_PraçaAlbertoTorres-RioPavuna', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9848, 9830);
INSERT INTO "ProdNac2021".cdg VALUES (3300421, 'RJ421', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-28', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8830, 7687);
INSERT INTO "ProdNac2021".cdg VALUES (3300353, 'RJ353', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-54', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9723, 9217);
INSERT INTO "ProdNac2021".cdg VALUES (3301051, 'RJ1051', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '15', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300088, 'RJ88', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1717 B', 'SPU-RJ - Geoinformação', '117.137-MP', '201362/54', 'Analógico', 'Carta Cadastral', '10.LinhaPreamarMedio1831_IlhasBaiacu-Cabras-Jurubaiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 9594, 9074);
INSERT INTO "ProdNac2021".cdg VALUES (3304676, 'RJ4676', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300079, 'RJ79', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2068-D', 'SPU-RJ - Geoinformação', '117.137-MP', '10.8873/50', 'Analógico', 'Carta Cadastral', '09.LinhaPreamarMedio1831_RuaLoboJunior-RuaJequiriça-Prolong', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8928, 8889);
INSERT INTO "ProdNac2021".cdg VALUES (3300685, 'RJ685', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-15', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11923, 11718);
INSERT INTO "ProdNac2021".cdg VALUES (3300218, 'RJ218', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1778', 'SPU-RJ - Geoinformação', '117.137-MP', '5.336/48', 'Analógico', 'Carta Índice', '20.Trecho_FazendaNacionalSantaCruz_PontaCaldas-TerrasReligiososCarmo', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 10000, 11031, 9458);
INSERT INTO "ProdNac2021".cdg VALUES (3300077, 'RJ77', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2068-B', 'SPU-RJ - Geoinformação', '117.137-MP', '10.8873/50', 'Analógico', 'Carta Cadastral', '09.LinhaPreamarMedio1831_RuaLoboJunior-RuaJequiriça-Prolong', 'Terreno de Marinha', 1950, NULL, 'Não', 'Não possui', 0, 500, 8913, 8886);
INSERT INTO "ProdNac2021".cdg VALUES (3300274, 'RJ274', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2443-7', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.440/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '24.Trecho_IlhaGovernador_PraiaGaegos-SacoRosa-PraiaGrande', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 8268, 7713);
INSERT INTO "ProdNac2021".cdg VALUES (3301146, 'RJ1146', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1712-7', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1966, NULL, 'Não', 'Não possui', 0, 1000, 12506, 11949);
INSERT INTO "ProdNac2021".cdg VALUES (3300006, 'RJ06', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1759-F', 'SPU-RJ - Geoinformação', '117.137-MP', '89.554/54', 'Analógico', 'Carta Cadastral', '01.PlantaFaixadeMarinhaRuaSantoCristo', 'Terreno de Marinha', 1973, NULL, 'Não', 'Não possui', 0, 500, 7832, 7808);
INSERT INTO "ProdNac2021".cdg VALUES (3300597, 'RJ597', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', 'FL 3054-7', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 330.395/60 Novo:10768.015329/92-30', 'Analógico', 'Carta Cadastral', '41.Trecho_Sernambetiba-BarraGuaratiba', 'Terreno de Marinha', 1962, NULL, 'Não', 'Não possui', 0, 2000, 9554, 9523);
INSERT INTO "ProdNac2021".cdg VALUES (3300486, 'RJ486', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2682 - 6', 'SPU-RJ - Geoinformação', '117.137-MP', '159.248/56', 'Analógico', 'Carta Cadastral', '32.Trecho_LagoasTijuca-Camorim', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 2000, 9041, 8192);
INSERT INTO "ProdNac2021".cdg VALUES (3300299, 'RJ299', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-2', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9320, 8636);
INSERT INTO "ProdNac2021".cdg VALUES (3300562, 'RJ562', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2803-1', 'SPU-RJ - Geoinformação', '117.137-MP', '307.820/57', 'Analógico', 'Carta Cadastral', '38.Trecho_EstradaJacarepagua-ArroioFundo', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 2000, 9956, 9935);
INSERT INTO "ProdNac2021".cdg VALUES (3300040, 'RJ40', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-12', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8713, 8670);
INSERT INTO "ProdNac2021".cdg VALUES (3300907, 'RJ907', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1934-3', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304372, 'RJ4372', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304617, 'RJ4617', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304908, 'RJ4908', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300545, 'RJ545', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2811-4', 'SPU-RJ - Geoinformação', '117.137-MP', '112.205/57', 'Analógico', 'Carta Cadastral', '37.Trecho_IlhaMadeira-MunicipioItaguai-BaiaSepetiba', 'Terreno de Marinha', 1957, NULL, 'Não', 'Não possui', 0, 1000, 10296, 10009);
INSERT INTO "ProdNac2021".cdg VALUES (3301153, 'RJ1153', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2208-1', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1968, NULL, 'Não', 'Não possui', 0, 1000, 12571, 12223);
INSERT INTO "ProdNac2021".cdg VALUES (3300906, 'RJ906', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1934-2', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '51.Gaveta8.Mangaratiba_Trecho_RioSaco-PontGuti', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300872, 'RJ872', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-89', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12821, 12458);
INSERT INTO "ProdNac2021".cdg VALUES (3304368, 'RJ4368', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304708, 'RJ4708', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304963, 'RJ4963', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300135, 'RJ135', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 G', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9881, 9849);
INSERT INTO "ProdNac2021".cdg VALUES (3300875, 'RJ875', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-92', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '49.Gaveta6.Mangaratiba_Trecho_OrlaMarítimaRamalMangaratiba', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 12824, 12461);
INSERT INTO "ProdNac2021".cdg VALUES (3300809, 'RJ809', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-29', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11603, 11504);
INSERT INTO "ProdNac2021".cdg VALUES (3300987, 'RJ987', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '8I', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '53.Gaveta10.NiteroiIcaraiCentro_Trecho_PraiaItaipu', 'Terreno de Marinha', 1967, NULL, 'Não', 'Não possui', 0, 500, 12159, 12075);
INSERT INTO "ProdNac2021".cdg VALUES (3300379, 'RJ379', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2571-2', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 263.844/53 Novo:10768.015468/92-36', 'Analógico', 'Carta Cadastral', '28.Trecho_AvGuilhermeMaxwell_AvDemocraticos_AvSuburbana-LargoBenfica', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 1000, 8409, 7889);
INSERT INTO "ProdNac2021".cdg VALUES (3300418, 'RJ418', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2581-25', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 88.445/54 Novo:10768.015330/92-19', 'Analógico', 'Carta Cadastral', '29.Trecho_IlhaGovernador-Jequia-Olaria-Freguesia', 'Terreno de Marinha', 1955, NULL, 'Não', 'Não possui', 0, 500, 8827, 7675);
INSERT INTO "ProdNac2021".cdg VALUES (3304521, 'RJ4521', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304697, 'RJ4697', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304863, 'RJ4863', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300829, 'RJ829', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2046-49', 'SPU-RJ - Geoinformação', '062.987-MP', '1065/59', 'Analógico', 'Carta Cadastral', '48.Gaveta5.Mangaratiba_Trecho_OrlaMaritima', 'Terreno de Marinha', 1961, NULL, 'Não', 'Não possui', 0, 500, 11750, 11529);
INSERT INTO "ProdNac2021".cdg VALUES (3300711, 'RJ711', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-41', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 11967, 11884);
INSERT INTO "ProdNac2021".cdg VALUES (3300918, 'RJ918', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1842-7', 'SPU-RJ - Geoinformação', '062.987-MP', 'Antigo: 1208/62 Novo:10768.026244/85-11', 'Analógico', 'Carta Cadastral', '52.Gaveta9.NiteroiIcaraiCentro_Trecho_CoronelGuimaraes-LargoBarreto', 'Terreno de Marinha', 1963, NULL, 'Não', 'Não possui', 0, 500, 12193, 12173);
INSERT INTO "ProdNac2021".cdg VALUES (3300146, 'RJ146', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2296 R', 'SPU-RJ - Geoinformação', '117.137-MP', '57.228/52', 'Analógico', 'Carta Cadastral', '14.Trecho_PontaMarisco-AvenidaNiemeyer', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9891, 9868);
INSERT INTO "ProdNac2021".cdg VALUES (3300211, 'RJ211', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1573-38', 'SPU-RJ - Geoinformação', '117.137-MP', '66.981/19-53', 'Analógico', 'Carta Cadastral', '18.Trecho_IlhaPaquetá', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 500, 11028, 9369);
INSERT INTO "ProdNac2021".cdg VALUES (3300032, 'RJ32', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1926-4', 'SPU-RJ - Geoinformação', '117.137-MP', '139.984/48', 'Analógico', 'Carta Cadastral', '04.LinhaPreamarMedio1831_AvenidaAtlantica', 'Terreno de Marinha', 1949, NULL, 'Não', 'Não possui', 0, 500, 8698, 8514);
INSERT INTO "ProdNac2021".cdg VALUES (3304698, 'RJ4698', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304864, 'RJ4864', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300617, 'RJ617', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-14', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 8796, 8072);
INSERT INTO "ProdNac2021".cdg VALUES (3301087, 'RJ1087', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '51', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '54.Gaveta11.Niteroi_OliveiraBote_BV_Trecho_FazendaBVLoteBV.S', 'Terreno de Marinha', 1956, NULL, 'Não', 'Não possui', 0, 1000, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300233, 'RJ233', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1779-1', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 24.525/53 Novo:10768.014079/95.81', 'Analógico', 'Carta Cadastral', '21.Trecho_FazendaNacionalSantaCruz_LimiteEsteFNSC-RioPiraque', 'Terreno de Marinha', 1953, NULL, 'Não', 'Não possui', 0, 1000, 11045, 10057);
INSERT INTO "ProdNac2021".cdg VALUES (3300641, 'RJ641', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '3713-38', 'SPU-RJ - Geoinformação', '117.137-MP', '79.646/73', 'Analógico', 'Carta Cadastral', '42.Trecho_EstradaBarraGuaratiba-RioPiraque-BaixadaGuaratiba', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 9440, 8267);
INSERT INTO "ProdNac2021".cdg VALUES (3304894, 'RJ4894', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300338, 'RJ338', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-39', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9695, 9140);
INSERT INTO "ProdNac2021".cdg VALUES (3304596, 'RJ4596', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3304641, 'RJ4641', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "ProdNac2021".cdg VALUES (3300321, 'RJ321', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '1590-22', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 158.986/53 Novo:10768.015509/92-11', 'Analógico', 'Carta Cadastral', '27.Trecho_IlhaGovernador_PonteGaleao-RuaPerezMotaJequia', 'Terreno de Marinha', 1954, NULL, 'Não', 'Não possui', 0, 500, 9624, 8711);
INSERT INTO "ProdNac2021".cdg VALUES (3301169, 'RJ1169', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2290-5', 'SPU-RJ - Geoinformação', '062.987-MP', NULL, 'Analógico', 'Carta Cadastral', '55.Gaveta12.NovaFribugo_Toledo_Nova Suica_BoaVentura_ParqueLagos_Trecho_Lote2J', 'Nacional Interior', 1971, NULL, 'Não', 'Não possui', 0, 1000, 12624, 12298);
INSERT INTO "ProdNac2021".cdg VALUES (3300102, 'RJ102', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2190-B', 'SPU-RJ - Geoinformação', '117.137-MP', 'Antigo: 220.066/50 Novo:10768.015463/92-12', 'Analógico', 'Carta Cadastral', '11.LinhaPremarMedio1831_AvenidaTexeiradeCastroaAvenidaGuilhermeMaxwell', 'Terreno de Marinha', 1952, NULL, 'Não', 'Não possui', 0, 500, 9682, 9626);
INSERT INTO "ProdNac2021".cdg VALUES (3300725, 'RJ725', 'RJ', 'Raphael Coelho - Zago/Ativo', 'Sim', '2346-55', 'SPU-RJ - Geoinformação', '062.987-MP', '1371/74', 'Analógico', 'Carta Cadastral', '46.Gaveta3.DuqueCaxias_Trecho_PonteEFLeopoldinaRioSarapui-FozRioMeriti', 'Terreno de Marinha', 1974, NULL, 'Não', 'Não possui', 0, 1000, 12102, 11898);
INSERT INTO "ProdNac2021".cdg VALUES (3304425, 'RJ4425', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);


--
-- TOC entry 2186 (class 0 OID 38192)
-- Dependencies: 187
-- Data for Name: geoaproximacao; Type: TABLE DATA; Schema: ProdNac2021; Owner: postgres
--



--
-- TOC entry 2188 (class 0 OID 38197)
-- Dependencies: 189
-- Data for Name: geolocalizacao; Type: TABLE DATA; Schema: ProdNac2021; Owner: postgres
--



--
-- TOC entry 2190 (class 0 OID 38202)
-- Dependencies: 191
-- Data for Name: georreferenciamento; Type: TABLE DATA; Schema: ProdNac2021; Owner: postgres
--



--
-- TOC entry 2192 (class 0 OID 38207)
-- Dependencies: 193
-- Data for Name: logbd; Type: TABLE DATA; Schema: ProdNac2021; Owner: postgres
--

INSERT INTO "ProdNac2021".logbd VALUES (1, '2021-04-13', 'postgres', 'INSERT', 3300978);
INSERT INTO "ProdNac2021".logbd VALUES (2, '2021-04-13', 'postgres', 'INSERT', 3300005);
INSERT INTO "ProdNac2021".logbd VALUES (3, '2021-04-13', 'postgres', 'INSERT', 3304823);
INSERT INTO "ProdNac2021".logbd VALUES (4, '2021-04-13', 'postgres', 'INSERT', 3300542);
INSERT INTO "ProdNac2021".logbd VALUES (5, '2021-04-13', 'postgres', 'INSERT', 3304914);
INSERT INTO "ProdNac2021".logbd VALUES (6, '2021-04-13', 'postgres', 'INSERT', 3300042);
INSERT INTO "ProdNac2021".logbd VALUES (7, '2021-04-13', 'postgres', 'INSERT', 3304508);
INSERT INTO "ProdNac2021".logbd VALUES (8, '2021-04-13', 'postgres', 'INSERT', 3300696);
INSERT INTO "ProdNac2021".logbd VALUES (9, '2021-04-13', 'postgres', 'INSERT', 3304572);
INSERT INTO "ProdNac2021".logbd VALUES (10, '2021-04-13', 'postgres', 'INSERT', 3304918);
INSERT INTO "ProdNac2021".logbd VALUES (11, '2021-04-13', 'postgres', 'INSERT', 3301213);
INSERT INTO "ProdNac2021".logbd VALUES (12, '2021-04-13', 'postgres', 'INSERT', 3300314);
INSERT INTO "ProdNac2021".logbd VALUES (13, '2021-04-13', 'postgres', 'INSERT', 3301165);
INSERT INTO "ProdNac2021".logbd VALUES (14, '2021-04-13', 'postgres', 'INSERT', 3301224);
INSERT INTO "ProdNac2021".logbd VALUES (15, '2021-04-13', 'postgres', 'INSERT', 3300267);
INSERT INTO "ProdNac2021".logbd VALUES (16, '2021-04-13', 'postgres', 'INSERT', 3304975);
INSERT INTO "ProdNac2021".logbd VALUES (17, '2021-04-13', 'postgres', 'INSERT', 3304859);
INSERT INTO "ProdNac2021".logbd VALUES (18, '2021-04-13', 'postgres', 'INSERT', 3300208);
INSERT INTO "ProdNac2021".logbd VALUES (19, '2021-04-13', 'postgres', 'INSERT', 3304358);
INSERT INTO "ProdNac2021".logbd VALUES (20, '2021-04-13', 'postgres', 'INSERT', 3301038);
INSERT INTO "ProdNac2021".logbd VALUES (21, '2021-04-13', 'postgres', 'INSERT', 3300668);
INSERT INTO "ProdNac2021".logbd VALUES (22, '2021-04-13', 'postgres', 'INSERT', 3304413);
INSERT INTO "ProdNac2021".logbd VALUES (23, '2021-04-13', 'postgres', 'INSERT', 3300796);
INSERT INTO "ProdNac2021".logbd VALUES (24, '2021-04-13', 'postgres', 'INSERT', 3300172);
INSERT INTO "ProdNac2021".logbd VALUES (25, '2021-04-13', 'postgres', 'INSERT', 3300365);
INSERT INTO "ProdNac2021".logbd VALUES (26, '2021-04-13', 'postgres', 'INSERT', 3300889);
INSERT INTO "ProdNac2021".logbd VALUES (27, '2021-04-13', 'postgres', 'INSERT', 3301037);
INSERT INTO "ProdNac2021".logbd VALUES (28, '2021-04-13', 'postgres', 'INSERT', 3300428);
INSERT INTO "ProdNac2021".logbd VALUES (29, '2021-04-13', 'postgres', 'INSERT', 3300944);
INSERT INTO "ProdNac2021".logbd VALUES (30, '2021-04-13', 'postgres', 'INSERT', 3300427);
INSERT INTO "ProdNac2021".logbd VALUES (31, '2021-04-13', 'postgres', 'INSERT', 3301040);
INSERT INTO "ProdNac2021".logbd VALUES (32, '2021-04-13', 'postgres', 'INSERT', 3300130);
INSERT INTO "ProdNac2021".logbd VALUES (33, '2021-04-13', 'postgres', 'INSERT', 3301108);
INSERT INTO "ProdNac2021".logbd VALUES (34, '2021-04-13', 'postgres', 'INSERT', 3304646);
INSERT INTO "ProdNac2021".logbd VALUES (35, '2021-04-13', 'postgres', 'INSERT', 3301070);
INSERT INTO "ProdNac2021".logbd VALUES (36, '2021-04-13', 'postgres', 'INSERT', 3300739);
INSERT INTO "ProdNac2021".logbd VALUES (37, '2021-04-13', 'postgres', 'INSERT', 3304352);
INSERT INTO "ProdNac2021".logbd VALUES (38, '2021-04-13', 'postgres', 'INSERT', 3304819);
INSERT INTO "ProdNac2021".logbd VALUES (39, '2021-04-13', 'postgres', 'INSERT', 3304836);
INSERT INTO "ProdNac2021".logbd VALUES (40, '2021-04-13', 'postgres', 'INSERT', 3300229);
INSERT INTO "ProdNac2021".logbd VALUES (41, '2021-04-13', 'postgres', 'INSERT', 3300103);
INSERT INTO "ProdNac2021".logbd VALUES (42, '2021-04-13', 'postgres', 'INSERT', 3300882);
INSERT INTO "ProdNac2021".logbd VALUES (43, '2021-04-13', 'postgres', 'INSERT', 3300393);
INSERT INTO "ProdNac2021".logbd VALUES (44, '2021-04-13', 'postgres', 'INSERT', 3304765);
INSERT INTO "ProdNac2021".logbd VALUES (45, '2021-04-13', 'postgres', 'INSERT', 3304972);
INSERT INTO "ProdNac2021".logbd VALUES (46, '2021-04-13', 'postgres', 'INSERT', 3304401);
INSERT INTO "ProdNac2021".logbd VALUES (47, '2021-04-13', 'postgres', 'INSERT', 3304866);
INSERT INTO "ProdNac2021".logbd VALUES (48, '2021-04-13', 'postgres', 'INSERT', 3300989);
INSERT INTO "ProdNac2021".logbd VALUES (49, '2021-04-13', 'postgres', 'INSERT', 3304784);
INSERT INTO "ProdNac2021".logbd VALUES (50, '2021-04-13', 'postgres', 'INSERT', 3300752);
INSERT INTO "ProdNac2021".logbd VALUES (51, '2021-04-13', 'postgres', 'INSERT', 3300563);
INSERT INTO "ProdNac2021".logbd VALUES (52, '2021-04-13', 'postgres', 'INSERT', 3300854);
INSERT INTO "ProdNac2021".logbd VALUES (53, '2021-04-13', 'postgres', 'INSERT', 3300686);
INSERT INTO "ProdNac2021".logbd VALUES (54, '2021-04-13', 'postgres', 'INSERT', 3300492);
INSERT INTO "ProdNac2021".logbd VALUES (55, '2021-04-13', 'postgres', 'INSERT', 3300139);
INSERT INTO "ProdNac2021".logbd VALUES (56, '2021-04-13', 'postgres', 'INSERT', 3304432);
INSERT INTO "ProdNac2021".logbd VALUES (57, '2021-04-13', 'postgres', 'INSERT', 3304737);
INSERT INTO "ProdNac2021".logbd VALUES (58, '2021-04-13', 'postgres', 'INSERT', 3304602);
INSERT INTO "ProdNac2021".logbd VALUES (59, '2021-04-13', 'postgres', 'INSERT', 3300712);
INSERT INTO "ProdNac2021".logbd VALUES (60, '2021-04-13', 'postgres', 'INSERT', 3300916);
INSERT INTO "ProdNac2021".logbd VALUES (61, '2021-04-13', 'postgres', 'INSERT', 3300892);
INSERT INTO "ProdNac2021".logbd VALUES (62, '2021-04-13', 'postgres', 'INSERT', 3300848);
INSERT INTO "ProdNac2021".logbd VALUES (63, '2021-04-13', 'postgres', 'INSERT', 3300780);
INSERT INTO "ProdNac2021".logbd VALUES (64, '2021-04-13', 'postgres', 'INSERT', 3304673);
INSERT INTO "ProdNac2021".logbd VALUES (65, '2021-04-13', 'postgres', 'INSERT', 3300475);
INSERT INTO "ProdNac2021".logbd VALUES (66, '2021-04-13', 'postgres', 'INSERT', 3300680);
INSERT INTO "ProdNac2021".logbd VALUES (67, '2021-04-13', 'postgres', 'INSERT', 3300012);
INSERT INTO "ProdNac2021".logbd VALUES (68, '2021-04-13', 'postgres', 'INSERT', 3300438);
INSERT INTO "ProdNac2021".logbd VALUES (69, '2021-04-13', 'postgres', 'INSERT', 3300667);
INSERT INTO "ProdNac2021".logbd VALUES (70, '2021-04-13', 'postgres', 'INSERT', 3304986);
INSERT INTO "ProdNac2021".logbd VALUES (71, '2021-04-13', 'postgres', 'INSERT', 3304469);
INSERT INTO "ProdNac2021".logbd VALUES (72, '2021-04-13', 'postgres', 'INSERT', 3301009);
INSERT INTO "ProdNac2021".logbd VALUES (73, '2021-04-13', 'postgres', 'INSERT', 3304713);
INSERT INTO "ProdNac2021".logbd VALUES (74, '2021-04-13', 'postgres', 'INSERT', 3304514);
INSERT INTO "ProdNac2021".logbd VALUES (75, '2021-04-13', 'postgres', 'INSERT', 3300924);
INSERT INTO "ProdNac2021".logbd VALUES (76, '2021-04-13', 'postgres', 'INSERT', 3300235);
INSERT INTO "ProdNac2021".logbd VALUES (77, '2021-04-13', 'postgres', 'INSERT', 3304427);
INSERT INTO "ProdNac2021".logbd VALUES (78, '2021-04-13', 'postgres', 'INSERT', 3300283);
INSERT INTO "ProdNac2021".logbd VALUES (79, '2021-04-13', 'postgres', 'INSERT', 3304672);
INSERT INTO "ProdNac2021".logbd VALUES (80, '2021-04-13', 'postgres', 'INSERT', 3304416);
INSERT INTO "ProdNac2021".logbd VALUES (81, '2021-04-13', 'postgres', 'INSERT', 3304920);
INSERT INTO "ProdNac2021".logbd VALUES (82, '2021-04-13', 'postgres', 'INSERT', 3301119);
INSERT INTO "ProdNac2021".logbd VALUES (83, '2021-04-13', 'postgres', 'INSERT', 3300516);
INSERT INTO "ProdNac2021".logbd VALUES (84, '2021-04-13', 'postgres', 'INSERT', 3301028);
INSERT INTO "ProdNac2021".logbd VALUES (85, '2021-04-13', 'postgres', 'INSERT', 3300534);
INSERT INTO "ProdNac2021".logbd VALUES (86, '2021-04-13', 'postgres', 'INSERT', 3300494);
INSERT INTO "ProdNac2021".logbd VALUES (87, '2021-04-13', 'postgres', 'INSERT', 3300284);
INSERT INTO "ProdNac2021".logbd VALUES (88, '2021-04-13', 'postgres', 'INSERT', 3300245);
INSERT INTO "ProdNac2021".logbd VALUES (89, '2021-04-13', 'postgres', 'INSERT', 3301039);
INSERT INTO "ProdNac2021".logbd VALUES (90, '2021-04-13', 'postgres', 'INSERT', 3304573);
INSERT INTO "ProdNac2021".logbd VALUES (91, '2021-04-13', 'postgres', 'INSERT', 3300122);
INSERT INTO "ProdNac2021".logbd VALUES (92, '2021-04-13', 'postgres', 'INSERT', 3304941);
INSERT INTO "ProdNac2021".logbd VALUES (93, '2021-04-13', 'postgres', 'INSERT', 3300893);
INSERT INTO "ProdNac2021".logbd VALUES (94, '2021-04-13', 'postgres', 'INSERT', 3304722);
INSERT INTO "ProdNac2021".logbd VALUES (95, '2021-04-13', 'postgres', 'INSERT', 3304475);
INSERT INTO "ProdNac2021".logbd VALUES (96, '2021-04-13', 'postgres', 'INSERT', 3301152);
INSERT INTO "ProdNac2021".logbd VALUES (97, '2021-04-13', 'postgres', 'INSERT', 3300152);
INSERT INTO "ProdNac2021".logbd VALUES (98, '2021-04-13', 'postgres', 'INSERT', 3304876);
INSERT INTO "ProdNac2021".logbd VALUES (99, '2021-04-13', 'postgres', 'INSERT', 3300837);
INSERT INTO "ProdNac2021".logbd VALUES (100, '2021-04-13', 'postgres', 'INSERT', 3300747);
INSERT INTO "ProdNac2021".logbd VALUES (101, '2021-04-13', 'postgres', 'INSERT', 3300810);
INSERT INTO "ProdNac2021".logbd VALUES (102, '2021-04-13', 'postgres', 'INSERT', 3301179);
INSERT INTO "ProdNac2021".logbd VALUES (103, '2021-04-13', 'postgres', 'INSERT', 3300320);
INSERT INTO "ProdNac2021".logbd VALUES (104, '2021-04-13', 'postgres', 'INSERT', 3301133);
INSERT INTO "ProdNac2021".logbd VALUES (105, '2021-04-13', 'postgres', 'INSERT', 3300313);
INSERT INTO "ProdNac2021".logbd VALUES (106, '2021-04-13', 'postgres', 'INSERT', 3300593);
INSERT INTO "ProdNac2021".logbd VALUES (107, '2021-04-13', 'postgres', 'INSERT', 3300623);
INSERT INTO "ProdNac2021".logbd VALUES (108, '2021-04-13', 'postgres', 'INSERT', 3300767);
INSERT INTO "ProdNac2021".logbd VALUES (109, '2021-04-13', 'postgres', 'INSERT', 3304531);
INSERT INTO "ProdNac2021".logbd VALUES (110, '2021-04-13', 'postgres', 'INSERT', 3304545);
INSERT INTO "ProdNac2021".logbd VALUES (111, '2021-04-13', 'postgres', 'INSERT', 3300272);
INSERT INTO "ProdNac2021".logbd VALUES (112, '2021-04-13', 'postgres', 'INSERT', 3300117);
INSERT INTO "ProdNac2021".logbd VALUES (113, '2021-04-13', 'postgres', 'INSERT', 3300535);
INSERT INTO "ProdNac2021".logbd VALUES (114, '2021-04-13', 'postgres', 'INSERT', 3304595);
INSERT INTO "ProdNac2021".logbd VALUES (115, '2021-04-13', 'postgres', 'INSERT', 3304603);
INSERT INTO "ProdNac2021".logbd VALUES (116, '2021-04-13', 'postgres', 'INSERT', 3300821);
INSERT INTO "ProdNac2021".logbd VALUES (117, '2021-04-13', 'postgres', 'INSERT', 3304506);
INSERT INTO "ProdNac2021".logbd VALUES (118, '2021-04-13', 'postgres', 'INSERT', 3304376);
INSERT INTO "ProdNac2021".logbd VALUES (119, '2021-04-13', 'postgres', 'INSERT', 3300741);
INSERT INTO "ProdNac2021".logbd VALUES (120, '2021-04-13', 'postgres', 'INSERT', 3300760);
INSERT INTO "ProdNac2021".logbd VALUES (121, '2021-04-13', 'postgres', 'INSERT', 3301103);
INSERT INTO "ProdNac2021".logbd VALUES (122, '2021-04-13', 'postgres', 'INSERT', 3300368);
INSERT INTO "ProdNac2021".logbd VALUES (123, '2021-04-13', 'postgres', 'INSERT', 3300472);
INSERT INTO "ProdNac2021".logbd VALUES (124, '2021-04-13', 'postgres', 'INSERT', 3300070);
INSERT INTO "ProdNac2021".logbd VALUES (125, '2021-04-13', 'postgres', 'INSERT', 3304732);
INSERT INTO "ProdNac2021".logbd VALUES (126, '2021-04-13', 'postgres', 'INSERT', 3301149);
INSERT INTO "ProdNac2021".logbd VALUES (127, '2021-04-13', 'postgres', 'INSERT', 3300849);
INSERT INTO "ProdNac2021".logbd VALUES (128, '2021-04-13', 'postgres', 'INSERT', 3300203);
INSERT INTO "ProdNac2021".logbd VALUES (129, '2021-04-13', 'postgres', 'INSERT', 3304748);
INSERT INTO "ProdNac2021".logbd VALUES (130, '2021-04-13', 'postgres', 'INSERT', 3300631);
INSERT INTO "ProdNac2021".logbd VALUES (131, '2021-04-13', 'postgres', 'INSERT', 3304719);
INSERT INTO "ProdNac2021".logbd VALUES (132, '2021-04-13', 'postgres', 'INSERT', 3304845);
INSERT INTO "ProdNac2021".logbd VALUES (133, '2021-04-13', 'postgres', 'INSERT', 3300627);
INSERT INTO "ProdNac2021".logbd VALUES (134, '2021-04-13', 'postgres', 'INSERT', 3301195);
INSERT INTO "ProdNac2021".logbd VALUES (135, '2021-04-13', 'postgres', 'INSERT', 3304735);
INSERT INTO "ProdNac2021".logbd VALUES (136, '2021-04-13', 'postgres', 'INSERT', 3301092);
INSERT INTO "ProdNac2021".logbd VALUES (137, '2021-04-13', 'postgres', 'INSERT', 3301024);
INSERT INTO "ProdNac2021".logbd VALUES (138, '2021-04-13', 'postgres', 'INSERT', 3300416);
INSERT INTO "ProdNac2021".logbd VALUES (139, '2021-04-13', 'postgres', 'INSERT', 3300497);
INSERT INTO "ProdNac2021".logbd VALUES (140, '2021-04-13', 'postgres', 'INSERT', 3300819);
INSERT INTO "ProdNac2021".logbd VALUES (141, '2021-04-13', 'postgres', 'INSERT', 3304526);
INSERT INTO "ProdNac2021".logbd VALUES (142, '2021-04-13', 'postgres', 'INSERT', 3304951);
INSERT INTO "ProdNac2021".logbd VALUES (143, '2021-04-13', 'postgres', 'INSERT', 3304965);
INSERT INTO "ProdNac2021".logbd VALUES (144, '2021-04-13', 'postgres', 'INSERT', 3304789);
INSERT INTO "ProdNac2021".logbd VALUES (145, '2021-04-13', 'postgres', 'INSERT', 3300109);
INSERT INTO "ProdNac2021".logbd VALUES (146, '2021-04-13', 'postgres', 'INSERT', 3300224);
INSERT INTO "ProdNac2021".logbd VALUES (147, '2021-04-13', 'postgres', 'INSERT', 3300618);
INSERT INTO "ProdNac2021".logbd VALUES (148, '2021-04-13', 'postgres', 'INSERT', 3304426);
INSERT INTO "ProdNac2021".logbd VALUES (149, '2021-04-13', 'postgres', 'INSERT', 3300649);
INSERT INTO "ProdNac2021".logbd VALUES (150, '2021-04-13', 'postgres', 'INSERT', 3301082);
INSERT INTO "ProdNac2021".logbd VALUES (151, '2021-04-13', 'postgres', 'INSERT', 3301014);
INSERT INTO "ProdNac2021".logbd VALUES (152, '2021-04-13', 'postgres', 'INSERT', 3304381);
INSERT INTO "ProdNac2021".logbd VALUES (153, '2021-04-13', 'postgres', 'INSERT', 3300263);
INSERT INTO "ProdNac2021".logbd VALUES (154, '2021-04-13', 'postgres', 'INSERT', 3300395);
INSERT INTO "ProdNac2021".logbd VALUES (155, '2021-04-13', 'postgres', 'INSERT', 3300315);
INSERT INTO "ProdNac2021".logbd VALUES (156, '2021-04-13', 'postgres', 'INSERT', 3301139);
INSERT INTO "ProdNac2021".logbd VALUES (157, '2021-04-13', 'postgres', 'INSERT', 3300811);
INSERT INTO "ProdNac2021".logbd VALUES (158, '2021-04-13', 'postgres', 'INSERT', 3300614);
INSERT INTO "ProdNac2021".logbd VALUES (159, '2021-04-13', 'postgres', 'INSERT', 3300721);
INSERT INTO "ProdNac2021".logbd VALUES (160, '2021-04-13', 'postgres', 'INSERT', 3300259);
INSERT INTO "ProdNac2021".logbd VALUES (161, '2021-04-13', 'postgres', 'INSERT', 3300359);
INSERT INTO "ProdNac2021".logbd VALUES (162, '2021-04-13', 'postgres', 'INSERT', 3304645);
INSERT INTO "ProdNac2021".logbd VALUES (163, '2021-04-13', 'postgres', 'INSERT', 3304969);
INSERT INTO "ProdNac2021".logbd VALUES (164, '2021-04-13', 'postgres', 'INSERT', 3300336);
INSERT INTO "ProdNac2021".logbd VALUES (165, '2021-04-13', 'postgres', 'INSERT', 3300624);
INSERT INTO "ProdNac2021".logbd VALUES (166, '2021-04-13', 'postgres', 'INSERT', 3301027);
INSERT INTO "ProdNac2021".logbd VALUES (167, '2021-04-13', 'postgres', 'INSERT', 3304349);
INSERT INTO "ProdNac2021".logbd VALUES (168, '2021-04-13', 'postgres', 'INSERT', 3300765);
INSERT INTO "ProdNac2021".logbd VALUES (169, '2021-04-13', 'postgres', 'INSERT', 3304541);
INSERT INTO "ProdNac2021".logbd VALUES (170, '2021-04-13', 'postgres', 'INSERT', 3301972);
INSERT INTO "ProdNac2021".logbd VALUES (171, '2021-04-13', 'postgres', 'INSERT', 3304452);
INSERT INTO "ProdNac2021".logbd VALUES (172, '2021-04-13', 'postgres', 'INSERT', 3304484);
INSERT INTO "ProdNac2021".logbd VALUES (173, '2021-04-13', 'postgres', 'INSERT', 3300715);
INSERT INTO "ProdNac2021".logbd VALUES (174, '2021-04-13', 'postgres', 'INSERT', 3300599);
INSERT INTO "ProdNac2021".logbd VALUES (175, '2021-04-13', 'postgres', 'INSERT', 3300802);
INSERT INTO "ProdNac2021".logbd VALUES (176, '2021-04-13', 'postgres', 'INSERT', 3304448);
INSERT INTO "ProdNac2021".logbd VALUES (177, '2021-04-13', 'postgres', 'INSERT', 3300636);
INSERT INTO "ProdNac2021".logbd VALUES (178, '2021-04-13', 'postgres', 'INSERT', 3300298);
INSERT INTO "ProdNac2021".logbd VALUES (179, '2021-04-13', 'postgres', 'INSERT', 3304681);
INSERT INTO "ProdNac2021".logbd VALUES (180, '2021-04-13', 'postgres', 'INSERT', 3304367);
INSERT INTO "ProdNac2021".logbd VALUES (181, '2021-04-13', 'postgres', 'INSERT', 3300678);
INSERT INTO "ProdNac2021".logbd VALUES (182, '2021-04-13', 'postgres', 'INSERT', 3300072);
INSERT INTO "ProdNac2021".logbd VALUES (183, '2021-04-13', 'postgres', 'INSERT', 3300409);
INSERT INTO "ProdNac2021".logbd VALUES (184, '2021-04-13', 'postgres', 'INSERT', 3300738);
INSERT INTO "ProdNac2021".logbd VALUES (185, '2021-04-13', 'postgres', 'INSERT', 3304583);
INSERT INTO "ProdNac2021".logbd VALUES (186, '2021-04-13', 'postgres', 'INSERT', 3300041);
INSERT INTO "ProdNac2021".logbd VALUES (187, '2021-04-13', 'postgres', 'INSERT', 3300694);
INSERT INTO "ProdNac2021".logbd VALUES (188, '2021-04-13', 'postgres', 'INSERT', 3304897);
INSERT INTO "ProdNac2021".logbd VALUES (189, '2021-04-13', 'postgres', 'INSERT', 3304881);
INSERT INTO "ProdNac2021".logbd VALUES (190, '2021-04-13', 'postgres', 'INSERT', 3300450);
INSERT INTO "ProdNac2021".logbd VALUES (191, '2021-04-13', 'postgres', 'INSERT', 3304768);
INSERT INTO "ProdNac2021".logbd VALUES (192, '2021-04-13', 'postgres', 'INSERT', 3300446);
INSERT INTO "ProdNac2021".logbd VALUES (193, '2021-04-13', 'postgres', 'INSERT', 3300291);
INSERT INTO "ProdNac2021".logbd VALUES (194, '2021-04-13', 'postgres', 'INSERT', 3304491);
INSERT INTO "ProdNac2021".logbd VALUES (195, '2021-04-13', 'postgres', 'INSERT', 3300095);
INSERT INTO "ProdNac2021".logbd VALUES (196, '2021-04-13', 'postgres', 'INSERT', 3304409);
INSERT INTO "ProdNac2021".logbd VALUES (197, '2021-04-13', 'postgres', 'INSERT', 3304423);
INSERT INTO "ProdNac2021".logbd VALUES (198, '2021-04-13', 'postgres', 'INSERT', 3304543);
INSERT INTO "ProdNac2021".logbd VALUES (199, '2021-04-13', 'postgres', 'INSERT', 3300939);
INSERT INTO "ProdNac2021".logbd VALUES (200, '2021-04-13', 'postgres', 'INSERT', 3300037);
INSERT INTO "ProdNac2021".logbd VALUES (201, '2021-04-13', 'postgres', 'INSERT', 3304720);
INSERT INTO "ProdNac2021".logbd VALUES (202, '2021-04-13', 'postgres', 'INSERT', 3300579);
INSERT INTO "ProdNac2021".logbd VALUES (203, '2021-04-13', 'postgres', 'INSERT', 3300533);
INSERT INTO "ProdNac2021".logbd VALUES (204, '2021-04-13', 'postgres', 'INSERT', 3304414);
INSERT INTO "ProdNac2021".logbd VALUES (205, '2021-04-13', 'postgres', 'INSERT', 3300753);
INSERT INTO "ProdNac2021".logbd VALUES (206, '2021-04-13', 'postgres', 'INSERT', 3304453);
INSERT INTO "ProdNac2021".logbd VALUES (207, '2021-04-13', 'postgres', 'INSERT', 3304474);
INSERT INTO "ProdNac2021".logbd VALUES (208, '2021-04-13', 'postgres', 'INSERT', 3304785);
INSERT INTO "ProdNac2021".logbd VALUES (209, '2021-04-13', 'postgres', 'INSERT', 3300575);
INSERT INTO "ProdNac2021".logbd VALUES (210, '2021-04-13', 'postgres', 'INSERT', 3304682);
INSERT INTO "ProdNac2021".logbd VALUES (211, '2021-04-13', 'postgres', 'INSERT', 3301008);
INSERT INTO "ProdNac2021".logbd VALUES (212, '2021-04-13', 'postgres', 'INSERT', 3304360);
INSERT INTO "ProdNac2021".logbd VALUES (213, '2021-04-13', 'postgres', 'INSERT', 3300050);
INSERT INTO "ProdNac2021".logbd VALUES (214, '2021-04-13', 'postgres', 'INSERT', 3300772);
INSERT INTO "ProdNac2021".logbd VALUES (215, '2021-04-13', 'postgres', 'INSERT', 3301220);
INSERT INTO "ProdNac2021".logbd VALUES (216, '2021-04-13', 'postgres', 'INSERT', 3304750);
INSERT INTO "ProdNac2021".logbd VALUES (217, '2021-04-13', 'postgres', 'INSERT', 3300963);
INSERT INTO "ProdNac2021".logbd VALUES (218, '2021-04-13', 'postgres', 'INSERT', 3300271);
INSERT INTO "ProdNac2021".logbd VALUES (219, '2021-04-13', 'postgres', 'INSERT', 3300469);
INSERT INTO "ProdNac2021".logbd VALUES (220, '2021-04-13', 'postgres', 'INSERT', 3304925);
INSERT INTO "ProdNac2021".logbd VALUES (221, '2021-04-13', 'postgres', 'INSERT', 3300754);
INSERT INTO "ProdNac2021".logbd VALUES (222, '2021-04-13', 'postgres', 'INSERT', 3304788);
INSERT INTO "ProdNac2021".logbd VALUES (223, '2021-04-13', 'postgres', 'INSERT', 3300581);
INSERT INTO "ProdNac2021".logbd VALUES (224, '2021-04-13', 'postgres', 'INSERT', 3301223);
INSERT INTO "ProdNac2021".logbd VALUES (225, '2021-04-13', 'postgres', 'INSERT', 3300642);
INSERT INTO "ProdNac2021".logbd VALUES (226, '2021-04-13', 'postgres', 'INSERT', 3300635);
INSERT INTO "ProdNac2021".logbd VALUES (227, '2021-04-13', 'postgres', 'INSERT', 3300300);
INSERT INTO "ProdNac2021".logbd VALUES (228, '2021-04-13', 'postgres', 'INSERT', 3300276);
INSERT INTO "ProdNac2021".logbd VALUES (229, '2021-04-13', 'postgres', 'INSERT', 3304928);
INSERT INTO "ProdNac2021".logbd VALUES (230, '2021-04-13', 'postgres', 'INSERT', 3304831);
INSERT INTO "ProdNac2021".logbd VALUES (231, '2021-04-13', 'postgres', 'INSERT', 3300703);
INSERT INTO "ProdNac2021".logbd VALUES (232, '2021-04-13', 'postgres', 'INSERT', 3300501);
INSERT INTO "ProdNac2021".logbd VALUES (233, '2021-04-13', 'postgres', 'INSERT', 3304654);
INSERT INTO "ProdNac2021".logbd VALUES (234, '2021-04-13', 'postgres', 'INSERT', 3300948);
INSERT INTO "ProdNac2021".logbd VALUES (235, '2021-04-13', 'postgres', 'INSERT', 3300973);
INSERT INTO "ProdNac2021".logbd VALUES (236, '2021-04-13', 'postgres', 'INSERT', 3300034);
INSERT INTO "ProdNac2021".logbd VALUES (237, '2021-04-13', 'postgres', 'INSERT', 3300502);
INSERT INTO "ProdNac2021".logbd VALUES (238, '2021-04-13', 'postgres', 'INSERT', 3301012);
INSERT INTO "ProdNac2021".logbd VALUES (239, '2021-04-13', 'postgres', 'INSERT', 3300478);
INSERT INTO "ProdNac2021".logbd VALUES (240, '2021-04-13', 'postgres', 'INSERT', 3300369);
INSERT INTO "ProdNac2021".logbd VALUES (241, '2021-04-13', 'postgres', 'INSERT', 3300278);
INSERT INTO "ProdNac2021".logbd VALUES (242, '2021-04-13', 'postgres', 'INSERT', 3304825);
INSERT INTO "ProdNac2021".logbd VALUES (243, '2021-04-13', 'postgres', 'INSERT', 3300223);
INSERT INTO "ProdNac2021".logbd VALUES (244, '2021-04-13', 'postgres', 'INSERT', 3304468);
INSERT INTO "ProdNac2021".logbd VALUES (245, '2021-04-13', 'postgres', 'INSERT', 3304435);
INSERT INTO "ProdNac2021".logbd VALUES (246, '2021-04-13', 'postgres', 'INSERT', 3300917);
INSERT INTO "ProdNac2021".logbd VALUES (247, '2021-04-13', 'postgres', 'INSERT', 3304371);
INSERT INTO "ProdNac2021".logbd VALUES (248, '2021-04-13', 'postgres', 'INSERT', 3300608);
INSERT INTO "ProdNac2021".logbd VALUES (249, '2021-04-13', 'postgres', 'INSERT', 3304511);
INSERT INTO "ProdNac2021".logbd VALUES (250, '2021-04-13', 'postgres', 'INSERT', 3304915);
INSERT INTO "ProdNac2021".logbd VALUES (251, '2021-04-13', 'postgres', 'INSERT', 3304691);
INSERT INTO "ProdNac2021".logbd VALUES (252, '2021-04-13', 'postgres', 'INSERT', 3300506);
INSERT INTO "ProdNac2021".logbd VALUES (253, '2021-04-13', 'postgres', 'INSERT', 3300417);
INSERT INTO "ProdNac2021".logbd VALUES (254, '2021-04-13', 'postgres', 'INSERT', 3304956);
INSERT INTO "ProdNac2021".logbd VALUES (255, '2021-04-13', 'postgres', 'INSERT', 3304335);
INSERT INTO "ProdNac2021".logbd VALUES (256, '2021-04-13', 'postgres', 'INSERT', 3300684);
INSERT INTO "ProdNac2021".logbd VALUES (257, '2021-04-13', 'postgres', 'INSERT', 3300194);
INSERT INTO "ProdNac2021".logbd VALUES (258, '2021-04-13', 'postgres', 'INSERT', 3301181);
INSERT INTO "ProdNac2021".logbd VALUES (259, '2021-04-13', 'postgres', 'INSERT', 3300853);
INSERT INTO "ProdNac2021".logbd VALUES (260, '2021-04-13', 'postgres', 'INSERT', 3304760);
INSERT INTO "ProdNac2021".logbd VALUES (261, '2021-04-13', 'postgres', 'INSERT', 3304347);
INSERT INTO "ProdNac2021".logbd VALUES (262, '2021-04-13', 'postgres', 'INSERT', 3300198);
INSERT INTO "ProdNac2021".logbd VALUES (263, '2021-04-13', 'postgres', 'INSERT', 3300887);
INSERT INTO "ProdNac2021".logbd VALUES (264, '2021-04-13', 'postgres', 'INSERT', 3301145);
INSERT INTO "ProdNac2021".logbd VALUES (265, '2021-04-13', 'postgres', 'INSERT', 3304599);
INSERT INTO "ProdNac2021".logbd VALUES (266, '2021-04-13', 'postgres', 'INSERT', 3304742);
INSERT INTO "ProdNac2021".logbd VALUES (267, '2021-04-13', 'postgres', 'INSERT', 3300861);
INSERT INTO "ProdNac2021".logbd VALUES (268, '2021-04-13', 'postgres', 'INSERT', 3300866);
INSERT INTO "ProdNac2021".logbd VALUES (269, '2021-04-13', 'postgres', 'INSERT', 3304733);
INSERT INTO "ProdNac2021".logbd VALUES (270, '2021-04-13', 'postgres', 'INSERT', 3301204);
INSERT INTO "ProdNac2021".logbd VALUES (271, '2021-04-13', 'postgres', 'INSERT', 3304402);
INSERT INTO "ProdNac2021".logbd VALUES (272, '2021-04-13', 'postgres', 'INSERT', 3304490);
INSERT INTO "ProdNac2021".logbd VALUES (273, '2021-04-13', 'postgres', 'INSERT', 3300210);
INSERT INTO "ProdNac2021".logbd VALUES (274, '2021-04-13', 'postgres', 'INSERT', 3304579);
INSERT INTO "ProdNac2021".logbd VALUES (275, '2021-04-13', 'postgres', 'INSERT', 3300140);
INSERT INTO "ProdNac2021".logbd VALUES (276, '2021-04-13', 'postgres', 'INSERT', 3301159);
INSERT INTO "ProdNac2021".logbd VALUES (277, '2021-04-13', 'postgres', 'INSERT', 3301000);
INSERT INTO "ProdNac2021".logbd VALUES (278, '2021-04-13', 'postgres', 'INSERT', 3304996);
INSERT INTO "ProdNac2021".logbd VALUES (279, '2021-04-13', 'postgres', 'INSERT', 3304393);
INSERT INTO "ProdNac2021".logbd VALUES (280, '2021-04-13', 'postgres', 'INSERT', 3300552);
INSERT INTO "ProdNac2021".logbd VALUES (281, '2021-04-13', 'postgres', 'INSERT', 3300331);
INSERT INTO "ProdNac2021".logbd VALUES (282, '2021-04-13', 'postgres', 'INSERT', 3300912);
INSERT INTO "ProdNac2021".logbd VALUES (283, '2021-04-13', 'postgres', 'INSERT', 3300212);
INSERT INTO "ProdNac2021".logbd VALUES (284, '2021-04-13', 'postgres', 'INSERT', 3304424);
INSERT INTO "ProdNac2021".logbd VALUES (285, '2021-04-13', 'postgres', 'INSERT', 3304433);
INSERT INTO "ProdNac2021".logbd VALUES (286, '2021-04-13', 'postgres', 'INSERT', 3304833);
INSERT INTO "ProdNac2021".logbd VALUES (287, '2021-04-13', 'postgres', 'INSERT', 3304916);
INSERT INTO "ProdNac2021".logbd VALUES (288, '2021-04-13', 'postgres', 'INSERT', 3300220);
INSERT INTO "ProdNac2021".logbd VALUES (289, '2021-04-13', 'postgres', 'INSERT', 3300505);
INSERT INTO "ProdNac2021".logbd VALUES (290, '2021-04-13', 'postgres', 'INSERT', 3300240);
INSERT INTO "ProdNac2021".logbd VALUES (291, '2021-04-13', 'postgres', 'INSERT', 3300191);
INSERT INTO "ProdNac2021".logbd VALUES (292, '2021-04-13', 'postgres', 'INSERT', 3304875);
INSERT INTO "ProdNac2021".logbd VALUES (293, '2021-04-13', 'postgres', 'INSERT', 3300909);
INSERT INTO "ProdNac2021".logbd VALUES (294, '2021-04-13', 'postgres', 'INSERT', 3301166);
INSERT INTO "ProdNac2021".logbd VALUES (295, '2021-04-13', 'postgres', 'INSERT', 3300940);
INSERT INTO "ProdNac2021".logbd VALUES (296, '2021-04-13', 'postgres', 'INSERT', 3304437);
INSERT INTO "ProdNac2021".logbd VALUES (297, '2021-04-13', 'postgres', 'INSERT', 3300073);
INSERT INTO "ProdNac2021".logbd VALUES (298, '2021-04-13', 'postgres', 'INSERT', 3304417);
INSERT INTO "ProdNac2021".logbd VALUES (299, '2021-04-13', 'postgres', 'INSERT', 3304438);
INSERT INTO "ProdNac2021".logbd VALUES (300, '2021-04-13', 'postgres', 'INSERT', 3304389);
INSERT INTO "ProdNac2021".logbd VALUES (301, '2021-04-13', 'postgres', 'INSERT', 3304520);
INSERT INTO "ProdNac2021".logbd VALUES (302, '2021-04-13', 'postgres', 'INSERT', 3300164);
INSERT INTO "ProdNac2021".logbd VALUES (303, '2021-04-13', 'postgres', 'INSERT', 3301199);
INSERT INTO "ProdNac2021".logbd VALUES (304, '2021-04-13', 'postgres', 'INSERT', 3304439);
INSERT INTO "ProdNac2021".logbd VALUES (305, '2021-04-13', 'postgres', 'INSERT', 3300828);
INSERT INTO "ProdNac2021".logbd VALUES (306, '2021-04-13', 'postgres', 'INSERT', 3304685);
INSERT INTO "ProdNac2021".logbd VALUES (307, '2021-04-13', 'postgres', 'INSERT', 3300144);
INSERT INTO "ProdNac2021".logbd VALUES (308, '2021-04-13', 'postgres', 'INSERT', 3304600);
INSERT INTO "ProdNac2021".logbd VALUES (309, '2021-04-13', 'postgres', 'INSERT', 3304609);
INSERT INTO "ProdNac2021".logbd VALUES (310, '2021-04-13', 'postgres', 'INSERT', 3304997);
INSERT INTO "ProdNac2021".logbd VALUES (311, '2021-04-13', 'postgres', 'INSERT', 3304729);
INSERT INTO "ProdNac2021".logbd VALUES (312, '2021-04-13', 'postgres', 'INSERT', 3300302);
INSERT INTO "ProdNac2021".logbd VALUES (313, '2021-04-13', 'postgres', 'INSERT', 3300638);
INSERT INTO "ProdNac2021".logbd VALUES (314, '2021-04-13', 'postgres', 'INSERT', 3304731);
INSERT INTO "ProdNac2021".logbd VALUES (315, '2021-04-13', 'postgres', 'INSERT', 3300341);
INSERT INTO "ProdNac2021".logbd VALUES (316, '2021-04-13', 'postgres', 'INSERT', 3300173);
INSERT INTO "ProdNac2021".logbd VALUES (317, '2021-04-13', 'postgres', 'INSERT', 3300419);
INSERT INTO "ProdNac2021".logbd VALUES (318, '2021-04-13', 'postgres', 'INSERT', 3300922);
INSERT INTO "ProdNac2021".logbd VALUES (319, '2021-04-13', 'postgres', 'INSERT', 3301215);
INSERT INTO "ProdNac2021".logbd VALUES (320, '2021-04-13', 'postgres', 'INSERT', 3304483);
INSERT INTO "ProdNac2021".logbd VALUES (321, '2021-04-13', 'postgres', 'INSERT', 3304957);
INSERT INTO "ProdNac2021".logbd VALUES (322, '2021-04-13', 'postgres', 'INSERT', 3300148);
INSERT INTO "ProdNac2021".logbd VALUES (323, '2021-04-13', 'postgres', 'INSERT', 3304333);
INSERT INTO "ProdNac2021".logbd VALUES (324, '2021-04-13', 'postgres', 'INSERT', 3304489);
INSERT INTO "ProdNac2021".logbd VALUES (325, '2021-04-13', 'postgres', 'INSERT', 3300337);
INSERT INTO "ProdNac2021".logbd VALUES (326, '2021-04-13', 'postgres', 'INSERT', 3304835);
INSERT INTO "ProdNac2021".logbd VALUES (327, '2021-04-13', 'postgres', 'INSERT', 3300706);
INSERT INTO "ProdNac2021".logbd VALUES (328, '2021-04-13', 'postgres', 'INSERT', 3304496);
INSERT INTO "ProdNac2021".logbd VALUES (329, '2021-04-13', 'postgres', 'INSERT', 3304565);
INSERT INTO "ProdNac2021".logbd VALUES (330, '2021-04-13', 'postgres', 'INSERT', 3304911);
INSERT INTO "ProdNac2021".logbd VALUES (331, '2021-04-13', 'postgres', 'INSERT', 3301053);
INSERT INTO "ProdNac2021".logbd VALUES (332, '2021-04-13', 'postgres', 'INSERT', 3301080);
INSERT INTO "ProdNac2021".logbd VALUES (333, '2021-04-13', 'postgres', 'INSERT', 3300743);
INSERT INTO "ProdNac2021".logbd VALUES (334, '2021-04-13', 'postgres', 'INSERT', 3300895);
INSERT INTO "ProdNac2021".logbd VALUES (335, '2021-04-13', 'postgres', 'INSERT', 3304793);
INSERT INTO "ProdNac2021".logbd VALUES (336, '2021-04-13', 'postgres', 'INSERT', 3304838);
INSERT INTO "ProdNac2021".logbd VALUES (337, '2021-04-13', 'postgres', 'INSERT', 3300928);
INSERT INTO "ProdNac2021".logbd VALUES (338, '2021-04-13', 'postgres', 'INSERT', 3300476);
INSERT INTO "ProdNac2021".logbd VALUES (339, '2021-04-13', 'postgres', 'INSERT', 3304482);
INSERT INTO "ProdNac2021".logbd VALUES (340, '2021-04-13', 'postgres', 'INSERT', 3300114);
INSERT INTO "ProdNac2021".logbd VALUES (341, '2021-04-13', 'postgres', 'INSERT', 3304964);
INSERT INTO "ProdNac2021".logbd VALUES (342, '2021-04-13', 'postgres', 'INSERT', 3300045);
INSERT INTO "ProdNac2021".logbd VALUES (343, '2021-04-13', 'postgres', 'INSERT', 3304436);
INSERT INTO "ProdNac2021".logbd VALUES (344, '2021-04-13', 'postgres', 'INSERT', 3300585);
INSERT INTO "ProdNac2021".logbd VALUES (345, '2021-04-13', 'postgres', 'INSERT', 3300484);
INSERT INTO "ProdNac2021".logbd VALUES (346, '2021-04-13', 'postgres', 'INSERT', 3304776);
INSERT INTO "ProdNac2021".logbd VALUES (347, '2021-04-13', 'postgres', 'INSERT', 3300205);
INSERT INTO "ProdNac2021".logbd VALUES (348, '2021-04-13', 'postgres', 'INSERT', 3300957);
INSERT INTO "ProdNac2021".logbd VALUES (349, '2021-04-13', 'postgres', 'INSERT', 3300260);
INSERT INTO "ProdNac2021".logbd VALUES (350, '2021-04-13', 'postgres', 'INSERT', 3300632);
INSERT INTO "ProdNac2021".logbd VALUES (351, '2021-04-13', 'postgres', 'INSERT', 3300701);
INSERT INTO "ProdNac2021".logbd VALUES (352, '2021-04-13', 'postgres', 'INSERT', 3304995);
INSERT INTO "ProdNac2021".logbd VALUES (353, '2021-04-13', 'postgres', 'INSERT', 3300440);
INSERT INTO "ProdNac2021".logbd VALUES (354, '2021-04-13', 'postgres', 'INSERT', 3300956);
INSERT INTO "ProdNac2021".logbd VALUES (355, '2021-04-13', 'postgres', 'INSERT', 3304889);
INSERT INTO "ProdNac2021".logbd VALUES (356, '2021-04-13', 'postgres', 'INSERT', 3300716);
INSERT INTO "ProdNac2021".logbd VALUES (357, '2021-04-13', 'postgres', 'INSERT', 3300311);
INSERT INTO "ProdNac2021".logbd VALUES (358, '2021-04-13', 'postgres', 'INSERT', 3304741);
INSERT INTO "ProdNac2021".logbd VALUES (359, '2021-04-13', 'postgres', 'INSERT', 3300382);
INSERT INTO "ProdNac2021".logbd VALUES (360, '2021-04-13', 'postgres', 'INSERT', 3301172);
INSERT INTO "ProdNac2021".logbd VALUES (361, '2021-04-13', 'postgres', 'INSERT', 3304944);
INSERT INTO "ProdNac2021".logbd VALUES (362, '2021-04-13', 'postgres', 'INSERT', 3300204);
INSERT INTO "ProdNac2021".logbd VALUES (363, '2021-04-13', 'postgres', 'INSERT', 3300766);
INSERT INTO "ProdNac2021".logbd VALUES (364, '2021-04-13', 'postgres', 'INSERT', 3301098);
INSERT INTO "ProdNac2021".logbd VALUES (365, '2021-04-13', 'postgres', 'INSERT', 3300526);
INSERT INTO "ProdNac2021".logbd VALUES (366, '2021-04-13', 'postgres', 'INSERT', 3300958);
INSERT INTO "ProdNac2021".logbd VALUES (367, '2021-04-13', 'postgres', 'INSERT', 3301128);
INSERT INTO "ProdNac2021".logbd VALUES (368, '2021-04-13', 'postgres', 'INSERT', 3304647);
INSERT INTO "ProdNac2021".logbd VALUES (369, '2021-04-13', 'postgres', 'INSERT', 3304663);
INSERT INTO "ProdNac2021".logbd VALUES (370, '2021-04-13', 'postgres', 'INSERT', 3304567);
INSERT INTO "ProdNac2021".logbd VALUES (371, '2021-04-13', 'postgres', 'INSERT', 3300482);
INSERT INTO "ProdNac2021".logbd VALUES (372, '2021-04-13', 'postgres', 'INSERT', 3304740);
INSERT INTO "ProdNac2021".logbd VALUES (373, '2021-04-13', 'postgres', 'INSERT', 3300567);
INSERT INTO "ProdNac2021".logbd VALUES (374, '2021-04-13', 'postgres', 'INSERT', 3304761);
INSERT INTO "ProdNac2021".logbd VALUES (375, '2021-04-13', 'postgres', 'INSERT', 3300878);
INSERT INTO "ProdNac2021".logbd VALUES (376, '2021-04-13', 'postgres', 'INSERT', 3300143);
INSERT INTO "ProdNac2021".logbd VALUES (377, '2021-04-13', 'postgres', 'INSERT', 3301214);
INSERT INTO "ProdNac2021".logbd VALUES (378, '2021-04-13', 'postgres', 'INSERT', 3304392);
INSERT INTO "ProdNac2021".logbd VALUES (379, '2021-04-13', 'postgres', 'INSERT', 3300459);
INSERT INTO "ProdNac2021".logbd VALUES (380, '2021-04-13', 'postgres', 'INSERT', 3300929);
INSERT INTO "ProdNac2021".logbd VALUES (381, '2021-04-13', 'postgres', 'INSERT', 3300996);
INSERT INTO "ProdNac2021".logbd VALUES (382, '2021-04-13', 'postgres', 'INSERT', 3304408);
INSERT INTO "ProdNac2021".logbd VALUES (383, '2021-04-13', 'postgres', 'INSERT', 3300664);
INSERT INTO "ProdNac2021".logbd VALUES (384, '2021-04-13', 'postgres', 'INSERT', 3300460);
INSERT INTO "ProdNac2021".logbd VALUES (385, '2021-04-13', 'postgres', 'INSERT', 3304488);
INSERT INTO "ProdNac2021".logbd VALUES (386, '2021-04-13', 'postgres', 'INSERT', 3304746);
INSERT INTO "ProdNac2021".logbd VALUES (387, '2021-04-13', 'postgres', 'INSERT', 3304523);
INSERT INTO "ProdNac2021".logbd VALUES (388, '2021-04-13', 'postgres', 'INSERT', 3300023);
INSERT INTO "ProdNac2021".logbd VALUES (389, '2021-04-13', 'postgres', 'INSERT', 3300154);
INSERT INTO "ProdNac2021".logbd VALUES (390, '2021-04-13', 'postgres', 'INSERT', 3300004);
INSERT INTO "ProdNac2021".logbd VALUES (391, '2021-04-13', 'postgres', 'INSERT', 3300481);
INSERT INTO "ProdNac2021".logbd VALUES (392, '2021-04-13', 'postgres', 'INSERT', 3300937);
INSERT INTO "ProdNac2021".logbd VALUES (393, '2021-04-13', 'postgres', 'INSERT', 3301225);
INSERT INTO "ProdNac2021".logbd VALUES (394, '2021-04-13', 'postgres', 'INSERT', 3300388);
INSERT INTO "ProdNac2021".logbd VALUES (395, '2021-04-13', 'postgres', 'INSERT', 3301216);
INSERT INTO "ProdNac2021".logbd VALUES (396, '2021-04-13', 'postgres', 'INSERT', 3304515);
INSERT INTO "ProdNac2021".logbd VALUES (397, '2021-04-13', 'postgres', 'INSERT', 3300670);
INSERT INTO "ProdNac2021".logbd VALUES (398, '2021-04-13', 'postgres', 'INSERT', 3304386);
INSERT INTO "ProdNac2021".logbd VALUES (399, '2021-04-13', 'postgres', 'INSERT', 3301011);
INSERT INTO "ProdNac2021".logbd VALUES (400, '2021-04-13', 'postgres', 'INSERT', 3300697);
INSERT INTO "ProdNac2021".logbd VALUES (401, '2021-04-13', 'postgres', 'INSERT', 3304703);
INSERT INTO "ProdNac2021".logbd VALUES (402, '2021-04-13', 'postgres', 'INSERT', 3300479);
INSERT INTO "ProdNac2021".logbd VALUES (403, '2021-04-13', 'postgres', 'INSERT', 3301155);
INSERT INTO "ProdNac2021".logbd VALUES (404, '2021-04-13', 'postgres', 'INSERT', 3300768);
INSERT INTO "ProdNac2021".logbd VALUES (405, '2021-04-13', 'postgres', 'INSERT', 3300062);
INSERT INTO "ProdNac2021".logbd VALUES (406, '2021-04-13', 'postgres', 'INSERT', 3304887);
INSERT INTO "ProdNac2021".logbd VALUES (407, '2021-04-13', 'postgres', 'INSERT', 3301919);
INSERT INTO "ProdNac2021".logbd VALUES (408, '2021-04-13', 'postgres', 'INSERT', 3300199);
INSERT INTO "ProdNac2021".logbd VALUES (409, '2021-04-13', 'postgres', 'INSERT', 3300049);
INSERT INTO "ProdNac2021".logbd VALUES (410, '2021-04-13', 'postgres', 'INSERT', 3300358);
INSERT INTO "ProdNac2021".logbd VALUES (411, '2021-04-13', 'postgres', 'INSERT', 3304643);
INSERT INTO "ProdNac2021".logbd VALUES (412, '2021-04-13', 'postgres', 'INSERT', 3300970);
INSERT INTO "ProdNac2021".logbd VALUES (413, '2021-04-13', 'postgres', 'INSERT', 3304534);
INSERT INTO "ProdNac2021".logbd VALUES (414, '2021-04-13', 'postgres', 'INSERT', 3300112);
INSERT INTO "ProdNac2021".logbd VALUES (415, '2021-04-13', 'postgres', 'INSERT', 3300792);
INSERT INTO "ProdNac2021".logbd VALUES (416, '2021-04-13', 'postgres', 'INSERT', 3300873);
INSERT INTO "ProdNac2021".logbd VALUES (417, '2021-04-13', 'postgres', 'INSERT', 3301161);
INSERT INTO "ProdNac2021".logbd VALUES (418, '2021-04-13', 'postgres', 'INSERT', 3300945);
INSERT INTO "ProdNac2021".logbd VALUES (419, '2021-04-13', 'postgres', 'INSERT', 3300520);
INSERT INTO "ProdNac2021".logbd VALUES (420, '2021-04-13', 'postgres', 'INSERT', 3304753);
INSERT INTO "ProdNac2021".logbd VALUES (421, '2021-04-13', 'postgres', 'INSERT', 3304912);
INSERT INTO "ProdNac2021".logbd VALUES (422, '2021-04-13', 'postgres', 'INSERT', 3300869);
INSERT INTO "ProdNac2021".logbd VALUES (423, '2021-04-13', 'postgres', 'INSERT', 3304670);
INSERT INTO "ProdNac2021".logbd VALUES (424, '2021-04-13', 'postgres', 'INSERT', 3300013);
INSERT INTO "ProdNac2021".logbd VALUES (425, '2021-04-13', 'postgres', 'INSERT', 3301167);
INSERT INTO "ProdNac2021".logbd VALUES (426, '2021-04-13', 'postgres', 'INSERT', 3300100);
INSERT INTO "ProdNac2021".logbd VALUES (427, '2021-04-13', 'postgres', 'INSERT', 3300704);
INSERT INTO "ProdNac2021".logbd VALUES (428, '2021-04-13', 'postgres', 'INSERT', 3304736);
INSERT INTO "ProdNac2021".logbd VALUES (429, '2021-04-13', 'postgres', 'INSERT', 3304808);
INSERT INTO "ProdNac2021".logbd VALUES (430, '2021-04-13', 'postgres', 'INSERT', 3301812);
INSERT INTO "ProdNac2021".logbd VALUES (431, '2021-04-13', 'postgres', 'INSERT', 3304566);
INSERT INTO "ProdNac2021".logbd VALUES (432, '2021-04-13', 'postgres', 'INSERT', 3304653);
INSERT INTO "ProdNac2021".logbd VALUES (433, '2021-04-13', 'postgres', 'INSERT', 3300319);
INSERT INTO "ProdNac2021".logbd VALUES (434, '2021-04-13', 'postgres', 'INSERT', 3300351);
INSERT INTO "ProdNac2021".logbd VALUES (435, '2021-04-13', 'postgres', 'INSERT', 3300322);
INSERT INTO "ProdNac2021".logbd VALUES (436, '2021-04-13', 'postgres', 'INSERT', 3300749);
INSERT INTO "ProdNac2021".logbd VALUES (437, '2021-04-13', 'postgres', 'INSERT', 3300258);
INSERT INTO "ProdNac2021".logbd VALUES (438, '2021-04-13', 'postgres', 'INSERT', 3300788);
INSERT INTO "ProdNac2021".logbd VALUES (439, '2021-04-13', 'postgres', 'INSERT', 3304723);
INSERT INTO "ProdNac2021".logbd VALUES (440, '2021-04-13', 'postgres', 'INSERT', 3300654);
INSERT INTO "ProdNac2021".logbd VALUES (441, '2021-04-13', 'postgres', 'INSERT', 3300435);
INSERT INTO "ProdNac2021".logbd VALUES (442, '2021-04-13', 'postgres', 'INSERT', 3300914);
INSERT INTO "ProdNac2021".logbd VALUES (443, '2021-04-13', 'postgres', 'INSERT', 3300101);
INSERT INTO "ProdNac2021".logbd VALUES (444, '2021-04-13', 'postgres', 'INSERT', 3300280);
INSERT INTO "ProdNac2021".logbd VALUES (445, '2021-04-13', 'postgres', 'INSERT', 3300790);
INSERT INTO "ProdNac2021".logbd VALUES (446, '2021-04-13', 'postgres', 'INSERT', 3300745);
INSERT INTO "ProdNac2021".logbd VALUES (447, '2021-04-13', 'postgres', 'INSERT', 3300244);
INSERT INTO "ProdNac2021".logbd VALUES (448, '2021-04-13', 'postgres', 'INSERT', 3300565);
INSERT INTO "ProdNac2021".logbd VALUES (449, '2021-04-13', 'postgres', 'INSERT', 3300803);
INSERT INTO "ProdNac2021".logbd VALUES (450, '2021-04-13', 'postgres', 'INSERT', 3300652);
INSERT INTO "ProdNac2021".logbd VALUES (451, '2021-04-13', 'postgres', 'INSERT', 3304563);
INSERT INTO "ProdNac2021".logbd VALUES (452, '2021-04-13', 'postgres', 'INSERT', 3304677);
INSERT INTO "ProdNac2021".logbd VALUES (453, '2021-04-13', 'postgres', 'INSERT', 3304822);
INSERT INTO "ProdNac2021".logbd VALUES (454, '2021-04-13', 'postgres', 'INSERT', 3301006);
INSERT INTO "ProdNac2021".logbd VALUES (455, '2021-04-13', 'postgres', 'INSERT', 3304954);
INSERT INTO "ProdNac2021".logbd VALUES (456, '2021-04-13', 'postgres', 'INSERT', 3300165);
INSERT INTO "ProdNac2021".logbd VALUES (457, '2021-04-13', 'postgres', 'INSERT', 3301018);
INSERT INTO "ProdNac2021".logbd VALUES (458, '2021-04-13', 'postgres', 'INSERT', 3301104);
INSERT INTO "ProdNac2021".logbd VALUES (459, '2021-04-13', 'postgres', 'INSERT', 3300439);
INSERT INTO "ProdNac2021".logbd VALUES (460, '2021-04-13', 'postgres', 'INSERT', 3304447);
INSERT INTO "ProdNac2021".logbd VALUES (461, '2021-04-13', 'postgres', 'INSERT', 3304694);
INSERT INTO "ProdNac2021".logbd VALUES (462, '2021-04-13', 'postgres', 'INSERT', 3301099);
INSERT INTO "ProdNac2021".logbd VALUES (463, '2021-04-13', 'postgres', 'INSERT', 3301212);
INSERT INTO "ProdNac2021".logbd VALUES (464, '2021-04-13', 'postgres', 'INSERT', 3304704);
INSERT INTO "ProdNac2021".logbd VALUES (465, '2021-04-13', 'postgres', 'INSERT', 3300665);
INSERT INTO "ProdNac2021".logbd VALUES (466, '2021-04-13', 'postgres', 'INSERT', 3304769);
INSERT INTO "ProdNac2021".logbd VALUES (467, '2021-04-13', 'postgres', 'INSERT', 3300455);
INSERT INTO "ProdNac2021".logbd VALUES (468, '2021-04-13', 'postgres', 'INSERT', 3304813);
INSERT INTO "ProdNac2021".logbd VALUES (469, '2021-04-13', 'postgres', 'INSERT', 3301851);
INSERT INTO "ProdNac2021".logbd VALUES (470, '2021-04-13', 'postgres', 'INSERT', 3300044);
INSERT INTO "ProdNac2021".logbd VALUES (471, '2021-04-13', 'postgres', 'INSERT', 3300413);
INSERT INTO "ProdNac2021".logbd VALUES (472, '2021-04-13', 'postgres', 'INSERT', 3304512);
INSERT INTO "ProdNac2021".logbd VALUES (473, '2021-04-13', 'postgres', 'INSERT', 3304680);
INSERT INTO "ProdNac2021".logbd VALUES (474, '2021-04-13', 'postgres', 'INSERT', 3300048);
INSERT INTO "ProdNac2021".logbd VALUES (475, '2021-04-13', 'postgres', 'INSERT', 3300054);
INSERT INTO "ProdNac2021".logbd VALUES (476, '2021-04-13', 'postgres', 'INSERT', 3301217);
INSERT INTO "ProdNac2021".logbd VALUES (477, '2021-04-13', 'postgres', 'INSERT', 3300762);
INSERT INTO "ProdNac2021".logbd VALUES (478, '2021-04-13', 'postgres', 'INSERT', 3304738);
INSERT INTO "ProdNac2021".logbd VALUES (479, '2021-04-13', 'postgres', 'INSERT', 3300651);
INSERT INTO "ProdNac2021".logbd VALUES (480, '2021-04-13', 'postgres', 'INSERT', 3300097);
INSERT INTO "ProdNac2021".logbd VALUES (481, '2021-04-13', 'postgres', 'INSERT', 3301094);
INSERT INTO "ProdNac2021".logbd VALUES (482, '2021-04-13', 'postgres', 'INSERT', 3300566);
INSERT INTO "ProdNac2021".logbd VALUES (483, '2021-04-13', 'postgres', 'INSERT', 3300071);
INSERT INTO "ProdNac2021".logbd VALUES (484, '2021-04-13', 'postgres', 'INSERT', 3300424);
INSERT INTO "ProdNac2021".logbd VALUES (485, '2021-04-13', 'postgres', 'INSERT', 3304958);
INSERT INTO "ProdNac2021".logbd VALUES (486, '2021-04-13', 'postgres', 'INSERT', 3300688);
INSERT INTO "ProdNac2021".logbd VALUES (487, '2021-04-13', 'postgres', 'INSERT', 3304730);
INSERT INTO "ProdNac2021".logbd VALUES (488, '2021-04-13', 'postgres', 'INSERT', 3300935);
INSERT INTO "ProdNac2021".logbd VALUES (489, '2021-04-13', 'postgres', 'INSERT', 3300783);
INSERT INTO "ProdNac2021".logbd VALUES (490, '2021-04-13', 'postgres', 'INSERT', 3301076);
INSERT INTO "ProdNac2021".logbd VALUES (491, '2021-04-13', 'postgres', 'INSERT', 3300441);
INSERT INTO "ProdNac2021".logbd VALUES (492, '2021-04-13', 'postgres', 'INSERT', 3304878);
INSERT INTO "ProdNac2021".logbd VALUES (493, '2021-04-13', 'postgres', 'INSERT', 3300879);
INSERT INTO "ProdNac2021".logbd VALUES (494, '2021-04-13', 'postgres', 'INSERT', 3300356);
INSERT INTO "ProdNac2021".logbd VALUES (495, '2021-04-13', 'postgres', 'INSERT', 3304683);
INSERT INTO "ProdNac2021".logbd VALUES (496, '2021-04-13', 'postgres', 'INSERT', 3304814);
INSERT INTO "ProdNac2021".logbd VALUES (497, '2021-04-13', 'postgres', 'INSERT', 3301143);
INSERT INTO "ProdNac2021".logbd VALUES (498, '2021-04-13', 'postgres', 'INSERT', 3300602);
INSERT INTO "ProdNac2021".logbd VALUES (499, '2021-04-13', 'postgres', 'INSERT', 3300961);
INSERT INTO "ProdNac2021".logbd VALUES (500, '2021-04-13', 'postgres', 'INSERT', 3300237);
INSERT INTO "ProdNac2021".logbd VALUES (501, '2021-04-13', 'postgres', 'INSERT', 3300719);
INSERT INTO "ProdNac2021".logbd VALUES (502, '2021-04-13', 'postgres', 'INSERT', 3304463);
INSERT INTO "ProdNac2021".logbd VALUES (503, '2021-04-13', 'postgres', 'INSERT', 3304747);
INSERT INTO "ProdNac2021".logbd VALUES (504, '2021-04-13', 'postgres', 'INSERT', 3304891);
INSERT INTO "ProdNac2021".logbd VALUES (505, '2021-04-13', 'postgres', 'INSERT', 3300717);
INSERT INTO "ProdNac2021".logbd VALUES (506, '2021-04-13', 'postgres', 'INSERT', 3300831);
INSERT INTO "ProdNac2021".logbd VALUES (507, '2021-04-13', 'postgres', 'INSERT', 3301084);
INSERT INTO "ProdNac2021".logbd VALUES (508, '2021-04-13', 'postgres', 'INSERT', 3301059);
INSERT INTO "ProdNac2021".logbd VALUES (509, '2021-04-13', 'postgres', 'INSERT', 3300206);
INSERT INTO "ProdNac2021".logbd VALUES (510, '2021-04-13', 'postgres', 'INSERT', 3304593);
INSERT INTO "ProdNac2021".logbd VALUES (511, '2021-04-13', 'postgres', 'INSERT', 3304882);
INSERT INTO "ProdNac2021".logbd VALUES (512, '2021-04-13', 'postgres', 'INSERT', 3304962);
INSERT INTO "ProdNac2021".logbd VALUES (513, '2021-04-13', 'postgres', 'INSERT', 3300243);
INSERT INTO "ProdNac2021".logbd VALUES (514, '2021-04-13', 'postgres', 'INSERT', 3301031);
INSERT INTO "ProdNac2021".logbd VALUES (515, '2021-04-13', 'postgres', 'INSERT', 3304767);
INSERT INTO "ProdNac2021".logbd VALUES (516, '2021-04-13', 'postgres', 'INSERT', 3304994);
INSERT INTO "ProdNac2021".logbd VALUES (517, '2021-04-13', 'postgres', 'INSERT', 3301107);
INSERT INTO "ProdNac2021".logbd VALUES (518, '2021-04-13', 'postgres', 'INSERT', 3304510);
INSERT INTO "ProdNac2021".logbd VALUES (519, '2021-04-13', 'postgres', 'INSERT', 3300847);
INSERT INTO "ProdNac2021".logbd VALUES (520, '2021-04-13', 'postgres', 'INSERT', 3300389);
INSERT INTO "ProdNac2021".logbd VALUES (521, '2021-04-13', 'postgres', 'INSERT', 3300695);
INSERT INTO "ProdNac2021".logbd VALUES (522, '2021-04-13', 'postgres', 'INSERT', 3304978);
INSERT INTO "ProdNac2021".logbd VALUES (523, '2021-04-13', 'postgres', 'INSERT', 3300442);
INSERT INTO "ProdNac2021".logbd VALUES (524, '2021-04-13', 'postgres', 'INSERT', 3300596);
INSERT INTO "ProdNac2021".logbd VALUES (525, '2021-04-13', 'postgres', 'INSERT', 3304412);
INSERT INTO "ProdNac2021".logbd VALUES (526, '2021-04-13', 'postgres', 'INSERT', 3304529);
INSERT INTO "ProdNac2021".logbd VALUES (527, '2021-04-13', 'postgres', 'INSERT', 3300036);
INSERT INTO "ProdNac2021".logbd VALUES (528, '2021-04-13', 'postgres', 'INSERT', 3301986);
INSERT INTO "ProdNac2021".logbd VALUES (529, '2021-04-13', 'postgres', 'INSERT', 3304458);
INSERT INTO "ProdNac2021".logbd VALUES (530, '2021-04-13', 'postgres', 'INSERT', 3301175);
INSERT INTO "ProdNac2021".logbd VALUES (531, '2021-04-13', 'postgres', 'INSERT', 3301171);
INSERT INTO "ProdNac2021".logbd VALUES (532, '2021-04-13', 'postgres', 'INSERT', 3304536);
INSERT INTO "ProdNac2021".logbd VALUES (533, '2021-04-13', 'postgres', 'INSERT', 3300136);
INSERT INTO "ProdNac2021".logbd VALUES (534, '2021-04-13', 'postgres', 'INSERT', 3304465);
INSERT INTO "ProdNac2021".logbd VALUES (535, '2021-04-13', 'postgres', 'INSERT', 3304834);
INSERT INTO "ProdNac2021".logbd VALUES (536, '2021-04-13', 'postgres', 'INSERT', 3300134);
INSERT INTO "ProdNac2021".logbd VALUES (537, '2021-04-13', 'postgres', 'INSERT', 3300030);
INSERT INTO "ProdNac2021".logbd VALUES (538, '2021-04-13', 'postgres', 'INSERT', 3304945);
INSERT INTO "ProdNac2021".logbd VALUES (539, '2021-04-13', 'postgres', 'INSERT', 3300838);
INSERT INTO "ProdNac2021".logbd VALUES (540, '2021-04-13', 'postgres', 'INSERT', 3300894);
INSERT INTO "ProdNac2021".logbd VALUES (541, '2021-04-13', 'postgres', 'INSERT', 3300175);
INSERT INTO "ProdNac2021".logbd VALUES (542, '2021-04-13', 'postgres', 'INSERT', 3304766);
INSERT INTO "ProdNac2021".logbd VALUES (543, '2021-04-13', 'postgres', 'INSERT', 3300927);
INSERT INTO "ProdNac2021".logbd VALUES (544, '2021-04-13', 'postgres', 'INSERT', 3304953);
INSERT INTO "ProdNac2021".logbd VALUES (545, '2021-04-13', 'postgres', 'INSERT', 3300991);
INSERT INTO "ProdNac2021".logbd VALUES (546, '2021-04-13', 'postgres', 'INSERT', 3300835);
INSERT INTO "ProdNac2021".logbd VALUES (547, '2021-04-13', 'postgres', 'INSERT', 3300022);
INSERT INTO "ProdNac2021".logbd VALUES (548, '2021-04-13', 'postgres', 'INSERT', 3304559);
INSERT INTO "ProdNac2021".logbd VALUES (549, '2021-04-13', 'postgres', 'INSERT', 3300082);
INSERT INTO "ProdNac2021".logbd VALUES (550, '2021-04-13', 'postgres', 'INSERT', 3300306);
INSERT INTO "ProdNac2021".logbd VALUES (551, '2021-04-13', 'postgres', 'INSERT', 3304630);
INSERT INTO "ProdNac2021".logbd VALUES (552, '2021-04-13', 'postgres', 'INSERT', 3304675);
INSERT INTO "ProdNac2021".logbd VALUES (553, '2021-04-13', 'postgres', 'INSERT', 3304734);
INSERT INTO "ProdNac2021".logbd VALUES (554, '2021-04-13', 'postgres', 'INSERT', 3304843);
INSERT INTO "ProdNac2021".logbd VALUES (555, '2021-04-13', 'postgres', 'INSERT', 3304714);
INSERT INTO "ProdNac2021".logbd VALUES (556, '2021-04-13', 'postgres', 'INSERT', 3304444);
INSERT INTO "ProdNac2021".logbd VALUES (557, '2021-04-13', 'postgres', 'INSERT', 3300611);
INSERT INTO "ProdNac2021".logbd VALUES (558, '2021-04-13', 'postgres', 'INSERT', 3300691);
INSERT INTO "ProdNac2021".logbd VALUES (559, '2021-04-13', 'postgres', 'INSERT', 3300310);
INSERT INTO "ProdNac2021".logbd VALUES (560, '2021-04-13', 'postgres', 'INSERT', 3300307);
INSERT INTO "ProdNac2021".logbd VALUES (561, '2021-04-13', 'postgres', 'INSERT', 3300543);
INSERT INTO "ProdNac2021".logbd VALUES (562, '2021-04-13', 'postgres', 'INSERT', 3304902);
INSERT INTO "ProdNac2021".logbd VALUES (563, '2021-04-13', 'postgres', 'INSERT', 3304615);
INSERT INTO "ProdNac2021".logbd VALUES (564, '2021-04-13', 'postgres', 'INSERT', 3300541);
INSERT INTO "ProdNac2021".logbd VALUES (565, '2021-04-13', 'postgres', 'INSERT', 3300064);
INSERT INTO "ProdNac2021".logbd VALUES (566, '2021-04-13', 'postgres', 'INSERT', 3300661);
INSERT INTO "ProdNac2021".logbd VALUES (567, '2021-04-13', 'postgres', 'INSERT', 3304610);
INSERT INTO "ProdNac2021".logbd VALUES (568, '2021-04-13', 'postgres', 'INSERT', 3300380);
INSERT INTO "ProdNac2021".logbd VALUES (569, '2021-04-13', 'postgres', 'INSERT', 3300778);
INSERT INTO "ProdNac2021".logbd VALUES (570, '2021-04-13', 'postgres', 'INSERT', 3300886);
INSERT INTO "ProdNac2021".logbd VALUES (571, '2021-04-13', 'postgres', 'INSERT', 3300761);
INSERT INTO "ProdNac2021".logbd VALUES (572, '2021-04-13', 'postgres', 'INSERT', 3304456);
INSERT INTO "ProdNac2021".logbd VALUES (573, '2021-04-13', 'postgres', 'INSERT', 3304470);
INSERT INTO "ProdNac2021".logbd VALUES (574, '2021-04-13', 'postgres', 'INSERT', 3300376);
INSERT INTO "ProdNac2021".logbd VALUES (575, '2021-04-13', 'postgres', 'INSERT', 3304827);
INSERT INTO "ProdNac2021".logbd VALUES (576, '2021-04-13', 'postgres', 'INSERT', 3300660);
INSERT INTO "ProdNac2021".logbd VALUES (577, '2021-04-13', 'postgres', 'INSERT', 3304338);
INSERT INTO "ProdNac2021".logbd VALUES (578, '2021-04-13', 'postgres', 'INSERT', 3300084);
INSERT INTO "ProdNac2021".logbd VALUES (579, '2021-04-13', 'postgres', 'INSERT', 3304857);
INSERT INTO "ProdNac2021".logbd VALUES (580, '2021-04-13', 'postgres', 'INSERT', 3300128);
INSERT INTO "ProdNac2021".logbd VALUES (581, '2021-04-13', 'postgres', 'INSERT', 3300863);
INSERT INTO "ProdNac2021".logbd VALUES (582, '2021-04-13', 'postgres', 'INSERT', 3301117);
INSERT INTO "ProdNac2021".logbd VALUES (583, '2021-04-13', 'postgres', 'INSERT', 3300713);
INSERT INTO "ProdNac2021".logbd VALUES (584, '2021-04-13', 'postgres', 'INSERT', 3300699);
INSERT INTO "ProdNac2021".logbd VALUES (585, '2021-04-13', 'postgres', 'INSERT', 3304385);
INSERT INTO "ProdNac2021".logbd VALUES (586, '2021-04-13', 'postgres', 'INSERT', 3300158);
INSERT INTO "ProdNac2021".logbd VALUES (587, '2021-04-13', 'postgres', 'INSERT', 3301170);
INSERT INTO "ProdNac2021".logbd VALUES (588, '2021-04-13', 'postgres', 'INSERT', 3300523);
INSERT INTO "ProdNac2021".logbd VALUES (589, '2021-04-13', 'postgres', 'INSERT', 3301148);
INSERT INTO "ProdNac2021".logbd VALUES (590, '2021-04-13', 'postgres', 'INSERT', 3304848);
INSERT INTO "ProdNac2021".logbd VALUES (591, '2021-04-13', 'postgres', 'INSERT', 3304507);
INSERT INTO "ProdNac2021".logbd VALUES (592, '2021-04-13', 'postgres', 'INSERT', 3304718);
INSERT INTO "ProdNac2021".logbd VALUES (593, '2021-04-13', 'postgres', 'INSERT', 3301111);
INSERT INTO "ProdNac2021".logbd VALUES (594, '2021-04-13', 'postgres', 'INSERT', 3304764);
INSERT INTO "ProdNac2021".logbd VALUES (595, '2021-04-13', 'postgres', 'INSERT', 3301189);
INSERT INTO "ProdNac2021".logbd VALUES (596, '2021-04-13', 'postgres', 'INSERT', 3300467);
INSERT INTO "ProdNac2021".logbd VALUES (597, '2021-04-13', 'postgres', 'INSERT', 3304498);
INSERT INTO "ProdNac2021".logbd VALUES (598, '2021-04-13', 'postgres', 'INSERT', 3304328);
INSERT INTO "ProdNac2021".logbd VALUES (599, '2021-04-13', 'postgres', 'INSERT', 3300443);
INSERT INTO "ProdNac2021".logbd VALUES (600, '2021-04-13', 'postgres', 'INSERT', 3304936);
INSERT INTO "ProdNac2021".logbd VALUES (601, '2021-04-13', 'postgres', 'INSERT', 3300225);
INSERT INTO "ProdNac2021".logbd VALUES (602, '2021-04-13', 'postgres', 'INSERT', 3300464);
INSERT INTO "ProdNac2021".logbd VALUES (603, '2021-04-13', 'postgres', 'INSERT', 3301100);
INSERT INTO "ProdNac2021".logbd VALUES (604, '2021-04-13', 'postgres', 'INSERT', 3304562);
INSERT INTO "ProdNac2021".logbd VALUES (605, '2021-04-13', 'postgres', 'INSERT', 3300794);
INSERT INTO "ProdNac2021".logbd VALUES (606, '2021-04-13', 'postgres', 'INSERT', 3300926);
INSERT INTO "ProdNac2021".logbd VALUES (607, '2021-04-13', 'postgres', 'INSERT', 3300294);
INSERT INTO "ProdNac2021".logbd VALUES (608, '2021-04-13', 'postgres', 'INSERT', 3300607);
INSERT INTO "ProdNac2021".logbd VALUES (609, '2021-04-13', 'postgres', 'INSERT', 3301182);
INSERT INTO "ProdNac2021".logbd VALUES (610, '2021-04-13', 'postgres', 'INSERT', 3300055);
INSERT INTO "ProdNac2021".logbd VALUES (611, '2021-04-13', 'postgres', 'INSERT', 3300171);
INSERT INTO "ProdNac2021".logbd VALUES (612, '2021-04-13', 'postgres', 'INSERT', 3304493);
INSERT INTO "ProdNac2021".logbd VALUES (613, '2021-04-13', 'postgres', 'INSERT', 3301129);
INSERT INTO "ProdNac2021".logbd VALUES (614, '2021-04-13', 'postgres', 'INSERT', 3304922);
INSERT INTO "ProdNac2021".logbd VALUES (615, '2021-04-13', 'postgres', 'INSERT', 3300666);
INSERT INTO "ProdNac2021".logbd VALUES (616, '2021-04-13', 'postgres', 'INSERT', 3300626);
INSERT INTO "ProdNac2021".logbd VALUES (617, '2021-04-13', 'postgres', 'INSERT', 3301035);
INSERT INTO "ProdNac2021".logbd VALUES (618, '2021-04-13', 'postgres', 'INSERT', 3301203);
INSERT INTO "ProdNac2021".logbd VALUES (619, '2021-04-13', 'postgres', 'INSERT', 3300324);
INSERT INTO "ProdNac2021".logbd VALUES (620, '2021-04-13', 'postgres', 'INSERT', 3300107);
INSERT INTO "ProdNac2021".logbd VALUES (621, '2021-04-13', 'postgres', 'INSERT', 3300769);
INSERT INTO "ProdNac2021".logbd VALUES (622, '2021-04-13', 'postgres', 'INSERT', 3301041);
INSERT INTO "ProdNac2021".logbd VALUES (623, '2021-04-13', 'postgres', 'INSERT', 3301004);
INSERT INTO "ProdNac2021".logbd VALUES (624, '2021-04-13', 'postgres', 'INSERT', 3300385);
INSERT INTO "ProdNac2021".logbd VALUES (625, '2021-04-13', 'postgres', 'INSERT', 3300832);
INSERT INTO "ProdNac2021".logbd VALUES (626, '2021-04-13', 'postgres', 'INSERT', 3300751);
INSERT INTO "ProdNac2021".logbd VALUES (627, '2021-04-13', 'postgres', 'INSERT', 3300773);
INSERT INTO "ProdNac2021".logbd VALUES (628, '2021-04-13', 'postgres', 'INSERT', 3300381);
INSERT INTO "ProdNac2021".logbd VALUES (629, '2021-04-13', 'postgres', 'INSERT', 3304379);
INSERT INTO "ProdNac2021".logbd VALUES (630, '2021-04-13', 'postgres', 'INSERT', 3300536);
INSERT INTO "ProdNac2021".logbd VALUES (631, '2021-04-13', 'postgres', 'INSERT', 3300942);
INSERT INTO "ProdNac2021".logbd VALUES (632, '2021-04-13', 'postgres', 'INSERT', 3304582);
INSERT INTO "ProdNac2021".logbd VALUES (633, '2021-04-13', 'postgres', 'INSERT', 3300992);
INSERT INTO "ProdNac2021".logbd VALUES (634, '2021-04-13', 'postgres', 'INSERT', 3300570);
INSERT INTO "ProdNac2021".logbd VALUES (635, '2021-04-13', 'postgres', 'INSERT', 3304500);
INSERT INTO "ProdNac2021".logbd VALUES (636, '2021-04-13', 'postgres', 'INSERT', 3304601);
INSERT INTO "ProdNac2021".logbd VALUES (637, '2021-04-13', 'postgres', 'INSERT', 3300138);
INSERT INTO "ProdNac2021".logbd VALUES (638, '2021-04-13', 'postgres', 'INSERT', 3300830);
INSERT INTO "ProdNac2021".logbd VALUES (639, '2021-04-13', 'postgres', 'INSERT', 3301033);
INSERT INTO "ProdNac2021".logbd VALUES (640, '2021-04-13', 'postgres', 'INSERT', 3300437);
INSERT INTO "ProdNac2021".logbd VALUES (641, '2021-04-13', 'postgres', 'INSERT', 3300489);
INSERT INTO "ProdNac2021".logbd VALUES (642, '2021-04-13', 'postgres', 'INSERT', 3300183);
INSERT INTO "ProdNac2021".logbd VALUES (643, '2021-04-13', 'postgres', 'INSERT', 3304809);
INSERT INTO "ProdNac2021".logbd VALUES (644, '2021-04-13', 'postgres', 'INSERT', 3304990);
INSERT INTO "ProdNac2021".logbd VALUES (645, '2021-04-13', 'postgres', 'INSERT', 3304758);
INSERT INTO "ProdNac2021".logbd VALUES (646, '2021-04-13', 'postgres', 'INSERT', 3304840);
INSERT INTO "ProdNac2021".logbd VALUES (647, '2021-04-13', 'postgres', 'INSERT', 3300180);
INSERT INTO "ProdNac2021".logbd VALUES (648, '2021-04-13', 'postgres', 'INSERT', 3300085);
INSERT INTO "ProdNac2021".logbd VALUES (649, '2021-04-13', 'postgres', 'INSERT', 3304415);
INSERT INTO "ProdNac2021".logbd VALUES (650, '2021-04-13', 'postgres', 'INSERT', 3300347);
INSERT INTO "ProdNac2021".logbd VALUES (651, '2021-04-13', 'postgres', 'INSERT', 3304888);
INSERT INTO "ProdNac2021".logbd VALUES (652, '2021-04-13', 'postgres', 'INSERT', 3300471);
INSERT INTO "ProdNac2021".logbd VALUES (653, '2021-04-13', 'postgres', 'INSERT', 3304970);
INSERT INTO "ProdNac2021".logbd VALUES (654, '2021-04-13', 'postgres', 'INSERT', 3304804);
INSERT INTO "ProdNac2021".logbd VALUES (655, '2021-04-13', 'postgres', 'INSERT', 3304900);
INSERT INTO "ProdNac2021".logbd VALUES (656, '2021-04-13', 'postgres', 'INSERT', 3300169);
INSERT INTO "ProdNac2021".logbd VALUES (657, '2021-04-13', 'postgres', 'INSERT', 3300432);
INSERT INTO "ProdNac2021".logbd VALUES (658, '2021-04-13', 'postgres', 'INSERT', 3300833);
INSERT INTO "ProdNac2021".logbd VALUES (659, '2021-04-13', 'postgres', 'INSERT', 3300160);
INSERT INTO "ProdNac2021".logbd VALUES (660, '2021-04-13', 'postgres', 'INSERT', 3301034);
INSERT INTO "ProdNac2021".logbd VALUES (661, '2021-04-13', 'postgres', 'INSERT', 3300807);
INSERT INTO "ProdNac2021".logbd VALUES (662, '2021-04-13', 'postgres', 'INSERT', 3301030);
INSERT INTO "ProdNac2021".logbd VALUES (663, '2021-04-13', 'postgres', 'INSERT', 3300925);
INSERT INTO "ProdNac2021".logbd VALUES (664, '2021-04-13', 'postgres', 'INSERT', 3304790);
INSERT INTO "ProdNac2021".logbd VALUES (665, '2021-04-13', 'postgres', 'INSERT', 3300637);
INSERT INTO "ProdNac2021".logbd VALUES (666, '2021-04-13', 'postgres', 'INSERT', 3304739);
INSERT INTO "ProdNac2021".logbd VALUES (667, '2021-04-13', 'postgres', 'INSERT', 3300060);
INSERT INTO "ProdNac2021".logbd VALUES (668, '2021-04-13', 'postgres', 'INSERT', 3300068);
INSERT INTO "ProdNac2021".logbd VALUES (669, '2021-04-13', 'postgres', 'INSERT', 3300161);
INSERT INTO "ProdNac2021".logbd VALUES (670, '2021-04-13', 'postgres', 'INSERT', 3300789);
INSERT INTO "ProdNac2021".logbd VALUES (671, '2021-04-13', 'postgres', 'INSERT', 3300683);
INSERT INTO "ProdNac2021".logbd VALUES (672, '2021-04-13', 'postgres', 'INSERT', 3304633);
INSERT INTO "ProdNac2021".logbd VALUES (673, '2021-04-13', 'postgres', 'INSERT', 3300979);
INSERT INTO "ProdNac2021".logbd VALUES (674, '2021-04-13', 'postgres', 'INSERT', 3301151);
INSERT INTO "ProdNac2021".logbd VALUES (675, '2021-04-13', 'postgres', 'INSERT', 3300644);
INSERT INTO "ProdNac2021".logbd VALUES (676, '2021-04-13', 'postgres', 'INSERT', 3301162);
INSERT INTO "ProdNac2021".logbd VALUES (677, '2021-04-13', 'postgres', 'INSERT', 3300339);
INSERT INTO "ProdNac2021".logbd VALUES (678, '2021-04-13', 'postgres', 'INSERT', 3300801);
INSERT INTO "ProdNac2021".logbd VALUES (679, '2021-04-13', 'postgres', 'INSERT', 3304356);
INSERT INTO "ProdNac2021".logbd VALUES (680, '2021-04-13', 'postgres', 'INSERT', 3304430);
INSERT INTO "ProdNac2021".logbd VALUES (681, '2021-04-13', 'postgres', 'INSERT', 3304639);
INSERT INTO "ProdNac2021".logbd VALUES (682, '2021-04-13', 'postgres', 'INSERT', 3300524);
INSERT INTO "ProdNac2021".logbd VALUES (683, '2021-04-13', 'postgres', 'INSERT', 3300035);
INSERT INTO "ProdNac2021".logbd VALUES (684, '2021-04-13', 'postgres', 'INSERT', 3300099);
INSERT INTO "ProdNac2021".logbd VALUES (685, '2021-04-13', 'postgres', 'INSERT', 3300451);
INSERT INTO "ProdNac2021".logbd VALUES (686, '2021-04-13', 'postgres', 'INSERT', 3300308);
INSERT INTO "ProdNac2021".logbd VALUES (687, '2021-04-13', 'postgres', 'INSERT', 3300884);
INSERT INTO "ProdNac2021".logbd VALUES (688, '2021-04-13', 'postgres', 'INSERT', 3300844);
INSERT INTO "ProdNac2021".logbd VALUES (689, '2021-04-13', 'postgres', 'INSERT', 3300228);
INSERT INTO "ProdNac2021".logbd VALUES (690, '2021-04-13', 'postgres', 'INSERT', 3304407);
INSERT INTO "ProdNac2021".logbd VALUES (691, '2021-04-13', 'postgres', 'INSERT', 3304629);
INSERT INTO "ProdNac2021".logbd VALUES (692, '2021-04-13', 'postgres', 'INSERT', 3304557);
INSERT INTO "ProdNac2021".logbd VALUES (693, '2021-04-13', 'postgres', 'INSERT', 3301046);
INSERT INTO "ProdNac2021".logbd VALUES (694, '2021-04-13', 'postgres', 'INSERT', 3304679);
INSERT INTO "ProdNac2021".logbd VALUES (695, '2021-04-13', 'postgres', 'INSERT', 3304861);
INSERT INTO "ProdNac2021".logbd VALUES (696, '2021-04-13', 'postgres', 'INSERT', 3301122);
INSERT INTO "ProdNac2021".logbd VALUES (697, '2021-04-13', 'postgres', 'INSERT', 3301064);
INSERT INTO "ProdNac2021".logbd VALUES (698, '2021-04-13', 'postgres', 'INSERT', 3300057);
INSERT INTO "ProdNac2021".logbd VALUES (699, '2021-04-13', 'postgres', 'INSERT', 3300357);
INSERT INTO "ProdNac2021".logbd VALUES (700, '2021-04-13', 'postgres', 'INSERT', 3300776);
INSERT INTO "ProdNac2021".logbd VALUES (701, '2021-04-13', 'postgres', 'INSERT', 3300340);
INSERT INTO "ProdNac2021".logbd VALUES (702, '2021-04-13', 'postgres', 'INSERT', 3304366);
INSERT INTO "ProdNac2021".logbd VALUES (703, '2021-04-13', 'postgres', 'INSERT', 3304955);
INSERT INTO "ProdNac2021".logbd VALUES (704, '2021-04-13', 'postgres', 'INSERT', 3300993);
INSERT INTO "ProdNac2021".logbd VALUES (705, '2021-04-13', 'postgres', 'INSERT', 3300629);
INSERT INTO "ProdNac2021".logbd VALUES (706, '2021-04-13', 'postgres', 'INSERT', 3300027);
INSERT INTO "ProdNac2021".logbd VALUES (707, '2021-04-13', 'postgres', 'INSERT', 3300402);
INSERT INTO "ProdNac2021".logbd VALUES (708, '2021-04-13', 'postgres', 'INSERT', 3300328);
INSERT INTO "ProdNac2021".logbd VALUES (709, '2021-04-13', 'postgres', 'INSERT', 3304410);
INSERT INTO "ProdNac2021".logbd VALUES (710, '2021-04-13', 'postgres', 'INSERT', 3304856);
INSERT INTO "ProdNac2021".logbd VALUES (711, '2021-04-13', 'postgres', 'INSERT', 3304926);
INSERT INTO "ProdNac2021".logbd VALUES (712, '2021-04-13', 'postgres', 'INSERT', 3300793);
INSERT INTO "ProdNac2021".logbd VALUES (713, '2021-04-13', 'postgres', 'INSERT', 3304773);
INSERT INTO "ProdNac2021".logbd VALUES (714, '2021-04-13', 'postgres', 'INSERT', 3300168);
INSERT INTO "ProdNac2021".logbd VALUES (715, '2021-04-13', 'postgres', 'INSERT', 3301134);
INSERT INTO "ProdNac2021".logbd VALUES (716, '2021-04-13', 'postgres', 'INSERT', 3300196);
INSERT INTO "ProdNac2021".logbd VALUES (717, '2021-04-13', 'postgres', 'INSERT', 3300474);
INSERT INTO "ProdNac2021".logbd VALUES (718, '2021-04-13', 'postgres', 'INSERT', 3300115);
INSERT INTO "ProdNac2021".logbd VALUES (719, '2021-04-13', 'postgres', 'INSERT', 3300984);
INSERT INTO "ProdNac2021".logbd VALUES (720, '2021-04-13', 'postgres', 'INSERT', 3304440);
INSERT INTO "ProdNac2021".logbd VALUES (721, '2021-04-13', 'postgres', 'INSERT', 3304528);
INSERT INTO "ProdNac2021".logbd VALUES (722, '2021-04-13', 'postgres', 'INSERT', 3304787);
INSERT INTO "ProdNac2021".logbd VALUES (723, '2021-04-13', 'postgres', 'INSERT', 3304924);
INSERT INTO "ProdNac2021".logbd VALUES (724, '2021-04-13', 'postgres', 'INSERT', 3300656);
INSERT INTO "ProdNac2021".logbd VALUES (725, '2021-04-13', 'postgres', 'INSERT', 3300364);
INSERT INTO "ProdNac2021".logbd VALUES (726, '2021-04-13', 'postgres', 'INSERT', 3300392);
INSERT INTO "ProdNac2021".logbd VALUES (727, '2021-04-13', 'postgres', 'INSERT', 3304499);
INSERT INTO "ProdNac2021".logbd VALUES (728, '2021-04-13', 'postgres', 'INSERT', 3304351);
INSERT INTO "ProdNac2021".logbd VALUES (729, '2021-04-13', 'postgres', 'INSERT', 3300779);
INSERT INTO "ProdNac2021".logbd VALUES (730, '2021-04-13', 'postgres', 'INSERT', 3300105);
INSERT INTO "ProdNac2021".logbd VALUES (731, '2021-04-13', 'postgres', 'INSERT', 3300843);
INSERT INTO "ProdNac2021".logbd VALUES (732, '2021-04-13', 'postgres', 'INSERT', 3301114);
INSERT INTO "ProdNac2021".logbd VALUES (733, '2021-04-13', 'postgres', 'INSERT', 3304660);
INSERT INTO "ProdNac2021".logbd VALUES (734, '2021-04-13', 'postgres', 'INSERT', 3300118);
INSERT INTO "ProdNac2021".logbd VALUES (735, '2021-04-13', 'postgres', 'INSERT', 3304341);
INSERT INTO "ProdNac2021".logbd VALUES (736, '2021-04-13', 'postgres', 'INSERT', 3300677);
INSERT INTO "ProdNac2021".logbd VALUES (737, '2021-04-13', 'postgres', 'INSERT', 3304597);
INSERT INTO "ProdNac2021".logbd VALUES (738, '2021-04-13', 'postgres', 'INSERT', 3300487);
INSERT INTO "ProdNac2021".logbd VALUES (739, '2021-04-13', 'postgres', 'INSERT', 3300515);
INSERT INTO "ProdNac2021".logbd VALUES (740, '2021-04-13', 'postgres', 'INSERT', 3300574);
INSERT INTO "ProdNac2021".logbd VALUES (741, '2021-04-13', 'postgres', 'INSERT', 3300547);
INSERT INTO "ProdNac2021".logbd VALUES (742, '2021-04-13', 'postgres', 'INSERT', 3300648);
INSERT INTO "ProdNac2021".logbd VALUES (743, '2021-04-13', 'postgres', 'INSERT', 3300972);
INSERT INTO "ProdNac2021".logbd VALUES (744, '2021-04-13', 'postgres', 'INSERT', 3304592);
INSERT INTO "ProdNac2021".logbd VALUES (745, '2021-04-13', 'postgres', 'INSERT', 3300466);
INSERT INTO "ProdNac2021".logbd VALUES (746, '2021-04-13', 'postgres', 'INSERT', 3304687);
INSERT INTO "ProdNac2021".logbd VALUES (747, '2021-04-13', 'postgres', 'INSERT', 3304752);
INSERT INTO "ProdNac2021".logbd VALUES (748, '2021-04-13', 'postgres', 'INSERT', 3304726);
INSERT INTO "ProdNac2021".logbd VALUES (749, '2021-04-13', 'postgres', 'INSERT', 3304988);
INSERT INTO "ProdNac2021".logbd VALUES (750, '2021-04-13', 'postgres', 'INSERT', 3304865);
INSERT INTO "ProdNac2021".logbd VALUES (751, '2021-04-13', 'postgres', 'INSERT', 3304642);
INSERT INTO "ProdNac2021".logbd VALUES (752, '2021-04-13', 'postgres', 'INSERT', 3304771);
INSERT INTO "ProdNac2021".logbd VALUES (753, '2021-04-13', 'postgres', 'INSERT', 3300708);
INSERT INTO "ProdNac2021".logbd VALUES (754, '2021-04-13', 'postgres', 'INSERT', 3301044);
INSERT INTO "ProdNac2021".logbd VALUES (755, '2021-04-13', 'postgres', 'INSERT', 3300589);
INSERT INTO "ProdNac2021".logbd VALUES (756, '2021-04-13', 'postgres', 'INSERT', 3300883);
INSERT INTO "ProdNac2021".logbd VALUES (757, '2021-04-13', 'postgres', 'INSERT', 3300560);
INSERT INTO "ProdNac2021".logbd VALUES (758, '2021-04-13', 'postgres', 'INSERT', 3300352);
INSERT INTO "ProdNac2021".logbd VALUES (759, '2021-04-13', 'postgres', 'INSERT', 3301065);
INSERT INTO "ProdNac2021".logbd VALUES (760, '2021-04-13', 'postgres', 'INSERT', 3301016);
INSERT INTO "ProdNac2021".logbd VALUES (761, '2021-04-13', 'postgres', 'INSERT', 3300011);
INSERT INTO "ProdNac2021".logbd VALUES (762, '2021-04-13', 'postgres', 'INSERT', 3300362);
INSERT INTO "ProdNac2021".logbd VALUES (763, '2021-04-13', 'postgres', 'INSERT', 3304853);
INSERT INTO "ProdNac2021".logbd VALUES (764, '2021-04-13', 'postgres', 'INSERT', 3300634);
INSERT INTO "ProdNac2021".logbd VALUES (765, '2021-04-13', 'postgres', 'INSERT', 3300081);
INSERT INTO "ProdNac2021".logbd VALUES (766, '2021-04-13', 'postgres', 'INSERT', 3300457);
INSERT INTO "ProdNac2021".logbd VALUES (767, '2021-04-13', 'postgres', 'INSERT', 3300131);
INSERT INTO "ProdNac2021".logbd VALUES (768, '2021-04-13', 'postgres', 'INSERT', 3300750);
INSERT INTO "ProdNac2021".logbd VALUES (769, '2021-04-13', 'postgres', 'INSERT', 3300513);
INSERT INTO "ProdNac2021".logbd VALUES (770, '2021-04-13', 'postgres', 'INSERT', 3304556);
INSERT INTO "ProdNac2021".logbd VALUES (771, '2021-04-13', 'postgres', 'INSERT', 3300059);
INSERT INTO "ProdNac2021".logbd VALUES (772, '2021-04-13', 'postgres', 'INSERT', 3304571);
INSERT INTO "ProdNac2021".logbd VALUES (773, '2021-04-13', 'postgres', 'INSERT', 3304770);
INSERT INTO "ProdNac2021".logbd VALUES (774, '2021-04-13', 'postgres', 'INSERT', 3304815);
INSERT INTO "ProdNac2021".logbd VALUES (775, '2021-04-13', 'postgres', 'INSERT', 3300646);
INSERT INTO "ProdNac2021".logbd VALUES (776, '2021-04-13', 'postgres', 'INSERT', 3300628);
INSERT INTO "ProdNac2021".logbd VALUES (777, '2021-04-13', 'postgres', 'INSERT', 3300865);
INSERT INTO "ProdNac2021".logbd VALUES (778, '2021-04-13', 'postgres', 'INSERT', 3301113);
INSERT INTO "ProdNac2021".logbd VALUES (779, '2021-04-13', 'postgres', 'INSERT', 3300400);
INSERT INTO "ProdNac2021".logbd VALUES (780, '2021-04-13', 'postgres', 'INSERT', 3300519);
INSERT INTO "ProdNac2021".logbd VALUES (781, '2021-04-13', 'postgres', 'INSERT', 3300273);
INSERT INTO "ProdNac2021".logbd VALUES (782, '2021-04-13', 'postgres', 'INSERT', 3300977);
INSERT INTO "ProdNac2021".logbd VALUES (783, '2021-04-13', 'postgres', 'INSERT', 3300390);
INSERT INTO "ProdNac2021".logbd VALUES (784, '2021-04-13', 'postgres', 'INSERT', 3304487);
INSERT INTO "ProdNac2021".logbd VALUES (785, '2021-04-13', 'postgres', 'INSERT', 3300839);
INSERT INTO "ProdNac2021".logbd VALUES (786, '2021-04-13', 'postgres', 'INSERT', 3300598);
INSERT INTO "ProdNac2021".logbd VALUES (787, '2021-04-13', 'postgres', 'INSERT', 3300734);
INSERT INTO "ProdNac2021".logbd VALUES (788, '2021-04-13', 'postgres', 'INSERT', 3300121);
INSERT INTO "ProdNac2021".logbd VALUES (789, '2021-04-13', 'postgres', 'INSERT', 3300325);
INSERT INTO "ProdNac2021".logbd VALUES (790, '2021-04-13', 'postgres', 'INSERT', 3304879);
INSERT INTO "ProdNac2021".logbd VALUES (791, '2021-04-13', 'postgres', 'INSERT', 3304477);
INSERT INTO "ProdNac2021".logbd VALUES (792, '2021-04-13', 'postgres', 'INSERT', 3300569);
INSERT INTO "ProdNac2021".logbd VALUES (793, '2021-04-13', 'postgres', 'INSERT', 3300281);
INSERT INTO "ProdNac2021".logbd VALUES (794, '2021-04-13', 'postgres', 'INSERT', 3304353);
INSERT INTO "ProdNac2021".logbd VALUES (795, '2021-04-13', 'postgres', 'INSERT', 3304935);
INSERT INTO "ProdNac2021".logbd VALUES (796, '2021-04-13', 'postgres', 'INSERT', 3300262);
INSERT INTO "ProdNac2021".logbd VALUES (797, '2021-04-13', 'postgres', 'INSERT', 3304648);
INSERT INTO "ProdNac2021".logbd VALUES (798, '2021-04-13', 'postgres', 'INSERT', 3304421);
INSERT INTO "ProdNac2021".logbd VALUES (799, '2021-04-13', 'postgres', 'INSERT', 3300824);
INSERT INTO "ProdNac2021".logbd VALUES (800, '2021-04-13', 'postgres', 'INSERT', 3304547);
INSERT INTO "ProdNac2021".logbd VALUES (801, '2021-04-13', 'postgres', 'INSERT', 3304987);
INSERT INTO "ProdNac2021".logbd VALUES (802, '2021-04-13', 'postgres', 'INSERT', 3300463);
INSERT INTO "ProdNac2021".logbd VALUES (803, '2021-04-13', 'postgres', 'INSERT', 3300360);
INSERT INTO "ProdNac2021".logbd VALUES (804, '2021-04-13', 'postgres', 'INSERT', 3300021);
INSERT INTO "ProdNac2021".logbd VALUES (805, '2021-04-13', 'postgres', 'INSERT', 3304606);
INSERT INTO "ProdNac2021".logbd VALUES (806, '2021-04-13', 'postgres', 'INSERT', 3300655);
INSERT INTO "ProdNac2021".logbd VALUES (807, '2021-04-13', 'postgres', 'INSERT', 3304904);
INSERT INTO "ProdNac2021".logbd VALUES (808, '2021-04-13', 'postgres', 'INSERT', 3300052);
INSERT INTO "ProdNac2021".logbd VALUES (809, '2021-04-13', 'postgres', 'INSERT', 3300954);
INSERT INTO "ProdNac2021".logbd VALUES (810, '2021-04-13', 'postgres', 'INSERT', 3304905);
INSERT INTO "ProdNac2021".logbd VALUES (811, '2021-04-13', 'postgres', 'INSERT', 3300150);
INSERT INTO "ProdNac2021".logbd VALUES (812, '2021-04-13', 'postgres', 'INSERT', 3304418);
INSERT INTO "ProdNac2021".logbd VALUES (813, '2021-04-13', 'postgres', 'INSERT', 3304619);
INSERT INTO "ProdNac2021".logbd VALUES (814, '2021-04-13', 'postgres', 'INSERT', 3300192);
INSERT INTO "ProdNac2021".logbd VALUES (815, '2021-04-13', 'postgres', 'INSERT', 3304598);
INSERT INTO "ProdNac2021".logbd VALUES (816, '2021-04-13', 'postgres', 'INSERT', 3304684);
INSERT INTO "ProdNac2021".logbd VALUES (817, '2021-04-13', 'postgres', 'INSERT', 3300592);
INSERT INTO "ProdNac2021".logbd VALUES (818, '2021-04-13', 'postgres', 'INSERT', 3300407);
INSERT INTO "ProdNac2021".logbd VALUES (819, '2021-04-13', 'postgres', 'INSERT', 3300511);
INSERT INTO "ProdNac2021".logbd VALUES (820, '2021-04-13', 'postgres', 'INSERT', 3304466);
INSERT INTO "ProdNac2021".logbd VALUES (821, '2021-04-13', 'postgres', 'INSERT', 3301066);
INSERT INTO "ProdNac2021".logbd VALUES (822, '2021-04-13', 'postgres', 'INSERT', 3304554);
INSERT INTO "ProdNac2021".logbd VALUES (823, '2021-04-13', 'postgres', 'INSERT', 3304744);
INSERT INTO "ProdNac2021".logbd VALUES (824, '2021-04-13', 'postgres', 'INSERT', 3304778);
INSERT INTO "ProdNac2021".logbd VALUES (825, '2021-04-13', 'postgres', 'INSERT', 3304938);
INSERT INTO "ProdNac2021".logbd VALUES (826, '2021-04-13', 'postgres', 'INSERT', 3304624);
INSERT INTO "ProdNac2021".logbd VALUES (827, '2021-04-13', 'postgres', 'INSERT', 3304754);
INSERT INTO "ProdNac2021".logbd VALUES (828, '2021-04-13', 'postgres', 'INSERT', 3304828);
INSERT INTO "ProdNac2021".logbd VALUES (829, '2021-04-13', 'postgres', 'INSERT', 3304363);
INSERT INTO "ProdNac2021".logbd VALUES (830, '2021-04-13', 'postgres', 'INSERT', 3304907);
INSERT INTO "ProdNac2021".logbd VALUES (831, '2021-04-13', 'postgres', 'INSERT', 3300447);
INSERT INTO "ProdNac2021".logbd VALUES (832, '2021-04-13', 'postgres', 'INSERT', 3301105);
INSERT INTO "ProdNac2021".logbd VALUES (833, '2021-04-13', 'postgres', 'INSERT', 3304441);
INSERT INTO "ProdNac2021".logbd VALUES (834, '2021-04-13', 'postgres', 'INSERT', 3304623);
INSERT INTO "ProdNac2021".logbd VALUES (835, '2021-04-13', 'postgres', 'INSERT', 3300600);
INSERT INTO "ProdNac2021".logbd VALUES (836, '2021-04-13', 'postgres', 'INSERT', 3300898);
INSERT INTO "ProdNac2021".logbd VALUES (837, '2021-04-13', 'postgres', 'INSERT', 3304949);
INSERT INTO "ProdNac2021".logbd VALUES (838, '2021-04-13', 'postgres', 'INSERT', 3300065);
INSERT INTO "ProdNac2021".logbd VALUES (839, '2021-04-13', 'postgres', 'INSERT', 3300251);
INSERT INTO "ProdNac2021".logbd VALUES (840, '2021-04-13', 'postgres', 'INSERT', 3300086);
INSERT INTO "ProdNac2021".logbd VALUES (841, '2021-04-13', 'postgres', 'INSERT', 3304797);
INSERT INTO "ProdNac2021".logbd VALUES (842, '2021-04-13', 'postgres', 'INSERT', 3304751);
INSERT INTO "ProdNac2021".logbd VALUES (843, '2021-04-13', 'postgres', 'INSERT', 3300915);
INSERT INTO "ProdNac2021".logbd VALUES (844, '2021-04-13', 'postgres', 'INSERT', 3300187);
INSERT INTO "ProdNac2021".logbd VALUES (845, '2021-04-13', 'postgres', 'INSERT', 3300399);
INSERT INTO "ProdNac2021".logbd VALUES (846, '2021-04-13', 'postgres', 'INSERT', 3300287);
INSERT INTO "ProdNac2021".logbd VALUES (847, '2021-04-13', 'postgres', 'INSERT', 3300951);
INSERT INTO "ProdNac2021".logbd VALUES (848, '2021-04-13', 'postgres', 'INSERT', 3300658);
INSERT INTO "ProdNac2021".logbd VALUES (849, '2021-04-13', 'postgres', 'INSERT', 3301042);
INSERT INTO "ProdNac2021".logbd VALUES (850, '2021-04-13', 'postgres', 'INSERT', 3300261);
INSERT INTO "ProdNac2021".logbd VALUES (851, '2021-04-13', 'postgres', 'INSERT', 3300619);
INSERT INTO "ProdNac2021".logbd VALUES (852, '2021-04-13', 'postgres', 'INSERT', 3300601);
INSERT INTO "ProdNac2021".logbd VALUES (853, '2021-04-13', 'postgres', 'INSERT', 3300186);
INSERT INTO "ProdNac2021".logbd VALUES (854, '2021-04-13', 'postgres', 'INSERT', 3304849);
INSERT INTO "ProdNac2021".logbd VALUES (855, '2021-04-13', 'postgres', 'INSERT', 3301060);
INSERT INTO "ProdNac2021".logbd VALUES (856, '2021-04-13', 'postgres', 'INSERT', 3304375);
INSERT INTO "ProdNac2021".logbd VALUES (857, '2021-04-13', 'postgres', 'INSERT', 3300266);
INSERT INTO "ProdNac2021".logbd VALUES (858, '2021-04-13', 'postgres', 'INSERT', 3301062);
INSERT INTO "ProdNac2021".logbd VALUES (859, '2021-04-13', 'postgres', 'INSERT', 3300046);
INSERT INTO "ProdNac2021".logbd VALUES (860, '2021-04-13', 'postgres', 'INSERT', 3304449);
INSERT INTO "ProdNac2021".logbd VALUES (861, '2021-04-13', 'postgres', 'INSERT', 3301019);
INSERT INTO "ProdNac2021".logbd VALUES (862, '2021-04-13', 'postgres', 'INSERT', 3304564);
INSERT INTO "ProdNac2021".logbd VALUES (863, '2021-04-13', 'postgres', 'INSERT', 3300564);
INSERT INTO "ProdNac2021".logbd VALUES (864, '2021-04-13', 'postgres', 'INSERT', 3300470);
INSERT INTO "ProdNac2021".logbd VALUES (865, '2021-04-13', 'postgres', 'INSERT', 3301201);
INSERT INTO "ProdNac2021".logbd VALUES (866, '2021-04-13', 'postgres', 'INSERT', 3300653);
INSERT INTO "ProdNac2021".logbd VALUES (867, '2021-04-13', 'postgres', 'INSERT', 3300448);
INSERT INTO "ProdNac2021".logbd VALUES (868, '2021-04-13', 'postgres', 'INSERT', 3300374);
INSERT INTO "ProdNac2021".logbd VALUES (869, '2021-04-13', 'postgres', 'INSERT', 3300019);
INSERT INTO "ProdNac2021".logbd VALUES (870, '2021-04-13', 'postgres', 'INSERT', 3301043);
INSERT INTO "ProdNac2021".logbd VALUES (871, '2021-04-13', 'postgres', 'INSERT', 3304420);
INSERT INTO "ProdNac2021".logbd VALUES (872, '2021-04-13', 'postgres', 'INSERT', 3304664);
INSERT INTO "ProdNac2021".logbd VALUES (873, '2021-04-13', 'postgres', 'INSERT', 3301050);
INSERT INTO "ProdNac2021".logbd VALUES (874, '2021-04-13', 'postgres', 'INSERT', 3304459);
INSERT INTO "ProdNac2021".logbd VALUES (875, '2021-04-13', 'postgres', 'INSERT', 3300610);
INSERT INTO "ProdNac2021".logbd VALUES (876, '2021-04-13', 'postgres', 'INSERT', 3304387);
INSERT INTO "ProdNac2021".logbd VALUES (877, '2021-04-13', 'postgres', 'INSERT', 3300093);
INSERT INTO "ProdNac2021".logbd VALUES (878, '2021-04-13', 'postgres', 'INSERT', 3300190);
INSERT INTO "ProdNac2021".logbd VALUES (879, '2021-04-13', 'postgres', 'INSERT', 3300845);
INSERT INTO "ProdNac2021".logbd VALUES (880, '2021-04-13', 'postgres', 'INSERT', 3304391);
INSERT INTO "ProdNac2021".logbd VALUES (881, '2021-04-13', 'postgres', 'INSERT', 3301093);
INSERT INTO "ProdNac2021".logbd VALUES (882, '2021-04-13', 'postgres', 'INSERT', 3300903);
INSERT INTO "ProdNac2021".logbd VALUES (883, '2021-04-13', 'postgres', 'INSERT', 3300662);
INSERT INTO "ProdNac2021".logbd VALUES (884, '2021-04-13', 'postgres', 'INSERT', 3300367);
INSERT INTO "ProdNac2021".logbd VALUES (885, '2021-04-13', 'postgres', 'INSERT', 3301121);
INSERT INTO "ProdNac2021".logbd VALUES (886, '2021-04-13', 'postgres', 'INSERT', 3304359);
INSERT INTO "ProdNac2021".logbd VALUES (887, '2021-04-13', 'postgres', 'INSERT', 3301088);
INSERT INTO "ProdNac2021".logbd VALUES (888, '2021-04-13', 'postgres', 'INSERT', 3300982);
INSERT INTO "ProdNac2021".logbd VALUES (889, '2021-04-13', 'postgres', 'INSERT', 3300647);
INSERT INTO "ProdNac2021".logbd VALUES (890, '2021-04-13', 'postgres', 'INSERT', 3304678);
INSERT INTO "ProdNac2021".logbd VALUES (891, '2021-04-13', 'postgres', 'INSERT', 3300014);
INSERT INTO "ProdNac2021".logbd VALUES (892, '2021-04-13', 'postgres', 'INSERT', 3300406);
INSERT INTO "ProdNac2021".logbd VALUES (893, '2021-04-13', 'postgres', 'INSERT', 3304382);
INSERT INTO "ProdNac2021".logbd VALUES (894, '2021-04-13', 'postgres', 'INSERT', 3304724);
INSERT INTO "ProdNac2021".logbd VALUES (895, '2021-04-13', 'postgres', 'INSERT', 3300946);
INSERT INTO "ProdNac2021".logbd VALUES (896, '2021-04-13', 'postgres', 'INSERT', 3300675);
INSERT INTO "ProdNac2021".logbd VALUES (897, '2021-04-13', 'postgres', 'INSERT', 3300066);
INSERT INTO "ProdNac2021".logbd VALUES (898, '2021-04-13', 'postgres', 'INSERT', 3300249);
INSERT INTO "ProdNac2021".logbd VALUES (899, '2021-04-13', 'postgres', 'INSERT', 3300017);
INSERT INTO "ProdNac2021".logbd VALUES (900, '2021-04-13', 'postgres', 'INSERT', 3304693);
INSERT INTO "ProdNac2021".logbd VALUES (901, '2021-04-13', 'postgres', 'INSERT', 3301001);
INSERT INTO "ProdNac2021".logbd VALUES (902, '2021-04-13', 'postgres', 'INSERT', 3300953);
INSERT INTO "ProdNac2021".logbd VALUES (903, '2021-04-13', 'postgres', 'INSERT', 3300630);
INSERT INTO "ProdNac2021".logbd VALUES (904, '2021-04-13', 'postgres', 'INSERT', 3300645);
INSERT INTO "ProdNac2021".logbd VALUES (905, '2021-04-13', 'postgres', 'INSERT', 3304443);
INSERT INTO "ProdNac2021".logbd VALUES (906, '2021-04-13', 'postgres', 'INSERT', 3301187);
INSERT INTO "ProdNac2021".logbd VALUES (907, '2021-04-13', 'postgres', 'INSERT', 3300091);
INSERT INTO "ProdNac2021".logbd VALUES (908, '2021-04-13', 'postgres', 'INSERT', 3300436);
INSERT INTO "ProdNac2021".logbd VALUES (909, '2021-04-13', 'postgres', 'INSERT', 3300239);
INSERT INTO "ProdNac2021".logbd VALUES (910, '2021-04-13', 'postgres', 'INSERT', 3300151);
INSERT INTO "ProdNac2021".logbd VALUES (911, '2021-04-13', 'postgres', 'INSERT', 3300132);
INSERT INTO "ProdNac2021".logbd VALUES (912, '2021-04-13', 'postgres', 'INSERT', 3300429);
INSERT INTO "ProdNac2021".logbd VALUES (913, '2021-04-13', 'postgres', 'INSERT', 3300289);
INSERT INTO "ProdNac2021".logbd VALUES (914, '2021-04-13', 'postgres', 'INSERT', 3304400);
INSERT INTO "ProdNac2021".logbd VALUES (915, '2021-04-13', 'postgres', 'INSERT', 3304755);
INSERT INTO "ProdNac2021".logbd VALUES (916, '2021-04-13', 'postgres', 'INSERT', 3300269);
INSERT INTO "ProdNac2021".logbd VALUES (917, '2021-04-13', 'postgres', 'INSERT', 3300815);
INSERT INTO "ProdNac2021".logbd VALUES (918, '2021-04-13', 'postgres', 'INSERT', 3300613);
INSERT INTO "ProdNac2021".logbd VALUES (919, '2021-04-13', 'postgres', 'INSERT', 3300227);
INSERT INTO "ProdNac2021".logbd VALUES (920, '2021-04-13', 'postgres', 'INSERT', 3304817);
INSERT INTO "ProdNac2021".logbd VALUES (921, '2021-04-13', 'postgres', 'INSERT', 3300584);
INSERT INTO "ProdNac2021".logbd VALUES (922, '2021-04-13', 'postgres', 'INSERT', 3300422);
INSERT INTO "ProdNac2021".logbd VALUES (923, '2021-04-13', 'postgres', 'INSERT', 3300586);
INSERT INTO "ProdNac2021".logbd VALUES (924, '2021-04-13', 'postgres', 'INSERT', 3304431);
INSERT INTO "ProdNac2021".logbd VALUES (925, '2021-04-13', 'postgres', 'INSERT', 3304581);
INSERT INTO "ProdNac2021".logbd VALUES (926, '2021-04-13', 'postgres', 'INSERT', 3300548);
INSERT INTO "ProdNac2021".logbd VALUES (927, '2021-04-13', 'postgres', 'INSERT', 3304933);
INSERT INTO "ProdNac2021".logbd VALUES (928, '2021-04-13', 'postgres', 'INSERT', 3300219);
INSERT INTO "ProdNac2021".logbd VALUES (929, '2021-04-13', 'postgres', 'INSERT', 3304343);
INSERT INTO "ProdNac2021".logbd VALUES (930, '2021-04-13', 'postgres', 'INSERT', 3301023);
INSERT INTO "ProdNac2021".logbd VALUES (931, '2021-04-13', 'postgres', 'INSERT', 3300950);
INSERT INTO "ProdNac2021".logbd VALUES (932, '2021-04-13', 'postgres', 'INSERT', 3300056);
INSERT INTO "ProdNac2021".logbd VALUES (933, '2021-04-13', 'postgres', 'INSERT', 3300404);
INSERT INTO "ProdNac2021".logbd VALUES (934, '2021-04-13', 'postgres', 'INSERT', 3300612);
INSERT INTO "ProdNac2021".logbd VALUES (935, '2021-04-13', 'postgres', 'INSERT', 3300327);
INSERT INTO "ProdNac2021".logbd VALUES (936, '2021-04-13', 'postgres', 'INSERT', 3300800);
INSERT INTO "ProdNac2021".logbd VALUES (937, '2021-04-13', 'postgres', 'INSERT', 3300971);
INSERT INTO "ProdNac2021".logbd VALUES (938, '2021-04-13', 'postgres', 'INSERT', 3304909);
INSERT INTO "ProdNac2021".logbd VALUES (939, '2021-04-13', 'postgres', 'INSERT', 3300458);
INSERT INTO "ProdNac2021".logbd VALUES (940, '2021-04-13', 'postgres', 'INSERT', 3304810);
INSERT INTO "ProdNac2021".logbd VALUES (941, '2021-04-13', 'postgres', 'INSERT', 3300727);
INSERT INTO "ProdNac2021".logbd VALUES (942, '2021-04-13', 'postgres', 'INSERT', 3300705);
INSERT INTO "ProdNac2021".logbd VALUES (943, '2021-04-13', 'postgres', 'INSERT', 3300485);
INSERT INTO "ProdNac2021".logbd VALUES (944, '2021-04-13', 'postgres', 'INSERT', 3300868);
INSERT INTO "ProdNac2021".logbd VALUES (945, '2021-04-13', 'postgres', 'INSERT', 3300236);
INSERT INTO "ProdNac2021".logbd VALUES (946, '2021-04-13', 'postgres', 'INSERT', 3300348);
INSERT INTO "ProdNac2021".logbd VALUES (947, '2021-04-13', 'postgres', 'INSERT', 3300009);
INSERT INTO "ProdNac2021".logbd VALUES (948, '2021-04-13', 'postgres', 'INSERT', 3301045);
INSERT INTO "ProdNac2021".logbd VALUES (949, '2021-04-13', 'postgres', 'INSERT', 3300222);
INSERT INTO "ProdNac2021".logbd VALUES (950, '2021-04-13', 'postgres', 'INSERT', 3304551);
INSERT INTO "ProdNac2021".logbd VALUES (951, '2021-04-13', 'postgres', 'INSERT', 3304811);
INSERT INTO "ProdNac2021".logbd VALUES (952, '2021-04-13', 'postgres', 'INSERT', 3300549);
INSERT INTO "ProdNac2021".logbd VALUES (953, '2021-04-13', 'postgres', 'INSERT', 3304890);
INSERT INTO "ProdNac2021".logbd VALUES (954, '2021-04-13', 'postgres', 'INSERT', 3304399);
INSERT INTO "ProdNac2021".logbd VALUES (955, '2021-04-13', 'postgres', 'INSERT', 3301138);
INSERT INTO "ProdNac2021".logbd VALUES (956, '2021-04-13', 'postgres', 'INSERT', 3301072);
INSERT INTO "ProdNac2021".logbd VALUES (957, '2021-04-13', 'postgres', 'INSERT', 3304992);
INSERT INTO "ProdNac2021".logbd VALUES (958, '2021-04-13', 'postgres', 'INSERT', 3300856);
INSERT INTO "ProdNac2021".logbd VALUES (959, '2021-04-13', 'postgres', 'INSERT', 3300781);
INSERT INTO "ProdNac2021".logbd VALUES (960, '2021-04-13', 'postgres', 'INSERT', 3300594);
INSERT INTO "ProdNac2021".logbd VALUES (961, '2021-04-13', 'postgres', 'INSERT', 3304721);
INSERT INTO "ProdNac2021".logbd VALUES (962, '2021-04-13', 'postgres', 'INSERT', 3300857);
INSERT INTO "ProdNac2021".logbd VALUES (963, '2021-04-13', 'postgres', 'INSERT', 3300546);
INSERT INTO "ProdNac2021".logbd VALUES (964, '2021-04-13', 'postgres', 'INSERT', 3300671);
INSERT INTO "ProdNac2021".logbd VALUES (965, '2021-04-13', 'postgres', 'INSERT', 3300431);
INSERT INTO "ProdNac2021".logbd VALUES (966, '2021-04-13', 'postgres', 'INSERT', 3300827);
INSERT INTO "ProdNac2021".logbd VALUES (967, '2021-04-13', 'postgres', 'INSERT', 3300740);
INSERT INTO "ProdNac2021".logbd VALUES (968, '2021-04-13', 'postgres', 'INSERT', 3300888);
INSERT INTO "ProdNac2021".logbd VALUES (969, '2021-04-13', 'postgres', 'INSERT', 3300285);
INSERT INTO "ProdNac2021".logbd VALUES (970, '2021-04-13', 'postgres', 'INSERT', 3300674);
INSERT INTO "ProdNac2021".logbd VALUES (971, '2021-04-13', 'postgres', 'INSERT', 3304884);
INSERT INTO "ProdNac2021".logbd VALUES (972, '2021-04-13', 'postgres', 'INSERT', 3300900);
INSERT INTO "ProdNac2021".logbd VALUES (973, '2021-04-13', 'postgres', 'INSERT', 3300580);
INSERT INTO "ProdNac2021".logbd VALUES (974, '2021-04-13', 'postgres', 'INSERT', 3300890);
INSERT INTO "ProdNac2021".logbd VALUES (975, '2021-04-13', 'postgres', 'INSERT', 3304339);
INSERT INTO "ProdNac2021".logbd VALUES (976, '2021-04-13', 'postgres', 'INSERT', 3304480);
INSERT INTO "ProdNac2021".logbd VALUES (977, '2021-04-13', 'postgres', 'INSERT', 3304661);
INSERT INTO "ProdNac2021".logbd VALUES (978, '2021-04-13', 'postgres', 'INSERT', 3304446);
INSERT INTO "ProdNac2021".logbd VALUES (979, '2021-04-13', 'postgres', 'INSERT', 3304759);
INSERT INTO "ProdNac2021".logbd VALUES (980, '2021-04-13', 'postgres', 'INSERT', 3304885);
INSERT INTO "ProdNac2021".logbd VALUES (981, '2021-04-13', 'postgres', 'INSERT', 3304419);
INSERT INTO "ProdNac2021".logbd VALUES (982, '2021-04-13', 'postgres', 'INSERT', 3304604);
INSERT INTO "ProdNac2021".logbd VALUES (983, '2021-04-13', 'postgres', 'INSERT', 3301132);
INSERT INTO "ProdNac2021".logbd VALUES (984, '2021-04-13', 'postgres', 'INSERT', 3304692);
INSERT INTO "ProdNac2021".logbd VALUES (985, '2021-04-13', 'postgres', 'INSERT', 3300371);
INSERT INTO "ProdNac2021".logbd VALUES (986, '2021-04-13', 'postgres', 'INSERT', 3304540);
INSERT INTO "ProdNac2021".logbd VALUES (987, '2021-04-13', 'postgres', 'INSERT', 3304791);
INSERT INTO "ProdNac2021".logbd VALUES (988, '2021-04-13', 'postgres', 'INSERT', 3304657);
INSERT INTO "ProdNac2021".logbd VALUES (989, '2021-04-13', 'postgres', 'INSERT', 3300176);
INSERT INTO "ProdNac2021".logbd VALUES (990, '2021-04-13', 'postgres', 'INSERT', 3300556);
INSERT INTO "ProdNac2021".logbd VALUES (991, '2021-04-13', 'postgres', 'INSERT', 3300676);
INSERT INTO "ProdNac2021".logbd VALUES (992, '2021-04-13', 'postgres', 'INSERT', 3300728);
INSERT INTO "ProdNac2021".logbd VALUES (993, '2021-04-13', 'postgres', 'INSERT', 3300582);
INSERT INTO "ProdNac2021".logbd VALUES (994, '2021-04-13', 'postgres', 'INSERT', 3300147);
INSERT INTO "ProdNac2021".logbd VALUES (995, '2021-04-13', 'postgres', 'INSERT', 3300167);
INSERT INTO "ProdNac2021".logbd VALUES (996, '2021-04-13', 'postgres', 'INSERT', 3304422);
INSERT INTO "ProdNac2021".logbd VALUES (997, '2021-04-13', 'postgres', 'INSERT', 3304796);
INSERT INTO "ProdNac2021".logbd VALUES (998, '2021-04-13', 'postgres', 'INSERT', 3304850);
INSERT INTO "ProdNac2021".logbd VALUES (999, '2021-04-13', 'postgres', 'INSERT', 3304350);
INSERT INTO "ProdNac2021".logbd VALUES (1000, '2021-04-13', 'postgres', 'INSERT', 3300116);
INSERT INTO "ProdNac2021".logbd VALUES (1001, '2021-04-13', 'postgres', 'INSERT', 3300798);
INSERT INTO "ProdNac2021".logbd VALUES (1002, '2021-04-13', 'postgres', 'INSERT', 3304665);
INSERT INTO "ProdNac2021".logbd VALUES (1003, '2021-04-13', 'postgres', 'INSERT', 3304394);
INSERT INTO "ProdNac2021".logbd VALUES (1004, '2021-04-13', 'postgres', 'INSERT', 3300067);
INSERT INTO "ProdNac2021".logbd VALUES (1005, '2021-04-13', 'postgres', 'INSERT', 3304717);
INSERT INTO "ProdNac2021".logbd VALUES (1006, '2021-04-13', 'postgres', 'INSERT', 3300931);
INSERT INTO "ProdNac2021".logbd VALUES (1007, '2021-04-13', 'postgres', 'INSERT', 3300554);
INSERT INTO "ProdNac2021".logbd VALUES (1008, '2021-04-13', 'postgres', 'INSERT', 3300974);
INSERT INTO "ProdNac2021".logbd VALUES (1009, '2021-04-13', 'postgres', 'INSERT', 3300185);
INSERT INTO "ProdNac2021".logbd VALUES (1010, '2021-04-13', 'postgres', 'INSERT', 3304638);
INSERT INTO "ProdNac2021".logbd VALUES (1011, '2021-04-13', 'postgres', 'INSERT', 3300403);
INSERT INTO "ProdNac2021".logbd VALUES (1012, '2021-04-13', 'postgres', 'INSERT', 3300207);
INSERT INTO "ProdNac2021".logbd VALUES (1013, '2021-04-13', 'postgres', 'INSERT', 3300657);
INSERT INTO "ProdNac2021".logbd VALUES (1014, '2021-04-13', 'postgres', 'INSERT', 3300782);
INSERT INTO "ProdNac2021".logbd VALUES (1015, '2021-04-13', 'postgres', 'INSERT', 3300201);
INSERT INTO "ProdNac2021".logbd VALUES (1016, '2021-04-13', 'postgres', 'INSERT', 3300414);
INSERT INTO "ProdNac2021".logbd VALUES (1017, '2021-04-13', 'postgres', 'INSERT', 3304668);
INSERT INTO "ProdNac2021".logbd VALUES (1018, '2021-04-13', 'postgres', 'INSERT', 3300682);
INSERT INTO "ProdNac2021".logbd VALUES (1019, '2021-04-13', 'postgres', 'INSERT', 3304983);
INSERT INTO "ProdNac2021".logbd VALUES (1020, '2021-04-13', 'postgres', 'INSERT', 3304336);
INSERT INTO "ProdNac2021".logbd VALUES (1021, '2021-04-13', 'postgres', 'INSERT', 3300454);
INSERT INTO "ProdNac2021".logbd VALUES (1022, '2021-04-13', 'postgres', 'INSERT', 3304486);
INSERT INTO "ProdNac2021".logbd VALUES (1023, '2021-04-13', 'postgres', 'INSERT', 3304802);
INSERT INTO "ProdNac2021".logbd VALUES (1024, '2021-04-13', 'postgres', 'INSERT', 3300076);
INSERT INTO "ProdNac2021".logbd VALUES (1025, '2021-04-13', 'postgres', 'INSERT', 3300265);
INSERT INTO "ProdNac2021".logbd VALUES (1026, '2021-04-13', 'postgres', 'INSERT', 3304467);
INSERT INTO "ProdNac2021".logbd VALUES (1027, '2021-04-13', 'postgres', 'INSERT', 3300378);
INSERT INTO "ProdNac2021".logbd VALUES (1028, '2021-04-13', 'postgres', 'INSERT', 3304577);
INSERT INTO "ProdNac2021".logbd VALUES (1029, '2021-04-13', 'postgres', 'INSERT', 3304803);
INSERT INTO "ProdNac2021".logbd VALUES (1030, '2021-04-13', 'postgres', 'INSERT', 3304943);
INSERT INTO "ProdNac2021".logbd VALUES (1031, '2021-04-13', 'postgres', 'INSERT', 3300742);
INSERT INTO "ProdNac2021".logbd VALUES (1032, '2021-04-13', 'postgres', 'INSERT', 3304651);
INSERT INTO "ProdNac2021".logbd VALUES (1033, '2021-04-13', 'postgres', 'INSERT', 3300503);
INSERT INTO "ProdNac2021".logbd VALUES (1034, '2021-04-13', 'postgres', 'INSERT', 3304939);
INSERT INTO "ProdNac2021".logbd VALUES (1035, '2021-04-13', 'postgres', 'INSERT', 3300784);
INSERT INTO "ProdNac2021".logbd VALUES (1036, '2021-04-13', 'postgres', 'INSERT', 3304345);
INSERT INTO "ProdNac2021".logbd VALUES (1037, '2021-04-13', 'postgres', 'INSERT', 3300530);
INSERT INTO "ProdNac2021".logbd VALUES (1038, '2021-04-13', 'postgres', 'INSERT', 3300836);
INSERT INTO "ProdNac2021".logbd VALUES (1039, '2021-04-13', 'postgres', 'INSERT', 3301061);
INSERT INTO "ProdNac2021".logbd VALUES (1040, '2021-04-13', 'postgres', 'INSERT', 3304357);
INSERT INTO "ProdNac2021".logbd VALUES (1041, '2021-04-13', 'postgres', 'INSERT', 3300193);
INSERT INTO "ProdNac2021".logbd VALUES (1042, '2021-04-13', 'postgres', 'INSERT', 3304332);
INSERT INTO "ProdNac2021".logbd VALUES (1043, '2021-04-13', 'postgres', 'INSERT', 3300255);
INSERT INTO "ProdNac2021".logbd VALUES (1044, '2021-04-13', 'postgres', 'INSERT', 3301097);
INSERT INTO "ProdNac2021".logbd VALUES (1045, '2021-04-13', 'postgres', 'INSERT', 3304901);
INSERT INTO "ProdNac2021".logbd VALUES (1046, '2021-04-13', 'postgres', 'INSERT', 3301218);
INSERT INTO "ProdNac2021".logbd VALUES (1047, '2021-04-13', 'postgres', 'INSERT', 3301219);
INSERT INTO "ProdNac2021".logbd VALUES (1048, '2021-04-13', 'postgres', 'INSERT', 3300990);
INSERT INTO "ProdNac2021".logbd VALUES (1049, '2021-04-13', 'postgres', 'INSERT', 3304632);
INSERT INTO "ProdNac2021".logbd VALUES (1050, '2021-04-13', 'postgres', 'INSERT', 3301123);
INSERT INTO "ProdNac2021".logbd VALUES (1051, '2021-04-13', 'postgres', 'INSERT', 3304792);
INSERT INTO "ProdNac2021".logbd VALUES (1052, '2021-04-13', 'postgres', 'INSERT', 3304873);
INSERT INTO "ProdNac2021".logbd VALUES (1053, '2021-04-13', 'postgres', 'INSERT', 3301158);
INSERT INTO "ProdNac2021".logbd VALUES (1054, '2021-04-13', 'postgres', 'INSERT', 3300787);
INSERT INTO "ProdNac2021".logbd VALUES (1055, '2021-04-13', 'postgres', 'INSERT', 3300720);
INSERT INTO "ProdNac2021".logbd VALUES (1056, '2021-04-13', 'postgres', 'INSERT', 3300317);
INSERT INTO "ProdNac2021".logbd VALUES (1057, '2021-04-13', 'postgres', 'INSERT', 3300254);
INSERT INTO "ProdNac2021".logbd VALUES (1058, '2021-04-13', 'postgres', 'INSERT', 3300275);
INSERT INTO "ProdNac2021".logbd VALUES (1059, '2021-04-13', 'postgres', 'INSERT', 3304497);
INSERT INTO "ProdNac2021".logbd VALUES (1060, '2021-04-13', 'postgres', 'INSERT', 3300795);
INSERT INTO "ProdNac2021".logbd VALUES (1061, '2021-04-13', 'postgres', 'INSERT', 3300814);
INSERT INTO "ProdNac2021".logbd VALUES (1062, '2021-04-13', 'postgres', 'INSERT', 3300500);
INSERT INTO "ProdNac2021".logbd VALUES (1063, '2021-04-13', 'postgres', 'INSERT', 3304590);
INSERT INTO "ProdNac2021".logbd VALUES (1064, '2021-04-13', 'postgres', 'INSERT', 3304860);
INSERT INTO "ProdNac2021".logbd VALUES (1065, '2021-04-13', 'postgres', 'INSERT', 3301124);
INSERT INTO "ProdNac2021".logbd VALUES (1066, '2021-04-13', 'postgres', 'INSERT', 3300155);
INSERT INTO "ProdNac2021".logbd VALUES (1067, '2021-04-13', 'postgres', 'INSERT', 3300174);
INSERT INTO "ProdNac2021".logbd VALUES (1068, '2021-04-13', 'postgres', 'INSERT', 3304979);
INSERT INTO "ProdNac2021".logbd VALUES (1069, '2021-04-13', 'postgres', 'INSERT', 3304762);
INSERT INTO "ProdNac2021".logbd VALUES (1070, '2021-04-13', 'postgres', 'INSERT', 3300354);
INSERT INTO "ProdNac2021".logbd VALUES (1071, '2021-04-13', 'postgres', 'INSERT', 3304533);
INSERT INTO "ProdNac2021".logbd VALUES (1072, '2021-04-13', 'postgres', 'INSERT', 3304390);
INSERT INTO "ProdNac2021".logbd VALUES (1073, '2021-04-13', 'postgres', 'INSERT', 3304942);
INSERT INTO "ProdNac2021".logbd VALUES (1074, '2021-04-13', 'postgres', 'INSERT', 3300468);
INSERT INTO "ProdNac2021".logbd VALUES (1075, '2021-04-13', 'postgres', 'INSERT', 3304460);
INSERT INTO "ProdNac2021".logbd VALUES (1076, '2021-04-13', 'postgres', 'INSERT', 3304917);
INSERT INTO "ProdNac2021".logbd VALUES (1077, '2021-04-13', 'postgres', 'INSERT', 3300826);
INSERT INTO "ProdNac2021".logbd VALUES (1078, '2021-04-13', 'postgres', 'INSERT', 3300133);
INSERT INTO "ProdNac2021".logbd VALUES (1079, '2021-04-13', 'postgres', 'INSERT', 3304725);
INSERT INTO "ProdNac2021".logbd VALUES (1080, '2021-04-13', 'postgres', 'INSERT', 3304968);
INSERT INTO "ProdNac2021".logbd VALUES (1081, '2021-04-13', 'postgres', 'INSERT', 3301002);
INSERT INTO "ProdNac2021".logbd VALUES (1082, '2021-04-13', 'postgres', 'INSERT', 3300692);
INSERT INTO "ProdNac2021".logbd VALUES (1083, '2021-04-13', 'postgres', 'INSERT', 3304494);
INSERT INTO "ProdNac2021".logbd VALUES (1084, '2021-04-13', 'postgres', 'INSERT', 3300242);
INSERT INTO "ProdNac2021".logbd VALUES (1085, '2021-04-13', 'postgres', 'INSERT', 3304625);
INSERT INTO "ProdNac2021".logbd VALUES (1086, '2021-04-13', 'postgres', 'INSERT', 3304781);
INSERT INTO "ProdNac2021".logbd VALUES (1087, '2021-04-13', 'postgres', 'INSERT', 3304971);
INSERT INTO "ProdNac2021".logbd VALUES (1088, '2021-04-13', 'postgres', 'INSERT', 3304634);
INSERT INTO "ProdNac2021".logbd VALUES (1089, '2021-04-13', 'postgres', 'INSERT', 3300968);
INSERT INTO "ProdNac2021".logbd VALUES (1090, '2021-04-13', 'postgres', 'INSERT', 3304659);
INSERT INTO "ProdNac2021".logbd VALUES (1091, '2021-04-13', 'postgres', 'INSERT', 3301174);
INSERT INTO "ProdNac2021".logbd VALUES (1092, '2021-04-13', 'postgres', 'INSERT', 3300195);
INSERT INTO "ProdNac2021".logbd VALUES (1093, '2021-04-13', 'postgres', 'INSERT', 3300366);
INSERT INTO "ProdNac2021".logbd VALUES (1094, '2021-04-13', 'postgres', 'INSERT', 3300177);
INSERT INTO "ProdNac2021".logbd VALUES (1095, '2021-04-13', 'postgres', 'INSERT', 3300874);
INSERT INTO "ProdNac2021".logbd VALUES (1096, '2021-04-13', 'postgres', 'INSERT', 3300932);
INSERT INTO "ProdNac2021".logbd VALUES (1097, '2021-04-13', 'postgres', 'INSERT', 3300445);
INSERT INTO "ProdNac2021".logbd VALUES (1098, '2021-04-13', 'postgres', 'INSERT', 3304502);
INSERT INTO "ProdNac2021".logbd VALUES (1099, '2021-04-13', 'postgres', 'INSERT', 3300411);
INSERT INTO "ProdNac2021".logbd VALUES (1100, '2021-04-13', 'postgres', 'INSERT', 3301022);
INSERT INTO "ProdNac2021".logbd VALUES (1101, '2021-04-13', 'postgres', 'INSERT', 3300736);
INSERT INTO "ProdNac2021".logbd VALUES (1102, '2021-04-13', 'postgres', 'INSERT', 3304798);
INSERT INTO "ProdNac2021".logbd VALUES (1103, '2021-04-13', 'postgres', 'INSERT', 3300410);
INSERT INTO "ProdNac2021".logbd VALUES (1104, '2021-04-13', 'postgres', 'INSERT', 3304558);
INSERT INTO "ProdNac2021".logbd VALUES (1105, '2021-04-13', 'postgres', 'INSERT', 3300461);
INSERT INTO "ProdNac2021".logbd VALUES (1106, '2021-04-13', 'postgres', 'INSERT', 3304539);
INSERT INTO "ProdNac2021".logbd VALUES (1107, '2021-04-13', 'postgres', 'INSERT', 3300936);
INSERT INTO "ProdNac2021".logbd VALUES (1108, '2021-04-13', 'postgres', 'INSERT', 3300625);
INSERT INTO "ProdNac2021".logbd VALUES (1109, '2021-04-13', 'postgres', 'INSERT', 3304445);
INSERT INTO "ProdNac2021".logbd VALUES (1110, '2021-04-13', 'postgres', 'INSERT', 3300595);
INSERT INTO "ProdNac2021".logbd VALUES (1111, '2021-04-13', 'postgres', 'INSERT', 3300391);
INSERT INTO "ProdNac2021".logbd VALUES (1112, '2021-04-13', 'postgres', 'INSERT', 3300456);
INSERT INTO "ProdNac2021".logbd VALUES (1113, '2021-04-13', 'postgres', 'INSERT', 3300609);
INSERT INTO "ProdNac2021".logbd VALUES (1114, '2021-04-13', 'postgres', 'INSERT', 3300980);
INSERT INTO "ProdNac2021".logbd VALUES (1115, '2021-04-13', 'postgres', 'INSERT', 3304513);
INSERT INTO "ProdNac2021".logbd VALUES (1116, '2021-04-13', 'postgres', 'INSERT', 3304973);
INSERT INTO "ProdNac2021".logbd VALUES (1117, '2021-04-13', 'postgres', 'INSERT', 3301081);
INSERT INTO "ProdNac2021".logbd VALUES (1118, '2021-04-13', 'postgres', 'INSERT', 3304560);
INSERT INTO "ProdNac2021".logbd VALUES (1119, '2021-04-13', 'postgres', 'INSERT', 3300279);
INSERT INTO "ProdNac2021".logbd VALUES (1120, '2021-04-13', 'postgres', 'INSERT', 3304824);
INSERT INTO "ProdNac2021".logbd VALUES (1121, '2021-04-13', 'postgres', 'INSERT', 3304906);
INSERT INTO "ProdNac2021".logbd VALUES (1122, '2021-04-13', 'postgres', 'INSERT', 3300732);
INSERT INTO "ProdNac2021".logbd VALUES (1123, '2021-04-13', 'postgres', 'INSERT', 3304974);
INSERT INTO "ProdNac2021".logbd VALUES (1124, '2021-04-13', 'postgres', 'INSERT', 3304700);
INSERT INTO "ProdNac2021".logbd VALUES (1125, '2021-04-13', 'postgres', 'INSERT', 3300372);
INSERT INTO "ProdNac2021".logbd VALUES (1126, '2021-04-13', 'postgres', 'INSERT', 3300120);
INSERT INTO "ProdNac2021".logbd VALUES (1127, '2021-04-13', 'postgres', 'INSERT', 3300247);
INSERT INTO "ProdNac2021".logbd VALUES (1128, '2021-04-13', 'postgres', 'INSERT', 3300253);
INSERT INTO "ProdNac2021".logbd VALUES (1129, '2021-04-13', 'postgres', 'INSERT', 3300846);
INSERT INTO "ProdNac2021".logbd VALUES (1130, '2021-04-13', 'postgres', 'INSERT', 3300960);
INSERT INTO "ProdNac2021".logbd VALUES (1131, '2021-04-13', 'postgres', 'INSERT', 3301109);
INSERT INTO "ProdNac2021".logbd VALUES (1132, '2021-04-13', 'postgres', 'INSERT', 3301164);
INSERT INTO "ProdNac2021".logbd VALUES (1133, '2021-04-13', 'postgres', 'INSERT', 3300344);
INSERT INTO "ProdNac2021".logbd VALUES (1134, '2021-04-13', 'postgres', 'INSERT', 3301005);
INSERT INTO "ProdNac2021".logbd VALUES (1135, '2021-04-13', 'postgres', 'INSERT', 3301140);
INSERT INTO "ProdNac2021".logbd VALUES (1136, '2021-04-13', 'postgres', 'INSERT', 3304451);
INSERT INTO "ProdNac2021".logbd VALUES (1137, '2021-04-13', 'postgres', 'INSERT', 3300616);
INSERT INTO "ProdNac2021".logbd VALUES (1138, '2021-04-13', 'postgres', 'INSERT', 3301054);
INSERT INTO "ProdNac2021".logbd VALUES (1139, '2021-04-13', 'postgres', 'INSERT', 3304707);
INSERT INTO "ProdNac2021".logbd VALUES (1140, '2021-04-13', 'postgres', 'INSERT', 3304844);
INSERT INTO "ProdNac2021".logbd VALUES (1141, '2021-04-13', 'postgres', 'INSERT', 3301058);
INSERT INTO "ProdNac2021".logbd VALUES (1142, '2021-04-13', 'postgres', 'INSERT', 3300550);
INSERT INTO "ProdNac2021".logbd VALUES (1143, '2021-04-13', 'postgres', 'INSERT', 3300145);
INSERT INTO "ProdNac2021".logbd VALUES (1144, '2021-04-13', 'postgres', 'INSERT', 3301197);
INSERT INTO "ProdNac2021".logbd VALUES (1145, '2021-04-13', 'postgres', 'INSERT', 3300345);
INSERT INTO "ProdNac2021".logbd VALUES (1146, '2021-04-13', 'postgres', 'INSERT', 3300462);
INSERT INTO "ProdNac2021".logbd VALUES (1147, '2021-04-13', 'postgres', 'INSERT', 3300137);
INSERT INTO "ProdNac2021".logbd VALUES (1148, '2021-04-13', 'postgres', 'INSERT', 3300726);
INSERT INTO "ProdNac2021".logbd VALUES (1149, '2021-04-13', 'postgres', 'INSERT', 3304628);
INSERT INTO "ProdNac2021".logbd VALUES (1150, '2021-04-13', 'postgres', 'INSERT', 3300525);
INSERT INTO "ProdNac2021".logbd VALUES (1151, '2021-04-13', 'postgres', 'INSERT', 3300246);
INSERT INTO "ProdNac2021".logbd VALUES (1152, '2021-04-13', 'postgres', 'INSERT', 3304388);
INSERT INTO "ProdNac2021".logbd VALUES (1153, '2021-04-13', 'postgres', 'INSERT', 3304749);
INSERT INTO "ProdNac2021".logbd VALUES (1154, '2021-04-13', 'postgres', 'INSERT', 3300544);
INSERT INTO "ProdNac2021".logbd VALUES (1155, '2021-04-13', 'postgres', 'INSERT', 3300731);
INSERT INTO "ProdNac2021".logbd VALUES (1156, '2021-04-13', 'postgres', 'INSERT', 3300015);
INSERT INTO "ProdNac2021".logbd VALUES (1157, '2021-04-13', 'postgres', 'INSERT', 3300930);
INSERT INTO "ProdNac2021".logbd VALUES (1158, '2021-04-13', 'postgres', 'INSERT', 3300904);
INSERT INTO "ProdNac2021".logbd VALUES (1159, '2021-04-13', 'postgres', 'INSERT', 3300729);
INSERT INTO "ProdNac2021".logbd VALUES (1160, '2021-04-13', 'postgres', 'INSERT', 3300643);
INSERT INTO "ProdNac2021".logbd VALUES (1161, '2021-04-13', 'postgres', 'INSERT', 3300252);
INSERT INTO "ProdNac2021".logbd VALUES (1162, '2021-04-13', 'postgres', 'INSERT', 3300983);
INSERT INTO "ProdNac2021".logbd VALUES (1163, '2021-04-13', 'postgres', 'INSERT', 3304377);
INSERT INTO "ProdNac2021".logbd VALUES (1164, '2021-04-13', 'postgres', 'INSERT', 3304854);
INSERT INTO "ProdNac2021".logbd VALUES (1165, '2021-04-13', 'postgres', 'INSERT', 3300639);
INSERT INTO "ProdNac2021".logbd VALUES (1166, '2021-04-13', 'postgres', 'INSERT', 3304777);
INSERT INTO "ProdNac2021".logbd VALUES (1167, '2021-04-13', 'postgres', 'INSERT', 3300825);
INSERT INTO "ProdNac2021".logbd VALUES (1168, '2021-04-13', 'postgres', 'INSERT', 3304649);
INSERT INTO "ProdNac2021".logbd VALUES (1169, '2021-04-13', 'postgres', 'INSERT', 3304652);
INSERT INTO "ProdNac2021".logbd VALUES (1170, '2021-04-13', 'postgres', 'INSERT', 3304666);
INSERT INTO "ProdNac2021".logbd VALUES (1171, '2021-04-13', 'postgres', 'INSERT', 3300512);
INSERT INTO "ProdNac2021".logbd VALUES (1172, '2021-04-13', 'postgres', 'INSERT', 3301101);
INSERT INTO "ProdNac2021".logbd VALUES (1173, '2021-04-13', 'postgres', 'INSERT', 3304709);
INSERT INTO "ProdNac2021".logbd VALUES (1174, '2021-04-13', 'postgres', 'INSERT', 3304706);
INSERT INTO "ProdNac2021".logbd VALUES (1175, '2021-04-13', 'postgres', 'INSERT', 3304342);
INSERT INTO "ProdNac2021".logbd VALUES (1176, '2021-04-13', 'postgres', 'INSERT', 3300386);
INSERT INTO "ProdNac2021".logbd VALUES (1177, '2021-04-13', 'postgres', 'INSERT', 3300188);
INSERT INTO "ProdNac2021".logbd VALUES (1178, '2021-04-13', 'postgres', 'INSERT', 3300710);
INSERT INTO "ProdNac2021".logbd VALUES (1179, '2021-04-13', 'postgres', 'INSERT', 3300938);
INSERT INTO "ProdNac2021".logbd VALUES (1180, '2021-04-13', 'postgres', 'INSERT', 3300559);
INSERT INTO "ProdNac2021".logbd VALUES (1181, '2021-04-13', 'postgres', 'INSERT', 3300755);
INSERT INTO "ProdNac2021".logbd VALUES (1182, '2021-04-13', 'postgres', 'INSERT', 3300808);
INSERT INTO "ProdNac2021".logbd VALUES (1183, '2021-04-13', 'postgres', 'INSERT', 3300862);
INSERT INTO "ProdNac2021".logbd VALUES (1184, '2021-04-13', 'postgres', 'INSERT', 3300241);
INSERT INTO "ProdNac2021".logbd VALUES (1185, '2021-04-13', 'postgres', 'INSERT', 3300248);
INSERT INTO "ProdNac2021".logbd VALUES (1186, '2021-04-13', 'postgres', 'INSERT', 3300200);
INSERT INTO "ProdNac2021".logbd VALUES (1187, '2021-04-13', 'postgres', 'INSERT', 3300483);
INSERT INTO "ProdNac2021".logbd VALUES (1188, '2021-04-13', 'postgres', 'INSERT', 3304461);
INSERT INTO "ProdNac2021".logbd VALUES (1189, '2021-04-13', 'postgres', 'INSERT', 3304631);
INSERT INTO "ProdNac2021".logbd VALUES (1190, '2021-04-13', 'postgres', 'INSERT', 3301210);
INSERT INTO "ProdNac2021".logbd VALUES (1191, '2021-04-13', 'postgres', 'INSERT', 3300850);
INSERT INTO "ProdNac2021".logbd VALUES (1192, '2021-04-13', 'postgres', 'INSERT', 3300113);
INSERT INTO "ProdNac2021".logbd VALUES (1193, '2021-04-13', 'postgres', 'INSERT', 3300517);
INSERT INTO "ProdNac2021".logbd VALUES (1194, '2021-04-13', 'postgres', 'INSERT', 3301180);
INSERT INTO "ProdNac2021".logbd VALUES (1195, '2021-04-13', 'postgres', 'INSERT', 3301135);
INSERT INTO "ProdNac2021".logbd VALUES (1196, '2021-04-13', 'postgres', 'INSERT', 3300764);
INSERT INTO "ProdNac2021".logbd VALUES (1197, '2021-04-13', 'postgres', 'INSERT', 3300813);
INSERT INTO "ProdNac2021".logbd VALUES (1198, '2021-04-13', 'postgres', 'INSERT', 3304348);
INSERT INTO "ProdNac2021".logbd VALUES (1199, '2021-04-13', 'postgres', 'INSERT', 3300805);
INSERT INTO "ProdNac2021".logbd VALUES (1200, '2021-04-13', 'postgres', 'INSERT', 3304472);
INSERT INTO "ProdNac2021".logbd VALUES (1201, '2021-04-13', 'postgres', 'INSERT', 3304893);
INSERT INTO "ProdNac2021".logbd VALUES (1202, '2021-04-13', 'postgres', 'INSERT', 3301190);
INSERT INTO "ProdNac2021".logbd VALUES (1203, '2021-04-13', 'postgres', 'INSERT', 3304839);
INSERT INTO "ProdNac2021".logbd VALUES (1204, '2021-04-13', 'postgres', 'INSERT', 3300518);
INSERT INTO "ProdNac2021".logbd VALUES (1205, '2021-04-13', 'postgres', 'INSERT', 3300587);
INSERT INTO "ProdNac2021".logbd VALUES (1206, '2021-04-13', 'postgres', 'INSERT', 3300001);
INSERT INTO "ProdNac2021".logbd VALUES (1207, '2021-04-13', 'postgres', 'INSERT', 3304479);
INSERT INTO "ProdNac2021".logbd VALUES (1208, '2021-04-13', 'postgres', 'INSERT', 3301136);
INSERT INTO "ProdNac2021".logbd VALUES (1209, '2021-04-13', 'postgres', 'INSERT', 3304404);
INSERT INTO "ProdNac2021".logbd VALUES (1210, '2021-04-13', 'postgres', 'INSERT', 3304569);
INSERT INTO "ProdNac2021".logbd VALUES (1211, '2021-04-13', 'postgres', 'INSERT', 3304605);
INSERT INTO "ProdNac2021".logbd VALUES (1212, '2021-04-13', 'postgres', 'INSERT', 3304374);
INSERT INTO "ProdNac2021".logbd VALUES (1213, '2021-04-13', 'postgres', 'INSERT', 3304794);
INSERT INTO "ProdNac2021".logbd VALUES (1214, '2021-04-13', 'postgres', 'INSERT', 3300673);
INSERT INTO "ProdNac2021".logbd VALUES (1215, '2021-04-13', 'postgres', 'INSERT', 3300817);
INSERT INTO "ProdNac2021".logbd VALUES (1216, '2021-04-13', 'postgres', 'INSERT', 3300775);
INSERT INTO "ProdNac2021".logbd VALUES (1217, '2021-04-13', 'postgres', 'INSERT', 3300104);
INSERT INTO "ProdNac2021".logbd VALUES (1218, '2021-04-13', 'postgres', 'INSERT', 3301125);
INSERT INTO "ProdNac2021".logbd VALUES (1219, '2021-04-13', 'postgres', 'INSERT', 3304594);
INSERT INTO "ProdNac2021".logbd VALUES (1220, '2021-04-13', 'postgres', 'INSERT', 3300226);
INSERT INTO "ProdNac2021".logbd VALUES (1221, '2021-04-13', 'postgres', 'INSERT', 3300698);
INSERT INTO "ProdNac2021".logbd VALUES (1222, '2021-04-13', 'postgres', 'INSERT', 3300538);
INSERT INTO "ProdNac2021".logbd VALUES (1223, '2021-04-13', 'postgres', 'INSERT', 3304799);
INSERT INTO "ProdNac2021".logbd VALUES (1224, '2021-04-13', 'postgres', 'INSERT', 3304525);
INSERT INTO "ProdNac2021".logbd VALUES (1225, '2021-04-13', 'postgres', 'INSERT', 3300349);
INSERT INTO "ProdNac2021".logbd VALUES (1226, '2021-04-13', 'postgres', 'INSERT', 3304535);
INSERT INTO "ProdNac2021".logbd VALUES (1227, '2021-04-13', 'postgres', 'INSERT', 3300129);
INSERT INTO "ProdNac2021".logbd VALUES (1228, '2021-04-13', 'postgres', 'INSERT', 3300724);
INSERT INTO "ProdNac2021".logbd VALUES (1229, '2021-04-13', 'postgres', 'INSERT', 3300202);
INSERT INTO "ProdNac2021".logbd VALUES (1230, '2021-04-13', 'postgres', 'INSERT', 3304913);
INSERT INTO "ProdNac2021".logbd VALUES (1231, '2021-04-13', 'postgres', 'INSERT', 3300557);
INSERT INTO "ProdNac2021".logbd VALUES (1232, '2021-04-13', 'postgres', 'INSERT', 3301106);
INSERT INTO "ProdNac2021".logbd VALUES (1233, '2021-04-13', 'postgres', 'INSERT', 3300452);
INSERT INTO "ProdNac2021".logbd VALUES (1234, '2021-04-13', 'postgres', 'INSERT', 3301007);
INSERT INTO "ProdNac2021".logbd VALUES (1235, '2021-04-13', 'postgres', 'INSERT', 3300488);
INSERT INTO "ProdNac2021".logbd VALUES (1236, '2021-04-13', 'postgres', 'INSERT', 3300540);
INSERT INTO "ProdNac2021".logbd VALUES (1237, '2021-04-13', 'postgres', 'INSERT', 3300126);
INSERT INTO "ProdNac2021".logbd VALUES (1238, '2021-04-13', 'postgres', 'INSERT', 3304959);
INSERT INTO "ProdNac2021".logbd VALUES (1239, '2021-04-13', 'postgres', 'INSERT', 3300465);
INSERT INTO "ProdNac2021".logbd VALUES (1240, '2021-04-13', 'postgres', 'INSERT', 3300493);
INSERT INTO "ProdNac2021".logbd VALUES (1241, '2021-04-13', 'postgres', 'INSERT', 3300234);
INSERT INTO "ProdNac2021".logbd VALUES (1242, '2021-04-13', 'postgres', 'INSERT', 3300885);
INSERT INTO "ProdNac2021".logbd VALUES (1243, '2021-04-13', 'postgres', 'INSERT', 3304960);
INSERT INTO "ProdNac2021".logbd VALUES (1244, '2021-04-13', 'postgres', 'INSERT', 3304985);
INSERT INTO "ProdNac2021".logbd VALUES (1245, '2021-04-13', 'postgres', 'INSERT', 3304883);
INSERT INTO "ProdNac2021".logbd VALUES (1246, '2021-04-13', 'postgres', 'INSERT', 3300633);
INSERT INTO "ProdNac2021".logbd VALUES (1247, '2021-04-13', 'postgres', 'INSERT', 3301086);
INSERT INTO "ProdNac2021".logbd VALUES (1248, '2021-04-13', 'postgres', 'INSERT', 3304492);
INSERT INTO "ProdNac2021".logbd VALUES (1249, '2021-04-13', 'postgres', 'INSERT', 3304862);
INSERT INTO "ProdNac2021".logbd VALUES (1250, '2021-04-13', 'postgres', 'INSERT', 3301156);
INSERT INTO "ProdNac2021".logbd VALUES (1251, '2021-04-13', 'postgres', 'INSERT', 3300615);
INSERT INTO "ProdNac2021".logbd VALUES (1252, '2021-04-13', 'postgres', 'INSERT', 3300181);
INSERT INTO "ProdNac2021".logbd VALUES (1253, '2021-04-13', 'postgres', 'INSERT', 3300746);
INSERT INTO "ProdNac2021".logbd VALUES (1254, '2021-04-13', 'postgres', 'INSERT', 3300806);
INSERT INTO "ProdNac2021".logbd VALUES (1255, '2021-04-13', 'postgres', 'INSERT', 3300346);
INSERT INTO "ProdNac2021".logbd VALUES (1256, '2021-04-13', 'postgres', 'INSERT', 3300330);
INSERT INTO "ProdNac2021".logbd VALUES (1257, '2021-04-13', 'postgres', 'INSERT', 3300425);
INSERT INTO "ProdNac2021".logbd VALUES (1258, '2021-04-13', 'postgres', 'INSERT', 3301209);
INSERT INTO "ProdNac2021".logbd VALUES (1259, '2021-04-13', 'postgres', 'INSERT', 3301112);
INSERT INTO "ProdNac2021".logbd VALUES (1260, '2021-04-13', 'postgres', 'INSERT', 3301183);
INSERT INTO "ProdNac2021".logbd VALUES (1261, '2021-04-13', 'postgres', 'INSERT', 3304589);
INSERT INTO "ProdNac2021".logbd VALUES (1262, '2021-04-13', 'postgres', 'INSERT', 3300553);
INSERT INTO "ProdNac2021".logbd VALUES (1263, '2021-04-13', 'postgres', 'INSERT', 3300033);
INSERT INTO "ProdNac2021".logbd VALUES (1264, '2021-04-13', 'postgres', 'INSERT', 3304667);
INSERT INTO "ProdNac2021".logbd VALUES (1265, '2021-04-13', 'postgres', 'INSERT', 3304852);
INSERT INTO "ProdNac2021".logbd VALUES (1266, '2021-04-13', 'postgres', 'INSERT', 3304981);
INSERT INTO "ProdNac2021".logbd VALUES (1267, '2021-04-13', 'postgres', 'INSERT', 3304779);
INSERT INTO "ProdNac2021".logbd VALUES (1268, '2021-04-13', 'postgres', 'INSERT', 3304984);
INSERT INTO "ProdNac2021".logbd VALUES (1269, '2021-04-13', 'postgres', 'INSERT', 3304614);
INSERT INTO "ProdNac2021".logbd VALUES (1270, '2021-04-13', 'postgres', 'INSERT', 3304504);
INSERT INTO "ProdNac2021".logbd VALUES (1271, '2021-04-13', 'postgres', 'INSERT', 3304869);
INSERT INTO "ProdNac2021".logbd VALUES (1272, '2021-04-13', 'postgres', 'INSERT', 3304820);
INSERT INTO "ProdNac2021".logbd VALUES (1273, '2021-04-13', 'postgres', 'INSERT', 3300528);
INSERT INTO "ProdNac2021".logbd VALUES (1274, '2021-04-13', 'postgres', 'INSERT', 3300962);
INSERT INTO "ProdNac2021".logbd VALUES (1275, '2021-04-13', 'postgres', 'INSERT', 3300797);
INSERT INTO "ProdNac2021".logbd VALUES (1276, '2021-04-13', 'postgres', 'INSERT', 3300791);
INSERT INTO "ProdNac2021".logbd VALUES (1277, '2021-04-13', 'postgres', 'INSERT', 3300605);
INSERT INTO "ProdNac2021".logbd VALUES (1278, '2021-04-13', 'postgres', 'INSERT', 3300947);
INSERT INTO "ProdNac2021".logbd VALUES (1279, '2021-04-13', 'postgres', 'INSERT', 3301032);
INSERT INTO "ProdNac2021".logbd VALUES (1280, '2021-04-13', 'postgres', 'INSERT', 3304544);
INSERT INTO "ProdNac2021".logbd VALUES (1281, '2021-04-13', 'postgres', 'INSERT', 3300880);
INSERT INTO "ProdNac2021".logbd VALUES (1282, '2021-04-13', 'postgres', 'INSERT', 3300774);
INSERT INTO "ProdNac2021".logbd VALUES (1283, '2021-04-13', 'postgres', 'INSERT', 3300969);
INSERT INTO "ProdNac2021".logbd VALUES (1284, '2021-04-13', 'postgres', 'INSERT', 3304471);
INSERT INTO "ProdNac2021".logbd VALUES (1285, '2021-04-13', 'postgres', 'INSERT', 3304546);
INSERT INTO "ProdNac2021".logbd VALUES (1286, '2021-04-13', 'postgres', 'INSERT', 3300029);
INSERT INTO "ProdNac2021".logbd VALUES (1287, '2021-04-13', 'postgres', 'INSERT', 3301003);
INSERT INTO "ProdNac2021".logbd VALUES (1288, '2021-04-13', 'postgres', 'INSERT', 3300758);
INSERT INTO "ProdNac2021".logbd VALUES (1289, '2021-04-13', 'postgres', 'INSERT', 3300170);
INSERT INTO "ProdNac2021".logbd VALUES (1290, '2021-04-13', 'postgres', 'INSERT', 3304690);
INSERT INTO "ProdNac2021".logbd VALUES (1291, '2021-04-13', 'postgres', 'INSERT', 3301202);
INSERT INTO "ProdNac2021".logbd VALUES (1292, '2021-04-13', 'postgres', 'INSERT', 3304805);
INSERT INTO "ProdNac2021".logbd VALUES (1293, '2021-04-13', 'postgres', 'INSERT', 3300522);
INSERT INTO "ProdNac2021".logbd VALUES (1294, '2021-04-13', 'postgres', 'INSERT', 3300401);
INSERT INTO "ProdNac2021".logbd VALUES (1295, '2021-04-13', 'postgres', 'INSERT', 3300433);
INSERT INTO "ProdNac2021".logbd VALUES (1296, '2021-04-13', 'postgres', 'INSERT', 3304829);
INSERT INTO "ProdNac2021".logbd VALUES (1297, '2021-04-13', 'postgres', 'INSERT', 3304929);
INSERT INTO "ProdNac2021".logbd VALUES (1298, '2021-04-13', 'postgres', 'INSERT', 3301144);
INSERT INTO "ProdNac2021".logbd VALUES (1299, '2021-04-13', 'postgres', 'INSERT', 3300934);
INSERT INTO "ProdNac2021".logbd VALUES (1300, '2021-04-13', 'postgres', 'INSERT', 3301013);
INSERT INTO "ProdNac2021".logbd VALUES (1301, '2021-04-13', 'postgres', 'INSERT', 3304568);
INSERT INTO "ProdNac2021".logbd VALUES (1302, '2021-04-13', 'postgres', 'INSERT', 3301069);
INSERT INTO "ProdNac2021".logbd VALUES (1303, '2021-04-13', 'postgres', 'INSERT', 3300238);
INSERT INTO "ProdNac2021".logbd VALUES (1304, '2021-04-13', 'postgres', 'INSERT', 3304550);
INSERT INTO "ProdNac2021".logbd VALUES (1305, '2021-04-13', 'postgres', 'INSERT', 3304662);
INSERT INTO "ProdNac2021".logbd VALUES (1306, '2021-04-13', 'postgres', 'INSERT', 3300689);
INSERT INTO "ProdNac2021".logbd VALUES (1307, '2021-04-13', 'postgres', 'INSERT', 3300047);
INSERT INTO "ProdNac2021".logbd VALUES (1308, '2021-04-13', 'postgres', 'INSERT', 3300370);
INSERT INTO "ProdNac2021".logbd VALUES (1309, '2021-04-13', 'postgres', 'INSERT', 3301154);
INSERT INTO "ProdNac2021".logbd VALUES (1310, '2021-04-13', 'postgres', 'INSERT', 3304940);
INSERT INTO "ProdNac2021".logbd VALUES (1311, '2021-04-13', 'postgres', 'INSERT', 3300558);
INSERT INTO "ProdNac2021".logbd VALUES (1312, '2021-04-13', 'postgres', 'INSERT', 3301193);
INSERT INTO "ProdNac2021".logbd VALUES (1313, '2021-04-13', 'postgres', 'INSERT', 3300722);
INSERT INTO "ProdNac2021".logbd VALUES (1314, '2021-04-13', 'postgres', 'INSERT', 3301211);
INSERT INTO "ProdNac2021".logbd VALUES (1315, '2021-04-13', 'postgres', 'INSERT', 3304896);
INSERT INTO "ProdNac2021".logbd VALUES (1316, '2021-04-13', 'postgres', 'INSERT', 3300730);
INSERT INTO "ProdNac2021".logbd VALUES (1317, '2021-04-13', 'postgres', 'INSERT', 3300672);
INSERT INTO "ProdNac2021".logbd VALUES (1318, '2021-04-13', 'postgres', 'INSERT', 3304457);
INSERT INTO "ProdNac2021".logbd VALUES (1319, '2021-04-13', 'postgres', 'INSERT', 3300952);
INSERT INTO "ProdNac2021".logbd VALUES (1320, '2021-04-13', 'postgres', 'INSERT', 3304858);
INSERT INTO "ProdNac2021".logbd VALUES (1321, '2021-04-13', 'postgres', 'INSERT', 3300578);
INSERT INTO "ProdNac2021".logbd VALUES (1322, '2021-04-13', 'postgres', 'INSERT', 3300539);
INSERT INTO "ProdNac2021".logbd VALUES (1323, '2021-04-13', 'postgres', 'INSERT', 3304923);
INSERT INTO "ProdNac2021".logbd VALUES (1324, '2021-04-13', 'postgres', 'INSERT', 3300149);
INSERT INTO "ProdNac2021".logbd VALUES (1325, '2021-04-13', 'postgres', 'INSERT', 3300679);
INSERT INTO "ProdNac2021".logbd VALUES (1326, '2021-04-13', 'postgres', 'INSERT', 3300744);
INSERT INTO "ProdNac2021".logbd VALUES (1327, '2021-04-13', 'postgres', 'INSERT', 3300823);
INSERT INTO "ProdNac2021".logbd VALUES (1328, '2021-04-13', 'postgres', 'INSERT', 3304398);
INSERT INTO "ProdNac2021".logbd VALUES (1329, '2021-04-13', 'postgres', 'INSERT', 3300003);
INSERT INTO "ProdNac2021".logbd VALUES (1330, '2021-04-13', 'postgres', 'INSERT', 3300373);
INSERT INTO "ProdNac2021".logbd VALUES (1331, '2021-04-13', 'postgres', 'INSERT', 3301071);
INSERT INTO "ProdNac2021".logbd VALUES (1332, '2021-04-13', 'postgres', 'INSERT', 3301057);
INSERT INTO "ProdNac2021".logbd VALUES (1333, '2021-04-13', 'postgres', 'INSERT', 3300532);
INSERT INTO "ProdNac2021".logbd VALUES (1334, '2021-04-13', 'postgres', 'INSERT', 3301015);
INSERT INTO "ProdNac2021".logbd VALUES (1335, '2021-04-13', 'postgres', 'INSERT', 3304780);
INSERT INTO "ProdNac2021".logbd VALUES (1336, '2021-04-13', 'postgres', 'INSERT', 3304821);
INSERT INTO "ProdNac2021".logbd VALUES (1337, '2021-04-13', 'postgres', 'INSERT', 3300408);
INSERT INTO "ProdNac2021".logbd VALUES (1338, '2021-04-13', 'postgres', 'INSERT', 3300955);
INSERT INTO "ProdNac2021".logbd VALUES (1339, '2021-04-13', 'postgres', 'INSERT', 3300480);
INSERT INTO "ProdNac2021".logbd VALUES (1340, '2021-04-13', 'postgres', 'INSERT', 3304899);
INSERT INTO "ProdNac2021".logbd VALUES (1341, '2021-04-13', 'postgres', 'INSERT', 3304428);
INSERT INTO "ProdNac2021".logbd VALUES (1342, '2021-04-13', 'postgres', 'INSERT', 3300870);
INSERT INTO "ProdNac2021".logbd VALUES (1343, '2021-04-13', 'postgres', 'INSERT', 3300785);
INSERT INTO "ProdNac2021".logbd VALUES (1344, '2021-04-13', 'postgres', 'INSERT', 3300899);
INSERT INTO "ProdNac2021".logbd VALUES (1345, '2021-04-13', 'postgres', 'INSERT', 3300571);
INSERT INTO "ProdNac2021".logbd VALUES (1346, '2021-04-13', 'postgres', 'INSERT', 3304442);
INSERT INTO "ProdNac2021".logbd VALUES (1347, '2021-04-13', 'postgres', 'INSERT', 3304462);
INSERT INTO "ProdNac2021".logbd VALUES (1348, '2021-04-13', 'postgres', 'INSERT', 3300394);
INSERT INTO "ProdNac2021".logbd VALUES (1349, '2021-04-13', 'postgres', 'INSERT', 3300028);
INSERT INTO "ProdNac2021".logbd VALUES (1350, '2021-04-13', 'postgres', 'INSERT', 3300162);
INSERT INTO "ProdNac2021".logbd VALUES (1351, '2021-04-13', 'postgres', 'INSERT', 3304329);
INSERT INTO "ProdNac2021".logbd VALUES (1352, '2021-04-13', 'postgres', 'INSERT', 3304549);
INSERT INTO "ProdNac2021".logbd VALUES (1353, '2021-04-13', 'postgres', 'INSERT', 3304783);
INSERT INTO "ProdNac2021".logbd VALUES (1354, '2021-04-13', 'postgres', 'INSERT', 3301102);
INSERT INTO "ProdNac2021".logbd VALUES (1355, '2021-04-13', 'postgres', 'INSERT', 3304384);
INSERT INTO "ProdNac2021".logbd VALUES (1356, '2021-04-13', 'postgres', 'INSERT', 3304826);
INSERT INTO "ProdNac2021".logbd VALUES (1357, '2021-04-13', 'postgres', 'INSERT', 3304699);
INSERT INTO "ProdNac2021".logbd VALUES (1358, '2021-04-13', 'postgres', 'INSERT', 3304701);
INSERT INTO "ProdNac2021".logbd VALUES (1359, '2021-04-13', 'postgres', 'INSERT', 3300387);
INSERT INTO "ProdNac2021".logbd VALUES (1360, '2021-04-13', 'postgres', 'INSERT', 3300303);
INSERT INTO "ProdNac2021".logbd VALUES (1361, '2021-04-13', 'postgres', 'INSERT', 3301222);
INSERT INTO "ProdNac2021".logbd VALUES (1362, '2021-04-13', 'postgres', 'INSERT', 3300669);
INSERT INTO "ProdNac2021".logbd VALUES (1363, '2021-04-13', 'postgres', 'INSERT', 3304989);
INSERT INTO "ProdNac2021".logbd VALUES (1364, '2021-04-13', 'postgres', 'INSERT', 3304522);
INSERT INTO "ProdNac2021".logbd VALUES (1365, '2021-04-13', 'postgres', 'INSERT', 3304867);
INSERT INTO "ProdNac2021".logbd VALUES (1366, '2021-04-13', 'postgres', 'INSERT', 3300061);
INSERT INTO "ProdNac2021".logbd VALUES (1367, '2021-04-13', 'postgres', 'INSERT', 3304584);
INSERT INTO "ProdNac2021".logbd VALUES (1368, '2021-04-13', 'postgres', 'INSERT', 3304473);
INSERT INTO "ProdNac2021".logbd VALUES (1369, '2021-04-13', 'postgres', 'INSERT', 3304640);
INSERT INTO "ProdNac2021".logbd VALUES (1370, '2021-04-13', 'postgres', 'INSERT', 3300473);
INSERT INTO "ProdNac2021".logbd VALUES (1371, '2021-04-13', 'postgres', 'INSERT', 3300043);
INSERT INTO "ProdNac2021".logbd VALUES (1372, '2021-04-13', 'postgres', 'INSERT', 3301079);
INSERT INTO "ProdNac2021".logbd VALUES (1373, '2021-04-13', 'postgres', 'INSERT', 3304575);
INSERT INTO "ProdNac2021".logbd VALUES (1374, '2021-04-13', 'postgres', 'INSERT', 3301068);
INSERT INTO "ProdNac2021".logbd VALUES (1375, '2021-04-13', 'postgres', 'INSERT', 3300499);
INSERT INTO "ProdNac2021".logbd VALUES (1376, '2021-04-13', 'postgres', 'INSERT', 3300020);
INSERT INTO "ProdNac2021".logbd VALUES (1377, '2021-04-13', 'postgres', 'INSERT', 3300305);
INSERT INTO "ProdNac2021".logbd VALUES (1378, '2021-04-13', 'postgres', 'INSERT', 3301142);
INSERT INTO "ProdNac2021".logbd VALUES (1379, '2021-04-13', 'postgres', 'INSERT', 3304429);
INSERT INTO "ProdNac2021".logbd VALUES (1380, '2021-04-13', 'postgres', 'INSERT', 3304886);
INSERT INTO "ProdNac2021".logbd VALUES (1381, '2021-04-13', 'postgres', 'INSERT', 3300901);
INSERT INTO "ProdNac2021".logbd VALUES (1382, '2021-04-13', 'postgres', 'INSERT', 3304495);
INSERT INTO "ProdNac2021".logbd VALUES (1383, '2021-04-13', 'postgres', 'INSERT', 3300733);
INSERT INTO "ProdNac2021".logbd VALUES (1384, '2021-04-13', 'postgres', 'INSERT', 3301176);
INSERT INTO "ProdNac2021".logbd VALUES (1385, '2021-04-13', 'postgres', 'INSERT', 3300816);
INSERT INTO "ProdNac2021".logbd VALUES (1386, '2021-04-13', 'postgres', 'INSERT', 3304555);
INSERT INTO "ProdNac2021".logbd VALUES (1387, '2021-04-13', 'postgres', 'INSERT', 3304818);
INSERT INTO "ProdNac2021".logbd VALUES (1388, '2021-04-13', 'postgres', 'INSERT', 3300995);
INSERT INTO "ProdNac2021".logbd VALUES (1389, '2021-04-13', 'postgres', 'INSERT', 3300756);
INSERT INTO "ProdNac2021".logbd VALUES (1390, '2021-04-13', 'postgres', 'INSERT', 3300384);
INSERT INTO "ProdNac2021".logbd VALUES (1391, '2021-04-13', 'postgres', 'INSERT', 3304800);
INSERT INTO "ProdNac2021".logbd VALUES (1392, '2021-04-13', 'postgres', 'INSERT', 3304411);
INSERT INTO "ProdNac2021".logbd VALUES (1393, '2021-04-13', 'postgres', 'INSERT', 3300891);
INSERT INTO "ProdNac2021".logbd VALUES (1394, '2021-04-13', 'postgres', 'INSERT', 3300786);
INSERT INTO "ProdNac2021".logbd VALUES (1395, '2021-04-13', 'postgres', 'INSERT', 3304548);
INSERT INTO "ProdNac2021".logbd VALUES (1396, '2021-04-13', 'postgres', 'INSERT', 3304695);
INSERT INTO "ProdNac2021".logbd VALUES (1397, '2021-04-13', 'postgres', 'INSERT', 3304331);
INSERT INTO "ProdNac2021".logbd VALUES (1398, '2021-04-13', 'postgres', 'INSERT', 3304874);
INSERT INTO "ProdNac2021".logbd VALUES (1399, '2021-04-13', 'postgres', 'INSERT', 3300323);
INSERT INTO "ProdNac2021".logbd VALUES (1400, '2021-04-13', 'postgres', 'INSERT', 3304947);
INSERT INTO "ProdNac2021".logbd VALUES (1401, '2021-04-13', 'postgres', 'INSERT', 3304518);
INSERT INTO "ProdNac2021".logbd VALUES (1402, '2021-04-13', 'postgres', 'INSERT', 3300453);
INSERT INTO "ProdNac2021".logbd VALUES (1403, '2021-04-13', 'postgres', 'INSERT', 3300377);
INSERT INTO "ProdNac2021".logbd VALUES (1404, '2021-04-13', 'postgres', 'INSERT', 3301090);
INSERT INTO "ProdNac2021".logbd VALUES (1405, '2021-04-13', 'postgres', 'INSERT', 3300859);
INSERT INTO "ProdNac2021".logbd VALUES (1406, '2021-04-13', 'postgres', 'INSERT', 3304727);
INSERT INTO "ProdNac2021".logbd VALUES (1407, '2021-04-13', 'postgres', 'INSERT', 3301196);
INSERT INTO "ProdNac2021".logbd VALUES (1408, '2021-04-13', 'postgres', 'INSERT', 3304611);
INSERT INTO "ProdNac2021".logbd VALUES (1409, '2021-04-13', 'postgres', 'INSERT', 3304743);
INSERT INTO "ProdNac2021".logbd VALUES (1410, '2021-04-13', 'postgres', 'INSERT', 3304895);
INSERT INTO "ProdNac2021".logbd VALUES (1411, '2021-04-13', 'postgres', 'INSERT', 3300277);
INSERT INTO "ProdNac2021".logbd VALUES (1412, '2021-04-13', 'postgres', 'INSERT', 3300197);
INSERT INTO "ProdNac2021".logbd VALUES (1413, '2021-04-13', 'postgres', 'INSERT', 3301048);
INSERT INTO "ProdNac2021".logbd VALUES (1414, '2021-04-13', 'postgres', 'INSERT', 3300318);
INSERT INTO "ProdNac2021".logbd VALUES (1415, '2021-04-13', 'postgres', 'INSERT', 3300921);
INSERT INTO "ProdNac2021".logbd VALUES (1416, '2021-04-13', 'postgres', 'INSERT', 3300621);
INSERT INTO "ProdNac2021".logbd VALUES (1417, '2021-04-13', 'postgres', 'INSERT', 3300759);
INSERT INTO "ProdNac2021".logbd VALUES (1418, '2021-04-13', 'postgres', 'INSERT', 3301075);
INSERT INTO "ProdNac2021".logbd VALUES (1419, '2021-04-13', 'postgres', 'INSERT', 3300842);
INSERT INTO "ProdNac2021".logbd VALUES (1420, '2021-04-13', 'postgres', 'INSERT', 3301205);
INSERT INTO "ProdNac2021".logbd VALUES (1421, '2021-04-13', 'postgres', 'INSERT', 3304927);
INSERT INTO "ProdNac2021".logbd VALUES (1422, '2021-04-13', 'postgres', 'INSERT', 3300860);
INSERT INTO "ProdNac2021".logbd VALUES (1423, '2021-04-13', 'postgres', 'INSERT', 3300687);
INSERT INTO "ProdNac2021".logbd VALUES (1424, '2021-04-13', 'postgres', 'INSERT', 3301160);
INSERT INTO "ProdNac2021".logbd VALUES (1425, '2021-04-13', 'postgres', 'INSERT', 3300959);
INSERT INTO "ProdNac2021".logbd VALUES (1426, '2021-04-13', 'postgres', 'INSERT', 3304669);
INSERT INTO "ProdNac2021".logbd VALUES (1427, '2021-04-13', 'postgres', 'INSERT', 3300178);
INSERT INTO "ProdNac2021".logbd VALUES (1428, '2021-04-13', 'postgres', 'INSERT', 3300343);
INSERT INTO "ProdNac2021".logbd VALUES (1429, '2021-04-13', 'postgres', 'INSERT', 3304851);
INSERT INTO "ProdNac2021".logbd VALUES (1430, '2021-04-13', 'postgres', 'INSERT', 3300876);
INSERT INTO "ProdNac2021".logbd VALUES (1431, '2021-04-13', 'postgres', 'INSERT', 3304362);
INSERT INTO "ProdNac2021".logbd VALUES (1432, '2021-04-13', 'postgres', 'INSERT', 3304763);
INSERT INTO "ProdNac2021".logbd VALUES (1433, '2021-04-13', 'postgres', 'INSERT', 3304705);
INSERT INTO "ProdNac2021".logbd VALUES (1434, '2021-04-13', 'postgres', 'INSERT', 3300309);
INSERT INTO "ProdNac2021".logbd VALUES (1435, '2021-04-13', 'postgres', 'INSERT', 3300430);
INSERT INTO "ProdNac2021".logbd VALUES (1436, '2021-04-13', 'postgres', 'INSERT', 3300182);
INSERT INTO "ProdNac2021".logbd VALUES (1437, '2021-04-13', 'postgres', 'INSERT', 3300355);
INSERT INTO "ProdNac2021".logbd VALUES (1438, '2021-04-13', 'postgres', 'INSERT', 3300159);
INSERT INTO "ProdNac2021".logbd VALUES (1439, '2021-04-13', 'postgres', 'INSERT', 3304355);
INSERT INTO "ProdNac2021".logbd VALUES (1440, '2021-04-13', 'postgres', 'INSERT', 3300583);
INSERT INTO "ProdNac2021".logbd VALUES (1441, '2021-04-13', 'postgres', 'INSERT', 3304636);
INSERT INTO "ProdNac2021".logbd VALUES (1442, '2021-04-13', 'postgres', 'INSERT', 3304806);
INSERT INTO "ProdNac2021".logbd VALUES (1443, '2021-04-13', 'postgres', 'INSERT', 3300640);
INSERT INTO "ProdNac2021".logbd VALUES (1444, '2021-04-13', 'postgres', 'INSERT', 3304537);
INSERT INTO "ProdNac2021".logbd VALUES (1445, '2021-04-13', 'postgres', 'INSERT', 3300412);
INSERT INTO "ProdNac2021".logbd VALUES (1446, '2021-04-13', 'postgres', 'INSERT', 3304622);
INSERT INTO "ProdNac2021".logbd VALUES (1447, '2021-04-13', 'postgres', 'INSERT', 3301191);
INSERT INTO "ProdNac2021".logbd VALUES (1448, '2021-04-13', 'postgres', 'INSERT', 3300297);
INSERT INTO "ProdNac2021".logbd VALUES (1449, '2021-04-13', 'postgres', 'INSERT', 3300508);
INSERT INTO "ProdNac2021".logbd VALUES (1450, '2021-04-13', 'postgres', 'INSERT', 3300326);
INSERT INTO "ProdNac2021".logbd VALUES (1451, '2021-04-13', 'postgres', 'INSERT', 3304532);
INSERT INTO "ProdNac2021".logbd VALUES (1452, '2021-04-13', 'postgres', 'INSERT', 3301047);
INSERT INTO "ProdNac2021".logbd VALUES (1453, '2021-04-13', 'postgres', 'INSERT', 3300514);
INSERT INTO "ProdNac2021".logbd VALUES (1454, '2021-04-13', 'postgres', 'INSERT', 3304454);
INSERT INTO "ProdNac2021".logbd VALUES (1455, '2021-04-13', 'postgres', 'INSERT', 3300840);
INSERT INTO "ProdNac2021".logbd VALUES (1456, '2021-04-13', 'postgres', 'INSERT', 3300257);
INSERT INTO "ProdNac2021".logbd VALUES (1457, '2021-04-13', 'postgres', 'INSERT', 3304637);
INSERT INTO "ProdNac2021".logbd VALUES (1458, '2021-04-13', 'postgres', 'INSERT', 3300110);
INSERT INTO "ProdNac2021".logbd VALUES (1459, '2021-04-13', 'postgres', 'INSERT', 3304344);
INSERT INTO "ProdNac2021".logbd VALUES (1460, '2021-04-13', 'postgres', 'INSERT', 3301137);
INSERT INTO "ProdNac2021".logbd VALUES (1461, '2021-04-13', 'postgres', 'INSERT', 3304807);
INSERT INTO "ProdNac2021".logbd VALUES (1462, '2021-04-13', 'postgres', 'INSERT', 3304644);
INSERT INTO "ProdNac2021".logbd VALUES (1463, '2021-04-13', 'postgres', 'INSERT', 3301078);
INSERT INTO "ProdNac2021".logbd VALUES (1464, '2021-04-13', 'postgres', 'INSERT', 3301185);
INSERT INTO "ProdNac2021".logbd VALUES (1465, '2021-04-13', 'postgres', 'INSERT', 3300620);
INSERT INTO "ProdNac2021".logbd VALUES (1466, '2021-04-13', 'postgres', 'INSERT', 3304710);
INSERT INTO "ProdNac2021".logbd VALUES (1467, '2021-04-13', 'postgres', 'INSERT', 3300063);
INSERT INTO "ProdNac2021".logbd VALUES (1468, '2021-04-13', 'postgres', 'INSERT', 3300777);
INSERT INTO "ProdNac2021".logbd VALUES (1469, '2021-04-13', 'postgres', 'INSERT', 3301077);
INSERT INTO "ProdNac2021".logbd VALUES (1470, '2021-04-13', 'postgres', 'INSERT', 3300881);
INSERT INTO "ProdNac2021".logbd VALUES (1471, '2021-04-13', 'postgres', 'INSERT', 3304519);
INSERT INTO "ProdNac2021".logbd VALUES (1472, '2021-04-13', 'postgres', 'INSERT', 3300709);
INSERT INTO "ProdNac2021".logbd VALUES (1473, '2021-04-13', 'postgres', 'INSERT', 3300718);
INSERT INTO "ProdNac2021".logbd VALUES (1474, '2021-04-13', 'postgres', 'INSERT', 3304586);
INSERT INTO "ProdNac2021".logbd VALUES (1475, '2021-04-13', 'postgres', 'INSERT', 3301141);
INSERT INTO "ProdNac2021".logbd VALUES (1476, '2021-04-13', 'postgres', 'INSERT', 3300975);
INSERT INTO "ProdNac2021".logbd VALUES (1477, '2021-04-13', 'postgres', 'INSERT', 3301194);
INSERT INTO "ProdNac2021".logbd VALUES (1478, '2021-04-13', 'postgres', 'INSERT', 3300799);
INSERT INTO "ProdNac2021".logbd VALUES (1479, '2021-04-13', 'postgres', 'INSERT', 3300477);
INSERT INTO "ProdNac2021".logbd VALUES (1480, '2021-04-13', 'postgres', 'INSERT', 3300444);
INSERT INTO "ProdNac2021".logbd VALUES (1481, '2021-04-13', 'postgres', 'INSERT', 3301021);
INSERT INTO "ProdNac2021".logbd VALUES (1482, '2021-04-13', 'postgres', 'INSERT', 3304782);
INSERT INTO "ProdNac2021".logbd VALUES (1483, '2021-04-13', 'postgres', 'INSERT', 3300214);
INSERT INTO "ProdNac2021".logbd VALUES (1484, '2021-04-13', 'postgres', 'INSERT', 3304795);
INSERT INTO "ProdNac2021".logbd VALUES (1485, '2021-04-13', 'postgres', 'INSERT', 3304812);
INSERT INTO "ProdNac2021".logbd VALUES (1486, '2021-04-13', 'postgres', 'INSERT', 3300933);
INSERT INTO "ProdNac2021".logbd VALUES (1487, '2021-04-13', 'postgres', 'INSERT', 3300507);
INSERT INTO "ProdNac2021".logbd VALUES (1488, '2021-04-13', 'postgres', 'INSERT', 3304871);
INSERT INTO "ProdNac2021".logbd VALUES (1489, '2021-04-13', 'postgres', 'INSERT', 3300141);
INSERT INTO "ProdNac2021".logbd VALUES (1490, '2021-04-13', 'postgres', 'INSERT', 3300498);
INSERT INTO "ProdNac2021".logbd VALUES (1491, '2021-04-13', 'postgres', 'INSERT', 3300757);
INSERT INTO "ProdNac2021".logbd VALUES (1492, '2021-04-13', 'postgres', 'INSERT', 3300985);
INSERT INTO "ProdNac2021".logbd VALUES (1493, '2021-04-13', 'postgres', 'INSERT', 3304530);
INSERT INTO "ProdNac2021".logbd VALUES (1494, '2021-04-13', 'postgres', 'INSERT', 3300080);
INSERT INTO "ProdNac2021".logbd VALUES (1495, '2021-04-13', 'postgres', 'INSERT', 3301010);
INSERT INTO "ProdNac2021".logbd VALUES (1496, '2021-04-13', 'postgres', 'INSERT', 3301036);
INSERT INTO "ProdNac2021".logbd VALUES (1497, '2021-04-13', 'postgres', 'INSERT', 3304903);
INSERT INTO "ProdNac2021".logbd VALUES (1498, '2021-04-13', 'postgres', 'INSERT', 3304880);
INSERT INTO "ProdNac2021".logbd VALUES (1499, '2021-04-13', 'postgres', 'INSERT', 3300335);
INSERT INTO "ProdNac2021".logbd VALUES (1500, '2021-04-13', 'postgres', 'INSERT', 3300871);
INSERT INTO "ProdNac2021".logbd VALUES (1501, '2021-04-13', 'postgres', 'INSERT', 3300316);
INSERT INTO "ProdNac2021".logbd VALUES (1502, '2021-04-13', 'postgres', 'INSERT', 3304618);
INSERT INTO "ProdNac2021".logbd VALUES (1503, '2021-04-13', 'postgres', 'INSERT', 3304656);
INSERT INTO "ProdNac2021".logbd VALUES (1504, '2021-04-13', 'postgres', 'INSERT', 3301208);
INSERT INTO "ProdNac2021".logbd VALUES (1505, '2021-04-13', 'postgres', 'INSERT', 3304365);
INSERT INTO "ProdNac2021".logbd VALUES (1506, '2021-04-13', 'postgres', 'INSERT', 3300031);
INSERT INTO "ProdNac2021".logbd VALUES (1507, '2021-04-13', 'postgres', 'INSERT', 3300449);
INSERT INTO "ProdNac2021".logbd VALUES (1508, '2021-04-13', 'postgres', 'INSERT', 3300304);
INSERT INTO "ProdNac2021".logbd VALUES (1509, '2021-04-13', 'postgres', 'INSERT', 3304946);
INSERT INTO "ProdNac2021".logbd VALUES (1510, '2021-04-13', 'postgres', 'INSERT', 3300966);
INSERT INTO "ProdNac2021".logbd VALUES (1511, '2021-04-13', 'postgres', 'INSERT', 3301017);
INSERT INTO "ProdNac2021".logbd VALUES (1512, '2021-04-13', 'postgres', 'INSERT', 3300923);
INSERT INTO "ProdNac2021".logbd VALUES (1513, '2021-04-13', 'postgres', 'INSERT', 3300659);
INSERT INTO "ProdNac2021".logbd VALUES (1514, '2021-04-13', 'postgres', 'INSERT', 3300911);
INSERT INTO "ProdNac2021".logbd VALUES (1515, '2021-04-13', 'postgres', 'INSERT', 3304937);
INSERT INTO "ProdNac2021".logbd VALUES (1516, '2021-04-13', 'postgres', 'INSERT', 3304950);
INSERT INTO "ProdNac2021".logbd VALUES (1517, '2021-04-13', 'postgres', 'INSERT', 3300999);
INSERT INTO "ProdNac2021".logbd VALUES (1518, '2021-04-13', 'postgres', 'INSERT', 3300723);
INSERT INTO "ProdNac2021".logbd VALUES (1519, '2021-04-13', 'postgres', 'INSERT', 3304774);
INSERT INTO "ProdNac2021".logbd VALUES (1520, '2021-04-13', 'postgres', 'INSERT', 3301188);
INSERT INTO "ProdNac2021".logbd VALUES (1521, '2021-04-13', 'postgres', 'INSERT', 3304658);
INSERT INTO "ProdNac2021".logbd VALUES (1522, '2021-04-13', 'postgres', 'INSERT', 3300949);
INSERT INTO "ProdNac2021".logbd VALUES (1523, '2021-04-13', 'postgres', 'INSERT', 3304574);
INSERT INTO "ProdNac2021".logbd VALUES (1524, '2021-04-13', 'postgres', 'INSERT', 3301115);
INSERT INTO "ProdNac2021".logbd VALUES (1525, '2021-04-13', 'postgres', 'INSERT', 3304919);
INSERT INTO "ProdNac2021".logbd VALUES (1526, '2021-04-13', 'postgres', 'INSERT', 3300420);
INSERT INTO "ProdNac2021".logbd VALUES (1527, '2021-04-13', 'postgres', 'INSERT', 3300998);
INSERT INTO "ProdNac2021".logbd VALUES (1528, '2021-04-13', 'postgres', 'INSERT', 3304832);
INSERT INTO "ProdNac2021".logbd VALUES (1529, '2021-04-13', 'postgres', 'INSERT', 3304980);
INSERT INTO "ProdNac2021".logbd VALUES (1530, '2021-04-13', 'postgres', 'INSERT', 3300423);
INSERT INTO "ProdNac2021".logbd VALUES (1531, '2021-04-13', 'postgres', 'INSERT', 3300804);
INSERT INTO "ProdNac2021".logbd VALUES (1532, '2021-04-13', 'postgres', 'INSERT', 3301226);
INSERT INTO "ProdNac2021".logbd VALUES (1533, '2021-04-13', 'postgres', 'INSERT', 3304396);
INSERT INTO "ProdNac2021".logbd VALUES (1534, '2021-04-13', 'postgres', 'INSERT', 3300405);
INSERT INTO "ProdNac2021".logbd VALUES (1535, '2021-04-13', 'postgres', 'INSERT', 3300681);
INSERT INTO "ProdNac2021".logbd VALUES (1536, '2021-04-13', 'postgres', 'INSERT', 3300770);
INSERT INTO "ProdNac2021".logbd VALUES (1537, '2021-04-13', 'postgres', 'INSERT', 3300529);
INSERT INTO "ProdNac2021".logbd VALUES (1538, '2021-04-13', 'postgres', 'INSERT', 3300184);
INSERT INTO "ProdNac2021".logbd VALUES (1539, '2021-04-13', 'postgres', 'INSERT', 3304587);
INSERT INTO "ProdNac2021".logbd VALUES (1540, '2021-04-13', 'postgres', 'INSERT', 3300590);
INSERT INTO "ProdNac2021".logbd VALUES (1541, '2021-04-13', 'postgres', 'INSERT', 3300591);
INSERT INTO "ProdNac2021".logbd VALUES (1542, '2021-04-13', 'postgres', 'INSERT', 3301095);
INSERT INTO "ProdNac2021".logbd VALUES (1543, '2021-04-13', 'postgres', 'INSERT', 3300295);
INSERT INTO "ProdNac2021".logbd VALUES (1544, '2021-04-13', 'postgres', 'INSERT', 3300179);
INSERT INTO "ProdNac2021".logbd VALUES (1545, '2021-04-13', 'postgres', 'INSERT', 3300981);
INSERT INTO "ProdNac2021".logbd VALUES (1546, '2021-04-13', 'postgres', 'INSERT', 3304872);
INSERT INTO "ProdNac2021".logbd VALUES (1547, '2021-04-13', 'postgres', 'INSERT', 3304932);
INSERT INTO "ProdNac2021".logbd VALUES (1548, '2021-04-13', 'postgres', 'INSERT', 3300897);
INSERT INTO "ProdNac2021".logbd VALUES (1549, '2021-04-13', 'postgres', 'INSERT', 3304383);
INSERT INTO "ProdNac2021".logbd VALUES (1550, '2021-04-13', 'postgres', 'INSERT', 3300852);
INSERT INTO "ProdNac2021".logbd VALUES (1551, '2021-04-13', 'postgres', 'INSERT', 3301157);
INSERT INTO "ProdNac2021".logbd VALUES (1552, '2021-04-13', 'postgres', 'INSERT', 3304855);
INSERT INTO "ProdNac2021".logbd VALUES (1553, '2021-04-13', 'postgres', 'INSERT', 3300312);
INSERT INTO "ProdNac2021".logbd VALUES (1554, '2021-04-13', 'postgres', 'INSERT', 3300051);
INSERT INTO "ProdNac2021".logbd VALUES (1555, '2021-04-13', 'postgres', 'INSERT', 3300561);
INSERT INTO "ProdNac2021".logbd VALUES (1556, '2021-04-13', 'postgres', 'INSERT', 3304613);
INSERT INTO "ProdNac2021".logbd VALUES (1557, '2021-04-13', 'postgres', 'INSERT', 3304517);
INSERT INTO "ProdNac2021".logbd VALUES (1558, '2021-04-13', 'postgres', 'INSERT', 3304934);
INSERT INTO "ProdNac2021".logbd VALUES (1559, '2021-04-13', 'postgres', 'INSERT', 3300491);
INSERT INTO "ProdNac2021".logbd VALUES (1560, '2021-04-13', 'postgres', 'INSERT', 3304330);
INSERT INTO "ProdNac2021".logbd VALUES (1561, '2021-04-13', 'postgres', 'INSERT', 3304395);
INSERT INTO "ProdNac2021".logbd VALUES (1562, '2021-04-13', 'postgres', 'INSERT', 3300877);
INSERT INTO "ProdNac2021".logbd VALUES (1563, '2021-04-13', 'postgres', 'INSERT', 3300213);
INSERT INTO "ProdNac2021".logbd VALUES (1564, '2021-04-13', 'postgres', 'INSERT', 3300221);
INSERT INTO "ProdNac2021".logbd VALUES (1565, '2021-04-13', 'postgres', 'INSERT', 3304688);
INSERT INTO "ProdNac2021".logbd VALUES (1566, '2021-04-13', 'postgres', 'INSERT', 3304967);
INSERT INTO "ProdNac2021".logbd VALUES (1567, '2021-04-13', 'postgres', 'INSERT', 3300964);
INSERT INTO "ProdNac2021".logbd VALUES (1568, '2021-04-13', 'postgres', 'INSERT', 3304626);
INSERT INTO "ProdNac2021".logbd VALUES (1569, '2021-04-13', 'postgres', 'INSERT', 3301025);
INSERT INTO "ProdNac2021".logbd VALUES (1570, '2021-04-13', 'postgres', 'INSERT', 3304403);
INSERT INTO "ProdNac2021".logbd VALUES (1571, '2021-04-13', 'postgres', 'INSERT', 3300834);
INSERT INTO "ProdNac2021".logbd VALUES (1572, '2021-04-13', 'postgres', 'INSERT', 3304931);
INSERT INTO "ProdNac2021".logbd VALUES (1573, '2021-04-13', 'postgres', 'INSERT', 3300016);
INSERT INTO "ProdNac2021".logbd VALUES (1574, '2021-04-13', 'postgres', 'INSERT', 3300496);
INSERT INTO "ProdNac2021".logbd VALUES (1575, '2021-04-13', 'postgres', 'INSERT', 3300038);
INSERT INTO "ProdNac2021".logbd VALUES (1576, '2021-04-13', 'postgres', 'INSERT', 3300555);
INSERT INTO "ProdNac2021".logbd VALUES (1577, '2021-04-13', 'postgres', 'INSERT', 3304361);
INSERT INTO "ProdNac2021".logbd VALUES (1578, '2021-04-13', 'postgres', 'INSERT', 3304501);
INSERT INTO "ProdNac2021".logbd VALUES (1579, '2021-04-13', 'postgres', 'INSERT', 3300361);
INSERT INTO "ProdNac2021".logbd VALUES (1580, '2021-04-13', 'postgres', 'INSERT', 3304553);
INSERT INTO "ProdNac2021".logbd VALUES (1581, '2021-04-13', 'postgres', 'INSERT', 3304772);
INSERT INTO "ProdNac2021".logbd VALUES (1582, '2021-04-13', 'postgres', 'INSERT', 3300864);
INSERT INTO "ProdNac2021".logbd VALUES (1583, '2021-04-13', 'postgres', 'INSERT', 3300531);
INSERT INTO "ProdNac2021".logbd VALUES (1584, '2021-04-13', 'postgres', 'INSERT', 3300396);
INSERT INTO "ProdNac2021".logbd VALUES (1585, '2021-04-13', 'postgres', 'INSERT', 3304674);
INSERT INTO "ProdNac2021".logbd VALUES (1586, '2021-04-13', 'postgres', 'INSERT', 3304686);
INSERT INTO "ProdNac2021".logbd VALUES (1587, '2021-04-13', 'postgres', 'INSERT', 3301177);
INSERT INTO "ProdNac2021".logbd VALUES (1588, '2021-04-13', 'postgres', 'INSERT', 3300375);
INSERT INTO "ProdNac2021".logbd VALUES (1589, '2021-04-13', 'postgres', 'INSERT', 3304340);
INSERT INTO "ProdNac2021".logbd VALUES (1590, '2021-04-13', 'postgres', 'INSERT', 3304976);
INSERT INTO "ProdNac2021".logbd VALUES (1591, '2021-04-13', 'postgres', 'INSERT', 3304524);
INSERT INTO "ProdNac2021".logbd VALUES (1592, '2021-04-13', 'postgres', 'INSERT', 3304921);
INSERT INTO "ProdNac2021".logbd VALUES (1593, '2021-04-13', 'postgres', 'INSERT', 3300965);
INSERT INTO "ProdNac2021".logbd VALUES (1594, '2021-04-13', 'postgres', 'INSERT', 3304405);
INSERT INTO "ProdNac2021".logbd VALUES (1595, '2021-04-13', 'postgres', 'INSERT', 3304585);
INSERT INTO "ProdNac2021".logbd VALUES (1596, '2021-04-13', 'postgres', 'INSERT', 3300106);
INSERT INTO "ProdNac2021".logbd VALUES (1597, '2021-04-13', 'postgres', 'INSERT', 3304993);
INSERT INTO "ProdNac2021".logbd VALUES (1598, '2021-04-13', 'postgres', 'INSERT', 3301074);
INSERT INTO "ProdNac2021".logbd VALUES (1599, '2021-04-13', 'postgres', 'INSERT', 3304527);
INSERT INTO "ProdNac2021".logbd VALUES (1600, '2021-04-13', 'postgres', 'INSERT', 3300166);
INSERT INTO "ProdNac2021".logbd VALUES (1601, '2021-04-13', 'postgres', 'INSERT', 3300650);
INSERT INTO "ProdNac2021".logbd VALUES (1602, '2021-04-13', 'postgres', 'INSERT', 3300905);
INSERT INTO "ProdNac2021".logbd VALUES (1603, '2021-04-13', 'postgres', 'INSERT', 3301085);
INSERT INTO "ProdNac2021".logbd VALUES (1604, '2021-04-13', 'postgres', 'INSERT', 3300232);
INSERT INTO "ProdNac2021".logbd VALUES (1605, '2021-04-13', 'postgres', 'INSERT', 3300398);
INSERT INTO "ProdNac2021".logbd VALUES (1606, '2021-04-13', 'postgres', 'INSERT', 3300264);
INSERT INTO "ProdNac2021".logbd VALUES (1607, '2021-04-13', 'postgres', 'INSERT', 3304616);
INSERT INTO "ProdNac2021".logbd VALUES (1608, '2021-04-13', 'postgres', 'INSERT', 3304696);
INSERT INTO "ProdNac2021".logbd VALUES (1609, '2021-04-13', 'postgres', 'INSERT', 3304712);
INSERT INTO "ProdNac2021".logbd VALUES (1610, '2021-04-13', 'postgres', 'INSERT', 3300994);
INSERT INTO "ProdNac2021".logbd VALUES (1611, '2021-04-13', 'postgres', 'INSERT', 3304910);
INSERT INTO "ProdNac2021".logbd VALUES (1612, '2021-04-13', 'postgres', 'INSERT', 3300157);
INSERT INTO "ProdNac2021".logbd VALUES (1613, '2021-04-13', 'postgres', 'INSERT', 3300334);
INSERT INTO "ProdNac2021".logbd VALUES (1614, '2021-04-13', 'postgres', 'INSERT', 3300010);
INSERT INTO "ProdNac2021".logbd VALUES (1615, '2021-04-13', 'postgres', 'INSERT', 3300588);
INSERT INTO "ProdNac2021".logbd VALUES (1616, '2021-04-13', 'postgres', 'INSERT', 3300967);
INSERT INTO "ProdNac2021".logbd VALUES (1617, '2021-04-13', 'postgres', 'INSERT', 3304816);
INSERT INTO "ProdNac2021".logbd VALUES (1618, '2021-04-13', 'postgres', 'INSERT', 3300504);
INSERT INTO "ProdNac2021".logbd VALUES (1619, '2021-04-13', 'postgres', 'INSERT', 3304542);
INSERT INTO "ProdNac2021".logbd VALUES (1620, '2021-04-13', 'postgres', 'INSERT', 3304406);
INSERT INTO "ProdNac2021".logbd VALUES (1621, '2021-04-13', 'postgres', 'INSERT', 3300509);
INSERT INTO "ProdNac2021".logbd VALUES (1622, '2021-04-13', 'postgres', 'INSERT', 3300606);
INSERT INTO "ProdNac2021".logbd VALUES (1623, '2021-04-13', 'postgres', 'INSERT', 3301120);
INSERT INTO "ProdNac2021".logbd VALUES (1624, '2021-04-13', 'postgres', 'INSERT', 3304552);
INSERT INTO "ProdNac2021".logbd VALUES (1625, '2021-04-13', 'postgres', 'INSERT', 3300771);
INSERT INTO "ProdNac2021".logbd VALUES (1626, '2021-04-13', 'postgres', 'INSERT', 3300290);
INSERT INTO "ProdNac2021".logbd VALUES (1627, '2021-04-13', 'postgres', 'INSERT', 3304538);
INSERT INTO "ProdNac2021".logbd VALUES (1628, '2021-04-13', 'postgres', 'INSERT', 3300270);
INSERT INTO "ProdNac2021".logbd VALUES (1629, '2021-04-13', 'postgres', 'INSERT', 3304576);
INSERT INTO "ProdNac2021".logbd VALUES (1630, '2021-04-13', 'postgres', 'INSERT', 3300288);
INSERT INTO "ProdNac2021".logbd VALUES (1631, '2021-04-13', 'postgres', 'INSERT', 3300156);
INSERT INTO "ProdNac2021".logbd VALUES (1632, '2021-04-13', 'postgres', 'INSERT', 3300690);
INSERT INTO "ProdNac2021".logbd VALUES (1633, '2021-04-13', 'postgres', 'INSERT', 3304481);
INSERT INTO "ProdNac2021".logbd VALUES (1634, '2021-04-13', 'postgres', 'INSERT', 3300577);
INSERT INTO "ProdNac2021".logbd VALUES (1635, '2021-04-13', 'postgres', 'INSERT', 3300919);
INSERT INTO "ProdNac2021".logbd VALUES (1636, '2021-04-13', 'postgres', 'INSERT', 3301163);
INSERT INTO "ProdNac2021".logbd VALUES (1637, '2021-04-13', 'postgres', 'INSERT', 3300383);
INSERT INTO "ProdNac2021".logbd VALUES (1638, '2021-04-13', 'postgres', 'INSERT', 3300333);
INSERT INTO "ProdNac2021".logbd VALUES (1639, '2021-04-13', 'postgres', 'INSERT', 3301131);
INSERT INTO "ProdNac2021".logbd VALUES (1640, '2021-04-13', 'postgres', 'INSERT', 3300415);
INSERT INTO "ProdNac2021".logbd VALUES (1641, '2021-04-13', 'postgres', 'INSERT', 3300142);
INSERT INTO "ProdNac2021".logbd VALUES (1642, '2021-04-13', 'postgres', 'INSERT', 3300301);
INSERT INTO "ProdNac2021".logbd VALUES (1643, '2021-04-13', 'postgres', 'INSERT', 3304378);
INSERT INTO "ProdNac2021".logbd VALUES (1644, '2021-04-13', 'postgres', 'INSERT', 3304892);
INSERT INTO "ProdNac2021".logbd VALUES (1645, '2021-04-13', 'postgres', 'INSERT', 3300075);
INSERT INTO "ProdNac2021".logbd VALUES (1646, '2021-04-13', 'postgres', 'INSERT', 3301056);
INSERT INTO "ProdNac2021".logbd VALUES (1647, '2021-04-13', 'postgres', 'INSERT', 3301020);
INSERT INTO "ProdNac2021".logbd VALUES (1648, '2021-04-13', 'postgres', 'INSERT', 3301127);
INSERT INTO "ProdNac2021".logbd VALUES (1649, '2021-04-13', 'postgres', 'INSERT', 3300707);
INSERT INTO "ProdNac2021".logbd VALUES (1650, '2021-04-13', 'postgres', 'INSERT', 3301178);
INSERT INTO "ProdNac2021".logbd VALUES (1651, '2021-04-13', 'postgres', 'INSERT', 3300896);
INSERT INTO "ProdNac2021".logbd VALUES (1652, '2021-04-13', 'postgres', 'INSERT', 3300902);
INSERT INTO "ProdNac2021".logbd VALUES (1653, '2021-04-13', 'postgres', 'INSERT', 3300293);
INSERT INTO "ProdNac2021".logbd VALUES (1654, '2021-04-13', 'postgres', 'INSERT', 3300282);
INSERT INTO "ProdNac2021".logbd VALUES (1655, '2021-04-13', 'postgres', 'INSERT', 3304570);
INSERT INTO "ProdNac2021".logbd VALUES (1656, '2021-04-13', 'postgres', 'INSERT', 3304364);
INSERT INTO "ProdNac2021".logbd VALUES (1657, '2021-04-13', 'postgres', 'INSERT', 3304715);
INSERT INTO "ProdNac2021".logbd VALUES (1658, '2021-04-13', 'postgres', 'INSERT', 3300002);
INSERT INTO "ProdNac2021".logbd VALUES (1659, '2021-04-13', 'postgres', 'INSERT', 3300748);
INSERT INTO "ProdNac2021".logbd VALUES (1660, '2021-04-13', 'postgres', 'INSERT', 3300851);
INSERT INTO "ProdNac2021".logbd VALUES (1661, '2021-04-13', 'postgres', 'INSERT', 3304608);
INSERT INTO "ProdNac2021".logbd VALUES (1662, '2021-04-13', 'postgres', 'INSERT', 3304711);
INSERT INTO "ProdNac2021".logbd VALUES (1663, '2021-04-13', 'postgres', 'INSERT', 3301221);
INSERT INTO "ProdNac2021".logbd VALUES (1664, '2021-04-13', 'postgres', 'INSERT', 3300123);
INSERT INTO "ProdNac2021".logbd VALUES (1665, '2021-04-13', 'postgres', 'INSERT', 3300342);
INSERT INTO "ProdNac2021".logbd VALUES (1666, '2021-04-13', 'postgres', 'INSERT', 3301207);
INSERT INTO "ProdNac2021".logbd VALUES (1667, '2021-04-13', 'postgres', 'INSERT', 3301096);
INSERT INTO "ProdNac2021".logbd VALUES (1668, '2021-04-13', 'postgres', 'INSERT', 3304716);
INSERT INTO "ProdNac2021".logbd VALUES (1669, '2021-04-13', 'postgres', 'INSERT', 3300702);
INSERT INTO "ProdNac2021".logbd VALUES (1670, '2021-04-13', 'postgres', 'INSERT', 3304354);
INSERT INTO "ProdNac2021".logbd VALUES (1671, '2021-04-13', 'postgres', 'INSERT', 3300988);
INSERT INTO "ProdNac2021".logbd VALUES (1672, '2021-04-13', 'postgres', 'INSERT', 3300215);
INSERT INTO "ProdNac2021".logbd VALUES (1673, '2021-04-13', 'postgres', 'INSERT', 3300603);
INSERT INTO "ProdNac2021".logbd VALUES (1674, '2021-04-13', 'postgres', 'INSERT', 3304689);
INSERT INTO "ProdNac2021".logbd VALUES (1675, '2021-04-13', 'postgres', 'INSERT', 3301200);
INSERT INTO "ProdNac2021".logbd VALUES (1676, '2021-04-13', 'postgres', 'INSERT', 3300714);
INSERT INTO "ProdNac2021".logbd VALUES (1677, '2021-04-13', 'postgres', 'INSERT', 3304505);
INSERT INTO "ProdNac2021".logbd VALUES (1678, '2021-04-13', 'postgres', 'INSERT', 3300976);
INSERT INTO "ProdNac2021".logbd VALUES (1679, '2021-04-13', 'postgres', 'INSERT', 3304516);
INSERT INTO "ProdNac2021".logbd VALUES (1680, '2021-04-13', 'postgres', 'INSERT', 3300572);
INSERT INTO "ProdNac2021".logbd VALUES (1681, '2021-04-13', 'postgres', 'INSERT', 3301118);
INSERT INTO "ProdNac2021".logbd VALUES (1682, '2021-04-13', 'postgres', 'INSERT', 3304966);
INSERT INTO "ProdNac2021".logbd VALUES (1683, '2021-04-13', 'postgres', 'INSERT', 3301055);
INSERT INTO "ProdNac2021".logbd VALUES (1684, '2021-04-13', 'postgres', 'INSERT', 3300573);
INSERT INTO "ProdNac2021".logbd VALUES (1685, '2021-04-13', 'postgres', 'INSERT', 3300078);
INSERT INTO "ProdNac2021".logbd VALUES (1686, '2021-04-13', 'postgres', 'INSERT', 3301184);
INSERT INTO "ProdNac2021".logbd VALUES (1687, '2021-04-13', 'postgres', 'INSERT', 3300622);
INSERT INTO "ProdNac2021".logbd VALUES (1688, '2021-04-13', 'postgres', 'INSERT', 3304961);
INSERT INTO "ProdNac2021".logbd VALUES (1689, '2021-04-13', 'postgres', 'INSERT', 3300292);
INSERT INTO "ProdNac2021".logbd VALUES (1690, '2021-04-13', 'postgres', 'INSERT', 3304612);
INSERT INTO "ProdNac2021".logbd VALUES (1691, '2021-04-13', 'postgres', 'INSERT', 3304756);
INSERT INTO "ProdNac2021".logbd VALUES (1692, '2021-04-13', 'postgres', 'INSERT', 3300434);
INSERT INTO "ProdNac2021".logbd VALUES (1693, '2021-04-13', 'postgres', 'INSERT', 3300812);
INSERT INTO "ProdNac2021".logbd VALUES (1694, '2021-04-13', 'postgres', 'INSERT', 3301091);
INSERT INTO "ProdNac2021".logbd VALUES (1695, '2021-04-13', 'postgres', 'INSERT', 3304655);
INSERT INTO "ProdNac2021".logbd VALUES (1696, '2021-04-13', 'postgres', 'INSERT', 3304847);
INSERT INTO "ProdNac2021".logbd VALUES (1697, '2021-04-13', 'postgres', 'INSERT', 3301126);
INSERT INTO "ProdNac2021".logbd VALUES (1698, '2021-04-13', 'postgres', 'INSERT', 3304476);
INSERT INTO "ProdNac2021".logbd VALUES (1699, '2021-04-13', 'postgres', 'INSERT', 3300008);
INSERT INTO "ProdNac2021".logbd VALUES (1700, '2021-04-13', 'postgres', 'INSERT', 3301110);
INSERT INTO "ProdNac2021".logbd VALUES (1701, '2021-04-13', 'postgres', 'INSERT', 3300124);
INSERT INTO "ProdNac2021".logbd VALUES (1702, '2021-04-13', 'postgres', 'INSERT', 3304561);
INSERT INTO "ProdNac2021".logbd VALUES (1703, '2021-04-13', 'postgres', 'INSERT', 3300568);
INSERT INTO "ProdNac2021".logbd VALUES (1704, '2021-04-13', 'postgres', 'INSERT', 3304509);
INSERT INTO "ProdNac2021".logbd VALUES (1705, '2021-04-13', 'postgres', 'INSERT', 3300329);
INSERT INTO "ProdNac2021".logbd VALUES (1706, '2021-04-13', 'postgres', 'INSERT', 3301186);
INSERT INTO "ProdNac2021".logbd VALUES (1707, '2021-04-13', 'postgres', 'INSERT', 3300858);
INSERT INTO "ProdNac2021".logbd VALUES (1708, '2021-04-13', 'postgres', 'INSERT', 3304485);
INSERT INTO "ProdNac2021".logbd VALUES (1709, '2021-04-13', 'postgres', 'INSERT', 3304745);
INSERT INTO "ProdNac2021".logbd VALUES (1710, '2021-04-13', 'postgres', 'INSERT', 3304868);
INSERT INTO "ProdNac2021".logbd VALUES (1711, '2021-04-13', 'postgres', 'INSERT', 3300256);
INSERT INTO "ProdNac2021".logbd VALUES (1712, '2021-04-13', 'postgres', 'INSERT', 3304478);
INSERT INTO "ProdNac2021".logbd VALUES (1713, '2021-04-13', 'postgres', 'INSERT', 3300855);
INSERT INTO "ProdNac2021".logbd VALUES (1714, '2021-04-13', 'postgres', 'INSERT', 3300908);
INSERT INTO "ProdNac2021".logbd VALUES (1715, '2021-04-13', 'postgres', 'INSERT', 3300510);
INSERT INTO "ProdNac2021".logbd VALUES (1716, '2021-04-13', 'postgres', 'INSERT', 3300818);
INSERT INTO "ProdNac2021".logbd VALUES (1717, '2021-04-13', 'postgres', 'INSERT', 3300058);
INSERT INTO "ProdNac2021".logbd VALUES (1718, '2021-04-13', 'postgres', 'INSERT', 3301147);
INSERT INTO "ProdNac2021".logbd VALUES (1719, '2021-04-13', 'postgres', 'INSERT', 3300920);
INSERT INTO "ProdNac2021".logbd VALUES (1720, '2021-04-13', 'postgres', 'INSERT', 3304346);
INSERT INTO "ProdNac2021".logbd VALUES (1721, '2021-04-13', 'postgres', 'INSERT', 3304578);
INSERT INTO "ProdNac2021".logbd VALUES (1722, '2021-04-13', 'postgres', 'INSERT', 3304580);
INSERT INTO "ProdNac2021".logbd VALUES (1723, '2021-04-13', 'postgres', 'INSERT', 3304982);
INSERT INTO "ProdNac2021".logbd VALUES (1724, '2021-04-13', 'postgres', 'INSERT', 3300189);
INSERT INTO "ProdNac2021".logbd VALUES (1725, '2021-04-13', 'postgres', 'INSERT', 3304635);
INSERT INTO "ProdNac2021".logbd VALUES (1726, '2021-04-13', 'postgres', 'INSERT', 3301067);
INSERT INTO "ProdNac2021".logbd VALUES (1727, '2021-04-13', 'postgres', 'INSERT', 3300153);
INSERT INTO "ProdNac2021".logbd VALUES (1728, '2021-04-13', 'postgres', 'INSERT', 3301083);
INSERT INTO "ProdNac2021".logbd VALUES (1729, '2021-04-13', 'postgres', 'INSERT', 3300943);
INSERT INTO "ProdNac2021".logbd VALUES (1730, '2021-04-13', 'postgres', 'INSERT', 3300735);
INSERT INTO "ProdNac2021".logbd VALUES (1731, '2021-04-13', 'postgres', 'INSERT', 3300111);
INSERT INTO "ProdNac2021".logbd VALUES (1732, '2021-04-13', 'postgres', 'INSERT', 3304728);
INSERT INTO "ProdNac2021".logbd VALUES (1733, '2021-04-13', 'postgres', 'INSERT', 3300495);
INSERT INTO "ProdNac2021".logbd VALUES (1734, '2021-04-13', 'postgres', 'INSERT', 3300024);
INSERT INTO "ProdNac2021".logbd VALUES (1735, '2021-04-13', 'postgres', 'INSERT', 3304775);
INSERT INTO "ProdNac2021".logbd VALUES (1736, '2021-04-13', 'postgres', 'INSERT', 3304607);
INSERT INTO "ProdNac2021".logbd VALUES (1737, '2021-04-13', 'postgres', 'INSERT', 3301192);
INSERT INTO "ProdNac2021".logbd VALUES (1738, '2021-04-13', 'postgres', 'INSERT', 3301130);
INSERT INTO "ProdNac2021".logbd VALUES (1739, '2021-04-13', 'postgres', 'INSERT', 3300913);
INSERT INTO "ProdNac2021".logbd VALUES (1740, '2021-04-13', 'postgres', 'INSERT', 3301063);
INSERT INTO "ProdNac2021".logbd VALUES (1741, '2021-04-13', 'postgres', 'INSERT', 3300490);
INSERT INTO "ProdNac2021".logbd VALUES (1742, '2021-04-13', 'postgres', 'INSERT', 3304650);
INSERT INTO "ProdNac2021".logbd VALUES (1743, '2021-04-13', 'postgres', 'INSERT', 3304620);
INSERT INTO "ProdNac2021".logbd VALUES (1744, '2021-04-13', 'postgres', 'INSERT', 3300039);
INSERT INTO "ProdNac2021".logbd VALUES (1745, '2021-04-13', 'postgres', 'INSERT', 3300910);
INSERT INTO "ProdNac2021".logbd VALUES (1746, '2021-04-13', 'postgres', 'INSERT', 3304757);
INSERT INTO "ProdNac2021".logbd VALUES (1747, '2021-04-13', 'postgres', 'INSERT', 3304991);
INSERT INTO "ProdNac2021".logbd VALUES (1748, '2021-04-13', 'postgres', 'INSERT', 3300083);
INSERT INTO "ProdNac2021".logbd VALUES (1749, '2021-04-13', 'postgres', 'INSERT', 3301150);
INSERT INTO "ProdNac2021".logbd VALUES (1750, '2021-04-13', 'postgres', 'INSERT', 3301049);
INSERT INTO "ProdNac2021".logbd VALUES (1751, '2021-04-13', 'postgres', 'INSERT', 3304397);
INSERT INTO "ProdNac2021".logbd VALUES (1752, '2021-04-13', 'postgres', 'INSERT', 3304842);
INSERT INTO "ProdNac2021".logbd VALUES (1753, '2021-04-13', 'postgres', 'INSERT', 3301168);
INSERT INTO "ProdNac2021".logbd VALUES (1754, '2021-04-13', 'postgres', 'INSERT', 3300125);
INSERT INTO "ProdNac2021".logbd VALUES (1755, '2021-04-13', 'postgres', 'INSERT', 3301052);
INSERT INTO "ProdNac2021".logbd VALUES (1756, '2021-04-13', 'postgres', 'INSERT', 3300332);
INSERT INTO "ProdNac2021".logbd VALUES (1757, '2021-04-13', 'postgres', 'INSERT', 3300527);
INSERT INTO "ProdNac2021".logbd VALUES (1758, '2021-04-13', 'postgres', 'INSERT', 3300119);
INSERT INTO "ProdNac2021".logbd VALUES (1759, '2021-04-13', 'postgres', 'INSERT', 3300693);
INSERT INTO "ProdNac2021".logbd VALUES (1760, '2021-04-13', 'postgres', 'INSERT', 3300350);
INSERT INTO "ProdNac2021".logbd VALUES (1761, '2021-04-13', 'postgres', 'INSERT', 3304627);
INSERT INTO "ProdNac2021".logbd VALUES (1762, '2021-04-13', 'postgres', 'INSERT', 3300604);
INSERT INTO "ProdNac2021".logbd VALUES (1763, '2021-04-13', 'postgres', 'INSERT', 3300867);
INSERT INTO "ProdNac2021".logbd VALUES (1764, '2021-04-13', 'postgres', 'INSERT', 3304380);
INSERT INTO "ProdNac2021".logbd VALUES (1765, '2021-04-13', 'postgres', 'INSERT', 3304837);
INSERT INTO "ProdNac2021".logbd VALUES (1766, '2021-04-13', 'postgres', 'INSERT', 3304930);
INSERT INTO "ProdNac2021".logbd VALUES (1767, '2021-04-13', 'postgres', 'INSERT', 3304952);
INSERT INTO "ProdNac2021".logbd VALUES (1768, '2021-04-13', 'postgres', 'INSERT', 3300163);
INSERT INTO "ProdNac2021".logbd VALUES (1769, '2021-04-13', 'postgres', 'INSERT', 3304503);
INSERT INTO "ProdNac2021".logbd VALUES (1770, '2021-04-13', 'postgres', 'INSERT', 3304870);
INSERT INTO "ProdNac2021".logbd VALUES (1771, '2021-04-13', 'postgres', 'INSERT', 3301116);
INSERT INTO "ProdNac2021".logbd VALUES (1772, '2021-04-13', 'postgres', 'INSERT', 3300363);
INSERT INTO "ProdNac2021".logbd VALUES (1773, '2021-04-13', 'postgres', 'INSERT', 3300250);
INSERT INTO "ProdNac2021".logbd VALUES (1774, '2021-04-13', 'postgres', 'INSERT', 3300551);
INSERT INTO "ProdNac2021".logbd VALUES (1775, '2021-04-13', 'postgres', 'INSERT', 3304591);
INSERT INTO "ProdNac2021".logbd VALUES (1776, '2021-04-13', 'postgres', 'INSERT', 3304948);
INSERT INTO "ProdNac2021".logbd VALUES (1777, '2021-04-13', 'postgres', 'INSERT', 3300397);
INSERT INTO "ProdNac2021".logbd VALUES (1778, '2021-04-13', 'postgres', 'INSERT', 3304801);
INSERT INTO "ProdNac2021".logbd VALUES (1779, '2021-04-13', 'postgres', 'INSERT', 3301089);
INSERT INTO "ProdNac2021".logbd VALUES (1780, '2021-04-13', 'postgres', 'INSERT', 3300053);
INSERT INTO "ProdNac2021".logbd VALUES (1781, '2021-04-13', 'postgres', 'INSERT', 3304841);
INSERT INTO "ProdNac2021".logbd VALUES (1782, '2021-04-13', 'postgres', 'INSERT', 3300663);
INSERT INTO "ProdNac2021".logbd VALUES (1783, '2021-04-13', 'postgres', 'INSERT', 3304369);
INSERT INTO "ProdNac2021".logbd VALUES (1784, '2021-04-13', 'postgres', 'INSERT', 3300268);
INSERT INTO "ProdNac2021".logbd VALUES (1785, '2021-04-13', 'postgres', 'INSERT', 3301173);
INSERT INTO "ProdNac2021".logbd VALUES (1786, '2021-04-13', 'postgres', 'INSERT', 3304434);
INSERT INTO "ProdNac2021".logbd VALUES (1787, '2021-04-13', 'postgres', 'INSERT', 3304702);
INSERT INTO "ProdNac2021".logbd VALUES (1788, '2021-04-13', 'postgres', 'INSERT', 3304898);
INSERT INTO "ProdNac2021".logbd VALUES (1789, '2021-04-13', 'postgres', 'INSERT', 3300997);
INSERT INTO "ProdNac2021".logbd VALUES (1790, '2021-04-13', 'postgres', 'INSERT', 3300986);
INSERT INTO "ProdNac2021".logbd VALUES (1791, '2021-04-13', 'postgres', 'INSERT', 3304337);
INSERT INTO "ProdNac2021".logbd VALUES (1792, '2021-04-13', 'postgres', 'INSERT', 3304671);
INSERT INTO "ProdNac2021".logbd VALUES (1793, '2021-04-13', 'postgres', 'INSERT', 3300822);
INSERT INTO "ProdNac2021".logbd VALUES (1794, '2021-04-13', 'postgres', 'INSERT', 3300521);
INSERT INTO "ProdNac2021".logbd VALUES (1795, '2021-04-13', 'postgres', 'INSERT', 3304373);
INSERT INTO "ProdNac2021".logbd VALUES (1796, '2021-04-13', 'postgres', 'INSERT', 3301206);
INSERT INTO "ProdNac2021".logbd VALUES (1797, '2021-04-13', 'postgres', 'INSERT', 3300763);
INSERT INTO "ProdNac2021".logbd VALUES (1798, '2021-04-13', 'postgres', 'INSERT', 3300941);
INSERT INTO "ProdNac2021".logbd VALUES (1799, '2021-04-13', 'postgres', 'INSERT', 3300737);
INSERT INTO "ProdNac2021".logbd VALUES (1800, '2021-04-13', 'postgres', 'INSERT', 3300700);
INSERT INTO "ProdNac2021".logbd VALUES (1801, '2021-04-13', 'postgres', 'INSERT', 3300230);
INSERT INTO "ProdNac2021".logbd VALUES (1802, '2021-04-13', 'postgres', 'INSERT', 3304786);
INSERT INTO "ProdNac2021".logbd VALUES (1803, '2021-04-13', 'postgres', 'INSERT', 3300108);
INSERT INTO "ProdNac2021".logbd VALUES (1804, '2021-04-13', 'postgres', 'INSERT', 3304846);
INSERT INTO "ProdNac2021".logbd VALUES (1805, '2021-04-13', 'postgres', 'INSERT', 3304588);
INSERT INTO "ProdNac2021".logbd VALUES (1806, '2021-04-13', 'postgres', 'INSERT', 3304455);
INSERT INTO "ProdNac2021".logbd VALUES (1807, '2021-04-13', 'postgres', 'INSERT', 3304370);
INSERT INTO "ProdNac2021".logbd VALUES (1808, '2021-04-13', 'postgres', 'INSERT', 3300286);
INSERT INTO "ProdNac2021".logbd VALUES (1809, '2021-04-13', 'postgres', 'INSERT', 3301026);
INSERT INTO "ProdNac2021".logbd VALUES (1810, '2021-04-13', 'postgres', 'INSERT', 3304450);
INSERT INTO "ProdNac2021".logbd VALUES (1811, '2021-04-13', 'postgres', 'INSERT', 3304877);
INSERT INTO "ProdNac2021".logbd VALUES (1812, '2021-04-13', 'postgres', 'INSERT', 3304977);
INSERT INTO "ProdNac2021".logbd VALUES (1813, '2021-04-13', 'postgres', 'INSERT', 3300074);
INSERT INTO "ProdNac2021".logbd VALUES (1814, '2021-04-13', 'postgres', 'INSERT', 3300820);
INSERT INTO "ProdNac2021".logbd VALUES (1815, '2021-04-13', 'postgres', 'INSERT', 3304830);
INSERT INTO "ProdNac2021".logbd VALUES (1816, '2021-04-13', 'postgres', 'INSERT', 3304621);
INSERT INTO "ProdNac2021".logbd VALUES (1817, '2021-04-13', 'postgres', 'INSERT', 3301073);
INSERT INTO "ProdNac2021".logbd VALUES (1818, '2021-04-13', 'postgres', 'INSERT', 3300426);
INSERT INTO "ProdNac2021".logbd VALUES (1819, '2021-04-13', 'postgres', 'INSERT', 3300127);
INSERT INTO "ProdNac2021".logbd VALUES (1820, '2021-04-13', 'postgres', 'INSERT', 3300537);
INSERT INTO "ProdNac2021".logbd VALUES (1821, '2021-04-13', 'postgres', 'INSERT', 3304464);
INSERT INTO "ProdNac2021".logbd VALUES (1822, '2021-04-13', 'postgres', 'INSERT', 3300209);
INSERT INTO "ProdNac2021".logbd VALUES (1823, '2021-04-13', 'postgres', 'INSERT', 3300576);
INSERT INTO "ProdNac2021".logbd VALUES (1824, '2021-04-13', 'postgres', 'INSERT', 3300421);
INSERT INTO "ProdNac2021".logbd VALUES (1825, '2021-04-13', 'postgres', 'INSERT', 3300353);
INSERT INTO "ProdNac2021".logbd VALUES (1826, '2021-04-13', 'postgres', 'INSERT', 3301051);
INSERT INTO "ProdNac2021".logbd VALUES (1827, '2021-04-13', 'postgres', 'INSERT', 3300088);
INSERT INTO "ProdNac2021".logbd VALUES (1828, '2021-04-13', 'postgres', 'INSERT', 3304676);
INSERT INTO "ProdNac2021".logbd VALUES (1829, '2021-04-13', 'postgres', 'INSERT', 3300079);
INSERT INTO "ProdNac2021".logbd VALUES (1830, '2021-04-13', 'postgres', 'INSERT', 3300685);
INSERT INTO "ProdNac2021".logbd VALUES (1831, '2021-04-13', 'postgres', 'INSERT', 3300218);
INSERT INTO "ProdNac2021".logbd VALUES (1832, '2021-04-13', 'postgres', 'INSERT', 3300077);
INSERT INTO "ProdNac2021".logbd VALUES (1833, '2021-04-13', 'postgres', 'INSERT', 3300274);
INSERT INTO "ProdNac2021".logbd VALUES (1834, '2021-04-13', 'postgres', 'INSERT', 3301146);
INSERT INTO "ProdNac2021".logbd VALUES (1835, '2021-04-13', 'postgres', 'INSERT', 3300006);
INSERT INTO "ProdNac2021".logbd VALUES (1836, '2021-04-13', 'postgres', 'INSERT', 3300597);
INSERT INTO "ProdNac2021".logbd VALUES (1837, '2021-04-13', 'postgres', 'INSERT', 3300486);
INSERT INTO "ProdNac2021".logbd VALUES (1838, '2021-04-13', 'postgres', 'INSERT', 3300299);
INSERT INTO "ProdNac2021".logbd VALUES (1839, '2021-04-13', 'postgres', 'INSERT', 3300562);
INSERT INTO "ProdNac2021".logbd VALUES (1840, '2021-04-13', 'postgres', 'INSERT', 3300040);
INSERT INTO "ProdNac2021".logbd VALUES (1841, '2021-04-13', 'postgres', 'INSERT', 3300907);
INSERT INTO "ProdNac2021".logbd VALUES (1842, '2021-04-13', 'postgres', 'INSERT', 3304372);
INSERT INTO "ProdNac2021".logbd VALUES (1843, '2021-04-13', 'postgres', 'INSERT', 3304617);
INSERT INTO "ProdNac2021".logbd VALUES (1844, '2021-04-13', 'postgres', 'INSERT', 3304908);
INSERT INTO "ProdNac2021".logbd VALUES (1845, '2021-04-13', 'postgres', 'INSERT', 3300545);
INSERT INTO "ProdNac2021".logbd VALUES (1846, '2021-04-13', 'postgres', 'INSERT', 3301153);
INSERT INTO "ProdNac2021".logbd VALUES (1847, '2021-04-13', 'postgres', 'INSERT', 3300906);
INSERT INTO "ProdNac2021".logbd VALUES (1848, '2021-04-13', 'postgres', 'INSERT', 3304334);
INSERT INTO "ProdNac2021".logbd VALUES (1849, '2021-04-13', 'postgres', 'INSERT', 3300872);
INSERT INTO "ProdNac2021".logbd VALUES (1850, '2021-04-13', 'postgres', 'INSERT', 3304368);
INSERT INTO "ProdNac2021".logbd VALUES (1851, '2021-04-13', 'postgres', 'INSERT', 3304708);
INSERT INTO "ProdNac2021".logbd VALUES (1852, '2021-04-13', 'postgres', 'INSERT', 3304963);
INSERT INTO "ProdNac2021".logbd VALUES (1853, '2021-04-13', 'postgres', 'INSERT', 3300135);
INSERT INTO "ProdNac2021".logbd VALUES (1854, '2021-04-13', 'postgres', 'INSERT', 3300875);
INSERT INTO "ProdNac2021".logbd VALUES (1855, '2021-04-13', 'postgres', 'INSERT', 3300809);
INSERT INTO "ProdNac2021".logbd VALUES (1856, '2021-04-13', 'postgres', 'INSERT', 3300987);
INSERT INTO "ProdNac2021".logbd VALUES (1857, '2021-04-13', 'postgres', 'INSERT', 3300379);
INSERT INTO "ProdNac2021".logbd VALUES (1858, '2021-04-13', 'postgres', 'INSERT', 3300418);
INSERT INTO "ProdNac2021".logbd VALUES (1859, '2021-04-13', 'postgres', 'INSERT', 3304521);
INSERT INTO "ProdNac2021".logbd VALUES (1860, '2021-04-13', 'postgres', 'INSERT', 3304697);
INSERT INTO "ProdNac2021".logbd VALUES (1861, '2021-04-13', 'postgres', 'INSERT', 3304863);
INSERT INTO "ProdNac2021".logbd VALUES (1862, '2021-04-13', 'postgres', 'INSERT', 3300829);
INSERT INTO "ProdNac2021".logbd VALUES (1863, '2021-04-13', 'postgres', 'INSERT', 3300711);
INSERT INTO "ProdNac2021".logbd VALUES (1864, '2021-04-13', 'postgres', 'INSERT', 3300918);
INSERT INTO "ProdNac2021".logbd VALUES (1865, '2021-04-13', 'postgres', 'INSERT', 3300146);
INSERT INTO "ProdNac2021".logbd VALUES (1866, '2021-04-13', 'postgres', 'INSERT', 3300211);
INSERT INTO "ProdNac2021".logbd VALUES (1867, '2021-04-13', 'postgres', 'INSERT', 3300032);
INSERT INTO "ProdNac2021".logbd VALUES (1868, '2021-04-13', 'postgres', 'INSERT', 3304698);
INSERT INTO "ProdNac2021".logbd VALUES (1869, '2021-04-13', 'postgres', 'INSERT', 3304864);
INSERT INTO "ProdNac2021".logbd VALUES (1870, '2021-04-13', 'postgres', 'INSERT', 3300617);
INSERT INTO "ProdNac2021".logbd VALUES (1871, '2021-04-13', 'postgres', 'INSERT', 3301087);
INSERT INTO "ProdNac2021".logbd VALUES (1872, '2021-04-13', 'postgres', 'INSERT', 3300233);
INSERT INTO "ProdNac2021".logbd VALUES (1873, '2021-04-13', 'postgres', 'INSERT', 3300641);
INSERT INTO "ProdNac2021".logbd VALUES (1874, '2021-04-13', 'postgres', 'INSERT', 3304894);
INSERT INTO "ProdNac2021".logbd VALUES (1875, '2021-04-13', 'postgres', 'INSERT', 3300338);
INSERT INTO "ProdNac2021".logbd VALUES (1876, '2021-04-13', 'postgres', 'INSERT', 3304596);
INSERT INTO "ProdNac2021".logbd VALUES (1877, '2021-04-13', 'postgres', 'INSERT', 3304641);
INSERT INTO "ProdNac2021".logbd VALUES (1878, '2021-04-13', 'postgres', 'INSERT', 3300321);
INSERT INTO "ProdNac2021".logbd VALUES (1879, '2021-04-13', 'postgres', 'INSERT', 3301169);
INSERT INTO "ProdNac2021".logbd VALUES (1880, '2021-04-13', 'postgres', 'INSERT', 3300102);
INSERT INTO "ProdNac2021".logbd VALUES (1881, '2021-04-13', 'postgres', 'INSERT', 3300725);
INSERT INTO "ProdNac2021".logbd VALUES (1882, '2021-04-13', 'postgres', 'INSERT', 3304425);


--
-- TOC entry 2194 (class 0 OID 38212)
-- Dependencies: 195
-- Data for Name: procedmetodolog; Type: TABLE DATA; Schema: ProdNac2021; Owner: postgres
--



--
-- TOC entry 2195 (class 0 OID 38215)
-- Dependencies: 196
-- Data for Name: profissional; Type: TABLE DATA; Schema: ProdNac2021; Owner: postgres
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
-- TOC entry 2196 (class 0 OID 38218)
-- Dependencies: 197
-- Data for Name: tipoacao; Type: TABLE DATA; Schema: ProdNac2021; Owner: postgres
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
-- Name: geoaproximacao_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: postgres
--

SELECT pg_catalog.setval('"ProdNac2021".geoaproximacao_seq', 1, false);


--
-- TOC entry 2203 (class 0 OID 0)
-- Dependencies: 190
-- Name: geolocalizacao_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: postgres
--

SELECT pg_catalog.setval('"ProdNac2021".geolocalizacao_seq', 4, true);


--
-- TOC entry 2204 (class 0 OID 0)
-- Dependencies: 192
-- Name: georreferenciamento_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: postgres
--

SELECT pg_catalog.setval('"ProdNac2021".georreferenciamento_seq', 4, true);


--
-- TOC entry 2205 (class 0 OID 0)
-- Dependencies: 194
-- Name: logbd_seq; Type: SEQUENCE SET; Schema: ProdNac2021; Owner: postgres
--

SELECT pg_catalog.setval('"ProdNac2021".logbd_seq', 1882, true);


--
-- TOC entry 2043 (class 2606 OID 38222)
-- Name: cdg pk_cdg; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".cdg
    ADD CONSTRAINT pk_cdg PRIMARY KEY (idcdg);


--
-- TOC entry 2045 (class 2606 OID 38224)
-- Name: geoaproximacao pk_geoaproximacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".geoaproximacao
    ADD CONSTRAINT pk_geoaproximacao PRIMARY KEY (codapro);


--
-- TOC entry 2047 (class 2606 OID 38226)
-- Name: geolocalizacao pk_geolocalizacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".geolocalizacao
    ADD CONSTRAINT pk_geolocalizacao PRIMARY KEY (codgeoloc);


--
-- TOC entry 2049 (class 2606 OID 38228)
-- Name: georreferenciamento pk_georreferenciamento; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".georreferenciamento
    ADD CONSTRAINT pk_georreferenciamento PRIMARY KEY (codgeorr);


--
-- TOC entry 2051 (class 2606 OID 38230)
-- Name: logbd pk_logbd; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".logbd
    ADD CONSTRAINT pk_logbd PRIMARY KEY (codlog);


--
-- TOC entry 2053 (class 2606 OID 38232)
-- Name: procedmetodolog pk_procedmetodolog; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT pk_procedmetodolog PRIMARY KEY (codproced);


--
-- TOC entry 2055 (class 2606 OID 38234)
-- Name: profissional pk_profissional; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".profissional
    ADD CONSTRAINT pk_profissional PRIMARY KEY (codprof);


--
-- TOC entry 2057 (class 2606 OID 38236)
-- Name: tipoacao pk_tipoacao; Type: CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".tipoacao
    ADD CONSTRAINT pk_tipoacao PRIMARY KEY (codacao);


--
-- TOC entry 2065 (class 2620 OID 38237)
-- Name: geoaproximacao t_ins_geoaproximacao; Type: TRIGGER; Schema: ProdNac2021; Owner: postgres
--

CREATE TRIGGER t_ins_geoaproximacao BEFORE INSERT ON "ProdNac2021".geoaproximacao FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_geoaproximacao();


--
-- TOC entry 2066 (class 2620 OID 38238)
-- Name: geolocalizacao t_ins_geolocalizacao; Type: TRIGGER; Schema: ProdNac2021; Owner: postgres
--

CREATE TRIGGER t_ins_geolocalizacao BEFORE INSERT ON "ProdNac2021".geolocalizacao FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_geolocalizacao();


--
-- TOC entry 2067 (class 2620 OID 38239)
-- Name: georreferenciamento t_ins_georreferenciamento; Type: TRIGGER; Schema: ProdNac2021; Owner: postgres
--

CREATE TRIGGER t_ins_georreferenciamento BEFORE INSERT ON "ProdNac2021".georreferenciamento FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_ins_georreferenciamento();


--
-- TOC entry 2064 (class 2620 OID 38240)
-- Name: cdg t_ins_logbd; Type: TRIGGER; Schema: ProdNac2021; Owner: postgres
--

CREATE TRIGGER t_ins_logbd AFTER INSERT OR DELETE OR UPDATE ON "ProdNac2021".cdg FOR EACH ROW EXECUTE PROCEDURE "ProdNac2021".f_trigger_logbd();


--
-- TOC entry 2058 (class 2606 OID 38241)
-- Name: geoaproximacao fk_geoaproximacao_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".geoaproximacao
    ADD CONSTRAINT fk_geoaproximacao_ref_cdg FOREIGN KEY (fk_idcdg_apro) REFERENCES "ProdNac2021".cdg(idcdg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2059 (class 2606 OID 38246)
-- Name: geolocalizacao fk_geolocalizacao_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".geolocalizacao
    ADD CONSTRAINT fk_geolocalizacao_ref_cdg FOREIGN KEY (fk_idcdg_geol) REFERENCES "ProdNac2021".cdg(idcdg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2060 (class 2606 OID 38251)
-- Name: georreferenciamento fk_georreferenciamento_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".georreferenciamento
    ADD CONSTRAINT fk_georreferenciamento_ref_cdg FOREIGN KEY (fk_idcdg_geor) REFERENCES "ProdNac2021".cdg(idcdg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2061 (class 2606 OID 38256)
-- Name: procedmetodolog fk_procedmetodolog_ref_cdg; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_cdg FOREIGN KEY (fk_idcdg) REFERENCES "ProdNac2021".cdg(idcdg) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2062 (class 2606 OID 38261)
-- Name: procedmetodolog fk_procedmetodolog_ref_profissional; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_profissional FOREIGN KEY (fk_codprof) REFERENCES "ProdNac2021".profissional(codprof) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2063 (class 2606 OID 38266)
-- Name: procedmetodolog fk_procedmetodolog_ref_tipoacao; Type: FK CONSTRAINT; Schema: ProdNac2021; Owner: postgres
--

ALTER TABLE ONLY "ProdNac2021".procedmetodolog
    ADD CONSTRAINT fk_procedmetodolog_ref_tipoacao FOREIGN KEY (fk_codacao) REFERENCES "ProdNac2021".tipoacao(codacao) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2021-04-15 09:57:20

--
-- PostgreSQL database dump complete
--

