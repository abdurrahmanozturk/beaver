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
  [./ci]
    # initial_condition = 0
  [../]
  [./cv]
    # initial_condition = 0
  [../]
  [./ddi]   #interstitial loop density
  [../]
  [./ddv]   #Vacancy loop density
  [../]
  # [./ddc]   #void sink density ddc= 4piNcRc, Nc:void number density, Rc:mean void radius
  # [../]
  # [./PolycrystalVariables]
  # [../]
[]

[AuxVariables]
  # [./xi]
  # [../]
  # [./xv]
  # [../]
  [./ddn]   #network dislocation density
    initial_condition = 1e14  #for nickel
  [../]
  [./epsi]   #*interstitial cascade collapse efficiency
    initial_condition = 1
  [../]
  [./epsv]   #cascade collapse efficiency
    initial_condition = 0.05   #for nickel
  [../]
  [./cvn]
    initial_condition = 0
  [../]
  [./cvv]
    initial_condition = 0
  [../]
  [./cvi]
    initial_condition = 0
  [../]
  [./cvc]
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

##### Interstitial Concentration Differantial Equations

  [./dci_dt]
    type = TimeDerivative
    variable = ci
  [../]
  [./ci_defect_generation]
    type = MaskedBodyForce
    variable = ci
    args = epsi      # coupled on materials block
    mask = Kepsi     # K(1-epsilon_i)
  [../]
  [./ci_recombination]  # alpha(CiCv) = KivCiCv
    type = MatReaction
    variable = ci
    args = cv     #coupled on materials block
    mob_name = Kiv
  [../]
  [./ci_diffusion]
    type = MatDiffusion
    variable = ci
    D_name = Di
  [../]
  [./ci_sink_ddn]
    type = MatReaction
    variable = ci
    args = ddn     #coupled on materials block
    mob_name = DiZin
  [../]
  [./ci_sink_ddv]
    type = MatReaction
    variable = ci
    args = ddv     #coupled on materials block
    mob_name = DiZiv
  [../]
  [./ci_sink_ddi]
    type = MatReaction
    variable = ci
    args = ddi     #coupled on materials block
    mob_name = DiZii
  [../]
  # [./ci_sink_ddc]
  #   type = MatReaction
  #   variable = ci
  #   args = ddc     #coupled on materials block
  #   mob_name = DiZic
  # [../]

