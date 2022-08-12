include_directories(/usr/local/include/signalrclient)

add_executable(hub-connection-sample
    HubConnectionSample.cpp
)

target_link_libraries(hub-connection-sample PRIVATE
    microsoft-signalr

    /root/workspace/SignalR-Client-Cpp/submodules/vcpkg/packages/cpprestsdk_x64-linux/lib/libcpprest.a
    /root/workspace/SignalR-Client-Cpp/submodules/vcpkg/installed/x64-linux/lib/libz.a
    /root/workspace/SignalR-Client-Cpp/submodules/vcpkg/installed/x64-linux/lib/libssl.a
    /root/workspace/SignalR-Client-Cpp/submodules/vcpkg/installed/x64-linux/lib/libcrypto.a

    dl
    pthread
    uuid
)

install(TARGETS hub-connection-sample DESTINATION bin)
