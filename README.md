Python-wrapped, stripped-down, modified version of MOOG17SCAT (Alex P. Ji, U. Chicago, Aug 2017 version with scattering; https://github.com/alexji/moog17scat) designed for generation of thousands of synthetic spectra simulatenously (with parallel processing). The improved treatment of scattering is important for the accurate computation of abundances from blue absorption features generated in metal-poor stellar atmospheres.

MOOG is a radiative transfer code for stellar abundances written by Chris Sneden (http://www.as.utexas.edu/~chris/moog.html).

MOOGIE by I. Escala (Carnegie, 2018). Utilized to generate the ATLAS9+MOOG based grid of synthethic spectra in Escala et al. 2019: https://ui.adsabs.harvard.edu/abs/2019ApJ...878...42E/abstract

Note that MOOGIE has been extensively tested, such that it produces the same results for a single-spectrum synthesis as compared to the unmodified version of MOOG17SCAT.

Note that the MOOGIE files are separated into different folders for organizational purposes in this repository, but when running either the pure Fortran version or wrapping your own version of MOOGIE, you must have all the base MOOG files (in the "moog17scat" folder), your desired Makefile ("makefiles" folder), and desired Fortran wrapper ("fortran-wrapper" folder) in the same directory (along with any files in the "python" folder). Fortran and Python-wrapped-Fortran executables are present in the main directory.

Files ending in "enk" are directly taken from EMOOG (Evan N. Kirby, Caltech, 2008 onward), whereas files ending with "ba" are directly taken from MOOGBA (Gina E. Duggan, IPAC, 2018). Files containing "ie" have modifications introduced in MOOGIE. Absent the file endings, the files are directly from the unmodified version of MOOG17SCAT. All files unnecessary for the specified synthesis have been purged from MOOGIE.

# Set Up Instructions #

**PYTHON-WRAPPED VERSION**

The following instructions describe how to wrap MOOGIE in Python on your own system to create a Python function (MOOGIEPY). Note that MOOGIEPY does not contain MPI internal to MOOG -- to parallelize MOOGIEPY, MPI must be called externally using Python. In addition, looping over the processors must be done externally. The files Calculate_nloop.f and Calculate_params.f are intended to assit with the external looping.

To wrap MOOGIE in Python, use the F2PY module: https://docs.scipy.org/doc/numpy-dev/f2py/

Requires GCC verison > 6.0
Note that you must edit the paths directly within Moogie_py.f to match that of your system
To wrap MOOGIE, you must first compile it using the command make -f Makefile.pywrap.
Then execute the command, "f2py -m moogie -h moogie.pyf *.f"

Followed by "f2py -c moogie.pyf *.o"

These commands are explicitly outlined in the pywrap.sh bash file. This should generate a file moogie.so, which you can use as follows (see also the file moogie.py for example usage):

* from moogie import moogie
* moogie(teff, logg, feh, alphafe, rank, synth_run, replace)
* where teff, logg, feh, alphafe (float) are the parameters for the spectrum you would like to synthesize, rank is the processor rank -- if not using MOOGIEPY in combination with MPI, rank = 0, synth_run is a string corresponding to the directory in which MOOG can find the relevant files (rank directories containing linelists, Barklem.dat information, etc.), replace is a Boolean object, where if replace = 0 files are NOT overwritten if they already exist

**PURE FORTRAN VERSION**

Ensure that the paths in Moogie.f point to the locations of your atmospheric models and your desired output directories.

NOTE: MOOGIE is intended to work with KURUCZ type atmospheric models

To compile MOOGIE, execute the following command. NOTE: MOOGIE is intended specifically for Linux machines.

make -f Makefile

To execute tests in MOOGIE, you must change the parameters in Moogie.f

To synthesize a single spectrum, make sure that test = .true.
You can change the test parameters at the bottom of the file in Moogie.f
Note that changing the parameters means that you must recompile MOOGIE
make -f Makefile clean
make -f Makefile

To run MOOGIE, either copy the executable to the relevant directory, or point to it within the directory by writing its full path, e.g., /home/iescala/moogie/MOOGIE

Moogie.f is for running standard synthesis of single or multiple spectra

Moogiempi.f is intended for running on a HPC system using MPI
Moogie_py.f is for wrapping MOOGIE in Python

To use Moogiempi.f, instead compile MOOGIE using the makefile Makefile.mpi and edit the file Moogiempi.f accordingly (similar to Moogie.f). To execute, include the command "mpirun ./MOOGIE" in the body of your job submission file, where MOOGIE is contained in the relevant directory.
