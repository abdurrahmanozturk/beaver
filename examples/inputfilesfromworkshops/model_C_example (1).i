# This is a template for phase-field model C
# that the solves the coupled Allen-Cahn and Cahn-Hilliard equations for non-conserved and conserved variables.
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
  [./eta]
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
  [./IC_eta]
    x1 = 128
    y1 = 128
    radius = 64.0
    outvalue = 0.0
    variable = eta
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
  # Split form of Cahn-Hilliard equation with eta as coupled variable
  # w is the chemical potential
  [./c_dot]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./c_res]
    type = SplitCHParsed
    variable = c
    f_name = F
    kappa_name = kappa_c
    w = w
    args = eta
  [../]
  [./w_res]
    # args = 'c' in case the mobility is concentration dependent
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
  # Allen-Cahn equation with c as coupled variable
  [./AC_bulk]
    type = AllenCahn
    variable = eta
    f_name = F
    args = c
    mob_name = L
  [../]
  [./AC_int]
    type = ACInterface
    variable = eta
    kappa_name = kappa_op
    mob_name = L
  [../]
  [./eta_dot]
    type = TimeDerivative
    variable = eta
  [../]
[]

[AuxKernels]
  [./total_F]
    type = TotalFreeEnergy
    variable = total_F
    interfacial_vars = 'c eta'
    kappa_names = 'kappa_c kappa_op'
  [../]
[]

[Materials]
  [./Bulk_Free_Eng]
    type = DerivativeParsedMaterial
    args ='eta c'
    f_name = F
    constant_names = 'A B D C_m C_p'
    # m:matrix, p: precipitate, C_p: Equilibrium concentration in precipitate
    # eta =1.0 inside the precipitate and eta=0.0 inside the matrix 
    constant_expressions = '1.0 1.0 1.0 0.0 1.0'
    function = 'h:=(3.0*eta^2-2.0*eta^3);g_p:=h*A*(c-C_p)^2;g_m:=(1.0-h)*B*(c-C_m)^2;g_eta:=D*(eta^2*(eta-1.0)^2);g_m+g_p+g_eta'
    # h is an interpolation function
    derivative_order = 2
  [../]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'kappa_c kappa_op L M'
    prop_values = '1.0 1.0 1.0 1.0'
  [../]
[]

[Postprocessors]
  [./ElementInt_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  [../]
  [./precip_area] # since eta=1.0 inside the precipitate
    type = ElementIntegralVariablePostprocessor
    variable = 'eta'
  [../]
  [./total_F]
    type = ElementIntegralVariablePostprocessor
    variable = total_F
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
