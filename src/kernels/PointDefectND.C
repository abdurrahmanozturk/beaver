#include "PointDefectND.h"

registerMooseObject("beaverApp", PointDefectND);

template<>
InputParameters validParams<PointDefectND>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription(
      "Kernel for Nondimensionalized Point Defect Balance Equations");
  params.addParam<Real>(
      "k", 0.0, "Defect generation rate. [dpa/s]");
  params.addParam<Real>(
      "D", 0.0, "Defect diffusion coefficient");
  params.addRequiredParam<Real>(
      "ks", "Total sink strength for defect. [1/length^2]");
  params.addParam<Real>(
      "kiv", 0.0, "The reaction rate constant for reaction between defects i and j. [1/s]");
  params.addParam<bool>(
      "disable_diffusion", false, "Disable diffusion term in point defect equations.");
  params.addCoupledVar(
      "coupled", "Coupled defect concentration");
  return params;
}

PointDefectND::PointDefectND(const InputParameters & parameters)
  : Kernel(parameters),
    _conc(coupledValue("coupled")),
    _k(getParam<Real>("k")),
    _D(getParam<Real>("D")),
    _ks(getParam<Real>("ks")),
    _kiv(getParam<Real>("kiv")),
    _disable_diffusion(getParam<bool>("disable_diffusion"))
{
  _t = sqrt(_k*_kiv)/(_ks*_ks*_D);
}

Real
PointDefectND::computeQpResidual()
{
  if (_disable_diffusion)
    return _test[_i][_qp]*_u[_qp]/_t + _test[_i][_qp]*_u[_qp]*_conc[_qp] - _test[_i][_qp];
  else
    return _test[_i][_qp]*_u[_qp]/_t + _test[_i][_qp]*_u[_qp]*_conc[_qp] - _test[_i][_qp] - (_k/(_t*_ks*_ks))*_grad_u[_qp]*_grad_test[_i][_qp];
}
