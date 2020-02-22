#----------------------------------------------------Mesh------------------------------------------------
[Mesh]
  type = FileMesh
  file = void.msh
  # dim = 2
  # nx = 100
  # ny = 100
  # xmin = 0
  # xmax = 1
  # ymin = 0
  # ymax = 1
[]
#----------------------------------------------------Mesh------------------------------------------------


#----------------------------------------------------MeshModifiers------------------------------------------------
[MeshModifiers]
[]
#----------------------------------------------------MeshModifiers------------------------------------------------


#-------------------------------------------------Variables----------------------------------------------
[Variables]
  [./ci]
    initial_condition = 0
    block = domain
  [../]
  [./cv]
    initial_condition = 0
    block = domain
  [../]
[]
#-------------------------------------------------Variables----------------------------------------------


#-----------------------------------------------AuxVariables---------------------------------------------
[AuxVariables]
  [./xi]
  [../]
  [./xv]
  [../]
  [./cs]
    block = domain
    # initial_condition = 1
  [../]
[]
#-----------------------------------------------AuxVariables---------------------------------------------



#-------------------------------------------------Functions----------------------------------------------
[Functions]
[]
#-------------------------------------------------Functions----------------------------------------------


#--------------------------------------------------Kernels-----------------------------------------------
[Kernels]
  [./defect_generation_i]
    type = BodyForce  #maskedbodyforce
    variable = ci
    # value = 1e-7   #dpa/s   recombination dominated case
    value = 1e-6   #dpa/s   regular case
    block = domain
  [../]
  [./defect_generation_v]
    type = BodyForce
    variable = cv
    # value = 1e-7   #dpa/s   recombination dominated case
    value = 1e-6   #dpa/s   regular case
    block = domain
  [../]
  [./recombination_i]
    type = MatReaction
    variable = ci
    args = cv     #coupled on materials block
    mob_name = Kiv
    block = domain
  [../]
  [./recombination_v]
    type = MatReaction
    variable = cv
    args = ci    #coupled in materials block
    mob_name = Kvi
    block = domain
  [../]
  # [./sink_reaction_i]
  #   type = MatReaction
  #   variable = ci
  #   mob_name = Kis
  #   args = cs     #coupled on materials block
  #   block = domain
  # [../]
  # [./sink_reaction_v]
  #   type = MatReaction
  #   variable = cv
  #   mob_name = Kvs
  #   args = cs    #coupled in materials block
  #   block = domain
  # [../]
  [./ci_diff]
    type = MatDiffusion
    variable = ci
    D_name = Di
    block = domain
  [../]
  [./cv_diff]
    type = MatDiffusion
    variable = cv
    D_name = Dv
    block = domain
  [../]
  [./ci_time]
    type = TimeDerivative
    variable = ci
    block = domain
  [../]
  [./cv_time]
    type = TimeDerivative
    variable = cv
    block = domain
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
#--------------------------------------------------Kernels-----------------------------------------------



#------------------------------------------------AuxKernels----------------------------------------------
[AuxKernels]
  [./xi]
    type = ParsedAux
    variable = xi
    args = ci
    function = 'kiv:=7.49e10;k:=1e-2;ci*sqrt(kiv/k)'
    block = domain
  [../]
  [./xv]
    type = ParsedAux
    variable = xv
    args = cv
    function = 'kiv:=7.49e10;k:=1e-2;cv*sqrt(kiv/k)'
    block = domain
  [../]
  # [./cs]
  #   type = ParsedAux
  #   variable = cs
  #   function = 'R:=0.707;if(x*x+y*y<=R*R,1,0)'
  # [../]
[]
#------------------------------------------------AuxKernels----------------------------------------------



#--------------------------------------------------BCs---------------------------------------------------
[BCs]
 [./ci_5]
   type = DirichletBC
   variable = ci
   value = 0
   boundary = void
 [../]
 [./cv_5]
   type = DirichletBC
   variable = cv
   value = 0
   boundary = void
 [../]
 # [./cs_5]
 #   type = DirichletBC
 #   variable = cs
 #   value = 1
 #   boundary = outside
 # [../]
[]
#--------------------------------------------------BCs---------------------------------------------------


#--------------------------------------------------ICs---------------------------------------------------
[ICs]
  # [./cs_ic]
  #   type = FunctionIC
  #   variable = cs
  #   function = 'R:=0.25;if(pow(x,2)+pow(y,2)<=R*R,1,0)'
  # [../]
#   [./cv]
#     type = RandomIC
#     min = 0
#     max = 1
#     variable = ci
#     # x1 = 0.5
#     # y1 = 0.5
#     # invalue = 1
#     # outvalue = 0
#     # radius = '0.25'
#   [../]
#   [./ci]
#     type = RandomIC
#     min = 0
#     max = 1
#     variable = cv
#     # x1 = 0.5
#     # y1 = 0.5
#     # invalue = 1
#     # outvalue = 0
#     # radius = '0.25'
#   [../]
[]
#--------------------------------------------------ICs---------------------------------------------------


