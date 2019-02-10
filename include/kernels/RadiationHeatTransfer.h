#ifndef RadiationHeatTransfer_H
#define RadiationHeatTransfer_H

#include "Kernel.h"
#include "ViewFactor.h"

class RadiationHeatTransfer;

template <>
InputParameters validParams<RadiationHeatTransfer>();

/**
 *
 */
class RadiationHeatTransfer : public Kernel
{
public:
  RadiationHeatTransfer(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  // const VariableValue & _temp;
  const ViewFactor & _viewfactor;
  const std::set<BoundaryID> & _master_boundary_ids;
  const std::set<BoundaryID> & _slave_boundary_ids;
  unsigned int _master_elem_id,_slave_elem_id;
  unsigned int & _current_side;
  unsigned int & _current_neighbor_side;
  const Node *& _current_node;
};

#endif // RadiationHeatTransfer_H
