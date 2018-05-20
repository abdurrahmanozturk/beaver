#ifndef UO2THERMALCONDUCTIVITY_H
#define UO2THERMALCONDUCTIVITY_H

#include "Material.h"
#include "DerivativeMaterialInterface.h"

// Forward Declarations
class UO2ThermalConductivity;

template <>
InputParameters validParams<UO2ThermalConductivity>();

/**
 * Calculates thermal conductivity as a function of temperature.
 * Equation is selected by IAEA, "Analysis of Reactor Fuel Rod Behaviour pg1530"
 */

class UO2ThermalConductivity : public DerivativeMaterialInterface<Material>
{
public:
  UO2ThermalConductivity(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

private:
  const VariableValue & _T;

  std::string _base_name;
  MaterialProperty<Real> & _thermal_conductivity;
  MaterialProperty<Real> & _dthermal_conductivity_dT;
};

#endif // THERMALCONDUCTIVITY_H
