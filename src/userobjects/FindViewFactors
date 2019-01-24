#include "FindViewFactors.h"

template <>
InputParameters
validParams<FindViewFactors>()
{
  InputParameters params = validParams<SideUserObject>();
  params.addCoupledVar("nodal_normal_x", "x component of normal");
  params.addCoupledVar("nodal_normal_y", "y component of normal");
  params.addCoupledVar("nodal_normal_z", "z component of normal");
  // params.addRequiredParam<std::vector<BoundaryName>>("master_boundary", "Master Boundary ID");
  // params.addRequiredParam<std::vector<BoundaryName>>("slave_boundary", "Slave Boundary ID");
  return params;
}

FindViewFactors::FindViewFactors(const InputParameters & parameters)
  : SideUserObject(parameters),
    _nodal_normal_x(isParamValid("nodal_normal_x") ? coupledValue("nodal_normal_x") : _zero),
    _nodal_normal_y(isParamValid("nodal_normal_y") ? coupledValue("nodal_normal_y") : _zero),
    _nodal_normal_z(isParamValid("nodal_normal_z") ? coupledValue("nodal_normal_z") : _zero)
{
}

void
FindViewFactors::initialize()
{
  std::srand(time(NULL));
  // const std::vector<BoundaryName> boundary_names = {"master_boundary", "slave_boundary"};
  // Data structures to hold the element boundary information
  std::vector<dof_id_type> elem_list;
  std::vector<unsigned short int> side_list;
  std::vector<boundary_id_type> id_list;

  // Retrieve the Element Boundary data structures from the mesh
  _mesh.buildSideList(elem_list, side_list, id_list);
  std::cout << "-----------side list#: " << id_list.size() << std::endl;
  std::cout << "-----------side list#: " << elem_list.size() << std::endl;
  std::cout << "-----------side list#: " << side_list.size() << std::endl;
  std::cout << "-----------side list#: " << id_list[0] << std::endl;
  std::cout << "-----------side list#: " << id_list[1] << std::endl;
  std::cout << "-----------side list#: " << id_list[2] << std::endl;
  std::cout << "-----------side list#: " << id_list[1] << std::endl;
  std::cout << "-----------side list#: " << id_list[2] << std::endl;
  std::cout << "-----------side list#: " << id_list[3] << std::endl;
  std::cout << "-----------side list#: " << id_list[4] << std::endl;
}
void
FindViewFactors::execute()
{

  // std::vector<BoundaryID> boundary_ids = _mesh_ptr->getBoundaryIDs(_boundary_names, true);

  //////
  // buildBndElemList();
  // BoundaryID current_boundary_id = _mesh.getBoundaryIDs(boundary_names[0]);
  /////

  // for (auto it = _mesh->bndElemsBegin(); it != _mesh->bndElemsEnd(); ++it)
  //   {
  //     std::cout << "-----------boundary id #: " <<(mesh_boundary_ids.count((*it)->_bnd_id))<<
  //     std::endl; BoundaryID current_boundary_id = mesh_boundary_ids.count((*it)->_bnd_id)
  //   }

  // current_boundary_id = master_boundary   // ASK ABOUT THIS

  // LOOPING OVER ELEMENTS ON THE MASTER BOUNDARY
  std::cout << "-----------side #: " << (_current_side) << std::endl;
  std::cout << "-----------elem #: " << (_current_elem->id()) << std::endl;
  unsigned int n = _current_side_elem->n_nodes();
  for (unsigned int i = 0; i < n; i++)
  {
    const Node * node = _current_side_elem->node_ptr(i);
    Real x_coord = (*node)(0);
    Real y_coord = (*node)(1);
    Real z_coord = (*node)(2);

    std::cout << "-----------node #: " << i << std::endl;
    // Nodal Coordinates
    std::cout << "x: " << x_coord << std::endl;
    std::cout << "y: " << y_coord << std::endl;
    std::cout << "z: " << z_coord << std::endl;
    // Nodal Normal Components
    std::cout << "n_x: " << (_normals[i](0)) << std::endl;
    std::cout << "n_y: " << (_normals[i](1)) << std::endl;
    std::cout << "n_z: " << (_normals[i](2)) << std::endl;
  }

  //  FINDING THE SOURCE POINT ON ELEMENT SURFACE AND SAMPLE DIRECTION
  //Random Source Point
  const Node * node0 = _current_side_elem->node_ptr(0);
  const Node * node1 = _current_side_elem->node_ptr(1);
  const Node * noden = _current_side_elem->node_ptr(3);
  unsigned int nsrc = 1;
  for (unsigned int i = 0; i < nsrc; i++)
  {
    rand_x = std::rand() / (1. * RAND_MAX);
    rand_y = std::rand() / (1. * RAND_MAX);
    rand_z = std::rand() / (1. * RAND_MAX);
    px1 = rand_x * ((*node1)(0) - (*node0)(0));
    py1 = rand_y * ((*node1)(1) - (*node0)(1));
    pz1 = rand_z * ((*node1)(2) - (*node0)(2));
    rand_x = std::rand() / (1. * RAND_MAX);
    rand_y = std::rand() / (1. * RAND_MAX);
    rand_z = std::rand() / (1. * RAND_MAX);
    px2 = rand_x * ((*noden)(0) - (*node0)(0));
    py2 = rand_y * ((*noden)(1) - (*node0)(1));
    pz2 = rand_z * ((*noden)(2) - (*node0)(2));
    px = (*node0)(0) + px1 + px2; // DONT DO THIS find surface equation plane equation
    py = (*node0)(1) + py1 + py2;
    pz = (*node0)(2) + pz1 + pz2;
    std::vector<double> src_pt;
    src_pt.push_back(px);
    src_pt.push_back(py);
    src_pt.push_back(pz);
    // std::cout << "source_point_x: " <<px<< std::endl;
    // std::cout << "source_point_y: " <<py<< std::endl;
    // std::cout << "source_point_z: " <<pz<< std::endl;
    std::cout << src_pt[0] << std::endl;
    std::cout << src_pt[1] << std::endl;
    std::cout << src_pt[2] << std::endl;

    //Sample Direction
    const double rand_theta = std::rand() / (1. * RAND_MAX);
    const double rand_phi = std::rand() / (1. * RAND_MAX);
    const double piv = 3.141592653589793238462643383279502884;
    const double theta = acos(1-2*rand_theta);
    const double phi = 2*piv*rand_phi;
    std::cout << theta << std::endl;
    std::cout << phi << std::endl;


    // *********LOOP OVER ELEMENTS ON THE SLAVE BOUNDARY

    for (auto it = _mesh.bndElemsBegin(); it != _mesh.bndElemsEnd(); ++it)
    {
      // // std::cout << "current boundary id #: " <<(current_boundary_id)<< std::endl;
      // std::cout << "-----------boundary id #: " <<((*it)->_bnd_id )<< std::endl;
      // // BoundaryID current_boundary_id = (*it)->_bnd_id )
      //
      // // FIND BOUNDARY CORNER NODE COORDINATES AND CALCULATE DISTANCE TO SOURCE POINT
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
//   // return _nodal_normal_x[_qp];
//   return (_normals[0](0));
// }
// Real
// FindViewFactors::spatialValue(const Point & p) const
// {
// return _nodal_normal_x[_qp];
// return _(*node)(0);
// }
