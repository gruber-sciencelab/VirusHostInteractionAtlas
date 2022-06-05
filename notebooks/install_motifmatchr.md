
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

Open R (we used ) and then follow the installation instructions below (after you have made sure that the above mentioned Centos libraries are installed).

```console
> R.version
               _                           
platform       x86_64-redhat-linux-gnu     
arch           x86_64                      
os             linux-gnu                   
system         x86_64, linux-gnu           
status                                     
major          3                           
minor          6.0                         
year           2019                        
month          04                          
day            26                          
svn rev        76424                       
language       R                           
version.string R version 3.6.0 (2019-04-26)
nickname       Planting of a Tree          
```

The setting below will set repositories so that the "not available for R version" is largely not a problem anymore.

```console
setRepositories(ind = c(1:6, 8))
```
To permanently change this, add a line like setRepositories(ind = c(1:6, 8)) to your Rprofile.site file. Source: https://stackoverflow.com/questions/25721884/how-should-i-deal-with-package-xxx-is-not-available-for-r-version-x-y-z-wa

### Install R packages

```console
install.packages("RCurl")
install.packages("CNEr")
BiocManager::install("motifmatchr")
```

To the request if any packages should be updated choose "all".

### Load the R library

```console
library(motifmatchr)
```
