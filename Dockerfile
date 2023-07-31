# Use a builder image for installing google cloud sdk
FROM python:3.8-slim-buster

# Accept the user ID and group ID as build arguments
ARG UID=1000
ARG GID=1000
ARG USER=user

WORKDIR /install

# Create a group and user with the provided IDs, and create a home directory for the user
RUN groupadd -r ${USER} -g ${GID} && \
    useradd -r -g ${USER} -u ${UID} -m -d /home/${USER} -s /bin/bash ${USER} && \
    chown -R ${USER}:${USER} /home/${USER}

WORKDIR /workdir

# Copy the local workdir directory to the Docker image
COPY . /workdir

# Install Python packages
RUN pip install --no-cache-dir -r requirements.txt

# Change the ownership of the workdir directory to our user and group
RUN chown -R ${USER}:${USER} /workdir

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Change to our non-root user and set the home directory
USER ${USER}
ENV HOME=/home/${USER}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
