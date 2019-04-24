########################## NOTES ###############################################
# This files goal is to take CMake options found in kokkos_options.cmake but 
# possibly set from elsewhere 
#   (see: trilinos/cmake/ProjectCOmpilerPostConfig.cmake) 
# using CMake idioms and map them onto the KOKKOS_SETTINGS variables that gets 
# passed to the kokkos makefile configuration:
#  make -f ${CMAKE_SOURCE_DIR}/core/src/Makefile ${KOKKOS_SETTINGS} build-makefile-cmake-kokkos
# that generates KokkosCore_config.h and kokkos_generated_settings.cmake
# To understand how to form KOKKOS_SETTINGS, see
#     <KOKKOS_PATH>/Makefile.kokkos

#-------------------------------------------------------------------------------
#------------------------------- GENERAL OPTIONS -------------------------------
#-------------------------------------------------------------------------------

# Ensure that KOKKOS_ARCH is in the ARCH_LIST
if (KOKKOS_ARCH MATCHES ",")
  message("-- Detected a comma in: KOKKOS_ARCH=`${KOKKOS_ARCH}`")
  message("-- Although we prefer KOKKOS_ARCH to be semicolon-delimited, we do allow")
  message("-- comma-delimited values for compatibility with scripts (see github.com/trilinos/Trilinos/issues/2330)")
  string(REPLACE "," ";" KOKKOS_ARCH "${KOKKOS_ARCH}")
  message("-- Commas were changed to semicolons, now KOKKOS_ARCH=`${KOKKOS_ARCH}`")
endif()
foreach(arch ${KOKKOS_ARCH})
  list(FIND KOKKOS_ARCH_LIST ${arch} indx)
  if (indx EQUAL -1)
    message(FATAL_ERROR "`${arch}` is not an accepted value in KOKKOS_ARCH=`${KOKKOS_ARCH}`."
      "  Please pick from these choices: ${KOKKOS_INTERNAL_ARCH_DOCSTR}")
  endif ()
endforeach()

# KOKKOS_SETTINGS uses KOKKOS_ARCH
string(REPLACE ";" "," KOKKOS_GMAKE_ARCH "${KOKKOS_ARCH}")

# From Makefile.kokkos: Options: yes,no
if(${KOKKOS_ENABLE_DEBUG})
  set(KOKKOS_GMAKE_DEBUG yes)
else()
  set(KOKKOS_GMAKE_DEBUG no)
endif()

#------------------------------- KOKKOS_DEVICES --------------------------------
# Can have multiple devices 
set(KOKKOS_DEVICESl)
foreach(devopt ${KOKKOS_DEVICES_LIST})
  string(TOUPPER ${devopt} devoptuc)
  if (${KOKKOS_ENABLE_${devoptuc}}) 
    list(APPEND KOKKOS_DEVICESl ${devopt})
  endif ()
endforeach()
# List needs to be comma-delmitted
string(REPLACE ";" "," KOKKOS_GMAKE_DEVICES "${KOKKOS_DEVICESl}")

#------------------------------- KOKKOS_OPTIONS --------------------------------
# From Makefile.kokkos: Options: aggressive_vectorization,disable_profiling,disable_deprecated_code
#compiler_warnings, aggressive_vectorization, disable_profiling, disable_dualview_modify_check, enable_profile_load_print

set(KOKKOS_OPTIONSl)
if(${KOKKOS_ENABLE_COMPILER_WARNINGS})
      list(APPEND KOKKOS_OPTIONSl compiler_warnings)
endif()
if(${KOKKOS_ENABLE_AGGRESSIVE_VECTORIZATION})
      list(APPEND KOKKOS_OPTIONSl aggressive_vectorization)
endif()
if(NOT ${KOKKOS_ENABLE_PROFILING})
      list(APPEND KOKKOS_OPTIONSl disable_profiling)
endif()
if(NOT ${KOKKOS_ENABLE_DEPRECATED_CODE})
      list(APPEND KOKKOS_OPTIONSl disable_deprecated_code)
endif()
if(NOT ${KOKKOS_ENABLE_DEBUG_DUALVIEW_MODIFY_CHECK})
      list(APPEND KOKKOS_OPTIONSl disable_dualview_modify_check)
