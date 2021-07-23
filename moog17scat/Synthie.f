
      subroutine synth (teffi,loggi,fehi,alphai,rank,nfslines,
     $        nfbarklem,moogpath,atmpath,synthpath,binpath,
     $        synth_run,replace,nflines)
 
c******************************************************************************
c     This program synthesizes a section of spectrum and compares it
c     to an observation file.
c******************************************************************************

      include 'Atmos.com'
      include 'Factor.com'
      include 'Mol.com'
      include 'Linex.com'
      
c   System parameters
      character*250 systemcall
      
c   A string version of the rank, used to define filenames
      character*3 srank
c   The following parameters are set to rank = 0 and size = 1 for non-MPI version
      integer values(8),rank
      
c   Define paths to be used to point to directories      
      character(*) moogpath,atmpath,synthpath,binpath,synth_run

c   These variables are for iterating over the various parameters for the
c   the atmospheric models   
      real*8 teffi,loggi,fehi,alphai, cfei
c   These are for finding and saving the relevant files   
      character*2 calpha, cfeh, clogg
      character*4 cteff
      character*1 loggsign, fehsign, alphasign

c   Parameters such as filenames for strong line lists and 
c   Barklem HI collisional broadening 
c   2 => raw synthesis output, b => binned synthesis output     
      character*99 flines,fmodel,f2out,fbout,f2outfull,fboutfull
      character*99 f2outshort
      integer nf2out,nfbout,nfmodel,nflines,nfslines,nfbarklem
      integer num,num2,numb,nums,jstat,mmm

c   Date/time characters for printing while synthesis is running in real time     
      character*8 date
      character*110 time
      character*5 zone

c   Boolean variables          
      logical replace,gz2,gzb,bin2,binb
     
c******* clear path names
1001  format (99(' '))
1002  format (250(' '))
      write (f2out,1001)
      write (fbout,1001)
      write (fmodel,1001)
      write (f2outshort,1001)
      write (f2outfull,1001)
      write (fboutfull,1001)
      write (systemcall,1002)

c******** setup syntheses parameters
c   Defining parameters in-file here as opposed to in Params.f

c   Flags for options
c     linefileopt = 0
      dampingopt = 1
      fluxintopt = 0
      scatopt = 1
      molopt = 1
      modprintopt = 0
      linprintopt = 0
      
      modelnum = 0
      
c   Fudge <= 0 does not scale "it". Fudge = -1 ensures no floating point problems
      fudge = -1.0
      
c   More parameters, I'm not sure what they do
      itru = 0
      iunits = 0
      nlines = 0
      byteswap = 0
      
c   Spectrum run parameters
      step = 0.02
      delta = 2.00
      start = 4100.
      sstop = 6300.
      oldstart = start
      oldstop = sstop
      
c   Line limit parameters
      lim1line = 0
      lim2line = 0
      lim1 = 0
      lim2 = 0
      
c   For elements/molecules with special abundance data
      neq = 0
      numpecatom = 0
      numatomsyn = 0
      numiso = 0
      
c   Other parameters
      cfei = 0.0
      jstat = 0
      
c******* setup file numbers
      nfmodel = rank*11+203
      nf2out = rank*11+204
      nfbout = rank*11+205
      
c******* build atmosphere, flines, and output filenames
      
      write (cteff, '(I04)'), int(teffi)
      if (cteff(1:1).eq.' ') cteff(1:1)='0'
      if (cteff(2:2).eq.' ') cteff(2:2)='0'
      if (cteff(3:3).eq.' ') cteff(3:3)='0'
      if (cteff(4:4).eq.' ') cteff(4:4)='0'

      write (clogg, '(I02)'), int(abs(loggi*10.)+0.0001)
      if (clogg(1:1).eq.' ') clogg(1:1)='0'
      if (clogg(2:2).eq.' ') clogg(2:2)='0'
      if (loggi .lt. -0.01) then
         loggsign='-'
      else
         loggsign='_'
      endif
            
      write (cfeh, '(I02)'), int(abs(fehi*10.)+0.0001)
      if (cfeh(1:1).eq.' ') cfeh(1:1)='0'
      if (cfeh(2:2).eq.' ') cfeh(2:2)='0'
      if (fehi .lt. -0.01) then
         fehsign='-'
      else
         fehsign='_'
      endif
      
      write (calpha, '(I02)'), int(abs(alphai*10.)+0.0001)
      if (calpha(1:1).eq.' ') calpha(1:1)='0'
      if (calpha(2:2).eq.' ') calpha(2:2)='0'
      if (alphai .lt. -0.01) then
          alphasign='-'
      else
          alphasign='_'
      endif
      
      write(srank, '(I03)') rank
      if (srank(1:1).eq.' ') srank(1:1)='0'
      if (srank(2:2).eq.' ') srank(2:2)='0'
      if (srank(3:3).eq.' ') srank(3:3)='0'
      
      num=99
      call getcount (num,atmpath)
      if (atmpath(num:num) .ne. '/') then
         num = num + 1
         atmpath(num:num) = '/'
      endif
      fmodel(1:num) = atmpath(1:num)
      fmodel(num+1:num+32) = 't'//cteff//'/g'//loggsign//
     $   clogg//'/t'//cteff//'g'//loggsign//clogg//'f'//
     $   fehsign//cfeh//'a'//alphasign//calpha//'.atm'
     
      nums=99
      call getcount (nums,synthpath)
      if (synthpath(nums:nums) .ne. '/') then
         nums = nums + 1
         synthpath(nums:nums) = '/'
      endif
      f2out(1:nums) = synthpath(1:nums)
      f2out(nums+1:nums+36) = 't'//cteff//'/g'//loggsign//
     $   clogg//'/t'//cteff//'g'//loggsign//clogg//
     $   'f'//fehsign//cfeh//'a'//alphasign//calpha//'.bin'
       
      numb=99
      call getcount (numb,binpath)
      if (binpath(numb:numb) .ne. '/') then
         numb = numb + 1
         binpath(numb:numb) = '/'
      endif
      fbout(1:numb) = binpath(1:numb)
      fbout(numb+1:numb+36) = 't'//cteff//'/g'//loggsign//
     $   clogg//'/t'//cteff//'g'//loggsign//clogg//
     $   'f'//fehsign//cfeh//'a'//alphasign//calpha//'.bin'

      
