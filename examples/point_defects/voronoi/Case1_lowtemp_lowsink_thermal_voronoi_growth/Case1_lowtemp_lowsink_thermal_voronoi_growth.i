# This simulation predicts GB migration of a 2D copper polycrystal with 100 grains
# Mesh adaptivity and time step adaptivity are used
# An AuxVariable is used to calculate the grain boundary locations
# Postprocessors are used to record time step and the number of grains

[Mesh]
  # Mesh block.  Meshes can be read in or automatically generated
  type = GeneratedMesh
  dim = 2 # Problem dimension
  nx = 125 # Number of elements in the x-direction
  ny = 125 # Number of elements in the y-direction
  nz = 0 # Number of elements in the z-direction
  xmin = 0    # minimum x-coordinate of the mesh
  xmax = 450 # maximum x-coordinate of the mesh
  ymin = 0    # minimum y-coordinate of the mesh
  ymax = 450# maximum y-coordinate of the mesh
  zmin = 0
  zmax = 0
  elem_type = QUAD4 # Type of elements used in the mesh
  uniform_refine = 2 # Initial uniform refinement of the mesh
[]

[GlobalParams]
  # Parameters used by several kernels that are defined globally to simplify input file
  op_num = 8 # Number of OPs (Phase-field variables)
  var_name_base = gr # Base name of grains
   block = '0'
[]

[UserObjects]
  # Used to initial random grain structure
  [./voronoi]
    type = PolycrystalVoronoi
    grain_num = 25
    rand_seed = 50
    coloring_algorithm = jp
  [../]
  # Used to track the grains
  [./grain_tracker]
    type = GrainTracker
    threshold = 0.2
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalColoringIC]
      polycrystal_ic_uo = voronoi
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
  # Variable block, where all variables in the simulation are declared
  [./PolycrystalVariables]
    # Custom action that created all of the grain variables
    order = FIRST # element type used by each grain variable
    family = LAGRANGE
  [../]
  [./D] #Temperature used for the direct calculation
    initial_condition = 450
  [../]
  [./cv]
  [../]
  [./ci]
  [../]
[]

[AuxVariables]
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
    [./PolycrystalKernel]
      args = 'D'
    [../]
    [./heat]
      type = HeatConduction
      variable = 'D'
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
    gradient_variable = 'D'
    component = x
  [../]
  [./dTdy]
    type = VariableGradientComponent
    variable = dTdy
    gradient_variable = 'D'
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
  # Boundary Condition block
  active = 'T_left T_right'
  [./Periodic]
    [./top_bottom]
      variable = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7'
      auto_direction = 'x y' # Makes problem periodic in the x and y directions
    [../]
  [../]
  [./T_left]
    type = DirichletBC
    variable = 'D'
    boundary = 'left'
    value = 15.0
  [../]
  [./T_right]
    type = DirichletBC
    variable = 'D'
    boundary = 'right'
    value = 5.0
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
  [./Copper]
    # Material properties
    type = GBEvolution # Quantitative material properties for copper grain growth.  Dimensions are nm and ns
    GBmob0 = 2.5e-6 #Mobility prefactor for Cu from Schonfelder1997
    GBenergy = 0.708 #GB energy for Cu from Schonfelder1997
    Q = 0.23 #Activation energy for grain growth from Schonfelder 1997
    T = 450 # K   #Constant temperature of the simulation (for mobility calculation)
    wGB = 10 # nm      #Width of the diffuse GB
  [../]

  [./Thermal_Conductivity]
    type = ParsedMaterial
      block = 0
  function = 'A:=1e-0;kb:=1;k2p:=(gr0^2+gr1^2+gr2^2+gr3^2+gr4^2+gr5^2+gr6^2+gr7^2);if((gr0^2+gr1^2+gr2^2+gr3^2+gr4^2+gr5^2+gr6^2+gr7^2)<=0.9608,k2p*A,kb*A)'
      outputs = exodus
      f_name = thermal_conductivity
      args = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7'
    [../]
[]

[Postprocessors]
  [./dt]
    # Outputs the current time step
    type = TimestepSize
  [../]
  [./DOFs]
    type = NumDOFs
    execute_on = 'INITIAL TIMESTEP_END'
  [../]

  [./k_x_direct] #Effective thermal conductivity from direct method
    type = ThermalConductivity
    variable = 'D'
    flux = jx
    length_scale = 1e-00
    T_hot = T_hot
    dx = 450
    boundary = right
  [../]
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
  [./T_cold]
    type = SideAverageValue
    variable = 'D'
    boundary = right
  [../]
  [./T_hot]
    type = SideAverageValue
    variable = 'D'
    boundary = left
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

[]

[VectorPostprocessors]
[./x_direction]
 type =  LineValueSampler
  start_point = '0 225 0'
  end_point = '450 225 0'
  variable = 'cv ci jvx jix D jx jy mat_therm_cond'
  num_points = 1001
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
  petsc_options_value = 'hypre    boomeramg      100                ds'

  l_max_its = 15 # Max number of linear iterations
  l_tol = 1e-3 # Relative tolerance for linear solves
  nl_max_its = 15 # Max number of nonlinear iterations
  nl_abs_tol = 1e-10 # Absolute tolerance for nonlienar solves
  nl_rel_tol = 1e-7 # Relative tolerance for nonlienar solves

  start_time = 0.0
  #end_time = 4
  num_steps = 150

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.25 # Initial time step.  In this simulation it changes.
    optimal_iterations = 7 #Time step will adapt to maintain this number of nonlinear iterations
  [../]

  [./Adaptivity]
    # Block that turns on mesh adaptivity. Note that mesh will never coarsen beyond initial mesh (before uniform refinement)
    initial_adaptivity = 2 # Number of times mesh is adapted to initial condition
    refine_fraction = 0.7 # Fraction of high error that will be refined
    coarsen_fraction = 0.1 # Fraction of low error that will coarsened
    max_h_level = 4 # Max number of refinements used, starting from initial mesh (before uniform refinement)
  [../]
[]

[Outputs]
  file_base = Case1_lowtemp_lowsink_thermal_voronoi_growth
  exodus = true
  csv = true
[]
