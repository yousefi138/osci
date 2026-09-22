# Running OSCA within a container

## Instructions

To run OSCA inside a container rather in the user environment, 
use the following steps:

1. Retrieve container

A copy of the container is available from `docker.io`. 
It can be downloaded as follows:

```
CONTAINER=osci
USERNAME=matthewsuderman
REGISTRY=docker.io
URL=$REGISTRY/$USERNAME/$CONTAINER
apptainer pull $CONTAINER.sif oras://$URL
```

2. Tell osci you want to use the container

Move `osci.sif` to the working directory of R
and then, in R, indicate that you'd like to use the container:

```
library(osci)
osci.use_container(TRUE)
```

## Customization for advanced users

The `osci.use_container()` function modifies the `osci.cmd` option in R as follows:
```
options(osci.cmd="CWD=$(realpath $(pwd)); apptainer run -B $CWD:$CWD --pwd $CWD osci.sif osca")
```
The osca command could be customized by editing this option directly. 

Further customization is possible by modifying the container. 
 
1. Edit [osci.def](osci.def)

2. Rebuild container file

```
apptainer build $CONTAINER.sif $CONTAINER.def
```

3. Upload container file

```
apptainer registry login --username $USERNAME docker://$REGISTRY
apptainer push $CONTAINER.sif oras://$URL:latest
```

