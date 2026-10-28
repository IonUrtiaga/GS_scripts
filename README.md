# Projected Persistent Northward Shift of the Gulf Stream under Climate Warming

Code for Urtiaga-Chasco et al. (2026, Nature Geoscience)

**Code author:** Ion Urtiaga-Chasco — ion.urtiaga@ulpgc.es  
Unidad Océano y Clima, IOCAG, Universidad de Las Palmas de Gran Canaria (ULPGC), Spain

---

## Requirements

- **MATLAB R2025b** + Statistics and Machine Learning Toolbox
- Third-party toolboxes:
  - [m_map](https://www.eoas.ubc.ca/~rich/map.html), [brewermap](https://github.com/DrosteEffect/BrewerMap), [cmocean](https://github.com/chadagreene/cmocean), [tight_subplot](https://www.mathworks.com/matlabcentral/fileexchange/27991)
  - [daynoleap2datenum](https://github.com/kakearney/daynoleap2datenum-pkg)

---

## Setup

Clone or download this repository to any local directory. Before running any script, create the following two subdirectories inside `GS-scripts/`:

```bash
mkdir mat   % will store intermediate .mat files
mkdir pdf   % will store generated figures
```

## Repository Structure

```
GS-scripts/
├── README.md
├── functions/    % core functions
├── save_*.m      % scripts generating intermediate .mat files
├── plot_Fig*.m   % scripts reproducing main figures
├── mat/          % create this folder locally (not included in repo)
└── pdf/          % create this folder locally (not included in repo)
```

### functions/
| File | Description |
|---|---|
| `GS_path.m` | Extracts the Gulf Stream path from ADT |
| `GS_Index.m` | Gulf Stream Index (GSI) following Pérez-Hernández & Joyce (2013) |
| `GS_Index_km.m` | Converts GSI to km using the MDT gradient |
| `GSPI.m` | Gulf Stream Path Index (GSPI): mean GS latitude between 72°W–52°W |
| `GSDI.m` | GS Destabilization Index (GSDI) following Andres (2016) |
| `timenc2datenum.m` | Converts NetCDF time to MATLAB datenum |

### save/
| File | Output | Description |
|---|---|---|
| `save_GSI.m` | `GSI_all.mat` | GSI and GSPI for all CMIP6/HighResMIP models and DUACS |
| `save_GSDI.m` | `GSDI_all.mat` | GSDI for all models and DUACS |
| `save_GS_periods.m` | `time_MxMn_{r}.mat` | Northward/southward GS states (1900–1940 and 2050–2090) |
| `save_MxMn.m` | `{var}_MxMn_{r}.mat` | Composites of tas, hus, P-E, WSC for N/S GS states |

### figures/
| File | Figure |
|---|---|
| `plot_Fig1.m` | Figure 1: GSI/GSPI maps and time series |
| `plot_Fig2.m` | Figure 2: GSDI time series (CanESM5-1, 1850–2100) |
| `plot_Fig3.m` | Figure 3: Composite differences for N/S GS states |

---

## Data

DUACS altimetry products are available via CMEMS ([all-sat](https://doi.org/10.48670/moi-00148), [two-sat](https://doi.org/10.48670/moi-00145)). CMIP6 and HighResMIP model outputs are available through the [Earth System Grid Federation (ESGF)](https://esgf-node.llnl.gov/search/cmip6/). Variables used: zos, tas, tos, psl, pr, hus, evspsbl, ua, va, ugos, vgos. Pre-computed `.mat` files are available upon request to the corresponding author.

---

## Execution Order

```matlab
save_GSI.m          % → GSI_all.mat  (required by all subsequent scripts)
save_GSDI.m         % → GSDI_all.mat
save_GS_periods.m   % → time_MxMn_{r}.mat  (requires GSI_all.mat)
save_MxMn.m         % → {var}_MxMn_{r}.mat  (requires time_MxMn_{r}.mat)

plot_Fig1.m         % requires GSI_all.mat
plot_Fig2.m         % requires GSDI_all.mat
plot_Fig3.m         % requires GSI_all.mat + {var}_MxMn_{r}.mat
```
