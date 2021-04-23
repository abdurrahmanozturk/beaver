# This simulates spinodal decomposition in a binary alloy using a template for phase-field model B

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 64
  ny = 64
  xmin = 0
  xmax = 128
  ymin = 0
  ymax = 128
  uniform_refine = 1
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
  [./T]
  [../]
[]
[Functions]
  [./Temperature]
    type = ParsedFunction
    value = 'if(x<=64,12,120)'
  [../]
[]
[ICs]
  [./c] # random variation in c inside the unstable spinodal region (0.218<c<0.787)
    type = RandomIC
    variable = 'c'
     min = 0.49
     max = 0.51
  [../]
  # at the lower end of the spinodal
  [./T]
    type = FunctionIC
    function = Temperature
    variable = T
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
    args ='c T'
    f_name = F
    constant_names = 'omega R'
    # m:matrix, p: precipitate, C_p: Equilibrium concentration in precipitate
    constant_expressions = '0.3 8.314e-3'
    function = 'omega*c*(1.0-c)+R*T*(c*log(c)+(1.0-c)*log(1.0-c))'
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
    function = if(c>0.5,1.0,0)
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
  file_base = decomposition_model_b_log
[]
