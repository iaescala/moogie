
      subroutine calculate_params(mmm,nsynths,size,rank,iteff1,
     $   teffi,loggi,fehi,alphai)
      
      implicit real*8 (a-h,o-z)
      
c   These variables are for iterating over the various parameters for the
c   the atmospheric models
      integer iteff1,ilogg1,ifeh1,ialpha1
      real*8 teffarr(34),loggarr(11),feharr(51),alphaarr(21)
      integer iteff,ilogg,ifeh,ialpha
      real*8 teffi,loggi,fehi,alphai
      integer nlogg,nfeh,nalpha
      
c   Based on the rank and size, determine the number of synthesis per core.
c   These variables loop through the various synthesis accordingly
      integer mmm,nnn,nsynths,size,rank
      
Cf2py intent(in) mmm,nsynths,size,rank,iteff1,nlogg,nfeh,nalpha
Cf2py intent(out) teffi,loggi,fehi,alphai

c   Set the parameter ranges for the run
      
      ilogg1=3
      ifeh1=1
      ialpha1=9

      nlogg=1
      nfeh=30
      nalpha=1
  
c   Define the parameter ranges for effective temperature (K), surface gravity 
c   (log cm s^(-2)), metallicity [Fe/H] (dex), and alpha to iron ratio [alpha/Fe](dex)
    
      data teffarr/3500, 3600, 3700, 3800, 3900,
     $             4000, 4100, 4200, 4300, 4400,
     $             4500, 4600, 4700, 4800, 4900,
     $             5000, 5100, 5200, 5300, 5400,
     $             5500, 5600, 5800, 6000, 6200,
     $             6400, 6600, 6800, 7000, 7200,
     $             7400, 7600, 7800, 8000/
      
      data loggarr/0.0, 0.5, 1.0, 1.5, 2.0, 2.5,
     $             3.0, 3.5, 4.0, 4.5, 5.0/
     
      data feharr/-5.0, -4.9, -4.8, -4.7, -4.6,
     $            -4.5, -4.4, -4.3, -4.2, -4.1,
     $            -4.0, -3.9, -3.8, -3.7, -3.6,
     $            -3.5, -3.4, -3.3, -3.2, -3.1,
     $            -3.0, -2.9, -2.8, -2.7, -2.6,
     $            -2.5, -2.4, -2.3, -2.2, -2.1,
     $            -2.0, -1.9, -1.8, -1.7, -1.6,
     $            -1.5, -1.4, -1.3, -1.2, -1.1,
     $            -1.0, -0.9, -0.8, -0.7, -0.6,
     $            -0.5, -0.4, -0.3, -0.2, -0.1, 0.0/
      
      data alphaarr/-0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1, 0.0,
     $       0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2/
     
c     Now based on the given loop number, rank, and size, determine which
c     parameters to use for the synthesis on this processor
      
      nnn=((mmm-1)*size)+rank+1
      if (nnn.le.nsynths) then
         iteff=floor(real(nnn-1)/real(nlogg*nfeh*nalpha))
         ilogg=floor(real(nnn-1-iteff*nlogg*nfeh*nalpha)
     .        /real(nfeh*nalpha))
         ifeh=floor(real(nnn-1-iteff*nlogg*nfeh*nalpha-ilogg
     .        *nfeh*nalpha)/real(nalpha))
         ialpha=nnn-1-iteff*nlogg*nfeh*nalpha-ilogg
     .        *nfeh*nalpha-ifeh*nalpha
         iteff=iteff+iteff1
         ilogg=ilogg+ilogg1
         ifeh=ifeh+ifeh1
         ialpha=ialpha+ialpha1

c         write(*,*) iteff, ilogg, ifeh, ialpha
         teffi=teffarr(iteff)
         loggi=loggarr(ilogg)
         fehi=feharr(ifeh)
         alphai=alphaarr(ialpha)

         return
      endif
         
      end
