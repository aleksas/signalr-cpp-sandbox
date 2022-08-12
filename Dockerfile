FROM debian:buster-slim as config

FROM config as dev

RUN mkdir -p /root/workspace \
    && apt-get update \
    && apt-get -y install build-essential gdb git curl zip unzip tar pkg-config uuid-dev

RUN ARCH=$(uname -m) && curl -k -L "https://github.com/Kitware/CMake/releases/download/v3.22.4/cmake-3.22.4-linux-${ARCH}.sh" --output /tmp/curl.sh
RUN bash /tmp/curl.sh --skip-license

RUN git clone https://github.com/aspnet/SignalR-Client-Cpp /root/workspace/SignalR-Client-Cpp \
    && git -C /root/workspace/SignalR-Client-Cpp submodule update --init \
    && /root/workspace/SignalR-Client-Cpp/submodules/vcpkg/bootstrap-vcpkg.sh \
    && /root/workspace/SignalR-Client-Cpp/submodules/vcpkg/vcpkg install cpprestsdk[websockets]:x64-linux boost-system:x64-linux boost-chrono:x64-linux boost-thread:x64-linux

RUN cmake -S /root/workspace/SignalR-Client-Cpp -B /root/workspace/SignalR-Client-Cpp-build \
        -DCMAKE_TOOLCHAIN_FILE=/root/workspace/SignalR-Client-Cpp/submodules/vcpkg/scripts/buildsystems/vcpkg.cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTINGE=false \
        -DUSE_CPPRESTSDK=true \
        -DBUILD_SHARED_LIBS=OFF \
    && cmake --build /root/workspace/SignalR-Client-Cpp-build --config Release --target install -- -l

FROM dev as src

COPY . /root/workspace/signalr-sandbox

FROM src as build

ARG BUILD_TYPE=Release

RUN cmake -E make_directory /root/workspace/signalr-sandbox-build \
    && cmake -S /root/workspace/signalr-sandbox -B /root/workspace/signalr-sandbox-build \
        -DCMAKE_INSTALL_PREFIX=/deploy \
        -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
RUN cmake --build /root/workspace/signalr-sandbox-build --target install  -- -l

FROM config AS deploy

COPY --from=build /deploy/ /usr/

ENTRYPOINT ["/usr/bin/hub-connection-sample"]
