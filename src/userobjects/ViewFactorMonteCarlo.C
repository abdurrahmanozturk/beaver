#include <vector>
#include "ViewFactorMonteCarlo.h"
#include "MooseRandom.h"
// libMesh includes
#include "libmesh/boundary_info.h"
#include "libmesh/mesh_generation.h"
#include "libmesh/mesh.h"
#include "libmesh/string_to_enum.h"
#include "libmesh/quadrature_gauss.h"
#include "libmesh/point_locator_base.h"

registerMooseObject("beaverApp", ViewFactorMonteCarlo);

template <>
InputParameters
validParams<ViewFactorMonteCarlo>()
{
  InputParameters params = validParams<UserObject>();
  params += validParams<BoundaryRestrictableRequired>();
  params += validParams<MaterialPropertyInterface>();
  params.addClassDescription("User Object to calculate view factors for radiative surfaces.");
  params.addParam<unsigned int>("sampling_number",100, "Number of Sampling");
  params.addParam<unsigned int>("source_number",100, "Number of Source Points");
  params.addParam<bool>("debug_mode",false, "Print everything to screen for debugging");
  params.addParam<bool>("print_screen",false, "Print View Factors to Screen");
  params.addParam<Real>("error_tolerance",1e-6, "Tolerance for calculations");
  params.addParam<std::vector<Real>>("parallel_planes",
                                     "{W1,W2,H} values for parallel planes to calculate view factor analytically");
  params.addParam<std::vector<BoundaryName>>("master_boundary", "Master Boundary ID");
  params.addParam<std::vector<BoundaryName>>("slave_boundary", "Slave Boundary ID");
  // !! Edit boundary definitions as vector of BoundaryNames for multiple input
  return params;
}

ViewFactorMonteCarlo::ViewFactorMonteCarlo(const InputParameters & parameters)
  : SideUserObject(parameters),
    // _current_normals(_assembly.normals()),
    _boundary_ids(boundaryIDs()),
    _mesh_boundary_ids(_mesh.meshBoundaryIds()),
    _mesh_sideset_ids(_mesh.meshSidesetIds()),
    _mesh_nodeset_ids(_mesh.meshNodesetIds()),
    _PI(acos(-1)), // 3.141592653589793238462643383279502884
    _debugMode(getParam<bool>("debug_mode")),
    _printScreen(getParam<bool>("print_screen")),
    _error_tol(getParam<Real>("error_tolerance")),
    _samplingNumber(getParam<unsigned int>("sampling_number")),
    _sourceNumber(getParam<unsigned int>("source_number")),
    _parallel_planes_geometry(getParam<std::vector<Real>>("parallel_planes")),
    _master_boundary_names(getParam<std::vector<BoundaryName>>("master_boundary")),
    _slave_boundary_names(getParam<std::vector<BoundaryName>>("slave_boundary"))
{

  // PUT THIS INTO PARENT CLASS
    if (_master_boundary_names.size()!=0 && _slave_boundary_names.size()!=0)
    {
      _boundary_ids.clear();
      // Get the IDs from the supplied names
      std::vector<BoundaryID> master_vec_ids = _mesh.getBoundaryIDs(_master_boundary_names, true);
      std::vector<BoundaryID> slave_vec_ids = _mesh.getBoundaryIDs(_slave_boundary_names, true);

      // Store the IDs, handling ANY_BOUNDARY_ID if supplied
      if (std::find(_master_boundary_names.begin(), _master_boundary_names.end(), "ANY_BOUNDARY_ID") !=
          _master_boundary_names.end())
      {
        _master_boundary_ids.insert(Moose::ANY_BOUNDARY_ID);
        _boundary_ids.insert(Moose::ANY_BOUNDARY_ID);
      }
      else
      {
        _master_boundary_ids.insert(master_vec_ids.begin(), master_vec_ids.end());
        _boundary_ids.insert(master_vec_ids.begin(), master_vec_ids.end());
      }
      if (std::find(_slave_boundary_names.begin(), _slave_boundary_names.end(), "ANY_BOUNDARY_ID") !=
          _slave_boundary_names.end())
      {
        _slave_boundary_ids.insert(Moose::ANY_BOUNDARY_ID);
        _boundary_ids.insert(Moose::ANY_BOUNDARY_ID);
      }
      else
      {
        _slave_boundary_ids.insert(slave_vec_ids.begin(), slave_vec_ids.end());
        _boundary_ids.insert(slave_vec_ids.begin(), slave_vec_ids.end());
      }
    }
}

