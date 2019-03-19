[Mesh]
  type = FileMesh
  file = experiment.e
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
  [./TimeDerivative]
    type = TimeDerivative
    variable = temp
  []
  [./HeatSource]
    type = HeatSource
    variable = temp
    value = 597.133e6
    function = 0.125
    block = 'pellet'
  [../]
[]
[BCs]
  [./wall_BC]
    type = DirichletBC
    value = 400 #K
    variable = temp
    boundary = 20
  [../]
  # [./convection_BC]
  #   type = ConvectiveFluxBC
  #   variable = temp
  #   boundary = 8
  # [../]
  [./RadiationHeatTransfer]
    type = RadiativeHeatFluxBC
    variable = temp
    boundary = '1 2 3 4 6 10 12 15 17 20 22'
    emissivity = '1 1 1 1 1 1 1 1 1 1 1'
    viewfactor_userobject = ViewFactor
  [../]
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
  [./constant_thermal_properties]
   type = GenericConstantMaterial
   prop_names = 'thermal_conductivity density specific_heat'
   prop_values = '2.8 10431 380'
   outputs = exodus
  [../]
  # [./uo2_thermal]
  #   type = UO2
  #   temp = temp
  #   outputs = exodus
  # [../]
[]
[Executioner]
  type = Transient
  solve_type = PJFNK
  start_time = 0
  end_time = 100
  dt = 1e-3
  # dtmin = 1e-6
  nl_abs_tol = 1e-15
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
    boundary = '1 2 3 4 5 6 10 12 15 17 20 22'
    method = MONTECARLO
    sampling_number = 10
    source_number = 10
    print_screen = true
    debug_mode = false
    execute_on = INITIAL
  [../]
[]
[Postprocessors]
  [./pellet_top]
    type = SideAverageValue
    boundary = '1'
    variable = temp
  [../]
  [./bn1_top]
    type = SideAverageValue
    boundary = '2'
    variable = temp
  [../]
  [./susceptor_top]
    type = SideAverageValue
    boundary = '3'
    variable = temp
  [../]
  [./bn2_top]
    type = SideAverageValue
    boundary = '4'
    variable = temp
  [../]
  [./wall_inner]
    type = SideAverageValue
    boundary = '5'
    variable = temp
  [../]
  [./wall_outer]
    type = SideAverageValue
    boundary = '26'
    variable = temp
  [../]
[]

[Outputs]
  exodus = true
  file_base = experiment_out
  console = true
[]
