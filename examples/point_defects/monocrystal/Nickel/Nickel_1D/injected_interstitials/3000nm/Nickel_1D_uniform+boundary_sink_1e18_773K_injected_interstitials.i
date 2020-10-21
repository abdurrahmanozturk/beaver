#
#--------------------------------------------------------------------------------------------------------
# Nickel Case in 1D
# Solution of Point Defect Balance Equations (Eq. 5.1) from the texbook
# Fundementals of Radiation Materials Science, Gary S. Was
# Notes : 1- Equations are non-dimensionalized
#         2- Sinks are uniformly distributed and located at boundaries
#         3- Non-uniformly distributed defect sources
#         4- Injected interstitials are considered
#         5- Nickel parameters are used
#--------------------------------------------------------------------------------------------------------
#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#----------------------------------------------------Mesh------------------------------------------------
[Mesh]
  type = GeneratedMesh  # use file mesh by external mesh generator vacancy fracion is one for cirlce bc
  dim = 1
  nx = 3000
  # ny = 32
  xmax = 3000
  # ymax = 256
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#-----------------------------------------------AuxVariables---------------------------------------------
[AuxVariables]
  [./xs]    #Uniform sink concentration
    initial_condition = 1.206e-11
  [../]
  [./l]     #Length scale
    initial_condition = 1e-09
  [../]
  [./Di]    #Interstitial Diffusion Coefficient {m^2/s}
    initial_condition = 1
  [../]
  [./Dv]    #Vacancy  Diffusion Coefficient {m^2/s}
    initial_condition = 1.810e-04
  [../]
  [./K0]     #Displacement damage rate  {dpa/s}
    initial_condition = 9.037e-13
  [../]
  [./K0_dist] #distributed displacement damage rate  {dpa/s}
    initial_condition = 9.037e-13
  [../]
  [./K0_dist_FP] #distributed displacement damage rate  {dpa/s}
  [../]
  [./K0_dist_II] #distributed displacement damage rate  {dpa/s}
  [../]
  [./bias]    #vacancy generation rate bias {1 = no bias}
    initial_condition = 1.000e+00
  [../]
  [./Kiv]     #Recombination rate  {1/s}
    initial_condition = 3668.460966
  [../]
  [./Kis]     #Sink Reaction rate  {1/s}
    initial_condition = 3667.796398
  [../]
  [./Kvs]     #Sink Reaction rate  {1/s}
    initial_condition = 0.6645681
  [../]
  [./xie]
  [../]
  [./xve]
    initial_condition = 3.7e-11
  [../]
  [./super_saturation]
  [../]
  [./void_nucleation_rate]
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
  [./K0_dist_FP]
    type = FunctionAux
    variable = K0_dist_FP
    function = dist_source_FP
  [../]
  [./K0_dist_II]
    type = FunctionAux
    variable = K0_dist_II
    function = dist_source_II
  [../]
  [./super_saturation]
    type = ParsedAux
    variable = super_saturation
    args = 'Di xi Dv xv xve'
    function = '(Dv*xv-Di*xi)/(Dv*xve)'
  [../]
  [./void_nucleation_rate]
    type = ParsedAux
    variable = void_nucleation_rate
    args = 'super_saturation'
    function = 'pow(super_saturation,5.41547)*exp(-14.6586)'
  [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#-------------------------------------------------Variables----------------------------------------------
[Variables]
  [./xi]
    scaling =1e4 #variables
  [../]
  [./xv]
    scaling =1e4 #variables
  [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#-------------------------------------------------Functions----------------------------------------------
[Functions]
  [./dist_source_FP]
    type = PiecewiseLinear
    data_file = vacancy.csv
    format = columns
    axis = 0
  [../]
  [./dist_source_II]
    type = PiecewiseLinear
    data_file = range.csv
    format = columns
    axis = 0
  [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#--------------------------------------------------Kernels-----------------------------------------------
[Kernels]
  [./defect_generation_i]
    type = MaskedBodyForce
    variable = xi
    mask = source_i
    args = 'K0_dist_FP bias'
  [../]
  [./injected_interstitials_i]
    type = MaskedBodyForce
    variable = xi
    mask = injected_interstitials_i
    args = 'K0_dist_II'
  [../]
  [./defect_generation_v]
    type = MaskedBodyForce
    variable = xv
    mask = source_v
    args = 'K0_dist_FP bias'
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
  # [./Periodic]
  #   [./all]
  #     auto_direction = 'x y'
  #   [../]
  # [../]
  [./xi_bc]
    type = DirichletBC
    variable = xi
    value = 0
    boundary = 'left right'
  [../]
  [./xv_bc]
    type = DirichletBC
    variable = xv
    value = 3.7e-11
    boundary = 'left right'
  [../]
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#--------------------------------------------------ICs---------------------------------------------------
[ICs]
  [./xv]
    type = RandomIC
    min = 3.6e-11       # Nickel equilibrium vacancy concentration
    max = 3.8e-11
    variable = xv
  [../]
  [./xi]
    type = RandomIC
    min = 1e-17
    max = 3e-17
    variable = xi
  [../]
  # [./xs]
  #   type = RandomIC
  #   min = 0
  #   max = 1
  #   variable = xs
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
    type = GenericFunctionMaterial
    prop_names = source_i
    prop_values = dist_source_FP
  [../]
  [./injected_interstitials_i]
    type = GenericFunctionMaterial
    prop_names = injected_interstitials_i
    prop_values = dist_source_II
  [../]
  [./source_v]
    type = GenericFunctionMaterial
    prop_names = source_v
    prop_values = dist_source_FP
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
  [./xDi]
    type = ElementAverageValue
    variable = Di
  [../]
  [./xDv]
    type = ElementAverageValue
    variable = Dv
  [../]
[]
[VectorPostprocessors]
  [./x_direc]
   type =  LineValueSampler
    start_point = '0 0 0'
    end_point = '3000 0 0'
    variable = 'xi xv jvx jix xie xve Di Dv K0_dist_FP K0_dist_II super_saturation void_nucleation_rate'
    num_points = 3001
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
  petsc_options_value = 'asm lu  '  #  either asm or hypre'
  l_tol = 1e-3 # Relative tolerance for linear solves
  nl_max_its = 15 # Max number of nonlinear iterations
  nl_abs_tol = 1e-16 # Relative tolerance for nonlienar solves
  nl_rel_tol = 1e-6 # Absolute tolerance for nonlienar solves
  scheme = bdf2   #try crank-nicholson
  start_time = 0
  end_time = 1e22 #executioner
  steady_state_detection = true
  steady_state_tolerance = 1e-16 #executioner
  dtmin = 1e-3 #executioner
  dtmax = 1e14 #executioner
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1 #s
    optimal_iterations = 5
    growth_factor = 1.2
    cutback_factor = 0.8
  [../]
  # [./Adaptivity]
  #     refine_fraction = 0.5
  #     coarsen_fraction = 0.05
  #     max_h_level = 2
  #    initial_adaptivity = 2
  # [../]
  # postprocessor = cv
  # skip = 25
  # criteria = 0.01
  # below = true
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#----------------------------------------------Outputs----------------------------------------------------
[Outputs]
  # exodus = true
  file_base = Nickel_1D_uniform+boundary_sink_1e18_773K_injected_interstitials
  [./exodus]
    type = Exodus

    enable = true #exodus
    output_material_properties = 1
    output_postprocessors = true
    interval = 10
  [../]
  csv = true
  interval = 10 #exodus
[]
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
