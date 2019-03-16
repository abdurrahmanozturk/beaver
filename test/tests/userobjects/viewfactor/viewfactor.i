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
    initial_condition = 400
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
  # [./TimeDerivative]
  #   type = TimeDerivative
  #   variable = temp
  # []
  # [./HeatSource]
  #   type = HeatSource
  #   variable = temp
  #   value = 360
  #   block = 'disk2'
  # [../]
[]
[BCs]
  [./master]
    type = DirichletBC
    value = 400 #K
    variable = temp
    boundary = 5
  [../]
  # [./slave]
  #   type = DirichletBC
  #   value = 900 #K
  #   variable = temp
  #   boundary = 7
  # [../]
  # [./RadiationHeatTransfer]
  #   type = RadiationHeatTransferBC
  #   variable = temp
  #   boundary = '2 6'
  #   emissivity = '1 1'
  #   viewfactor_userobject = ViewFactor
  # [../]
  # [./RadiativeBC]
  #   type = RadiativeBC
  #   variable = temp
  #   viewfactor_method = MONTECARLO
  #   boundary = '2 7'
  #   emissivity = '1 1'
  #   sampling_number = 10
  #   source_number = 10
  # [../]
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
  # start_time = 0
  # end_time = 100
  # dt = 1e-3
  # dtmin = 1e-6
  # nl_abs_tol = 1e-15
[]
[UserObjects]
  # [./ViewFactor]
  #   type = ViewFactorMonteCarlo
  #   boundary = '2 7 8 13'
  #   sampling_number = 100
  #   source_number = 100
  #   execute_on = INITIAL
  # [../]
  [./ViewFactor]
    type = ViewFactor
    boundary = '5 2'
    method = MONTECARLO
    sampling_number = 10
    source_number = 10
    print_screen = true
    execute_on = INITIAL
  [../]
[]
[Postprocessors]
  [./boundarytemp_2]
    type = SideAverageValue
    boundary = '2'
    variable = temp
  [../]
  [./boundarytemp_3]
    type = SideAverageValue
    boundary = '3'
    variable = temp
  [../]
  [./boundarytemp_5]
    type = SideAverageValue
    boundary = '5'
    variable = temp
  [../]
  [./boundarytemp_6]
    type = SideAverageValue
    boundary = '6'
    variable = temp
  [../]
[]

[Outputs]
  exodus = true
  file_base = viewfactor
  console = true
[]
