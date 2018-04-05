--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.6
-- Dumped by pg_dump version 9.6.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = public, pg_catalog;

--
-- Name: create_service(character varying); Type: FUNCTION; Schema: public; Owner: hfuller
--

CREATE FUNCTION create_service(name character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare 
salt character varying;
pass character varying;
begin
salt := gen_salt('bf');
pass := md5(random()::text);

insert into service(name, hash) values(name, crypt(pass, salt));
return pass; end;
$$;


ALTER FUNCTION public.create_service(name character varying) OWNER TO hfuller;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: person; Type: TABLE; Schema: public; Owner: hfuller
--

CREATE TABLE person (
    id integer NOT NULL,
    username character varying NOT NULL,
    balance money DEFAULT 0
);


ALTER TABLE person OWNER TO hfuller;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: hfuller
--

CREATE SEQUENCE person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE person_id_seq OWNER TO hfuller;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hfuller
--

ALTER SEQUENCE person_id_seq OWNED BY person.id;


--
-- Name: service; Type: TABLE; Schema: public; Owner: hfuller
--

CREATE TABLE service (
    id integer NOT NULL,
    name character varying NOT NULL,
    hash character varying
);


ALTER TABLE service OWNER TO hfuller;

--
-- Name: service_id_seq; Type: SEQUENCE; Schema: public; Owner: hfuller
--

CREATE SEQUENCE service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE service_id_seq OWNER TO hfuller;

--
-- Name: service_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hfuller
--

ALTER SEQUENCE service_id_seq OWNED BY service.id;


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: hfuller
--

CREATE TABLE transaction (
    id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT statement_timestamp() NOT NULL,
    person_id integer NOT NULL,
    amount money NOT NULL,
    service_id integer NOT NULL,
    notes character varying
);


ALTER TABLE transaction OWNER TO hfuller;

--
-- Name: transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: hfuller
--

CREATE SEQUENCE transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE transaction_id_seq OWNER TO hfuller;

--
-- Name: transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hfuller
--

ALTER SEQUENCE transaction_id_seq OWNED BY transaction.id;


--
-- Name: person id; Type: DEFAULT; Schema: public; Owner: hfuller
--

ALTER TABLE ONLY person ALTER COLUMN id SET DEFAULT nextval('person_id_seq'::regclass);


--
-- Name: service id; Type: DEFAULT; Schema: public; Owner: hfuller
--

ALTER TABLE ONLY service ALTER COLUMN id SET DEFAULT nextval('service_id_seq'::regclass);


--
-- Name: transaction id; Type: DEFAULT; Schema: public; Owner: hfuller
--

ALTER TABLE ONLY transaction ALTER COLUMN id SET DEFAULT nextval('transaction_id_seq'::regclass);


--
-- Name: person person_id_key; Type: CONSTRAINT; Schema: public; Owner: hfuller
--

ALTER TABLE ONLY person
    ADD CONSTRAINT person_id_key UNIQUE (id);


--
-- Name: person person_username_key; Type: CONSTRAINT; Schema: public; Owner: hfuller
--

ALTER TABLE ONLY person
    ADD CONSTRAINT person_username_key UNIQUE (username);


--
-- Name: service service_id_key; Type: CONSTRAINT; Schema: public; Owner: hfuller
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_id_key UNIQUE (id);


--
-- Name: transaction transaction_id_key; Type: CONSTRAINT; Schema: public; Owner: hfuller
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_id_key UNIQUE (id);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: hfuller
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY ("timestamp");


--
-- Name: transaction transaction_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hfuller
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_person_id_fkey FOREIGN KEY (person_id) REFERENCES person(id);


--
-- Name: transaction transaction_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hfuller
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_service_id_fkey FOREIGN KEY (service_id) REFERENCES service(id);


--
-- PostgreSQL database dump complete
--

