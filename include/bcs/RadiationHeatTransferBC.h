#ifndef RADIATIONHEATTRANSFERBC_H
#define RADIATIONHEATTRANSFERBC_H

#include "IntegratedBC.h"
#include "ViewFactor.h"

// Forward declarations
class RadiationHeatTransferBC;

template <>
InputParameters validParams<RadiationHeatTransferBC>();

class RadiationHeatTransferBC : public IntegratedBC
{
public:
  RadiationHeatTransferBC(const InputParameters & parameters);
  const std::map<unsigned int, std::vector<Real>> getSideMap(const Elem * elem,const unsigned int side);
  const Real getArea(const Elem * elem,const unsigned int side);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  const unsigned int _var_number;
  const System & _system;
  // Point _point;
  // Real _value;

private:
  const ViewFactor & _vf;
  const std::set<BoundaryID> & _boundary_ids;
  const std::set<BoundaryID> & _master_boundary_ids;
  const std::set<BoundaryID> & _slave_boundary_ids;
  const Real _stefan_boltzmann, _ambient_temp;
  const bool _heat_loss;
  std::map<BoundaryID, Real> _emissivity;
  std::map<unsigned int, unsigned int> _elem_side_map;
  unsigned int _master_elem_id,_slave_elem_id;
};

#endif /* RADIATIONHEATTRANSFERBC_H */
