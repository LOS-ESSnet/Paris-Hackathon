# LFS CSV data to RDF data cube

During the [Linked Open Statistics hackathon](https://github.com/LOS-ESSnet/Paris-Hackathon) that took place on September 10th and September 11th 2018, we worked with **[LFS series dataset](https://github.com/LOS-ESSnet/Paris-Hackathon/blob/master/data/lfs-fr.md)** ([download CSV](http://linked-open-statistics.org/plosh/lfs-qlf15c0-fr.csv)) and created a [Data structure definition](https://www.w3.org/TR/vocab-data-cube/#dsd) and exported the observations (data cells) to RDF using the [Data cube ontology](https://www.w3.org/TR/vocab-data-cube/).

The Data structure definition (`lfs_dsd.ttl`) was written by hand, inspired by [the example](https://www.w3.org/TR/vocab-data-cube/#full-example) used in the Data cube specification.

The observations were extracted from the CSV using [TARQL](https://github.com/tarql/tarql) and a [SPARQL] query (`csvdata2qbObservations.rq`):

```bash
tarql csvdata2qbObservations.rq lfs-qlf15c0-fr.csv
```

The [age code list from Eurostat (CL_AGE)](http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=ACT_OTH_CLS_DLD&StrNom=CL_AGE_&StrFormat=CSV&StrLanguageCode=EN&IntKey=&IntLevel=&bExport=) was converted from the CSV to RDF with regular expressions.

## Contributors

- [Colin Maudry](http://colin.maudry.com) (Independent Linked Data consultant)
- Frédéric Comte (INSEE)
