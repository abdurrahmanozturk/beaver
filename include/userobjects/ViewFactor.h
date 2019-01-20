#ifndef VIEWFACTOR_H
#define VIEWFACTOR_H

#include <vector>
#include "SideUserObject.h"
#include "MooseMesh.h"

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
  virtual void threadJoin(const UserObject & y) override {}

  const std::vector<Real> findNormalFromNodeMap(std::map<unsigned int, std::vector<Real> > map);
  const Real angleBetweenVectors(const std::vector<Real> v1, const std::vector<Real> v2);
  const std::vector<Real> getRandomPoint(std::map<unsigned int, std::vector<Real> > map);
  const std::vector<Real> getRandomDirection(const std::vector<Real> & normal);
  const Real getAnalyticalViewFactor(const std::vector<Real> & v);
  // const std::map<BoundaryID, std::map<BoundaryID, Real> > getBoundarViewFactors(const
  // std::map<BoundaryID, std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, Real >
  // > > > &map);
  const bool isVisible(const std::map<unsigned int, std::vector<Real>> & master,
                       const std::map<unsigned int, std::vector<Real>> & slave);
  const bool isIntersected(const std::vector<Real> & p1,
                           const std::vector<Real> & dir,
                           const std::map<unsigned int, std::vector<Real>> & map);
  void printViewFactors();
  unsigned int _qp;
  const double _PI;
  unsigned int _samplingNumber;
  std::vector<Real> _parallel_planes_geometry;
  Point p;
  Point q;
  // MooseRandom _random;
  const MooseArray<Point> & _current_normals;
  const std::set<BoundaryID> & _boundary_ids;
  const std::vector<BoundaryName> & _boundary_list;
  std::map<BoundaryID, std::map<unsigned int, const Elem *> > _element_side;
  std::map<BoundaryID, std::map<unsigned int, unsigned int> > _element_set;
  std::map<BoundaryID, std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, Real>>>>
      _element_viewfactors;
  std::map<BoundaryID, std::map<BoundaryID, Real>> _viewfactors;
  // std::map<unsigned int, std::map<unsigned int, unsigned int> > _view_factor_set;
  std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, std::vector<Real> > > > _node_set;
  std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, std::vector<Real> > > > _normal_set;
};

#endif // VIEWFACTOR_H
