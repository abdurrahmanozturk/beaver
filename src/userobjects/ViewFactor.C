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
    // _viewfactor(declareProperty<Real>("viewfactor"))
{
  for (const auto & t : _mesh.buildSideList())    //buildSideList(el,side,bnd)
  {
    auto elem_id = std::get<0>(t);
    auto side_id = std::get<1>(t);
    auto bnd_id = std::get<2>(t);
    if (_boundary_ids.find(bnd_id)!=_boundary_ids.end())
      _elem_side_map[elem_id]=side_id;
  }
}

void
ViewFactor::initialize()
{
  std::cout << "------------------------" << std::endl;
  std::cout << "Calculating View Factors" << std::endl;
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
  Real viewfactor_elem_to_bnd{0};
  BoundaryID slave_bnd;
  BoundaryID master_bnd = _mesh.getBoundaryIDs(_current_elem, _current_side)[0];
  unsigned int master_elem =(_current_elem->id());
  _master_side_map = getSideMap(_current_elem,_current_side);   //master side node coordinates
  for (const auto & elem : _elem_side_map)
  {
    // std::cout<<"checkpoint1"<<std::endl;
    unsigned int slave_elem = elem.first;   //slave_elem id el->id()
    // std::cout<<"master elem:"<<master_elem<<"-> slave elem:"<<slave_elem<<std::endl;
    if (master_elem == slave_elem)     //element side can not see itself
      continue;
    Elem * el = _mesh.elemPtr(elem.first);  //elem ptr for slave elem
    unsigned int slave_side = elem.second;  //slave_side id
    slave_bnd = _mesh.getBoundaryIDs(el,slave_side)[0];  //slave_bnd id
    _slave_side_map = getSideMap(el,slave_side);   //slave side node coordinates
    // std::cout<<"checkpoint2"<<std::endl;
    // if (_viewfactors_map[slave_bnd][master_bnd][slave_elem][master_elem]!=0)    //use reciprocity of viewfactors
    // {
    //   // std::cout<<"checkpoint3"<<std::endl;
    //   Real master_side_area = getArea(getCenterPoint(_master_side_map),_master_side_map);
    //   Real slave_side_area = getArea(getCenterPoint(_slave_side_map),_slave_side_map);
    //   Real afsm = slave_side_area/master_side_area;
    //   Real Fsm = _viewfactors_map[slave_bnd][master_bnd][slave_elem][master_elem];
    //   // std::cout<<"F_master-slave:"<<Fsm<<std::endl;
    //   _viewfactors_map[master_bnd][slave_bnd][master_elem][slave_elem] = afsm * Fsm;
    //   viewfactor_elem_to_bnd += afsm * Fsm;
    //   // std::cout<<"F_slave-master:"<<(afsm*Fsm)<<std::endl;
    //   // std::cout<<"F_slave-master:"<<_viewfactors_map[master_bnd][slave_bnd][master_elem][slave_elem]<<std::endl;
    // }
    // else
    // {    //reciprocity
      // std::cout<<"checkpoint4"<<std::endl;
      if (isVisible(_master_side_map,_slave_side_map))
      {
        // std::cout<<"checkpoint5"<<std::endl;
        Real viewfactor_elem_to_elem = 0;   //initialize viewFactor calculation
        if (_method=="MONTECARLO")
          viewfactor_elem_to_elem = doMonteCarlo(_master_side_map,_slave_side_map,_sourceNumber,_samplingNumber);
        else
          mooseError("Unknown method for view factor calculations.");
        _viewfactors_map[master_bnd][slave_bnd][master_elem][slave_elem] = viewfactor_elem_to_elem;
        viewfactor_elem_to_bnd += viewfactor_elem_to_elem;
        // _viewfactor[_qp] = viewfactor_elem_to_elem;
      }
      else
      {
        // std::cout<<"checkpoint7"<<std::endl;
        // std::cout<<"not visible"<<std::endl;
        _viewfactors_map[master_bnd][slave_bnd][master_elem][slave_elem] = 0;
        viewfactor_elem_to_bnd += 0;
        // _viewfactor[_qp] = 0;
      }
    // }//reciprocity
    // std::cout<<"F["<<master_elem<<"]["<<slave_elem<<"]= "<<_viewfactors_map[master_bnd][slave_bnd][master_elem][slave_elem]<<std::endl;
  }
  // std::cout<<"Fsum="<<viewfactor_elem_to_bnd<<std::endl;
}
//
// void
// ViewFactor::threadJoin(const UserObject & y)
// {
//   const ViewFactor & vf = dynamic_cast<const ViewFactor &>(y);
//   for (auto it1 : vf._viewfactors_map)
//     for (auto it2 : it1.second)
//       for (auto it3 : it2.second)
//         for (auto it4 : it3.second)
//           _viewfactors_map[it1.first][it2.first][it3.first][it4.first]=it4.second;
// }

void
ViewFactor::finalize()
{
  std::cout << "done." << std::endl;
  std::cout << "------------------------" << std::endl;
  if (_printScreen==true)
    printViewFactors();
  // std::cout<<"------------"<<std::endl;
  // std::cout<<"ViewFactors:"<<std::endl;
  // for (auto it1 : _viewfactors_map)
  //   for (auto it2 : it1.second)
  //     for (auto it3 : it2.second)
  //       for (auto it4 : it3.second)
  //         {
  //           gatherSum(it4.second);
  //         }

  // //write viewfactors to screen for debugging
  // for (auto it1 : _viewfactors_map)
  //   for (auto it2 : it1.second)
  //     for (auto it3 : it2.second)
  //       for (auto it4 : it3.second)
  //         {
  //           // std::cout<<"map size ="<<_viewfactors_map.size()*it1.second.size()*it2.second.size()*it3.second.size()<<std::endl;
  //           Real vf = _viewfactors_map[it1.first][it2.first][it3.first][it4.first]=it4.second;
  //           // std::cout<<"F["<<it1.first<<"]["<<it2.first<<"]["<<it3.first<<"]["<<it4.first<<"]
  //           // ="<<vf<<std::endl;
  //         }
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
    {
      std::cout<<"Boundaries: "<<master_bnd<<"->"<<slave_bnd<<std::endl;
      mooseError("Viewfactor requested for unknown slave boundary. Make sure UserObject is executed on INITIAL and boundaries are defined correctly in UserObject block.");
    }
  }
  std::cout<<"Boundaries: "<<master_bnd<<"-> "<<slave_bnd<<std::endl;
  mooseError("Viewfactor requested for unknown master boundary. Make sure UserObject is executed on INITIAL and boundaries are defined correctly in UserObject block.");
  return 0;   //satisfy compiler
}
