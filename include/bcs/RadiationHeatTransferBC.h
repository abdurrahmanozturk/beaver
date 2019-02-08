#ifndef RADIATIONHEATTRANSFERBC_H
#define RADIATIONHEATTRANSFERBC_H

#include "IntegratedBC.h"
#include "ViewFactor.h"

// Forward declarations
class RadiationHeatTransferBC;

template <>
InputParameters validParams<RadiationHeatTransferBC>();

/**
 * Base class for deriving any boundary condition of a integrated type
 */
class RadiationHeatTransferBC : public IntegratedBC
{
public:
  RadiationHeatTransferBC(const InputParameters & parameters);
  const Real getArea(const Elem * elem,const unsigned int side);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

private:
  const ViewFactor & _viewfactor;
  const std::set<BoundaryID> & _master_boundary_ids;
  const std::set<BoundaryID> & _slave_boundary_ids;
  const Real _stefan_boltzmann;
  unsigned int _master_elem_id,_slave_elem_id;
  BoundaryID _current_boundary_id;
};

#endif /* RADIATIONHEATTRANSFERBC_H */
