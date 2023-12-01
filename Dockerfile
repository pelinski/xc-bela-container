# Connect Bela and checkout https://github.com/pelinski/Bela/tree/xc
FROM debian:bullseye
ENV DEBIAN_FRONTEND noninteractive

COPY scripts/build_bela.sh \
	scripts/build_packages.sh \
	scripts/build_env.sh \
	scripts/build_settings \
	./

RUN ./build_packages.sh && rm build_packages.sh
RUN ./build_bela.sh && rm build_bela.sh && rm build_settings
RUN ./build_env.sh && rm build_env.sh

RUN apt-get update && \
      apt-get install -y python3 pipenv

WORKDIR /workspace

RUN git clone --recurse-submodules -j8  https://github.com/pelinski/pybela-pytorch-xc-tutorial.git

WORKDIR /workspace/pybela-pytorch-xc-tutorial

RUN pipenv install

RUN pipenv run pip3 install torch 

# CMD [ "pipenv", "run","jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
CMD /bin/bash