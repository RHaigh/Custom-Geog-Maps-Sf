# Custom Geography Maps in R
A guide for analysts to quickly create customised maps in pdf or png format without requiring licensed mapping software using the sf and ggmap packages. 

Author: Richard Haigh

Date of Intial Upload: 09/07/2020

Written - R Desktop 3.6.1

Environment: RStudio v1.2.1335

Software Requirements: Google Maps API Key - Geocode and Static Maps enabled

Packages:
sf v0.9-3, tidyverse v1.2.1, ggmap v3.0.0

This is intended to be a guide for analysts and statisticians with a mid-level knowledge of R and programming fundamentals that will aid them in creating customised maps. Use this if you wish for a pdf or png output file that shows your desired geography level breakdown (be it LA, DZ or SPC) and can shade each geog area by a given variable such as population, wealth or any other quantifiable numeric measurement.

You can use this with an existing dataset providing it has a breakdown of your chosen geography level. You must also have access to the software stated above.

Using this guide, you can quickly create ouptut such as this without using any licensed mapping software, such as QGIS, FME or ArcMap:


