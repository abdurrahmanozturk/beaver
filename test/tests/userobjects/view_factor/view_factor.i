#ray tracing test
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
  [./normals]
    order = FIRST
    family = LAGRANGE
  [../]
[]
# [AuxKernels]
#   [./norm]
#     type = SpatialUserObjectAux
#     user_object = ViewFactor
#     variable = normals
#     boundary = 9
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
  [./UO2ThermalConductivity]
    type = UO2ThermalConductivity
    temp = temp
  [../]
[]
[Executioner]
  type = Steady
  solve_type = PJFNK
[]
[UserObjects]
  [./ViewFactor]
    type = FindViewFactors
    #diffusivity = 1
    # nodal_normal_x = nodal_normal_x
    #nodal_normal_y = nodal_normal_y
    #nodal_normal_z = nodal_normal_z
    boundary = 2
    master_boundary = 2
    slave_boundary = 7
    #variable = temp
  [../]
[]
[Postprocessors]
  [./normal]
    type = PointValue
    point = '0 0 0'
    variable = normals
    execute_on = 'timestep_begin'
  [../]
[]

[Outputs]
  exodus = true
  file_base = view_factor
  console = true
[]
