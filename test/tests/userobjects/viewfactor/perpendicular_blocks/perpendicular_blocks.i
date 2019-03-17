[Mesh]
  type = FileMesh
  file = perpendicular_blocks.e
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
    sampling_number = 10000
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
  file_base = perpendicular_blocks_out
  console = true
[]
