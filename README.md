# Minishift Demo
The purpose of this repo is to demonstrate how Minishift and OpenShift can be used to develop software in a local development environment. This repo has changed since we wrote the original [blog post](http://www.nearform.com/nodecrunch/minishift-development-environment-node-js-projects-openshift-kubernetes/)

Two points of difference with our recent update.  We no longer use volumnes tied to the local host and we also switched to using a nearform supported image of node. Hot syncing the files is still supported with these changes.

## Minishift Setup
If you dont have minishift setup these steps work on **High Sierra version 10.13.4 (17E199)**
```
$ brew install docker-machine-driver-xhyve
$ sudo chown root:wheel /usr/local/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
$ sudo chmod u+s /usr/local/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
$ brew cask install minishift
$ minishift start
...
  OpenShift server started.

  The server is accessible via web console at:
      https://192.168.64.2:8443

  You are logged in as:
      User:     developer
      Password: <any value>

  To login as administrator:
      oc login -u system:admin
```
Minishift also installs the OpenShift command line client on your local machine. By default it is not placed in the `PATH` so a little extra configuration is needed. Simply run `eval $(minishift oc-env)`. This adds the installation folder to the path for the current terminal session.
```
$ eval $(minishift oc-env)
$ oc version
  oc v3.7.2+282e43f
  kubernetes v1.7.6+a08f5eeb62
  features: Basic-Auth

  Server https://192.168.64.2:8443
  openshift v3.7.2+5eda3fa-5
  kubernetes v1.7.6+a08f5eeb62
  ```
For a more permanent solution, run `minishift oc-env` and paste the output into your `~/.bash_profile` or `~/.bashrc`.

### Create the Project
We can now create the `minishift-demo` project using the `scripts/create-project.sh` script. This script will do the following:
1. Create a project/namespace in OpenShift named minishift-demo
2. Load configurations for our
  * Images
  * Builds
  * Services
  * Routes
  * Deployments
3. Build our Image
4. Deploy our Build

All of the objects created in the project will be named or prefixed with hello-server. Our script will let you know when the deployment has finished.  It should be available fairly quickly. Once you see:
```
replication controller "hello-server-X" successfully rolled out
```
You should be able to open the route listed [here](http://hello-server-minishift-demo.192.168.64.3.nip.io/).  A succesful deployment will respond on the URL with 
```
{msg: "Hello World"}
```
### Redeploying Chages
A second script is provided that will do just the build and deployments steps of our create script. 
```
$ sh scripts/build.sh
```
### Syncing on Local Changes
To still maintain a local working development environment like previously mentioned where we used volumes, we switch to using the following commands.  This will sync a local directory (i.e. ./hello-server) to a running pod.
#### one-time sync
```
oc rsync {local directory} {pod name}:{path within pod}

oc rsync ./hello-server/ hello-server-7-hrlld:/opt/app-root/src
```
#### Hot Watch
Since we have nodemon in play our server will restart every time changes are introduced.  To synch every change in a continuous fashion use the command above with the `--watch` flag appended.
```
oc rsync ./hello-server/ hello-server-7-hrlld:/opt/app-root/src --watch
```
### Viewing Application logs
In the web console, use the side bar to navigate to `Application > Services` and select the `hello-server` service. From that page you should see a single running `pod`. A pod is a resource that a living container runs in. From here you should see a number of tabs such as `Details`, `Environment`, `Logs`, `Terminal` and `Events`. The logs of the running application can be viewed here.

You can also use the OC CLI.  You first need to know your pod's name
```
$ oc get pods
NAME                    READY     STATUS      RESTARTS   AGE
...
hello-server-35-build   0/1       Completed   0          30m
hello-server-4-9b286    1/1       Running     0          30m

$ oc logs hello-server-4-9b286
...
```
You should see a message saying the server is listening on port `8080`.  You can also add the `-f` flag to follow logs.

