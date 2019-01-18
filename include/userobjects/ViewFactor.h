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
  // virtual Real getValue();
  // virtual Real spatialValue(const Point & p) const;
  // const VariableValue & _nodal_normal_x;
  // const VariableValue & _nodal_normal_y;
  // const VariableValue & _nodal_normal_z;
  // VariableValue & _nodal_normal_z
  unsigned int _qp;
  Real rand_x, rand_y, rand_z;
  Real px, px1, px2, py, py1, py2, pz, pz1, pz2;
  Point p;
  Point q;
  MooseRandom _random;
  const MooseArray<Point> & _current_normals;
  const std::set<BoundaryID> & _boundary_ids;
  const std::vector<BoundaryName> & _boundary_list;
  std::map<BoundaryID, std::vector<unsigned int>> _boundary_index_sets;
  std::map<unsigned int, const Node *> _node_set;
  std::map<unsigned int, std::map<unsigned int, const Node *> > _side_set;
  std::map<BoundaryID, std::map<unsigned int, const Elem *> > _element_side;
  std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, std::map<unsigned int, const Node *> > > > _boundary_set;
  std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, const Node * > > > _node_coordinates;
  std::map<BoundaryID, std::map<unsigned int, std::map<unsigned int, Point > > > _node_normals;
// private:
  // int m_coord_index;
};

#endif // VIEWFACTOR_H
