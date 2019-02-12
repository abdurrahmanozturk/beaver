#include "ViewFactorBase.h"
#include "ViewFactor.h"

registerMooseObject("beaverApp", ViewFactor);

template <>
InputParameters
validParams<ViewFactor>()
{
  InputParameters params = validParams<ViewFactorBase>();
  params.addClassDescription("User Object to calculate view factors for radiative surfaces.");
  params.addParam<std::string>("method","MONTECARLO","View Factor calculation method. The available options: MONTECARLO");
  params.addParam<unsigned int>("sampling_number",100, "Number of Sampling");
  params.addParam<unsigned int>("source_number",100, "Number of Source Points");
  return params;
}

ViewFactor::ViewFactor(const InputParameters & parameters)
  : ViewFactorBase(parameters),
    _samplingNumber(getParam<unsigned int>("sampling_number")),
    _sourceNumber(getParam<unsigned int>("source_number")),
    _method(getParam<std::string>("method"))
{
}

void
ViewFactor::initialize()
{
  std::srand(time(NULL));
}

void
ViewFactor::execute()
{
  unsigned int dim = _current_elem->dim();
  if (dim!=3)
    mooseError("ViewFactor UserObject can only be used for 3D geometry.");

  // LOOPING OVER ELEMENTS ON THE MASTER BOUNDARY
  // Define IDs
  BoundaryID current_boundary_id = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  const auto current_boundary_name = _mesh.getBoundaryName(current_boundary_id);
  unsigned int current_element_id =(_current_elem->id());
  //Loop over nodes on current element side
  unsigned int n = _current_side_elem->n_nodes();
  for (unsigned int i = 0; i < n; i++)
  {
    unsigned int _current_node_id = i;
    const Node * node = _current_side_elem->node_ptr(i);    //get nodes from current_elem_side pointer
    for (unsigned int j = 0; j < 3; j++)         // Define nodal coordinates
    {
      _coordinates_map[current_boundary_id][current_element_id][_current_node_id].push_back((*node)(j));
    }
  }
}
void
ViewFactor::finalize()
{
  std::cout<<"Calculating View Factors"<<std::endl;
  std::cout<<"------------------------"<<std::endl;
  // for (auto master_bnd_id : _master_boundary_ids)
  for (auto master_bnd_id : _boundary_ids)
  {
    Real viewfactor{0};
    const auto master_boundary_map = _coordinates_map[master_bnd_id];
    // for (auto slave_bnd_id : _slave_boundary_ids)
    for (auto slave_bnd_id : _boundary_ids)
    {
      viewfactor = 0;
      const auto slave_boundary_map = _coordinates_map[slave_bnd_id];
      const auto master_bnd_name = _mesh.getBoundaryName(master_bnd_id);
      const auto slave_bnd_name = _mesh.getBoundaryName(slave_bnd_id);
      for (auto master_elem : master_boundary_map)
      {
        const auto master_elem_map = _coordinates_map[master_bnd_id][master_elem.first];
        for (auto slave_elem : slave_boundary_map)
        {
          const auto slave_elem_map = _coordinates_map[slave_bnd_id][slave_elem.first];

          if (_F[slave_bnd_id][master_bnd_id]!=0)
          {
            //reciprocity
            Real master_elem_area = getArea(getCenterPoint(master_elem_map),master_elem_map);
            Real slave_elem_area = getArea(getCenterPoint(slave_elem_map),slave_elem_map);
            Real afsm = slave_elem_area/master_elem_area;
            Real Fsm = _viewfactors_map[slave_bnd_id][master_bnd_id][slave_elem.first][master_elem.first];
            _viewfactors_map[master_bnd_id][slave_bnd_id][master_elem.first][slave_elem.first] = afsm * Fsm;
            _viewfactors[master_elem.first][slave_elem.first] = afsm * Fsm;
            viewfactor += afsm * Fsm;
          }
          else
          {
            if (isVisible(master_elem_map,slave_elem_map))
            {
              Real viewfactor_per_elem;
              if (_method=="MONTECARLO")
                viewfactor_per_elem = doMonteCarlo(master_elem_map,slave_elem_map,_sourceNumber,_samplingNumber);
              else
                mooseError("Undefined method for view factor calculations.");

              viewfactor += viewfactor_per_elem;
              _viewfactors_map[master_bnd_id][slave_bnd_id][master_elem.first][slave_elem.first] = viewfactor_per_elem;
              _viewfactors[master_elem.first][slave_elem.first] = viewfactor_per_elem;
            }
            else
            {
              _viewfactors_map[master_bnd_id][slave_bnd_id][master_elem.first][slave_elem.first] = 0;
              _viewfactors[master_elem.first][slave_elem.first]=0;
              viewfactor +=0;
            }
          }
        }
      }
      viewfactor *= (1.0/master_boundary_map.size());
      std::cout<<"F["<<master_bnd_id<<"]["<<slave_bnd_id<<"] = "<<viewfactor<<std::endl;
      _F[master_bnd_id][slave_bnd_id]=viewfactor;
    }
  }
  std::cout<<"F[7][11]"<<_viewfactors[4][11]<<std::endl;
  if (_printScreen==true)
    printViewFactors();
}

Real ViewFactor::getViewFactor(BoundaryID master_bnd, unsigned int master_elem, BoundaryID slave_bnd, unsigned int slave_elem) const
{
  if (_viewfactors_map.find(master_bnd) != _viewfactors_map.end())
  {
    if (_viewfactors_map.find(master_bnd)->second.find(slave_bnd) != _viewfactors_map.find(master_bnd)->second.end())
      if (_viewfactors_map.find(master_bnd)->second.find(slave_bnd)->second.find(master_elem) != _viewfactors_map.find(master_bnd)->second.find(slave_bnd)->second.end())
        if (_viewfactors_map.find(master_bnd)->second.find(slave_bnd)->second.find(master_elem)->second.find(slave_elem) != _viewfactors_map.find(master_bnd)->second.find(slave_bnd)->second.find(master_elem)->second.end())
          return (_viewfactors_map.find(master_bnd)->second.find(slave_bnd)->second.find(master_elem)->second.find(slave_elem)->second);
    else
      mooseError("Viewfactor requested for unknown slave boundary. Make sure UserObject is executed on INITIAL and boundaries are defined correctly in UserObject block.");
  }
  mooseError("Viewfactor requested for unknown slave boundary. Make sure UserObject is executed on INITIAL and boundaries are defined correctly in UserObject block.");
  return 0;   //satisfy compiler
}
