# Connect Bela and checkout https://github.com/pelinski/Bela/tree/xc
FROM debian:bullseye
ENV DEBIAN_FRONTEND noninteractive

COPY scripts/*.sh scripts/build_settings ./
COPY CustomMakefile/* /tmp/

RUN ./build_packages.sh && rm build_packages.sh

RUN ./build_env.sh && rm build_env.sh

RUN ./build_libs.sh && rm build_libs.sh

RUN ./build_libbelafull.sh && rm build_libbelafull.sh && rm  tmp/CustomMakefile*

RUN ./build_bela.sh && rm build_bela.sh && rm build_settings

WORKDIR /workspace
COPY Toolchain.cmake workspace/

CMD /bin/bash