
      subroutine inlines (num,nflines,nfslines)
c******************************************************************************
c     This subroutine reads in the line data
c******************************************************************************

      implicit real*8 (a-h,o-z)
      include 'Atmos.com'
      include 'Linex.com'
      include 'Mol.com'
      include 'Dummy.com'
      include 'Quants.com'
      include 'Factor.com'
c These s variables are for the strong line list
      real*8        swave1(40), satom1(40), se(40),sgf(40),
     .              sdampnum(40),sd0(40),swidth(40), scharge(40)
      integer n1, n2, nflines, nfslines
      character*80 linitle
      data n1,n2 /1,0/
      
      if (num .eq. 2) go to 4
      if (num .eq. 6) go to 340
      n1 = 1
      n2 = 0


c*****decide if certain element abundances need to be modified.
c      if (numpecatom .gt. 0) then
c         do iatom=3,95
c            xabund(iatom) = 10.**pecabund(iatom,isynth)*
c     .                      10.**abfactor(isynth)*xabu(iatom)
c         enddo
c      endif
c      if (num .ne. 5) then
c         write (nf1out,1004)
c         xmetals = abscale + abfactor(isynth)
c         if (ninetynineflag .eq. 1) then
c            write (nf1out,1005) xmetals
c            if (nf2out .gt. 0) write (nf2out,1005) xmetals
c         else
c            if (nf2out .gt. 0) write (nf2out,1006) abscale
c         endif
c         do j=1,93
c            if (pec(j) .gt. 0 ) then
c               dummy1(j) = dlog10(xabund(j)) + 12.0
c               write (nf1out,1007) names(j),dummy1(j)
c               if (nf2out .gt. 0) write (nf2out,1007) names(j),dummy1(j)
c            endif
c         enddo
c      endif


c*****output information about the isotopic ratios
c      if (numiso .gt. 0) then
c         write (nf1out,1014) 'Isotopic Ratios given for this synthesis'
c         do i=1,numiso
c            iiso = isotope(i)
c            write (nf1out,1015) iiso, isotope(i), isoabund(i,isorun)
c            if (nf2out .gt. 0) write (nf2out,1015) 
c     .                         iiso, isotope(i), isoabund(i,isorun)
c         enddo
c      endif



c*****Inititalize strong line printing
c     if 'printstrong' gt 0 then the strong lines have 
c     been printed
c      printstrong = -1

      if (num .ne. 4) then  
         rewind nflines
         wave = start
         read (nflines,1001) linitle
      endif


c*****read in the strong lines if needed
302   nstrong = 0
      rewind nfslines
      do j=1,41
         read (nfslines,1002,end=340) swave1(j),satom1(j),se(j),
     .                             sgf(j),sdampnum(j),sd0(j),swidth(j)
         nstrong = nstrong + 1
         iatom = satom1(j)
         scharge(j) = 1.0 + dble(int(10.0*(satom1(j) - iatom)
     .       +0.0001))
c         if (scharge(j) .gt. 3.) then
c            write (*,1003) swave1(i), satom1(i)
c            stop
c         endif
      enddo
c      if (nstrong .gt. 40) then
c         write(*,*) 'STRONG LINE LIST HAS MORE THAN 40 LINES. THIS'
c         write(*,*) 'IS NOT ALLOWED. I QUIT!'
c         stop
c      endif
340   nlines = 5000 - nstrong
c340   nlines = 2500 - nstrong
      j = 1
333   read (nflines,1002,iostat=jstat,end=311) wave1(j),atom1(j),e(j,1),
     .                             gf(j),dampnum(j),d0(j),width(j)
      iatom = atom1(j)
      charge(j) = 1.0 + dble(int(10.0*(atom1(j) - iatom)+0.0001))
c      if (charge(j) .gt. 3.) then
c         write (*,1003) wave1(j), atom1(j)
c         stop
c      endif 
      if (width(j) .lt. 0) go to 333
      if (iunits .eq. 1) wave1(j) = 1.d+4*wave1(j)
      j = j + 1
      if (j .le. nlines) go to 333
311   nlines = j - 1 


c*****append the strong lines here if necessary
      do k=1,nstrong
         wave1(nlines+k) = swave1(k)
         atom1(nlines+k) = satom1(k)
         e(nlines+k,1) = se(k)
         gf(nlines+k) = sgf(k)
         dampnum(nlines+k) = sdampnum(k)
         d0(nlines+k) = sd0(k)
         width(nlines+k) = swidth(k)
         charge(nlines+k) = scharge(k)
      enddo


c*****here groups of lines for blended features are defined
310   do j=1,nlines+nstrong
         if (wave1(j) .lt. 0.) then
            group(j) = 1
            wave1(j) = dabs(wave1(j))
            width(j) = width(j-1)
         else
            group(j) = 0
         endif
      enddo     


