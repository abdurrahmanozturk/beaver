[Mesh]
  type = FileMesh
  file = benchmark.e
[]
[Variables]
  [./temp]
    # initial_condition = 873
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
  [./inner]
    type = DirichletBC
    value = 1673.15 #K
    variable = temp
    boundary = innercylinder_outer
  [../]
  [./outer]
    type = DirichletBC
    value = 873.15 #K
    variable = temp
    boundary = outercylinder_outer
  [../]
  [./RadiationHeatTransfer]
    type = RadiationHeatTransferBC
    variable = temp
    boundary = 'innercylinder_outer outercylinder_inner'
    viewfactor_userobject = ViewFactor
  [../]
[]
[Materials]
  [./constant_thermal_properties]
   type = GenericConstantMaterial
   prop_names = 'thermal_conductivity density specific_heat'
   prop_values = '4.190 5000 680'
   outputs = exodus
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
    sampling_number = 10
    source_number = 10
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
