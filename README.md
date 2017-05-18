# Minishift Demo

The purpose of this repo is to demonstrate how Minishift and Openshift can be used to develop software in a local development environment. 

## What is Minishift?

Minishift is a tool that lets you run the entire Openshift platform locally in a virtual machine. [Openshift](https://www.openshift.org/) is Red Hat's open source container platform based off [Kubernetes](https://kubernetes.io/). 

Minishift makes it simple to install and manage Openshift in a self-contained environment, and serves as a great tool for learning about Openshift without incurring any cost.

## Scope

This project shows how Minishift/Openshift can potentially be used on a day-to-day basis in a local development workflow.

The project contains the following resources:

- A simple webserver written in Node.js.
- A manifest file that defines all of the resources needed to deploy the application in Openshift.
- Scripts to install and start Minishift, and to create the project resources.

The structure is as follows:

```
.
├── README.md
├── hello-server
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── index.js
│   └── package.json
├── openshift
│   └── minishift-demo.yaml
└── scripts
    ├── create-project.sh
    └── minishift-install.sh
```

## Getting started with Minishift

### Prerequisites
Minishift requires a hypervisor to run the virtual machine on which OpenShift installed. A number of hypervisors are supported but `virtualbox` is the most widely used within the community and is the most recommended option. Link to [official downloads page.](https://www.virtualbox.org/wiki/Downloads)

Depending on your host OS, you have the choice of the following hypervisors:

**Mac OS X**
- VirtualBox
- VMware Fusion
- xhyve

**GNU/Linux**
- VirtualBox
- KVM

The default parameters for the virtual machine are:
- 2 Virtual CPU
- 2 GB of RAM
- 20 GB of space disk

### Install and Start Minishift:

With an appropriate hypervisor installed, Minishift can be installed and started as follows:

- Clone this repository https://github.com/nearform/minishift-demo
- `cd` into the `scripts` directory and run `./minishift-install.sh`

This interactive script downloads the latest release of Minishift, installs it in a location of your choice and starts the virtual machine using a hypervisor of your choice. The default options `/usr/local/bin` and `virtualbox` are recommended. Simply hit enter to select the default options.

The script will spin up a Virtual Machine and install OpenShift Origin inside. You should see output similar to that below.

```
scripts (master) $ ./minishift-install.sh
(1/4) Installing minishift...
(2/4) Where do you want to copy the executable? (default: /usr/local/bin)
# Return
(3/4) Which hypervisor do you want to use? (recommended: virtualbox)?
(xhyve, virtualbox, vmware-fusion)
# Return
(4/4) minishift start --vm-driver virtualbox
Starting local OpenShift cluster using 'virtualbox' hypervisor...
Downloading ISO 'https://github.com/minishift/minishift-b2d-iso/releases/download/v1.0.2/minishift-b2d.iso'
 40.00 MiB / 40.00 MiB [===================================================================================================================] 100.00% 0s
Downloading OpenShift binary 'oc' version 'v1.5.0'
 18.93 MiB / 18.93 MiB [===================================================================================================================] 100.00% 0s
-- Checking OpenShift client ... OK
-- Checking Docker client ... OK
-- Checking Docker version ... OK
-- Checking for existing OpenShift container ... OK
-- Checking for openshift/origin:v1.5.0 image ...
   Pulling image openshift/origin:v1.5.0
   Pulled 0/3 layers, 3% complete
   Pulled 0/3 layers, 35% complete
   Pulled 1/3 layers, 63% complete
   Pulled 1/3 layers, 92% complete
   Pulled 2/3 layers, 98% complete
   Pulled 3/3 layers, 100% complete
   Extracting
   Image pull complete
-- Checking Docker daemon configuration ... OK
-- Checking for available ports ... OK
-- Checking type of volume mount ...
   Using Docker shared volumes for OpenShift volumes
-- Creating host directories ... OK
-- Finding server IP ...
   Using 192.168.99.100 as the server IP
-- Starting OpenShift container ...
   Creating initial OpenShift configuration
   Starting OpenShift using container 'origin'
   Waiting for API server to start listening
   OpenShift server started
-- Adding default OAuthClient redirect URIs ... OK
-- Installing registry ... OK
-- Installing router ... OK
-- Importing image streams ... OK
-- Importing templates ... OK
-- Login to server ... OK
-- Creating initial project "myproject" ... OK
-- Removing temporary directory ... OK
-- Checking container networking ... OK
-- Server Information ...
   OpenShift server started.
   The server is accessible via web console at:
       https://192.168.99.100:8443

   You are logged in as:
       User:     developer
       Password: developer

   To login as administrator:
       oc login -u system:admin
```

Once the script is complete you can open the openshift web console using the command `minishift console`. You can login with `username: developer password: developer`

#### An Additional Note
Minishift also installs the OpenShift command line client on your local machine. By default it is not placed in the `PATH` so a little extra configuration is needed. Simply run `eval $(minishift oc-env)`. This adds the installation folder to the path for the current terminal session.

For a more permanent solution, run `minishift oc-env` and paste the output into your `~/.bash_profile` or `~/.bashrc`.

Before proceeding to the next step, ensure you can run the following command:

```
$ oc version
oc v1.5.0+031cbe4
kubernetes v1.5.2+43a9be4
features: Basic-Auth

Server https://192.168.99.100:8443
openshift v1.5.0+031cbe4
kubernetes v1.5.2+43a9be4
```

### Create the Project
We can now create the `minishift-demo` project using the `scripts/create-project.sh` script.

```
scripts (master) $ ./create-project.sh
Creating demo application...
==========================
(1/4) Applying extra permissions...
Logged into "https://192.168.99.100:8443" as "system:admin" using existing credentials.

You have access to the following projects and can switch between them with 'oc project <projectname>':

    default
    kube-system
  * myproject
    openshift
    openshift-infra

Using project "myproject".
Logged into "https://192.168.99.100:8443" as "developer" using existing credentials.

You have one project on this server: "myproject"

Using project "myproject".
==========================
(2/4) Creating new project...
==========================
(3/4) Deploying hello-server...
service "hello-server" created
route "hello-server" created
deploymentconfig "hello-server" created
imagestream "hello-server" created
buildconfig "hello-server" created
(4/4) Building hello-server Image
Uploading directory "/Users/dara/dev/minishift-demo/hello-server" as binary input for the build ...
build "hello-server-2" started

# Stream of Build Output
```

This script takes `openshift/minishift-demo.yaml` - a template file that defines all the resources needed to run the application and passes it into the `oc` command line tool along with some additional parameters. This gets passed into the OpenShift cluster, the resources are created and starts the first build.

### Deployment

The intial build takes about 5 minutes and once it finishes, a deployment will start. The progress can be viewed in the Project Overview page in the web console. Once the deployment completes you should see the `hello-server` service is up and running and is available at an endpoint similar to `http://hello-server-minishift-demo.192.168.99.100.nip.io`. Follow the link in the browser, or make a request with `curl` and you should see the output `{"msg":"Hello World"}`

### Viewing Application logs

In the web console, use the side bar to navigate to `Application > Services` and select the `hello-server` service. From that page you should see a single running `pod`. A pod is a resource that a living container runs in. From here you should see a number of tabs such as `Details`, `Environment`, `Logs`, `Terminal` and `Events`. The logs of the running application can be viewed here.

### Instant Reload

Inside the running container, the `hello-server` application is being run with `nodemon` a simple utility that watches the source code and restarts the application whenever files are updated. Because our local source folder is mounted into the container as a volume, we can make local changes and nodemon will instantly see those changes and restart the application inside.

To make it easy to test this we have provided a `/version` endpoint. See commands below to request the endpoint:

```
$ oc get routes
NAME           HOST/PORT                                           PATH      SERVICES       PORT      TERMINATION   WILDCARD
hello-server   hello-server-minishift-demo.192.168.99.100.nip.io             hello-server   <all>                   None

curl http://hello-server-minishift-demo.192.168.99.100.nip.io/version
{"version":"1.1"}
```

Now open `hello-server/index.js` and find the following block of code:

```js
server.get('/version', function (req, res, next){
  res.json({ version: '1.1' })
  
  return next()
})
```

Increment the version number and save the file. In the application logs you should see the application restart.

### Application Dependencies

## Templates

A template describes a set of objects that can be parameterized and processed to produce a list of objects for creation by OpenShift. The objects to create can include anything that users have permission to create within a project, for example services, build configurations, and deployment configurations. A template may also define a set of labels to apply to every object defined in the template.

OpenShift mantains an official [repository](https://github.com/openshift/library) where it is possible to find templates. Also community templates are available and submitted periodically. The common ones are already available in Minishift.

