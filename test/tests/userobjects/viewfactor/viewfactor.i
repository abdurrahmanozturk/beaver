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
  # elem_type = HEX8
[]
[Variables]
  [./temp]
    initial_condition = 300
  [../]
[]
# [AuxVariables]
#   [./src_pt]
#     order = FIRST
#     family = LAGRANGE
#   [../]
# []
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
  [./RadiationHeatTransfer]
    type = RadiationHeatTransferBC
    variable = temp
    boundary = '2 7'
    viewfactor_userobject = ViewFactor
  [../]
  [./top]
    type = DirichletBC
    value = 300 #K
    variable = temp
    boundary = 7
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
    master_boundary = '2'
    slave_boundary = '7'
    sampling_number = 100
    source_number = 100
    print_screen = false
    error_tolerance = 1e-9
    parallel_planes = '10.0 10.0 9.0'
    execute_on = 'timestep_begin'
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
