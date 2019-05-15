[Mesh]
  type = FileMesh
  file = parallel_blocks.e
[]
[Variables]
  [./temp]
    initial_condition = 400
  [../]
[]
# [Functions]
#   [./Power]
#     type = PiecewiseLinear
#     x = '0 100.0'
#     y = '400 1000.0'
#   [../]
# []
[Kernels]
  [./HeatConduction]
    type = HeatConduction
    variable = temp
    diffusion_coefficient = thermal_conductivity
  [../]
  [./HeatConductionTimeDerivative]
    type = HeatConductionTimeDerivative
    variable = temp
  [../]
  # [./HeatSource]
  #   type = HeatSource
  #   variable = temp
  #   # value = 8.2e7
  #   function = Power   #W/m3
  #   block = 'block1'
  # [../]
[]
[BCs]
  [./temp_bc]
    type = DirichletBC
    variable = temp
    value = 1000
    boundary = 1
  [../]
  [./slave]
    type = DirichletBC
    value = 600 #K
    variable = temp
    boundary = 2
  [../]
  [./radht]
    type = RadiationHeatTransferBC
    variable = temp
    viewfactor_userobject = ViewFactor
    boundary = '2 7'
  [../]
[]
[Materials]
  # [./uo2_thermal]
  #   type = UO2
  #   temp = temp
  # [../]
  [./constant_thermal_properties]
   type = GenericConstantMaterial
   prop_names = 'thermal_conductivity density specific_heat'
   prop_values = '2.8 10431 380'
   outputs = exodus
  [../]
[]
[Executioner]
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  start_time = 0 #s
  end_time = 360 #s
  # dt = 1 #s
[]
[UserObjects]
  [./ViewFactor]
    type = ViewFactor
    boundary = '2 7 13'
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
    boundary = 'block1_x1'
    variable = temp
  [../]
  [./boundarytemp_3]
    type = SideAverageValue
    boundary = 'block1_x2'
    variable = temp
  [../]
  [./boundarytemp_5]
    type = SideAverageValue
    boundary = 'block2_x1'
    variable = temp
  [../]
  [./boundarytemp_6]
    type = SideAverageValue
    boundary = 'block2_x2'
    variable = temp
  [../]
[]

[Outputs]
  exodus = true
  file_base = parallel_blocks_rht_out
  console = true
[]
