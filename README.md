### Overview

This repository compares two approaches to injecting fluid at a fixed flow rate and temperature in MOOSE's PorousFlow Thermo-hydro simulations. The first approach fixes the temperature at the inlet using a PresetBC, DirichletBC, or FunctionDirichletBC, while the second approach injects an amount of enthalpy based on the inlet fluid temperature using a PorousFlowSink BC.

### Details

The domain is initially at zero degrees and has a BCs that encourage a flow of 40000 kg/s, or 40 m3/s across it (which is accomplished in *input\_initialization.i*). After the initialization period, the inlet temperature is raised in one of two ways: (a) the temperature at the boundary is raised to 1 degree (*input\_PresetBC.i*) or the enthalpy that is associated with 40000 kg/s at 1 degree is injected (*input\_PFSink.i*).

#### Parameters 

We use the SimpleFluidProperties equation of state: Viscosity = 1 Pa-s, heat capacity = 4200 J/kg/K, reference density = 1000 kg/m3, bulk modulus of the fluid = 2e9 Pa. 
The rock material properties are: permeability = 10^-7 m2, porosity = 0.1, rock density = 2500 kg/m3, specific heat capacity = 800, dry thermal conductivity = 2.1, wet thermal conductivity = 1.8.
The domain is 200 x 1 x 200 m and the area of the injection and extraction BCs are 200 m2.

#### Calculation of enthalpy injection rate

The enthalpy injection rate is the product of the flow rate, the fluid heat capacity, and the temperature change = 40,000 kg/s * 4200 J/kg/K * 1 K = 1.68e8 J/s. Dividing by the area gives the flux\_function = 840000 J/m2/s for the PorousFlowSink BC in *input\_PFSink.i*.

#### Sanity check

The steady state pressure gradient can be calculated from Darcy's equation: $$\nabla P$$. \alpha

### Results and Interpretation

![Tux, the Linux mascot](Heat_BC_comparison.png)


