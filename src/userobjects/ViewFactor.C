#include "ViewFactor.h"

template <>
InputParameters
validParams<ViewFactor>()
{
  InputParameters params = validParams<SideUserObject>();
  params.addCoupledVar("nodal_normal_x", "x component of normal");
  params.addCoupledVar("nodal_normal_y", "y component of normal");
  params.addCoupledVar("nodal_normal_z", "z component of normal");
  // params.addRequiredParam<std::vector<BoundaryName>>("master_boundary", "Master Boundary ID");
  // params.addRequiredParam<std::vector<BoundaryName>>("slave_boundary", "Slave Boundary ID");
  return params;
}

ViewFactor::ViewFactor(const InputParameters & parameters)
  : SideUserObject(parameters),
    _nodal_normal_x(isParamValid("nodal_normal_x") ? coupledValue("nodal_normal_x") : _zero),
    _nodal_normal_y(isParamValid("nodal_normal_y") ? coupledValue("nodal_normal_y") : _zero),
    _nodal_normal_z(isParamValid("nodal_normal_z") ? coupledValue("nodal_normal_z") : _zero)
{
}

void
ViewFactor::initialize()
{
  std::srand(time(NULL));
  // const std::vector<BoundaryName> boundary_names = {"master_boundary", "slave_boundary"};
  // Data structures to hold the element boundary information
  std::vector<dof_id_type> elem_list;
  std::vector<unsigned short int> side_list;
  std::vector<boundary_id_type> id_list;

  // Retrieve the Element Boundary data structures from the mesh
  _mesh.buildSideList(elem_list, side_list, id_list);
  // std::cout << "-----------side list#: " << id_list.size() << std::endl;
  // std::cout << "-----------side list#: " << elem_list.size() << std::endl;
  // std::cout << "-----------side list#: " << side_list.size() << std::endl;
  // std::cout << "-----------side list#: " << id_list[0] << std::endl;
  // std::cout << "-----------side list#: " << id_list[1] << std::endl;
  // std::cout << "-----------side list#: " << id_list[2] << std::endl;
  // std::cout << "-----------side list#: " << id_list[3] << std::endl;
  // std::cout << "-----------side list#: " << id_list[4] << std::endl;
  // std::cout << "-----------side list#: " << id_list[5] << std::endl;
  // std::cout << "-----------side list#: " << id_list[6] << std::endl;
}
void
ViewFactor::execute()
{
  // LOOPING OVER ELEMENTS ON THE MASTER BOUNDARY
  // std::cout << "-----------side #: " << (_current_side) << std::endl;
  // std::cout << "-----------elem #: " << (_current_elem->id()) << std::endl;
  unsigned int j=(_current_elem->id());
  unsigned int n = _current_side_elem->n_nodes();
  double coords_array[3*n+2][j];
  double normals_array[3*n+2][j];
  for (unsigned int i = 0; i < n; i++)
  {
    const Node * node = _current_side_elem->node_ptr(i);
    Real x_coord = (*node)(0);
    Real y_coord = (*node)(1);
    Real z_coord = (*node)(2);
    Real x_normal = (_normals[i](0));
    Real y_normal = (_normals[i](1));
    Real z_normal = (_normals[i](2));
    coords_array[3*i][j]=x_coord;
    coords_array[3*i+1][j]=y_coord;
    coords_array[3*i+3][j]=z_coord;
    normals_array[3*i][j]=x_normal;
    normals_array[3*i+1][j]=y_normal;
    normals_array[3*i+2][j]=z_normal;
    // std::cout << "-----------node #: " << i << std::endl;
  }
  // Nodal Coordinates
  std::cout << "x: " << coords_array[0][0] << std::endl;
  std::cout << "x: " << coords_array[0][1] << std::endl;
  std::cout << "x: " << coords_array[0][2] << std::endl;
  // Nodal Normal Components
  std::cout << "n_x: " << normals_array[0][0] << std::endl;
  std::cout << "n_x: " << normals_array[0][1] << std::endl;
  std::cout << "n_x: " << normals_array[0][2] << std::endl;
}
void
ViewFactor::finalize()
{

  // //  FINDING THE SOURCE POINT ON ELEMENT SURFACE AND SAMPLE DIRECTION
  // //Random Source Point
  // const Node * node0 = _current_side_elem->node_ptr(0);
  // const Node * node1 = _current_side_elem->node_ptr(1);
  // const Node * noden = _current_side_elem->node_ptr(3);
  // unsigned int nsrc = 1;
  // for (unsigned int i = 0; i < nsrc; i++)
  // {
  //   rand_x = std::rand() / (1. * RAND_MAX);
  //   rand_y = std::rand() / (1. * RAND_MAX);
  //   rand_z = std::rand() / (1. * RAND_MAX);
  //   px1 = rand_x * ((*node1)(0) - (*node0)(0));
  //   py1 = rand_y * ((*node1)(1) - (*node0)(1));
  //   pz1 = rand_z * ((*node1)(2) - (*node0)(2));
  //   rand_x = std::rand() / (1. * RAND_MAX);
  //   rand_y = std::rand() / (1. * RAND_MAX);
  //   rand_z = std::rand() / (1. * RAND_MAX);
  //   px2 = rand_x * ((*noden)(0) - (*node0)(0));
  //   py2 = rand_y * ((*noden)(1) - (*node0)(1));
  //   pz2 = rand_z * ((*noden)(2) - (*node0)(2));
  //   px = (*node0)(0) + px1 + px2; // DONT DO THIS find surface equation plane equation
  //   py = (*node0)(1) + py1 + py2;
  //   pz = (*node0)(2) + pz1 + pz2;
  //   std::vector<double> src_pt;
  //   src_pt.push_back(px);
  //   src_pt.push_back(py);
  //   src_pt.push_back(pz);
  //   // std::cout << "source_point_x: " <<px<< std::endl;
  //   // std::cout << "source_point_y: " <<py<< std::endl;
  //   // std::cout << "source_point_z: " <<pz<< std::endl;
  //   std::cout << src_pt[0] << std::endl;
  //   std::cout << src_pt[1] << std::endl;
  //   std::cout << src_pt[2] << std::endl;
  //
  //   //Sample Direction
  //   const double rand_theta = std::rand() / (1. * RAND_MAX);
  //   const double rand_phi = std::rand() / (1. * RAND_MAX);
  //   const double piv = 3.141592653589793238462643383279502884;
  //   const double theta = acos(1-2*rand_theta);
  //   const double phi = 2*piv*rand_phi;
  //   std::cout << theta << std::endl;
  //   std::cout << phi << std::endl;
  //
  // }
}
