# [GlobalParams]
#   block = '0'
#   op_num = '3' # total number of order parameters
#   var_name_base = 'eta'
# []

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
  [./xi]
    # initial_condition = 0
  [../]
  [./xv]
    # initial_condition = 0
  [../]
  [./rho_i]   #non-dimensionalized interstitial loop density, rho_i=ddi/ddn
    initial_condition = 0
  [../]
  [./rho_v]   #non-dimensionalized vacancy loop density, rho_v=ddv/ddn
    initial_condition = 0
  [../]
  # [./rho_c] #non-dimensionalized void sink density , rho_c=ddc/ddn  where ddc= 4piNcRc, Nc:void number density, Rc:mean void radius
  # [../]
  # [./PolycrystalVariables]
  # [../]
[]

[AuxVariables]
  ##--- Non-dimensionalization scaling parameters ---
  ##  alpha : recombination rate
  ##  lambda = Dv*ZvN*rho_n
  ##  gamma = alpha/lambda
  ##  x   = gamma*c
  ##  rho  = dd/ddn
  ##  tau = lambda*t
  [./P]      #P = gamma*K/lambda
    initial_condition = 2.844e-19
  [../]
  [./Di_bar] #Di_bar = Di/lambda
    initial_condition = 9.886e-13
  [../]
  [./Dv_bar] #Dv_bar = Dv/lambda
    initial_condition = 1e-15
  [../]
  [./mu]     #mu = Di/Dv
    initial_condition = 988.584
  [../]
  [./B]      #Excess network bias
    initial_condition = 0.1
  [../]
  [./tau_i]  # tau_i = b*alpha*rho_n/2*pi*N*Dv
    initial_condition = 7363707.96
  [../]
  [./tau_v]  # tau_v = b*rv*rho_n*gamma
    initial_condition = 1.9998e-16
  [../]
  # [./tau_c]  # tau_c = alpha*rho_n*rho_n/(4*pi*Nc)*(4*pi*Nc)*Dv
  #   initial_condition = 0
  # [../]
  [./epsi]   #interstitial cascade collapse efficiency
    initial_condition = 0.1
  [../]
  [./epsv]   #cascade collapse efficiency
    initial_condition = 0.1   #for nickel
  [../]
  [./xvL]   # Thermallyemitted vacancies from network dislocation.  xvN << xvv ~= xxi ~= xvc = xvL
    initial_condition = 0
  [../]
#   # for visuallizing all grains
#   [./bnds]
#     order = FIRST
#     family = LAGRANGE
#   [../]
#   # unique number for each grain
#   [./unique_grains]
#     order = CONSTANT
#     family = MONOMIAL
#   [../]
# # dislocation density
#   [./disden]
#     order = CONSTANT
#     family = MONOMIAL
#   [../]
[]

[Functions]
  # dislocation_denisty (could be function of space and time)
  # [./g_o_func]
  #   type = ParsedFunction
  #   value ='k1:=0;k2:=6.0;if(y>= x & y<=(x + 10),k2,(if(y>= (x+40) & y<=(x + 50),k2,(if(y>= (x+80) & y<=(x + 90),k2,(if(y>= (x+110) & y<=(x + 120),k2,(if(y>= (x+150) & y<=(x + 160),k2,(if(y>= (x+190) & y<=(x + 200),k2,(if(y>= (x+230) & y<=(x + 240),k2,k1)))))))))))))'
  #   #### use this to repeat the function on the last k1 "(if(y>= (x+?) & y<=(x + ?+1),k2,k1))"
  # [../]
[]

[Kernels]

##### Interstitial Concentration Differantial Equation

  [./dxi_dtau]
    type = TimeDerivative
    variable = xi
  [../]
  [./xi_defect_generation]
    type = MaskedBodyForce
    variable = xi
    args = 'P epsi'      # coupled on materials block
    mask = source_i  # P*(1-epsilon_i)
  [../]
  [./xi_recombination]
    type = MatReaction
    variable = xi
    args = xv            #coupled on materials block
    mob_name = reaction_iv     # xi*xv
  [../]
  [./xi_diffusion]
    type = MatDiffusion
    variable = xi
    D_name = Di
  [../]
  [./xi_sink]
    type = MatReaction
    variable = xi
    args = 'mu B rho_i rho_v'     #coupled on materials block
    mob_name = sink_i
  [../]
  # # [./xi_sink_rho_c]
  # #   type = MatReaction
  # #   variable = xi
  # #   args = 'mu rho_c'     #coupled on materials block
  # #   mob_name = sink_i_rho_c
  # # [../]