endif()
if(${KOKKOS_ENABLE_PROFILING_LOAD_PRINT})
      list(APPEND KOKKOS_OPTIONSl enable_profile_load_print)
endif()
if(${KOKKOS_ENABLE_EXPLICIT_INSTANTIATION} OR ${KOKKOS_ENABLE_ETI})
      list(APPEND KOKKOS_OPTIONSl enable_eti)
endif()
# List needs to be comma-delimitted
string(REPLACE ";" "," KOKKOS_GMAKE_OPTIONS "${KOKKOS_OPTIONSl}")


#------------------------------- KOKKOS_USE_TPLS -------------------------------
# Construct the Makefile options
set(KOKKOS_USE_TPLSl)
foreach(tplopt ${KOKKOS_USE_TPLS_LIST})
  if (${KOKKOS_ENABLE_${tplopt}}) 
    list(APPEND KOKKOS_USE_TPLSl ${KOKKOS_INTERNAL_${tplopt}})
  endif ()
endforeach()
# List needs to be comma-delimitted
string(REPLACE ";" "," KOKKOS_GMAKE_USE_TPLS "${KOKKOS_USE_TPLSl}")


#------------------------------- KOKKOS_CUDA_OPTIONS ---------------------------
# Construct the Makefile options
set(KOKKOS_CUDA_OPTIONSl)
foreach(cudaopt ${KOKKOS_CUDA_OPTIONS_LIST})
  if (${KOKKOS_ENABLE_CUDA_${cudaopt}})
    list(APPEND KOKKOS_CUDA_OPTIONSl ${KOKKOS_INTERNAL_${cudaopt}})
  endif ()
endforeach()
# List needs to be comma-delmitted
string(REPLACE ";" "," KOKKOS_GMAKE_CUDA_OPTIONS "${KOKKOS_CUDA_OPTIONSl}")

#------------------------------- PATH VARIABLES --------------------------------
#  Want makefile to use same executables specified which means modifying
#  the path so the $(shell ...) commands in the makefile see the right exec
#  Also, the Makefile's use FOO_PATH naming scheme for -I/-L construction
#TODO:  Makefile.kokkos allows this to be overwritten? ROCM_HCC_PATH

set(KOKKOS_INTERNAL_PATHS)
set(addpathl)
foreach(kvar IN LISTS KOKKOS_USE_TPLS_LIST ITEMS CUDA QTHREADS)
  if(${KOKKOS_ENABLE_${kvar}})
    if(DEFINED KOKKOS_${kvar}_DIR)
      set(KOKKOS_INTERNAL_PATHS ${KOKKOS_INTERNAL_PATHS} "${kvar}_PATH=${KOKKOS_${kvar}_DIR}")
      if(IS_DIRECTORY ${KOKKOS_${kvar}_DIR}/bin)
        list(APPEND addpathl ${KOKKOS_${kvar}_DIR}/bin)
      endif()
    endif()
  endif()
endforeach()
# Path env is : delimitted
string(REPLACE ";" ":" KOKKOS_INTERNAL_ADDTOPATH "${addpathl}")


######################### SET KOKKOS_SETTINGS ##################################
# Set the KOKKOS_SETTINGS String -- this is the primary communication with the
# makefile configuration.  See Makefile.kokkos

set(KOKKOS_SETTINGS KOKKOS_CMAKE=yes)
if(KOKKOS_HAS_TRILINOS)
  set(KOKKOS_SETTINGS ${KOKKOS_SETTINGS} KOKKOS_TRIBITS=yes)
else()
  set(KOKKOS_SETTINGS ${KOKKOS_SETTINGS} KOKKOS_STANDALONE_CMAKE=yes)
endif()
set(KOKKOS_SETTINGS ${KOKKOS_SETTINGS} KOKKOS_SRC_PATH=${KOKKOS_SRC_PATH})
set(KOKKOS_SETTINGS ${KOKKOS_SETTINGS} KOKKOS_PATH=${KOKKOS_PATH})
set(KOKKOS_SETTINGS ${KOKKOS_SETTINGS} KOKKOS_INSTALL_PATH=${CMAKE_INSTALL_PREFIX})

