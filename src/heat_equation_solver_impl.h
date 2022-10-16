#ifndef HEAT_EQUATION_SOLVER_IMPL_H
#define HEAT_EQUATION_SOLVER_IMPL_H

#include "heat_equation_solver.h"
#include "heat_equation_utils.h"

#ifndef TARGET_DEVICE
#define TARGET_DEVICE UNKNOWN
#endif  // TARGET_DEVICE

const char *get_target_device_type() {
  return xstr(TARGET_DEVICE);
}

#endif  // HEAT_EQUATION_SOLVER_IMPL_H
