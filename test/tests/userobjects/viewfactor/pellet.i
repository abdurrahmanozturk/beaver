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
  [./TimeDerivativeConduction]
    type = HeatConductionTimeDerivative
    variable = temp
  [../]
  [./HeatSource]
    type = HeatSource
    variable = temp
    value = 809.97e6
    block = 'pellet'
  [../]
[]
[BCs]
  [./master]
    type = DirichletBC
    value = 420 #K
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
  # start_time = 0
  # end_time = 100
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
    boundary = '1'
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
