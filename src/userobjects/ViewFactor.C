#include <vector>
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
  params.addParam<unsigned int>("sampling_number",100, "Number of Sampling");
  params.addParam<unsigned int>("source_number",100, "Number of Source Points");
  params.addParam<bool>("print_screen",false, "Print to Screen");
  params.addParam<Real>("area_tolerance",1e-6, "Area Calculation Tolerance");
  params.addParam<std::vector<Real>>("parallel_planes",
                                     "{W1,W2,H} values for parallel planes to calculate view factor analytically");
  // params.addRequiredParam<std::vector<BoundaryName>>("master_boundary", "Master Boundary ID");
  // params.addRequiredParam<std::vector<BoundaryName>>("slave_boundary", "Slave Boundary ID");
  return params;
}

ViewFactor::ViewFactor(const InputParameters & parameters)
  : SideUserObject(parameters),
    _current_normals(_assembly.normals()),
    _boundary_ids(boundaryIDs()),
    _PI(acos(-1)), // 3.141592653589793238462643383279502884
    _printScreen(getParam<bool>("print_screen")),
    _area_tol(getParam<Real>("area_tolerance")),
    _samplingNumber(getParam<unsigned int>("sampling_number")),
    _sourceNumber(getParam<unsigned int>("source_number")),
    _parallel_planes_geometry(getParam<std::vector<Real>>("parallel_planes"))
    // _master_boundary(getParam<std::vector<BoundaryName>>("master_boundary")),
    // _slave_boundary(getParam<std::vector<BoundaryName>>("slave_boundary"))
{
}

const Real
ViewFactor::getAngleBetweenVectors(const std::vector<Real> v1, const std::vector<Real> v2)
{
  Real v1_length = pow((v1[0]*v1[0]+v1[1]*v1[1]+v1[2]*v1[2]),0.5);
  Real v2_length = pow((v2[0]*v2[0]+v2[1]*v2[1]+v2[2]*v2[2]),0.5);
  Real v12_dot = v1[0]*v2[0]+v1[1]*v2[1]+v1[2]*v2[2];
  Real theta = acos(v12_dot/(v1_length*v2_length));  //Radian
  theta *= (180/_PI);
  return theta;
}

