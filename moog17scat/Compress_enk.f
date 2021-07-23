
      real*4 function compress (x)

      implicit real*8 (a-h,o-z) 
      real*8 x, log2, mant
      integer ndig

      ndig = 10

      if (x.eq.0.0) then
         compress = real(x)
         return
      endif

c     exponent part
      log2 = int((log(abs(x))/0.69314718056)+0.5)
      
c     mantissa, truncated
      mant = dble(nint(x/(2.0**(log2-ndig))))/(2.0**ndig)

c     multiply 2^exponent back in 
      compress = real(mant*(2.0**log2))

      return                                             
      end                                               