const std::set<BoundaryID> &
ViewFactorMonteCarlo::getMasterBoundaries() const
{
  return _master_boundary_ids;
}

const std::set<BoundaryID> &
ViewFactorMonteCarlo::getSlaveBoundaries() const
{
  return _slave_boundary_ids;
}

const Real
ViewFactorMonteCarlo::getAngleBetweenVectors(const std::vector<Real> v1, const std::vector<Real> v2) const
{
  Real v1_length = pow((v1[0]*v1[0]+v1[1]*v1[1]+v1[2]*v1[2]),0.5);
  Real v2_length = pow((v2[0]*v2[0]+v2[1]*v2[1]+v2[2]*v2[2]),0.5);
  Real v12_dot = v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2];
  Real theta = acos(v12_dot/(v1_length*v2_length));  //Radian
  theta *= (180/_PI);
  return theta;
}

const Real
ViewFactorMonteCarlo::getDistanceBetweenPoints(const std::vector<Real> v1, const std::vector<Real> v2) const
{
  Real d = pow(((v2[0]-v1[0])*(v2[0]-v1[0])
               +(v2[1]-v1[1])*(v2[1]-v1[1])
               +(v2[2]-v1[2])*(v2[2]-v1[2])),0.5);
  return d;
}

const Real
ViewFactorMonteCarlo::getAnalyticalViewFactor(const std::vector<Real> & v)
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

const Real
ViewFactorMonteCarlo::getVectorLength(const std::vector<Real> & v) const
{
  return pow((v[0]*v[0]+v[1]*v[1]+v[2]*v[2]),0.5);
}

const std::vector<Real>
ViewFactorMonteCarlo::getNormalFromNodeMap(std::map<unsigned int, std::vector<Real> > map) const
{
  // three points in plane
  std::vector<Real> p1 = map[0];
  std::vector<Real> p2 = map[1];
  std::vector<Real> p3 = map[2];
    //find 2 vectors in surface
  std::vector<Real> v12{(p2[0]-p1[0]),
                        (p2[1]-p1[1]),
                        (p2[2]-p1[2])};
  std::vector<Real> v13{(p3[0]-p1[0]),
                        (p3[1]-p1[1]),
                        (p3[2]-p1[2])};
  //cross product of vectors gives surface normal
  std::vector<Real> n(v12.size());
  n[0] = v12[1]*v13[2]-v12[2]*v13[1];
  n[1] = v12[2]*v13[0]-v12[0]*v13[2];
  n[2] = v12[0]*v13[1]-v12[1]*v13[0];
  //normalization
  const Real length = getVectorLength(n);
  n[0]/=length;
  n[1]/=length;
  n[2]/=length;
  return n;
}

const std::vector<Real>
ViewFactorMonteCarlo::getCenterPoint(std::map<unsigned int, std::vector<Real> > map) const
{
  unsigned int n=map.size();
  Real sum_x{0},sum_y{0},sum_z{0};
  for (size_t i = 0; i < n; i++)
  {
    sum_x += map[i][0];
    sum_y += map[i][1];
    sum_z += map[i][2];
  }
  std::vector<Real> center{(sum_x/n),(sum_y/n),(sum_z/n)};  //center is geometric mean nodes
  return center;
}

