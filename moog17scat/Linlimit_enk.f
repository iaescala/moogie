
      subroutine linlimit (nflines, nfslines, nfbarklem)
c******************************************************************************
c     This routine marks the range of lines to be considered in a 
c     particular line calculations, depending on the type of calculation
c     (e.g. synthetic spectrum, single line curve-of-growth, etc.)
c******************************************************************************

      implicit real*8 (a-h,o-z)
      include 'Linex.com'
      integer nflines, nfslines, nfbarklem


c*****for spectrum synthesis, find the range of lines to include at each
c     wavelength step; called from "synspec"
      if (lim1line .eq. 0) lim1line = 1
111   do j=lim1line,nlines
         if (wave1(j) .ge. wave-delta) then
            lim1line = j
            go to 10
         endif
      enddo
      call inlines (5,nflines,nfslines)
      write(*,*)"The number of strong lines is",nstrong
      write(*,*)"First wavelength",wave1(1)
      write(*,*)"Last wavelength",wave1(2500)
      stop
      call nearly (nfbarklem)
      go to 111
10    do j=lim1line,nlines
         if (wave1(j) .gt. wave+delta) then
            lim2line = max0(1,j-1)
            return
         endif
      enddo 
      if (nlines+nstrong .eq. 5000) then
c      if (nlines+nstrong .eq. 2500) then
         lim2line = -1
      else
         lim2line = nlines
      endif
      return


c*****format statements
1001  format ('TROUBLE! THE FIRST LINE IN THE GROUP')
1002  format ('DOES NOT DEFINE A NEW GROUP OF LINES!  I QUIT!')
      end

