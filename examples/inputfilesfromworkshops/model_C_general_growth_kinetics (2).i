# This simulates general particle growth kinetics
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
  # the chemical potential gradients
  [./dwdx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dwdy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  # the flux
  [./jx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./jy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./j_tot]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
  [./IC_c]
    x1 = 128.0
    y1 = 128.0
    radius = 32.0
    outvalue = 0.1 # Matrix is supersaturated with solute atoms
    variable = c
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./IC_eta]
    x1 = 128
    y1 = 128
    radius = 32.0
    outvalue = 0.0
    variable = eta
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]

[BCs]
  [./cBC]
    type = DirichletBC
    variable = 'c'
    boundary = 'left right top bottom'
    value = 0.1
  [../]
  [./wBC]
    type = DirichletBC
    variable = 'w'
    boundary = 'left right top bottom'
    value = 0.2  # w~= 2*c (in the matrix)
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
    mob_name = M # Cahn-Hilliard diffusional mobility
  [../]
  # Allen-Cahn equation with c as coupled variable
  [./AC_bulk]
    type = AllenCahn
    variable = eta
    f_name = F
    args = c
    mob_name = L # Allen-Cahn interface mobility
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
  [./dwdx]
    type = VariableGradientComponent
    variable = dwdx
    gradient_variable = w
    component = x
  [../]
  [./dwdy]
    type = VariableGradientComponent
    variable = dwdy
    gradient_variable = w
    component = y
  [../]
  [./jx]
    type = ParsedAux
    variable = jx
    args = 'dwdx'
    function = '-1.0*dwdx'
  [../]
  [./jy]
    type = ParsedAux
    variable = jy
    args = 'dwdy'
    function = '-1.0*dwdy'
  [../]
  [./j_tot]
    type = ParsedAux
    variable = j_tot
    args = 'jx jy'
    function = 'sqrt(jx^2+jy^2)'
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
    constant_expressions = '1.0 1.0  1.0 0.0 1.0'
    function = 'h:=(3.0*eta^2-2.0*eta^3);g_p:=h*B*(c-C_p)^2;g_m:=(1.0-h)*A*(c-C_m)^2;g_eta:=D*(eta^2*(eta-1.0)^2);g_m+g_p+g_eta'
    # h is an interpolation function
    derivative_order = 2
  [../]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'kappa_c kappa_op L M'
    prop_values = '1.0 1.0 1.0e-4 1.0'
    # as (L*R*interf_width)/M ratio increases growth kinetics changes from interface- to diffusion-controlled
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
[VectorPostprocessors]
  # The numerical values of the variables/auxvariables across the centerline
  [./line_values]
   type =  LineValueSampler
    start_point = '0 128 0'
    end_point = '256 128 0'
    variable = 'c w j_tot'
    num_points = 257
    sort_by =  id
    execute_on = 'TIMESTEP_END'
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
  num_steps = 500
  nl_abs_tol = 1e-9
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
    growth_factor = 1.2
    cutback_factor = 0.75
    optimal_iterations = 7
  [../]
  [./Adaptivity]
    refine_fraction = 0.7
    coarsen_fraction = 0.1
    max_h_level = 2
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  interval = 1
  file_base = general_growth_kinetics
[]
