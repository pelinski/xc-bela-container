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
      apt-get install -y \
				python3 \
				pipenv

WORKDIR /workspace

RUN git clone https://github.com/pelinski/pyBela-AIMC-tutorial.git

WORKDIR /workspace/pyBela-AIMC-tutorial

RUN pipenv install

RUN pipenv run pip3 install torch -index-url https://download.pytorch.org/whl/cpu

CMD [ "pipenv", "run","jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]