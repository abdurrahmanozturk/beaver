[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 500
  ny = 0
  nz = 0
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 0
  zmin = 0
  zmax = 0
[]

[Variables]
  [./T]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Functions]
  # Thermal_Conductivity of Material (could be function of space and time)
  [./thermal_conductivity_func]
    type = ParsedFunction
    value = 5.0e-2
    #value = 'L:=1.0;A:=1.0;A*sin(pi*x/L)'
  [../]
  [./T_IC] # Initial condition for T
    type = ParsedFunction
    value = 'L:=1.0;A:=1.0;5+A*sin(2*pi*x/L)'
  [../]
  [./analytic_solution]
    type =  ParsedFunction
    # Simple time dependent solution in 1D
   value = 'A:=1.0;k:=5.0e-2;L:=1.0;t1:=L^2/(k*pi^2);A*sin(pi*x/L)*exp(-t/t1)'
  [../]
[]

[ICs]
    [./InitialCondition]
      type = FunctionIC
      function = T_IC
      variable = T
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
  [./heat_diffusion]  # evaluates the Laplacian of temperature
    type = HeatConduction
    variable = T
  [../]
  [./T_dot] # evaluates the time derivative of temperature
    variable = T
    type = TimeDerivative
  [../]
[]

[BCs]
  [./T_left]
    type = DirichletBC
    variable = 'T'
    boundary = 'left'
    value = 5.0
  [../]
  [./T_right]
    type = DirichletBC
    variable = 'T'
    boundary = 'right'
    value = 5.0
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
  [./error] # difference between numerical and analtical solutions (L2 norm)
    type = ElementL2Error
    variable = T
    function = analytic_solution
  [../]

[]
[VectorPostprocessors]
  # The numerical values of the variables/auxvariables across the centerline
  [./line_values]
   type =  LineValueSampler
    start_point = '0 0 0'
    end_point = '1 0 0'
    variable = 'T jx dTdx mat_therm_cond'
    num_points = 101
    sort_by =  id
    execute_on = 'initial TIMESTEP_END'
  [../]
[]
[Executioner] # Solver options
  type = Transient
  solve_type = 'LINEAR'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  l_tol = 1e-9
  num_steps = 50
  dt = 1.0
[]
[Outputs]
  file_base = problem5
  exodus = true
  csv = true
[]