c*****open files

      open (unit=nfmodel,file=fmodel,access='sequential',
     .    form='formatted',status='old',
     .    iostat=jstat)
    
c*****open files

c     First check if the relevant files exist
      f2outfull = f2out(1:nums+32)//".gz"
      fboutfull = fbout(1:numb+32)//".gz"
      
      inquire (file=f2outfull, exist=gz2)
      inquire (file=fboutfull, exist=gzb) 
      inquire (file=f2out, exist=bin2)
      inquire (file=fbout, exist=binb)

c     If the files exist, remove then, then proceed
      if (replace .eqv. .true.) then
         if (bin2 .eqv. .true.) then
            systemcall='rm -f '//f2out
            call system (systemcall)
         endif
         if (binb .eqv. .true.) then
            systemcall='rm -f '//fbout
            call system (systemcall)
         endif
         if (gz2 .eqv. .true.) then
            systemcall='rm -f '//f2outfull
            call system (systemcall)
         endif
         if (gzb .eqv. .true.) then
            systemcall='rm -f '//fboutfull
            call system (systemcall)
         endif
c   If it does not exist, then proceed with the synthesis.
      else
c        If both zipped files exist, then skip this synthesis
         if ((gz2 .eqv. .true.) .and. (gzb .eqv. .true.)) then
            write(*,*)f2out(nums+12:nums+28)," exists! skipping.."
            return
c        If both zipped files do not exist, check if the unzipped
c        files exist, and remove them before proceeding with the
c        synthesis 
         else
            if (bin2 .eqv. .true.) then
               systemcall='rm -f '//f2out
               call system (systemcall)
            endif
            if (binb .eqv. .true.) then
               systemcall='rm -f '//fbout
               call system (systemcall)
            endif
         endif
      endif

      open (unit=nf2out,file=f2out,access='stream',
     .      form='unformatted',status='new', iostat=jstat)

      open (unit=nfbout,file=fbout,access='stream',
     .      form='unformatted',status='new',
     .      iostat=jstat)


c*****read the model atmosphere file

c      write(*,*) fmodel,nfmodel

c   The subroutine inmodel (Inmodelie.f) contains options for reading in the 
c   atmospheric models. The only option here is "KURUCZ"
c         call inmodel (nfmodel, cfei)
      call inmodel (nfmodel)
     
c element: solar abundance (A-12) + feh/h(proxy for all metals) +alpha/fe ratio
c The elements below correspond to Mg, Si, Ca, and Ti respectively
      xabund(12)=10.0**(7.58+fehi-12.00+alphai)
      xabund(14)=10.0**(7.55+fehi-12.00+alphai)
      xabund(20)=10.0**(6.36+fehi-12.00+alphai)
      xabund(22)=10.0**(4.99+fehi-12.00+alphai)

c*******set up isotopes
c Different isotopes for CH molecule (C12 vs. C13)

      numiso = 2
      do i=1,20
         isotope(i) = 0.
         do j=1,5
            isoabund(i,j) = 0.
         enddo
      enddo

      isotope(1) = 106.00112
      isotope(2) = 106.00113
      if (loggi .le. 2.0) then
         isoabund(1,1) = 1.167
         isoabund(2,1) = 7.00
      elseif ((loggi .gt. 2.0) .and. (loggi .le. 2.7)) then
         isoabund(1,1) = (63.*loggi - 119.)/(63.*loggi - 120.)
         isoabund(2,1) = 63.00*loggi - 119.00
      else
         isoabund(1,1) = 1.02
         isoabund(2,1) = 51.00
      endif

c Information for printing out progress of the synthesis in real-time
2020  format(A4,"-",A2,"-",A2,1X,A2,":",A2,":",A2,1X,I3,1X,A21)

      call date_and_time(date,time,zone,values)
      write(*,2020) date(1:4),date(5:6),date(7:8),time(1:2),
     $   time(3:4),time(5:6),rank,f2out(nums+12:nums+30)

      write(*,*)nf2out,nfbout,nfmodel,nfslines,nfbarklem
      write(*,*)f2out,fbout,fmodel

      f2outshort = f2out(nums+12:nums+28)
10    if (numpecatom .eq. 0 .or. numatomsyn .eq. 0) then
         isynth = 1
         isorun = 1
         nlines = 0
         call inlines (1,nflines,nfslines)
         call eqlib
         call nearly(nfbarklem)
         call synspec (nf2out,nfbout,nflines,nfslines,nfbarklem,
     $      f2outshort) 
      else
         do n=1,numatomsyn
            isynth = n
            isorun = n
            start = oldstart
            sstop = oldstop
            call inlines (1, nflines, nfslines)
            call eqlib
            call nearly(nfbarklem)
            call synspec (nf2out,nfbout,nflines,nfslines,nfbarklem,
     $         f2outshort) 
         enddo
      endif

      close(unit=nf2out)
      close(unit=nfbout)
      close(unit=nfmodel)

      systemcall='gzip -f '//f2out
      call system (systemcall)
      systemcall='gzip -f '//fbout
      call system (systemcall)

      end                                                                
