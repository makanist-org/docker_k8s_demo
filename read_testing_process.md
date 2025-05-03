1. enable kubernetes od docker and make sure kubecontext is set to it. https://www.youtube.com/watch?v=8Fb8KuQehPk&list=PLRBkbp6t5gM00gLaQExFrvW0Ju-3ns7LH&index=3&ab_channel=CumulusCycles
2. test the node app and install requirmenets "npm init -y" and node server.js. stop server when done testing
3. Use docker bild to test image and use docker down to take it down.
4. Push image to docker hub and update k8 deployment.yaml with correct image reference fromd ocker hub. (if using eks here is reference https://www.youtube.com/watch?v=QiE6YpA5jk4&ab_channel=CumulusCycles)
5. run namespaces.yaml if you want to create the righ namesapce and then deployment.yaml
6. You might need to have secret to pull from docker hub or ECR depending on implementation.
7. once deployed test the working by load balncer url 

<!-- saiteja@Mac k8s % kubectl apply -f app-server-deployment.yaml
deployment.apps/app-server-deployment created
service/app-server-service unchanged -->

<!-- 
saiteja@Mac k8s % kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=makanist \
  --docker-password='*******PWD' \
  --docker-email=tejam1224@gmail.com \
  --namespace=docker-demo-namespace
secret/regcred created -->