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
[] # Mesh
#----------------------------------------------------Mesh------------------------------------------------

#----------------------------------------------------MeshModifiers------------------------------------------------
[MeshModifiers]
[]
#----------------------------------------------------MeshModifiers------------------------------------------------



#-------------------------------------------------Variables----------------------------------------------
[Variables]
  [./xi]
    # initial_condition = 0
  [../]
  [./xv]
    # initial_condition = 0
  [../]
[]
#-------------------------------------------------Variables----------------------------------------------



#-----------------------------------------------AuxVariables---------------------------------------------
[AuxVariables]
  [./ci]
  [../]
  [./cv]
  [../]
[]
#-----------------------------------------------AuxVariables---------------------------------------------



#-------------------------------------------------Functions----------------------------------------------
[Functions]
[]
#-------------------------------------------------Functions----------------------------------------------


#--------------------------------------------------Kernels-----------------------------------------------
[Kernels]
  [./recombination_i]
    type = MatReaction
    mob_name = kiv
    # type = CoefReaction
    # coefficient = 7.49e10
    variable = ci
    v = cv
  [../]
  [./recombination_v]
    type = MatReaction
    mob_name = kiv
    # type = CoefReaction
    # coefficient = 7.49e10
    variable = cv
    v = ci
  [../]
  [./sink_i]
    type = MatReaction
    mob_name = ki
    # type = CoefReaction
    # coefficient = 1
    variable = ci
    v = cs
  [../]
  [./sink_v]
    type = MatReaction
    mob_name = kv
    # type = CoefReaction
    # coefficient = 1
    variable = cv
    v = cs
  [../]
  [./diff_i]
    type = MatDiffusion
    variable = ci
    D_name = Di
  [../]
  [./diff_v]
    type = MatDiffusion
    variable = cv
    D_name = Dv
  [../]
  # [./defect_i]
  #   type = PointDefectND
  #   variable = xi
  #   coupled = xv
  #   ks = 38490
  #   k = 1e-2
  #   kiv = 7.49e10
  #   D = 1.35e-7
  #   # disable_diffusion = true
  # [../]
  # [./defect_v]
  #   type = PointDefectND
  #   variable = xv
  #   coupled = xi
  #   ks = 36580
  #   k = 1e-2
  #   kiv = 7.49e10
  #   D = 9.4e-13
  #   # disable_diffusion = true
  # [../]
  # [./diff_ci]
  #   type = MatDiffusion
  #   variable = ci
  #   D_name = Di
  # [../]
  # [./diff_cv]
  #   type = MatDiffusion
  #   variable = cv
  #   D_name = Dv
  # [../]
  [./ci_time]
    type = TimeDerivative
    variable = xi
  [../]
  [./cv_time]
    type = TimeDerivative
    variable = xv
  [../]
[]
#--------------------------------------------------Kernels-----------------------------------------------



#------------------------------------------------AuxKernels----------------------------------------------
[AuxKernels]
  [./ci]
    type = ParsedAux
    variable = ci
    args = xi
    function = 'kiv:=7.49e10;k:=1e-2;xi/sqrt(kiv/k)'
  [../]
  [./cv]
    type = ParsedAux
    variable = cv
    args = xv
    function = 'kiv:=7.49e10;k:=1e-2;xv/sqrt(kiv/k)'
  [../]
[]
#------------------------------------------------AuxKernels----------------------------------------------



#--------------------------------------------------BCs---------------------------------------------------
[BCs]
  [./ci_bottom]
    type = DirichletBC
    variable = xi
    value = 0
    boundary = '0 2'
  [../]
  [./cv_bottom]
    type = DirichletBC
    variable = xv
    value = 0
    boundary = '0 2'
  [../]
[]
#--------------------------------------------------BCs---------------------------------------------------


#--------------------------------------------------ICs---------------------------------------------------
[ICs]
#   [./xi_ic]
#     type = RandomIC
#     min = 0
#     max = 1
#     variable = xi
#     #     # x1 = 0.5
#     #     # y1 = 0.5
#     #     # invalue = 1
#     #     # outvalue = 0
#     #     # radius = '0.25'
#   [../]
#   [./xv_ic]
#     type = RandomIC
#     min = 0
#     max = 1
#     variable = xv
# #     # x1 = 0.5
# #     # y1 = 0.5
# #     # invalue = 1
# #     # outvalue = 0
# #     # radius = '0.25'
#   [../]
[]
#--------------------------------------------------ICs---------------------------------------------------


#-----------------------------------------------Materials-------------------------------------------------
[Materials]
  [./t]
    type = TimeStepMaterial
    prop_time = time
 [../]
 [./tau]
   type = ParsedMaterial
   material_property_names = time
   function = 'kiv:=7.49e10;k:=1e-2;time*sqrt(kiv*k)'
 [../]
 # [./D]
 #   type = GenericConstantMaterial # diffusion coeficients
 #   prop_names = 'Di Dv'
 #   prop_values = '1.35e-7 9.4e-13' # cm2/sec
 #   block = '0'
 # [../]
 # [./k_values]
 #   type = GenericConstantMaterial
 #   prop_names = 'k ki kv kiv'
 #   prop_values = '1e-2 38490 36580 7.49e10'
 #   block = '0'
 # [../]
[]
#-----------------------------------------------Materials-------------------------------------------------




#--------------------------------------------Postprocessors------------------------------------------------
[Postprocessors]
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
  end_time = 30000000
  # dt = 1
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-2 #s
    growth_factor = 1.1
    cutback_factor = 0.5
  [../]
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
    file_base = rate_theory_ND
    # show_material_properties = 'D' # set material properite to a variable so it can be output
    output_material_properties = 1
    output_postprocessors = true
  [../]
  csv = true
  #xda = true
[] # Outputs
#----------------------------------------------Outputs----------------------------------------------------