c*****here excitation potentials are changed from cm^-1 to eV, if needed
      do j=1,nlines+nstrong
         if (e(j,1) .gt. 50.) then
            do jj=1,nlines+nstrong
               e(jj,1) = 1.2389e-4*e(jj,1)
            enddo
         endif
      enddo
 

c*****here log(gf) values are turned into gf values, if needed
378   do j=1,nlines+nstrong
         if (gfstyle.eq.1 .or. gf(j) .lt. 0) then
            do jj=1,nlines+nstrong
               gf(jj) = 10.**gf(jj)
            enddo
         endif
      enddo         

c*****turn log(RW) values and EW values in mA into EW values in A.  Stuff
c     duplicate EW values of the first line of a blend into all blend members.
379   do j=1,nlines+nstrong
         if (width(j) .lt. 0.) then
            width(j) = 10.**width(j)*wave1(j)
         else
            width(j) = width(j)/1000.
         endif
       enddo


c*****here some parameters for the lines are assigned or calculated; 
c     there is a block of statements for moleculer lines, 
c     and a different one for atomic lines
      do j=1,nlines+nstrong
         iatom = atom1(j)
         atom10 = 10.*atom1(j)
         e(j,2) =  e(j,1) + 1.239d+4/wave1(j)


c*****here are the calculations specific to molecular lines
         if (iatom .ge. 100) then
            call sunder (atom1(j),ia,ib)
            if (ia .gt. ib) then
c               write (*,1010) ia,ib
               stop
            endif
            if (atom10-int(atom10) .le. 0.0) then
               amass(j) = xam(ia) + xam(ib)    
               mas1 = xam(ia) + 0.0000001
               mas2 = xam(ib) + 0.0000001
            else 
               jat100 = int(100.*(atom10+0.00001))
               mas1 = jat100 - 100*int(atom10)
               jat10000 = int(10000.*(atom10+0.00001))
               mas2 = jat10000 - 100*jat100
               if (mas1.gt.mas2 .or. mas1.le.0.0 .or. 
     .             mas2.le.0.0) then
c                  write (*,1011) mas1, mas2
                  stop
               endif
               amass(j) = mas1 + mas2
            endif
c*****use an internal dissociation energy for molecules if the user
c     does not read one in
            if (d0(j) .eq. 0.) then
               do k=1,110
                  if (int(datmol(1,k)+0.01) .eq.
     .                int(atom1(j)+0.01)) then
                     d0(j) = datmol(2,k)
                     go to 390
                  endif
                enddo
c                write (*,1013) atom1(j)
                stop
            endif
390         rdmass(j) = mas1*mas2/amass(j)
            chi(j,1) = 0.
            chi(j,2) = 0.
            chi(j,3) = 0.


c*****here are the calculations specific to atomic lines
         else
            if (atom10-int(atom10) .le. 0.0) then
               amass(j) = xam(iatom)
            else 
               atom10 = atom10 + 0.00001
               amass(j) = int(1000*(atom10-int(atom10)))
            endif
            rdmass(j) = 0.
            chi(j,1) = xchi1(iatom)
            chi(j,2) = xchi2(iatom)
            chi(j,3) = xchi3(iatom)
         endif
      enddo


c*****quit the routine normally
c      if (nlines+nstrong .lt. 2500) then
      if (nlines+nstrong .lt. 5000) then
         if (sstop .gt. wave1(nlines)+10.) sstop = wave1(nlines)+10.
      endif
      lim1line = 1
      return  


c****prepare to get another chunk of line data 
4     n2 = n1 + lim1line - 1
      n1 = n2
      rewind nflines
      do j=1,n2
         read (nflines,1001)
      enddo
      start = wave
      go to 302


c*****format statements
1001  format (a80)
1002  format (7e10.3)
1003  format ('INPUT STRONG LINE: LAMBDA = ', f10.3, ' AND ID = ',
     .        f6.1, ' CANNOT BE DONE!'/
     .        'NO TRIPLE OR GREATER IONS; I QUIT!')
1004  format (/'For these computations, some abundances have ',
     .       ' been altered:')
1005  format ('Changing overall metallicity: ', f6.2, ' dex')
1006  format ('ALL abundances NOT listed below differ ',
     .        'from solar by ', f6.2, ' dex')
1007  format ('element ', a2, ':  abundance = ', f7.2)
1010  format ('ATOMIC NUMBERS IN MOLECULAR NAME (',
     .        2i2, ') ARE IN WRONG ORDER'/'I QUIT!!!')
1011  format ('ISOTOPIC MASS NUMBERS IN MOLECULAR NAME (',
     .        2i3, ') ARE IN WRONG ORDER OR ARE WEIRD;'/'I QUIT!!!')
1013  format (f6.1, ' IS AN UNKOWN MOLECULE; I QUIT!')
1014  format ('Isotopic Ratios given for this synthesis')
1015  format ('Isotopic Ratio: [', i4, '/', f10.5, '] = ', f10.3)


      end



