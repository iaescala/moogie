
c      subroutine inmodel (nfmodel, cfei)
      subroutine inmodel (nfmodel)
c******************************************************************************
c     This subroutine reads in the model 
c****************************************************************************** 

      implicit real*8 (a-h,o-z) 
      include 'Atmos.com'
      include 'Linex.com'
      include 'Mol.com'
      include 'Quants.com'
      include 'Factor.com'
      include 'Dummy.com'
      real*8 element(95), logepsilon(95)
      real*8 kaprefmass(100)
      real*8 bmol(110)
      real*8 cfei
      character list*80, list2*70
      character*80 moditle
      integer append, nfmodel
      character*10 modtype


c*****Read in the key word to define the model type
      modelnum = modelnum + 1
      rewind nfmodel
      read (nfmodel,2001) modtype
c      write (nf1out,1010) modtype
c      if (modtype .eq. 'begn      ' .or.  modtype .eq. 'BEGN      ') 
c     .   write (nf1out,1011)


c*****Read a comment line (usually describing the model)
      read (nfmodel,2002) moditle
      write(*,*)moditle


c*****Read the number of depth points
      read (nfmodel,2002) list
      list2 = list(11:)
      read (list2,*) ntau
c      if (ntau .gt. 100) then
c         write (array,1012)
c         call prinfo (10)
c         stop
c      endif


c     OR: Read in a model from the output of the ATLAS code.  This
c     modtype is called "KURUCZ".  On each line the numbers are:
c     rhox, t, pgas, ne, and Rosseland mean opacity (cm^2/gm) (perhaps also,
c     two values not used by MOOG).  
      do i=1,ntau
         read (nfmodel,*) rhox(i),t(i),pgas(i),ne(i),kaprefmass(i)
      enddo


c*****Compute other convenient forms of the temperatures
      do i=1,ntau
          theta(i) = 5040./t(i)
          tkev(i) = 8.6171d-5*t(i)
          tlog(i) = dlog(t(i))
      enddo


c*****Convert from logarithmic Pgas scales, if needed
      if (pgas(ntau)/pgas(1) .lt. 10.) then
         do i=1,ntau                                                    
            pgas(i) = 10.0**pgas(i)
         enddo
      endif


c*****Convert from logarithmic Ne scales, if needed
      if(ne(ntau)/ne(1) .lt. 20.) then
         do i=1,ntau                                                    
            ne(i) = 10.0**ne(i)
         enddo
      endif


c*****Convert from Pe to Ne, if needed
      if(ne(ntau) .lt. 1.0e7) then
         do i=1,ntau                                                    
            ne(i) = ne(i)/1.38054d-16/t(i)
         enddo
      endif


c*****compute the atomic partition functions
      do j=1,95
         elem(j) = dble(j)
         call partfn (elem(j),j)
      enddo


c*****Read the microturbulence (either a single value to apply to 
c     all layers, or a value for each of the ntau layers). 
c     Conversion to cm/sec from km/sec is done if needed
      read (nfmodel,2003) (vturb(i),i=1,6)
      if (vturb(2) .ne. 0.) then
         read (nfmodel,2003) (vturb(i),i=7,ntau) 
      else
         do i=2,ntau                                                    
            vturb(i) = vturb(1)
         enddo
      endif
      if (vturb(1) .lt. 100.) then
         write (moditle(55:62),1008) vturb(1)
         do i=1,ntau
            vturb(i) = 1.0e5*vturb(i)
         enddo
      else
         write (moditle(55:62),1008) vturb(1)/1.0e5
      endif


c*****Read in the abundance data, storing the original abundances in xabu
c*****The abundances not read in explicity are taken from the default
c*****solar ones contained in array xsolar.
      read (nfmodel,2002) list
      list2 = list(11:)
      read (list2,*) natoms,abscale
      write (moditle(63:73),1009) abscale
c      natoms = natoms+1
c      element(1) = 6.0
c      logepsilon(1) = cfei + abscale + xsolar(6)
      if(natoms .ne. 0) 
     .         read (nfmodel,*) (element(i),logepsilon(i),i=1,natoms) 
      xhyd = 10.0**xsolar(1)
      xabund(1) = 1.0
      xabund(2) = 10.0**xsolar(2)/xhyd
      do i=3,95                                                      
         xabund(i) = 10.0**(xsolar(i)+abscale)/xhyd
         xabu(i) = xabund(i)
      enddo
      if (natoms .ne. 0) then
         do i=1,natoms                                                  
            xabund(idint(element(i))) = 10.0**logepsilon(i)/xhyd
            xabu(idint(element(i))) = 10.0**logepsilon(i)/xhyd
         enddo
      endif

c*****Compute the mean molecular weight, ignoring molecule formation
c     in this approximation (maybe make more general some day?)
      wtnum = 0.
      wtden = 0.
      do i=1,95
         wtnum = wtnum + xabund(i)*xam(i)
         wtden = wtden + xabund(i)
      enddo
      wtmol = wtnum/(xam(1)*wtden)
      nomolweight = 0
      if (nomolweight .ne. 1) then
         do i=1,ntau
             molweight(i) = wtmol
         enddo
      endif

