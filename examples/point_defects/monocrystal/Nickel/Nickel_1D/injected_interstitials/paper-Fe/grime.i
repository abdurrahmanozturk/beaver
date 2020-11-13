[Mesh]
  type = GeneratedMesh
  dim = 1

  nx = 300

# Specify things in nm
  xmin = 0
  xmax = 3e3
[]

[Variables]
  active = 'Vacancies Interstitials'

  [./Vacancies]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
  [../]

  [./Interstitials]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0
  [../]
[]

[AuxVariables]
  active = 'VacancyCreation Recombination InjectedInterstitials VacancyDiffusivityAux InterstitialDiffusivityAux ExcessInterstitialFraction RecomboAux DislocationSinkRate-V DislocationSinkRate-I ThermalVacancies VoidSinkRate-V VoidSinkRate-I VacancySupersaturation VacancySupersaturationNumerator VoidNucleationRate AverageVoidRadius'

  [./VacancyCreation]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./Recombination]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./InjectedInterstitials]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./VacancyDiffusivityAux]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 1e10
  [../]

  [./InterstitialDiffusivityAux]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 1e11
  [../]

  [./RecomboAux]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./DislocationSinkRate-V]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./DislocationSinkRate-I]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./ExcessInterstitialFraction]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./ThermalVacancies]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./VoidSinkRate-V]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./VoidSinkRate-I]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./VacancySupersaturation]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./VacancySupersaturationNumerator]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./VoidNucleationRate]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]

  [./AverageVoidRadius]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0
  [../]
[]

[Functions]
  active = 'DamageRate InjectionRate'

  [./DamageRate]
    type = PiecewiseLinear
    data_file = vacancy.csv
    format = columns
    axis = 0
  [../]

  [./InjectionRate]
    type = PiecewiseLinear
    data_file = range.csv
    format = columns
    axis = 0
  [../]
[]

[Kernels]
  active = 'VacancyDt InterstitialDt VacancyDiffusion InterstitialDiffusion VacancySource InterstitialSource VacancyRecombo InterstitialRecombo DislocationSink-V DislocationSink-I'

  [./VacancyDt]
    type = TimeDerivative
    variable = Vacancies
  [../]

  [./InterstitialDt]
    type = TimeDerivative
    variable = Interstitials
  [../]

  [./VacancyDiffusion]
    type = MatPropDiffusion
    variable = Vacancies
    diffusivity = VacancyDiffusivityMatProp
  [../]

  [./InterstitialDiffusion]
    type = MatPropDiffusion
    variable = Interstitials
    diffusivity = InterstitialDiffusivityMatProp
  [../]

  [./VacancySource]
    type = DefectSource
    variable = Vacancies
    PrimarySource = VacancyCreation
  [../]

  [./InterstitialSource]
    type = DefectSource
    variable = Interstitials
    PrimarySource = VacancyCreation
    SecondarySource = InjectedInterstitials
  [../]

  [./VacancyRecombo]
    type = DefectRecombination
    variable = Vacancies
    OtherDefect = Interstitials
    Recombination = Recombination
  [../]

  [./InterstitialRecombo]
    type = DefectRecombination
    variable = Interstitials
    OtherDefect = Vacancies
    Recombination = Recombination
  [../]

  [./DislocationSink-V]
    type = DefectSink
    variable = Vacancies
    SinkRate = DislocationSinkRate-V
  [../]

  [./DislocationSink-I]
    type = DefectSink
    variable = Interstitials
    SinkRate = DislocationSinkRate-I
  [../]
[]

[AuxKernels]
  active = 'DamageCreationRate InterstitialInjectionRate RecombinationRate VacancyDiffusivityMatProp InterstitialDiffusivityMatProp ExcessInterstitialFractionAux DislocationSinkRate-VAux DislocationSinkRate-IAux ThermalVacanciesMatPropAux SupersaturationAux SupersaturationNumeratorAux VoidNucleationRateAux'

  [./DamageCreationRate]
    type = FunctionAux
    variable = VacancyCreation
    function = DamageRate
  [../]

  [./InterstitialInjectionRate]
    type = FunctionAux
    variable = InjectedInterstitials
    function = InjectionRate
  [../]

  [./RecombinationRate]
    type = DefectRecombinationRateConstant
    variable = Recombination
  [../]

  [./VacancyDiffusivityMatProp]
    type = MaterialRealAux
    variable = VacancyDiffusivityAux
    property = VacancyDiffusivityMatProp
  [../]

  [./InterstitialDiffusivityMatProp]
    type = MaterialRealAux
    variable = InterstitialDiffusivityAux
    property = InterstitialDiffusivityMatProp
  [../]

  [./RecomboMatProp]
    type = MaterialRealAux
    variable = RecomboAux
    property = RecombinationEfficiencyMatProp
  [../]

  [./DislocationSinkRate-VAux]
    type = DislocationSinkRate
    variable = DislocationSinkRate-V
    Diffusivity = VacancyDiffusivityMatProp
    DislocationDensity = DislocationDensityMatProp
    DislocationCoreSize = 1.2
  [../]

  [./DislocationSinkRate-IAux]
    type = DislocationSinkRate
    variable = DislocationSinkRate-I
    Diffusivity = InterstitialDiffusivityMatProp
    DislocationDensity = DislocationDensityMatProp
    DislocationCoreSize = 3.6
  [../]

  [./ExcessInterstitialFractionAux]
    type = ExcessInterstitialFractionAux
    variable = ExcessInterstitialFraction
    vacancy_creation = VacancyCreation
    interstitial_creation = InjectedInterstitials
  [../]

  [./ThermalVacanciesMatPropAux]
    type = MaterialRealAux
    variable = ThermalVacancies
    property = ThermalVacancyConcentrationMatProp
  [../]

  [./SupersaturationAux]
    type = VacancySupersaturation
    variable = VacancySupersaturation
    Numerator = VacancySupersaturationNumerator
    EquilibriumVacancies = ThermalVacancies
  [../]

  [./SupersaturationNumeratorAux]
    type = VacancySupersaturationNumerator
    variable = VacancySupersaturationNumerator
    Vacancies = Vacancies
    Interstitials = Interstitials
    EquilibriumVacancies = ThermalVacancies
  [../]

  [./VoidNucleationRateAux]
    type = VoidNucleation
    variable = VoidNucleationRate
    Supersaturation = VacancySupersaturation
  [../]
