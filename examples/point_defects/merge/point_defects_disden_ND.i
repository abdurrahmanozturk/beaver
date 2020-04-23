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
  ##  l : length scale
  ##  w : time scale
  ##  alpha : recombination rate
  ##  beta = l^2
  ##  gamma = alpha*w
  ##  x   = gamma*c
  ##  rho  = beta*disden
  ##  tau = w*t
  [./l]     #length scale {m}
    initial_condition = 1e-9
  [../]
  [./w]     #time scale , w=l^2/Di  {s}
    initial_condition = 5.4e-10
  [../]
  [./Di]    #Interstitial Diffusion Coefficient {m^2/s}
    initial_condition = 1.8537471e-9
  [../]
  [./Dv]    #Vacancy  Diffusion Coefficient {m^2/s}
    initial_condition = 1.8751155e-12
  [../]
  [./K]     #Displacement damage rate  {dpa/s}
    initial_condition = 1e-3
  [../]
  [./alpha] #recombination rate {1/s}
  initial_condition = 1e-9
  [../]
  [./beta]  #beta = l^2 {m^2}
    initial_condition = 1e-18
  [../]
  [./gamma] #gamma = alpha/(Di*l^2) {unitless}
    initial_condition = 5.39448e-19
  [../]
  [./B]     #Excess network bias  {unitless}
    initial_condition = 0.1
  [../]
  [./Zix]   #ZiI=ZiN=ZiV=1+B    {unitless}
    initial_condition = 1.1
  [../]
  [./Zvx]   #ZvI=ZvN=ZvV=ZvC=ZiC = 1  {unitless}
    initial_condition = 1
  [../]
  [./epsi]  #interstitial cascade collapse efficiency  {unitless}
    initial_condition = 0
  [../]
  [./epsv]  #cascade collapse efficiency   {unitless}
    initial_condition = 0.1   #for nickel
  [../]
  [./N]     #interstitial loop denisty  {1/m^3}
    initial_condition = 1e22   #for nickel
  [../]
  [./Nc]    #void loop denisty   {1/m^3}
    initial_condition = 0      #check this value for void!
  [../]
  [./xvL]   #Thermallyemitted vacancies from interstitial,vacancy,void.  xvv ~= xvi ~= xvc = xvL
    initial_condition = 0#3.12525e-28   # xvL=gamma*Cv_e,  can be assumed to be equal to non-dimensionalized equilibrium vacancy concentration or zero
  [../]
  [./xvN]   #Thermallyemitted vacancies from network dislocation.  xvN << xvL
    initial_condition = 0
  [../]
  [./rho_n] #non-dimensionalized network dislocation_denisty, rho_n=beta*ddn   {1/m^2}
    initial_condition = 1e14
  [../]
  [./Rv]    #non-dimensionalized network dislocation_denisty, rho_n=beta*ddn   {1/m^2}
    initial_condition = 1.5e-9
  [../]
  [./b]     #non-dimensionalized network dislocation_denisty, rho_n=beta*ddn   {1/m^2}
    initial_condition = 2.5e-10
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
    args = 'gamma w K epsi'      # coupled on materials block
    mask = source_i
  [../]
  [./xi_recombination]
    type = MatReaction
    variable = xi
    args = 'w alpha gamma xv'   # coupled on materials block
    mob_name = reaction_iv
  [../]
  [./xi_diffusion]
    type = MatDiffusion
    variable = xi
    D_name = wDi
  [../]
  [./xi_sink]
    type = MatReaction
    variable = xi
    args = 'w Di beta Zix rho_n rho_v rho_i'     #coupled on materials block
    mob_name = sink_i
  [../]
  # # [./xi_sink_rho_c]
  # #   type = MatReaction
  # #   variable = xi
  # #   args = 'w Di beta Zvx rho_c'     #coupled on materials block
  # #   mob_name = sink_i_rho_c
  # # [../]