const Real
ViewFactor::getDistanceBetweenPoints(const std::vector<Real> v1, const std::vector<Real> v2)
{
  Real d = pow(((v2[0]-v1[0])*(v2[0]-v1[0])
               +(v2[1]-v1[1])*(v2[1]-v1[1])
               +(v2[2]-v1[2])*(v2[2]-v1[2])),0.5);
  return d;
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

const Real
ViewFactor::getVectorLength(const std::vector<Real> & v)
{
  return pow((v[0]*v[0]+v[1]*v[1]+v[2]*v[2]),0.5);
}

const std::vector<Real>
ViewFactor::getNormalFromNodeMap(std::map<unsigned int, std::vector<Real> > map)
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
ViewFactor::getCenterPoint(std::map<unsigned int, std::vector<Real> > map)
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
ViewFactor::getRandomDirection(const std::vector<Real> & n,const int dim)
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
ViewFactor::getArea(const std::vector<Real> &p, std::map<unsigned int, std::vector<Real>> map)
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
ViewFactor::isOnSurface(const std::vector<Real> &p, std::map<unsigned int, std::vector<Real>> map)
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

  if ((area-elem_area)<_area_tol)
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
ViewFactor::getRandomPoint(std::map<unsigned int, std::vector<Real>> map)
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
  while(true)
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
ViewFactor::isIntersected(const std::vector<Real> & p1,
                          const std::vector<Real> & dir,
                          std::map<unsigned int, std::vector<Real>> map)
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
  if (_printScreen==true)
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
ViewFactor::isVisible(const std::map<unsigned int, std::vector<Real>> & master,
                      const std::map<unsigned int, std::vector<Real>> & slave)
{
  const std::vector<Real> master_normal = getNormalFromNodeMap(master);
  const std::vector<Real> slave_normal = getNormalFromNodeMap(slave);
  for (size_t i = 0; i < 1000; i++) // check visibility for different points
  {
    const std::vector<Real> master_point = getRandomPoint(master);
    const std::vector<Real> slave_point = getRandomPoint(slave);
    const std::vector<Real> master_slave = {(slave_point[0]-master_point[0]),(slave_point[1]-master_point[1]),(slave_point[2]-master_point[2])};
    const std::vector<Real> slave_master = {(master_point[0]-slave_point[0]),(master_point[1]-slave_point[1]),(master_point[2]-slave_point[2])};
    Real theta_master_slave = getAngleBetweenVectors(master_normal,master_slave);
    Real theta_slave_master = getAngleBetweenVectors(slave_normal,slave_master);
    if (theta_slave_master<90 && theta_master_slave<90)
      return true;
  }
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
  Real viewfactor{0};
  Real master_elem_number{0};
  for (const auto & master_boundary : _viewfactors_map)
  {
    auto master_boundary_map = _viewfactors_map[master_boundary.first];
    for (const auto & slave_boundary : master_boundary_map)
    {
      if (_F[master_boundary.first][slave_boundary.first]==0)    // no need bec
        continue;
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
      std::cout << "\t\t\t\t\t   % Relative Error = " <<100*(viewfactor/getAnalyticalViewFactor(_parallel_planes_geometry)-1)<< std::endl;
      std::cout << "----------------------------------------------------------------------"
                << std::endl;
    }
  }
}

void
ViewFactor::printNodesNormals()
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
ViewFactor::initialize()
{
  //Check Element Type and Number of nodes
  std::srand(time(NULL));

  if (_printScreen==true)
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
    for (const auto bid : _boundary_ids)
    {
      _boundary_list.push_back(bid);
      std::cout << "id: " << bid <<" name: "<<_mesh.getBoundaryName(bid)<< std::endl;
    }
  }
  ElemType elem_type = _current_elem->type();   //HEX8=10 QUAD4=5
  unsigned int n_elem = _current_elem->n_nodes();
  std::cout << n_elem <<"-noded element (typeid="<<elem_type<<")"<< std::endl;
  // if (n_elem!=8)
  //   mooseError("ViewFactor UserObject can only be used for 8-noded Hexagonal Elements");
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
ViewFactor::finalize()
{
  for (auto master_bnd_id : _boundary_ids)
  {
    Real viewfactor{0};
    const auto master_boundary_map = _coordinates_map[master_bnd_id];
    for (auto slave_bnd_id : _boundary_ids)
    {
      // std::cout<<_F[slave_bnd_id][master_bnd_id]<<std::endl;
      // if ((_F[slave_bnd_id][master_bnd_id]!=0) || (slave_bnd_id==master_bnd_id))  // fix this for identical surfaces

      viewfactor = 0;
      const auto slave_boundary_map = _coordinates_map[slave_bnd_id];
      const auto master_bnd_name = _mesh.getBoundaryName(master_bnd_id);
      const auto slave_bnd_name = _mesh.getBoundaryName(slave_bnd_id);
      std::cout << "-----------------------------------------" << std::endl;
      std::cout << "\t" << master_bnd_id << ":" << master_bnd_name << "  ->  " << slave_bnd_id << ":"
                << slave_bnd_name << std::endl;
      std::cout << "-----------------------------------------" << std::endl;
      for (auto master_elem : master_boundary_map)
      {
        const auto master_elem_map = _coordinates_map[master_bnd_id][master_elem.first];
        for (auto slave_elem : slave_boundary_map)
        {
          const auto slave_elem_map = _coordinates_map[slave_bnd_id][slave_elem.first];
          if (isVisible(master_elem_map,slave_elem_map))
          {
            // std::cout << "Element #" << master_elem.first << " -> Element #" << slave_elem.first
            //           << "...........done" << std::endl;
            if (_printScreen==true)
            {
              for (auto master_node : master_elem_map)
              {
                std::cout <<"Master Node #"<<master_node.first<<" : ("<<(master_node.second)[0]<<","
                          <<(master_node.second)[1]<<","<<(master_node.second)[2]<<")"<<std::endl;
              }
            }
            const std::vector<Real> master_elem_normal = getNormalFromNodeMap(master_elem_map);
            if (_printScreen==true)
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
              if (_printScreen==true)
              {
                std::cout << "source_point: ("
                <<source_point[0]<<","<<source_point[1]<<","<<source_point[2]<<")"<<std::endl;
              }
              counter = 0;
              for (size_t ray = 0; ray < _samplingNumber; ray++)
              {
                const std::vector<Real> direction = getRandomDirection(master_elem_normal);
                const Real theta = getAngleBetweenVectors(direction, master_elem_normal);   // in Degree
                if (_printScreen==true)
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
                    if (_printScreen==true)
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
            if (_printScreen==true)
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
        // std::cout << "Boundary #" <<master_bnd_id<<":Element #" << master_elem.first << " -> Boundary #" << slave_bnd_id
        //           << "...........done" << std::endl;
      }
      viewfactor *= (1.0/master_boundary_map.size());
      // std::cout << "-----------------------------------------" << std::endl;
      std::cout<<"F"<<master_bnd_id<<slave_bnd_id<<" = "<<viewfactor<<std::endl;
      _F[master_bnd_id][slave_bnd_id]=viewfactor;
    }
  }
  // printViewFactors();
  if (_printScreen==true)
  {
    printViewFactors();
    printNodesNormals();
  }
}

Real ViewFactor::getViewFactor()
{
  return _F[_boundary_list[0]][_boundary_list[1]];
}
