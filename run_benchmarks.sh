#!/bin/bash

ETOL=${1:-1e-6}
GRID_SIZE=${2:-512}
MAX_ITER=${3:-1000000}

BENCHMARKS_TABLE='benchmarks.csv'

echo "Target device;Algo ver;Number of iters;Elapsed Time;Iters without err counting" >> $BENCHMARKS_TABLE

make clean
make

# Very slow version, then we use only 100 iters
./naive_cpu.out $ETOL $GRID_SIZE 100 >> $BENCHMARKS_TABLE
./naive_gpu.out $ETOL $GRID_SIZE 100 >> $BENCHMARKS_TABLE

./parallel_cpu.out $ETOL $GRID_SIZE $MAX_ITER >> $BENCHMARKS_TABLE
./parallel_gpu.out $ETOL $GRID_SIZE $MAX_ITER >> $BENCHMARKS_TABLE

ITERS_WITHOUT_ERR_LIST="1 5 10 25 50 100 150 200 300 500 1000 1500 2000 2500 3000 5000 10000"

for iter_without_err in $ITERS_WITHOUT_ERR_LIST; do
    N_ERR_COMPUTING_IN_DEVICE=$iter_without_err make 

    ./reduce_err_copy_cpu.out $ETOL $GRID_SIZE $MAX_ITER >> $BENCHMARKS_TABLE
    ./reduce_err_copy_gpu.out $ETOL $GRID_SIZE $MAX_ITER >> $BENCHMARKS_TABLE

    ./without_swap_cpu.out $ETOL $GRID_SIZE $MAX_ITER >> $BENCHMARKS_TABLE
    ./without_swap_gpu.out $ETOL $GRID_SIZE $MAX_ITER >> $BENCHMARKS_TABLE
done
