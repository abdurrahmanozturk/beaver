#UO2 MaterialProperty Models testing between 300K < T < 3000K
[Mesh]
  type = GeneratedMesh
  #2D
  xmax = 0.5 #m
  xmin = -0.5    #m
  ymax = 0.5 #m
  ymin = -0.5    #m
  nx = 100
  ny = 100
  dim = 2
  elem_type = QUAD4
[]

[MeshModifiers]
  [./centerBC]
    type = AddExtraNodeset
    new_boundary = 'center'
    coord = '0 0'
  [../]
[]

[Variables]
  [./temp]
    order = FIRST
    family = LAGRANGE
    initial_condition = 300 #K
  [../]
[]

[Functions]
  [./BC_temp]
    type = PiecewiseLinear
    x = '0 100.0'    #sec
    y = '300 3000.0' #K
  [../]
[]

[Kernels]
  [./HeatCond]
    type = HeatConduction
    variable = temp
    diffusion_coefficient = thermal_conductivity
  [../]
  [./TimeDerivativeConduction]
    type = HeatConductionTimeDerivative
    variable = temp
  [../]
[]

[BCs]
  [./all]
    type = FunctionDirichletBC
    variable = temp
    function = BC_temp
    boundary = '0 1 2 3'
  [../]
  [./center]
    type = FunctionDirichletBC
    variable = temp
    function = BC_temp
    boundary = 'center'
  [../]
[]

[Materials]
  #[./constant_thermal_properties]
  #  type = GenericConstantMaterial
  #  prop_names = 'thermal_conductivity density specific_heat'
  #  prop_values = '3.5 10431 380 '
  #[../]
  # [./uo2_thermal]
  #   type = UO2
  #   temp = temp
  #   outputs = exodus
  # [../]
  [./density]
    type = UO2Density
    temp = temp
    output = exodus
  [../]
  [./specific_heat]
    type = UO2HeatCapacity
    temp = temp
    output = exodus
  [../]
  [./electrical_conductivity]
    type = UO2ElectricalConductivity
    temp = temp
    output = exodus
  [../]
  [./thermal_conductivity]
    type = UO2ThermalConductivity
    temp = temp
    output = exodus
  [../]
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  start_time = 0 #s
  end_time = 36000 #s
  dt = 1 #s
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1 #s
    growth_factor = 1.1
    cutback_factor = 0.5
  [../]
[]

[Postprocessors]
  [./density_kg_m3]
    type = ElementIntegralMaterialProperty
    outputs = console
    mat_prop = density
    execute_on = 'initial timestep_end'
  [../]
  [./temp_K]
    type = PointValue
    point = '0 0 0'
    variable = temp
    execute_on = 'initial timestep_end'
  [../]
  [./specific_heat_J_kg-K]
    type = ElementIntegralMaterialProperty
    outputs = console
    mat_prop = specific_heat
    execute_on = 'initial timestep_end'
  [../]
  [./thermal_conductivity_W_m-K]
    type = ElementIntegralMaterialProperty
    outputs = console
    mat_prop = thermal_conductivity
    execute_on = 'initial timestep_end'
  [../]
  [./electrical_conductivity]
    type = ElementIntegralMaterialProperty
    outputs = console
    mat_prop = electrical_conductivity
    execute_on = 'initial timestep_end'
  [../]
[]

[Outputs]
    file_base = 'model_test'
    console = true
    exodus = true
[]
