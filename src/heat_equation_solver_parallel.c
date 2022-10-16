#include "heat_equation_solver_impl.h"

#include <stdlib.h>
#include <math.h>

int solve_heat_equation(FLOAT_TYPE * restrict init_grid, const size_t grid_size, const size_t max_iter, const FLOAT_TYPE etol, size_t *last_iter)
{
  const size_t grid_sqr = grid_size * grid_size;
  FLOAT_TYPE *buff_grid = (FLOAT_TYPE *)malloc(sizeof(FLOAT_TYPE) * grid_sqr * 2);
  if (NULL == buff_grid)
  {
    return 1;
  }

#pragma acc data copy(init_grid [0:grid_sqr]) create(buff_grid [0:grid_sqr * 2])
  {
    FLOAT_TYPE *curr_grid = buff_grid, *next_grid = buff_grid + grid_sqr;
    FLOAT_TYPE err = (FLOAT_TYPE)INFINITY;
    size_t curr_iter;

#pragma acc data present(init_grid [0:grid_sqr], next_grid [0:grid_sqr], curr_grid [0:grid_sqr])
#pragma acc parallel
    {
#pragma acc loop independent collapse(2)
      for (size_t i = 0; i < grid_size; ++i)
      {
        for (size_t j = 0; j < grid_size; ++j)
        {
          size_t grid_idx = i * grid_size + j;
          curr_grid[grid_idx] = init_grid[grid_idx];
          next_grid[grid_idx] = init_grid[grid_idx];
        }
      }
    }

    for (curr_iter = 0u; curr_iter < max_iter && err > etol; ++curr_iter)
    {
      err = (FLOAT_TYPE)0.0;

#pragma acc data present(next_grid [0:grid_sqr], curr_grid [0:grid_sqr])
#pragma acc kernels
      {
#pragma acc loop independent collapse(2) reduction(max \
                                                   : err)
        for (size_t i = 1; i < grid_size - 1; ++i)
        {
          for (size_t j = 1; j < grid_size - 1; ++j)
          {
            const size_t grid_idx = i * grid_size + j;
            next_grid[grid_idx] = (FLOAT_TYPE)0.25 * (curr_grid[grid_idx - grid_size] +
                                                      curr_grid[grid_idx + grid_size] +
                                                      curr_grid[grid_idx - 1] +
                                                      curr_grid[grid_idx + 1]);
            err = fmax(err, fabs(next_grid[grid_idx] - curr_grid[grid_idx]));
          }
        }
      }

      FLOAT_TYPE *tmp_ptr = curr_grid;
      curr_grid = next_grid;
      next_grid = tmp_ptr;
    }

#pragma acc data present(init_grid [0:grid_sqr], curr_grid [0:grid_sqr])
#pragma acc parallel
    {
#pragma acc loop independent collapse(2)
      for (size_t i = 0; i < grid_size; ++i)
      {
        for (size_t j = 0; j < grid_size; ++j)
        {
          size_t grid_idx = i * grid_size + j;
          init_grid[grid_idx] = curr_grid[grid_idx];
        }
      }
    }

    if (NULL != last_iter)
    {
      *last_iter = curr_iter;
    }
  }

  free(buff_grid);

  return 0;
}

const char *get_solver_version() {
  return "Version 2";
}

int get_iters_without_err() {
  return 0;
}
