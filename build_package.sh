#!/usr/bin/env bash

##########################
# download ant from :
#   https://ant.apache.org

MVN="$(which mvn)"
if [ ! -z "${MAVEN_HOME}" ]; then
    echo MAVEN_HOME: ${MAVEN_HOME}
    MVN="${MAVEN_HOME}/bin/mvn"
fi

if [ -z "$MVN" ]; then
    echo "maven not found."
    exit 1
fi

# Get Java Major Version
JAVA_VER=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
echo "Detected Java Major Version: $JAVA_VER"

if [ -z "$JAVA_VER" ]; then
    echo "Java is not installed or not in PATH."
    exit 1
fi

$MVN -Dmaven.test.skip=true clean install

# 8 이상 21 미만인 경우 (JDK 8+ 프로필)
if [ "$JAVA_VER" -ge 8 ] && [ "$JAVA_VER" -lt 21 ]; then
    echo "JDK 8~20 detected. Building java-8-plus profile"
    $MVN -Dmaven.test.skip=true -f ./scouter.agent.java/pom.xml -Pjava-8-plus package
# 21 이상인 경우 (JDK 21+ 프로필)
elif [ "$JAVA_VER" -ge 21 ]; then
    echo "JDK 21+ detected. Building java-21-plus profile"
    $MVN -Dmaven.test.skip=true -f ./scouter.agent.java/pom.xml -Pjava-21-plus package
fi

$MVN -Dmaven.test.skip=true -f ./scouter.deploy/pom.xml clean package