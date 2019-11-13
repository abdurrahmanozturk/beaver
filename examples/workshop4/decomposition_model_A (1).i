# This input file simulate phase decomposition starting from unstable state (No nucleation required)

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 128
  ny = 128
  nz = 0
  xmin = 0
  xmax = 512
  ymin = 0
  ymax = 512
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  [./eta]
    order = FIRST
    family =  LAGRANGE
  [../]
[]

[AuxVariables]
  [./local_free_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]
[AuxKernels]
  [./local_free_energy]
    type = TotalFreeEnergy
    variable = local_free_energy
    kappa_names = kappa_op
    interfacial_vars = eta
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
[]

[ICs]
  [./eta] # random variation around the unstable point (eta=0.125)
    type = RandomIC
    variable = 'eta'
     min = 0.124
     max = 0.126
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
      variable = 'eta'
    [../]
  [../]
[]

[Kernels]
  [./AC1_bulk]
    type = AllenCahn
    variable = 'eta'
    f_name = F
    args = 'eta'
  [../]
  [./AC1_int]
    type = ACInterface
    variable = 'eta'
  [../]
  [./e1_dot]
    type = TimeDerivative
    variable = 'eta'
  [../]
[]

[Materials]
  [./FreeEng]
    type = DerivativeParsedMaterial
    args ='eta'
    constant_names = 'A B'
    constant_expressions = '0.10 0.025'
    function = A*(eta^2*(1.0-eta)^2)+B*(2.0*eta^3-3.0*eta^2)
    derivative_order = 2
  [../]
    [./const]
      type = GenericConstantMaterial
      prop_names = 'kappa_op L'
      prop_values = '0.20 1.0'
  [../]
  [./precipitate_indicator]  # Returns 1 if inside the precipitate
    type = ParsedMaterial
    f_name = prec_indic
    args = eta
    function = if(eta>0.5,1.0,0)
  [../]
[]

[Postprocessors]
  [./total_free_energy]
    type = ElementIntegralVariablePostprocessor
    variable = local_free_energy
    execute_on = 'initial timestep_end'
  [../]
  [./precipitate_area]
    type = ElementIntegralMaterialProperty
    mat_prop = prec_indic
    execute_on = 'initial timestep_end'
  [../]
  [./total_area] #The total mesh area/volume
      type = VolumePostprocessor
      execute_on = 'initial'
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
   scheme = bdf2
  type = Transient
  nl_max_its = 15
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
  l_max_its = 15
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-8
  start_time = 0.0
  num_steps = 50
  nl_abs_tol = 1e-11
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
    growth_factor = 1.2
    cutback_factor = 0.75
    optimal_iterations = 6
  [../]
[]

[Outputs]
  file_base = decomposition_model_A
  exodus = true
  csv = true
  interval = 1
[]
