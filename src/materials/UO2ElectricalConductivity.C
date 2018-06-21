#include "UO2ElectricalConductivity.h"
#include "libmesh/quadrature.h"

template <>
InputParameters
validParams<UO2ElectricalConductivity>()
{
  InputParameters params = validParams<Material>();
  params.addCoupledVar("temp", 300.0, "variable for temperature");
  params.addParam<Real>("activation_energy", 0.13, "Activation energy of UO2");
  params.addParam<Real>("k_const", 8.617e-5, "Boltzmann Constant");
  params.addParam<Real>("sigma_0", 25., "Constant in conductivity equation");
  return params;
}

UO2ElectricalConductivity::UO2ElectricalConductivity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _act_e(getParam<Real>("activation_energy")),
    _k_const(getParam<Real>("k_const")),
    _sigma_0(getParam<Real>("sigma_0")),
    _T(coupledValue("temp")),
    _electric_conductivity(declareProperty<Real>("electrical_conductivity")),
    _delectric_conductivity_dT(
        declarePropertyDerivative<Real>("electrical_conductivity", getVar("temp", 0)->name()))
{
}

void
UO2ElectricalConductivity::computeQpProperties()
{
  _electric_conductivity[_qp] = (_sigma_0 * exp((-_act_e) / (_k_const * _T[_qp])));
  _delectric_conductivity_dT[_qp] = 0.; //(( (_sigma_0 * _act_e) / (_k_const * _T[_qp]) ) * exp(
                                        //(-_act_e) / (_k_const * _T[_qp]) )) * 100.;
}
