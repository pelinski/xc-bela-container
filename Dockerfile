# NEEDS TO RUN WITH BELA CONNECTED TO THE HOST
FROM debian:bullseye
ENV DEBIAN_FRONTEND=noninteractive

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "running on $BUILDPLATFORM, building for $TARGETPLATFORM" 

COPY scripts/build_settings ./

COPY scripts/build_packages.sh ./
RUN ./build_packages.sh && rm build_packages.sh

COPY scripts/build_env.sh ./
RUN ./build_env.sh && rm build_env.sh
COPY CustomMakefile/CustomMakefileTop.in /sysroot/root/Bela/

COPY scripts/build_libs.sh ./
RUN ./build_libs.sh && rm build_libs.sh

COPY scripts/build_bela.sh ./
RUN ./build_bela.sh && rm build_bela.sh && rm build_settings

COPY example-project/* /sysroot/root/Bela/projects/basic/

WORKDIR /sysroot/root/
COPY Toolchain.cmake ./

CMD /bin/bash