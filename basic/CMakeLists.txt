cmake_minimum_required(VERSION 3.18)

if(NOT DEFINED PROJECT_NAME)
    set(PROJECT_NAME "project")
endif()

project(${PROJECT_NAME})

####################################

add_compile_options(
    -march=armv7-a
    -mtune=cortex-a8
    -mfloat-abi=hard
    -mfpu=neon
    -Wno-psabi
)

add_compile_options(
    -O3
    -g 
    -fPIC
    -ftree-vectorize
    -ffast-math
)

add_compile_definitions(DXENOMAI_SKIN_posix)

####################################

set(BELA_ROOT "${CMAKE_SYSROOT}/root/Bela") 
set(SYS_ROOT "${CMAKE_SYSROOT}")

find_library(COBALT_LIB REQUIRED
    NAMES cobalt libcobalt
    HINTS "${CMAKE_SYSROOT}/usr/xenomai/lib"
)

find_library(NEON_LIB REQUIRED
    NAMES NE10 libNE10
    HINTS "${CMAKE_SYSROOT}/usr/lib"
)

find_library(MATHNEON_LIB REQUIRED
    NAMES mathneon libmathneon
    HINTS "${CMAKE_SYSROOT}/usr/lib"
)

####################################

set(EXE_NAME ${PROJECT_NAME})

file(GLOB SRC_FILES *.cpp)

# If main.cpp is not found, append default_main.cpp
list(FIND SRC_FILES main.cpp main_index)
if(main_index EQUAL -1)
    list(APPEND SRC_FILES ${BELA_ROOT}/core/default_main.cpp)
endif()

add_executable(${EXE_NAME} ${SRC_FILES})

target_include_directories(
    ${EXE_NAME} PRIVATE ${BELA_ROOT} ${BELA_ROOT}/include
)

target_link_libraries(
    ${EXE_NAME}
    PRIVATE
    ${BELA_ROOT}/lib/libbelafull.so
    ${COBALT_LIB}
    ${NEON_LIB}
    ${MATHNEON_LIB}
    dl
    prussdrv
    asound
    atomic
    sndfile
    pthread
    rt
)