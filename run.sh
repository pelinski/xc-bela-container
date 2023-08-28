docker build -t xc-bela-container-ws .     

docker run -it --name bela --env-file .devcontainer/devcontainer.env  -p 8888:8888 xc-bela-container-ws
