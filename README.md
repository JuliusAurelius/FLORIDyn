# FLORIDyn
Dynamic implementation of the FLORIS model including time varying wind speeds and directions.

*WORK IN PROGRESS*

Alpha version of a dynamic FLORIS implementation including time varying wind speeds and directions.
The program aims to provide interfaces to various models such as the Bastankhah(2016) model or the Gebraad(2014) model.

## Outline
This is a simulator written in MATLAB which will be able to approximately simulate the dynamic behaviour of the wind field in a wind farm. The basic concept was introduced by *Pieter M.O. Gebraad* and *J.W. van Wingerden* in *A Control-Oriented Dynamic Model for Wakes in Wind Plants*, (TORQUE 2014).
The idea is to create observation points (OPs) at the rotor plane which inherit the relevant characteristics of turbine in this time step (axial induction factor, yaw, wind speed). With the acquired data, the OPs are able to calculate the effective wind speed at their location in the wake. With their speed calculated, they travel down stream with the passing time. With OPs spawning at the same location at the rotor plane and following the same path (given there is no change) a chain is formed. Changes at the rotor plane now travel down the wake and the chains and take their time before a wind turbine further down stream experiences them. This creates a serious challenge for a wind farm controller which should not be ignored when controller designs are tested. With other wake simulations like one purely based on the FLORIS wake model, these changes are immediately applied to downstream turbines and dynamic effects are ignored. 
Additionally, the OPs interact with each other, so wakes influencing each other can be modeled.

This implementation extends the basic concept and implements changing wind speeds and directions. It also aims to be able to switch between different wake models and to generally be modular in order for users to add, modify and extend the code.

### Current state
The code can simulate multiple wakes (tested with up to 6), heterogeneous wind conditions (direction and speed), uniform or varying chain lengths and numbers per turbine.

### What is missing?
* The wakes experience no speed decrease, the observation point speed is currently always equal to the wind speed of the wind field.
* There is no wake interaction implemented yet.
* No controller is implemented
* No (proper) visualization is implemented

This code is part of the master thesis of Marcus Becker.

Picture of the wakes currently produced. The Proof-Of-Concept shows multiple turbines, changing wind directions and speed, various chain lengths and the 3D representation of the field. Like mentioned before, wake effects are not included yet, this is meant as a demonstration of the core code.
![Proof of concept](https://github.com/JuliusAurelius/FLORIDyn/blob/master/Pictures/Proof_of_concept_WindDirSpe_change_05.png?raw=true)

### .graphml files
The .graphml files can be opened with the free software [yEd](https://www.yworks.com/products/yed#yed-support-resources) from yWorks. It is a graphing editor which can automatically layout graphs in various ways.
