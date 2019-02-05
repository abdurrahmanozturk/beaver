#include "RadiationHeatTransfer.h"

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
  // _temp(coupledValue("variable")),
  _viewfactor(getUserObject<ViewFactor>("viewfactor_userobject"))
{
}

Real
RadiationHeatTransfer::computeQpResidual()
{
  // Calculate Radiation heat transfer between element pairs
  Real f12 =_viewfactor.getViewFactor(1,2);//(_current_elem->id(),_current_elem->id());
  // //loop over all elements in mesh,
  // // first retrieve the side list form the mesh and loop over all element sides
  // for (const auto & t : _mesh.buildSideList())    //buildSideList(el,side,bnd)
  // {
  //   auto elem_id = std::get<0>(t);
  //   auto side_id = std::get<1>(t);
  //   auto bnd_id = std::get<2>(t);
  //   // std::cout << "------------bnd#: " << bc_id << std::endl;
  //   // std::cout << "-----------elem#: " << elem_id << std::endl;
  //   // std::cout << "-----------side#: " << side_id << std::endl;
  //   Elem * el = _mesh.elemPtr(elem_id);
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
  //
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
