#include <vector>
#include <fstream>
#include "ViewFactor.h"
#include "MooseRandom.h"
// libMesh includes
#include "libmesh/boundary_info.h"
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
  params.addParam<unsigned int>("sampling_number",1000, "Number of Sampling");
  params.addParam<unsigned int>("source_number",1, "Number of Source Points");
  params.addParam<std::vector<Real>>("parallel_planes",
                                     "{W1,W2,H} values for parallel planes to calculate view factor analytically");
  // params.addRequiredParam<std::vector<BoundaryName>>("master_boundary", "Master Boundary ID");
  // params.addRequiredParam<std::vector<BoundaryName>>("slave_boundary", "Slave Boundary ID");
  return params;
}

ViewFactor::ViewFactor(const InputParameters & parameters)
  : SideUserObject(parameters),
    _PI(acos(-1)), // 3.141592653589793238462643383279502884
    _samplingNumber(getParam<unsigned int>("sampling_number")),
    _sourceNumber(getParam<unsigned int>("source_number")),
    _parallel_planes_geometry(getParam<std::vector<Real>>("parallel_planes")),
    _current_normals(_assembly.normals()),
    _boundary_ids(boundaryIDs()),
    _boundary_list(getParam<std::vector<BoundaryName>>("boundary"))
{
}

const Real
ViewFactor::angleBetweenVectors(const std::vector<Real> v1, const std::vector<Real> v2)
{
  Real v1_length = pow((v1[0]*v1[0]+v1[1]*v1[1]+v1[2]*v1[2]),0.5);
  Real v2_length = pow((v2[0]*v2[0]+v2[1]*v2[1]+v2[2]*v2[2]),0.5);
  Real v12_dot = v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2];
  Real theta = acos(v12_dot/(v1_length*v2_length));  //Radian
  theta *= (180/_PI);   //Degree
  return theta;
}

const Real
ViewFactor::getAnalyticalViewFactor(const std::vector<Real> & v)
{
  Real x = 1.0 * v[0] / v[2];
  Real y = 1.0 * v[1] / v[2];
  Real viewfactor =
      (2 / (_PI * x * y)) *
      (log(pow((((1 + x * x) * (1 + y * y)) / (1 + x * x + y * y)), 0.5)) +
       x * (pow((1 + y * y), 0.5)) * atan(x / (pow((1 + y * y), 0.5))) +
       y * (pow((1 + x * x), 0.5)) * atan(y / (pow((1 + x * x), 0.5))) - x * atan(x) - y * atan(y));
  return viewfactor;
}

const std::vector<Real>
ViewFactor::findNormalFromNodeMap(std::map<unsigned int, std::vector<Real>> map)
{
  std::vector<Real> v1 = map[0];
  std::vector<Real> v2 = map[1];
  std::vector<Real> v3 = map[2];
  std::vector<Real> v12(v1.size());
  std::vector<Real> v13(v1.size());
  v12[0] = v2[0]-v1[0];
  v12[1] = v2[1]-v1[1];
  v12[2] = v2[2]-v1[2];
  v13[0] = v3[0]-v1[0];
  v13[1] = v3[1]-v1[1];
  v13[2] = v3[2]-v1[2];
  std::vector<Real> v(v1.size());
  v[0] = v12[1]*v13[2]-v12[2]*v13[1];
  v[1] = v12[2]*v13[0]-v12[0]*v13[2];
  v[2] = v12[0]*v13[1]-v12[1]*v13[0];
  //normalization
  const Real v_length = pow((v[0]*v[0]+v[1]*v[1]+v[2]*v[2]),0.5);
  v[0]/=v_length;
  v[1]/=v_length;
  v[2]/=v_length;
  return v;
}

