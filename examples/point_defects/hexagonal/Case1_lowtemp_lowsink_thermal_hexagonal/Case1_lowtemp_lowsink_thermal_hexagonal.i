# This simulation predicts GB migration of a 2D copper polycrystal with 100 grains
# Mesh adaptivity and time step adaptivity are used
# An AuxVariable is used to calculate the grain boundary locations
# Postprocessors are used to record time step and the number of grains

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 250
  ny = 34
  nz = 0
  xmax = 1000
  ymax = 866
  zmax = 0
  elem_type = QUAD4
  uniform_refine = 2
[]
[GlobalParams]
  # Parameters used by several kernels that are defined globally to simplify input file
  op_num = 4 # Number of OPs (Phase-field variables)
  var_name_base = gr # Base name of grains
 block = '0'
[]

[UserObjects]
  [./hex_ic]
    type = PolycrystalHex
    coloring_algorithm = bt
    grain_num = 4
    x_offset = 0.25
    #output_adjacency_matrix = true
  [../]
  [./grain_tracker]
    type = GrainTracker
    threshold = 0.2
    connecting_threshold = 0.08
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_begin'
    flood_entity_type = ELEMENTAL
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalColoringIC]
      polycrystal_ic_uo = hex_ic
    [../]
  [../]
  [./cv]
    type = RandomIC
    variable = 'cv'
    min = 1e-11
    max = 3e-11
     seed = 10
  [../]

  [./ci]
    type = RandomIC
    variable = 'ci'
    min = 1e-11
    max = 3e-11
     seed = 11
  [../]
[]

[Variables]
  [./cv]
  [../]
  [./ci]
  [../]
  # Variable block, where all variables in the simulation are declared
  [./PolycrystalVariables]
    # Custom action that created all of the grain variables
    order = FIRST # element type used by each grain variable
    family = LAGRANGE
  [../]
  [./T]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
#active = ''
  # Dependent variables
  [./dcvdx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dcidx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./jvx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./jix]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./bnds]
    # Variable used to visualize the grain boundaries in the simulation
    order = FIRST
    family = LAGRANGE
  [../]
  [./mat_therm_cond]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dTdx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dTdy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./jx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./jy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  # Kernel block, where the kernels defining the residual equations are set up.
  [./PolycrystalKernel]
    # Custom action creating all necessary kernels for grain growth.  All input parameters are up in GlobalParams
args = 'T'
  [../]
  [./heat]
    type = HeatConduction
    variable = 'T'
  [../]

  ############# cv_eqn ###################
  [./cv_dot]
    type = TimeDerivative
    variable = 'cv'
  [../]
  [./cv_diff]
    type = MatDiffusion
    variable = cv
    D_name = Dv
  [../]
  [./recomb_reaction_cv]
    type = MatReaction
     variable = cv
    mob_name = kivci
    args = ci
  [../]
  [./sink_reaction_cv]
    type = MatReaction
     variable = cv
    mob_name = kvscs
  [../]
  [./GBsink_reaction_cv]
    type = MatReaction
     variable = cv
    mob_name = kvgb
  [../]
  [./cv_source]
      type = MaskedBodyForce
      variable = cv
      value = 1e-6
      mask = 1
    [../]


  ############# ci_eqn ###################
  [./ci_dot]
    type = TimeDerivative
    variable = 'ci'
  [../]
  [./ci_diff]
    type = MatDiffusion
    variable = ci
    D_name = Di
  [../]
  [./recomb_reaction_ci]
    type = MatReaction
     variable = ci
    mob_name = kivcv
    args = cv
  [../]
  [./sink_reaction_ci]
    type = MatReaction
     variable = ci
    mob_name = kiscs
  [../]
  [./GBsink_reaction_ci]
    type = MatReaction
     variable = ci
    mob_name = kigb
  [../]
  [./ci_source]
      type = MaskedBodyForce
      variable = ci
      value = 1e-6
      mask = 1
    [../]
[]

