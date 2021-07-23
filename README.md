# README #

* MOOGIE
* Version 0.0 
* November 22 2017
* I. Escala (iescala@caltech.edu)

* MOOGIE is a modification of MOOG17SCAT (MOOG August 2017 verison with scattering).
* It includes a proper treatment of scattering, which is important for accurately computing
* abundances of blue lines in metal-poor stars.

* MOOG17SCAT is a modification of MOOG by Alex Ji
* MOOGIE was modified by I. Escala, based on G. Duggan's and E. Kirby's modifications of
* MOOG to enable the computation of thousands of spectra simultaneously by parallezing MOOG

* The introduced modifications enable synthesizing a grid of spectra with parameters including
* effective temperature, surface gravity, metallicity, and alpha abundance of the model atmosphere.
* In particular, MOOGIE is intended to synthesize the blue region of the spectrum, 4100 - 6300 A.

* Files ending in "enk" are directly taken from EMOOG (E. Kirby), whereas files ending with "ba" 
* are directly taken from MOOGBA (G. Duggan). Files containing "ie" have modifications introduced 
* in MOOGIE. Absent the file endings, the files are directly from MOOG17SCAT. All files unnecessary 
* for the specified synthesis have been purged from MOOGIE. 

* MOOGIE has been extensively tested, such that it produces the same results for a single-spectrum
* synthesis as compared to MOOG17SCAT.

* MOOG is a radiative transfer code for stellar abundances written by Chris Sneden.
* http://www.as.utexas.edu/~chris/moog.html

### SETUP ###

* Download MOOGIE by obtaining it from this repository.

* Ensure that the paths in Moogie.f point to the locations of your atmospheric models
* and your desired output directories. 
* NOTE: MOOGIE is intended to work with KURUCZ type atmospheric models

* To compile MOOGIE, execute the following command.
* NOTE: MOOGIE is intended specifically for Linux machines. 
* make -f Makefile

* To execute tests in MOOGIE, you must change the parameters in Moogie.f
* To synthesize a single spectrum, make sure that test = .true.
* You can change the test parameters at the bottom of the file in Moogie.f
* Note that changing the parameters means that you must recompile MOOGIE
* make -f Makefile clean
* make -f Makefile

* To run MOOGIE, either copy the executable to the relevant directory,
* or point to it within the directory by writing its full path
* e.g., /home/iescala/moogie/MOOGIE

* Moogie.f is for running standard synthesis of single or multiple spectra
* Moogiempi.f is intended for running on a HPC system using MPI

* To use Moogiempi.f, instead compile MOOGIE using the makefile Makefile.mpi
* and edit the file Moogiempi.f accordingly (similar to Moogie.f)
* To execute the MPI verison of MOOGIE, you must submit a PBS job
* Ensure that you load the relevant modules, such as openmpi
* To execute, include the command "mpirun ./MOOGIE" in the body of your PBS file, where
* MOOGIE is contained in the relevant directory