const std::vector<Real>
ViewFactor::getRandomPoint(std::map<unsigned int, std::vector<Real>> map)
{
  const std::vector<Real> node0 = map[0];
  const std::vector<Real> node1 = map[1];
  const std::vector<Real> node2 = map[2];
  const std::vector<Real> node3 = map[3];
  std::vector<Real> p(node0.size());
  Real px1, px2, py1, py2, pz1, pz2;
  Real rand_x, rand_y, rand_z;
  rand_x = std::rand() / (1. * RAND_MAX);
  rand_y = std::rand() / (1. * RAND_MAX);
  rand_z = std::rand() / (1. * RAND_MAX);
  px1 = rand_x * (node1[0] - node0[0]);
  py1 = rand_y * (node1[1] - node0[1]);
  pz1 = rand_z * (node1[2] - node0[2]);
  rand_x = std::rand() / (1. * RAND_MAX);
  rand_y = std::rand() / (1. * RAND_MAX);
  rand_z = std::rand() / (1. * RAND_MAX);
  px2 = rand_x * (node3[0] - node0[0]);
  py2 = rand_y * (node3[1] - node0[1]);
  pz2 = rand_z * (node3[2] - node0[2]);
  p[0] = node0[0] + px1 + px2;
  p[1] = node0[1] + py1 + py2;
  p[2] = node0[2] + pz1 + pz2;
  return p;
}

const bool
ViewFactor::isVisible(const std::map<unsigned int, std::vector<Real>> & master,
                      const std::map<unsigned int, std::vector<Real>> & slave)
{
  const std::vector<Real> master_normal = findNormalFromNodeMap(master);
  const std::vector<Real> slave_normal = findNormalFromNodeMap(slave);
  for (size_t i = 0; i < 1000; i++) // check visibility for different points
  {
    const std::vector<Real> master_point = getRandomPoint(master);
    const std::vector<Real> slave_point = getRandomPoint(slave);
    const std::vector<Real> master_slave = {(slave_point[0]-master_point[0]),(slave_point[1]-master_point[1]),(slave_point[2]-master_point[2])};
    const std::vector<Real> slave_master = {(master_point[0]-slave_point[0]),(master_point[1]-slave_point[1]),(master_point[2]-slave_point[2])};
    Real theta_master_slave = angleBetweenVectors(master_normal,master_slave);
    Real theta_slave_master = angleBetweenVectors(slave_normal,slave_master);
    if (theta_slave_master<90 && theta_master_slave<90)
      return true;
  }
  return false;
}

const std::vector<Real>
ViewFactor::getRandomDirection(const std::vector<Real> & normal)
{
  //   Sample Direction by transforming normal vector
  const Real rand_theta = std::rand() / (1. * RAND_MAX);
  const Real rand_phi = std::rand() / (1. * RAND_MAX);
  const Real theta = 0.5 * acos(1 - 2 * rand_theta);
  // std::cout << theta <<std::endl;
  const Real phi = 2 * _PI * rand_phi;
  const Real dir_z{sin(theta) * sin(phi)},
             dir_y{sin(theta) * cos(phi)},
             dir_x{cos(theta)};
  const std::vector<Real> direction{dir_x,dir_y,dir_z}; // Radian
  return direction;
}

const bool
ViewFactor::isOnSurface(const std::vector<Real> &p, std::map<unsigned int, std::vector<Real>> map)
{
  std::vector<Real> x;
  std::vector<Real> y;
  std::vector<Real> z;
  for (size_t i = 0; i < 4; i++)     //write nodes to test point is on surface or not
  {
    // std::cout<<"Slave Node #"<<i<<" : ("<<map[i][0]<<","<<map[i][1]<<","<<map[i][2]<<")"<<std::endl;
    x.push_back(map[i][0]);
    y.push_back(map[i][1]);
    z.push_back(map[i][2]);
  }
  Real x_max = *(std::max_element(x.begin(), x.end()));
  Real x_min = *(std::min_element(x.begin(), x.end()));
  Real y_max = *(std::max_element(y.begin(), y.end()));
  Real y_min = *(std::min_element(y.begin(), y.end()));
  Real z_max = *(std::max_element(z.begin(), z.end()));
  Real z_min = *(std::min_element(z.begin(), z.end()));

  if (p[0]<=x_max && p[0]>=x_min && p[1]<=y_max && p[1]>=y_min && p[2]<=z_max && p[2]>=z_min)   // FIX THIS
  {
    return true;
  }
  else
  {
    // std::cout<<"not on surface"<<std::endl;
    return false;
  }
}

