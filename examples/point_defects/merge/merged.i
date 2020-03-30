[GlobalParams]
  block = '0'
  op_num = '3' # total number of order parameters
  var_name_base = 'eta'
[]

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

[Variables]
  [./ci]
    # initial_condition = 0
  [../]
  [./cv]
    # initial_condition = 0
  [../]
  [./PolycrystalVariables]
  [../]
[]

[AuxVariables]
  [./xi]
  [../]
  [./xv]
  [../]
  [./cs]
    initial_condition = 1
  [../]
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
  [./disden]
    order = CONSTANT
    family = MONOMIAL
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

[Kernels]
  [./defect_generation_i]
    type = BodyForce  #maskedbodyforce
    variable = ci
    # value = 1e-7   #dpa/s   recombination dominated case
    value = 1e-6   #dpa/s   regular case
  [../]
  [./defect_generation_v]
    type = BodyForce
    variable = cv
    # value = 1e-7   #dpa/s   recombination dominated case
    value = 1e-6   #dpa/s   regular case
  [../]
  [./recombination_i]
    type = MatReaction
    variable = ci
    args = cv     #coupled on materials block
    mob_name = Kiv
  [../]
  [./recombination_v]
    type = MatReaction
    variable = cv
    args = ci    #coupled in materials block
    mob_name = Kvi
  [../]
  [./sink_reaction_i]
    type = MatReaction
    variable = ci
    mob_name = Kis
    args = cs     #coupled on materials block
  [../]
  [./sink_reaction_v]
    type = MatReaction
    variable = cv
    mob_name = Kvs
    args = cs    #coupled in materials block
  [../]
  [./ci_diff]
    type = MatDiffusion
    variable = ci
    D_name = Di
  [../]
  [./cv_diff]
    type = MatDiffusion
    variable = cv
    D_name = Dv
  [../]
  [./ci_time]
    type = TimeDerivative
    variable = ci
  [../]
  [./cv_time]
    type = TimeDerivative
    variable = cv
  [../]

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
  ################################  eta 2 ###########
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

[AuxKernels]
  [./xi]
    type = ParsedAux
    variable = xi
    args = ci
    function = 'kiv:=1;k:=1e-6;ci*sqrt(kiv/k)'
  [../]
  [./xv]
    type = ParsedAux
    variable = xv
    args = cv
    function = 'kiv:=1;k:=1e-6;cv*sqrt(kiv/k)'
  [../]

  [./bnds]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'timestep_end'
  [../]

############### to display the dislocation_denisty ##########

  [./disden]
    type = MaterialRealAux
    variable = disden
    property = dis_den
  [../]

[]

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

  [./cv]
    type = RandomIC
    variable = 'cv'
    min = 1e-11
    max = 3e-11
     seed = 10
  [../]

  [./ci]
    type = RandomIC
    variable = 'ci'
    min = 1e-11
    max = 3e-11
     seed = 11
  [../]

[]

[BCs]
  [./Periodic]
    [./All]
      variable = 'eta0 eta1 eta2'
      # edited to auto_direction = y
      auto_direction = 'y'
    [../]
  [../]
[]

[Materials]
 [./D]
   type = GenericConstantMaterial # diffusion coeficients
   prop_names = 'Di Dv'
   # prop_values = '5e-14 1.3e-28'   # cm2/sec      recombination dominated case
   prop_values = '1e-15 1e-15' # cm2/sec      regular case
   block = '0'
 [../]
 [./Kiv]
   type = DerivativeParsedMaterial
   f_name = Kiv
   args = cv
   # function = 'kiv:=1.7e4;kiv*cv'    # 1/s recombination dominated
   function = 'kiv:=1e-9;-kiv*cv'  # 1/s regular case
 [../]
 [./Kvi]
   type = DerivativeParsedMaterial
   f_name = Kvi
   args = ci
   # function = 'kiv:=1.7e4;kiv*ci'    # 1/s recombination dominated
   function = 'kiv:=1e-9;-kiv*ci'  # 1/s regular case
 [../]
 [./Kis]
   type = DerivativeParsedMaterial
   f_name = Kis
   args = cs
   # function = 'Di:=5e-14;ki:=38490;Di*ki*ki*cs' # 1/s      recombination dominated case
   function = 'kis:=1e-2;-kis*cs' # 1/s      regular case
 [../]
 [./Kvs]
   type = DerivativeParsedMaterial
   f_name = Kvs
   args = cs
   # function = 'Dv:=1.3e-28;kv:=36580;Dv*Dv*kv*cs' # 1/s      recombination dominated case
   function = 'kvs:=1e-5;-kvs*cs' # 1/s      regular case
 [../]

 [./FreeEng]
   type = DerivativeParsedMaterial
   args = 'eta0 eta1 eta2'
   constant_names = 'gamma a'
   constant_expressions = '1.50 2.0'
   material_property_names = 'dd'
   function = 'd:=dd;sumeta:=eta0^2+eta1^2+eta2^2;f3:=(0.25+(0.25*(eta0^4+eta1^4+eta2^4))-(0.5*(eta0^2+eta1^2+eta2^2)));f4:=gamma*(eta0^2*eta1^2+eta0^2*eta2^2+eta1^2*eta2^2);f1:=d*((eta0^2)/sumeta);f:=f1+a*(f3+f4);f'
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

  [./dislocation_density]
    type = ParsedMaterial
    f_name = dd
    args = 'ci cv'
    function = 'Di:=1e-15;Dv:=1e-15;(Dv*cv-Di*ci)'#/(ci+cv)  ## steady state condition relation
  [../]
[]

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
  [./dd]
    type = ElementIntegralMaterialProperty
    mat_prop = dd
    execute_on = 'initial timestep_end'
  [../]
  [./center_ci]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = ci
  [../]
  [./center_cv]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = cv
  [../]
  [./center_xi]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = xi
  [../]
  [./center_xv]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = xv
  [../]
  [./center_cs]
    type = PointValue
    point = '0.5 0.5 0.0'
    variable = cs
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'  #try NEWTON,PJFNK
  petsc_options_iname = '-pc_type -sub_pc_type'
  petsc_options_value = 'asm ilu  '  #  either asm or hypre'
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 40 # Max number of nonlinear iterations
  nl_abs_tol = 1e-15 # Relative tolerance for nonlienar solves
  nl_rel_tol = 1e-9 # Absolute tolerance for nonlienar solves
  scheme = bdf2   #try crank-nicholson
  start_time = 0
  # num_steps = 4294967295
  steady_state_detection = true
  end_time = 100
  # dt = 1
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1 #s
    optimal_iterations = 5
    growth_factor = 1.2
    cutback_factor = 0.8
  [../]
  # postprocessor = cv
  # skip = 25
  # criteria = 0.01
  # below = true
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  # exodus = true
  file_base = point_defects_merged
  [./exodus]
    type = Exodus
    output_material_properties = 1
    output_postprocessors = true
    interval = 10000
  [../]
  csv = true
[]
