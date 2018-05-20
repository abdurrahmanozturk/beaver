#ifndef UO2HEATCAPACITY_H
#define UO2HEATCAPACITY_H

#include "Material.h"
#include "DerivativeMaterialInterface.h"

class UO2HeatCapacity;

template<>
InputParameters validParams<UO2HeatCapacity>();

/**
 *Calculates specific heat capacity of UO2 as a function of temperature.
 * Equation from Fink(2000) et al, "Analysis of Reactor Fuel Rod Behaviour pg1534"
 */
class UO2HeatCapacity : public DerivativeMaterialInterface<Material>
{
public:
  UO2HeatCapacity(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  const Real _mol_kg;
  const VariableValue & _T;

  std::string _base_name;
  MaterialProperty<Real> & _specific_heat;
  MaterialProperty<Real> & _dspecific_heat_dT;
};

#endif //UO2HEATCAPACITY_H
