/*
 * MATLAB Compiler: 4.7 (R2007b)
 * Date: Fri Nov 27 10:02:21 2009
 * Arguments: "-B" "macro_default" "-o" "B1show" "-W" "main" "-d"
 * "D:\git\B1-GUI\B1show\src" "-T" "link:exe" "-g" "-G" "-w"
 * "enable:specified_file_mismatch" "-w" "enable:repeated_file" "-w"
 * "enable:switch_ignored" "-w" "enable:missing_lib_sentinel" "-w"
 * "enable:demo_license" "D:\git\B1-GUI\B1graphics.m" "-a"
 * "D:\git\B1-GUI\downloaddata.m" "-a" "D:\git\B1-GUI\imageread.m" "-a"
 * "D:\git\B1-GUI\readheader.m" "-a" "D:\git\B1-GUI\B1graphics.fig" 
 */

#include "mclmcr.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_B1show_session_key[] = {
    '8', 'D', '4', 'A', 'A', 'A', 'D', 'D', 'E', '7', 'C', '1', 'F', 'D', '1',
    '4', 'C', '0', '4', 'D', '8', '3', '1', '2', 'D', '3', '4', '4', 'F', '0',
    '7', '4', '3', '8', 'D', '8', 'C', '9', '8', 'D', 'B', '6', 'F', '5', 'C',
    '7', '0', '4', 'C', '5', '2', '6', '4', '3', '9', 'C', 'B', '6', 'C', 'D',
    'E', '5', '1', '7', 'B', 'F', 'E', 'C', '9', '4', 'C', '2', '3', 'E', 'A',
    '3', 'E', '5', 'F', 'E', '2', 'A', 'F', 'C', '2', '3', '5', 'C', '2', 'C',
    'F', '9', '8', 'F', 'E', 'D', '3', '0', '3', 'C', '6', '3', 'D', '9', '7',
    '2', '7', '7', '7', '2', 'E', '5', '9', '3', '8', 'D', 'C', '3', '7', '9',
    '8', 'F', 'A', 'D', '9', '6', '5', 'F', '3', '3', '6', 'A', '8', '7', 'C',
    'C', '2', 'C', '2', 'B', '1', '7', '3', 'C', '0', 'E', 'B', 'D', 'A', 'B',
    '2', '3', 'B', '3', 'F', '7', '5', '1', 'F', 'B', '4', '6', 'E', 'F', '4',
    'D', 'C', 'B', '3', '8', '9', '4', 'C', '6', 'A', '0', '3', '4', '4', 'D',
    'E', '9', '1', '9', '2', '5', 'A', 'B', '8', '6', '5', 'F', '3', 'A', '9',
    '6', '0', '8', '4', '5', '5', '8', '6', 'D', 'E', 'B', '7', '1', '8', 'F',
    '0', 'F', '5', '5', 'C', '5', '5', '2', '0', 'D', 'A', '3', '2', '5', 'C',
    'D', 'B', 'A', '9', '7', '2', '1', 'E', '4', '4', 'C', '1', 'D', 'F', 'E',
    '6', '3', '6', '5', '3', 'A', 'C', 'B', '8', '6', 'E', '4', '1', '0', '6',
    '2', '\0'};

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
  "B1show_A40FC53A290D46182EB35290BF6D7780",

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