const std::vector<Real>
ViewFactorMonteCarlo::getRandomDirection(const std::vector<Real> & n,const int dim) const
{
  //find theta and phi for unit normal vector in global coordinate system
  Real theta_normal = acos(n[2]);
  Real phi_normal{0};
  if (theta_normal!=0)
  {
    if (n[1]<0)
    {
      phi_normal = 2*_PI-acos(n[0]/sin(theta_normal));
    }
    else
    {
      phi_normal = acos(n[0]/sin(theta_normal));
    }
  }
  //Create Rotation Matrix to transform global coordinate system to local coordinate system
  const Real theta_local = -theta_normal;
  const Real phi_local = -phi_normal;
  Real Rlocal[3][3]={{(cos(theta_local)*cos(phi_local)),sin(phi_local),(-cos(phi_local)*sin(theta_local))},
                     {(-cos(theta_local)*sin(phi_local)),cos(phi_local),(sin(theta_local)*sin(phi_local))},
                     {sin(theta_local),0,cos(theta_local)}};
  //Sample direction in global coordinate system
  Real theta{0},phi{0};
  const Real rand_phi = std::rand() / (1. * RAND_MAX);
  const Real rand_theta = std::rand() / (1. * RAND_MAX);
  switch (dim)   // check dimension  2: sample radial position  3:sample spherical position
  {
    case 2:
    {
      theta = _PI/2;
      phi = 2 * _PI * rand_phi;
      break;
    }
    case 3:
    {
      theta = 0.5 * acos(1 - 2 * rand_theta);
      phi = 2 * _PI * rand_phi;
      break;
    }
  }
  // std::cout << theta <<std::endl;
  const Real dir_x{sin(theta) * cos(phi)},
             dir_y{sin(theta) * sin(phi)},
             dir_z{cos(theta)};
  const std::vector<Real> dir_global{dir_x,dir_y,dir_z};
  // transform global direction to local direction
  const std::vector<Real> dir_local{(Rlocal[0][0]*dir_global[0]+Rlocal[0][1]*dir_global[1]+Rlocal[0][2]*dir_global[2]),
                                    (Rlocal[1][0]*dir_global[0]+Rlocal[1][1]*dir_global[1]+Rlocal[1][2]*dir_global[2]),
                                    (Rlocal[2][0]*dir_global[0]+Rlocal[2][1]*dir_global[1]+Rlocal[2][2]*dir_global[2])};
  return dir_local;
}

const Real
ViewFactorMonteCarlo::getArea(const std::vector<Real> &p, std::map<unsigned int, std::vector<Real>> map) const
{
  //FIND AREA OF ELEMENT SURFACE by summing area of triangles
  unsigned int n = map.size();    // number of nodes in element surface
  // std::cout<<" n= "<<n<<std::endl;
  Real area{0};
  for (size_t i = 0; i < n; i++)    //create triangle and calculate area
  {
    const std::vector<Real> node1 = map[i];
    const std::vector<Real> node2 = map[(i+1)%n];
    const std::vector<Real> v1 = {(node1[0]-p[0]),(node1[1]-p[1]),(node1[2]-p[2])};
    const std::vector<Real> v2 = {(node2[0]-p[0]),(node2[1]-p[1]),(node2[2]-p[2])};
    const Real theta = (_PI/180)*getAngleBetweenVectors(v1,v2);
    area += 0.5 * getVectorLength(v1)*getVectorLength(v2)*sin(theta);
  }
  return area;
}

const bool
ViewFactorMonteCarlo::isOnSurface(const std::vector<Real> &p, std::map<unsigned int, std::vector<Real>> map) const
{
  // std::vector<Real> x;
  // std::vector<Real> y;
  // std::vector<Real> z;
  // for (size_t i = 0; i < map.size(); i++)     //write nodes to test point is on surface or not
  // {
    // x.push_back(map[i][0]);
    // y.push_back(map[i][1]);
    // z.push_back(map[i][2]);
  // }
  // Real x_max = *(std::max_element(x.begin(), x.end()));
  // Real x_min = *(std::min_element(x.begin(), x.end()));
  // Real y_max = *(std::max_element(y.begin(), y.end()));
  // Real y_min = *(std::min_element(y.begin(), y.end()));
  // Real z_max = *(std::max_element(z.begin(), z.end()));
  // Real z_min = *(std::min_element(z.begin(), z.end()));

  const std::vector<Real> center{getCenterPoint(map)};
  Real elem_area = getArea(center,map);
  Real area = getArea(p,map);
  // std::cout << "Slave Element Surface Area ="<< slave_area << std::endl;
  // std::cout << "Calcualted Surface Area ="<< area << std::endl;
  // std::cout << "Area Residual ="<<area - slave_area<< std::endl;
  // bool a{0},b{0};

  if ((area-elem_area)<_error_tol)
    return true;
  else
    return false;
  // if (area>slave_area+1e-6)
  // {
  //   // a=false;
  //   // std::cout<<"not on surface"<<std::endl;
  //   return false;
  // }
  // else
  // {
  //   // a=true;
  //   // std::cout<<"on surface"<<std::endl;
  //   return true;
  // }

  // if (p[0]<=x_max && p[0]>=x_min && p[1]<=y_max && p[1]>=y_min && p[2]<=z_max && p[2]>=z_min)   // FIX THIS
  // {
  //   b=true;
  //   if (a!=b)
  //     mooseError("something is wrong!");
  //   return true;
  // }
  // else
  // {
  //   std::cout<<"not on surface"<<std::endl;
  //   b=false;
  //   if (a!=b)
  //     mooseError("something is wrong!");
  //   return false;
  // }
}

