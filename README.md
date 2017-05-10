# Minishift

Minishift is a tool that helps you run OpenShift locally by running a single-node OpenShift cluster inside a VM. You can try out OpenShift or develop with it, day-to-day, on your local host.

Minishift uses libmachine for provisioning VMs, and OpenShift Origin for running the cluster.

## Getting started with Minishift

### Installing Minishift

#### Prerequisites
Minishift requires a hypervisor to start the virtual machine on which the OpenShift cluster is provisioned. Make sure that the hypervisor of your choice is installed and enabled on your system before you start Minishift. 

Depending on your host OS, you have the choice of the following hypervisors:

**Mac OS X**
- xhyve
- VirtualBox
- VMware Fusion

*xhyve requires specific installation and configuration steps that are described in the Installing Docker machine drivers section.*


**GNU/Linux**
- KVM
- VirtualBox

*KVM requires specific installation and configuration steps that are described in the Installing Docker machine drivers section.
Note: it is recommend to use VirtualBox due to the good support of the community around and the compatibility with both OSX and Linux.*

Default parameters for the virtual machine:
- 2 Virtual CPU
- 2 GB of RAM
- 20 GB of space disk

Steps:

- Clone the repository https://github.com/nearform/minishift-demo
- Run the script `dev-build.sh` located under minishift/bin
The script will spin up a Virtual Machine in the chosen hypervisor which run OpenShift Origin. Furthermore it will copy under your $HOME directory the folder .kube which maintain the config to connect to the Kubernetes cluster.

*Note: if you already have a pre-existent configuration under kube, the new configuration will be added to the existing config file.*

## Templates

A template describes a set of objects that can be parameterized and processed to produce a list of objects for creation by OpenShift. The objects to create can include anything that users have permission to create within a project, for example services, build configurations, and deployment configurations. A template may also define a set of labels to apply to every object defined in the template.

OpenShift mantains an official [repository](https://github.com/openshift/library) where it is possible to find templates. Also community templates are available and submitted periodically. The common ones are already available in Minishift.

