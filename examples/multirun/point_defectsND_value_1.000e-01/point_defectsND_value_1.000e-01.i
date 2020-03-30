#----------------------------------------------------Mesh------------------------------------------------
[Mesh]
  type = GeneratedMesh  # use file mesh by external mesh generator vacancy fracion is one for cirlce bc
  dim = 2
  nx = 100
  ny = 100
  xmin = -0.5
  xmax = 0.5
  ymin = -0.5
  ymax = 0.5
[]
#----------------------------------------------------Mesh------------------------------------------------


#----------------------------------------------------MeshModifiers------------------------------------------------
[MeshModifiers]
[]
#----------------------------------------------------MeshModifiers------------------------------------------------


#-------------------------------------------------Variables----------------------------------------------
[Variables]
  [./xi]
    initial_condition = 0
  [../]
  [./xv]
    initial_condition = 0
  [../]
[]
#-------------------------------------------------Variables----------------------------------------------


#-----------------------------------------------AuxVariables---------------------------------------------
[AuxVariables]
  [./ci]
  [../]
  [./cv]
  [../]
  [./xs]
    initial_condition = 1
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
    variable = xi
    value = 1.000e-01
  [../]
  [./defect_generation_v]
    type = BodyForce
    variable = xv
    value = 1.000e-01
  [../]
  [./recombination_i]
    type = MatReaction
    variable = xi
    args = xv     #coupled on materials block
    mob_name = Kiv
  [../]
  [./recombination_v]
    type = MatReaction
    variable = xv
    args = xi    #coupled in materials block
    mob_name = Kvi
  [../]
  [./sink_reaction_i]
    type = MatReaction
    variable = xi
    mob_name = Kis
    args = xs     #coupled on materials block
  [../]
  [./sink_reaction_v]
    type = MatReaction
    variable = xv
    mob_name = Kvs
    args = xs    #coupled in materials block
  [../]
  [./ci_diff]
    type = MatDiffusion
    variable = xi
    D_name = Di
  [../]
  [./cv_diff]
    type = MatDiffusion
    variable = xv
    D_name = Dv
  [../]
  [./ci_time]
    type = TimeDerivative
    variable = xi
  [../]
  [./cv_time]
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
#--------------------------------------------------Kernels-----------------------------------------------



#------------------------------------------------AuxKernels----------------------------------------------
[AuxKernels]
  # [./xi]
  #   type = ParsedAux
  #   variable = xi
  #   args = ci
  #   function = 'kiv:=7.49e10;k:=1e-2;ci*sqrt(kiv/k)'
  # [../]
  # [./xv]
  #   type = ParsedAux
  #   variable = xv
  #   args = cv
  #   function = 'kiv:=7.49e10;k:=1e-2;cv*sqrt(kiv/k)'
  # [../]
  # [./cs]
  #   type = ParsedAux
  #   variable = cs
  #   function = 'R:=0.707;if(x*x+y*y<=R*R,1,0)'
  # [../]
[]
#------------------------------------------------AuxKernels----------------------------------------------



#--------------------------------------------------BCs---------------------------------------------------
[BCs]
 # [./ci_bottom]
 #   type = DirichletBC
 #   variable = ci
 #   value = 0
 #   boundary = '0 1 2 3'
 # [../]
 # [./cv_bottom]
 #   type = DirichletBC
 #   variable = cv
 #   value = 0
 #   boundary = '0 1 2 3'
 # [../]
[]
#--------------------------------------------------BCs---------------------------------------------------


#--------------------------------------------------ICs---------------------------------------------------
[ICs]
  # [./cs_ic]
  #   type = FunctionIC
  #   variable = cs
  #   # function = 'R:=0.25;if(pow(x,2)+pow(y,2)<=R*R,1,0)'
  #   function = 'if(((x=0.5)|(x=-0.5)|(y=0.5)|(y=-0.5)),1,0)'
  # [../]
  # [./cv]
  #   type = RandomIC
  #   min = 0
  #   max = 1
  #   variable = cv
  #   # x1 = 0.5
  #   # y1 = 0.5
  #   # invalue = 1
  #   # outvalue = 0
  #   # radius = '0.25'
  # [../]
  # [./ci]
  #   type = RandomIC
  #   min = 0
  #   max = 1
  #   variable = ci
  #   # x1 = 0.5
  #   # y1 = 0.5
  #   # invalue = 1
  #   # outvalue = 0
  #   # radius = '0.25'
  # [../]
  # [./cs]
  #   type = RandomIC
  #   min = 0
  #   max = 1
  #   variable = cs
  #   # x1 = 0.5
  #   # y1 = 0.5
  #   # invalue = 1
  #   # outvalue = 0
  #   # radius = '0.25'
  # [../]
[]
#--------------------------------------------------ICs---------------------------------------------------


#-----------------------------------------------Materials-------------------------------------------------
[Materials]
 [./D]
   type = GenericConstantMaterial # diffusion coeficients
   prop_names = 'Di Dv'
   prop_values = '1e-1 1e-2' # cm2/sec      regular case
   block = '0'
 [../]
 [./Kiv]
   type = DerivativeParsedMaterial
   f_name = Kiv
   args = xv
   function = 'kiv:=1;-kiv*xv'  # 1/s regular case, parametric study
 [../]
 [./Kvi]
   type = DerivativeParsedMaterial
   f_name = Kvi
   args = xi
   function = 'kiv:=1;-kiv*xi'  # 1/s regular case, parametric study
 [../]
 [./Kis]
   type = DerivativeParsedMaterial
   f_name = Kis
   args = xs
   function = 'kis:=1;-kis*xs' # 1/s      regular case
 [../]
 [./Kvs]
   type = DerivativeParsedMaterial
   f_name = Kvs
   args = xs
   function = 'kvs:=1;-kvs*xs' # 1/s      regular case
 [../]
 # [./k_value]
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
  # [./center_ci]
  #   type = PointValue
  #   point = '0.5 0.5 0.0'
  #   variable = ci
  # [../]
  # [./center_cv]
  #   type = PointValue
  #   point = '0.5 0.5 0.0'
  #   variable = cv
  # [../]
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
  end_time = 100
  dt = 1
  # [./TimeStepper]
  #   type = IterationAdaptiveDT
  #   dt = 1 #s
  #   # optimal_iterations = 6
  #   growth_factor = 1.2
  #   cutback_factor = 0.8
  # [../]
  # postprocessor = cv
  # skip = 25
  # criteria = 0.01
  # below = true
[]
#----------------------------------------------Executioner-------------------------------------------------




#----------------------------------------------Outputs----------------------------------------------------
[Outputs]
  # exodus = true
  file_base = point_defectsND_value_1.000e-01/point_defectsND_value_1.000e-01
  [./exodus]
    type = Exodus
    # show_material_properties = 'D' # set material properite to a variable so it can be output
    output_material_properties = 1
    output_postprocessors = true
    interval = 10000
  [../]
  csv = true
  #xda = true
[]
#----------------------------------------------Outputs----------------------------------------------------
