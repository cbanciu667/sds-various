#!/bin/bash

# debug faulty nodes with VPC CNI IRSA role issues
/etc/eks/bootstrap.sh infrastructure-eks-do6AboyJ --kubelet-extra-args \
'--node-labels=eks.amazonaws.com/nodegroup-image=ami-0c37e3f6cdf6a9007,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=on-demand-eks-compute-20220327085431434400000005,compute-profile=on-demand-eks-profile --max-pods=29' \
--b64-cluster-ca XXXXX --apiserver-endpoint https://3A68DE84CB25E8B.gr7.eu-central-1.eks.amazonaws.com \
--dns-cluster-ip 172.20.0.10 --use-max-pods false
sudo systemctl status kubelet

KUBELET_EXTRA_ARGS="--root-dir=/tmp/data/var/lib/kubelet --bootstrap-kubeconfig var/lib/kubelet/bootstrap-kubeconfig --node-labels=eks.amazonaws.com/nodegroup-image=ami-0a3da8b47de1d87b8,eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=eks-dev-on-demand-2023040315181210480000004b,compute-profile=eks-dev-on-demand --max-pods=29"
KUBELET_ARGS="--node-ip=10.10.10.10 --pod-infra-container-image=public.ecr.aws/eks-distro/kubernetes/pause:3.9 --v=2" 

kubelet \
--config etc/kubernetes/kubelet/kubelet-config.json \
--kubeconfig var/lib/kubelet/bootstrap-kubeconfig \
--container-runtime remote \
--container-runtime-endpoint unix:///run/containerd/containerd.sock \
--cert-dir /tmp/data/var/lib/kubelet/pki \
--root-dir /tmp/data/var/lib/kubelet \
$KUBELET_ARGS \
$KUBELET_EXTRA_ARGS

/tmp/data/aws-iam-authenticator token -i CLUSTER_NAME --region us-east-1

aws eks list-nodegroups --cluster-name eks-prod
aws eks describe-nodegroup --cluster-name eks-prod --nodegroup-name eks-prod-on-demand-20230330160731214700000003
aws eks list-updates --name eks-dev --region us-east-1
aws eks update-cluster-version --name eks-dev --region us-east-1 --kubernetes-version 1.27
aws eks describe-cluster --name eks-prod --region us-east-1
aws eks update-addon --cluster-name eks-dev --addon-name vpc-cni --addon-version v1.12.6-eksbuild.2 --resolve-conflicts OVERWRITE --region us-east-1
aws eks list-addons --cluster-name eks-dev --region us-east-1
aws eks describe-addon-versions --kubernetes-version 1.27 --addon-name vpc-cni --region us-east-1
aws eks list-nodegroups --cluster-name eks-dev --region us-east-1
aws eks describe-nodegroup --cluster-name eks-dev --nodegroup-name eks-dev-on-demand-2023041121255393420000004f --region us-east-1
aws eks update-nodegroup-version --cluster-name eks-prod --nodegroup-name eks-prod-on-demand-hm-20230411212457571400000035 --force --region us-east-1
aws eks delete-nodegroup --cluster-name eks-dev --nodegroup-name eks-dev-on-demand-hm-2023041121255392840000004d --region us-east-1
aws eks update-nodegroup-config --cluster-name eks-dev --nodegroup-name eks-dev-on-demand-2023041121255393420000004f --scaling-config minSize=10,maxSize=30,desiredSize=12