const bool
ViewFactor::isIntersected(const std::vector<Real> & p1,
                          const std::vector<Real> & dir,
                          const std::map<unsigned int, std::vector<Real>> & map)
{
  const std::vector<Real> n = findNormalFromNodeMap(map);
  // const std::vector<Real> pR = getRandomPoint(map);
  const Real d = _parallel_planes_geometry[2]/dir[0];
  // std::cout << "d : "<<d<< std::endl;
  const std::vector<Real> p2{(p1[0] + d * dir[0]),
                             (p1[1] + d * dir[1]),
                             (p1[2] + d * dir[2])};
  // std::cout << "target    : (" << p2[0] <<","<< p2[1] <<","<< p2[2] <<")"<< std::endl;
  // std::cout<<"Slave Normal #: ("<<n[0]<<","<<n[1]<<","<<n[2]<<")"<<std::endl;

  // //test in x direction
  // // const std::vector<Real> node0 = map[0];
  // Real w = (pR[0]-p1[0]);
  // // Real w = (n[0] * (pR[0] - p1[0]) + n[1] * (pR[1] - p1[1]) + n[2] * (pR[2] - p1[2])) /
  // //          (n[0] * dir[0] + n[1] * dir[1] + n[2] * dir[2]);
  // std::cout<<"w = "<<w<<std::endl;
  // const std::vector<Real> p2{(p1[0] + w * dir[0]),
  //                            (p1[1] + w * dir[1]),
  //                            (p1[2] + w * dir[2])};
  //
  // Real d0 = pow(((p2[0] - p1[0]) * (p2[0] - p1[0]) + (p2[1] - p1[1]) * (p2[1] - p1[1]) +
  //                (p2[2] - p1[2]) * (p2[2] - p1[2])),0.5);
  // // std::cout <<"d : "<< d <<"     dp: "<<dp<<std::endl;
  //

  if (isOnSurface(p2,map))
    return true;
  else
    return false;
}

void
ViewFactor::printViewFactors()
{
  std::cout << " " << std::endl;
  std::cout << "============================ View Factors ============================"
            << std::endl;
  std::cout << "----------------------------------------------------------------------"
            << std::endl;
  Real elem_to_bnd_viewfactor{0};
  Real bnd_viewfactor{0};
  unsigned int elem_pair_size{0};
  for (const auto & bnd1 : _element_viewfactors)
  {
    auto bnd1_map = _element_viewfactors[bnd1.first];
    for (const auto & bnd2 : bnd1_map)
    {
      auto bnd2_map = bnd1_map[bnd2.first];
      bnd_viewfactor = 0;
      for (const auto & elem1 : bnd2_map)
      {
        elem_to_bnd_viewfactor = 0;
        auto elem1_map = bnd2_map[elem1.first];
        elem_pair_size = elem1_map.size();
        for (const auto & elem2 : elem1_map)
        {
          elem_to_bnd_viewfactor += elem2.second;
          std::cout << "Bnd " << bnd1.first << " : Elem " << elem1.first << "    --->    "
                    << "Bnd " << bnd2.first << " : Elem " << elem2.first
                    << "    View Factor = " << elem2.second << std::endl;
        }
        std::cout << "        Elem " << elem1.first << "    --->    "
                  << "Bnd " << bnd2.first << "       Total View Factor = " << elem_to_bnd_viewfactor
                  << "\n"<<std::endl;
        bnd_viewfactor += elem_to_bnd_viewfactor;
      }
      bnd_viewfactor /= elem_pair_size;
      std::cout << "         Bnd " << bnd1.first << "    --->    "
                << "Bnd " << bnd2.first << "     Average View Factor = " << bnd_viewfactor
                << std::endl;
      std::cout << "                                       % Relative Error = " <<100*(bnd_viewfactor/getAnalyticalViewFactor(_parallel_planes_geometry)-1)<< std::endl;
      std::cout << "----------------------------------------------------------------------"
                << std::endl;
    }
  }
}

