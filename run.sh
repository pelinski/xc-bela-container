docker build --no-cache -t xc-bela .     

docker run -it --name bela --env-file .devcontainer/devcontainer.env  -p 8888:8888 xc-bela
