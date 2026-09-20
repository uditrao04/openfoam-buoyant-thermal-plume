Note: This file is written in Markdown (.md) format and can be opened and edited using any text editor or Markdown-compatible editor such as VS Code. In VS Code, press Ctrl + Shift + V to open the rendered Markdown preview.

# Thermal Plume Simulation — Aspect Ratio Effects

This repository contains the OpenFOAM case setup, automation scripts, and ParaView post-processing workflow used to investigate thermal plume behavior for rectangular thermal sources with different aspect ratios.

The aspect-ratio configurations considered are:

- β = 0.1
- β = 0.2
- β = 0.4
- β = 0.6
- β = 0.8
- β = 1.0

The `beta_1.0` case is used as the template for generating the other cases.

---

## Repository Structure

```text
.
├── beta_1.0/
│   ├── 0/
│   ├── constant/
│   ├── system/
│   ├── Allrun
│   └── Allclean
│
├── cleanAll.sh
├── genAll
├── makePlots.py
└── runAll.sh
```

After running `genAll`, the repository contains:

```text
.
├── beta_0.1/
├── beta_0.2/
├── beta_0.4/
├── beta_0.6/
├── beta_0.8/
├── beta_1.0/
│
├── cleanAll.sh
├── genAll
├── makePlots.py
└── runAll.sh
```

---

## 1. Case Generation

### `genAll`

`genAll` generates the aspect-ratio cases used in the study from the `beta_1.0` template.

The generated cases are:

```text
β = 0.1, 0.2, 0.4, 0.6, 0.8, 1.0
```

The script changes only the `halfWidth` value in:

```text
system/blockMeshDict
```

The fixed source dimension is:

```text
halfLength = 0.05 m
```

The corresponding `halfWidth` values are:

| Aspect ratio β | `halfWidth` |
|---:|---:|
| 0.1 | 0.005 m |
| 0.2 | 0.010 m |
| 0.4 | 0.020 m |
| 0.6 | 0.030 m |
| 0.8 | 0.040 m |
| 1.0 | 0.050 m |

### Generate the cases

From the repository root:

```bash
./genAll
```

Existing cases are skipped.

### Replace existing generated cases

```bash
./genAll --force
```

`--force` removes an existing generated case before recreating it from `beta_1.0`. Use this option only when existing case data can be discarded.

### Display help

```bash
./genAll --help
```

`genAll` does not run the simulations. It only creates and verifies the case directories.

---

## 2. Running the Cases

### `runAll.sh`

`runAll.sh` runs `Allrun` inside every immediate subdirectory of the repository.

From the repository root:

```bash
./runAll.sh
```

The equivalent workflow is:

```text
case directory
      ↓
./Allrun
      ↓
OpenFOAM simulation
```

After generating the aspect-ratio cases, the complete workflow is:

```bash
./genAll
./runAll.sh
```

The cases are run sequentially.

The script assumes that each immediate subdirectory contains an `Allrun` script.

---

## 3. Individual Case Execution

Each case contains its own `Allrun` script.

For example:

```bash
cd beta_1.0
./Allrun
```

The simulation workflow is:

```text
blockMesh
    ↓
topoSet
    ↓
createPatch
    ↓
renumberMesh
    ↓
decomposePar
    ↓
buoyantBoussinesqSimpleFoam
    ↓
reconstructPar
```

The solver is executed in parallel using 8 MPI processes:

```bash
mpirun -np 8 buoyantBoussinesqSimpleFoam -parallel
```

The commands are executed in the following order:

```text
1. blockMesh
2. topoSet
3. createPatch -overwrite
4. renumberMesh -overwrite
5. decomposePar -force
6. mpirun -np 8 buoyantBoussinesqSimpleFoam -parallel
7. reconstructPar -latestTime
```

The generated logs are:

```text
log.blockMesh
log.topoSet
log.createPatch
log.renumberMesh
log.decomposePar
log
log.reconstructPar
```

---

## 4. Cleaning a Case

### `Allclean`

Each case contains an `Allclean` script.

For an individual case:

```bash
cd beta_1.0
./Allclean
```

The script removes generated simulation data, including:

- solver logs
- generated time directories
- processor directories
- `constant/polyMesh`
- `postProcessing`
- `.foam` files
- `cleanLog*`
- selected temporary repository metadata

The base case setup and initial conditions are retained.

---

## 5. Cleaning All Cases

### `cleanAll.sh`

`cleanAll.sh` executes `Allclean` inside every immediate subdirectory.

From the repository root:

```bash
./cleanAll.sh
```

This returns the cases to a clean state suitable for another simulation.

The script assumes that each immediate subdirectory contains an `Allclean` script.

---

## 6. ParaView Post-Processing

After completing a simulation, the reconstructed case can be opened in ParaView using:

```bash
paraFoam
```

or through ParaView's case/file interface.

Select the reconstructed case and apply the reader.

The automated post-processing script is:

```text
makePlots.py
```

---

