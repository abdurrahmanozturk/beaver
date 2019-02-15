#ifndef RADIATIVEBC_H
#define RADIATIVEBC_H

#include "RadiativeBCBase.h"

// Forward declarations
class RadiativeBC;

template <>
InputParameters validParams<RadiativeBC>();

/**
 * Base class for deriving any boundary condition of a integrated type
 */
class RadiativeBC : public RadiativeBCBase
{
public:
  RadiativeBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  const unsigned int _var_number;
  const System & _system;

private:
  const unsigned int _samplingNumber, _sourceNumber;
  unsigned int _master_elem_id, _slave_elem_id;
  const std::set<BoundaryID> & _boundary_ids;
  const Real _stefan_boltzmann;
  const std::string _method;
  std::map<BoundaryID, Real> _emissivity;
  std::map<unsigned int, unsigned int> _elem_side_map;
  std::map<unsigned int, std::vector<Real>> _master_side_map;
  std::map<unsigned int, std::vector<Real>> _slave_side_map;
};

#endif /* RADIATIVEBC_H */
