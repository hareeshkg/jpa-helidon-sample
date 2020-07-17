# A step by step Tutorial for Helidon MP with JPA
Now that you are here , I assume you would be knowing that Helidon is a micro-service framework released by Oracle . As of now the framework supports two programming models namely Helidon MP and Helidon SE .



In this tutorial we are primarily going to look at how to create a Helidon MP microservice with JPA support .
Helidon MP is an implementation of Microprofile — Java EE’s answer to microservices platform— which is primarily contributed by Eclipse and hence mostly known as Eclipse Microprofile .

Read more about Helidon here https://helidon.io/#/

Let’s look at how to create a project so that we can jump into this new interesting framework .

## Step 1 — Create a quickstart Helidon application with maven archetype
Use a maven archetype to create the project skeleton. Helidon has released a set of archetypes to make life easy for us . Look at the available quickstart maven archetypes from Helidon here — https://mvnrepository.com/artifact/io.helidon.archetypes
In our case we are going to set up a project with the archetype helidon-quickstart-mp
```
mvn archetype:generate \
-DinteractiveMode=false \
-DarchetypeGroupId=io.helidon.archetypes \
-DarchetypeArtifactId=helidon-quickstart-mp \
-DarchetypeVersion=2.0.1 \
-DgroupId=com.hkg.helidon \
-DartifactId=jpa-helidon-sample \
-Dpackage=com.hkg.helidon.sample \
-DapplicationName=HelidonJPAApp
```
The archetype will generate a quickstart helidon mp project with the necessary code .
The generated code will have a resource named GreetResource as a quickstart API .
Build the project and run the application as a jar .
java -jar target/jpa-helidon-sample.jar
Once application is started you can access the Greet resource like given below
```
curl GET http://localhost:8080/greet
```
And we will see the below JSON response
```
{"message":"Hello World!"}
```
## Step 2 — Add dependencies in pom.xml for JPA support
Add the CDI ( context and dependency injection ) dependencies for JPA .
```
<dependency>
    <groupId>io.helidon.integrations.cdi</groupId>
    <artifactId>helidon-integrations-cdi-jpa</artifactId>
</dependency>
<dependency>
    <groupId>io.helidon.integrations.cdi</groupId>
    <artifactId>helidon-integrations-cdi-jta-weld</artifactId>
</dependency>
<dependency>
    <groupId>io.helidon.integrations.cdi</groupId>
    <artifactId>helidon-integrations-cdi-datasource-hikaricp</artifactId>
</dependency>
```
Helidon provides out-of-the-box support for JPA implementations like EclipseLink and Hibernate . Most of the examples that are available around the internet are using EclipseLink , so in this tutorial I am going to go with Hibernate .
Let’s add the dependency for the helidon Hibernate support .
```
<dependency>
   <groupId>io.helidon.integrations.cdi</groupId>
   <artifactId>helidon-integrations-cdi-hibernate</artifactId>
   <version>2.0.0</version>
 </dependency>
```
Next add the dependency for the database drivers . Here we are going to use PostgreSQL , since we will be running a postgresql database using Docker .
```
<dependency>
 <groupId>org.postgresql</groupId>
 <artifactId>postgresql</artifactId>
 <version>42.2.7</version>
</dependency>
```
And finally we add the jakarta JPA and JTA libraries to support the CDI libraries we added earlier
```
<dependency>
 <groupId>jakarta.persistence</groupId>
 <artifactId>jakarta.persistence-api</artifactId>
 <version>2.2.2</version>
</dependency>
<dependency>
 <groupId>javax.transaction</groupId>
 <artifactId>javax.transaction-api</artifactId>
 <version>1.2</version>
</dependency>
```
That’s all with the pom.xml !
## Step -3 Let’s set up a PostgreSQL database ( you can skip this step if you already have a database up and running )
We are going to set up a docker-compose file for starting up a docker container of PostgreSQL .
Create the docker-compose.yml file in the project root and define the details as given below
```
version: '3'
services:
  airport-db:
    image: library/postgres:latest
    ports:
      - "5432:5432"
    container_name: aiport-db-postgres
    environment:
      - POSTGRES_DB= airport-db
      - POSTGRES_PASSWORD=docker
      - POSTGRES_USER=docker
    volumes:
      - ./data:/var/lib/postgresql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
```
As you can see we have included an init.sql file which has the database script to create a database objects and to initialise the data.
contents of init.sql is as given below
```
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
```
To start the data base use the docker compose up command
```
docker-compose up 
```
## Step 4 : Configuring Helidon to connect to the Database
Create persistence.xml configured for postgreSQL under the folder src/resources/META-INF