## 7. `makePlots.py`

`makePlots.py` automates line sampling of the simulation results and exports the sampled data as CSV files.

The script obtains the active ParaView source and creates a cell-to-point data representation before performing the line sampling.

### Horizontal profiles

Horizontal sampling lines are created at:

```text
z = 0.05, 0.10, 0.15, ..., 0.95 m
```

Each line extends from:

```text
(0, -0.5, z)
```

to:

```text
(0, 0.5, z)
```

with:

```text
Resolution = 1000
```

The corresponding ParaView pipeline objects are named:

```text
Plot_Z_0.05
Plot_Z_0.10
Plot_Z_0.15
...
Plot_Z_0.95
```

### Centerline

The script also creates a vertical centerline from:

```text
(0, 0, 0)
```

to:

```text
(0, 0, 1)
```

with a resolution of 1000.

The pipeline object is named:

```text
Centerline
```

---

## 8. Running `makePlots.py`

Open the completed case in ParaView and ensure that the required case source is the active source.

Open:

```text
View → Python Shell
```

The Python Shell may appear docked or floating depending on the ParaView configuration.

Use **Run Script** and select:

```text
makePlots.py
```

The script creates the sampling objects and exports the data automatically.

The output directory is:

```text
ParaView Exports/
```

The directory is created automatically if it does not already exist.

---

## 9. ParaView Output

The horizontal sampling produces:

```text
line_z_0.05.csv
line_z_0.10.csv
line_z_0.15.csv
line_z_0.20.csv
line_z_0.25.csv
line_z_0.30.csv
line_z_0.35.csv
line_z_0.40.csv
line_z_0.45.csv
line_z_0.50.csv
line_z_0.55.csv
line_z_0.60.csv
line_z_0.65.csv
line_z_0.70.csv
line_z_0.75.csv
line_z_0.80.csv
line_z_0.85.csv
line_z_0.90.csv
line_z_0.95.csv
```

The centerline produces:

```text
centerline.csv
```

Therefore:

```text
ParaView Exports/
├── line_z_0.05.csv
├── line_z_0.10.csv
├── ...
├── line_z_0.95.csv
└── centerline.csv
```

These CSV files contain the sampled data generated by ParaView and can be used for subsequent analysis and plotting.

---

## 10. Line Chart Visualization

After `makePlots.py` has executed, the generated `Plot_Z_*` and `Centerline` objects are available in the Pipeline Browser.

To visualize a profile:

1. Select the required `Plot_Z_*` or `Centerline` object.
2. Create a **Line Chart View**.
3. Enable the required variable from the Pipeline Browser.
4. Select the required field association and variable for plotting.

The available variables depend on the fields loaded from the simulation results.

---

## 11. Complete Workflow

Starting with the repository containing `beta_1.0`:

### Generate the aspect-ratio cases

```bash
./genAll
```

### Run all cases

```bash
./runAll.sh
```

### Open a completed case

For example:

```bash
cd beta_0.4
paraFoam
```

### Run the ParaView extraction

In ParaView:

```text
View → Python Shell → Run Script → makePlots.py
```

The extracted data are written to:

```text
ParaView Exports/
```

### Clean all cases when required

From the repository root:

```bash
./cleanAll.sh
```

---

## 12. Script Summary

| Script | Function |
|---|---|
| `genAll` | Generates the six aspect-ratio cases from `beta_1.0` |
| `runAll.sh` | Runs `Allrun` for each case |
| `cleanAll.sh` | Runs `Allclean` for each case |
| `Allrun` | Executes the mesh, preprocessing, solver, and reconstruction workflow |
| `Allclean` | Removes generated case data |
| `makePlots.py` | Performs automated ParaView line sampling and CSV export |

---

## 13. Aspect-Ratio Definition

The aspect ratio is varied by changing the heat-source width while keeping the other source dimension fixed.

The template uses:

```text
halfLength = 0.05 m
```

and `genAll` modifies:

```text
halfWidth
```

according to:

\[
\beta = \frac{\text{halfWidth}}{\text{halfLength}}
\]

Thus:

```text
β = 1.0  → halfWidth = 0.050 m
β = 0.8  → halfWidth = 0.040 m
β = 0.6  → halfWidth = 0.030 m
β = 0.4  → halfWidth = 0.020 m
β = 0.2  → halfWidth = 0.010 m
β = 0.1  → halfWidth = 0.005 m
```

All other case settings are inherited from the `beta_1.0` template.

---

## 14. Notes

- `beta_1.0` is the template case for case generation.
- `genAll` generates only the six aspect ratios listed above.
- `genAll` does not execute OpenFOAM.
- `runAll.sh` executes the cases sequentially.
- The solver is run with 8 MPI processes in `Allrun`.
- `makePlots.py` must be executed with the relevant case loaded as the active ParaView source.
- Generated CSV files are stored separately in `ParaView Exports/`.
- Use `--force` with `genAll` only when existing generated cases may safely be replaced.
