# CliffDelineaTool
<em>CliffDelineaTool</em> is a tool to map coastal cliffs by finding cliff base and top positions from topographic data.</br>
It assumes that if a coast is described by a series of coastline-normal transects, a cliff base and a cliff top position can be identified for individual transects based on elevation, across-shore location and spatial relationships with other points along the transects.</br></br>
The MATLAB script takes as input a text file with a series of points conrtaining the following information:
- point ID
- transect ID 
- elevation
- distance from the seaward end of the transect

<b>FAQ</b>
a.	How to generate cross-shore transects and points?

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

b.	Does it matter how long the transects are?
c.	How to space transects alongshore?
d.	How to space points along transects?
e.	How to set cliff base max elevation?
f.	How calibrated parameters depend on the settings (plunging cliffs, trees, buildings, roads), cliff morphology (cross-shore and alongshore), DEM resolution, transect spacing and point spacing?
g.	Do the parameters need to be calibrated if used elsewhere?
h.	How to implement the output in GIS?
ArcMap: Add Join, Select by Attribute
Manual mapping ArcMap: Analysis>Intersect with the transect (to points), Multipart to Singlepart (for now only multipart i.e. 1 point per transect (slosest to the seaward edge), Near (seaward line)
i.	What happens if a transect does not have a cliff base and/or top location?
j.	Why was the transect-based model used?
k.	Why existing models were not used?
