
c******************************************************************************
c     this common block has variables related to the lines.  Most
c     input quantities typically have single dimensions, while the 
c     things that are computed for each line at each atmosphere level
c     have double dimensions.  The variables "a", "dopp", and 
c     "kapnu0" are often over-written with plotting data,
c     so leave them alone or suffer unspeakable programming tortures.
c******************************************************************************

      real*8       a(5000,100), dopp(5000,100), kapnu0(5000,100)
      real*8       gf(5000), wave1(5000), atom1(5000), e(5000,2),
     .             chi(5000,3), amass(5000), charge(5000), d0(5000),
     .             dampnum(5000), gf1(5000), width(5000), 
     .             abundout(5000), widout(5000), strength(5000), 
     .             rdmass(5000), gambark(5000), alpbark(5000),
     .             gamrad(5000), wid1comp(5000)
      real*8       kapnu(100), taunu(100), cd(100), sline(100)
      real*8       d(5000), dellam(400), w(100),
     .             rwtab(3000), gftab(3000), gfhold
      real*8       delta, start, sstop, step, contnorm,
     .             oldstart, oldstop, oldstep, olddelta
      real*8       rwlow, rwhigh, rwstep, wavestep, cogatom,
     .             delwave, wave, waveold, st1
      real*8       gammatot, gammav, gammas, gammar
      integer      group(5000), dostrong, gfstyle, lineflag, molflag,
     .             lim1, lim2, mode, nlines, nstrong, ndepths, ncurve,
     .             lim1line, lim2line, n1marker, ntabtot, 
     .             iabatom, iaa, ibb
      character*7  damptype(5000)

      common/linex/a, dopp, kapnu0,   
     .             gf, wave1, atom1, e,
     .             chi, amass, charge, d0,
     .             dampnum, gf1, width, 
     .             abundout, widout, strength,
     .             rdmass, gambark, alpbark, 
     .             gamrad, wid1comp,
     .             kapnu, taunu, cd, sline,
     .             d, dellam, w,
     .             rwtab, gftab, gfhold,
     .             delta, start, sstop, step, contnorm,
     .             oldstart, oldstop, oldstep, olddelta,
     .             rwlow, rwhigh, rwstep, wavestep, cogatom,
     .             delwave, wave, waveold, st1,
     .             gammatot, gammav, gammas, gammar,
     .             group, dostrong, gfstyle, lineflag, molflag,
     .             lim1, lim2, mode, nlines, nstrong, ndepths, ncurve,
     .             lim1line, lim2line, n1marker, ntabtot,
     .             iabatom, iaa, ibb
      common/lindamp/damptype

