[Mesh]
  type = FileMesh
  file = coaxial_spheres.e
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
    boundary = innersphere_outer
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
    boundary = 'outersphere_inner innersphere_outer'
    method = MONTECARLO
    sampling_number = 100
    source_number = 10000
    print_screen = true
    execute_on = INITIAL
  [../]
[]
[Postprocessors]
  [./boundarytemp_2]
    type = SideAverageValue
    boundary = 'innersphere_outer'
    variable = temp
  [../]
  [./boundarytemp_3]
    type = SideAverageValue
    boundary = 'outersphere_inner'
    variable = temp
  [../]
  [./boundarytemp_5]
    type = SideAverageValue
    boundary = 'outersphere_outer'
    variable = temp
  [../]
[]

[Outputs]
  exodus = true
  file_base = coaxial_spheres_out
  console = true
[]