const std::vector<Real>
ViewFactorMonteCarlo::getRandomPoint(std::map<unsigned int, std::vector<Real>> map) const
{
  const std::vector<Real> n = getNormalFromNodeMap(map);
  const std::vector<Real> center{getCenterPoint(map)};
  Real rad{0},d{0};  //radius, distance
  for (size_t i = 0; i < map.size(); i++)   //find max distance to surrounding nodes
  {
    d = getDistanceBetweenPoints(center,map[i]);
    if (d>rad)
      rad=d;
  }
  // std::cout<<"r = "<<r<<std::endl;
  // std::cout<<"center = ("<<center[0]<<","<<center[1]<<","<<center[2]<<")"<<std::endl;
  while (true)
  {
    const Real rand_r = std::rand() / (1. * RAND_MAX);
    const Real r =rad*pow(rand_r,0.5);
    const std::vector<Real> dir{getRandomDirection(n,2)};
    // std::cout<<"dir=("<<dir[0]<<","<<dir[1]<<","<<dir[2]<<")"<<std::endl;
    const std::vector<Real> p{(center[0]+r*dir[0]),(center[1]+r*dir[1]),(center[2]+r*dir[2])};
    // std::cout<<"sampled point = ("<<p[0]<<","<<p[1]<<","<<p[2]<<")"<<std::endl;
    if (isOnSurface(p,map))
      return p;
  }
}

const bool
ViewFactorMonteCarlo::isIntersected(const std::vector<Real> & p1,
                          const std::vector<Real> & dir,
                          std::map<unsigned int, std::vector<Real>> map) const
{
  const std::vector<Real> n = getNormalFromNodeMap(map);
  const std::vector<Real> pR = getRandomPoint(map);
  // const Real d = _parallel_planes_geometry[2]/dir[0];
  // //test in x direction
  // // const std::vector<Real> node0 = map[0];
  // Real w = (pR[0]-p1[0]);
  Real d = (n[0] * (pR[0] - p1[0]) + n[1] * (pR[1] - p1[1]) + n[2] * (pR[2] - p1[2])) /
           (n[0] * dir[0] + n[1] * dir[1] + n[2] * dir[2]);
  const std::vector<Real> p2{(p1[0] + d * dir[0]),
                             (p1[1] + d * dir[1]),
                             (p1[2] + d * dir[2])};
  if (_debugMode==true)
  {
    for (size_t i = 0; i < map.size(); i++)     //write nodes to test point is on surface or not
    {
     std::cout<<"Slave Node #"<<i<<" : ("<<map[i][0]<<","<<map[i][1]<<","<<map[i][2]<<")"<<std::endl;
    }
    std::cout << "d : "<<d<< std::endl;
    std::cout << "target    : (" << p2[0] <<","<< p2[1] <<","<< p2[2] <<")"<< std::endl;
    std::cout<<"Slave Normal #: ("<<n[0]<<","<<n[1]<<","<<n[2]<<")"<<std::endl;
  }
  if (isOnSurface(p2,map))
    return true;
  else
    return false;
}

const bool
ViewFactorMonteCarlo::isSidetoSide(const std::map<unsigned int, std::vector<Real>> & master,
                         const std::map<unsigned int, std::vector<Real>> & slave) const
{
  std::map<unsigned int, std::vector<Real>> master_map = master;
  std::map<unsigned int, std::vector<Real>> slave_map = slave;
  const std::vector<Real> master_normal = getNormalFromNodeMap(master);
  const std::vector<Real> slave_normal = getNormalFromNodeMap(slave);
  // check whether faces are looking each other
  for (size_t i = 0; i < master.size(); i++)
  {
    const std::vector<Real> master_node = master_map[i];
    for (size_t j = 0; j < slave.size(); j++)
    {
      const std::vector<Real> slave_node = slave_map[j];
      const std::vector<Real> master_slave = {(slave_node[0]-master_node[0]),(slave_node[1]-master_node[1]),(slave_node[2]-master_node[2])};
      const std::vector<Real> slave_master = {(master_node[0]-slave_node[0]),(master_node[1]-slave_node[1]),(master_node[2]-slave_node[2])};
      Real theta_master_slave = getAngleBetweenVectors(master_normal,master_slave);
      Real theta_slave_master = getAngleBetweenVectors(slave_normal,slave_master);
      if (theta_slave_master<90 && theta_master_slave<90)
        return true;
    }
  }
  return false;
}

