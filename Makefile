#
# this Makefile should be OK for tcl/tk 8.5, python 2.7 using gcc/gfortran
# (tested on Ubuntu 12.04)
#
CCOMP = gcc

FCOMP = gfortran

MPIFC = mpif90

FFLAGS = -O2

CFLAGS = -O2

all:	f_python f_tclsh f_wish f_demo libompstubs.a

demo:	f_demo

libompstubs.a: openmp_stubs_c.c openmp_stubs_f.F90
	$(CCOMP) -c -fPIC openmp_stubs_c.c
	$(FCOMP) -c -fPIC openmp_stubs_f.F90
	ar rcv libompstubs.a openmp_stubs_c.o openmp_stubs_f.o

f_demo:	mydemo.c Fortran_to_c_main.F90
	$(CCOMP) -c -Dmain=MY_C_MAIN mydemo.c
	$(FCOMP) -o f_demo Fortran_to_c_main.F90 mydemo.o
	rm -f mydemo.o

f_python : pythonAppInit.c Fortran_to_c_main.F90
	$(CCOMP) -c -Dmain=MY_C_MAIN pythonAppInit.c $(shell pkg-config --cflags python3-embed)
	$(FCOMP) -o f_python Fortran_to_c_main.F90 pythonAppInit.o $(shell pkg-config --libs python3-embed)
	rm -f pythonAppInit.o

f_tclsh : tclAppInit.c Fortran_to_c_main.F90
	$(CCOMP) -c -Dmain=MY_C_MAIN tclAppInit.c -I/usr/include/tcl8.5
	$(FCOMP) -o f_tclsh Fortran_to_c_main.F90 tclAppInit.o -ltcl8.5
	rm -f tclAppInit.o

f_wish : tkAppInit.c Fortran_to_c_main.F90
	$(CCOMP) -c -Dmain=MY_C_MAIN tkAppInit.c -I/usr/include/tcl8.5
	$(FCOMP) -o f_wish Fortran_to_c_main.F90 tkAppInit.o -ltk8.5  -ltcl8.5
	rm -f tkAppInit.o

clean:	
	rm -f *.o *.mod a.out f_python f_tclsh f_wish f_demo *~  *.s
	rm -f libompstubs.a 
