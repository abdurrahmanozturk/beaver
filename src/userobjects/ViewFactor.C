#include <vector>
#include "ViewFactor.h"
#include "libmesh/boundary_info.h"
// libMesh includes
#include "libmesh/mesh_generation.h"
#include "libmesh/mesh.h"
#include "libmesh/string_to_enum.h"
#include "libmesh/quadrature_gauss.h"
#include "libmesh/point_locator_base.h"

template <>
InputParameters
validParams<ViewFactor>()
{
  InputParameters params = validParams<SideUserObject>();
  // params.addCoupledVar("nodal_normal_x", "x component of normal");
  // params.addCoupledVar("nodal_normal_y", "y component of normal");
  // params.addCoupledVar("nodal_normal_z", "z component of normal");
  // params.addRequiredParam<std::vector<BoundaryName>>("master_boundary", "Master Boundary ID");
  // params.addRequiredParam<std::vector<BoundaryName>>("slave_boundary", "Slave Boundary ID");
  return params;
}

ViewFactor::ViewFactor(const InputParameters & parameters)
  : SideUserObject(parameters),
    _current_normals(_assembly.normals()),
    _boundary_ids(boundaryIDs()),
    _boundary_list(getParam<std::vector<BoundaryName> >("boundary"))
    // m_coord_index(0)
    // _nodal_normal_x(isParamValid("nodal_normal_x") ? coupledValue("nodal_normal_x") : _zero),
    // _nodal_normal_y(isParamValid("nodal_normal_y") ? coupledValue("nodal_normal_y") : _zero),
    // _nodal_normal_z(isParamValid("nodal_normal_z") ? coupledValue("nodal_normal_z") : _zero)
{
}
//
// std::vector<double> ViewFactor::x_coords;
// std::vector<double> ViewFactor::y_coords;
// std::vector<double> ViewFactor::z_coords;

void
ViewFactor::initialize()
{
  std::srand(time(NULL));
  std::cout << "-------boundary_ids #: " << _boundary_ids.size() << std::endl;
  // std::vector<std::vector<double>> coords_array[1][1];
  // std::vector<std::vector<double>> normals_array[1][1];
  // double coords_array[3*n+2][j];
  // double normals_array[3*n+2][j];
}
void
ViewFactor::execute()
{
  // LOOPING OVER ELEMENTS ON THE MASTER BOUNDARY
  BoundaryID current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  const auto current_boundary_name = _mesh.getBoundaryName(current_boundary_id);
  unsigned int current_element_id=(_current_elem->id());    // const Elem *& _current_elem
  //const Elem * elem = _current_side_elem;
  _element_set[current_boundary_id][current_element_id] = _current_elem;
  std::cout<<_element_set[current_boundary_id][current_element_id]->id()<<std::endl; //test
  // unsigned int _current_surface_index{0};
  std::cout << "--------------------------------------------------------------------------"<< std::endl;
  std::cout << "-------boundary #: " << current_boundary_id << " : "<<current_boundary_name<< std::endl;
  std::cout << "-----------elem #: " << (_current_elem->id()) << std::endl;
  std::cout << "-----------side #: " << (_current_side) << std::endl;
  unsigned int n = _current_side_elem->n_nodes();
  for (unsigned int i = 0; i < n; i++)
  {
    const Node * node = _element_set[current_boundary_id][current_element_id]->node_ptr(i);    //get nodes
    // const Node * node1 = _current_side_elem->node_ptr(i);    //get nodes
    Point normal = _normals[i];                             //get nodal normals
    // _node_coordinates[current_boundary_id][current_element_id][_current_side][i]=node;
    // _node_normals[current_boundary_id][current_element_id][_current_side][i]=normal;
    _node_coordinates[current_boundary_id][current_element_id][i]=node;
    _node_normals[current_boundary_id][current_element_id][i]=normal;
    std::cout <<"Node #"<<i<<" : ("<<(*node)(0)<<","<<(*node)(1)<<","<<(*node)(2)<<")\t";
    std::cout <<" Normal : ("<<(normal)(0)<<","<<(normal)(1)<<","<<(normal)(2)<<")"<< std::endl;
  }
}
void
ViewFactor::finalize()
{
  for (auto master_bid : _boundary_ids)
  {
    const auto master_elem = _element_set[master_bid];
    for (auto slave_bid : _boundary_ids)
    {
      const auto slave_elem = _element_set[slave_bid];
      std::cout <<"bnd :"<<master_bid<< " -> "<<slave_bid<<std::endl;
      std::cout <<"-------------------------------------------------"<<std::endl;
      for (auto master_elem_map : master_elem)
      {
        for (auto slave_elem_map : slave_elem)
        {
          std::cout <<"elem:"<< master_elem_map.second->id() <<" ->"<<slave_elem_map.second->id()<< std::endl;
        }
      }
    }
  }
  // std::cout << "-------boundary #: " <<_boundary_ids<< std::endl;
  // std::cout << "-------boundary #: " <<_boundary_ids<< std::endl;
  // std::cout << "-----------elem #: " << std::endl;
  // std::cout << "-----------side #: " << std::endl;
  // std::cout << "-----------node #: " << std::endl;
  // std::cout <<"("<<(*_node_coordinates[1][0][0][0])(0)<<","<<(*_node_coordinates[1][0][0][0])(1)<<","<<(*_node_coordinates[1][0][0][0])(2)<<")"<<'\n';
  // for (unsigned int i = 0; i < x_coords.size(); i++)
  // {
  //   // std::cout<<"x="<<x_coords[i]<<'\n';
  //   // std::cout<<y_coords[i]<<'\n';
  //   // std::cout<<z_coords[i]<<'\n';
  // }
  // Nodal Coordinates
  // std::cout << "x: " << coords_array[0][0] << std::endl;
  // std::cout << "y: " << coords_array[1][0] << std::endl;
  // std::cout << "z: " << coords_array[2][0] << std::endl;
  // Nodal Normal Components
  // std::cout << "n_x: " << normals_array[0][0] << std::endl;
  // std::cout << "n_y: " << normals_array[1][0] << std::endl;
  // std::cout << "n_z: " << normals_array[2][0] << std::endl;
  // std::cout << "n_x: " << normals_array[0][3] << std::endl;
  // FINDING THE SOURCE POINT ON ELEMENT SURFACE AND SAMPLE DIRECTION
  // Random Source Point
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