# Form of KOKKOS_foo=$KOKKOS_foo
foreach(kvar ARCH;DEVICES;DEBUG;OPTIONS;CUDA_OPTIONS;USE_TPLS)
  if(DEFINED KOKKOS_GMAKE_${kvar})
    if (NOT "${KOKKOS_GMAKE_${kvar}}" STREQUAL "")
      set(KOKKOS_SETTINGS ${KOKKOS_SETTINGS} KOKKOS_${kvar}=${KOKKOS_GMAKE_${kvar}})
    endif()
  endif()
endforeach()

# Form of VAR=VAL
#TODO:  Makefile supports MPICH_CXX, OMPI_CXX as well
foreach(ovar CXX;CXXFLAGS;LDFLAGS)
  if(DEFINED ${ovar})
    if (NOT "${${ovar}}" STREQUAL "")
      set(KOKKOS_SETTINGS ${KOKKOS_SETTINGS} ${ovar}=${${ovar}})
    endif()
  endif()
endforeach()

# Finally, do the paths
if (NOT "${KOKKOS_INTERNAL_PATHS}" STREQUAL "")
  set(KOKKOS_SETTINGS ${KOKKOS_SETTINGS} ${KOKKOS_INTERNAL_PATHS})
endif()
if (NOT "${KOKKOS_INTERNAL_ADDTOPATH}" STREQUAL "")
  set(KOKKOS_SETTINGS ${KOKKOS_SETTINGS} "PATH=${KOKKOS_INTERNAL_ADDTOPATH}:$ENV{PATH}")
endif()

SET(KOKKOS_CXX_STANDARD "" CACHE STRING "The C++ standard for Kokkos to use: c++11, c++14, or c++17")
SET(KOKKOS_CXX_FEATURES "" CACHE STRING "The list of C++ features for Kokkos to enable")
SET(CXX_STANDARD_TEST)

IF (KOKKOS_CXX_STANDARD AND CMAKE_CXX_STANDARD)
  #make sure these are consistent
  IF (${KOKKOS_CXX_STANDARD} STREQUAL "c++11")
    IF(NOT ${CMAKE_CXX_STANDARD} STREQUAL "11")
      SET(CXX_STD_ERROR ON)
    ENDIF()
  ELSEIF (${KOKKOS_CXX_STANDARD} STREQUAL "c++14")
    IF(NOT ${CMAKE_CXX_STANDARD} STREQUAL "14")
      SET(CXX_STD_ERROR ON)
    ENDIF()
  ELSEIF (${KOKKOS_CXX_STANDARD} STREQUAL "c++17")
    IF(NOT ${CMAKE_CXX_STANDARD} STREQUAL "17")
      SET(CXX_STD_ERROR ON)
    ENDIF()
  ELSE()
    #KOKKOS_CXX_STANDARD is something else, which means definitely invalid
    SET(CXX_STD_ERROR ON)
  ENDIF()
  IF (CXX_STD_ERROR)
    MESSAGE(FATAL_ERROR "Specified both CMAKE_CXX_STANDARD and KOKKOS_CXX_STANDARD, but they don't match")
  ENDIF()
ENDIF()

IF (NOT KOKKOS_CXX_STANDARD AND NOT CMAKE_CXX_STANDARD)
  SET(KOKKOS_CXX_STANDARD "c++11")
ENDIF()

IF (KOKKOS_CXX_STANDARD)
  IF (${KOKKOS_CXX_STANDARD} STREQUAL "c++11")
    LIST(APPEND KOKKOS_CXX_FEATURES cxx_std_11)
  ELSEIF(${KOKKOS_CXX_STANDARD} STREQUAL "c++14")
    LIST(APPEND KOKKOS_CXX_FEATURES cxx_std_14)
  ELSEIF(${KOKKOS_CXX_STANDARD} STREQUAL "c++17")
    LIST(APPEND KOKKOS_CXX_FEATURES cxx_std_17)
  ENDIF()
ENDIF()

IF (CMAKE_CXX_STANDARD)
  IF (${CMAKE_CXX_STANDARD} STREQUAL "11")
    LIST(APPEND KOKKOS_CXX_FEATURES cxx_std_11)
    SET(KOKKOS_CXX_STANDARD "c++11")
  ELSEIF(${CMAKE_CXX_STANDARD} STREQUAL "14")
    LIST(APPEND KOKKOS_CXX_FEATURES cxx_std_14)
    SET(KOKKOS_CXX_STANDARD "c++14")
  ELSEIF(${CMAKE_CXX_STANDARD} STREQUAL "17")
    LIST(APPEND KOKKOS_CXX_FEATURES cxx_std_17)
    SET(KOKKOS_CXX_STANDARD "c++17")
  ENDIF()