const bool
ViewFactorMonteCarlo::isVisible(const std::map<unsigned int, std::vector<Real>> & master,
                      const std::map<unsigned int, std::vector<Real>> & slave) const
{
  //check element sides are looking each other
  if (isSidetoSide(master,slave)==false)
  {
    return false;
  }
  // otherwise, check whether there is a surface between master and slave or not
  const std::vector<Real> master_center = getCenterPoint(master); // edges can be chosen instead
  const std::vector<Real> slave_center = getCenterPoint(slave);
  Real d = getDistanceBetweenPoints(master_center,slave_center);
  const Real dir_x = (slave_center[0]-master_center[0])/d;
  const Real dir_y = (slave_center[1]-master_center[1])/d;
  const Real dir_z = (slave_center[2]-master_center[2])/d;
  const std::vector<Real> dir{dir_x,dir_y,dir_z};
  Real d1 = getDistanceBetweenPoints(master_center,slave_center);
  Real d2{0};
  //loop over all elements in mesh,
  // first retrieve the side list form the mesh and loop over all element sides
  for (const auto & t : _mesh.buildSideList())    //buildSideList(el,side,bnd)
  {
    auto elem_id = std::get<0>(t);
    auto side_id = std::get<1>(t);
    auto bnd_id = std::get<2>(t);
    // std::cout << "------------bnd#: " << bc_id << std::endl;
    // std::cout << "-----------elem#: " << elem_id << std::endl;
    // std::cout << "-----------side#: " << side_id << std::endl;
    Elem * el = _mesh.elemPtr(elem_id);
    std::unique_ptr<const Elem> el_side = el->build_side_ptr(side_id);
    std::map<unsigned int, std::vector<Real>> side_map;
    unsigned int n_n = el_side->n_nodes();
    for (unsigned int i = 0; i < n_n; i++)
    {
      const Node * node = el_side->node_ptr(i);    //get nodes
      for (unsigned int j = 0; j < 3; j++)         // Define nodal coordinates and normals
      {
        side_map[i].push_back((*node)(j));
      }
      // std::cout <<"Node #"<<i<<" : ("<<(*n_ptr)(0)<<","<<(*n_ptr)(1)<<","<<(*n_ptr)(2)<<")\t";
    }
    const std::vector<Real> side_center = getCenterPoint(side_map);
    d2 = getDistanceBetweenPoints(master_center,side_center);
    // std::cout<<"d1= "<<d1<<" d2= "<<d2<<std::endl;
    // for better results node to node distances can be checked
    if (isSidetoSide(master,side_map) && isIntersected(master_center,dir,side_map) && d2<d1)
    {
      if (_debugMode==true)
      {
        std::cout<<"Boundary #"<<bnd_id<<" is blocking visibility."<<std::endl;
      }
      return false;
    }
  }
  return true;
}