##### Vacancy Concentration Differantial Equation

  [./dxv_dt]
    type = TimeDerivative
    variable = xv
  [../]
  [./xv_defect_generation]
    type = MaskedBodyForce
    variable = xv
    args = 'P epsv'      # coupled on materials block
    mask = source_v  # P*(1-epsilon_v)
  [../]
  [./xv_recombination]
    type = MatReaction
    variable = xv
    args = xi            #coupled on materials block
    mob_name = reaction_vi     # xi*xv
  [../]
  [./xv_diffusion]
    type = MatDiffusion
    variable = xv
    D_name = Dv
  [../]
  [./xv_sink]
    type = MatReaction
    variable = xv
    args = 'rho_i rho_v'     #coupled on materials block
    mob_name = sink_v
  [../]
  # [./xv_sink_rho_c]
  #   type = MatReaction
  #   variable = xv
  #   args = rho_c            #coupled on materials block
  #   mob_name = sink_v_rho_c
  # [../]

##### Dislocation Density Differantial Equation

  # interstitial loop density
  [./drho_i_dt]
    type = TimeDerivative
    variable = rho_i
  [../]
  [./rho_i_source]
    type = MaskedBodyForce
    variable = rho_i
    args = 'tau_i epsi P mu B xi xv xvL'      # coupled on materials block
    mask = source_rho_i         # P*epsilon_i
  [../]

  # vacancy loop density
  [./drho_v_dt]
    type = TimeDerivative
    variable = rho_v
  [../]
  [./rho_v_source]
    type = MaskedBodyForce
    variable = rho_v
    args = 'tau_v epsv P'      # coupled on materials block
    mask = source_rho_v  # P*epsilon_v
  [../]
  [./rho_v_reaction]
    type = MatReaction
    variable = rho_v
    args = 'mu B xi xv xvL tau_v'      # coupled on materials block
    mob_name = reaction_rho_v
  [../]

  #void sink density
  # vacancy loop density
  [./tau_c_rho_c_drho_c_dt]
    type = SusceptibilityTimeDerivative
    variable = rho_c
    args = rho_c
    f_name = susceptibility_rho_c
  [../]
  [./rho_v_source]
    type = MaskedBodyForce
    variable = rho_v
    args = 'tau_v epsv P'      # coupled on materials block
    mask = source_rho_v  # P*epsilon_v
  [../]

#
#   ################# eta0 ####################
#     [./AC0_bulk]
#       type = AllenCahn
#       variable = eta0
#       f_name = F
#       args = 'eta1 eta2'
#     [../]
#
#     [./AC0_int]
#       type = ACInterface
#       variable = eta0
#     [../]
#
#     [./e0_dot]
#       type = TimeDerivative
#       variable = eta0
#     [../]
#
#   #########################  eta1 ###############
#
#     [./AC1_bulk]
#       type = AllenCahn
#       variable = eta1
#       f_name = F
#       args = 'eta0 eta2'
#     [../]
#
#     [./AC1_int]
#       type = ACInterface
#       variable = eta1
#     [../]
#
#     [./e1_dot]
#       type = TimeDerivative
#       variable = eta1
#     [../]
#   ################################  eta 2 ###########
#     [./AC2_bulk]
#       type = AllenCahn
#       variable = eta2
#       f_name = F
#       args = 'eta0 eta1'
#     [../]
#
#     [./AC2_int]
#       type = ACInterface
#       variable = eta2
#     [../]
#
#     [./e2_dot]
#       type = TimeDerivative
#       variable = eta2
#     [../]
[]

[AuxKernels]

  # [./ci]
  #   type = ParsedAux
  #   variable = ci
  #   args = xi
  #   function = 'gamma:=DEFINE;xi/gamma'
  # [../]

  # [./cv]
  #   type = ParsedAux
  #   variable = cv
  #   args = xv
  #   function = 'gamma:=DEFINE;xv/gamma'
  # [../]

  # [./bnds]
  #   type = BndsCalcAux
  #   variable = bnds
  #   execute_on = 'timestep_end'
  # [../]

