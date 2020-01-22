#pragma once

#include "Kernel.h"

//Forward Declarations
class PointDefectND;

template<>
InputParameters validParams<PointDefectND>();

class PointDefectND : public Kernel
{
public:
  PointDefectND(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();

  const VariableValue & _conc;
  Real _k;
  Real _D;
  Real _ks;
  Real _kiv;
  Real _t;
  bool _disable_diffusion;
};
