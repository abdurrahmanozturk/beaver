#ifndef VIEWFACTOR_H
#define VIEWFACTOR_H

#include "SideUserObject.h"
#include "MooseRandom.h"
#include "MooseMesh.h"
// libMesh includes
#include "libmesh/mesh_generation.h"
#include "libmesh/mesh.h"
#include "libmesh/string_to_enum.h"
#include "libmesh/quadrature_gauss.h"
#include "libmesh/point_locator_base.h"

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

  const VariableValue & _nodal_normal_x;
  const VariableValue & _nodal_normal_y;
  const VariableValue & _nodal_normal_z;
  // VariableValue & _nodal_normal_z
  unsigned int _qp;
  Real rand_x, rand_y, rand_z;
  Real px, px1, px2, py, py1, py2, pz, pz1, pz2;
  Point p;
  Point q;
  MooseRandom _random;
  // std::vector<Point> _node_coordinates;
  // const MooseArray<Point> & _node_coordinates;
  // const MooseArray<Point> & _normals;
};

#endif // VIEWFACTOR_H
