#ifndef UO2DENSITY_H
#define UO2DENSITY_H

#include "Material.h"
#include "DerivativeMaterialInterface.h"

class UO2Density;

template<>
InputParameters validParams<UO2Density>();

/**
 * Calculates density of UO2 as a function of temperature.
 * Equation is selected by IAEA, "Analysis of Reactor Fuel Rod Behaviour pg1528"
 */
class UO2Density : public DerivativeMaterialInterface<Material>
{
public:
  UO2Density(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  const VariableValue & _T;

  std::string _base_name;
  MaterialProperty<Real> & _density;
  MaterialProperty<Real> & _ddensity_dT;
};

#endif //UO2DENSITY_H