void
ViewFactor::printNodesNormals()
{
  for (const auto &master_bid : _boundary_ids)    //bid : bid
  {
    const auto master_boundary = _node_set[master_bid];  //map[bid]
    const auto master_bname = _mesh.getBoundaryName(master_bid);
    for (const auto &master_elem : master_boundary)  // map : map
    {
      const auto master_node_map = _node_set[master_bid][master_elem.first];
      std::cout << "--------------------------------------------------------------------------"<<
      std::endl; std::cout << "-------boundary #: " << master_bid << " : "<<master_bname<<
      std::endl; std::cout << "-----------elem #: " << master_elem.first << std::endl;
      for (auto master_node : master_node_map)
      {
        std::cout <<"Node #"<<master_node.first<<" : ("<<(master_node.second)[0]<<","
                  <<(master_node.second)[1]<<","<<(master_node.second)[2]<<")\t"<<"Normal : ("
                  <<findNormalFromNodeMap(master_node_map)[0]<<","
                  <<findNormalFromNodeMap(master_node_map)[1]<<","
                  <<findNormalFromNodeMap(master_node_map)[2]<<")"<<std::endl;
      }
    }
  }
}


// const std::map<BoundaryID, std::map<BoundaryID, Real> > ViewFactor::getBoundarViewFactors(const
// std::map<BoundaryID, std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, Real > >
// > > &map)
// {
// }