```
<?xml version="1.0" encoding="UTF-8"?>
<persistence version="2.2"
             xmlns="http://xmlns.jcp.org/xml/ns/persistence"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/persistence
                                 http://xmlns.jcp.org/xml/ns/persistence/persistence_2_2.xsd">
    <persistence-unit name="aptrestPU" transaction-type="JTA">
        <provider>org.hibernate.jpa.HibernatePersistenceProvider</provider>
        <jta-data-source>airportDataSource</jta-data-source>
        

        <properties>

            <property name="javax.persistence.jdbc.driver" value="org.postgresql.Driver"/>
            <property name="javax.persistence.jdbc.url" value="jdbc:postgresql://localhost:5432/airport-db"/>
            <property name="javax.persistence.jdbc.user" value="docker" />
            <property name="javax.persistence.jdbc.password" value="docker" />
            <property name="hibernate.dialect" value="org.hibernate.dialect.PostgreSQLDialect" />
            <property name="hibernate.archive.autodetection" value="class" />
            <property name="hibernate.show_sql" value="true" />
            <property name="hibernate.format_sql" value="true" />
            <property name="hibernate.hbm2ddl.auto" value="update" />

        </properties>
    </persistence-unit>
</persistence>
```
Now we need to configure the Datasource in the application.yaml so that a default datasource is injected to the EntityManager .
Content of the application.yaml is given below

```
server:
    port: 8080
javax:
    sql:
        DataSource:
            airportDataSource:
                dataSourceClassName: org.postgresql.ds.PGSimpleDataSource
                dataSource:
                    url: jdbc:postgresql://localhost:5432/airport-db
                    user: docker
                    password: docker
```
## Step -5 : Implementing an end-to-end JAX-RS based CRUD service
Create the following classes

```
Airport.java
package com.hkg.helidon.airport.enitity;
import java.io.Serializable;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
@Entity
@Table(name = "AIRPORT")
public class Airport implements Serializable {
 
 /**
  * 
  */
 private static final long serialVersionUID = 1L;
@Id
 @Column(name="id")
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "apt_id_seq")
    @SequenceGenerator(name = "apt_id_seq", sequenceName = "apt_id_seq", allocationSize=1)
 private Long id ;
 
 @Column(name="apt_code")
 private String airportCode;
 
 @Column(name="apt_name")
 private String airportName;
 
 @Column(name="city_name")
 private String cityName;
 
 @Column(name="country")
 private String countryName;
public Long getId() {
  return id;
 }
public void setId(Long id) {
  this.id = id;
 }
public String getAirportCode() {
  return airportCode;
 }
public void setAirportCode(String airportCode) {
  this.airportCode = airportCode;
 }
public String getAirportName() {
  return airportName;
 }
public void setAirportName(String airportName) {
  this.airportName = airportName;
 }
public String getCityName() {
  return cityName;
 }
public void setCityName(String cityName) {
  this.cityName = cityName;
 }
public String getCountryName() {
  return countryName;
 }
public void setCountryName(String countryName) {
  this.countryName = countryName;
 }
}
```
AirportRespository.java

