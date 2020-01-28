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
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  const VariableValue & _conc;
  Real _k;
  Real _D;
  Real _ks;
  Real _kiv;
  Real _tau;
  bool _disable_diffusion;
};
