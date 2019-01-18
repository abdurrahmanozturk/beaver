#view_factor calculations for 2 parallel blocks
[Mesh]
  type = FileMesh
  file = parallel_blocks.e
  # type = GeneratedMesh
  # xmax = 1
  # xmin = 0
  # ymax = 1
  # ymin = 0
  # zmax = 1
  # zmin = 0
  # dim = 3
  # nx = 1
  # ny = 1
  # nz = 1
[]
[Variables]
  [./temp]
    initial_condition = 300
  [../]
[]
[AuxVariables]
  [./src_pt]
    order = FIRST
    family = LAGRANGE
  [../]
[]
# [AuxKernels]
#   [./source_point]
#     type = SpatialUserObjectAux
#     user_object = ViewFactor
#     variable = src_pt
#     boundary = 2
#     #block = 1 2
#   [../]
# []
[Kernels]
  [./HeatConduction]
    type = HeatConduction
    variable = temp
    diffusion_coefficient = thermal_conductivity
  [../]
[]
[NodalNormals]
[]
[BCs]
  [./top]
    type = DirichletBC
    value = 300 #K
    variable = temp
    boundary = 1
  [../]
  [./bottom]
    type = DirichletBC
    value = 400 #K
    variable = temp
    boundary = 2
  [../]
[]
[Materials]
  [./uo2_thermal]
    type = UO2
    temp = temp
  [../]
[]
[Executioner]
  type = Steady
  solve_type = PJFNK
[]
[UserObjects]
  [./ViewFactor]
    type = ViewFactor
    boundary = '5'
  [../]
[]
[Postprocessors]
  # [./source_point]
  #   type = PointValue
  #   point = '0 0 0'
  #   variable = src_pt
  #   execute_on = 'timestep_begin'
  # [../]
[]

[Outputs]
  exodus = true
  file_base = viewfactor
  console = true
[]
