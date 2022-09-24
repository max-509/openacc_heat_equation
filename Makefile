RESULTS_FILE=results.csv
ETOL?=10e-6
MAX_ITER?=1000000
GRID_SIZE?=128
FLOAT_TYPE?=double
COMMON_CC_FLAGS=-DFLOAT_TYPE=$(FLOAT_TYPE) -std=c11 -fopenmp -lm -O3
OPENACC_CC_FLAGS=$(COMMON_CC_FLAGS) -acc -Minfo=accel
GPU_CC_FLAGS=$(OPENACC_CC_FLAGS) -ta=tesla
CPU_CC_FLAGS=$(OPENACC_CC_FLAGS) -ta=multicore

all: build run

rebuild: clean build

build: mkdir_build naive

naive: src/heat_equation_solver_naive.c src/heat_equation_solver.h src/heat_equation_utils.h heat_equation_runner.o
	pgcc $(GPU_CC_FLAGS) src/heat_equation_solver_naive.c heat_equation_runner.o -o $@_gpu.out
	pgcc $(CPU_CC_FLAGS) src/heat_equation_solver_naive.c heat_equation_runner.o -o $@_cpu.out

heat_equation_runner.o: src/heat_equation_runner.c
	gcc $(COMMON_CC_FLAGS) -c src/heat_equation_runner.c -o heat_equation_runner.o

mkdir_build:
	mkdir -p build

clean:
	rm -rf *.o *.out *.so

.PHONY: mkdir_build run clean