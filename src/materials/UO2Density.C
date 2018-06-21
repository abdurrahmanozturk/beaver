#include "UO2Density.h"
#include "libmesh/quadrature.h"

template <>
InputParameters
validParams<UO2Density>()
{
  InputParameters params = validParams<Material>();
  params.addClassDescription("Temperature dependent density model for UO2 by IAEA [kg/m3]");
  params.addCoupledVar("temp", "coupled variable name for temperature");
  return params;
}

UO2Density::UO2Density(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _T(coupledValue("temp")),
    _density(declareProperty<Real>("density")),
    _ddensity_dT(declarePropertyDerivative<Real>("density", getVar("temp", 0)->name()))
{
}

void
UO2Density::computeQpProperties()
{
  _density[_qp] = 1000 * (11.049 - 3.34e-4 * _T[_qp] + 3.9913e-8 * pow(_T[_qp], 2) -
                          2.7649e-11 * pow(_T[_qp], 3));
  _ddensity_dT[_qp] = 1000 * (-3.34e-4 + 7.9826e-8 * _T[_qp] - 8.2947e-11 * pow(_T[_qp], 2));
}
