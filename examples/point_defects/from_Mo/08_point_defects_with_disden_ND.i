
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 256
  ny = 32
  nz = 0
  xmax = 256
  ymax = 32
  elem_type = QUAD4
  #parallel_type = DISTRIBUTED
[]

[Variables]
  [./xi]  # non-dimensionalized Interstitial Concentration
  [../]
  [./xv]   # non-dimensionalized Vacancy Concentration
  [../]
  [./rho_i]   #non-dimensionalized interstitial loop density, rho_i=ddi/ddn
  [../]
[]

[AuxVariables]
  ##--- Non-dimensionalization scaling parameters ---
  ##  l : length scale
  ##  w : time scale
  ##  alpha : recombination rate
  ##  x   = gamma*c
  # Using Ni model parameters
  # At T = 773K(500C), D_i = 1e-9 m^2/s, D_v = 2e-13 m^2/s
  # c_v_eq = 3.7e-11
  # length_scale = 1e-7 m , time_scale = 1e-5 s
  # r = cpature_readius = 10*a, a = lattice parameter = 0.352nm
  # omega = atomic_volume = 1.2*10^-29 m^3



# fluxes added to compare between periodic BCs and Zero Dirchilet (representing a perfect sink such as GB)
    [./ux]
      order = CONSTANT
      family = MONOMIAL
    [../]
    [./vx]
      order = CONSTANT
      family = MONOMIAL
    [../]
    [./uy]
      order = CONSTANT
      family = MONOMIAL
    [../]
    [./vy]
      order = CONSTANT
      family = MONOMIAL
    [../]
    [./jx]
      order = CONSTANT
      family = MONOMIAL
    [../]
    [./jy]
      order = CONSTANT
      family = MONOMIAL
    [../]
    [./qx]
      order = CONSTANT
      family = MONOMIAL
    [../]
    [./qy]
      order = CONSTANT
      family = MONOMIAL
    [../]

[]

[ICs]

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
    min = 1e-17
    max = 3e-17
    seed = 11
  [../]
  [./rho_i]
    type = RandomIC
    variable = 'rho_i'
    min = 1e-3
    max = 3e-3
    seed = 10
  [../]

[]

[BCs]  # domain boundaries are perfect unbiased sinks (such as void surfaces or GBs)
  [./cv]
    type = DirichletBC
    variable = xv
    boundary = 'left right top bottom'
    value = 3.7e-11  # EQ Value at 500C
  [../]
  [./ci]
    type = DirichletBC
    variable = xi
    boundary = 'left right top bottom'
    value = 0
  [../]
[]


[Kernels]

  ##### Interstitial Concentration Differantial Equation

    [./xi_dot]
      type = TimeDerivative
      variable = 'xi'
    [../]

    [./xi_source]
      type = BodyForce
      # please Note that, "MaskedBodyForce" kernel is used here in order to be linked with the material block
      # comparing with "BodyForce" it is not linked to the material block
      #args = ' constants that used to describe the function'      # coupled on materials block, these parameters are forming their relation in "source_i", which can be found in material block
      #mask = source_i
      variable = xi
      value = 1.0e-8  # value of "source_i" from the Excel file (K(1-epsi)*w) #edited1
    [../]

    [./xi_recombination]
      type = MatReaction #please note that the "MatReaction" formulation is simply equal to "mob_name*variable", that why in material block you will find the description of mob_name.
      #compare the "MatReaction" with the "Reaction" Kernels, the Coefficient for "reaction" kernel could be constant, but for "MatReaction" kernel can be material property or Function.
      variable = xi
      args = 'xv'   # coupled on materials block
      mob_name = reaction_iv
    [../]


    [./xi_diffusion]
      type = MatDiffusion
      variable = xi
      D_name = omega_w_Di
    [../]

    [./xi_sink]
      type = MatReaction
      variable = xi
      args = 'rho_i'     #coupled on materials block
      mob_name = sink_i
    [../]


  ##### Vacancy Concentration Differantial Equation

  [./xv_dot]
    type = TimeDerivative
    variable = 'xv'
  [../]

  [./xv_source]
    type = BodyForce
    # please Note that, "MaskedBodyForce" kernel is used here in order to be linked with the material block
    # comparing with "BodyForce" it is not linked to the material block
    #args = ' constants that used to describe the function'      # coupled on materials block, these parameters are forming their relation in "source_i", which can be found in material block
    #mask = source_i
    variable = xv
    value = 1.1e-8  # value of "source_v" from the Excel file
  [../]

  [./xv_recombination]
    type = MatReaction #please note that the "MatReaction" formulation is simply equal to "mob_name*variable", that why in material block you will find the description of mob_name.
    #compare the "MatReaction" with the "Reaction" Kernels, the Coefficient for "reaction" kernel could be constant, but for "MatReaction" kernel can be material property or Function.
    variable = xv
    args = 'xi'   # coupled on materials block
    mob_name = reaction_vi
  [../]


  [./xv_diffusion]
    type = MatDiffusion
    variable = xv
    D_name = omega_w_Dv
  [../]

  [./xv_sink]
    type = MatReaction
    variable = xv
    args = 'rho_i'     #coupled on materials block
    mob_name = sink_v
  [../]

