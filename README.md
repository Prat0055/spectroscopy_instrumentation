# Spectroscopy Instrumentation and Spectral Analysis Framework

MATLAB-based instrumentation and analysis framework for high-resolution atomic spectroscopy using a Czerny–Turner spectrometer coupled to CMOS detector systems and hollow cathode lamp plasma sources.

This repository combines:

- spectrometer syntony control,
- detector acquisition,
- shutter and mirror control,
- slit-curvature calibration,
- wavelength calibration,
- detector-image processing,
- spectral extraction,
- response-function handling,
- and interactive spectral-line identification.

The software was developed within the Atomic Spectroscopy Laboratory (AstroLab-Uva), Universidad de Valladolid, Spain.

---

# Repository Structure

```text
spectroscopy_instrumentation/
│
├── README.md
├── LICENSE
├── CITATION.cff
├── .gitignore
│
├── Prg/
│   ├── Optical_Parameters_Change.mlapp
│   ├── Optical_Parameters_Change_new_mirror.mlapp
│   ├── OpenDevice.m
│   ├── DefineMotor.m
│   ├── SpinMotor.m
│   ├── Calibration.xlsx
│   ├── Response_function_deuterium.xlsx
│   ├── Response_function_tungsten.xlsx
│   ├── dispersion.mat
│   ├── circle_parameters.mat
│   └── parabola_parameters.mat
│
├── Curvature calibration/
│   ├── obtain_circle_parameters.m
│   ├── obtain_parabola_parameters.m
│   ├── calculate_circular_spectra.m
│   ├── calculate_parabolic_spectra.m
│   ├── example detector images
│   └── calibration parameter files
│
├── Identified lines/
│   ├── recover.m
│   ├── plot_identified_lines.mlapp
│   └── saved identified spectra
│
├── identify_lines.mlapp
├── lines.xlsx
├── example.xlsx
├── dispersion.mat
│
└── Resolution_slit_width/
    ├── plot_res.m
    └── example.xlsx
```

---

# Scientific Purpose

The repository provides a complete workflow for experimental optical spectroscopy, beginning from hardware control and detector acquisition and extending to curvature correction, wavelength calibration, spectral extraction, and spectral-line identification.

The framework was developed for:

- high-resolution atomic spectroscopy,
- hollow cathode lamp measurements,
- rare-earth element spectroscopy,
- wavelength-calibrated spectral acquisition,
- detector-response correction,
- slit-curvature correction,
- and laboratory astrophysics applications.

---

# Experimental Hardware Requirements

The instrumentation applications inside:

```text
Prg/
```

were developed for a specific experimental spectroscopy setup. Proper operation requires compatible hardware and communication interfaces.

## Main Experimental Components

### Spectrometer

- Czerny–Turner spectrometer
- Motor-controlled grating rotation
- Motor-controlled slit mechanisms

### Detector

- CMOS detector system
- MATLAB-compatible acquisition support
- Detector images saved and processed through MATLAB

### Plasma Source

- Hollow cathode lamp source
- Stable current power supply

### Motion and Hardware Control

The App Designer applications communicate with:

- stepper motors,
- shutters,
- mirrors,
- and detector hardware

through GPIB-based instrumentation control.

### Communication Requirements

The repository assumes:

- MATLAB Instrument Control support
- GPIB communication access
- Agilent-compatible device communication
- MATLAB App Designer support

---

# MATLAB Requirements

Recommended:

- MATLAB R2024a or newer

Recommended MATLAB Toolboxes:

- MATLAB App Designer
- Image Processing Toolbox
- Curve Fitting Toolbox
- Optimization Toolbox
- Instrument Control Toolbox

---

# Main Instrumentation Applications

Located in:

```text
Prg/
```

Main applications:

```text
Optical_Parameters_Change.mlapp
Optical_Parameters_Change_new_mirror.mlapp
```

The applications provide:

- spectrometer syntony control,
- detector acquisition,
- shutter and mirror control,
- slit control,
- ROI selection,
- live spectra visualisation,
- spectral export,
- and curvature-corrected spectral extraction.

---

# IMPORTANT FIRST STEP — Curvature Calibration

Before measurements can properly be performed, slit-curvature calibration must first be completed.

If no calibration files exist, the user MUST first press:

```text
Calibrate Curvature
```

inside the instrumentation application.

The software will then display instructions that must be followed carefully.

The calibration workflow generates:

```text
circle_parameters.mat
parabola_parameters.mat
```

inside:

```text
Curvature calibration/
```

These files contain the fitted slit-curvature parameters.

---

# Required Calibration File Transfer

After the curvature calibration is completed:

```text
circle_parameters.mat
parabola_parameters.mat
```

