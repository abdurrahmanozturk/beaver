[Mesh]
  type = FileMesh
  file = coaxial_cylinders.e
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
  # [./HeatSource]
  #   type = HeatSource
  #   value = 1000
  #   variable = temp
  #   block = innercylinder
  # [../]
[]
[BCs]
  # [./master]
  #   type = DirichletBC
  #   value = 1000 #K
  #   variable = temp
  #   boundary = outercylinder_outer
  # [../]
  # [./RadiationHeatTransfer]
  #   type = RadiationHeatTransferBC
  #   variable = temp
  #   boundary = 'innercylinder_outer outercylinder_inner'
  #   emissivity = '1 1'
  #   viewfactor_userobject = ViewFactor
  # [../]
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
    boundary = 'innercylinder_outer outercylinder_inner'
    method = MONTECARLO
    sampling_number = 100
    source_number = 100
    print_screen = true
    execute_on = INITIAL
  [../]
[]
[Postprocessors]
  [./innercylinder_outer]
    type = SideAverageValue
    boundary = 'innercylinder_outer'
    variable = temp
  [../]
  [./outercylinder_inner]
    type = SideAverageValue
    boundary = 'outercylinder_inner'
    variable = temp
  [../]
  [./outercylinder_outer]
    type = SideAverageValue
    boundary = 'outercylinder_outer'
    variable = temp
  [../]
[]

[Outputs]
  exodus = true
  file_base = coaxial_cylinders_out
  console = true
[]
