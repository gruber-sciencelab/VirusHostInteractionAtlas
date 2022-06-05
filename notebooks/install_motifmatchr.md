
# Installation of motifmatchr on Centos

Motifmatchr was used for benchmarking (it is not required for the use of SMEAGOL).

Below are listed the installation steps.

## Centos packages

Install libraries that motifmatchr will assume are available on Centos:

```console
sudo yum install libxml2-devel
sudo yum install libcurl-devel
sudo yum install openssl-devel
sudo yum install gsl-devel
```

## R packages

The setting below will set repositories so that the "not available for R version" is largely not a problem anymore.

```console
setRepositories(ind = c(1:6, 8))
```
To permanently change this, add a line like setRepositories(ind = c(1:6, 8)) to your Rprofile.site file.

Source: https://stackoverflow.com/questions/25721884/how-should-i-deal-with-package-xxx-is-not-available-for-r-version-x-y-z-wa

```console
install.packages("RCurl")
install.packages("CNEr")
BiocManager::install("motifmatchr")
```

To the request if any packages should be updated choose "all".
