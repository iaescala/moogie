      program moog

      real*8 teffi,loggi,fehi,alphai
      integer rank
      character*99 synth_run
      logical replace
      call moogie(teffi,loggi,fehi,alphai,rank,synth_run,
     $   replace)
      end

      subroutine moogie (teffi,loggi,fehi,alphai,rank,synth_run,
     $   replace)

      implicit real*8 (a-h,o-z)
    
c   The following parameters are set to rank = 0 and size = 1 for non-MPI version
      integer rank
c   A string version of the rank, used to define filenames
      character*3 srank
      
c   Define paths to be used to point to directories
      character*99 moogpath,atmpath,synthpath,binpath,synth_run
      
c   These variables are for iterating over the various parameters for the
c   the atmospheric models
      real*8 teffi,loggi,fehi,alphai
      
c   Parameters such as filenames for strong line lists and 
c   Barklem HI collisional broadening
      character*99 fslines,fbarklem,flines,fmultlines
      integer nfslines,nfbarklem
      integer num, num2
    
c   Boolean variables
      logical replace
      
Cf2py intent(in) teffi,loggi,fehi,alphai,rank,synth_run,replace

c******* clear path names
1001  format (99(' '))
      write (flines, 1001)
      write (fslines,1001)
      write (fbarklem,1001)
      write (moogpath,1001)
      write (synthpath,1001)
      write (binpath,1001)
      write (atmpath,1001)
      
c******* define paths
      moogpath = 
     .  '/home/iescala/moogiepy2/'
      atmpath = 
     .  '/home/iescala/atmospheres/'
      synthpath = 
     .  '/panfs/ds08/hopkins/iescala/gridiepy/synths'
      binpath = 
     .  '/panfs/ds08/hopkins/iescala/gridiepy/bin'
      
c******* open strong line list and barklem data on HI collisional broadening

      nfbarklem = rank*11+201
      nfslines = rank*11+202

      num=99
c   The subroutine getcount (Getcount.f) counts the number of characters in the
c   specified string, most useful for discovering the length of a filename
      call getcount (num,moogpath)
      if (moogpath(num:num) .ne. '/') then
         num = num + 1
         moogpath(num:num) = '/'
      endif
      
      write(srank, '(I03)') rank
      if (srank(1:1).eq.' ') srank(1:1)='0'
      if (srank(2:2).eq.' ') srank(2:2)='0'
      if (srank(3:3).eq.' ') srank(3:3)='0'
      
      num2=99
      call getcount (num2,synth_run)
      if (synth_run(num2:num2) .ne. '/') then
         num2 = num2 + 1
         synth_run(num2:num2) = '/'
      endif

      fslines(1:num+num2)=moogpath(1:num)//synth_run
      fslines(num+1+num2:num+15+num2)=srank//'/full.strong'

      fbarklem(1:num+num2) = moogpath(1:num)//synth_run
      fbarklem(num+1+num2:num+15+num2) = srank//'/Barklem.dat'
     
      write(*,*) fslines, fbarklem

      open (unit=nfslines,file=fslines,access='sequential',
     .   form='formatted',blank='null',status='old',
     .   iostat=jstat)
      open (unit=nfbarklem,file=fbarklem,access='sequential',
     .   form='formatted',blank='null',status='old',
     .   iostat=jstat)

c****Read in the linelist

      fmultlines = '/valdnist.4163'

      flines(1:num+num2) = moogpath(1:num)//synth_run
      nflines = rank*11+206

      flines(num+num2+1:num+num2+25) = srank//fmultlines
      open (unit=nflines,file=flines,access='sequential',
     .      form='formatted',blank='null',status='old',
     .      iostat=jstat)
c   Now synthesize the spectrum by calling the subroutine synth (Synthie.f)
      call synth (teffi,loggi,fehi,alphai,rank,nfslines,
     $   nfbarklem,moogpath,atmpath,synthpath,binpath,
     $   synth_run,replace,nflines)
     
      close(unit=nfslines)
      close(unit=nfbarklem)
      close(unit=nflines)

      end
