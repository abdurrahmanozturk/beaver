#include "ViewFactorBase.h"
#include "MooseRandom.h"

template <>
InputParameters
validParams<ViewFactorBase>()
{
  InputParameters params = validParams<UserObject>();
  params += validParams<BoundaryRestrictableRequired>();
  params += validParams<MaterialPropertyInterface>();
  params.addParam<bool>("debug_mode",false, "Print everything to screen for debugging");
  params.addParam<bool>("print_screen",false, "Print View Factors to Screen");
  params.addParam<Real>("error_tolerance",1e-6, "Tolerance for calculations");
  params.addParam<std::vector<BoundaryName>>("master_boundary", "Master Boundary ID");
  params.addParam<std::vector<BoundaryName>>("slave_boundary", "Slave Boundary ID");
  return params;
}

ViewFactorBase::ViewFactorBase(const InputParameters & parameters)
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
    _master_boundary_names(getParam<std::vector<BoundaryName>>("master_boundary")),
    _slave_boundary_names(getParam<std::vector<BoundaryName>>("slave_boundary"))
{
    if (_master_boundary_names.size()!=0 && _slave_boundary_names.size()!=0)
    {
      _boundary_ids.clear();   //use master and slave boundaries if they are given in input file
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
ViewFactorBase::getMasterBoundaries() const
{
  return _master_boundary_ids;
}

const std::set<BoundaryID> &
ViewFactorBase::getSlaveBoundaries() const
{
  return _slave_boundary_ids;
}

const std::map<unsigned int, std::vector<Point>>
ViewFactorBase::getSideMap(const Elem * elem,const unsigned int side) const
{
  std::unique_ptr<const Elem> elem_side = elem->build_side_ptr(side); //define side pointer
  std::map<unsigned int, std::vector<Point>> side_map;  //define an empty map of vectors
  unsigned int n_n = elem_side->n_nodes();       //define number of nodes in side
  for (unsigned int i = 0; i < n_n; i++)         // loop over nodes
  {
    const Node * node = elem_side->node_ptr(i);  // define pointer for node i
    Point node_p((*node)(0), (*node)(1), (*node)(2));
    side_map[i].push_back(node_p);
  }
  return side_map;
}

const Point
ViewFactorBase::getNormal(std::map<unsigned int, std::vector<Point>> map) const
{
  // three points in plane
  Point p1 = map[0][0];
  Point p2 = map[1][0];
  Point p3 = map[2][0];
    //find 2 vectors in surface
  Point v12(p2-p1);
  Point v13(p3-p1);
  //cross product of vectors gives surface normal
  Point n(v12.cross(v13));
  //normalization
  n /= n.norm();
  return n;
}

const Point
ViewFactorBase::getCenterPoint(std::map<unsigned int, std::vector<Point> > map) const
{
  unsigned int n=map.size();
  Point center(0,0,0);
  for (size_t i = 0; i < n; i++)
  {
    center += map[i][0];
  }
  center /= n;
  return center;
}

const Real
ViewFactorBase::getArea(const Point &p, std::map<unsigned int, std::vector<Point>> map) const
{
  //FIND AREA OF ELEMENT SURFACE by summing area of triangles
  unsigned int n = map.size();    // number of nodes in element surface
  // std::cout<<" n= "<<n<<std::endl;
  Real area{0};
  for (size_t i = 0; i < n; i++)    //create triangle and calculate area
  {
    const Point node1 = map[i][0];
    const Point node2 = map[(i+1)%n][0];
    const Point v1(node1-p);
    const Point v2(node2-p);
    const Real theta = acos((v1*v2)/(v1.norm()*v2.norm())); // Radian
    area += 0.5 * v1.norm() * v2.norm() * sin(theta);
  }
  return area;
}

const Point
ViewFactorBase::getRandomDirection(const Point & n,const int dim) const
{
  //find theta and phi for unit normal vector in global coordinate system
  Real theta_normal = acos(n(2));
  Real phi_normal{0};
  if (theta_normal!=0)
  {
    if (n(1)<0)
    {
      phi_normal = 2 * _PI-acos(n(0)/sin(theta_normal));
    }
    else
    {
      phi_normal = acos(n(0)/sin(theta_normal));
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
  const Point dir_global(sin(theta)*cos(phi),sin(theta)*sin(phi),cos(theta));
  // transform global direction to local direction
  const Point dir_local((Rlocal[0][0]*dir_global(0)+Rlocal[0][1]*dir_global(1)+Rlocal[0][2]*dir_global(2)),
                        (Rlocal[1][0]*dir_global(0)+Rlocal[1][1]*dir_global(1)+Rlocal[1][2]*dir_global(2)),
                        (Rlocal[2][0]*dir_global(0)+Rlocal[2][1]*dir_global(1)+Rlocal[2][2]*dir_global(2)));
  return dir_local;
}

const bool
ViewFactorBase::isOnSurface(const Point &p, std::map<unsigned int, std::vector<Point>> map) const
{
  // std::cout<<"checkpoint_isOnSurface1"<<std::endl;
  const Point center{getCenterPoint(map)};
  Real elem_area = getArea(center,map);
  Real area = getArea(p,map);
  // std::cout << "Slave Element Surface Area ="<< slave_area << std::endl;
  // std::cout << "Calcualted Surface Area ="<< area << std::endl;
  // std::cout << "Area Residual ="<<area - slave_area<< std::endl;

  if ((area-elem_area)<_error_tol)
    return true;
  else
    return false;
}

const Point
ViewFactorBase::getRandomPoint(std::map<unsigned int, std::vector<Point>> map) const
{
  const Point n = getNormal(map);
  const Point center{getCenterPoint(map)};
  Real rad{0},d{0};  //radius, distance
  for (size_t i = 0; i < map.size(); i++)   //find max distance to surrounding nodes
  {
    Point p = map[i][0];
    d = (p-center).norm();
    if (d>rad)
      rad=d;
  }
  // std::cout<<"r = "<<r<<std::endl;
  // std::cout<<"center = ("<<center[0]<<","<<center[1]<<","<<center[2]<<")"<<std::endl;
  while (true)
  {
    const Real rand_r = std::rand() / (1. * RAND_MAX);
    const Real r =rad * std::sqrt(rand_r);
    const Point dir(getRandomDirection(n,2));
    // std::cout<<"dir=("<<dir[0]<<","<<dir[1]<<","<<dir[2]<<")"<<std::endl;
    const Point p(center + r*dir);
    // std::cout<<"sampled point = ("<<p[0]<<","<<p[1]<<","<<p[2]<<")"<<std::endl;
    if (isOnSurface(p,map))
      return p;
  }
}

const bool
ViewFactorBase::isIntersected(const Point & p1,
                              const Point & dir,
                              std::map<unsigned int, std::vector<Point>> map) const
{
  // std::cout<<"checkpoint_isintersected1"<<std::endl;
  const Point n = getNormal(map);
  const Point pR = getRandomPoint(map);
  Real d = (n*(pR-p1))/(n*dir);
  const Point p2(p1 + d*dir);
  if (_debugMode==true)
  {
    for (size_t i = 0; i < map.size(); i++)     //write nodes to test point is on surface or not
    {
     std::cout<<"Slave Node #"<<i<<" : ("<<map[i][0](0)<<","<<map[i][0](1)<<","<<map[i][0](2)<<")"<<std::endl;
    }
    std::cout << "d : "<<d<< std::endl;
    std::cout << "target    : (" << p2(0) <<","<< p2(1) <<","<< p2(2) <<")"<< std::endl;
    std::cout<<"Slave Normal #: ("<<n(0)<<","<<n(1)<<","<<n(2)<<")"<<std::endl;
  }
  // std::cout<<"checkpoint_isintersected2"<<std::endl;
  if (isOnSurface(p2,map))
    return true;
  else
    return false;
  // std::cout<<"checkpoint_isintersected3"<<std::endl;
}

const bool
ViewFactorBase::isSidetoSide(const std::map<unsigned int, std::vector<Point>> & master_side_map,
                             const std::map<unsigned int, std::vector<Point>> & slave_side_map) const
{
  // std::cout<<"checkpoint_isSidetoSide1"<<std::endl;
  std::map<unsigned int, std::vector<Point>> master_map = master_side_map;
  std::map<unsigned int, std::vector<Point>> slave_map = slave_side_map;
  const Point master_normal = getNormal(master_side_map);
  const Point slave_normal = getNormal(slave_side_map);
  // check whether faces are looking each other
  for (size_t i = 0; i < master_side_map.size(); i++)
  {
    const Point master_node = master_map[i][0];
    // std::cout<<"checkpoint_isSidetoSide2"<<std::endl;
    for (size_t j = 0; j < slave_side_map.size(); j++)
    {
      const Point slave_node = slave_map[j][0];
      const Point master_slave = (slave_node - master_node);
      const Point slave_master = (master_node - slave_node);
      const Real theta_master_slave = acos((master_normal*master_slave)/(master_normal.norm()*master_slave.norm())); //Radian
      const Real theta_slave_master = acos((slave_normal*slave_master)/(slave_normal.norm()*slave_master.norm()));  //Radian
      // std::cout<<"checkpoint_isSidetoSide3"<<std::endl;
      if (theta_slave_master<_PI/2 && theta_master_slave<_PI/2)
        return true;
    }
  }
  return false;
}

const bool
ViewFactorBase::isVisible(const std::map<unsigned int, std::vector<Point>> & master_side_map,
                          const std::map<unsigned int, std::vector<Point>> & slave_side_map) const
{
  //check element sides are looking at each other
  // std::cout<<"checkpoint_isvisible1"<<std::endl;
  if (isSidetoSide(master_side_map, slave_side_map) == false)
  {
    return false;
  }
  // otherwise, check whether there is a surface between master and slave or not
  const Point master_center = getCenterPoint(master_side_map); // edges can be chosen instead
  const Point slave_center = getCenterPoint(slave_side_map);
  Real d1 = (master_center - slave_center).norm();
  Point dir = (slave_center - master_center)/d1;
  Real d2{0};
  //loop over all elements in mesh,
  //first retrieve the side list form the mesh and loop over all element sides
  // std::cout<<"checkpoint_isvisible2"<<std::endl;
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
    std::map<unsigned int, std::vector<Point>> side_map;
    unsigned int n_n = el_side->n_nodes();
    // std::cout<<"checkpoint_isvisible3"<<std::endl;
    for (unsigned int i = 0; i < n_n; i++)
    {
      // std::cout<<"checkpoint_isvisible4"<<std::endl;
      const Node * node = el_side->node_ptr(i);  // define pointer for node i
      Point node_p((*node)(0), (*node)(1), (*node)(2));
      side_map[i].push_back(node_p);
      // std::cout <<"Node #"<<i<<" : ("<<(*n_ptr)(0)<<","<<(*n_ptr)(1)<<","<<(*n_ptr)(2)<<")\t";
    }
    const Point side_center = getCenterPoint(side_map);
    d2 = (master_center - side_center).norm();
    // std::cout<<"d1= "<<d1<<" d2= "<<d2<<std::endl;
    // for better results node to node distances can be checked
    // std::cout<<"checkpoint_isvisible5"<<std::endl;
    if (isSidetoSide(master_side_map, side_map) && isIntersected(master_center, dir, side_map) &&
        d2 < d1)
    {
      if (_debugMode==true)
      {
        std::cout<<"Boundary #"<<bnd_id<<" is blocking visibility."<<std::endl;
      }
      // std::cout<<"checkpoint_isvisible7"<<std::endl;
      return false;
    }
  }
  // std::cout<<"checkpoint_isvisible8"<<std::endl;
  return true;
}

void
ViewFactorBase::printViewFactors()
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
          if (slave_elem.second==0)
            continue;
          // std::cout << "Bnd " << master_boundary.first << " :\tElem " << master_elem.first << "          --->  "
          //           << "Bnd " << slave_boundary.first << " :\tElem " << slave_elem.first
          //           << "\tView Factor = " << slave_elem.second << std::endl;
        }
        viewfactor += elem_to_bnd_viewfactor;
        if (elem_to_bnd_viewfactor==0)
          continue;
        // std::cout << "\tElem " << master_elem.first << "  --->  "
        //           << "Bnd " << slave_boundary.first << "\t  Total View Factor = " <<
        //           elem_to_bnd_viewfactor
        //           << "\n"<<std::endl;
      }
      viewfactor /= master_elem_number;    //take average for elements on master boundary
      std::cout << "\t\tBnd " << master_boundary.first << "\t--->\t"
                << "Bnd " << slave_boundary.first << "\tAverage View Factor = " << viewfactor
                << std::endl;
      std::cout << "----------------------------------------------------------------------"
                << std::endl;
    }
  }
}

