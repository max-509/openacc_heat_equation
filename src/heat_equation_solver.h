#ifndef HEAT_EQUATION_SOLVER_NAIVE_H
#define HEAT_EQUATION_SOLVER_NAIVE_H

#include "heat_equation_common.h"

#include <stddef.h>

int
solve_heat_equation(FLOAT_TYPE *init_grid, size_t gird_size, size_t max_iter, FLOAT_TYPE etol, size_t *last_iter);

#endif //  HEAT_EQUATION_SOLVER_NAIVE_H
