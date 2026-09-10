# syntax=docker/dockerfile:1

FROM docker.io/library/debian:trixie-slim
LABEL org.opencontainers.image.authors="ak1ra-lab" \
      org.opencontainers.image.source="https://github.com/ak1ra-lab/docker-debian-ansible" \
      org.opencontainers.image.description="Debian 13 (Trixie) container for Ansible playbook and role testing." \
      org.opencontainers.image.licenses="MIT"

# Install dependencies.
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo systemd systemd-sysv udev \
       build-essential wget libffi-dev libssl-dev procps \
       python3-pip python3-dev python3-setuptools python3-wheel python3-apt \
       iproute2 dbus \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Allow installing Python packages into the system interpreter, then install Ansible.
RUN --mount=type=cache,target=/root/.cache/pip \
    rm -f /usr/lib/python3*/EXTERNALLY-MANAGED \
    && python3 -m pip install --break-system-packages ansible cryptography

COPY --chmod=0755 initctl_faker /initctl_faker

# Configure initctl, the Ansible inventory, and disable systemd gettys.
RUN ln -sf /initctl_faker /sbin/initctl \
    && mkdir -p /etc/ansible \
    && printf '[local]\nlocalhost ansible_connection=local\n' > /etc/ansible/hosts \
    && rm -f /lib/systemd/system/multi-user.target.wants/getty.target

STOPSIGNAL SIGRTMIN+3

CMD ["/lib/systemd/systemd"]
