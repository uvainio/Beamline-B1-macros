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

#include <stdio.h>
#include "mclmcr.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_B1show_component_data;

#ifdef __cplusplus
}
#endif

static HMCRINSTANCE _mcr_inst = NULL;


#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_B1show_C_API 
#define LIB_B1show_C_API /* No special import/export declaration */
#endif

LIB_B1show_C_API 
bool MW_CALL_CONV B1showInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstance(&_mcr_inst, &__MCC_B1show_component_data,
                                      true, NoObjectType, ExeTarget,
                                      error_handler, print_handler))
    return false;
  return true;
}

LIB_B1show_C_API 
bool MW_CALL_CONV B1showInitialize(void)
{
  return B1showInitializeWithHandlers(mclDefaultErrorHandler,
                                      mclDefaultPrintHandler);
}

LIB_B1show_C_API 
void MW_CALL_CONV B1showTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

int run_main(int argc, const char **argv)
{
  int _retval;
  /* Generate and populate the path_to_component. */
  char path_to_component[(PATH_MAX*2)+1];
  separatePathName(argv[0], path_to_component, (PATH_MAX*2)+1);
  __MCC_B1show_component_data.path_to_component = path_to_component; 
  if (!B1showInitialize()) {
    return -1;
  }
  _retval = mclMain(_mcr_inst, argc, argv, "B1graphics", 0);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  B1showTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_B1show_component_data.runtime_options,
    __MCC_B1show_component_data.runtime_option_count))
    return 0;
  
  return mclRunMain(run_main, argc, argv);
}
