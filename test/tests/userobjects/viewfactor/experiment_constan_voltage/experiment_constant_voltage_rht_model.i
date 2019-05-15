[Mesh]
  type = FileMesh
  file = experiment_fine.e
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
    initial_condition = 700
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
# [Functions]
#   [./Power]
#     type = PiecewiseLinear
#     data_file = 'joule_power.csv' # Time in seconds
#     y_index_in_file = 3
#     xy_in_file_only = false
#     format = columns
#   [../]
# []
[Kernels]
  [./HeatConduction]
    type = HeatConduction
    variable = temp
    diffusion_coefficient = thermal_conductivity
  [../]
  [./TimeDerivative]
    type = HeatConductionTimeDerivative
    variable = temp
  []
  [./HeatSource]
    type = HeatSource
    variable = temp
    value = 8.2e7    #W/m3
    function = 0.5   #half geometry
    # function = Power   #W/m3
    block = 'pellet'
  [../]
[]

[BCs]
  [./wall_BC]
    type = DirichletBC
    value = 320 #K
    variable = temp
    boundary = 25
  [../]
  # [./bn2_outer]
  #   type = DirichletBC
  #   value = 500 #K
  #   variable = temp
  #   boundary = 19
  # [../]
  # [./convection_BC]
  #   type = ConvectiveFluxBC
  #   variable = temp
  #   boundary = 8
  # [../]
  [./RadiationHeatTransfer]
    type = RadiationHeatTransferBC
    variable = temp
    boundary = '6 11 14 21'
    viewfactor_userobject = ViewFactor
  [../]
  [./RadiationHeatTransfer2]
    type = RadiationHeatTransferBC
    variable = temp
    boundary = '9 16'
    viewfactor_userobject = ViewFactor2
  [../]
  [./RadiationHeatTransfer3]
    type = RadiationHeatTransferBC
    variable = temp
    boundary = '1 2 26'
    viewfactor_userobject = ViewFactor3
  [../]
  [./RadiationHeatTransfer4]
    type = RadiationHeatTransferBC
    variable = temp
    boundary = '3 4 26'
    viewfactor_userobject = ViewFactor4
  [../]
  [./RadiationHeatTransfer5]
    type = RadiationHeatTransferBC
    variable = temp
    boundary = '19 26'
    viewfactor_userobject = ViewFactor5
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
  # [./constant_thermal_properties_UO2]
  #  type = GenericConstantMaterial
  #  prop_names = 'thermal_conductivity density specific_heat'
  #  prop_values = '2.8 10431 380'
  #  outputs = exodus
  #  block = pellet
  # [../]
  [./constant_thermal_properties_BN]
   type = GenericConstantMaterial
   prop_names = 'thermal_conductivity density specific_heat'
   prop_values = '80 1900 810'
   outputs = exodus
   block = 'bn1 bn2'
  [../]
  [./constant_thermal_properties_Mo]
   type = GenericConstantMaterial
   prop_names = 'thermal_conductivity density specific_heat'
   prop_values = '138 10220 250'
   outputs = exodus
   block = 'susceptor wall'
  [../]
  [./uo2_thermal]
    type = UO2
    temp = temp
    block = pellet
    outputs = exodus
  [../]
[]
[Executioner]
  type = Transient
  solve_type = PJFNK
  start_time = 0
  end_time = 300
  # dt = 1e-3
  # [./TimeStepper]
  #   type = IterationAdaptiveDT
  #   dt = 1e-3 #s
  #   growth_factor = 1.5
  #   cutback_factor = 0.5
  # [../]
  # dtmin = 1e-6
  # nl_abs_tol = 1e-5
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
    boundary = '6 11 14 21'
    method = MONTECARLO
    sampling_number = 10
    source_number = 10
    print_screen = true
    debug_mode = false
    execute_on = INITIAL
  [../]
  [./ViewFactor2]
    type = ViewFactor
    boundary = '9 16'
    method = MONTECARLO
    sampling_number = 10
    source_number = 10
    print_screen = true
    debug_mode = false
    execute_on = INITIAL
  [../]
  [./ViewFactor3]
    type = ViewFactor
    boundary = '1 2 26'
    method = MONTECARLO
    sampling_number = 10
    source_number = 10
    print_screen = true
    debug_mode = false
    execute_on = INITIAL
  [../]
  [./ViewFactor4]
    type = ViewFactor
    boundary = '3 4 26'
    method = MONTECARLO
    sampling_number = 10
    source_number = 10
    print_screen = true
    debug_mode = false
    execute_on = INITIAL
  [../]
  [./ViewFactor5]
    type = ViewFactor
    boundary = '19 26'
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
  # [./bn1_top]
  #   type = SideAverageValue
  #   boundary = '2'
  #   variable = temp
  # [../]
  # [./susceptor_top]
  #   type = SideAverageValue
  #   boundary = '3'
  #   variable = temp
  # [../]
  # [./bn2_top]
  #   type = SideAverageValue
  #   boundary = '4'
  #   variable = temp
  # [../]
  [./wall_inner]
    type = SideAverageValue
    boundary = '26'
    variable = temp
  [../]
  [./wall_outer]
    type = SideAverageValue
    boundary = '25'
    variable = temp
  [../]
  [./centerline_temp]
    type = PointValue
    point = '0 0 0'
    variable = temp
  [../]
[]
[Outputs]
  exodus = true
  file_base = experiment_fine_rht_model_700K_constvolt_out
  console = true
[]