# ############### to display the dislocation_denisty ##########
#
#   [./disden]
#     type = MaterialRealAux
#     variable = disden
#     property = dis_den
#   [../]

[]

[ICs]
  #   # Intial Slab Geometry
  #   [./IC_eta0]
  #     x1 = 0
  #     y1 = 0
  #     x2 = 256
  #     y2 = 256
  #     inside = 1.0
  #     variable = eta0
  #     outside = 0.0
  #     type = BoundingBoxIC
  # [../]
  #
  # # Extrea OPs for nucleation of new grains
  # [./IC_eta1]
  #   variable = eta1
  #   type = RandomIC
  #   max = 2e-2
  #   min = 1e-2
  # [../]
  # [./IC_eta2]
  #   variable = eta2
  #   seed = 1000
  #   type = RandomIC
  #   max = 2e-2
  #   min = 1e-2
  # [../]

  [./xv]
    type = RandomIC
    variable = 'xv'
    min = 1e-11
    max = 3e-11
    seed = 10
  [../]

  [./xi]
    type = RandomIC
    variable = 'xi'
    min = 1e-11
    max = 3e-11
    seed = 11
  [../]

[]

[BCs]
  # [./Periodic]
  #   [./All]
  #     variable = 'eta0 eta1 eta2'
  #     # edited to auto_direction = y
  #     auto_direction = 'y'
  #   [../]
  # [../]
[]

[Materials]

  #interstitial Concentration diff equation
  [./source_i]
    type = ParsedMaterial
    f_name = source_i
    args = 'P epsi'
    function = 'P*(1-epsi)'
  [../]
  [./reaction_iv]
    type = DerivativeParsedMaterial
    f_name = reaction_iv
    args = xv
    function = '-xv'
  [../]
  [./sink_i]
    type = DerivativeParsedMaterial
    f_name = sink_i
    args = 'mu B rho_i rho_v'
    function = '-mu*((1+B)*(1+rho_i+rho_v))'
  [../]
  # [./sink_i_rho_c]
  #   type = DerivativeParsedMaterial
  #   f_name = sink_i_rho_c
  #   args = 'mu rho_c'
  #   function = '-mu*rho_c'
  # [../]

  #vacancy Concentration diff equation
  [./source_v]
    type = DerivativeParsedMaterial
    f_name = source_v
    args = 'P epsv xvL rho_i rho_v'
    function = 'P*(1-epsv)+xvL*(rho_i+rho_v)'
  [../]
  # [./source_v_rho_c]
  #   type = DerivativeParsedMaterial
  #   f_name = source_v_rho_c
  #   args = 'xvL rho_c'
  #   function = 'xvL*rho_c'
  # [../]
  [./reaction_vi]
    type = DerivativeParsedMaterial
    f_name = reaction_vi
    args = xi
    function = '-xi'
  [../]
  [./sink_v]
    type = DerivativeParsedMaterial
    f_name = sink_v
    args = 'rho_i rho_v'
    function = '-(1+rho_i+rho_v)'
  [../]
  # [./sink_v_rho_c]
  #   type = DerivativeParsedMaterial
  #   f_name = sink_v_rho_c
  #   args = rho_c
  #   function = '-rho_c'
  # [../]


  #interstitial loop density diff equation
  [./rho_i_source]
    type = DerivativeParsedMaterial
    f_name = source_rho_i
    args = 'tau_i epsi P mu B xi xv xvL'
    function = '(epsi*P+mu*(1+B)*xi-(xv-xvL))/tau_i'
  [../]

  #vacancy loop density diff equation
  [./rho_v_source]
    type = ParsedMaterial
    f_name = source_rho_v
    args = 'tau_v epsv P'
    function = '(epsv*P)/tau_v'
  [../]
  [./reaction_rho_v]
    type = DerivativeParsedMaterial
    f_name = reaction_rho_v
    args = 'mu B xi xv xvL tau_v'
    function = '-((mu*(1+B)*xi+xvL-xv)/tau_v)'
  [../]

  ##void sink density diff equation
  # [./susceptibility_rho_c]
  #   type = DerivativeParsedMaterial
  #   f_name = susceptibility_rho_c
  #   args = rho_c
  #   function = 'rho_c'
  # [../]
  # [./rho_c_source]
  #   type = DerivativeParsedMaterial
  #   f_name = source_rho_c
  #   args = 'xv xvL mu xi tau_c'
  #   function = '(xv-xvL-mu*xi)/tau_c'
  # [../]

  #diffusion coefficients
  [./Di_bar]
    type = ParsedMaterial
    f_name = Di
    args = 'Di_bar'
    function = 'Di_bar'
  [../]
  [./Dv_bar]
    type = ParsedMaterial
    f_name = Dv
    args = Dv_bar
    function = 'Dv_bar'
  [../]

 # [./FreeEng]
 #   type = DerivativeParsedMaterial
 #   args = 'eta0 eta1 eta2'
 #   constant_names = 'gamma a'
 #   constant_expressions = '1.50 2.0'
 #   material_property_names = 'dd'
 #   function = 'd:=dd;sumeta:=eta0^2+eta1^2+eta2^2;f3:=(0.25+(0.25*(eta0^4+eta1^4+eta2^4))-(0.5*(eta0^2+eta1^2+eta2^2)));f4:=gamma*(eta0^2*eta1^2+eta0^2*eta2^2+eta1^2*eta2^2);f1:=d*((eta0^2)/sumeta);f:=f1+a*(f3+f4);f'
 #   derivative_order = 2
 # [../]
 # [./const]
 #   type = GenericConstantMaterial
 #   prop_names = 'kappa_op L' # g_o is the strain energy set for equilbrium value; try increase it or decrease it by an order of magnitude to see growth or shrinkage
 #   prop_values = '0.50 1.0'
 # [../]
 #
 # [./dis_den_0]
 #   type = GenericFunctionMaterial
 #   prop_names = g_o
 #   prop_values = g_o_func
 # [../]

  # ###############################################
  # [./dis_den]
  #   type = ParsedMaterial
  #   f_name = dis_den
  #   args = 'eta0 eta1 eta2'
  #   material_property_names = g_o
  #   function = g_o*((eta0^2)/(eta0^2+eta1^2+eta2^2))
  # [../]
  #
  # [./dislocation_density]
  #   type = ParsedMaterial
  #   f_name = dd
  #   args = 'xi xv'
  #   function = 'Di:=1e-15;Dv:=1e-15;(Dv*xv-Di*xi)'#/(xi+xv)  ## steady state condition relation
  # [../]
