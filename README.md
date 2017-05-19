# Minishift Demo

The purpose of this repo is to demonstrate how Minishift and OpenShift can be used to develop software in a local development environment. 

## What is Minishift?

Minishift is a tool that lets you run the entire OpenShift platform locally in a virtual machine. [OpenShift](https://www.OpenShift.org/) is Red Hat's open source container platform based off [Kubernetes](https://kubernetes.io/). 

Minishift makes it simple to install and manage OpenShift in a self-contained environment, and serves as a great tool for learning about OpenShift without incurring any cost.

## Scope

This project shows how Minishift/OpenShift can potentially be used on a day-to-day basis in a local development workflow.

The project contains the following resources:

- A simple webserver written in Node.js.
- A manifest file that defines all of the resources needed to deploy the application in OpenShift.
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
├── OpenShift
│   └── minishift-demo.yaml
└── scripts
    ├── create-project.sh
    └── minishift-install.sh
```

## Getting started with Minishift

### Prerequisites
Minishift requires a hypervisor to run the virtual machine on which OpenShift installed. A number of hypervisors are supported but `virtualbox` is the most widely used within the community and is the most recommended option. Link to [official downloads page.](https://www.virtualbox.org/wiki/Downloads)

Depending on your host OS, you have a choice of the following hypervisors:

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

This interactive script downloads the latest release of Minishift, installs it in a location of your choice and starts the virtual machine using you chosen hypervisor. The default options `/usr/local/bin` and `virtualbox` are recommended. Hit return to choose the defaults.

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
-- Checking for OpenShift/origin:v1.5.0 image ...
   Pulling image OpenShift/origin:v1.5.0
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

Once the script is complete you can open the OpenShift web console using the command `minishift console`. You can login with `username: developer password: developer`

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
OpenShift v1.5.0+031cbe4
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
    OpenShift
    OpenShift-infra

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

This script takes `OpenShift/minishift-demo.yaml` - a template file that defines all the resources needed to run the application and passes it into the `oc` cli tool along with some additional parameters. This gets passed into the OpenShift cluster where the resources are created.

### Deployment

The intial build takes about 5 minutes and once it finishes, a deployment will start. The progress can be viewed in the Project Overview page in the web console. Once the deployment completes you should see the `hello-server` service is up and running and is available at an endpoint similar to `http://hello-server-minishift-demo.192.168.99.100.nip.io`. Follow the link in the browser, or make a request with `curl` and you should see the output `{"msg":"Hello World"}`

### Viewing Application logs

In the web console, use the side bar to navigate to `Application > Services` and select the `hello-server` service. From that page you should see a single running `pod`. A pod is a resource that a living container runs in. From here you should see a number of tabs such as `Details`, `Environment`, `Logs`, `Terminal` and `Events`. The logs of the running application can be viewed here.

### Instant Reload

Inside the running container, the `hello-server` application is being run with `nodemon` a simple utility that watches the source code and restarts the application whenever files are updated. Because our local source folder is mounted into the container as a volume, we can make local changes and nodemon will instantly see those changes and restart the application inside.

Changes can be tested easily using the `/version` endpoint. See commands below to request the endpoint:

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

Increment the version number and save the file. In the application logs you should see the application restart immediately.

## Challenges Faced

In a local development environment, it is critical that you can make code changes and execute them as quickly as possible. Being a production grade container platform, OpenShift's default deployment mechanism consists of a building a service into a Docker image and simultaneously rolling out that service out while the old version is scaled down.

This feature is spectacular in a live environment but takes too much time in a development environment. Instant feedback is needed. We faced a number of challenges as we worked towards a feasible solution. The `hello-server` service for testing our setup.

### Volume Mounts

We wanted to see code changes reflected immediately without having to rebuild a container. The solution was to build the container once, and mount the local source code as a volume in the running container. To do this:

1. The code has to be mounted into the Minishift VM.
2. From the VM it has to be mounted into the container.

Luckily Minishift creates a direct mapping of your local $HOME directory in the VM so we get the first part for free.

The next part was configured by defining a volume in `minishift-demo.yaml` 

```
volumes:
- name: app-volume
  hostPath:
    path: "${APP_VOLUME}"
```

Where `${APP_VOLUME}` is the local `hello-server` directory. This volume is mounted into the `/usr/src/app/bin` folder in the container.
```
volumeMounts:
- mountPath: /usr/src/app/bin
  name: app-volume
```

This made it possible to modify local code and have it update within the container.

### Instant Reload
We used the very popular [`nodemon`](https://www.npmjs.com/package/nodemon) utility to restart the application whenever code changes are made. Instead of being baked into the container, it's included as an application dependency along with an additional start command (`npn run start:dev`) in `package.json`. This approach was taken so the application's default behaviour is to run in a production mode without `nodemon`. In the `minishift-demo.yaml` file we override the container's default `CMD`:

```
# Taken from minishift-demo.yaml
  command:
  - npm
  - run
  - start:dev
```

There is **one caveat**. `nodemon` must be run in __legacy mode__ because it will not see changes inside a networked volume using the standard configuration. Legacy mode is provided for this exact use case. See nodemon [docs](https://www.npmjs.com/package/nodemon#application-isnt-restarting) for more info.

### Permissions Issues

As an enterprise platform, OpenShift is very security conscious and provides a standard configuration that makes perfect sense in a live environment. By default, containers do not have access to the filesystem on the underlying host so our solution of using volume mounts does not work out of the box.

All of the OpenShift components (e.g. registry, deployer, builder, application containers, etc) operate using a `service account`. Each project in OpenShift gets some default service accounts, as shown below:

```
$ oc get serviceaccounts
NAME       SECRETS   AGE
builder    2         19h
default    2         19h
deployer   2         19h
```

Service accounts and normal users have what are called `security context constraints` (SCC) attached to them. Essentially, they are policies that define a set of security rules. Multiple SCC's can be attached. There are a number of predefined SCCs out of the box

```
$ oc get scc
NAME               PRIV      CAPS      SELINUX     RUNASUSER          FSGROUP     SUPGROUP    PRIORITY   READONLYROOTFS   VOLUMES
anyuid             false     []        MustRunAs   RunAsAny           RunAsAny    RunAsAny    10         false            [configMap downwardAPI emptyDir persistentVolumeClaim secret]
hostaccess         false     []        MustRunAs   MustRunAsRange     MustRunAs   RunAsAny    <none>     false            [configMap downwardAPI emptyDir hostPath persistentVolumeClaim secret]
hostmount-anyuid   false     []        MustRunAs   RunAsAny           RunAsAny    RunAsAny    <none>     false            [configMap downwardAPI emptyDir hostPath nfs persistentVolumeClaim secret]
hostnetwork        false     []        MustRunAs   MustRunAsRange     MustRunAs   MustRunAs   <none>     false            [configMap downwardAPI emptyDir persistentVolumeClaim secret]
nonroot            false     []        MustRunAs   MustRunAsNonRoot   RunAsAny    RunAsAny    <none>     false            [configMap downwardAPI emptyDir persistentVolumeClaim secret]
privileged         true      []        RunAsAny    RunAsAny           RunAsAny    RunAsAny    <none>     false            [*]
restricted         false     []        MustRunAs   MustRunAsRange     MustRunAs   RunAsAny    <none>     false            [configMap downwardAPI emptyDir persistentVolumeClaim secret]
```

The service account we are interested in is the `default` service account as this one is used to run application containers unless specified otherwise. The `default` service account has the `restricted` SCC attached to it. To make our development environment less restrictive we attach the `hostaccess` and the `anyuid` policies to the `default` service account. This gives host access and allows the processes inside containers to run as the `root` user.

We attach these policies in `scripts/create-project.sh`:

```
# This adds anyuid and hostaccess security context constraints to default service account
# This is acceptable for a dev environment only
oc login -u system:admin
oc adm policy add-scc-to-user anyuid system:serviceaccount:$PROJECT:default
oc adm policy add-scc-to-user hostaccess system:serviceaccount:$PROJECT:default
```

For more information see the [official documentation on SCCs](https://docs.OpenShift.org/latest/admin_guide/manage_scc.html).

### Native Dependencies
With our solution, the entire application folder is mounted from the developer's machine into the container. This initially included the local `node_modules` folder, but we soon realised this wasn't feasible because of native dependencies. Native dependencies are generally compiled at the time of running `npm install`. 

A problem arises if a developer is using OSx or Windows and the application has native dependencies - their local `node_modules` folder simply won't be compatible inside a Linux container. Native modules are widely used and have to be supported.

Simply building the dependencies into the application's `node_modules` as part of the `docker build` wouldn't work because the entire app directory gets replaced when our local one is mounted in the container. However, we couldn't scrap the volumes idea either because we found it was the most reliable solution for instant reload. We wanted to install dependencies at build time to ensure native addons are compiled properly, **and** mount our local app code.

When you `require()` a dependency, `Node` obviously looks for it in the standard `node_modules` folder but it is possible to add additional search paths using the `$NODE_PATH` environment variable. See [node docs](https://nodejs.org/dist/latest-v6.x/docs/api/modules.html#modules_loading_from_the_global_folders).

We were able to tweak the `Dockerfile` to get a working solution. Here's a summary of what we did:

- Install the `node_modules` outside of the application folder.
- Set the `$NODE_PATH` environment variable to point to the external `node_modules` folder.
- Set the `$PATH` environment variable to point to the external `node_modules/.bin` folder to make executables like `nodemon` available.
- Because the standard `node_modules` location has highest priority, an empty volume is mounted there to ensure our local `node_modules` never ends up inside the container.

The one **caveat** of this solution is that any time dependencies need to be changed, a new build is needed. This is a tradeoff we're willing to make because the build times are still pretty fast.

