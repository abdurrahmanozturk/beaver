#include "UO2ThermalConductivity.h"
#include "libmesh/quadrature.h"

template <>
InputParameters
validParams<UO2ThermalConductivity>()
{
  InputParameters params = validParams<Material>();
  params.addClassDescription("Temperature dependent thermal_conductivity model for UO2 by IAEA [W/m-K]");
  params.addCoupledVar("temp", "variable for temperature");
  return params;
}

UO2ThermalConductivity::UO2ThermalConductivity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _T(coupledValue("temp")),
    _thermal_conductivity(declareProperty<Real>("thermal_conductivity")),
    _dthermal_conductivity_dT(declarePropertyDerivative<Real>("thermal_conductivity", getVar("temp", 0)->name()))
{
}

void
UO2ThermalConductivity::computeQpProperties()
{
  _thermal_conductivity[_qp] = 100 / (7.5408 + 17.692*(0.001*_T[_qp]) + 3.6142*pow(0.001*_T[_qp],2)) + 6400*exp(-16.35/(0.001*_T[_qp]))/pow(0.001*_T[_qp],2.5);
  _dthermal_conductivity_dT[_qp] = (1769.2 + 722.84*0.001*_T[_qp])/pow((7.5408 + 17.692*(0.001*_T[_qp]) + 3.6142*pow(0.001*_T[_qp],2)),2) + exp(-16.35/(0.001*_T[_qp]))*(104640.0/pow(0.001*_T[_qp],4.5)-16000/pow(0.001*_T[_qp],3.5));
  // _dthermal_conductivity_dT[_qp] = 0.;
}
