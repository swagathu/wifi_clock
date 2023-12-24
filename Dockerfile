FROM ubuntu:22.04 as ubuntuimage

ARG USERID=1000
ARG GROUPID=1000
ARG USERNAME="user"
ARG GROUPNAME="thegroup"

USER root

ENTRYPOINT [ "build.sh" ]
WORKDIR /wifi_clock


RUN apt-get update -y && apt-get -y upgrade

RUN apt-get install -y unzip
RUN apt-get install -y make
RUN apt-get install -y git
RUN apt-get install -y gcc
RUN apt-get install -y python3
RUN apt-get install -y python3-pip

RUN pip3 install pyserial

RUN groupadd -g ${GROUPID} ${GROUPNAME}
RUN useradd -u ${USERID} -g ${GROUPID} ${USERNAME}
RUN ln -s $(which python3) /usr/bin/python


USER ${USERNAME}

ENV PATH="/usr/bin"
