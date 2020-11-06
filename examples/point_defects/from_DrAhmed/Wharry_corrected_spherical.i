## l_scale = 1e-9 m
# the concentrations of interstitials and vacancies were fixed at their thermal equilibrium values

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1000
  #ny = 64
  #nz = 0
  xmax = 1000
  #ymax = 256
[]

[Problem]
  coord_type = RSPHERICAL
[]

[Variables]
  [./Xv]
  [../]
  [./Xi]
  [../]
  [./X_cr] #A
  [../]
#  [./X_fe] #B
#  [../]
[]

[AuxVariables]
  # [./dcfedx]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./dccrdx]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./dcvdx]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./dcidx]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./jcrx]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./jfex]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./jvx]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./jix]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]

 #T = 823 K values
  [./dcri]
    initial_condition = 1.9241531397555732e-09
  [../]
  [./dfei]
    initial_condition = 7.170779111319062e-10
  [../]
  [./dcrv]
    initial_condition = 1.3671127082368977e-09
  [../]
  [./dfev]
    initial_condition = 3.1653391669259404e-10
  [../]
[]


[AuxKernels]

#  [./dcfedx]
#    type = VariableGradientComponent
#    variable = dcfedx
#    gradient_variable = X_fe
#    component = x
#  [../]
#   [./dccrdx]
#     type = VariableGradientComponent
#     variable = dccrdx
#     gradient_variable = X_cr
#     component = x
#   [../]
#   [./dcvdx]
#     type = VariableGradientComponent
#     variable = dcvdx
#     gradient_variable = Xv
#     component = x
#   [../]
#   [./dcidx]
#     type = VariableGradientComponent
#     variable = dcidx
#     gradient_variable = Xi
#     component = x
#   [../]
#   [./jfex]
#     type = ParsedAux
#     variable = jfex
#     args = 'dcfedx'
#     function = '-1.0*dcfedx'
#   [../]
#   [./jcrx]
#     type = ParsedAux
#     variable = jcrx
#     args = 'dccrdx'
#     function = '-1.0*dccrdx'
#   [../]
#   [./jvx]
#     type = ParsedAux
#     variable = jvx
#     args = 'dcvdx'
#     function = '-1.0*dcvdx'
#   [../]
#   [./jix]
#     type = ParsedAux
#     variable = jix
#     args = 'dcidx'
#     function = '-1.0*dcidx'
#   [../]
 []

[ICs]
  [./Xv] # Concentration of vacancy
    type = RandomIC
    variable = Xv
    min = 4.22e-10
    max = 4.42e-10
    seed = 11
[../]

[./Xi] # Concentration of interstials
  type = RandomIC
  variable = Xi
  min = 2.40e-31
  max = 2.42e-31
  seed = 11
[../]

[./X_cr] # Concentration of Cr
  type = ConstantIC
   value = 0.090
  variable = X_cr
  #min = 0.08
  #max = 0.1
  #seed = 11
[../]

[]

[BCs]

# BCs at surface
  [./Xv]
  type = DirichletBC
  variable = 'Xv'
  boundary = 'right'
  value = 4.3256151210346623e-10
  [../]

  [./Xi]
  type = DirichletBC
  variable = 'Xi'
  boundary = 'right'
  value = 2.4014820928976054e-31
  [../]

  # zero flux at the grain center (left boundary)

[]