const Real
ViewFactorBase::doMonteCarlo(std::map<unsigned int, std::vector<Point>> master_side_map,
                             std::map<unsigned int, std::vector<Point>> slave_side_map,
                             unsigned int _sourceNumber,
                             unsigned int _samplingNumber)
{
  // std::cout<<"checkpoint_doMonteCarlo1"<<std::endl;
  const Point master_elem_normal = getNormal(master_side_map);
  unsigned int counter{0};
  Real viewfactor_per_elem{0};
  Real viewfactor_per_src{0};
  for (size_t src = 0; src < _sourceNumber; src++)
  {
    viewfactor_per_src = 0;
    const Point source_point = getRandomPoint(master_side_map);
    counter = 0;
    // std::cout<<"checkpoint_doMonteCarlo2"<<std::endl;
    for (size_t ray = 0; ray < _samplingNumber; ray++)
    {
      const Point direction = getRandomDirection(master_elem_normal);
      const Real theta = acos((direction*master_elem_normal)/(direction.norm()*master_elem_normal.norm())); // Radian
      if (theta < _PI/2) // check forward sampling, in direction of surface normal
      {
        if (isIntersected(source_point, direction, slave_side_map)) // check Intersecting
        {
          counter++;
        }
      }
    }
    viewfactor_per_src = (counter * 1.0) / _samplingNumber;
    viewfactor_per_elem += viewfactor_per_src;
  }
  viewfactor_per_elem *= (1.0/_sourceNumber);
  // std::cout<<"checkpoint_doMonteCarlo3"<<std::endl;
  return viewfactor_per_elem;
}
