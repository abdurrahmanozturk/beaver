[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 500
  ny = 0
  nz = 0
  xmin = 0
  xmax = 1
[]

[Variables]
  [./T] # Temperature
  [../]
[]

[Functions]
  # Thermal_Conductivity of Material (could be function of space and time)
  [./thermal_conductivity_func]
    type = ParsedFunction
    value = '1.0'
  [../]
  [./analytic_solution]
    type =  ParsedFunction
    # Simple linear solution in 1D
   value = 'T_a:=1.0;T_b:=2.0;L:=1.0;T_a+(T_b-T_a)/L*x'
  [../]
[]
[AuxVariables] # auxiliary varaibles that do not appear directly in the PDE
 # this is just to visualize the thermal conductivity of material over the domain
  [./mat_therm_cond]
    order = CONSTANT
    family = MONOMIAL
  [../]
  # the temperature gradient
  [./dTdx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  # the heat flux
  [./jx]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels] # the kernels that evaluate the values of the auxvariables
  [./mat_therm_cond]
    type = MaterialRealAux
    variable = mat_therm_cond
    property = thermal_conductivity
  [../]
  [./dTdx]
    type = VariableGradientComponent
    variable = dTdx
    gradient_variable = T
    component = x
  [../]
  [./jx]
    type = ParsedAux
    variable = jx
    args = 'mat_therm_cond dTdx'
    function = '-mat_therm_cond*dTdx'
  [../]

[]
[Kernels] # the terms that appear in the PDE
  [./heat_diffusion]  # evaluate the Laplacian of temperature
    type = HeatConduction
    variable = T
  [../]
[]

[BCs]
  [./T_left] # T_a
    type = DirichletBC
    variable = 'T'
    boundary = 'left'
    value = 1.0
  [../]
  [./T_right] # T_b
    type = DirichletBC
    variable = 'T'
    boundary = 'right'
    value = 2.0
  [../]
[]
[Materials]
  [./Thermal_Conductivity]
    type = GenericFunctionMaterial
    prop_names = thermal_conductivity
    prop_values = thermal_conductivity_func
  [../]
[]
[Postprocessors]
  [./error] # difference between numerical and analtical solutions (L2 norm)
    type = ElementL2Error
    variable = T
    function = analytic_solution
  [../]
  [./jx_r]
    type = SideAverageValue
    variable = jx
    boundary = right
  [../]
  [./jx_l]
    type = SideAverageValue
    variable = jx
    boundary = left
  [../]
[]
[VectorPostprocessors]
  # The numerical values of the variables/auxvariables across the centerline
  [./x_direction]
   type =  LineValueSampler
    start_point = '0 0 0'
    end_point = '1 0 0'
    variable = 'T jx dTdx'
    num_points = 101
    sort_by =  id
  [../]
[]
[Executioner] # Solver options
type = Steady
solve_type = 'LINEAR'
petsc_options_iname = '-pc_type'
petsc_options_value = 'lu'
l_max_its = 100
l_tol = 1.0e-6
[]
[Outputs]
  file_base = problem2
  exodus = true
  [./csv]
    type = CSV
    output_postprocessors = true
  [../]
  # csv = true
[]
