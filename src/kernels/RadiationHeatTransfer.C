#include "RadiationHeatTransfer.h"

// registerMooseObject("", RadiationHeatTransfer);

template<>
InputParameters validParams<RadiationHeatTransfer>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Radiation Heat Transfer Model");
  params.addRequiredParam<Real>("view_factor", "View Factor for Master-Slave Boundary Pair");
  return params;
}

RadiationHeatTransfer::RadiationHeatTransfer(const InputParameters & parameters)
  : Kernel(parameters),
    _view_factor(getParam<Real>("view_factor") !=0.0)
{
}

Real
RadiationHeatTransfer::computeQpResidual()
{
    return 0;
}

Real
RadiationHeatTransfer::computeQpJacobian()
{
  return 0;
}
