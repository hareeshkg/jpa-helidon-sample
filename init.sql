
CREATE TABLE public.airport (
    id bigint NOT NULL,
    apt_code character varying(255),
    apt_name text,
    city_name text,
    country text
);

CREATE SEQUENCE public.apt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

INSERT INTO public.airport VALUES (1, 'DXB', 'Dubai International Airport', 'Dubai', 'UAE');
INSERT INTO public.airport VALUES (2, 'JFK', 'John F Kennedy International Airport', 'Newyork', 'USA');
INSERT INTO public.airport VALUES (3, 'COK', 'Cochin International Airport', 'Kochi', 'India');

SELECT pg_catalog.setval('apt_id_seq', 3, true);



