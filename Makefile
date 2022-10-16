N_ERR_COMPUTING_IN_DEVICE?=100
FLOAT_TYPE?=double
COMMON_CC_FLAGS=-DFLOAT_TYPE=$(FLOAT_TYPE) -std=c11 -fopenmp -lm -O3
OPENACC_CC_FLAGS=$(COMMON_CC_FLAGS) -acc -Minfo=accel
GPU_CC_FLAGS=$(OPENACC_CC_FLAGS) -ta=tesla -DTARGET_DEVICE=GPU
CPU_CC_FLAGS=$(OPENACC_CC_FLAGS) -ta=multicore -DTARGET_DEVICE=CPU

all: build

rebuild: clean build

build: naive parallel reduce_err_copy without_swap

naive: src/heat_equation_solver_naive.c heat_equation_runner.o src/heat_equation_solver.h src/heat_equation_utils.h
	pgcc $(GPU_CC_FLAGS) $< heat_equation_runner.o -o $@_gpu.out
	pgcc $(CPU_CC_FLAGS) $< heat_equation_runner.o -o $@_cpu.out

parallel: src/heat_equation_solver_parallel.c heat_equation_runner.o src/heat_equation_solver.h src/heat_equation_utils.h
	pgcc $(GPU_CC_FLAGS) $< heat_equation_runner.o -o $@_gpu.out
	pgcc $(CPU_CC_FLAGS) $< heat_equation_runner.o -o $@_cpu.out

reduce_err_copy: src/heat_equation_solver_reduce_err_copy.c heat_equation_runner.o src/heat_equation_solver.h src/heat_equation_utils.h
	pgcc $(GPU_CC_FLAGS) -DN_ERR_COMPUTING_IN_DEVICE=$(N_ERR_COMPUTING_IN_DEVICE) $< heat_equation_runner.o -o $@_gpu.out
	pgcc $(CPU_CC_FLAGS) -DN_ERR_COMPUTING_IN_DEVICE=$(N_ERR_COMPUTING_IN_DEVICE) $< heat_equation_runner.o -o $@_cpu.out

without_swap: src/heat_equation_solver_without_swap.c heat_equation_runner.o src/heat_equation_solver.h src/heat_equation_utils.h
	pgcc $(GPU_CC_FLAGS) -DN_ERR_COMPUTING_IN_DEVICE=$(N_ERR_COMPUTING_IN_DEVICE) $< heat_equation_runner.o -o $@_gpu.out
	pgcc $(CPU_CC_FLAGS) -DN_ERR_COMPUTING_IN_DEVICE=$(N_ERR_COMPUTING_IN_DEVICE) $< heat_equation_runner.o -o $@_cpu.out

heat_equation_runner.o: src/heat_equation_runner.c
	gcc $(COMMON_CC_FLAGS) -c src/heat_equation_runner.c -o heat_equation_runner.o

clean:
	rm -rf *.o *.out *.so

.PHONY: run clean