[Kernels]

                            #### Xv_equation ###

  [./Xv_dot]
   type = TimeDerivative
    variable = 'Xv'
  [../]

  [./Xv_dcrv_dfev]
    type = MatDiffusion
    variable = Xv
    D_name = dcrv_dfev
    v = X_cr
    args = Xv
  [../]

  [./Xv_Dv]
    type = MatDiffusion
    variable = Xv
    D_name = Xv_Dv
    args = 'X_cr'
  [../]

  [./Xv_source_K0]
      type = MaskedBodyForce
      variable = Xv
      mask = Xv_source_K0
      args = ' '
  [../]

  [./Xv_KivXiXv]
      type = MatReaction
      variable = Xv
      mob_name = Xv_KivXiXv
      args = 'Xi X_cr'
  [../]

                          ###   Xi_equation  ####

  [./Xi_dot]
    type = TimeDerivative
    variable = 'Xi'
  [../]

  [./Xi_dcri_dfei]
    type = MatDiffusion
    variable = Xi
    D_name = dcri_dfei
    v = X_cr
    args = Xi
  [../]

  [./Xi_Di]
    type = MatDiffusion
    variable = Xi
    D_name = Xi_Di
    args = 'X_cr'
  [../]

  [./Xi_source_K0]
    type = MaskedBodyForce
    variable = Xi
    mask = Xi_source_K0
    args = ' '
  [../]

  [./Xi_KivXiXv]
        type = MatReaction
        variable = Xi
        mob_name = Xi_KivXiXv
        args = 'Xv X_cr'
  [../]

                        #### X_Cr_equation  ####

  [./X_cr_dot]
    type = TimeDerivative
    variable = 'X_cr'
  [../]

  [./X_cr_Dcr]
    type = MatDiffusion
    variable = X_cr
    D_name = X_cr_Dcr
    args = 'Xv Xi'
  [../]

  [./X_cr_dcri]
    type = MatDiffusion
    variable = X_cr
    D_name = dcri_bar
    v = Xi
    args = X_cr
  [../]

  [./X_cr_dcrv]
    type = MatDiffusion
    variable = X_cr
    D_name = dcrv_bar
    v = Xv
    args = X_cr
  [../]

[]

[Materials]

                          ##### Xv_equation_material###

        [./Xv_dcrv_dfev]
          type = DerivativeParsedMaterial
          constant_names = 'chi' #chi: thermodynamic_factor (unitless) # Di = (dcri-dfei)*X_cr+dfei
          constant_expressions = '1'
          f_name = dcrv_dfev
          function = -(chi)*Xv*(dcrv-dfev)/(dcri)
          args = 'Xv dcrv dcri dfev'
        [../]

        [./Xv_Dv]
          type = DerivativeParsedMaterial
          f_name = Xv_Dv
          function = (((dcrv-dfev)*X_cr+dfev)/dcri)
          args = 'X_cr dcrv dcri dfev'
        [../]

        [./Xv_source_K0]
          type = DerivativeParsedMaterial
          constant_names = 'K0 l_scale' # Di = (dcri-dfei)*X_cr+dfei
          constant_expressions = '1.05e-3 1e-9'
          # you can try production bias (K0_Xv=1.05*K0_Xi)
          f_name = Xv_source_K0
          function = K0*((l_scale*l_scale)/dcri)
          args = 'dcri'
        [../]

        [./Xv_KivXiXv]
          type = DerivativeParsedMaterial
          constant_names = 'l_scale omega'
          constant_expressions = '1e-9 1.212683025575e-29' #4.52633e-29
          f_name = Xv_KivXiXv
          function = -4*3.14*(1e-9)*(((dcri-dfei)*X_cr+dfei)+((dcrv-dfev)*X_cr+dfev))*((l_scale*l_scale)/(dcri*omega))*Xi
          args = 'Xi X_cr dcri dfei dfev dcrv'
        [../]

                          ###  Xi_equation_material #####

        [./Xi_dcri_dfei]
          type = DerivativeParsedMaterial
          constant_names = 'chi omega'
          constant_expressions = '1 1.212683025575e-29'
          f_name = dcri_dfei
          function = chi*Xi*(dcri-dfei)/dcri
          args = 'Xi dcri dfei'
        [../]

        [./Xi_Di]
          type = DerivativeParsedMaterial
          #constant_names = 'l_scale'
          #constant_expressions = '1e-10 '
          f_name = Xi_Di
          function = (((dcri-dfei)*X_cr+dfei)/dcri)
          args = 'X_cr dcri dfei'
        [../]

        [./Xi_source_K0]
          type = DerivativeParsedMaterial
          constant_names = 'K0 l_scale '
          constant_expressions = '1.0e-3 1e-9'
          f_name = Xi_source_K0
          function = K0*((l_scale*l_scale)/dcri)
          args = 'dcri'
        [../]

        [./Xi_KivXiXv]
          type = DerivativeParsedMaterial
          constant_names = 'l_scale omega '
          constant_expressions = ' 1e-9 1.212683025575e-29'
          f_name = Xi_KivXiXv
          function = -4*3.14*(1e-9)*(((dcri-dfei)*X_cr+dfei)+((dcrv-dfev)*X_cr+dfev))*((l_scale*l_scale)/(dcri*omega))*Xv
          args = 'Xv X_cr dcri dfei dcrv dfev'
        [../]

                            #### X_Cr_equation_material  ####
       [./X_cr_Dcr]
          type = DerivativeParsedMaterial
          constant_names = 'chi' # Dcr = (dcrv*Xv+dcri*Xi)
          constant_expressions = '1'
          f_name = X_cr_Dcr
          function = chi*(dcrv*Xv+dcri*Xi)/dcri
          args = 'dcri dcrv Xi Xv'
       [../]

       [./X_cr_dcri]
         type = DerivativeParsedMaterial
         f_name = dcri_bar
         function = X_cr*dcri/dcri
         args = 'X_cr dcri'
       [../]

       [./X_cr_dcrv]
         type = DerivativeParsedMaterial
         f_name = dcrv_bar
         function = -X_cr*dcrv/dcri
         args = 'X_cr dcri dcrv'
       [../]


