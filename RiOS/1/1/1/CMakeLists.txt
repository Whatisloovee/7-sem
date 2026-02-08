cmake_minimum_required(VERSION 3.10)
project(UDPTimeSync)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

include_directories(${CMAKE_SOURCE_DIR}/include)

add_executable(server src/server.cpp)
add_executable(client src/client.cpp)
add_executable(ntp_time_server src/ntp/ntp_time_server.cpp)
add_executable(ntp_time_client src/ntp/ntp_time_client.cpp)
add_executable(ptp_server src/p18/p18_server.cpp)
add_executable(ptp_client src/p18/p18_client.cpp)

file(MAKE_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)