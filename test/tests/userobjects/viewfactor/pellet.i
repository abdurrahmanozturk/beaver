# [GlobalParams]
#   length_scale = 1
#   time_scale = 1
# []
[Mesh]
  type = FileMesh
  file = pellet.e
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
# [MeshModifiers]
#   [./centerBC]
#     type = AddExtraNodeset
#     new_boundary = 'center'
#     coord = '0 0'
#   [../]
# []
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
[Functions]
  [./Power]
    type = PiecewiseLinear
    data_file = 'joule_power.csv' # Time in seconds
    y_index_in_file = 2
    xy_in_file_only = false
    format = columns
  [../]
[]
[Kernels]
  [./HeatConduction]
    type = HeatConduction
    variable = temp
    diffusion_coefficient = thermal_conductivity
  [../]
  [./TimeDerivativeConduction]
    type = HeatConductionTimeDerivative
    variable = temp
  [../]
  [./HeatSource]
    type = HeatSource
    variable = temp
    # value = 8.2e7
    function = Power   #W/m3
    block = 'pellet'
  [../]
[]
[BCs]
  [./master]
    type = DirichletBC
    value = 850 #K
    variable = temp
    boundary = pellet_outer
  [../]
  # [./slave]
  #   type = DirichletBC
  #   value = 600 #K
  #   variable = temp
  #   boundary = 1
  # [../]
  # [./RadiationHeatTransfer]
  #   type = RadiationHeatTransferBC
  #   variable = temp
  #   boundary = '2 3'
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
  end_time = 300
  # dt = 1e-3
  # dtmin = 1e-6
  nl_abs_tol = 1e-10
[]
[UserObjects]
  # [./ViewFactor]
  #   type = ViewFactorMonteCarlo
  #   boundary = '2 7 8 13'
  #   sampling_number = 100
  #   source_number = 100
  #   execute_on = INITIAL
  # [../]
  # [./ViewFactor]
  #   type = ViewFactor
  #   boundary = '2 3'
  #   method = MONTECARLO
  #   sampling_number = 10
  #   source_number = 10
  #   print_screen = true
  #   execute_on = INITIAL
  # [../]
[]
[Postprocessors]
  [./thermal_conductivity_W_m-K]
    type = ElementIntegralMaterialProperty
    outputs = console
    block = pellet
    mat_prop = thermal_conductivity
    # execute_on = 'initial timestep_end'
  [../]
  [./surface_temp]
    type = SideAverageValue
    boundary = pellet_outer
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
  file_base = pellet_out
  console = true
[]
