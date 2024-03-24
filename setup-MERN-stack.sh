#!/bin/bash
default_nodejs_version="alpine"
default_mongo_version="7.0.7"
default_nodejs_port=3000
default_mongo_port=27017

validate_port() {
    local port=$1

    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    if ((port < 1 || port > 65535)); then
        return 1
    fi

    return 0
}
while true; do
    echo "Please enter your project name*:"
    read name
    if [ -z "$name" ]; then
        continue
    else
        mkdir $name
        cd $name
        break
    fi
done

echo "Enter port number for MongoDB (default port $default_mongo_port):"
read mongo_port
if validate_port "$mongo_port"; then
    mongo_port="$mongo_port"
else
    mongo_port="$default_mongo_port"
fi

echo "Enter port number for nodejs (default port $default_nodejs_port):"
read nodejs_port
if validate_port "$nodejs_port"; then
    nodejs_port="$nodejs_port"
else
    nodejs_port="$default_nodejs_port"
fi

echo "Enter MongoDB version (default version $default_mongo_version):"
read mongo_version
if [ -z "$mongo_version" ]; then
    mongo_version="$default_mongo_version"
fi
echo "Enter Nodejs version (default version $default_nodejs_version):"
read nodejs_version
if [ -z "$nodejs_version" ]; then
    nodejs_version="$default_nodejs_version"
fi
yml="version: '3.8'
name: '$name'
services:
  mongodb:
    image: "mongo:$mongo_version"
    container_name: "$name-db"
    restart: always
    ports:
      - "$mongo_port:27017"
    volumes:
      - "./storage/db:/$name/db"
  nodejs:
    image: "node:$nodejs_version"
    container_name: "$name-app"
    working_dir: "/$name"
    ports:
      - "$nodejs_port:80"
    volumes:
      - ".:/$name"
    stdin_open: true
    tty: true
"
echo "$yml" >> docker-compose.yml
docker compose up -d ;docker exec -it $name-app npm init -y;docker exec -it $name-app npm install express mongoose
if [ $? -eq 0 ]; then
    echo "Containers created successfully"
    echo "MongoDB is running on monogd://localhost:$mongo_port"
    echo "Project setup successfully"
else
    echo "Command failed with error"
fi
