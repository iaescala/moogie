
      subroutine synspec(nf2out,nfbout,nflines,nfslines,nfbarklem,
     $   f2outshort)
c******************************************************************************
c     This routine does synthetic spectra                                
c******************************************************************************

      implicit real*8 (a-h,o-z)
      include 'Atmos.com'
      include 'Linex.com'
      include 'Factor.com'
      include 'Dummy.com'
      include 'Source.com'
c      real*8 dd(5000)
      real*8 dbin
      real*4 compress,dout,dbinout
      character*99 f2outshort
      integer nn,binsize
      integer nf2out,nfbout,nflines,nfslines,nfbarklem
      logical verbose

      dbin = 0
      nn = 0
      n = 1           
      binsize = 7
      nsteps = 1
      niter_line = 0
      niter_cont = 0

c*****calculate continuum quantities at the spectrum wavelength
      wave = start
      wavl = 0.
30    if (dabs(wave-wavl)/wave .ge. 0.001) then
         wavl = wave   
         call opacit (2,wave) 
         call cdcalc_JS (1,dabs(wave-wavl),niter_cont,niter_line)
         flux = 1-adepth
      endif

c*****find the appropriate set of lines for this wavelength, reading 
c     in a new set if needed
20    call linlimit (nflines,nfslines,nfbarklem)
      if (lim2line .lt. 0) then
         call inlines (2, nflines, nfslines)
         call nearly (nfbarklem)
         go to 20
      endif
      lim1 = lim1line
      lim2 = lim2line

c*****compute a spectrum depth at this point
      call taukap   
      call cdcalc_JS (2,dabs(wave-wavl),niter_cont,niter_line)
      d(n) = adepth     
      dout = compress(d(n))
      write(nf2out) dout

      dbin = dbin + d(n)
      nn = nn + 1

      if(nfbout .gt. 0 .and. nn .ge. binsize) then
         dbinout = compress(dbin / real(binsize))
         write (nfbout) dbinout
         dbin = 0
         nn = 0
      endif


c*****step in wavelength and try again 
      wave = oldstart + step*nsteps
      if (wave .le. sstop) then
         n = n + 1        
         nsteps = nsteps + 1
         if (n .gt. 5000) then
c         if (n .gt. 2500) then
            n = 1                                      
         endif
         go to 30                   


c*****finish the synthesis
      else
      write(*,*)"Convergence",niter_cont,niter_line,f2outshort
         if(nfbout.gt.0 .and. nn .ne. 0) then
            dbinout = compress(dbin / real(nn))
            write (nfbout) dbinout
            dbin = 0
            nn = 0
            endif
         return 
      endif


c*****format statements
c1001  format ('  kaplam from 1 to ntau at wavelength',f10.2/
c     .        (6(1pd12.4)))
c1002  format ('MODEL: ',a73)
c1003  format ('AT WAVELENGTH/FREQUENCY =',f11.7,
c     .        '  CONTINUUM FLUX/INTENSITY =',1p,d12.5)
c1004  format ('AT WAVELENGTH/FREQUENCY =',f11.3,
c     .        '  CONTINUUM FLUX/INTENSITY =',1p,d12.5)
c1101  format (/'SPECTRUM DEPTHS')
c1102  format (4f11.3)
c1103  format (4f10.7)
c1104  format ('SIMPLE  =    t'/'NAXIS   =     1'/'NAXIS1  = ',i10,/
c     .        'W0      =',f10.4/'CRVAL1  =',f10.4/'WPC     =',f10.4/
c     .        'CDELT1  =',f10.4)
c1105  format (16HORIGIN  = 'moog'/21HDATA-TYP= 'synthetic'/
c     .        18HCTYPE1  = 'lambda'/21HCUNIT1  = 'angstroms')
c1106  format (11HTITLE   = ',A65,1H')
c1107  format ('ATOM    = ',1H',7x,a2,1H',/,'ABUND   = ',f10.2)
c1108  format ('VTURB   = ',d10.4,'     /  cm/sec  ')
c1109  format ('END')
c1110  format (10f7.4)
c1111  format (f10.3,': depths=',10f6.3)
c1112  format (f10.7,': depths=',10f6.3)
c1113  format ('FINAL WAVELENGTH/FREQUENCY =',f10.7/)
c1114  format ('FINAL WAVELENGTH/FREQUENCY =',f10.3/)


      end                                




