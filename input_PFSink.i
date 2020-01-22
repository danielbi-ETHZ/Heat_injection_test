ENDING_TIME = 1000.
DT_MAX_TIME = 50.
HEAT_ON_TIME = 100.
HEAT_ON_TIME_DT = 100.01

# [MeshGenerators]
#   [./gmg]
#     type = GeneratedMeshGenerator
#     dim = 3
#     nx = 20
#     ny = 2
#     nz = 20
#     bias_x = 1.0
#     xmin = 0.0
#     xmax = 200.0
#     ymin = 0.0
#     ymax = 1.0
#     bias_z = 1.0
#     zmax = 200.0
#     zmin = 0
#   []
#   [./createNewSidesetOne]
#     type = SideSetsFromBoundingBoxGenerator
#     input = gmg
#     boundary_id_old = 'left' #says to look on the bottom boundary
#     boundary_id_new = 10     #new boundary is assigned to 10
#     bottom_left = '-0.1 -0.1 -1.1' #bounds of the new boundary
#     top_right = '1000 1000 1000'     #bounds of the new boundary
#     block_id = 0                #applied on block_id = 0 (i.e. the whole domain)
#   []
#   [./createNewSidesetTwo]
#     type = SideSetsFromBoundingBoxGenerator
#     input = createNewSidesetOne
#     boundary_id_old = 'right'
#     boundary_id_new = 11
#     bottom_left = '-0.1 -0.1 -0.1' #bounds of the new boundary
#     top_right = '1000 1000 1000'     #bounds of the new boundary
#     block_id = 0
#   []
# []

[Mesh]
  file = input_initialization_out.e
  # type = MeshGeneratorMesh
  # boundary_id = '10 11'
  # boundary_name = 'injectionBC productionBC'
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[Variables]
  [./temp]
    # initial_condition = 0
    scaling = 1.E-1
    initial_from_file_var = temp
    initial_from_file_timestep = LATEST
  [../]
  [./pp]
    initial_from_file_var = pp
    initial_from_file_timestep = LATEST
    # scaling = 1e7
    # initial_condition = 0.0
  [../]
[]

[Functions]
  [./heat_BC_func]
    type = PiecewiseConstant
    x = '0. ${HEAT_ON_TIME}  ${HEAT_ON_TIME_DT} ${ENDING_TIME}'
    y = '1.0   1.0    1.0      1.0'
    # x = '0 100   200 1e8' # x actls like time
    # y = '0 -1e-6 -1e-6   -1e-6'  # y acts like the amount of tracer at the inlet
    direction = left
  [../]
[]

[BCs]
  ##### For use_mobility = false
  [./injection]
    type = PorousFlowSink
    variable = pp
    boundary = left
    flux_function = -200
    fluid_phase = 0
    use_mobility = false
    save_in = fluxes_in
  [../]

  [./injection_heat]
    type = PorousFlowSink
    variable = temp
    boundary = left
    flux_function = -840000.
    fluid_phase = 0
    use_mobility = false
    use_enthalpy = false
    save_in = heat_fluxes_in
  [../]
  # [./injection_heat]
  #   type = PresetBC
  #   variable = temp
  #   boundary = left
  #   value = 1.
  #   save_in = heat_fluxes_in
  # [../]
  # [./injection_heat_function]
  #  type = FunctionDirichletBC
  #  variable = temp
  #  boundary =left
  #  # fluid_phase = 0 #Not used
  #  # value = 393.15
  #  function = heat_BC_func
  # [../]

  [./production]
    type = PorousFlowSink
    variable = pp
    boundary = right
    flux_function = 200
    fluid_phase = 0
    use_mobility = false
    save_in = fluxes_out
  [../]
  [./production_heat]
    type = PorousFlowSink
    variable = temp
    boundary = right
    flux_function = 200
    fluid_phase = 0
    use_mobility = false
    use_enthalpy = true
    save_in = heat_fluxes_out
  [../]
[]

# [Adaptivity]
#  marker = errorfrac
#  steps = 2
#  max_h_level = 2
#  [./Indicators]
#    [./error]
#      type = GradientJumpIndicator
#      variable = pp
#      # variable = temp
#      outputs = none
#    [../]
#  [../]
#  [./Markers]
#    [./errorfrac]
#      type = ErrorFractionMarker
#      refine = 0.5  #Refines the elements that contribut the top 50% of error.
#      coarsen = 0.1 #this would coarsen the elements that contribute only 10% of the error, but wont coarsen past original size
#      indicator = error
#      outputs = none
#    [../]
#  [../]
# []

