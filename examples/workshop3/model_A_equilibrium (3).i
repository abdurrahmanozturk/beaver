# This is a simple example to calculate the equilibrium properties for Model A
# surface energy = 0.2357 
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 400
  ny = 10
  nz = 0
  xmin = -100
  xmax = 100
  ymin = 0
  ymax = 1
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
    f_name = F
    execute_on = 'TIMESTEP_END'
  [../]
[]
[Functions]
  [./analytic_solution] # expected equilibrium profile
    type = ParsedFunction
    value = 'Kappa:=1.0;A:=1.0;0.50*(1.0+tanh(x*sqrt(A/(2.0*Kappa))))'
  [../]
[]

[ICs]
  [./InitialCondition]
    type = FunctionIC
    function = analytic_solution
    variable = eta
  [../]
[]

[BCs]
[]

[Kernels]
  [./AC_bulk]
    type = AllenCahn
    variable = 'eta'
    f_name = F
  [../]
  [./AC_int]
    type = ACInterface
    variable = 'eta'
  [../]
[]

[Materials]
  [./bulk_free_energy]
    type = DerivativeParsedMaterial
    args ='eta'
    f_name = F
    constant_names = 'A'
    constant_expressions = '1.0'
    function = A*(eta^2*(eta-1.0)^2)
    derivative_order = 2
  [../]
    [./const]
      type = GenericConstantMaterial
      prop_names = 'kappa_op L'
      prop_values = '1.0 1.0'
  [../]
[]

[Postprocessors]
  [./total_free_energy]
    type = ElementIntegralVariablePostprocessor
    variable = local_free_energy
    # this will give the excess/interface energy
  [../]
  [./error]
    type = ElementL2Error
    variable = eta
    function = analytic_solution
  [../]
[]

[VectorPostprocessors]
  [./x_direction]
   type =  LineValueSampler
    start_point = '-100 0.5 0'
    end_point = '100 0.5 0'
    variable = 'eta'
    num_points = 401
    sort_by =  id
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Steady
  nl_max_its = 15
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  l_max_its = 15
  l_tol = 1.0e-6
  nl_rel_tol = 1.0e-9
  nl_abs_tol = 1e-11
  [./Adaptivity]
    refine_fraction = 0.5
    coarsen_fraction = 0.01
    max_h_level = 3
    initial_adaptivity = 2
  [../]
[]

[Outputs]
  file_base = model_A_eq
  exodus = true
  csv = true
  interval = 1
[]
