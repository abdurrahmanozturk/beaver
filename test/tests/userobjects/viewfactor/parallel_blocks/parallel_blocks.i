[Mesh]
  type = FileMesh
  file = parallel_blocks_coarse.e
[]
[Variables]
  [./temp]
    initial_condition = 400
  [../]
[]
[Kernels]
  [./HeatConduction]
    type = HeatConduction
    variable = temp
    diffusion_coefficient = thermal_conductivity
  [../]
  # [./HeatConductionTimeDerivative]
  #   type = HeatConductionTimeDerivative
  #   variable = temp
  # [../]
[]
[BCs]
  [./master]
    type = DirichletBC
    value = 1000 #K
    variable = temp
    boundary = block1_x1
  [../]
  # [./slave]
  #   type = DirichletBC
  #   value = 600
  #   variable = temp
  #   boundary = block3_x2
  # [../]
  [./RadiationHeatTransferBC]
    type = RadiationHeatTransferBC
    boundary = 'block1_x2 block2_x1 block2_x2 block3_x1'
    viewfactor_userobject = ViewFactor
    variable = temp
  [../]
  [./RadiationHeatTransferHeatLoss]
    type = RadiationHeatTransferBC
    boundary = block3_x2
    viewfactor_userobject = ViewFactor
    variable = temp
    ambient_temperature = 320
  [../]
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
  # [../]
[]
[Executioner]
  type = Steady
  solve_type = PJFNK
[]
[UserObjects]
  [./ViewFactor]
    type = ViewFactor
    boundary = 'block1_x2 block2_x1 block2_x2 block3_x1'
    method = MONTECARLO
    sampling_number = 100
    source_number = 100
    print_screen = true
    execute_on = INITIAL
  [../]
[]
[Postprocessors]
  [./block1_x1]
    type = SideAverageValue
    boundary = 'block1_x1'
    variable = temp
  [../]
  [./block1_x2]
    type = SideAverageValue
    boundary = 'block1_x2'
    variable = temp
  [../]
  [./block2_x1]
    type = SideAverageValue
    boundary = 'block2_x1'
    variable = temp
  [../]
  [./block2_x2]
    type = SideAverageValue
    boundary = 'block2_x2'
    variable = temp
  [../]
  [./block3_x1]
    type = SideAverageValue
    boundary = 'block3_x1'
    variable = temp
  [../]
  [./block3_x2]
    type = SideAverageValue
    boundary = 'block3_x2'
    variable = temp
  [../]
[]

[Outputs]
  exodus = true
  file_base = parallel_blocks_out_1x2x2_size1
  console = true
[]
