## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

![Network Diagram](Images/Azure-Diagram.png?raw=true)

This document contains the following details:
- Links to the Configuration and Playbook files used
- Description of the Topology
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select playbook files may be used to install only certain pieces of it, such as Filebeat or Metricbeat.

### Ansible Configuration Files
[Ansible Configuration File](ansible/ansible.cfg)
[Ansible Hosts File](ansible/hosts)

### VM Image Playbooks
[Install DVWA](ansible/files/install-dvwa.yml)
[Install Elk](ansible/files/install-elk.yml)
[Install nginx](ansible/files/install-nginx.yml)

### Filebeat Configuration Files
[Standard Filebeat Configuration](ansible/files/filebeat-configuration.yml)
[Elk Server Filebeat Configuration](ansible/files/filebeat-configuration-elk.yml)

### Metricbeat Configuration Files
[Standard Metricbeat Configuration](ansible/files/metricbeat-configuration.yml)
[Elk Server Metricbeat Configuration](ansible/files/metricbeat-configuration-elk.yml)

### Filebeat Installation Playbooks
[DVWA Playbook](ansible/roles/filebeat-playbook-dvwa.yml)
[Elk Playbook](ansible/roles/filebeat-playbook-elk.yml)
[Jump Box Playbook](ansible/roles/filebeat-playbook-jb.yml)
[nginx Playbook](ansible/roles/filebeat-playbook-nginx.yml)

### Metricbeat Installation Playbooks
[DVWA Playbook](ansible/roles/metricbeat-playbook-dvwa.yml)
[Elk Playbook](ansible/roles/metricbeat-playbook-elk.yml)
[Jump Box Playbook](ansible/roles/metricbeat-playbook-jb.yml)
[nginx Playbook](ansible/roles/metricbeat-playbook-nginx.yml)



### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

- Load balancing ensures that the application will be highly available, in addition to restricting access to the network.
- Load balancers protect availability by forwarding traffic from the same front end ip address to multiple backend machines configured the same.
- A jump box is used to provision these machines remotely without the need for physical access to the machines, multiple machines can be provisioned at one time allowing services to scale to demand with relative ease, once the extra resources are no longer needed they can be removed.

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the Docker containers and system logs.
- Filebeat monitors system logs
- Metricbeat monitors Docker container health and resources

The configuration details of each machine may be found below.

| Region   | Name                 | Function    | IP Address(es)          | Operating System     |
|----------|----------------------|-------------|-------------------------|----------------------|
| West US  | Jump-Box-Provisioner | Provisioner | 52.160.123.175,10.0.1.4 | Linux - Ubuntu 18.04 |
| West US  | DVWA-VM1             | Webserver   | 10.0.1.5                | Linux - Ubuntu 18.04 |
| West US  | DVWA-VM2             | Webserver   | 10.0.1.9                | Linux - Ubuntu 18.04 |
| West US  | WebServ-VM1          | Webserver   | 10.1.1.4                | Linux - Ubuntu 18.04 |
| East US  | WebServ-VM2          | Webserver   | 10.1.1.5                | Linux - Ubuntu 18.04 |
| East US  | WebServ-VM3          | Webserver   | 10.1.1.6                | Linux - Ubuntu 18.04 |
| East US  | WebServ-VM4          | Webserver   | 10.1.1.7                | Linux - Ubuntu 18.04 |
| West US 2| ELK-W2-VM            | ELK Server  | 52.229.20.51,10.2.0.4   | Linux - Ubuntu 18.04 |


### Access Policies

The machines on the internal network are not exposed to the public Internet. 

The Jump-Box-Provisioner machine can accept SSH connections from the Internet. Access to this machine is only allowed from the following IP addresses:
- "My Home Network Public IP" ## This IP Address is the only address the Jump Box will accept SSH connections from. 
The Elk Server Machine has only one internet facing port open (ELK-WebServ-Port). Access to this machine is only allowed from the following IP addressess:
- "My Home Network Public IP" ## This IP Address is the only address the Elk server will accept connections from.
- Machines within the network can only be accessed by the Jump-Box-Provisioner except the ELK-W2-VM that has the same access restrictions as the Jump-Box-Provisioner. 
- The Load balancer forwards external traffic from the internet to port 80 on the DVWA and WebServ machines.  
- Every machine in the network reports back to the Elk server through the internal network.  This communication is possible accross regions by peering the virtual networks together, each regional Vnet peers with the other two regions Vnets. [Azure Vnet Peering](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)


