#!/bin/bash
set -e

echo "=== Updating system packages ==="
apt-get update
apt-get upgrade -y

echo "=== Installing Java 21 and dependencies ==="
apt-get install -y openjdk-21-jdk curl gnupg ca-certificates

java -version
update-java-alternatives -s java-21-openjdk-amd64 || true

echo "=== Adding Jenkins repository ==="
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | apt-key add -
echo "deb https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "=== Installing Jenkins ==="
apt-get update
apt-get install -y jenkins

echo "=== Configuring Jenkins JAVA_HOME ==="
echo "JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64" >> /etc/default/jenkins
echo "JENKINS_JAVA_CMD=/usr/bin/java" >> /etc/default/jenkins

echo "=== Creating Jenkins init scripts ==="
mkdir -p /var/lib/jenkins/init.groovy.d

# Create admin user setup script
cat > /var/lib/jenkins/init.groovy.d/00-create-admin.groovy << 'GROOVY_EOF'
import hudson.security.HudsonPrivateSecurityRealm
import hudson.security.FullControlOnceLoggedInAuthorizationStrategy
import jenkins.model.Jenkins
import jenkins.install.InstallState

def instance = Jenkins.get()
if (instance.getSecurityRealm() instanceof HudsonPrivateSecurityRealm) return

println("Creating Jenkins admin user...")
def realm = new HudsonPrivateSecurityRealm(false)
realm.createAccount("admin", "gaurav@123")
instance.setSecurityRealm(realm)
instance.setAuthorizationStrategy(new FullControlOnceLoggedInAuthorizationStrategy())
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.save()
GROOVY_EOF

# Create plugin installation script
cat > /var/lib/jenkins/init.groovy.d/01-install-plugins.groovy << 'GROOVY_EOF'
import jenkins.model.Jenkins
import java.util.logging.Logger

def logger = Logger.getLogger("jenkins.init")
def instance = Jenkins.get()
def uc = instance.getUpdateCenter()
def pluginIds = [
  "git",
  "workflow-aggregator",
  "credentials",
  "mailer",
  "matrix-auth",
  "ssh-slaves",
  "pipeline-stage-view",
  "blueocean",
  "job-dsl",
  "docker-plugin",
  "cloudbees-folder"
]

logger.info("Installing recommended Jenkins plugins: " + pluginIds.toString())
pluginIds.each { id ->
  if (!instance.pluginManager.getPlugin(id)) {
    def plugin = uc.getPlugin(id)
    if (plugin) {
      logger.info("Deploying plugin " + id)
      plugin.deploy().get()
    } else {
      logger.info("Plugin " + id + " not found in update center")
    }
  }
}
instance.save()
GROOVY_EOF

chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d

echo "=== Setting Jenkins permissions ==="
chown -R jenkins:jenkins /var/lib/jenkins
chown -R jenkins:jenkins /var/log/jenkins
chown -R jenkins:jenkins /var/cache/jenkins

echo "=== Starting Jenkins ==="
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

sleep 10

echo "=== Jenkins Status ==="
systemctl status jenkins || true

echo "=== Installation Complete ==="
