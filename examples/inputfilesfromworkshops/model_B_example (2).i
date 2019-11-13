# This is a template for phase-field model B
# that the solves the Cahn-Hilliard equation (in the split form) for a conserved variable (concentration).
# It follows the evolution of a circular precipitate embedded in a large matrix
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 64
  ny = 64
  xmin = 0
  xmax = 256
  ymin = 0
  ymax = 256
  uniform_refine = 2
  elem_type = QUAD4
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
[]
# aux varaibles to track the free energy change (must decrease with time)
[AuxVariables]
  [./total_F]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
  [./IC_c]
    x1 = 128.0
    y1 = 128.0
    radius = 64.0
    outvalue = 0.0
    variable = c
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Kernels]
  # Split form of Cahn-Hilliard equation
  # w is the chemical potential
  [./c_dot]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./c_residual]
    type = SplitCHParsed
    variable = c
    f_name = F
    kappa_name = kappa_c
    w = w
  [../]
  [./w_residual]
    # args = 'c' in case the mobility is concentration dependent
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
[]

[AuxKernels]
  [./total_F]
    type = TotalFreeEnergy
    variable = total_F
    interfacial_vars = 'c'
    kappa_names = 'kappa_c'
  [../]
[]

[Materials]
  [./Bulk_Free_Eng]
    type = DerivativeParsedMaterial
    args ='c'
    f_name = F
    constant_names = 'A C_m C_p'
    # m:matrix, p: precipitate, C_p: Equilibrium concentration in precipitate
    constant_expressions = '1.0 0.0 1.0'
    function = A*((c-C_m)^2*(c-C_p)^2)
    # one can also use the regular solution free energy
    derivative_order = 2
  [../]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'kappa_c M'
    prop_values = '1.0 1.0'
  [../]
  [./precipitate_indicator]  # Returns 1 if inside the precipitate
    type = ParsedMaterial
    f_name = prec_indic
    args = c
    function = if(c>0.9,1.0,0)
  [../]
[]

[Postprocessors]
  [./ElementInt_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  [../]
  [./total_F]
    type = ElementIntegralVariablePostprocessor
    variable = total_F
  [../]
  [./precipitate_area]      # Area of precipitate
    type = ElementIntegralMaterialProperty
    mat_prop = prec_indic
  [../]
[]

[Preconditioning]
  [./SMP] # to produce the complete perfect Jacobian
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  nl_max_its = 15
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = -pc_type
  petsc_options_value = asm
  l_max_its = 15
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-8
  start_time = 0.0
  num_steps = 10
  nl_abs_tol = 1e-9
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
    growth_factor = 1.2
    cutback_factor = 0.75
    optimal_iterations = 6
  [../]
  [./Adaptivity]
    refine_fraction = 0.5
    coarsen_fraction = 0.01
    max_h_level = 3
    initial_adaptivity = 2
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  interval = 1
  file_base = model_c
[]