##### Vacancy Concentration Differantial Equations

  [./dcv_dt]
    type = TimeDerivative
    variable = cv
  [../]
  [./cv_defect_generation]
    type = MaskedBodyForce
    variable = cv
    args = epsv      # coupled on materials block
    mask = Kepsv     # K(1-epsilon_i)
  [../]
  [./cv_recombination]  # alpha(CiCv) = KivCvCv
    type = MatReaction
    variable = cv
    args = ci     #coupled on materials block
    mob_name = Kvi
  [../]
  [./cv_diffusion]
    type = MatDiffusion
    variable = cv
    D_name = Dv
  [../]
  [./cv_sink_ddn]
    type = MatReaction
    variable = cv
    args = ddn     #coupled on materials block
    mob_name = DvZvn
  [../]
  [./cv_sink_ddv]
    type = MatReaction
    variable = cv
    args = ddv     #coupled on materials block
    mob_name = DvZvv
  [../]
  [./cv_sink_ddi]
    type = MatReaction
    variable = cv
    args = ddi     #coupled on materials block
    mob_name = DvZvi
  [../]
  # [./cv_sink_ddc]
  #   type = MatReaction
  #   variable = cv
  #   args = ddc     #coupled on materials block
  #   mob_name = DvZvc
  # [../]

  # Thermally emitted vacancies
  [./cv_cvn_ddn]
    type = MaskedBodyForce
    variable = cv
    args = 'cvn ddn'     #coupled on materials block
    mask = cvnDvZvn
  [../]
  [./cv_cvv_ddv]
    type = MaskedBodyForce
    variable = cv
    args = 'cvv ddv'     #coupled on materials block
    mask = cvvDvZvv
  [../]
  [./cv_cvi_ddi]
    type = MaskedBodyForce
    variable = cv
    args = 'cvi ddi'     #coupled on materials block
    mask = cviDvZvi
  [../]
  # [./cv_cvc_ddc]
  #   type = MaskedBodyForce
  #   variable = cv
  #   args = 'cvc ddc'     #coupled on materials block
  #   mob_name = cvcDvZvc
  # [../]

  ##### Dislocation Density Equations
  # interstitial loop density
  [./dddi_dt]
    type = TimeDerivative
    variable = ddi
  [../]
  [./ddi_generation]
    type = MaskedBodyForce
    variable = ddi
    args = epsi      # coupled on materials block
    mask = 2piNbKepsi
  [../]
  [./ddi_ci]
    type = MaskedBodyForce
    variable = ddi
    args = ci      # coupled on materials block
    mask = 2piNbDiZii
  [../]
  [./ddi_cv]
    type = MaskedBodyForce
    variable = ddi
    args = cv      # coupled on materials block
    mask = 2piNbDvZvi
  [../]
  [./ddi_cvi]
    type = MaskedBodyForce
    variable = ddi
    args = cvi      # coupled on materials block
    mask = cvi2piNbDvZvi
  [../]
  # vacancy loop density
  [./dddv_dt]
    type = TimeDerivative
    variable = ddi
  [../]
  [./ddv_generation]
    type = MaskedBodyForce
    variable = ddv
    args = epsv      # coupled on materials block
    mask = brvKepsv
  [../]
  [./ddv_ci]
    type = MatReaction
    variable = ddv
    args = ci      # coupled on materials block
    mob_name = brvKDiZiv
  [../]
  [./ddv_cv]
    type = MatReaction
    variable = ddv
    args = cv      # coupled on materials block
    mob_name = brvKDvZvv
  [../]
  [./ddv_cvv]
    type = MatReaction
    variable = ddv
    args = cvv      # coupled on materials block
    mob_name = cvvbrvKDvZvv
  [../]
  ## Void sink density ddc= 4piNcRc, Nc:void number density, Rc:mean void radius
  # [./dddc_dt]
  #   type = TimeDerivative
  #   variable = ddc
  # [../]
  # [./ddc_ci]
  #   type = Kernel for A/ddc
  #   variable = ddc
  #   args = ci      # coupled on materials block
  #   mob_name = -4piNc2DiZic  #CHECK SIGN
  # [../]
  # [./ddc_cv]
  #   type = Kernel for A/ddc
  #   variable = ddv
  #   args = cv      # coupled on materials block
  #   mob_name = 4piNc2DvZvc  #CHECK SIGN
  # [../]
  # [./ddc_cvc]
  #   type = Kernel for A/ddc
  #   variable = ddv
  #   args = cvc      # coupled on materials block
  #   mob_name = -brvKDvZvc  #CHECK SIGN
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
  # [./xi]
  #   type = ParsedAux
  #   variable = xi
  #   args = ci
  #   function = 'kiv:=1;k:=1e-6;ci*sqrt(kiv/k)'
  # [../]
  # [./xv]
  #   type = ParsedAux
  #   variable = xv
  #   args = cv
  #   function = 'kiv:=1;k:=1e-6;cv*sqrt(kiv/k)'
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
  # [./Periodic]
  #   [./All]
  #     variable = 'eta0 eta1 eta2'
  #     # edited to auto_direction = y
  #     auto_direction = 'y'
  #   [../]
  # [../]
[]

