cmake_minimum_required(VERSION 3.17)

project(gpu-burn LANGUAGES CUDA CXX)

include(CheckLanguage)
check_language(CUDA)

if(NOT DEFINED CMAKE_CUDA_STANDARD)
    set(CMAKE_CUDA_STANDARD 11)
    set(CMAKE_CUDA_STANDARD_REQUIRED ON)
endif()

if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 11)
    set(CMAKE_CXX_STANDARD_REQUIRED True)
endif()

if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 62)
endif()

find_package(CUDAToolkit)

add_library(compare OBJECT compare.cu)
set_target_properties(compare PROPERTIES CUDA_PTX_COMPILATION ON)

add_executable(gpu-burn gpu_burn-drv.cpp)
target_link_libraries(gpu-burn
    PRIVATE CUDA::cudart CUDA::cuda_driver CUDA::cublas)

install(TARGETS gpu-burn DESTINATION bin)
install(TARGETS compare DESTINATION share)