void
ViewFactor::initialize()
{
  std::srand(time(NULL));
  std::cout << "---------------------- " <<std::endl;
  std::cout << "Analytical Value of View Factor"
            << "\nParallel planes with W1=" << _parallel_planes_geometry[0]
            << ", W2=" << _parallel_planes_geometry[1] << ", H=" << _parallel_planes_geometry[2]
            << std::endl;
  std::cout << "F = " << getAnalyticalViewFactor(_parallel_planes_geometry) << std::endl;
  std::cout << "---------------------- " << std::endl;
  std::cout << ": Defined Boundaries : " << std::endl;
  std::cout << "---------------------- " << std::endl;

  for (const auto bid : _boundary_ids)
  {
    std::cout << "id: " << bid <<" name: "<<_mesh.getBoundaryName(bid)<< std::endl;
  }
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
  _element_set_ptr[current_boundary_id][current_element_id] = _current_side_elem;
  _element_set[current_boundary_id][current_element_id] = _current_side_elem->n_nodes();
  // std::cout << "------------------------------"<< std::endl;
  // std::cout << "-------boundary #: " << current_boundary_id << " : "<<current_boundary_name<< std::endl;
  // std::cout << "-----------elem #: " << (_current_elem->id()) << std::endl;
  // std::cout << "-----------side #: " << (_current_side) << std::endl;
  //Loop over nodes on current element side
  unsigned int n = _current_side_elem->n_nodes();
  if (n!=4)
    mooseError("ViewFactor UserObject can only be used for 4-noded Quadrilateral Elements");
  for (unsigned int i = 0; i < n; i++)
  {
    unsigned int _current_node_id = i;
    const Node * node = _element_set_ptr[current_boundary_id][current_element_id]->node_ptr(i);    //get nodes
    for (unsigned int j = 0; j < 3; j++)         // Define nodal coordinates and normals
    {
      _node_set[current_boundary_id][current_element_id][_current_node_id].push_back((*node)(j));
      _normal_set[current_boundary_id][current_element_id][_current_node_id].push_back(_normals[i](j));
    }
    // std::cout <<"Node #"<<i<<" : ("<<(*node)(0)<<","<<(*node)(1)<<","<<(*node)(2)<<")\t";
    // std::cout <<" Normal : ("<<(normal)(0)<<","<<(normal)(1)<<","<<(normal)(2)<<")"<< std::endl;
  }
}
void
ViewFactor::finalize()
{
  for (auto master_bid : _boundary_ids)
  {
    const auto master_boundary = _node_set[master_bid];
    for (auto slave_bid : _boundary_ids)
    {
      const auto slave_boundary = _node_set[slave_bid];
      const auto master_bname = _mesh.getBoundaryName(master_bid);
      const auto slave_bname = _mesh.getBoundaryName(slave_bid);
      std::cout << "-----------------------------------------" << std::endl;
      std::cout << "\t" << master_bid << ":" << master_bname << "  ->  " << slave_bid << ":"
                << slave_bname << std::endl;
      std::cout << "-----------------------------------------" << std::endl;
      for (auto master_elem : master_boundary)
      {
        const auto master_node_map = _node_set[master_bid][master_elem.first];
        for (auto slave_elem : slave_boundary)
        {
          const auto slave_node_map = _node_set[slave_bid][slave_elem.first];
          if (isVisible(master_node_map,slave_node_map))
          {
            std::cout << "Element #" << master_elem.first << " -> Element #" << slave_elem.first
                      << "...........done" << std::endl;
            for (auto master_node : master_node_map)
            {
              // std::cout <<"Master Node #"<<master_node.first<<" : ("<<(master_node.second)[0]<<","
              //           <<(master_node.second)[1]<<","<<(master_node.second)[2]<<")"<<std::endl;
            }
            const std::vector<Real> master_normal = findNormalFromNodeMap(master_node_map);
            // std::cout <<"Master Normal : (" << master_normal[0]<<"," << master_normal[1] <<","<< master_normal[2]<<")" <<std::endl;
            unsigned int counter{0};
            Real viewfactor{0};
            Real viewfactor_src{0};
            for (size_t src = 0; src < _sourceNumber; src++)
            {
              viewfactor_src = 0;
              const std::vector<Real> source_point = getRandomPoint(master_node_map);
              // std::cout << "source_point: ("
              // <<source_point[0]<<","<<source_point[1]<<","<<source_point[2]<<")"<<std::endl;
              counter = 0;
              for (size_t ray = 0; ray < _samplingNumber; ray++)
              {
                const std::vector<Real> direction = getRandomDirection(master_normal);
                // std::cout << "direction: (" << direction[0] << "," << direction[1] << ","
                //           << direction[2] << ")" << std::endl;
                const Real theta = angleBetweenVectors(direction, master_normal);   // in Degree
                // std::cout <<"theta : "<< theta << std::endl;
                if (theta < 90) // check forward sampling
                {
                  if (isIntersected(source_point, direction, slave_node_map)) // check Intersecting
                  {
                    counter++;
                    // std::cout << "!! Intersected !!" << std::endl;
                    // std::cout <<" Count:"<<counter<<std::endl;
                  }
                }
              }
              viewfactor_src = (counter * 1.0) / _samplingNumber;
              viewfactor += viewfactor_src;
            }
            _element_viewfactors[master_bid][slave_bid][master_elem.first][slave_elem.first] = (viewfactor * 1.0) / _sourceNumber;
          }
          else
          {
            _element_viewfactors[master_bid][slave_bid][master_elem.first][slave_elem.first] = 0;
            std::cout << "Element #" << master_elem.first << " -> Element #" << slave_elem.first
                      << "......invisible" << std::endl;
          }
        }
      }
    }
  }
  printViewFactors();
  // printNodesNormals();
}
