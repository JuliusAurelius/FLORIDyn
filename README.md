# FLORIDyn
Dynamic implementation of the FLORIS model including time varying wind speeds and directions.

*WORK IN PROGRESS*

Beta version of a dynamic FLORIS implementation including time varying wind speeds and directions.

## Outline
This is a simulator written in MATLAB which will be able to approximately simulate the dynamic behaviour of the wind field in a wind farm. The basic concept was introduced by *Pieter M.O. Gebraad* and *J.W. van Wingerden* in *A Control-Oriented Dynamic Model for Wakes in Wind Plants*, (TORQUE 2014).
The idea is to create observation points (OPs) at the rotor plane which inherit the relevant characteristics of turbine at that time step (Ct and yaw). With the stored data, the OPs are able to calculate the effective wind speed at their location in the wake. With their speed calculated, they travel down stream with the passing time. With OPs spawning at the same location at the rotor plane and following the same path (given there is no change) a chain is formed. Changes at the rotor plane now travel down the wake and the chains and take their time before a wind turbine further down stream experiences them. This creates a serious challenge for a wind farm controller which should not be ignored when controller designs are tested. With other wake simulations like one purely based on the FLORIS wake model, these changes are immediately applied to downstream turbines and dynamic effects are ignored. 
Additionally, the OPs interact with each other, so wakes influencing each other can be modeled.

This implementation extends the basic concept and implements changing wind speeds and directions. It also aims to be modular in order for users to add, modify and extend the code. It is meant to bridge the gap between computationally cheap but non-dynamic models and computationally expensive CFD simulations.

### Current state
The code can simulate multiple wakes (tested with up to 6), heterogeneous wind conditions (direction and speed), uniform or varying chain lengths and numbers per turbine. The code runs 3D simulations. The implemented wake model is based on *Experimental and theoretical study of wind turbine wakes in yawed conditions* by *M. Bastankhah and F. Porté-Agel* (2016). The equations for the ambient turbulence intensity are taken from *Design and analysis of a spatially heterogeneous wake* by *A. Farrell, J. King et al.* (Wind Energy Science Discussions, 2020). The wake interaction is currently based on a simple nearest neighbour interpolation since the differences between single points are assumed to be marginal in the closer neighbourhood. 

### What is missing?
* Validate the speed decrease in the wake
* Validate the power output
* No controller is implemented

This code is part of the master thesis of Marcus Becker.

#### Alpha version of a contour plot
Since transforming the Observation Point data into a grid with which 'contourf' can work is a computationally expensive task, the plot is only created at the end of the simulation. Shown here with 30 levels of speed.
![Contour plot of three wind turbines](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/contour_interpolation_07.png)

#### Observation Point plot of the Bastankhah model
Now with added near-wake features the model is almost complete. The ambient turbulence intesity is implemented as a field property. The near-far wake transition is smooth and it lines up with what is shown in the paper. This is the same setup as the one used for the contour plot. The grey arrows in the background indicate the interpolated wind speed. Below the OP plot is a first version of the power output plot. With 2D wakes, the wind speed calculation is approximative and might not sufficiently match the reality.
![Bastankhah model with near wake characteristics](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/PowerCalc_2D_01.png)

### .graphml files
The .graphml files can be opened with the free software [yEd](https://www.yworks.com/products/yed#yed-support-resources) from yWorks. It is a graphing editor which can automatically layout graphs in various ways.
