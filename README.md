# Overview

This repository compares two approaches to injecting fluid at a fixed flow rate and temperature in MOOSE's PorousFlow Thermo-hydro simulations. The first approach fixes the temperature at the inlet using a PresetBC, DirichletBC, or FunctionDirichletBC, while the second approach injects an amount of enthalpy based on the inlet fluid temperature using a PorousFlowSink BC.

### Details

Fluid flows across the domain at 40000 kg/s (or 40 m3/s). Once the flow field has come to a steady state (accomplished by running input\_initialization.i), the inlet temperature is raised from 0 to 1 degree in either input\_PFSink.i or input\_PresetBC.i. The outlet boundary allows flow and heat to flow out naturally. 


