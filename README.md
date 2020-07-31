# FLORIDyn
Dynamic implementation of the FLORIS model including time varying wind speeds and directions.

*WORK IN PROGRESS*

Alpha version of a dynamic FLORIS implementation including time varying wind speeds and directions.
The program aims to provide interfaces to various models such as the Bastankhah(2016) model or the Gebraad(2014) model.

## Outline
This is a simulator written in MATLAB which will be able to approximately simulate the dynamic behaviour of the wind field in a wind farm. The basic concept was introduced by *Pieter M.O. Gebraad* and *J.W. van Wingerden* in *A Control-Oriented Dynamic Model for Wakes in Wind Plants*, (TORQUE 2014).
The idea is to create observation points (OPs) at the rotor plane which inherit the relevant characteristics of turbine in this time step (axial induction factor, yaw, wind speed). With the acquired data, the OPs are able to calculate the effective wind speed at their location in the wake. With their speed calculated, they travel down stream with the passing time. With OPs spawning at the same location at the rotor plane and following the same path (given there is no change) a chain is formed. Changes at the rotor plane now travel down the wake and the chains and take their time before a wind turbine further down stream experiences them. This creates a serious challenge for a wind farm controller which should not be ignored when controller designs are tested. With other wake simulations like one purely based on the FLORIS wake model, these changes are immediately applied to downstream turbines and dynamic effects are ignored. 
Additionally, the OPs interact with each other, so wakes influencing each other can be modeled.

This implementation extends the basic concept and implements changing wind speeds and directions. It also aims to be modular in order for users to add, modify and extend the code. It is meant to bridge the gap between computationally cheap but non-dynamic models and computationally expensive CFD simulations.

### Current state
The code can simulate multiple wakes (tested with up to 6), heterogeneous wind conditions (direction and speed), uniform or varying chain lengths and numbers per turbine. The code is able to run 2D as well as 3D simulations. The implemented wake model is based on *Experimental and theoretical study of wind turbine wakes in yawed conditions* by *M. Bastankhah and F. Porté-Agel* (2016). The equations for the ambient turbulence intensity are taken from *Design and analysis of a spatially heterogeneous wake* by *A. Farrell, J. King et al.* (Wind Energy Science Discussions, 2020).

### What is missing?
* Validate the speed decrease in the wake, implement other forms and define an interface.
* There is no wake interaction implemented yet.
* No controller is implemented
* No (proper) visualization is implemented

This code is part of the master thesis of Marcus Becker.

The first Proof-of-Concept shows multiple turbines, changing wind directions and speed, various chain lengths and the 3D representation of the field. Wake effects are not included yet, this is meant as a demonstration of the core code.
![Proof of concept changing wind direction and speed](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/Proof_of_concept_WindDirSpe_change_05.png?raw=true)

The second Proof-of-Concept shows one turbine with the Gebraad FLORIS Wake Model (2014). The code is not validated but the output shows a recovery process of the wake with clearly visible near field characteristics.
![Proof of concept changing wind direction and speed](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/Proof_of_concept_Wake_02.png?raw=true)

Here a plot of the 3D wake (on top) and the 2D wake (below) can be seen. Switching between the 2D/3D requires to change the flag `Dim = 2;` to `Dim = 3;` in main.m.
![3D model next to a 2D model](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/2D_3D.png)

This is a plot of the Bastankhah model implementation. Note that the near field characteristics are currently ignored and the speed is assumed to be constant. The wake shape starts at the end of the core, when self-simiarity is applicable. The snake shape is due to the controller swinging between yaw = -30° and +30° to visualize the dynamics.
![First FLORIS (Bastankhah) implementation](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/bastankhah04.png)

### .graphml files
The .graphml files can be opened with the free software [yEd](https://www.yworks.com/products/yed#yed-support-resources) from yWorks. It is a graphing editor which can automatically layout graphs in various ways.
