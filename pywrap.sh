make -f Makefile.pywrap clean
make -f Makefile.pywrap
rm *.pyf *.so
f2py -m moogiepyc -h moogiepyc.pyf *.f
f2py -c moogiepyc.pyf *.o
