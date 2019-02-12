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
    initial_condition = 500
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
  [./TimeDerivative]
    type = TimeDerivative
    variable = temp
  []
[]
[NodalNormals]
[]
[BCs]
  [./master]
    type = DirichletBC
    value = 1000 #K
    variable = temp
    boundary = 1
  [../]
  # [./slave]
  #   type = DirichletBC
  #   value = 900 #K
  #   variable = temp
  #   boundary = 7
  # [../]
  [./RadiationHeatTransfer]
    type = RadiationHeatTransferBC
    variable = temp
    boundary = '2 7 8 13'
    emissivity = '1 1 1 1'
    viewfactor_userobject = ViewFactor
  [../]
  # [./Convective]
  #   type = CoupledConvectiveFlux
  #   T_infinity = 300
  #   coefficient = 50
  #   variable = temp
  #   boundary = '8'
  # [../]
[]
[Materials]
  [./uo2_thermal]
    type = UO2
    temp = temp
  [../]
[]
[Executioner]
  type = Transient
  solve_type = PJFNK
  start_time = 0
  end_time = 1000
  dt = 1e-3
  dtmin = 1e-6
  nl_abs_tol = 1e-10
[]
[UserObjects]
  [./ViewFactor]
    type = ViewFactor
    boundary = '2 7 8 13'
    sampling_number = 100
    source_number = 100
    execute_on = INITIAL
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