[]

[Postprocessors]

        [./average_Xi]
          type = ElementAverageValue
          variable = Xi
        [../]
        [./average_Xv]
          type = ElementAverageValue
          variable = Xv
        [../]
        [./average_X_cr]
          type = ElementAverageValue
          variable = X_cr
        [../]

        [./left_X_cr]
          type = PointValue
          point = '0.0 0.0 0.0'
          variable = X_cr
        [../]
        [./right_X_cr]
          type = PointValue
          point = '1000 0.0 0.0'
          variable = X_cr
        [../]

        [./left_X_i]
          type = PointValue
          point = '0.0 0.0 0.0'
          variable = Xi
        [../]
        [./right_X_i]
          type = PointValue
          point = '1000 0.0 0.0'
          variable = Xi
        [../]
        [./left_X_v]
          type = PointValue
          point = '0.0 0.0 0.0'
          variable = Xv
        [../]
        [./right_X_v]
          type = PointValue
          point = '1000 0.0 0.0'
          variable = Xv
        [../]

[]

[VectorPostprocessors]
        [./x_direc]
         type =  LineValueSampler
          start_point = '0 0 0'
          end_point = '1000 0 0'
          variable = 'X_cr Xv Xi' # jvx jix jfex jcrx'
          num_points = 1001
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
         scheme = BDF2
         #scheme = crank-nicolson
        type = Transient
        nl_max_its = 15
        solve_type = NEWTON
      #  petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_tol -pc_hypre_boomeramg_max_iter'
      #  petsc_options_value = 'hypre boomeramg 1e-4 20'
         petsc_options_iname = '-pc_type'
         petsc_options_value = 'lu'

        l_max_its = 15 #max linear iterations default 10000
        l_tol = 1.0e-3 #linear tolerance
        nl_rel_tol = 1.0e-5 #nonlinear relative tolerance default 1e-8
        start_time = 0.0
        nl_abs_tol = 1e-16
        num_steps = 150000
        steady_state_detection = true
         steady_state_tolerance = 1e-16
        [./TimeStepper]
          type = IterationAdaptiveDT
          cutback_factor = .75
          dt = 1.0
          growth_factor = 1.2
          optimal_iterations = 7
        [../]
[]
[Outputs]
        csv = true
        exodus = true
        interval = 1
[]
