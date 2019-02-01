#ifndef VIEWFACTOR_H
#define VIEWFACTOR_H

#include "SideUserObject.h"

// Forward Declarations
class ViewFactor;

template <>
InputParameters validParams<ViewFactor>();

class ViewFactor : public SideUserObject
{
public:
  ViewFactor(const InputParameters & parameters);
  virtual void initialize() override;
  virtual void execute() override;
  virtual void finalize() override;
  virtual Real getViewFactor();
  virtual void threadJoin(const UserObject & y) override {}

  const Real getAngleBetweenVectors(const std::vector<Real> v1, const std::vector<Real> v2);
  const Real getDistanceBetweenVectors(const std::vector<Real> v1, const std::vector<Real> v2);
  const Real getAnalyticalViewFactor(const std::vector<Real> & v);
  const Real getArea(const std::vector<Real> &p, std::map<unsigned int, std::vector<Real> > map);
  const Real getVectorLength(const std::vector<Real> & v);

  const std::vector<Real> getNormalFromNodeMap(std::map<unsigned int, std::vector<Real> > map);
  const std::vector<Real> getCenterPoint(std::map<unsigned int, std::vector<Real> > map);
  const std::vector<Real> getRandomPoint(std::map<unsigned int, std::vector<Real> > map);
  const std::vector<Real> getRandomDirection(const std::vector<Real> & n, const int dim=3);
  // const std::map<BoundaryID, std::map<BoundaryID, Real> > getBoundarViewFactors(const
  // std::map<BoundaryID, std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, Real >
  // > > > &map);
  const bool isOnSurface(const std::vector<Real> &p, std::map<unsigned int, std::vector<Real>> map);
  const bool isVisible(const std::map<unsigned int, std::vector<Real>> & master,
                       const std::map<unsigned int, std::vector<Real>> & slave);
  const bool isIntersected(const std::vector<Real> & p1,
                           const std::vector<Real> & dir,
                           std::map<unsigned int, std::vector<Real>> map);
  void printViewFactors();
  void printNodesNormals();
  // unsigned int _qp;
  // Point p;
  // Point q;
  const MooseArray<Point> & _current_normals;
  const std::set<BoundaryID> & _boundary_ids;
  const double _PI;
  const bool _printScreen;
  const Real _area_tol;   //area tolerance
  const unsigned int _samplingNumber,_sourceNumber;
  std::vector<Real> _parallel_planes_geometry;
  std::vector<BoundaryID> _boundary_list;
  // BoundaryID _master_boundary,_slave_boundary;
  std::map<BoundaryID, std::map<BoundaryID, Real>> _F;   //bnd-bnd viewfactors
  std::map<unsigned int, std::map<unsigned int, Real>> _viewfactors;  //elem-elem viewfactors
  std::map<BoundaryID, std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, Real>>>> _viewfactors_map;
  std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, std::vector<Real> > > > _coordinates_map;
  // std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, std::vector<Real> > > > _normal_map;
  // std::map<BoundaryID, std::map<unsigned int, const Elem *> > _element_set_ptr;
  // std::map<BoundaryID, std::map<unsigned int, unsigned int> > _element_set;
};

#endif // VIEWFACTOR_H
