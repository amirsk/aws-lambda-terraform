#!/bin/bash

rm ./hello_world_lambda.zip
echo "Deleted existing zip"

java -version

# Compile Java code
javac HelloWorld.java
echo "Compiled"

# Create ZIP archive
zip hello_world_lambda.zip HelloWorld.class
echo "Zipped"

# Clean up the compiled class file
rm HelloWorld.class

echo "Lambda deployment package created: hello_world_lambda.zip"
