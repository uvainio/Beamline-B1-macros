/*
 * MATLAB Compiler: 4.7 (R2007b)
 * Date: Tue Apr 20 09:23:56 2010
 * Arguments: "-B" "macro_default" "-o" "B1show" "-W" "main" "-d"
 * "D:\git\Beamline-B1-macros\B1-GUI\B1show\src" "-T" "link:exe" "-g" "-G" "-w"
 * "enable:specified_file_mismatch" "-w" "enable:repeated_file" "-w"
 * "enable:switch_ignored" "-w" "enable:missing_lib_sentinel" "-w"
 * "enable:demo_license" "D:\git\Beamline-B1-macros\B1-GUI\B1graphics.m" "-a"
 * "D:\git\Beamline-B1-macros\B1-GUI\downloaddata.m" "-a"
 * "D:\git\Beamline-B1-macros\B1-GUI\imageread.m" "-a"
 * "D:\git\Beamline-B1-macros\B1-GUI\readheader.m" "-a"
 * "D:\git\Beamline-B1-macros\B1-GUI\B1graphics.fig" 
 */

#include "mclmcr.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_B1show_session_key[] = {
    '6', '3', '4', 'B', '7', '7', 'F', '8', 'E', '6', '1', 'B', '5', '3', 'C',
    '8', '8', 'C', '2', 'C', '6', '5', 'E', 'F', '2', 'C', 'D', '7', '0', '8',
    '6', '4', '0', 'A', '2', '6', '1', 'A', '9', 'D', 'F', '0', 'E', '5', '1',
    '7', '8', 'B', '7', 'F', '8', '6', 'B', '2', '5', 'E', 'D', '0', '5', 'A',
    'A', '5', '6', '2', 'E', '5', '7', 'B', '4', 'B', '1', 'E', '9', '4', 'F',
    '0', '6', 'C', '5', 'E', 'F', 'E', '9', 'D', 'E', '0', '7', '1', '2', 'F',
    '5', '0', 'D', '8', '6', '9', 'B', '6', '6', 'A', 'C', '1', 'D', '0', '4',
    '2', 'D', '9', 'F', '4', 'F', '4', 'C', 'B', '5', '5', 'C', '7', '6', '7',
    'F', '1', '3', 'A', 'C', '3', '6', '2', 'C', '8', '3', '8', 'E', 'E', 'F',
    'A', '6', 'F', 'F', '1', '2', 'B', '3', '9', '5', 'C', '2', '6', '6', '7',
    '4', '0', 'C', '4', 'F', 'C', 'C', '0', '7', 'F', '6', 'D', '0', 'C', '2',
    'E', '9', '2', '2', '9', '1', '7', 'A', '4', '8', 'C', 'E', 'C', '6', '0',
    '4', '7', '9', '3', '2', '6', '1', '4', '9', '5', '6', '8', '2', '3', '7',
    'C', '3', '1', 'B', 'A', '1', '6', '0', '8', '5', '7', 'F', 'B', 'F', '5',
    'E', '0', '2', '6', '2', '6', 'F', '3', 'B', '9', 'A', '4', '4', '6', '9',
    'D', 'F', '0', '8', '2', '3', 'B', '9', '5', 'C', 'E', 'D', '1', '1', 'F',
    '6', 'A', '8', '3', '7', 'A', 'D', '8', '3', '4', 'A', '8', '7', '1', '4',
    'F', '\0'};

const unsigned char __MCC_B1show_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_B1show_matlabpath_data[] = 
  { "B1show/", "toolbox/compiler/deploy/",
    "win.desy.de/home/b1user/My Documents/MATLAB/",
    "$TOOLBOXMATLABDIR/general/", "$TOOLBOXMATLABDIR/ops/",
    "$TOOLBOXMATLABDIR/lang/", "$TOOLBOXMATLABDIR/elmat/",
    "$TOOLBOXMATLABDIR/elfun/", "$TOOLBOXMATLABDIR/specfun/",
    "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/datafun/",
    "$TOOLBOXMATLABDIR/polyfun/", "$TOOLBOXMATLABDIR/funfun/",
    "$TOOLBOXMATLABDIR/sparfun/", "$TOOLBOXMATLABDIR/scribe/",
    "$TOOLBOXMATLABDIR/graph2d/", "$TOOLBOXMATLABDIR/graph3d/",
    "$TOOLBOXMATLABDIR/specgraph/",
    "$TOOLBOXMATLABDIR/graphics/", "$TOOLBOXMATLABDIR/uitools/",
    "$TOOLBOXMATLABDIR/strfun/", "$TOOLBOXMATLABDIR/imagesci/",
    "$TOOLBOXMATLABDIR/iofun/", "$TOOLBOXMATLABDIR/audiovideo/",
    "$TOOLBOXMATLABDIR/timefun/", "$TOOLBOXMATLABDIR/datatypes/",
    "$TOOLBOXMATLABDIR/verctrl/", "$TOOLBOXMATLABDIR/codetools/",
    "$TOOLBOXMATLABDIR/helptools/", "$TOOLBOXMATLABDIR/winfun/",
    "$TOOLBOXMATLABDIR/demos/", "$TOOLBOXMATLABDIR/timeseries/",
    "$TOOLBOXMATLABDIR/hds/", "$TOOLBOXMATLABDIR/guide/",
    "$TOOLBOXMATLABDIR/plottools/", "toolbox/local/" };

static const char * MCC_B1show_classpath_data[] = 
  { "" };

static const char * MCC_B1show_libpath_data[] = 
  { "" };

static const char * MCC_B1show_app_opts_data[] = 
  { "" };

static const char * MCC_B1show_run_opts_data[] = 
  { "" };

static const char * MCC_B1show_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_B1show_component_data = { 

  /* Public key data */
  __MCC_B1show_public_key,

  /* Component name */
  "B1show",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_B1show_session_key,

  /* Component's MATLAB Path */
  MCC_B1show_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  36,

  /* Component's Java class path */
  MCC_B1show_classpath_data,
  /* Number of directories in the Java class path */
  0,

  /* Component's load library path (for extra shared libraries) */
  MCC_B1show_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_B1show_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_B1show_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "B1show_56C051488178987BE27C5CF6299C1DDA",

  /* MCR warning status data */
  MCC_B1show_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


