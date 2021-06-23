# CliffDelineaTool
<em>CliffDelineaTool</em> is an algorithm for mapping coastal cliffs by finding cliff base and top positions along cross-shore transects. Written in MATLAB R2019a, it takes as input text files with a series of points containing information on point ID, transect ID, elevation and distance from the seaward end of the transect. To run the code you need to generate alongshore transects and resample them. Instructions on how to do it in ArcMap can be found below (FAQ). See <em>/datasets</em> folder for the calibration and validation datasets.</br></br>
Please cite: Swirad Z.M. & Young A.P. 2021. Automating coastal cliff erosion measurements from large-area LiDAR datasets in California, USA. Geomorphology 389: 107799 (https://doi.org/10.1016/j.geomorph.2021.107799) if using this code.</br></br>

<b>FAQ</b></br></br>
<b>How to generate cross-shore transects and points in ArcMap?</b></br>
Create polylines to delimit seaward and landward extent of transects. Generate equally-spaced points along the seaward polyline (<em>Generate Points along Lines</em>). Add a new field to the Attribute Table of the point shapefile (<em>Calculate Field</em>: ID = FID + 1). Copy the point shapefile. Get the locations of the nearest points along the landward polyline for the point shapefile (<em>Near>; tick ‘location’). Extract those neares points along the landward polyline (<em>Make XY Event Layer</em> of the Near location in point Attribute Table). Append the new point layer to the copied point shapefile (<em>Data Management > Append</em>; 'no test'). Add a new field to the Attribute Table of the appended shapefile (<em>Calculate Field</em>: ID_1 = ID). Convert points to a polyline (<em>Points to Line</em>; field: ID_1). Densify polyline to desired interval (<em>Densify</em>)and use it to create a point shapefile (<em>Feature Vertices to Points</em>). Extract the elevation values for points from DEM (<em>Extract Values to Points</em>). Calculate the distance to the seaward polyline (<em>Near</em>). Export the Attribute Table.</br></br>

<b>Does it matter how long the transects are?</b></br>
<b>How to space transects alongshore?</b></br>
<b>How to space points along transects?</b></br>
<b>How to implement the output in GIS?</b></br>
ArcMap: Add Join, Select by Attribute
Manual mapping ArcMap: Analysis>Intersect with the transect (to points), Multipart to Singlepart (for now only multipart i.e. 1 point per transect (slosest to the seaward edge), Near (seaward line)

