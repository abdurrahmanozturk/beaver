#ifndef RadiationHeatTransfer_H
#define RadiationHeatTransfer_H

#include "Kernel.h"

class RadiationHeatTransfer;

template <>
InputParameters validParams<RadiationHeatTransfer>();

/**
 *
 */
class RadiationHeatTransfer : public Kernel
{
public:
  RadiationHeatTransfer(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  Real _view_factor;
};

#endif // RadiationHeatTransfer_H
