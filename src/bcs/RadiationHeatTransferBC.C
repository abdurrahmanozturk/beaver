#include "RadiationHeatTransferBC.h"
#include "PenetrationLocator.h"

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
  params.addParam<std::vector<Real>>("emissivity","The emissivities of boundaries (sort by ids).");
  return params;
}

RadiationHeatTransferBC::RadiationHeatTransferBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _var_number(_subproblem.getVariable(_tid,
                                 parameters.get<NonlinearVariableName>("variable"),
                                 Moose::VarKindType::VAR_ANY,
                                 Moose::VarFieldType::VAR_FIELD_STANDARD).number()),
    _system(_subproblem.getSystem(getParam<NonlinearVariableName>("variable"))),
    _vf(getUserObject<ViewFactor>("viewfactor_userobject")),
    _boundary_ids(boundaryIDs()),
    _master_boundary_ids(_vf.getMasterBoundaries()),
    _slave_boundary_ids(_vf.getSlaveBoundaries()),
    _stefan_boltzmann(getParam<Real>("stefan_boltzmann"))
{
  std::vector<Real> emissivity = getParam<std::vector<Real>>("emissivity");
  // if (emissivity.size()!=_boundary_ids.size())
  //   mooseError("The number of emissivities does not match the number of boundaries.");
  unsigned int i{0};
  for (const auto bid : _boundary_ids)
    _emissivity[bid] = 1; // emissivity[i++];   //change this for non-black radiation surfaces

  for (const auto & t : _mesh.buildSideList())    //buildSideList(el,side,bnd)
  {
    auto elem_id = std::get<0>(t);
    auto side_id = std::get<1>(t);
    auto bnd_id = std::get<2>(t);
    // if (_slave_boundary_ids.find(bnd_id)!=_slave_boundary_ids.end())
    if (_boundary_ids.find(bnd_id)!=_boundary_ids.end())
      _elem_side_map[elem_id]=side_id;
  }
}

const std::map<unsigned int, std::vector<Real>>
RadiationHeatTransferBC::getSideMap(const Elem * elem,const unsigned int side)
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
  return side_map;
}

const Real
RadiationHeatTransferBC::getArea(const Elem * elem,const unsigned int side)
{
  std::map<unsigned int, std::vector<Real>> side_map{getSideMap(elem,side)};
  const std::vector<Real> side_center = _vf.getCenterPoint(side_map);
  Real area = _vf.getArea(side_center,side_map);
  // std::cout<<"BC::area ="<<area<<std::endl;
  return area;
}

Real
RadiationHeatTransferBC::computeQpResidual()
{
  Real _u_slave, q_ms, q_sm, q_net{0};
  Real temp_func_master = _u[_qp] * _u[_qp] * _u[_qp] * _u[_qp];
  // q_net = _stefan_boltzmann * temp_func_master; // black body
  BoundaryID current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  // if (_master_boundary_ids.find(current_boundary_id)!=_master_boundary_ids.end())
  if (_boundary_ids.find(current_boundary_id)!=_boundary_ids.end())
  {
    _master_elem_id = _current_elem->id();
    Real area_master = getArea(_current_elem,_current_side);
    // std::cout<<"q_net:"<<q_net<<std::endl;
    // std::cout<<"Master:"<<_master_elem_id<<std::endl;
    // std::cout<<"qp "<<_qp<<std::endl;
    // std::cout<<"master_temp ="<<_u[_qp]<<std::endl;
    // std::cout<<"qpoint "<<_q_point[_qp]<<std::endl;
    for (const auto & elem : _elem_side_map)
    {
      Elem * el = _mesh.elemPtr(elem.first);
      unsigned int side = elem.second;
      BoundaryID bnd_id = _mesh.getBoundaryIDs(el,side)[0];
      // std::cout<<current_boundary_id<<"->"<<bnd_id<<std::endl;
      _slave_elem_id = el->id();   //elem.first
      if (_master_elem_id == _slave_elem_id)
        continue;
      Real area_slave = getArea(el,side);
      std::map<unsigned int, std::vector<Real>> side_map{getSideMap(el,side)};
      const std::vector<Real> center = _vf.getCenterPoint(side_map);
      const Point point(center[0],center[1],center[2]);
      _u_slave = _system.point_value(_var_number, point, false);
      // std::cout<<_u_slave<<std::endl;
      Real temp_func_slave = _u_slave * _u_slave * _u_slave * _u_slave;
      // const unsigned int Dim = el->dim();
      // const std::vector<std::vector<OutputShape>> & phi = my_fe->get_phi();
      // T_slave = _variable->getValue(el, slave_side_phi);
      Real f_ms = _vf.getViewFactor(current_boundary_id,_master_elem_id, bnd_id, _slave_elem_id);
      if (f_ms!=0)
      {
        // std::cout<<"F["<<_master_elem_id<<"]["<<_slave_elem_id<<"] = "<<f_ms<<std::endl;
      }
      // Real f_sm = f_ms * (area_master / area_slave);    //use reciprocity
      Real f_sm = _vf.getViewFactor(bnd_id, _slave_elem_id,current_boundary_id,_master_elem_id);
      q_ms = _emissivity[current_boundary_id] * _stefan_boltzmann * f_ms * temp_func_master; // master-slave
      q_sm = _emissivity[bnd_id] * _stefan_boltzmann * f_sm * temp_func_slave;  // slave-master
      q_net += q_ms - q_sm;
      // std::cout<<"q= "<<q_net<<std::endl;

      // FIND THE SOLUTION AT SLAVE QUADRATURE POINT

      // ADD emissivity values for master and slave Boundaries

      // Node * qnode = _mesh.getQuadratureNode(el, side_id, _qp);
      // _value = _system.point_value(_var_number, _slave_center, false);

      // std::cout<<"Slave:"<<std::endl;
      // std::cout<<"qp "<<_qp<<std::endl;
      // std::cout<<"temp ="<<_value<<std::endl;
      // std::cout<<"qpoint "<<qnode<<std::endl;
      // calculate net heat flux between master element and salve element
    }
  }
  return _test[_i][_qp] * q_net;
}

Real
RadiationHeatTransferBC::computeQpJacobian()
{
  Real dq_net{0.0};
  BoundaryID current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  // if (_master_boundary_ids.find(current_boundary_id) != _master_boundary_ids.end())
  if (_boundary_ids.find(current_boundary_id)!=_boundary_ids.end())
  {
    Real dtemp_func_master = 4 * _phi[_j][_qp] * _u[_qp] * _u[_qp] * _u[_qp];
    dq_net = _stefan_boltzmann * dtemp_func_master; // black body
  }
  return _test[_i][_qp] * dq_net;
  return 0;
}
