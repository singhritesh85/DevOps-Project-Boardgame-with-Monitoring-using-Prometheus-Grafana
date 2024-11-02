# Monitoring-using-Prometheus-Grafana
![image](https://github.com/user-attachments/assets/7b7f4586-e968-42fd-88a3-58a0eb62498b)

This DevOps project aims to create the infrastructure for the project, establish the end-to-end CI/CD setup and its monitoring using Prometheus and Grafana (Prometheus and Grafana used as Monitoring Tool in this project). Jenkins was used as CI/CD Tool. For Code Quality check SonarQube, to keep the Artifacts Nexus and Maven was used as a Build Tool. Trivy was used as a Security Scanning tool, Docker Image was stored in ECR (Elastic Container Registry) and for deployment ArgoCD had been used. The high-level architecture diagram for the project is as shown above.

Prometheus and Grafana had been used as monitoring tool for this project. Node-Exporter will extract the metrics from the Jenkins-Master, Jenkins-Slave, SonarQube-Server, Nexus-Server, Prometheus Server, Blackbox-Exporter Server, Grafana-Server and EKS Cluster and send to the Prometheus Server. I had installed Blackbox Exporter on a different server and not on the Prometheus Server. Prometheus blackbox operator is used for endpoint monitoring (Synthetic Monitoring) across the protocol http, https, TCP and ICMP. In this project I am monitoring the Application URL https://boardgame.singhritesh85.com with the help of Prometheus Blackbox-Exporter. Prometheus blackbox exporter will send the metrics to Prometheus. For this project Prometheus acts as a DataSource for Grafana and send metrics to Grafana which we can see with the help of Charts and Graphs.  
