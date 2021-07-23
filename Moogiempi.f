      program moog

      implicit real*8 (a-h,o-z)
    
      include 'mpif.h'
      include 'Atmos.com'
      include 'Dampdat.com'
      include 'Dummy.com'
      include 'Factor.com'
      include 'Kappa.com'
      include 'Linex.com'
      include 'Mol.com'
      include 'Quants.com'
    
c   The following parameters are set to rank = 0 and size = 1 for non-MPI version
      integer rank, size, ierr
c   A string version of the rank, used to define filenames
      character*3 srank
c   Based on the rank and size, determine the number of synthesis per core.
c   These variables loop through the various synthesis accordingly
      integer nsynths,nnn,mmm,nloop
c   Variables for determining how long it takes to synthesize a spectrum
      real :: cpustart, cpufinish
    
c   System parameters
      character*250 systemcall
    
c   Define paths to be used to point to directories
      character*99 moogpath,atmpath,synthpath,binpath,synth_run
    
c   These variables are for iterating over the various parameters for the
c   the atmospheric models
      integer tempindex
      integer iteff,ilogg,ifeh,ialpha
      real*8 teffarr(34),loggarr(11),feharr(51),alphaarr(21)
      real*8 teffi,loggi,fehi,alphai
      integer nteff,nlogg,nfeh,nalpha
    
c   Parameters such as filenames for strong line lists and 
c   Barklem HI collisional broadening
      character*99 fslines,fbarklem
      integer nfslines,nfbarklem
      integer num, num2
    
c   Boolean variables
      logical test, replace
    
c   Variables for a test run, including output directory and a restrictive range
c   for the temperature
      synth_run = 'mpi_test'
      tempindex = 1
      
      test = .true.
      replace = .true.

      call cpu_time(cpustart)
      
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

c   Initialize the MPI execution environment, where ierr is an error return
c   Note that the communicator MPI_COMM_WORLD contains all of the processes
      call MPI_INIT(ierr)
c   Determines the rank of the calling processes in the communicator
c   Returns the rank of the calling processes in the group mpi_comm_world
      call MPI_COMM_RANK(MP_COMM_WORLD, rank, ierr)
c   Determines the size of the group associated with a communicator
c   Returns the number of processes in the group mpi_comm_world
      call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierr)
      write(*,*)"rank: ",rank," size: ",size," ierr: ",ierr 
      
c******* clear path names
1001  format (99(' '))
1002  format (250(' '))
      write (systemcall,1002)
      write (fslines,1001)
      write (fbarklem,1001)
      write (moogpath,1001)
      write (synthpath,1001)
      write (binpath,1001)
      write (atmpath,1001)
      
c******* define paths
      moogpath = 
     .  '/raid/iescala/moogie/'
      atmpath = 
     .  '/raid/grid7/atmospheres'
      synthpath = 
     .  '/raid/iescala/gridie/synths'
      binpath = 
     .  '/raid/iescala/gridie/bin'
      
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
 
c******* find total number of interations (nsynths)

      iteff1=tempindex
      iteff2=tempindex
    
      ilogg1=1
      ilogg2=11

      ifeh1=1
      ifeh2=51

      ialpha1=1
      ialpha2=21

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
      
      if (test .eqv. .true.) then
         nsynths=1
      endif
      nloop=floor(real(nsynths)/real(size))+1
      if (rank .eq. 0) then
         write(*,*) "Number of loops:",nloop
      endif

c********* call synth for each iteration
     
      do mmm=1,nloop
         if ((rank .eq. 0) .and. (replace .eqv. .true.)) then
            write(*,*) "Rank 0 is starting loop:",mmm
         endif
         nnn=((mmm-1)*size)+rank+1
         if (nnn.le.nsynths) then
            iteff=floor(real(nnn-1)/real(nlogg*nfeh*nalpha))
            ilogg=floor(real(nnn-1-iteff*nlogg*nfeh*nalpha)
     .           /real(nfeh*nalpha))
            ifeh=floor(real(nnn-1-iteff*nlogg*nfeh*nalpha-ilogg
     .           *nfeh*nalpha)/real(nalpha))
            ialpha=nnn-1-iteff*nlogg*nfeh*nalpha-ilogg
     .           *nfeh*nalpha-ifeh*nalpha
            iteff=iteff+iteff1
            ilogg=ilogg+ilogg1
            ifeh=ifeh+ifeh1
            ialpha=ialpha+ialpha1

c   Focus on effective temperature < 4200 K and log g < 3.5 cm s^(-2) to start            
            if ((iteff .lt. 8) .or. (ilogg .lt. 8)) then
c              write(*,*) iteff, ilogg, ifeh, ialpha
               teffi=teffarr(iteff)
               loggi=loggarr(ilogg)
               fehi=feharr(ifeh)
               alphai=alphaarr(ialpha)

c   Now synthesize the spectrum by calling the subroutine synth (Synthie.f)
               call synth (teffi,loggi,fehi,alphai,rank,nfslines,
     $            nfbarklem,moogpath,atmpath,synthpath,binpath,test,
     $            synth_run,replace)
            endif
         endif
      enddo
      
c   Terminate the MPI execution environment
      call MPI_FINALIZE(ierr)

      call cpu_time(cpufinish)
      write(*,*)'Elapsed CPU time',cpufinish-cpustart,' seconds'

      end