void
ViewFactorMonteCarlo::printViewFactors()
{
  std::cout << " " << std::endl;
  std::cout << "============================ View Factors ============================"
            << std::endl;
  std::cout << "----------------------------------------------------------------------"
            << std::endl;
  Real elem_to_bnd_viewfactor{0};
  Real viewfactor{0};
  Real master_elem_number{0};
  for (const auto & master_boundary : _viewfactors_map)
  {
    auto master_boundary_map = _viewfactors_map[master_boundary.first];
    for (const auto & slave_boundary : master_boundary_map)
    {
      // if (_F[master_boundary.first][slave_boundary.first]==0)    // no need bec
      //   continue;
      auto slave_boundary_map = master_boundary_map[slave_boundary.first];
      viewfactor = 0;
      for (const auto & master_elem : slave_boundary_map)
      {
        elem_to_bnd_viewfactor = 0;
        auto master_elem_map = slave_boundary_map[master_elem.first];
        master_elem_number = slave_boundary_map.size();  //number of element in master boundary
        for (const auto & slave_elem : master_elem_map)
        {
          elem_to_bnd_viewfactor += slave_elem.second;
          std::cout << "Bnd " << master_boundary.first << " :\tElem " << master_elem.first << "  --->  "
                    << "Bnd " << slave_boundary.first << " :\tElem " << slave_elem.first
                    << "\tView Factor = " << slave_elem.second << std::endl;
        }
        std::cout << "\tElem " << master_elem.first << "  --->  "
                  << "Bnd " << slave_boundary.first << "\t  Total View Factor = " << elem_to_bnd_viewfactor
                  << "\n"<<std::endl;
        viewfactor += elem_to_bnd_viewfactor;
      }
      viewfactor /= master_elem_number;    //take average for elements on master boundary
      std::cout << "\t\tBnd " << master_boundary.first << "  --->  "
                << "Bnd " << slave_boundary.first << "\tAverage View Factor = " << viewfactor
                << std::endl;
      if (_parallel_planes_geometry.size()!=0)
      {
        std::cout << "\t\t\t\t\t   % Relative Error = " <<100*(viewfactor/getAnalyticalViewFactor(_parallel_planes_geometry)-1)<< std::endl;
      }
      std::cout << "----------------------------------------------------------------------"
                << std::endl;
    }
  }
}

void
ViewFactorMonteCarlo::printNodesNormals()
{
  for (const auto &boundary_id : _boundary_ids)    //bid : bid
  {
    const auto boundary_map = _coordinates_map[boundary_id];  //map[bid]
    const auto boundary_name = _mesh.getBoundaryName(boundary_id);
    for (const auto &elem : boundary_map)  // map : map
    {
      const auto elem_map = _coordinates_map[boundary_id][elem.first];
      std::cout << "--------------------------------------------------------------------------"<<
      std::endl; std::cout << "-------boundary #: " << boundary_id << " : "<<boundary_name<<
      std::endl; std::cout << "-----------elem #: " << elem.first << std::endl;
      for (auto node : elem_map)
      {
        std::cout <<"Node #"<<node.first<<" : ("<<(node.second)[0]<<","
                  <<(node.second)[1]<<","<<(node.second)[2]<<")\t"<<"Normal : ("
                  <<getNormalFromNodeMap(elem_map)[0]<<","
                  <<getNormalFromNodeMap(elem_map)[1]<<","
                  <<getNormalFromNodeMap(elem_map)[2]<<")"<<std::endl;
      }
    }
  }
}

void
ViewFactorMonteCarlo::initialize()
{
  std::srand(time(NULL));
  if (_debugMode==true)
  {
    std::cout << "---------------------- " <<std::endl;
    std::cout << "Analytical Value of View Factor"
              << "\nParallel planes with W1=" << _parallel_planes_geometry[0]
              << ", W2=" << _parallel_planes_geometry[1] << ", H=" << _parallel_planes_geometry[2]
              << std::endl;
    std::cout << "F = " << getAnalyticalViewFactor(_parallel_planes_geometry) << std::endl;
    std::cout << "---------------------- " << std::endl;
    std::cout << ": Defined Boundaries : " << std::endl;
    std::cout << "---------------------- " << std::endl;
  }
  //Check Element Type and Number of nodes
  ElemType elem_type = _current_elem->type();   //HEX8=10 QUAD4=5
  unsigned int n_elem = _current_elem->n_nodes();
  // std::cout << n_elem <<"-noded element (typeid="<<elem_type<<")"<< std::endl;
  // if (n_elem!=8)
  //   mooseError("ViewFactorMonteCarlo UserObject can only be used for 8-noded Hexagonal Elements");
}

