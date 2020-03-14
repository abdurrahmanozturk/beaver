# This simulates nucleation in Model A (Non-conserved dynamics)

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 256
  ny = 256
  nz = 0
  xmin = 0
  xmax = 256
  ymin = 0
  ymax = 256
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
  [./total_free_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]
[AuxKernels]
  [./total_free_energy]
    type = TotalFreeEnergy
    variable = total_free_energy
    kappa_names = kappa_op
    interfacial_vars = eta
    execute_on = 'INITIAL TIMESTEP_END'
  [../]

[]

[ICs]
  [./eta] # small variation around the metastable phase (eta=0)
    type = RandomIC
    variable = 'eta'
     min = -0.0001
     max = 0.0001
     seed = 10
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
  [./AC_bulk]
    type = AllenCahn
    variable = 'eta'
    f_name = F
    args = 'eta'
  [../]
  [./AC_int]
    type = ACInterface
    variable = 'eta'
  [../]
  [./eta_dot]
    type = TimeDerivative
    variable = 'eta'
  [../]
  [./eta_langevin] # stochastic noise term to stimulate nucleation
    type = LangevinNoise
    amplitude = 0.09
    variable = eta
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
      prop_values = '0.10 1.0'
  [../]
  [./precipitate_indicator]  # Returns 1 if inside the precipitate
    type = ParsedMaterial
    f_name = prec_indic
    args = eta
    function = if(eta>0.5,1.0,0)
  [../]
  [./domain_area]  # Returns 1
    type = ParsedMaterial
    f_name = total_area
    args = ''
    function = 1.0
  [../]
[]

[Postprocessors]
  [./total_free_energy]
    type = ElementIntegralVariablePostprocessor
    variable = total_free_energy
  [../]
  [./precipitate_area]
    type = ElementIntegralMaterialProperty
    mat_prop = prec_indic
  [../]
  [./total_area]
    type = ElementIntegralMaterialProperty
    mat_prop = total_area
  [../]
[]

[Executioner]
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
    num_steps = 1
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
  file_base = nucleation_model_A
  exodus = true
  csv = true
  interval = 1
[]