A summary of the access policies in place can be found in the table below.

| Priority | Name                 | Port(s)   | Protocol        | Source                              | Destination                         | Action |
|----------|----------------------|-----------|-----------------|-------------------------------------|-------------------------------------|--------|
|          |                      |           | West US Rules   |                                     |                                     |        |
|          |                      |           |                 |                                     |                                     |        |
| 4020     | DVWA-LB-Port-Forward | 80        | TCP             | Internet                            | 10.0.1.5,10.0.1.9                   | Allow  |
| 4050     | SSH-from-home        | 22        | TCP             | 'Home Network Public IP"            | 10.0.1.4                            | Allow  |
| 4075     | Jump-Box-SSH-to-VN   | 22        | 22              | 10.0.1.4                            | 10.0.1.5,10.0.1.9                   | Allow  |
| 4096     | Block-All            | Any       | Any             | Any                                 | Any                                 | Deny   |
|          |                      |           |                 |                                     |                                     |        |
|          |                      |           | East US Rules   |                                     |                                     |        |
|          |                      |           |                 |                                     |                                     |        |
| 4020     | WebServ-Port-Forward | 80        | TCP             | Internet                            | 10.1.1.4,10.1.1.5,10.1.1.6,10.1.1.7 | Allow  |
| 4080     | Jump-Box-SSH         | 22        | TCP             | 10.0.1.4                            | 10.1.1.4,10.1.1.5,10.1.1.6,10.1.1.7 | Allow  |
| 4096     | Block-All            | Any       | Any             | Any                                 | Any                                 | Deny   |
|          |                      |           |                 |                                     |                                     |        |
|          |                      |           | West US 2 Rules |                                     |                                     |        |
|          |                      |           |                 |                                     |                                     |        |
| 4055     | ELK-Ports-nginx      | 9200,5601 | TCP             | 10.1.1.4,10.1.1.5,10.1.1.6,10.1.1.7 | 10.2.0.4                            | Allow  |
| 4060     | ELK-WebServ-Port     | 5601      | TCP             | "Home Network Public IP"            | 10.2.0.4                            | Allow  |
| 4065     | ELK-from-Jump-Box    | 9200,5601 | TCP             | 10.0.1.4                            | 10.2.0.4                            | Allow  |
| 4070     | ELK-Ports-DVWA       | 9200,5601 | TCP             | 10.0.1.5,10.0.1.9                   | 10.2.0.4                            | Allow  |
| 4075     | SSH-from-Jump-Box    | 22        | TCP             | 10.0.1.4                            | 10.2.0.4                            | Allow  |
| 4096     | Block-All            | Any       | Any             | Any                                 | Any                                 | Deny   |


### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because you can deploy multiple ELK machines for monitoring different blocks of VMs, one Elk server for webservers, one for Databases, one for another block of webservers hosting a different website, etc.


The playbook implements the following tasks:[Install Elk](ansible/files/install-elk.yml)
- Installs Docker
- Installs pip
- Installs the docker module for python
- Configures the system memory of the Virtual machine
- Installs the docker container from a docker image and opens specified ports

The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

[Docker ps Output](Images/Elk-Docker-ps.png)

### Target Machines & Beats
This ELK server is configured to monitor the following machines:

| Region   | Name                 | IP Address          |
|----------|----------------------|-------------------------|
| West US  | Jump-Box-Provisioner | 10.0.1.4                |
| West US  | DVWA-VM1             | 10.0.1.5                |
| West US  | DVWA-VM2             | 10.0.1.9                |
| West US  | WebServ-VM1          | 10.1.1.4                |
| East US  | WebServ-VM2          | 10.1.1.5                |
| East US  | WebServ-VM3          | 10.1.1.6                |
| East US  | WebServ-VM4          | 10.1.1.7                |
| West US 2| ELK-W2-VM            | 10.2.0.4                |

We have installed the following Beats on these machines:
- Filebeat
- Metricbeat

These Beats allow us to collect the following information from each machine:
- Filebeat collects system logs in this use case, it can also be configured to log data from webserver and database logs.
- In this use case Metricbeat is configured to record performance and health metrics for docker containers, Network IO, Memory Usage, CPU Usage, Images and names of containers, and number of containers per name.

