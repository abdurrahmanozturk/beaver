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
    initial_condition = 0
  [../]
  # [./xv]
    # initial_condition = 0
  # [../]
[]
#-------------------------------------------------Variables----------------------------------------------



#-----------------------------------------------AuxVariables---------------------------------------------
[AuxVariables]
  [./ci]
  [../]
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
  [./xi]
    type = PointDefectND
    variable = xi  #xi
    coupled = xi   #xv=xi for recombination dominated condition
    ks = 0
    k = 1e-7
    kiv = 1.7e4
    D = 5e-14
    disable_diffusion = true
  [../]
  # [./defect_v]
  #   type = PointDefectND
  #   variable = cv
  #   coupled = ci
  #   ks = 1e4
  #   k = 1e-7
  #   kiv = 1.7e4
  #   D = 1.3e-28
  # [../]
  [./dxi_dt]
    type = TimeDerivative
    variable = xi
  [../]
  # [./dxv_dt]
  #   type = TimeDerivative
  #   variable = xv
  # [../]
  # [./diff]
  #   type = MatDiffusion
  #   variable = ci
  #   D_name = Di
  # [../]
[]
#--------------------------------------------------Kernels-----------------------------------------------



#------------------------------------------------AuxKernels----------------------------------------------
[AuxKernels]
  [./ci]
    type = ParsedAux
    variable = ci
    args = xi
    function = 'kiv:=1.7e4;k:=1e-7;xi/sqrt(kiv/k)'
  [../]
  # [./cv]
  #   type = ParsedAux
  #   variable = cv
  #   args = xv
  #   function = 'kiv:=1.7e4;k:=1e-7;xv/sqrt(kiv/k)'
  # [../]
[]
#------------------------------------------------AuxKernels----------------------------------------------



#--------------------------------------------------BCs---------------------------------------------------
[BCs]
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
#   [./xv_ic]
#     type = RandomIC
#     min = 0
#     max = 1
#     variable = xi
#     # x1 = 0.5
#     # y1 = 0.5
#     # invalue = 1
#     # outvalue = 0
#     # radius = '0.25'
#   [../]
#   [./xi_ic]
#     type = RandomIC
#     min = 0
#     max = 1
#     variable = xv
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
  # [./D]
  #   type = GenericConstantMaterial # diffusion coeficients
  #   prop_names = 'Di Dv'
  #   prop_values = '5e-14 1.3e-28' # cm2/sec
  #   block = '0'
  # [../]
  # [./k_values]
  #   type = GenericConstantMaterial
  #   prop_names = 'k ki kv kiv'
  #   prop_values = '1e-7 0 0 1.7e4'
  #   block = '0'
  # [../]
   [./tau]
     type = ParsedMaterial
     material_property_names = time
     function = 'kiv:=1.7e4;k:=1e-7;time*sqrt(kiv*k)'
   [../]
[]
#-----------------------------------------------Materials-------------------------------------------------




#--------------------------------------------Postprocessors------------------------------------------------
[Postprocessors]
  [./center_xi]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = xi
  [../]
  # [./center_xv]
  #   type = PointValue
  #   point = '0.5 0.5 0.0'
  #   variable = xv
  # [../]
  [./center_ci]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = ci
  [../]
  # [./center_cv]
  #   type = PointValue
  #   point = '0.5 0.5 0.0'
  #   variable = cv
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
  end_time = 30
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
    file_base = recombination_dominated_ND
    # show_material_properties = 'D' # set material properite to a variable so it can be output
    output_material_properties = true
    # output_postprocessors = true
  [../]
  csv = true
  #xda = true
[] # Outputs
#----------------------------------------------Outputs----------------------------------------------------
