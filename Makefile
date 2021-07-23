#     makefile for MOOG with all of the common block assignments;
#     this is for a  64-bit linux machine

#     here are the object files
IEOBJECTS = AngWeight.o Batom_enk.o Bmolec.o Cdcalcie_JS.o \
	  Compress_enk.o \
          Damping.o Discov.o Eqlib.o Gammabarkie.o Getasci.o Getcount.o \
          Getnum.o \
          Inlinesie.o Inmodelie.o Invert.o Jexpint.o \
          Linlimit_enk.o \
          Moogie.o Nansi.o Nearlyba.o Number.o Opaccouls.o \
          OpacHelium.o \
          OpacHydrogen.o Opacit_enk.o Opacmetals.o Opacscat.o Partfn.o \
          Partnew.o Prinfoie.o Rinteg.o Sourcefuncie_scat_cont.o \
          Sourcefuncie_scat_line.o Sunder.o Synspecie.o Synthie.o \
          Taukap.o Trudamp.o Ucalc.o Voigt.o

#     here are the common files
IECOMMON =  Atmos.com Dampdat.com Dummy.com Factor.com Kappa.com \
          Linex.com Mol.com Quants.com Source.com

FC = f95 -Wall
   
#        here are the compilation and linking commands
all: MOOGIE;
    
MOOGIE:  $(IEOBJECTS);
	$(FC) $(IEOBJECTS) -o MOOGIE 

$(IEOBJECTS): $(IECOMMON)

clean:
	-rm -f *.o MOOGIE 
