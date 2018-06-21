#include "UO2HeatCapacity.h"
#include "libmesh/quadrature.h"

template <>
InputParameters
validParams<UO2HeatCapacity>()
{
  InputParameters params = validParams<Material>();
  params.addClassDescription(
      "Temperature dependent specific heat capacity model for UO2 by Fink(2000) [J/kg-K]");
  params.addCoupledVar("temp", "coupled variable name for temperature");
  params.addParam<Real>("mol_kg", 0.27002771, "conversion from moles to kg for UO2");
  return params;
}

UO2HeatCapacity::UO2HeatCapacity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _mol_kg(getParam<Real>("mol_kg")),
    _T(coupledValue("temp")),
    _specific_heat(declareProperty<Real>("specific_heat")),
    _dspecific_heat_dT(declarePropertyDerivative<Real>("specific_heat", getVar("temp", 0)->name()))
{
}

void
UO2HeatCapacity::computeQpProperties()
{
  _specific_heat[_qp] = (-2.6334 * pow(0.001 * _T[_qp], 4) + 31.542 * pow(0.001 * _T[_qp], 3) -
                         84.2411 * pow(0.001 * _T[_qp], 2) + 87.951 * 0.001 * _T[_qp] -
                         0.71391 * pow(0.001 * _T[_qp], -2) + 52.1743) /
                        _mol_kg;
  _dspecific_heat_dT[_qp] =
      (-10.534 * pow(0.001 * _T[_qp], 3) + 94.626 * pow(0.001 * _T[_qp], 2) -
       168.48 * 0.001 * _T[_qp] + 87.951 + 1.4278 * pow(0.001 * _T[_qp], -3)) /
      _mol_kg;
}