ENDIF()


if (CMAKE_CXX_STANDARD)
  if (CMAKE_CXX_STANDARD STREQUAL "98")
    message(FATAL_ERROR "Kokkos requires C++11 or newer!")
  endif()
  set(KOKKOS_CXX_STANDARD "c++${CMAKE_CXX_STANDARD}")
  if (CMAKE_CXX_EXTENSIONS)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      set(KOKKOS_CXX_STANDARD "gnu++${CMAKE_CXX_STANDARD}")
    endif()
  endif()
endif()
#changed - allow user to directly set KOKKOS_CXX_STANDARD
set(KOKKOS_SETTINGS ${KOKKOS_SETTINGS} "KOKKOS_CXX_STANDARD=\"${KOKKOS_CXX_STANDARD}\"")

# Final form that gets passed to make
set(KOKKOS_SETTINGS env ${KOKKOS_SETTINGS})


############################ PRINT CONFIGURE STATUS ############################

if(KOKKOS_CMAKE_VERBOSE)
  message(STATUS "")
  message(STATUS "****************** Kokkos Settings ******************")
  message(STATUS "Execution Spaces")

  if(KOKKOS_ENABLE_CUDA)
    message(STATUS "  Device Parallel: Cuda")
  else()
    message(STATUS "  Device Parallel: None")
  endif()

  if(KOKKOS_ENABLE_OPENMP)
    message(STATUS "    Host Parallel: OpenMP")
  elseif(KOKKOS_ENABLE_PTHREAD)
    message(STATUS "    Host Parallel: Pthread")
  elseif(KOKKOS_ENABLE_QTHREADS)
    message(STATUS "    Host Parallel: Qthreads")
  elseif(KOKKOS_ENABLE_HPX)
    message(STATUS "    Host Parallel: HPX")
  else()
    message(STATUS "    Host Parallel: None")
  endif()

  if(KOKKOS_ENABLE_SERIAL)
    message(STATUS "      Host Serial: Serial")
  else()
    message(STATUS "      Host Serial: None")
  endif()

  message(STATUS "")
  message(STATUS "Architectures:")
  message(STATUS "    ${KOKKOS_GMAKE_ARCH}")

  message(STATUS "")
  message(STATUS "Enabled options")

  if(KOKKOS_SEPARATE_LIBS)
    message(STATUS "  KOKKOS_SEPARATE_LIBS")
  endif()

  foreach(opt IN LISTS KOKKOS_INTERNAL_ENABLE_OPTIONS_LIST)
    string(TOUPPER ${opt} OPT)
    if (KOKKOS_ENABLE_${OPT})
      message(STATUS "  KOKKOS_ENABLE_${OPT}")
    endif()
  endforeach()

  if(KOKKOS_ENABLE_CUDA)
    if(KOKKOS_CUDA_DIR)
      message(STATUS "  KOKKOS_CUDA_DIR: ${KOKKOS_CUDA_DIR}")
    endif()
  endif()

  if(KOKKOS_QTHREADS_DIR)
    message(STATUS "  KOKKOS_QTHREADS_DIR: ${KOKKOS_QTHREADS_DIR}")
  endif()

  if(KOKKOS_HWLOC_DIR)
    message(STATUS "  KOKKOS_HWLOC_DIR: ${KOKKOS_HWLOC_DIR}")
  endif()

  if(KOKKOS_MEMKIND_DIR)
    message(STATUS "  KOKKOS_MEMKIND_DIR: ${KOKKOS_MEMKIND_DIR}")
  endif()

  if(KOKKOS_HPX_DIR)
    message(STATUS "  KOKKOS_HPX_DIR: ${KOKKOS_HPX_DIR}")
  endif()

  message(STATUS "")
  message(STATUS "Final kokkos settings variable:")
  message(STATUS "  ${KOKKOS_SETTINGS}")

  message(STATUS "*****************************************************")
  message(STATUS "")
endif()
