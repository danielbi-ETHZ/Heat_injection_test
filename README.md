### Overview

This repository compares two approaches to injecting fluid at a fixed flow rate and temperature in MOOSE's PorousFlow Thermo-hydro simulations. The first approach fixes the temperature at the inlet using a DirichletBC, while the second approach injects an amount of enthalpy based on the inlet fluid temperature using a PorousFlowSink BC.

### Details

The domain is initially at zero degrees and has a BCs that encourage a flow of 40000 kg/s, or 40 m3/s, across it (which is accomplished in *input\_initialization.i*). After the initialization period, the inlet temperature is raised in one of two ways: (a) the temperature at the boundary is raised to 1 degree (*input\_PresetBC.i*) or (b) the relevant enthalpy injection rate is specified (i.e. the enthalpy from 40000 kg/s at 1 degree, in *input\_PFSink.i*). The outflow boundary produces fluid at 40000 kg/s and allows temperature to leave with the fluid. This is achieved by having very similar *PorousFlowSink* cards at the outlet for temperature and pressure. The only difference are the variable names (temp instead of pp) and that *use\_enthalpy* is included for the temperature condition.

```
  [./production]
    type = PorousFlowSink
    variable = pp
    boundary = right
    flux_function = 200 ## extraction of fluid at 200 kg/m2/s
    fluid_phase = 0
    use_mobility = false
    save_in = fluxes_out
  [../]
  #Note that production_heat is identical to production at outflow boundary
  #except that variable = temp and use_enthalpy = true
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
```

#### Parameters 

We use the SimpleFluidProperties equation of state: Viscosity = 1 Pa-s, heat capacity = 4200 J/kg/K, reference density = 1000 kg/m3, bulk modulus of the fluid = 2e9 Pa. 
The rock material properties are: permeability = 10^-7 m2, porosity = 0.1, rock density = 2500 kg/m3, specific heat capacity = 800, dry thermal conductivity = 2.1, wet thermal conductivity = 1.8.
The domain is 200 x 1 x 200 m and the area of the injection and extraction BCs are 200 m2.

#### Calculation of enthalpy injection rate

The enthalpy injection rate is the product of the flow rate, the fluid heat capacity, and the temperature change = 40,000 kg/s * 4200 J/kg/K * 1 K = 1.68e8 J/s. Dividing by the area gives the flux\_function = 840000 J/m2/s for the PorousFlowSink BC in *input\_PFSink.i*.

```
  [./injection_heat]
    type = PorousFlowSink
    variable = temp
    boundary = left
    flux_function = -840000. #This is the amount of enthalpy calculated a priori
    fluid_phase = 0
    use_mobility = false
    use_enthalpy = false #NOTE this is false since a priori calculation was already done for flux_function
    save_in = heat_fluxes_in
  [../]
```

### Results and Interpretation

The figure below shows temperature versus distance along the flow path, x. 

![Tux, the Linux mascot](Heat_BC_comparison.png)


