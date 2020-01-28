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
    # initial_condition = 1
  [../]
  [./cv]
    # initial_condition = 1
  [../]
[]
#-------------------------------------------------Variables----------------------------------------------



#-----------------------------------------------AuxVariables---------------------------------------------
[AuxVariables]
  [./xi]
  [../]
  [./xv]
  [../]
[]
#-----------------------------------------------AuxVariables---------------------------------------------



#-------------------------------------------------Functions----------------------------------------------
[Functions]
[]
#-------------------------------------------------Functions----------------------------------------------


#--------------------------------------------------Kernels-----------------------------------------------
[Kernels]
  [./ci]
    type = PointDefect
    variable = ci
    coupled = cv
    ks = 38729.8
    k = 1e-7
    kiv = 4e16
    D = 7e-2
    # disable_diffusion = true
  [../]
  [./cv]
    type = PointDefect
    variable = cv
    coupled = ci
    ks = 38729.8
    k = 1e-7
    kiv = 4e16
    D = 5e-6
    # disable_diffusion = true
  [../]
  # [./ci_diff]
  #   type = MatDiffusion
  #   variable = ci
  #   D_name = Di
  # [../]
  # [./cv_diff]
  #   type = MatDiffusion
  #   variable = cv
  #   D_name = Dv
  # [../]
  [./dci_dt]
    type = TimeDerivative
    variable = ci
  [../]
  [./dcv_dt]
    type = TimeDerivative
    variable = cv
  [../]
[]
#--------------------------------------------------Kernels-----------------------------------------------



#------------------------------------------------AuxKernels----------------------------------------------
[AuxKernels]
  [./xi]
    type = ParsedAux
    variable = xi
    args = ci
    function = 'kiv:=4e16;k:=1e-7;ci*sqrt(kiv/k)'
  [../]
  [./cv]
    type = ParsedAux
    variable = xv
    args = cv
    function = 'kiv:=4e16;k:=1e-7;cv*sqrt(kiv/k)'
  [../]
[]
#------------------------------------------------AuxKernels----------------------------------------------



#--------------------------------------------------BCs---------------------------------------------------
[BCs]
 [./ci_bc]
   type = DirichletBC
   variable = ci
   value = 0
   boundary = '0 2'
 [../]
 [./cv_bc]
   type = DirichletBC
   variable = cv
   value = 0
   boundary = '0 2'
 [../]
[]
#--------------------------------------------------BCs---------------------------------------------------


#--------------------------------------------------ICs---------------------------------------------------
[ICs]
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
[./cv_ic]
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
[./ci_ic]
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
   [./D]
     type = GenericConstantMaterial # diffusion coeficient was found in
     prop_names = 'Di Dv'
     prop_values = '7e-2 5e-6' # cm2/s
     block = '0'
   [../]
   # [./k_values]
   #   type = GenericConstantMaterial
   #   prop_names = 'k ki kv kiv'
   #   prop_values = '1e-7 38729.8 38729.8 4e16'
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
  end_time = 300
  dt = 0.1
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
    file_base = sink_dominated_ND
    # show_material_properties = 'D' # set material properite to a variable so it can be output
    # output_material_properties = 1
    output_postprocessors = true
  [../]
  csv = true
  #xda = true
[] # Outputs
#----------------------------------------------Outputs----------------------------------------------------
