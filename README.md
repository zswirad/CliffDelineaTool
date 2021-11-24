# CliffDelineaTool
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5724975.svg)](https://doi.org/10.5281/zenodo.5724975)</br>
<em>CliffDelineaTool</em> is an algorithm for mapping coastal cliffs by finding cliff base and top positions along cross-shore transects. Written in MATLAB and available in Python, it takes as input text files with series of points containing information on point ID, transect ID, elevation and distance from the seaward transect ends. To run the code you need to generate alongshore transects and resample them. Suggestions on how to do it in ArcMap can be found below. See <em>datasets</em> folder for the calibration and validation datasets.</br></br>
If you use the code, please cite the article: Swirad Z.M. & Young A.P. 2021. CliffDelineaTool v1.1.0: an algorithm for identifying coastal cliff base and top positions. Geoscientific Model Development Discussions [preprint]. https://doi.org/10.5194/gmd-2021-269</br></br>
<b>How to generate cross-shore transects and points in ArcMap?</b></br>
Create polylines to delimit seaward and landward extent of transects. Generate equally-spaced points along the seaward polyline (<em>Generate Points along Lines</em>). Add a new field to the Attribute Table of the point shapefile (<em>Calculate Field</em>: ID = FID + 1). Copy the point shapefile. Get the locations of the nearest points along the landward polyline for the point shapefile (<em>Near</em>; tick ‘location’). Extract those nearest points along the landward polyline (<em>Make XY Event Layer</em> of the <em>Near</em> location in point Attribute Table). Append the new point layer to the copied point shapefile (<em>Data Management > Append</em>; 'no test'). Add a new field to the Attribute Table of the appended shapefile (<em>Calculate Field</em>: ID_1 = ID). Convert points to a polyline (<em>Points to Line</em>; field: ID_1). Densify polyline to desired interval (<em>Densify</em>) and use it to create a point shapefile (<em>Feature Vertices to Points</em>). Extract the elevation values for points from DEM (<em>Extract Values to Points</em>). Calculate the distance to the seaward polyline (<em>Near</em>). Export the Attribute Table.</br></br>
<b>How to import outputs into ArcMap?</b></br>
Join the point shapefile with the text file output of <em>CliffDelineaTool</em> (<em>Add Join</em>; use point ID as the 'join field'). Select points that have any values in the model output columns of the Attribute Table (<em>Select by Attribute</em>; e.g. 'Field1>0'). Export to a new shapefile. Starting from v1.2.0 it is possible to include XY coordinates as point properties and directly import them as XY layer in GIS software.  
