# This simulates disorder-order(A2---->B2)transsition in BCC alloys
# eta=0 in the disordered case
#and eta=+/-1 in the two ordered variants
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 128
  ny = 128
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
  [./eta] # order parameter
    type = RandomIC
    variable = 'eta'
     min = -0.0100
     max = 0.0101  # A little biased toward the +ve variant
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
  [./AC_bulk]
    type = AllenCahn
    variable = 'eta'
    f_name = F
    args = 'eta'
  [../]
  [./AC_int]
    type = ACInterface
    variable = 'eta'
  [../]
  [./eta_dot]
    type = TimeDerivative
    variable = 'eta'
  [../]
[]

[Materials]
  [./FreeEng]
    type = DerivativeParsedMaterial
    args ='eta'
    constant_names = 'A'
    constant_expressions = '1.0'
    function = A*(eta+1.0)^2*(eta-1.0)^2
    derivative_order = 2
  [../]
    [./const]
      type = GenericConstantMaterial
      prop_names = 'kappa_op L'
      prop_values = '1.0 1.0'
  [../]
  [./positive_variant]  # Returns 1 if inside the +ve variant
    type = ParsedMaterial
    f_name = positive_variant
    args = eta
    function = if(eta>0.5,1.0,0)
  [../]
[]

[Postprocessors]
  [./positive_variant_area] # total area of the +ve variant
    type = ElementIntegralMaterialProperty
    mat_prop = positive_variant
    execute_on = 'initial timestep_end'
  [../]
  [./total_free_energy]
    type = ElementIntegralVariablePostprocessor
    variable = local_free_energy
  [../]
[]

[Executioner]
   scheme = bdf2
  type = Transient
  nl_max_its = 15
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
  l_max_its = 15
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-7
  start_time = 0.0
  num_steps = 1000
  nl_abs_tol = 1e-9
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.10
    growth_factor = 1.2
    cutback_factor = 0.75
    optimal_iterations = 7
  [../]
[]

[Outputs]
  file_base = disorder_order_transition
  exodus = true
  csv = true
  interval = 1
[]
