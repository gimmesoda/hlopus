add_library(extension SHARED "extension.c")

if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET extension PROPERTY C_STANDARD 11)
endif()

set_target_properties(extension PROPERTIES
  OUTPUT_NAME "opus"
  SUFFIX ".hdll")

if (MSVC)
  target_compile_options(extension PRIVATE
    $<$<CONFIG:Release>:/O2>
    $<$<CONFIG:MinSizeRel>:/O1>
    $<$<CONFIG:MinSizeRel>:/Gy>
    $<$<CONFIG:MinSizeRel>:/Gw>)
  target_link_options(extension PRIVATE
    $<$<CONFIG:Release>:/OPT:REF>
    $<$<CONFIG:Release>:/OPT:ICF>
    $<$<CONFIG:MinSizeRel>:/OPT:REF>
    $<$<CONFIG:MinSizeRel>:/OPT:ICF>)
endif()

set(HASHLINK_ROOT "$ENV{HASHLINK}")
set(OPUSFILE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/opusfile")
set(OPUS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/opus")
set(VORBIS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/vorbis")

if (HASHLINK_ROOT STREQUAL "" OR NOT EXISTS "${HASHLINK_ROOT}")
  message(FATAL_ERROR "HASHLINK environment variable must point to your HashLink directory.")
endif()

file(GLOB OPUSFILE_SOURCES CONFIGURE_DEPENDS "${OPUSFILE_DIR}/*.c")
file(GLOB OPUS_SOURCES CONFIGURE_DEPENDS
  "${OPUS_DIR}/src/*.c"
  "${OPUS_DIR}/celt/*.c"
  "${OPUS_DIR}/silk/*.c"
  "${OPUS_DIR}/silk/float/*.c")
file(GLOB VORBIS_SOURCES CONFIGURE_DEPENDS "${VORBIS_DIR}/*.c")

set(VENDORED_SOURCES
  ${OPUSFILE_SOURCES}
  ${OPUS_SOURCES}
  ${VORBIS_SOURCES})

target_sources(extension PRIVATE
  ${VENDORED_SOURCES})

if (MSVC)
  set_source_files_properties(${VENDORED_SOURCES} PROPERTIES
    COMPILE_OPTIONS "/wd4244;/wd4267;/wd4305;/wd4996")
endif()

target_compile_definitions(extension PRIVATE
  OPUS_BUILD
  USE_ALLOCA
  HAVE_LRINTF
  HAVE_CONFIG_H)

target_include_directories(extension PRIVATE
  "${HASHLINK_ROOT}/include"
  "${OPUSFILE_DIR}"
  "${OPUS_DIR}/include"
  "${OPUS_DIR}"
  "${OPUS_DIR}/celt"
  "${OPUS_DIR}/silk"
  "${OPUS_DIR}/silk/float"
  "${VORBIS_DIR}")

if (NOT WIN32)
  find_library(HASHLINK_LIBRARY
    NAMES hl libhl
    PATHS
      "${HASHLINK_ROOT}"
      "${HASHLINK_ROOT}/bin"
      "${HASHLINK_ROOT}/lib")
else()
  set(HASHLINK_LIBRARY "${HASHLINK_ROOT}/libhl.lib")
endif()

if (NOT HASHLINK_LIBRARY)
  message(FATAL_ERROR "HashLink library not found. Set HASHLINK to your HashLink directory.")
endif()

target_link_libraries(extension PRIVATE "${HASHLINK_LIBRARY}")

if (NOT WIN32)
  target_link_libraries(extension PRIVATE m)
endif()

install(TARGETS extension
  RUNTIME DESTINATION .
  LIBRARY DESTINATION .
  ARCHIVE DESTINATION .)
