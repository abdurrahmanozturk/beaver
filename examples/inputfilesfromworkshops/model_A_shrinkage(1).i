# particle shrinkage under its curvature effect 


[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 64
  ny = 64
  nz = 0
  xmin = 0
  xmax = 128
  ymin = 0
  ymax = 128
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  [./eta]
    order = FIRST
    family =  LAGRANGE
  [../]
[]

[AuxVariables]
  [./local_free_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]
[AuxKernels]
  [./local_free_energy]
    type = TotalFreeEnergy
    variable = local_free_energy
    kappa_names = kappa_op
    interfacial_vars = eta
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
[]

[ICs]
  [./eta]
    type = SpecifiedSmoothCircleIC
    variable = eta
    x_positions = '64'
    y_positions = '64'
    z_positions = '0'
    radii = '25'
    invalue = 1.0
    outvalue = 0.0
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
      variable = 'eta'
    [../]
  [../]
[]

[Kernels]
  [./AC1_bulk]
    type = AllenCahn
    variable = 'eta'
    f_name = F
    args = 'eta'
  [../]
  [./AC1_int]
    type = ACInterface
    variable = 'eta'
  [../]
  [./e1_dot]
    type = TimeDerivative
    variable = 'eta'
  [../]
[]

[Materials]
  [./FreeEng]
    type = DerivativeParsedMaterial
    args ='eta'
    constant_names = 'A B'
    constant_expressions = '1.0 0.0'
    function = A*(eta^2*(1.0-eta)^2)+B*(2.0*eta^3-3.0*eta^2)
    derivative_order = 2
  [../]
    [./const]
      type = GenericConstantMaterial
      prop_names = 'kappa_op L'
      prop_values = '1.0 1.0'
  [../]
[]

[Postprocessors]
  [./area_fraction]
    type = ElementIntegralVariablePostprocessor
    variable = 'eta'
  [../]
  [./total_free_energy]
    type = ElementIntegralVariablePostprocessor
    variable = local_free_energy
  [../]
[]

[Executioner]
  type = Transient
  nl_max_its = 15
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
  l_max_its = 15
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-6
  start_time = 0.0
  num_steps = 50
  nl_abs_tol = 1e-9
  #dtmax = 2
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0
    growth_factor = 1.2
    cutback_factor = 0.75
    optimal_iterations = 7
  [../]
  [./Adaptivity]
    refine_fraction = 0.7
    coarsen_fraction = 0.01
    max_h_level = 2
    initial_adaptivity = 2
  [../]
[]

[Outputs]
  file_base = modelA_shrinkage
  exodus = true
  csv = true
  interval = 1
[]
