# LOS Paris Hackathon: software tools #

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

TBP


## Python

[RDFLib](https://pypi.org/project/rdflib/) is a Python library for working with RDF. It also provides a SPARQL engine.

## R

The two main packages for the manipulation of `RDF` data are `rdflib` and `SPARQL`.

### The rdflib package

The [rOpenSci](https://ropensci.org/)'s `rdflib` package (https://cran.r-project.org/package=rdflib) provides a friendly and concise user interface for performing common tasks on `RDF` data, such as parsing and converting between formats including `rdfxml`, `turtle`, `nquads`, `ntriples`, and `trig`, creating `RDF` graphs, and performing `SPARQL` queries.  

This package wraps the rOpenSci's `redland` R package (https://cran.r-project.org/package=redland) that implements an R interface to the Redland RDF C library,
described at http://librdf.org/docs/api/index.html.  
See the installation instructions here: [doi:10.5063/F1VM496B](http://doi.org/10.5063/F1VM496B).

### The SPARQL package

The `SPARQL` package (https://cran.r-project.org/package=SPARQL): use `SPARQL` to pose `SELECT` or `UPDATE` queries to an end-point.

## JavaScript

Search results for 'rdf' on yhe npm repository: https://www.npmjs.com/search?q=keywords:RDF

SPARQL-Connect: https://www.npmjs.com/package/sparql-connect


## High-level tools

### DSD Editor

The [DSD Editor](https://github.com/LOS-ESSnet/DSD-Editor) is a prototype web app designed to edit [Data Cube](https://www.w3.org/TR/vocab-data-cube/) Data Structure Definitions. This ReactJS tool is based on [N3.js](https://github.com/rdfjs/N3.js) which provides a local RDF store. Import, export, create and edit your RDF data!

### Open Cube Toolkit

The [Open Cube Toolkit](http://opencube-toolkit.eu/) is a collection of tools designed to work with RDF data cubes.

### Centralised LOSD Publication Platform
The Centralised LOSD Publication Platform is a set of tools that have been thoroughly studied and deployed/adapted by [Derilinx](https://derilinx.com/), [ADAPT](https://www.adaptcentre.ie/) and [Insight](https://www.insight-centre.org/) to form the LOSD publication pipeline: Data Cataloging, Conversion, Publishing, and Visualisation and Analysis.

Details about the LOSD Publication pipeline are available [here](losd.md).

### Chargement DSD
L'outil [chargement DSD](https://github.com/Landalvic/los-hackathon) est un poc fait en react + java qui permet de charger/modifier/supprimer des  DSD et de charger des données à l'intérieur, le tout basé sur le modèle [Data Cube](https://www.w3.org/TR/vocab-data-cube/). L'outil permet également de visualiser ces données en format XML ou JSON.
