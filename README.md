# tiny_earth_VICE
A virtual interactive computing environment (VICE) for Tiny Earth Genomics

This Dockerfile is designed to be used with [Cyverse](https://cyverse.org/), although you can also use it locally through a browser, as part of the Tiny Earth Genomics course. 
It has the following bioinformatics tools installed:

* [AntiSMASH](https://antismash.secondarymetabolites.org/#!/start) (For finding and annotating secondary metabolite pathways)
* [Prokka](https://github.com/tseemann/prokka) (For annotating bacterial genomes)
* [KofamScan](https://github.com/takaram/kofam_scan) (For sorting genes into functional categories)
* [GTDB-Tk](https://github.com/Ecogenomics/GTDBTk) (For classifying genomes taxonomically)
* [CheckM](https://ecogenomics.github.io/CheckM/#:~:text=CheckM%20provides%20a%20set%20of,copy%20within%20a%20phylogenetic%20lineage.) (For assessing metagnomic bin quality)

If you would like to run the Docker image locally, first build or pull the image from Dockerhub, then run the following command:

```bash
docker run -it --rm -v /$HOME:/work --workdir /work -p 8888:8888 -e REDIRECT_URL=http://localhost:8888 jasonkwan/tiny_earth_vice:latest
``` 

Then, you should be able to interact with the image by navigating to `http://localhost:8888` in your browser. Note: In the example above, the working directory for the image will
be your `$HOME` directory. Change this to whatever you want to use.
