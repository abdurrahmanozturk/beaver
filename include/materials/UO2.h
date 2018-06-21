#ifndef UO2_H
#define UO2_H

#include "Material.h"
#include "DerivativeMaterialInterface.h"

class UO2;

template <>
InputParameters validParams<UO2>();

/* Temperature dependent equations:
   -density equation is selected by IAEA, "Analysis of Reactor Fuel Rod Behaviour pg1528"
   -specific heat capacity equation from Fink(2000) et al, "Analysis of Reactor Fuel Rod Behaviour
   pg1534"
*/
class UO2 : public DerivativeMaterialInterface<Material>
{
public:
  UO2(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  const VariableValue & _T;
  const Real _mol_kg;

  std::string _base_name;
  MaterialProperty<Real> & _specific_heat;
  MaterialProperty<Real> & _density;
  MaterialProperty<Real> & _thermal_conductivity;
  MaterialProperty<Real> & _dspecific_heat_dT;
  MaterialProperty<Real> & _ddensity_dT;
  MaterialProperty<Real> & _dthermal_conductivity_dT;
};

#endif // UO2_H
