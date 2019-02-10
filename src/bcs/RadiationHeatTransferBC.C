#include "RadiationHeatTransferBC.h"

registerMooseObject("beaverApp", RadiationHeatTransferBC);

template <>
InputParameters
validParams<RadiationHeatTransferBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addClassDescription("Radiation Heat Transfer BC Model with view factors.");
  params.addRequiredParam<UserObjectName>("viewfactor_userobject",
      "The name of the UserObject that is used for view factor calculations.");
  params.addParam<Real>(
      "stefan_boltzmann", 5.670367e-8, "The Stefan-Boltzmann constant [kg.s^3.K^4].");
  params.addParam<Real>("emissivity", 0.8, "The emissivity of radiation surfaces.");

  return params;
}

RadiationHeatTransferBC::RadiationHeatTransferBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
    // _var_number(_subproblem
    //   .getVariable(_tid,
    //     parameters.get<VariableName>("variable"),
    //     Moose::VarKindType::VAR_ANY,
    //     Moose::VarFieldType::VAR_FIELD_STANDARD)
    //     .number()),
    //     _system(_subproblem.getSystem(getParam<VariableName>("variable"))),
    //     _value(0)
    _viewfactor(getUserObject<ViewFactor>("viewfactor_userobject")),
    _master_boundary_ids(_viewfactor.getMasterBoundaries()),
    _slave_boundary_ids(_viewfactor.getSlaveBoundaries()),
    _stefan_boltzmann(getParam<Real>("stefan_boltzmann")),
    _emissivity(getParam<Real>("emissivity"))
{
}

const Real
RadiationHeatTransferBC::getArea(const Elem * elem,const unsigned int side)
{
  std::unique_ptr<const Elem> elem_side = elem->build_side_ptr(side);

  std::map<unsigned int, std::vector<Real>> side_map;
  unsigned int n_n = elem_side->n_nodes();
  for (unsigned int i = 0; i < n_n; i++)
  {
    const Node * node = elem_side->node_ptr(i);    //get nodes
    for (unsigned int j = 0; j < 3; j++)         // Define nodal coordinates and normals
    {
      side_map[i].push_back((*node)(j));
    }
  }
  const std::vector<Real> side_center = _viewfactor.getCenterPoint(side_map);
  Real area = _viewfactor.getArea(side_center,side_map);
  // std::cout<<"BC::area ="<<area<<std::endl;
  return area;
}

// void
// RadiationHeatTransferBC::updateValues()
// {
//   _system = _subproblem.getSystem(getParam<VariableName>("variable"));
// }

Real
RadiationHeatTransferBC::computeQpResidual()
{
  Real q_ms, q_sm, q_net{0}, T_slave{500.0};
  Real temp_func_master = _u[_qp] * _u[_qp] * _u[_qp] * _u[_qp];
  q_net = _stefan_boltzmann * temp_func_master; // black body
  _current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  if (_master_boundary_ids.find(_current_boundary_id)!=_master_boundary_ids.end())
  {
    _master_elem_id = _current_elem->id();
    Real area_master = getArea(_current_elem,_current_side);
    // std::cout<<"q_net:"<<q_net<<std::endl;
    // std::cout<<"Master:"<<_master_elem_id<<std::endl;
    // std::cout<<"qp "<<_qp<<std::endl;
    // std::cout<<"master_temp ="<<_u[_qp]<<std::endl;
    // std::cout<<"qpoint "<<_q_point[_qp]<<std::endl;
    for (const auto & t : _mesh.buildSideList())    //buildSideList(el,side,bnd)
    {
      auto elem_id = std::get<0>(t);
      auto side_id = std::get<1>(t);
      auto bnd_id = std::get<2>(t);
      if (_slave_boundary_ids.find(bnd_id)!=_slave_boundary_ids.end())
      {
        // updateValues();
        Elem * el = _mesh.elemPtr(elem_id);
        _slave_elem_id = el->id();
        Real f_ms =_viewfactor.getViewFactor(_master_elem_id,_slave_elem_id);
        // std::cout<<"F["<<_master_elem_id<<"]["<<_slave_elem_id<<"] = "<<f_ms<<std::endl;
        Real area_slave = getArea(el,side_id);
        Real temp_func_slave = T_slave * T_slave * T_slave * T_slave;
        // Real f_sm = f_ms * (area_master/area_slave);
        // q_ms = f_ms*temp_func_slave;   // master - slave
        // q_sm = f_sm*temp_func_master;    //slave - master
        q_net -= _stefan_boltzmann * f_ms * temp_func_slave;
        // std::cout<<"q= "<<q_net<<std::endl;
        // _slave_center = Point(2.5, 0.0, 0.0);

        // FIND THE SOLUTION AT SLAVE QUADRATURE POINT
        // Node * qnode = _mesh.getQuadratureNode(el, side_id, _qp);

        // _value = _system.point_value(_var_number, _slave_center, false);

        // std::cout<<"Slave:"<<std::endl;
        // std::cout<<"qp "<<_qp<<std::endl;
        // std::cout<<"temp ="<<_value<<std::endl;
        // std::cout<<"qpoint "<<qnode<<std::endl;
        // calculate net heat flux between master element and salve element
      }
    }
  }
  return _test[_i][_qp] * q_net;
}

Real
RadiationHeatTransferBC::computeQpJacobian()
{
  // Real dq_net{0.0};
  // _current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  // if (_master_boundary_ids.find(_current_boundary_id)!=_master_boundary_ids.end())
  // {
  //   Real dtemp_func_master = 4 * _phi[_j][_qp]*_u[_qp]*_u[_qp]*_u[_qp];
  //   dq_net = _stefan_boltzmann * dtemp_func_master;   //black body
  // }
  // return _test[_i][_qp] * dq_net;
  return 0;
}
