# solves Heat/Fiffusion Eqn in 2D with anisotropic conductivity/diffusivity tensor

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 128
  ny = 128
  nz = 0
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  elem_type = QUAD4
[]

[Variables]
  [./T]
  [../]
[]

[AuxVariables] # auxiliary varaibles that do not appear directly in the PDE

  # the temperature gradient
  [./dTdx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./dTdy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  # conductivity tensor components
  [./k_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./k_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./k_xy]
    order = CONSTANT
    family = MONOMIAL
  [../]

  # the heat flux
  [./jx]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./jy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]
[AuxKernels] # the kernels that evaluate the values of the auxvariables
  [./dTdx]
    type = VariableGradientComponent
    variable = dTdx
    gradient_variable = T
    component = x
  [../]
  [./dTdy]
    type = VariableGradientComponent
    variable = dTdy
    gradient_variable = T
    component = y
  [../]
  [./k_xx]
    type = MaterialRealTensorValueAux
      property = k
       column = 0
       row = 0
      variable = k_xx
  [../]
  [./k_yy]
    type = MaterialRealTensorValueAux
      property = k
       column = 1
       row = 1
      variable = k_yy
  [../]
  [./k_xy]
    type = MaterialRealTensorValueAux
      property = k
       column = 1
       row = 0
    variable = k_xy
  [../]
  [./jx]
    type = ParsedAux
    variable = jx
    args = 'k_xx k_xy dTdx dTdy'
    function = '-(k_xx*dTdx+k_xy*dTdy)'
  [../]
  [./jy]
    type = ParsedAux
    variable = jy
    args = 'k_yy k_xy dTdx dTdy'
    function = '-(k_yy*dTdy+k_xy*dTdx)'
  [../]

[]

[Kernels]
  [./heat_diffusion] # with anisotropic conductivity/diffusivity tensor
    type = MatAnisoDiffusion
    D_name = k
    variable = T
  [../]

[]

[Materials]
  [./k] # anisotropic conductivity/diffusivity tensor
    type = ConstantAnisotropicMobility
    tensor = '1.0  0.90 0.0
              0.90 1.0 0.0
              0.0  0.0 0.0'
    M_name = k
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

[]

[VectorPostprocessors]
  [./line_values]
   type =  LineValueSampler
    start_point = '0 0.5 0'
    end_point = '1 0.5 0'
    variable = 'T dTdx dTdy jx jy'
    num_points = 101
    sort_by =  id
  [../]
[]
[Executioner]
  type = Steady
  solve_type = 'LINEAR'
  line_search = none
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  l_max_its = 100
  l_tol = 1.0e-6
[]

[Outputs]
  file_base = 2D_aniso_linear_heat_conduction
  exodus = true
  csv = true
[]
