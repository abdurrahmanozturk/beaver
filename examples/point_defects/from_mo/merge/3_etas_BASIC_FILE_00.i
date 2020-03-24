
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
  op_num = '3' # total number of order parameters
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
    value ='k1:=0;k2:=6.0;if(y>= x & y<=(x + 10),k2,(if(y>= (x+40) & y<=(x + 50),k2,(if(y>= (x+80) & y<=(x + 90),k2,(if(y>= (x+110) & y<=(x + 120),k2,(if(y>= (x+150) & y<=(x + 160),k2,(if(y>= (x+190) & y<=(x + 200),k2,(if(y>= (x+230) & y<=(x + 240),k2,k1)))))))))))))'

    #### use this to repeat the function on the last k1 "(if(y>= (x+?) & y<=(x + ?+1),k2,k1))"
  [../]
[]



################################


[AuxVariables]
  # for visuallizing all grains
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]
  # unique number for each grain
  [./unique_grains]
    order = CONSTANT
    family = MONOMIAL
  [../]
# dislocation density
  [./dd]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]



# ## New IC

[ICs]
    # Intial Slab Geometry
    [./IC_eta0]
      x1 = 0
      y1 = 0
      x2 = 256
      y2 = 256
      inside = 1.0
      variable = eta0
      outside = 0.0
      type = BoundingBoxIC
  [../]

  # Extrea OPs for nucleation of new grains
  [./IC_eta1]
    variable = eta1
    type = RandomIC
    max = 2e-2
    min = 1e-2
  [../]
  [./IC_eta2]
    variable = eta2
    seed = 1000
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

# New Kernels

# last kernels
[Kernels]

################# eta0 ####################
  [./AC0_bulk]
    type = AllenCahn
    variable = eta0
    f_name = F
    args = 'eta1 eta2'
  [../]

  [./AC0_int]
    type = ACInterface
    variable = eta0
  [../]

  [./e0_dot]
    type = TimeDerivative
    variable = eta0
  [../]

#########################  eta1 ###############

  [./AC1_bulk]
    type = AllenCahn
    variable = eta1
    f_name = F
    args = 'eta0 eta2'
  [../]

  [./AC1_int]
    type = ACInterface
    variable = eta1
  [../]

  [./e1_dot]
    type = TimeDerivative
    variable = eta1
  [../]
################################  eta 3 ###########
  [./AC2_bulk]
    type = AllenCahn
    variable = eta2
    f_name = F
    args = 'eta0 eta1'
  [../]

  [./AC2_int]
    type = ACInterface
    variable = eta2
  [../]

  [./e2_dot]
    type = TimeDerivative
    variable = eta2
  [../]

[]

##################################

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'timestep_end'
  [../]

############### to display the dislocation_denisty ##########

  [./dd]
    type = MaterialRealAux
    variable = dd
    property = dis_den
  [../]

[]

###### need help here #####


[Materials]
  [./FreeEng]
    type = DerivativeParsedMaterial
    args = 'eta0 eta1 eta2'
    constant_names = 'gamma a'
    constant_expressions = '1.50 2.0'
    material_property_names = 'g_o'
    function = 'sumeta:=eta0^2+eta1^2+eta2^2;f3:=(0.25+(0.25*(eta0^4+eta1^4+eta2^4))-(0.5*(eta0^2+eta1^2+eta2^2)));f4:=gamma*(eta0^2*eta1^2+eta0^2*eta2^2+eta1^2*eta2^2);f1:=g_o*((eta0^2)/sumeta);f:=f1+a*(f3+f4);f'
    derivative_order = 2
  [../]
  [./const]
    type = GenericConstantMaterial
    prop_names = 'kappa_op L' # g_o is the strain energy set for equilbrium value; try increase it or decrease it by an order of magnitude to see growth or shrinkage
    prop_values = '0.50 1.0'
  [../]


  [./dis_den_0]
  type = GenericFunctionMaterial
  prop_names = g_o
  prop_values = g_o_func
[../]

###############################################
[./dis_den]
  type = ParsedMaterial
  f_name = dis_den
  args = 'eta0 eta1 eta2'
  material_property_names = g_o
  function = g_o*((eta0^2)/(eta0^2+eta1^2+eta2^2))

  [../]

[]
##########################################################


[Postprocessors]
  [./rec_grn_area]
    type = ElementIntegralVariablePostprocessor
    variable = 'eta1 eta2'
  [../]
  [./dt]
    type = TimestepSize
  [../]
  [./dislocation_denisty]
    type = ElementIntegralMaterialProperty
    mat_prop = dis_den
    execute_on = 'initial timestep_end'
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
  petsc_options_iname = '-pc_type -sub_pc_type'
  petsc_options_value = 'asm ilu'
  l_max_its = 15
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-7
  start_time = 0.0
  end_time = 4000
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
  csv = true
  interval = 1
[]