[]

[Materials]
active = 'PureIron'

  [./PureIron]
    type = RadiationMaterial
    block = 0

# Global simulation parameters
    ConstantTemperature = 723

# Defect mobilities
    VacancyActivationEnergy = 0.86  # From R. A. Johnson, "Interstitials and Vacancies in α Iron", PRL 134 (1964), ****Ultrapure from experiment & MD
#    VacancyActivationEnergy = 1.1  # From conversations with B. D. Wirth, Michigan, March 2014
    InterstitialActivationEnergy = 0.17  # from N. Soneda & T. Diaz de La Rubia, "Migration kinetics of the self- interstitial atom and its clusters in bcc Fe", Phil Mag A 81 (2001)
    VacancyD0 = 8.016e11  # from V. A. Borodin and P. V. Vladimirov, "Diffusion coefficients and thermal stability of small helium–vacancy clusters in iron," J. Nucl. Mater 362 (2007)
    InterstitialD0 = 2.09e11  # from N. Soneda & T. Diaz de La Rubia, "Migration kinetics of the self- interstitial atom and its clusters in bcc Fe", Phil Mag A 81 (2001)

# Intra-cascade annihilation information
    IntraCascadeSurvivalFraction = 25e-2

# Defect sink information
    VacancySinkDensity = 5e10
    InterstitialSinkDensity = 5e10
    VacancySinkStrength = 1
    InterstitialSinkStrength = 1
    RecombinationEfficiency = 0.95

# Purely material parameters
    LatticeParameter = 2.86e-1  # in nm
    DislocationDensityInitial = 1e-6  # in #/nm^2
    AverageVoidRadiusInitial = 0.5  # in nm
  [../]
[]

[BCs]
  active = 'V-Surface I-Surface V-right I-right'

  [./V-Surface]
    type = DirichletBC
    variable = Vacancies
    boundary = 'left'
    value = 0
  [../]

  [./I-Surface]
    type = DirichletBC
    variable = Interstitials
    boundary = 'left'
    value = 0
  [../]

  [./V-right]
    type = DirichletBC
    variable = Vacancies
    boundary = 'right'
    value = 0
  [../]

  [./I-right]
    type = DirichletBC
    variable = Interstitials
    boundary = 'right'
    value = 0
  [../]

  [./Void-right]
    type = DirichletBC
    variable = Voids
    boundary = 'right'
    value = 0
  [../]
[]

[Postprocessors]
  [./FluxChecker-V]
    type = ElementIntegralVariablePostprocessor
    variable = Vacancies
  [../]

  [./FluxChecker-I]
    type = ElementIntegralVariablePostprocessor
    variable = Interstitials
  [../]

  [./VoidNucleationRateIntegral]
    type = ElementIntegralVariablePostprocessor
    variable = VoidNucleationRate
  [../]
[]

[Preconditioning]
  active = smp
  [./smp]
    type = SMP
    full = true
  [../]

  [./fdp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  num_steps = 1000000
  end_time = 3600

#  [./TimeStepper]
#    type = SolutionTimeAdaptiveDT
#    dt = 1e-9
#  [../]

  [./TimeStepper]
      type                     = DT2
      dt                       = 1e-9                        # The initial time step size.
      e_max                    = 1e7                  # Maximum acceptable error.
      e_tol                    = 1e6                  # Target error tolerance.
      max_increase             = 1.5                       # Maximum ratio that the time step can increase.
  [../]

#  dt = 1e-9

  solve_type = Newton
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'

  l_max_its = 100
  l_tol = 1e-5
  nl_rel_step_tol = 1e-50
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-11

#  line_search = none

#  [./Adaptivity]
#    steps = 1
#    refine_fraction = 0.4
#    coarsen_fraction = 0.02
#    max_h_level = 3
#    error_estimator = KellyErrorEstimator
#  [../]
[]

[Outputs]
  file_base = grime-200nA
  interval = 1
  exodus = true
  perf_log = true
  all_var_norms = true
  csv = true
[]


