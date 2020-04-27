# this input file couples rate-theory equations to the phase-field grain growth model
# reaction terms are added to RT equations to account for defects-GB interactions
# Effect of defects on grain growth is neglected (one-way coupling)
[Mesh]
  type = GeneratedMesh
  uniform_refine = 2
  dim = 2
  nx = 64
  ny = 64
  nz = 0
  xmax = 256
  ymax = 256
[]

[GlobalParams]
  op_num = 2 # Number of OPs (Phase-field variables)
  var_name_base = eta # Base name of grains
  block = '0'
[]

[Variables]
  [./cv]
  [../]
  [./ci]
  [../]
  [./PolycrystalVariables]
    # Custom action that created all of the grain variables
    order = FIRST # element type used by each grain variable
    family = LAGRANGE
  [../]
  [./D] #Temperature used for the direct calculation
    initial_condition = 450
  [../]
[]
[AuxVariables]
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
[AuxKernels]
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
[ICs]

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
  [./PolycrystalICs] # A simple Bicrystal configuration/ Hexagonal and Voronoi ICs and Grain Tracker Object might be used as well
    [./BicrystalBoundingBoxIC]
      x1 = 0
      y1 = 0
      x2 = 128
      y2 = 256
    [../]
  [../]

[]
[BCs]
  # Eternal/Domain surface is ignoed as a sink and only discrete GBs are considered
  active = 'T_left T_right'
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

[Kernels]

  [./PolycrystalKernel]
    # Custom action creating all necessary kernels for grain growth.  All input parameters are up in GlobalParams
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

[Materials]
  [./cvci_reaction_rate] # Low recombination rate
    type = DerivativeParsedMaterial
    function = -kiv*ci
    constant_names = 'kiv'
    constant_expressions = '1e-9'
    args = 'ci'
    f_name = kivci
    derivative_order = 1
  [../]
  [./cicv_reaction_rate] # Low recombination rate
    type = DerivativeParsedMaterial
    function = -kiv*cv
    constant_names = 'kiv'
    constant_expressions = '1e-9'
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
    prop_values = '1.0e-3 1.0 -1.0e-2 -1.0e-5'
  [../]
  [./CuGrGr]
    # Material properties
    type = GBEvolution # Quantitative material properties for copper grain growth.  Dimensions are nm and ns
    GBmob0 = 2.5e-6 #Mobility prefactor for Cu from Schonfelder1997
    GBenergy = 0.708 #GB energy for Cu from Schonfelder1997
    Q = 0.23 #Activation energy for grain growth from Schonfelder 1997
    T = 450 # K   #Constant temperature of the simulation (for mobility calculation)
    wGB = 4 # nm      #Width of the diffuse GB
  [../]
  [./Thermal_Conductivity]
    type = ParsedMaterial
      block = 0
  function = 'kb:=1;k2p:=(eta0^2+eta1^2);if((eta0^2+eta1^2)=1,kb,k2p)'
      outputs = exodus
      f_name = thermal_conductivity
      args = 'eta0 eta1'
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
  [./k_x_direct] #Effective thermal conductivity from direct method
    # This value is lower than the AEH value because it is impacted by second phase
    # on the right boundary
    type = ThermalConductivity
    variable = 'D'
    flux = jx
    length_scale = 1e-00
    T_hot = T_hot
    dx = 256
    boundary = right
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
  [./x_direc]
   type =  LineValueSampler
    start_point = '0 128 0'
    end_point = '256 128 0'
    variable = 'cv ci jvx jix D jx jy mat_therm_cond'
    num_points = 5121
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
solve_type = 'PJFNK'
petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -mat_mffd_type'
petsc_options_value = 'hypre    boomeramg      100                ds'
l_max_its = 15
l_tol = 1e-3
nl_max_its = 15
nl_abs_tol = 1e-10
nl_rel_tol = 1e-7
start_time = 0.0
#end_time = 4
num_steps = 150000

  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = .75
    dt = 1.0
    growth_factor = 1.2
    optimal_iterations = 7
  [../]
[]

[Outputs]
  file_base = Case5_hightemp_highsink_highDiffusion_thermal_bicrystal
  exodus = true
  csv = true
  interval = 1

[]
