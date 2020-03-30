# Camila Freitas Matozinhos
# Gabriel Caio Queiroz Tomaz

# NUEN 689 - Final Project - 05/02/2019

# Reference - http://www.featflow.de/en/benchmarks/cfdbenchmarking/flow/dfg_benchmark1_re20.html

# This input file was based on the examples
# - lid_driven.i
# - velocity_channel.i
# - stagnation.i

[GlobalParams]
  gravity = '0 0 0'
  integrate_p_by_parts = true
[]

# Loads GMSH generated mesh. TRI3 type, second order elements.
[Mesh]
  # Mesh name denotes the number of elements.
  type = FileMesh
  file = void.msh
[]

# Second order for velocities and first order for pressure
[Variables]
  [./vel_x]
    order = SECOND
    family = LAGRANGE
  [../]
  [./vel_y]
    order = SECOND
    family = LAGRANGE
  [../]
  [./p]
    order = FIRST
    family = LAGRANGE
  [../]
[]

# Incompressible Navier-Stokes kernel in Laplacian form
[Kernels]
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
  [../]
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
  [../]
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
  [../]
[]

# No-slip (v = 0) boundary condition for cylinder ('wall') and channel walls ('top', 'botton')
# Input('left') BC as a parabolic velocity profile following the analytical profile for the
# flow in a channel. The maximum velocity is 0.3.
[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'top bottom wall'
    value = 0.0
  [../]
  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'left top bottom wall'
    value = 0.0
  [../]
  [./x_inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'left'
    function = 'inlet_func'
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    block = '0'
    prop_names = 'rho mu'
    prop_values = '1  0.001'
  [../]
[]

# Newton solver was used since it was much faster and PJFNK did not improved
# convergence significatively.
[Preconditioning]
  [./SMP_PJFNK]
    type = SMP
    full = true
    solve_type = NEWTON
    #solve_type = PJFNK
  [../]
[]

[Executioner]
  type = Steady
  petsc_options_iname = '-ksp_gmres_restart'
  petsc_options_value = '300               '
  line_search = none
  nl_rel_tol = 1e-5
  nl_max_its = 6
  l_tol = 1e-6
  l_max_its = 300
[]

# Parabolic velocity profile. Vx(0,0) = Vx(0,0.41) = 0, Vx(0,0.205) = 0.3.
[Functions]
  [./inlet_func]
    type = ParsedFunction
    value = '0.3*4*(0.41-y)*y/0.41^2'
  [../]
[]

[Outputs]
  exodus = true
[]

# Saves a CSV file with pressure values around the cylinder for the Cl and Cd calculation.
[VectorPostprocessors]
  [./nodal_sample]
    # Pick off the wall pressure values.
    type = NodalValueSampler
    variable = p
    boundary = 'wall'
    sort_by = x
  [../]
[]
