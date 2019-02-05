#ifndef RadiationHeatTransfer_H
#define RadiationHeatTransfer_H

#include "Kernel.h"
#include "ViewFactor.h"

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

  // const VariableValue & _temp;
  const ViewFactor & _viewfactor;
};

#endif // RadiationHeatTransfer_H