c*****Compute the density 
      do i=1,ntau                                                    
         rho(i) = pgas(i)*molweight(i)*1.6606d-24/(1.38054d-16*t(i))
      enddo

c*****Calculate the fictitious number density of hydrogen
c     Note:  ph = (-b1 + dsqrt(b1*b1 - 4.0*a1*c1))/(2.0*a1)
      iatom = 1
      call partfn (dble(iatom),iatom)
      do i=1,ntau    
         th = 5040.0/t(i)         
         ah2 = 10.0**(-(12.7422+(-5.1137+(0.1145-0.0091*th)*th)*th))
         a1 = (1.0+2.0*xabund(2))*ah2
         b1 = 1.0 + xabund(2)
         c1 = -pgas(i)         
         ph = (-b1/2.0/a1)+dsqrt((b1**2/(4.0*a1*a1))-(c1/a1))
         nhtot(i) = (ph+2.0*ph*ph*ah2)/(1.38054d-16*t(i))
      enddo


c*****Molecular equilibrium called here.
c     First, a default list of ions and molecules is considered. Then the 
c     user's list is read in. A check is performed to see if any of these 
c     species need to be added. If so, then they are appended to the 
c     default list. The molecular equilibrium routine is then called.
c     Certain species are important for continuous opacities and damping
c     calculations - these are read from the equilibrium solution and 
c     saved.
c
c*****Here is the default list of ions and molecules.  These names are 
c     kept in a data statement in "Bmolec.com"
c
c     P(H)  = p(H) + p(H+) + 2p(H_2) + p(CH) + p(NH) + p(OH) + p(MgH) + p(AlH)
c                  + p(SiH) + p(PH) + p(SH) + p(ClH) + p(CaH) + p(CrH) 
c                  + p(FeH) + 2p(CH_2) + 2p(NH_2) + 2p(H_2O) + 2p(PH_2) 
c                  + 2p(SH_2) + p(HCO) + p(MgOH) + p(AlOH) + p(CaOH)
c     P(He) = p(He) + p(He+)
c     P(C)  = p(C) + p(C+) + p(CO) + p(CH) + 2p(CH_2) + p(HCO) + p(CN)
c                  + p(CS) + p(CO_2)
c     P(N)  = p(N) + p(N+) + 2p(N_2) + p(NH) + p(NH_2) + p(CN) + p(NO) 
c                  + p(SiO) + p(PN) + p(SN) 
c     P(O)  = p(O) + p(O+) + p(CO) + p(OH) + p(H_2O) + p(HCO) + p(MgOH) 
c                  + p(AlOH) + p(CaOH) + 2p(CO_2) + p(NO) + 2p(O_2)
c                  + p(MgO) + p(SiO) + p(PO) + p(SO) + p(TiO) + p(VO) + p(FeO)
c     P(Mg) = p(Mg) + p(Mg+) + p(MgH) + p(MGOH) + p(MgO)
c     P(Al) = p(Al) + p(Al+) + p(AlH) + p(AlOH) 
c     P(Si) = p(Si) + p(Si+) + p(SiH) + p(SiO) + p(SiS)
c     P(P)  = p(P) + p(P+) + p(PH) + p(PH_2) + p(PN) + p(PO)
c     P(S)  = p(S) + p(S+) + p(SH) + p(SH_2) + p(SC) + p(SN) + P(SO) + p(SiS)
c     P(Cl) = p(Cl) + p(Cl+) + p(ClH) 
c     P(Ca) = p(Ca) + P(Ca+) + p(CaH) + p(CaOH) 
c     P(Ti) = p(Ti) + p(Ti+) + p(TiO)
c     P(V)  = p(V) + p(V+) + p(VO)
c     P(Cr) = p(Cr) + p(Cr+) + p(CrH) 
c     p(Fe) = p(Fe) + p(Fe+) + p(FeH) + p(FeO)
c
c
c*****Read in the names of additional molecules to be used in 
c     molecular equilibrium if needed.
c      nmol = 56 (if molset is not equal to one)
c      molset = 0 as default in moog17scat
      nmol = 21
 
      do i=1,110
         amol(i) = smallmollist(i)
      enddo

      read (nfmodel,2002) list
      list2 = list(11:)
      read (list2,*) mmol
      if (mmol .ne. 0) then
         read (nfmodel,*) (bmol(i),i=1,mmol)
         append = 1
         do k=1,mmol
            do l=1,nmol
               if (nint(bmol(k)) .eq. nint(amol(l))) 
     .         append = 0  
            enddo
            if (append .eq. 1) then 
               nmol = nmol + 1
               amol(nmol) = bmol(k)
            endif
            append = 1
         enddo 
      endif 

c*****do the general molecular equilibrium
      call eqlib


