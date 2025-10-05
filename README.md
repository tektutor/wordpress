# Rootless Wordpress container image for Kubernetes & Openshift

Supporting the OpenShift Community with Rootless Wordpress Image.

The open-source ecosystem thrives on choice and transparency. With Bitnami silently discontinuing their rootless Wordpress image on Docker Hub, many OpenShift users were left without a trusted, non-root alternative.

We provide a fully maintained rootless Wordpress container image, ready for OpenShift and other non-root environments, helping developers continue building secure and compliant containerized applications.

## Deploying Wordpress using this Container Image on Openshift
```
oc new-app --name wordpress tektutor/wordpress:1.0 \
  -e WORDPRESS_DB_HOST=mariadb \
  -e WORDPRESS_DB_USER=wordpress \
  -e WORDPRESS_DB_PASSWORD=-your-wordpress-dbserver-password \
  -e WORDPRESS_DB_NAME=wordpress
```
