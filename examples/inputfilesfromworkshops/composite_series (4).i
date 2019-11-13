[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  nz = 0
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
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
    value = 'k1:=1;k2:=4;if(x<=0.5,k1,k2)'
  [../]
[]
[AuxVariables] # auxiliary varaibles that do not appear directly in the PDE
 # this is just to visualize the thermal conductivity of material over the domain
  [./therm_cond]
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
  [./therm_cond]
    type = MaterialRealAux
    variable = therm_cond
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
    args = 'therm_cond dTdx'
    function = '-therm_cond*dTdx'
  [../]

[]
[Kernels] # the terms that appear in the PDE
  [./heat_diffusion]  # evaluate the Laplacian of temperature
    type = HeatConduction
    variable = T
  [../]
[]

[BCs]
  [./T_left]
    type = DirichletBC
    variable = 'T'
    boundary = 'left'
    value = 0.0
  [../]
  [./T_right]
    type = DirichletBC
    variable = 'T'
    boundary = 'right'
    value = 1.0
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
  [./T_cold]
    type = SideAverageValue
    variable = T
    boundary = left
  [../]
  [./T_hot]
    type = SideAverageValue
    variable = T
    boundary = right
  [../]
  [./jx_right]
    type = SideAverageValue
    variable = jx
    boundary = right
  [../]
  [./jx_left]
    type = SideAverageValue
    variable = jx
    boundary = left
  [../]
  [./k_eff] #Effective thermal conductivity
  type = ThermalConductivity
  variable = T
  flux = jx_right
  length_scale = 1.0
  T_hot = T_hot
  dx = 1.0
  boundary = left
  [../]

[]
[VectorPostprocessors]
  # The numerical values of the variables/auxvariables across the centerline
  [./x_direction]
   type =  LineValueSampler
    start_point = '0 0.5 0'
    end_point = '1 0.5 0'
    variable = 'T jx dTdx'
    num_points = 101
    sort_by =  id
  [../]
[]
[Executioner] # Solver options
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = -pc_type
  petsc_options_value = lu
  l_max_its = 50
  l_tol = 1.0e-9
[]
[Outputs]
  file_base = composite_series
  exodus = true
  csv = true
[]
