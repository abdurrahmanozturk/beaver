[Mesh]
  type = FileMesh
  file = duct.e
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
  # [./TimeDerivativeConduction]
  #   type = HeatConductionTimeDerivative
  #   variable = temp
  # [../]
  # [./HeatSource]
  #   type = HeatSource
  #   variable = temp
  #   value = 597.133e6
  #   block = 'pellet'
  # [../]
[]
[BCs]
  [./master]
    type = DirichletBC
    value = 1000 #K
    variable = temp
    boundary = 'top bottom'
  [../]
  [./slave]
    type = DirichletBC
    value = 600 #K
    variable = temp
    boundary = 'left right'
  [../]
  [./RadiationHeatTransfer]
    type = RadiationHeatTransferBC
    variable = temp
    boundary = 'bottom right'
    emissivity = '1 1'
    viewfactor_userobject = ViewFactor
  [../]
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
  type = Steady
  solve_type = PJFNK
  # start_time = 0
  # end_time = 100
  # dt = 1e-3
  # dtmin = 1e-6
  # nl_abs_tol = 1e-15
[]
[UserObjects]
  # [./ViewFactor]
  #   type = ViewFactorMonteCarlo
  #   boundary = '2 7 8 13'
  #   sampling_number = 100
  #   source_number = 100
  #   execute_on = INITIAL
  # [../]
  [./ViewFactor]
    type = ViewFactor
    boundary = 'bottom right'
    method = MONTECARLO
    sampling_number = 100
    source_number = 10
    print_screen = true
    execute_on = INITIAL
  [../]
[]
[Postprocessors]
  [./thermal_conductivity_W_m-K]
    type = ElementIntegralMaterialProperty
    outputs = console
    block = duct
    mat_prop = thermal_conductivity
    # execute_on = 'initial timestep_end'
  [../]
  [./bottom_temp]
    type = SideAverageValue
    boundary = 'bottom'
    variable = temp
  [../]
  # [./bottom_flux_ave]
  #   type = SideFluxAverage
  #   boundary = 'bottom'
  #   variable = temp
  # [../]
  # [./bottom_flux_int]
  #   type = SideFluxIntegral
  #   boundary = 'bottom'
  #   variable = temp
  # [../]
  [./right_temp]
    type = SideAverageValue
    boundary = 'right'
    variable = temp
  [../]
  # [./right_flux_ave]
  #   type = SideFluxAverage
  #   boundary = 'right'
  #   variable = temp
  # [../]
  # [./right_flux_int]
  #   type = SideFluxIntegral
  #   boundary = 'right'
  #   variable = temp
  # [../]
[]

[Outputs]
  exodus = true
  file_base = duct_out
  console = true
[]
