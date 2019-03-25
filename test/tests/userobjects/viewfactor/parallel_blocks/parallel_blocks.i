[Mesh]
  type = FileMesh
  file = parallel_blocks.e
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
[]
[BCs]
  [./master]
    type = DirichletBC
    value = 400 #K
    variable = temp
    boundary = block1_x1
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
    boundary = 'block1_x2 block2_x1'
    method = MONTECARLO
    sampling_number = 100
    source_number = 100
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
  file_base = parallel_blocks_out_1x2x2_size1
  console = true
[]
