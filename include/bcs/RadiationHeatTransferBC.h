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
  void updateValues();

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  const unsigned int _var_number;
  const System & _system;
  // Point _point;
  // Real _value;

private:
  const ViewFactor & _viewfactor;
  const std::set<BoundaryID> & _master_boundary_ids;
  const std::set<BoundaryID> & _slave_boundary_ids;
  const Real _stefan_boltzmann;
  const Real _emissivity;
  unsigned int _master_elem_id,_slave_elem_id;
  BoundaryID _current_boundary_id;
};

#endif /* RADIATIONHEATTRANSFERBC_H */
