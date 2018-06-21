#include "UO2.h"
#include "libmesh/quadrature.h"

template <>
InputParameters
validParams<UO2>()
{
  InputParameters params = validParams<Material>();
  params.addClassDescription("Uranium Dioxide(UO2) Thermo-Physical Properties");
  params.addCoupledVar("temp", "Coupled variable name for temperature");
  params.addParam<Real>("mol_kg", 0.27002771, "Conversion from moles to kg for UO2");
  return params;
}

UO2::UO2(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _T(coupledValue("temp")),
    _mol_kg(getParam<Real>("mol_kg")),
    _specific_heat(declareProperty<Real>("specific_heat")),
    _density(declareProperty<Real>("density")),
    _thermal_conductivity(declareProperty<Real>("thermal_conductivity")),
    _dspecific_heat_dT(declarePropertyDerivative<Real>("specific_heat", getVar("temp", 0)->name())),
    _ddensity_dT(declarePropertyDerivative<Real>("density", getVar("temp", 0)->name())),
    _dthermal_conductivity_dT(declarePropertyDerivative<Real>("thermal_conductivity", getVar("temp", 0)->name()))
{
}

void
UO2::computeQpProperties()
{
  _specific_heat[_qp] = (-2.6334 * pow(0.001 * _T[_qp], 4) + 31.542 * pow(0.001 * _T[_qp], 3) -
                         84.2411 * pow(0.001 * _T[_qp], 2) + 87.951 * 0.001 * _T[_qp] -
                         0.71391 * pow(0.001 * _T[_qp], -2) + 52.1743) / _mol_kg;
  _density[_qp] = 1000 * (11.049 - 3.34e-4 * _T[_qp] + 3.9913e-8 * pow(_T[_qp], 2) - 2.7649e-11 * pow(_T[_qp], 3));
  _thermal_conductivity[_qp] = 100 / (7.5408 + 17.692 * (0.001 * _T[_qp]) + 3.6142 * pow(0.001 * _T[_qp], 2)) +
                               6400 * exp(-16.35 / (0.001 * _T[_qp])) / pow(0.001 * _T[_qp], 2.5);

  _dspecific_heat_dT[_qp] = (-10.534 * pow(0.001 * _T[_qp], 3) + 94.626 * pow(0.001 * _T[_qp], 2) -
                             168.48 * 0.001 * _T[_qp] + 87.951 + 1.4278 * pow(0.001 * _T[_qp], -3)) / _mol_kg;
  _ddensity_dT[_qp] = 1000 * (-3.34e-4 + 7.9826e-8 * _T[_qp] - 8.2947e-11 * pow(_T[_qp], 2));
  _dthermal_conductivity_dT[_qp] = (1769.2 + 722.84 * 0.001 * _T[_qp]) /
                                    pow((7.5408 + 17.692 * (0.001 * _T[_qp]) + 3.6142 * pow(0.001 * _T[_qp], 2)), 2) +
                                    exp(-16.35 / (0.001 * _T[_qp])) * (104640.0 / pow(0.001 * _T[_qp], 4.5) -
                                    16000 / pow(0.001 * _T[_qp], 3.5));
}