#-----------------------------------------------Materials-------------------------------------------------
[Materials]
 [./D]
   type = GenericConstantMaterial # diffusion coeficients
   prop_names = 'Di Dv'
   # prop_values = '5e-14 1.3e-28'   # cm2/sec      recombination dominated case
   prop_values = '1.35e-7 9.4e-13' # cm2/sec      regular case
   block = domain
 [../]
 [./Kiv]
   type = DerivativeParsedMaterial
   f_name = Kiv
   args = cv
   # function = 'kiv:=1.7e4;kiv*cv'    # 1/s recombination dominated
   function = 'kiv:=7.49e10;-kiv*cv'  # 1/s regular case
   block = domain
 [../]
 [./Kvi]
   type = DerivativeParsedMaterial
   f_name = Kvi
   args = ci
   # function = 'kiv:=1.7e4;kiv*ci'    # 1/s recombination dominated
   function = 'kiv:=7.49e10;-kiv*ci'  # 1/s regular case
   block = domain
 [../]
 [./Kis]
   type = DerivativeParsedMaterial
   f_name = Kis
   args = cs
   # function = 'Di:=5e-14;ki:=38490;Di*ki*ki*cs' # 1/s      recombination dominated case
   function = 'Di:=1.35e-7;ki:=38490;-Di*ki*ki/cs' # 1/s      regular case
   block = domain
 [../]
 [./Kvs]
   type = DerivativeParsedMaterial
   f_name = Kvs
   args = cs
   # function = 'Dv:=1.3e-28;kv:=36580;Dv*Dv*kv*cs' # 1/s      recombination dominated case
   function = 'Dv:=9.4e-13;kv:=36580;-Dv*kv*kv/cs' # 1/s      regular case
   block = domain
 [../]
 # [./k_values]
 #   type = GenericConstantMaterial
 #   prop_names = 'k ki kv kiv'
 #   prop_values = '1e-2 38490 36580 7.49e10'
 #   block = '0'
 # [../]
 # [./t]
 #   type = TimeStepMaterial
 #   prop_time = time
 # [../]
 # [./t1]
 #   type = ParsedMaterial
 #   material_property_names = time
 #   function = 'kiv:=7.49e10;k:=1e-2;time*sqrt(kiv*k)'
 # [../]
[]
#-----------------------------------------------Materials-------------------------------------------------




#--------------------------------------------Postprocessors------------------------------------------------
[Postprocessors]
  [./center_ci]
    type = PointValue
    point = '0.75 0.75 0.0'
    variable = ci
  [../]
  [./center_cv]
    type = PointValue
    point = '0.75 0.75 0.0'
    variable = cv
  [../]
  [./center_xi]
    type = PointValue
    point = '0.75 0.75 0.0'
    variable = xi
  [../]
  [./center_xv]
    type = PointValue
    point = '0.75 0.75 0.0'
    variable = xv
  [../]
  [./center_cs]
    type = PointValue
    point = '0.75 0.75 0.0'
    variable = cs
  [../]
  # [./ci]  # should be equal 0.5,0.5
  #   type = ElementIntegralVariablePostprocessor
  #   variable = ci
  #   execute_on = 'initial timestep_end'
  # [../]
  # [./cv]  # should be equal 0.5,0.5
  #   type = ElementIntegralVariablePostprocessor
  #   variable = cv
  #   execute_on = 'initial timestep_end'
  # [../]
  # [./flux_ci]  # should be equal 0.5,0.5
  #   type = SideFluxIntegral
  #   variable = ci
  #   diffusivity = 'Di'
  #   boundary = '1'
  #   execute_on = 'initial timestep_end'
  # [../]
  # [./flux_cv]  # should be equal 0.5,0.5
  #   type = SideFluxIntegral
  #   variable = cv
  #   diffusivity = 'Dv'
  #   boundary = '1'
  #   execute_on = 'initial timestep_end'
  # [../]
[]
#--------------------------------------------Postprocessors------------------------------------------------


#--------------------------------------------Preconditioning------------------------------------------------
# [Preconditioning]
#   [./SMP]
#     type = SMP
#     full = true
#   [../]
# []
#--------------------------------------------Preconditioning------------------------------------------------


#----------------------------------------------Executioner-------------------------------------------------
[Executioner]
  type = Transient
  solve_type = 'NEWTON'  #try NEWTON,PJFNK
  petsc_options_iname = '-pc_type -sub_pc_type'
  petsc_options_value = 'asm ilu  '  #  either asm or hypre'
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 40 # Max number of nonlinear iterations
  nl_abs_tol = 1e-15 # Relative tolerance for nonlienar solves
  nl_rel_tol = 1e-9 # Absolute tolerance for nonlienar solves
  scheme = bdf2   #try crank-nicholson
  start_time = 0
  # num_steps = 4294967295
  # steady_state_detection = true
  end_time = 1200
  # dt = 1e-8
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-8 #s
    optimal_iterations = 5
    growth_factor = 1.2
    cutback_factor = 0.8
  [../]
  # postprocessor = cv
  # skip = 25
  # criteria = 0.01
  # below = true
[]
#----------------------------------------------Executioner-------------------------------------------------




#----------------------------------------------Outputs----------------------------------------------------
[Outputs]
  # exodus = true
  file_base = point_defects_circular_sink_1e-6
  [./exodus]
    type = Exodus
    # file_base = point_defects_circular_sink
    # show_material_properties = 'D' # set material properite to a variable so it can be output
    output_material_properties = 1
    output_postprocessors = true
    interval = 100
  [../]
  csv = true
  #xda = true
[]
#----------------------------------------------Outputs----------------------------------------------------
