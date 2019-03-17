[Mesh]
  type = FileMesh
  file = coaxial_disks.e
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
    boundary = disk1_top
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
    boundary = 'disk2_top disk1_bottom'
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
    boundary = 'disk1_top'
    variable = temp
  [../]
  [./boundarytemp_3]
    type = SideAverageValue
    boundary = 'disk1_bottom'
    variable = temp
  [../]
  [./boundarytemp_5]
    type = SideAverageValue
    boundary = 'disk2_top'
    variable = temp
  [../]
  [./boundarytemp_6]
    type = SideAverageValue
    boundary = 'disk2_bottom'
    variable = temp
  [../]
[]

[Outputs]
  exodus = true
  file_base = coaxial_disks_out
  console = true
[]
