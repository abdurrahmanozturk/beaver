#
#--------------------------------------------------------------------------------------------------------
# Solution of Point Defect Balance Equations (Eq. 5.1) from the texbook
# Fundementals of Radiation Materials Science, Gary S. Was
# Notes : 1- Equations are non-dimensionalized
#         2- Sinks are uniformly distributed
#--------------------------------------------------------------------------------------------------------
#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#----------------------------------------------------Mesh------------------------------------------------
[Mesh]
  type = GeneratedMesh  # use file mesh by external mesh generator vacancy fracion is one for cirlce bc
  dim = 2
  nx = 64
  ny = 64
  xmax = 256
  ymax = 256
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#-----------------------------------------------AuxVariables---------------------------------------------
[AuxVariables]
  [./xs]    #Uniform sink concentration
  initial_condition = 1
  [../]
  [./Di]    #Interstitial Diffusion Coefficient {m^2/s}
  initial_condition = 1e-15
  [../]
  [./Dv]    #Vacancy  Diffusion Coefficient {m^2/s}
  initial_condition = 1e-15
  [../]
  [./K0]     #Displacement damage rate  {dpa/s}
  initial_condition = 1.000e-05
  [../]
  [./Kiv]     #Recombination rate  {1/s}
  initial_condition = 1e2
  [../]
  [./Kis]     #Sink Reaction rate  {1/s}
  initial_condition = 1e-4
  [../]
  [./Kvs]     #Sink Reaction rate  {1/s}
  initial_condition = 1e-7
  [../]
  [./ci]
  [../]
  [./cv]
  [../]
  [./dxvdx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dxidx]
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
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#------------------------------------------------AuxKernels----------------------------------------------
[AuxKernels]
  [./dxvdx]
    type = VariableGradientComponent
    variable = dxvdx
    gradient_variable = xv
    component = x
  [../]
  [./dxidx]
    type = VariableGradientComponent
    variable = dxidx
    gradient_variable = xi
    component = x
  [../]
  [./jvx]
    type = ParsedAux
    variable = jvx
    args = 'Dv dxvdx'
    function = '-Dv*dxvdx'
  [../]
  [./jix]
    type = ParsedAux
    variable = jix
    args = 'Di dxidx'
    function = '-Di*dxidx'
  [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#-------------------------------------------------Variables----------------------------------------------
[Variables]
  [./xi]
    # initial_condition = 0
  [../]
  [./xv]
    # initial_condition = 0
  [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#-------------------------------------------------Functions----------------------------------------------
[Functions]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#--------------------------------------------------Kernels-----------------------------------------------
[Kernels]
  [./defect_generation_i]
    type = MaskedBodyForce
    variable = xi
    mask = source_i
    args = 'K0'
  [../]
  [./defect_generation_v]
    type = MaskedBodyForce
    variable = xv
    mask = source_v
    args = 'K0'
  [../]
  [./recombination_i]
    type = MatReaction
    variable = xi
    args = 'xv Kiv'     #coupled on materials block
    mob_name = reaction_i
  [../]
  [./recombination_v]
    type = MatReaction
    variable = xv
    args = 'xi Kiv'    #coupled in materials block
    mob_name = reaction_v
  [../]
  [./sink_reaction_i]
    type = MatReaction
    variable = xi
    args = 'xs Kis'     #coupled on materials block
    mob_name = sink_i
  [../]
  [./sink_reaction_v]
    type = MatReaction
    variable = xv
    args = 'xs Kvs'    #coupled in materials block
    mob_name = sink_v
  [../]
  [./xi_diff]
    type = MatDiffusion
    variable = xi
    args = Di
    D_name = diff_i
  [../]
  [./xv_diff]
    type = MatDiffusion
    variable = xv
    args = Dv
    D_name = diff_v
  [../]
  [./xi_time]
    type = TimeDerivative
    variable = xi
  [../]
  [./xv_time]
    type = TimeDerivative
    variable = xv
  [../]
  # [./defect_i]
  #   type = PointDefect
  #   variable = ci
  #   coupled = cv
  #   ks = 38490
  #   k = 1e-2
  #   kiv = 7.49e10
  #   D = 1.35e-7
  #   # disable_diffusion = true
  # [../]
  # [./defect_v]
  #   type = PointDefect
  #   variable = cv
  #   coupled = ci
  #   ks = 36580
  #   k = 1e-2
  #   kiv = 7.49e10
  #   D = 9.4e-13
  #   # disable_diffusion = true
  # [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#--------------------------------------------------BCs---------------------------------------------------
[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
  # [./xi_bc]
  #   type = DirichletBC
  #   variable = xi
  #   value = 0
  #   boundary = '0 1 2 3'
  # [../]
  # [./xv_bc]
  #   type = DirichletBC
  #   variable = xv
  #   value = 0
  #   boundary = '0 1 2 3'
  # [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#--------------------------------------------------ICs---------------------------------------------------
[ICs]
  [./xv]
    type = RandomIC
    min = 1e-11
    max = 3e-11
    variable = xv
  [../]
  [./xi]
    type = RandomIC
    min = 1e-11
    max = 3e-11
    variable = xi
  [../]
  # [./cs]
  #   type = RandomIC
  #   min = 0
  #   max = 1
  #   variable = cs
  # [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#-----------------------------------------------Materials-------------------------------------------------
[Materials]
  #diffusion coefficients
  [./diff_i]
    type = ParsedMaterial
    f_name = diff_i
    args = Di
    function = Di
  [../]
  [./diff_v]
    type = ParsedMaterial
    f_name = diff_v
    args = Dv
    function = Dv
  [../]
  [./source_i]
    type = ParsedMaterial
    f_name = source_i
    args = K0
    function = K0
  [../]
  [./source_v]
    type = ParsedMaterial
    f_name = source_v
    args = K0
    function = K0
  [../]
  [./reaction_i]
    type = DerivativeParsedMaterial
    f_name = reaction_i
    args = 'xv Kiv'
    function = -Kiv*xv  # 1/s regular case
    derivative_order = 1
  [../]
  [./reaction_v]
    type = DerivativeParsedMaterial
    f_name = reaction_v
    args = 'xi Kiv'
    function = -Kiv*xi  # 1/s regular case
    derivative_order = 1
  [../]
  [./sink_i]
    type = DerivativeParsedMaterial
    f_name = sink_i
    args = 'xs Kis'
    function = -Kis*xs # 1/s      regular case
  [../]
  [./sink_v]
    type = DerivativeParsedMaterial
    f_name = sink_v
    args = 'xs Kvs'
    function = -Kvs*xs # 1/s      regular case
  [../]
  [./dt]
    type = TimeStepMaterial
    prop_time = timestep
  [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#--------------------------------------------Postprocessors------------------------------------------------
[Postprocessors]
  [./average_xv]
    type = ElementAverageValue
    variable = xv
  [../]
  [./average_xi]
    type = ElementAverageValue
    variable = xi
  [../]
  [./center_xi]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = xi
  [../]
  [./center_xv]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = xv
  [../]
  [./center_xs]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = xs
  [../]
  [./total_cv]
    type = ElementIntegralVariablePostprocessor
    variable = xv
  [../]
  [./total_ci]
    type = ElementIntegralVariablePostprocessor
    variable = xi
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
    variable = 'xi xv'
    num_points = 257
    sort_by =  id
  [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#--------------------------------------------Preconditioning------------------------------------------------
[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#----------------------------------------------Executioner-------------------------------------------------
[Executioner]
  type = Transient
  solve_type = 'NEWTON'  #try NEWTON,PJFNK
  petsc_options_iname = '-pc_type -sub_pc_type'
  petsc_options_value = 'asm ilu  '  #  either asm or hypre'
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 15 # Max number of nonlinear iterations
  nl_abs_tol = 1e-9 # Relative tolerance for nonlienar solves
  nl_rel_tol = 1e-6 # Absolute tolerance for nonlienar solves
  scheme = bdf2   #try crank-nicholson
  start_time = 0
  num_steps = 4294967295
  steady_state_detection = true
  # end_time = 30000
  # dt = 1
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1 #s
    optimal_iterations = 5
    growth_factor = 1.2
    cutback_factor = 0.8
  [../]
  # postprocessor = cv
  # skip = 25
  # criteria = 0.01
  # below = true
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#----------------------------------------------Outputs----------------------------------------------------
[Outputs]
  # exodus = true
  file_base = Case2_uniform_sink_initial_condition_1.000e-05/Case2_uniform_sink_initial_condition_1.000e-05
  [./exodus]
    type = Exodus
    
    # show_material_properties = 'D' # set material properite to a variable so it can be output
    output_material_properties = 1
    output_postprocessors = true
    interval = 1
  [../]
  csv = true
  #xda = true
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
