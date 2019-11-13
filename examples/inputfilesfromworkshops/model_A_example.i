# This is a template for phase-field model A
# that the solves Allen-Cahn equation for non-conserved variables.
# It follows the evolution of a circular precipitate/grain/domain embedded in a large matrix
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 64
  ny = 64
  xmin = 0
  xmax = 256
  ymin = 0
  ymax = 256
  uniform_refine = 2
  elem_type = QUAD4
[]

[Variables]
  [./eta]
    order = FIRST
    family =  LAGRANGE
  [../]
[]
# aux varaibles to track the free energy change (must decrease with time)
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
    f_name = F
    execute_on = 'TIMESTEP_END'
  [../]
[]

[ICs]
  [./IC_eta]
    x1 = 128
    y1 = 128
    radius = 64.0
    outvalue = 0.0
    variable = eta
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Kernels]
  [./AC1_bulk]
    type = AllenCahn
    variable = 'eta'
    f_name = F
    mob_name = L
  [../]
  [./AC1_int]
    type = ACInterface
    variable = 'eta'
    kappa_name = kappa_op
    mob_name = L
  [../]
  [./eta_dot]
    type = TimeDerivative
    variable = eta
  [../]
[]

[Materials]
  [./bulk_free_energy]
    type = DerivativeParsedMaterial
    args ='eta'
    f_name = F
    constant_names = 'A eta_m eta_p'
    constant_expressions = '1.0 0.0 1.0'
    # m:matrix, p: precipitate, eta_p: Equilibrium value of eta in precipitate
    function = A*((eta-eta_m)^2*(eta-eta_p)^2)
    derivative_order = 2
  [../]
    [./const]
      type = GenericConstantMaterial
      prop_names = 'kappa_op L'
      prop_values = '1.0 1.0'
  [../]
[]

[Postprocessors]
  [./precip_area] # since eta=1.0 inside the precipitate
    type = ElementIntegralVariablePostprocessor
    variable = 'eta'
  [../]
  [./total_free_energy]
    type = ElementIntegralVariablePostprocessor
    variable = local_free_energy
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  scheme = bdf2
  nl_max_its = 15
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
  start_time = 0
  num_steps = 10
  l_max_its = 15
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-8
  nl_abs_tol = 1e-11
[]

[Outputs]
  file_base = model_A
  exodus = true
  csv = true
  interval = 1
[]
