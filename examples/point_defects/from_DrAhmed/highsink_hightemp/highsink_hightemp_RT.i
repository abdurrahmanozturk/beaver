
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

  block = '0'
[]

[Variables]
  [./cv]
  [../]
  [./ci]
  [../]
[]    # fluxes added to compare between periodic BCs and Zero Dirchilet (representing a perfect sink such as GB)
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
    function = '-1.0e-15*dcvdx'
  [../]
  [./jix]
    type = ParsedAux
    variable = jix
    args = 'dcidx'
    function = '-1.0e-15*dcidx'
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

[]
[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
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
[./ci_source]
    type = MaskedBodyForce
    variable = ci
    value = 1e-6
    mask = 1
  [../]

[]

[Materials]
  [./cvci_reaction_rate] # low recombination rate
    type = DerivativeParsedMaterial
    function = -kiv*ci
    constant_names = 'kiv'
    constant_expressions = '1e-9'
    args = 'ci'
    f_name = kivci
    derivative_order = 1
  [../]
  [./cicv_reaction_rate] # low recombination rate
    type = DerivativeParsedMaterial
    function = -kiv*cv
    constant_names = 'kiv'
    constant_expressions = '1e-9'
    args = 'cv'
    f_name = kivcv
    derivative_order = 1
  [../]
  [./const]
    type = GenericConstantMaterial # high sinkd density and high Temp, but Diffusion is ignored
    prop_names = 'Dv Di kiscs kvscs'
    prop_values = '1.0e-15 1.0e-15 -1.0e-2 -1.0e-5'
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
[]

[VectorPostprocessors]
  [./x_direc]
   type =  LineValueSampler
    start_point = '0 128 0'
    end_point = '256 128 0'
    variable = 'cv ci jvx jix'
    num_points = 257
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
   petsc_options_value = 'asm ilu'
  l_max_its = 15
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-6
  start_time = 0.0
  num_steps = 150000
  nl_abs_tol = 1e-8
  #dtmax=10
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = .75
    dt = 1.0
    growth_factor = 1.2
    optimal_iterations = 7
  [../]
[]

[Outputs]
  file_base = RT_highSink_highTemp_NO_DIFF
  exodus = true
  csv = true
  interval = 1

[]
