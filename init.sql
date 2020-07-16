
CREATE TABLE public.airport (
    id integer NOT NULL,
    apt_code character varying(255),
    city_name text,
    apt_name text,
    country text
);

INSERT INTO public.airport VALUES (1, 'DXB', 'Dubai International Airport', 'Dubai', 'UAE');
INSERT INTO public.airport VALUES (2, 'JFK', 'John F Kennedy International Airport', 'Newyork', 'USA');
INSERT INTO public.airport VALUES (2, 'COK', 'Cochin International Airport', 'Kochi', 'India');