must be copied from:

```text
Curvature calibration/
```

into:

```text
Prg/
```

before spectral measurements are taken.

Without these files, curvature-corrected spectral extraction may fail or produce incorrect spectra.

---

# Recommended Experimental Workflow

```text
1. Run curvature calibration
                ↓
2. Follow instructions displayed by the software
                ↓
3. Generate:
        circle_parameters.mat
        parabola_parameters.mat
                ↓
4. Copy both files into:
        Prg/
                ↓
5. Run instrumentation application
                ↓
6. Acquire spectra
                ↓
7. Export corrected spectral files
                ↓
8. Run identify_lines.mlapp
                ↓
9. Identify spectral lines
                ↓
10. Run recover.m
                ↓
11. Run plot_identified_lines.mlapp
                ↓
12. Save PNG spectra outputs
```

---

# Slit Curvature Analysis

Located in:

```text
Curvature calibration/
```

These routines determine the geometric curvature of the monochromator entrance slit from detector images.

The routines:

- detect slit-image maxima,
- fit circular and parabolic models,
- determine curvature parameters,
- and extract spectra along curved detector geometries.

Main routines:

```matlab
obtain_circle_parameters.m
obtain_parabola_parameters.m
calculate_circular_spectra.m
calculate_parabolic_spectra.m
```

The methodology accompanies the report:

> Analysis of Slit Curvature Using Image Processing  
> DOI: 10.5281/zenodo.14002840

---

# Spectral Line Identification

After measurements are completed, the spectral-line identification workflow is performed using:

```text
identify_lines.mlapp
```

The application allows:

- loading measured spectra,
- wavelength conversion,
- overlaying previously reported transitions,
- interactive spectral alignment,
- line identification,
- and exporting labelled spectra.

---

# Required Files for Spectral Identification

The following files are required in the working directory:

```text
identify_lines.mlapp
dispersion.mat
lines.xlsx
measured_spectrum.xlsx
```

---

# NIST Line List Requirement

The line list used for identification must be stored in an Excel file following the SAME format as:

```text
lines.xlsx
```

The included:

```text
lines.xlsx
```

is only an example template.

The user should replace or extend it using spectral-line data downloaded from:

- NIST Atomic Spectra Database

The formatting structure must remain compatible with the application.

---

# Example Measured Spectrum

An example experimentally measured spectrum is provided:

```text
example.xlsx
```

This file demonstrates the expected format of exported spectral measurements.

---

# Recover and Plot Workflow

Each time:

```text
identify_lines.mlapp
```

is executed, the following workflow should be followed.

## Step 1 — Run recover.m

Located in:

```text
Identified lines/
```

Run:

```matlab
recover
```

This restores and prepares the spectral-identification environment for plotting and saving.

---

## Step 2 — Run plot_identified_lines.mlapp

Then run:

```text
plot_identified_lines.mlapp
```

This application is used to:

- visualise identified spectra,
- generate PNG outputs,
- and save labelled spectral plots.

---

# Resolution and Slit Width Analysis

Located in:

```text
Resolution_slit_width/
```

Contains scripts used for:

- slit-width studies,
- spectral-resolution measurements,
- and detector-resolution analysis.

---

# Notes on Calibration Files

The repository contains instrument-specific calibration products such as:

```text
dispersion.mat
circle_parameters.mat
parabola_parameters.mat
```

These may need to be regenerated if:

- detector geometry changes,
- slit alignment changes,
- optical alignment changes,
- camera positioning changes,
- or spectrometer configuration changes.

---

# Scientific Context

The framework was developed for high-resolution spectroscopy of hollow cathode lamp plasmas and rare-earth elements using:

- Czerny–Turner spectrometers,
- CMOS detector systems,
- wavelength-calibrated optical spectroscopy,
- and curved spectral extraction techniques.

Applications include:

- transition probability measurements,
- branching fraction analysis,
- wavelength calibration,
- detector-response correction,
- and laboratory astrophysics.

---

# Citation

If this software is used in academic work, please cite:

```text
CITATION.cff
```

and additionally:

> Sen Sarma, P. R., Belmonte Sainz-Ezquerra, M. T., & Mar, S.  
> Analysis of Slit Curvature Using Image Processing  
> Zenodo (2024)  
> DOI: 10.5281/zenodo.14002840

---

# Authors

Pratyush Ranjan Sen Sarma  
AstroLab-Uva  
Universidad de Valladolid  
Spain

María Teresa Belmonte Sainz-Ezquerra  
AstroLab-Uva  
Universidad de Valladolid  
Spain

Santiago Mar  
AstroLab-Uva  
Universidad de Valladolid  
Spain
