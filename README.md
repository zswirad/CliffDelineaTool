# CliffDelineaTool
<em>CliffDelineaTool</em> is an algorithm for mapping coastal cliffs by finding cliff base and top positions along cross-shore transects. Written in MATLAB R2019a, it takes as input text files with a series of points containing information on point ID, transect ID, elevation and distance from the seaward end of the transect. To run the code you need to generate alongshore transects and resample them. Instructions on how to do it in ArcMap can be found below (FAQ). See <em>/datasets</em> folder for the calibration and validation datasets.</br></br>
Please cite: Swirad Z.M. & Young A.P. 2021. Automating coastal cliff erosion measurements from large-area LiDAR datasets in California, USA. Geomorphology 389: 107799 (https://doi.org/10.1016/j.geomorph.2021.107799) if using this code.</br></br>

<b>FAQ</b></br></br>
<b>How to generate cross-shore transects and points?</b></br>

ArcMap:
1.	Make a seaward and landward lines
2.	Generate Points Along Lines (seaward)
3.	Calculate Field (ID = FID + 1)
4.	Copy point shp
5.	Near (points to landward line; tick ‘location’)
6.	Make XY Event Layer (of the Near location in point Attribute Table)
7.	Data Management > Append (XY layer and copied points, no test)
8.	Calculate Field (ID-1 = ID)
9.	Points to Line (field: ID_1)
10.	Densify
11.	Feature Vertices to Points
12.	Extract Values to Points (elevation)
13.	Near (seaward line)
14.	Export Attribute Table

<b>Does it matter how long the transects are?</b></br>
<b>How to space transects alongshore?</b></br>
<b>How to space points along transects?</b></br>
<b>How to implement the output in GIS?</b></br>
ArcMap: Add Join, Select by Attribute
Manual mapping ArcMap: Analysis>Intersect with the transect (to points), Multipart to Singlepart (for now only multipart i.e. 1 point per transect (slosest to the seaward edge), Near (seaward line)

