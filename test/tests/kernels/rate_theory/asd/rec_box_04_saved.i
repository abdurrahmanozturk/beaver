# This is a simple recrystallization example with one recrystallized grain embedded in a deformed matrix grain
# if the strain energy balances the curvature effect the recrystallized grain will be in equilbrium with the matrix
# higher strain energy will cause growth of the recrystallized grain, lower will cause shrinkage


[Mesh]
  type = GeneratedMesh
  uniform_refine = 2
  dim = 2
  nx = 128
  ny = 128
  nz = 0
  xmin = 0
  xmax = 256
  ymin = 0
  ymax = 256
  zmax = 0
  elem_type = QUAD4
[]

[GlobalParams]
  block = '0'
  op_num = '2'
  var_name_base = 'eta'
[]

[Variables]
  [./PolycrystalVariables]
  [../]
[]

[Functions]
  # dislocation_denisty (could be function of space and time)
  [./g_o_func]
    type = ParsedFunction
    value = 'k1:=0;k2:=5;if(x<=128,k1,if(y<=136&y>=120,k2,k1))'
  [../]
[]


[AuxVariables]
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]

# dislocation density
  [./dd]
    order = CONSTANT
    family = MONOMIAL
  [../]

[]


[ICs]
    # Intial Slab Geometry
    [./IC_eta1]
      x1 = 0
      y1 = 0
      x2 = 128
      y2 = 256
      inside = 1.0
      variable = eta0
      outside = 0.0
      type = BoundingBoxIC
  [../]

  [./IC_eta2]
      x1 = 128
      y1 = 0
      x2 = 256
      y2 = 256
      inside = 1.0
      variable = eta1
      outside = 0.0
      type = BoundingBoxIC
  [../]
  []

## circle IC

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'y'
    [../]
  [../]
[]

[Kernels]
  [./AC1_bulk]
    type = AllenCahn
    variable = eta0
    f_name = F
    args = 'eta1'
  [../]
  [./AC1_int]
    type = ACInterface
    variable = eta0
  [../]
  [./e1_dot]
    type = TimeDerivative
    variable = eta0
  [../]
  [./AC2_bulk]
    type = AllenCahn
    variable = eta1
    f_name = F
    args = 'eta0'
  [../]
  [./AC2_int]
    type = ACInterface
    variable = eta1
  [../]
  [./e2_dot]
    type = TimeDerivative
    variable = eta1
  [../]
[]

[AuxKernels]

  [./bnds]
    type = BndsCalcAux
    variable = bnds
    execute_on = timestep_end
  [../]

  [./dd]
    type = MaterialRealAux
    variable = dd
    property = g_o
  [../]

[]


[Materials]
  [./FreeEng]
    type = DerivativeParsedMaterial
    args = 'eta1 eta0'
    constant_names = 'gamma a'
    constant_expressions = '1.50 2.0'
    material_property_names = 'g_o'
    function = 'sumeta:=eta0^2+eta1^2;f3:=1.0/4.0+1.0/4.0*eta1^4-1.0/2.0*eta1^2+1.0/4.0*eta0^4-1.0/2.0*eta0^2;f4:=gamma*(eta1^2*eta0^2);f1:=g_o*((eta1^2)/sumeta);f:=f1+a*(f3+f4);f'
    derivative_order = 2
  [../]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'kappa_op L' # g_o is the strain energy set for equilbrium value; try increase it or decrease it by an order of magnitude to see growth or shrinkage
    prop_values = '0.50 1.0'
  [../]
  [./dislocation_denisty]
  type = GenericFunctionMaterial
  prop_names = g_o
  prop_values = g_o_func
[../]

[]

[Postprocessors]
  [./rec_grn_area]
    type = ElementIntegralVariablePostprocessor
    variable = 'eta1'
  [../]
  [./dt]
    type = TimestepSize
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
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
  end_time = 400
  nl_abs_tol = 1e-8
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0e-1
    growth_factor = 1.2
    cutback_factor = 0.75
    optimal_iterations = 7
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  show = 'bnds dd'
  interval = 1
[]
