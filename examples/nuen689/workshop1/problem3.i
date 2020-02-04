# Solution of nonlinear diffusion Eqn in 1D
# DerivativeParsedMaterial is used to automatically get the required derivative to set up the Jacobian

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 500
  ny = 0
  nz = 0
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 0
  zmin = 0
  zmax = 0
  elem_type = EDGE
[]

[Variables]
  [./T]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables] # auxiliary varaibles that do not appear directly in the PDE

 # this is just to visualize the thermal conductivity of material over the domain
  [./mat_therm_cond]
    order = CONSTANT
    family = MONOMIAL
  [../]

  # the temperature gradient
  [./dTdx]
    order = CONSTANT
    family = MONOMIAL
  [../]

  # the heat flux
  [./jx]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]
[AuxKernels] # the kernels that evaluate the values of the auxvariables
  [./mat_therm_cond]
    type = MaterialRealAux
    variable = mat_therm_cond
    property = k
  [../]
  [./dTdx]
    type = VariableGradientComponent
    variable = dTdx
    gradient_variable = T
    component = x
  [../]
  [./jx]
    type = ParsedAux
    variable = jx
    args = 'mat_therm_cond dTdx'
    function = '-mat_therm_cond*dTdx'
  [../]

[]

[Kernels] # the terms that appear in the PDE
  [./symbolic_diffusion_kernel]
    type = MatDiffusion   # evaluate the divergence of a flux
    variable = T
    D_name = k # change to Diffusivity = k
    # the thermal_conductivity/ diffusion_coefficient and their derivatives
    # can be symbolically evaluated form a DerivativeParsedMaterial
    # to be defined under the Materials block
  [../]
[]

[BCs]
  [./T_left]
    type = DirichletBC
    variable = 'T'
    boundary = 'left'
    value = 1.0
  [../]
  [./T_right]
    type = DirichletBC
    variable = 'T'
    boundary = 'right'
    value = 2.0
  [../]
[]

[Postprocessors]
  [./jx_r]
    type = SideAverageValue
    variable = jx
    boundary = right
  [../]
  [./jx_l]
    type = SideAverageValue
    variable = jx
    boundary = left
  [../]
  [./nonlinear_iterations]  # Number of nonlinear iterations
    type =  NumNonlinearIterations
  [../]
  [./linear_iterations]  # Number of linear iterations
    type =  NumLinearIterations
  [../]
  [./active_time]  # Time computer spent on simulation (in seconds)
    type = PerformanceData
    event =  ALIVE
  [../]
  [./Memory]
    type = MemoryUsage
    mem_type = physical_memory
    value_type = total
    # by default MemoryUsage reports the peak value for the current timestep
    # out of all samples that have been taken (at linear and non-linear iterations)
  [../]

[]

[VectorPostprocessors]
  [./line_values]
   type =  LineValueSampler
    start_point = '0 0 0'
    end_point = '1 0 0'
    variable = 'T jx dTdx mat_therm_cond'
    num_points = 501
    sort_by =  id
  [../]
[]

[Executioner]
  type =  Steady
  solve_type = 'PJFNK'
  # try both PJFNK and NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  l_max_its = 25
  nl_max_its = 150
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-6
  nl_abs_tol = 1e-8
[]

[Materials]
  [./thermal_conductivity] # thermal_conductivity
    type = DerivativeParsedMaterial
    f_name = k
    # function = 'a:=1.0;b:=10.0;n:=1;1.0/(a+b*T^n)'
    function = 'a:=1.0;b:=10.0;n:=10;a+b*T^n'
    args = 'T' # arguments (the variables that k depends on)
    derivative_order = 0
    # this kernel will auotmatically generate a symbolic derivative (exact!)
    # of k w.r.t T to fill out the Jacobian Matrix
    # if derivative_order = 0, Jacobain entries will be zero
  [../]
[]

[Outputs]
  file_base = problem3_pfjnk_do=0_k1_n=10
  # you should change the file name for each run,
  # otherwise old data will be overwritten
  exodus = true
  csv = true
[]
