
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../unit_tests)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../../src)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../../src/Transfers)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../../src/Smoothers)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../../gallery)
INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/../../adapters/belos)

# first ensure that these cmake boolean variables are defined
ASSERT_DEFINED(
  ${PACKAGE_NAME}_ENABLE_Amesos
  ${PACKAGE_NAME}_ENABLE_Ifpack
  )

ASSERT_DEFINED(
  ${PACKAGE_NAME}_ENABLE_Amesos2
  )

IF (${PACKAGE_NAME}_ENABLE_Galeri AND ${PACKAGE_NAME}_ENABLE_Epetra)

  # TRIBITS_ADD_EXECUTABLE_AND_TEST(
  #     amesos2
  #     SOURCES amesos2.cpp
  #     ARGS ""
  #     COMM serial mpi
  #   )


  # TRIBITS_ADD_EXECUTABLE_AND_TEST(
  #     simple1D-mergedSmoo
  #     SOURCES mainMergedSmoo.cpp
  #     ARGS ""
  #     COMM serial mpi
  #   )

  # JJH: 9/3/2013 This test is failing.  Until Andrey fixes it, I'm allowing
  #               it to compile (for coverage) but not run.
  IF (${PACKAGE_NAME}_ENABLE_Belos)
  TRIBITS_ADD_EXECUTABLE(
    simple1D-Emin
    SOURCES Emin.cpp
    COMM serial mpi
    )
  ENDIF()
  
  # TRIBITS_ADD_EXECUTABLE_AND_TEST(
  #   simple1D-Emin
  #   SOURCES Emin.cpp
  #   ARGS ""
  #   COMM serial mpi
  #   )

  TRIBITS_ADD_EXECUTABLE(
    simple1D-UncoupledAggregation
    SOURCES simple1D-UncoupledAggregation.cpp
    )
    
  IF( ${PACKAGE_NAME}_ENABLE_Tpetra )
    TRIBITS_ADD_TEST(
      simple1D-UncoupledAggregation
      NAME "simple1D-UncoupledAggregation-Tpetra"
      ARGS "--linAlgebra=Tpetra"
      COMM serial mpi
      )
  ENDIF()

  IF( ${PACKAGE_NAME}_ENABLE_Epetra )
    TRIBITS_ADD_TEST(
      simple1D-UncoupledAggregation
      NAME "simple1D-UncoupledAggregation-Epetra"
      ARGS "--linAlgebra=Epetra"
      COMM serial mpi
      )
  ENDIF()
ENDIF()
