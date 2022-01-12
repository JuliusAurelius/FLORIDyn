# FLORIDyn
Dynamic implementation of the FLORIS model including time varying wind speeds and directions.

# Current state
**This work has been continued in a different repo!**
Find the current model at https://github.com/MarcusBecker-GitHub/FLORIDyn_Matlab

## Paper and citation
The paper about this model is currently in discussion in Wind Energy Science and can be accessed here: https://wes.copernicus.org/preprints/wes-2021-154/
If the Gaussian FLORIDyn model is playing or played a role in your research, consider citing the work:
Becker, M., Ritter, B., Doekemeijer, B., van der Hoek, D., Konigorski, U., Allaerts, D., and van Wingerden, J.-W.: The revised FLORIDyn model: Implementation of heterogeneous flow and the Gaussian wake, Wind Energ. Sci. Discuss. [preprint], https://doi.org/10.5194/wes-2021-154, in review, 2022.


# Description of this repo DEPRECATED
Beta version of a dynamic FLORIS implementation including time varying wind speeds and directions.

## Outline
This is a simulator written in MATLAB which will be able to approximately simulate the dynamic behaviour of the wind field in a wind farm. The basic concept was introduced by *Pieter M.O. Gebraad* and *J.W. van Wingerden* in *A Control-Oriented Dynamic Model for Wakes in Wind Plants*, (TORQUE 2014).
The idea is to create observation points (OPs) at the rotor plane which inherit the relevant characteristics of turbine at that time step (Ct and yaw). With the stored data, the OPs are able to calculate the effective wind speed at their location in the wake. With their speed calculated, they travel down stream with the passing time. With OPs spawning at the same location at the rotor plane and following the same path (given there is no change) a chain is formed. Changes at the rotor plane now travel down the wake and the chains and take their time before a wind turbine further down stream experiences them. This creates a serious challenge for a wind farm controller which should not be ignored when controller designs are tested. With other wake simulations like one purely based on the FLORIS wake model, these changes are immediately applied to downstream turbines and dynamic effects are ignored. 
Additionally, the OPs interact with each other, so wakes influencing each other can be modeled.

This implementation extends the basic concept and implements changing wind speeds and directions. It also aims to be modular in order for users to add, modify and extend the code. It is meant to bridge the gap between computationally cheap but non-dynamic models and computationally expensive CFD simulations.

### Current state
The code can simulate multiple wakes (tested with up to 6), heterogeneous wind conditions (direction and speed), uniform or varying chain lengths and numbers per turbine. The code runs 3D simulations. The implemented wake model is based on *Experimental and theoretical study of wind turbine wakes in yawed conditions* by *M. Bastankhah and F. Porté-Agel* (2016). The equations for the ambient turbulence intensity are taken from *Design and analysis of a spatially heterogeneous wake* by *A. Farrell, J. King et al.* (Wind Energy Science Discussions, 2020). The wake interaction is currently based on a simple nearest neighbour interpolation since the differences between single points are assumed to be marginal in the closer neighbourhood. 

### What is missing?
* No controller is implemented

This code is part of the master thesis of Marcus Becker.

Selection of animations and pictures. For more, see Pictures/
#### 60 degree wind direction change in a nine turbine wind farm
The angle changes equally for every point in the field, something which can be changed in the Code
![Nine turbines wind direction change](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/Animations/9T.gif)

#### Flow field
Comparison of the three turbine flow field with SOWFA simulation data, plotted as the relative error.
![2 Turbine flow field](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/FlowField/ThreeT_00_FlowField_Horizontal_RelError_newI.png)

#### Power generated
Generated power of three turbines with 5D distance with greedy control approach
![Generated power of three consecutive turbines](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/GeneratedPower/3T_00_greedy.png)

Three turbine case with T0 and T1 increasing their yaw stepwise from 0 deg to +30 deg. The begin of the yaw change is marked by a black line.
![Three turbine positive yaw change](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/GeneratedPower/3T_changingPosYaw.png)

#### Performance
Performance measurements for a varying number of turbines and observation points.
Measurements taken on a Laptop (2,3 GHz 8-Core Intel Core i9; 32 GB 2667 MHz DDR4)
![Performance](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/Performance/Performance_totalNumOP_log.png)

### .graphml files
The .graphml files can be opened with the free software [yEd](https://www.yworks.com/products/yed#yed-support-resources) from yWorks. It is a graphing editor which can automatically layout graphs in various ways.