### Using the Playbooks
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:
- Copy the desired playbook(s) files to /etc/ansible/roles/ or /etc/ansible/files. I will be using these locations in the following walkthrough.
- Update the hosts file to include the IP address of the target machine under the hosts group i.e. [elkservers] for the Elk machine
- Run the playbook, and navigate to the Public IP of the Elk VM on port 5601 to check that the installation worked as expected. 
In my case it would look like 52.229.20.51:5601. 

### Configuring Ansible on your Jump-Box
Please install Docker and create a Ansible container with these commands (replace apt with your package manager if different)
I will be using absolute paths throughout to make this walk through beginner friendly, If you know what you're doing go ahead and do your thing!

- Make sure you apt repository is up to date
`sudo apt update && sudo apt upgrade -y`

- Install docker and verify it is running
`sudo apt docker.io`
`service docker status` 

- Pull the Ansible docker image
`sudo docker pull cyberxsecurity/ansible`

- Launch the Container and name it Ansible
`sudo docker --name Ansible -ti cyberxsecurity/ansible:latest /bin/bash`

- Your shell prompt should have changed! You are now in your brand new ansible container!

### Configuring DVWA VM's
- Ensure that your hosts file has the proper IP addresses for the DVWA VM's before continuing. We are going to run the install-dvwa.yml playbook with this command.
`ansible-playbook /etc/ansible/files/install-dvwa.yml`

- Once the playbook completes you should be able to SSH into the container and run `curl localhost/setup.php`. You should see some HTML printed to the screen. Pointing a browser at `DVWA.ip.add.ress` or the address of you load balancer should display a login page.

### Configuring ELK VM
- Once again make sure the IP address of your ELK VM is in the proper place in the [hosts](ansible/hosts) file and run the playbook
`ansible-playbook /etc/ansible/files/install-elk.yml` now navigating to the ELK VM IP address on port 5601 should load the kibana page. `ELK.ip.add.ress:5601`

### Configuring Default NGINX containers
- This will install an nginx container on a VM with just the default welcome to nginx page, nothing special here.
`ansible-playbook /etc/ansible/files/install-nginx.yml` point your browser at `nginx.ip.add.ress` or the load balancer ip address and you should see the Welcome to NGINX page displayed.

Now that we have the proper containers deployed and running in our VM's we can move on to installing the beats.

### Beats Installation

- Filebeat Installation
The installation process is very similar for the DVWA, Jump-Box and NGINX vm's so I will only cover one, simply choose the desired playbook to install the filebeat service on different VM types, there are different playbooks for the different hosts designated in the [hosts](ansible/hosts) file. All three use the same [Filebeat-Configuration](ansible/files/filebeat-configuration.yml) file that needs to be modified.  On lines 1105 and 1805 the IP addresses need to be changed to your ELK servers IP, leave the port the same. Once that is correct you can run the playbook with the command
`ansible-playbook /etc/ansible/roles/filebeat-playbook-dvwa.yml` 

For installation on the ELK VM the IP addresses at lines 1105 and 1805 should say `localhost` instead, this will point the log monitor at itself instead of a different VM. Since the [Filebeat Configuration](ansible/files/filebeat-configuration-elk.yml) file is different and we are pointing at a different host we will run the [ELK Playbook](ansible/roles/filebeat-playbook-elk.yml) with the same `ansible-playbook` command like this
`ansible-playbook /etc/ansible/roles/filebeat-configuration-elk.yml`

- Metricbeat Installation
This is the exact same process as the Filebeat installation. The [Metricbeat Configuration](ansible/files/metricbeat-configuration.yml) is the same for all three Host VM types (DVWA, Jump-box and NGINX) and must be modified on line 62 and 96 to point to the ELK VM IP addresss, leave the port the same. Then run the playbook
`ansible-playbook /etc/ansible/roles/metricbeat-playbook-dvwa.yml`

For the ELK VM change lines 62 and 96 to `localhost` in the [Metricbeat Configuration](ansible/files/metricbeat-configuration-elk.yml) file instead of an IP address, this has the same reasoning as the changes made to the Filebeat Configuration file. Run the playbook
`ansible-playbook /etc/ansible/roles/metricbeat-playbook-elk.yml`

You should now have a working ELK stack and be able to customize a Kibana dashboard to your liking. [Here's mine](Images/Kibana-Dashboard.png)
