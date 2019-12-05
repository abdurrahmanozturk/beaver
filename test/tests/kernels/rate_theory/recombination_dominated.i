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
    initial_condition = 0
  [../]
  [./cv]
    initial_condition = 0
  [../]
  # [./gen]
  #   initial_condition = 0
  # [../]
[]
#-------------------------------------------------Variables----------------------------------------------



#-----------------------------------------------AuxVariables---------------------------------------------
[AuxVariables]
[]
#-----------------------------------------------AuxVariables---------------------------------------------



#-------------------------------------------------Functions----------------------------------------------
[Functions]
[]
#-------------------------------------------------Functions----------------------------------------------


#--------------------------------------------------Kernels-----------------------------------------------
[Kernels]
  [./defect_i]
    type = PointDefectND
    variable = ci
    coupled = cv
    ks = 1e4
    k = 1e-7
    kiv = 1.7e4
    D = 5e-14
  [../]
  [./defect_v]
    type = PointDefectND
    variable = cv
    coupled = ci
    ks = 1e4
    k = 1e-7
    kiv = 1.7e4
    D = 1.3e-28
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
# [ICs]
#   [./conc]
#     # type = BoundingCircleIC
#     type = ConstantIC
#     variable = ci
#     value = 10
#     block = 0
#     # inside = '1'
#     # outside = 0
#     # radius = '0.28'
#     # height = 1.47
#   [../]
# []
#--------------------------------------------------ICs---------------------------------------------------


#-----------------------------------------------Materials-------------------------------------------------
[Materials]
   # [./D]
   #   type = GenericConstantMaterial # diffusion coeficient was found in
   #   prop_names = 'D_A D_B'
   #   prop_values = '0.0055 0.0065' # m/year
   #   block = '0'
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
  end_time = 100
  # dt = 0.5
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
    file_base = recombination_dominated
    # show_material_properties = 'D' # set material properite to a variable so it can be output
    # output_material_properties = 1
    output_postprocessors = true
  [../]
  # csv = true
  #xda = true
[] # Outputs
#----------------------------------------------Outputs----------------------------------------------------
