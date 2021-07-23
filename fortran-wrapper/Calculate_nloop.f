      subroutine calculate_nloop(iteff1,iteff2,size,nloop,nsynths)
      
      implicit real*8 (a-h,o-z)
      
c   These variables are for iterating over the various parameters for the
c   the atmospheric models
      integer iteff1,iteff2
      integer iteff,ilogg,ifeh,ialpha
      real*8 teffarr(34),loggarr(11),feharr(51),alphaarr(21)
      real*8 teffi,loggi,fehi,alphai
      integer nlogg,nfeh,nalpha
      
c   Based on the rank and size, determine the number of synthesis per core.
c   These variables loop through the various synthesis accordingly
      integer nsynths,nloop,size
      
Cf2py intent(in) iteff1,iteff2,size
Cf2py intent(out) nloop,nsynths
      
c   Set the parameter ranges for the run
      
      ilogg1=3
      ilogg2=3

      ifeh1=1
      ifeh2=30

      ialpha1=9
      ialpha2=9
      
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
     
c******* find total number of interations (nsynths)

      nsynths=0

      nteff=iteff2-iteff1+1
      nlogg=ilogg2-ilogg1+1
      nfeh=ifeh2-ifeh1+1
      nalpha=ialpha2-ialpha1+1
    
      do iteff=iteff1,iteff2
         do ilogg=ilogg1,ilogg2
            do ifeh=ifeh1,ifeh2
               do ialpha=ialpha1,ialpha2
                  nsynths=nsynths+1
               enddo
            enddo
         enddo
      enddo
      
      nloop=floor(real(nsynths)/real(size))+1
      
      return
      end
