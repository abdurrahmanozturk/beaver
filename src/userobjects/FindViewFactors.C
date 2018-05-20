#include "FindViewFactors.h"
// #include "SubProblem.h"
// #include "MooseMesh.h"
// #include "Assembly.h"
//
// // libMesh includes
// #include "libmesh/mesh_tools.h"
// #include "libmesh/string_to_enum.h"
// #include "libmesh/quadrature.h"

template <>
InputParameters
validParams<FindViewFactors>()
{
  InputParameters params = validParams<SideUserObject>();
  params.addCoupledVar("nodal_normal_x", "x component of normal");
  params.addCoupledVar("nodal_normal_y", "y component of normal");
  params.addCoupledVar("nodal_normal_z", "z component of normal");
  params.addRequiredParam<std::vector<BoundaryName>>("master_boundary", "Master Boundary ID");
  params.addRequiredParam<std::vector<BoundaryName>>("slave_boundary", "Slave Boundary ID");
  return params;
}

FindViewFactors::FindViewFactors(const InputParameters & parameters) : SideUserObject(parameters),
_nodal_normal_x(isParamValid("nodal_normal_x")? coupledValue("nodal_normal_x"):_zero),
_nodal_normal_y(isParamValid("nodal_normal_y")? coupledValue("nodal_normal_y"):_zero),
_nodal_normal_z(isParamValid("nodal_normal_z")? coupledValue("nodal_normal_z"):_zero)
{

}

void FindViewFactors::initialize()
{
    std::srand(time(NULL));
    const std::vector<BoundaryName> boundary_names = {"master_boundary", "slave_boundary"};
}
void
FindViewFactors::execute()
{

//////////
// // buildBndElemList();
// // BoundaryID current_boundary_id = getBoundaryID(boundary_names[i]);
// BoundaryID current_boundary_id = slave_boundary;
// //
// for (auto it = bndElemsBegin(); it != bndElemsEnd(); ++it)
//   if ((*it)->_bnd_id == current_boundary_id)
//   {
//     Elem * elem = (*it)->_elem;
//     auto s = (*it)->_side;
//   }
//////////


  // *********LOOP OVER ELEMENTS ON THE MASTER BOUNDARY AND FIND SOURCE POINTS
  std::cout << "-----------elem #: " <<(_current_elem->id())<< std::endl;
  unsigned int n = _current_side_elem->n_nodes();
  for (unsigned int i = 0; i < n; i++)
  {
      const Node * node = _current_side_elem->node_ptr(i);
      Real x_coord = (*node)(0);
      Real y_coord = (*node)(1);
      Real z_coord = (*node)(2);
      // Real n_x = _normals[0](0);
      // Real n_y = _normals[0](1);
      // Real n_z = _normals[0](2);
      std::cout << "-----------node #: " <<i<< std::endl;
      std::cout << "x: " <<x_coord<< std::endl;
      std::cout << "y: " <<y_coord<< std::endl;
      std::cout << "z: " <<z_coord<< std::endl;
      // const std::vector<Point> & _node_coordinates = fe->get_xyz();
      // _node_coordinates[i] = (x_coord, y_coord, z_coord);
      // _node_coordinates[i] = y_coord;
      // _node_coordinates[i] = z_coord;
      std::cout << "n_x: " <<(_normals[i](0))<< std::endl;
      std::cout << "n_y: " <<(_normals[i](1))<< std::endl;
      std::cout << "n_z: " <<(_normals[i](2))<< std::endl;
  }
  const Node * node0 = _current_side_elem->node_ptr(0);
  const Node * node1 = _current_side_elem->node_ptr(1);
  const Node * noden = _current_side_elem->node_ptr(3);
  for (unsigned int i = 0; i < 1; i++)
  {
    rand_x = std::rand()/(1.*RAND_MAX);
    rand_y = std::rand()/(1.*RAND_MAX);
    rand_z = std::rand()/(1.*RAND_MAX);
    px1 = rand_x*((*node1)(0)-(*node0)(0));
    py1 = rand_y*((*node1)(1)-(*node0)(1));
    pz1 = rand_z*((*node1)(2)-(*node0)(2));
    rand_x = std::rand()/(1.*RAND_MAX);
    rand_y = std::rand()/(1.*RAND_MAX);
    rand_z = std::rand()/(1.*RAND_MAX);
    px2 = rand_x*((*noden)(0)-(*node0)(0));
    py2 = rand_y*((*noden)(1)-(*node0)(1));
    pz2 = rand_z*((*noden)(2)-(*node0)(2));
    px = (*node0)(0)+px1+px2; // DON DO THIS find surface equation plane equation
    py = (*node0)(1)+py1+py2;
    pz = (*node0)(2)+pz1+pz2;
    p = (px,py,pz);
    // std::cout << "source_point_x: " <<px<< std::endl;
    // std::cout << "source_point_y: " <<py<< std::endl;
    // std::cout << "source_point_z: " <<pz<< std::endl;
    std::cout <<px<< std::endl;
    std::cout <<py<< std::endl;
    std::cout <<pz<< std::endl;
    // *********LOOP OVER ELEMENTS ON THE SLAVE BOUNDARY
    // _boundary_names = getParam<std::vector<BoundaryName>>("slave_boundary");
    // std::vector<BoundaryID> boundary_ids = _mesh_ptr->getBoundaryIDs(_boundary_names, true);
    MeshBase::const_element_iterator       el     = _mesh.getMesh().active_local_elements_begin();
    const MeshBase::const_element_iterator end_el = _mesh.getMesh().active_local_elements_end();
    for ( ; el != end_el ; ++el)
    {
      const Elem * elem = *el;
      std::cout << "-----------elem #: " <<(_current_elem->id())<< std::endl;
    }
  }
// }
//   Node * _node_ptr = _mesh.getMesh().query_node_ptr(_qp);
//
//   // remember this! to get nodal coordinate
//   const Point & p = * _node_ptr;
//   Real n_x = p(0);
//   Real n_y = p(1);
//   std::cout << "x: " << n_x << std::endl;
  // std::cout << "Normal x: " << _nodal_normal_x[_qp] << std::endl;
  // std::cout << "Normal y: " << _nodal_normal_y[_qp] << std::endl;
  // std::cout << "Normal z: " << _nodal_normal_z[_qp] << std::endl;
}
//
// Real
// FindViewFactors::getValue()
// {
//   // return _subproblem.mesh().nNodes();
//   //return _nodal_normal_x[_qp];
//   return (_normals[0](0));
// }
// Real
// FindViewFactors::spatialValue(const Point & p) const
// {
  // return _nodal_normal_x[_qp];
  // return _(*node)(0);
// }
