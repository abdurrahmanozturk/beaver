
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
  op_num = '4' # total number of order parameters
  var_name_base = 'eta'
  variable_L = false
[]

[Variables]
  [./ci]
  initial_condition = 0.85
  [../]
  [./cv]
  initial_condition = 0.85
  [../]
  [./eta0]
  [../]
  [./eta1]
  [../]
  [./eta2]
  [../]
  [./eta3]
  [../]
[]

[AuxVariables]

    [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]

    [./unique_grains]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./dd]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]



[ICs]
  # [./cv]
  #   type = RandomIC
  #   min = 0
  #   max = 1
  #   variable = ci
  #   # x1 = 0.5
  #   # y1 = 0.5
  #   # invalue = 1
  #   # outvalue = 0
  #   # radius = '0.25'
  # [../]
  # [./ci]
  #   type = RandomIC
  #   min = 0
  #   max = 1
  #   variable = cv
  #   # x1 = 0.5
  #   # y1 = 0.5
  #   # invalue = 1
  #   # outvalue = 0
  #   # radius = '0.25'
  # [../]

# Intial Slab Geometry
    [./IC_eta0]
      x1 = 0
      y1 = 0
      x2 = 128
      y2 = 256
      inside = 1.0
      variable = eta0
      outside = 0.0
      type = BoundingBoxIC
    [../]

    [./IC_eta1]
      x1 = 128
      y1 = 0
      x2 = 256
      y2 = 256
      inside = 1.0
      variable = eta1
      outside = 0.0
      type = BoundingBoxIC
    [../]

  # Extrea OPs for nucleation of new grains
  [./IC_eta2]
    variable = eta2
    type = RandomIC
    max = 2e-2
    min = 1e-2
  [../]

  [./IC_eta3]
    variable = eta3
    type = RandomIC
    max = 2e-2
    min = 1e-2
  [../]

[]

[BCs]
  [./Periodic]
    [./All]
      # edited to auto_direction = y
      auto_direction = 'y'
    [../]
  [../]
[]


[Kernels]
  [./defect_i]
  type = PointDefect
  variable = ci
  coupled = cv
  ks = 38490
  k = 1e-2
  kiv = 7.49e10
  D = 1.35e-7
  # disable_diffusion = true
[../]
[./defect_v]
  type = PointDefect
  variable = cv
  coupled = ci
  ks = 36580
  k = 1e-2
  kiv = 7.49e10
  D = 9.4e-13
  # disable_diffusion = true
[../]
[./ci_time]
  type = TimeDerivative
  variable = ci
[../]
[./cv_time]
  type = TimeDerivative
  variable = cv
[../]

  [./AC0_bulk]
    type = AllenCahn
    variable = eta0
    f_name = F
    args = 'eta1 eta2 eta3'
  [../]

  [./AC0_int]
    type = ACInterface
    variable = eta0
  [../]

  [./e0_dot]
    type = TimeDerivative
    variable = eta0
  [../]

  [./AC1_bulk]
    type = AllenCahn
    variable = eta1
    f_name = F
    args = 'eta0 eta2 eta3'
  [../]

  [./AC1_int]
    type = ACInterface
    variable = eta1
  [../]

  [./e1_dot]
    type = TimeDerivative
    variable = eta1
  [../]

  [./AC2_bulk]
    type = AllenCahn
    variable = eta2
    f_name = F
    args = 'eta0 eta1 eta3'
  [../]

  [./AC2_int]
    type = ACInterface
    variable = eta2
  [../]

  [./e2_dot]
    type = TimeDerivative
    variable = eta2
  [../]

  [./AC3_bulk]
    type = AllenCahn
    variable = eta3
    f_name = F
    args = 'eta0 eta1 eta2'
  [../]

  [./AC3_int]
    type = ACInterface
    variable = eta3
  [../]

  [./e3_dot]
    type = TimeDerivative
    variable = eta3
  [../]



[]

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'timestep_end'
  [../]

  [./dd]
    type = MaterialRealAux
    variable = dd
    property = dis_den
    [../]

    [./unique_grains]
      type = FeatureFloodCountAux
      variable = unique_grains
      flood_counter = grain_tracker
      execute_on = 'initial timestep_begin'
    [../]

    []


    [Materials]

      [./t]
    type = TimeStepMaterial
    prop_time = time
   # [./D]
   #   type = GenericConstantMaterial # diffusion coeficient was found in
   #   prop_names = 'D_A D_B'
   #   prop_values = '0.0055 0.0065' # m/year
   #   block = '0'
   # [../]
 [../]
 # [./t1]
 #   type = ParsedMaterial
 #   material_property_names = time
 #   function = 'kiv:=7.49e10;k:=1e-2;time*sqrt(kiv*k)'
 # [../]

      [./FreeEng]
        type = DerivativeParsedMaterial
        args = 'eta0 eta1 eta2 eta3'
        constant_names = 'g b e'
        constant_expressions = '1.50 1.0 0.85'
        material_property_names = 'dis_den'
        function = 'sumeta:=eta0^2+eta1^2+eta2^2+eta3^2;f3:=1.0/4.0+1.0/4.0*eta1^4-1.0/2.0*eta1^2+1.0/4.0*eta2^4-1.0/2.0*eta2^2+1.0/4.0*eta3^4-1.0/2.0*eta3^2+1.0/4.0*eta0^4-1.0/2.0*eta0^2;f4:=g*((eta0^2*eta1^2+eta0^2*eta2^2+eta0^2*eta3^2)+(eta1^2*eta2^2+eta1^2*eta3^2)+(eta2^2*eta3^2));f1:=e*((eta0^2+eta1^2)/sumeta);f:=f1+b*(f3+f4);f'
        derivative_order = 2
      [../]

  [./const]
    type = GenericConstantMaterial
    prop_names = 'kappa_op L'
    prop_values = '1.0 1.0'
  [../]

  # [./dis_den]
  #   type = ParsedMaterial
  #   f_name = dis_den
  #   args = 'eta0 eta1 eta2 eta3'
  #   constant_names = 'e'
  #   constant_expressions = '0.85'
  #   function = 'sumeta:=eta0^2+eta1^2+eta2^2+eta3^2;f:=e*((eta0^2+eta1^2)/sumeta);f'
  # [../]

  [./rec_frac]
    type = ParsedMaterial
    f_name = rec_frac
    args = 'eta2 eta3'
    constant_names = 'rec'
    constant_expressions = '256*256'
    function = '((eta2+eta3)/(rec))'
    #outputs = exodus
  [../]
[]

[Postprocessors]

  [./dt]
    type = TimestepSize
  [../]

  [./recrystallized_fraction]
    type = ElementIntegralMaterialProperty
    mat_prop = rec_frac
    execute_on = 'initial timestep_end'
  [../]

  [./grain_tracker]
  type = FauxGrainTracker

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
  end_time = 100000
  nl_abs_tol = 1e-8

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.0e-8
    growth_factor = 1.2
    cutback_factor = 0.75
    optimal_iterations = 7
  [../]
[]

[Outputs]
  exodus = true
[]