void
ViewFactorMonteCarlo::execute()
{
  // LOOPING OVER ELEMENTS ON THE MASTER BOUNDARY
  // Define IDs
  BoundaryID current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  const auto current_boundary_name = _mesh.getBoundaryName(current_boundary_id);
  unsigned int current_element_id =(_current_elem->id());
  //Define Map for current boundary and current element and put Elem pointer for current element side
  // _element_set_ptr[current_boundary_id][current_element_id] = _current_side_elem;
  // _element_set[current_boundary_id][current_element_id] = _current_side_elem->n_nodes();
  // std::cout << "------------------------------"<< std::endl;
  // std::cout << "-------boundary #: " << current_boundary_id << " : "<<current_boundary_name<< std::endl;
  // std::cout << "-----------elem #: " << (_current_elem->id()) << std::endl;
  // std::cout << "-----------side #: " << (_current_side) << std::endl;
  //Loop over nodes on current element side
  unsigned int n = _current_side_elem->n_nodes();
  for (unsigned int i = 0; i < n; i++)
  {
    unsigned int _current_node_id = i;
    // const Node * node = _element_set_ptr[current_boundary_id][current_element_id]->node_ptr(i);    //get nodes
    const Node * node = _current_side_elem->node_ptr(i);    //get nodes
    for (unsigned int j = 0; j < 3; j++)         // Define nodal coordinates and normals
    {
      _coordinates_map[current_boundary_id][current_element_id][_current_node_id].push_back((*node)(j));
      // _normal_map[current_boundary_id][current_element_id][_current_node_id].push_back(_normals[i](j));
    }
    // std::cout <<"Node #"<<i<<" : ("<<(*node)(0)<<","<<(*node)(1)<<","<<(*node)(2)<<")\t";
    // std::cout <<" Normal : ("<<(normal)(0)<<","<<(normal)(1)<<","<<(normal)(2)<<")"<< std::endl;
  }
}
void
ViewFactorMonteCarlo::finalize()
{
  std::cout<<"Calculating View Factors"<<std::endl;
  std::cout<<"------------------------"<<std::endl;
  // for (auto master_bnd_id : _master_boundary_ids)
  for (auto master_bnd_id : _boundary_ids)
  {
    Real viewfactor{0};
    const auto master_boundary_map = _coordinates_map[master_bnd_id];
    // for (auto slave_bnd_id : _slave_boundary_ids)
    for (auto slave_bnd_id : _boundary_ids)
    {
      // std::cout<<_F[slave_bnd_id][master_bnd_id]<<std::endl;
      // if (_F[master_bnd_id][slave_bnd_id]!=0)  // fix this for identical surfaces
      //   continue;

      // if (master_bnd_id!=_master_boundary || slave_bnd_id!=_slave_boundary)  // fix this for identical surfaces
      //   continue;

      viewfactor = 0;
      const auto slave_boundary_map = _coordinates_map[slave_bnd_id];
      const auto master_bnd_name = _mesh.getBoundaryName(master_bnd_id);
      const auto slave_bnd_name = _mesh.getBoundaryName(slave_bnd_id);
      if (_debugMode==true)
      {
        std::cout << "-----------------------------------------" << std::endl;
        std::cout << "\t" << master_bnd_id << ":" << master_bnd_name << "  ->  " << slave_bnd_id << ":"
                  << slave_bnd_name << std::endl;
        std::cout << "-----------------------------------------" << std::endl;
      }
      for (auto master_elem : master_boundary_map)
      {
        const auto master_elem_map = _coordinates_map[master_bnd_id][master_elem.first];
        for (auto slave_elem : slave_boundary_map)
        {
          const auto slave_elem_map = _coordinates_map[slave_bnd_id][slave_elem.first];

          if (_F[slave_bnd_id][master_bnd_id]!=0)
          {
            //reciprocity
            Real master_elem_area = getArea(getCenterPoint(master_elem_map),master_elem_map);
            Real slave_elem_area = getArea(getCenterPoint(slave_elem_map),slave_elem_map);
            Real afsm = slave_elem_area/master_elem_area;
            Real Fsm = _viewfactors_map[slave_bnd_id][master_bnd_id][slave_elem.first][master_elem.first];
            _viewfactors_map[master_bnd_id][slave_bnd_id][master_elem.first][slave_elem.first] = afsm * Fsm;
            _viewfactors[master_elem.first][slave_elem.first] = afsm * Fsm;
            viewfactor += afsm * Fsm;
          }
          else
          {
            if (isVisible(master_elem_map,slave_elem_map))
            {
              // std::cout << "Element #" << master_elem.first << " -> Element #" << slave_elem.first
              //           << "...........done" << std::endl;
              if (_debugMode==true)
              {
                for (auto master_node : master_elem_map)
                {
                  std::cout <<"Master Node #"<<master_node.first<<" : ("<<(master_node.second)[0]<<","
                            <<(master_node.second)[1]<<","<<(master_node.second)[2]<<")"<<std::endl;
                }
              }
              const std::vector<Real> master_elem_normal = getNormalFromNodeMap(master_elem_map);
              if (_debugMode==true)
              {
                std::cout <<"Master Normal : (" << master_elem_normal[0]<<"," << master_elem_normal[1] <<","<< master_elem_normal[2]<<")" <<std::endl;
              }
              unsigned int counter{0};
              Real viewfactor_per_elem{0};
              Real viewfactor_per_src{0};
              for (size_t src = 0; src < _sourceNumber; src++)
              {
                viewfactor_per_src = 0;
                const std::vector<Real> source_point = getRandomPoint(master_elem_map);
                if (_debugMode==true)
                {
                  std::cout << "source_point: ("
                  <<source_point[0]<<","<<source_point[1]<<","<<source_point[2]<<")"<<std::endl;
                }
                counter = 0;
                for (size_t ray = 0; ray < _samplingNumber; ray++)
                {
                  const std::vector<Real> direction = getRandomDirection(master_elem_normal);
                  const Real theta = getAngleBetweenVectors(direction, master_elem_normal);   // in Degree
                  if (_debugMode==true)
                  {
                    std::cout << "direction: (" << direction[0] << "," << direction[1] << ","
                              << direction[2] << ")" << std::endl;
                    std::cout <<"theta : "<< theta << std::endl;
                  }
                  if (theta < 90) // check forward sampling, in direction of surface normal
                  {
                    if (isIntersected(source_point, direction, slave_elem_map)) // check Intersecting
                    {
                      counter++;
                      if (_debugMode==true)
                      {
                        std::cout << "!! Intersected !!" << std::endl;
                      }
                      // std::cout <<" Count:"<<counter<<std::endl;
                    }
                  }
                }
                viewfactor_per_src = (counter * 1.0) / _samplingNumber;
                viewfactor_per_elem += viewfactor_per_src;
              }
              viewfactor_per_elem *= (1.0/_sourceNumber);
              viewfactor += viewfactor_per_elem;
              if (_debugMode==true)
              {
                std::cout<<"\tElement View Factor = "<<viewfactor_per_elem<<std::endl;
              }
              _viewfactors_map[master_bnd_id][slave_bnd_id][master_elem.first][slave_elem.first] = viewfactor_per_elem;
              _viewfactors[master_elem.first][slave_elem.first] = viewfactor_per_elem;
            }
            else
            {
              _viewfactors_map[master_bnd_id][slave_bnd_id][master_elem.first][slave_elem.first] = 0;
              _viewfactors[master_elem.first][slave_elem.first]=0;
              viewfactor +=0;
              // std::cout << "Element #" << master_elem.first << " -> Element #" << slave_elem.first
              //           << "......invisible" << std::endl;
            }
          }
        }
        // std::cout << "Boundary #" <<master_bnd_id<<":Element #" << master_elem.first << " -> Boundary #" << slave_bnd_id
        //           << "...........done" << std::endl;
      }
      viewfactor *= (1.0/master_boundary_map.size());
      std::cout<<"F["<<master_bnd_id<<"]["<<slave_bnd_id<<"] = "<<viewfactor<<std::endl;
      _F[master_bnd_id][slave_bnd_id]=viewfactor;
    }
  }
  if (_printScreen==true)
    printViewFactors();
  if (_debugMode==true)
  {
    printViewFactors();
    printNodesNormals();
  }
}

Real ViewFactorMonteCarlo::getViewFactor(BoundaryID master_elem, BoundaryID slave_elem) const
{
  if (_viewfactors.find(master_elem) != _viewfactors.end())
  {
    if (_viewfactors.find(master_elem)->second.find(slave_elem) != _viewfactors.find(master_elem)->second.end())
      return _viewfactors.find(master_elem)->second.find(slave_elem)->second;
    else
      mooseError("Viewfactor requested for unknown slave boundary. Make sure UserObject is executed on timestep_begin and boundaries are defined in UserObject block.");
  }
  mooseError("Viewfactor requested for unknown master boundary. Make sure UserObject is executed on timestep_begin and boundaries are defined in UserObject block.");
  return 0;   //satisfy compiler
}
