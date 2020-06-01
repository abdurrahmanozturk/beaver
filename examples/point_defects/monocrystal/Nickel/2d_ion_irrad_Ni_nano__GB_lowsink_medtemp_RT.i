# Using Ni model parameters
# At T = 773K(500C), D_i = 1e-9 m^2/s, D_v = 2e-13 m^2/s
# c_v_eq = 3.7e-11
# length_scale = 1e-9 m , time_scale = 1e-9 s

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 256
  ny = 32
  nz = 0
  xmax = 256
  ymax = 32
  elem_type = QUAD4
[]

[Variables]
  [./cv]
  [../]
  [./ci]
  [../]
[]
[AuxVariables] # fluxes added to compare between periodic BCs and Zero Dirchilet (representing a perfect sink such as GB)
  [./dcvdx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dcidx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dcvdy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dcidy]
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
  [./jvy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./jiy]
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
  [./dcvdy]
    type = VariableGradientComponent
    variable = dcvdy
    gradient_variable = cv
    component = y
  [../]
  [./dcidy]
    type = VariableGradientComponent
    variable = dcidy
    gradient_variable = ci
    component = y
  [../]
  [./jvx]
    type = ParsedAux
    variable = jvx
    args = 'dcvdx'
    function = '-2.0e-4*dcvdx'
  [../]
  [./jix]
    type = ParsedAux
    variable = jix
    args = 'dcidx'
    function = '-1.0*dcidx'
  [../]
  [./jvy]
    type = ParsedAux
    variable = jvy
    args = 'dcvdy'
    function = '-2.0e-4*dcvdy'
  [../]
  [./jiy]
    type = ParsedAux
    variable = jiy
    args = 'dcidy'
    function = '-1.0*dcidy'
  [../]

[]
[ICs]

  [./cv]
    type = RandomIC
    variable = 'cv'
    min = 3.6e-11   # EQ Value at 500C
    max = 3.8e-11
     seed = 10
  [../]

  [./ci]
    type = RandomIC
    variable = 'ci'
    min = 1e-17
    max = 3e-17
     seed = 11
  [../]

[]
[BCs]  # domain boundaries are perfect unbiased sinks (such as void surfaces or GBs)
  [./cv]
    type = DirichletBC
    variable = cv
    boundary = 'left right top bottom'
    value = 3.7e-11  # EQ Value at 500C
  [../]
  [./ci]
    type = DirichletBC
    variable = ci
    boundary = 'left right top bottom'
    value = 0.0
  [../]
[]

[Kernels]

############# cv_eqn ###################
[./cv_dot]
  type = TimeDerivative
  variable = 'cv'
[../]
[./cv_diff]
  type = MatDiffusion
  variable = cv
  diffusivity = Dv

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
[./cv_source]
    type = BodyForce
    variable = cv
    value = 1.1e-12  # dpa/s* time_scale
    # 1e-3 dpa/s for ion irradiation
    # 1e-6 dpa/s for neutron irradiation
    # 10% biased
  [../]


############# ci_eqn ###################
[./ci_dot]
  type = TimeDerivative
  variable = 'ci'
[../]
[./ci_diff]
  type = MatDiffusion
  variable = ci
  diffusivity = Di

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
[./ci_source]
    type = BodyForce
    variable = ci
    value = 1.0e-12
  [../]

[]

[Materials]
  [./cvci_reaction_rate] # low recombination rate
    type = DerivativeParsedMaterial
    function = -kiv*ci
    constant_names = 'kiv'
    constant_expressions = '3.7e3'
    args = 'ci'
    f_name = kivci
    derivative_order = 1
    # K-iv = 4*Pi*r*length_scale^2/omega
    # r = cpature_readius = 10*a, a = lattice parameter = 0.352nm
    # omega = atomic_volume = 1.2*10^-29 m^3
  [../]
  [./cicv_reaction_rate] # low recombination rate
    type = DerivativeParsedMaterial
    function = -kiv*cv
    constant_names = 'kiv'
    constant_expressions = '3.7e3'
    args = 'cv'
    f_name = kivcv
    derivative_order = 1
  [../]
  [./const]
    type = GenericConstantMaterial # low sink density and high Temp, with Diffusion to GBs
    prop_names = 'Dv Di kiscs kvscs'
    prop_values = '2.0e-4 1.0 -4.42e-6 -8.84e-10'
    # K_iscs = 4*Pi*r*length_scale^2*Cs
    # Cs = Sink_density = 1e20 1/m^3 (low)
    # K_vscs/K_iscs = D_v/D_i
  [../]

[]

[Postprocessors]
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
  #---------y-----------
  [./top_jvy]
    type = SideAverageValue
    variable = jvy
    boundary = top
  [../]
  [./bottom_jvx]
    type = SideAverageValue
    variable = jvy
    boundary = bottom
  [../]
  [./top_jiy]
    type = SideAverageValue
    variable = jiy
    boundary = top
  [../]
  [./bottom_jix]
    type = SideAverageValue
    variable = jiy
    boundary = bottom
  [../]

[]

[VectorPostprocessors]
  [./x_direc]
   type =  LineValueSampler
    start_point = '0 16 0'
    end_point = '256 16 0'
    variable = 'cv ci jvx jix jvy jiy'
    num_points = 257
    sort_by =  id
  [../]
  [./y_direc]
   type =  LineValueSampler
    start_point = '128 0 0'
    end_point = '128 32 0'
    variable = 'cv ci jvx jix jvy jiy'
    num_points = 33
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
  # Preconditioned JFNK (default)
   scheme = bdf2
  type = Transient
  nl_max_its = 10
  solve_type = NEWTON
   petsc_options_iname = '-pc_type -sub_pc_type'
   petsc_options_value = 'asm lu'
  l_max_its = 20
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-6
  start_time = 0.0
  num_steps = 150000
  steady_state_detection = true
  steady_state_tolerance = 1.0e-9
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = .75
    dt = 1.0 # time_scale = 1e-9 s
    growth_factor = 1.2
    optimal_iterations = 7
  [../]
  [./Adaptivity]
      refine_fraction = 0.5
      coarsen_fraction = 0.05
      max_h_level = 2
     initial_adaptivity = 2
    [../]
[]
[Outputs]
  file_base = ion_irr_2dRT_lowSink_IntermediateTemp_diffusion_to_GB256x32_1e-9l
  exodus = true
  csv = true
  interval = 1
  # physical_time = simulation_time*time_scale(1e-9 s)

[]
