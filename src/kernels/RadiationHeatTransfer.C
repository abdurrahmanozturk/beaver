#include "RadiationHeatTransfer.h"
#include "Assembly.h"

// registerMooseObject("BeaverApp", RadiationHeatTransfer);

template <>
InputParameters
validParams<RadiationHeatTransfer>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Radiation Heat Transfer Model with view factors.");
  // params.addRequiredCoupledVar("variable", "Temperature variable");
  params.addRequiredParam<UserObjectName>("viewfactor_userobject",
      "The name of the UserObject that is used for view factor calculations.");
  return params;
}

RadiationHeatTransfer::RadiationHeatTransfer(const InputParameters & parameters)
  : Kernel(parameters),
    _viewfactor(getUserObject<ViewFactor>("viewfactor_userobject")),
    _master_boundary_ids(_viewfactor.getMasterBoundaries()),
    _slave_boundary_ids(_viewfactor.getSlaveBoundaries()),
    _current_side(_assembly.side()),
    _current_neighbor_side(_assembly.neighborSide()),
    _current_node(_assembly.node())
{
}

Real
RadiationHeatTransfer::computeQpResidual()
{
  // std::cout<<"current elem id= "<<_current_elem->id()<<std::endl;
  // auto _current_side_elem = _current_elem->build_side_ptr(0);
  // const Node * node = _current_side_elem->node_ptr(0);
  // std::cout<<"current node id= "<<(*node)(0)<<std::endl;
  // Calculate Radiation heat transfer between element pairs
  //loop over all elements in mesh,
  // first retrieve the side list form the mesh and loop over all element sides
  std::cout << "current elem id= " << _current_elem->id() << std::endl;
  std::cout << "current side id= " << _current_side << std::endl;
  std::cout << "current neighbor side id= " << _current_neighbor_side << std::endl;
  BoundaryID _current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  std::cout << "current boundary id= " << _current_boundary_id << std::endl;
  _master_elem_id = _current_elem->id();
  // if (_master_boundary_ids.find(_current_boundary_id)!=_master_boundary_ids.end())
  // {
  //   for (const auto & t : _mesh.buildSideList())    //buildSideList(el,side,bnd)
  //   {
  //     auto elem_id = std::get<0>(t);
  //     auto side_id = std::get<1>(t);
  //     auto bnd_id = std::get<2>(t);
  //     // std::cout << "------------bnd#: " << bc_id << std::endl;
  //     // std::cout << "-----------elem#: " << elem_id << std::endl;
  //     // std::cout << "-----------side#: " << side_id << std::endl;
  //     if (_slave_boundary_ids.find(bnd_id)!=_slave_boundary_ids.end())
  //     {
  //       Elem * el = _mesh.elemPtr(elem_id);
  //       _slave_elem_id = el->id();
  //       Real f12 =_viewfactor.getViewFactor(_master_elem_id,_slave_elem_id);
  //       if (f12!=0.0)
  //       {
  //         // std::cout <<"Node #"<<" : ("<<(*_current_node)(0)<<","<<(*_current_node)(1)<<","<<(*_current_node)(2)<<")"<<std::endl;
  //         // for (unsigned int j = 0; j < 3; j++)         // Define nodal coordinates and normals
  //         // {
  //         //   // side_map[i].push_back((*node)(j));
  //         // std::cout <<"quadrature point #"<<_qp<<" : ("<<_q_point[_qp]<<"\t";
  //         // }
  //         std::cout<<"F["<<_master_elem_id<<"]["<<_slave_elem_id<<"] = "<<f12<<std::endl;
  //       }
  //     }
  //   }
  // }
  // std::cout <<"next #"<<std::endl;
  //   std::unique_ptr<const Elem> el_side = el->build_side_ptr(side_id);
  //   std::map<unsigned int, std::vector<Real>> side_map;
  //   unsigned int n_n = el_side->n_nodes();
  //   for (unsigned int i = 0; i < n_n; i++)
  //   {
  //     const Node * node = el_side->node_ptr(i);    //get nodes
  //     for (unsigned int j = 0; j < 3; j++)         // Define nodal coordinates and normals
  //     {
  //       side_map[i].push_back((*node)(j));
  //     }
  //     // std::cout <<"Node #"<<i<<" : ("<<(*n_ptr)(0)<<","<<(*n_ptr)(1)<<","<<(*n_ptr)(2)<<")\t";
  //   }
  // }
  // for (auto mas : _master_boundary_ids )
  // {
  //   std::cout<<"master= "<<mas<<std::endl;
  // }
  // for (auto sla : _slave_boundary_ids)
  // {
  //   std::cout<<"slave= "<<sla<<std::endl;
  // }
  // Real f12 =_viewfactor.getViewFactor(_current_elem->id(),_current_elem->id());
  // std::cout<<"viewfactor = "<<f12<<std::endl;
  //   if (_emissivity == 0.0)
  //     return 0.0;
  //
  //   const Real temp_func =
  //       (_temp[_qp] * _temp[_qp] + _gap_temp * _gap_temp) * (_temp[_qp] + _gap_temp);
  //   return _stefan_boltzmann * temp_func / _emissivity;
  return 0;
}

Real
RadiationHeatTransfer::computeQpJacobian()
{
  return 0;
}
