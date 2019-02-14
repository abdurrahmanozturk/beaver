#ifndef VIEWFACTORBASE_H
#define VIEWFACTORBASE_H

#include "SideUserObject.h"

// Forward Declarations
class ViewFactorBase;

template <>
InputParameters validParams<ViewFactorBase>();

class ViewFactorBase : public SideUserObject
{
public:
  ViewFactorBase(const InputParameters & parameters);

  const Real getAngleBetweenVectors(const std::vector<Real> v1, const std::vector<Real> v2) const;
  const Real getDistanceBetweenPoints(const std::vector<Real> v1, const std::vector<Real> v2) const;
  const Real getAnalyticalViewFactor(const std::vector<Real> & v);
  const Real getArea(const std::vector<Real> &p, std::map<unsigned int, std::vector<Real> > map) const;
  const Real getVectorLength(const std::vector<Real> & v) const;

  const std::vector<Real> getNormalFromNodeMap(std::map<unsigned int, std::vector<Real> > map) const;
  const std::vector<Real> getCenterPoint(std::map<unsigned int, std::vector<Real> > map) const;
  const std::vector<Real> getRandomPoint(std::map<unsigned int, std::vector<Real> > map) const;
  const std::vector<Real> getRandomDirection(const std::vector<Real> & n, const int dim=3) const;
  const std::set<BoundaryID> & getMasterBoundaries() const;
  const std::set<BoundaryID> & getSlaveBoundaries() const;
  const std::map<unsigned int, std::vector<Real>> getSideMap(const Elem * elem,
                                                             const unsigned int side) const;
  const bool isOnSurface(const std::vector<Real> &p, std::map<unsigned int, std::vector<Real>> map) const;
  const bool isIntersected(const std::vector<Real> & p1,
                           const std::vector<Real> & dir,
                           std::map<unsigned int, std::vector<Real>> map) const;
  const bool isSidetoSide(const std::map<unsigned int, std::vector<Real>> & master,
                          const std::map<unsigned int, std::vector<Real>> & slave) const;
  const bool isVisible(const std::map<unsigned int, std::vector<Real>> & master,
                          const std::map<unsigned int, std::vector<Real>> & slave) const;
  const Real doMonteCarlo(std::map<unsigned int, std::vector<Real>> master_elem_map,
                          std::map<unsigned int, std::vector<Real>> slave_elem_map,
                          unsigned int _sourceNumber, unsigned int _samplingNumber);
  void printViewFactors();

protected:
  const MooseArray<Point> & _current_normals;
  std::set<BoundaryID>  _boundary_ids;
  const std::set<BoundaryID> _mesh_boundary_ids;
  const std::set<BoundaryID> _mesh_sideset_ids;
  const std::set<BoundaryID> _mesh_nodeset_ids;
  const double _PI;
  const bool _debugMode;
  const bool _printScreen;
  const Real _error_tol;   //tolerance
  std::map<BoundaryID, std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, Real>>>> _viewfactors_map;
  std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, std::vector<Real> > > > _coordinates_map;
  std::vector<BoundaryName> _master_boundary_names,_slave_boundary_names;
  std::set<BoundaryID> _master_boundary_ids,_slave_boundary_ids;
  std::map<BoundaryID, std::map<BoundaryID, Real>> _F;   //bnd-bnd viewfactors
  std::map<unsigned int, std::map<unsigned int, Real>> _viewfactors;  //elem-elem viewfactors
};

#endif // VIEWFACTORBASE_H