[AuxKernels]
  # AuxKernel block, defining the equations used to calculate the auxvars
  [./dcvdx]
    type = VariableGradientComponent
    variable = dcvdx
    gradient_variable = cv
    component = x
  [../]
  [./dcidx]
    type = VariableGradientComponent
    variable = dcidx
    gradient_variable = ci
    component = x
  [../]
  [./jvx]
    type = ParsedAux
    variable = jvx
    args = 'dcvdx'
    function = '-1.0e-3*dcvdx'
  [../]
  [./jix]
    type = ParsedAux
    variable = jix
    args = 'dcidx'
    function = '-1.0*dcidx'
  [../]
  [./bnds_aux]
    # AuxKernel that calculates the GB term
    type = BndsCalcAux
    variable = bnds
    execute_on = timestep_end
  [../]
  [./mat_therm_cond]
    type = MaterialRealAux
    variable = mat_therm_cond
    property = thermal_conductivity
    #execute_on = timestep_end
  [../]
  [./dTdx]
    type = VariableGradientComponent
    variable = dTdx
    gradient_variable = T
    component = x
  [../]
  [./dTdy]
    type = VariableGradientComponent
    variable = dTdy
    gradient_variable = T
    component = y
  [../]
  [./jx]
    type = ParsedAux
    variable = jx
    args = 'mat_therm_cond dTdx'
    function = '-mat_therm_cond*dTdx'
  [../]
  [./jy]
    type = ParsedAux
    variable = jy
    args = 'mat_therm_cond dTdy'
    function = '-mat_therm_cond*dTdy'
  [../]
[]

[BCs]
  [./left_T]
  #  type = DirichletBC
  type = PresetBC
    variable = 'T'
    boundary = 'left'
    value = 0.0
  [../]
  [./right_T]
    type = PresetBC
    variable = 'T'
    boundary = 'right'
    value = 500.0
  [../]
  [./Periodic]
    [./all]
      variable = 'gr0 gr1 gr2 gr3 '
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]

  [./cvci_reaction_rate] # Low recombination rate
    type = DerivativeParsedMaterial
    function = -kiv*ci
    constant_names = 'kiv'
    constant_expressions = '1e2'
    args = 'ci'
    f_name = kivci
    derivative_order = 1
  [../]
  [./cicv_reaction_rate] # Low recombination rate
    type = DerivativeParsedMaterial
    function = -kiv*cv
    constant_names = 'kiv'
    constant_expressions = '1e2'
    args = 'cv'
    f_name = kivcv
    derivative_order = 1
  [../]
  [./cigb_reaction_rate] # reactions rate between ci and discrete GBs
    type = ParsedMaterial
    function = -kigb*(1.0-bnds) # Non-zero only inside GBs
    constant_names = 'kigb'
    constant_expressions = '1e-2'
    args = 'bnds'
    f_name = kigb
  [../]
  [./cvgb_reaction_rate] # reactions rate between cv and discrete GBs
    type = ParsedMaterial
    function = -kvgb*(1.0-bnds) # Non-zero only inside GBs
    constant_names = 'kvgb'
    constant_expressions = '1e-2'
    args = 'bnds'
    f_name = kvgb
  [../]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'Dv Di kiscs kvscs' # high sinkd density and Temp, with active Diffusion
    prop_values = '1.0e-15 1.0e-15 -1.0e-5 -1.0e-8'
  [../]
  [./CuGrGr]
    # Material properties
    type = GBEvolution # Quantitative material properties for copper grain growth.  Dimensions are nm and ns
    GBmob0 = 2.5e-6 #Mobility prefactor for Cu from Schonfelder1997
    GBenergy = 0.708 #GB energy for Cu from Schonfelder1997
    Q = 0.23 #Activation energy for grain growth from Schonfelder 1997
    T = 500 # K   #Constant temperature of the simulation (for mobility calculation)
    wGB = 8 # nm      #Width of the diffuse GB

  [../]
  [./Thermal_Conductivity]
    type = ParsedMaterial
    f_name = thermal_conductivity
    args = 'gr0 gr1 gr2 gr3'
       function = 'A:=1;kb:=1;kgb:=(gr0^2+gr1^2+gr2^2+gr3^2);if((gr0^2+gr1^2+gr2^2+gr3^2)<0.99,kgb*A,kb*A)'
    outputs = exodus
  [../]
