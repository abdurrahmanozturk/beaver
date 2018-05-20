[Mesh]
  type = GeneratedMesh
  xmax = 1
  ymax = 1
  dim = 2
  nx = 10
  ny = 10
[]

[Variables]
[./temp]
  family = LAGRANGE
  order = FIRST
[../]
[]

[Kernels]
  [./HeatConduction]
    type = HeatConduction
    variable = temp
  [../]
[]

[BCs]
  [./top]
    type = DirichletBC
    boundary = top
    value = 100
    variable = temp
  [../]
  [./bottom]
    type = DirichletBC
    boundary = bottom
    value = 0
    variable = temp
  [../]
[]

[Materials]
[]

[Executioner]
  type = Steady
  solve_type = PJFNK
[]
[Outputs]
  console = true
  exodus = true
  file_base = 'view_factor'
[]
