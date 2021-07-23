import numpy as np
from mpi4py import MPI
from moogiepyc import moogie
from multiprocessing import Process
from calculate_params import calculate_params
from calculate_nloop import calculate_nloop

synth_run = 'run_1'

teff1 = 3500; teff2 = 3700
teff_array = np.arange(3500, 5600, 100).tolist() + np.arange(5600, 8200, 200).tolist()
teff_array = np.array(teff_array)

#Information for where to synthesize for low Teff runs
teff_vals = np.array([3500., 3600., 3700.])
feh_thresh = np.array([-5., -4.9, -4.8])

w1 = np.where(teff_array == teff1)[0][0]
w2 = np.where(teff_array == teff2)[0][0]

iteff1 = w1+1
iteff2 = w2+1

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

nloop,nsynths = calculate_nloop(iteff1,iteff2,size)

start_time = MPI.Wtime()
    
for mmm in range(nloop):

    mmm += 1
    params = calculate_params(mmm,nsynths,size,rank,iteff1)
    params = np.round(params, decimals=1)
    if params.tolist().count(0.) == len(params): pass
    else:
       #Additional code to avoid certain problematic regions of parameter space for low Teff
       where_teff = np.where(teff_vals == params[0])[0][0]
       #print where_teff, feh_thresh[where_teff], params[0]
       if params[2] < feh_thresh[where_teff]: pass
       else:
          print 'process: '+str(rank)+', parameters: teff = {}, logg = {}, feh = {}, alpha = {}'.format(params[0], params[1], params[2], params[3])
          p = Process(target=moogie, args=(params[0],params[1],params[2],params[3],rank,synth_run,))
          p.start()
          p.join()

end_time = MPI.Wtime()
print'Elapsed CPU time: '+str(end_time - start_time)+' s'


      


    
    
