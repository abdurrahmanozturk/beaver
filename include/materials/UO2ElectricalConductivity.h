#ifndef UO2ELECTRICALCONDUCTIVITY_H
#define UO2ELECTRICALCONDUCTIVITY_H

#include "Material.h"
#include "DerivativeMaterialInterface.h"

// Forward Declarations
class UO2ElectricalConductivity;

template <>
InputParameters validParams<UO2ElectricalConductivity>();

/**
 * Calculates electrical conductivity as a function of temperature.
 * Equation from Bates et al, "Electrical Conductivity of Uranium Dioxide", PNNL, Journal of The American Ceramic Society, 1967
 */
class UO2ElectricalConductivity : public DerivativeMaterialInterface<Material>
{
public:
  UO2ElectricalConductivity(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  const Real _act_e;
  const Real _k_const;
  const Real _sigma_0;
  const VariableValue & _T;

  std::string _base_name;
  MaterialProperty<Real> & _electric_conductivity;
  MaterialProperty<Real> & _delectric_conductivity_dT;
};

#endif // ELECTRICALCONDUCTIVITY_H
