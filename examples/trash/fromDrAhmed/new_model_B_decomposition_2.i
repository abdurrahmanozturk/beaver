# This simulates spinodal decomposition in a binary alloy using a template for phase-field model B

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
  [./c] # random variation in c inside the unstable spinodal region (0.218<c<0.787)
    type = RandomIC
    variable = 'c'
     min = 0.45
     max = 0.55
     # In the middle of the spinodal
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

  #-----------w equation--------------------
  [./c_dot]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./w_residual]
    # use MatDiffusion if M is c dependent
    # args = 'c' in case the mobility is concentration dependent
    type = CoefDiffusion
    variable = 'w'
     coef = 1.0 # M
  [../]

#-----------c equation--------------------

  [./c_bulk]
    type = MaskedBodyForce
    variable = 'c'
     mask = c_bulk
     #args ='c'
  [../]
  [./w_coupled]
    type = MaskedBodyForce
     variable = 'c'
     mask = w_coupled
     args ='w'
  [../]
  [./c_LaPlacian]
    type = CoefDiffusion
    variable = 'c'
     coef = 1.0 # kappa_c
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
  [./bulk_free_energy]
    type = ParsedMaterial
    args ='c'
    f_name = F
    constant_names = 'A'
    constant_expressions = '1.0'
    function = A*(c^2*(c-1.0)^2)
    #derivative_order = 2
  [../]
  [./c_bulk] # bulk_free_energy_derivative
    type = DerivativeParsedMaterial
    args ='c'
    f_name = c_bulk
    constant_names = 'A'
    constant_expressions = '-1.0'
    function = A*(2.0*c-6.0*c^2+4.0*c^3)
    derivative_order = 1
  [../]
  [./w_coupled]
    type = DerivativeParsedMaterial
    args ='w'
    f_name = w_coupled
    function = w
    derivative_order = 1
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
  num_steps = 200
  nl_abs_tol = 1e-9
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
    growth_factor = 1.2
    cutback_factor = 0.75
    optimal_iterations = 6
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  interval = 1
  file_base = new_decomposition_model_b_3
[]
