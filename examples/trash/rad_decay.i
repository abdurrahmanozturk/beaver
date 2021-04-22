[Mesh]
  type = GeneratedMesh
  nx = 10
  ny = 10
  dim = 2
[]
[Variables]
  [./n]
    initial_condition = 1
  [../]
[]
[Kernels]
  [./timederivative]
    type = TimeDerivative
    variable = n
  [../]
  [./body_force]
    type = MaskedBodyForce
    variable = n
    mask = lambda
    args = n
  [../]
[]
[Materials]
  [./lambda]
    type = ParsedMaterial
    f_name = lambda
    args = n
    constant_names = 't12'
    constant_expressions = '10'
    function = '-(log(2)/t12)*n'
  [../]
[]
[Postprocessors]
  [./mass]
    type = ElementAverageValue
    variable = n
  [../]
[]
[Executioner]
  type = Transient
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  dt = 0.1
  steady_state_detection = true
[]
[Outputs]
  exodus = true
  csv = true
[]
