cmake_minimum_required(VERSION 2.8)
project(Capture)

# Check for C++11 (also works for icc/icpc)
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
elseif(COMPILER_SUPPORTS_CXX0X)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
else()
  message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

# Find OpenCV
find_package(OpenCV REQUIRED)

# Include Blackmagic SDK
set(BMDSDK_INCLUDES "../../deps/blackmagicSDK/include/")
set(BMDSDK_LIBS pthread dl)

include_directories(${BMDSDK_INCLUDES})
add_executable(Capture capture.cpp bmd/callback.cpp)
target_link_libraries(Capture ${NMDSDK_LIBS} ${OpenCV_LIBS})
