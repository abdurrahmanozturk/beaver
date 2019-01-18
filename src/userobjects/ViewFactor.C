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
    // _nodal_normal_x(isParamValid("nodal_normal_x") ? coupledValue("nodal_normal_x") : _zero),
    // _nodal_normal_y(isParamValid("nodal_normal_y") ? coupledValue("nodal_normal_y") : _zero),
    // _nodal_normal_z(isParamValid("nodal_normal_z") ? coupledValue("nodal_normal_z") : _zero)
{
}

void
ViewFactor::initialize()
{
  std::srand(time(NULL));
  std::cout << "-------boundary_ids #: " << _boundary_ids.size() << std::endl;
}

void
ViewFactor::execute()
{
  // LOOPING OVER ELEMENTS ON THE MASTER BOUNDARY
  // Define IDs
  BoundaryID current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  const auto current_boundary_name = _mesh.getBoundaryName(current_boundary_id);
  unsigned int current_element_id =(_current_elem->id());
  //Define Map for current boundary and current element and put Elem pointer for current element side
  _element_side[current_boundary_id][current_element_id] = _current_side_elem;
  std::cout << "--------------------------------------------------------------------------"<< std::endl;
  std::cout << "-------boundary #: " << current_boundary_id << " : "<<current_boundary_name<< std::endl;
  std::cout << "-----------elem #: " << (_current_elem->id()) << std::endl;
  // std::cout << "-----------side #: " << (_current_side) << std::endl;
  //Loop over nodes on current element side
  unsigned int n = _current_side_elem->n_nodes();
  for (unsigned int i = 0; i < n; i++)
  {
    const Node * node = _element_side[current_boundary_id][current_element_id]->node_ptr(i);    //get nodes
    Point normal = _normals[i];                                                                 //get nodal normals
    // _node_coordinates[current_boundary_id][current_element_id][_current_side][i]=node;
    // _node_normals[current_boundary_id][current_element_id][_current_side][i]=normal;
    // _node_coordinates[current_boundary_id][current_element_id][i]=node;
    std::cout <<"Node #"<<i<<" : ("<<(*node)(0)<<","<<(*node)(1)<<","<<(*node)(2)<<")\t";

    //Define node normals
    _node_normals[current_boundary_id][current_element_id][i]=normal;
    std::cout <<" Normal : ("<<(normal)(0)<<","<<(normal)(1)<<","<<(normal)(2)<<")"<< std::endl;
  }
}
void
ViewFactor::finalize()
{
  for (auto master_bid : _boundary_ids)
  {
    const auto master_elem = _element_side[master_bid];
    for (auto slave_bid : _boundary_ids)
    {
      const auto slave_elem = _element_side[slave_bid];
      const auto master_bname = _mesh.getBoundaryName(master_bid);
      const auto slave_bname = _mesh.getBoundaryName(master_bid);
      std::cout <<"-------------------------------------------------"<<std::endl;
      std::cout <<"bnd :"<<master_bname<< " -> "<<slave_bname<<std::endl;
      std::cout <<"-------------------------------------------------"<<std::endl;
      for (auto master_elem_map : master_elem)
      {
        for (auto slave_elem_map : slave_elem)
        {
          std::cout <<"elem:"<< master_elem_map.first <<" ->"<<slave_elem_map.first<< std::endl;
        }
      }
    }
  }
  for (auto master_bid : _boundary_ids)
  {
    const auto master_elem = _element_side[master_bid];
    const auto master_bname = _mesh.getBoundaryName(master_bid);
    for (auto master_elem_map : master_elem)
    {
      std::cout << "--------------------------------------------------------------------------"<< std::endl;
      std::cout << "-------boundary #: " << master_bid << " : "<<master_bname<< std::endl;
      std::cout << "-----------elem #: " << master_elem_map.first << std::endl;
      unsigned int n = master_elem_map.second->n_nodes();
      for (unsigned int i = 0; i < n; i++)
      {
        const Node * node = master_elem_map.second->node_ptr(i);    //get nodes
        Point normal = _normals[i];                             //get nodal normals
        // _node_coordinates[current_boundary_id][current_element_id][_current_side][i]=node;
        // _node_normals[current_boundary_id][current_element_id][_current_side][i]=normal;
        // _node_coordinates[current_boundary_id][current_element_id][i]=node;
        std::cout <<"Node #"<<i<<" : ("<<(*node)(0)<<","<<(*node)(1)<<","<<(*node)(2)<<")\t";

        //Define node normals
        _node_normals[master_bid][master_elem_map.first][i]=normal;
        std::cout <<" Normal : ("<<(normal)(0)<<","<<(normal)(1)<<","<<(normal)(2)<<")"<< std::endl;
      }
    }
  }
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
