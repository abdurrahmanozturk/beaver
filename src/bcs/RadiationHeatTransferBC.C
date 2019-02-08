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
  params.addParam<Real>("stefan_boltzmann", 5.670367e-8, "The Stefan-Boltzmann constant [kg.s^3.K^4]");

  return params;
}

RadiationHeatTransferBC::RadiationHeatTransferBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
  _viewfactor(getUserObject<ViewFactor>("viewfactor_userobject")),
  _master_boundary_ids(_viewfactor.getMasterBoundaries()),
  _slave_boundary_ids(_viewfactor.getSlaveBoundaries()),
  _stefan_boltzmann(getParam<Real>("stefan_boltzmann"))
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

Real
RadiationHeatTransferBC::computeQpResidual()
{
  _current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  if (_master_boundary_ids.find(_current_boundary_id)!=_master_boundary_ids.end())
  {
    _master_elem_id = _current_elem->id();
    Real area_master = getArea(_current_elem,_current_side);
    Real flux_master = _stefan_boltzmann * _u[_qp]*_u[_qp]*_u[_qp]*_u[_qp];
    std::cout<<"Master:"<<_qp<<std::endl;
    std::cout<<"qp "<<_qp<<std::endl;
    std::cout<<"temp ="<<_u[_qp]<<std::endl;
    std::cout<<"qpoint "<<_q_point[_qp]<<std::endl;
    for (const auto & t : _mesh.buildSideList())    //buildSideList(el,side,bnd)
    {
      auto elem_id = std::get<0>(t);
      auto side_id = std::get<1>(t);
      auto bnd_id = std::get<2>(t);
      if (_slave_boundary_ids.find(bnd_id)!=_slave_boundary_ids.end())
      {
        Elem * el = _mesh.elemPtr(elem_id);
        _slave_elem_id = el->id();
        Real f_ms =_viewfactor.getViewFactor(_master_elem_id,_slave_elem_id);
        std::cout<<"F["<<_master_elem_id<<"]["<<_slave_elem_id<<"] = "<<f_ms<<std::endl;
        Real area_slave = getArea(el,side_id);

        // FIND THE SOLUTION AT SLAVE QUADRATURE POINT
        Node * qnode = _mesh.getQuadratureNode(_current_elem, _current_side, _qp);

        std::cout<<"Slave:"<<_qp<<std::endl;
        std::cout<<"qp "<<_qp<<std::endl;
        std::cout<<"temp ="<<_u[_qp]<<std::endl;
        std::cout<<"qpoint "<<_q_point[_qp]<<std::endl;
        // calculate emissive power from element1 to element2 q12
      }
    }
  }

  return 0;
}

Real
RadiationHeatTransferBC::computeQpJacobian()
{
  return 0;
}
