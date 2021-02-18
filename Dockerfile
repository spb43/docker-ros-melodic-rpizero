FROM arm32v5/debian

RUN apt update && apt install vim gnupg \
    python-rosdep python-rosinstall-generator \
    python-wstool python-rosinstall build-essential cmake \
    python-defusedxml python-netifaces ca-certificates \
    python-empy python3-empy python-setuptools python3-setuptools \
    python-pip -y

RUN pip install pycryptodome gnupg

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    apt update && apt upgrade -y && \
    rosdep init && \
    rosdep update 
RUN mkdir -p /ros_catkin_ws/src && cd /ros_catkin_ws && rosinstall_generator ros_comm --rosdistro melodic --deps --wet-only --tar > melodic-ros_comm-wet.rosinstall && \
    wstool init src melodic-ros_comm-wet.rosinstall
RUN cd /ros_catkin_ws && rosdep install -y --from-paths src --skip-keys='sbcl' --ignore-src --rosdistro melodic

WORKDIR /ros_catkin_ws
RUN ./src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/melodic 

SHELL ["/bin/bash", "-c"]
CMD . /opt/ros/melodic/setup.bash && roscore