c     In the number density array "numdens", the elements denoted by
c     the first subscripts are named in at the ends of the assignment
c     lines; at present these are the only ones needed for continuous 
c     opacities
c     
      do i=1,ntau
         numdens(1,1,i) = xamol(1,i)                                    H I
         numdens(1,2,i) = xmol(1,i)                                     H II
         numdens(2,1,i) = xamol(2,i)                                    He I
         numdens(2,2,i) = xmol(2,i)                                     Hi II
         numdens(3,1,i) = xamol(3,i)                                    C I
         numdens(3,2,i) = xmol(3,i)                                     C II
         numdens(4,1,i) = xamol(6,i)                                    Mg I
         numdens(4,2,i) = xmol(6,i)                                     Mg II
         numdens(5,1,i) = xamol(7,i)                                    Al I
         numdens(5,2,i) = xmol(7,i)                                     Al II
         numdens(6,1,i) = xamol(8,i)                                    Si I
         numdens(6,2,i) = xmol(8,i)                                     Si II
         numdens(7,1,i) = xamol(16,i)                                   Fe I
         numdens(7,2,i) = xmol(16,i)                                    Fe II
         numdens(8,1,i) = xmol(17,i)                                    H_2
      enddo



c     SPECIAL NEEDS: for KURUCZ models, to create the optical depth array,
c     and to convert kaprefs to our units
c      if (modtype .eq. 'KURUCZ    ') then
      first = rhox(1)*kaprefmass(1)
      tottau = rinteg(rhox,kaprefmass,tauref,ntau,first) 
      tauref(1) = first
c      tauref(1) = -6.875
      do i=2,ntau
         tauref(i) = tauref(i-1) + 0.125
      enddo
      do i=1,ntau
         tauref(i) = 10.**(tauref(i))
      enddo
      do i=1,ntau
         kapref(i) = kaprefmass(i)*rho(i)
      enddo


c*****Convert from logarithmic optical depth scales, or vice versa.
c     xref will contain the log of the tauref
      if(tauref(1) .lt. 0.) then
         do i=1,ntau                                                    
            xref(i) = tauref(i)
            tauref(i) = 10.0**xref(i)
         enddo
      else
         do i=1,ntau                                                    
            xref(i) = dlog10(tauref(i))
         enddo
      endif


c*****Write information to output files
c      if (modprintopt .lt. 1) return
c      write (nf1out,1002) moditle
c      do i=1,ntau
c         dummy1(i) = dlog10(pgas(i))
c         dummy2(i) = dlog10(ne(i)*1.38054d-16*t(i))
c      enddo
c      write (nf1out,1003) wavref,(i,xref(i),tauref(i),t(i),dummy1(i),
c     .                    pgas(i),dummy2(i),ne(i),vturb(i),i=1,ntau)
c      write (nf1out,1004)
c      do i=1,95
c         dummy1(i) = dlog10(xabund(i)) + 12.0
c      enddo
c      write (nf1out,1005) (names(i),i,dummy1(i),i=1,95)
c      write (nf1out,1006) modprintopt, molopt, linprintopt, fluxintopt
c      write (nf1out,1007) (kapref(i),i=1,ntau)
      return


c*****format statements
2001  format (a10)
2002  format (a80)
2003  format (6d13.0)
1001  format('permitted model types are:'/'KURUCZ, BEGN, ',
     .       'KURTYPE, KUR-PADOVA, NEWMARCS, WEBMARCS, NEXTGEN, ',
     .       'WEB2MARC, or GENERIC'/ 'MOOG quits!')
1002  format (/'MODEL ATMOSPHERE HEADER:'/a80/)
1003  format ('INPUT ATMOSPHERE QUANTITIES', 10x,
     .        '(reference wavelength =',f10.2,')'/3x, 'i', 2x, 'xref',
     .        3x, 'tauref', 7x, 'T', 6x, 'logPg', 4x, 'Pgas',
     .        6x, 'logPe', 5x, 'Ne', 9x, 'Vturb'/
     .        (i4, 0pf6.2, 1pd11.4, 0pf9.1, f8.3, 1pd11.4, 0pf8.3,
     .        1pd11.4, d11.2))
1004  format (/'INPUT ABUNDANCES: (log10 number densities, log H=12)'/
     .       '      Default solar abundances: Anders and Grevesse 1989')
1005  format (5(3x,a2, '(',i2,')=', f5.2))
1006  format (/'OPTIONS: atmosphere = ', i1, 5x, 'molecules  = ', i1/
     .        '         lines      = ', i1, 5x, 'flux/int   = ', i1)
1007  format (/'KAPREF ARRAY:'/(6(1pd12.4)))
1008  format ('vt=', f5.2)
1009  format (' M/H=', f5.2)
1010  format (13('-'),'MOOG OUTPUT FILE', 10('-'),
     .        '(MOOG version from 01/28/09)', 13('-')//
     .        'THE MODEL TYPE: ', a10)
1011  format ('   The Rosseland opacities and optical depths have ',
     .        'been read in')
1012  format ('HOUSTON, WE HAVE MORE THAN 100 DEPTH POINTS! I QUIT!')


      end

