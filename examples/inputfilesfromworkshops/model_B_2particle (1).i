# This simulates the coarsening of two unequal sizes particles
[Mesh] 
  type = GeneratedMesh
  dim = 2
  nx = 128
  ny = 128
  xmin = 0
  xmax = 128
  ymin = 0
  ymax = 128
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
    type = SpecifiedSmoothCircleIC
    variable = c
    x_positions = '50 83'
    y_positions = '64 64'
    z_positions = '0 0'
    radii = '10 15'
    invalue = 1.0
    outvalue = 0.00786 # equilibrium solubility with particle of radius 15
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
    execute_on = 'initial TIMESTEP_END'
  [../]
  [./total_F]
    type = ElementIntegralVariablePostprocessor
    variable = total_F
    execute_on = 'initial TIMESTEP_END'
  [../]
  [./precipitate_area]      # Area of precipitate
    type = ElementIntegralMaterialProperty
    mat_prop = prec_indic
    execute_on = 'TIMESTEP_END'
  [../]
[]
[VectorPostprocessors]
  # The numerical values of the variables/auxvariables across the centerline
  [./line_values]
   type =  LineValueSampler
    start_point = '0 64 0'
    end_point = '128 64 0'
    variable = 'c w j_tot'
    num_points = 129
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
  nl_rel_tol = 1.0e-7
  start_time = 0.0
  num_steps = 200
  nl_abs_tol = 1e-9
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
    growth_factor = 1.2
    cutback_factor = 0.75
    optimal_iterations = 7
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  interval = 1
  file_base = modelB_2particle
[]