[Materials]
 [./D]
   type = GenericConstantMaterial # diffusion coeficients
   prop_names = 'Di Dv'
   prop_values = '1.854e-9 1.876e-12' # cm2/sec      regular case
   block = '0'
 [../]
 [./Kiv]
   type = DerivativeParsedMaterial
   f_name = Kiv
   args = cv
   function = 'kiv:=1e-9;-kiv*cv'  # 1/s regular case
 [../]
 [./Kvi]
   type = DerivativeParsedMaterial
   f_name = Kvi
   args = ci
   function = 'kiv:=1e-9;-kiv*ci'  # 1/s regular case
 [../]
 ##############
 [./Kepsi]
   type = ParsedMaterial
   f_name = Kepsi
   args = epsi
   function = 'K:=1e-5;K*(1-epsi)' # 1/s      regular case
 [../]
 [./DiZin]
   type = DerivativeParsedMaterial
   f_name = DiZin
   args = ddn
   function = 'Di:=1.854e-9;B:=0.1;Zin:=1+B;-Di*Zin*ddn' # 1/s      regular case
 [../]
 [./DiZiv]
   type = DerivativeParsedMaterial
   f_name = DiZiv
   args = ddv
   function = 'Di:=1.854e-9;B:=0.1;Ziv:=1+B;-Di*Ziv*ddv' # 1/s      regular case
 [../]
 [./DiZii]
   type = DerivativeParsedMaterial
   f_name = DiZii
   args = ddi
   function = 'Di:=1.854e-9;B:=0.1;Zii:=1+B;-Di*Zii*ddi' # 1/s      regular case
 [../]
 # [./DiZic]
 #   type = DerivativeParsedMaterial
 #   f_name = DiZic
 #   args = ddc
 #   function = 'Di:=1.854e-9;B:=0;Zic:=1+B;-Di*Zic*ddc' # 1/s      regular case
 # [../]
 ##############
 [./Kepsv]
   type = ParsedMaterial
   f_name = Kepsv
   args = epsv
   function = 'K:=1e-5;K*(1-epsv)' # 1/s      regular case
 [../]
 [./DvZvn]
   type = DerivativeParsedMaterial
   f_name = DvZvn
   args = ddn
   function = 'Dv:=1.876e-12;B:=0;Zvn:=1+B;-Dv*Zvn*ddn' # 1/s      regular case
 [../]
 [./cvnDvZvn]
   type = DerivativeParsedMaterial
   f_name = cvnDvZvn
   args = 'cvn ddn'
   function = 'Dv:=1.876e-12;B:=0;Zvn:=1+B;Dv*Zvn*cvn*ddn' # 1/s      regular case
 [../]
 [./DvZvv]
   type = DerivativeParsedMaterial
   f_name = DvZvv
   args = ddv
   function = 'Dv:=1.876e-12;B:=0;Zvv:=1+B;Dv*Zvv*ddv' # 1/s      regular case
 [../]
 [./cvvDvZvv]
   type = DerivativeParsedMaterial
   f_name = cvvDvZvv
   args = 'cvv ddv'
   function = 'Dv:=1.876e-12;B:=0;Zvv:=1+B;Dv*Zvv*cvv*ddv' # 1/s      regular case
 [../]
 [./DvZvi]
   type = DerivativeParsedMaterial
   f_name = DvZvi
   args = ddi
   function = 'Dv:=1.876e-12;B:=0;Zvi:=1+B;Dv*Zvi*ddi' # 1/s      regular case
 [../]
 [./cviDvZvi]
   type = DerivativeParsedMaterial
   f_name = cviDvZvi
   args = 'cvi ddi'
   function = 'Dv:=1.876e-12;B:=0;Zvi:=1+B;Dv*Zvi*cvi*ddi' # 1/s      regular case
 [../]
 # [./DvZvc]
 #   type = DerivativeParsedMaterial
 #   f_name = DvZvc
 #   args = ddc
 #   function = 'Dv:=1.876e-12;B:=0;Zvc:=1+B;Dv*Zvc*ddc'
 # [../]
 # [./cvcDvZvc]
 #   type = DerivativeParsedMaterial
 #   f_name = cvcDvZvc
 #   args = 'cvc ddc'
 #   function = 'Dv:=1e-5;B:=0;Zvc:=1+B;Dv*Zvc*cvc*ddc'
 # [../]
 ##############
 [./2piNbKepsi]
   type = ParsedMaterial
   f_name = 2piNbKepsi
   args = epsi
   function = 'pi:=acos(-1);N:=1e21;b:=2.5e-10;K:=1e-5;(K*2*pi*N/b)*epsi'
 [../]
 [./2piNbDiZii]
   type = ParsedMaterial
   f_name = 2piNbDiZii
   args = ci
   function = 'pi:=acos(-1);N:=1e21;b:=2.5e-10;Di:=1.854e-9;B:=0.1;Zii:=1+B;2*pi*N*b*Di*Zii*ci'
 [../]
 [./2piNbDvZvi]
   type = ParsedMaterial
   f_name = 2piNbDvZvi
   args = cv
   function = 'pi:=acos(-1);N:=1e21;b:=2.5e-10;Dv:=1.876e-12;B:=0;Zvi:=1+B;-2*pi*N*b*Dv*Zvi*cv'
 [../]
 [./cvi2piNbDvZvi]
   type = ParsedMaterial
   f_name = cvi2piNbDvZvi
   args = cvi
   function = 'pi:=acos(-1);N:=1e21;b:=2.5e-10;Dv:=1.876e-12;B:=0;Zvi:=1+B;2*pi*N*b*Dv*Zvi*cvi'
 [../]
 [./brvKepsv]
   type = ParsedMaterial
   f_name = brvKepsv
   args = epsv
   function = 'b:=2.5e-10;rv:=1.5e-9;K:=1e-5;K*epsv/(b*rv)'
 [../]
 [./brvKDiZiv]
   type = DerivativeParsedMaterial
   f_name = brvKDiZiv
   args = ci
   function = 'b:=2.5e-10;rv:=1.5e-9;Di:=1.854e-9;B:=0.1;Ziv:=1+B;-Di*Ziv*ci/(b*rv)'
 [../]
 [./brvKDvZvv]
   type = DerivativeParsedMaterial
   f_name = brvKDvZvv
   args = cv
   function = 'b:=2.5e-10;rv:=1.5e-9;Dv:=1.876e-12;B:=0.1;Zvv:=1+B;Dv*Zvv*cv/(b*rv)'
 [../]
 [./cvvbrvKDvZvv]
   type = DerivativeParsedMaterial
   f_name = cvvbrvKDvZvv
   args = cvv
   function = 'b:=2.5e-10;rv:=1.5e-9;Dv:=1.876e-12;B:=0.1;Zvv:=1+B;-Dv*Zvv*cvv/(b*rv)'
 [../]
