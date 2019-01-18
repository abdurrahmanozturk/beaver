#ifndef VIEWFACTOR_H
#define VIEWFACTOR_H

#include <vector>
#include "SideUserObject.h"
#include "MooseRandom.h"
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

  unsigned int _qp;
  Real rand_x, rand_y, rand_z;
  Real px, px1, px2, py, py1, py2, pz, pz1, pz2;
  Point p;
  Point q;
  MooseRandom _random;
  const MooseArray<Point> & _current_normals;
  const std::set<BoundaryID> & _boundary_ids;
  const std::vector<BoundaryName> & _boundary_list;
  // std::map<unsigned int, const Node *> _node_set;
  std::map<BoundaryID, std::map<unsigned int, const Elem *> > _element_side;
  std::map<BoundaryID, std::map<unsigned int, unsigned int> > _element_set;
  std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, std::vector<Real> > > > _node_set;
  std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, std::vector<Real> > > > _normal_set;
};

#endif // VIEWFACTOR_H
