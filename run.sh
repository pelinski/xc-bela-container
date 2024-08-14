docker build --no-cache -t xc-bela--test .     

docker run -it --name bela--test -e BBB_HOSTNAME=192.168.7.2  -p 8888:8888 xc-bela--test