##############
# [./brvKDvZvi]
#   type = DerivativeParsedMaterial
#   f_name = brvKDvZvi
#   args = ci
#   function = 'pi:=acos(-1);Nc:=???;Di:=1e-5;B:=0.1;Zic:=1+B;-((4*pi*Nc)*(4*pi*Nc))*Di*Zic*ci' #CHECK SIGN
# [../]
# [./brvKDvZvc]
#   type = DerivativeParsedMaterial
#   f_name = brvKDvZvc
#   args = cv
#   function = 'pi:=acos(-1);Nc:=???;Dv:=1e-5;B:=0;Zvc:=1+B;((4*pi*Nc)*(4*pi*Nc))*Dv*Zvc*cv' #CHECK SIGN
# [../]
#  [./cvcbrvKDvZvc]
#    type = DerivativeParsedMaterial
#    f_name = cvcbrvKDvZvc
#    args = cvc
#    function = 'pi:=acos(-1);Nc:=???;Dv:=1e-5;B:=0;Zvc:=1+B;-((4*pi*Nc)*(4*pi*Nc))*Dv*Zvc*cvc' #CHECK SIGN
#  [../]

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
  #   args = 'ci cv'
  #   function = 'Di:=1e-15;Dv:=1e-15;(Dv*cv-Di*ci)'#/(ci+cv)  ## steady state condition relation
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
  [./ci]
    type = ElementIntegralVariablePostprocessor
    variable = ci
  [../]
  [./cv]
    type = ElementIntegralVariablePostprocessor
    variable = cv
  [../]
  [./ddi]
    type = ElementIntegralVariablePostprocessor
    variable = ddi
  [../]
  [./ddv]
    type = ElementIntegralVariablePostprocessor
    variable = ddv
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
    dt = 1e-8 #s
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
  file_base = point_defects_paper
  [./exodus]
    type = Exodus
    output_material_properties = 1
    output_postprocessors = true
    interval = 10000
  [../]
  csv = true
[]
