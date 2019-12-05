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
  [./ci]
    # initial_condition = 0
  [../]
  [./cv]
    # initial_condition = 0
  [../]
  # [./gen]
  #   initial_condition = 0
  # [../]
[]
#-------------------------------------------------Variables----------------------------------------------



#-----------------------------------------------AuxVariables---------------------------------------------
[AuxVariables]
  # [./ci]
  # [../]
  # [./cv]
  # [../]
[]
#-----------------------------------------------AuxVariables---------------------------------------------



#-------------------------------------------------Functions----------------------------------------------
[Functions]
[]
#-------------------------------------------------Functions----------------------------------------------


#--------------------------------------------------Kernels-----------------------------------------------
[Kernels]
  [./defect_i]
    type = PointDefect
    variable = ci
    coupled = cv
    ks = 38490
    k = 1e-2
    kiv = 7.49e10
    D = 1.35e-7
    # disable_diffusion = true
  [../]
  [./defect_v]
    type = PointDefect
    variable = cv
    coupled = ci
    ks = 36580
    k = 1e-2
    kiv = 7.49e10
    D = 9.4e-13
    # disable_diffusion = true
  [../]
  # [./decay]
  #   type = RadioactiveDecay
  #   variable = decay
  #   half_life = 30.1
  # [../]
  # [./diff_decay]
  #   type = MatDiffusion
  #   variable = decay
  #   D_name = D_A
  # [../]
  [./ci_time]
    type = TimeDerivative
    variable = ci
  [../]
  [./cv_time]
    type = TimeDerivative
    variable = cv
  [../]
  #
  # [./gen]
  #   type = RadioactiveGeneration
  #   variable = gen
  #   coupled = decay
  #   half_life = 30.1
  # [../]
  # [./gen_time]
  #   type = TimeDerivative
  #   variable = gen
  # [../]
  # [./diff_gen]
  #   type = MatDiffusion
  #   variable = gen
  #   D_name = D_B
  # [../]
[]
#--------------------------------------------------Kernels-----------------------------------------------



#------------------------------------------------AuxKernels----------------------------------------------
[AuxKernels]
  # [./ci]
  #   type = ParsedAux
  #   variable = ci
  #   args = xi
  #   function = 'kiv:=7.49e10;k:=1e-2;xi/sqrt(kiv/k)'
  # [../]
  # [./cv]
  #   type = ParsedAux
  #   variable = cv
  #   args = xv
  #   function = 'kiv:=7.49e10;k:=1e-2;xv/sqrt(kiv/k)'
  # [../]
[]
#------------------------------------------------AuxKernels----------------------------------------------



#--------------------------------------------------BCs---------------------------------------------------
[BCs]
 # [./outside_conc_dec]
 #   type = DirichletBC
 #   variable = conc
 #   value = 0
 #   boundary = '1'
 # [../]
 # [./outside_conc_gen]
 #   type = DirichletBC
 #   variable = gen
 #   value = 0
 #   boundary = '1'
 # [../]
[]
#--------------------------------------------------BCs---------------------------------------------------


#--------------------------------------------------ICs---------------------------------------------------
[ICs]
  [./cv]
    type = RandomIC
    min = 0
    max = 1
    variable = ci
    # x1 = 0.5
    # y1 = 0.5
    # invalue = 1
    # outvalue = 0
    # radius = '0.25'
  [../]
  [./ci]
    type = RandomIC
    min = 0
    max = 1
    variable = cv
    # x1 = 0.5
    # y1 = 0.5
    # invalue = 1
    # outvalue = 0
    # radius = '0.25'
  [../]
[]
#--------------------------------------------------ICs---------------------------------------------------


#-----------------------------------------------Materials-------------------------------------------------
[Materials]
  [./t]
    type = TimeStepMaterial
    prop_time = time
   # [./D]
   #   type = GenericConstantMaterial # diffusion coeficient was found in
   #   prop_names = 'D_A D_B'
   #   prop_values = '0.0055 0.0065' # m/year
   #   block = '0'
   # [../]
 [../]
 [./t1]
   type = ParsedMaterial
   material_property_names = time
   function = 'kiv:=7.49e10;k:=1e-2;time*sqrt(kiv*k)'
 [../]
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
  # [./decay]  # should be equal 0.5,0.5
  #   type = ElementIntegralVariablePostprocessor
  #   variable = decay
  #   execute_on = 'initial timestep_end'
  # [../]
  # [./gen]  # should be equal 0.5,0.5
  #   type = ElementIntegralVariablePostprocessor
  #   variable = gen
  #   execute_on = 'initial timestep_end'
  # [../]
  # [./flux_decay]  # should be equal 0.5,0.5
  #   type = SideFluxIntegral
  #   variable = decay
  #   diffusivity = 'D_A'
  #   boundary = '1'
  #   execute_on = 'initial timestep_end'
  # [../]
  # [./flux_gen]  # should be equal 0.5,0.5
  #   type = SideFluxIntegral
  #   variable = gen
  #   diffusivity = 'D_B'
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
  # postprocessor = gen
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
    file_base = rate_theory_randomIC
    # show_material_properties = 'D' # set material properite to a variable so it can be output
    output_material_properties = 1
    output_postprocessors = true
  [../]
  csv = true
  #xda = true
[] # Outputs
#----------------------------------------------Outputs----------------------------------------------------
