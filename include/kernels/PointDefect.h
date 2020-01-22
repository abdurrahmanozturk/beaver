#pragma once

#include "Kernel.h"

//Forward Declarations
class PointDefect;

template<>
InputParameters validParams<PointDefect>();

class PointDefect : public Kernel
{
public:
  PointDefect(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();

  const VariableValue & _conc;
  Real _k;
  Real _D;
  Real _ks;
  Real _kiv;
  bool _disable_diffusion;
};
