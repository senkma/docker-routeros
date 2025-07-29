# Mikrotik RouterOS in Docker

This project comprises a Docker image that runs a MikroTik's RouterOS
virtual machine inside QEMU.

It's designed to simulate MikroTik's RouterOS environment, making it an
excellent tool for development and testing purposes, especially for those
working with the RouterOS API.

This Docker image is particularly useful for unit testing the
[routeros-api-php](https://github.com/EvilFreelancer/routeros-api-php) library, allowing developers to test applications
in a controlled environment that closely mimics a real RouterOS setup.

For users seeking a fully operational RouterOS environment for production
use within Docker, the [VR Network Lab](https://github.com/plajjan/vrnetlab) project is recommended
as an alternative.

## Getting Started

### Quick Start (Local Development)

The easiest way to get RouterOS running locally is using the provided startup script:

```bash
git clone https://github.com/senkma/docker-routeros.git
cd docker-routeros
chmod +x start.sh
./start.sh
```

This will automatically:
- Check system requirements (KVM, TUN device)
- Build the RouterOS container
- Start the container with all necessary ports exposed
- Show connection information

### Manual Local Setup

If you prefer manual setup, you can use docker-compose directly:

```bash
# Build and start the container
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

### Production Deployment

For production deployment, use the production configuration:

```bash
# On your server
chmod +x deploy.sh
./deploy.sh
```

Or manually with production compose file:

```bash
export ROUTEROS_VERSION=7.16.1
docker-compose -f docker-compose.prod.yml up --build -d
```

### Automated Deployment with GitHub Actions

This repository includes GitHub Actions workflow for automated deployment. Set up these secrets in your GitHub repository:

- `SSH_PRIVATE_KEY`: Your SSH private key for server access
- `SERVER_HOST`: Your server hostname or IP
- `SERVER_USER`: Username for SSH connection

The workflow will automatically deploy to your server when you push to the master branch.

### Building from Source

To build a custom version with specific RouterOS version:

```bash
docker build --build-arg ROUTEROS_VERSION=7.16.1 -t routeros:custom .
docker run -d -p 2222:22 -p 8728:8728 -p 8729:8729 -p 5900:5900 -ti routeros:custom
```

After launching the container, you can access your RouterOS instance
via VNC (port 5900) and SSH (port 2222).

## Connection Information

Once the container is running, you can access RouterOS through various methods:

| Service | Local Port | Production Port | Description |
|---------|------------|-----------------|-------------|
| SSH | 2222 | 2222 | SSH access (admin/no password) |
| Telnet | 2223 | 2223 | Telnet access |
| HTTP | 8080 | 8080 | Web interface |
| HTTPS | 8443 | 8443 | Secure web interface |
| API | 8728 | 8728 | RouterOS API |
| API SSL | 8729 | 8729 | RouterOS API over SSL |
| VNC | 5900 | 5900 | VNC access for GUI |
| Winbox | 8291 | 8291 | Winbox access |

### Default Credentials
- **Username**: admin
- **Password**: (empty - no password)

### Connection Examples

```bash
# SSH connection
ssh admin@localhost -p 2222

# API connection (using routeros-api-php or similar)
$connection = new RouterOS\Client([
    'host' => 'localhost',
    'port' => 8728,
    'user' => 'admin',
    'pass' => ''
]);
```

## Exposed Ports

Additional ports available for RouterOS services:

| Description | Ports                                 |
|-------------|---------------------------------------|
| Defaults    | 21, 22, 23, 80, 443, 8291, 8728, 8729 |
| IPSec       | 50, 51, 500/udp, 4500/udp             |
| OpenVPN     | 1194/tcp, 1194/udp                    |
| L2TP        | 1701                                  |
| PPTP        | 1723                                  |

## Troubleshooting

### Common Issues

**Container fails to start with KVM errors:**
```bash
# Check if KVM is available
ls -la /dev/kvm

# Install KVM support (Ubuntu/Debian)
sudo apt install qemu-kvm
sudo usermod -a -G kvm $USER
# Logout and login again
```

**TUN device not found:**
```bash
# Load TUN module
sudo modprobe tun

# Make it persistent
echo 'tun' | sudo tee -a /etc/modules
```

**Container starts but RouterOS doesn't respond:**
- Wait longer (RouterOS can take 2-3 minutes to fully boot)
- Check container logs: `docker-compose logs -f`
- Verify all required devices are available

**Permission denied errors:**
- Make sure your user is in the `docker` group
- For KVM: add user to `kvm` group
- Check file permissions on scripts

## Links

For more insights into Docker and virtualization technologies
related to RouterOS and networking, explore the following resources:

* [Mikrotik RouterOS in Docker using Qemu](https://habr.com/ru/articles/498012/) - An article on Habr that provides a guide on setting up Mikrotik RouterOS in Docker using Qemu, ideal for developers and network engineers interested in RouterOS virtualization.
* [RouterOS API Client](https://github.com/EvilFreelancer/routeros-api-php) - GitHub repository for the RouterOS API PHP library, useful for interfacing with MikroTik devices.
* [VR Network Lab](https://github.com/vrnetlab/vrnetlab) - A project for running network equipment in Docker containers, recommended for production-level RouterOS simulations.
* [qemu-docker](https://github.com/joshkunz/qemu-docker) - A resource for integrating QEMU with Docker, enabling virtual machine emulation within containers.
* [QEMU/KVM on Docker](https://github.com/ennweb/docker-kvm) - Demonstrates using QEMU/KVM virtualization within Docker containers for improved performance.
