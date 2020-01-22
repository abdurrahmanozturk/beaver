#ifndef VIEWFACTORBASE_H
#define VIEWFACTORBASE_H

#include "SideUserObject.h"

// Forward Declarations
class MonteCarloViewFactorBase;

template <>
InputParameters validParams<MonteCarloViewFactorBase>();

class MonteCarloViewFactorBase : public SideUserObject
{
public:
  MonteCarloViewFactorBase(const InputParameters & parameters);

  // const Real getVectorLength(const Point & v) const;
  // const Real getAngleBetweenVectors(const Point v1, const Point v2) const;
  // const Real getDistanceBetweenPoints(const Point v1, const Point v2) const;
  const Real getArea(const Point &p, std::map<unsigned int, std::vector<Point> > map) const;
  const Point getNormal(std::map<unsigned int, std::vector<Point>> map) const;
  const Point getCenterPoint(std::map<unsigned int, std::vector<Point> > map) const;
  const Point getRandomPoint(std::map<unsigned int, std::vector<Point> > map) const;
  const Point getRandomDirection(const Point & n, const int dim=3) const;
  const std::set<BoundaryID> & getMasterBoundaries() const;
  const std::set<BoundaryID> & getSlaveBoundaries() const;
  const std::map<unsigned int, std::vector<Point>> getSideMap(const Elem * elem,
                                                             const unsigned int side) const;
  const bool isOnSurface(const Point & p,
                         std::map<unsigned int, std::vector<Point>> map) const;
  const bool isIntersected(const Point & p1,
                           const Point & dir,
                           std::map<unsigned int, std::vector<Point>> map) const;
  const bool isSidetoSide(const std::map<unsigned int, std::vector<Point>> & master_side_map,
                          const std::map<unsigned int, std::vector<Point>> & slave_side_map) const;
  const bool isVisible(const std::map<unsigned int, std::vector<Point>> & master_side_map,
                       const std::map<unsigned int, std::vector<Point>> & slave_side_map) const;
  const Real doMonteCarlo(std::map<unsigned int, std::vector<Point>> master_side_map,
                          std::map<unsigned int, std::vector<Point>> slave_side_map,
                          unsigned int _sourceNumber,
                          unsigned int _samplingNumber);
  void printViewFactors();

protected:
  // const MooseArray<Point> & _current_normals;
  std::set<BoundaryID>  _boundary_ids;
  const std::set<BoundaryID> _mesh_boundary_ids;
  const std::set<BoundaryID> _mesh_sideset_ids;
  const std::set<BoundaryID> _mesh_nodeset_ids;
  const double _PI;
  const bool _debugMode;
  const bool _printScreen;
  const Real _error_tol;   //tolerance
  std::map<BoundaryID, std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, Real>>>> _viewfactors_map;
  std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, std::vector<Point> > > > _coordinates_map;
  std::vector<BoundaryName> _master_boundary_names,_slave_boundary_names;
  std::set<BoundaryID> _master_boundary_ids,_slave_boundary_ids;
  std::map<BoundaryID, std::map<BoundaryID, Real>> _F;   //bnd-bnd viewfactors
  std::map<unsigned int, std::map<unsigned int, Real>> _viewfactors;  //elem-elem viewfactors
};

#endif // VIEWFACTORBASE_H
