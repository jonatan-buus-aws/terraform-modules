#!/bin/bash
kubectl patch serviceaccount aws-node -n kube-system -p "{\"metadata\":{\"annotations\":{\"eks.amazonaws.com/role-arn\":\"$1\"}}}"