#include "RadiativeBC.h"
#include "RadiativeBCBase.h"

registerMooseObject("beaverApp", RadiativeBC);

template <>
InputParameters
validParams<RadiativeBC>()
{
  InputParameters params = validParams<RadiativeBCBase>();
  params.addClassDescription("Radiation Heat Transfer BC Model with view factors.");
  params.addParam<Real>(
      "stefan_boltzmann", 5.670367e-8, "The Stefan-Boltzmann constant [kg.s^3.K^4].");
  params.addRequiredParam<std::vector<Real>>("emissivity",
                                             "The emissivities of boundaries (sort by ids).");
  params.addParam<std::string>("viewfactor_method",
                               "MONTECARLO",
                               "View Factor calculation method. The available options: MONTECARLO");
  params.addParam<unsigned int>("sampling_number", 100, "Number of Sampling");
  params.addParam<unsigned int>("source_number", 100, "Number of Source Points");
  return params;
}

RadiativeBC::RadiativeBC(const InputParameters & parameters)
  : RadiativeBCBase(parameters),
    _var_number(_subproblem
                    .getVariable(_tid,
                                 parameters.get<NonlinearVariableName>("variable"),
                                 Moose::VarKindType::VAR_ANY,
                                 Moose::VarFieldType::VAR_FIELD_STANDARD)
                    .number()),
    _system(_subproblem.getSystem(getParam<NonlinearVariableName>("variable"))),
    _samplingNumber(getParam<unsigned int>("sampling_number")),
    _sourceNumber(getParam<unsigned int>("source_number")),
    _boundary_ids(boundaryIDs()),
    _stefan_boltzmann(getParam<Real>("stefan_boltzmann")),
    _method(getParam<std::string>("viewfactor_method"))
{
  std::vector<Real> emissivity = getParam<std::vector<Real>>("emissivity");
  if (emissivity.size() != _boundary_ids.size())
    mooseError("The number of emissivities does not match the number of boundaries.");
  unsigned int i{0};
  for (const auto bid : _boundary_ids)
    _emissivity[bid] = emissivity[i++];

  for (const auto & t : _mesh.buildSideList()) // buildSideList(el,side,bnd)
  {
    auto elem_id = std::get<0>(t);
    auto side_id = std::get<1>(t);
    auto bnd_id = std::get<2>(t);
    // if (_slave_boundary_ids.find(bnd_id)!=_slave_boundary_ids.end())
    if (_boundary_ids.find(bnd_id) != _boundary_ids.end())
      _elem_side_map[elem_id] = side_id;
  }
}

Real
RadiativeBC::computeQpResidual()
{
  Real _u_slave, q_ms, q_sm, q_net{0};
  Real temp_func_master = _u[_qp] * _u[_qp] * _u[_qp] * _u[_qp];
  BoundaryID current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  if (_boundary_ids.find(current_boundary_id) != _boundary_ids.end())
  {
    _master_elem_id = _current_elem->id();
    _master_side_map = getSideMap(_current_elem, _current_side);
    const std::vector<Real> master_center = getCenterPoint(_master_side_map);
    const Real master_area = getArea(master_center, _master_side_map);
    for (const auto & elem : _elem_side_map)
    {
      Elem * slave_elem = _mesh.elemPtr(elem.first);
      const unsigned int slave_side = elem.second;
      BoundaryID slave_bnd_id = _mesh.getBoundaryIDs(slave_elem, slave_side)[0];
      _slave_elem_id = slave_elem->id(); // elem.first
      // if (_master_elem_id == _slave_elem_id)
      //   continue;
      _slave_side_map = getSideMap(slave_elem, slave_side);
      const std::vector<Real> slave_center = getCenterPoint(_slave_side_map);
      const Real slave_area = getArea(slave_center, _slave_side_map);
      const Point point(slave_center[0], slave_center[1], slave_center[2]);
      _u_slave = _system.point_value(_var_number, point, false);
      Real temp_func_slave = _u_slave * _u_slave * _u_slave * _u_slave;
      Real f_ms;
      if (isVisible(_master_side_map, _slave_side_map))
      {
        if (_method == "MONTECARLO")
          f_ms = doMonteCarlo(_master_side_map, _slave_side_map, _sourceNumber, _samplingNumber);
        else
          mooseError("Undefined method for view factor calculations.");
      }
      else
      {
        f_ms = 0;
      }
      Real f_sm = f_ms * (master_area / slave_area);
      q_ms = _emissivity[current_boundary_id] * _stefan_boltzmann * f_ms *
             temp_func_master;                                                       // master-slave
      q_sm = _emissivity[slave_bnd_id] * _stefan_boltzmann * f_sm * temp_func_slave; // slave-master
      q_net += q_ms - q_sm;
    }
  }
  return _test[_i][_qp] * q_net;
}

Real
RadiativeBC::computeQpJacobian()
{
  // Real dq_net{0.0};
  // BoundaryID current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  // if (_boundary_ids.find(current_boundary_id)!=_boundary_ids.end())
  // {
  //   Real dtemp_func_master = 4 * _phi[_j][_qp] * _u[_qp] * _u[_qp] * _u[_qp];
  //   dq_net = _emissivity[current_boundary_id] * _stefan_boltzmann * f_ms * dtemp_func_master; //
  //   black body
  // }
  // return _test[_i][_qp] * dq_net;
  return 0;
}
