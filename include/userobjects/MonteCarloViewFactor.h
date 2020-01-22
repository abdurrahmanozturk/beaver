#ifndef MONTECARLOVIEWFACTOR_H
#define MONTECARLOVIEWFACTOR_H

#include "MonteCarloViewFactorBase.h"
// #include "Material.h"

// Forward Declarations
class MonteCarloViewFactor;

template <>
InputParameters validParams<MonteCarloViewFactor>();

class MonteCarloViewFactor : public MonteCarloViewFactorBase
{
public:
  MonteCarloViewFactor(const InputParameters & parameters);
  virtual void initialize() override;
  virtual void execute() override;
  virtual void finalize() override;
  virtual void threadJoin(const UserObject & y) override {}

  virtual Real getViewFactor(BoundaryID master_bnd, unsigned int master_elem,
                             BoundaryID slave_bnd, unsigned int slave_elem) const;
protected:
  const unsigned int _samplingNumber,_sourceNumber;
  const std::string _method;
  // MaterialProperty<Real> & _viewfactor;
  std::map<unsigned int, unsigned int> _elem_side_map;
  std::map<unsigned int, std::vector<Point>> _master_side_map;
  std::map<unsigned int, std::vector<Point>> _slave_side_map;
};

#endif // MONTECARLOVIEWFACTOR_H
