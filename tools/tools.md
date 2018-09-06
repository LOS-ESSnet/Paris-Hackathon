# LOS Paris Hackathon: software tools

This page lists different tools that could be useful for the participants, without aiming at exhaustivity.

## Java

The two main packages for the manipulation of RDF data are Apache Jena and Eclipse RDF4J.

### Apache Jena

Jena (https://jena.apache.org/) is a top-level project of the Apache foundation, and actively developed under its auspices.

The [Getting started](https://jena.apache.org/getting_started/index.html) page gives an overview of the library structure and links to interesting tutorials and documentations.

To use Jena in a Maven project, just add a [dependency](https://mvnrepository.com/artifact/org.apache.jena/apache-jena-libs) on the `apache-jena-libs` artifact ([more detail here](https://jena.apache.org/download/maven.html)).

### RDF4J

RDF4J (http://rdf4j.org/), previously known as Sesame, is currently in incubation phase at the Eclipse foundation.

The [Documentation](http://docs.rdf4j.org/) page gives an overview of the library structure and links to interesting tutorials and documentations.

To use RDF4J in a Maven project, just add a [dependency](https://mvnrepository.com/artifact/org.eclipse.rdf4j/rdf4j-runtime) on the `rdf4j-runtime` artifact ([more detail here](http://docs.rdf4j.org/programming)).

### Other tools

A number of useful tools can be used in order to read the source data.

#### Apache POI

[Apache POI](https://poi.apache.org/) is a good solution for reading Microsoft Office documents, and in particular Excel spreadsheets, even very large ones.

#### Apache Commons CSV

[Apache Commons CSV](https://commons.apache.org/proper/commons-csv/) is an efficient and flexible solution for reading CSV files.

### Exemples

The [POP5](https://github.com/LOS-ESSnet/POP5) program shows how to work with Apache Jena. See the [DataSetModelMaker](https://github.com/LOS-ESSnet/POP5/blob/master/src/main/java/eu/europa/ec/eurostat/los/pop5/DataSetModelMaker.java) class for an example of reading Excel data with POI and transforming it to RDF, and the [DSDModelMaker](https://github.com/LOS-ESSnet/POP5/blob/master/src/main/java/eu/europa/ec/eurostat/los/pop5/DSDModelMaker.java) for how to make a SPARQL query with Jena.

The [NUTS GeoSPARQL](https://github.com/LOS-ESSnet/NUTS-GeoSPARQL) program also uses Jena, but Apache Commons CSV is used to read the raw data.

The DSD Loader (see below) is an example of Java program using Eclipse RDF4J framework.

## Python

[RDFLib](https://pypi.org/project/rdflib/) is a Python library for working with RDF. It also provides a SPARQL engine.

A demo Jupyter notebook showing how to query a SPARQL endpoint is provided [here](sparql-python.ipynb).

A web application using [Dash](https://plot.ly/products/dash/) is also available. The source code is [here](https://github.com/jfeudeline/los-python-app) and the application is deployed [here](https://los-dash-app.herokuapp.com/).

## R

The two main packages for the manipulation of `RDF` data are `rdflib` and `SPARQL`.

### The rdflib package

The [rOpenSci](https://ropensci.org/)'s `rdflib` package (https://cran.r-project.org/package=rdflib) provides a friendly and concise user interface for performing common tasks on `RDF` data, such as parsing and converting between formats including `rdfxml`, `turtle`, `nquads`, `ntriples`, and `trig`, creating `RDF` graphs, and performing `SPARQL` queries.  

This package wraps the rOpenSci's `redland` R package (https://cran.r-project.org/package=redland) that implements an R interface to the Redland RDF C library,
described at http://librdf.org/docs/api/index.html.  
See the installation instructions here: [doi:10.5063/F1VM496B](http://doi.org/10.5063/F1VM496B).

### The SPARQL package

The `SPARQL` package (https://cran.r-project.org/package=SPARQL): use `SPARQL` to pose `SELECT` or `UPDATE` queries to an end-point.

### Demo

An R Shiny demo application using SPARQL queries and some dataviz is provided [here](https://github.com/LOS-ESSnet/SPARQL-Shiny-Demo).


## JavaScript

### Libraries

The [results](https://www.npmjs.com/search?q=keywords:RDF) of a search for 'RDF' on the npm repository show that a large number of JavaScript resources are available. A number of these projects have recently regrouped into the [RDF.js](https://github.com/rdfjs/) community. In particular, the [N3](https://www.npmjs.com/package/n3) library is a good solution for handling RDF data inside the browser.

For React/Redux applications, [SPARQL-Connect](https://www.npmjs.com/package/sparql-connect) is a useful tools for sending SPARQL queries and storing the results in the application state.

### Examples

The [DSD Editor](https://github.com/LOS-ESSnet/DSD-Editor) is an example of React application using N3.js with local storage.

The [SPARQL React demo](https://github.com/LOS-ESSnet/SPARQL-React-Demo) shows how to query SPARQL data and to make visualisations with it.

The [Operation Explorer](https://github.com/FranckCo/Operation-Explorer) is a prototype tools developed by Insee that uses SPARQL Connect. 

## High-level tools

### Centralised LOSD Publication Platform

The Centralised LOSD Publication Platform is a set of tools that have been thoroughly studied and deployed/adapted by [Derilinx](https://derilinx.com/), [ADAPT](https://www.adaptcentre.ie/) and [Insight](https://www.insight-centre.org/) to form the LOSD publication pipeline: Data Cataloging, Conversion, Publishing, and Visualisation and Analysis.

Details about the LOSD Publication pipeline are available [here](losd.md).

### DSD Editor

The [DSD Editor](https://github.com/LOS-ESSnet/DSD-Editor) is a prototype web app designed to edit [Data Cube](https://www.w3.org/TR/vocab-data-cube/) Data Structure Definitions. This ReactJS tool is based on [N3.js](https://github.com/rdfjs/N3.js) which provides a local RDF store. Import, export, create and edit your RDF data!

### DSD Loader

The [DSD Loader](https://github.com/Landalvic/los-hackathon) is a React + Java tool that allows to load, create and modify [Data Cube](https://www.w3.org/TR/vocab-data-cube/) Data Structure Definitions and to load the corresponding data into an RDF triple store. It can also be used to visualize the data as XML or JSON.

### Open Cube Toolkit

The [Open Cube Toolkit](http://opencube-toolkit.eu/) is a collection of tools designed to work with RDF data cubes.

### Tools from the OpenGovIntelligence project

The [GitHub repository](https://github.com/OpenGovIntelligence) of the project contains the source code of the tools developed during the Open Cube and the OpenGovIntelligence projects.
