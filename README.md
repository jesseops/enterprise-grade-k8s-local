<!-- vim: set expandtab ts=4 sw=4 sts=4 tw=100: -->

# enterprise-grade-k8s-local
Pseudo Enterprise Grade Kubernetes - On a Laptop

> :warning: _Not Actually Enterprise Grade_

## The problem

Running a single Kubernetes cluster at home just isn't interesting enough. Sure, you may have moved
from nodeport services up to MetalLB, and thanks to an extra couple hard drives and Longhorn you've
got storage that doesn't require pinning Pods to a specific node. Heck, you've probably even decided
enough is enough and you've gotta have _something_ aside from your bash history keeping track of
your Helm installs, prompting you to get most of your stack redefined within Helmfile.

But now, aside from giving ever more resources to your kids creative Minecraft server, there's not
much to do except kick back and enjoy the clean browsing experience your PiHole deployment ensures
while Plex streams some Futurama episodes to the TV.

## The solution

It's time to take it to the next level. No more running a quick command to update a Helm release for
us; we're implementing _change management_. No longer will your _media_ applications blemish the
same cluster as your _infrastructure_! We're splitting out your `infra`, `prod`, and `test`
environments to their own clusters.

To keep this as approachable as possible, this lab is designed to run on a single machine. If your
laptop happens to melt while chewing through this well... Don't blame me, blame the manufacturers
chasing paper thin and feather light laptops instead of giving better battery life and usable
keyboards.

## The architecture

_pre-requisites_
A half-way decent workstation.

We'll spin up 3 clusters, each with their own set of "nodes". Each will expose the Kubernetes API to
a separate port on _localhost_. Most direct interaction will be with ArgoCD running on the `infra`
cluster, allowing it to handle the configuration of the `prod` and `test` clusters.

Each cluster will run MetalLB in ARP mode (BGP is nicer, but requires support in your home network).
Optionally, you can port-forward `:80` and `:443` to your `prod` cluster for external Ingress, or
use a public hosted VPS along with a tunnel. Bonus points to skip either and take advantage of Argo
Tunnels from Cloudflare (they're free!).

Finally, we will setup LinkerD & deploy the test application EmojiVoto to get some "live" traffic.

The result should be a questionably stable environment & a ton of fun!

## The tools

**k3s**
: For IoT, Edge computing, and just screwing around; [k3s](https://k3s.io/) is a full-on _certified_
Kubernetes distribution that will run anywhere.

**k3d**
: A handy "little helper", [k3d](https://k3d.io/) creates containerized k3s clusters - basically,
use Docker containers as cluster nodes.

**Terraform**
: From HashiCorp, [Terraform](https://www.terraform.io/) is a command line tool designed to turn
YAML into Cost (aka, Infrastructure as Code).

**ArgoCD**
: It's got a cute Octopus mascot and the docs say "GitOps" a bunch --
[ArgoCD](https://argoproj.github.io/argo-cd/) keeps your running Kubernetes cluster in sync with the
resource definitions stored in `git` (and yes, it's YAML all the way down).


# Lets do this!

## Terraform

Just build the things man!

```bash
cd terraform && terraform init && terraform apply
```

## Setup initial pieces

```bash
kubectl --kubeconfig terraform/infra*.kubeconfig apply -k argocd/argocd  # terraform can do this
kubectl --kubeconfig terraform/infra*.kubeconfig apply -k app_manager/infra
# do ^ for each cluster to get the common bits sync'd
```

## At this point we can
```bash
kubectl --kubeconfig ../terraform/infra-local-5a413c1635.kubeconfig \
  -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d

kubectl --kubeconfig ../../terraform/infra-local-5a413c1635.kubeconfig \
  -n argocd port-forward argocd-server-6f4fcdc5dc-czhnw 8080:8080
```

Login with admin and the password provided.

## err, probably need to configure docker networks somewhere...
