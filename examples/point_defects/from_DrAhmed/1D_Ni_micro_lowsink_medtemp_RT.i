# Using Ni model parameters
# At T = 773K(500C), D_i = 1e-9 m^2/s, D_v = 2e-13 m^2/s
# c_v_eq = 3.7e-11
# length_scale = 1e-10 m , time_scale = 1e-11 s
# Scaling is the same as in the 2D input files
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 50000
  xmax = 50000
[]

[GlobalParams]

  block = '0'
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
    function = '-2.0e-4*dcvdx'
  [../]
  [./jix]
    type = ParsedAux
    variable = jix
    args = 'dcidx'
    function = '-1.0*dcidx'
  [../]
[]
[ICs]

  [./cv]
    type = RandomIC
    variable = 'cv'
    min = 3.6e-11
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
  boundary = 'left right'
  value = 3.7e-11  # EQ Value at 500C
[../]
[./ci]
  type = DirichletBC
  variable = ci
  boundary = 'left right'
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
    type = BodyForce
    variable = cv
    value = 1.1e-14
    # 1e-3 dpa/s
    # 10% bias
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
    type = BodyForce
    variable = ci
    value = 1.0e-14
  [../]

[]

[Materials]
  [./cvci_reaction_rate] # low recombination rate
    type = DerivativeParsedMaterial
    function = -kiv*ci
    constant_names = 'kiv'
    constant_expressions = '1.4e1'
    args = 'ci'
    f_name = kivci
    derivative_order = 1
  [../]
  [./cicv_reaction_rate] # low recombination rate
    type = DerivativeParsedMaterial
    function = -kiv*cv
    constant_names = 'kiv'
    constant_expressions = '1.4e1'
    args = 'cv'
    f_name = kivcv
    derivative_order = 1
  [../]
  [./const]
    type = GenericConstantMaterial # low sink density and high Temp, with Diffusion to GBs
    prop_names = 'Dv Di kiscs kvscs'
    prop_values = '2.0e-4 1.0 -4.42e-8 -8.84e-12'
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
    start_point = '0 0 0'
    end_point = '50000 0 0'
    variable = 'cv ci jvx jix'
    num_points = 50001
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
  steady_state_tolerance = 1.0e-12
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = .75
    dt = 1.0
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
  file_base = 1D_5micron_ion_RT_lowSink_IntermediateTemp_diffusion_to_GB
  exodus = true
  csv = true
  interval = 1

[]