##### Vacancy Concentration Differantial Equation

  [./dxv_dtau]
    type = TimeDerivative
    variable = xv
  [../]
  [./xv_defect_generation]
    type = MaskedBodyForce
    variable = xv
    args = 'gamma w K epsv Dv beta Zvx xvL xvN rho_n rho_v rho_i'      # coupled on materials block
    mask = source_v
  [../]
  [./xv_recombination]
    type = MatReaction
    variable = xv
    args = 'w alpha gamma xi'            #coupled on materials block
    mob_name = reaction_vi
  [../]
  [./xv_diffusion]
    type = MatDiffusion
    variable = xv
    D_name = wDv
  [../]
  [./xv_sink]
    type = MatReaction
    variable = xv
    args = 'w Dv beta Zvx rho_n rho_v rho_i'     #coupled on materials block
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
  [./drho_i_dtau]
    type = TimeDerivative
    variable = rho_i
  [../]
  [./rho_i_source]
    type = MaskedBodyForce
    variable = rho_i
    args = 'N beta w b epsi K Di Zix gamma xi Dv Zvx xv xvL'      # coupled on materials block
    mask = source_rho_i
  [../]

  # vacancy loop density
  [./drho_v_dtau]
    type = TimeDerivative
    variable = rho_v
  [../]
  [./rho_v_source]
    type = MaskedBodyForce
    variable = rho_v
    args = 'w b Rv beta epsv K'      # coupled on materials block
    mask = source_rho_v
  [../]
  [./rho_v_reaction]
    type = MatReaction
    variable = rho_v
    args = 'w b Rv gamma Di Zix xi Dv Zvx xv xvL'      # coupled on materials block
    mob_name = reaction_rho_v
  [../]

  #void sink density
  # vacancy loop density
  # [./rho_c_drho_c_dtau]
  #   type = SusceptibilityTimeDerivative
  #   variable = rho_c
  #   args = rho_c
  #   f_name = susceptibility_rho_c
  # [../]
  # [./rho_c_source]
  #   type = MaskedBodyForce
  #   variable = rho_c
  #   args = 'w Nc lamba gamma Dv Zvx xv xvL Di Zix xi'      # coupled on materials block
  #   mask = source_rho_c
  # [../]

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
  [./Periodic]
    [./All]
      # variable = 'eta0 eta1 eta2'
      # auto_direction = y
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]

  #interstitial Concentration diff equation
  [./source_i]
    type = ParsedMaterial
    f_name = source_i
    args = 'gamma w K epsi'
    function = 'gamma*w*K*(1-epsi)'
  [../]
  [./reaction_iv]
    type = DerivativeParsedMaterial
    f_name = reaction_iv
    args = 'w alpha gamma xv'
    function = '-w*alpha*xv/gamma'
  [../]
  [./sink_i]
    type = DerivativeParsedMaterial
    f_name = sink_i
    args = 'w Di beta Zix rho_n rho_v rho_i'
    function = '-(w*Di*Zix/beta)*(rho_n+rho_v+rho_i)'
  [../]
  # [./sink_i_rho_c]
  #   type = DerivativeParsedMaterial
  #   f_name = sink_i_rho_c
  #   args = 'w Di beta Zvx rho_c'
  #   function = '-w*Di*Zvx*rho_c/beta'
  # [../]

  #vacancy Concentration diff equation
  [./source_v]
    type = DerivativeParsedMaterial
    f_name = source_v
    args = 'gamma w K epsv Dv beta Zvx xvL xvN rho_n rho_v rho_i'
    function = 'gamma*w*K*(1-epsv)+(w*Dv*Zvx/beta)*(xvN*rho_n + xvL*(rho_i+rho_v))'
  [../]
  # [./source_v_rho_c]
  #   type = DerivativeParsedMaterial
  #   f_name = source_v_rho_c
  #   args = 'w Dv beta Zvx xvL rho_c'
  #   function = 'w*Dv*Zvx*xvL*rho_c/beta'
  # [../]
  [./reaction_vi]
    type = DerivativeParsedMaterial
    f_name = reaction_vi
    args = 'w alpha gamma xi'
    function = '-w*alpha*xi/gamma'
  [../]
  [./sink_v]
    type = DerivativeParsedMaterial
    f_name = sink_v
    args = 'w Dv beta Zvx rho_n rho_v rho_i'
    function = '-(w*Dv*Zvx/beta)*(rho_n+rho_v+rho_i)'
  [../]
  # [./sink_v_rho_c]
  #   type = DerivativeParsedMaterial
  #   f_name = sink_v_rho_c
  #   args = 'w Dv beta Zvx rho_c'
  #   function = '-w*Dv*Zvx*rho_c/beta'
  # [../]


  #interstitial loop density diff equation
  [./rho_i_source]
    type = DerivativeParsedMaterial
    f_name = source_rho_i
    args = 'N beta w b epsi K Di Zix gamma xi Dv Zvx xv xvL'
    function = 'PI:=acos(-1);(2*PI*N*beta*w/b)*(epsi*K + (Di*Zix/gamma)*xi - (Dv*Zvx/gamma)*(xv-xvL))'
  [../]

  #vacancy loop density diff equation
  [./rho_v_source]
    type = ParsedMaterial
    f_name = source_rho_v
    args = 'w b Rv beta epsv K'
    function = '(w*beta*epsv*K)/(b*Rv)'
  [../]
  [./reaction_rho_v]
    type = DerivativeParsedMaterial
    f_name = reaction_rho_v
    args = 'w b Rv gamma Di Zix xi Dv Zvx xv xvL'
    function = '-(w/(b*Rv*gamma))*(Di*Zix*xi - Dv*Zvx*(xv-xvL))'
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
  #   args = 'w Nc lamba gamma Dv Zvx xv xvL Di Zix xi'
  #   function = 'PI:=acos(-1);(w*(4*PI*Nc*beta)*(4*PI*Nc*beta)/gamma)*(Dv*Zvx*(xv-xvL) - Di*Zix*xi)'
  # [../]

  #diffusion coefficients
  [./wDi]
    type = ParsedMaterial
    f_name = wDi
    args = 'w Di'
    function = 'w*Di'
  [../]
  [./wDv]
    type = ParsedMaterial
    f_name = wDv
    args = 'w Dv'
    function = 'w*Dv'
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
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1 # tau = t/w {s}
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
  file_base = point_defectsND_paper
  [./exodus]
    type = Exodus
    output_material_properties = 1
    execute_postprocessors_on = 'initial timestep_end'
    interval = 10000
  [../]
  csv = true
[]