##### Dislocation Density Differantial Equation

# interstitial loop density

[./rho_i_dot]
  type = TimeDerivative
  variable = rho_i
[../]

[./rho_i_source]
  type = MaskedBodyForce
  variable = rho_i
  args = 'xi xv'     # coupled on materials block
  mask = rho_i_evolution
[../]


[]



[Materials]

  #interstitial Concentration diff equation
  [./reaction_iv]
    type = DerivativeParsedMaterial
    f_name = reaction_iv
    constant_names = 'l omega b w Di Dv K r Zix Zvx epsi epsv N'
    constant_expressions = '1e-8 1.2e-29 2.5e-10 1e-5 1e-9 1e-13 1e-3 3.52e-9 1 1 0.01 0.1 1e21'
    args = 'xv'
    function = '-(((4*3.14*r*Di)*w)/omega)*xv'
    #note that apha_i = 4*pi*r*Di
  [../]


  [./omega_w_Di]
    type = ParsedMaterial
    f_name = omega_w_Di
    constant_names = 'l omega b w Di Dv K r Zix Zvx epsi epsv N'
    constant_expressions = '1e-8 1.2e-29 2.5e-10 1e-5 1e-9 1e-13 1e-3 3.52e-9 1 1 0.01 0.1 1e21'
    function = 'w*Di'
  [../]

  [./sink_i]
    type = DerivativeParsedMaterial
    f_name = sink_i
    args = 'rho_i'
    function = '-(w*Di*Zix)*(rho_i)'
    constant_names = 'l omega b w Di Dv K r Zix Zvx epsi epsv N'
    constant_expressions = '1e-8 1.2e-29 2.5e-10 1e-5 1e-9 1e-13 1e-3 3.52e-9 1 1 0.01 0.1 1e21'
  [../]


  #vacancy Concentration diff equation

  [./reaction_vi]
    type = DerivativeParsedMaterial
    f_name = reaction_vi
    args = 'xi'
    constant_names = 'l omega b w Di Dv K r Zix Zvx epsi epsv N'
    constant_expressions = '1e-8 1.2e-29 2.5e-10 1e-5 1e-9 1e-13 1e-3 3.52e-9 1 1 0.01 0.1 1e21'
    function = '-(((4*3.14*r*Dv)*w)/omega)*xi'
  [../]

  [./omega_w_Dv]
    type = ParsedMaterial
    f_name = omega_w_Dv
    constant_names = 'l omega b w Di Dv K r Zix Zvx epsi epsv N'
    constant_expressions = '1e-8 1.2e-29 2.5e-10 1e-5 1e-9 1e-13 1e-3 3.52e-9 1 1 0.01 0.1 1e21'
    function = 'w*Dv'
  [../]

  [./sink_v]
    type = DerivativeParsedMaterial
    f_name = sink_v
    args = 'rho_i'
    constant_names = 'l omega b w Di Dv K r Zix Zvx epsi epsv N'
    constant_expressions = '1e-8 1.2e-29 2.5e-10 1e-5 1e-9 1e-13 1e-3 3.52e-9 1 1 0.01 0.1 1e21'
    function = '-(w*Dv*Zvx)*(rho_i)'
  [../]



  #interstitial loop density diff equation
  [./rho_i_evolution]
    type = DerivativeParsedMaterial
    f_name = rho_i_evolution
    args = 'xi xv'
    constant_names = 'l omega b w Di Dv K r Zix Zvx epsi epsv N'
    constant_expressions = '1e-8 1.2e-29 2.5e-10 1e-5 1e-9 1e-13 1e-3 3.52e-9 1 1 0.01 0.1 1e21'
    function = '((((2*3.14*N*l*l*w)/b))*((epsi*K*0)+((Di*Zix)*xi)-((Dv*Zvx)*xv)))' # by myltiplying by zero , we truned off the effect of the term epsi*k
  [../]

[]

[Postprocessors]

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

[]

[VectorPostprocessors]
  [./x_direc]
   type =  LineValueSampler
    start_point = '0 16 0'
    end_point = '256 16 0'
    variable = 'xv xi rho_i'
    num_points = 257
    sort_by =  id
  [../]

  [./y_direc]
   type =  LineValueSampler
    start_point = '128 0 0'
    end_point = '128 32 0'
    variable = 'xv xi rho_i'
    num_points = 33
    sort_by =  id
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
  nl_max_its = 10
  solve_type = NEWTON
   petsc_options_iname = '-pc_type -sub_pc_type'
   petsc_options_value = 'asm lu'
  l_max_its = 20
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-6
  start_time = 0.0
  num_steps = 150000
  steady_state_detection = true
  steady_state_tolerance = 1.0e-9

  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = .75
    dt = 1.0 # time_scale = 1e-5 s
    growth_factor = 1.2
    optimal_iterations = 7
  [../]

  [./Adaptivity]
      refine_fraction = 0.5
      coarsen_fraction = 0.05
      max_h_level = 2
     initial_adaptivity = 2
    [../]
[]


[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  exodus = true
  csv = true
  interval = 1
  # physical_time = simulation_time*time_scale(1e-5 s)

[]