[]

[Postprocessors]
  [./tot_cv]
    type = ElementIntegralVariablePostprocessor
    variable = cv
  [../]
  [./tot_ci]
    type = ElementIntegralVariablePostprocessor
    variable = ci
  [../]
  [./average_cv]
    type = ElementAverageValue
    variable = cv
  [../]
  [./average_ci]
    type = ElementAverageValue
    variable = ci
  [../]
  [./right_jvx]
    type = SideAverageValue
    variable = jvx
    boundary = right
  [../]
  [./left_jvx]
    type = SideAverageValue
    variable = jvx
    boundary = left
  [../]
  [./right_jix]
    type = SideAverageValue
    variable = jix
    boundary = right
  [../]
  [./left_jix]
    type = SideAverageValue
    variable = jix
    boundary = left
  [../]
  # Scalar postprocessors
  [./dt]
    # Outputs the current time step
    type = TimestepSize
  [../]
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
  [./jx]
    type = SideAverageValue
    variable = jx
    boundary = right
  [../]
  [./right_jy]
    type = SideAverageValue
    variable = jy
    boundary = right
  [../]
  [./left_jx]
    type = SideAverageValue
    variable = jx
    boundary = left
  [../]
  [./left_jy]
    type = SideAverageValue
    variable = jy
    boundary = left
  [../]
  [./k_eff] #Effective thermal conductivity
  type = ThermalConductivity
  variable = T
  flux = jx
  length_scale = 1.0
  T_hot = 500
  dx = 1000.0
  boundary = left
  [../]
  [./bnd_length]
    type = GrainBoundaryArea
  [../]
[]
[VectorPostprocessors]
  [./x_direction]
   type =  LineValueSampler
    start_point = '0 433 0'
    end_point = '1000 433 0'
    variable = 'mat_therm_cond cv ci jvx jix T jx jy dTdx dTdy gr0'
    num_points = 5001
    sort_by =  id
  [../]
  [./y_direction]
   type =  LineValueSampler
    start_point = '500 0 0'
    end_point = '500 866 0'
    variable = 'T jx jy dTdx dTdy gr0'
    num_points = 5001
    sort_by =  id
  [../]
[]
[Preconditioning]

  [./SMP]
   type = SMP
    full = true
  [../]
[]
[Executioner]
  type = Transient # Type of executioner, here it is transient with an adaptive time step
  scheme = bdf2 # Type of time integration (2nd order backward euler), defaults to 1st order backward euler

  #Preconditioned JFNK (default)

  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -mat_mffd_type'
  petsc_options_value = 'hypre    boomeramg      50                ds'
  #petsc_options_iname = -pc_type
  #petsc_options_value = lu

  l_max_its = 30 # Max number of linear iterations
  l_tol = 1e-3 # Relative tolerance for linear solves
  nl_max_its = 40 # Max number of nonlinear iterations
  nl_abs_tol = 1e-11 # Absolute tolerance for nonlienar solves
  nl_rel_tol = 1e-7 # Relative tolerance for nonlienar solves

  start_time = 0.0
#  end_time = 1
num_steps = 150000

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.5 # Initial time step.  In this simulation it changes.
    optimal_iterations = 7 #Time step will adapt to maintain this number of nonlinear iterations
  [../]

  [./Adaptivity]
    # Block that turns on mesh adaptivity. Note that mesh will never coarsen beyond initial mesh (before uniform refinement)
    initial_adaptivity = 3 # Number of times mesh is adapted to initial condition
    refine_fraction = 0.6 # Fraction of high error that will be refined
    coarsen_fraction = 0.03 # Fraction of low error that will coarsened
    max_h_level = 5 # Max number of refinements used, starting from initial mesh (before uniform refinement)
  [../]
[]

[Outputs]
  file_base = Case1_lowtemp_lowsink_thermal_hexagonal
  exodus = true
  csv = true
[]
