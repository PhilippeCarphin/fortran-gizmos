#
# this Makefile should be OK for tcl/tk 8.5, python 2.7 using gcc/gfortran
# (tested on Ubuntu 12.04)
#
CCOMP = gcc

FCOMP = gfortran

MPIFC = mpif90

FFLAGS = -O2

CFLAGS = -O2

TK_FLAGS = $(shell pkg-config --cflags x11)
TK_LIBS = $(shell pkg-config --libs x11)
PYTHON3_FLAGS = $(shell pkg-config --cflags python3-embed)
PYTHON3_LIBS = $(shell pkg-config --libs python3-embed)
OMP_FLAGS = -I /opt/homebrew/Cellar/libomp/12.0.0/include

all:	f_python f_tclsh f_wish f_demo libompstubs.a

demo:	f_demo

libompstubs.a: openmp_stubs_c.c openmp_stubs_f.F90
	$(CCOMP) -c -fPIC openmp_stubs_c.c $(OMP_FLAGS)
	$(FCOMP) -c -fPIC openmp_stubs_f.F90 $(OMP_FLAGS)
	ar rcv libompstubs.a openmp_stubs_c.o openmp_stubs_f.o

f_demo:	mydemo.c Fortran_to_c_main.F90
	$(CCOMP) -c -Dmain=MY_C_MAIN mydemo.c
	$(FCOMP) -o f_demo Fortran_to_c_main.F90 mydemo.o -Wc-binding-type
	rm -f mydemo.o

f_python : pythonAppInit.c Fortran_to_c_main.F90
	$(CCOMP) -c -Dmain=MY_C_MAIN pythonAppInit.c $(PYTHON3_FLAGS)
	$(FCOMP) -o f_python Fortran_to_c_main.F90 pythonAppInit.o $(PYTHON3_LIBS)
	rm -f pythonAppInit.o

f_tclsh : tclAppInit.c Fortran_to_c_main.F90
	$(CCOMP) -c -Dmain=MY_C_MAIN tclAppInit.c -I/usr/include/tcl8.5
	$(FCOMP) -o f_tclsh Fortran_to_c_main.F90 tclAppInit.o -ltcl8.5
	rm -f tclAppInit.o

f_wish : tkAppInit.c Fortran_to_c_main.F90
	$(CCOMP) -c -Dmain=MY_C_MAIN tkAppInit.c -I/usr/include/tcl8.5 $(TK_FLAGS)
	$(FCOMP) -o f_wish Fortran_to_c_main.F90 tkAppInit.o -ltk8.5  -ltcl8.5 $(TK_LIBS)
	rm -f tkAppInit.o

clean:	
	rm -f *.o *.mod a.out f_python f_tclsh f_wish f_demo *~  *.s
	rm -f libompstubs.a 
