# This is a Paraview Python Script derived from a Paraview Trace.
# Refer to README.md for instructions on running it.

from paraview.simple import *
import os

script_dir = os.path.dirname(os.path.abspath(__file__))
output_dir = os.path.join(script_dir, "ParaView Exports")

os.makedirs(output_dir, exist_ok=True)
source = GetActiveSource()
source = CellDatatoPointData(Input=source)

for i in range(1, 20):

    z = round(i * 0.05, 2)

    pol = PlotOverLine(Input=source)

    pol.Point1 = [0.0, -0.5, z]
    pol.Point2 = [0.0,  0.5, z]

    pol.Resolution = 1000

    RenameSource("Plot_Z_{:.2f}".format(z), pol)

    filename = os.path.join(
        output_dir,
        "line_z_{:.2f}.csv".format(z)
    )

    SaveData(filename, proxy=pol)

# Centerline: (0,0,0) -> (0,0,1)

pol = PlotOverLine(Input=source)

pol.Point1 = [0.0, 0.0, 0.0]
pol.Point2 = [0.0, 0.0, 1.0]

pol.Resolution = 1000

RenameSource("Centerline", pol)

filename = os.path.join(
    output_dir,
    "centerline.csv"
)

SaveData(filename, proxy=pol)

print("DONE")