[]

[Postprocessors]
  # [./rec_grn_area]
  #   type = ElementIntegralVariablePostprocessor
  #   variable = 'eta1 eta2'
  # [../]
  # [./dt]
  #   type = TimestepSize
  # [../]
  # [./dislocation_denisty]
  #   type = ElementIntegralMaterialProperty
  #   mat_prop = dis_den
  #   execute_on = 'initial timestep_end'
  # [../]
  # [./dd]
  #   type = ElementIntegralMaterialProperty
  #   mat_prop = dd
  #   execute_on = 'initial timestep_end'
  # [../]
  [./xi]
    type = ElementIntegralVariablePostprocessor
    variable = xi
  [../]
  [./xv]
    type = ElementIntegralVariablePostprocessor
    variable = xv
  [../]
  [./rho_i]
    type = ElementIntegralVariablePostprocessor
    variable = rho_i
  [../]
  [./rho_v]
    type = ElementIntegralVariablePostprocessor
    variable = rho_v
  [../]
  # [./center_xi]
  #   type = PointValue
  #   point = '0.5 0.5 0.0'
  #   variable = xi
  # [../]
  # [./center_xv]
  #   type = PointValue
  #   point = '0.5 0.5 0.0'
  #   variable = xv
  # [../]
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
  end_time = 1000
  # dt = 1
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1 #s
    optimal_iterations = 5
    growth_factor = 1.2
    cutback_factor = 0.8
  [../]
  # postprocessor = xv
  # skip = 25
  # criteria = 0.01
  # below = true
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  # exodus = true
  file_base = point_defects_paper
  [./exodus]
    type = Exodus
    output_material_properties = 1
    output_postprocessors = true
    interval = 10000
  [../]
  csv = true
[]
