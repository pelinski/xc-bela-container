# NEEDS TO RUN WITH BELA CONNECTED TO THE HOST
FROM debian:bullseye
ENV DEBIAN_FRONTEND=noninteractive

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "running on $BUILDPLATFORM, building for $TARGETPLATFORM" 

ENV BELA_ROOT=/sysroot/root/Bela

COPY scripts/build_settings ./

COPY scripts/build_packages.sh ./
RUN ./build_packages.sh && rm build_packages.sh

COPY scripts/build_env.sh ./
RUN ./build_env.sh && rm build_env.sh

COPY CustomMakefile/Bela/CustomMakefile* /tmp/
COPY scripts/build_libbelafull.sh ./
RUN ./build_libbelafull.sh && rm build_libbelafull.sh && rm /tmp/CustomMakefile*
COPY Toolchain.cmake ${BELA_ROOT}/

COPY CustomMakefile/Docker/CustomMakefileTop.in ${BELA_ROOT}/

COPY scripts/build_libs.sh ./
RUN ./build_libs.sh && rm build_libs.sh

COPY scripts/build_bela.sh ./
RUN ./build_bela.sh && rm build_bela.sh && rm build_settings

COPY basic/render.cpp ${BELA_ROOT}/projects/basic/

WORKDIR /sysroot/root/

CMD /bin/bash