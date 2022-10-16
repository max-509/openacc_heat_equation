#ifndef HEAT_EQUATION_SOLVER_H
#define HEAT_EQUATION_SOLVER_H

#include "heat_equation_common.h"

#include <stddef.h>

int solve_heat_equation(FLOAT_TYPE *init_grid, size_t gird_size, size_t max_iter, FLOAT_TYPE etol, size_t *last_iter);

const char *get_target_device_type();

const char *get_solver_version();

int get_iters_without_err();

#endif //  HEAT_EQUATION_SOLVER_H
