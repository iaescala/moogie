      subroutine cdcalc_JS (number,wavedelta,niter_cont,niter_line)
c******************************************************************
c     Calculates the line depth and accordingly, the quantity adepth
c     (analogous to the quantity, cd(i), in MOOG-NONscat).
c     The quantity 'adepth' is the depth of the spectral line at a specified 
c     wavelength. Essentially, the integral of this quantity over the wavelength of 
c     the spectral feature is the equivalent width. 

c******************************************************************
      implicit real*8 (a-h,o-z)
      real*8  Residual, Flux_cont_corr, m

      include 'Atmos.com'
      include 'Linex.com'
      include 'Source.com'
      
      if (number .eq. 1) then
         call sourcefunc_scat_cont (niter_cont)
         return
      else  
         call sourcefunc_scat_line (niter_line)
      m = 0.00097087
      Flux_cont_corr = Flux_cont * (1 + (m * wavedelta))
      Residual = Flux_line/Flux_cont_corr
      adepth   = 1.- Residual
      endif


      return
      end

 