```
package com.hkg.helidon.airport.repository;
import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaDelete;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Root;
import javax.transaction.Transactional;
import com.hkg.helidon.airport.enitity.Airport;
@ApplicationScoped
public class AirportRepository {
@PersistenceContext
 EntityManager entityManager;
@Transactional
 public Airport createOrUpdate(Airport airport) {
  if (airport.getId() == null) {
   this.entityManager.persist(airport);
   return airport;
  } else {
   return this.entityManager.merge(airport);
  }
 }
@Transactional
 public void deleteById(Long id) {
  CriteriaBuilder cb = this.entityManager.getCriteriaBuilder();
  CriteriaDelete<Airport> delete = cb.createCriteriaDelete(Airport.class);
  Root<Airport> root = delete.from(Airport.class);
  delete.where(cb.equal(root.get("id"), id));
  this.entityManager.createQuery(delete).executeUpdate();
 }
public List<Airport> getAllAirports() {
  CriteriaBuilder cb = entityManager.getCriteriaBuilder();
  CriteriaQuery<Airport> cq = cb.createQuery(Airport.class);
  Root<Airport> rootEntry = cq.from(Airport.class);
  CriteriaQuery<Airport> all = cq.select(rootEntry);
  TypedQuery<Airport> allQuery = entityManager.createQuery(all);
  return allQuery.getResultList();
}
 
}

```

AirportService.java

```
package com.hkg.helidon.airport.service;
import java.util.List;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import com.hkg.helidon.airport.enitity.Airport;
import com.hkg.helidon.airport.repository.AirportRepository;
@ApplicationScoped
public class AirportService {
 
 private final AirportRepository  airportRepository;
 
 @Inject
 public AirportService(AirportRepository airportRepository) {
  this.airportRepository = airportRepository;
 }
 
 @Transactional
 public Airport save(Airport airport) {
  return airportRepository.createOrUpdate(airport);
 }
 
 public List<Airport> getAllAirports() {
  return airportRepository.getAllAirports();
 }
 
    @Transactional
 public void deleteByid(Long id) {
  airportRepository.deleteById(id);
 }
}
```

AirportResource.java

```
package com.hkg.helidon.airport.resource;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.container.ResourceContext;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;
import javax.ws.rs.core.MediaType;
import static javax.ws.rs.core.Response.ok;
import com.hkg.helidon.airport.enitity.Airport;
import com.hkg.helidon.airport.service.AirportService;
@Path("/airport")
@RequestScoped
public class AirportResource {
private final AirportService airporService;
@Context
 UriInfo uriInfo;
@Context
 ResourceContext resourceContext;
@Inject
 public AirportResource(AirportService airporService) {
  this.airporService = airporService;
 }
@GET
 @Path("/all")
 @Produces(MediaType.APPLICATION_JSON)
 public Response getAllAirports() {
  return ok(this.airporService.getAllAirports()).build();
 }
@POST
 @Path("/save")
 @Consumes(MediaType.APPLICATION_JSON)
 public Response save(Airport airport) {
  return ok(this.airporService.save(airport)).build();
 }
@DELETE
 @Path("/delete/{id}/")
 public Response deleteOrderById(@PathParam("id") Long id) {
try {
   this.airporService.deleteByid(id);
  } catch (Exception e) {
   return Response.status(Response.Status.OK).entity("Delete failed").build();
  }
  return Response.status(Response.Status.OK).entity("Deleted successfully").build();
 }
}
```

## Step-6 Add the entity in persistence-unit

Add the Airport entry in persistence.xml under the persistence-unit
```
<persistence-unit name="aptrestPU" transaction-type="JTA">
.....
<jta-data-source>airportDataSource</jta-data-source><class>com.hkg.helidon.airport.enitity.Airport</class>
<properties>
......
......
</persistence-unit>
```

## Step-7 The final step . Build , Run and Test your project
Build the project with 
```
maven clean install
```
And now you can run the application
```
java -jar target/jpa-helidon-sample.jar
```
Test the application for the GET,POST and DELETE functions
```
curl GET http://localhost:8080/airport/all
```
To save a new entry
```
curl POST http://localhost:8080/airport/save {"airportCode":"AMS","airportName":"Amsterdam International Airport","cityName":"Amsterdam","countryName":"Netherlands"}
```
To save a delete an entry
```
curl DELETE http://localhost:8080/airport/delete/4
```
So we saw how to configure a helidon MP microservice with JPA support and build and end-to-end CRUD service.