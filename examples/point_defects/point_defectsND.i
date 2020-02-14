#----------------------------------------------------Mesh------------------------------------------------
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
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
  [./cs]
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
    type = BodyForce
    variable = xi
    value = 1   #dpa/s   regular case
  [../]
  [./defect_generation_v]
    type = BodyForce
    variable = xv
    value = 1   #dpa/s   regular case
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
    variable = ci
    D_name = Di
  [../]
  [./cv_diff]
    type = MatDiffusion
    variable = cv
    D_name = Dv
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
#--------------------------------------------------Kernels-----------------------------------------------



#------------------------------------------------AuxKernels----------------------------------------------
[AuxKernels]
  [./ci]
    type = ParsedAux
    variable = ci
    args = xi
    function = 'k:=1e-2;xi*k'
  [../]
  [./cv]
    type = ParsedAux
    variable = cv
    args = xv
    function = 'k:=1e-2;xv*k'
  [../]
  [./cs]
    type = ParsedAux
    variable = cs
    args = xs
    function = 'ki:=36580;xs/ki'
  [../]
[]
#------------------------------------------------AuxKernels----------------------------------------------



#--------------------------------------------------BCs---------------------------------------------------
[BCs]
 # [./ci_bottom]
 #   type = DirichletBC
 #   variable = xi
 #   value = 0
 #   boundary = '0 1 2 3'
 # [../]
 # [./cv_bottom]
 #   type = DirichletBC
 #   variable = xv
 #   value = 0
 #   boundary = '0 1 2 3'
 # [../]
[]
#--------------------------------------------------BCs---------------------------------------------------


#--------------------------------------------------ICs---------------------------------------------------
# [ICs]
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
# []
#--------------------------------------------------ICs---------------------------------------------------


#-----------------------------------------------Materials-------------------------------------------------
[Materials]
 [./D]
   type = GenericConstantMaterial # diffusion coeficients
   prop_names = 'Di Dv'
   # prop_values = '5e-14 1.3e-28'   # cm2/sec      recombination dominated case
   prop_values = '1.35e-7 9.4e-13' # cm2/sec      regular case
   block = '0'
 [../]
 [./Kiv]
   type = DerivativeParsedMaterial
   f_name = Kiv
   args = xv
   # function = 'kiv:=1.7e4;kiv*cv'    # 1/s recombination dominated
   function = 'kiv:=7.49e10;k:=1e-2;k*kiv*xv'  # 1/s regular case
 [../]
 [./Kvi]
   type = DerivativeParsedMaterial
   f_name = Kvi
   args = xi
   # function = 'kiv:=1.7e4;kiv*ci'    # 1/s recombination dominated
   function = 'kiv:=7.49e10;k:=1e-2;k*kiv*xi'  # 1/s regular case
 [../]
 [./Kis]
   type = DerivativeParsedMaterial
   f_name = Kis
   args = xs
   # function = 'Di:=5e-14;ki:=38490;Di*ki*ki*cs' # 1/s      recombination dominated case
   function = 'xs' # 1/s      regular case
 [../]
 [./Kvs]
   type = DerivativeParsedMaterial
   f_name = Kvs
   args = xs
   # function = 'Dv:=1.3e-28;kv:=36580;Dv*Dv*kv*cs' # 1/s      recombination dominated case
   function = 'ki:=38490;kv:=36580;xs*kv/ki' # 1/s      regular case
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
    point = '0.5 0.5 0.0'
    variable = ci
  [../]
  [./center_cv]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = cv
  [../]
  [./center_cs]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = cs
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
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 40 # Max number of nonlinear iterations
  nl_abs_tol = 1e-10 # Relative tolerance for nonlienar solves
  nl_rel_tol = 1e-11 # Absolute tolerance for nonlienar solves
  start_time = 0
  end_time = 1200
  # dt = 1e-8
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-8 #s
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
  [./exodus]
    type = Exodus
    file_base = point_defectsND
    # show_material_properties = 'D' # set material properite to a variable so it can be output
    output_material_properties = 1
    output_postprocessors = true
  [../]
  csv = true
  #xda = true
[]
#----------------------------------------------Outputs----------------------------------------------------