[Kernels]
  [./mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = pp
  [../]
  [./adv0]
    type = PorousFlowAdvectiveFlux
    fluid_component = 0
    variable = pp
  [../]
 [./energy_dot]
   type = PorousFlowEnergyTimeDerivative
   variable = temp
 [../]
 [./convection]
   type = PorousFlowHeatAdvection
   variable = temp
 [../]
 [./conduction]
   type = PorousFlowHeatConduction
   variable = temp
 [../]
[]

[UserObjects]
  [./dictator]
    type = PorousFlowDictator
    # porous_flow_vars = 'pp'
    porous_flow_vars = 'pp temp'
    number_fluid_phases = 1
    number_fluid_components = 1
  [../]
[]

[Modules]
  [./FluidProperties]
    [./simple_fluid]
      type = SimpleFluidProperties
      bulk_modulus = 2.0E9
      density0 = 1000.0
      #density0 = 1.
      thermal_expansion = 0.0
      viscosity = 1.0
      cv = 4.2e3
      porepressure_coefficient = 0 #assumed to be zero so enthalpy can be calcualted a priori
    [../]
  [../]
[]

[Materials]
  [./permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1.E-7 0 0   0 1.e-7 0   0 0 1.e-7'
  [../]
  [./poro]
    type = PorousFlowPorosityConst
    porosity = 1e-1
  [../]
  [./relp]
    type = PorousFlowRelativePermeabilityConst
    phase = 0
  [../]
  [./rock_heat]
    type = PorousFlowMatrixInternalEnergy
    specific_heat_capacity = 800
    density = 2500
  [../]
 [./temperature]
   type = PorousFlowTemperature
   temperature = temp
 [../]
  [./ppss_qp]
    type = PorousFlow1PhaseFullySaturated
    porepressure = pp
  [../]
  [./massfrac]
    type = PorousFlowMassFraction
  [../]
  [./simple_fluid_qp]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid
    phase = 0
  [../]
 [./rock_thermal_conductivity]
   type = PorousFlowThermalConductivityIdeal
   dry_thermal_conductivity = '2.1 0 0  0 2.1 0  0 0 2.1'
   wet_thermal_conductivity = '1.8 0 0  0 1.8 0  0 0 1.8'
 [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = 'lu mumps'
  [../]
[]


[AuxVariables]
  [./fluxes_out]
  [../]
  [./fluxes_in]
  [../]
  [./heat_fluxes_out]
  [../]
  [./heat_fluxes_in]
  [../]
  [./darcy_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./darcy_y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./darcy_z]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./density_water]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./viscosity_water]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./porosity]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./permeability_x]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./permeability_xy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./permeability_y]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[AuxKernels]
  [./darcy_x]
    type = PorousFlowDarcyVelocityComponent
    variable = darcy_x
    gravity = '0 0 0'
    component = x
    #block = 'EnhPerm'
  [../]
  [./darcy_y]
    type = PorousFlowDarcyVelocityComponent
    variable = darcy_y
    #gravity = '0 0 -10E-6'
    gravity = '0 0 0'
    component = y
  [../]
  [./darcy_z]
    type = PorousFlowDarcyVelocityComponent
    variable = darcy_z
    gravity = '0 0 0'
    component = z
  [../]
  [./density_water]
    type = PorousFlowPropertyAux
    variable = density_water
    property = density
    phase = 0
    execute_on = timestep_end
  [../]
  [./viscosity_water]
    type = PorousFlowPropertyAux
    variable = viscosity_water
    property = viscosity
    phase = 0
    execute_on = timestep_end
  [../]
  [./porosity]
    type = MaterialRealAux
    property = PorousFlow_porosity_qp
    variable = porosity
  [../]
  [./permeability_x]
    type = MaterialRealTensorValueAux
    property = PorousFlow_permeability_qp
    column = 0
    row = 0
    variable = permeability_x
  [../]
  [./permeability_xy]
    type = MaterialRealTensorValueAux
    property = PorousFlow_permeability_qp
    column = 0
    row = 1
    variable = permeability_xy
  [../]
  [./permeability_y]
    type = MaterialRealTensorValueAux
    property = PorousFlow_permeability_qp
    column = 0
    row = 0
    variable = permeability_y
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]

[Postprocessors]
  [./outlet_flux_kg_s]
    type = NodalSum
    boundary = productionBC
    variable = fluxes_out
    execute_on = 'timestep_end'
  [../]
  [./inlet_flux_kg_s]
    type = NodalSum
    boundary = injectionBC
    variable = fluxes_in
    execute_on = 'timestep_end'
  [../]
  [./outlet_flux_J_s]
    type = NodalSum
    boundary = productionBC
    variable = heat_fluxes_out
    execute_on = 'timestep_end'
  [../]
  [./inlet_flux_J_s]
    type = NodalSum
    boundary = injectionBC
    variable = heat_fluxes_in
    execute_on = 'timestep_end'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  start_time = 0.0
  end_time = '${ENDING_TIME}'
  # dt = 2.e5
  dtmax = '${DT_MAX_TIME}'
  dtmin = 0.1
 [./TimeStepper]
   type = IterationAdaptiveDT
   dt = 1.0
   optimal_iterations = 3
   time_t  = '0  ${HEAT_ON_TIME}'
   time_dt = '1  1'
 [../]
# controls for linear iterations
  l_max_its = 15
  l_tol = 1e-4
# controls for nonlinear iterations
  nl_max_its = 20
  nl_rel_tol = 1e-5
  nl_abs_tol = 1e-4
[]

## Puts correct pressure out
[VectorPostprocessors]
  [./pressure]
    type = SideValueSampler
    variable = pp
    sort_by = x
    execute_on = timestep_end
    boundary = bottom
  [../]
[]

[Outputs]
  [./out]
    type = Exodus
    execute_on = 'initial timestep_end'
  [../]
  [./csv]
    type = CSV
    execute_on = final
    sync_times = '1 10 100 300'
  [../]
[]
